# ポケレコ(PokeReco)

育成したポケモン・パーティ・対戦を記録する Android 向けアプリです(iOS は未定)。

ダウンロード ↓

<a href='https://play.google.com/store/apps/details?id=com.dkomki.pokereco'><img alt='Google Play で手に入れよう' width="160" src='https://play.google.com/intl/en_us/badges/static/images/badges/ja_badge_web_generic.png'/></a>

<img width="200" src="Screenshot_20231017-183758.png"> <img width="200" src="Screenshot_20231124-171155.png"> <img width="200" src="Screenshot_20231124-172052.png">

## 特徴

## 環境構築

### Windows(for Android)

### Mac OS(for iOS)

- 公式：https://docs.flutter.dev/get-started/install/macos/mobile-ios
- 日本語記事：https://zenn.dev/kboy/books/ca6a9c93fd23f3/viewer/5232dc

## Integration Test 方法

通常の[Flutter integration_test](https://docs.flutter.dev/testing/integration-tests)では、テスト実行のたびにビルドからやり直しとなり、テストの効率が悪いです。

また、https://qiita.com/allJokin/items/8576ef79710d7e682c2c にあるように「flutter run」コマンドで実行するとホットリロードが可能になりますが、実機でのテストができません。(実機上でシミュレータが動いているような画面になり、実機と挙動が異なります。)

上記の問題を解決するため、本リポジトリでは VSCode で以下の方法を用いてテストしています。

1. 「実行とデバッグ」タブで、プルダウンメニューから「App of Integration Test」を選択し、実機にてデバッグ開始
1. 実機で通常通りアプリが起動する
1. 「実行とデバッグ」タブで、プルダウンメニューから「poke_reco」(デフォルトの選択肢)を選択し、poke_reco\test\integration_test.dart を開いてデバッグ開始
1. 実機で起動しているアプリがテストを実施する。テストプログラムはホットリロードやブレークポイントに対応

参考：https://qiita.com/agajo/items/b3a7afa07040c0f7132c

## 注意事項

### Flutter のルートディレクトリ

Flutter のルートディレクトリは poke_reco/です。
Flutter のコマンドを実行するとき(`flutter pub get`など)は poke_reco に移動してから行ってください。

### 広告ユニット表示部の削除

TODO

### 一部パッケージのコード修正が必要

上下矢印付きの数値入力ボックスでキーボードを使って文字を消すと例外が出るバグがあるので、下記の修正を施す（現在公式のアップデート待ち状態）
https://github.com/rmsmani/number_inc_dec/commit/74ce164a25f0ab7c3b162b432f64210be88b10d9
