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
    # input_text = request.json['text']
    # result = article_to_question(input_text)
    # questions_and_answers = parse_questions_and_answers(result)
    text = """
question1: 輕微燒燙傷的止痛方法有哪些？
answer1: 輕微燒燙傷可以使用乙醯胺酚 Acetaminophen 和非類固醇消炎藥（NSAIDs），如阿斯匹靈 Aspirin、布洛芬 Ibuprofen 等。這些藥物可以幫助緩解疼痛和消炎。
explanation1: 文本提到在止痛上，輕微燒燙傷可以使用乙醯胺酚和非類固醇消炎藥，如阿斯匹靈和布洛芬。這些藥物可以減輕痛楚和消除炎症，幫助舒緩燒傷的不適感。

question2: 淺二度燒燙傷傷口出現水泡時，應該如何處理？
answer2: 淺二度燒燙傷傷口出現水泡時，應該盡量保持水泡的完整，使用自身的表皮作為保護，以減少感染的風險。
explanation2: 文本提到，淺二度燒燙傷傷口通常會出現水泡。在這種情況下，應該盡量保持水泡的完整，因為水泡可以作為一種天然保護層，降低傷口感染的機會。

question3: 清洗燒燙傷傷口時，應該使用什麼來清潔？
answer3: 目前的研究不再建議使用皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口，而是建議使用溫和的肥皮膚消毒劑來清潔燒燙傷傷口。
explanation3: 文本提到，用於清洗表淺性燒燙傷傷口的方法為使用溫和的肥皂和自來水。最新的研究不再推薦使用皮膚消毒劑，因為這些劑可能抑制傷口癒合並引起色素沉澱。使用溫和的肥皂和自來水可以達到清潔傷口的效果，同時不會對傷口癒合造成不良影響。
"""

    a = {
        "question1": "什麼樣的燒燙傷需要轉診到燒燙傷中心或具專業燒燙傷處置外科醫師的醫院？",
        "answer1": "若水泡持續數週沒有被吸收，則代表可能有潛在的深二度或三度燒燙傷，需要轉診到燒燙傷中心或具專業燒燙傷處置外科醫師的醫院。這表示長時間存在水泡可能表示燒燙傷的嚴重程度較高，可能需要更專業的醫療處置。",
        "question2": "在清潔表淺性燒燙傷傷口時，為什麼不建議使用皮膚消毒劑？",
        "answer2": "研究顯示，皮膚消毒劑（如優碘）可能抑制傷口的癒合並造成色素沉澱。因此，目前建議使用溫和的肥皂和自來水來清洗表淺性燒燙傷傷口，以避免這些問題的發生。",
        "question3": "在哪些情況下需要使用局部抗菌劑和細胞保護敷料來覆蓋燒燙傷傷口？",
        "answer3": "如果是表皮不完整的二、三級燒燙傷的情況，則需根據燒燙傷部位、深淺及醫師評估來選用燙傷藥膏。在這種情況下，局部抗菌劑和細胞保護敷料是傷口覆蓋的最佳選擇，以幫助保護傷口並預防感染。"
    }
    print(a)
    return a


@app.route('/')
def index():
    return render_template('index.html')


def parse_questions_and_answers(result):
    # Split the text by lines
    lines = result.split('\n')

    # Initialize variables
    result_dict = {}
    current_question = None
    current_answer = None
    current_explanation = None

    for line in lines:
        line = line.strip()
        if line.startswith("question"):
            if current_question is not None:
                result_dict[current_question] = {
                    "question": current_question,
                    "answer": current_answer,
                    "explanation": current_explanation
                }

            current_question = line
            current_answer = None
            current_explanation = None
        elif line.startswith("answer"):
            current_answer = line
        elif line.startswith("explanation"):
            current_explanation = line

    # Add the last question-answer pair
    if current_question is not None:
        result_dict[current_question] = {
            "question": current_question,
            "answer": current_answer,
            "explanation": current_explanation
        }

    return result_dict


if __name__ == "__main__":
    app.run(debug=True)
