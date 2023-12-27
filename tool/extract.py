import argparse
import re

def set_argparse():
    parser = argparse.ArgumentParser(description='TODO')
    parser.add_argument('txt', help='わざ名が含まれるテキストファイル')
    parser.add_argument('output', help='わざ名のみの羅列出力ファイル')
    args = parser.parse_args()
    return args

def main():
    args = set_argparse()
    line_text = []

    # テキストファイル読み込み
    with open(args.txt, mode='r', encoding="utf-8") as file:
        for line in file:
            name = line.strip()
            names = name.split()
            if re.match(r'思い出し|進化時|基本|Lv.[0-9]+|マシン[0-9]+|遺伝', names[0]) is not None:
                move = re.sub('\[遺伝経路\]New|\[遺伝経路\]|New', '', names[1])
                line_text.append(move+'\n')
    
    # 変換後文字列を書き込み
    with open(args.output, mode='w', encoding="utf-8") as file:
        for text in line_text:
            file.write(text)
    

if __name__ == "__main__":
    main()

