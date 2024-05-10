import argparse
import sqlite3
import pandas as pd
from pathlib import Path

###### その他の補正(フォルム等)のリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
buffDebuffDBFile = 'BuffDebuffs.db'
buffDebuffDBTable = 'buffDebuffDB'
buffDebuffColumnId = 'id'
buffDebuffColumnName = 'name'
buffDebuffColumnEnglishName = 'englishName'
buffDebuffColumnColor = 'color'
buffDebuffColumnTurns = 'turns'
buffDebuffColumnIsHidden = 'isHidden'

# CSVファイル(PokeAPI+独自)の列名
abilitiesLangCSVabilityIDColumn = 'ability_id'
abilitiesLangCSVLangIDColumn = 'local_language_id'
abilitiesLangCSVNameColumn = 'name'

# CSVファイルの列インデックス
buffDebuffsCSVIDIndex = 1
buffDebuffsCSVnameIndex = 3
buffDebuffsCSVenglishNameIndex = 4
buffDebuffsCSVcolorIndex = 5
buffDebuffsCSVturnsIndex = 6
buffDebuffsCSVisHiddenIndex = 7

# SQLiteでintの配列をvalueにした場合の変換方法
# ※注）intの2重配列を対象にしている
IntIntList = list
sqlite3.register_adapter(IntIntList, lambda l: ';'.join([':'.join(str(int(i)) for i in ints) for ints in l]))
sqlite3.register_converter("IntIntList", lambda s: [[int(i) for i in s2.split(':')] for s2 in s.split(';')])

def set_argparse():
    parser = argparse.ArgumentParser(description='その他の補正(フォルム等)のリストをcsvファイルから取得してsqliteファイルに保存する')
    parser.add_argument('buff_debuffs', help='各補正の情報（ID等）が記載されたCSVファイル')
    parser.add_argument('-o', '--output', required=False, default=buffDebuffDBFile, help='出力先ファイル名')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    db_path = Path.cwd().joinpath(args.output)
    conn = sqlite3.connect(db_path)
    con = conn.cursor()

    # 読み込み
    buff_debuffs_list = []
    try:
        con.execute(f'SELECT * FROM {buffDebuffDBTable}')
        buff_debuffs_list = con.fetchall()
        print('read [buffDebuffs]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [buffDebuffs] data with PokeAPI and create table')

    if (len(buff_debuffs_list) == 0):
        # 補正一覧ファイル読み込み
        buff_debuff_df = pd.read_csv(args.buff_debuffs)
        buff_debuff_df = buff_debuff_df.fillna('')
        for row in buff_debuff_df.itertuples():
            # ID
            id = row[buffDebuffsCSVIDIndex]
            # 日本語表示名
            name = row[buffDebuffsCSVnameIndex]
            # 英語表示名
            name_en = row[buffDebuffsCSVenglishNameIndex]
            # 表示色
            color = row[buffDebuffsCSVcolorIndex]
            # 持続ターン数
            turns = row[buffDebuffsCSVturnsIndex]
            # 隠しステータスかどうか
            is_hidden = row[buffDebuffsCSVisHiddenIndex]
            buff_debuffs_list.append((id, name, name_en, color, turns, is_hidden))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {buffDebuffDBTable} ('
            f'  {buffDebuffColumnId} integer primary key,'
            f'  {buffDebuffColumnName} text not null,'
            f'  {buffDebuffColumnEnglishName} text not null,'
            f'  {buffDebuffColumnColor} text not null,'
            f'  {buffDebuffColumnTurns} integer,'
            f'  {buffDebuffColumnIsHidden} integer)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {buffDebuffDBTable} ({buffDebuffColumnId}, {buffDebuffColumnName}, {buffDebuffColumnEnglishName}, {buffDebuffColumnColor}, {buffDebuffColumnTurns}, {buffDebuffColumnIsHidden}) VALUES ( ?, ?, ?, ?, ?, ? )',
                buff_debuffs_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
