# 標準庫
from datetime import date, datetime
from flask_restx import Resource
from datetime import datetime, timedelta
from decimal import Decimal
import hashlib
import json
import os
import random
import string
import base64
import time

# 第三方庫
import pandas as pd
import mysql.connector
from mysql.connector import Error
from flask import Flask, request, session, jsonify, url_for
from flask_mail import Mail, Message
from flask_restx import Api, Resource, reqparse
from flask_cors import CORS
from werkzeug.datastructures import FileStorage
from authlib.integrations.flask_client import OAuth
from tqdm import tqdm
from openai import OpenAI
from dotenv import load_dotenv
from werkzeug.datastructures import FileStorage


app = Flask(__name__)
CORS(app)
oauth = OAuth(app)
load_dotenv()
app.secret_key = os.getenv('FLASK_SECRET_KEY')
api = Api(app, version='1.0', title='Graduation_Repository APIs',
          description='110級畢業專案第一組\n組員：吳堃豪、侯程麟、謝佳蓉、許馨文、王暐睿\n指導教授：洪智鐸')


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


user_parser = reqparse.RequestParser()
user_parser.add_argument('user_name', type=str, required=True, help='使用者名稱')
user_parser.add_argument('user_password', type=str,
                         required=True, help='使用者密碼')
user_parser.add_argument('user_school', type=str, required=True, help='使用者學校')
user_parser.add_argument('user_birthday', type=str,
                         required=True, help='使用者生日 (YYYY-MM-DD)')
user_parser.add_argument('user_email', type=str,
                         required=True, help='使用者email')
user_parser.add_argument('user_phone', type=str, required=True, help='使用者電話')

login_parser = reqparse.RequestParser()
login_parser.add_argument('user_email', type=str,
                          required=True, help='使用者電子郵件')
login_parser.add_argument('user_password', type=str,
                          required=True, help='使用者密碼')

user_id_parser = reqparse.RequestParser()
user_id_parser.add_argument('user_id', type=int, required=True, help='使用者ID')

email_reset_parser = reqparse.RequestParser()
email_reset_parser.add_argument(
    'user_id', type=int, required=True, help='使用者ID')
email_reset_parser.add_argument(
    'new_email', type=str, required=True, help='使用者新email')

password_reset_parser = reqparse.RequestParser()
password_reset_parser.add_argument(
    'user_email', type=str, required=True, help='使用者email')
password_reset_parser.add_argument(
    'new_password', type=str, required=True, help='使用者新密碼')

phone_reset_parser = reqparse.RequestParser()
phone_reset_parser.add_argument(
    'user_id', type=int, required=True, help='使用者ID')
phone_reset_parser.add_argument(
    'new_phone', type=str, required=True, help='使用者新電話號碼')

school_reset_parser = reqparse.RequestParser()
school_reset_parser.add_argument(
    'user_id', type=int, required=True, help='使用者ID')
school_reset_parser.add_argument(
    'new_school', type=str, required=True, help='新學校名稱')

birthday_reset_parser = reqparse.RequestParser()
birthday_reset_parser.add_argument(
    'user_id', type=int, required=True, help='使用者ID')
birthday_reset_parser.add_argument(
    'new_birthday', type=str, required=True, help='新生日')

article_upload_parser = reqparse.RequestParser()
article_upload_parser.add_argument('file', type=FileStorage, location='files',
                                   required=True, help='可以上傳Excel檔案，格式要是|article_title|article_link|article_content|')

get_questions_parser = reqparse.RequestParser()
get_questions_parser.add_argument(
    'article_id_start', type=int, required=True, help='檢驗範圍的文章id')
get_questions_parser.add_argument(
    'article_id_end', type=int, required=True, help='欲產生問題之最後一個文章編號')

get_rate_parser = reqparse.RequestParser()
get_rate_parser.add_argument(
    'article_id', type=int, required=True, help='原文文章id')
get_rate_parser.add_argument('answer', type=str, required=True, help='回答')

get_login_record_parser = reqparse.RequestParser()
get_login_record_parser.add_argument(
    'user_id', type=int, required=True, help='使用者id'
)

character_image_upload_parser = reqparse.RequestParser()
character_image_upload_parser.add_argument(
    'character_name', type=str, required=True, help='角色名稱')
character_image_upload_parser.add_argument(
    'image', type=FileStorage, location='files', required=True, help='上傳的圖片檔案')

enemy_image_upload_parser = reqparse.RequestParser()
enemy_image_upload_parser.add_argument(
    'enemy_category', type=int, required=True, help='敵人類別')
enemy_image_upload_parser.add_argument(
    'image', type=FileStorage, location='files', required=True, help='上傳的圖片檔案')

follow_up_parser = reqparse.RequestParser()
follow_up_parser.add_argument('user_id', type=int, required=True, help='使用者id')
follow_up_parser.add_argument(
    'user_input', type=str, required=True, help='使用者輸入問題')

history_parser = reqparse.RequestParser()
history_parser.add_argument('user_id', type=int, required=True, help='使用者ID')
history_parser.add_argument('article_id', type=int, required=True, help='文章ID')
history_parser.add_argument(
    'q1_user_answer', type=str, required=True, help='第一題使用者答案')
history_parser.add_argument(
    'q2_user_answer', type=str, required=True, help='第二題使用者答案')
history_parser.add_argument(
    'q3_user_answer', type=str, required=True, help='第三題使用者答案')
history_parser.add_argument(
    'q3_aicomment', type=str, required=True, help='第三題AI評價'
)
history_parser.add_argument('q3_score_1', type=int,
                            required=True, help='第三題評分1')
history_parser.add_argument('q3_explanation1', type=str,
                            required=True, help='第一個評分項目解釋')
history_parser.add_argument('q3_score_2', type=int,
                            required=True, help='第三題評分2')
history_parser.add_argument('q3_explanation2', type=str,
                            required=True, help='第二個評分項目解釋')
history_parser.add_argument('q3_score_3', type=int,
                            required=True, help='第三題評分3')
history_parser.add_argument('q3_explanation3', type=str,
                            required=True, help='第三個評分項目解釋')

random_article_parser = reqparse.RequestParser()
random_article_parser.add_argument(
    'user_id', type=int, required=True, help='使用者ID')
random_article_parser.add_argument(
    'article_category', type=str, required=True, help='文章類別')

test_article_parser = reqparse.RequestParser()
test_article_parser.add_argument(
    'article_pass', type=int, required=True, help='測試結果(1 => 成功, 0 => 錯誤)')
test_article_parser.add_argument(
    'article_note', type=str, required=False, help='測試備註')
test_article_parser.add_argument(
    'article_id', type=int, required=True, help='文章帳號')
test_article_parser.add_argument(
    'article_title', type=str, required=True, help='文章標題')
test_article_parser.add_argument(
    'article_content', type=str, required=True, help='文章內文')

# Question 1
test_article_parser.add_argument(
    'question_1', type=str, required=True, help='問題 1')
test_article_parser.add_argument(
    'question1_choice1', type=str, required=True, help='問題 1 選項 A')
test_article_parser.add_argument(
    'question1_choice2', type=str, required=True, help='問題 1 選項 B')
test_article_parser.add_argument(
    'question1_choice3', type=str, required=True, help='問題 1 選項 C')
test_article_parser.add_argument(
    'question1_choice4', type=str, required=True, help='問題 1 選項 D')
test_article_parser.add_argument(
    'question1_answer', type=str, required=True, help='問題 1 答案')
test_article_parser.add_argument(
    'question1_explanation', type=str, required=True, help='問題 1 詳解')

# Question 2
test_article_parser.add_argument(
    'question_2', type=str, required=True, help='問題 2')
test_article_parser.add_argument(
    'question2_choice1', type=str, required=True, help='問題 2 選項 A')
test_article_parser.add_argument(
    'question2_choice2', type=str, required=True, help='問題 2 選項 B')
test_article_parser.add_argument(
    'question2_choice3', type=str, required=True, help='問題 2 選項 C')
test_article_parser.add_argument(
    'question2_choice4', type=str, required=True, help='問題 2 選項 D')
test_article_parser.add_argument(
    'question2_answer', type=str, required=True, help='問題 2 答案')
test_article_parser.add_argument(
    'question2_explanation', type=str, required=True, help='問題 2 詳解')

# Question 3
test_article_parser.add_argument(
    'question3', type=str, required=True, help='問題 3')
test_article_parser.add_argument(
    'question3_answer', type=str, required=True, help='問題 3 答案')

# User api區
user_ns = api.namespace('User', description='與使用者操作相關之api')


@user_ns.route('/normal_register')
class RegisterUser(Resource):
    @user_ns.expect(user_parser)
    def post(self):
        '''註冊新用戶'''
        args = user_parser.parse_args()
        user_name = args['user_name']
        user_password = args['user_password']
        user_school = args['user_school']
        user_birthday = args['user_birthday']
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
                INSERT INTO `User`(`user_id`, `user_name`, `user_password`, `user_school`, `user_birthday`, `user_email`, `user_phone`, `created_at`)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (new_user_id, user_name, encrypted_password,
                               user_school, user_birthday, user_email, user_phone, datetime.now().date()))
                connection.commit()
                return {"message": "User registered successfully", "user_id": new_user_id}, 201
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


image_parser = reqparse.RequestParser()
image_parser.add_argument('user_id', type=int, required=True, help='user id')
image_parser.add_argument('character_id', type=int,
                          required=True, help='character id')
update_offline_parser = reqparse.RequestParser()
update_offline_parser.add_argument('login_id', type=int, required=True)
update_offline_parser.add_argument('offline_time', type=str, required=True)

@user_ns.route('/image_register')
class ImageRegister(Resource):
    @user_ns.expect(image_parser)
    def post(self):
        '''加入角色id'''
        args = image_parser.parse_args()
        user_id = args['user_id']
        character_id = args['character_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                sql = """
                UPDATE User SET character_id = %s WHERE user_id = %s
                """
                cursor.execute(sql, (character_id, user_id))
                connection.commit()
                return {"message": "Image registered successfully"}, 201
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

@user_ns.route('/normal_login')
class LoginUser(Resource):
    @user_ns.expect(login_parser)
    def post(self):
        '''登入用戶'''
        args = login_parser.parse_args()
        user_email = args['user_email']
        user_password = args['user_password']

        encrypted_password = hashlib.sha256(user_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = """
                SELECT user_id FROM User
                WHERE user_email = %s AND user_password = %s
                """
                cursor.execute(sql, (user_email, encrypted_password))
                user = cursor.fetchone()

                user_id = user['user_id'] if user else None
                success = bool(user)

                # 插入登錄記錄
                if user_id:
                    insert_sql = """
                    INSERT INTO LoginRecord (user_id, login_time, ip_address, user_agent, success)
                    VALUES (%s, %s, %s, %s, %s)
                    """
                    cursor.execute(insert_sql, (
                        user_id,
                        datetime.now(),
                        request.remote_addr,
                        request.headers.get('User-Agent'),
                        success
                    ))
                    connection.commit()

                    # 獲取插入的 login_record_id
                    login_record_id = cursor.lastrowid
                else:
                    login_record_id = None

                if success:
                    session['user_id'] = user['user_id']
                    return {"message": "Login successful", "user_id": user['user_id'], "login_record_id": login_record_id}, 200
                else:
                    return {"message": "Invalid username or password"}, 401
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500
@user_ns.route('/update_offline')
class UpdateOffline(Resource):
    @user_ns.expect(update_offline_parser)
    def post(self):
        '''更新下線時間'''
        args = update_offline_parser.parse_args()
        login_id = args["login_id"]
        
        try:
            offline_time = datetime.strptime(args["offline_time"], '%Y-%m-%d %H:%M:%S')
        except ValueError as ve:
            return {"error": str(ve)}, 400

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                sql = "UPDATE `LoginRecord` SET offline_time = %s WHERE login_id = %s;"
                cursor.execute(sql, (offline_time, login_id))
                connection.commit()
                return {"message": "Offline time updated successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

all_history_parser = reqparse.RequestParser()
all_history_parser.add_argument('user_id', type=int, required=True)

all_history_parser = reqparse.RequestParser()
all_history_parser.add_argument('user_id', type=int, required=True)

@user_ns.route('/get_all_history_from_user_id')
class GetHistoryFromUserID(Resource):
    @user_ns.expect(all_history_parser)
    def get(self):
        '''抓取所有上下線歷史、上線時長、作答紀錄'''
        args = all_history_parser.parse_args()  # 使用 all_history_parser
        user_id = args["user_id"]
        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)  # 使用 dictionary 以便返回字典格式
                sql = \
                """
                SELECT 
                    l.login_id,
                    l.login_time,
                    COALESCE(l.offline_time, 
                        (SELECT MIN(l2.login_time) 
                        FROM LoginRecord AS l2 
                        WHERE l2.user_id = l.user_id 
                        AND l2.login_time > l.login_time)) AS offline_time,  -- 使用 COALESCE 獲取下一次登入的時間
                    TIMESTAMPDIFF(SECOND, l.login_time, 
                        COALESCE(l.offline_time, 
                            (SELECT MIN(l2.login_time) 
                            FROM LoginRecord AS l2 
                            WHERE l2.user_id = l.user_id 
                            AND l2.login_time > l.login_time))) AS online_length,  -- 計算在線時長
                    COUNT(h.history_id) * 3 AS questions_answered,
                    AVG(h.total_score) AS average_score
                FROM 
                    LoginRecord AS l 
                LEFT JOIN 
                    History AS h ON h.user_id = l.user_id 
                WHERE 
                    l.user_id = %s
                    AND h.time BETWEEN l.login_time AND COALESCE(l.offline_time, 
                        (SELECT MIN(l2.login_time) 
                        FROM LoginRecord AS l2 
                        WHERE l2.user_id = l.user_id 
                        AND l2.login_time > l.login_time))  -- 確保 history_time 在 login_time 和 offline_time 之間
                GROUP BY 
                    l.login_id, l.login_time;
                """
                cursor.execute(sql, (user_id,))
                results = cursor.fetchall()  # 獲取查詢結果

                if results:  # 如果找到結果
                    for record in results:
                        for key, value in record.items():
                            if isinstance(value, (date, datetime)):
                                record[key] = value.isoformat()  # 將日期轉換為 ISO 格式
                            elif isinstance(value, Decimal):
                                record[key] = str(value)
                    return {"data": results}, 200
                else:
                    return {"error": "User not found"}, 404   # 如果沒有結果則返回 404

            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

google = oauth.register(
    name='google',
    client_id=os.getenv('GOOGLE_CLIENT_ID'),
    client_secret=os.getenv('GOOGLE_CLIENT_SECRET'),
    access_token_url='https://accounts.google.com/o/oauth2/token',
    access_token_params=None,
    authorize_url='https://accounts.google.com/o/oauth2/auth',
    authorize_params=None,
    api_base_url='https://www.googleapis.com/oauth2/v1/',
    jwks_uri='https://www.googleapis.com/oauth2/v3/certs',
    client_kwargs={'scope': 'openid email profile'},
)


@app.route('/User/google_login')
def login():
    redirect_uri = url_for('authorize', _external=True)
    return google.authorize_redirect(redirect_uri)


@app.route('/User/authorize')
def authorize():
    token = google.authorize_access_token()
    resp = google.get('userinfo')
    user_info = resp.json()

    user_school = user_info.get('hd')

    connection = create_db_connection()
    if connection is not None:
        try:
            cursor = connection.cursor()
            cursor.execute("SELECT user_id FROM User WHERE google_id = %s OR user_email = %s",
                           (user_info['id'], user_info['email']))
            user = cursor.fetchone()
            if user is None:
                cursor.execute("SELECT MAX(user_id) FROM User")
                result = cursor.fetchone()
                max_id = result[0] if result[0] is not None else 0
                new_user_id = max_id + 1
                sql = """
                INSERT INTO User (user_id, google_id, user_name, profile_picture, user_email, user_school, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (new_user_id, user_info['id'], user_info['name'], user_info.get(
                    'picture'), user_info['email'], user_school, datetime.now().date()))
                connection.commit()
                user_id = new_user_id
            else:
                user_id = user[0]
                sql = """
                UPDATE User
                SET google_id = %s, user_name = %s, profile_picture = %s, user_school = %s
                WHERE user_id = %s
                """
                cursor.execute(sql, (user_info['id'], user_info['name'], user_info.get(
                    'picture'), user_school, user_id))
                connection.commit()

            insert_login_record(user_id, True)
            session['user_id'] = user_id
            return {"message": f"Login successfully as {user_info['name']}!", "user_id": user_id}, 200
        except Error as e:
            insert_login_record(None, False)
            return {"error": str(e)}, 500
        finally:
            cursor.close()
            connection.close()
    else:
        return {"error": "Unable to connect to the database"}, 500

def insert_login_record(user_id, success):
    connection = create_db_connection()
    if connection is not None:
        try:
            cursor = connection.cursor()
            sql = """
            INSERT INTO LoginRecord (user_id, login_time, ip_address, user_agent, success)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                user_id,
                datetime.now(),
                request.remote_addr,
                request.headers.get('User-Agent'),
                success
            ))
            connection.commit()
        except Error as e:
            print(f"Error logging login attempt: {e}")
        finally:
            cursor.close()
            connection.close()

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_USERNAME'] = '110306047@g.nccu.edu.tw'
app.config['MAIL_PASSWORD'] = 'ahwesebrfcsdrvkl'
app.config['MAIL_DEFAULT_SENDER'] = ('Reading King', 'reading@gmail.com')

mail = Mail(app)

verification_code_parser = reqparse.RequestParser()
verification_code_parser.add_argument(
    'user_email', type=str, required=True, help='使用者 email')


@user_ns.route('/send_verification_code')
class SendVerificationCode(Resource):
    @user_ns.expect(verification_code_parser)
    def post(self):
        '''寄送驗證碼到使用者的 email'''
        args = verification_code_parser.parse_args()
        user_email = args['user_email']
        # 生成 6 位隨機驗證碼
        verification_code = ''.join(random.choices(
            string.ascii_uppercase + string.digits, k=6))

        # 將驗證碼存入資料庫
        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute(
                    "SELECT user_id FROM User WHERE user_email = %s", (user_email,))
                user = cursor.fetchone()

                if user:
                    user_id = user[0]

                    cursor.execute(
                        "SELECT COALESCE(MAX(id), 0) + 1 FROM VerificationCodes")
                    new_id = cursor.fetchone()[0]

                    sql = """
                    INSERT INTO VerificationCodes (id, user_id, verification_code, created_at)
                    VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(
                        sql, (new_id, user_id, verification_code, datetime.now()))
                    connection.commit()

                    try:
                        msg = Message("您的驗證碼", recipients=[user_email])
                        msg.body = f"您的驗證碼是：{verification_code}，請在10分鐘內使用。"
                        mail.send(msg)
                    except Exception as mail_error:
                        return {"error": "Failed to send email", "details": str(mail_error)}, 500

                    return {"message": "Verification code sent successfully"}, 200
                else:
                    return {"message": "Email not found"}, 404
            except Error as db_error:
                return {"error": str(db_error)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


verification_code_check_parser = reqparse.RequestParser()
verification_code_check_parser.add_argument(
    'user_email', type=str, required=True, help='使用者 email')
verification_code_check_parser.add_argument(
    'verification_code', type=str, required=True, help='驗證碼')


@user_ns.route('/check_verification_code')
class CheckVerificationCode(Resource):
    @user_ns.expect(verification_code_check_parser)
    def get(self):
        '''檢查使用者的驗證碼是否有效'''
        args = verification_code_check_parser.parse_args()
        user_email = args['user_email']
        input_code = args['verification_code']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                cursor.execute(
                    "SELECT user_id FROM User WHERE user_email = %s", (user_email,))
                user = cursor.fetchone()

                if user:
                    user_id = user[0]

                    cursor.execute("""
                        SELECT verification_code, created_at FROM VerificationCodes
                        WHERE user_id = %s
                        ORDER BY created_at DESC
                        LIMIT 1
                    """, (user_id,))
                    record = cursor.fetchone()

                    if record:
                        db_verification_code, created_at = record
                        current_time = datetime.now()
                        time_diff = current_time - created_at

                        if time_diff > timedelta(minutes=3):
                            return {"error": "驗證碼已過期"}, 400
                        elif db_verification_code != input_code:
                            return {"error": "驗證碼錯誤"}, 401
                        else:
                            return {"message": "驗證成功"}, 200
                    else:
                        return {"error": "未找到此使用者"}, 404
                else:
                    return {"error": "您輸入的電子郵件可能有誤，請重新輸入"}, 404
            except Error as db_error:
                return {"error": str(db_error)}, 500
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
                sql = "SELECT * FROM User WHERE user_id = %s"
                cursor.execute(sql, (user_id,))
                user = cursor.fetchone()

                if user:
                    for key, value in user.items():
                        if isinstance(value, (date, datetime)):
                            user[key] = value.isoformat()
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


@user_ns.route('/reset_password')
class PasswordReset(Resource):
    @user_ns.expect(password_reset_parser)
    def post(self):
        '''重設密碼'''
        args = password_reset_parser.parse_args()
        user_email = args['user_email']
        new_password = args['new_password']
        encrypted_new_password = hashlib.sha256(
            new_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                # 確認用戶是否存在
                sql = "SELECT `user_id` FROM `User` WHERE `user_email` = %s"
                cursor.execute(sql, (user_email,))
                user = cursor.fetchone()
                if user:
                    update_sql = "UPDATE `User` SET `user_password` = %s WHERE `user_email` = %s"
                    cursor.execute(
                        update_sql, (encrypted_new_password, user_email))
                    connection.commit()
                    return {"message": "Password updated successfully"}, 200
                else:
                    return {"message": "Invalid email"}, 404
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
        user_id = args['user_id']
        new_phone = args['new_phone']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_phone` = %s WHERE `user_id` = %s"
                cursor.execute(update_sql, (new_phone, user_id))
                if cursor.rowcount == 0:
                    return {"message": "User not found"}, 404
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


@user_ns.route('/reset_school')
class SchoolReset(Resource):
    @user_ns.expect(school_reset_parser)
    def post(self):
        '''重設學校資料'''
        args = school_reset_parser.parse_args()
        user_id = args['user_id']
        new_school = args['new_school']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_school` = %s WHERE `user_id` = %s"
                cursor.execute(update_sql, (new_school, user_id))
                if cursor.rowcount == 0:
                    return {"message": "User not found"}, 404
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


@user_ns.route('/reset_birthday')
class BirthdayReset(Resource):
    @user_ns.expect(birthday_reset_parser)
    def post(self):
        '''重設生日'''
        args = birthday_reset_parser.parse_args()
        user_id = args['user_id']
        new_birthday = args['new_birthday']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                update_sql = "UPDATE `User` SET `user_birthday` = %s WHERE `user_id` = %s"
                cursor.execute(update_sql, (new_birthday, user_id))

                if cursor.rowcount == 0:
                    return {"message": "User not found"}, 404
                else:
                    connection.commit()
                    return {"message": "Birthday updated successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@user_ns.route('/get_login_record')
class GetLoginRecord(Resource):
    @user_ns.expect(get_login_record_parser)
    def get(self):
        '''取得登入紀錄'''
        args = get_login_record_parser.parse_args()
        user_id = args['user_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)

                # 執行 SQL 查詢，查詢所有符合條件的記錄
                sql = "SELECT login_time FROM `LoginRecord` WHERE user_id = %s;"
                cursor.execute(sql, (user_id,))

                # 使用 fetchall 來抓取多行結果
                login_records = cursor.fetchall()

                # 如果查詢結果不為空
                if login_records:
                    # 將所有 datetime 物件轉換為 ISO 格式
                    for record in login_records:
                        for key, value in record.items():
                            if isinstance(value, (date, datetime)):
                                record[key] = value.isoformat()
                    return login_records, 200
                else:
                    return {"error": "User not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                # 確保 cursor 和 connection 正確關閉
                if cursor:
                    cursor.close()
                if connection:
                    connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


# Article api區
article_ns = api.namespace('Article', description='與文章操作相關之api')


def get_max_article_id(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT MAX(article_id) FROM `Article`")
    result = cursor.fetchone()
    max_id = result[0] if result[0] is not None else 0
    cursor.close()
    return max_id


@article_ns.route('/get_random_article')
class DataList(Resource):
    def get(self):
        '''取得隨機文章'''
        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            try:
                cursor.execute(
                    "SELECT article_title, article_content FROM Article ORDER BY RAND() LIMIT 1;")
                article = cursor.fetchall()
                return jsonify(article)
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()


@article_ns.route('/get_random_unseen_article')
class DataList(Resource):
    @user_ns.expect(random_article_parser)
    def get(self):
        '''根據使用者id以及所選的類別找出此使用者還沒看過且年齡適合的文章'''
        args = random_article_parser.parse_args()
        user_id = args['user_id']
        article_category = args['article_category']
        connection = create_db_connection()

        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            try:
                # 1. 查詢使用者的生日，並根據現在的時間計算年齡
                cursor.execute(
                    "SELECT user_birthday FROM User WHERE user_id = %s", (user_id,))
                result = cursor.fetchone()

                if not result:
                    return {"error": "User not found"}, 404

                user_birthday = result['user_birthday']
                today = datetime.today()
                user_age = today.year - user_birthday.year - \
                    ((today.month, today.day) <
                     (user_birthday.month, user_birthday.day))
                user_age = min(user_age, 15)
                print(user_age)
                # 2. 查詢使用者還沒看過的文章，且文章年齡適合
                sql = """
                    SELECT a.article_id, a.article_title, a.article_content, q.question_grade, q.question_1, 
                        q.question1_choice1, q.question1_choice2, q.question1_choice3, q.question1_choice4, 
                        q.question1_answer, q.question1_explanation, q.question_2, q.question2_choice1, 
                        q.question2_choice2, q.question2_choice3, q.question2_choice4, q.question2_answer, 
                        q.question2_explanation, q.question3, q.question3_answer
                    FROM Article AS a
                    JOIN Question AS q ON a.article_id = q.article_id
                    WHERE a.article_category = %s
                    AND a.article_pass = 1
                    AND a.article_grade <= %s  -- 確保文章適合當前年齡
                    AND NOT EXISTS (
                        SELECT 1
                        FROM History h
                        WHERE h.article_id = a.article_id
                        AND h.user_id = %s
                    )
                    ORDER BY RAND()
                    LIMIT 1;
                """
                cursor.execute(sql, (article_category, user_age, user_id))
                article = cursor.fetchall()

                if article:
                    return jsonify(article)
                else:
                    return {"message": "No unseen articles found for this user"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@article_ns.route('/get_random_uncheck_article')
class RandomArticle(Resource):
    def get(self):
        '''隨機選取4598到6000範圍內且article_pass為NULL的文章'''
        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            try:
                article_id = random.randint(4598, 6000)
                sql = """
                SELECT a.article_id, a.article_title, a.article_content, q.question_grade, q.question_1, 
                    q.question1_choice1, q.question1_choice2, q.question1_choice3, q.question1_choice4, 
                    q.question1_answer, q.question1_explanation, q.question_2, q.question2_choice1, 
                    q.question2_choice2, q.question2_choice3, q.question2_choice4, q.question2_answer, 
                    q.question2_explanation, q.question3, q.question3_answer 
                FROM Article AS a
                JOIN Question AS q ON a.article_id = q.article_id
                WHERE a.article_id = %s AND a.article_pass IS NULL 
                LIMIT 1;
                """
                cursor.execute(sql, (article_id,))
                article = cursor.fetchone()
                if article:
                    return jsonify(article)
                else:
                    return {"message": "No article found or all articles are checked."}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()


@article_ns.route('/submit_article_fixed')
class SubmitArticleFixed(Resource):
    @article_ns.expect(test_article_parser)
    def post(self):
        '''提交文章檢查結果'''
        args = test_article_parser.parse_args()

        # 提取所有提交的參數
        check = args['article_pass']
        note = args['article_note']
        article_id = args['article_id']
        article_title = args['article_title']
        article_content = args['article_content']

        # Question 1
        question_1 = args['question_1']
        question1_choice1 = args['question1_choice1']
        question1_choice2 = args['question1_choice2']
        question1_choice3 = args['question1_choice3']
        question1_choice4 = args['question1_choice4']
        question1_answer = args['question1_answer']
        question1_explanation = args['question1_explanation']

        # Question 2
        question_2 = args['question_2']
        question2_choice1 = args['question2_choice1']
        question2_choice2 = args['question2_choice2']
        question2_choice3 = args['question2_choice3']
        question2_choice4 = args['question2_choice4']
        question2_answer = args['question2_answer']
        question2_explanation = args['question2_explanation']

        # Question 3
        question3 = args['question3']
        question3_answer = args['question3_answer']

        check_time = datetime.now()

        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor()
            try:
                # 更新文章表的文章基本信息
                sql_article = """
                UPDATE Article 
                SET article_pass = %s, article_note = %s, check_time = %s, article_title = %s, article_content = %s
                WHERE article_id = %s;
                """
                cursor.execute(sql_article, (check, note, check_time,
                               article_title, article_content, article_id))

                # 更新問題表的相關數據
                sql_question = """
                UPDATE Question
                SET question_1 = %s, question1_choice1 = %s, question1_choice2 = %s, question1_choice3 = %s, question1_choice4 = %s,
                question1_answer = %s, question1_explanation = %s, question_2 = %s, question2_choice1 = %s, question2_choice2 = %s, 
                question2_choice3 = %s, question2_choice4 = %s, question2_answer = %s, question2_explanation = %s, 
                question3 = %s, question3_answer = %s
                WHERE article_id = %s;
                """
                cursor.execute(sql_question, (question_1, question1_choice1, question1_choice2, question1_choice3, question1_choice4,
                                              question1_answer, question1_explanation, question_2, question2_choice1, question2_choice2,
                                              question2_choice3, question2_choice4, question2_answer, question2_explanation,
                                              question3, question3_answer, article_id))

                connection.commit()
                return {"success": True}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


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
OpenAI.api_key = os.getenv('OPENAI_API_KEY')


@openAI_ns.route('/get_questions_from_article')
class GetQuestionsFromArticle(Resource):
    @openAI_ns.expect(get_questions_parser)
    def post(self):
        error = 0
        '''傳送多個文章內容至OpenAI API，獲得三個問題及標準答案進資料庫'''
        args = get_questions_parser.parse_args()
        article_id_start = args['article_id_start']
        article_id_end = args['article_id_end']
        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                for article_id in tqdm(range(article_id_start, article_id_end + 1), desc='Processing articles'):
                    try:
                        sql_check = "SELECT 1 FROM `Question` WHERE `article_id` = %s"
                        cursor.execute(sql_check, (article_id,))
                        if cursor.fetchone():
                            print('文章編號: ' + str(article_id) + '已存在於資料庫中，跳過')
                            continue
                        sql = "SELECT `article_content` FROM `Article` WHERE `article_id` = %s"
                        cursor.execute(sql, (article_id,))
                        article = cursor.fetchone()
                        if article:
                            article = article['article_content']
                            client = OpenAI(
                                api_key=os.getenv('OPENAI_API_KEY'))

                            try:
                                prompt = f"""
                                我將給你一篇文章，請你判斷以下資訊：
                                1. 此篇文章的適讀年齡，回傳一個阿拉伯數字介於6到15之間代表歲數。
                                2. 產生兩個選擇題，兩個題目要不一樣，且兩個題目都有四個選項。
                                3. 產生兩個選擇題的正確答案和解釋。
                                4. 產生一個問答題（開放性題目）的題目。
                                5. 提供一個問答題的標準答案。
                                文章內容如下：
                                {article}
                                將以上資訊放進以下格式的JSON當中回傳，不要多也不要少，使用繁體中文回傳，回傳時請確認是否為JSON好讓我做parsing，你容易忘記在question3和answer3之間加上逗號，還有，answer1和answer2要是正確選項內的「文字」而非「question"x"choice"y"」

                                {{
                                    "article_age": null,
                                    "question1": null,
                                    "question1choice1": null,
                                    "question1choice2": null,
                                    "question1choice3": null,
                                    "question1choice4": null,
                                    "answer1": null,
                                    "explanation1": null,
                                    "question2": null,
                                    "question2choice1": null,
                                    "question2choice2": null,
                                    "question2choice3": null,
                                    "question2choice4": null,
                                    "answer2": null,
                                    "explanation2": null,
                                    "question3": null,
                                    "answer3": null
                                }}
                                不要漏掉任何一個，請你嚴格檢查以後再傳給我，我要收到17行的response"。
                                """
                                response = client.chat.completions.create(
                                    model="gpt-3.5-turbo",
                                    messages=[
                                        {"role": "system",
                                         "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
                                        {"role": "user", "content": prompt}]
                                )
                                response_text = str(response)
                                start_pattern = "ChatCompletionMessage(content='{"
                                end_pattern = "', role='assistant'"
                                start = response_text.find(
                                    start_pattern) + len(start_pattern) - 1
                                end = response_text.find(end_pattern)
                                substring = response_text[start:end]
                                noenter = substring.replace("\\n", "").replace(
                                    "\n", "").replace("\\", "")
                                if '"answer3"' in noenter:
                                    answer3_index = noenter.find('"answer3"')
                                    if noenter[answer3_index - 1] != ',' and noenter[answer3_index - 2] != ',' and noenter[answer3_index - 3] != ',' and noenter[answer3_index - 4] != ',' and noenter[answer3_index - 5] != ',' and noenter[answer3_index - 6] != ',':
                                        noenter = noenter[:answer3_index] + \
                                            ',' + noenter[answer3_index:]
                                try:
                                    content_json = json.loads(noenter)
                                except json.JSONDecodeError as e:
                                    content_json = None
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
                                    sql_update_article = """
                                    UPDATE `Article`
                                    SET `article_grade` = %s
                                    WHERE `article_id` = %s
                                    """
                                    cursor.execute(
                                        sql_update_article, (content_json['article_age'], article_id))

                                    connection.commit()
                                    print('已成功匯入文章id: ' + str(article_id))
                                except Exception as e:
                                    import traceback
                                    traceback.print_exc()
                                    error = error + 1
                                    continue
                            except Exception as e:
                                import traceback
                                traceback.print_exc()
                                continue
                    except Error as e:
                        import traceback
                        traceback.print_exc()
                        continue
            except Error as e:
                import traceback
                traceback.print_exc()
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        return {'status': '指示總數： ' + str(article_id_end - article_id_start + 1) + ' 錯誤總數：' + str(error) + ' 成功率： ' + str((1 - (error)/(article_id_end - article_id_start + 1))*100) + '%'}, 200


@openAI_ns.route('/get_rate_from_answers')
class GetRateFromAnswers(Resource):
    @openAI_ns.expect(get_rate_parser)
    def post(self):
        '''傳送回答獲得評分與評語'''
        args = get_rate_parser.parse_args()
        article_id = args['article_id']
        answer = args['answer']

        # 評分標準
        rate_standard = (
            "回答評分標準\n"
            "1. 語意 (Semantics)\n"
            "1分：回答的內容與題目的核心語意完全無關，未能正確解釋相關概念。\n"
            "2分：回答包含了一些相關語意，但存在嚴重的語意偏誤或誤解。\n"
            "3分：回答基本涵蓋了主要語意，但可能存在某些不準確或語意模糊之處。\n"
            "4分：回答大部分語意正確，內容涵蓋了主要概念，但可能缺少部分細節或深入解釋。\n"
            "5分：回答語意非常精確，涵蓋了問題的所有關鍵概念，並提供了清晰、正確的解釋。\n"
            "\n"
            "2. 語用 (Pragmatics)\n"
            "1分：回答完全忽視了語境，無法正確使用語用知識來傳達意圖或達成溝通目標。\n"
            "2分：回答表達了一定的語用意圖，但存在明顯的語境錯誤或無法適當地理解問題要求。\n"
            "3分：回答在語用上較為恰當，但可能未能完全符合語境或表達意圖稍顯模糊。\n"
            "4分：回答大致符合語境需求，能夠表達清楚意圖，但仍可進一步完善表達的精確性。\n"
            "5分：回答在語用上完全符合語境，意圖表達清晰且得當，能有效達成溝通目標。\n"
            "\n"
            "3. 語法 (Syntax)\n"
            "1分：回答的句子結構混亂，存在嚴重的語法錯誤，影響理解。\n"
            "2分：回答的語法結構基本正確，但存在明顯的語法錯誤或結構不完整的問題。\n"
            "3分：回答語法結構大體正確，但可能存在一些小錯誤或不通順的地方。\n"
            "4分：回答語法清晰正確，只有少數不影響理解的小錯誤或不精確的表達。\n"
            "5分：回答語法非常正確，句子結構清晰、順暢，無明顯語法錯誤。\n\n"
        )

        # 建立資料庫連接
        connection = create_db_connection()

        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                # 查詢文章內容和問題
                sql = """
                    SELECT a.article_content, q.question3, q.question3_answer
                    FROM Question AS q
                    LEFT JOIN Article AS a ON q.article_id = a.article_id
                    WHERE a.article_id = %s;
                """
                cursor.execute(sql, (article_id,))
                article = cursor.fetchone()

                if article:
                    article_content = article['article_content']
                    question = article['question3']
                    question_answer = article['question3_answer']

                    # 組裝 Prompt
                    prompt_message = (
                        f"我有一篇文章，以及根據這篇文章所產生的開放性問題、我的回答以及此題的標準答案。"
                        f"請你根據以下三個回答評分標準去對我的回答做評分，"
                        f"三個各自最低1分，最高5分，並針對你做出的這三個評分給出理由，"
                        f"最後再給一個總評。並以JSON格式回傳，格式如下："
                        f'{{"總評": 說明整體回答表現如何, "語意得分": 1~5, "語意評分理由": 理由, '
                        f'"語用得分": 1~5, "語用評分理由": 理由, '
                        f'"語法得分": 1~5, "語法評分理由": 理由}}'
                        f"\n\n以下是文章內文、此開放性問題、我的回答和標準答案："
                        f'{{"文章內文": "{article_content}", "開放性問題": "{question}", '
                        f'"我的回答": "{answer}", "標準答案": "{question_answer}"}}\n\n{rate_standard}'
                    )

                    # 發送 OpenAI 請求
                    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
                    response = client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=[
                            {"role": "system", "content": "你是一名專門在閱讀學生答案後產生評分與評語的老師。"},
                            {"role": "user", "content": prompt_message}
                        ],
                    ) 
                    response_str = str(response)

                    content_start = response_str.find("總評") - 8
                    content_end = response_str.find("role='assistant'") - 8
                    content_json_str = response_str[content_start:content_end]
                    content_json_str = content_json_str.replace("\\n", "").replace("\n", "").replace("\\", "").strip()
                    if content_json_str[-2] == ",":
                        content_json_str = content_json_str[:-2] + content_json_str[-1]
                    if content_json_str[-1] != "}":
                        content_json_str += "}"
                    
                    print(content_json_str)

                    import json
                    content_json = None  # 初始化 content_json
                    try:
                        content_json = json.loads(content_json_str)
                        print(content_json)
                    except ValueError as e:
                        print("JSON 解析錯誤:", e)

                    # 確保 content_json 存在返回
                    if content_json:
                        return content_json, 200
                    else:
                        return {"error": "無法解析JSON"}, 500

            except Exception as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close() 


@openAI_ns.route('/follow_up_question')
class FollowUpQuestion(Resource):
    @openAI_ns.expect(follow_up_parser)
    def post(self):
        '''追問問題並解答：輸入使用者id會去找最近一筆歷史紀錄，藉由這筆歷史紀錄去找原文和問題以及正確答案'''
        args = follow_up_parser.parse_args()
        user_id = args['user_id']
        user_input = args['user_input']

        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            try:
                sql = """
                SELECT h.article_id, h.q1_user_answer, h.q2_user_answer, h.q3_user_answer, 
                       h.q3_score_1, h.q3_score_2, h.q3_score_3,
                       a.article_title, a.article_content, q.question_grade, q.question_1, 
                       q.question1_choice1, q.question1_choice2, q.question1_choice3, q.question1_choice4, 
                       q.question1_answer, q.question1_explanation, q.question_2, q.question2_choice1, 
                       q.question2_choice2, q.question2_choice3, q.question2_choice4, q.question2_answer, 
                       q.question2_explanation, q.question3, q.question3_answer
                FROM History AS h
                JOIN Article AS a ON h.article_id = a.article_id
                JOIN Question AS q ON a.article_id = q.article_id
                WHERE h.user_id = %s 
                ORDER BY h.time DESC 
                LIMIT 1;
                """
                cursor.execute(sql, (user_id,))
                record = cursor.fetchone()

                if record:
                    # 取得數據
                    article_title = record['article_title']
                    article_content = record['article_content']
                    question_1 = record['question_1']
                    question1_choice1 = record['question1_choice1']
                    question1_choice2 = record['question1_choice2']
                    question1_choice3 = record['question1_choice3']
                    question1_choice4 = record['question1_choice4']
                    question1_answer = record['question1_answer']
                    question1_explanation = record['question1_explanation']
                    question_2 = record['question_2']
                    question2_choice1 = record['question2_choice1']
                    question2_choice2 = record['question2_choice2']
                    question2_choice3 = record['question2_choice3']
                    question2_choice4 = record['question2_choice4']
                    question2_answer = record['question2_answer']
                    question2_explanation = record['question2_explanation']
                    question_3 = record['question3']
                    question3_answer = record['question3_answer']

                    q1_user_answer = record['q1_user_answer']
                    q2_user_answer = record['q2_user_answer']
                    q3_user_answer = record['q3_user_answer']
                    q3_score_1 = record['q3_score_1']
                    q3_score_2 = record['q3_score_2']
                    q3_score_3 = record['q3_score_3']

                    # 組裝 prompt message
                    prompt_message = (
                        f"以下是一篇文章的內容以及三個問題的題幹和標準答案：\n"
                        f"標題：{article_title}\n"
                        f"內容：{article_content}\n"
                        f"問題1：{question_1}\n"
                        f"問題1的四個選項：1. {question1_choice1} 2. {question1_choice2} 3. {question1_choice3} 4. {question1_choice4}\n"
                        f"問題1的正確答案是：{question1_answer}，原因為：{question1_explanation}\n"
                        f"而我問題1的回答是：{q1_user_answer}\n"
                        f"問題2：{question_2}\n"
                        f"問題2的四個選項：1. {question2_choice1} 2. {question2_choice2} 3. {question2_choice3} 4. {question2_choice4}\n"
                        f"問題2的正確答案是：{question2_answer}，原因為：{question2_explanation}\n"
                        f"而我問題2的回答是：{q2_user_answer}\n"
                        f"問題3：{question_3}\n"
                        f"標準答案是：{question3_answer}\n"
                        f"而我問題3的回答是：{q3_user_answer}\n"
                        f"我在正確度滿分五分得到：{q3_score_1}、完整度滿分五分得到：{q3_score_2}、語言表達清晰度得到：{q3_score_3}\n"
                        f"我有些關於以上題目的問題想問，問題如下，請你解釋：{user_input}\n"
                        f"回傳時，請不要換行，也不要出現斜線n的換行符號"
                    )

                    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
                    try:
                        response = client.chat.completions.create(
                            model="gpt-3.5-turbo",
                            messages=[
                                {"role": "system", "content": "你是一名專門幫學生解答疑惑的解題老師。"},
                                {"role": "user", "content": prompt_message}
                            ],
                        )
                        response_str = str(response)

                        start_token = "content='"
                        end_token = "', role='assistant'"

                        start_index = response_str.find(
                            start_token) + len(start_token)
                        end_index = response_str.find(end_token, start_index)

                        content = response_str[start_index:end_index]
                        cleaned_content = content.replace("\n", "")

                        return {"message": cleaned_content}, 200

                    except Exception as e:
                        return {"error": str(e)}, 500
                else:
                    return {"error": "No history or article record found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


# History api區
history_ns = api.namespace('History', description='與歷史紀錄操作之相關api')


def get_max_history_id(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT MAX(history_id) FROM `History`")
    result = cursor.fetchone()
    max_id = result[0] if result[0] is not None else 0
    cursor.close()
    return max_id


@history_ns.route('/get_all_history')
class DataList(Resource):
    def get(self):
        '''取得所有History資料'''
        connection = create_db_connection()
        if connection is not None:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT * FROM `History`")
            data = cursor.fetchall()
            cursor.close()
            connection.close()
            return data
        else:
            return {"error": "Unable to connect to the database"}, 500


@history_ns.route('/record_new_history')
class RecordHistory(Resource):
    @history_ns.expect(history_parser)
    def post(self):
        '''記錄新的歷史答題數據'''
        args = history_parser.parse_args()
        connection = create_db_connection()
        if connection is None:
            return {"error": "Unable to connect to the database"}, 500

        try:
            new_history_id = get_max_history_id(connection) + 1
            article_id = args['article_id']
            time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            cursor = connection.cursor(dictionary=True)
            cursor.execute(
                f"SELECT * FROM `Question` WHERE article_id = {article_id};")
            question_data = cursor.fetchone()

            question_id = question_data['question_id']

            q1_correct_answer = question_data['question1_answer']
            q2_correct_answer = question_data['question2_answer']
            q3_correct_answer = question_data['question3_answer']
            q3_aicomment = args['q3_aicomment']

            q1_is_correct = int(args['q1_user_answer'] == q1_correct_answer)
            q2_is_correct = int(args['q2_user_answer'] == q2_correct_answer)

            args['q3_total_score'] = args['q3_score_1'] + \
                args['q3_score_2'] + args['q3_score_3']
            total_score = 3 * q1_is_correct + 3 * q2_is_correct + \
                (args['q3_score_1'] * 0.26 + args['q3_score_2']
                 * 0.26 + args['q3_score_3'] * 0.28)

            insert_query = """
            INSERT INTO `History`(`history_id`, `user_id`, `article_id`, `question_id`, `time`, `q1_user_answer`, `q1_correct_answer`, `q1_is_correct`, `q2_user_answer`, `q2_correct_answer`, `q2_is_correct`, `q3_user_answer`, `q3_correct_answer`, `q3_aicomment`, `q3_score_1`, `q3_explanation1`, `q3_score_2`, `q3_explanation2`, `q3_score_3`, `q3_explanation3`, `q3_total_score`, `total_score`)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (
                new_history_id, args['user_id'], args['article_id'], question_id, time_now,
                args['q1_user_answer'], q1_correct_answer, q1_is_correct, args['q2_user_answer'], q2_correct_answer, q2_is_correct,
                args['q3_user_answer'], q3_correct_answer, q3_aicomment, args['q3_score_1'], args['q3_explanation1'], args['q3_score_2'], args['q3_explanation2'], args['q3_score_3'], args['q3_explanation3'],
                args['q3_total_score'], total_score
            ))
            connection.commit()
            return {"history_id": new_history_id}, 201

        except Error as e:
            return {"error": str(e)}, 500
        finally:
            if connection:
                connection.close()

history_id_parser = reqparse.RequestParser()
history_id_parser.add_argument(
    'history_id', type=int, required=True, help='歷史紀錄id')

@history_ns.route('/get_all_data_with_history_id')
class GetAllDataWithHistoryID(Resource):
    @history_ns.expect(history_id_parser)
    def get(self):
        '''根據 history_id 獲取歷史資料並包括對應的文章資料'''
        args = history_id_parser.parse_args()
        history_id = args['history_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                cursor.execute("""
                    SELECT H.*, A.*, Q.*
                    FROM History H
                    JOIN Article A ON H.article_id = A.article_id
                    LEFT JOIN Question Q ON A.article_id = Q.article_id
                    WHERE H.history_id = %s
                """, (history_id,))
                
                result = cursor.fetchone()

                if result:
                    for key, value in result.items():
                        if isinstance(value, Decimal):
                            result[key] = str(value)  # 轉成字串
                        elif isinstance(value, datetime):
                            result[key] = value.strftime("%Y-%m-%d %H:%M:%S")
                        elif isinstance(value, date):
                            result[key] = value.strftime("%Y-%m-%d")
                    return result, 200
                else:
                    return {"error": "History or Article not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


gethistory_id_parser = reqparse.RequestParser()
gethistory_id_parser.add_argument('user_id', type=int, required=True, help='使用者ID')
gethistory_id_parser.add_argument('article_category', type=str, required=True, help='文章類別')
@history_ns.route('/get_history_from_user')
class GetHistoryFromUser(Resource):
    @history_ns.expect(gethistory_id_parser)
    def get(self):
        '''根據 user_id 獲取歷史資料並篩選 article_category'''
        args = gethistory_id_parser.parse_args()
        user_id = args['user_id']
        article_category = args['article_category']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT h.*, a.article_title FROM `History` h JOIN `Article` a ON h.article_id = a.article_id WHERE h.user_id = %s AND a.article_category = %s ORDER BY h.time DESC;"
                cursor.execute(sql, (user_id,article_category))
                histories = cursor.fetchall()

                if histories:
                    for history in histories:
                        # 處理時間格式
                        if 'time' in history and history['time']:
                            history['time'] = history['time'].strftime(
                                '%Y-%m-%d %H:%M:%S')

                        # 將 Decimal 類型轉換為字串
                        for key in history:
                            if isinstance(history[key], Decimal):
                                history[key] = str(history[key])
                    return histories, 200
                else:
                    return {"error": "No history found for the user"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500



character_ns = api.namespace('Character', description='與角色操作相關之api')
character_id_parser = reqparse.RequestParser()
character_id_parser.add_argument(
    'character_id', type=str, required=True, help='角色id')


@character_ns.route('/get_character_from_id')
class GetCharacterFromID(Resource):
    @character_ns.expect(character_id_parser)
    def get(self):
        '''根據 character_id 獲取角色資料'''
        args = character_id_parser.parse_args()
        character_id = args['character_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT * FROM `Character` WHERE character_id = %s"
                cursor.execute(sql, (character_id,))
                character = cursor.fetchone()

                if character:
                    # 檢查角色中是否有二進制的圖片數據
                    if 'character_image' in character:
                        # 將二進制圖片數據轉換為 base64 字符串
                        character['character_image'] = base64.b64encode(
                            character['character_image']).decode('utf-8')

                    return character, 200
                else:
                    return {"error": "Character not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@character_ns.route('/upload_character_image')
class UploadCharacterImage(Resource):
    @character_ns.expect(character_image_upload_parser)
    def post(self):
        '''上傳角色圖片並儲存到資料庫'''
        args = character_image_upload_parser.parse_args()
        character_name = args['character_name']
        uploaded_image = args['image']

        image_data = uploaded_image.read()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                # 插入圖片與角色名稱到資料庫
                sql = """
                INSERT INTO `Character` (character_name, character_image)
                VALUES (%s, %s)
                """
                cursor.execute(sql, (character_name, image_data))
                connection.commit()
                return {"message": "Image uploaded successfully"}, 201
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


enemy_ns = api.namespace('Enemy', description='與敵人操作相關之api')
enemy_category_parser = reqparse.RequestParser()
enemy_category_parser.add_argument(
    'enemy_category', type=int, required=True, help='敵人編號(100a的100)')


@enemy_ns.route('/get_enemy_from_id')
class GetEnemyFromID(Resource):
    @enemy_ns.expect(enemy_category_parser)
    def get(self):
        '''根據 enemy_category 獲取敵人資料'''
        args = enemy_category_parser.parse_args()
        enemy_category = args['enemy_category']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT * FROM Enemy WHERE enemy_category = %s"
                cursor.execute(sql, (enemy_category,))
                enemies = cursor.fetchall()  # 使用 fetchall 獲取所有資料

                if enemies:
                    for enemy in enemies:
                        # 檢查角色中是否有二進制的圖片數據
                        if 'enemy_image' in enemy and enemy['enemy_image']:
                            # 將二進制圖片數據轉換為 base64 字符串
                            enemy['enemy_image'] = base64.b64encode(
                                enemy['enemy_image']).decode('utf-8')

                    return enemies, 200
                else:
                    return {"error": "Enemy not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


@enemy_ns.route('/upload_enemy_image')
class UploadEnemyImage(Resource):
    @enemy_ns.expect(enemy_image_upload_parser)
    def post(self):
        '''上傳角色圖片並儲存到資料庫'''
        args = enemy_image_upload_parser.parse_args()
        enemy_category = args['enemy_category']
        uploaded_image = args['image']

        image_data = uploaded_image.read()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                # 插入圖片與角色名稱到資料庫
                sql = """
                INSERT INTO `Enemy` (enemy_category, enemy_image)
                VALUES (%s, %s)
                """
                cursor.execute(sql, (enemy_category, image_data))
                connection.commit()
                return {"message": "Image uploaded successfully"}, 201
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500


shortquestion_ns = api.namespace('Shortquestion', description='與短題目操作相關之api')
shortquestion_age_parser = reqparse.RequestParser()
shortquestion_age_parser.add_argument(
    'shortquestion_age', type=int, required=True, help='短題目年齡適合問題')

compete_ns = api.namespace('Compete', description='與對戰操作相關之api')
match_parser = reqparse.RequestParser()
match_parser.add_argument('user_id', type=int, required=True, help='使用者ID')


@compete_ns.route('/match_user')
class MatchUser(Resource):
    @compete_ns.expect(match_parser)
    def post(self):
        args = match_parser.parse_args()
        user_id = args['user_id']

        connection = create_db_connection()
        if connection:
            try:
                cursor = connection.cursor()

                # 1. 查詢使用者年齡，若年齡大於15則視為15
                cursor.execute(
                    "SELECT user_birthday FROM User WHERE user_id = %s", (user_id,))
                result = cursor.fetchone()
                if not result:
                    return {"error": "User not found"}, 404
                
                user_birthday = result[0]
                today = datetime.today()
                user_age = today.year - user_birthday.year - \
                    ((today.month, today.day) <
                     (user_birthday.month, user_birthday.day))
                user_age = min(user_age, 15)

                # 2. 檢查當前使用者是否已經在等待隊列中，並且有匹配對手
                cursor.execute("""
                    SELECT user_matched_id, question_set FROM WaitingQueue WHERE user_id = %s
                """, (user_id,))
                existing_record = cursor.fetchone()

                if existing_record:
                    user_matched_id, question_set = existing_record

                    # 如果 user_matched_id 不為空，說明已經匹配到了對手
                    if user_matched_id:
                        print(user_matched_id)
                        cursor.execute("SELECT compete_id FROM Compete WHERE user1_id = %s AND user2_id = %s ORDER BY compete_id DESC LIMIT 1;", (user_id, user_matched_id))
                        compete_record = cursor.fetchone()
                        new_compete_id = compete_record[0]
                        # 刪除該列並返回匹配成功和對手資料
                        cursor.execute("DELETE FROM WaitingQueue WHERE user_id = %s", (user_id,))
                        connection.commit()

                        return {
                            "message": "Match found",
                            "compete_id": new_compete_id,
                            "opponent_id": user_matched_id,
                            # 將 JSON 題目集轉為 Python 字典
                            "questions": json.loads(question_set)
                        }, 200

                    # 如果還沒匹配到對手
                    return {"message": "Already waiting for an opponent"}, 201

                # 3. 檢查是否有年齡匹配的使用者
                cursor.execute("""
                    SELECT user_id, question_set FROM WaitingQueue
                    WHERE user_id != %s AND user_age = %s
                    ORDER BY created_at ASC
                    LIMIT 1
                """, (user_id, user_age))
                match = cursor.fetchone()

                if match:
                    matched_user_id = match[0]
                    question_set = match[1]  # 匹配對手的題目集

                    # 4. 更新匹配到的對手的 user_matched_id 欄位
                    cursor.execute("""
                        UPDATE WaitingQueue
                        SET user_matched_id = %s
                        WHERE user_id = %s
                    """, (user_id, matched_user_id))
                    connection.commit()

                    #這裡要insert進去新的Compete列，決定誰是User_1誰是User_2
                    cursor.execute("""
                        INSERT INTO Compete (user1_id, user2_id, user1_score, user2_score, compete_time)
                        VALUES (%s, %s, %s, %s, NOW())
                    """, (matched_user_id, user_id, 0, 0))
                    compete_id = cursor.lastrowid
                    connection.commit()

                    # 5. 返回匹配成功和題目集
                    return {
                        "message": "Match found",
                        "compete_id": compete_id,
                        "opponent_id": matched_user_id,
                        # 將 JSON 題目集轉為 Python 字典
                        "questions": json.loads(question_set)
                    }, 200
                else:
                    # 6. 選取年齡相符的四道題目，這一次隨機選取後存入等待隊列
                    cursor.execute("""
                        SELECT * FROM ShortQuestion
                        WHERE shortquestion_age BETWEEN 8 AND %s + 1
                        ORDER BY RAND()
                        LIMIT 5
                    """, (user_age,))
                    questions = cursor.fetchall()

                    if len(questions) != 5:
                        return {"error": "Insufficient questions available"}, 500

                    formatted_questions = [
                        {
                            "shortquestion_id": q[0],
                            "shortquestion_content": q[1],
                            "shortquestion_age": q[2],
                            "shortquestion_option1": q[3],
                            "shortquestion_option2": q[4],
                            "shortquestion_option3": q[5],
                            "shortquestion_option4": q[6],
                            "answer": q[7]
                        }
                        for q in questions
                    ]

                    # 7. 將當前使用者和隨機選取的題目集加入等待隊列
                    cursor.execute("""
                        INSERT INTO WaitingQueue (user_id, user_age, created_at, question_set)
                        VALUES (%s, %s, NOW(), %s)
                    """, (user_id, user_age, json.dumps(formatted_questions)))
                    connection.commit()

                    return {"message": "Waiting for an opponent"}, 200

            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

@compete_ns.route('/cancel_queue')
class CancelQueue(Resource):
    @compete_ns.expect(match_parser)
    def delete(self):
        '''從等待隊列中刪除該使用者的紀錄'''
        args = match_parser.parse_args()
        user_id = args['user_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                # 刪除 WaitingQueue 中該 user_id 的紀錄
                cursor.execute("DELETE FROM WaitingQueue WHERE user_id = %s", (user_id,))
                connection.commit()
                return {"message": "User removed from queue successfully"}, 200
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

# 定義parser來解析compete_id
compete_id_parser = reqparse.RequestParser()
compete_id_parser.add_argument('compete_id', type=int, required=True, help='對戰ID')

@compete_ns.route('/get_compete_from_id')
class GetCompeteById(Resource):
    @compete_ns.expect(compete_id_parser)
    def get(self):
        '''根據 compete_id 獲取比賽資料'''
        args = compete_id_parser.parse_args()
        compete_id = args['compete_id']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor(dictionary=True)
                sql = "SELECT * FROM Compete WHERE compete_id = %s"
                cursor.execute(sql, (compete_id,))
                compete = cursor.fetchone()

                if compete:
                    # 將所有 datetime 類型的欄位轉為 ISO 格式
                    for key, value in compete.items():
                        if isinstance(value, (date, datetime)):
                            compete[key] = value.isoformat()
                    return compete, 200
                else:
                    return {"error": "Compete not found"}, 404
            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

update_answer_parser = reqparse.RequestParser()
update_answer_parser.add_argument('user_id', type=int, required=True, help='使用者 ID')
update_answer_parser.add_argument('compete_id', type=int, required=True, help='比賽 ID')
update_answer_parser.add_argument('question_number', type=int, required=True, help='問題編號，1-5 之間')
update_answer_parser.add_argument('selected_option', type=int, required=True, help='使用者選擇的選項')
update_answer_parser.add_argument('score', type=int, required=True, help='總分')
@compete_ns.route('/update_answer')
class UpdateAnswer(Resource):
    @compete_ns.expect(update_answer_parser)
    def post(self):
        """
        根據 user_id 和 compete_id 更新對應的問題答案與分數
        傳入參數: user_id, compete_id, question_number, selected_option, score
        """
        args = update_answer_parser.parse_args()
        user_id = args['user_id']
        compete_id = args['compete_id']
        question_number = args['question_number']
        selected_option = args['selected_option']
        score = args['score']

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()

                # 1. 確認 user_id 是 user1 還是 user2
                cursor.execute("""
                    SELECT user1_id, user2_id FROM Compete WHERE compete_id = %s
                """, (compete_id,))
                compete_record = cursor.fetchone()

                if not compete_record:
                    return {"error": "Compete not found"}, 404

                user1_id, user2_id = compete_record

                if user_id == user1_id:
                    user_type = 'user1'
                elif user_id == user2_id:
                    user_type = 'user2'
                else:
                    return {"error": "User not part of this competition"}, 400

                # 2. 根據 question_number 更新對應的欄位
                if question_number < 1 or question_number > 5:
                    return {"error": "Invalid question number"}, 400

                question_field = f"{user_type}_question{question_number}"
                score_field = f"{user_type}_score"

                # 更新選項與分數
                cursor.execute(f"""
                    UPDATE Compete
                    SET {question_field} = %s, {score_field} = %s
                    WHERE compete_id = %s
                """, (selected_option, score, compete_id))
                connection.commit()

                return {"message": "Answer and score updated successfully"}, 200

            except Error as e:
                return {"error": str(e)}, 500
            finally:
                cursor.close()
                connection.close()
        else:
            return {"error": "Unable to connect to the database"}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
