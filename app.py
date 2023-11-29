import os
import openai
from flask import Flask, request, jsonify, render_template
import json

openai.api_key = f'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'


def article_to_question(text):
    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": text +
            "\n 根據以上文本，請使用繁體中文提供三個關於此文本的問題，以及答案和詳細解釋。我要你回答的格式如下：問題1：（第一題問題）\n答案1：（第一題答案）\n解釋1：（第一題解釋）\n問題2：（第二題問題）\n答案2：（第二題答案）\n解釋2：（第二題解釋）\n問題3：（第三題問題）\n答案3：（第三題答案）\n解釋3：（第三題解釋），一共應該會有九行輸出"},
    ]

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages
    )

    answer = response['choices'][0]['message']['content']
    return answer


def response_to_answers(a1, a2, a3):
    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": a1+"\n"+a2+"\n"+a3+"\n" +
            "以上是我的回答，請你根據以下格式評價我的回答：第一題：正確度（）分、切題度（）分、完整度（）分、評語：（）\n第二題：正確度（）分、切題度（）分、完整度（）分、評語：（）\n第三題：正確度（）分、切題度（）分、完整度（）分、評語：（）。以1到5分為基準，一分為最低，完全不正確以及完全不切題、回答簡短等，要根據內容給予回饋，譬如說你覺得第一題回答的部分你給了三個4分，是哪裡可以做得更好。分數評比可以嚴格些，回答應該只有三行。"},
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
    questions_and_answers = parse_questions_and_answers(result)
    return questions_and_answers


@app.route('/generate_answers', methods=['POST', 'GET'])
def generate_answers():
    answer1 = request.json['answer1']
    answer2 = request.json['answer2']
    answer3 = request.json['answer3']
    result = response_to_answers(answer1, answer2, answer3)
    lines = [line for line in result.split('\n') if line.strip()]
    data={}
    data["rate1"] = lines[0].strip()
    data["rate2"] = lines[1].strip()
    data["rate3"] = lines[2].strip()
    return data


@app.route('/')
def index():
    return render_template('index.html')


def parse_questions_and_answers(text):
    print(text)
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    data = {}
    question_count = 1
    answer_count = 1
    explanation_count = 1
    if (len(lines) == 9):
        for i in range(0, len(lines), 3):
            if i + 2 < len(lines):
                question_key = f"question{question_count}"
                answer_key = f"answer{answer_count}"
                explanation_key = f"explanation{explanation_count}"

                data[question_key] = lines[i].strip()
                data[answer_key] = lines[i + 1].strip()
                data[explanation_key] = lines[i + 2].strip()

                question_count += 1
                answer_count += 1
                explanation_count += 1
    else:
        temp = {'question1': 'temporary failure'}
        return temp

    return data


if __name__ == "__main__":
    app.run(debug=True)
