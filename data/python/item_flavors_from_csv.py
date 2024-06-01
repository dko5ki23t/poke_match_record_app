import argparse
import sqlite3
import pandas as pd
from pathlib import Path

###### もちものの説明文リストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
itemFlavorDBFile = 'ItemFlavors.db'
itemFlavorDBTable = 'itemFlavorDB'
itemFlavorColumnId = 'id'
itemFlavorColumnFlavor = 'flavor'
itemFlavorColumnEnglishFlavor = 'englishFlavor'

# CSVファイル(PokeAPI)の列名
itemFlavorCSVItemIDColumn = 'item_id'
itemFlavorCSVVersionIDColumn = 'version_group_id'
itemFlavorCSVLangIDColumn = 'language_id'
itemFlavorCSVFlavorColumn = 'flavor_text'

# CSVファイル(PokeAPI+独自)の列インデックス
itemFlavorCSVItemIDIndex = 1
itemFlavorCSVVersionIDIndex = 2
itemFlavorCSVLangIDIndex = 3
itemFlavorCSVFlavorIndex = 4

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='もちものの説明文リストをcsvファイルから取得してsqliteファイルに保存する')
    parser.add_argument('item_flavor_text', help='各アイテムの説明が記載されたCSVファイル(item_flavor_text.csv)')
    parser.add_argument('-o', '--output', required=False, default=itemFlavorDBFile, help='出力先ファイル名')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    db_path = Path.cwd().joinpath(args.output)
    conn = sqlite3.connect(db_path)
    con = conn.cursor()

    # 読み込み
    flavors_list = []
    try:
        con.execute(f'SELECT * FROM {itemFlavorDBTable}')
        flavors_list = con.fetchall()
        print('read [item flavors]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [item flavors] data with PokeAPI and create table')

    if (len(flavors_list) == 0):
        # アイテム説明文ファイル読み込み
        item_flavors_df = pd.read_csv(args.item_flavor_text)
        item_flavors_df = item_flavors_df.fillna(0)
        #current_append = (0, '')
        current_id = 0
        current_japanese = ''
        current_english = ''
        for row in item_flavors_df.itertuples():
            id = row[itemFlavorCSVItemIDIndex]
            if type(id) != int:
                continue
            if id > current_id and current_japanese != '' and current_english != '':
                flavors_list.append((current_id, current_japanese, current_english))
                current_japanese = ''
                current_english = ''
            lang = row[itemFlavorCSVLangIDIndex]
            current_id = id
            if lang == englishID:
                current_english = row[itemFlavorCSVFlavorIndex]
            elif lang == japaneseID:
                current_japanese = row[itemFlavorCSVFlavorIndex]
            else:
                continue
            #current_append = (id, row[itemFlavorCSVFlavorIndex])
        if current_id > 0 and current_japanese != '' and current_english != '':
            flavors_list.append((current_id, current_japanese, current_english))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {itemFlavorDBTable} ('
            f'  {itemFlavorColumnId} integer primary key,'
            f'  {itemFlavorColumnFlavor} text not null,'
            f'  {itemFlavorColumnEnglishFlavor} text not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {itemFlavorDBTable} ({itemFlavorColumnId}, {itemFlavorColumnFlavor}, {itemFlavorColumnEnglishFlavor}) VALUES ( ?, ?, ? )',
                flavors_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
