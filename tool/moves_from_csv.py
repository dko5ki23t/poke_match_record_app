import argparse
import sqlite3
import pandas as pd

###### わざのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
moveDBFile = 'Moves.db'
moveDBTable = 'moveDB'
moveColumnId = 'id'
moveColumnName = 'name'
moveColumnEnglishName = 'englishName'
moveColumnType = 'type'
moveColumnPower = 'power'
moveColumnAccuracy = 'accuracy'
moveColumnPriority = 'priority'
moveColumnTarget = 'target'
moveColumnDamageClass = 'damage_class'
moveColumnEffect = 'effect'
moveColumnEffectChance = 'effect_chance'
moveColumnPP = 'PP'
moveColumnIsDirect = 'is_direct'
moveColumnIsSound = 'is_sound'
moveColumnIsDrain = 'is_drain'
moveColumnIsPunch = 'is_punch'
moveColumnIsWave = 'is_wave'
moveColumnIsDance = 'is_dance'
moveColumnIsRecoil = 'is_recoil'
moveColumnIsAdditionalEffect = 'is_additional_effect'
moveColumnIsAdditionalEffect2 = 'is_additional_effect2'
moveColumnIsBite = 'is_bite'
moveColumnIsCut = 'is_cut'
moveColumnIsWind = 'is_wind'
moveColumnIsPowder = 'is_powder'
moveColumnIsBullet = 'is_bullet'
moveColumnSuccessWithProtect = 'success_with_protect'

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
movesCSVisDirect = 16
movesCSVisSound = 17
movesCSVisDrain = 18
movesCSVisPunch = 19
movesCSVisWave = 20
movesCSVisDance = 21
movesCSVisRecoil = 22
movesCSVisAdditionalEffect = 23
movesCSVisAdditionalEffect2 = 24
movesCSVisBite = 25
movesCSVisCut = 26
movesCSVisWind = 27
movesCSVisPowder = 28
movesCSVisBullet = 29
movesCSVsuccessWithProtect = 30

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
englishID = 9

def set_argparse():
    parser = argparse.ArgumentParser(description='わざの情報をCSVからデータベース化')
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
            is_direct = row[movesCSVisDirect]
            is_sound = row[movesCSVisSound]
            is_drain = row[movesCSVisDrain]
            is_punch = row[movesCSVisPunch]
            is_wave = row[movesCSVisWave]
            is_dance = row[movesCSVisDance]
            is_recoil = row[movesCSVisRecoil]
            is_additionalEffect = row[movesCSVisAdditionalEffect]
            is_additionalEffect2 = row[movesCSVisAdditionalEffect2]
            is_bite = row[movesCSVisBite]
            is_cut = row[movesCSVisCut]
            is_wind = row[movesCSVisWind]
            is_powder = row[movesCSVisPowder]
            is_bullet = row[movesCSVisBullet]
            success_with_protect = row[movesCSVsuccessWithProtect]

            if id == 863:
                print(effect, 'OK')

            if pokeType > 10000:    # 特殊なタイプ
                pokeType = 0
            
            # 日本語名取得
            names = lang_df[(lang_df[movesLangCSVmoveIDColumn] == id) & (lang_df[movesLangCSVLangIDColumn] == japaneseID)][movesLangCSVNameColumn]
            # 英語名取得
            names_en = lang_df[(lang_df[movesLangCSVmoveIDColumn] == id) & (lang_df[movesLangCSVLangIDColumn] == englishID)][movesLangCSVNameColumn]
            if len(names) > 0:
                moves_list.append((
                    id, names.iloc[0], names_en.iloc[0], pokeType, power, accuracy, priority, target, damage_class, effect, effect_chance, pp,
                    is_direct, is_sound, is_drain, is_punch, is_wave, is_dance, is_recoil, is_additionalEffect, is_additionalEffect2, is_bite,
                    is_cut, is_wind, is_powder, is_bullet, success_with_protect
                ))

        # 作成(存在してたら作らない)
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {moveDBTable} ('
            f'  {moveColumnId} integer primary key,'
            f'  {moveColumnName} text not null,'
            f'  {moveColumnEnglishName} text not null,'
            f'  {moveColumnType} integer not null,'
            f'  {moveColumnPower} integer not null,'
            f'  {moveColumnAccuracy} integer not null,'
            f'  {moveColumnPriority} integer not null,'
            f'  {moveColumnTarget} integer not null,'
            f'  {moveColumnDamageClass} integer not null,'
            f'  {moveColumnEffect} integer not null,'
            f'  {moveColumnEffectChance} integer not null,'
            f'  {moveColumnPP} integer not null,'
            f'  {moveColumnIsDirect} integer not null,'
            f'  {moveColumnIsSound} integer not null,'
            f'  {moveColumnIsDrain} integer not null,'
            f'  {moveColumnIsPunch} integer not null,'
            f'  {moveColumnIsWave} integer not null,'
            f'  {moveColumnIsDance} integer not null,'
            f'  {moveColumnIsRecoil} integer not null,'
            f'  {moveColumnIsAdditionalEffect} integer not null,'
            f'  {moveColumnIsAdditionalEffect2} integer not null,'
            f'  {moveColumnIsBite} integer not null,'
            f'  {moveColumnIsCut} integer not null,'
            f'  {moveColumnIsWind} integer not null,'
            f'  {moveColumnIsPowder} integer not null,'
            f'  {moveColumnIsBullet} integer not null,'
            f'  {moveColumnSuccessWithProtect} integer not null)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        try:
            con.executemany(
                f'INSERT INTO {moveDBTable} ({moveColumnId}, {moveColumnName}, '
                f'{moveColumnEnglishName}, {moveColumnType}, {moveColumnPower}, '
                f'{moveColumnAccuracy}, {moveColumnPriority}, {moveColumnTarget}, '
                f'{moveColumnDamageClass}, {moveColumnEffect}, {moveColumnEffectChance}, '
                f'{moveColumnPP}, {moveColumnIsDirect}, {moveColumnIsSound}, '
                f'{moveColumnIsDrain}, {moveColumnIsPunch}, {moveColumnIsWave}, '
                f'{moveColumnIsDance}, {moveColumnIsRecoil}, {moveColumnIsAdditionalEffect}, '
                f'{moveColumnIsAdditionalEffect2}, {moveColumnIsBite}, {moveColumnIsCut}, '
                f'{moveColumnIsWind}, {moveColumnIsPowder}, {moveColumnIsBullet}, '
                f'{moveColumnSuccessWithProtect}) '
                f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                moves_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
