from flask import Flask
from flask_restx import Api, Resource, reqparse
import mysql.connector
from mysql.connector import Error
import hashlib

app = Flask(__name__)
api = Api(app, version='1.0', title='Graduation_Repository APIs', description='110級畢業專案第一組\n組員：吳堃豪、侯程麟、謝佳蓉、許馨文、王暐睿\n指導教授：洪智鐸')

parser = reqparse.RequestParser()
parser.add_argument('user_name', type=str, required=True, help='The user name')
parser.add_argument('user_password', type=str, required=True, help='The user password')
parser.add_argument('user_school', type=str, required=True, help='The user school')
parser.add_argument('user_age', type=int, required=True, help='The user age')
parser.add_argument('user_email', type=str, required=True, help='The user email')
parser.add_argument('user_phone', type=str, required=True, help='The user phone number')

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

ns = api.namespace('User', description='User operations')

def get_max_user_id(cursor):
    cursor.execute("SELECT MAX(user_id) FROM `User`")
    result = cursor.fetchone()
    max_id = result[0] if result[0] is not None else 0
    return max_id + 1

@ns.route('/getalluser')
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

@ns.route('/register')
class RegisterUser(Resource):
    @ns.expect(parser)
    def post(self):
        '''註冊新用戶'''
        args = parser.parse_args()
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
                new_user_id = get_max_user_id(cursor)
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)