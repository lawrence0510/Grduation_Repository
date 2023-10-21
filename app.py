import os
import openai
from flask import Flask, request, jsonify, render_template
import json

openai.api_key = f'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'


def article_to_question(text):
    messages = [
        {"role": "system", "content": "你是一名專門在閱讀文章後產生問題給學生回答的得力助手。"},
        {"role": "user", "content": text +
            "\n 根據以上文本，請使用繁體中文提供三個關於此文本的問題，以及答案和詳細解釋。"},
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
    print(result + '\n\n')
    questions_and_answers = parse_questions_and_answers(result)
    print(questions_and_answers)
#     text = """
# 問題1：輕微燒燙傷時，可以使用哪些止痛藥物？

# 答案：輕微燒燙傷時，可以使用乙醯胺酚（Acetaminophen）和非類固醇消炎藥（NSAIDs），如阿斯匹靈（Aspirin）、布洛芬（Ibuprofen）等。

# 解釋：根據文本所述，在輕微燒燙傷的情況下，可使用乙醯胺酚和非類固醇消炎藥來緩解疼痛。

# 問題2：淺二度燒燙傷時，傷口常出現什麼狀況？應如何處理？

# 答案：淺二度燒燙傷時，傷口常出現水泡。應盡量維持水泡的完整，用自身的表皮作為天然的保護，以減少感染的風險。

# 解釋：根據文本所述，淺二度燒燙傷常伴隨著水泡的形成。在這種情況下，應該盡量保持水泡完整，因為水泡可以起到保護傷口的作用，避免感染。

# 問題3：在清洗淺表性燒燙傷傷口時，推薦使用什麼方法？

# 答案：在清洗淺表性燒燙傷傷口時，推薦使用溫和的肥皂和自來水。

# 解釋：根據文本所述，目前的研究不再建議使用皮膚消毒劑（如優碘）來清洗傷口，而是建議使用溫和的肥皂和自來水來清洗淺表性燒燙傷傷口，以避免消毒劑對傷口癒合的不良影響。
# """
    # questions_and_answers = parse_questions_and_answers(text)
    return questions_and_answers


@app.route('/')
def index():
    return render_template('index.html')


def parse_questions_and_answers(text):
    lines = [line for line in text.split('\n') if line.strip()]  # 排除空行
    data = {}
    question_count = 1
    answer_count = 1
    explanation_count = 1

    if(len(lines) == 6):
        for i in range(0, len(lines), 2):
            if i + 2 < len(lines):
                question_key = f"question{question_count}"
                answer_key = f"answer{answer_count}"

                data[question_key] = lines[i].strip()
                data[answer_key] = lines[i + 1].strip()

                question_count += 1
                answer_count += 1
    elif(len(lines) == 9):
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
