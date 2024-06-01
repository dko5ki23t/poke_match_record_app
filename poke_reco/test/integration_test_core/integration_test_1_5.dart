import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// パーモット戦1
Future<void> test1_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうパーモット戦1',
    ownPartyname: '1もこパーモット',
    opponentName: 'メリタマ',
    pokemon1: 'ギャラドス',
    pokemon2: 'セグレイブ',
    pokemon3: 'テツノツツミ',
    pokemon4: 'デカヌチャン',
    pokemon5: 'テツノコウベ',
    pokemon6: 'カバルドン',
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこロローム/',
      opponentPokemon: 'デカヌチャン/');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  await testExistAnyWidgets(find.text('成功'), driver);
  // デカヌチャンのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', true);
  // ボーマンダの残りHP127
  await inputRemainHP(driver, op, '127');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // デカヌチャンの残りHP0
  await inputRemainHP(driver, me, '0');
  // デカヌチャンひんし→テツノツツミに交代
  await changePokemon(driver, op, 'テツノツツミ', false);
  // クォークチャージ発動
  await addEffect(driver, 2, op, 'クォークチャージ');
  // クォークチャージの内容編集
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // 追加されてるか確認
  await testExistEffect(driver, 'クォークチャージ');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // テツノツツミの残りHP0
  await inputRemainHP(driver, me, '0');
  // テツノツツミひんし→ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', false);
  // いかく発動
  await addEffect(driver, 2, op, 'いかく');
  await driver.tap(find.text('OK'));

  // 次のターンへボタンタップ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦2
Future<void> test1_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうパーモット戦2',
    ownPartyname: '1もこパーモット',
    opponentName: 'k.k',
    pokemon1: 'チヲハウハネ',
    pokemon2: 'デカヌチャン',
    pokemon3: 'キラフロル',
    pokemon4: 'ミミッキュ',
    pokemon5: 'サザンドラ',
    pokemon6: 'キノガッサ',
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'チヲハウハネ/');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // チヲハウハネのこだいかっせい
  await addEffect(driver, 1, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // 追加されてるか確認
  await testExistEffect(driver, 'こだいかっせい');
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // チヲハウハネ->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // ボーマンダのダブルウイングが外れる
  await setHitCount(driver, me, 0);
  await inputRemainHP(driver, me, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ミミッキュの残りHP70
  await inputRemainHP(driver, me, '70');
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ボーマンダの残りHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのもちものがいのちのたまと判明
  await editPokemonState(driver, 'ミミッキュ/k.k', null, null, 'いのちのたま');
  // ボーマンダひんし→リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアテラスタル
  await inputTerastal(driver, me, '');
  // 相手ミミッキュ→チヲハウハネに交代
  await changePokemon(driver, op, 'チヲハウハネ', true);
  // リーフィアのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // チヲハウハネの残りHP70
  await inputRemainHP(driver, me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // チヲハウハネの残りHP0
  await inputRemainHP(driver, me, '0');
  // チヲハウハネひんし→サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // サザンドラの残りHP90
  await inputRemainHP(driver, me, '90');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // リーフィアの残りHP0
  await inputRemainHP(driver, op, '0');
  // リーフィアひんし→パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手サザンドラ→ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // パーモットのさいきのいのりでボーマンダ復活
  await tapMove(driver, me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('ボーマンダ'), driver);
  await driver.tap(find.text('ボーマンダ'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // パーモットの残りHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'きあいのタスキ');
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // ミミッキュの残りHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし→サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // サザンドラのりゅうせいぐんが外れる
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');
  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // サザンドラの残りHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦3
Future<void> test1_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうパーモット戦3',
    ownPartyname: '1もこパーモット',
    opponentName: 'Daikon',
    pokemon1: 'トドロクツキ',
    pokemon2: 'バンギラス',
    pokemon3: 'ウルガモス',
    pokemon4: 'カイリュー',
    pokemon5: 'ブロロローム',
    pokemon6: 'ギャラドス',
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ウルガモス/');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのテラスタル
  await inputTerastal(driver, op, 'いわ');
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ウルガモスの残りHP70
  await inputRemainHP(driver, me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ボーマンダの残りHP70
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし→マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリテラスタル
  await inputTerastal(driver, me, '');
  // 相手ウルガモス→トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', true);
  // トドロクツキのこだいかっせい
  await addEffect(driver, 1, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'こだいかっせい');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // トドロクツキの残りHP70
  await inputRemainHP(driver, me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのつじぎり
  await tapMove(driver, op, 'つじぎり', true);
  // マリルリの残りHP93
  await inputRemainHP(driver, op, '93');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // きゅうしょ命中
  await tapCritical(driver, me);
  // トドロクツキの残りHP0
  await inputRemainHP(driver, me, '0');
  // トドロクツキひんし→バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', false);
  // バンギラスのとくせいがすなおこしと判明
  //await editPokemonState(driver, 'バンギラス/Daikon', null, 'すなおこし', null);
  // バンギラスのすなおこし
  await addEffect(driver, 3, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'すなおこし');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // バンギラスのいわなだれ
  await tapMove(driver, op, 'いわなだれ', true);
  // マリルリの残りHP48
  await inputRemainHP(driver, op, '48');
  await testExistAnyWidgets(find.text('マリルリはひるんで技がだせない'), driver);
  await driver.tap(find.text('マリルリはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // きゅうしょ命中
  await tapCritical(driver, me);
  // バンギラスの残りHP30
  await inputRemainHP(driver, me, '30');
  // バンギラスのじだんだ
  await tapMove(driver, op, 'じだんだ', true);
  // マリルリの残りHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし→パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのりでボーマンダ復活
  await tapMove(driver, me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('マリルリ'), driver);
  await driver.tap(find.text('マリルリ'));
  // バンギラスのじだんだ
  await tapMove(driver, op, 'じだんだ', false);
  // パーモットの残りHP12
  await inputRemainHP(driver, op, '12');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手バンギラス→ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ウルガモスの残りHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスのほのおのからだ
  await addEffect(driver, 2, op, 'ほのおのからだ');
  await driver.tap(find.text('OK'));
  // すなあらしダメージでパーモットがやられる
  // ウルガモスひんし→バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', false);
  // パーモットひんし→マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // バンギラスの残りHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦4
Future<void> test1_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうパーモット戦4',
    ownPartyname: '1もこパーモット',
    opponentName: 'アイアムあむ',
    pokemon1: 'ソウブレイズ',
    pokemon2: 'グレンアルマ',
    pokemon3: 'ドドゲザン',
    pokemon4: 'キラフロル',
    pokemon5: 'ウルガモス',
    pokemon6: 'セグレイブ',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこルリ/',
      ownPokemon2: 'もこキリン/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'ソウブレイズ/');

  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ソウブレイズの残りHP40
  await inputRemainHP(driver, me, '40');
  // ソウブレイズのくだけるよろい
  await addEffect(driver, 1, op, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'くだけるよろい');
  // ソウブレイズのレッドカード
  await addEffect(driver, 2, op, 'レッドカード');
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('パーモット'));
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'レッドカード');
  // ソウブレイズのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモット->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', true);
  // マリルリの残りHP90
  await inputRemainHP(driver, op, '90');
  // ソウブレイズの残りHP70に回復
  await inputRemainHP(driver, op, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ソウブレイズのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // マリルリの残りHP2
  await inputRemainHP(driver, op, '2');
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズひんし→セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // マリルリの残りHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし→パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのりでマリルリ復活
  await tapMove(driver, me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('マリルリ'), driver);
  await driver.tap(find.text('マリルリ'));
  // セグレイブのきょけんとつげき
  await tapMove(driver, op, 'きょけんとつげき', true);
  // パーモットの残りHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // パーモットの残りHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし→マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手セグレイブ->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // ドドゲザンのプレッシャー
  await addEffect(driver, 1, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ドドゲザンの残りHP60
  await inputRemainHP(driver, me, '60');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドドゲザンのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ドドゲザンの残りHP35
  await inputRemainHP(driver, me, '35');
  // ドドゲザンのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // 急所に命中
  await tapCritical(driver, op);
  // マリルリの残りHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし→リキキリンに交代
  await changePokemon(driver, me, 'リキキリン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンテラスタル
  await inputTerastal(driver, me, '');
  // リキキリンのこうそくいどう
  await tapMove(driver, me, 'こうそくいどう', false);
  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', true);
  // リキキリンの残りHP163
  await inputRemainHP(driver, op, '163');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのツインビーム
  await tapMove(driver, me, 'ツインビーム', false);
  // ドドゲザンの残りHP5
  await inputRemainHP(driver, me, '5');
  // ドドゲザンのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // リキキリンの残りHP54
  await inputRemainHP(driver, op, '54');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのツインビーム
  await tapMove(driver, me, 'ツインビーム', false);
  // ドドゲザンの残りHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし→セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // セグレイブの残りHP25
  await inputRemainHP(driver, me, '25');
  // セグレイブのじゃくてんほけん
  await addEffect(driver, 1, op, 'じゃくてんほけん');
  await driver.tap(find.text('OK'));
  // セグレイブのきょけんとつげき
  await tapMove(driver, op, 'きょけんとつげき', false);
  // リキキリンの残りHP0
  await inputRemainHP(driver, op, '0');
  // あいての勝利
  await testExistEffect(driver, 'アイアムあむの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦1
Future<void> test2_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイルカマン戦1',
    ownPartyname: '2もこイルカマン',
    opponentName: 'ぜんれつなに',
    pokemon1: 'ミミッキュ',
    pokemon2: 'カバルドン',
    pokemon3: 'キラフロル',
    pokemon4: 'パオジアン',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイルカ/',
      ownPokemon2: 'もこフィア/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'ロトム(ウォッシュロトム)/');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イルカマン->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // ニンフィアのHP157
  await inputRemainHP(driver, op, '157');
  // キラフロルに交代
  await changePokemon(driver, op, 'キラフロル', false);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // キラフロルのHP80
  await inputRemainHP(driver, me, '80');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キラフロルのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', true);
  // キラフロルのヘドロウェーブ
  await tapMove(driver, op, 'ヘドロウェーブ', true);
  // イルカマンのHP71
  await inputRemainHP(driver, op, '71');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キラフロルはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // イルカマンのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンのHP83
  await inputRemainHP(driver, me, '83');
  // どくげしょう発動
  await addEffect(driver, 2, op, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // キラフロルひんし→パオジアンに交代
  await changePokemon(driver, op, 'パオジアン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, me, 'ジェットパンチ', false);
  // パオジアンのHP45
  await inputRemainHP(driver, me, '45');
  // パオジアンのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パオジアンのテラスタル
  await inputTerastal(driver, op, 'こおり');
  // イルカマンのジェットパンチ
  await tapMove(driver, me, 'ジェットパンチ', false);
  // パオジアンのHP0
  await inputRemainHP(driver, me, '0');
  // パオジアンひんし→ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // イルカマンのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンひんし→リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', false);
  // 急所に命中
  await tapCritical(driver, op);
  // リーフィアのHP39
  await inputRemainHP(driver, op, '39');
  // リーフィアのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // ロトムの残りHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦2
Future<void> test2_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイルカマン戦2',
    ownPartyname: '2もこイルカマン',
    opponentName: '雪見櫻',
    pokemon1: 'コータス',
    pokemon2: 'ハバタクカミ',
    pokemon3: 'ラウドボーン',
    pokemon4: 'ラッキー',
    pokemon5: 'トドロクツキ',
    pokemon6: 'スコヴィラン',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイルカ/',
      ownPokemon2: 'もこニンフィア/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'コータス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // コータスのひでり
  await addEffect(driver, 0, op, 'ひでり');
  await driver.tap(find.text('OK'));
  // イルカマンのクイックターン
  await tapMove(driver, me, 'クイックターン', false);
  // コータスのHP90
  await inputRemainHP(driver, me, '90');
  // ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // コータスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // コータスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // ニンフィアのHP115
  await inputRemainHP(driver, op, '115');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィア->イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', true);
  // 相手コータス->ハバタクカミに交代
  await changePokemon(driver, op, 'ハバタクカミ', true);
  // こだいかっせい編集
  await tapEffect(driver, 'こだいかっせい');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのテラスタル
  await inputTerastal(driver, me, '');
  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // イルカマンのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンひんし→リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', false);
  // ハバタクカミのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // ハバタクカミのHP0
  await inputRemainHP(driver, me, '0');
  // ハバタクカミひんし→スコヴィランに交代
  await changePokemon(driver, op, 'スコヴィラン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // スコヴィランのHP90
  await inputRemainHP(driver, me, '90');
  // スコヴィランのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // リーフィアのHP0
  await inputRemainHP(driver, op, '0');
  // リーフィアひんし→ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // スコヴィランのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, '雪見櫻の勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦3
Future<void> test2_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイルカマン戦3',
    ownPartyname: '2もこイルカマン',
    opponentName: 'ズイ',
    pokemon1: 'ガブリアス',
    pokemon2: 'ドドゲザン',
    pokemon3: 'ギャラドス',
    pokemon4: 'ミミッキュ',
    pokemon5: 'テツノブジン',
    pokemon6: 'テツノツツミ',
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイルカ/',
      ownPokemon2: 'もこヘル/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // イルカマンのクイックターン
  await tapMove(driver, me, 'クイックターン', false);
  // コータスのHP90
  await inputRemainHP(driver, me, '90');
  // ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ガブリアスのさめはだ
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // 交換先のニンフィアにさめはだダメージが入っていないことを確認(ステロダメージのみ)
  await testHP(driver, me, '177/202');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // ニンフィアのHP86
  await inputRemainHP(driver, op, '86');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし→テツノツツミに交代
  await changePokemon(driver, op, 'テツノツツミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // テツノツツミのHP95
  await inputRemainHP(driver, me, '95');
  // テツノツツミのゆきげしき
  await tapMove(driver, op, 'ゆきげしき', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのフリーズドライ
  await tapMove(driver, op, 'フリーズドライ', true);
  // ニンフィアのHP37
  await inputRemainHP(driver, op, '37');
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのエレキフィールド
  await tapMove(driver, op, 'エレキフィールド', true);
  // クォークチャージ編集
  await tapEffect(driver, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // テツノツツミのHP20
  await inputRemainHP(driver, me, '20');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // テツノツツミのHP15
  await inputRemainHP(driver, me, '15');
  // テツノツツミのオーロラベール
  await tapMove(driver, op, 'オーロラベール', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのフリーズドライ
  await tapMove(driver, op, 'フリーズドライ', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし→イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', false);
  // イルカマンにさめはだダメージ＆ステロダメージが入っていること確認
  await testHP(driver, me, '157/207');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, me, 'ジェットパンチ', false);
  // テツノツツミのHP0
  await inputRemainHP(driver, me, '0');
  // テツノツツミひんし→テツノブジンに交代
  await changePokemon(driver, op, 'テツノブジン', false);
  // クォークチャージ編集
  await tapEffect(driver, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのテラスタル
  await inputTerastal(driver, me, '');
  // テツノブジンのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // イルカマンのHP99
  await inputRemainHP(driver, op, '99');
  // イルカマンのアクロバット
  await tapMove(driver, me, 'アクロバット', false);
  // テツノブジンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦4
Future<void> test2_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイルカマン戦4',
    ownPartyname: '2もこイルカマン',
    opponentName: 'ABCNOW',
    pokemon1: 'モロバレル',
    pokemon2: 'オーロンゲ',
    pokemon3: 'イルカマン',
    pokemon4: 'ミミッキュ',
    pokemon5: 'テツノドクガ',
    pokemon6: 'セグレイブ',
    sex1: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイルカ/',
      ownPokemon2: 'もこニンフィア/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'オーロンゲ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // オーロンゲのリフレクター
  await tapMove(driver, op, 'リフレクター', true);
  // イルカマンのクイックターン
  await tapMove(driver, me, 'クイックターン', false);
  // オーロンゲのHP90
  await inputRemainHP(driver, me, '90');
  // ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // オーロンゲのひかりのかべ
  await tapMove(driver, op, 'ひかりのかべ', true);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手オーロンゲ->テツノドクガに交代
  await changePokemon(driver, op, 'テツノドクガ', true);
  // クォークチャージでとくこうが高まる
  await addEffect(driver, 1, op, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノドクガのヘドロウェーブ
  await tapMove(driver, op, 'ヘドロウェーブ', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノドクガはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // イルカマンのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // テツノドクガのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンのHP155
  await inputRemainHP(driver, me, '155');
  // テツノドクガひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // イルカマンのクイックターン
  await tapMove(driver, me, 'クイックターン', false);
  // セグレイブのHP90
  await inputRemainHP(driver, me, '90');
  // ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ヘルガーのほうふく
  await tapMove(driver, me, 'ほうふく', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->オーロンゲに交代
  await changePokemon(driver, op, 'オーロンゲ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ヘルガーのテラスタル
  await inputTerastal(driver, me, '');
  // ヘルガーのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // オーロンゲのHP60
  await inputRemainHP(driver, me, '60');
  // オーロンゲのソウルクラッシュ
  await tapMove(driver, op, 'ソウルクラッシュ', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, me, 'ジェットパンチ', false);
  // オーロンゲのHP20
  await inputRemainHP(driver, me, '20');
  // オーロンゲのでんじは
  await tapMove(driver, op, 'でんじは', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // オーロンゲのソウルクラッシュ
  await tapMove(driver, op, 'ソウルクラッシュ', true);
  // イルカマンのHP98
  await inputRemainHP(driver, op, '98');
  // イルカマンはとくこうが下がった(デフォルトでオン)
  //await driver.tap(find.text('イルカマンはとくこうが下がった'));
  // イルカマンのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // オーロンゲのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンのHP138
  await inputRemainHP(driver, me, '138');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦1
Future<void> test3_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイッカネズミ戦1',
    ownPartyname: '3もこネズミ',
    opponentName: 'モルス',
    pokemon1: 'ウルガモス',
    pokemon2: 'テツノドクガ',
    pokemon3: 'チヲハウハネ',
    pokemon4: 'エクスレッグ',
    pokemon5: 'ハッサム',
    pokemon6: 'ワナイダー',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこネズミ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'チヲハウハネ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // チヲハウハネのであいがしら
  await tapMove(driver, op, 'であいがしら', true);
  // イッカネズミのHP17
  await inputRemainHP(driver, op, '17');
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 6回命中
  await setHitCount(driver, me, 6);
  // チヲハウハネのHP0
  await inputRemainHP(driver, me, '0');
  // チヲハウハネひんし->テツノドクガに交代
  await changePokemon(driver, op, 'テツノドクガ', false);
  // クォークチャージでとくこうが高まる
  await addEffect(driver, 2, op, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // 2回急所に命中
  await setHitCount(driver, me, 2);
  // テツノドクガのHP0
  await inputRemainHP(driver, me, '0');
  // テツノドクガひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);

  // 次のターンへボタンタップ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦2
Future<void> test3_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイッカネズミ戦2',
    ownPartyname: '3もこネズミ',
    opponentName: 'ユシア',
    pokemon1: 'イダイナキバ',
    pokemon2: 'ミミッキュ',
    pokemon3: 'グレンアルマ',
    pokemon4: 'トドロクツキ',
    pokemon5: 'ミミズズ',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこネズミ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ミミズズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);
  // ミミズズのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのテラスタル
  await inputTerastal(driver, me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // ミミズズのHP40
  await inputRemainHP(driver, me, '40');
  // ミミズズのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ミミズズのしっぽきり
  await tapMove(driver, op, 'しっぽきり', true);
  await tapMoveNext(driver, op);
  // ミミズズのHP15
  await inputRemainHP(driver, op, '15');
  // ミミズズ->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', false);
  // こだいかっせいですばやさが高まる
  await addEffect(driver, 4, op, 'こだいかっせい');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // トドロクツキのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 1回急所に命中
  await setCriticalCount(driver, me, 1);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // トドロクツキのHP0
  await inputRemainHP(driver, me, '0');
  // トドロクツキひんし->ミミズズに交代
  await changePokemon(driver, op, 'ミミズズ', false);

  // 次のターンへボタンタップ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦3
Future<void> test3_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイッカネズミ戦3',
    ownPartyname: '3もこネズミ',
    opponentName: 'DinerooGzz',
    pokemon1: 'ガブリアス',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'ルガルガン(たそがれのすがた)',
    pokemon4: 'コノヨザル',
    pokemon5: 'ギャラドス',
    pokemon6: 'ドドゲザン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこネズミ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ギャラドス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ギャラドスのいかく
  await addEffect(driver, 0, op, 'いかく');
  await driver.tap(find.text('OK'));
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);
  // ギャラドスのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのテラスタル
  await inputTerastal(driver, me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // 6回命中
  await setHitCount(driver, me, 6);
  // ギャラドス->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, me, 'かみつく', false);
  // コノヨザルのHP80
  await inputRemainHP(driver, me, '80');
  // コノヨザルのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // イッカネズミひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // イッカネズミを復活
  await changePokemon(driver, me, 'イッカネズミ', false);
  // コノヨザルのじだんだ
  await tapMove(driver, op, 'じだんだ', true);
  // パーモットのHP56
  await inputRemainHP(driver, op, '56');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // 急所に命中
  await tapCritical(driver, me);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // コノヨザル->ソウブレイズに交代
  await changePokemon(driver, op, 'ソウブレイズ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // ソウブレイズのHP95
  await inputRemainHP(driver, me, '95');
  // ソウブレイズのサイコカッター
  await tapMove(driver, op, 'サイコカッター', true);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモット->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, me, 'かみつく', false);
  // ソウブレイズのHP30
  await inputRemainHP(driver, me, '30');
  // ソウブレイズのニトロチャージ
  await tapMove(driver, op, 'ニトロチャージ', true);
  // イッカネズミのHP24
  await inputRemainHP(driver, op, '24');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, me, 'かみつく', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦4
Future<void> test3_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうイッカネズミ戦4',
    ownPartyname: '3もこネズミ',
    opponentName: 'セジュン',
    pokemon1: 'オーロンゲ',
    pokemon2: 'サーフゴー',
    pokemon3: 'ミミッキュ',
    pokemon4: 'カイリュー',
    pokemon5: 'ギャラドス',
    pokemon6: 'カバルドン',
    sex3: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこネズミ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'カバルドン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // カバルドンのすなおこし
  await addEffect(driver, 0, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // カバルドンのHP45
  await inputRemainHP(driver, me, '45');
  // カバルドンのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // カバルドンのあくび
  await tapMove(driver, op, 'あくび', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // カバルドンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カバルドンのHP0
  await inputRemainHP(driver, me, '0');
  // カバルドンひんし->サーフゴー
  await changePokemon(driver, op, 'サーフゴー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // マリルリのHP74
  await inputRemainHP(driver, op, '74');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP50
  await inputRemainHP(driver, me, '50');
  // サーフゴーのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ゴツゴツメット＋すなあらしダメージでマリルリのHP29
  await testHP(driver, me, '29/201');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのシャドーボール空打ち
  await tapMove(driver, op, 'シャドーボール', true);
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');
  // マリルリひんし->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);
  // 死に出しで出てきたイッカネズミはステルスロックのダメージのみ受けてHP123
  // (バグってゴツメダメージが入ることがあったので確認)
  await testHP(driver, me, '123/150');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', false);
  // イッカネズミのHP26
  await inputRemainHP(driver, op, '26');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, me, 'かみつく', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ミミッキュのHP80
  await inputRemainHP(driver, me, '80');
  // ミミッキュのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのHP75
  await inputRemainHP(driver, op, '75');
  // ミミッキュのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // イッカネズミひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのテラスタル
  await inputTerastal(driver, me, '');
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦1
Future<void> test4_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミミズズ戦1',
    ownPartyname: '4もこミミズ',
    opponentName: 'あまいなつ',
    pokemon1: 'ウェーニバル',
    pokemon2: 'イーユイ',
    pokemon3: 'ミミズズ',
    pokemon4: 'ドヒドイデ',
    pokemon5: 'トドロクツキ',
    pokemon6: 'デカヌチャン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこヘル/',
      ownPokemon3: 'もこリガメ/',
      opponentPokemon: 'ミミズズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // 相手のミミズズのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // こちらのミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapMoveNext(driver, me);
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // ミミズズ->カジリガメに交代
  await changePokemon(driver, me, 'カジリガメ', false);
  // ステルスロックダメージ
  await testExistEffect(driver, 'ステルスロック');
  await testHP(driver, me, '146/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミズズのじならし
  await tapMove(driver, op, 'じならし', true);
  // みがわりは壊れない
  await inputRemainHP(driver, op, '');
  // カジリガメのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのテラスタル
  await inputTerastal(driver, me, '');
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ミミズズのHP0
  await inputRemainHP(driver, me, '0');
  // ミミズズひんし->ドヒドイデに交代
  await changePokemon(driver, op, 'ドヒドイデ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデのトーチカ
  await tapMove(driver, op, 'トーチカ', true);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // トーチカで失敗、失敗のためいのちのたまダメージは受けない
  await inputRemainHP(driver, me, '');
  await testHP(driver, me, '110/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ドヒドイデのHP45
  await inputRemainHP(driver, me, '45');
  // ドヒドイデのくろいきり
  await tapMove(driver, op, 'くろいきり', true);
  // ドヒドイデのくろいヘドロ
  await addEffect(driver, 3, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // どくダメージ計算合ってるか確認
  await testHP(driver, me, '74/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデのトーチカ
  await tapMove(driver, op, 'トーチカ', false);
  // カジリガメのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // どくダメージ計算合ってるか確認
  await testHP(driver, me, '54/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ドヒドイデのHP0
  await inputRemainHP(driver, me, '0');
  //ドヒドイデひんし->デカヌチャン
  await changePokemon(driver, op, 'デカヌチャン', false);
  // どくダメージ計算合ってるか確認
  await testHP(driver, me, '18/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // デカヌチャンのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦2
Future<void> test4_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミミズズ戦2',
    ownPartyname: '4もこミミズ',
    opponentName: 'あああああ',
    pokemon1: 'マスカーニャ',
    pokemon2: 'バンギラス',
    pokemon3: 'キラフロル',
    pokemon4: 'ギャラドス',
    pokemon5: 'ロトム(ヒートロトム)',
    pokemon6: 'ミミッキュ',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこリガメ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'ギャラドス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ギャラドスのいかく
  await addEffect(driver, 0, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ギャラドスのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ミミズズのしっぽきり失敗
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミズズ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ギャラドスのでんじは
  await tapMove(driver, op, 'でんじは', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手ギャラドス->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // バンギラスのすなおこし
  await addEffect(driver, 1, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // バンギラスのHP90
  await inputRemainHP(driver, me, '90');
  // すなあらしダメージでHP161になっていることを確認
  await testHP(driver, me, '161/171');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダ->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', true);
  // バンギラスのかみくだく
  await tapMove(driver, op, 'かみくだく', true);
  // ミミズズのHP120
  await inputRemainHP(driver, op, '120');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // バンギラスのじしん
  await tapMove(driver, op, 'じしん', true);
  // ミミズズのどしょくが発動するのでダメージ変動なし
  await inputRemainHP(driver, op, '');
  // どしょくが発動していることを確認
  await testExistEffect(driver, 'どしょく');
  await testHP(driver, me, '164/177');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapMoveNext(driver, me);
  // ミミズズのHP75
  await inputRemainHP(driver, me, '75');
  // ミミズズ->カジリガメに交代
  await changePokemon(driver, me, 'カジリガメ', false);
  // カジリガメにすなあらしダメージが入らないことを確認
  await testHP(driver, me, '166/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // バンギラスのじしん
  await tapMove(driver, op, 'じしん', false);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // カジリガメは無傷
  await inputRemainHP(driver, op, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // バンギラスのHP0
  await inputRemainHP(driver, me, '0');
  // バンギラスひんし->ギャラドス
  await changePokemon(driver, op, 'ギャラドス', false);
  // すなあらしが終了するか確認
  await testExistEffect(driver, 'すなあらし終了');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ギャラドス->ヒートロトムに交代
  await changePokemon(driver, op, 'ロトム(ヒートロトム)', true);
  // カジリガメのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ロトムのHP10
  await inputRemainHP(driver, me, '10');
  // ロトムのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('10');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ひんしロトム->ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', false);
  // カジリガメのHP確認
  await testHP(driver, me, '118/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, me, 2);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ギャラドスのHP40
  await inputRemainHP(driver, me, '40');
  // ギャラドスのたきのぼり
  await tapMove(driver, op, 'たきのぼり', true);
  // カジリガメのHP0
  await inputRemainHP(driver, op, '0');
  // ひんしカジリガメ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ギャラドスのこおりのキバ
  await tapMove(driver, op, 'こおりのキバ', true);
  // ボーマンダのHP107
  await inputRemainHP(driver, op, '107');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // ギャラドスのゴツゴツメット
  await addEffect(driver, 3, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦3
Future<void> test4_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミミズズ戦3',
    ownPartyname: '4もこミミズ',
    opponentName: 'るちあ',
    pokemon1: 'ミミッキュ',
    pokemon2: 'デカヌチャン',
    pokemon3: 'ハッサム',
    pokemon4: 'カイリュー',
    pokemon5: 'ビビヨン',
    pokemon6: 'イルカマン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこリガメ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'デカヌチャン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // デカヌチャンのかたやぶり
  await addEffect(driver, 0, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // デカヌチャンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapMoveNext(driver, me);
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // ミミズズ->カジリガメに交代
  await changePokemon(driver, me, 'カジリガメ', false);
  // カジリガメにステロダメージが入っていることを確認
  await testHP(driver, me, '146/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // デカヌチャンのデカハンマー
  await tapMove(driver, op, 'デカハンマー', true);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // カジリガメは無傷
  await inputRemainHP(driver, op, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦4
Future<void> test4_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミミズズ戦4',
    ownPartyname: '4もこミミズ2',
    opponentName: 'りる',
    pokemon1: 'カイリュー',
    pokemon2: 'イルカマン',
    pokemon3: 'ミミッキュ',
    pokemon4: 'ウインディ',
    pokemon5: 'チオンジェン',
    pokemon6: 'パオジアン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこルリ2/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イルカマンのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // ミミズズのHP103
  await inputRemainHP(driver, op, '103');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapMoveNext(driver, me);
  // ミミズズのHP14
  await inputRemainHP(driver, me, '14');
  // マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマン->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', true);
  // ウインディのいかく
  await addEffect(driver, 1, op, 'いかく');
  await driver.tap(find.text('OK'));
  // いかくの効果がないことの確認
  await testRank(driver, me, 'A', 'Zero0');
  // マリルリのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // マリルリのHPが101であることを確認
  await testHP(driver, me, '101/201');
  await testRank(driver, me, 'A', 'Up5');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ウインディのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // マリルリは無傷
  await inputRemainHP(driver, op, '');
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ウインディのHP0
  await inputRemainHP(driver, me, '0');
  // ひんしウインディ->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カイリューのでんきテラスタル
  await inputTerastal(driver, op, 'でんき');
  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // マリルリのHP11
  await inputRemainHP(driver, op, '11');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // ひんしカイリュー->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP99
  await inputRemainHP(driver, op, '99');
  // ひんしマリルリ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // イルカマンのHP75
  await inputRemainHP(driver, op, '75');
  // ヘルガーのきあいのタスキ
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ヘルガーのほうふく
  await tapMove(driver, me, 'ほうふく', false);
  // イルカマンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// グレンアルマ戦1
Future<void> test5_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうグレンアルマ戦1',
    ownPartyname: '5もこアルマ',
    opponentName: 'ラン',
    pokemon1: 'イッカネズミ',
    pokemon2: 'ハラバリー',
    pokemon3: 'マスカーニャ',
    pokemon4: 'ブロロローム',
    pokemon5: 'イルカマン',
    pokemon6: 'キョジオーン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアルマ/',
      ownPokemon2: 'もこネズミ/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのくだけるよろいが発動しているか確認
  await testExistEffect(driver, 'くだけるよろい');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ハラバリーのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 不発に終わる
  // TODO: 外れたことにするが、本当は成否のボタンをつけた方がいいかも？
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');
  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // みちづれ状態であることを確認する
  bool test = await isExistAilment(driver, me, 'みちづれ');
  expect(test, true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのテラスタル
  await inputTerastal(driver, me, '');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // ハラバリーのHP0
  await inputRemainHP(driver, me, '0');
  // みちづれ状態が解除されていることを確認する
  test = await isExistAilment(driver, me, 'みちづれ');
  expect(test, false);
  // ひんしハラバリー->イッカネズミに交代
  await changePokemon(driver, op, 'イッカネズミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // イッカネズミのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// グレンアルマ戦2
Future<void> test5_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうグレンアルマ戦2',
    ownPartyname: '5もこアルマ',
    opponentName: 'ダイチ',
    pokemon1: 'ドヒドイデ',
    pokemon2: 'キノガッサ',
    pokemon3: 'テツノツツミ',
    pokemon4: 'ミミッキュ',
    pokemon5: 'トドロクツキ',
    pokemon6: 'キョジオーン',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこネズミ/',
      ownPokemon2: 'もこアルマ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'キョジオーン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イッカネズミタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  // キョジオーンのHP65
  await inputRemainHP(driver, me, '65');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // イッカネズミのHP116
  await inputRemainHP(driver, op, '116');
  // イッカネズミのHPが98になっていることを確認する
  await testHP(driver, me, '98/150');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);
  // キョジオーンのものまねハーブ発動
  await addEffect(driver, 1, op, 'ものまねハーブ');
  // こうげきとすばやさが1段階上がる
  await driver.tap(find.byValueKey('ItemEffectRankAMenu'));
  //var designatedWidget = find.descendant(
  //    of: find.byValueKey('ItemEffectRankAMenu'), matching: find.text('+1'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.byValueKey('ItemEffectRankSMenu'));
  //designatedWidget = find.descendant(
  //    of: find.byValueKey('ItemEffectRankSMenu'), matching: find.text('+1'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.text('OK'));
  // キョジオーンのロックブラスト
  await tapMove(driver, op, 'ロックブラスト', true);
  // 2回命中
  await setHitCount(driver, op, 2);
  // イッカネズミのHP28
  await inputRemainHP(driver, op, '28');
  // しおづけによってイッカネズミのHPが10になることを確認
  await testHP(driver, me, '10/150');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // ひんしキョジオーン->ドヒドイデに交代
  await changePokemon(driver, op, 'ドヒドイデ', false);
  // ひんしイッカネズミ->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // ドヒドイデのHP45
  await inputRemainHP(driver, me, '45');
  // ドヒドイデのどくどく
  await tapMove(driver, op, 'どくどく', true);
  // ドヒドイデのくろいヘドロ
  await addEffect(driver, 2, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデ->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', true);
  // トドロクツキのこだいかっせい
  await addEffect(driver, 1, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // 効果がない
  await inputRemainHP(driver, me, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのかみくだく
  await tapMove(driver, op, 'かみくだく', true);
  // 急所に命中
  await tapCritical(driver, op);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // ひんしグレンアルマ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // トドロクツキのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // ボーマンダのHP45
  await inputRemainHP(driver, op, '45');
  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // トドロクツキのHP0
  await inputRemainHP(driver, me, '0');
  // ひんしトドロクツキ->ドヒドイデに交代
  await changePokemon(driver, op, 'ドヒドイデ', false);
  // ドヒドイデはさいせいりょくだったためHP回復している
  await editPokemonState(driver, 'ドヒドイデ/ダイチ', '80', 'さいせいりょく', null);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデのトーチカ
  await tapMove(driver, op, 'トーチカ', true);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // トーチカで失敗
  await inputRemainHP(driver, me, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ドヒドイデのHP5
  await inputRemainHP(driver, me, '5');
  // ドヒドイデのひやみず
  await tapMove(driver, op, 'ひやみず', true);
  // ボーマンダのHP13
  await inputRemainHP(driver, op, '13');
  // 相手の勝利
  await testExistEffect(driver, 'ダイチの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// グレンアルマ戦3
Future<void> test5_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうグレンアルマ戦3',
    ownPartyname: '5もこアルマ',
    opponentName: 'ぐりこ',
    pokemon1: 'ウェーニバル',
    pokemon2: 'ドラパルト',
    pokemon3: 'ソウブレイズ',
    pokemon4: 'カイリュー',
    pokemon5: 'チオンジェン',
    pokemon6: 'ディンルー',
    sex2: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアルマ/',
      ownPokemon2: 'もこフィア/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'チオンジェン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのテラスタル
  await inputTerastal(driver, me, '');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // チオンジェンのHP0
  await inputRemainHP(driver, me, '0');
  // チオンジェンひんし->ディンルーに交代
  await changePokemon(driver, op, 'ディンルー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ディンルーのHP50
  await inputRemainHP(driver, me, '50');
  // ディンルーのじしん
  await tapMove(driver, op, 'じしん', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // ディンルーのHP0
  await inputRemainHP(driver, me, '0');
  // ディンルーひんし->ソウブレイズに交代
  await changePokemon(driver, op, 'ソウブレイズ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ソウブレイズのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ソウブレイズのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', true);
  // ニンフィアのHP98
  await inputRemainHP(driver, op, '98');
  // ソウブレイズの回復なし
  await inputRemainHP(driver, op, '');
  // ニンフィアのあまえる
  await tapMove(driver, me, 'あまえる', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ソウブレイズのクリアスモッグ
  await tapMove(driver, op, 'クリアスモッグ', true);
  // ニンフィアのHP76
  await inputRemainHP(driver, op, '76');
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// グレンアルマ戦4
Future<void> test5_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうグレンアルマ戦4',
    ownPartyname: '5もこアルマ',
    opponentName: 'レバブル',
    pokemon1: 'サーフゴー',
    pokemon2: 'セグレイブ',
    pokemon3: 'グレンアルマ',
    pokemon4: 'カイリュー',
    pokemon5: 'マスカーニャ',
    pokemon6: 'マリルリ',
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアルマ/',
      ownPokemon2: 'もこフィア/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // サーフゴー->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // グレンアルマのテラスタル
  await inputTerastal(driver, me, '');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // マリルリのHP75
  await inputRemainHP(driver, me, '75');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマ->リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', true);
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // リーフィアのHP100
  await inputRemainHP(driver, op, '100');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィア->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // マリルリ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サーフゴー->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // マリルリのHP30
  await inputRemainHP(driver, me, '30');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, op, 'アクアジェット', true);
  // グレンアルマのHP74
  await inputRemainHP(driver, op, '74');
  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // カイリューのHP80
  await inputRemainHP(driver, me, '80');
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // ニンフィアのHP91
  await inputRemainHP(driver, op, '91');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP10
  await inputRemainHP(driver, me, '10');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // 外れる
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');
  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // サーフゴーのHP80
  await inputRemainHP(driver, me, '80');
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // リーフィアのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'レバブルの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}
