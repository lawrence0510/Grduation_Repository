import requests
from bs4 import BeautifulSoup
import pandas as pd

def fetch_data(url):
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15',
        'x-api-source': 'pc',
        'referer': url
    }
    response = requests.get(url, headers=headers)
    response.encoding = 'utf-8'
    return BeautifulSoup(response.text, "html.parser")

def extract_content(url):
    soup = fetch_data(url)
    content = soup.find('div', class_="Maincontent")
    return content.text if content else ''

def start_crawling():
    base_url = 'https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/%e4%ba%ba%e9%96%93%e5%82%b3%e5%a5%87/'
    soup = fetch_data(base_url)

    stories = []
    for title in soup.find_all('h3')[1:]:
        a_tag = title.select_one('a')
        if a_tag:
            title_text = a_tag.get_text()
            link = a_tag.get('href')
            content = extract_content(link)
            stories.append({'article_title': title_text, 'article_link': link, 'article_content': content})
    return stories
