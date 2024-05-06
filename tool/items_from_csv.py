import argparse
import csv
import sqlite3
import pandas as pd
import os
import tqdm
import time
import datetime

###### もちもののリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
itemDBFile = 'Items.db'
itemDBTable = 'itemDB'
itemColumnId = 'id'
itemColumnName = 'name'
itemColumnEnglishName = 'englishName'
itemColumnFlingPower = 'fling_power'
itemColumnFlingEffect = 'fling_effect'
itemColumnTiming = 'timing'
itemColumnIsBerry = 'is_berry'
itemColumnImageUrl = 'image_url'
itemColumnPossiblyChangeStat = 'possiblyChangeStat'

imageUrlBase = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/'

# CSVファイル(PokeAPI)の列名
itemsCSVItemIDColumn = 'id'
itemLangCSVItemIDColumn = 'item_id'
itemLangCSVLangIDColumn = 'local_language_id'
itemLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI+独自)の列インデックス
itemCSVitemIDIndex = 1
itemCSVIdentifierIndex = 2
itemCSVFlingPowerIndex = 5
itemCSVFlingEffectIDIndex = 6
itemCSVtimingIDIndex = 7
itemCSVisBerryIndex = 8
itemCSVchangeStatIDIndex = 9
itemCSVchangeStatValIndex = 10
itemCSVchangeStatIDIndex2 = 11
itemCSVchangeStatValIndex2 = 12

# CSVファイル(PokeAPI)で必要となる各ID
validItemIDs = [i for i in range(1, 8)]       # バトルでポケモンに持たせられるアイテムの種類
japaneseID = 1
englishID = 9

# SQLiteでintの配列をvalueにした場合の変換方法
# ※注）intの2重配列を対象にしている
IntIntList = list
sqlite3.register_adapter(IntIntList, lambda l: ';'.join([':'.join(str(int(i)) for i in ints) for ints in l]))
sqlite3.register_converter("IntIntList", lambda s: [[int(i) for i in s2.split(':')] for s2 in s.split(';')])

def set_argparse():
    parser = argparse.ArgumentParser(description='もちものの情報をCSVからデータベース化')
    parser.add_argument('items', help='各アイテムの情報（IDやタイプ）が記載されたCSVファイル')
    parser.add_argument('item_lang', help='各アイテムと各言語での名称の情報が記載されたCSVファイル')
    parser.add_argument('item_flag_map', help='各アイテムとその属性が記載されたCSVファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(itemDBFile)
    con = conn.cursor()

    # 読み込み
    items_list = []
    try:
        con.execute(f'SELECT * FROM {itemDBTable}')
        items_list = con.fetchall()
        print('read [items]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [items] data with PokeAPI and create table')

    if (len(items_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.item_lang)
        # アイテム属性ファイル読み込み
        flags_df = pd.read_csv(args.item_flag_map)
        # アイテム一覧ファイル読み込み
        item_df = pd.read_csv(args.items)
        item_df = item_df.fillna(0)
        for row in item_df.itertuples():
            id = row[itemCSVitemIDIndex]
            fling_power = row[itemCSVFlingPowerIndex]
            fling_effect = row[itemCSVFlingEffectIDIndex]
            timing = row[itemCSVtimingIDIndex]
            is_berry = row[itemCSVisBerryIndex]
            # 変化するステータス
            changeStat = []
            if row[itemCSVchangeStatIDIndex] != -1:
                changeStat.append([row[itemCSVchangeStatIDIndex], row[itemCSVchangeStatValIndex]])
            if row[itemCSVchangeStatIDIndex2] != -1:
                changeStat.append([row[itemCSVchangeStatIDIndex2], row[itemCSVchangeStatValIndex2]])
            # 日本語名取得
            names = lang_df[(lang_df[itemLangCSVItemIDColumn] == id) & (lang_df[itemLangCSVLangIDColumn] == japaneseID)][itemLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[itemLangCSVItemIDColumn] == id) & (lang_df[itemLangCSVLangIDColumn] == englishID)][itemLangCSVNameColumn]
            if len(names) > 0:
                # 属性について
                #att = [a for a in flags_df[flags_df['item_id'] == id]['item_flag_id']]
                #if len(att) > 0:
                imageUrl = f'{imageUrlBase}{row[itemCSVIdentifierIndex]}.png'
                items_list.append((id, names.iloc[0], names_en.iloc[0], fling_power, fling_effect, timing, is_berry, imageUrl, changeStat))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {itemDBTable} ('
            f'  {itemColumnId} integer primary key,'
            f'  {itemColumnName} text not null,'
            f'  {itemColumnEnglishName} text not null,'
            f'  {itemColumnFlingPower} integer,'
            f'  {itemColumnFlingEffect} integer,'
            f'  {itemColumnTiming} integer,'
            f'  {itemColumnIsBerry} integer, '
            f'  {itemColumnImageUrl} text not null,'
            f'  {itemColumnPossiblyChangeStat} IntIntList)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {itemDBTable} ({itemColumnId}, {itemColumnName}, {itemColumnEnglishName}, {itemColumnFlingPower}, {itemColumnFlingEffect}, {itemColumnTiming}, {itemColumnIsBerry}, {itemColumnImageUrl}, {itemColumnPossiblyChangeStat})'
                f' VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                items_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
