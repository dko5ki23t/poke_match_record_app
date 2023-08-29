import argparse
import sqlite3
import pandas as pd

###### わざのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
moveDBFile = 'Moves.db'
moveDBTable = 'moveDB'
moveColumnId = 'id'
moveColumnName = 'name'
moveColumnType = 'type'
moveColumnPower = 'power'
moveColumnAccuracy = 'accuracy'
moveColumnPriority = 'priority'
moveColumnTarget = 'target'
moveColumnDamageClass = 'damage_class'
moveColumnEffect = 'effect'
moveColumnEffectChance = 'effect_chance'
moveColumnPP = 'PP'

# CSVファイル(PokeAPI)の列名
movesLangCSVmoveIDColumn = 'move_id'
movesLangCSVLangIDColumn = 'local_language_id'
movesLangCSVNameColumn = 'name'

# CSVファイル(PokeAPI)の列インデックス
movesCSVmoveIDIndex = 1
movesCSVtypeIDIndex = 4
movesCSVpowerIndex = 5
movesCSVaccuracyIndex = 7
movesCSVpriority = 8
movesCSVtargetIDIndex = 9
movesCSVdamageClassIDIndex = 10
movesCSVeffectIDIndex = 11
movesCSVeffectChanceIndex = 12
movesCSVPPIndex = 6

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
    parser.add_argument('moves', help='各わざの情報（ID等）が記載されたCSVファイル')
    parser.add_argument('move_lang', help='各わざと各言語での名称の情報が記載されたCSVファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(moveDBFile)
    con = conn.cursor()

    # 読み込み
    moves_list = []
    try:
        con.execute(f'SELECT * FROM {moveDBTable}')
        moves_list = con.fetchall()
        print('read [moves]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [moves] data with PokeAPI and create table')

    if (len(moves_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.move_lang)
        # とくせい一覧ファイル読み込み
        move_df = pd.read_csv(args.moves)
        # 欠損値は値0に置換
        move_df = move_df.fillna(0)
        for row in move_df.itertuples():
            id = row[movesCSVmoveIDIndex]
            pokeType = row[movesCSVtypeIDIndex]
            power = row[movesCSVpowerIndex]
            accuracy = row[movesCSVaccuracyIndex]
            priority = row[movesCSVpriority]
            target = row[movesCSVtargetIDIndex]
            damage_class = row[movesCSVdamageClassIDIndex]
            effect = row[movesCSVeffectIDIndex]
            effect_chance = row[movesCSVeffectChanceIndex]
            pp = row[movesCSVPPIndex]

            if pokeType > 10000:    # 特殊なタイプ
                pokeType = 0
            
            # 日本語名取得
            names = lang_df[(lang_df[movesLangCSVmoveIDColumn] == id) & (lang_df[movesLangCSVLangIDColumn] == japaneseID)][movesLangCSVNameColumn]
            if len(names) > 0:
                moves_list.append((id, names.iloc[0], pokeType, power, accuracy, priority, target, damage_class, effect, effect_chance, pp))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {moveDBTable} ('
            f'  {moveColumnId} integer primary key,'
            f'  {moveColumnName} text not null,'
            f'  {moveColumnType} integer not null,'
            f'  {moveColumnPower} integer not null,'
            f'  {moveColumnAccuracy} integer not null,'
            f'  {moveColumnPriority} integer not null,'
            f'  {moveColumnTarget} integer not null,'
            f'  {moveColumnDamageClass} integer not null,'
            f'  {moveColumnEffect} integer not null,'
            f'  {moveColumnEffectChance} integer not null,'
            f'  {moveColumnPP} integer not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {moveDBTable} ({moveColumnId}, {moveColumnName}, {moveColumnType}, {moveColumnPower}, {moveColumnAccuracy}, {moveColumnPriority}, {moveColumnTarget}, {moveColumnDamageClass}, {moveColumnEffect}, {moveColumnEffectChance}, {moveColumnPP}) '
                f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                moves_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
