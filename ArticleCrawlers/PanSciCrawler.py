import requests
from bs4 import BeautifulSoup
import re
from urllib.parse import unquote
import pandas as pd
import time

start_time = time.time()
# 第一部分：收集 unique_links
categories = ['humanbeing', 'earth', 'space', '文明足跡', 'environment', 'lifescience',
              'scicomm', 'technology', 'nature', '物理-化學', 'medicine-health', 'scienceinmovies']

base_url = 'https://pansci.asia/archives/category/type/'

pattern = re.compile(r'https://pansci.asia/archives/\d+$')

unique_links = set()

for category in categories:
    category = unquote(category)
    for page in range(1, 4):
        full_url = f"{base_url}{category}/page/{page}"
        print(f"Fetching articles for category page: {full_url}")
        response = requests.get(full_url)
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'html.parser')
        article_links = soup.find_all("a", href=True)
        for link in article_links:
            if pattern.match(link['href']) and link['href'] not in unique_links:
                unique_links.add(link['href'])

print(f"Total unique articles found: {len(unique_links)}")

mid_time = time.time()
print(f"First Part execution time: {mid_time-start_time} seconds")
# 第二部分：遍歷 unique_links 並提取標題和內文
data = []

for url in unique_links:
    response = requests.get(url)
    response.encoding = 'utf-8'
    soup = BeautifulSoup(response.text, 'html.parser')
    
    title = soup.find('title')

    paragraphs_text = []
    paragraphs = soup.find_all('p')
    for paragraph in paragraphs:
        paragraphs_text.append(paragraph.text)

    paragraphs_text = paragraphs_text[4:]

    updated_paragraphs_text = []
    for paragraph in paragraphs_text:
        if '討論功能關閉中。'in paragraph:
            break
        elif paragraph.startswith('延伸閱讀'):
            break
        elif paragraph.strip() == '0':
            break
        elif '查看原始文章'in paragraph:
            break
        else:
            updated_paragraphs_text.append(paragraph)

    content = '\n'.join(updated_paragraphs_text)
    
    data.append({
        'article_title': title.text,
        'article_link': url,
        'article_content': content
    })
    print('存入標題： '+ title.text + '\n' + '目前Excel進度：'+ str(len(data)) + '/' + str(len(unique_links)))

df = pd.DataFrame(data)

excel_path = 'PanSciArticles.xlsx'
with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
    df.to_excel(writer, index=False, sheet_name='Articles')

end_time = time.time()
total_time = end_time - start_time
print(f"Excel file has been saved to {excel_path}")
print(f"First Part execution time: {mid_time-start_time} seconds")
print(f"Total execution time: {total_time} seconds")
