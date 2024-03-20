from flask import Flask
from flask_restx import Api, Resource
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
api = Api(app, version='1.0', title='API Documentation',
          description='A simple API')

ns = api.namespace('User', description='User operations')

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

if __name__ == '__main__':
    app.run(debug=True)
