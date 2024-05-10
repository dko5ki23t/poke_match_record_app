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
buffDebuffColumnEffectID = 'effectID'
buffDebuffColumnEffectArg1 = 'effectArg1'
buffDebuffColumnEffectArg2 = 'effectArg2'
buffDebuffColumnEffectArg3 = 'effectArg3'
buffDebuffColumnEffectArg4 = 'effectArg4'
buffDebuffColumnEffectArg5 = 'effectArg5'
buffDebuffColumnEffectArg6 = 'effectArg6'
buffDebuffColumnEffectArg7 = 'effectArg7'

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
buffDebuffsCSVeffectIDIndex = 8
buffDebuffsCSVeffectArg1Index = 9
buffDebuffsCSVeffectArg2Index = 10
buffDebuffsCSVeffectArg3Index = 11
buffDebuffsCSVeffectArg4Index = 12
buffDebuffsCSVeffectArg5Index = 13
buffDebuffsCSVeffectArg6Index = 14
buffDebuffsCSVeffectArg7Index = 15

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
            # 効果ID
            effect_id = row[buffDebuffsCSVeffectIDIndex]
            # 効果の引数1~6
            effect_arg1 = row[buffDebuffsCSVeffectArg1Index]
            effect_arg2 = row[buffDebuffsCSVeffectArg2Index]
            effect_arg3 = row[buffDebuffsCSVeffectArg3Index]
            effect_arg4 = row[buffDebuffsCSVeffectArg4Index]
            effect_arg5 = row[buffDebuffsCSVeffectArg5Index]
            effect_arg6 = row[buffDebuffsCSVeffectArg6Index]
            effect_arg7 = row[buffDebuffsCSVeffectArg7Index]

            buff_debuffs_list.append((id, name, name_en, color, turns, is_hidden,
                                      effect_id, effect_arg1, effect_arg2, effect_arg3,
                                      effect_arg4, effect_arg5, effect_arg6, effect_arg7))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {buffDebuffDBTable} ('
            f'  {buffDebuffColumnId} integer primary key,'
            f'  {buffDebuffColumnName} text not null,'
            f'  {buffDebuffColumnEnglishName} text not null,'
            f'  {buffDebuffColumnColor} text not null,'
            f'  {buffDebuffColumnTurns} integer,'
            f'  {buffDebuffColumnIsHidden} integer,'
            f'  {buffDebuffColumnEffectID} integer,'
            f'  {buffDebuffColumnEffectArg1} integer,'
            f'  {buffDebuffColumnEffectArg2} integer,'
            f'  {buffDebuffColumnEffectArg3} integer,'
            f'  {buffDebuffColumnEffectArg4} integer,'
            f'  {buffDebuffColumnEffectArg5} integer,'
            f'  {buffDebuffColumnEffectArg6} integer,'
            f'  {buffDebuffColumnEffectArg7} integer)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {buffDebuffDBTable} ({buffDebuffColumnId}, {buffDebuffColumnName}, {buffDebuffColumnEnglishName}, '
                f'{buffDebuffColumnColor}, {buffDebuffColumnTurns}, {buffDebuffColumnIsHidden},'
                f'{buffDebuffColumnEffectID}, {buffDebuffColumnEffectArg1}, {buffDebuffColumnEffectArg2}, {buffDebuffColumnEffectArg3}, '
                f'{buffDebuffColumnEffectArg4}, {buffDebuffColumnEffectArg5}, {buffDebuffColumnEffectArg6} {buffDebuffColumnEffectArg7})'
                f' VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                buff_debuffs_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
