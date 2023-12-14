import argparse
import sqlite3
import pandas as pd
from plyer import notification

###### とくせいの説明文リストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
abilityFlavorDBFile = 'AbilityFlavors.db'
abilityFlavorDBTable = 'abilityFlavorDB'
abilityFlavorColumnId = 'id'
abilityFlavorColumnFlavor = 'flavor'

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
        current_append = (0, '')
        current_id = 0
        for row in ability_flavors_df.itertuples():
            id = row[abilityFlavorCSVAbilityIDIndex]
            if type(id) != int:
                continue
            if id > current_id and current_append[0] > 0:
                ability_list.append(current_append)
                current_append = (0, '')
            lang = row[abilityFlavorCSVLangIDIndex]
            current_id = id
            if lang != japaneseID:
                continue
            current_append = (id, row[abilityFlavorCSVFlavorIndex])
        if current_append[0] > 0:
            ability_list.append(current_append)

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {abilityFlavorDBTable} ('
            f'  {abilityFlavorColumnId} integer primary key,'
            f'  {abilityFlavorColumnFlavor} text not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {abilityFlavorDBTable} ({abilityFlavorColumnId}, {abilityFlavorColumnFlavor}) VALUES ( ?, ? )',
                ability_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
