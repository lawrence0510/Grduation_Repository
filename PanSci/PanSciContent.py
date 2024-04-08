import requests
from bs4 import BeautifulSoup
import re
from urllib.parse import unquote

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
