from docx import Document
import json

# 讀取 Word 文件
doc = Document("/Users/kunhaowu/Desktop/College/code projects/Grduation_Repository/教科書題目/國文/四上國文閱讀_題目&詳解_1卷.docx")
all_text = []

for para in doc.paragraphs:
    all_text.append(para.text.strip())

# 處理每個段落的資料並依照規則進行拆分
results = []

for i in range(0, len(all_text), 4):
    # 第1個元素處理
    article_data = {}
    first_element = all_text[i]
    
    # article_title: 第一個字到第一個\n之前
    article_title_end_idx = first_element.find("\n")
    article_data['article_title'] = first_element[:article_title_end_idx]
    
    # article_content: 第一個\n到ˉ或\u3000為止
    content_start_idx = article_title_end_idx + 1
    content_end_idx = min(first_element.find("（ˉ）", content_start_idx), first_element.find("\u3000", content_start_idx))
    article_data['article_content'] = first_element[content_start_idx:content_end_idx]
    
    # 處理問題和選項
    def extract_question_and_choices(text, question_num):
        question_start_idx = text.find(f'{question_num}？')
        if question_start_idx == -1:
            return "", "", "", "", ""
        
        # 找到選項之間的分隔符號（ˉ或\u3000）
        choice_1_start = text.find("ˉ", question_start_idx) + 1
        choice_2_start = text.find("ˉ", choice_1_start) + 1
        choice_3_start = text.find("ˉ", choice_2_start) + 1
        choice_4_start = text.find("ˉ", choice_3_start) + 1
        choice_end = text.find("。", choice_4_start)
        
        question = text[question_start_idx+len(f'{question_num}？'):choice_1_start-1].strip()
        choice1 = text[choice_1_start:choice_2_start-1].strip()
        choice2 = text[choice_2_start:choice_3_start-1].strip()
        choice3 = text[choice_3_start:choice_4_start-1].strip()
        choice4 = text[choice_4_start:choice_end].strip()
        
        return question, choice1, choice2, choice3, choice4
    
    article_data['question_1'], article_data['question1_choice1'], article_data['question1_choice2'], \
    article_data['question1_choice3'], article_data['question1_choice4'] = extract_question_and_choices(first_element, '１')
    
    article_data['question_2'], article_data['question2_choice1'], article_data['question2_choice2'], \
    article_data['question2_choice3'], article_data['question2_choice4'] = extract_question_and_choices(first_element, '２')
    
    article_data['question_3'], article_data['question3_choice1'], article_data['question3_choice2'], \
    article_data['question3_choice3'], article_data['question3_choice4'] = extract_question_and_choices(first_element, '３')
    
    # 第2個元素處理，只取數字，並將數字放入相應的答案中
    second_element = all_text[i + 1]
    numbers = [s for s in second_element if s.isdigit()]

    if len(numbers) == 2:
        print("此題只有兩個選項")
    elif len(numbers) == 4:
        numbers = numbers[:-1]  # 捨棄最後一個數字
    print(numbers)
    article_data['question1_answer'] = numbers[0] if len(numbers) > 0 else None
    article_data['question2_answer'] = numbers[1] if len(numbers) > 1 else None
    article_data['question3_answer'] = numbers[2] if len(numbers) > 2 else None
    
    # 第3個元素是空格，跳過
    
    # 將處理完的數據加入results
    results.append(article_data)
    print(results)
    exit

# 打印結果
print(json.dumps(results, ensure_ascii=False, indent=4))
