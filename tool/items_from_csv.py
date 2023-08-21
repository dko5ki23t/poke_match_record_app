import argparse
import csv
import sqlite3
import pandas as pd
import os
import tqdm
import time
from plyer import notification
import datetime

###### もちもののリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
itemDBFile = 'Items.db'
itemDBTable = 'itemDB'
itemColumnId = 'id'
itemColumnName = 'name'

# CSVファイル(PokeAPI)の列名
itemsCSVItemIDColumn = 'id'
itemLangCSVItemIDColumn = 'item_id'
itemLangCSVLangIDColumn = 'local_language_id'
itemLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI)で必要となる各ID
validItemIDs = [i for i in range(1, 8)]       # バトルでポケモンに持たせられるアイテムの種類
japaneseID = 1

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
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
        for id in item_df[itemsCSVItemIDColumn]:
            # 日本語名取得
            names = lang_df[(lang_df[itemLangCSVItemIDColumn] == id) & (lang_df[itemLangCSVLangIDColumn] == japaneseID)][itemLangCSVNameColumn]
            if len(names) > 0:
                # 属性について
                #att = [a for a in flags_df[flags_df['item_id'] == id]['item_flag_id']]
                #if len(att) > 0:
                    items_list.append((id, names.iloc[0]))

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


if __name__ == "__main__":
    main()
