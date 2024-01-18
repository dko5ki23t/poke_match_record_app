# ポケレコ(PokeReco)

育成したポケモン・パーティ・対戦を記録するAndroid向けアプリです(iOSは未定)。

ダウンロード↓

<a href='https://play.google.com/store/apps/details?id=com.dkomki.pokereco'><img alt='Google Play で手に入れよう' width="160" src='https://play.google.com/intl/en_us/badges/static/images/badges/ja_badge_web_generic.png'/></a>

<img width="200" src="Screenshot_20231017-183758.png"> <img width="200" src="Screenshot_20231124-171155.png"> <img width="200" src="Screenshot_20231124-172052.png">

## 特徴

## 環境構築

### Windows(for Android)

### Mac OS(for iOS)
* 公式：https://docs.flutter.dev/get-started/install/macos/mobile-ios
* 日本語記事：https://zenn.dev/kboy/books/ca6a9c93fd23f3/viewer/5232dc

## 注意事項

### Flutterのルートディレクトリ
Flutterのルートディレクトリはpoke_reco/です。
Flutterのコマンドを実行するとき(`flutter pub get`など)はpoke_recoに移動してから行ってください。

### 広告ユニット表示部の削除
TODO

### 一部パッケージのコード修正が必要

上下矢印付きの数値入力ボックスでキーボードを使って文字を消すと例外が出るバグがあるので、下記の修正を施す（現在公式のアップデート待ち状態）
https://github.com/rmsmani/number_inc_dec/commit/74ce164a25f0ab7c3b162b432f64210be88b10d9
