import argparse
import sqlite3
import pandas as pd

###### とくせいの説明文リストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
abilityFlavorDBFile = 'AbilityFlavors.db'
abilityFlavorDBTable = 'abilityFlavorDB'
abilityFlavorColumnId = 'id'
abilityFlavorColumnFlavor = 'flavor'
abilityFlavorColumnEnglishFlavor = 'englishFlavor'

# CSVファイル(PokeAPI)の列名
abilityFlavorCSVAbilityIDColumn = 'ability_id'
abilityFlavorCSVVersionIDColumn = 'version_group_id'
abilityFlavorCSVLangIDColumn = 'language_id'
abilityFlavorCSVFlavorColumn = 'flavor_text'

# CSVファイル(PokeAPI+独自)の列インデックス
abilityFlavorCSVAbilityIDIndex = 1
abilityFlavorCSVVersionIDIndex = 2
abilityFlavorCSVLangIDIndex = 3
abilityFlavorCSVFlavorIndex = 4

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='とくせいの説明をCSVからデータベース化')
    parser.add_argument('ability_flavor_text', help='各アイテムの説明が記載されたCSVファイル(ability_flavor_text.csv)')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(abilityFlavorDBFile)
    con = conn.cursor()

    # 読み込み
    ability_list = []
    try:
        con.execute(f'SELECT * FROM {abilityFlavorDBTable}')
        ability_list = con.fetchall()
        print('read [ability flavors]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [ability flavors] data with PokeAPI and create table')

    if (len(ability_list) == 0):
        # とくせい説明文ファイル読み込み
        ability_flavors_df = pd.read_csv(args.ability_flavor_text)
        ability_flavors_df = ability_flavors_df.fillna(0)
        current_id = 0
        current_japanese = ''
        current_english = ''
        for row in ability_flavors_df.itertuples():
            id = row[abilityFlavorCSVAbilityIDIndex]
            if type(id) != int:
                continue
            if id > current_id and current_japanese != '' and current_english != '':
                ability_list.append((current_id, current_japanese, current_english))
                current_japanese = ''
                current_english = ''
            lang = row[abilityFlavorCSVLangIDIndex]
            current_id = id
            if lang == englishID:
                current_english = row[abilityFlavorCSVFlavorIndex]
            elif lang == japaneseID:
                current_japanese = row[abilityFlavorCSVFlavorIndex]
            else:
                continue
            #current_append = (id, row[abilityFlavorCSVFlavorIndex])
        if id > current_id and current_japanese != '' and current_english != '':
            ability_list.append((current_id, current_japanese, current_english))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {abilityFlavorDBTable} ('
            f'  {abilityFlavorColumnId} integer primary key,'
            f'  {abilityFlavorColumnFlavor} text not null,'
            f'  {abilityFlavorColumnEnglishFlavor} text not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {abilityFlavorDBTable} ({abilityFlavorColumnId}, {abilityFlavorColumnFlavor}, {abilityFlavorColumnEnglishFlavor}) VALUES ( ?, ?, ? )',
                ability_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
