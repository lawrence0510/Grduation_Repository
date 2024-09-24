import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
from datetime import datetime, timedelta
import json

load_dotenv()

# 建立資料庫連接
def create_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DATABASE_HOST'),
            user=os.getenv('DATABASE_USER'),
            password=os.getenv('DATABASE_PASSWORD'),
            database=os.getenv('DATABASE_NAME')
        )
        return connection
    except Error as e:
        print(f"Error: '{e}'")
        return None

def get_question1_answer(json_data):
    answer_key = f"question1_choice{json_data['question1_answer']}"
    return json_data.get(answer_key, '')
def get_question2_answer(json_data):
    answer_key = f"question2_choice{json_data['question2_answer']}"
    return json_data.get(answer_key, '')
def get_question3_answer(json_data):
    answer_key = f"question3_choice{json_data['question3_answer']}"
    return json_data.get(answer_key, '')

def get_max_article_id(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT MAX(article_id) FROM `Article`")
    result = cursor.fetchone()
    max_id = result[0] if result[0] is not None else 0
    cursor.close()
    return max_id

def get_max_question_id(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT MAX(question_id) FROM `Question`")
    result = cursor.fetchone()
    max_question_id = result[0] if result[0] is not None else 0
    cursor.close()
    return max_question_id

# 插入資料的函數
def insert_article(json_data, article_category, article_grade):
    connection = create_db_connection()
    if connection is None:
        return
    
    try:
        cursor = connection.cursor()

        # 計算 article_expired_day 為今天日期 + 60 天
        article_expired_day = (datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

        # 插入到 Article 表格
        article_sql = """
        INSERT INTO Article (article_id, article_title, article_link, article_category, article_content, article_grade, article_pass, article_expired_day, article_note, check_time)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, CURDATE())
        """

        article_id = get_max_article_id(connection) + 1

        cursor.execute(article_sql, (
            article_id,
            json_data['article_title'], 
            '',  # article_link 留空
            article_category, 
            json_data['article_content'], 
            article_grade, 
            1,  # article_pass = 1
            article_expired_day,  # 設定為今天 + 60 天
            ''  # article_note 留空
        ))

        # 根據 question3_answer 找到對應的選項內容
        question1_final_answer = get_question1_answer(json_data)
        question2_final_answer = get_question2_answer(json_data)
        question3_final_answer = get_question3_answer(json_data)

        question_id = get_max_question_id(connection) + 1

        # 插入到 Question 表格
        question_sql = """
                                    INSERT INTO `Question`(
                                        `question_id`, `article_id`, `question_grade`, `question_1`, `question1_choice1`, 
                                        `question1_choice2`, `question1_choice3`, `question1_choice4`, 
                                        `question1_answer`, `question1_explanation`, `question_2`, 
                                        `question2_choice1`, `question2_choice2`, `question2_choice3`, 
                                        `question2_choice4`, `question2_answer`, `question2_explanation`, 
                                        `question3`, `question3_answer`
                                    ) VALUES (
                                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                                    )
                                    """

        # 處理 None 值顯式替換為 None
        cursor.execute(question_sql, (
            question_id,
            article_id,
            article_grade, 
            json_data['question_1'], 
            json_data['question1_choice1'], 
            json_data['question1_choice2'], 
            json_data['question1_choice3'], 
            json_data['question1_choice4'], 
            question1_final_answer, 
            '',
            json_data['question_2'], 
            json_data['question2_choice1'], 
            json_data['question2_choice2'], 
            json_data['question2_choice3'], 
            json_data['question2_choice4'], 
            question2_final_answer, 
            '',
            json_data['question_3'], 
            question3_final_answer  # 插入對應的 question3_answer 內容
        ))

        # 提交更改
        connection.commit()

        print("資料插入成功")

    except Error as e:
        print(f"Error: '{e}'")
        connection.rollback()
    
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

# 循環輸入 JSON 資料
categories = "Social"
age = 13

json_data = {
    "article_title": "慈濟志工的慈善理念",
    "article_content": "慈濟是臺灣最大的慈善團體，慈濟志工在發送物資或紅包給低收入戶或災民時，總是用雙手奉上，避免受贈者有『被救濟』的感覺。他們稱災民為『感恩戶』，認為這代表『感恩讓我們有機會付出』。慈濟的理念是『人人一律平等』，並不因為施予救濟而感到自己更高級，災民僅是暫時處於困境。",
    "question_1": "慈濟志工發放物資給災民的主要目的是什麼？",
    "question1_choice1": "協助實現災民理想",
    "question1_choice2": "平撫心理創傷",
    "question1_choice3": "維持基本生存",
    "question1_choice4": "促進災民自我發展",
    "question_2": "慈濟志工為何要向災民致謝？",
    "question2_choice1": "救濟物資供應充足",
    "question2_choice2": "維護災民心理尊嚴",
    "question2_choice3": "志工從事救災有高回報",
    "question2_choice4": "災民有回報義務",
    "question_3": "面對災民，國中生應如何表現出正確的態度？",
    "question3_choice1": "待成年後再幫助他人",
    "question3_choice2": "不關我們的事",
    "question3_choice3": "加入志工行列",
    "question3_choice4": "節省零用錢捐助慈善機構",
    "question1_answer": "3",
    "question2_answer": "2",
    "question3_answer": "4"
}












insert_article(json_data, categories, age)
