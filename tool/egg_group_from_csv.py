import argparse
import sqlite3
import pandas as pd

###### タマゴグループのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
eggGroupDBFile = 'EggGroup.db'
eggGroupDBTable = 'eggGroupDB'
eggGroupColumnId = 'id'
eggGroupColumnName = 'name'

# CSVファイル(PokeAPI)の列名
eggGroupsCSVItemIDColumn = 'egg_group_id'
eggGroupsCSVLangIDColumn = 'local_language_id'
eggGroupsCSVNameColumn = 'name'

# CSVファイル(PokeAPI)の列インデックス
eggGroupCSVeggGroupIndex = 1
eggGroupCSVlangIndex = 2
eggGroupCSVnameIndex = 3

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1

def set_argparse():
    parser = argparse.ArgumentParser(description='タマゴグループの情報をCSVからデータベース化')
    parser.add_argument('egg_group', help='各タマゴグループの情報が記載されたCSVファイル(egg_group_prose.csv)')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(eggGroupDBFile)
    con = conn.cursor()

    # 読み込み
    egg_group_list = []
    try:
        con.execute(f'SELECT * FROM {eggGroupDBTable}')
        egg_group_list = con.fetchall()
        print('read [egg group]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [egg group] data with PokeAPI and create table')

    if (len(egg_group_list) == 0):
        # タマゴグループ一覧ファイル読み込み
        egg_group_df = pd.read_csv(args.egg_group)
        for row in egg_group_df.itertuples():
            id = row[eggGroupCSVeggGroupIndex]
            lang = row[eggGroupCSVlangIndex]
            if lang == japaneseID:
                # 日本語名取得
                name = row[eggGroupCSVnameIndex]
                egg_group_list.append((id, name))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {eggGroupDBTable} ('
            f'  {eggGroupColumnId} integer primary key,'
            f'  {eggGroupColumnName} text not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {eggGroupDBTable} ({eggGroupColumnId}, {eggGroupColumnName}) VALUES ( ?, ? )',
                egg_group_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
