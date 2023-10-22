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
pokeBaseColumnFemaleRate = 'femaleRate'
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
pokeBaseColumnHeight = 'height'
pokeBaseColumnWeight = 'weight'
pokeBaseColumnEggGroup = 'eggGroup'

# SQLiteでintの配列をvalueにした場合の変換方法
IntList = list
sqlite3.register_adapter(IntList, lambda l: ';'.join([str(i) for i in l]))
sqlite3.register_converter("IntList", lambda s: [int(i) for i in s.split(';')])

# CSVファイル(PokeAPI)の列名
pokemonSpeciesCSVIDColumn = 'id'
pokemonSpeciesCSVEvolvesFromIDColumn = 'evolves_from_species_id'

pokemonsLangCSVPokemonIDColumn = 'pokemon_species_id'
pokemonsLangCSVLangIDColumn = 'local_language_id'
pokemonsLangCSVNameColumn = 'name'

pokemonsAbilityCSVPokemonIDColumn = 'pokemon_id'
pokemonsAbilityCSVAbilityIDColumn = 'ability_id'

pokemonsMoveCSVPokemonIDColumn = 'pokemon_id'
pokemonsMoveCSVVersionGroupIDColumn = 'version_group_id'
pokemonsMoveCSVMoveIDColumn = 'move_id'

pokemonsStatCSVPokemonIDColumn = 'pokemon_id'
pokemonsStatCSVStatIDColumn = 'stat_id'
pokemonsStatCSVBaseStatColumn = 'base_stat'

pokemonsTypeCSVPokemonIDColumn = 'pokemon_id'
pokemonsTypeCSVTypeIDColumn = 'type_id'

pokemonsVersionCSVPokemonIDColumn = 'pokemon_id'
pokemonsVersionCSVVersionIDColumn = 'version_id'

allpokemonsCSVPokemonIDColumn = 'id'
allpokemonsCSVSpeciesIDColumn = 'species_id'
allpokemonsCSVHeightColumn = 'height'
allpokemonsCSVWeightColumn = 'weight'

pokemonFormsCSVPokemonIDColumn = 'pokemon_id'
pokemonFormsCSVPokemonFormIDColumn = 'id'
pokemonFormsCSVIsBattleOnlyColumn = 'is_battle_only'

formLangCSVPokemonIDColumn = 'pokemon_form_id'
formLangCSVLangIDColumn = 'local_language_id'
formLangCSVNameColumn = 'form_name'

pokemonEggGroupsCSVPokemonIDColumn = 'species_id'
pokemonEggGroupsCSVEggGroupIDColumn = 'egg_group_id'

# CSVファイル(PokeAPI)の列インデックス
pokeBaseCSVpokemonIDIndex = 1
pokeBaseCSVevolvesFromIDIndex = 4
pokeBaseCSVfemaleRate = 9

# CSVファイル(PokeAPI)で必要となる各ID
japaneseID = 1
HPID = 1
attackID = 2
defenseID = 3
specialAttackID = 4
specialDefenseID = 5
speedID = 6
svVersionID = 25

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
    parser.add_argument('pokemons', help='各ポケモンの情報（ID等）が記載されたCSVファイル(pokemon_species.csv)')
    parser.add_argument('pokemon_lang', help='各ポケモンと各言語での名称の情報が記載されたCSVファイル(pokemon_species_names.csv)')
    parser.add_argument('pokemon_ability', help='各ポケモンのもつとくせいの情報が記載されたCSVファイル(pokemon_abilities.csv)')
    parser.add_argument('pokemon_move', help='各ポケモンが覚えるわざの情報が記載されたCSVファイル(pokemon_moves.csv)')
    parser.add_argument('pokemon_stat', help='各ポケモンの種族値が記載されたCSVファイル(pokemon_stats.csv)')
    parser.add_argument('pokemon_type', help='各ポケモンのタイプが記載されたCSVファイル(pokemon_types.csv)')
    parser.add_argument('pokemon_version', help='各ポケモンの登場ゲームが記載されたCSVファイル(pokemon_game_indices.csv)')
    parser.add_argument('pokemon_all', help='リージョンフォーム等のすべてのポケモンが記載されたCSVファイル(pokemon.csv)')
    parser.add_argument('pokemon_forms', help='リージョンフォーム等ポケモンのフォームIDと各ポケモンIDの情報が記載されたCSVファイル(pokemon_forms.csv)')
    parser.add_argument('form_lang', help='リージョンフォーム等ポケモンと各言語での名称の情報が記載されたCSVファイル(pokemon_form_names.csv)')
    parser.add_argument('pokemon_egg_group', help='各ポケモンIDとそのタマゴグループが記載されたCSVファイル(pokemon_egg_groups.csv)')
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
        version_df = pd.read_csv(args.pokemon_version)
        allpokemon_df = pd.read_csv(args.pokemon_all)
        forms_df = pd.read_csv(args.pokemon_forms)
        form_lang_df = pd.read_csv(args.form_lang)
        egg_group_df = pd.read_csv(args.pokemon_egg_group)
        # 欠損値は値0に置換
        pokemon_df = pokemon_df.fillna(0)
        for row in pokemon_df.itertuples():
            id = row[pokeBaseCSVpokemonIDIndex]
            # SV、SVのDLC登場ポケモンのみにフィルタリング
            versions = version_df[version_df[pokemonsVersionCSVPokemonIDColumn] == id][pokemonsVersionCSVVersionIDColumn].tolist()
            if svVersionID not in versions:
                continue

            evolves_from = row[pokeBaseCSVevolvesFromIDIndex]
            evolves_evolves = pokemon_df[pokemon_df[pokemonSpeciesCSVIDColumn] == evolves_from][pokemonSpeciesCSVEvolvesFromIDColumn]
            # 祖先も祖先を持ってる場合
            if len(evolves_evolves) > 0:
                evolves_from = evolves_evolves.iloc[0]
            female_rate = row[pokeBaseCSVfemaleRate]
            egg_groups = egg_group_df[egg_group_df[pokemonEggGroupsCSVPokemonIDColumn] == id][pokemonEggGroupsCSVEggGroupIDColumn].tolist()

            # リージョンフォーム等がないかチェック
            form = []
            form_check = allpokemon_df[allpokemon_df[allpokemonsCSVSpeciesIDColumn] == id][allpokemonsCSVPokemonIDColumn]
            for pokemon_id in form_check:
                form.append(pokemon_id)

            name = ''
            base_name = ''
            # 日本語名取得
            names = lang_df[(lang_df[pokemonsLangCSVPokemonIDColumn] == id) & (lang_df[pokemonsLangCSVLangIDColumn] == japaneseID)][pokemonsLangCSVNameColumn]
            if len(names) > 0:
                base_name = names.iloc[0]
            if len(form) > 1:
                battle_only = True
                for f in form:
                    tmp = forms_df[forms_df[pokemonFormsCSVPokemonIDColumn] == f][pokemonFormsCSVIsBattleOnlyColumn]
                    if f != id and len(tmp) > 0 and tmp.iloc[0] == 0:
                        battle_only = False
                if not battle_only:
                    # フォームID取得
                    tmp = forms_df[forms_df[pokemonFormsCSVPokemonIDColumn] == id][pokemonFormsCSVPokemonFormIDColumn]
                    if len(tmp) > 0:
                        poke_form_id = tmp.iloc[0]
                        # 日本語名取得
                        names = form_lang_df[(form_lang_df[formLangCSVPokemonIDColumn] == poke_form_id) & (form_lang_df[formLangCSVLangIDColumn] == japaneseID)][formLangCSVNameColumn]
                        if len(names) > 0:
                            name = base_name + f'({names.iloc[0]})'
                        else:
                            name = base_name
                    else:
                        name = base_name
                else:
                    name = base_name
            else:
                name = base_name
            # とくせい取得
            abilities = ability_df[ability_df[pokemonsAbilityCSVPokemonIDColumn] == id][pokemonsAbilityCSVAbilityIDColumn].to_list()
            # 重複削除
            abilities = list(set(abilities))
            # わざ取得
            moves = move_df[(move_df[pokemonsMoveCSVPokemonIDColumn] == id) & (move_df[pokemonsMoveCSVVersionGroupIDColumn] == svVersionID)][pokemonsMoveCSVMoveIDColumn].to_list()
            # たまごわざ取得
            if evolves_from is not None:
                egg_moves = move_df[(move_df[pokemonsMoveCSVPokemonIDColumn] == evolves_from) & (move_df[pokemonsMoveCSVVersionGroupIDColumn] == svVersionID)][pokemonsMoveCSVMoveIDColumn].to_list()
                moves = moves + egg_moves
            # 重複削除
            moves = list(set(moves))
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
            # たかさ取得
            height = int(allpokemon_df[allpokemon_df[allpokemonsCSVPokemonIDColumn] == id][allpokemonsCSVHeightColumn].iloc[0])
            # おもさ取得
            weight = int(allpokemon_df[allpokemon_df[allpokemonsCSVPokemonIDColumn] == id][allpokemonsCSVWeightColumn].iloc[0])

            pokemons_list.append((id, name, abilities, form, female_rate, moves, h, a, b, c, d, s, types, height, weight, egg_groups))

            for form_id in form:
                if form_id == id:
                    continue
                # SV、SVのDLC登場ポケモンのみにフィルタリング
                versions = version_df[version_df[pokemonsVersionCSVPokemonIDColumn] == form_id][pokemonsVersionCSVVersionIDColumn].tolist()
                if svVersionID not in versions:
                    continue
                form_name = ''
                # フォームID取得
                tmp = forms_df[forms_df[pokemonFormsCSVPokemonIDColumn] == form_id][pokemonFormsCSVPokemonFormIDColumn]
                if len(tmp) > 0:
                    poke_form_id = tmp.iloc[0]
                    # 日本語名取得
                    names = form_lang_df[(form_lang_df[formLangCSVPokemonIDColumn] == poke_form_id) & (form_lang_df[formLangCSVLangIDColumn] == japaneseID)][formLangCSVNameColumn]
                    if len(names) > 0:
                        form_name = f'{base_name}({names.iloc[0]})'
                        if names.iloc[0] == 'メスのすがた':
                            female_rate = 8
                else:
                    form_name = base_name
                    print(form_id, form_name)
                # とくせい取得
                form_abilities = ability_df[ability_df[pokemonsAbilityCSVPokemonIDColumn] == form_id][pokemonsAbilityCSVAbilityIDColumn].to_list()
                # 重複削除
                form_abilities = list(set(form_abilities))
                # わざ取得
                form_moves = move_df[(move_df[pokemonsMoveCSVPokemonIDColumn] == form_id) & (move_df[pokemonsMoveCSVVersionGroupIDColumn] == svVersionID)][pokemonsMoveCSVMoveIDColumn].to_list()
                # たまごわざ取得
                if evolves_from is not None:
                    egg_moves = move_df[(move_df[pokemonsMoveCSVPokemonIDColumn] == evolves_from) & (move_df[pokemonsMoveCSVVersionGroupIDColumn] == svVersionID)][pokemonsMoveCSVMoveIDColumn].to_list()
                    form_moves = form_moves + egg_moves
                # 重複削除
                form_moves = list(set(form_moves))
                # HP取得
                form_h = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == HPID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # こうげき取得
                form_a = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == attackID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # ぼうぎょ取得
                form_b = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == defenseID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # とくこう取得
                form_c = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == specialAttackID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # とくぼう取得
                form_d = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == specialDefenseID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # すばやさ取得
                form_s = int(stat_df[(stat_df[pokemonsStatCSVPokemonIDColumn] == form_id) & (stat_df[pokemonsStatCSVStatIDColumn] == speedID)][pokemonsStatCSVBaseStatColumn].iloc[0])
                # タイプ取得
                form_types = type_df[type_df[pokemonsTypeCSVPokemonIDColumn] == form_id][pokemonsTypeCSVTypeIDColumn].to_list()
                for i in range(len(types)):
                    if types[i] > 10000:    # 特殊なタイプ
                        types[i] = 0
                # たかさ取得
                form_height = int(allpokemon_df[allpokemon_df[allpokemonsCSVPokemonIDColumn] == form_id][allpokemonsCSVHeightColumn].iloc[0])
                # おもさ取得
                form_weight = int(allpokemon_df[allpokemon_df[allpokemonsCSVPokemonIDColumn] == form_id][allpokemonsCSVWeightColumn].iloc[0])

                pokemons_list.append((form_id, form_name, form_abilities, form, female_rate, form_moves, form_h, form_a, form_b, form_c, form_d, form_s, form_types, form_height, form_weight, egg_groups))


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
            f'  {pokeBaseColumnFemaleRate} integer, '
            f'  {pokeBaseColumnMove} IntList,' +
            statsColumn +
            f'  {pokeBaseColumnType} IntList, '
            f'  {pokeBaseColumnHeight} integer, '
            f'  {pokeBaseColumnWeight} integer, '
            f'  {pokeBaseColumnEggGroup} IntList)'
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
                f'{pokeBaseColumnId}, {pokeBaseColumnName}, {pokeBaseColumnAbility}, '
                f'{pokeBaseColumnForm}, {pokeBaseColumnFemaleRate}, {pokeBaseColumnMove}, '
                f'{statsColumn}, {pokeBaseColumnType}, {pokeBaseColumnHeight}, '
                f'{pokeBaseColumnWeight}, {pokeBaseColumnEggGroup}) '
                f'VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )',
                pokemons_list)
        except sqlite3.OperationalError:
            print('failed to insert table')

        conn.commit()

    con.close()
    conn.close()


if __name__ == "__main__":
    main()
