import sqlite3
import requests
from tqdm import tqdm
import re

pokeApiRoute = "https://pokeapi.co/api/v2"

# APIお試し
for i in range(1, 19):
    response = requests.get(pokeApiRoute + '/type/' + str(i))
    stat = response.json()
    print(i, stat['name'])
#print(re.findall('([0-9]+)/?$', stat['species']['url']))

abilityDBFile = 'Abilities.db'
abilityDBTable = 'abilityDB'
abilityColumnId = 'id'
abilityColumnName = 'name'

temperDBFile = 'Tempers.db'
temperDBTable = 'temperDB'
temperColumnId = 'id'
temperColumnName = 'name'
temperColumnDe = 'decreased_stat'
temperColumnIn = 'increased_stat'

itemDBFile = 'Items.db'
itemDBTable = 'itemDB'
itemColumnId = 'id'
itemColumnName = 'name'

moveDBFile = 'Moves.db'
moveDBTable = 'moveDB'
moveColumnId = 'id'
moveColumnName = 'name'
moveColumnPP = 'PP'

pokeBaseDBFile = 'PokeBases.db'
pokeBaseDBTable = 'pokeBaseDB'
pokeBaseColumnId = 'id'
pokeBaseColumnName = 'name'
pokeBaseColumnAbility = 'ability'
pokeBaseColumnForm = 'form'
pokeBaseColumnMove = 'move'
pokeBaseColumnStats = [
    'h',
    'a',
    'b',
    'c',
    'd',
    's',
]
pokeBaseNameToIdx = {     # (pokeAPIでの名称/tableの列名 : idx)
    'hp': 0,
    'attack' : 1,
    'defense' : 2,
    'special-attack' : 3,
    'special-defense' : 4,
    'speed' : 5,
}
pokeBaseColumnType = 'type'

# SQLiteでintの配列をvalueにした場合の変換方法
IntList = list
sqlite3.register_adapter(IntList, lambda l: ';'.join([str(i) for i in l]))
sqlite3.register_converter("IntList", lambda s: [int(i) for i in s.split(';')])

# TODO:上手く関数化する

###### とくせい ######

conn = sqlite3.connect(abilityDBFile)
con = conn.cursor()

# 読み込み
abilities_list = []
try:
    con.execute(f'SELECT * FROM {abilityDBTable}')
    abilities_list = con.fetchall()
    print('read [abilities]:')
#    print(abilities_list)
except sqlite3.OperationalError:
    print('failed to read table')
    print('get [abilities] data with PokeAPI and create table')

if (len(abilities_list) == 0):
    # PokeAPIで取得
    response = requests.get(pokeApiRoute + '/ability')
    abilities = response.json()
    pbar = tqdm(total=abilities['count'])
    while (True):
        for e in abilities['results']:
            ability_detail = requests.get(e['url']).json()
            name = ability_detail['name']
            for f in ability_detail['names']:
                if f['language']['name'] == 'ja':
                    name = f['name']
            abilities_list.append((ability_detail['id'], name))
            pbar.update(1)
        # 次のURLを取得
        if abilities['next'] == None:   # リストを網羅したので終了
            break
        response = requests.get(abilities['next'])
        abilities = response.json()
    pbar.close()

    # 作成(存在してたら作らない)
    try:
        con.execute(
        f'CREATE TABLE IF NOT EXISTS {abilityDBTable} ('
        f'  {abilityColumnId} integer primary key,'
        f'  {abilityColumnName} text not null)'
        )
    except sqlite3.OperationalError:
        print('failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {abilityDBTable} ({abilityColumnId}, {abilityColumnName}) VALUES ( ?, ? )',
            abilities_list)
    except sqlite3.OperationalError:
        print('failed to insert table')

    conn.commit()

con.close()
conn.close()


###### せいかく ######

conn = sqlite3.connect(temperDBFile)
con = conn.cursor()

# 読み込み
tempers_list = []
try:
    con.execute(f'SELECT * FROM {temperDBTable}')
    tempers_list = con.fetchall()
    print('read [tempers]:')
#    print(tempers_list)
except sqlite3.OperationalError:
    print('failed to read table')
    print('get [tempers] data with PokeAPI and create table')

if (len(tempers_list) == 0):
    # PokeAPIで取得
    response = requests.get(pokeApiRoute + '/nature')
    tempers = response.json()
    pbar = tqdm(total=tempers['count'])
    while (True):
        for e in tempers['results']:
            nature_detail = requests.get(e['url']).json()
            name = nature_detail['name']
            for f in nature_detail['names']:
                if f['language']['name'] == 'ja':
                    name = f['name']
            dec = 'none' if (nature_detail['decreased_stat'] is None) else nature_detail['decreased_stat']['name']
            inc = 'none' if (nature_detail['increased_stat'] is None) else nature_detail['increased_stat']['name']
            tempers_list.append((
                nature_detail['id'], name, dec, inc))
            pbar.update(1)
        # 次のURLを取得
        if tempers['next'] == None:   # リストを網羅したので終了
            break
        response = requests.get(tempers['next'])
        tempers = response.json()
    pbar.close()

    # 作成(存在してたら作らない)
    try:
        con.execute(
        f'CREATE TABLE IF NOT EXISTS {temperDBTable} ('
        f'  {temperColumnId} integer primary key,'
        f'  {temperColumnName} text not null,'
        f'  {temperColumnDe} text,'
        f'  {temperColumnIn} text)'
        )
    except sqlite3.OperationalError:
        print('failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {temperDBTable} ({temperColumnId}, {temperColumnName}, {temperColumnDe}, {temperColumnIn}) VALUES ( ?, ?, ?, ? )',
            tempers_list)
    except sqlite3.OperationalError:
        print('failed to insert table')

    conn.commit()

con.close()
conn.close()


###### もちもの ######

conn = sqlite3.connect(itemDBFile)
con = conn.cursor()

# 読み込み
items_list = []
try:
    con.execute(f'SELECT * FROM {itemDBTable}')
    items_list = con.fetchall()
    print('read [items]:')
#    print(items_list)
except sqlite3.OperationalError:
    print('failed to read table')
    print('get [items] data with PokeAPI and create table')

if (len(items_list) == 0):
    # PokeAPIで取得
    response = requests.get(pokeApiRoute + '/item')
    items = response.json()
    pbar = tqdm(total=items['count'])
    while (True):
        for e in items['results']:
            item_detail = requests.get(e['url']).json()
            name = item_detail['name']
            for f in item_detail['names']:
                if f['language']['name'] == 'ja':
                    name = f['name']
            is_holdable = False
            for f in item_detail['attributes']:
                if f['name'] == 'holdable' or f['name'] == 'holdable-active':
                    is_holdable = True
                    break
            if is_holdable:     # こうしないと、もちもの多すぎ
                items_list.append((
                    item_detail['id'], name))
            pbar.update(1)
        # 次のURLを取得
        if items['next'] == None:   # リストを網羅したので終了
            break
        response = requests.get(items['next'])
        items = response.json()
    pbar.close()
    print(f'valid item num : {len(items_list)}')

    # 作成(存在してたら作らない)
    try:
        con.execute(
        f'CREATE TABLE IF NOT EXISTS {itemDBTable} ('
        f'  {itemColumnId} integer primary key,'
        f'  {itemColumnName} text not null)'
        )
    except sqlite3.OperationalError:
        print('failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {itemDBTable} ({itemColumnId}, {itemColumnName}) VALUES ( ?, ? )',
            items_list)
    except sqlite3.OperationalError:
        print('failed to insert table')

    conn.commit()

con.close()
conn.close()


###### わざ ######

conn = sqlite3.connect(moveDBFile)
con = conn.cursor()

# 読み込み
moves_list = []
try:
    con.execute(f'SELECT * FROM {moveDBTable}')
    moves_list = con.fetchall()
    print('read [moves]:')
#    print(moves_list)
except sqlite3.OperationalError:
    print('failed to read table')
    print('get [moves] data with PokeAPI and create table')

if (len(moves_list) == 0):
    # PokeAPIで取得
    response = requests.get(pokeApiRoute + '/move')
    moves = response.json()
    pbar = tqdm(total=moves['count'])
    while (True):
        for e in moves['results']:
            move_detail = requests.get(e['url']).json()
            name = move_detail['name']
            for f in move_detail['names']:
                if f['language']['name'] == 'ja':
                    name = f['name']
            pp = move_detail['pp']
            if pp is None:
                pp = 0
            moves_list.append((
                move_detail['id'], name, pp))
            pbar.update(1)
        # 次のURLを取得
        if moves['next'] == None:   # リストを網羅したので終了
            break
        response = requests.get(moves['next'])
        moves = response.json()
    pbar.close()

    # 作成(存在してたら作らない)
    try:
        con.execute(
        f'CREATE TABLE IF NOT EXISTS {moveDBTable} ('
        f'  {moveColumnId} integer primary key,'
        f'  {moveColumnName} text not null,'
        f'  {moveColumnPP} int)'
        )
    except sqlite3.OperationalError:
        print('failed to create table')

    # 挿入
    try:
        con.executemany(
            f'INSERT INTO {moveDBTable} ({moveColumnId}, {moveColumnName}, {moveColumnPP}) VALUES ( ?, ?, ? )',
            moves_list)
    except sqlite3.OperationalError:
        print('failed to insert table')

    conn.commit()

con.close()
conn.close()


###### ポケモン ######

conn = sqlite3.connect(pokeBaseDBFile)
con = conn.cursor()

# 読み込み
poke_base_list = []
try:
    con.execute(f'SELECT * FROM {pokeBaseDBTable}')
    poke_base_list = con.fetchall()
    print('read [pokemon]:')
#    print(poke_base_list)
except sqlite3.OperationalError:
    print('failed to read table')
    print('get [pokemon] data with PokeAPI and create table')

if (len(poke_base_list) == 0):
    # PokeAPIで取得
    response = requests.get(pokeApiRoute + '/pokemon')
    poke_bases = response.json()
    pbar = tqdm(total=poke_bases['count'])
    while (True):
        for e in poke_bases['results']:
            poke_base_detail = requests.get(e['url']).json()
            # SVに登場するのか調べる
            is_sv = False
#            for game in poke_base_detail['game_indices']:
#                if game['name'] == 
            # なまえ
            name = poke_base_detail['name']
            species = requests.get(poke_base_detail['species']['url']).json()
            for f in species['names']:
                if f['language']['name'] == 'ja':
                    name = f['name']
            # とくせいリスト(IDを入れる←ID取得のためにいちいちAPI叩かないことにする(TODO: OK？))
            poke_abilities = []
            for f in poke_base_detail['abilities']:
                id = re.findall('([0-9]+)/?$', f['ability']['url'])[0]   # TODO:URLの形式変わっちゃったら例外起きる
                poke_abilities.append(id)
            # すがた(IDを入れる)
            poke_forms = []
            for f in poke_base_detail['forms']:
                id = re.findall('([0-9]+)/?$', f['url'])[0]
                poke_forms.append(id)
            # おぼえるわざ(IDを入れる)
            poke_moves = []
            for f in poke_base_detail['moves']:
                id = re.findall('([0-9]+)/?$', f['move']['url'])[0]
                poke_moves.append(id)
            # 6値
            six_params = [0] * 6
            for f in poke_base_detail['stats']:
                six_params[pokeBaseNameToIdx[f['stat']['name']]] = f['base_stat']
            # タイプ(IDを入れる)
            poke_types = []
            for f in poke_base_detail['types']:
                id = re.findall('([0-9]+)/?$', f['type']['url'])[0]
                poke_types.append(id)
            poke_base_list.append((
                poke_base_detail['id'], name, poke_abilities, poke_forms, poke_moves) + tuple(six_params) + (poke_types,))
            pbar.update(1)
        # 次のURLを取得
        if poke_bases['next'] == None:   # リストを網羅したので終了
            break
        response = requests.get(poke_bases['next'])
        poke_bases = response.json()
    pbar.close()

    # 作成(存在してたら作らない)
    # TODO:もっといい方法あるかも
    statsColumn = ''
    for element in pokeBaseColumnStats:
        statsColumn += f'  {element} int,'
    try:
        con.execute(
        f'CREATE TABLE IF NOT EXISTS {pokeBaseDBTable} ('
        f'  {pokeBaseColumnId} integer primary key,'
        f'  {pokeBaseColumnName} text not null,'
        f'  {pokeBaseColumnAbility} IntList,'
        f'  {pokeBaseColumnForm} IntList,'
        f'  {pokeBaseColumnMove} IntList,' +
        statsColumn +
        f'  {pokeBaseColumnType} IntList)'
        )
    except sqlite3.OperationalError:
        print('failed to create table')

    # 挿入
    # TODO:もっといい方法あるかも
    statsColumn = ''
    for element in pokeBaseColumnStats:
        statsColumn += f'{element}, '
    statsColumn = statsColumn[:-2]
    try:
        con.executemany(
            f'INSERT INTO {pokeBaseDBTable} ('
            f'{pokeBaseColumnId}, {pokeBaseColumnName}, {pokeBaseColumnAbility}, {pokeBaseColumnForm}, {pokeBaseColumnMove}, {statsColumn}, {pokeBaseColumnType}) '
            f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
            poke_base_list)
    except sqlite3.OperationalError:
        print('failed to insert table')

    conn.commit()

con.close()
conn.close()
