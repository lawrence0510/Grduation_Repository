import requests
from bs4 import BeautifulSoup
import re
from urllib.parse import unquote
import pandas as pd
from openpyxl.utils.exceptions import IllegalCharacterError
from tqdm import tqdm

def start_crawling():

    # 第一部分：收集 unique_links
    categories = ['humanbeing', 'earth', 'space', '文明足跡', 'environment', 'lifescience',
                'scicomm', 'technology', 'nature', '物理-化學', 'medicine-health', 'scienceinmovies']

    base_url = 'https://pansci.asia/archives/category/type/'

    pattern = re.compile(r'https://pansci.asia/archives/\d+$')

    unique_links = []

    for category in tqdm(categories, desc='Collecting categories'):
        category = unquote(category)
        for page in range(1, 51):
            full_url = f"{base_url}{category}/page/{page}"
            print(f"Fetching articles for category page: {full_url}")
            response = requests.get(full_url)
            response.encoding = 'utf-8'
            soup = BeautifulSoup(response.text, 'html.parser')
            article_links = soup.find_all("a", href=True)
            for link in article_links:
                if pattern.match(link['href']):
                    link_info = {'url': link['href'], 'category': category}
                    if link_info not in unique_links:
                        unique_links.append(link_info)

    print(f"Total unique articles found: {len(unique_links)}")

    # 第二部分：遍歷 unique_links 並提取標題和內文
    data = []

    for link_info in tqdm(unique_links, desc='Processing links'):
        url = link_info['url']
        category = link_info['category']
        response = requests.get(url)
        response.encoding = 'utf-8'
        soup = BeautifulSoup(response.text, 'html.parser')
        
        title_element = soup.find('title')
        
        if title_element is None or not title_element.text.strip():
            print(f"跳過標題為空的文章: {url}")
            continue
        
        title = title_element.text
            
        paragraphs = soup.find_all('p')[4:]
        updated_paragraphs_text = []

        for paragraph in paragraphs:
            text = paragraph.text
            if '討論功能關閉中。' in text or text.startswith('延伸閱讀') or text.strip() == '0' or '查看原始文章' in text:
                break
            updated_paragraphs_text.append(text)

        content = '\n'.join(updated_paragraphs_text)
        
        data.append({
            'article_title': title,
            'article_link': url,
            'article_content': content,
            'article_category': category,
        })
        print('存入標題：' + title + '\n' + '目前進度：' + str(len(data)) + '/' + str(len(unique_links)))
    return data