from bs4 import BeautifulSoup
import urllib.request
import re 
soup = BeautifulSoup(open("comment_element.html"))
d = {}
for tag in soup.find_all(["button","emoji-mart-emoji"]):
    s = tag.find("span")["style"]
    pattern = re.compile(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')
    k = tag['aria-label']
    url = re.findall(pattern,s)[0]
    print(k)
    print(url.split("/")[-1])
    # urllib.request.urlretrieve(url, "./emojis/" + url.split("/")[-1]) //下载逻辑
    d[k] = url.split("/")[-1]
print(d)