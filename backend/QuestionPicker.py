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
age = 15

json_data = {
    "article_title": "贖罪券與宗教改革",
    "article_content": "「錢幣叮噹投進捐獻箱，靈魂應聲出煉獄！」是十六世紀的一句行銷口號，天主教教會以此遊說信徒捐獻，信徒深信購買教會的贖罪券可以為自己或旁人買到更多希望。",
    "question_1": "西元1517年，批評贖罪券並提出《九十五條論綱》的是下列何人？",
    "question1_choice1": "喀爾文",
    "question1_choice2": "羅耀拉",
    "question1_choice3": "亨利八世",
    "question1_choice4": "馬丁路德",
    "question_2": "此人之所以能快速將其神學觀點散布至德意志地區，擴張宗教改革的影響力，應該歸因於下列何者？",
    "question2_choice1": "印刷術",
    "question2_choice2": "德語《聖經》",
    "question2_choice3": "信而得救",
    "question2_choice4": "預選說",
    "question_3": "天主教教會面對宗教改革的聲浪，卻能成功贏回部分信徒的信心，該怎麼描述天主教教會的改革？",
    "question3_choice1": "教義上堅持教宗的權威，實務上接受改革",
    "question3_choice2": "教務上堅持贖罪券公用，教義上廢除教宗",
    "question3_choice3": "教義上接受因信而稱義，實務上堅持傳統",
    "question3_choice4": "教務上出現耶穌會改革，教義上廢除教宗",
    "question1_answer": "4",
    "question2_answer": "1",
    "question3_answer": "1"
}













insert_article(json_data, categories, age)
