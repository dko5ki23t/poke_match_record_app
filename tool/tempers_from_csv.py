import argparse
import sqlite3
import pandas as pd

###### せいかくのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
temperDBFile = 'Tempers.db'
temperDBTable = 'temperDB'
temperColumnId = 'id'
temperColumnName = 'name'
temperColumnEnglishName = 'englishName'
temperColumnDe = 'decreased_stat'
temperColumnIn = 'increased_stat'

# CSVファイル(PokeAPI)の列名
tempersCSVTemperIDColumn = 'id'
temperLangCSVTemperIDColumn = 'nature_id'
temperLangCSVLangIDColumn = 'local_language_id'
temperLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI+独自)の列インデックス
temperCSVtemperIDIndex = 1
temperCSVdecreaseStatIDIndex = 3
temperCSVincreaseStatIDIndex = 4

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='せいかくの情報をCSVからデータベース化')
    parser.add_argument('tempers', help='各せいかくの情報（IDやタイプ）が記載されたCSVファイル')
    parser.add_argument('temper_lang', help='各せいかくと各言語での名称の情報が記載されたCSVファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(temperDBFile)
    con = conn.cursor()

    # 読み込み
    tempers_list = []
    try:
        con.execute(f'SELECT * FROM {temperDBTable}')
        tempers_list = con.fetchall()
        print('read [tempers]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [tempers] data with PokeAPI and create table')

    if (len(tempers_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.temper_lang)
        # とくせい一覧ファイル読み込み
        temper_df = pd.read_csv(args.tempers)
        temper_df = temper_df.fillna(0)
        for row in temper_df.itertuples():
            id = row[temperCSVtemperIDIndex]
            dec = row[temperCSVdecreaseStatIDIndex]
            inc = row[temperCSVincreaseStatIDIndex]
            # 日本語名取得
            names = lang_df[(lang_df[temperLangCSVTemperIDColumn] == id) & (lang_df[temperLangCSVLangIDColumn] == japaneseID)][temperLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[temperLangCSVTemperIDColumn] == id) & (lang_df[temperLangCSVLangIDColumn] == englishID)][temperLangCSVNameColumn]
            if len(names) > 0:
                tempers_list.append((id, names.iloc[0], names_en.iloc[0], dec, inc))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {temperDBTable} ('
            f'  {temperColumnId} integer primary key,'
            f'  {temperColumnName} text not null,'
            f'  {temperColumnEnglishName} text not null,'
            f'  {temperColumnDe} integer,'
            f'  {temperColumnIn} integer)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {temperDBTable} ({temperColumnId}, {temperColumnName}, {temperColumnEnglishName}, {temperColumnDe}, {temperColumnIn})'
                f' VALUES ( ?, ?, ?, ?, ? )',
                tempers_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
