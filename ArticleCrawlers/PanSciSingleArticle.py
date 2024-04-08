import requests
from bs4 import BeautifulSoup


url = 'https://pansci.asia/archives/368012'
response = requests.get(url)
response.encoding = 'utf-8'

soup = BeautifulSoup(response.text, 'html.parser')

title = soup.find('title')
print('標題：'+title.text+'\n\n')

paragraphs_text = []
paragraphs = soup.find_all('p')
for paragraph in paragraphs:
    paragraphs_text.append(paragraph.text)

paragraphs_text = paragraphs_text[4:]

updated_paragraphs_text = []
for paragraph in paragraphs_text:
    if '討論功能關閉中。'in paragraph:
        break
    else:
        updated_paragraphs_text.append(paragraph)

final_text = '\n'.join(updated_paragraphs_text)

print(updated_paragraphs_text)
