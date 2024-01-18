import argparse
import pandas as pd

# pokemon_movesに追加するためのスクリプト

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
    parser.add_argument('csv', help='追記するCSVファイル(IDは1列目)')
    parser.add_argument('id', help='追記対象のID')
    parser.add_argument('txt', help='追記したいID(2)が羅列されたファイル(ID(2)は1行ごと)')
#    parser.add_argument('columns', help='追記したい列の文字列(ID,につづく文字列,ID)')
    parser.add_argument('output', help='出力先csv')
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

    # テキストファイル読み込み
    add_list = []
    with open(args.txt, mode='r', encoding="utf-8") as file:
        for line in file:
            name = line.strip()
            add_list.append(f'{args.id},25,{int(name)},0,0,\n')

    # CSVファイル読み込み
    line_text = []
    has_added = False
    with open(args.csv, mode='r', encoding="utf-8") as file:
        for line in file:
            if not isInt(line.split(',')[0]):
                line_text.append(line)
                continue
            now_id = int(line.split(',')[0])
            if now_id > int(args.id) and has_added is False:
                for text in add_list:
                    line_text.append(text)
                has_added = True
            line_text.append(line)
        if has_added is False and now_id == int(args.id):
            for text in add_list:
                line_text.append(text)
    
    # CSVファイル読み込み
    with open(args.output, mode='w', encoding="utf-8") as file:
        for text in line_text:
            file.write(text)
    

if __name__ == "__main__":
    main()

