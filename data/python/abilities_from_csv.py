import argparse
import sqlite3
import pandas as pd
from pathlib import Path

###### とくせいのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
abilityDBFile = 'Abilities.db'
abilityDBTable = 'abilityDB'
abilityColumnId = 'id'
abilityColumnName = 'name'
abilityColumnEnglishName = 'englishName'
abilityColumnTiming = 'timing'
abilityColumnTarget = 'target'
abilityColumnPossiblyChangeStat = 'possiblyChangeStat'

# CSVファイル(PokeAPI+独自)の列名
abilitiesLangCSVabilityIDColumn = 'ability_id'
abilitiesLangCSVLangIDColumn = 'local_language_id'
abilitiesLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI+独自)の列インデックス
abilitiesCSVabilityIDIndex = 1
abilitiesCSVtimingIDIndex = 5
abilitiesCSVtargetIDIndex = 6
abilitiesCSVeffectIDIndex = 7
abilitiesCSVchangeStatIDIndex = 8
abilitiesCSVchangeStatValIndex = 9
abilitiesCSVchangeStatIDIndex2 = 10
abilitiesCSVchangeStatValIndex2 = 11

# CSVファイル(PokeAPI+独自)で必要となる各ID
japaneseID = 1
englishID = 9

# SQLiteでintの配列をvalueにした場合の変換方法
# ※注）intの2重配列を対象にしている
IntIntList = list
sqlite3.register_adapter(IntIntList, lambda l: ';'.join([':'.join(str(int(i)) for i in ints) for ints in l]))
sqlite3.register_converter("IntIntList", lambda s: [[int(i) for i in s2.split(':')] for s2 in s.split(';')])

def set_argparse():
    parser = argparse.ArgumentParser(description='とくせいのリストをcsvファイルから取得してsqliteファイルに保存する')
    parser.add_argument('abilities', help='各とくせいの情報（ID等）が記載されたCSVファイル')
    parser.add_argument('ability_lang', help='各とくせいと各言語での名称の情報が記載されたCSVファイル')
    parser.add_argument('-o', '--output', required=False, default=abilityDBFile, help='出力先ファイル名')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    db_path = Path.cwd().joinpath(args.output)
    conn = sqlite3.connect(db_path)
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
            # 変化するステータス
            changeStat = []
            if row[abilitiesCSVchangeStatIDIndex] != -1:
                changeStat.append([row[abilitiesCSVchangeStatIDIndex], row[abilitiesCSVchangeStatValIndex]])
            if row[abilitiesCSVchangeStatIDIndex2] != -1:
                changeStat.append([row[abilitiesCSVchangeStatIDIndex2], row[abilitiesCSVchangeStatValIndex2]])
            #effect = row[abilitiesCSVeffectIDIndex]
            # 日本語名取得
            names = lang_df[(lang_df[abilitiesLangCSVabilityIDColumn] == id) & (lang_df[abilitiesLangCSVLangIDColumn] == japaneseID)][abilitiesLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[abilitiesLangCSVabilityIDColumn] == id) & (lang_df[abilitiesLangCSVLangIDColumn] == englishID)][abilitiesLangCSVNameColumn]
            if len(names) > 0:
                abilities_list.append((id, names.iloc[0], names_en.iloc[0], timing, target, changeStat))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {abilityDBTable} ('
            f'  {abilityColumnId} integer primary key,'
            f'  {abilityColumnName} text not null,'
            f'  {abilityColumnEnglishName} text not null,'
            f'  {abilityColumnTiming} integer,'
            f'  {abilityColumnTarget} integer,'
            f'  {abilityColumnPossiblyChangeStat} IntIntList)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {abilityDBTable} ({abilityColumnId}, {abilityColumnName}, {abilityColumnEnglishName}, {abilityColumnTiming}, {abilityColumnTarget}, {abilityColumnPossiblyChangeStat}) VALUES ( ?, ?, ?, ?, ?, ? )',
                abilities_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
