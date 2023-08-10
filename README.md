# poke_match_record_app

## clone時の注意

各種パッケージが存在せずにエラーになるので、以下を実行

`flutter pub get`

## 一部パッケージのコード修正が必要

上下矢印付きの数値入力ボックスでキーボードを使って文字を消すと例外が出るバグがあるので、下記の修正を施す（現在公式のアップデート待ち状態）
https://github.com/rmsmani/number_inc_dec/commit/74ce164a25f0ab7c3b162b432f64210be88b10d9
