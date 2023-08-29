import argparse
import sqlite3
import pandas as pd

###### ポケモンのリストをcsvファイルから取得してsqliteファイルに保存 ######

# 保存先SQLiteの各種名前
pokeBaseDBFile = 'PokeBases.db'
pokeBaseDBTable = 'pokeBaseDB'
pokeBaseColumnId = 'id'
pokeBaseColumnName = 'name'
pokeBaseColumnAbility = 'ability'
pokeBaseColumnForm = 'form'
pokeBaseColumnMove = 'move'
pokeBaseColumnStats = [
  'h',
  'a',
  'b',
  'c',
  'd',
  's',
]
pokeBaseColumnType = 'type'

# SQLiteでintの配列をvalueにした場合の変換方法
IntList = list
sqlite3.register_adapter(IntList, lambda l: ';'.join([str(i) for i in l]))
sqlite3.register_converter("IntList", lambda s: [int(i) for i in s.split(';')])

# CSVファイル(PokeAPI)の列名
pokemonsLangCSVPokemonIDColumn = 'pokemon_species_id'
pokemonsLangCSVLangIDColumn = 'local_language_id'
pokemonsLangCSVNameColumn = 'name'

pokemonsAbilityCSVPokemonIDColumn = 'pokemon_id'
pokemonsAbilityCSVAbilityIDColumn = 'ability_id'

pokemonsMoveCSVPokemonIDColumn = 'pokemon_id'
pokemonsMoveCSVMoveIDColumn = 'move_id'

pokemonsStatCSVPokemonIDColumn = 'pokemon_id'
pokemonsStatCSVStatIDColumn = 'stat_id'
pokemonsStatCSVBaseStatColumn = 'base_stat'

pokemonsTypeCSVPokemonIDColumn = 'pokemon_id'
pokemonsTypeCSVTypeIDColumn = 'type_id'

# CSVファイル(PokeAPI)の列インデックス
pokeBaseCSVpokemonIDIndex = 1

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
HPID = 1
attackID = 2
defenseID = 3
specialAttackID = 4
specialDefenseID = 5
speedID = 6

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
    parser.add_argument('pokemons', help='各ポケモンの情報（ID等）が記載されたCSVファイル(pokemon_species.csv)')
    parser.add_argument('pokemon_lang', help='各ポケモンと各言語での名称の情報が記載されたCSVファイル(pokemon_species_names.csv)')
    parser.add_argument('pokemon_ability', help='各ポケモンのもつとくせいの情報が記載されたCSVファイル')
    parser.add_argument('pokemon_move', help='各ポケモンが覚えるわざの情報が記載されたCSVファイル')
    parser.add_argument('pokemon_stat', help='各ポケモンの種族値が記載されたCSVファイル')
    parser.add_argument('pokemon_type', help='各ポケモンのタイプが記載されたCSVファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()

    conn = sqlite3.connect(pokeBaseDBFile)
    con = conn.cursor()

    # 読み込み
    pokemons_list = []
    try:
        con.execute(f'SELECT * FROM {pokeBaseDBTable}')
        pokemons_list = con.fetchall()
        print('read [pokemons]:')
    except sqlite3.OperationalError:
        print('failed to read table')
        print('get [pokemons] data with PokeAPI and create table')

    if (len(pokemons_list) == 0):
        # 言語ファイル読み込み
        lang_df = pd.read_csv(args.pokemon_lang)
        # ポケモン一覧ファイル読み込み
        pokemon_df = pd.read_csv(args.pokemons)
        # 各種情報ファイル読み込み
        ability_df = pd.read_csv(args.pokemon_ability)
        move_df = pd.read_csv(args.pokemon_move)
        stat_df = pd.read_csv(args.pokemon_stat)
        type_df = pd.read_csv(args.pokemon_type)
        # 欠損値は値0に置換
        pokemon_df = pokemon_df.fillna(0)
        for row in pokemon_df.itertuples():
            id = row[pokeBaseCSVpokemonIDIndex]
            name = ''
            form = ['0']    # TODO:いつか実装する？
            
            # 日本語名取得
            names = lang_df[(lang_df[pokemonsLangCSVPokemonIDColumn] == id) & (lang_df[pokemonsLangCSVLangIDColumn] == japaneseID)][pokemonsLangCSVNameColumn]
            if len(names) > 0:
                name = names.iloc[0]
            # とくせい取得
            #abilities_raw = ability_df[ability_df[pokemonsAbilityCSVPokemonIDColumn] == id][pokemonsAbilityCSVAbilityIDColumn]
            #abilities = []
            #for i in abilities_raw:
            #    abilities.append(str(i))
            abilities = ability_df[ability_df[pokemonsAbilityCSVPokemonIDColumn] == id][pokemonsAbilityCSVAbilityIDColumn].to_list()
            # わざ取得
            moves = move_df[move_df[pokemonsMoveCSVPokemonIDColumn] == id][pokemonsMoveCSVMoveIDColumn].to_list()
            # HP取得
            h = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == HPID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # こうげき取得
            a = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == attackID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # ぼうぎょ取得
            b = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == defenseID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # とくこう取得
            c = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == specialAttackID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # とくぼう取得
            d = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == specialDefenseID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # すばやさ取得
            s = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == id) & (stat_df[pokemonsStatCSVStatIDColumn] == speedID)][pokemonsStatCSVBaseStatColumn].iloc[0])
            # タイプ取得
            types = type_df[type_df[pokemonsTypeCSVPokemonIDColumn] == id][pokemonsTypeCSVTypeIDColumn].to_list()
            for i in range(len(types)):
                if types[i] > 10000:    # 特殊なタイプ
                    types[i] = 0

            pokemons_list.append((id, name, abilities, form, moves, h, a, b, c, d, s, types))


        # 作成(存在してたら作らない)
        statsColumn = ''
        for element in pokeBaseColumnStats:
            statsColumn += f'  {element} int,'
        try:
            con.execute(
            f'CREATE TABLE IF NOT EXISTS {pokeBaseDBTable} ('
            f'  {pokeBaseColumnId} integer primary key,'
            f'  {pokeBaseColumnName} text not null,'
            f'  {pokeBaseColumnAbility} IntList,'
            f'  {pokeBaseColumnForm} IntList,'
            f'  {pokeBaseColumnMove} IntList,' +
            statsColumn +
            f'  {pokeBaseColumnType} IntList)'
            )
        except sqlite3.OperationalError:
            print('failed to create table')

        # 挿入
        statsColumn = ''
        for element in pokeBaseColumnStats:
            statsColumn += f'{element}, '
        statsColumn = statsColumn[:-2]
        try:
            con.executemany(
                f'INSERT INTO {pokeBaseDBTable} ('
                f'{pokeBaseColumnId}, {pokeBaseColumnName}, {pokeBaseColumnAbility}, {pokeBaseColumnForm}, {pokeBaseColumnMove}, {statsColumn}, {pokeBaseColumnType}) '
                f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                pokemons_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
