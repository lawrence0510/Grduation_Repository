import os
import openai

openai.api_key = 'YOUR_API_KEY'

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

def main():
    with open('article.txt', 'r') as file:
        article_text = file.read()

    result = article_to_question(article_text)

    with open('output.txt', 'w') as output_file:
        output_file.write(result)

    print("已輸出至output.txt")

if __name__ == "__main__":
    main()


