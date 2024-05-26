import argparse
import pandas as pd

# pokemon_species CSVファイルの列名
pokemonSpeciesCSVEvolvesFromIDColumn = 'evolves_from_species_id'

# pokemon CSVファイルの列インデックス
pokemonCSVSpeciesIDIndex = 2
pokemonCSVAvailableEvioliteIndex = 8

def set_argparse():
    parser = argparse.ArgumentParser(description='CSVファイルのしんかのきせき適用可能性を更新する')
    parser.add_argument('pokemon', help='リージョンフォーム等のすべてのポケモンが記載されたCSVファイル(pokemon.csv)')
    parser.add_argument('pokemon_species', help='各ポケモンの情報（ID等）が記載されたCSVファイル(pokemon_species.csv)')
    args = parser.parse_args()
    return args

def isInt(s):
    try:
        int(s)
    except ValueError:
        return False
    else:
        return True

def main():
    args = set_argparse()

    # 種族IDごとの情報CSVファイル読み込み
    species_df = pd.read_csv(args.pokemon_species)

    # 全ポケモンの情報CSVファイル読み込み
    line_text = []
    with open(args.pokemon, mode='r', encoding="utf-8") as file:
        for line in file:
            # 1列目がIDじゃない(intじゃない)場合は出力に現在の行を追加して、次の行へ
            if not isInt(line.split(',')[0]):
                line_text.append(line)
                continue
            # 現在の行のカンマ区切りをリストに保存
            elements = line.split(',')
            cur_species_id = int(elements[pokemonCSVSpeciesIDIndex])  # 種族ID
            # 対象種族IDを進化元に持つポケモンを探す
            evolve_to = species_df[species_df[pokemonSpeciesCSVEvolvesFromIDColumn] == cur_species_id]
            # 進化元に持つポケモンがいない＝進化先がないなら
            if len(evolve_to) == 0:
                # しんかのきせき適用外とする
                elements[pokemonCSVAvailableEvioliteIndex] = '0'
            else:
                # しんかのきせき適用とする
                elements[pokemonCSVAvailableEvioliteIndex] = '1'
            line_text.append(','.join(elements) + '\n')
    
    # CSVファイル読み込み
    with open(args.pokemon, mode='w', encoding="utf-8") as file:
        for text in line_text:
            file.write(text)

if __name__ == "__main__":
    main()
