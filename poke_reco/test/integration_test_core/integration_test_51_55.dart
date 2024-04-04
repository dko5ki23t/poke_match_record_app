import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ブースター戦1
Future<void> test51_1(
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
    battleName: 'もこうブースター戦1',
    ownPartyname: '51もこブースター',
    opponentName: 'minasi',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ガブリアス',
    pokemon3: 'サーフゴー',
    pokemon4: 'セグレイブ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ドータクン',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブースター/',
      ownPokemon2: 'もこ炎マリルリ/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ブースターのテラスタル
  await inputTerastal(driver, me, '');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // ブースターのHP72
  await inputRemainHP(driver, op, '72');
  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // ロトムのHP65
  await inputRemainHP(driver, me, '65');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // 外れる
  await tapHit(driver, op);
  // ブースターのHP72
  await inputRemainHP(driver, op, '');
  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ガブリアスのHP1
  await inputRemainHP(driver, me, '1');
  // ガブリアスのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ガブリアスのさめはだ
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', true);
  // ブースターのHP0
  await inputRemainHP(driver, op, '0');
  // ブースターひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ドータクンに交代
  await changePokemon(driver, op, 'ドータクン', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '90');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', true);
  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // ドータクンのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こうこうのしっぽ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こうこうのしっぽ')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ドータクンのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '');
  // 外れる
  await tapHit(driver, me);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ドータクンのHP40
  await inputRemainHP(driver, me, '40');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドータクンのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ハラバリーのHP3
  await inputRemainHP(driver, op, '3');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // ドータクンのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP37
  await inputRemainHP(driver, me, '37');
  // ドータクンひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ブースター戦2
Future<void> test51_2(
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

/// ブースター戦3
Future<void> test51_3(
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

/// ブースター戦4
Future<void> test51_4(
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

/// ブースター戦5
Future<void> test51_5(
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

// テンプレ
/*
/// ブースター戦1
Future<void> test51_1(
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
