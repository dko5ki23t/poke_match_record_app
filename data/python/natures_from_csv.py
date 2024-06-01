import argparse
import sqlite3
import pandas as pd
from pathlib import Path

###### せいかくのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
natureDBFile = 'Natures.db'
natureDBTable = 'natureDB'
natureColumnId = 'id'
natureColumnName = 'name'
natureColumnEnglishName = 'englishName'
natureColumnDe = 'decreased_stat'
natureColumnIn = 'increased_stat'

# CSVファイル(PokeAPI)の列名
naturesCSVNatureIDColumn = 'id'
natureLangCSVNatureIDColumn = 'nature_id'
natureLangCSVLangIDColumn = 'local_language_id'
natureLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI+独自)の列インデックス
natureCSVnatureIDIndex = 1
natureCSVdecreaseStatIDIndex = 3
natureCSVincreaseStatIDIndex = 4

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='せいかくのリストをcsvファイルから取得してsqliteファイルに保存する')
    parser.add_argument('natures', help='各せいかくの情報（IDやタイプ）が記載されたCSVファイル')
    parser.add_argument('nature_lang', help='各せいかくと各言語での名称の情報が記載されたCSVファイル')
    parser.add_argument('-o', '--output', required=False, default=natureDBFile, help='出力先ファイル名')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    db_path = Path.cwd().joinpath(args.output)
    conn = sqlite3.connect(db_path)
    con = conn.cursor()

    # 読み込み
    natures_list = []
    try:
        con.execute(f'SELECT * FROM {natureDBTable}')
        natures_list = con.fetchall()
        print('read [natures]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [natures] data with PokeAPI and create table')

    if (len(natures_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.nature_lang)
        # とくせい一覧ファイル読み込み
        nature_df = pd.read_csv(args.natures)
        nature_df = nature_df.fillna(0)
        for row in nature_df.itertuples():
            id = row[natureCSVnatureIDIndex]
            dec = row[natureCSVdecreaseStatIDIndex]
            inc = row[natureCSVincreaseStatIDIndex]
            # 日本語名取得
            names = lang_df[(lang_df[natureLangCSVNatureIDColumn] == id) & (lang_df[natureLangCSVLangIDColumn] == japaneseID)][natureLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[natureLangCSVNatureIDColumn] == id) & (lang_df[natureLangCSVLangIDColumn] == englishID)][natureLangCSVNameColumn]
            if len(names) > 0:
                natures_list.append((id, names.iloc[0], names_en.iloc[0], dec, inc))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {natureDBTable} ('
            f'  {natureColumnId} integer primary key,'
            f'  {natureColumnName} text not null,'
            f'  {natureColumnEnglishName} text not null,'
            f'  {natureColumnDe} integer,'
            f'  {natureColumnIn} integer)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {natureDBTable} ({natureColumnId}, {natureColumnName}, {natureColumnEnglishName}, {natureColumnDe}, {natureColumnIn})'
                f' VALUES ( ?, ?, ?, ?, ? )',
                natures_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
