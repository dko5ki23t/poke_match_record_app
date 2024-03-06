import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// セグレイブ戦1
Future<void> test11_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうセグレイブ戦1',
    ownPartyname: '11もこレイブ',
    opponentName: 'かずき',
    pokemon1: 'ニンフィア',
    pokemon2: 'エーフィ',
    pokemon3: 'ブースター',
    pokemon4: 'ブラッキー',
    pokemon5: 'グレイシア',
    pokemon6: 'リーフィア',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイブ/',
      ownPokemon2: 'もこフィア/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'ブースター');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // セグレイブのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ブースターのおにび
  await tapMove(driver, op, 'おにび', true);
  await tapSuccess(driver, op);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // ブースターのHP0
  await inputRemainHP(driver, me, '0');
  // ブースターひんし->エーフィに交代
  await changePokemon(driver, op, 'エーフィ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // エーフィのHP1
  await inputRemainHP(driver, me, '1');
  // エーフィのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // エーフィはひるんで技がだせない
  await driver.tap(find.text('エーフィはひるんで技がだせない'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// セグレイブ戦2
Future<void> test11_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうセグレイブ戦2',
    ownPartyname: '11もこレイブ',
    opponentName: 'サクラ',
    pokemon1: 'ニンフィア',
    pokemon2: 'タイカイデン',
    pokemon3: 'ドドゲザン',
    pokemon4: 'イルカマン',
    pokemon5: 'チオンジェン',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイブ/',
      ownPokemon2: 'もこミミズ/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'ニンフィア');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // セグレイブのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // セグレイブのHP134
  await inputRemainHP(driver, op, '134');
  // ニンフィアのとくせいがフェアリースキンと判明
  await editPokemonState(driver, 'ニンフィア/サクラ', null, 'フェアリースキン', null);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ニンフィアひんし->チオンジェンに交代
  await changePokemon(driver, op, 'チオンジェン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, me, 'つららばり', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  // チオンジェンのHP0
  await inputRemainHP(driver, me, '0');
  // チオンジェンひんし->タイカイデンに交代
  await changePokemon(driver, op, 'タイカイデン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// セグレイブ戦3
Future<void> test11_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうせグレイブ戦3',
    ownPartyname: '11もこレイブ',
    opponentName: 'ねぎ',
    pokemon1: 'マスカーニャ',
    pokemon2: 'テツノブジン',
    pokemon3: 'パオジアン',
    pokemon4: 'ミミッキュ',
    pokemon5: 'テツノドクガ',
    pokemon6: 'ワタッコ',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイブ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこミミズ/',
      opponentPokemon: 'ワタッコ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ワタッコ->テツノドクガに交代
  await changePokemon(driver, op, 'テツノドクガ', true);
  // テツノドクガのクォークチャージ
  await addEffect(driver, 1, op, 'クォークチャージ');
  // とくこうが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // セグレイブのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // テツノドクガのHP0
  await inputRemainHP(driver, me, '0');
  // テツノドクガひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// セグレイブ戦4
Future<void> test11_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうせグレイブ戦4',
    ownPartyname: '11もこレイブ',
    opponentName: 'カラレス',
    pokemon1: 'イルカマン',
    pokemon2: 'グレンアルマ',
    pokemon3: 'ハッサム',
    pokemon4: 'カバルドン',
    pokemon5: 'キノガッサ',
    pokemon6: 'カイリュー',
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイブ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこミミズ/',
      opponentPokemon: 'カバルドン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // カバルドンのすなおこし
  await addEffect(driver, 0, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  await driver.tap(find.text('OK'));
  // セグレイブのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // カバルドンのあくび
  await tapMove(driver, op, 'あくび', true);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, me, 'つららばり', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  // カバルドンのHP30
  await inputRemainHP(driver, me, '30');
  // カバルドンのオボンのみ
  await addEffect(driver, 1, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // カバルドンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // セグレイブのラムのみ
  await addEffect(driver, 5, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // カバルドン->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', true);
  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // ハッサムのHP55
  await inputRemainHP(driver, me, '55');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, me, '');
  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  // セグレイブのHP66
  await inputRemainHP(driver, op, '66');
  // セグレイブのつららばり
  await tapMove(driver, me, 'つららばり', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '0');
  // ハッサムひんし->カバルドンに交代
  await changePokemon(driver, op, 'カバルドン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // カバルドンのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // カバルドンのHP1
  await inputRemainHP(driver, me, '1');
  // カバルドンのじしん
  await tapMove(driver, op, 'じしん', true);
  // セグレイブのHP0
  await inputRemainHP(driver, op, '0');
  // セグレイブひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // TODO:すなあらしが収まるターンにすなあらしダメージが入らないようにする。
  // TODO: 本来死なないカバルドンが死んじゃったのでここまでで一旦終わっているが、続きも必要
  return;

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// セグレイブ戦5
Future<void> test11_5(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうせグレイブ戦5',
    ownPartyname: '11もこレイブ',
    opponentName: 'わかめせん',
    pokemon1: 'ミミッキュ',
    pokemon2: 'ドラパルト',
    pokemon3: 'ラウドボーン',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'サーフゴー',
    pokemon6: 'マスカーニャ',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイブ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこミミズ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // セグレイブのテラスタル
  await inputTerastal(driver, me, '');
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // セグレイブのHP158
  await inputRemainHP(driver, op, '158');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // セグレイブのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // サーフゴーのHP75
  await inputRemainHP(driver, me, '75');
  // サーフゴーはひるんで技がだせない
  await driver.tap(find.text('サーフゴーはひるんで技がだせない'));
  // サーフゴーのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // サーフゴーのHP50
  await inputRemainHP(driver, me, '50');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // セグレイブのHP92
  await inputRemainHP(driver, op, '92');
  // セグレイブはとくぼうが下がった
  await driver.tap(find.text('セグレイブはとくぼうが下がった'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP80
  await inputRemainHP(driver, op, '80');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // サーフゴーのHP40
  await inputRemainHP(driver, me, '40');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // セグレイブのHP0
  await inputRemainHP(driver, op, '0');
  // セグレイブひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // サーフゴーのHP1
  await inputRemainHP(driver, me, '1');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // 急所に命中
  await tapCritical(driver, op);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->セグレイブに交代
  await changePokemon(driver, me, 'セグレイブ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブのきょけんとつげき
  await tapMove(driver, me, 'きょけんとつげき', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', true);
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ミミズズのHP147
  await inputRemainHP(driver, op, '147');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ミミッキュのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ミミズズのHP38
  await inputRemainHP(driver, op, '38');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ミミッキュのHP80
  await inputRemainHP(driver, me, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // ミミズズのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドラパルトのHP70
  await inputRemainHP(driver, me, '70');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// セグレイブ戦1
Future<void> test11_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);

      
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}
*/
