from flask import Flask, session, jsonify
from flask_restx import Api, Resource, reqparse
import mysql.connector
from mysql.connector import Error
import hashlib
import openai
from datetime import datetime, timedelta
from werkzeug.datastructures import FileStorage
import pandas as pd


openai.api_key = f'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'
app = Flask(__name__)
app.secret_key = '5b52b65660fc4c498fe0ed356fdc5212'
api = Api(app, version='1.0', title='Graduation_Repository APIs', description='110級畢業專案第一組\n組員：吳堃豪、侯程麟、謝佳蓉、許馨文、王暐睿\n指導教授：洪智鐸')

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
user_parser.add_argument('user_password', type=str, required=True, help='使用者密碼')
user_parser.add_argument('user_school', type=str, required=True, help='使用者學校')
user_parser.add_argument('user_age', type=int, required=True, help='使用者年齡')
user_parser.add_argument('user_email', type=str, required=True, help='使用者email')
user_parser.add_argument('user_phone', type=str, required=True, help='使用者電話')

login_parser = reqparse.RequestParser()
login_parser.add_argument('user_name', type=str, required=True, help='使用者名稱')
login_parser.add_argument('user_password', type=str, required=True, help='使用者密碼')

user_id_parser = reqparse.RequestParser()
user_id_parser.add_argument('user_id', type=int, required=True, help='使用者ID')

email_reset_parser = reqparse.RequestParser()
email_reset_parser.add_argument('original_email', type=str, required=True, help='使用者舊email')
email_reset_parser.add_argument('original_password', type=str, required=True, help='使用者密碼')
email_reset_parser.add_argument('new_email', type=str, required=True, help='使用者新email')

password_reset_parser = reqparse.RequestParser()
password_reset_parser.add_argument('user_email', type=str, required=True, help='使用者email')
password_reset_parser.add_argument('original_password', type=str, required=True, help='使用者舊密碼')
password_reset_parser.add_argument('new_password', type=str, required=True, help='使用者新密碼')

phone_reset_parser = reqparse.RequestParser()
phone_reset_parser.add_argument('user_email', type=str, required=True, help='使用者email')
phone_reset_parser.add_argument('user_password', type=str, required=True, help='使用者密碼')
phone_reset_parser.add_argument('new_phone', type=str, required=True, help='使用者新電話號碼')

name_reset_parser = reqparse.RequestParser()
name_reset_parser.add_argument('user_email', type=str, required=True, help='使用者email')
name_reset_parser.add_argument('user_password', type=str, required=True, help='使用者密碼')
name_reset_parser.add_argument('new_name', type=str, required=True, help='使用者新名稱')

school_reset_parser = reqparse.RequestParser()
school_reset_parser.add_argument('user_email', type=str, required=True, help='使用者email')
school_reset_parser.add_argument('user_password', type=str, required=True, help='使用者密碼')
school_reset_parser.add_argument('new_school', type=str, required=True, help='新學校名稱')

article_upload_parser = reqparse.RequestParser()
article_upload_parser.add_argument('file', type=FileStorage, location='files', required=True, help='可以上傳Excel檔案，格式要是|article_title|article_link|article_content|')

get_questions_parser = reqparse.RequestParser()
get_questions_parser.add_argument('article_text', type=str, required=True, help='欲產生問題之文章內文')


#User api區
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
                cursor.execute(sql, (new_user_id, user_name, encrypted_password, user_school, user_age, user_email, user_phone))
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
                cursor.execute(select_sql, (original_email, encrypted_password))
                user = cursor.fetchone()
                if user:
                    update_sql = "UPDATE `User` SET `user_email` = %s WHERE `user_email` = %s AND `user_password` = %s"
                    cursor.execute(update_sql, (new_email, original_email, encrypted_password))
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
        encrypted_original_password = hashlib.sha256(original_password.encode()).hexdigest()
        encrypted_new_password = hashlib.sha256(new_password.encode()).hexdigest()

        connection = create_db_connection()
        if connection is not None:
            try:
                cursor = connection.cursor()
                sql = "SELECT `user_id` FROM `User` WHERE `user_email` = %s AND `user_password` = %s"
                cursor.execute(sql, (user_email, encrypted_original_password))
                user = cursor.fetchone()
                if user:
                    update_sql = "UPDATE `User` SET `user_password` = %s WHERE `user_email` = %s"
                    cursor.execute(update_sql, (encrypted_new_password, user_email))
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
                cursor.execute(update_sql, (new_phone, user_email, encrypted_password))
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
                cursor.execute(update_sql, (new_name, user_email, encrypted_password))
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
                cursor.execute(update_sql, (new_school, user_email, encrypted_password))
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

#Article api區
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
                        article['article_expired_day'] = article['article_expired_day'].strftime('%Y-%m-%d')
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
                    article_expired_day = (datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

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
                article_expired_day = (datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')
                
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

#OpenAI api區
openAI_ns = api.namespace('OpenAI', description='與openai操作相關之api，‼️此區皆為付費區，需測試請先洽Lawrence‼️')

@openAI_ns.route('/get_questions_from_article')
class GetQuestionsFromArticle(Resource):
    @openAI_ns.expect(get_questions_parser)
    def post(self):
        '''傳送文章內容至openai API，獲得三個問題及標準答案'''




if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)