import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ハッサム戦1
Future<void> test46_1(
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
    battleName: 'もこうハッサム戦1',
    ownPartyname: '46もこハッサム',
    opponentName: 'やよい',
    pokemon1: 'アーマーガア',
    pokemon2: 'マリルリ',
    pokemon3: 'サザンドラ',
    pokemon4: 'コノヨザル',
    pokemon5: 'ドラパルト',
    pokemon6: 'ウインディ',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこハッサム/',
      ownPokemon2: 'もこリドリ/',
      ownPokemon3: 'もこカイリュー/',
      opponentPokemon: 'マリルリ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ハッサムのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', false);
  // マリルリのばかぢから
  await tapMove(driver, op, 'ばかぢから', true);
  // ハッサムのHP73
  await inputRemainHP(driver, op, '73');
  // ターン2へ
  await goTurnPage(driver, turnNum++);
  // ハッサムのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);
  // ハッサムのどろぼう
  await tapMove(driver, me, 'どろぼう', false);
  // サザンドラのHP70
  await inputRemainHP(driver, me, '70');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('こだわりメガネ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりメガネ')));
  // サザンドラのだいもんじ
  await tapMove(driver, op, 'だいもんじ', true);
  // ハッサムのHP0
  await inputRemainHP(driver, op, '0');
  // ハッサムひんし->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);
  // オドリドリのテラスタル
  await inputTerastal(driver, me, '');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // オドリドリのHP104
  await inputRemainHP(driver, op, '104');
  // オドリドリはひるんで技がだせない
  await driver.tap(find.text('オドリドリはひるんで技がだせない'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);
  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // オドリドリのHP0
  await inputRemainHP(driver, op, '0');
  // オドリドリひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);
  // サザンドラのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // カイリューのHP68
  await inputRemainHP(driver, op, '68');
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // カイリューのHP47
  await inputRemainHP(driver, op, '47');
  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // サザンドラのHP65
  await inputRemainHP(driver, me, '65');
  // ターン8へ
  await goTurnPage(driver, turnNum++);
  // サザンドラのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', false);
  // カイリューのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハッサム戦2
Future<void> test46_2(
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
    battleName: 'もこうハッサム戦2',
    ownPartyname: '46もこハッサム',
    opponentName: 'あゆ',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ブラッキー',
    pokemon3: 'ウルガモス',
    pokemon4: 'カイリュー',
    pokemon5: 'カバルドン',
    pokemon6: 'サーフゴー',
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこハッサム/',
      ownPokemon2: 'もこリドリ/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.text('OK'));
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('あく'));
  await driver.tap(find.text('OK'));
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ハッサムのHP38
  await inputRemainHP(driver, op, '38');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('オボンのみ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('オボンのみ')));
  // ハッサムのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ハッサムのバレットパンチ
  await tapMove(driver, me, 'バレットパンチ', false);
  // サーフゴーのHP85
  await inputRemainHP(driver, me, '85');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのどろぼう
  await tapMove(driver, me, 'どろぼう', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('こだわりメガネ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりメガネ')));
  // サーフゴーひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, me, 'バレットパンチ', false);
  // マスカーニャのHP20
  await inputRemainHP(driver, me, '20');
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // ハッサムのHP0
  await inputRemainHP(driver, op, '0');
  // ハッサムひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // 急所に命中
  await tapCritical(driver, me);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', true);
  // ウルガモスのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // オドリドリのおどりこ
  await addEffect(driver, 3, me, 'おどりこ');
  await driver.tap(find.byValueKey('DanceTypeAheadField'));
  await driver.enterText('ちょうのまい');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ちょうのまい')));
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // オドリドリのHP48
  await inputRemainHP(driver, op, '48');
  // ウルガモスのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // オドリドリのおどりこ
  await addEffect(driver, 3, me, 'おどりこ');
  await driver.tap(find.byValueKey('DanceTypeAheadField'));
  await driver.enterText('ほのおのまい');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ほのおのまい')));
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('60');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // ウルガモスのHP5
  await inputRemainHP(driver, me, '5');
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', false);
  // オドリドリのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハッサム戦3
Future<void> test46_3(
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
    battleName: 'もこうハッサム戦3',
    ownPartyname: '46もこハッサム',
    opponentName: 'かまぼこ',
    pokemon1: 'ドラパルト',
    pokemon2: 'イルカマン',
    pokemon3: 'アーマーガア',
    pokemon4: 'サザンドラ',
    pokemon5: 'サーフゴー',
    pokemon6: 'ドオー',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこハッサム/',
      ownPokemon2: 'もこカイリュー/',
      ownPokemon3: 'もこリドリ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // ハッサムのHP117
  await inputRemainHP(driver, op, '117');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // イルカマンのふうせん
  await addEffect(driver, 1, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // ハッサムのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // サーフゴーのHP90
  await inputRemainHP(driver, me, '90');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのどろぼう
  await tapMove(driver, me, 'どろぼう', false);
  // サーフゴーのHP20
  await inputRemainHP(driver, me, '20');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));
  // ハッサムのHP27
  await inputRemainHP(driver, op, '27');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのどろぼう
  await tapMove(driver, me, 'どろぼう', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));
  // サーフゴーひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // イルカマンのHP50
  await inputRemainHP(driver, me, '50');
  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // 急所に命中
  await tapCritical(driver, op);
  // ハッサムのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP35
  await inputRemainHP(driver, op, '35');
  // ハッサムひんし->カイリューに交代
  await changePokemon(driver, me, 'カイリュー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // カイリューのHP114
  await inputRemainHP(driver, op, '114');
  // イルカマンのHP20
  await inputRemainHP(driver, op, '20');
  // カイリューのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // カイリューのHP24
  await inputRemainHP(driver, op, '24');
  // イルカマンのHP0
  await inputRemainHP(driver, op, '0');
  // カイリューのじしん
  await tapMove(driver, me, 'じしん', false);
  // 外れる
  await tapHit(driver, me);
  // イルカマンひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // イルカマンのHP0
  await inputRemainHP(driver, me, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // サザンドラのHP80
  await inputRemainHP(driver, me, '80');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // カイリューのHP0
  await inputRemainHP(driver, op, '0');
  // カイリューひんし->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // オドリドリのテラスタル
  await inputTerastal(driver, me, '');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP82
  await inputRemainHP(driver, op, '82');
  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オドリドリのHP11
  await inputRemainHP(driver, me, '11');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP101
  await inputRemainHP(driver, op, '101');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // サザンドラのHP50
  await inputRemainHP(driver, me, '50');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP56
  await inputRemainHP(driver, op, '56');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オドリドリのHP132
  await inputRemainHP(driver, me, '132');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP85
  await inputRemainHP(driver, op, '85');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オドリドリのHP151
  await inputRemainHP(driver, me, '151');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP105
  await inputRemainHP(driver, op, '105');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // サザンドラのHP20
  await inputRemainHP(driver, me, '20');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // オドリドリのHP58
  await inputRemainHP(driver, op, '58');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハッサム戦4
Future<void> test46_4(
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
    battleName: 'もこうハッサム戦4',
    ownPartyname: '46もこハッサム',
    opponentName: 'ラビィ',
    pokemon1: 'ムウマージ',
    pokemon2: 'ハラバリー',
    pokemon3: 'ミミズズ',
    pokemon4: 'バンギラス',
    pokemon5: 'ハカドッグ',
    pokemon6: 'エクスレッグ',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'ねつじょう/',
      ownPokemon2: 'もこハッサム/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'ムウマージ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ムウマージ->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // ムウマージのすなおこし
  await addEffect(driver, 1, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // バンギラスのHP97
  await inputRemainHP(driver, me, '97');
  // ムウマージのたべのこし
  await addEffect(driver, 4, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->ハッサムに交代
  await changePokemon(driver, me, 'ハッサム', true);
  // バンギラスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', true);
  // ハッサムのHP125
  await inputRemainHP(driver, op, '125');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->ハカドッグに交代
  await changePokemon(driver, op, 'ハカドッグ', true);
  // ハッサムのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // ハカドッグのHP90
  await inputRemainHP(driver, me, '90');
  // バンギラスのゴツゴツメット
  await addEffect(driver, 3, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハッサム->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ハカドッグのナイトヘッド
  await tapMove(driver, op, 'ナイトヘッド', true);
  // ヘルガーのHP92
  await inputRemainHP(driver, op, '92');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグ->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // バンギラスのHP95
  await inputRemainHP(driver, me, '95');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->ハッサムに交代
  await changePokemon(driver, me, 'ハッサム', true);
  // バンギラスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // ハッサムのHP0
  await inputRemainHP(driver, op, '0');
  // ハッサムひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->ハカドッグに交代
  await changePokemon(driver, op, 'ハカドッグ', true);
  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // マリルリのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ハカドッグのHP5
  await inputRemainHP(driver, me, '5');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグ->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // バンギラスのHP60
  await inputRemainHP(driver, me, '60');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // バンギラスのまもる
  await tapMove(driver, op, 'まもる', true);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // バンギラスのHP66
  await inputRemainHP(driver, me, '');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->ハカドッグに交代
  await changePokemon(driver, op, 'ハカドッグ', true);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ハカドッグのHP0
  await inputRemainHP(driver, me, '0');
  // ハカドッグひんし->ムウマージに交代
  await changePokemon(driver, op, 'ムウマージ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ムウマージのサイコショック
  await tapMove(driver, op, 'サイコショック', true);
  // 外れる
  await tapHit(driver, op);
  // ヘルガーのHP83
  await inputRemainHP(driver, op, '');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ムウマージ->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // バンギラスのHP65
  await inputRemainHP(driver, me, '65');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // バンギラスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', false);
  // 外れる
  await tapHit(driver, op);
  // ヘルガーのHP74
  await inputRemainHP(driver, op, '');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // バンギラスのHP65
  await inputRemainHP(driver, me, '65');
  // バンギラスはひるんで技がだせない
  await driver.tap(find.text('バンギラスはひるんで技がだせない'));
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // バンギラスのHP60
  await inputRemainHP(driver, me, '60');
  // バンギラスはひるんで技がだせない
  await driver.tap(find.text('バンギラスはひるんで技がだせない'));
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // バンギラスのまもる
  await tapMove(driver, op, 'まもる', false);
  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // バンギラスのHP60
  await inputRemainHP(driver, me, '60');
  // バンギラスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // バンギラスのHP20
  await inputRemainHP(driver, me, '20');
  // バンギラスのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // 急所に命中
  await tapCritical(driver, op);
  // マリルリのHP38
  await inputRemainHP(driver, op, '38');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // バンギラスのHP0
  await inputRemainHP(driver, me, '0');
  // バンギラスひんし->ムウマージに交代
  await changePokemon(driver, op, 'ムウマージ', false);
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // ムウマージのサイコショック
  await tapMove(driver, op, 'サイコショック', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ストリンダー戦1
Future<void> test47_1(
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
    battleName: 'もこうストリンダー戦1',
    ownPartyname: '47もこリンダー',
    opponentName: 'すしくいねぇ',
    pokemon1: 'ラウドボーン',
    pokemon2: 'セグレイブ',
    pokemon3: 'キノガッサ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ドヒドイデ',
    pokemon6: 'サーフゴー',
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこティフ/',
      ownPokemon2: 'おとこ/',
      ownPokemon3: 'もこニンフィア2/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // マフィティフのHP0
  await inputRemainHP(driver, op, '0');
  // マフィティフひんし->ストリンダーに交代
  await changePokemon(driver, me, 'ストリンダー(ハイなすがた)', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);
  // サーフゴー->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ストリンダーのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);
  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // ロトムのHP40
  await inputRemainHP(driver, me, '40');
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // ストリンダーのHP109
  await inputRemainHP(driver, op, '109');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);
  // ストリンダーのテラスタル
  await inputTerastal(driver, me, '');
  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // サーフゴーのHP10
  await inputRemainHP(driver, me, '10');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // 外れる
  await tapHit(driver, op);
  // ストリンダーのHP109
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);
  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);
  // ストリンダーのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ストリンダー戦2
Future<void> test47_2(
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
    battleName: 'もうストリンダー戦2',
    ownPartyname: '47もこリンダー',
    opponentName: 'なにわづ',
    pokemon1: 'カイリュー',
    pokemon2: 'ドラパルト',
    pokemon3: 'サーフゴー',
    pokemon4: 'ドドゲザン',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ヘイラッシャ',
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'おとこ/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ストリンダーのHP71
  await inputRemainHP(driver, op, '71');
  // ドラパルトのいのちのたま
  await addEffect(driver, 1, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ストリンダーのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのテラスタル
  await inputTerastal(driver, me, '');
  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // ドラパルトのHP60
  await inputRemainHP(driver, me, '60');
  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ストリンダーのHP71
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // ストリンダーのHP0
  await inputRemainHP(driver, op, '0');
  // ストリンダーひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // グレンアルマのサイコフィールド
  await tapMove(driver, me, 'サイコフィールド', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのワイドフォース
  await tapMove(driver, me, 'ワイドフォース', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // カイリューのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ストリンダー戦3
Future<void> test47_3(
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
    battleName: 'もこうストリンダー戦3',
    ownPartyname: '47もこリンダー',
    opponentName: 'つた',
    pokemon1: 'ウルガモス',
    pokemon2: 'パーモット',
    pokemon3: 'ドドゲザン',
    pokemon4: 'ドラパルト',
    pokemon5: 'マリルリ',
    pokemon6: 'カイリュー',
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'おとこ/',
      ownPokemon2: 'もこアルマ2/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'カイリュー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ストリンダー->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', true);
  // ボーマンダのHP162
  await inputRemainHP(driver, op, '162');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // カイリューのHP65
  await inputRemainHP(driver, me, '65');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('9');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('0');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('6');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('68');
  // カイリューのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // カイリューのHP95
  await inputRemainHP(driver, me, '95');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // カイリューのHP95
  await inputRemainHP(driver, me, '95');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ボーマンダひんし->ストリンダーに交代
  await changePokemon(driver, me, 'ストリンダー(ハイなすがた)', false);
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, op);
  // ストリンダーのHP170
  await inputRemainHP(driver, op, '');
  // ストリンダーのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // カイリューのHP65
  await inputRemainHP(driver, me, '65');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ストリンダーのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP45
  await inputRemainHP(driver, me, '45');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP95
  await inputRemainHP(driver, op, '95');
  // ストリンダーのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->パーモットに交代
  await changePokemon(driver, op, 'パーモット', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ストリンダー->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', true);
  // パーモットのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // グレンアルマのHP108
  await inputRemainHP(driver, op, '108');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // パーモットのでんこうそうげき
  await tapMove(driver, op, 'でんこうそうげき', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // グレンアルマひんし->ストリンダーに交代
  await changePokemon(driver, me, 'ストリンダー(ハイなすがた)', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // ドドゲザンのHP70
  await inputRemainHP(driver, me, '70');
  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', true);
  // ストリンダーのHP49
  await inputRemainHP(driver, op, '49');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ドドゲザンのHP30
  await inputRemainHP(driver, me, '30');
  // ストリンダーのHP93
  await inputRemainHP(driver, me, '93');
  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', false);
  // ストリンダーのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'つたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ストリンダー戦4
Future<void> test47_4(
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
    battleName: 'もこうストリンダー戦4',
    ownPartyname: '47もこリンダー',
    opponentName: 'sakura',
    pokemon1: 'ガブリアス',
    pokemon2: 'サーフゴー',
    pokemon3: 'アーマーガア',
    pokemon4: 'クエスパトラ',
    pokemon5: 'マリルリ',
    pokemon6: 'ウルガモス',
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'おとこ/',
      ownPokemon2: 'もこニンフィア2/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'クエスパトラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのテラスタル
  await inputTerastal(driver, me, '');
  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', true);
  // ストリンダーのHP91
  await inputRemainHP(driver, op, '91');
  // ストリンダーのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // クエスパトラのHP1
  await inputRemainHP(driver, me, '1');
  // クエスパトラのきあいのタスキ
  await addEffect(driver, 4, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ストリンダー->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ニンフィアのHP148
  await inputRemainHP(driver, op, '148');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラ->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アーマーガア->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ガブリアスのHP10
  await inputRemainHP(driver, me, '10');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // 急所に命中
  await tapCritical(driver, op);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->ストリンダーに交代
  await changePokemon(driver, me, 'ストリンダー(ハイなすがた)', false);
  // ガブリアスひんし->クエスパトラに交代
  await changePokemon(driver, op, 'クエスパトラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ストリンダーのHP13
  await inputRemainHP(driver, op, '13');
  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // クエスパトラのHP0
  await inputRemainHP(driver, me, '0');
  // クエスパトラひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ストリンダーのオーバードライブ
  await tapMove(driver, me, 'オーバードライブ', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ストリンダー戦5
Future<void> test47_5(
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
    battleName: 'もこうストリンダー戦5',
    ownPartyname: '47もこリンダー',
    opponentName: 'たぐち',
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
      ownPokemon1: 'もこリククラゲ/',
      ownPokemon2: 'おとこ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'コノヨザル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // リククラゲのHP89
  await inputRemainHP(driver, op, '89');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('8');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('0');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('1');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('11');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('116');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // リククラゲ->ストリンダーに交代
  await changePokemon(driver, me, 'ストリンダー(ハイなすがた)', true);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // 急所に命中
  await tapCritical(driver, op);
  // ストリンダーのHP0
  await inputRemainHP(driver, op, '0');
  // ストリンダーひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', false);
  // ボーマンダのHP85
  await inputRemainHP(driver, op, '85');
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('106');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サーフゴー->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', true);
  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // コノヨザルのHP40
  await inputRemainHP(driver, me, '40');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // コノヨザルひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('13');
  // ガブリアスのさめはだ
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'あく');
  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP2
  await inputRemainHP(driver, me, '2');
  // ボーマンダひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // 外れる
  await tapHit(driver, op);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ケケンカニ戦1
Future<void> test48_1(
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
    battleName: 'もこうケケンカニ戦1',
    ownPartyname: '48もこンカニ',
    opponentName: 'バイオレット',
    pokemon1: 'ドラパルト',
    pokemon2: 'カイリュー',
    pokemon3: 'ガブリアス',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'ジバコイル',
    pokemon6: 'サーフゴー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこンカニ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', true);
  // ケケンカニのHP174
  await inputRemainHP(driver, op, '174');
  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ジバコイルのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ケケンカニのHP122
  await inputRemainHP(driver, op, '122');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP201
  await inputRemainHP(driver, me, '201');
  // ジバコイルのゴツゴツメット
  await addEffect(driver, 3, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ジバコイルひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ドラパルトのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ドラパルトのHP45
  await inputRemainHP(driver, me, '45');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // ケケンカニのHP26
  await inputRemainHP(driver, op, '26');
  // ドラパルトのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP100
  await inputRemainHP(driver, me, '100');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ケケンカニ戦2
Future<void> test48_2(
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
    battleName: 'もこうケケンカニ戦2',
    ownPartyname: '48もこンカニ2',
    opponentName: 'さざなみ',
    pokemon1: 'ガブリアス',
    pokemon2: 'マリルリ',
    pokemon3: 'ジバコイル',
    pokemon4: 'マスカーニャ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'サザンドラ',
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこンカニ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこエーフィ/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ケケンカニのHP186
  await inputRemainHP(driver, op, '186');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // サザンドラのHP100
  await inputRemainHP(driver, me, '');
  // ケケンカニのHP186
  await inputRemainHP(driver, me, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニ->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', true);
  // ラウドボーンのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // エーフィのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // マリルリのHP70
  await inputRemainHP(driver, me, '70');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エーフィのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // マリルリのHP40
  await inputRemainHP(driver, me, '40');
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // エーフィひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, op, 'アクアジェット', true);
  // パーモットのHP81
  await inputRemainHP(driver, op, '81');
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // エーフィを復活
  await changePokemon(driver, me, 'エーフィ', false);
  // ラウドボーンのおにび
  await tapMove(driver, op, 'おにび', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // ラウドボーンのHP98
  await inputRemainHP(driver, me, '98');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // ラウドボーンのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // パーモットひんし->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', true);
  // ラウドボーン->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', false);
  // ケケンカニのHP170
  await inputRemainHP(driver, op, '170');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // サザンドラのHP100
  await inputRemainHP(driver, me, '');
  // ケケンカニのHP170
  await inputRemainHP(driver, me, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ケケンカニのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'どく');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ケケンカニのHP73
  await inputRemainHP(driver, op, '73');
  // ケケンカニはひるんで技がだせない
  await driver.tap(find.text('ケケンカニはひるんで技がだせない'));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'さざなみの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ケケンカニ戦3
Future<void> test48_3(
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
    battleName: 'もこうケケンカニ戦3',
    ownPartyname: '48もこンカニ',
    opponentName: 'あきら',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ソウブレイズ',
    pokemon3: 'サザンドラ',
    pokemon4: 'アーマーガア',
    pokemon5: 'サーフゴー',
    pokemon6: 'セグレイブ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこンカニ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこニンフィア3/',
      opponentPokemon: 'ソウブレイズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, op, 'むねんのつるぎ', true);
  // ケケンカニのHP150
  await inputRemainHP(driver, op, '150');
  // ソウブレイズのHP100
  await inputRemainHP(driver, op, '');
  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ケケンカニのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サザンドラのHP70
  await inputRemainHP(driver, me, '70');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ケケンカニのHP56
  await inputRemainHP(driver, op, '56');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // サザンドラのHP30
  await inputRemainHP(driver, me, '30');
  // ケケンカニのHP142
  await inputRemainHP(driver, me, '142');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ケケンカニのHP49
  await inputRemainHP(driver, op, '49');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP67
  await inputRemainHP(driver, me, '67');
  // サザンドラひんし->ソウブレイズに交代
  await changePokemon(driver, op, 'ソウブレイズ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // ケケンカニのHP12
  await inputRemainHP(driver, op, '12');
  // ケケンカニのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ソウブレイズのHP1
  await inputRemainHP(driver, me, '1');
  // ソウブレイズのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ソウブレイズのくだけるよろい
  await addEffect(driver, 3, op, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // セグレイブのHP10
  await inputRemainHP(driver, me, '10');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ケケンカニ戦4
Future<void> test48_4(
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
    battleName: 'もこうケケンカニ戦4',
    ownPartyname: '48もこンカニ',
    opponentName: 'あきと',
    pokemon1: 'サザンドラ',
    pokemon2: 'キラフロル',
    pokemon3: 'アーマーガア',
    pokemon4: 'ニンフィア',
    pokemon5: 'セグレイブ',
    pokemon6: 'ポットデス',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこンカニ/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'キラフロル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エーフィのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('きあいのタスキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ')));
  // キラフロルのヘドロウェーブ
  await tapMove(driver, op, 'ヘドロウェーブ', true);
  // エーフィのHP1
  await inputRemainHP(driver, op, '1');
  // エーフィのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルひんし->ポットデスに交代
  await changePokemon(driver, op, 'ポットデス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ポットデスのHP60
  await inputRemainHP(driver, me, '60');
  // ポットデスはとくぼうが下がった
  await driver.tap(find.text('ポットデスはとくぼうが下がった'));
  // ポットデスのしろいハーブ
  await addEffect(driver, 1, op, 'しろいハーブ');
  await driver.tap(find.text('OK'));
  // ポットデスのからをやぶる
  await tapMove(driver, op, 'からをやぶる', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // エーフィひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのアシストパワー
  await tapMove(driver, op, 'アシストパワー', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // パーモットのきあいのタスキ
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // ポットデスのHP0
  await inputRemainHP(driver, me, '0');
  // ポットデスひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのテラスタル
  await inputTerastal(driver, op, 'ドラゴン');
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // アーマーガアのHP99
  await inputRemainHP(driver, me, '99');
  // アーマーガアのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // パーモットひんし->ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ケケンカニのHP122
  await inputRemainHP(driver, op, '122');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ケケンカニのHP59
  await inputRemainHP(driver, op, '59');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ケケンカニのHP49
  await inputRemainHP(driver, op, '49');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // アーマーガアのHP75
  await inputRemainHP(driver, me, '75');
  // ケケンカニのHP75
  await inputRemainHP(driver, me, '75');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // アーマーガアのHP10
  await inputRemainHP(driver, me, '10');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'あきとの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ベラカス戦1
Future<void> test49_1(
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
    battleName: 'もこうベラカス戦1',
    ownPartyname: '49もこカス',
    opponentName: 'SEKI',
    pokemon1: 'パーモット',
    pokemon2: 'ドドゲザン',
    pokemon3: 'ゲンガー',
    pokemon4: 'ドラパルト',
    pokemon5: 'カイリュー',
    pokemon6: 'キノガッサ',
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
      ownPokemon1: 'もこンカニ2/',
      ownPokemon2: 'もこカス/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'ドドゲザン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ドドゲザンのでんじは
  await tapMove(driver, op, 'でんじは', true);
  await tapSuccess(driver, op);
  // ドドゲザンのヨプのみ
  await addEffect(driver, 2, op, 'ヨプのみ');
  await driver.tap(find.text('OK'));
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ドドゲザンのHP10
  await inputRemainHP(driver, me, '10');
  // ケケンカニのHP201
  await inputRemainHP(driver, me, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ケケンカニのかみなりパンチ
  await tapMove(driver, me, 'かみなりパンチ', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ケケンカニのHP40
  await inputRemainHP(driver, op, '40');
  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // ドラパルトのHP50
  await inputRemainHP(driver, me, '50');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // カイリューのHP95
  await inputRemainHP(driver, me, '95');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // カイリューのHP60
  await inputRemainHP(driver, me, '60');
  // カイリューはひるんで技がだせない
  await driver.tap(find.text('カイリューはひるんで技がだせない'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // カイリューのHP30
  await inputRemainHP(driver, me, '30');
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->ベラカスに交代
  await changePokemon(driver, me, 'ベラカス', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP80
  await inputRemainHP(driver, op, '80');
  // ベラカスのトリックルーム
  await tapMove(driver, me, 'トリックルーム', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ベラカスのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // ケケンカニを復活
  await changePokemon(driver, me, 'ケケンカニ', false);
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ベラカス->ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', true);
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP94
  await inputRemainHP(driver, me, '94');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ベラカス戦2
Future<void> test49_2(
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
    battleName: 'もこうベラカス戦2',
    ownPartyname: '49もこカス',
    opponentName: 'リュウ',
    pokemon1: 'ウルガモス',
    pokemon2: 'サザンドラ',
    pokemon3: 'カイリュー',
    pokemon4: 'セグレイブ',
    pokemon5: 'サーフゴー',
    pokemon6: 'デカヌチャン',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこンカニ2/',
      ownPokemon2: 'もこカス/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'カイリュー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // カイリューのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ロトムのトリック
  await tapMove(driver, me, 'トリック', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // ウルガモスのHP40
  await inputRemainHP(driver, me, '40');
  // ベラカスに交代
  await changePokemon(driver, me, 'ベラカス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ベラカスのトリックルーム
  await tapMove(driver, me, 'トリックルーム', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ベラカスのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // ケケンカニを復活
  await changePokemon(driver, me, 'ケケンカニ', false);
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // ベラカスのHP0
  await inputRemainHP(driver, op, '0');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // ベラカスひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', false);
  // ウルガモスひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ケケンカニのかみなりパンチ
  await tapMove(driver, me, 'かみなりパンチ', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのきあいだま
  await tapMove(driver, op, 'きあいだま', true);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', false);
  // カイリューのHP40
  await inputRemainHP(driver, me, '40');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ベラカス戦3
Future<void> test49_3(
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
    battleName: 'もこうベラカス戦3',
    ownPartyname: '49もこカス',
    opponentName: 'シラタキ',
    pokemon1: 'サーナイト',
    pokemon2: 'ハッサム',
    pokemon3: 'カイリュー',
    pokemon4: 'ドラパルト',
    pokemon5: 'キノガッサ',
    pokemon6: 'パルシェン',
    sex1: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこンカニ2/',
      ownPokemon3: 'もこカス/',
      opponentPokemon: 'パルシェン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // パルシェンのテラスタル
  await inputTerastal(driver, op, 'こおり');
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // パルシェンのHP55
  await inputRemainHP(driver, me, '55');
  // ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', false);
  // パルシェンのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // マスカーニャのHP122
  await inputRemainHP(driver, op, '122');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // パルシェンのロックブラスト
  await tapMove(driver, op, 'ロックブラスト', true);
  // 0回命中
  await setHitCount(driver, op, 0);
  // ケケンカニのHP171
  await inputRemainHP(driver, op, '');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // パルシェンのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP136
  await inputRemainHP(driver, me, '136');
  // パルシェンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->ベラカスに交代
  await changePokemon(driver, me, 'ベラカス', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', false);
  // ベラカスのHP50
  await inputRemainHP(driver, op, '50');
  // ベラカスのトリックルーム
  await tapMove(driver, me, 'トリックルーム', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ベラカスのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // ケケンカニを復活
  await changePokemon(driver, me, 'ケケンカニ', false);
  // ドラパルトのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', false);
  // ベラカスのHP0
  await inputRemainHP(driver, op, '0');
  // ベラカスひんし->ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのアイスハンマー
  await tapMove(driver, me, 'アイスハンマー', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->キノガッサに交代
  await changePokemon(driver, op, 'キノガッサ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', true);
  // ケケンカニのHP8
  await inputRemainHP(driver, op, '8');
  // キノガッサのHP1
  await inputRemainHP(driver, me, '1');
  // ケケンカニのHP76
  await inputRemainHP(driver, me, '76');
  // キノガッサのきあいのタスキ
  await addEffect(driver, 4, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', false);
  // ケケンカニのHP0
  await inputRemainHP(driver, op, '0');
  // ケケンカニひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'シラタキの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ベラカス戦4
Future<void> test49_4(
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
    battleName: 'もこうベラカス戦4',
    ownPartyname: '49もこカス',
    opponentName: 'ミルフィーユ',
    pokemon1: 'カイリュー',
    pokemon2: 'ヌメルゴン',
    pokemon3: 'オーロンゲ',
    pokemon4: 'コノヨザル',
    pokemon5: 'マスカーニャ',
    pokemon6: 'ヘイラッシャ',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこンカニ2/',
      ownPokemon2: 'もこカス/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ケケンカニのHP158
  await inputRemainHP(driver, op, '158');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('いのちのたま');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('いのちのたま')));
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // マスカーニャのHP1
  await inputRemainHP(driver, me, '1');
  // ケケンカニのHP201
  await inputRemainHP(driver, me, '201');
  // マスカーニャのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // ケケンカニのHP54
  await inputRemainHP(driver, op, '54');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニのHP55
  await inputRemainHP(driver, me, '55');
  // マスカーニャひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニ->ベラカスに交代
  await changePokemon(driver, me, 'ベラカス', true);
  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', true);
  // ベラカスのHP12
  await inputRemainHP(driver, op, '12');
  // ベラカスのトリックルーム
  await tapMove(driver, me, 'トリックルーム', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ベラカスのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // コノヨザルのHP45
  await inputRemainHP(driver, me, '45');
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // ベラカスのHP0
  await inputRemainHP(driver, op, '0');
  // ベラカスひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // ロトムのHP10
  await inputRemainHP(driver, op, '10');
  // ロトムのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // ケケンカニに交代
  await changePokemon(driver, me, 'ケケンカニ', false);
  // コノヨザルひんし->ヌメルゴンに交代
  await changePokemon(driver, op, 'ヌメルゴン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのテラスタル
  await inputTerastal(driver, me, '');
  // ヌメルゴンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ケケンカニのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // ヌメルゴンのHP70
  await inputRemainHP(driver, me, '70');
  // ケケンカニのHP85
  await inputRemainHP(driver, me, '85');
  // ヌメルゴンのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ケケンカニのHP1
  await inputRemainHP(driver, op, '1');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ケケンカニのかみなりパンチ
  await tapMove(driver, me, 'かみなりパンチ', false);
  // ヌメルゴンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アチゲータ戦1
Future<void> test50_1(
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
    battleName: 'もこうアチゲータ戦1',
    ownPartyname: '50もこゲータ',
    opponentName: 'ショウ',
    pokemon1: 'ブラッキー',
    pokemon2: 'ドドゲザン',
    pokemon3: 'オノノクス',
    pokemon4: 'アーマーガア',
    pokemon5: 'マスカーニャ',
    pokemon6: 'ドラパルト',
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ2/',
      ownPokemon2: 'もこゲータ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '1');
  // イキリンコのHP105
  await inputRemainHP(driver, me, '105');
  // ドラパルトのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await tapSuccess(driver, op);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドラパルトのHP1
  await inputRemainHP(driver, op, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // アーマーガアのHP85
  await inputRemainHP(driver, me, '85');
  // イキリンコのHP80
  await inputRemainHP(driver, me, '80');
  // ドラパルトのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // イキリンコのHP89
  await inputRemainHP(driver, me, '89');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イキリンコ->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', true);
  // アーマーガア->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', true);
  // アチゲータのHP188
  await inputRemainHP(driver, op, '');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // アチゲータのHP143
  await inputRemainHP(driver, op, '143');
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '');
  // アチゲータのHP143
  await inputRemainHP(driver, op, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // アチゲータのHP100
  await inputRemainHP(driver, op, '100');
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP188
  await inputRemainHP(driver, me, '188');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '');
  // アチゲータのHP188
  await inputRemainHP(driver, op, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // アチゲータのHP140
  await inputRemainHP(driver, op, '140');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ドラパルトのプレッシャー
  await addEffect(driver, 3, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // アチゲータのHP113
  await inputRemainHP(driver, op, '113');
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // アチゲータのHP87
  await inputRemainHP(driver, op, '87');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // アーマーガアのHP55
  await inputRemainHP(driver, me, '55');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // アチゲータのHP60
  await inputRemainHP(driver, op, '60');
  // アチゲータのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アチゲータ戦2
Future<void> test50_2(
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
    battleName: 'もこうアチゲータ戦2',
    ownPartyname: '50もこゲータ',
    opponentName: 'せろりめん',
    pokemon1: 'ミミズズ',
    pokemon2: 'フラージェス',
    pokemon3: 'ラウドボーン',
    pokemon4: 'ドドゲザン',
    pokemon5: 'ミガルーサ',
    pokemon6: 'ドラパルト',
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパモ/',
      ownPokemon2: 'もこゲータ/',
      ownPokemon3: 'もこリンコ2/',
      opponentPokemon: 'フラージェス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // パーモット->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', true);
  // フラージェスのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // 急所に命中
  await tapCritical(driver, op);
  // アチゲータのHP124
  await inputRemainHP(driver, op, '124');
  // アチゲータはとくこうが下がった
  await driver.tap(find.text('アチゲータはとくこうが下がった'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // フラージェスのめいそう
  await tapMove(driver, op, 'めいそう', true);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // フラージェスのHP95
  await inputRemainHP(driver, me, '95');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フラージェスのスキルスワップ
  await tapMove(driver, op, 'スキルスワップ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // フラワーベール
  {
    await driver.tap(find.byValueKey('SelectAbilityInputOpponent'));
    await driver.enterText('フラワーベール');
    final selectListTile = find.ancestor(
      matching: find.byType('ListTile'),
      of: find.text('フラワーベール'),
      firstMatchOnly: true,
    );
    await driver.tap(selectListTile);
  }
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // フラージェスのスキルスワップ
  await tapMove(driver, op, 'スキルスワップ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP188
  await inputRemainHP(driver, me, '188');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // フラージェスのスキルスワップ
  await tapMove(driver, op, 'スキルスワップ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // フラージェスのHP58
  await inputRemainHP(driver, me, '58');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // フラージェスのスキルスワップ
  await tapMove(driver, op, 'スキルスワップ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // アチゲータのあくび
  await tapMove(driver, me, 'あくび', false);
  // バインド(ダメージ/終了)編集
  await tapEffect(driver, 'バインド(ダメージ/終了)');
  // 効果が切れた
  await driver.tap(find.byValueKey('AilmentEffectDropDownMenu'));
  await driver.tap(find.text('効果が切れた'));
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // フラージェス->ミミズズに交代
  await changePokemon(driver, op, 'ミミズズ', true);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ミミズズのHP80
  await inputRemainHP(driver, me, '80');
  // フラージェスのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // アチゲータ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // ミミズズのしっぽきり
  await tapMove(driver, op, 'しっぽきり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミズズのHP24
  await inputRemainHP(driver, op, '24');
  // ミガルーサに交代
  await changePokemon(driver, op, 'ミガルーサ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ミガルーサのHP100
  await inputRemainHP(driver, me, '');
  // ミガルーサのみをけずる
  await tapMove(driver, op, 'みをけずる', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミガルーサのHP50
  await inputRemainHP(driver, op, '50');
  // ミガルーサのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのアシストパワー
  await tapMove(driver, op, 'アシストパワー', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // パーモットのきあいのタスキ
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // ミガルーサのHP0
  await inputRemainHP(driver, me, '0');
  // ミガルーサひんし->フラージェスに交代
  await changePokemon(driver, op, 'フラージェス', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // パーモットのテラスタル
  await inputTerastal(driver, me, '');
  // フラージェスのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // フラージェスのHP2
  await inputRemainHP(driver, me, '2');
  // フラージェスのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', false);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->イキリンコに交代
  await changePokemon(driver, me, 'イキリンコ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // TODO:そもそもまねっこだった＆ものまね->ムーンフォース選択で例外発生
  // イキリンコのものまね
  await tapMove(driver, me, 'ものまね', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アチゲータ戦3
Future<void> test50_3(
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
    battleName: 'もこうアチゲータ戦3',
    ownPartyname: '50もこゲータ2',
    opponentName: 'るかちょ',
    pokemon1: 'ペリッパー',
    pokemon2: 'フローゼル',
    pokemon3: 'デカヌチャン',
    pokemon4: 'サザンドラ',
    pokemon5: 'ジバコイル',
    pokemon6: 'ソウブレイズ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこエーフィ/',
      ownPokemon3: 'もこゲータ/',
      opponentPokemon: 'ソウブレイズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', true);
  // ソウブレイズのあめふらし
  await addEffect(driver, 1, op, 'あめふらし');
  await driver.tap(find.text('OK'));
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ペリッパーのHP90
  await inputRemainHP(driver, me, '90');
  // エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ペリッパーのHP0
  await inputRemainHP(driver, me, '0');
  // ペリッパーひんし->フローゼルに交代
  await changePokemon(driver, op, 'フローゼル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのテラスタル
  await inputTerastal(driver, op, 'みず');
  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // エーフィのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルのHP75
  await inputRemainHP(driver, op, '75');
  // エーフィひんし->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのテラスタル
  await inputTerastal(driver, me, '');
  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // アチゲータのHP104
  await inputRemainHP(driver, op, '104');
  // フローゼルのHP65
  await inputRemainHP(driver, op, '65');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // フローゼルのHP60
  await inputRemainHP(driver, me, '60');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // アチゲータのHP15
  await inputRemainHP(driver, op, '15');
  // フローゼルのHP30
  await inputRemainHP(driver, op, '30');
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP109
  await inputRemainHP(driver, me, '109');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // アチゲータのHP46
  await inputRemainHP(driver, op, '46');
  // フローゼルのHP0
  await inputRemainHP(driver, op, '0');
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP140
  await inputRemainHP(driver, me, '140');
  // フローゼルひんし->ソウブレイズに交代
  await changePokemon(driver, op, 'ソウブレイズ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アチゲータ戦4
Future<void> test50_4(
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
    battleName: 'もこうアチゲータ戦4',
    ownPartyname: '50もこゲータ',
    opponentName: 'いのっち',
    pokemon1: 'デカヌチャン',
    pokemon2: 'カイリュー',
    pokemon3: 'ウインディ',
    pokemon4: 'ドドゲザン',
    pokemon5: 'トリトドン',
    pokemon6: 'ノココッチ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこゲータ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこニンフィア3/',
      opponentPokemon: 'ノココッチ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // アチゲータ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // ノココッチのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ノココッチのHP90
  await inputRemainHP(driver, me, '90');
  // ノココッチ->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // ノココッチのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // パーモットひんし->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ノココッチに交代
  await changePokemon(driver, op, 'ノココッチ', true);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ノココッチのHP90
  await inputRemainHP(driver, me, '90');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのテラスタル
  await inputTerastal(driver, me, '');
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  await tapSuccess(driver, me);
  // ノココッチのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', true);
  // アチゲータのHP162
  await inputRemainHP(driver, op, '162');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ノココッチのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // アチゲータのHP136
  await inputRemainHP(driver, op, '136');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのあくび
  await tapMove(driver, me, 'あくび', false);
  // ノココッチのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // 外れる
  await tapHit(driver, op);
  // アチゲータのHP136
  await inputRemainHP(driver, op, '');
  // ノココッチのオボンのみ
  await addEffect(driver, 4, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP188
  await inputRemainHP(driver, me, '188');
  // ノココッチのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // 外れる
  await tapHit(driver, op);
  // アチゲータのHP188
  await inputRemainHP(driver, op, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ノココッチ->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP95
  await inputRemainHP(driver, me, '95');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // アチゲータ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // カイリューのアンコール
  await tapMove(driver, op, 'アンコール', true);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ニンフィアのHP74
  await inputRemainHP(driver, op, '74');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // カイリューのHP50
  await inputRemainHP(driver, me, '50');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ドドゲザンのHP65
  await inputRemainHP(driver, me, '65');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', true);
  // ドドゲザンのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // アチゲータのHP165
  await inputRemainHP(driver, op, '165');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', true);
  // アチゲータのHP107
  await inputRemainHP(driver, op, '107');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ドドゲザンのHP65
  await inputRemainHP(driver, me, '');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', false);
  // アチゲータのHP46
  await inputRemainHP(driver, op, '46');
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP140
  await inputRemainHP(driver, me, '140');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザン->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // カイリューのHP35
  await inputRemainHP(driver, me, '35');
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP188
  await inputRemainHP(driver, me, '188');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  await tapSuccess(driver, me);
  // カイリューひんし->ノココッチに交代
  await changePokemon(driver, op, 'ノココッチ', false);
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // アチゲータ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン21へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ノココッチのHP30
  await inputRemainHP(driver, me, '30');
  // ノココッチのばくおんぱ
  await tapMove(driver, op, 'ばくおんぱ', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', false);
  // ターン22へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ノココッチのHP15
  await inputRemainHP(driver, me, '10');
  // ノココッチのばくおんぱ
  await tapMove(driver, op, 'ばくおんぱ', false);
  // アチゲータのHP71
  await inputRemainHP(driver, op, '71');
  // ノココッチひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // ノココッチのそうだいしょう
  await addEffect(driver, 4, op, 'そうだいしょう');
  await driver.tap(find.text('OK'));
  // ターン23へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', false);
  // アチゲータのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'いのっちの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アチゲータ戦5
Future<void> test50_5(
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
    battleName: 'もこうアチゲータ戦5',
    ownPartyname: '50もこゲータ2',
    opponentName: 'ゴウ',
    pokemon1: 'デカヌチャン',
    pokemon2: 'カイリュー',
    pokemon3: 'サーフゴー',
    pokemon4: 'キラフロル',
    pokemon5: 'イルカマン',
    pokemon6: 'ペリッパー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこゲータ/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', true);
  // イルカマンのかたやぶり
  await addEffect(driver, 1, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // エーフィのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('ふうせん');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ふうせん')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // デカヌチャンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', true);
  // デカヌチャンのあめふらし
  await addEffect(driver, 1, op, 'あめふらし');
  await driver.tap(find.text('OK'));
  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ペリッパーのHP85
  await inputRemainHP(driver, me, '85');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ペリッパー->デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', true);
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // デカヌチャンのHP53
  await inputRemainHP(driver, me, '53');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // デカヌチャンのHP2
  await inputRemainHP(driver, me, '2');
  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // パーモットのHP99
  await inputRemainHP(driver, op, '99');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('きあいのタスキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ')));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // デカヌチャンひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのテラスタル
  await inputTerastal(driver, op, 'みず');
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', true);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', true);
  // アチゲータのテラスタル
  await inputTerastal(driver, me, '');
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ペリッパーのHP85
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ペリッパーのぼうふう
  await tapMove(driver, op, 'ぼうふう', true);
  // アチゲータのHP69
  await inputRemainHP(driver, op, '69');
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP163
  await inputRemainHP(driver, me, '163');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ペリッパーのぼうふう
  await tapMove(driver, op, 'ぼうふう', false);
  // アチゲータのHP91
  await inputRemainHP(driver, op, '91');
  // アチゲータはこんらんした
  await driver.tap(find.text('アチゲータはこんらんした'));
  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ペリッパーのHP85
  await inputRemainHP(driver, me, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ペリッパーのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // アチゲータのHP82
  await inputRemainHP(driver, op, '82');
  // イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP176
  await inputRemainHP(driver, me, '176');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // アチゲータのHP65
  await inputRemainHP(driver, op, '65');
  // イルカマンのHP90
  await inputRemainHP(driver, op, '90');
  // アチゲータは自分を攻撃した
  await tapMove(driver, me, 'ConfusionDamage', false);
  // アチゲータのHP57
  await inputRemainHP(driver, me, '57');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // アチゲータのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP80
  await inputRemainHP(driver, op, '80');
  // アチゲータひんし->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->ペリッパーに交代
  await changePokemon(driver, op, 'ペリッパー', true);
  // エーフィのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('ラムのみ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ラムのみ')));
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // あなたの勝利
  await testExistEffect(driver, 'ゴウの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// TODO: ほのおのうずは使ったポケモンが場から離れると解除？
/// アチゲータ戦6
Future<void> test50_6(
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
    battleName: 'もこうアチゲータ戦6',
    ownPartyname: '50もこゲータ2',
    opponentName: 'マメ',
    pokemon1: 'ラウドボーン',
    pokemon2: 'ハラバリー',
    pokemon3: 'サザンドラ',
    pokemon4: 'カイリュー',
    pokemon5: 'マスカーニャ',
    pokemon6: 'キラフロル',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこエーフィ/',
      ownPokemon2: 'もこゲータ/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'カイリュー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エーフィのトリック
  await tapMove(driver, me, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('ゴツゴツメット');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ゴツゴツメット')));
  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', true);
  // エーフィのHP119
  await inputRemainHP(driver, op, '119');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // エーフィのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', true);
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', true);
  // アチゲータのHP169
  await inputRemainHP(driver, op, '169');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのあくび
  await tapMove(driver, me, 'あくび', false);
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // アチゲータのHP133
  await inputRemainHP(driver, op, '133');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ハラバリーのHP98
  await inputRemainHP(driver, me, '98');
  // ハラバリーのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // アチゲータのHP0
  await inputRemainHP(driver, op, '0');
  // カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // アチゲータひんし->エーフィに交代
  await changePokemon(driver, me, 'エーフィ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // エーフィのテラスタル
  await inputTerastal(driver, me, '');
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // カイリューのアンコール
  await tapMove(driver, op, 'アンコール', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', true);
  // エーフィのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ハラバリーのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのでんきにかえる
  await addEffect(driver, 2, op, 'でんきにかえる');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // エーフィ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, op, 'パラボラチャージ', true);
  // パーモットのHP150
  await inputRemainHP(driver, op, '');
  // ハラバリーのHP70
  await inputRemainHP(driver, op, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ハラバリー->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // アチゲータを復活
  await changePokemon(driver, me, 'アチゲータ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // カイリューのHP73
  await inputRemainHP(driver, me, '73');
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', true);
  // パーモットのHP25
  await inputRemainHP(driver, op, '25');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // パーモット->アチゲータに交代
  await changePokemon(driver, me, 'アチゲータ', true);
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', false);
  // アチゲータのHP36
  await inputRemainHP(driver, op, '36');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP130
  await inputRemainHP(driver, me, '130');
  // カイリューのじしん
  await tapMove(driver, op, 'じしん', false);
  // アチゲータのHP74
  await inputRemainHP(driver, op, '74');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', true);
  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP168
  await inputRemainHP(driver, me, '168');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // ハラバリーのHP60
  await inputRemainHP(driver, me, '60');
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // アチゲータのHP149
  await inputRemainHP(driver, op, '149');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのテラスタル
  await inputTerastal(driver, op, 'でんき');
  // アチゲータのアンコール
  await tapMove(driver, me, 'アンコール', false);
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // アチゲータのHP116
  await inputRemainHP(driver, op, '116');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのなまける
  await tapMove(driver, me, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アチゲータのHP188
  await inputRemainHP(driver, me, '188');
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // アチゲータのHP140
  await inputRemainHP(driver, op, '140');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // アチゲータのほのおのうず
  await tapMove(driver, me, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, me);
  // ハラバリーのHP24
  await inputRemainHP(driver, me, '');
  // ハラバリーのアシッドボム
  await tapMove(driver, op, 'アシッドボム', false);
  // 急所に命中
  await tapCritical(driver, op);
  // アチゲータのHP27
  await inputRemainHP(driver, op, '27');
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // アチゲータ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, op, 'パラボラチャージ', false);
  // パーモットのHP25
  await inputRemainHP(driver, op, '');
  // ハラバリーのHP12
  await inputRemainHP(driver, op, '');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// アチゲータ戦1
Future<void> test50_1(
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
