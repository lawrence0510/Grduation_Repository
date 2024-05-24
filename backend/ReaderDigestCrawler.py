import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

def start_crawling():
    urls = [
        "https://cn.readersdigest.asia/category/%e5%81%a5%e5%ba%b7/",
        "https://cn.readersdigest.asia/category/%e5%81%a5%e5%ba%b7/?pno=2",
        "https://cn.readersdigest.asia/category/%e5%81%a5%e5%ba%b7/?pno=3",
        "https://cn.readersdigest.asia/category/%e5%81%a5%e5%ba%b7/?pno=4",
        "https://cn.readersdigest.asia/category/%e5%81%a5%e5%ba%b7/?pno=5",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=2",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=3",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=4",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=5",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=6",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=7",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=8",
        "https://cn.readersdigest.asia/category/%e7%94%9f%e6%b4%bb/?pno=9",
        "https://cn.readersdigest.asia/category/%e5%8b%95%e7%89%a9%e8%88%87%e4%ba%ba/%e5%8b%95%e7%89%a9%e5%a4%a7%e8%a7%80/",
        "https://cn.readersdigest.asia/category/%e5%8b%95%e7%89%a9%e8%88%87%e4%ba%ba/%e5%af%b5%e7%89%a9/",
        "https://cn.readersdigest.asia/category/%e5%8b%95%e7%89%a9%e8%88%87%e4%ba%ba/%e5%af%b5%e7%89%a9/?pno=2",
        "https://cn.readersdigest.asia/category/%e6%97%85%e9%81%8a/?pno=1",
        "https://cn.readersdigest.asia/category/%e6%97%85%e9%81%8a/?pno=2",
        "https://cn.readersdigest.asia/category/%e6%97%85%e9%81%8a/?pno=3",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/?pno=1",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/?pno=2",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/?pno=3",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/?pno=4",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/%e6%88%91%e7%9a%84%e6%95%85%e4%ba%8b/?pno=1",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/%e6%88%91%e7%9a%84%e6%95%85%e4%ba%8b/?pno=2",
        "https://cn.readersdigest.asia/category/%e5%8b%b5%e5%bf%97%e6%95%85%e4%ba%8b/%e6%88%91%e7%9a%84%e6%95%85%e4%ba%8b/?pno=3"
    ]

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    }

    articles_list = []

    for url in tqdm(urls):
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.content, 'html.parser')

        articles = soup.find_all('h3')

        for article in articles:
            span_tag = article.find('span', class_='field-content')
            if span_tag:
                a_tag = span_tag.find('a')
                if a_tag:
                    title = a_tag.get_text(strip=True)
                    link = a_tag['href']
                    
                    article_response = requests.get(link, headers=headers, allow_redirects=False)
                    
                    if article_response.status_code == 302:
                        redirect_url = article_response.headers['Location']
                        article_response = requests.get(redirect_url, headers=headers)
                    
                    article_soup = BeautifulSoup(article_response.content, 'html.parser')
                    
                    content_div = article_soup.find('div', class_='Maincontent')
                    if content_div:
                        content = content_div.get_text(strip=True)
                        articles_list.append({
                            'article_title': title,
                            'article_link': link,
                            'article_content': content
                        })
                        print('存入標題：' + title + '\n')
    
    return articles_list