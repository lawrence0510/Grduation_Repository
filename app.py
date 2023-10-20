import os
import openai
from flask import Flask, request, jsonify, render_template

openai.api_key = f'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'

def article_to_question(text):
    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": text + "\n 根據以上文本，請使用繁體中文提供三個關於此文本的問題，以及答案和詳細解釋。"},
    ]

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages
    )

    answer = response['choices'][0]['message']['content']
    return answer

app = Flask(__name__)
@app.route('/generate_questions', methods=['POST', 'GET'])

def generate_questions():
    input_text = request.json['text']
    result = article_to_question(input_text)
    return result

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True)


