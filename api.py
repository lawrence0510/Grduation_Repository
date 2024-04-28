from openai import OpenAI
from flask import Flask, session, jsonify
from flask_restx import Api, Resource, reqparse
import mysql.connector
from mysql.connector import Error
import hashlib
from datetime import datetime, timedelta
from werkzeug.datastructures import FileStorage
import pandas as pd
import json
from tqdm import tqdm
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.secret_key = '5b52b65660fc4c498fe0ed356fdc5212'
api = Api(app, version='1.0', title='Graduation_Repository APIs',
          description='110級畢業專案第一組\n組員：吳堃豪、侯程麟、謝佳蓉、許馨文、王暐睿\n指導教授：洪智鐸')


def create_db_connection():
    try:
        connection = mysql.connector.connect(
            host='140.119.19.145',
            user='lawrence',
            password='25352Riigdii',
            database='graduation_repository'
        )
        return connection
    except Error as e:
        print(f"Error: '{e}'")
        return None


user_parser = reqparse.RequestParser()
user_parser.add_argument('user_name', type=str, required=True, help='使用者名稱')
user_parser.add_argument('user_password', type=str,
                         required=True, help='使用者密碼')
user_parser.add_argument('user_school', type=str, required=True, help='使用者學校')
user_parser.add_argument('user_age', type=int, required=True, help='使用者年齡')
user_parser.add_argument('user_email', type=str,
                         required=True, help='使用者email')
user_parser.add_argument('user_phone', type=str, required=True, help='使用者電話')

login_parser = reqparse.RequestParser()
login_parser.add_argument('user_name', type=str, required=True, help='使用者名稱')
login_parser.add_argument('user_password', type=str,
                          required=True, help='使用者密碼')

user_id_parser = reqparse.RequestParser()
user_id_parser.add_argument('user_id', type=int, required=True, help='使用者ID')

email_reset_parser = reqparse.RequestParser()
email_reset_parser.add_argument(
    'original_email', type=str, required=True, help='使用者舊email')
email_reset_parser.add_argument(
    'original_password', type=str, required=True, help='使用者密碼')
email_reset_parser.add_argument(
    'new_email', type=str, required=True, help='使用者新email')

password_reset_parser = reqparse.RequestParser()
password_reset_parser.add_argument(
    'user_email', type=str, required=True, help='使用者email')
password_reset_parser.add_argument(
    'original_password', type=str, required=True, help='使用者舊密碼')
password_reset_parser.add_argument(
    'new_password', type=str, required=True, help='使用者新密碼')

phone_reset_parser = reqparse.RequestParser()
phone_reset_parser.add_argument(
    'user_email', type=str, required=True, help='使用者email')
phone_reset_parser.add_argument(
    'user_password', type=str, required=True, help='使用者密碼')
phone_reset_parser.add_argument(
    'new_phone', type=str, required=True, help='使用者新電話號碼')

name_reset_parser = reqparse.RequestParser()
name_reset_parser.add_argument(
    'user_email', type=str, required=True, help='使用者email')
name_reset_parser.add_argument(
    'user_password', type=str, required=True, help='使用者密碼')
name_reset_parser.add_argument(
    'new_name', type=str, required=True, help='使用者新名稱')

school_reset_parser = reqparse.RequestParser()
school_reset_parser.add_argument(
    'user_email', type=str, required=True, help='使用者email')
school_reset_parser.add_argument(
    'user_password', type=str, required=True, help='使用者密碼')
school_reset_parser.add_argument(
    'new_school', type=str, required=True, help='新學校名稱')

article_upload_parser = reqparse.RequestParser()
article_upload_parser.add_argument('file', type=FileStorage, location='files',
                                   required=True, help='可以上傳Excel檔案，格式要是|article_title|article_link|article_content|')

get_questions_parser = reqparse.RequestParser()
get_questions_parser.add_argument(
    'article_id_start', type=int, required=True, help='欲產生問題之第一個文章編號')
get_questions_parser.add_argument(
    'article_id_end', type=int, required=True, help='欲產生問題之最後一個文章編號')

get_rate_parser = reqparse.RequestParser()
get_rate_parser.add_argument(
    'article_id', type=int, required=True, help='原文文章id')
get_rate_parser.add_argument('answer', type=str, required=True, help='回答')


# User api區
user_ns = api.namespace('User', description='與使用者操作相關之api')


@user_ns.route('/get_all_user')
class DataList(Resource):
    def get(self):
        '''取得所有User資料'''
        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT * FROM `User`")
            data = cursor.fetchall()
            cursor.close()
            connection.close()
            return data
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/register')
class RegisterUser(Resource):
    @user_ns.expect(user_parser)
    def post(self):
        '''註冊新用戶'''
        args = user_parser.parse_args()
        user_name = args['user_name']
        user_password = args['user_password']
        user_school = args['user_school']
        user_age = args['user_age']
        user_email = args['user_email']
        user_phone = args['user_phone']

        # 使用 SHA-256 對密碼加密
        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute("SELECT MAX(user_id) FROM `User`")
                result = cursor.fetchone()
                max_id = result[0] if result[0] is not None else 0
                new_user_id = max_id + 1
                sql = """
                INSERT INTO `User`(`user_id`, `user_name`, `user_password`, `user_school`, `user_age`, `user_email`, `user_phone`)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (new_user_id, user_name, encrypted_password,
                               user_school, user_age, user_email, user_phone))
                connection.commit()
                return {"message": "User registered successfully"}, 201
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/login')
class LoginUser(Resource):
    @user_ns.expect(login_parser)
    def post(self):
        '''登入用戶'''
        args = login_parser.parse_args()
        user_name = args['user_name']
        user_password = args['user_password']

        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = """
                SELECT `user_id` FROM `User`
                WHERE `user_name` = %s AND `user_password` = %s
                """
                cursor.execute(sql, (user_name, encrypted_password))
                user = cursor.fetchone()

                if user:
                    session['user_id'] = user['user_id']
                    return {"message": "Login successful", "user_id": user['user_id']}, 200
                else:
                    return {"message": "Invalid username or password"}, 401
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/logout')
class LogoutUser(Resource):
    def post(self):
        '''登出用戶'''
        session.pop('user_id', None)
        return {"message": "You have been logged out."}, 200


@user_ns.route('/get_user_from_id')
class GetUserFromID(Resource):
    @user_ns.expect(user_id_parser)
    def get(self):
        '''根據 user_id 獲取用戶資料'''
        args = user_id_parser.parse_args()
        user_id = args['user_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT * FROM `User` WHERE `user_id` = %s"
                cursor.execute(sql, (user_id,))
                user = cursor.fetchone()

                if user:
                    return user, 200
                else:
                    return {"error": "User not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/reset_email')
class EmailReset(Resource):
    @user_ns.expect(email_reset_parser)
    def post(self):
        '''重設email'''
        args = email_reset_parser.parse_args()
        original_email = args['original_email']
        user_password = args['user_password']
        new_email = args['new_email']
        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                select_sql = "SELECT `user_id` FROM `User` WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(
                    select_sql, (original_email, encrypted_password))
                user = cursor.fetchone()
                if user:
                    update_sql = "UPDATE `User` SET `user_email` = %s WHERE `user_email` = %s AND `user_password` = %s"
                    cursor.execute(
                        update_sql, (new_email, original_email, encrypted_password))
                    connection.commit()
                    if cursor.rowcount > 0:
                        return {"message": "Email updated successfully"}, 200
                    else:
                        return {"message": "Email not updated, please check your details"}, 400
                else:
                    return {"message": "Original email or password is incorrect"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/reset_password')
class PasswordReset(Resource):
    @user_ns.expect(password_reset_parser)
    def post(self):
        '''重設密碼'''
        args = password_reset_parser.parse_args()
        user_email = args['user_email']
        original_password = args['original_password']
        new_password = args['new_password']
        encrypted_original_password = hashlib.sha256(
            original_password.encode()).hexdigest()
        encrypted_new_password = hashlib.sha256(
            new_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                sql = "SELECT `user_id` FROM `User` WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(sql, (user_email, encrypted_original_password))
                user = cursor.fetchone()
                if user:
                    update_sql = "UPDATE `User` SET `user_password` = %s WHERE `user_email` = %s"
                    cursor.execute(
                        update_sql, (encrypted_new_password, user_email))
                    connection.commit()
                    return {"message": "Password updated successfully"}, 200
                else:
                    return {"message": "Invalid email or original password"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/reset_phone')
class PhoneReset(Resource):
    @user_ns.expect(phone_reset_parser)
    def post(self):
        '''重設手機號碼'''
        args = phone_reset_parser.parse_args()
        user_email = args['user_email']
        user_password = args['user_password']
        new_phone = args['new_phone']
        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_phone` = %s WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(
                    update_sql, (new_phone, user_email, encrypted_password))
                if cursor.rowcount == 0:
                    return {"message": "Invalid email or password"}, 404
                else:
                    connection.commit()
                    return {"message": "Phone number updated successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/reset_name')
class NameReset(Resource):
    @user_ns.expect(name_reset_parser)
    def post(self):
        '''重設姓名'''
        args = name_reset_parser.parse_args()
        user_email = args['user_email']
        user_password = args['user_password']
        new_name = args['new_name']
        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_name` = %s WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(
                    update_sql, (new_name, user_email, encrypted_password))
                if cursor.rowcount == 0:
                    return {"message": "Invalid email or password"}, 404
                else:
                    connection.commit()
                    return {"message": "Name updated successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/reset_school')
class SchoolReset(Resource):
    @user_ns.expect(school_reset_parser)
    def post(self):
        '''重設學校資料'''
        args = school_reset_parser.parse_args()
        user_email = args['user_email']
        user_password = args['user_password']
        new_school = args['new_school']
        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_school` = %s WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(
                    update_sql, (new_school, user_email, encrypted_password))
                if cursor.rowcount == 0:
                    return {"message": "Invalid email or password"}, 404
                else:
                    connection.commit()
                    return {"message": "School updated successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


# Article api區
article_ns = api.namespace('Article', description='與文章操作相關之api')


@article_ns.route('/get_all_article')
class DataList(Resource):
    def get(self):
        '''取得所有Article資料'''
        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            try:
                cursor.execute("SELECT * FROM `Article`")
                articles = cursor.fetchall()
                # 將所有datetime對象轉換為字符串
                for article in articles:
                    if isinstance(article['article_expired_day'], datetime):
                        article['article_expired_day'] = article['article_expired_day'].strftime(
                            '%Y-%m-%d')
                return jsonify(articles)
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


def get_max_article_id(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT MAX(article_id) FROM `Article`")
    result = cursor.fetchone()
    max_id = result[0] if result[0] is not None else 0
    cursor.close()
    return max_id


@article_ns.route('/upload_articles')
class UploadArticles(Resource):
    @user_ns.expect(article_upload_parser)
    def post(self):
        '''從Excel上傳文章資料並插入到數據庫'''
        args = article_upload_parser.parse_args()
        uploaded_file = args['file']

        if uploaded_file:
            df = pd.read_excel(uploaded_file.stream)
            connection = create_db_connection()

            if connection is not None:
                max_article_id = get_max_article_id(connection)

                for index, row in df.iterrows():
                    new_article_id = max_article_id + 1
                    article_title = row['article_title']
                    article_link = row['article_link']
                    article_content = row['article_content']
                    article_expired_day = (
                        datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

                    try:
                        cursor = connection.cursor()
                        insert_query = """
                        INSERT INTO `Article` (
                            `article_id`, `article_title`, `article_link`,
                            `article_category`, `article_content`,
                            `article_grade`, `article_expired_day`
                        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """
                        cursor.execute(insert_query, (
                            new_article_id, article_title, article_link, None,
                            article_content, None, article_expired_day
                        ))
                        connection.commit()
                        max_article_id = new_article_id
                    except Error as e:
                        return {"error": str(e)}, 500

                cursor.close()
                connection.close()
                return {"message": "Articles uploaded successfully"}, 201
            else:
                return {"error": "Unable to connect to the database"}, 500
        else:
            return {"error": "No file uploaded"}, 400


@article_ns.route('/upload_pansci')
class UploadPanSciArticles(Resource):
    def post(self):
        '''從泛科學爬取文章資料並插入到數據庫\n‼️執行此api將會耗費大量時間（約兩小時）請謹慎操作‼️'''
        from PanSciCrawler import start_crawling

        data = start_crawling()
        connection = create_db_connection()

        if connection is not None:
            max_article_id = get_max_article_id(connection)

            for item in data:
                new_article_id = max_article_id + 1
                article_title = item['article_title']
                article_link = item['article_link']
                article_content = item['article_content']
                article_category = item['article_category']
                article_expired_day = (
                    datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

                try:
                    cursor = connection.cursor()
                    insert_query = """
                    INSERT INTO `Article` (
                        `article_id`, `article_title`, `article_link`,
                        `article_category`, `article_content`,
                        `article_grade`, `article_expired_day`
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """
                    cursor.execute(insert_query, (
                        new_article_id, article_title, article_link, article_category,
                        article_content, None, article_expired_day
                    ))
                    connection.commit()
                    max_article_id = new_article_id
                except Error as e:
                    return {"error": str(e)}, 500
            cursor.close()
            connection.close()
            return {"message": "PanSci articles uploaded successfully"}, 201
        else:
            return {"error": "Unable to connect to the database"}, 500

@article_ns.route('/upload_reader_digest')
class UploadPanSciArticles(Resource):
    def post(self):
        '''從讀者文摘爬取文章資料並插入到數據庫'''
        from ReaderDigestCrawler import start_crawling

        data = start_crawling()
        connection = create_db_connection()

        if connection is not None:
            max_article_id = get_max_article_id(connection)

            for item in data:
                new_article_id = max_article_id + 1
                article_title = item['article_title']
                article_link = item['article_link']
                article_content = item['article_content']
                # article_category = item['article_category']
                article_expired_day = (
                    datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

                try:
                    cursor = connection.cursor()
                    insert_query = """
                    INSERT INTO `Article` (
                        `article_id`, `article_title`, `article_link`,
                        `article_category`, `article_content`,
                        `article_grade`, `article_expired_day`
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """
                    cursor.execute(insert_query, (
                        new_article_id, article_title, article_link, None,
                        article_content, None, article_expired_day
                    ))
                    connection.commit()
                    max_article_id = new_article_id
                except Error as e:
                    return {"error": str(e)}, 500
            cursor.close()
            connection.close()
            return {"message": "Reader Digest articles uploaded successfully"}, 201
        else:
            return {"error": "Unable to connect to the database"}, 500

# OpenAI api區
openAI_ns = api.namespace(
    'OpenAI', description='與openai操作相關之api，‼️此區皆為付費區，需測試請先洽Lawrence‼️')
OpenAI.api_key = f'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'


@openAI_ns.route('/get_questions_from_article')
class GetQuestionsFromArticle(Resource):
    @openAI_ns.expect(get_questions_parser)
    def post(self):
        '''傳送多個文章內容至OpenAI API，獲得三個問題及標準答案進資料庫'''
        args = get_questions_parser.parse_args()
        article_id_start = args['article_id_start']
        article_id_end = args['article_id_end']
        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                for article_id in tqdm(range(article_id_start, article_id_end + 1), desc='Processing articles'):
                    sql = "SELECT `article_content` FROM `Article` WHERE `article_id` = %s"
                    cursor.execute(sql, (article_id,))
                    article = cursor.fetchone()
                    if article:
                        article_content = article['article_content']
                        client = OpenAI(
                            api_key='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')

                        try:
                            prompt_message = (
                                f"以下是一篇文章的內容：\n{article_content}\n\n"
                                "請根據以上文本，follow這個格式使用繁體中文回傳給我，"
                                "我想要你首先判斷這篇文章的適讀年齡，要回傳一個阿拉伯數字放入article_age中，"
                                "介於6到15歲之間，再回傳三個問題，第一二題都是選擇題，分別要提供四個選項，"
                                "再提供答案和解析，第三題要是問答題，你必須產生一個標準答案並儲存在answer3中，"
                                "格式如下：" + json.dumps({
                                    "article_age": None,
                                    "question1": None,
                                    "question1choice1": None,
                                    "question1choice2": None,
                                    "question1choice3": None,
                                    "question1choice4": None,
                                    "answer1": None,
                                    "explanation1": None,
                                    "question2": None,
                                    "question2choice1": None,
                                    "question2choice2": None,
                                    "question2choice3": None,
                                    "question2choice4": None,
                                    "answer2": None,
                                    "explanation2": None,
                                    "question3": None,
                                    "answer3": None
                                }) +
                                "尤其注意，你在回答answer1和answer2的時候要回答的是選項的內容，而不是回答question1choice2或是question2choice3這種" +
                                "並請確保你回傳剛好17行數據，並按照上述的格式回傳給我。"
                            )
                            response = client.chat.completions.create(
                                model="gpt-3.5-turbo",
                                messages=[
                                    {"role": "system",
                                        "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
                                    {"role": "user", "content": prompt_message}
                                ],
                            )

                            response_str = str(response).replace(
                                '\n', '').replace('\\n', '')
                            content_start = response_str.find(
                                "content='") + len("content='")
                            content_end = response_str.find(
                                "}', role='assistant'", content_start) + 1
                            content_json_str = response_str[content_start:content_end]
                            content_json_str = content_json_str.replace(
                                "\\'", "'").replace('\\"', '"').replace('\\\\', '\\')
                            print(content_json_str)
                            try:
                                content_json = json.loads(content_json_str)
                            except ValueError as e:
                                retry_prompt = "請你檢查你剛剛傳給我的訊息，其並非JSON格式，幫我轉成JSON以後再給我一次"
                                response = client.chat.completions.create(
                                    model="gpt-3.5-turbo",
                                    messages=[
                                        {"role": "system",
                                            "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
                                        {"role": "user", "content": retry_prompt}
                                    ],
                                )
                                response_str = str(response).replace(
                                    '\n', '').replace('\\n', '')
                                content_start = response_str.find(
                                    "content='") + len("content='")
                                content_end = response_str.find(
                                    "}', role='assistant'", content_start) + 1
                                content_json_str = response_str[content_start:content_end]
                                content_json_str = content_json_str.replace(
                                    "\\'", "'").replace('\\"', '"').replace('\\\\', '\\')
                                content_json = json.loads(content_json_str)
                            print(content_json)
                            cursor.execute(
                                "SELECT MAX(question_id) as max_id FROM `Question`")
                            result = cursor.fetchone()
                            max_id = result['max_id'] if result['max_id'] is not None else 0
                            question_id = max_id + 1
                            try:
                                sql_insert = """
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
                                cursor.execute(sql_insert, (
                                    question_id,
                                    article_id,
                                    content_json['article_age'],
                                    content_json['question1'],
                                    content_json['question1choice1'],
                                    content_json['question1choice2'],
                                    content_json['question1choice3'],
                                    content_json['question1choice4'],
                                    content_json['answer1'],
                                    content_json['explanation1'],
                                    content_json['question2'],
                                    content_json['question2choice1'],
                                    content_json['question2choice2'],
                                    content_json['question2choice3'],
                                    content_json['question2choice4'],
                                    content_json['answer2'],
                                    content_json['explanation2'],
                                    content_json['question3'],
                                    content_json['answer3']
                                ))
                                connection.commit()
                            except Exception as e:
                                import traceback
                                traceback.print_exc()
                                return {"error": str(e)}, 500
                        except Exception as e:
                            import traceback
                            traceback.print_exc()
                            return {'error': str(e)}, 500
            except Error as e:
                import traceback
                traceback.print_exc()
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        return {'status': 'success'}, 200


@openAI_ns.route('/get_rate_from_answers')
class GetRateFromAnswers(Resource):
    @openAI_ns.expect(get_rate_parser)
    def post(self):
        '''傳送回答獲得評分與評語'''
        args = get_rate_parser.parse_args()
        article_id = args['article_id']
        answer = args['answer']
        connection = create_db_connection()
        rate_standard = (
            "回答評分標準\n"
            "1. 正確度\n"
            "1分：回答與問題無關或包含嚴重錯誤。\n"
            "2分：回答包含一些正確信息，但存在明顯的錯誤。\n"
            "3分：回答正確度一般，涵蓋了主要內容，但可能有一些不準確之處。\n"
            "4分：回答正確度較高，包含主要內容，但可能缺少一些細節。\n"
            "5分：回答非常正確，涵蓋了問題的所有關鍵內容，並提供了詳盡的解釋。\n"
            "\n"
            "2. 完整度\n"
            "1分：回答非常不完整，未涵蓋問題的主要內容。\n"
            "2分：回答缺乏關鍵信息，僅涵蓋了部分內容。\n"
            "3分：回答包含一些內容，但缺少關鍵細節。\n"
            "4分：回答涵蓋了主要內容，但可能缺少一些次要細節。\n"
            "5分：回答非常完整，涵蓋了問題的所有重要內容，包括次要細節。\n"
            "\n"
            "3. 語言表達清晰度\n"
            "1分：回答存在嚴重語句不通順或難以理解的問題。\n"
            "2分：回答有明顯的表達問題，導致理解上的困難。\n"
            "3分：回答表達尚可，但可能存在一些不通順或模糊之處。\n"
            "4分：回答表達清晰，但可能存在一些表達不夠精確的地方。\n"
            "5分：回答表達非常清晰，言之有物，易於理解。\n\n"
        )
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT a.article_content, q.question3,q.question3_answer FROM Question AS q LEFT JOIN Article AS a ON q.article_id = a.article_id WHERE a.article_id = %s;"
                cursor.execute(sql, (article_id,))
                article = cursor.fetchone()
                if article:
                    article_content = article['article_content']
                    question = article['question3']
                    standard_answer = article['question3_answer']
                    client = OpenAI(
                        api_key='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')

                    try:
                        prompt_message = (
                            f"以下是一篇文章的內容：\n{article_content}\n以下是根據這篇文章所產生的開放性問題：\n{question}\n然後，以下是我的使用者回答：\n{answer}\n現在，請你根據以下標準，針對此回答給予評分。標準如下：\n{rate_standard}\n，然後根據以下JSON格式回傳你的回覆給我："+
                            json.dumps({
                                "正確度": None,
                                "正確度原因": None,
                                "完整度": None,
                                "完整度原因": None,
                                "語言表達清晰度": None,
                                "語言表達清晰度原因": None,
                                "總分": None,
                                "總評": None
                            })
                        )
                        response = client.chat.completions.create(
                            model="gpt-3.5-turbo",
                            messages=[
                                {"role": "system",
                                    "content": "你是一名專門在閱讀學生答案後產生評分與評語的嚴格老師。"},
                                {"role": "user", "content": prompt_message}
                            ],
                        )
                        print(response)
                        response_str = str(response).replace(
                            '\n', '').replace('\\n', '')
                        content_start = response_str.find(
                            "content='") + len("content='")
                        content_end = response_str.find(
                            "}', role='assistant'", content_start) + 1
                        content_json_str = response_str[content_start:content_end]
                        content_json_str = content_json_str.replace(
                            "\\'", "'").replace('\\"', '"').replace('\\\\', '\\')
                        print(content_json_str)
                        try:
                            content_json = json.loads(content_json_str)
                        except ValueError as e:
                            retry_prompt = "請你檢查你剛剛傳給我的訊息，其並非JSON格式，幫我轉成JSON以後再給我一次"
                            response = client.chat.completions.create(
                                model="gpt-3.5-turbo",
                                messages=[
                                    {"role": "system",
                                        "content": "你是一名專門在閱讀學生答案後產生評分與評語的嚴格老師。對於胡亂回答的，你可以直接則被使用者，也應該要給予很低的分數。"},
                                    {"role": "user", "content": retry_prompt}
                                ],
                            )
                            response_str = str(response).replace(
                                '\n', '').replace('\\n', '')
                            content_start = response_str.find(
                                "content='") + len("content='")
                            content_end = response_str.find(
                                "}', role='assistant'", content_start) + 1
                            content_json_str = response_str[content_start:content_end]
                            content_json_str = content_json_str.replace(
                                "\\'", "'").replace('\\"', '"').replace('\\\\', '\\')
                            content_json = json.loads(content_json_str)
                        return {'status': 'success', 'content': content_json}, 200
                    except Exception as e:
                        import traceback
                        traceback.print_exc()
                        return {'error': str(e)}, 500
            except Error as e:
                import traceback
                traceback.print_exc()
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
