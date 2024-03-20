import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// オノノクス戦1
Future<void> test31_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオノノクス戦1',
    ownPartyname: '31もこノクス',
    opponentName: 'U-turn',
    pokemon1: 'ソウブレイズ',
    pokemon2: 'カバルドン',
    pokemon3: 'カイリュー',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'サーフゴー',
    pokemon6: 'ニンフィア',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこノクス/',
      ownPokemon2: 'もこリングマ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ソウブレイズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ソウブレイズのHP1
  await inputRemainHP(driver, me, '1');
  // ソウブレイズのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ソウブレイズのくだけるよろい
  await addEffect(driver, 3, op, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  // ソウブレイズのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', true);
  // オノノクスのHP65
  await inputRemainHP(driver, op, '65');
  // ソウブレイズのHP30
  await inputRemainHP(driver, op, '30');
  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オノノクス->リングマに交代
  await changePokemon(driver, me, 'リングマ', true);
  // カイリューのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // リングマのHP98
  await inputRemainHP(driver, op, '98');
  // リングマののしかかり
  await tapMove(driver, me, 'のしかかり', false);
  // カイリューのHP90
  await inputRemainHP(driver, me, '90');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // 外れる
  await tapHit(driver, me);
  // ロトムのHP100
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // リングマのHP0
  await inputRemainHP(driver, op, '0');
  // リングマひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトム->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // カイリューのHP1
  await inputRemainHP(driver, me, '1');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オノノクス->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // ボーマンダのHP129
  await inputRemainHP(driver, op, '129');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回命中
  await setHitCount(driver, me, 1);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ロトムのHP75
  await inputRemainHP(driver, me, '75');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オノノクス戦2
Future<void> test31_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオノノクス戦2',
    ownPartyname: '31もこノクス',
    opponentName: 'まりわさ',
    pokemon1: 'マリルリ',
    pokemon2: 'ラウドボーン',
    pokemon3: 'マスカーニャ',
    pokemon4: 'サザンドラ',
    pokemon5: 'コノヨザル',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこルリ/',
      ownPokemon2: 'もこノクス/',
      ownPokemon3: 'もこリングマ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのおにび
  await tapMove(driver, op, 'おにび', true);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ドラパルトのHP90
  await inputRemainHP(driver, me, '90');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->リングマに交代
  await changePokemon(driver, me, 'リングマ', true);
  // ドラパルトのたたりめ
  await tapMove(driver, op, 'たたりめ', true);
  // リングマのHP191
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // リングマのHP98
  await inputRemainHP(driver, op, '98');
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドラパルトのHP30
  await inputRemainHP(driver, me, '30');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // マスカーニャのHP75
  await inputRemainHP(driver, me, '75');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとくせいがへんげんじざいと判明
  await editPokemonState(driver, 'マスカーニャ/まりわさ', null, 'へんげんじざい', null);
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // リングマのHP0
  await inputRemainHP(driver, op, '0');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('しんかのきせき');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('しんかのきせき')));
  // リングマひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // マリルリのHP117
  await inputRemainHP(driver, op, '117');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('とつげきチョッキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('とつげきチョッキ')));
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ドラパルトのHP20
  await inputRemainHP(driver, me, '20');
  // ドラパルトのたたりめ
  await tapMove(driver, op, 'たたりめ', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', true);
  // オノノクスのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // コノヨザルのHP95
  await inputRemainHP(driver, me, '95');
  // ドラパルトのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // オノノクスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', true);
  // オノノクスのHP33
  await inputRemainHP(driver, op, '33');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // コノヨザルのHP8
  await inputRemainHP(driver, me, '8');
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // オノノクスのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'まりわさの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オノノクス戦3
Future<void> test31_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオノノクス戦3',
    ownPartyname: '31もこノクス2',
    opponentName: 'ゆうが',
    pokemon1: 'ガブリアス',
    pokemon2: 'ルカリオ',
    pokemon3: 'シビルドン',
    pokemon4: 'オーロンゲ',
    pokemon5: 'ドオー',
    pokemon6: 'ウォーグル',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'もこノクス/',
      ownPokemon3: 'もこアルマ/',
      opponentPokemon: 'オーロンゲ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // モトトカゲのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // オーロンゲのHP95
  await inputRemainHP(driver, me, '95');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('ひかりのねんど');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ひかりのねんど')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのすてみタックル
  await tapMove(driver, me, 'すてみタックル', false);
  // オーロンゲのHP45
  await inputRemainHP(driver, me, '45');
  // モトトカゲのHP113
  await inputRemainHP(driver, me, '113');
  // オーロンゲのソウルクラッシュ
  await tapMove(driver, op, 'ソウルクラッシュ', true);
  // モトトカゲのHP0
  await inputRemainHP(driver, op, '0');
  // モトトカゲひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // オーロンゲのHP10
  await inputRemainHP(driver, me, '10');
  // オーロンゲのリフレクター
  await tapMove(driver, op, 'リフレクター', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのテラスタル
  await inputTerastal(driver, me, '');
  // オーロンゲのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', false);
  // オノノクスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  await tapSuccess(driver, me);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲのひかりのかべ
  await tapMove(driver, op, 'ひかりのかべ', true);
  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // オーロンゲのHP0
  await inputRemainHP(driver, me, '0');
  // オーロンゲひんし->ルカリオに交代
  await changePokemon(driver, op, 'ルカリオ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オノノクス->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // ルカリオのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ルカリオのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ルカリオのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // ルカリオのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ルカリオのHP35
  await inputRemainHP(driver, me, '35');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ルカリオのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ルカリオ->シビルドンに交代
  await changePokemon(driver, op, 'シビルドン', true);
  // オノノクスのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // シビルドンのHP40
  await inputRemainHP(driver, me, '40');
  // ルカリオのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // シビルドンのHP0
  await inputRemainHP(driver, me, '0');
  // シビルドンひんし->ルカリオに交代
  await changePokemon(driver, op, 'ルカリオ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ルカリオのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // オノノクスのHP4
  await inputRemainHP(driver, op, '4');
  // オノノクスのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ルカリオのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オノノクス戦4
Future<void> test31_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオノノクス戦4',
    ownPartyname: '31もこノクス2',
    opponentName: 'スニはら',
    pokemon1: 'ドドゲザン',
    pokemon2: 'ガブリアス',
    pokemon3: 'ドラパルト',
    pokemon4: 'グレンアルマ',
    pokemon5: 'デカヌチャン',
    pokemon6: 'ジバコイル',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'もこノクス/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'デカヌチャン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのかたやぶり
  await addEffect(driver, 0, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // デカヌチャンのふうせん
  await addEffect(driver, 1, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // モトトカゲのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // デカヌチャンのHP90
  await inputRemainHP(driver, me, '90');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('ふうせん');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ふうせん')));
  // デカヌチャンのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // デカヌチャンのHP65
  await inputRemainHP(driver, op, '65');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  return;
  // モトトカゲのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // モトトカゲのHP73
  await inputRemainHP(driver, me, '73');
  // TODO: オボンのみが発動しない
  // オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  return;
  // デカヌチャンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // デカヌチャンのHP65
  await inputRemainHP(driver, me, '');
  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // オノノクスのHP144
  await inputRemainHP(driver, op, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // オノノクスのHP144
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // デカヌチャンひんし->グレンアルマに交代
  await changePokemon(driver, op, 'グレンアルマ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのじしん
  await tapMove(driver, me, 'じしん', false);
  // グレンアルマのHP1
  await inputRemainHP(driver, me, '1');
  // 急所に命中
  await tapCritical(driver, me);
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのくだけるよろい
  await addEffect(driver, 3, op, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  // グレンアルマのサイコフィールド
  await tapMove(driver, op, 'サイコフィールド', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // オノノクス->モトトカゲに交代
  await changePokemon(driver, me, 'モトトカゲ', true);
  // グレンアルマのテラスタル
  await inputTerastal(driver, op, 'エスパー');
  // グレンアルマのワイドフォース
  await tapMove(driver, op, 'ワイドフォース', true);
  // モトトカゲのHP0
  await inputRemainHP(driver, op, '0');
  // モトトカゲひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // グレンアルマのみちづれ
  await tapMove(driver, op, 'みちづれ', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->オノノクスに交代
  await changePokemon(driver, me, 'オノノクス', false);
  // グレンアルマひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 1回命中
  await setHitCount(driver, op, 1);
  // オノノクスのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'スニはらの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// スコヴィラン戦1
Future<void> test32_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうスコヴィラン戦1',
    ownPartyname: '32もこヴィラン',
    opponentName: 'サイクロ',
    pokemon1: 'ガブリアス',
    pokemon2: 'コノヨザル',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'ドドゲザン',
    pokemon5: 'ニンフィア',
    pokemon6: 'ベラカス',
    sex1: Sex.female,
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もコータス/',
      ownPokemon3: 'もこヴィラン/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのテラスタル
  await inputTerastal(driver, op, 'こおり');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ロトムのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->コータスに交代
  await changePokemon(driver, me, 'コータス', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // コータスのHP87
  await inputRemainHP(driver, op, '87');
  // コータスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // コータスのHP0
  await inputRemainHP(driver, op, '0');
  // コータスひんし->スコヴィランに交代
  await changePokemon(driver, me, 'スコヴィラン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのソーラービーム
  await tapMove(driver, me, 'ソーラービーム', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ベラカスに交代
  await changePokemon(driver, op, 'ベラカス', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのテラスタル
  await inputTerastal(driver, me, '');
  // スコヴィランのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ベラカスのHP0
  await inputRemainHP(driver, me, '0');
  // ベラカスひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// スコヴィラン戦2
Future<void> test32_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうスコヴィラン戦2',
    ownPartyname: '32もこヴィラン',
    opponentName: 'りゅいか18',
    pokemon1: 'パーモット',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ハッサム',
    pokemon4: 'サーフゴー',
    pokemon5: 'ブラッキー',
    pokemon6: 'ラウドボーン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もコータス/',
      ownPokemon2: 'もこヴィラン/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'パーモット');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // パーモット->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // コータスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // 急所に命中
  await tapCritical(driver, op);
  // コータスのHP102
  await inputRemainHP(driver, op, '102');
  // コータスのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // 外れる
  await tapHit(driver, me);
  // ラウドボーンのHP100
  await inputRemainHP(driver, me, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // コータスのHP0
  await inputRemainHP(driver, op, '0');
  // コータスひんし->スコヴィランに交代
  await changePokemon(driver, me, 'スコヴィラン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのテラスタル
  await inputTerastal(driver, me, '');
  // スコヴィランのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // スコヴィランのHP0
  await inputRemainHP(driver, op, '0');
  // スコヴィランひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// スコヴィラン戦3
Future<void> test32_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうスコヴィラン戦3',
    ownPartyname: '32もこヴィラン',
    opponentName: 'てぃせー',
    pokemon1: 'ペリッパー',
    pokemon2: 'フローゼル',
    pokemon3: 'ドオー',
    pokemon4: 'ハッサム',
    pokemon5: 'カイリュー',
    pokemon6: 'サザンドラ',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もコータス/',
      ownPokemon2: 'もこヴィラン/',
      ownPokemon3: 'もこヤドキング/',
      opponentPokemon: 'ハッサム');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // コータスのHP149
  await inputRemainHP(driver, op, '149');
  // ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', false);
  // コータスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ハッサムのあめふらし
  await addEffect(driver, 2, op, 'あめふらし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // コータス->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ペリッパーのぼうふう
  await tapMove(driver, op, 'ぼうふう', true);
  // ヤドキングのHP137
  await inputRemainHP(driver, op, '137');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ペリッパーのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ヤドキングのHP111
  await inputRemainHP(driver, op, '111');
  // ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ヤドキングのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ヤドキングのテラスタル
  await inputTerastal(driver, me, '');
  // ハッサムのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', false);
  // ヤドキングのHP50
  await inputRemainHP(driver, op, '50');
  // ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', false);
  // ヤドキングのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ペリッパーのHP0
  await inputRemainHP(driver, me, '0');
  // ペリッパーひんし->フローゼルに交代
  await changePokemon(driver, op, 'フローゼル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ヤドキング->コータスに交代
  await changePokemon(driver, me, 'コータス', true);
  // フローゼルのテラスタル
  await inputTerastal(driver, op, 'みず');
  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // コータスのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルのHP65
  await inputRemainHP(driver, op, '65');
  // コータスひんし->スコヴィランに交代
  await changePokemon(driver, me, 'スコヴィラン', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // フローゼルのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルひんし->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  // スコヴィランのHP84
  await inputRemainHP(driver, op, '84');
  // スコヴィランのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// スコヴィラン戦4
Future<void> test32_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうスコヴィラン戦5',
    ownPartyname: '32もこヴィラン',
    opponentName: 'タクト',
    pokemon1: 'ユキノオー',
    pokemon2: 'サザンドラ',
    pokemon3: 'コノヨザル',
    pokemon4: 'アーマーガア',
    pokemon5: 'マリルリ',
    pokemon6: 'ジバコイル',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もコータス/',
      ownPokemon2: 'もこヴィラン/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // コータスのHP83
  await inputRemainHP(driver, op, '83');
  // コータスのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // サザンドラのHP70
  await inputRemainHP(driver, me, '70');
  // コータスのだっしゅつパック
  await addEffect(driver, 3, me, 'だっしゅつパック');
  // スコヴィランに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('スコヴィラン'));
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ユキノオーに交代
  await changePokemon(driver, op, 'ユキノオー', false);
  // サザンドラのゆきふらし
  await addEffect(driver, 3, op, 'ゆきふらし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // スコヴィラン->ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', true);
  // ユキノオー->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // コノヨザルのHP10
  await inputRemainHP(driver, me, '10');
  // コノヨザルのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', true);
  // ハルクジラのHP87
  await inputRemainHP(driver, op, '87');
  // コノヨザルのHP30
  await inputRemainHP(driver, op, '30');
  // コノヨザルのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // コノヨザル->ユキノオーに交代
  await changePokemon(driver, op, 'ユキノオー', true);
  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // ユキノオーのHP0
  await inputRemainHP(driver, me, '0');
  // ユキノオーひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// スコヴィラン戦5
Future<void> test32_5(
  FlutterDriver driver,
) async {
  // TODO:ダメージ推定たぶん晴れによる上昇考慮されてない
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうスコヴィラン戦6',
    ownPartyname: '32もこヴィラン',
    opponentName: 'BOOK',
    pokemon1: 'ラウドボーン',
    pokemon2: 'ミミッキュ',
    pokemon3: 'サザンドラ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'キョジオーン',
    pokemon6: 'キノガッサ',
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もコータス/',
      ownPokemon2: 'もこヴィラン/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'キョジオーン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // コータスのHP139
  await inputRemainHP(driver, op, '139');
  // コータスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キョジオーンののろい
  await tapMove(driver, op, 'のろい', true);
  // コータスのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // キョジオーンのHP75
  await inputRemainHP(driver, me, '75');
  // コータスのだっしゅつパック
  await addEffect(driver, 3, me, 'だっしゅつパック');
  // スコヴィランに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('スコヴィラン'));
  await driver.tap(find.text('OK'));
  // しおづけ編集
  await tapEffect(driver, 'しおづけ');
  await driver.tap(find.text('削除'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのソーラービーム
  await tapMove(driver, me, 'ソーラービーム', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // スコヴィラン->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', true);
  // サザンドラのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // エルレイドのHP0
  await inputRemainHP(driver, op, '0');
  // エルレイドひんし->スコヴィランに交代
  await changePokemon(driver, me, 'スコヴィラン', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // スコヴィランのソーラービーム
  await tapMove(driver, me, 'ソーラービーム', false);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // サザンドラのたべのこし
  await addEffect(driver, 4, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのテラスタル
  await inputTerastal(driver, me, '');
  // スコヴィランのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // スコヴィラン->コータスに交代
  await changePokemon(driver, me, 'コータス', true);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // コータスのHP15
  await inputRemainHP(driver, op, '15');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // コータスのHP0
  await inputRemainHP(driver, op, '0');
  // コータスひんし->スコヴィランに交代
  await changePokemon(driver, me, 'スコヴィラン', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オトシドリ戦1
Future<void> test33_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオトシドリ戦1',
    ownPartyname: '33もこシドリ',
    opponentName: 'もこり',
    pokemon1: 'ドラパルト',
    pokemon2: 'ドオー',
    pokemon3: 'ラウドボーン',
    pokemon4: 'セグレイブ',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'サーフゴー',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシドリ/',
      ownPokemon2: 'もこアルマ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのテラスタル
  await inputTerastal(driver, me, '');
  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ドオーに交代
  await changePokemon(driver, op, 'ドオー', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オトシドリ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ドオーのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドオーのHP28
  await inputRemainHP(driver, me, '28');
  // ドオーのあくび
  await tapMove(driver, op, 'あくび', true);
  // ドオーのくろいヘドロ
  await addEffect(driver, 3, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ドオーのHP0
  await inputRemainHP(driver, me, '0');
  // ドオーひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 1回急所
  await setCriticalCount(driver, op, 1);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // ドラパルトのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // グレンアルマひんし->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ドラゴン');
  // オトシドリのすてゼリフ
  await tapMove(driver, me, 'すてゼリフ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ドラパルトのHP2
  await inputRemainHP(driver, me, '2');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('いのちのたま');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('いのちのたま')));
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // オトシドリのHP56
  await inputRemainHP(driver, op, '56');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オトシドリ戦2
Future<void> test33_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオトシドリ戦3',
    ownPartyname: '33もこシドリ',
    opponentName: 'シリウス',
    pokemon1: 'セグレイブ',
    pokemon2: 'キノガッサ',
    pokemon3: 'アーマーガア',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'エーフィ',
    pokemon6: 'バンギラス',
    sex1: Sex.female,
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシドリ/',
      ownPokemon2: 'もこリドリ/',
      ownPokemon3: 'もこニバル/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのテラスタル
  await inputTerastal(driver, me, '');
  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オトシドリ->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', true);
  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // オトシドリのものまねハーブ
  await addEffect(driver, 2, me, 'ものまねハーブ');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // アーマーガア->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // アーマーガアのすなおこし
  await addEffect(driver, 1, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オドリドリ->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', true);
  // バンギラスのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', true);
  // 外れる
  await tapHit(driver, op);
  // ウェーニバルのHP161
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ウェーニバルのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', true);
  // アーマーガアのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // アーマーガアのドリルくちばし
  await tapMove(driver, op, 'ドリルくちばし', true);
  // オドリドリのHP101
  await inputRemainHP(driver, op, '101');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // アーマーガア->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // バンギラスのHP85
  await inputRemainHP(driver, me, '85');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オドリドリ->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', true);
  // バンギラスのじしん
  await tapMove(driver, op, 'じしん', true);
  // ウェーニバルのHP62
  await inputRemainHP(driver, op, '62');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ウェーニバルのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // アーマーガアのHP70
  await inputRemainHP(driver, me, '70');
  // バンギラスのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', true);
  // アーマーガアのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アーマーガアのHP100
  await inputRemainHP(driver, op, '100');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // 外れる
  await tapHit(driver, me);
  // アーマーガアのHP100
  await inputRemainHP(driver, me, '');
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // オトシドリのHP42
  await inputRemainHP(driver, op, '42');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // アーマーガアのHP15
  await inputRemainHP(driver, me, '15');
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // オトシドリのHP0
  await inputRemainHP(driver, op, '0');
  // オトシドリひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オトシドリ戦3
Future<void> test33_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオトシドリ戦4',
    ownPartyname: '33もこシドリ',
    opponentName: 'じゅんき',
    pokemon1: 'フローゼル',
    pokemon2: 'セグレイブ',
    pokemon3: 'ペリッパー',
    pokemon4: 'サーフゴー',
    pokemon5: 'デカヌチャン',
    pokemon6: 'モロバレル',
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシドリ/',
      ownPokemon2: 'もこアルマ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ペリッパー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ペリッパーのあめふらし
  await addEffect(driver, 0, op, 'あめふらし');
  await driver.tap(find.text('OK'));
  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ペリッパーのHP1
  await inputRemainHP(driver, me, '1');
  // ペリッパーのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ペリッパーのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // オトシドリのHP126
  await inputRemainHP(driver, op, '126');
  // フローゼルに交代
  await changePokemon(driver, op, 'フローゼル', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オトシドリ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // フローゼルのテラスタル
  await inputTerastal(driver, op, 'みず');
  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // ボーマンダのHP40
  await inputRemainHP(driver, op, '40');
  // フローゼルのHP80
  await inputRemainHP(driver, op, '80');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルのHP70
  await inputRemainHP(driver, op, '70');
  // ボーマンダひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // フローゼル->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', true);
  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // モロバレルのHP30
  await inputRemainHP(driver, me, '30');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // モロバレルのHP0
  await inputRemainHP(driver, me, '0');
  // モロバレルひんし->ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマ->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', true);
  // ペリッパーのなみのり
  await tapMove(driver, op, 'なみのり', true);
  // オトシドリのHP5
  await inputRemainHP(driver, op, '5');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ペリッパーのHP0
  await inputRemainHP(driver, me, '0');
  await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));
  // ペリッパーひんし->フローゼルに交代
  await changePokemon(driver, op, 'フローゼル', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // オトシドリのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルのHP65
  await inputRemainHP(driver, op, '65');
  // オトシドリひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // フローゼルのHP50
  await inputRemainHP(driver, op, '50');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // フローゼルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エーフィ戦1
Future<void> test34_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうエーフィ戦1',
    ownPartyname: '34もこエーフィ',
    opponentName: 'ヒロ',
    pokemon1: 'サーフゴー',
    pokemon2: 'ドオー',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'ドラパルト',
    pokemon5: 'セグレイブ',
    pokemon6: 'マスカーニャ',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこエーフィ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'ドオー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ドオーのHP40
  await inputRemainHP(driver, me, '40');
  // エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ドオーのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ドオーのくろいヘドロ
  await addEffect(driver, 3, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // ドオーのHP36
  await inputRemainHP(driver, me, '36');
  // ドオーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドオーのHP86
  await inputRemainHP(driver, op, '86');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', true);
  // ドオーのじしん
  await tapMove(driver, op, 'じしん', true);
  // エクスレッグのHP146
  await inputRemainHP(driver, op, '146');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ドオーのHP40
  await inputRemainHP(driver, me, '40');
  // エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ドオーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドオーのHP90
  await inputRemainHP(driver, op, '90');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ドオーのHP0
  await inputRemainHP(driver, me, '0');
  // ドオーひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エーフィ戦2
Future<void> test34_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうエーフィ戦2',
    ownPartyname: '34もこエーフィ',
    opponentName: '#きち',
    pokemon1: 'ドラパルト',
    pokemon2: 'ガブリアス',
    pokemon3: 'サーフゴー',
    pokemon4: 'ドドゲザン',
    pokemon5: 'マリルリ',
    pokemon6: 'グレンアルマ',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこエーフィ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'マリルリ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // マリルリのHP55
  await inputRemainHP(driver, me, '55');
  // マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // マリルリのHP111
  await inputRemainHP(driver, op, '111');
  // ターン2へ
  await goTurnPage(driver, turnNum++);
  // マリルリ->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ドドゲザンのHP35
  await inputRemainHP(driver, me, '35');
  // ターン3へ
  await goTurnPage(driver, turnNum++);
  // ドドゲザンのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // マリルリのHP21
  await inputRemainHP(driver, op, '21');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ガブリアスのHP80
  await inputRemainHP(driver, me, '80');
  // ガブリアスのHP80
  await inputRemainHP(driver, me, '80');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // マリルリひんし->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);
  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ガブリアスのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, op, 'アクアジェット', true);
  // エーフィのHP30
  await inputRemainHP(driver, op, '30');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エーフィ戦3
Future<void> test34_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうエーフィ戦3',
    ownPartyname: '34もこエーフィ',
    opponentName: 'れんげ',
    pokemon1: 'ユキノオー',
    pokemon2: 'ミミッキュ',
    pokemon3: 'ジバコイル',
    pokemon4: 'ボーマンダ',
    pokemon5: 'セグレイブ',
    pokemon6: 'イルカマン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // イルカマンのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンひんし->ユキノオーに交代
  await changePokemon(driver, op, 'ユキノオー', false);
  // イルカマンのゆきふらし
  await addEffect(driver, 3, op, 'ゆきふらし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ユキノオーのHP1
  await inputRemainHP(driver, me, '1');
  // ユキノオーのオーロラベール
  await tapMove(driver, op, 'オーロラベール', true);
  // ユキノオーのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ユキノオーのHP0
  await inputRemainHP(driver, me, '0');
  // ユキノオーひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // セグレイブのHP50
  await inputRemainHP(driver, me, '50');
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 4回命中
  await setHitCount(driver, op, 4);
  // 3回命中
  await setHitCount(driver, op, 3);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // エーフィひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', false);
  // 4回命中
  await setHitCount(driver, op, 4);
  // 3回命中
  await setHitCount(driver, op, 3);
  // 2回命中
  await setHitCount(driver, op, 2);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // マリルリのHP118
  await inputRemainHP(driver, op, '118');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エーフィ戦4
Future<void> test34_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうエーフィ戦4',
    ownPartyname: '34もこエーフィ',
    opponentName: 'sayuc♡',
    pokemon1: 'ボーマンダ',
    pokemon2: 'セグレイブ',
    pokemon3: 'ガブリアス',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ニンフィア',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこレッグ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ガブリアスのHP10
  await inputRemainHP(driver, me, '10');
  // ガブリアスのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ガブリアスのじならし
  await tapMove(driver, op, 'じならし', true);
  // エーフィのHP71
  await inputRemainHP(driver, op, '71');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', true);
  // ガブリアスのじならし
  await tapMove(driver, op, 'じならし', false);
  // エクスレッグのHP146
  await inputRemainHP(driver, op, '146');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスひんし->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ニンフィアのHP30
  await inputRemainHP(driver, me, '30');
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // エーフィひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ロトムのHP65
  await inputRemainHP(driver, me, '65');
  // マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ロトムのおにび
  await tapMove(driver, op, 'おにび', true);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ロトムのHP40
  await inputRemainHP(driver, me, '40');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトムのねむる
  await tapMove(driver, op, 'ねむる', true);
  // ロトムのカゴのみ
  await addEffect(driver, 1, op, 'カゴのみ');
  await driver.tap(find.text('OK'));
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ロトムのHP65
  await inputRemainHP(driver, me, '65');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // マリルリのHP105
  await inputRemainHP(driver, op, '105');
  // ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 外れる
  await tapHit(driver, me);
  // ニンフィアのHP36
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ロトムのHP60
  await inputRemainHP(driver, me, '60');
  // ロトムはぼうぎょが下がった
  await driver.tap(find.text('ロトムはぼうぎょが下がった'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // マリルリのHP51
  await inputRemainHP(driver, op, '51');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ロトムのHP40
  await inputRemainHP(driver, me, '40');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // マリルリひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ロトムひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ニンフィアのHP2
  await inputRemainHP(driver, me, '2');
  // エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ニンフィアのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // エクスレッグのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'sayuc♡の勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// フローゼル戦1
Future<void> test35_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうフローゼル戦1',
    ownPartyname: '35もこーゼル',
    opponentName: 'こぶち',
    pokemon1: 'オーロンゲ',
    pokemon2: 'クエスパトラ',
    pokemon3: 'キラフロル',
    pokemon4: 'ボーマンダ',
    pokemon5: 'ウルガモス',
    pokemon6: 'ドラパルト',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレトス/',
      ownPokemon2: 'もこーゼル/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ウルガモスのHP75
  await inputRemainHP(driver, op, '75');
  // フォレトスのあまごい
  await tapMove(driver, me, 'あまごい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // フォレトスのHP1
  await inputRemainHP(driver, op, '1');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // フォレトスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フォレトスのだいばくはつ
  await tapMove(driver, me, 'だいばくはつ', false);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ウルガモスのHP75
  await inputRemainHP(driver, me, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);
  return;
  // TODO: だいばくはつでひんしにならない
  // フォレトスひんし->フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのテラスタル
  await inputTerastal(driver, me, '');
  // ウルガモスのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP113
  await inputRemainHP(driver, me, '113');
  // ウルガモスひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP57
  await inputRemainHP(driver, me, '57');
  // ドラパルトひんし->クエスパトラに交代
  await changePokemon(driver, op, 'クエスパトラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // クエスパトラのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// フローゼル戦2
Future<void> test35_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうフローゼル戦2',
    ownPartyname: '35もこーゼル2',
    opponentName: 'めれんげ',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ドラパルト',
    pokemon3: 'ミミッキュ',
    pokemon4: 'サーフゴー',
    pokemon5: 'アーマーガア',
    pokemon6: 'ハピナス',
    sex2: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレトス/',
      ownPokemon2: 'もこーゼル/',
      ownPokemon3: 'もこアルマ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // フォレトスのHP167
  await inputRemainHP(driver, op, '167');
  // アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // フォレトスのあまごい
  await tapMove(driver, me, 'あまごい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // アーマーガアのHP85
  await inputRemainHP(driver, me, '85');
  // フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのテラスタル
  await inputTerastal(driver, me, '');
  // フローゼルのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // アーマーガアのHP15
  await inputRemainHP(driver, me, '15');
  // アーマーガアのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アーマーガアのHP65
  await inputRemainHP(driver, op, '65');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アーマーガア->ハピナスに交代
  await changePokemon(driver, op, 'ハピナス', true);
  // フローゼルのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // ハピナスのHP75
  await inputRemainHP(driver, me, '75');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // フローゼル->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', true);
  // ハピナスのタマゴうみ
  await tapMove(driver, op, 'タマゴうみ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ハピナスのHP100
  await inputRemainHP(driver, op, '100');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハピナス->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // アーマーガアのHP45
  await inputRemainHP(driver, me, '45');
  // フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // アーマーガア->ハピナスに交代
  await changePokemon(driver, op, 'ハピナス', true);
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ハピナスのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP52
  await inputRemainHP(driver, me, '52');
  // ハピナスひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // フローゼルのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // グレンアルマのHP54
  await inputRemainHP(driver, op, '54');
  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // ドラパルトのHP40
  await inputRemainHP(driver, me, '40');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマ->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', true);
  // ドラパルトのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // フォレトスのHP167
  await inputRemainHP(driver, op, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // フォレトスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アーマーガアのHP95
  await inputRemainHP(driver, op, '95');
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // アーマーガアのHP90
  await inputRemainHP(driver, me, '90');
  // グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 1回命中
  await setHitCount(driver, op, 1);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ドラゴン');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // フォレトスのHP118
  await inputRemainHP(driver, op, '118');
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // ドラパルトのHP24
  await inputRemainHP(driver, me, '24');
  // フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // フォレトスのHP72
  await inputRemainHP(driver, op, '72');
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // ドラパルトのHP15
  await inputRemainHP(driver, me, '15');
  // フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // フォレトスのHP26
  await inputRemainHP(driver, op, '26');
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // ドラパルトのHP5
  await inputRemainHP(driver, me, '5');
  // フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // フォレトスのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'めれんげの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// フローゼル戦3
Future<void> test35_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうフローゼル戦3',
    ownPartyname: '35もこーゼル2',
    opponentName: 'いみご',
    pokemon1: 'オリーヴァ',
    pokemon2: 'ビビヨン',
    pokemon3: 'フワライド',
    pokemon4: 'バチンウニ',
    pokemon5: 'サザンドラ',
    pokemon6: 'ウルガモス',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレトス/',
      ownPokemon2: 'もこーゼル/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'バチンウニ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // バチンウニのエレキメイカー
  await addEffect(driver, 0, op, 'エレキメイカー');
  await driver.tap(find.text('OK'));
  // フォレトスのあまごい
  await tapMove(driver, me, 'あまごい', false);
  // バチンウニのほうでん
  await tapMove(driver, op, 'ほうでん', true);
  // フォレトスのHP89
  await inputRemainHP(driver, op, '89');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // フォレトスのだいばくはつ
  await tapMove(driver, me, 'だいばくはつ', false);
  // バチンウニ->フワライドに交代
  await changePokemon(driver, op, 'フワライド', true);
  // バチンウニのエレキシード
  await addEffect(driver, 1, op, 'エレキシード');
  await driver.tap(find.text('OK'));
  // フワライドのHP100
  await inputRemainHP(driver, me, '');
  // フォレトスひんし->フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのテラスタル
  await inputTerastal(driver, me, '');
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // フワライドのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP87
  await inputRemainHP(driver, me, '87');
  // フワライドひんし->バチンウニに交代
  await changePokemon(driver, op, 'バチンウニ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // バチンウニのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP36
  await inputRemainHP(driver, me, '36');
  // バチンウニひんし->ビビヨンに交代
  await changePokemon(driver, op, 'ビビヨン', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// オノノクス戦1
Future<void> test31_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}
*/
