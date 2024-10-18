from selenium import webdriver
from selenium.webdriver.common.by import By
import time
from bs4 import BeautifulSoup
from selenium.webdriver.support.ui import Select

import cx_Oracle

conn = cx_Oracle.connect("sohee", "sohee", "localhost:1521/xe")

url = "https://www.koreabaseball.com/Schedule/Schedule.aspx"

driver = webdriver.Chrome()
driver.implicitly_wait(3)

driver.get(url)
time.sleep(1)

# 정규시즌 선택
select_year = driver.find_element(By.ID, 'ddlSeries')
select = Select(select_year)
select.select_by_value('0,9,6')
time.sleep(1)

# 년 선택
select_year = driver.find_element(By.ID, 'ddlYear')
select = Select(select_year) # Select 클래스를 사용해서 조작
select.select_by_value('2023')

# 월 선택
select_month = driver.find_element(By.ID, 'ddlMonth')
select = Select(select_month)
select.select_by_value('10')
time.sleep(1)

# 팀 선택
# driver.find_element(By.CSS_SELECTOR, '.tab-schedule li:nth-child(7)').click()
# time.sleep(1)

# 해당월 경기 리스트 수집...
game = driver.find_element(By.ID, 'tblScheduleList')
game_table = game.find_element(By.TAG_NAME, 'tbody')
game_lists = game_table.find_elements(By.TAG_NAME, 'tr')
game = list()

cur = conn.cursor()
sql1 = """
        INSERT INTO tb_kbo(game_day, home_team, home_team_score
                        ,away_team, away_team_score, game_space, game_note)
        VALUES(TO_DATE(:1, 'YYYY.MM.DD HH24:MI'), :2, :3, :4, :5, :6, :7)
"""

soup = BeautifulSoup(driver.page_source, 'html.parser')
trs = soup.select('#tblScheduleList tbody tr')

game_day1 = '2024.01.01'
for tr in trs:
    home_team = '-'
    home_team_score = '-'
    away_team = '-'
    away_team_score = '-'
    tds = tr.find_all('td')
    for td in tds:
        cls = td.get('class')
        if cls == ['day']:
            game_day1 = '2024.' + td.text[:5] + ' '
        if cls == ['time']:
            game_day = game_day1 + td.text
        if cls == ['play']:
            spans = td.find_all('span')
            if len(spans) == 5:
                home_team = spans[0].text
                home_team_score = spans[1].text
                away_team = spans[4].text
                away_team_score = spans[3].text
            if len(spans) == 3:
                home_team = spans[0].text
                away_team = spans[2].text
    game_place = tds[-2].text
    game_note = tds[-1].text

    cur.execute(sql1
                , [game_day, home_team, home_team_score
                , away_team, away_team_score, game_place, game_note])

time.sleep(1)

conn.commit()
conn.close()

driver.quit()
# print(soup.prettify())
