from flask import Flask, jsonify, request, render_template

app = Flask(__name__)

def simulate_openai_response():
    simulated_responses = {
        "question1": "This is a simulated question for question 1",
        "answer1": "This is a simulated answer for question 1",
        "explanation1": "This is a simulated explanation for question 1",
        "question2": "This is a simulated question for question 2",
        "answer2": "This is a simulated answer for question 2",
        "explanation2": "This is a simulated explanation for question 2",
        "question3": "This is a simulated question for question 3",
        "answer3": "This is a simulated answer for question 3",
        "explanation3": "This is a simulated explanation for question 3",
    }
    return simulated_responses

@app.route('/generate_questions', methods=['POST', 'GET'])
def generate_questions():
    input_text = request.json['text']
    questions_and_answers = simulate_openai_response()
    return jsonify(questions_and_answers)

@app.route('/generate_answers', methods=['POST', 'GET'])
def generate_answers():
    answer1 = request.json['answer1']
    answer2 = request.json['answer2']
    answer3 = request.json['answer3']
    
    simulated_result = simulate_openai_response()
    
    data = {
        "rate1": simulated_result["answer1"],
        "rate2": simulated_result["answer2"],
        "rate3": simulated_result["answer3"],
    }
    return jsonify(data)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True)
