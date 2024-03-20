from flask import Flask, request, jsonify, render_template
import openai
import json

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
    questions = generate_questions(article, age)
    question3 = generate_open_ended_question(article, age)
    
    # 返回生成的問題
    return jsonify({
        'age': age,
        **questions,  # 展開questions字典以包含所有問題
        'question3': question3
    })

def evaluate_reading_age(article):
    # 使用OpenAI API評估文章的適讀年齡
    prompt = f"給定以下文章：\n\n{article}\n\n請你判斷這篇文章是適合幾歲的學生閱讀，答案只能給一個阿拉伯數字，不要有其他多餘的冗字，給一個「阿拉伯數字」代表其年齡即可。"
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",
        prompt=prompt,
        temperature=0.5,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )
    try:
        age_estimate = int(response.choices[0].text.strip())
    except ValueError:
        age_estimate = 5
    return age_estimate

def generate_questions(article, age):
    prompt = (f"給定以下文章：\n\n{article}\n\n"
              f"請為{age-1}歲和{age+1}歲的兒童各創建一個適合的選擇題問題，"
              f"每個問題都要包括四個選項和一個正確答案，以及一個解析。"
              f"請確保這兩個問題是不同的。"
              f"然後，請你follow以下格式回傳給我。\n"
              f"問題1：（這邊放入問題1的內容）\n"
              f"選項A： \n選項B： \n選項C： \n選項D：\n"
              f"答案1：\n"
              f"解釋1：\n"
              f"問題2：（這邊放入問題2的內容）\n"
              f"選項A： \n選項B： \n選項C： \n選項D：\n"
              f"答案2：\n"
              f"解釋2：\n")

    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",
        prompt=prompt,
        temperature=0.5,
        max_tokens=2000,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )

    output = response.choices[0].text.strip().split('\n')  # 直接按行分割
    print(output)
    # 解析問題1
    question1 = output[0].strip()
    options1 = {
        'A': output[1].strip(),
        'B': output[2].strip(),
        'C': output[3].strip(),
        'D': output[4].strip(),
    }
    answer1 = output[5].strip()
    explanation1 = output[6].strip()

    # 解析問題2
    question2 = output[8].strip()
    options2 = {
        'A': output[9].strip(),
        'B': output[10].strip(),
        'C': output[11].strip(),
        'D': output[12].strip(),
    }
    answer2 = output[13].strip()
    explanation2 = output[14].strip()

    questions = {
        'question1': {
            'question': question1,
            'options': options1,
            'correct_answer': answer1,
            'explanation': explanation1,
        },
        'question2': {
            'question': question2,
            'options': options2,
            'correct_answer': answer2,
            'explanation': explanation2,
        }
    }

    return questions



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
