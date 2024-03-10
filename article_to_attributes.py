from flask import Flask, request, jsonify, render_template
import openai

app = Flask(__name__)

# 請替換成您的OpenAI API密鑰
openai.api_key = f'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'

@app.route('/')
def index():
    # 渲染前端頁面
    return render_template('article_to_attributes.html')

@app.route('/evaluate', methods=['POST'])
def evaluate_article():
    # 從請求中獲取文章內容
    data = request.json
    article = data.get('article')
    if not article:
        return jsonify({'error': '未提供文章內容'}), 400

    # 評估適讀年齡
    age = evaluate_reading_age(article)
    # 生成問題
    question1, options1, answer1, explanation1 = generate_question(article, age, -1)
    question2, options2, answer2, explanation2 = generate_question(article, age, 1)
    question3 = generate_open_ended_question(article, age)
    
    # 返回生成的問題
    return jsonify({
        'age': age,
        'question1': {
            'question': question1,
            'options': options1,
            'correct_answer': answer1,
            'explanation': explanation1
        },
        'question2': {
            'question': question2,
            'options': options2,
            'correct_answer': answer2,
            'explanation': explanation2
        },
        'question3': question3
    })

def evaluate_reading_age(article):
    # 使用OpenAI API評估文章的適讀年齡
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",
        prompt=f"根據以下文章內容，評估適合的閱讀年齡為何？請給我一個阿拉伯數字就好，不要其他的冗言贅字或理由，就是一個單純的數字，幾歲的學生是適合讀這篇文章的？\n\n{article}",
        temperature=0.7,
        max_tokens=50,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )
    try:
        age_estimate = int(response.choices[0].text.strip())
    except ValueError:
        age_estimate = 10
    return age_estimate

def generate_question(article, age, adjustment=0):
    # 根據指定年齡生成選擇題
    adjusted_age = age + adjustment
    prompt = f"給定以下文章：\n\n{article}\n\n為{adjusted_age}歲的兒童創建一個適合的選擇題問題，一定要包括四個選項和一個正確答案。"
    
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",
        prompt=prompt,
        temperature=0.5,
        max_tokens=200,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )
    output = response.choices[0].text.strip().split('\n')
    question = output[0]
    options = output[1:5]
    correct_answer = output[-1].split(". ")[-1]  # 假設正確答案是最後一行，並且格式為"X. 答案"
    explanation = f"正確答案是{correct_answer}，因為..."
    return question, options, correct_answer, explanation

def generate_open_ended_question(article, age):
    # 根據指定年齡生成開放式問題
    prompt = f"給定以下文章：\n\n{article}\n\n為{age}歲的學生創建「一個」適合的開放式問題，問題一定要跟文章有關聯，然後一個問題就好，不多也不少。"
    
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",
        prompt=prompt,
        temperature=0.5,
        max_tokens=100,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )
    question = response.choices[0].text.strip()
    return question

if __name__ == '__main__':
    app.run(debug=True)
