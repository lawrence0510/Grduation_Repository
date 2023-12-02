import os
import openai
from flask import Flask, request, jsonify, render_template
import json

openai.api_key = f'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'


def article_to_question(text):
    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": text +
            "\n 根據以上文本，請使用繁體中文提供三個關於此文本的問題，以及答案和詳細解釋。我要你回答的格式如下：問題1：（第一題問題）\n答案1：（第一題答案）\n解釋1：（第一題解釋）\n問題2：（第二題問題）\n答案2：（第二題答案）\n解釋2：（第二題解釋）\n問題3：（第三題問題）\n答案3：（第三題答案）\n解釋3：（第三題解釋），不要有任何多餘的行，只有剛好九行輸出"},
    ]

    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages
    )

    answer = response['choices'][0]['message']['content']
    return answer

def response_to_answers(a1, a2, a3):
    prompt = (
        "現在，我要回答問題，請你根據以下評分標準來針對我的回答評分：\n"
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

    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": f"{prompt}\n以下是我第一題的回答，請根據此格式評價我的回答，請你只參考我第一題的回答做出評價\n格式：「第一題：正確度（）分、完整度（）分、語言表達清晰度（）分、評語：（）」\n"+a1+"\n"},
        {"role": "user", "content": "以下是我第二題的回答，請根據此格式評價我的回答，請你只參考我第二題的回答做出評價\n格式：「第二題：正確度（）分、完整度（）分、語言表達清晰度（）分、評語：（）」\n"+a2+"\n"},
        {"role": "user", "content": "以下是我第三題的回答，請根據此格式評價我的回答，請你只參考我第三題的回答做出評價\n格式：「第三題：正確度（）分、完整度（）分、語言表達清晰度（）分、評語：（）」\n"+a3+"\n"},
    ]

    response = openai.ChatCompletion.create(model="gpt-3.5-turbo", messages=messages)

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
    data = {}
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
