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
categories = "Chinese"
age = 15

json_data = {
    "article_title": "船難",
    "article_content": "我疲倦的仰躺在艉甲板上嘆氣，獲救的希望如泡沫般已經破滅。天空灰雲輾轉翻滾，我想著家人，想著小孩，再次自責昨夜看見燈塔時沒把握機會游泳回家。 天色陰沉轉暗，船隻幾次打旋後，我困頓疲乏的迷失在茫茫大海裡。湧浪擊打船舷，衝出飛揚的細沫水煙，風力漸增，海上薄霧隨風飄散，這時，我再次看到岸緣迷濛的山頭，看到了那峭壁上的白點，我失去控制，對著白點大聲嚷叫，心裡盪出一股決心—我要活著回去！ 頹倒在船尾甲板上綁著衣衫的延繩釣旗桿隨風震顫了一下。我眼前一亮，那是風暴前颳起的東北風，我心裡頭點著了一盞燈，我只要在甲板上豎起一支風帆，東北風有機會將我帶回岸邊。 拉起浮力袋，拆掉袋子縫線，我動手造帆。風暴就要來臨，時間就是生命。每一分每一秒，我在心裡和風暴追逐。 那天天黑前，我扯緊桅繩豎起風帆。帆面旋即迎風鼓漲，船尖衝浪昂起，如魚得水。我感覺船隻重拾動力伸手展腳的歡喜。我深深喘出一口長氣，船隻擺脫束縛飛快衝出。 風力呼嘯急猛，風帆下緣甩擺急打著明快的節奏，湧浪汩聳若山，船隻順風斜身騎壓著海面崎嶇波折。隨著船行輕快，崖壁白點迅速膨脹如一根指頭大小……然後，如一條胳膊粗壯。天色全暗時，崖壁白點已飛撲在岸緣天空，如一襲張著懷抱的白衣幽靈。（廖鴻基 船難）",
    "question_1": "文中的「我」如何升起製作風帆的念頭？",
    "question1_choice1": "看到岸邊的山頭，看到了峭壁上的白點",
    "question1_choice2": "看見綁著衣衫的延繩釣旗桿隨風震顫了一下",
    "question1_choice3": "風暴即將來臨，隨著時間流逝獲救的希望越來越小",
    "question1_choice4": "我想著家人，想著小孩，想要靠自己的力量回家",
    "question_2": "岸壁上的白點大小為何在文中不停的變換？",
    "question2_choice1": "「我」離岸壁越來越近",
    "question2_choice2": "「我」產生了臆症",
    "question2_choice3": "「我」瀕臨死亡",
    "question2_choice4": "「我」感覺自己將衝破枷鎖",
    "question_3": "關於「我」的敘述，下列何者正確？",
    "question3_choice1": "「我」的船運行良好，但是「我」在海上迷失了方向",
    "question3_choice2": "「我」看見白色幽靈，是因為「我」快死了",
    "question3_choice3": "「我」在進行極限運動，想要測試自己生存能力",
    "question3_choice4": "「我」發生了船難，依靠製作的風帆回歸陸地",
    "question1_answer": "2",
    "question2_answer": "1",
    "question3_answer": "4"
}









insert_article(json_data, categories, age)
