import requests
from bs4 import BeautifulSoup
import mysql.connector
from mysql.connector import Error
import os
from datetime import datetime, timedelta
import time
from dotenv import load_dotenv

load_dotenv()

# 創建資料庫連接
def create_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv('DATABASE_HOST'),
            user=os.getenv('DATABASE_USER'),
            password=os.getenv('DATABASE_PASSWORD'),
            database=os.getenv('DATABASE_NAME')
        )
        return connection
    except Error as e:
        print(f"Error: '{e}'")
        return None

# 檢查文章是否已經存在
def check_article_exists(cursor, article_link):
    check_query = "SELECT COUNT(*) FROM Article WHERE article_link = %s"
    cursor.execute(check_query, (article_link,))
    result = cursor.fetchone()
    return result[0] > 0

# 爬取新聞內容
def start_crawling():
    # 類別列表
    categories = ['world', 'local']
    data = []

    # 迴圈遍歷每個類別
    for category in categories:
        url = f'https://news.ltn.com.tw/list/breakingnews/{category}'
        headers = {
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15',
            'referer': f'https://news.ltn.com.tw/list/breakingnews/{category}'
        }

        # 發送 GET 請求到每個類別的主頁
        response = requests.get(url, headers=headers)
        response.encoding = 'utf-8'

        # 確認請求成功
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')

            # 找到所有新聞的 URL（根據你的 HTML 結構）
            swiper_slides = soup.find_all('a', class_='ph listS_h')
            
            # 檢查是否有找到新聞連結
            if swiper_slides:
                # 遍歷每個新聞連結
                for slide in swiper_slides:
                    news_url = slide['href']
                    title = slide.get('title', 'No title available')

                    # 發送 GET 請求進入每個新聞頁面
                    news_response = requests.get(news_url, headers=headers)
                    if news_response.status_code == 200:
                        news_soup = BeautifulSoup(news_response.text, 'html.parser')
                        
                        # 爬取指定的 <p> 標籤內容
                        article_content = ""
                        paragraphs = news_soup.find_all('p')  # 找到頁面中的所有 <p> 標籤
                        
                        if paragraphs:
                            # 提取所有 <p> 標籤中的文本
                            full_text = '\n'.join([p.get_text() for p in paragraphs])
                            
                            # 找到起始點 "為達最佳瀏覽效果" 並開始截取
                            start_keyword = "為達最佳瀏覽效果，建議使用 Chrome、Firefox 或 Microsoft Edge 的瀏覽器。"
                            end_keyword = "不用抽 不用搶 現在用APP看新聞 保證天天中獎"

                            start_index = full_text.find(start_keyword)
                            end_index = full_text.find(end_keyword)

                            if start_index != -1 and end_index != -1:
                                # 提取從 start_keyword 後到 end_keyword 之前的內容
                                article_content = full_text[start_index + len(start_keyword):end_index].strip()
                            else:
                                article_content = 'No relevant content found'
                        else:
                            article_content = 'No content found'
                        
                        # 檢查文章是否以「爆」開頭，如果是，則刪除第一個字
                        if article_content.startswith("爆"):
                            article_content = article_content[1:].strip()

                        # 將結果添加到 data 中
                        data.append({
                            'Title': title,
                            'URL': news_url,
                            'Content': article_content,
                            'Category': category
                        })
                    else:
                        print(f"Failed to retrieve content from {news_url}")
            else:
                print(f"No news articles found for category: {category}")
        else:
            print(f"Failed to retrieve the webpage for category: {category}. Status code:", response.status_code)
    
    return data

# 將爬取到的資料插入資料庫
def insert_data_to_db(data):
    connection = create_db_connection()
    if connection is None:
        print("資料庫連接失敗")
        return

    try:
        cursor = connection.cursor()

        # 找到最大 article_id
        cursor.execute("SELECT MAX(article_id) FROM Article")
        result = cursor.fetchone()
        max_article_id = result[0] if result[0] else 0

        for row in data:
            article_title = row['Title']
            article_link = row['URL']
            article_category = 'news'
            article_content = row['Content']
            article_expired_day = (datetime.now() + timedelta(days=60)).strftime('%Y-%m-%d')

            # 檢查是否已經存在該 URL
            if check_article_exists(cursor, article_link):
                print(f"文章已存在，跳過：{article_link}")
                continue  # 如果文章已存在，跳過此文章

            new_article_id = max_article_id + 1

            insert_query = """
            INSERT INTO `Article` (
                `article_id`, `article_title`, `article_link`,
                `article_category`, `article_content`,
                `article_expired_day`
            ) VALUES (%s, %s, %s, %s, %s, %s)
            """

            cursor.execute(insert_query, (
                new_article_id, article_title, article_link, article_category,
                article_content, article_expired_day
            ))

            connection.commit()
            max_article_id = new_article_id
            print(f"已成功插入文章：{article_title}")
    
    except Error as e:
        print(f"插入資料庫時發生錯誤: {e}")
    
    finally:
        cursor.close()
        connection.close()

# 主程式運行 - 每小時執行一次
if __name__ == "__main__":
    while True:
        print("開始爬取新聞...")
        articles_data = start_crawling()
        insert_data_to_db(articles_data)
        print("等待1小時後再次執行...")
        time.sleep(3600)  # 每1小時執行一次
