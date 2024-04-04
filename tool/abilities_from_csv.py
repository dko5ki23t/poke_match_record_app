import argparse
import sqlite3
import pandas as pd

###### とくせいのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
abilityDBFile = 'Abilities.db'
abilityDBTable = 'abilityDB'
abilityColumnId = 'id'
abilityColumnName = 'name'
abilityColumnEnglishName = 'englishName'
abilityColumnTiming = 'timing'
abilityColumnTarget = 'target'

# CSVファイル(PokeAPI+独自)の列名
abilitiesLangCSVabilityIDColumn = 'ability_id'
abilitiesLangCSVLangIDColumn = 'local_language_id'
abilitiesLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI+独自)の列インデックス
abilitiesCSVabilityIDIndex = 1
abilitiesCSVtimingIDIndex = 5
abilitiesCSVtargetIDIndex = 6
abilitiesCSVeffectIDIndex = 7

# CSVファイル(PokeAPI+独自)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='とくせいの情報をCSVからデータベース化')
    parser.add_argument('abilities', help='各とくせいの情報（ID等）が記載されたCSVファイル')
    parser.add_argument('ability_lang', help='各とくせいと各言語での名称の情報が記載されたCSVファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(abilityDBFile)
    con = conn.cursor()

    # 読み込み
    abilities_list = []
    try:
        con.execute(f'SELECT * FROM {abilityDBTable}')
        abilities_list = con.fetchall()
        print('read [abilities]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [abilities] data with PokeAPI and create table')

    if (len(abilities_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.ability_lang)
        # とくせい一覧ファイル読み込み
        ability_df = pd.read_csv(args.abilities)
        for row in ability_df.itertuples():
            id = row[abilitiesCSVabilityIDIndex]
            timing = row[abilitiesCSVtimingIDIndex]
            target = row[abilitiesCSVtargetIDIndex]
            #effect = row[abilitiesCSVeffectIDIndex]
            # 日本語名取得
            names = lang_df[(lang_df[abilitiesLangCSVabilityIDColumn] == id) & (lang_df[abilitiesLangCSVLangIDColumn] == japaneseID)][abilitiesLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[abilitiesLangCSVabilityIDColumn] == id) & (lang_df[abilitiesLangCSVLangIDColumn] == englishID)][abilitiesLangCSVNameColumn]
            if len(names) > 0:
                abilities_list.append((id, names.iloc[0], names_en.iloc[0], timing, target))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {abilityDBTable} ('
            f'  {abilityColumnId} integer primary key,'
            f'  {abilityColumnName} text not null,'
            f'  {abilityColumnEnglishName} text not null,'
            f'  {abilityColumnTiming} integer,'
            f'  {abilityColumnTarget} integer)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {abilityDBTable} ({abilityColumnId}, {abilityColumnName}, {abilityColumnEnglishName}, {abilityColumnTiming}, {abilityColumnTarget}) VALUES ( ?, ?, ?, ?, ? )',
                abilities_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
