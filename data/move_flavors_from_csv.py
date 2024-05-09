import argparse
import sqlite3
import pandas as pd

###### わざの説明文リストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
moveFlavorDBFile = 'MoveFlavors.db'
moveFlavorDBTable = 'moveFlavorDB'
moveFlavorColumnId = 'id'
moveFlavorColumnFlavor = 'flavor'
moveFlavorColumnEnglishFlavor = 'englishFlavor'

# CSVファイル(PokeAPI)の列名
moveFlavorCSVMoveIDColumn = 'move_id'
moveFlavorCSVVersionIDColumn = 'version_group_id'
moveFlavorCSVLangIDColumn = 'language_id'
moveFlavorCSVFlavorColumn = 'flavor_text'

# CSVファイル(PokeAPI+独自)の列インデックス
moveFlavorCSVMoveIDIndex = 1
moveFlavorCSVVersionIDIndex = 2
moveFlavorCSVLangIDIndex = 3
moveFlavorCSVFlavorIndex = 4

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='わざの説明文をCSVからデータベース化')
    parser.add_argument('move_flavor_text', help='各アイテムの説明が記載されたCSVファイル(move_flavor_text.csv)')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(moveFlavorDBFile)
    con = conn.cursor()

    # 読み込み
    move_list = []
    try:
        con.execute(f'SELECT * FROM {moveFlavorDBTable}')
        move_list = con.fetchall()
        print('read [move flavors]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [move flavors] data with PokeAPI and create table')

    if (len(move_list) == 0):
        # とくせい説明文ファイル読み込み
        move_flavors_df = pd.read_csv(args.move_flavor_text)
        move_flavors_df = move_flavors_df.fillna(0)
        current_id = 0
        current_japanese = ''
        current_english = ''
        for row in move_flavors_df.itertuples():
            id = row[moveFlavorCSVMoveIDIndex]
            if type(id) != int:
                continue
            if id > current_id and current_japanese != '' and current_english != '':
                move_list.append((current_id, current_japanese, current_english))
                current_japanese = ''
                current_english = ''
            lang = row[moveFlavorCSVLangIDIndex]
            current_id = id
            if lang == englishID:
                current_english = row[moveFlavorCSVFlavorIndex]
            if lang == japaneseID:
                current_japanese = row[moveFlavorCSVFlavorIndex]
            else:
                continue
            #current_append = (id, row[moveFlavorCSVFlavorIndex])
        if id > current_id and current_japanese != '' and current_english != '':
            move_list.append((current_id, current_japanese, current_english))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {moveFlavorDBTable} ('
            f'  {moveFlavorColumnId} integer primary key,'
            f'  {moveFlavorColumnFlavor} text not null, '
            f'  {moveFlavorColumnEnglishFlavor} text not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {moveFlavorDBTable} ({moveFlavorColumnId}, {moveFlavorColumnFlavor}, {moveFlavorColumnEnglishFlavor}) VALUES ( ?, ?, ? )',
                move_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
