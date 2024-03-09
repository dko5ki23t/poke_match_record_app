import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
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

/// ワナイダー戦1
Future<void> test12_1(
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
    battleName: 'もこうワナイダー戦1',
    ownPartyname: '12もこイダー',
    opponentName: 'シーザー',
    pokemon1: 'テツノブジン',
    pokemon2: 'カバルドン',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'オノノクス',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'ゾロアーク',
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー/',
      ownPokemon2: 'もこヘル/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'テツノブジン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // テツノブジンのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ワナイダーのメンタルハーブ
  await addEffect(driver, 1, me, 'メンタルハーブ');
  await driver.tap(find.text('OK'));
  // ワナイダーのねばねばネット
  await tapMove(driver, me, 'ねばねばネット', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);
  // ワナイダーのスレッドトラップ
  await tapMove(driver, me, 'スレッドトラップ', false);
  // テツノブジンのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', false);
  await tapSuccess(driver, op);
  // ターン4へ
  await goTurnPage(driver, turnNum++);
  // ワナイダーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // テツノブジンのHP90
  await inputRemainHP(driver, me, '90');
  // TODO:ゾロアークだった
  return;

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ワナイダー戦2
Future<void> test12_2(
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
    battleName: 'もこうワナイダー戦2',
    ownPartyname: '12もこイダー',
    opponentName: 'Kazu',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ドラパルト',
    pokemon3: 'ウルガモス',
    pokemon4: 'キョジオーン',
    pokemon5: 'ニンフィア',
    pokemon6: 'パオジアン',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー/',
      ownPokemon2: 'もこイルカ/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ワナイダーのねばねばネット
  await tapMove(driver, me, 'ねばねばネット', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ワナイダー->イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // イルカマンのHP45
  await inputRemainHP(driver, op, '45');
  // ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのインファイト
  await tapMove(driver, me, 'インファイト', true);
  // ウルガモスのHP90
  await inputRemainHP(driver, me, '90');
  // だっしゅつパック編集
  await tapEffect(driver, 'だっしゅつパック');
  await driver.tap(find.text('OK'));
  // TODO:だっしゅつパックで交代
  return;
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ワナイダー戦3
Future<void> test12_3(
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
    battleName: 'もこうワナイダー戦3',
    ownPartyname: '12もこイダー',
    opponentName: 'ブンタロウ',
    pokemon1: 'セグレイブ',
    pokemon2: 'バンギラス',
    pokemon3: 'サザンドラ',
    pokemon4: 'ブロロローム',
    pokemon5: 'ハバタクカミ',
    pokemon6: 'ラウドボーン',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー/',
      ownPokemon2: 'もこイルカ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'ブロロローム');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのすてゼリフ
  await tapMove(driver, op, 'すてゼリフ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ワナイダーのねばねばネット
  await tapMove(driver, me, 'ねばねばネット', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ワナイダーのおきみやげ
  await tapMove(driver, me, 'おきみやげ', false);
  // ワナイダーひんし->イルカマンに交代
  await changePokemon(driver, me, 'イルカマン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', false);
  // イルカマンのインファイト
  await tapMove(driver, me, 'インファイト', true);
  // セグレイブのHP35
  await inputRemainHP(driver, me, '35');
  // だっしゅつパック編集
  await tapEffect(driver, 'だっしゅつパック');
  await driver.tap(find.text('OK'));
  // TODO: だっしゅつパックで交代
  return;
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ワナイダー戦4
Future<void> test12_4(
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
    battleName: 'もこうワナイダー戦4',
    ownPartyname: '12もこイダー',
    opponentName: 'としき',
    pokemon1: 'ラウドボーン',
    pokemon2: 'パルシェン',
    pokemon3: 'イルカマン',
    pokemon4: 'ミミッキュ',
    pokemon5: 'イッカネズミ',
    pokemon6: 'ドラパルト',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー/',
      ownPokemon2: 'もこレイブ/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'イッカネズミ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのおかたづけ
  await tapMove(driver, op, 'おかたづけ', true);
  // ワナイダーのねばねばネット
  await tapMove(driver, me, 'ねばねばネット', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ワナイダーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // イッカネズミのHP80
  await inputRemainHP(driver, me, '80');
  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', true);
  // 6回命中
  await setHitCount(driver, op, 6);
  // ワナイダーのHP0
  await inputRemainHP(driver, op, '0');
  // ワナイダーひんし->セグレイブに交代
  await changePokemon(driver, me, 'セグレイブ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', false);
  // 1回急所
  await setCriticalCount(driver, op, 1);
  // 2回急所
  await setCriticalCount(driver, op, 2);
  // 8回命中
  await setHitCount(driver, op, 8);
  // セグレイブのHP0
  await inputRemainHP(driver, op, '0');
  // セグレイブひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', false);
  // 3回命中
  await setHitCount(driver, op, 3);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'としきの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// トドロクツキ戦1
Future<void> test13_1(
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
    battleName: 'もこうトドロクツキ戦1',
    ownPartyname: '13もこロクツキ',
    opponentName: 'パープル',
    pokemon1: 'テツノドクガ',
    pokemon2: 'キノガッサ',
    pokemon3: 'ミミッキュ',
    pokemon4: 'イルカマン',
    pokemon5: 'パオジアン',
    pokemon6: 'ガブリアス',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこミミズ/',
      ownPokemon3: 'もこロクツキ/',
      opponentPokemon: 'パオジアン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ボーマンダ->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', true);
  // パオジアンのつららおとし
  await tapMove(driver, op, 'つららおとし', true);
  // 外れる
  await tapHit(driver, op);
  // ミミズズのHP177
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // パオジアンのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // トドロクツキに交代
  await changePokemon(driver, me, 'トドロクツキ', false);
  // こだいかっせい編集
  await tapEffect(driver, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // パオジアンのせいなるつるぎ
  await tapMove(driver, op, 'せいなるつるぎ', true);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // トドロクツキのHP181
  await inputRemainHP(driver, op, '');
  // トドロクツキのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // パオジアンのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // トドロクツキのHP64
  await inputRemainHP(driver, op, '64');
  // トドロクツキのアクロバット
  await tapMove(driver, me, 'アクロバット', false);
  // パオジアンのHP0
  await inputRemainHP(driver, me, '0');
  // パオジアンひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // トドロクツキのHP22
  await inputRemainHP(driver, op, '22');
  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->テツノドクガに交代
  await changePokemon(driver, op, 'テツノドクガ', false);
  // テツノドクガのクォークチャージ
  await addEffect(driver, 3, op, 'クォークチャージ');
  // とくこうが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのテラスタル
  await inputTerastal(driver, me, '');
  // テツノドクガのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // 急所に命中
  await tapCritical(driver, me);
  // テツノドクガのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// トドロクツキ戦2
Future<void> test13_2(
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
    battleName: 'もこうトドロクツキ戦2',
    ownPartyname: '13もこロクツキ',
    opponentName: '核隠',
    pokemon1: 'セグレイブ',
    pokemon2: 'ミミズズ',
    pokemon3: 'サーフゴー',
    pokemon4: 'コノヨザル',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'ドオー',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこヒートロトム/',
      ownPokemon2: 'もこリククラゲ/',
      ownPokemon3: 'もこロクツキ/',
      opponentPokemon: 'コノヨザル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', true);
  // ロトムのHP115
  await inputRemainHP(driver, op, '115');
  // ロトムのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ロトム->トドロクツキに交代
  await changePokemon(driver, me, 'トドロクツキ', true);
  // コノヨザル->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのテラスタル
  await inputTerastal(driver, me, '');
  // トドロクツキのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // セグレイブのきょけんとつげき
  await tapMove(driver, op, 'きょけんとつげき', true);
  // トドロクツキのHP15
  await inputRemainHP(driver, op, '15');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのテラスタル
  await inputTerastal(driver, op, 'みず');
  // トドロクツキのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ヘイラッシャのHP60
  await inputRemainHP(driver, me, '60');
  // ヘイラッシャのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // 外れる
  await tapHit(driver, op);
  // トドロクツキのHP0
  await inputRemainHP(driver, op, '');
  // トドロクツキひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', true);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ヘイラッシャひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // リククラゲのHP24
  await inputRemainHP(driver, op, '24');
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネ編集
  await tapEffect(driver, 'やどりぎのタネ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('54');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // コノヨザルのHP40
  await inputRemainHP(driver, me, '40');
  // コノヨザルのインファイト
  await tapMove(driver, op, 'インファイト', false);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // リククラゲひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', true);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// トドロクツキ戦3
Future<void> test13_3(
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
    battleName: 'もこうトドロクツキ戦3',
    ownPartyname: '13もこロクツキ',
    opponentName: 'えのん',
    pokemon1: 'ミミッキュ',
    pokemon2: 'キラフロル',
    pokemon3: 'スナノケガワ',
    pokemon4: 'サーフゴー',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'トドロクツキ',
    sex1: Sex.female,
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこリククラゲ/',
      ownPokemon3: 'もこロクツキ/',
      opponentPokemon: 'キラフロル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // ミミズズのHP177
  await inputRemainHP(driver, op, '');
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // トドロクツキに交代
  await changePokemon(driver, me, 'トドロクツキ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // キラフロルのHP30
  await inputRemainHP(driver, me, '30');
  // キラフロルのどくげしょう
  await addEffect(driver, 1, op, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // キラフロルのだいちのちから
  await tapMove(driver, op, 'だいちのちから', false);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // トドロクツキのHP159
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, me, 'じごくづき', false);
  // ミミッキュのHP88
  await inputRemainHP(driver, me, '');
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // トドロクツキのHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // トドロクツキひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュののろい
  await tapMove(driver, op, 'のろい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミッキュのHP16
  await inputRemainHP(driver, op, '16');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // リククラゲ->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // ミミズズのHP89
  await inputRemainHP(driver, op, '89');
  // ミミズズのじしん
  await tapMove(driver, me, 'じしん', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', false);
  // こうげきが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('こうげき'));
  // ミミッキュのこだいかっせい
  await addEffect(driver, 5, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // トドロクツキのHP75
  await inputRemainHP(driver, me, '75');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // トドロクツキのHP68
  await inputRemainHP(driver, me, '68');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのくらいつく
  await tapMove(driver, op, 'くらいつく', true);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのテラスタル
  await inputTerastal(driver, me, '');
  // トドロクツキのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', false);
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  await tapSuccess(driver, me);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // トドロクツキのHP50
  await inputRemainHP(driver, me, '50');
  // トドロクツキのくらいつく
  await tapMove(driver, op, 'くらいつく', false);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'えのんの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// トドロクツキ戦4
Future<void> test13_4(
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
    battleName: 'もこうトドロクツキ戦4',
    ownPartyname: '13もこロクツキ',
    opponentName: 'きーと',
    pokemon1: 'ヌメルゴン',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'ドオー',
    pokemon4: 'トドロクツキ',
    pokemon5: 'パルシェン',
    pokemon6: 'シビルドン',
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこロクツキ/',
      ownPokemon2: 'もこミミズ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'シビルドン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // シビルドン->ソウブレイズに交代
  await changePokemon(driver, op, 'ソウブレイズ', true);
  // トドロクツキのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ソウブレイズのHP1
  await inputRemainHP(driver, me, '1');
  // シビルドンのきあいのタスキ
  await addEffect(driver, 3, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // シビルドンのくだけるよろい
  await addEffect(driver, 4, op, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // トドロクツキのHP0
  await inputRemainHP(driver, op, '0');
  // トドロクツキひんし->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', true);
  // ミミズズのHP17
  await inputRemainHP(driver, op, '17');
  // ソウブレイズのHP60
  await inputRemainHP(driver, op, '60');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', false);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ソウブレイズのHP75
  await inputRemainHP(driver, op, '75');
  // ミミズズひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', false);
  // ボーマンダのHP122
  await inputRemainHP(driver, op, '122');
  // ソウブレイズのHP90
  await inputRemainHP(driver, op, '90');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', false);
  // ボーマンダのHP72
  await inputRemainHP(driver, op, '72');
  // ソウブレイズのHP100
  await inputRemainHP(driver, op, '100');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズひんし->シビルドンに交代
  await changePokemon(driver, op, 'シビルドン', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // シビルドンのHP0
  await inputRemainHP(driver, me, '0');
  // シビルドンひんし->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', false);
  // すばやさが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  // シビルドンのこだいかっせい
  await addEffect(driver, 3, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // トドロクツキのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// シャリタツ戦1
Future<void> test14_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // TODO: ゾロアークが登場する
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうシャリタツ戦1',
    ownPartyname: '14もこシャリ2',
    opponentName: 'セジュン',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ムクホーク',
    pokemon3: 'ミミッキュ',
    pokemon4: 'ゾロアーク',
    pokemon5: 'ジバコイル',
    pokemon6: 'キョジオーン',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー/',
      ownPokemon2: 'もこシャリ/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'ムクホーク');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  return;
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// シャリタツ戦2
Future<void> test14_2(
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
    battleName: 'もこうシャリタツ戦2',
    ownPartyname: '14もこシャリ2',
    opponentName: 'タクマ',
    pokemon1: 'グレンアルマ',
    pokemon2: 'サーフゴー',
    pokemon3: 'バンギラス',
    pokemon4: 'ドラパルト',
    pokemon5: 'アーマーガア',
    pokemon6: 'ミミッキュ',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシャリ/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'グレンアルマ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // グレンアルマのHP65
  await inputRemainHP(driver, me, '65');
  // グレンアルマのエナジーボール
  await tapMove(driver, op, 'エナジーボール', true);
  // シャリタツのHP33
  await inputRemainHP(driver, op, '33');
  // グレンアルマのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマ->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->グレンアルマに交代
  await changePokemon(driver, op, 'グレンアルマ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, me, '0');
  // グレンアルマひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // TODO: サーフゴーのたべのこしを効果として追加しようとしたらinsertableTimings()で無限ループした
  return;

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// シャリタツ戦3
Future<void> test14_3(
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
    battleName: 'もこうシャリタツ戦3',
    ownPartyname: '14もこシャリ2',
    opponentName: 'ニンジャ',
    pokemon1: 'リキキリン',
    pokemon2: 'セグレイブ',
    pokemon3: 'ロトム(ヒートロトム)',
    pokemon4: 'サーフゴー',
    pokemon5: 'モロバレル',
    pokemon6: 'ウェーニバル',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシャリ/',
      ownPokemon2: 'もこいかくマンダ/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // シャリタツのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // シャリタツのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // セグレイブのHP70
  await inputRemainHP(driver, me, '70');
  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // シャリタツのHP0
  await inputRemainHP(driver, op, '0');
  // シャリタツひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ボーマンダのHP35
  await inputRemainHP(driver, op, '35');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // セグレイブのHP10
  await inputRemainHP(driver, me, '10');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '');
  // セグレイブひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // モロバレルのHP80
  await inputRemainHP(driver, me, '80');
  // モロバレルのどくどく
  await tapMove(driver, op, 'どくどく', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// シャリタツ戦4
Future<void> test14_4(
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
    battleName: 'もこうシャリタツ戦4',
    ownPartyname: '14もこシャリ2',
    opponentName: '7らいおん',
    pokemon1: 'ブリムオン',
    pokemon2: 'ダイオウドウ',
    pokemon3: 'コータス',
    pokemon4: 'オノノクス',
    pokemon5: 'ロトム(ヒートロトム)',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリククラゲ/',
      ownPokemon2: 'もこシャリ/',
      ownPokemon3: 'もこネズミ/',
      opponentPokemon: 'ミミッキュ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ミミッキュ->ブリムオンに交代
  await changePokemon(driver, op, 'ブリムオン', true);
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ブリムオンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // ブリムオンのHP60
  await inputRemainHP(driver, me, '60');
  // ブリムオンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // ブリムオンのHP25
  await inputRemainHP(driver, me, '25');
  // ブリムオンのマジカルフレイム
  await tapMove(driver, op, 'マジカルフレイム', true);
  // リククラゲのHP89
  await inputRemainHP(driver, op, '89');
  // やどりぎのタネ編集
  await tapEffect(driver, 'やどりぎのタネ');
  await driver.enterText('115');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ブリムオンのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲのHP124
  await inputRemainHP(driver, me, '124');
  // ブリムオンひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // リククラゲのHP124
  await inputRemainHP(driver, me, '');
  // ミミッキュはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ミミッキュのばけのかわ
  // TODO:ここ自動発動させたい
  await addEffect(driver, 2, op, 'ばけのかわ');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ミミッキュのHP75
  await inputRemainHP(driver, me, '75');
  // リククラゲのHP142
  await inputRemainHP(driver, me, '142');
  // ミミッキュのトリックルーム
  await tapMove(driver, op, 'トリックルーム', true);
  // ミミッキュのルームサービス
  await addEffect(driver, 2, op, 'ルームサービス');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュののろい
  await tapMove(driver, op, 'のろい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミッキュのHP25
  await inputRemainHP(driver, op, '25');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュ->コータスに交代
  await changePokemon(driver, op, 'コータス', true);
  // コータスのひでり
  await addEffect(driver, 1, op, 'ひでり');
  await driver.tap(find.text('OK'));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネ編集
  await tapEffect(driver, 'やどりぎのタネ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('79');
  await driver.tap(find.text('OK'));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // コータスのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // コータスのふんか
  await tapMove(driver, op, 'ふんか', true);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // リククラゲひんし->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);
  // TODO:こちらがひんしのとき、やどりぎダメージは入らないようにすべき？

  // コータスのふんか
  await tapMove(driver, op, 'ふんか', false);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // イッカネズミひんし->シャリタツに交代
  await changePokemon(driver, me, 'シャリタツ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // コータス->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // ミミッキュのHP25
  await inputRemainHP(driver, me, '');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->コータスに交代
  await changePokemon(driver, op, 'コータス', false);
  // TODO: ここ、ひんし直後にターン終了処理であるはれ終了が行われ、コータス死に出しで再度はれになるべき
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // コータスのHP10
  await inputRemainHP(driver, me, '10');
  // コータスのソーラービーム
  await tapMove(driver, op, 'ソーラービーム', true);
  // シャリタツのHP22
  await inputRemainHP(driver, op, '22');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // コータスのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エルレイド戦1
Future<void> test15_1(
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
    battleName: 'もこうエルレイド戦1',
    ownPartyname: '15もこレイド',
    opponentName: 'root5',
    pokemon1: 'サーフゴー',
    pokemon2: 'ミミッキュ',
    pokemon3: 'オーロンゲ',
    pokemon4: 'ドラパルト',
    pokemon5: 'イルカマン',
    pokemon6: 'ラウドボーン',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイド/',
      ownPokemon2: 'もこリククラゲ/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // イルカマンのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', true);
  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ミミッキュはとくぼうが下がった
  await driver.tap(find.text('ミミッキュはとくぼうが下がった'));
  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // リククラゲひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのテラスタル
  await inputTerastal(driver, me, '');
  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // エルレイドのHP31
  await inputRemainHP(driver, op, '31');
  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // ドラパルトのHP30
  await inputRemainHP(driver, me, '30');
  // TODO:ゴーストダイブ、1ターン目は成功/失敗だけ入力できる方がよさげ
  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', true);
  // エルレイドのHP31
  await inputRemainHP(driver, op, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // ヘルガーのHP12
  await inputRemainHP(driver, op, '12');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // ヘルガーのHP12
  await inputRemainHP(driver, op, '');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP30
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エルレイド戦2
Future<void> test15_2(
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
    battleName: 'もこうエルレイド戦2',
    ownPartyname: '15もこレイド',
    opponentName: 'かみなりおか',
    pokemon1: 'キノガッサ',
    pokemon2: 'ガブリアス',
    pokemon3: 'ロトム(ウォッシュロトム)',
    pokemon4: 'キョジオーン',
    pokemon5: 'サーフゴー',
    pokemon6: 'ドドゲザン',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこレイド/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // エルレイドのHP92
  await inputRemainHP(driver, op, '92');
  // ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのテラスタル
  await inputTerastal(driver, me, '');
  // エルレイドのテラスタル
  await inputTerastal(driver, me, '');
  // ガブリアス->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // エルレイドのテラスタル
  await inputTerastal(driver, me, '');
  // エルレイドのせいなるつるぎ
  await tapMove(driver, me, 'せいなるつるぎ', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // キョジオーンのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // 急所に命中
  await tapCritical(driver, op);
  // ボーマンダのHP85
  await inputRemainHP(driver, op, '85');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // キョジオーンのHP70
  await inputRemainHP(driver, me, '70');
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // キョジオーンのHP70
  await inputRemainHP(driver, me, '70');
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // キョジオーンのHP70
  await inputRemainHP(driver, me, '70');
  // 疲れ果ててこんらんした
  await driver.tap(find.text('疲れ果ててこんらんした'));
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // キョジオーン->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', false);
  // ボーマンダひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // キョジオーンのHP30
  await inputRemainHP(driver, me, '30');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', false);
  // ヘルガーのHP47
  await inputRemainHP(driver, op, '47');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エルレイド戦3
Future<void> test15_3(
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
    battleName: 'もこうエルレイド戦3',
    ownPartyname: '15もこレイド',
    opponentName: 'にわ',
    pokemon1: 'ギャラドス',
    pokemon2: 'ジバコイル',
    pokemon3: 'ウインディ',
    pokemon4: 'ガブリアス',
    pokemon5: 'サザンドラ',
    pokemon6: 'ヘイラッシャ',
    sex1: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこいかくマンダ/',
      ownPokemon2: 'もこレイド/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'ギャラドス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのいかく
  // TODO:ボーマンダのあとにいかくを追加したかったが、候補になかった
  await addEffect(driver, 0, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ギャラドスのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ギャラドスのHP40
  await inputRemainHP(driver, me, '40');
  // ギャラドスのこおりのキバ
  await tapMove(driver, op, 'こおりのキバ', true);
  // ボーマンダのHP93
  await inputRemainHP(driver, op, '93');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ギャラドス->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ヘイラッシャのHP60
  await inputRemainHP(driver, me, '60');
  // ギャラドスのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのまもる
  await tapMove(driver, op, 'まもる', true);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ヘイラッシャのHP66
  await inputRemainHP(driver, me, '');
  // 疲れ果ててこんらんした
  await driver.tap(find.text('疲れ果ててこんらんした'));
  // ボーマンダのラムのみ
  await addEffect(driver, 3, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ヘイラッシャのHP30
  await inputRemainHP(driver, me, '30');
  // ヘイラッシャのあくび
  await tapMove(driver, op, 'あくび', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャ->ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', true);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // 疲れ果ててこんらんした
  await driver.tap(find.text('疲れ果ててこんらんした'));
  // ギャラドスひんし->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', false);
  // ヘイラッシャのいかく
  await addEffect(driver, 5, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ウインディのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのせいなるつるぎ
  await tapMove(driver, me, 'せいなるつるぎ', false);
  // ウインディのHP25
  await inputRemainHP(driver, me, '25');
  // ウインディのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // エルレイドのHP0
  await inputRemainHP(driver, op, '0');
  // エルレイドひんし->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ウインディのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // キョジオーンのHP159
  await inputRemainHP(driver, op, '159');
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ウインディ->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのまもる
  await tapMove(driver, op, 'まもる', false);
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ヘイラッシャのHP42
  await inputRemainHP(driver, me, '');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのじわれ
  await tapMove(driver, op, 'じわれ', true);
  // 外れる
  await tapHit(driver, op);
  // キョジオーンのHP195
  await inputRemainHP(driver, op, '');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ヘイラッシャのHP40
  await inputRemainHP(driver, me, '40');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのじわれ
  await tapMove(driver, op, 'じわれ', false);
  // 外れる
  await tapHit(driver, op);
  // キョジオーンのHP207
  await inputRemainHP(driver, op, '');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ヘイラッシャのHP15
  await inputRemainHP(driver, me, '15');
  // ヘイラッシャひんし->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ウインディのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // ウインディのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // キョジオーンのHP139
  await inputRemainHP(driver, op, '139');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ウインディのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エルレイド戦4
Future<void> test15_4(
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
    battleName: 'もこうエルレイド戦4',
    ownPartyname: '15もこレイド',
    opponentName: 'bn',
    pokemon1: 'ミミッキュ',
    pokemon2: 'カイリュー',
    pokemon3: 'モロバレル',
    pokemon4: 'セグレイブ',
    pokemon5: 'ロトム(ヒートロトム)',
    pokemon6: 'ブラッキー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレイド/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのせいなるつるぎ
  await tapMove(driver, me, 'せいなるつるぎ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', true);
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // キョジオーンのHP181
  await inputRemainHP(driver, op, '181');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // モロバレル->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // カイリューのHP80
  await inputRemainHP(driver, me, '80');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // カイリューのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // キョジオーンのHP41
  await inputRemainHP(driver, op, '41');
  // キョジオーンはひるんで技がだせない
  await driver.tap(find.text('キョジオーンはひるんで技がだせない'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // キョジオーンひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', true);
  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // モロバレルのHP30
  await inputRemainHP(driver, me, '30');
  // カイリューのくろいヘドロ
  await addEffect(driver, 2, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // モロバレルのHP0
  await inputRemainHP(driver, me, '0');
  // モロバレルひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // エルレイドのHP36
  await inputRemainHP(driver, op, '36');
  // エルレイドのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// エルレイド戦1
Future<void> test15_1(
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
