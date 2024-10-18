import requests

def get_home_lineup(code):
    lineup_url = f"https://api-gw.sports.naver.com/schedule/games/{code}/preview"
    res = requests.get(lineup_url)
    arr = []
    if res.status_code == 200:
        json_data = res.json()
        lineup_datas = json_data['result']['previewData']['homeTeamLineUp']['fullLineUp']
        idx = 0
        for lineup_data in lineup_datas:
            if idx == 0:
                lineup = {
                    "positionName": lineup_data['positionName'],
                    "playerName": lineup_data['playerName'],
                    "position": lineup_data['position'],
                }
                arr.append(lineup)
            else:
                lineup = {
                    "positionName": lineup_data['positionName'],
                    "playerName": lineup_data['playerName'],
                    "batorder": lineup_data['batorder'],
                    "position": lineup_data['position'],
                }
                arr.append(lineup)
            idx += 1
    return arr

def get_away_lineup(code):
    lineup_url = f"https://api-gw.sports.naver.com/schedule/games/{code}/preview"
    res = requests.get(lineup_url)
    arr = []
    if res.status_code == 200:
        json_data = res.json()
        lineup_datas = json_data['result']['previewData']['awayTeamLineUp']['fullLineUp']
        idx = 0
        for lineup_data in lineup_datas:
            if idx == 0:
                lineup = {
                    "positionName": lineup_data['positionName'],
                    "playerName": lineup_data['playerName'],
                    "position": lineup_data['position'],
                }
                arr.append(lineup)
            else:
                lineup = {
                        "positionName": lineup_data['positionName'],
                        "playerName": lineup_data['playerName'],
                        "batorder": lineup_data['batorder'],
                        "position": lineup_data['position'],
                        }
                arr.append(lineup)
            idx += 1
    return arr

# game = '20240901HTSS02024'
#
# if __name__ == '__main__':
#     print(get_home_lineup(game))
#     print(get_away_lineup(game))





