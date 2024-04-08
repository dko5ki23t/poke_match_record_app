import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// タイカイデン戦1
Future<void> test41_1(
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
    battleName: 'もこうタイカイデン戦',
    ownPartyname: '41もこカイデン',
    opponentName: 'ガクト',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'アーマーガア',
    pokemon4: 'ガブリアス',
    pokemon5: 'オリーヴァ',
    pokemon6: 'ニンフィア',
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイデン/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンのテラスタル
  await inputTerastal(driver, me, '');
  // タイカイデンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->オリーヴァに交代
  await changePokemon(driver, op, 'オリーヴァ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // タイカイデン->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // オリーヴァのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // オリーヴァのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ヤドキングのHP172
  await inputRemainHP(driver, op, '172');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのギガドレイン
  await tapMove(driver, op, 'ギガドレイン', true);
  // ヤドキングのHP41
  await inputRemainHP(driver, op, '41');
  // オリーヴァのHP100
  await inputRemainHP(driver, op, '');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // オリーヴァのHP45
  await inputRemainHP(driver, me, '45');
  // オリーヴァのこぼれダネ
  await addEffect(driver, 1, op, 'こぼれダネ');
  await driver.tap(find.text('OK'));
  // オリーヴァのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // ハルクジラのHP70
  await inputRemainHP(driver, op, '70');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // オリーヴァのプレッシャー
  await addEffect(driver, 1, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // アーマーガアのHP100
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラ->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ヤドキングのHP90
  await inputRemainHP(driver, op, '90');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // タイカイデンに交代
  await changePokemon(driver, me, 'タイカイデン', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->オリーヴァに交代
  await changePokemon(driver, op, 'オリーヴァ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// タイカイデン戦2
Future<void> test41_2(
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
    battleName: 'もこうタイカイデン戦2',
    ownPartyname: '41もこカイデン2',
    opponentName: 'バイオレット',
    pokemon1: 'サーフゴー',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'ミミッキュ',
    pokemon4: 'イルカマン',
    pokemon5: 'カイリュー',
    pokemon6: 'ハラバリー',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイデン/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'ハラバリー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // ハラバリーのHP90
  await inputRemainHP(driver, me, '90');
  // ハラバリーのでんきにかえる
  await addEffect(driver, 1, op, 'でんきにかえる');
  await driver.tap(find.text('OK'));
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', true);
  // タイカイデンのHP122
  await inputRemainHP(driver, op, '122');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // ハラバリーのHP80
  await inputRemainHP(driver, me, '80');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, op, 'パラボラチャージ', true);
  // タイカイデンのHP122
  await inputRemainHP(driver, op, '');
  // ハラバリーのHP80
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // タイカイデン->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // ヤドキングのHP185
  await inputRemainHP(driver, op, '185');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ハラバリーのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // ヤドキングのHP194
  await inputRemainHP(driver, op, '194');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // TODO はらだいこ後の体力がおかしい
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // ハルクジラのHP54
  await inputRemainHP(driver, op, '54');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// TODO: ターン1のボルトチェンジ後のシャドーボールのダメージがエクスレッグに適用されない
// TODO: ゆきのターン経過計算がおかしい
/// タイカイデン戦3
Future<void> test41_3(
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
    battleName: 'もこうタイカイデン戦3',
    ownPartyname: '41もこカイデン2',
    opponentName: '3104',
    pokemon1: 'ミミッキュ',
    pokemon2: 'マリルリ',
    pokemon3: 'サーフゴー',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'カバルドン',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイデン/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこレッグ/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // サーフゴーのHP55
  await inputRemainHP(driver, me, '55');
  // エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // タイカイデンのHP125
  await inputRemainHP(driver, op, '125');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // サーフゴーのHP40
  await inputRemainHP(driver, me, '40');
  // タイカイデンに交代
  await changePokemon(driver, me, 'タイカイデン', false);
  // サーフゴーのゴツゴツメット
  await addEffect(driver, 1, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // サーフゴーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP90
  await inputRemainHP(driver, op, '90');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // サーフゴーのHP25
  await inputRemainHP(driver, me, '25');
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // タイカイデンのHP79
  await inputRemainHP(driver, op, '79');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サーフゴー->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // タイカイデン->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ヤドキングのHP130
  await inputRemainHP(driver, op, '130');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // タイカイデンに交代
  await changePokemon(driver, me, 'タイカイデン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンのテラスタル
  await inputTerastal(driver, me, '');
  // マリルリのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // タイカイデンの１０まんボルト
  await tapMove(driver, me, '１０まんボルト', false);
  // マリルリのHP55
  await inputRemainHP(driver, me, '55');
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // タイカイデンのHP0
  await inputRemainHP(driver, op, '0');
  // タイカイデンひんし->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ヤドキングのなみのり
  await tapMove(driver, me, 'なみのり', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // ヤドキングのHP88
  await inputRemainHP(driver, op, '88');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグ->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // ヤドキングのHP81
  await inputRemainHP(driver, op, '81');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// タイカイデン戦4
Future<void> test41_4(
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
    battleName: 'もこうタイカイデン戦4',
    ownPartyname: '41もこカイデン3',
    opponentName: 'KDH',
    pokemon1: 'ヌメルゴン',
    pokemon2: 'アーマーガア',
    pokemon3: 'ガブリアス',
    pokemon4: 'ロトム(ヒートロトム)',
    pokemon5: 'モロバレル',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイデン/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // タイカイデンのテラスタル
  await inputTerastal(driver, me, '');
  // タイカイデンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ヌメルゴンに交代
  await changePokemon(driver, op, 'ヌメルゴン', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // タイカイデン->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ヌメルゴンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ヌメルゴンのアシッドボム
  await tapMove(driver, op, 'アシッドボム', true);
  // ヤドキングのHP179
  await inputRemainHP(driver, op, '179');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ヌメルゴンのヘドロばくだん
  await tapMove(driver, op, 'ヘドロばくだん', true);
  // ヤドキングのHP91
  await inputRemainHP(driver, op, '91');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // ヌメルゴン->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // アーマーガアのHP30
  await inputRemainHP(driver, me, '30');
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ハルクジラのHP106
  await inputRemainHP(driver, op, '106');
  // アーマーガアのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->ヌメルゴンに交代
  await changePokemon(driver, op, 'ヌメルゴン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // ヌメルゴンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ギャラドス戦1
Future<void> test42_1(
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
    battleName: 'もこうギャラドス戦1',
    ownPartyname: '42もこギャラドス',
    opponentName: 'ベータ',
    pokemon1: 'ケンタロス(パルデアのすがた(かくとう・ほのお))',
    pokemon2: 'マスカーニャ',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'キラフロル',
    pokemon5: 'グレンアルマ',
    pokemon6: 'ヘイラッシャ',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこギャラドス/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'オモダカさん/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 1, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('むし'));
  await driver.tap(find.text('OK'));
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ギャラドスのHP155
  await inputRemainHP(driver, op, '155');
  // ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのテラスタル
  await inputTerastal(driver, me, '');
  // ロトムのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, op);
  // ギャラドスのHP155
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ロトム->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // 急所に命中
  await tapCritical(driver, me);
  // マスカーニャひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, me, 'たきのぼり', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ケンタロスに交代
  await changePokemon(driver, op, 'ケンタロス(パルデアのすがた(かくとう・ほのお))', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ケンタロスのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ギャラドス戦2
Future<void> test42_2(
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
    battleName: 'もこうギャラドス戦2',
    ownPartyname: '42もこギャラドス',
    opponentName: 'とむ',
    pokemon1: 'サザンドラ',
    pokemon2: 'ウルガモス',
    pokemon3: 'ガブリアス',
    pokemon4: 'ジバコイル',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ドヒドイデ',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこギャラドス/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'オモダカさん/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのテラスタル
  await inputTerastal(driver, me, '');
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ジバコイルのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, op);
  // ギャラドスのHP191
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ジバコイルひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ガブリアスのHP2
  await inputRemainHP(driver, me, '2');
  // ガブリアスのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // ギャラドスのHP41
  await inputRemainHP(driver, op, '41');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ドヒドイデに交代
  await changePokemon(driver, op, 'ドヒドイデ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドヒドイデのテラスタル
  await inputTerastal(driver, op, 'あく');
  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドヒドイデのHP30
  await inputRemainHP(driver, me, '30');
  // ドヒドイデのくろいきり
  await tapMove(driver, op, 'くろいきり', true);
  // ドヒドイデのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドヒドイデのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// TODO: ちょうはつ終了のタイミングがおかしい
/// ギャラドス戦3
Future<void> test42_3(
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
    battleName: 'もこうギャラドス戦3',
    ownPartyname: '42もこギャラドス',
    opponentName: 'たびら',
    pokemon1: 'ミミッキュ',
    pokemon2: 'アーマーガア',
    pokemon3: 'ウルガモス',
    pokemon4: 'カバルドン',
    pokemon5: 'マスカーニャ',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこギャラドス/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'オモダカさん/',
      opponentPokemon: 'カバルドン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カバルドンのすなおこし
  await addEffect(driver, 1, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // カバルドンのメンタルハーブ
  await addEffect(driver, 3, op, 'メンタルハーブ');
  await driver.tap(find.text('OK'));
  // カバルドンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // カバルドンのあくび
  await tapMove(driver, op, 'あくび', true);
  await tapSuccess(driver, op);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // カバルドン->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのテラスタル
  await inputTerastal(driver, me, '');
  // ドラパルトの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // 外れる
  await tapHit(driver, op);
  // ギャラドスのHP158
  await inputRemainHP(driver, op, '');
  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  await tapSuccess(driver, op);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ギャラドス戦4
Future<void> test42_4(
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
    battleName: 'もこうギャラドス戦4',
    ownPartyname: '42もこギャラドス',
    opponentName: 'ほしみち',
    pokemon1: 'ブラッキー',
    pokemon2: 'セグレイブ',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'ラウドボーン',
    pokemon5: 'ガブリアス',
    pokemon6: 'ミミッキュ',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこギャラドス/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'オモダカさん/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ラウドボーンのあくび
  await tapMove(driver, op, 'あくび', true);
  await tapSuccess(driver, op);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, me, 'たきのぼり', false);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // ラウドボーンのゴツゴツメット
  await addEffect(driver, 1, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // ギャラドスのHP136
  await inputRemainHP(driver, op, '136');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ギャラドスのHP100
  await inputRemainHP(driver, op, '100');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ギャラドスのHP49
  await inputRemainHP(driver, op, '49');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, me, 'たきのぼり', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // ギャラドスのHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ギャラドスひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // 外れる
  await tapHit(driver, me);
  // ガブリアスのHP100
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // ギャラドスを復活
  await changePokemon(driver, me, 'ギャラドス', false);
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // パーモットのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ガブリアスのHP70
  await inputRemainHP(driver, me, '70');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // パーモットひんし->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのテラスタル
  await inputTerastal(driver, me, '');
  // キラフロルのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // ガブリアスのHP10
  await inputRemainHP(driver, me, '10');
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', false);
  // 外れる
  await tapHit(driver, op);
  // キラフロルのHP140
  await inputRemainHP(driver, op, '');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // キラフロル->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', true);
  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // ギャラドスのHP0
  await inputRemainHP(driver, op, '0');
  // ギャラドスひんし->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのパワージェム
  await tapMove(driver, me, 'パワージェム', false);
  // ミミッキュのHP80
  await inputRemainHP(driver, me, '');
  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', false);
  // キラフロルのHP28
  await inputRemainHP(driver, op, '28');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', false);
  // 急所に命中
  await tapCritical(driver, op);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ほしみちの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ヘラクロス戦1
Future<void> test43_1(
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
    battleName: 'もこうヘラクロス戦1',
    ownPartyname: '43もこクロス2',
    opponentName: 'あつき',
    pokemon1: 'カイリュー',
    pokemon2: 'ドラパルト',
    pokemon3: 'マリルリ',
    pokemon4: 'ラウドボーン',
    pokemon5: 'ガブリアス',
    pokemon6: 'ロトム(カットロトム)',
    sex1: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ2/',
      ownPokemon2: 'もこクロス/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'ロトム(カットロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのさいみんじゅつ
  await tapMove(driver, me, 'さいみんじゅつ', false);
  await tapSuccess(driver, me);
  // ロトムのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // クエスパトラのHP0
  await inputRemainHP(driver, op, '0');
  // クエスパトラひんし->ヘラクロスに交代
  await changePokemon(driver, me, 'ヘラクロス', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトム->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // ヘラクロスのミサイルばり
  await tapMove(driver, me, 'ミサイルばり', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // 4回命中
  await setHitCount(driver, me, 4);
  // マリルリのHP70
  await inputRemainHP(driver, me, '70');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // ヘラクロスのHP18
  await inputRemainHP(driver, op, '18');
  // ドラパルトのいのちのたま
  await addEffect(driver, 1, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // ドラパルトのHP25
  await inputRemainHP(driver, me, '25');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ヘラクロスのHP0
  await inputRemainHP(driver, op, '0');
  // ヘラクロスひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ロトムに交代
  await changePokemon(driver, op, 'ロトム(カットロトム)', true);
  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // ロトムのHP52
  await inputRemainHP(driver, me, '52');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // グレンアルマのHP24
  await inputRemainHP(driver, op, '24');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// TODO: ねがいごとが消費されない
// TODO: まもるされたときにまひすると挙動がおかしい
/// ヘラクロス戦2
Future<void> test43_2(
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
    battleName: 'もこうヘラクロス戦2',
    ownPartyname: '43もこクロス2',
    opponentName: 'ひっしー',
    pokemon1: 'ブラッキー',
    pokemon2: 'ドオー',
    pokemon3: 'イルカマン',
    pokemon4: 'サザンドラ',
    pokemon5: 'ミミッキュ',
    pokemon6: 'コノヨザル',
    sex2: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ2/',
      ownPokemon2: 'もこクロス/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'ミミッキュ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // クエスパトラのフェザーダンス
  await tapMove(driver, me, 'フェザーダンス', false);
  // ミミッキュのものまねハーブ
  await addEffect(driver, 3, op, 'ものまねハーブ');
  // すばやさが1段階上がる
  await driver.tap(find.byValueKey('ItemEffectRankSMenu'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラ->ヘラクロスに交代
  await changePokemon(driver, me, 'ヘラクロス', true);
  // ミミッキュのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュののろい
  await tapMove(driver, op, 'のろい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミッキュのHP50
  await inputRemainHP(driver, op, '50');
  // ヘラクロスのタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // ミミッキュのHP30
  await inputRemainHP(driver, me, '30');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ヘラクロスのHP13
  await inputRemainHP(driver, op, '13');
  // ヘラクロスのミサイルばり
  await tapMove(driver, me, 'ミサイルばり', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // ミミッキュのHP2
  await inputRemainHP(driver, me, '2');
  // ヘラクロスひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // サザンドラのHP90
  await inputRemainHP(driver, me, '90');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // マリルリのHP116
  await inputRemainHP(driver, op, '116');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サザンドラのHP30
  await inputRemainHP(driver, me, '30');
  // サザンドラはぼうぎょが下がった
  await driver.tap(find.text('サザンドラはぼうぎょが下がった'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ブラッキーに交代
  await changePokemon(driver, op, 'ブラッキー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのでんじは
  await tapMove(driver, op, 'でんじは', true);
  await tapSuccess(driver, op);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ブラッキーのHP30
  await inputRemainHP(driver, me, '30');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのでんじは
  await tapMove(driver, op, 'でんじは', false);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ブラッキーのHP2
  await inputRemainHP(driver, me, '2');
  // ブラッキーはぼうぎょが下がった
  await driver.tap(find.text('ブラッキーはぼうぎょが下がった'));
  // ブラッキーのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのまもる
  await tapMove(driver, op, 'まもる', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ブラッキーのHP8
  await inputRemainHP(driver, me, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ブラッキーのねがいごと
  await tapMove(driver, op, 'ねがいごと', true);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのまもる
  await tapMove(driver, op, 'まもる', false);
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // マリルリのHP84
  await inputRemainHP(driver, op, '84');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのまもる
  await tapMove(driver, op, 'まもる', false);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ブラッキーのHP32
  await inputRemainHP(driver, me, '');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのイカサマ
  await tapMove(driver, op, 'イカサマ', false);
  // マリルリのHP51
  await inputRemainHP(driver, op, '51');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ブラッキーのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // マリルリのHP18
  await inputRemainHP(driver, op, '18');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ブラッキーのHP0
  await inputRemainHP(driver, me, '0');
  // ブラッキーひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ヘラクロス戦3
Future<void> test43_3(
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
    battleName: 'もこうヘラクロス戦3',
    ownPartyname: '43もこクロス2',
    opponentName: 'ぶりを',
    pokemon1: 'サーフゴー',
    pokemon2: 'ヘイラッシャ',
    pokemon3: 'セグレイブ',
    pokemon4: 'モロバレル',
    pokemon5: 'オーロンゲ',
    pokemon6: 'ウルガモス',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ2/',
      ownPokemon2: 'もこクロス2/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'オーロンゲ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのさいみんじゅつ
  await tapMove(driver, me, 'さいみんじゅつ', false);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲ->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', true);
  // クエスパトラのバトンタッチ
  await tapMove(driver, me, 'バトンタッチ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ヘラクロスに交代
  await changePokemon(driver, me, 'ヘラクロス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->オーロンゲに交代
  await changePokemon(driver, op, 'オーロンゲ', true);
  // ヘラクロスのテラスタル
  await inputTerastal(driver, me, '');
  // ヘラクロスのミサイルばり
  await tapMove(driver, me, 'ミサイルばり', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // 2回急所
  await setCriticalCount(driver, me, 2);
  // 4回命中
  await setHitCount(driver, me, 4);
  // オーロンゲのHP30
  await inputRemainHP(driver, me, '30');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ヘラクロスのかわらわり
  await tapMove(driver, me, 'かわらわり', false);
  // オーロンゲのHP0
  await inputRemainHP(driver, me, '0');
  // オーロンゲひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ヘラクロスのミサイルばり
  await tapMove(driver, me, 'ミサイルばり', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // ウルガモスのHP60
  await inputRemainHP(driver, me, '60');
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // ヘラクロスのHP16
  await inputRemainHP(driver, op, '16');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // 3回命中
  await setHitCount(driver, me, 3);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ヘラクロスのHP0
  await inputRemainHP(driver, op, '0');
  // ヘラクロスひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのフェザーダンス
  await tapMove(driver, me, 'フェザーダンス', false);
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 4回命中
  await setHitCount(driver, op, 4);
  // クエスパトラのHP107
  await inputRemainHP(driver, op, '107');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのフェザーダンス
  await tapMove(driver, me, 'フェザーダンス', false);
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // クエスパトラのものまねハーブ
  await addEffect(driver, 3, me, 'ものまねハーブ');
  // こうげきとすばやさが1段階上がる
  await driver.tap(find.byValueKey('ItemEffectRankAMenu'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.byValueKey('ItemEffectRankSMenu'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ヘラクロス戦4
Future<void> test43_4(
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
    battleName: 'もこうヘラクロス戦4',
    ownPartyname: '43もこクロス2',
    opponentName: 'pulpul',
    pokemon1: 'ドラパルト',
    pokemon2: 'サザンドラ',
    pokemon3: 'マリルリ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ブラッキー',
    sex1: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ2/',
      ownPokemon2: 'もこクロス2/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'マリルリ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのフェザーダンス
  await tapMove(driver, me, 'フェザーダンス', false);
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // クエスパトラのHP108
  await inputRemainHP(driver, op, '108');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // クエスパトラのさいみんじゅつ
  await tapMove(driver, me, 'さいみんじゅつ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのバトンタッチ
  await tapMove(driver, me, 'バトンタッチ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ヘラクロスに交代
  await changePokemon(driver, me, 'ヘラクロス', false);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // ヘラクロスのタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // ラウドボーンのHP95
  await inputRemainHP(driver, me, '95');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // ラウドボーンのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // 3回命中
  await setHitCount(driver, me, 3);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ヘラクロスのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // マリルリのHP40
  await inputRemainHP(driver, me, '40');
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // ヘラクロスのHP0
  await inputRemainHP(driver, op, '0');
  // ヘラクロスひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのサイコフィールド
  await tapMove(driver, me, 'サイコフィールド', false);
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 3, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのテラスタル
  await inputTerastal(driver, me, '');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // マリルリのHP1
  await inputRemainHP(driver, me, '1');
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのさいみんじゅつ
  await tapMove(driver, me, 'さいみんじゅつ', false);
  await tapSuccess(driver, me);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのさいみんじゅつ
  await tapMove(driver, me, 'さいみんじゅつ', false);
  await tapSuccess(driver, me);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // クエスパトラのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'pulpulの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦1
Future<void> test44_1(
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
    battleName: 'もこうカイリュー戦1',
    ownPartyname: '44もこカイリュー',
    opponentName: 'こた',
    pokemon1: 'ガブリアス',
    pokemon2: 'サーフゴー',
    pokemon3: 'ドドゲザン',
    pokemon4: 'キョジオーン',
    pokemon5: 'カイリュー',
    pokemon6: 'ヘイラッシャ',
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイリュー/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこカーニャ/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのふうせん
  await addEffect(driver, 0, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // サーフゴー->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', true);
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // キョジオーンのHP30
  await inputRemainHP(driver, me, '30');
  // キョジオーンのオボンのみ
  await addEffect(driver, 1, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // カイリューのHP165
  await inputRemainHP(driver, op, '165');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // キョジオーン->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サーフゴー->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP85
  await inputRemainHP(driver, me, '85');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // グレンアルマのHP24
  await inputRemainHP(driver, op, '24');
  // グレンアルマのサイコフィールド
  await tapMove(driver, me, 'サイコフィールド', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', true);
  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// TODO:アンコール解けるタイミングがおかしい
/// カイリュー戦2
Future<void> test44_2(
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
    battleName: 'もこうカイリュー戦2',
    ownPartyname: '44もこカイリュー',
    opponentName: 'チャロバー',
    pokemon1: 'マスカーニャ',
    pokemon2: 'コノヨザル',
    pokemon3: 'ウルガモス',
    pokemon4: 'ニンフィア',
    pokemon5: 'トリトドン',
    pokemon6: 'カイリュー',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイリュー/',
      ownPokemon2: 'オモダカさん/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'ニンフィア');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // キラフロルのHP103
  await inputRemainHP(driver, op, '103');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ニンフィアのHP45
  await inputRemainHP(driver, me, '45');
  // ニンフィアのサイコショック
  await tapMove(driver, op, 'サイコショック', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリューのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ニンフィアのサイコショック
  await tapMove(driver, op, 'サイコショック', false);
  // カイリューのHP172
  await inputRemainHP(driver, op, '172');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->トリトドンに交代
  await changePokemon(driver, op, 'トリトドン', true);
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // トリトドンのHP30
  await inputRemainHP(driver, me, '30');
  // トリトドンのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // トリトドンのあくび
  await tapMove(driver, op, 'あくび', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // トリトドンのHP0
  await inputRemainHP(driver, me, '0');
  // トリトドンひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', true);
  // カイリューのHP164
  await inputRemainHP(driver, op, '164');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // カイリューのHP115
  await inputRemainHP(driver, op, '115');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // グレンアルマのHP46
  await inputRemainHP(driver, op, '46');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // コノヨザル->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', true);
  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // ニンフィアのHP30
  await inputRemainHP(driver, me, '30');
  // ニンフィアのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ニンフィアひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  await tapSuccess(driver, me);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', false);
  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // コノヨザルのHP45
  await inputRemainHP(driver, me, '45');
  // コノヨザルのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', true);
  // カイリューのHP123
  await inputRemainHP(driver, op, '123');
  // コノヨザルのHP70
  await inputRemainHP(driver, op, '70');
  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // コノヨザルのHP15
  await inputRemainHP(driver, me, '15');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // カイリューのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'チャロバーの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦3
Future<void> test44_3(
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
    battleName: 'もこうカイリュー戦3',
    ownPartyname: '44もこカイリュー',
    opponentName: 'JOKER',
    pokemon1: 'オノノクス',
    pokemon2: 'マリルリ',
    pokemon3: 'グレンアルマ',
    pokemon4: 'サーフゴー',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'カイリュー',
    sex1: Sex.female,
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイリュー/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこカーニャ/',
      opponentPokemon: 'マリルリ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // カイリューのHP140
  await inputRemainHP(driver, op, '140');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP70
  await inputRemainHP(driver, me, '70');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP30
  await inputRemainHP(driver, me, '30');
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // カイリューのHP74
  await inputRemainHP(driver, op, '74');
  // カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // カイリューのHP4
  await inputRemainHP(driver, op, '4');
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // カイリューのHP60
  await inputRemainHP(driver, me, '60');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // カイリューのHP0
  await inputRemainHP(driver, op, '0');
  // カイリューひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのサイコフィールド
  await tapMove(driver, me, 'サイコフィールド', false);
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', true);
  // グレンアルマのHP10
  await inputRemainHP(driver, op, '10');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // マスカーニャのHP42
  await inputRemainHP(driver, op, '42');
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, op, 'アクアジェット', true);
  // マスカーニャのHP11
  await inputRemainHP(driver, op, '11');
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦4
Future<void> test44_4(
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
    battleName: 'もこうカイリュー戦4',
    ownPartyname: '44もこカイリュー',
    opponentName: 'セジュン',
    pokemon1: 'ミミッキュ',
    pokemon2: 'マスカーニャ',
    pokemon3: 'ラウドボーン',
    pokemon4: 'ガブリアス',
    pokemon5: 'サーフゴー',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex1: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこ両刀マンダ/',
      ownPokemon2: 'もこカイリュー/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ボーマンダのHP155
  await inputRemainHP(driver, op, '155');
  // ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // マスカーニャのHP80
  await inputRemainHP(driver, me, '80');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', true);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // ガブリアスのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ガブリアスのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // ガブリアスのHP50
  await inputRemainHP(driver, me, '50');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ガブリアスひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦5
Future<void> test44_5(
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
    battleName: 'もこうカイリュー戦5',
    ownPartyname: '44もこカイリュー',
    opponentName: 'るま',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ラウドボーン',
    pokemon3: 'マリルリ',
    pokemon4: 'ジバコイル',
    pokemon5: 'カイリュー',
    pokemon6: 'セグレイブ',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこカイリュー/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // マスカーニャのHP1
  await inputRemainHP(driver, me, '1');
  // マスカーニャのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // キラフロルのHP65
  await inputRemainHP(driver, op, '65');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // カイリューのHP147
  await inputRemainHP(driver, op, '147');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('たべのこし');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('たべのこし')));
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // マリルリのHP30
  await inputRemainHP(driver, me, '30');
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // カイリューのHP42
  await inputRemainHP(driver, op, '42');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // 急所に命中
  await tapCritical(driver, me);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // カイリューのHP0
  await inputRemainHP(driver, op, '0');
  // カイリューひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // グレンアルマのHP33
  await inputRemainHP(driver, op, '33');
  // グレンアルマのサイコフィールド
  await tapMove(driver, me, 'サイコフィールド', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦6
Future<void> test44_6(
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
    battleName: 'もこうカイリュー戦6',
    ownPartyname: '44もこカイリュー',
    opponentName: 'ドラカビ',
    pokemon1: 'グレイシア',
    pokemon2: 'ラウドボーン',
    pokemon3: 'マリルリ',
    pokemon4: 'ユキノオー',
    pokemon5: 'ドラパルト',
    pokemon6: 'サーフゴー',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'ユキノオー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ユキノオーのゆきふらし
  await addEffect(driver, 0, op, 'ゆきふらし');
  await driver.tap(find.text('OK'));
  // キラフロルのパワージェム
  await tapMove(driver, me, 'パワージェム', false);
  // ユキノオーのHP1
  await inputRemainHP(driver, me, '1');
  // ユキノオーのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ユキノオーのじしん
  await tapMove(driver, op, 'じしん', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ユキノオーのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // マリルリのHP180
  await inputRemainHP(driver, op, '180');
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ユキノオーのHP0
  await inputRemainHP(driver, me, '0');
  // ユキノオーひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // マリルリのHP160
  await inputRemainHP(driver, op, '160');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンはぼうぎょが下がった
  await driver.tap(find.text('ラウドボーンはぼうぎょが下がった'));
  // ラウドボーンのたべのこし
  await addEffect(driver, 4, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // ドラパルトのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // マリルリひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドラパルトのHP53
  await inputRemainHP(driver, op, '53');
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ドラパルトのHP53
  await inputRemainHP(driver, me, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ドラカビの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦7
Future<void> test44_7(
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
    battleName: 'もこうカイリュー戦7',
    ownPartyname: '44もこカイリュー',
    opponentName: 'しぇだ',
    pokemon1: 'ノコッチ',
    pokemon2: 'ドラパルト',
    pokemon3: 'ラウドボーン',
    pokemon4: 'パーモット',
    pokemon5: 'ドドゲザン',
    pokemon6: 'マリルリ',
    sex1: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカイリュー/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'ノコッチ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ノコッチのあくび
  await tapMove(driver, op, 'あくび', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリューのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ノコッチのあくび
  await tapMove(driver, op, 'あくび', false);
  await tapSuccess(driver, op);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ノコッチ->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドドゲザンのHP15
  await inputRemainHP(driver, me, '15');
  // ドドゲザンのオボンのみ
  await addEffect(driver, 1, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ドドゲザンのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // カイリューのHP153
  await inputRemainHP(driver, op, '153');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザン->ノコッチに交代
  await changePokemon(driver, op, 'ノコッチ', true);
  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ノコッチのHP40
  await inputRemainHP(driver, me, '40');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ノコッチのHP0
  await inputRemainHP(driver, me, '0');
  // ノコッチひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦8
Future<void> test44_8(
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
    battleName: 'もこうカイリュー戦8',
    ownPartyname: '44もこカイリュー',
    opponentName: 'らヴぁら',
    pokemon1: 'ドラパルト',
    pokemon2: 'マスカーニャ',
    pokemon3: 'セグレイブ',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'ウルガモス',
    pokemon6: 'ユキノオー',
    sex1: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこカイリュー/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('むし'));
  await driver.tap(find.text('OK'));
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // ユキノオーに交代
  await changePokemon(driver, op, 'ユキノオー', false);
  // マスカーニャひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));
  // 相手の勝利
  await testExistEffect(driver, 'らヴぁらの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カイリュー戦9
Future<void> test44_9(
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
    battleName: 'もこうカイリュー戦9',
    ownPartyname: '44もこカイリュー',
    opponentName: 'ばんり',
    pokemon1: 'サザンドラ',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'ドラパルト',
    pokemon4: 'マリルリ',
    pokemon5: 'ロトム(フロストロトム)',
    pokemon6: 'アーマーガア',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこカイリュー/',
      opponentPokemon: 'ロトム(フロストロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトム->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // アーマーガアのHP95
  await inputRemainHP(driver, me, '95');
  // グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // アーマーガア->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // ドラパルトのHP40
  await inputRemainHP(driver, me, '40');
  // 急所に命中
  await tapCritical(driver, me);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマ->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', true);
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // ロトムに交代
  await changePokemon(driver, op, 'ロトム(フロストロトム)', false);
  // マスカーニャひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));
  // 相手の勝利
  await testExistEffect(driver, 'ばんりの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マフィティフ戦1
Future<void> test45_1(
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
    battleName: 'もこうマフィティフ戦1',
    ownPartyname: '45もこティフ',
    opponentName: 'トモッヒロ◎',
    pokemon1: 'マニューラ',
    pokemon2: 'エルレイド',
    pokemon3: 'ドラミドロ',
    pokemon4: 'サーフゴー',
    pokemon5: 'マスカーニャ',
    pokemon6: 'チルタリス',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこティフ/',
      ownPokemon2: 'もこブレイズ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // サーフゴー->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // 急所に命中
  await tapCritical(driver, me);
  // マスカーニャのHP10
  await inputRemainHP(driver, me, '10');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('くさ'));
  await driver.tap(find.text('OK'));
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // マフィティフのHP6
  await inputRemainHP(driver, op, '6');
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // マフィティフのHP0
  await inputRemainHP(driver, op, '0');
  // マフィティフひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', false);
  // ソウブレイズのHP101
  await inputRemainHP(driver, op, '101');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', false);
  // ソウブレイズのHP35
  await inputRemainHP(driver, op, '35');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP132
  await inputRemainHP(driver, me, '132');
  // サーフゴーひんし->マニューラに交代
  await changePokemon(driver, op, 'マニューラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マニューラのねこだまし
  await tapMove(driver, op, 'ねこだまし', true);
  // ソウブレイズのHP103
  await inputRemainHP(driver, op, '103');
  // マニューラのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マニューラのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ソウブレイズのHP22
  await inputRemainHP(driver, op, '22');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // マニューラのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP81
  await inputRemainHP(driver, me, '81');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マフィティフ戦2
Future<void> test45_2(
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
    battleName: 'もこうマフィティフ戦2',
    ownPartyname: '45もこティフ',
    opponentName: 'りょーま',
    pokemon1: 'クエスパトラ',
    pokemon2: 'ハッサム',
    pokemon3: 'シャワーズ',
    pokemon4: 'アーマーガア',
    pokemon5: 'ハピナス',
    pokemon6: 'ドヒドイデ',
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブレイズ/',
      ownPokemon2: 'もこティフ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'クエスパトラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->マフィティフに交代
  await changePokemon(driver, me, 'マフィティフ', true);
  // クエスパトラのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // クエスパトラのHP75
  await inputRemainHP(driver, op, '75');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのまもる
  await tapMove(driver, op, 'まもる', true);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // クエスパトラのHP75
  await inputRemainHP(driver, me, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, op, 'めいそう', true);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // クエスパトラのHP75
  await inputRemainHP(driver, me, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのみがわり
  await tapMove(driver, op, 'みがわり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // クエスパトラのHP50
  await inputRemainHP(driver, op, '50');
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // クエスパトラのHP50
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのまもる
  await tapMove(driver, op, 'まもる', false);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // クエスパトラのHP50
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのみがわり
  await tapMove(driver, op, 'みがわり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // クエスパトラのHP25
  await inputRemainHP(driver, op, '25');
  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのわるあがき
  await tapMove(driver, op, 'わるあがき', true);
  // マフィティフのHP143
  await inputRemainHP(driver, op, '143');
  // クエスパトラのHP2
  await inputRemainHP(driver, op, '2');
  // クエスパトラのフィラのみ
  await addEffect(driver, 1, op, 'フィラのみ');
  await driver.tap(find.text('OK'));
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // クエスパトラのHP35
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラ->シャワーズに交代
  await changePokemon(driver, op, 'シャワーズ', true);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // シャワーズのHP30
  await inputRemainHP(driver, me, '30');
  // クエスパトラのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // シャワーズのとける
  await tapMove(driver, op, 'とける', true);
  await tapSuccess(driver, op);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // シャワーズのHP0
  await inputRemainHP(driver, me, '0');
  // シャワーズひんし->クエスパトラに交代
  await changePokemon(driver, op, 'クエスパトラ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのまもる
  await tapMove(driver, op, 'まもる', false);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // クエスパトラのHP35
  await inputRemainHP(driver, me, '');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのバトンタッチ
  await tapMove(driver, op, 'バトンタッチ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // TODO:ここ、アーマーガアにダメージ入ってない
  // クエスパトラのHP30
  await inputRemainHP(driver, me, '30');
  // クエスパトラのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->クエスパトラに交代
  await changePokemon(driver, op, 'クエスパトラ', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マフィティフ戦3
Future<void> test45_3(
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
    battleName: 'もこうマフィティフ戦3',
    ownPartyname: '45もこティフ',
    opponentName: 'たなかたろう',
    pokemon1: 'ガブリアス',
    pokemon2: 'カイリュー',
    pokemon3: 'サザンドラ',
    pokemon4: 'ドドゲザン',
    pokemon5: 'サーフゴー',
    pokemon6: 'コノヨザル',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこティフ/',
      ownPokemon2: 'もこブレイズ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'コノヨザル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コノヨザル->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // ドドゲザンのHP90
  await inputRemainHP(driver, me, '90');
  // ドドゲザンのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // マフィティフのHP62
  await inputRemainHP(driver, op, '62');
  // マフィティフのロゼルのみ
  await addEffect(driver, 3, me, 'ロゼルのみ');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ドドゲザンのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // マフィティフのHP0
  await inputRemainHP(driver, op, '0');
  // ドドゲザンひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // マフィティフひんし->セグレイブに交代
  await changePokemon(driver, me, 'セグレイブ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マフィティフ戦4
Future<void> test45_4(
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
    battleName: 'もこうマフィティフ戦4',
    ownPartyname: '45もこティフ',
    opponentName: 'すたふぉー',
    pokemon1: 'モロバレル',
    pokemon2: 'サーフゴー',
    pokemon3: 'イルカマン',
    pokemon4: 'サザンドラ',
    pokemon5: 'ゴチルゼル',
    pokemon6: 'ニンフィア',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこティフ/',
      ownPokemon2: 'もこブレイズ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', true);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // モロバレルのHP40
  await inputRemainHP(driver, me, '40');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // モロバレルのリーフストーム
  await tapMove(driver, op, 'リーフストーム', true);
  // マフィティフのHP57
  await inputRemainHP(driver, op, '57');
  // モロバレルのだっしゅつパック
  await addEffect(driver, 2, op, 'だっしゅつパック');
  // イルカマンに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('イルカマン'));
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // イルカマンのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // イルカマンのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', false);
  await tapSuccess(driver, op);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', true);
  // マフィティフのHP0
  await inputRemainHP(driver, op, '0');
  // マフィティフひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // ソウブレイズのHP110
  await inputRemainHP(driver, op, '110');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのテラスタル
  await inputTerastal(driver, op, 'かくとう');
  // イルカマンのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // イルカマンのHP75
  await inputRemainHP(driver, op, '75');
  // ソウブレイズのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // イルカマンのHP75
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', true);
  // ソウブレイズのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP100
  await inputRemainHP(driver, op, '100');
  // ソウブレイズひんし->セグレイブに交代
  await changePokemon(driver, me, 'セグレイブ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // イルカマンのHP90
  await inputRemainHP(driver, me, '90');
  // イルカマンはひるんで技がだせない
  await driver.tap(find.text('イルカマンはひるんで技がだせない'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, me, 'つららばり', false);
  // イルカマンのHP40
  await inputRemainHP(driver, me, '40');
  // イルカマンのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP80
  await inputRemainHP(driver, op, '80');
  // 相手の勝利
  await testExistEffect(driver, 'すたふぉーの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マフィティフ戦5
Future<void> test45_5(
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
    battleName: 'もこうマフィティフ戦5',
    ownPartyname: '45もこティフ',
    opponentName: 'つかだ',
    pokemon1: 'ドヒドイデ',
    pokemon2: 'モロバレル',
    pokemon3: 'ラッキー',
    pokemon4: 'クレベース',
    pokemon5: 'ドオー',
    pokemon6: 'キョジオーン',
    sex3: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこティフ/',
      ownPokemon3: 'もこブレイズ/',
      opponentPokemon: 'ドヒドイデ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->マフィティフに交代
  await changePokemon(driver, me, 'マフィティフ', true);
  // ドヒドイデ->ラッキーに交代
  await changePokemon(driver, op, 'ラッキー', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ラッキー->ドヒドイデに交代
  await changePokemon(driver, op, 'ドヒドイデ', true);
  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // ドヒドイデのHP50
  await inputRemainHP(driver, me, '50');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ドヒドイデのメンタルハーブ
  await addEffect(driver, 1, op, 'メンタルハーブ');
  await driver.tap(find.text('OK'));
  // ドヒドイデのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドヒドイデのHP100
  await inputRemainHP(driver, op, '100');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ドヒドイデのどくどく
  await tapMove(driver, op, 'どくどく', true);
  await tapSuccess(driver, op);
  // もうどくダメージ編集
  await tapEffect(driver, 'もうどくダメージ');
  await driver.tap(find.text('削除'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // ドヒドイデのHP75
  await inputRemainHP(driver, me, '75');
  // ドヒドイデのわるあがき
  await tapMove(driver, op, 'わるあがき', true);
  // マフィティフのHP140
  await inputRemainHP(driver, op, '140');
  // ドヒドイデのHP50
  await inputRemainHP(driver, op, '50');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのくらいつく
  await tapMove(driver, me, 'くらいつく', false);
  // ドヒドイデのHP30
  await inputRemainHP(driver, me, '30');
  // ドヒドイデのわるあがき
  await tapMove(driver, op, 'わるあがき', true);
  // マフィティフのHP125
  await inputRemainHP(driver, op, '125');
  // ドヒドイデのHP0
  await inputRemainHP(driver, op, '0');
  // ドヒドイデひんし->クレベースに交代
  await changePokemon(driver, op, 'クレベース', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マフィティフのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // クレベースのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // マフィティフのHP0
  await inputRemainHP(driver, op, '0');
  // マフィティフひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // クレベースのテラスタル
  await inputTerastal(driver, op, 'かくとう');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // クレベースのつららおとし
  await tapMove(driver, op, 'つららおとし', true);
  // ソウブレイズのHP157
  await inputRemainHP(driver, op, '157');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // クレベースのつららおとし
  await tapMove(driver, op, 'つららおとし', false);
  // ソウブレイズのHP139
  await inputRemainHP(driver, op, '139');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // クレベースのHP70
  await inputRemainHP(driver, me, '70');
  // ソウブレイズのHP180
  await inputRemainHP(driver, me, '180');
  // クレベースのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', true);
  // クレベースのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // クレベースのHP100
  await inputRemainHP(driver, op, '100');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // クレベース->ラッキーに交代
  await changePokemon(driver, op, 'ラッキー', true);
  // エーフィのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('しんかのきせき');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('しんかのきせき')));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ラッキーのHP80
  await inputRemainHP(driver, me, '80');
  // ラッキーのちきゅうなげ
  await tapMove(driver, op, 'ちきゅうなげ', true);
  // エーフィのHP91
  await inputRemainHP(driver, op, '91');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', true);
  // ラッキーのちきゅうなげ
  await tapMove(driver, op, 'ちきゅうなげ', false);
  // 外れる
  await tapHit(driver, op);
  // ソウブレイズのHP180
  await inputRemainHP(driver, op, '');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', true);
  // ラッキー->クレベースに交代
  await changePokemon(driver, op, 'クレベース', true);
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // クレベースのHP1
  await inputRemainHP(driver, me, '1');
  // クレベースのがんじょう
  await addEffect(driver, 1, op, 'がんじょう');
  await driver.tap(find.text('OK'));
  // クレベースのつららおとし
  await tapMove(driver, op, 'つららおとし', false);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // エーフィひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // クレベースのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP181
  await inputRemainHP(driver, me, '181');
  // クレベースひんし->ラッキーに交代
  await changePokemon(driver, op, 'ラッキー', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ラッキーのHP25
  await inputRemainHP(driver, me, '25');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '182');
  // ラッキーのタマゴうみ
  await tapMove(driver, op, 'タマゴうみ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラッキーのHP75
  await inputRemainHP(driver, op, '75');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ラッキーのHP20
  await inputRemainHP(driver, me, '20');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '');
  // ラッキーのタマゴうみ
  await tapMove(driver, op, 'タマゴうみ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラッキーのHP70
  await inputRemainHP(driver, op, '70');
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ラッキーのタマゴうみ
  await tapMove(driver, op, 'タマゴうみ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラッキーのHP100
  await inputRemainHP(driver, op, '100');
  // ターン21へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ラッキーのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// マフィティフ戦1
Future<void> test45_1(
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
