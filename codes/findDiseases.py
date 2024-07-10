# -*- coding: utf-8 -*-
"""
试图从https://www.disgenet.org/search自动化查询基因-疾病关联，
但由于需要顺序点击多个按钮并输入数据，导致无法实现
"""
import requests
from bs4 import BeautifulSoup
import traceback
import os
import urllib

# 定位input标签，拼接URL
def build_form(gene):
    header = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko'}
    res = requests.get('http://search.dangdang.com/advsearch', headers=header)
    res.encoding = 'GB2312'
    soup = BeautifulSoup(res.text, 'html.parser')
    # 定位input标签
    input_tag_name = ''
    conditions = soup.select('.box2 > .detail_condition > label')
    print('共找到%d项基本条件,正在寻找input标签' % len(conditions))
    for item in conditions:
        text = item.select('span')[0].string
        if text == '出版社':
            input_tag_name = item.select('input')[0].get('name')
            print('已经找到input标签，name:', input_tag_name)
    # 拼接url
    keyword = {'medium': '01',
               input_tag_name: gene.encode(''),
               'category_path': '01.00.00.00.00.00',
               'sort_type': 'sort_pubdate_desc'
               }
    url = 'http://search.dangdang.com/?'
    url += urllib.parse.urlencode(keyword)
    print('入口地址:%s' % url)
    return url

# 抓取信息
def get_info(entry_url):
    header = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko'}
    res = requests.get(entry_url, headers=header)
    res.encoding = 'GB2312'
    # 这里用lxml解析会出现内容缺失
    soup = BeautifulSoup(res.text, 'html.parser')
    # 获取页数
    page_num = int(soup.select('.data > span')[1].text.strip('/'))
    print('共 %d 页待抓取， 这里只测试采集1页' % page_num)
    page_num = 1    #这里只测试抓1页
    
    page_now = '&page_index='
    # 书名 价格 出版时间 评论数量 
    books_title = []
    books_price = []
    books_date = []
    books_comment = []
    for i in range(1, page_num+1):
        now_url = entry_url + page_now + str(i)
        print('正在获取第%d页,URL:%s' % (i, now_url))
        res = requests.get(now_url, headers=header)
        soup = BeautifulSoup(res.text, 'html.parser')
        # 获取书名
        tmp_books_title = soup.select('ul.bigimg > li[ddt-pit] > a')
        for book in tmp_books_title:
            books_title.append(book.get('title'))
        # 获取价格
        tmp_books_price = soup.select('ul.bigimg > li[ddt-pit] > p.price > span.search_now_price')
        for book in tmp_books_price:
            books_price.append(book.text)
        # 获取评论数量
        tmp_books_comment = soup.select('ul.bigimg > li[ddt-pit] > p.search_star_line > a')
        for book in tmp_books_comment:
            books_comment.append(book.text)
        # 获取出版日期
        tmp_books_date = soup.select('ul.bigimg > li[ddt-pit] > p.search_book_author > span')
        for book in tmp_books_date[1::3]:
            books_date.append(book.text[2:])
    books_dict = {'title': books_title, 'price': books_price, 'date': books_date, 'comment': books_comment}
    return books_dict

# 保存数据
def save_info(file_dir, press_name, books_dict):
    res = ''
    try:
        for i in range(len(books_dict['title'])):
            res += (str(i+1) + '.' + '书名:' + books_dict['title'][i] + '\r\n' +
                    '价格:' + books_dict['price'][i] + '\r\n' +
                    '出版日期:' + books_dict['date'][i] + '\r\n' +
                    '评论数量:' + books_dict['comment'][i] + '\r\n' +
                    '\r\n'
                    )
    except Exception as e:
        print('保存出错')
        print(e)
        traceback.print_exc()
    finally:
        file_path = file_dir + os.sep + press_name + '.txt'
        f = open(file_path, "wb")
        f.write(res.encode("utf-8"))
        f.close()
        return

# 入口
def start_spider(dicGenes, saved_file_dir):
    for key in dicGenes:
        print('------ 开始抓取 %s 对应基因的疾病关联 ------' % key)
        press_page_url = build_form(press_name)
        books_dict = get_info(press_page_url)
        save_info(saved_file_dir, press_name, books_dict)
        print('------- 出版社: %s 抓取完毕 -------' % press_name)
    return

# 读取待查基因到字典
# key-value:rsID-基因列表
def readGenes(fn):
    genes = {}
    with open(fn,'r') as f:
        hd = False    #表头部分
        for ln in f.readlines():
            ln = ln.strip('\n') # 删除回车
            if ln == 'rsID,Genes': # 找到表头
                hd = True
                continue
            else:
                if hd:
                    lst = ln.split(',')
                    key = lst[0]
                    del lst[0]
                    genes[key] = lst

    return genes
                        

if __name__ == '__main__':
    geneFn = 'genes.csv' # 基因文件名。key-value:rsID-基因列表
    resFn = 'disease.csv' # 查询结果文件名
    dirRes = os.path.join(os.getcwd(),'BDres')   # 结果目录
    genes = readGenes(os.path.join(dirRes,geneFn))
    
    # 启动
    start_spider(genes, os.path.join(dirRes,resFn))
