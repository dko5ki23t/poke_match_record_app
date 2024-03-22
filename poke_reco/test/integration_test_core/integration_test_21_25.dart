import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ハルクジラ戦1
Future<void> test21_1(
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
    battleName: 'もこうハルクジラ戦1',
    ownPartyname: '21もこクジラ',
    opponentName: 'RENSHI',
    pokemon1: 'ドラパルト',
    pokemon2: 'マリルリ',
    pokemon3: 'ロトム(ヒートロトム)',
    pokemon4: 'サーフゴー',
    pokemon5: 'オリーヴァ',
    pokemon6: 'キョジオーン',
    sex2: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこヤドキング/',
      ownPokemon2: 'もこハルクジラ/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // ヤドキングのHP89
  await inputRemainHP(driver, op, '89');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // キョジオーンのHP25
  await inputRemainHP(driver, me, '25');
  // キョジオーンのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP75
  await inputRemainHP(driver, op, '75');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラ->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', true);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // リククラゲのHP12
  await inputRemainHP(driver, op, '12');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // リククラゲひんし->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // ヤドキングのHP41
  await inputRemainHP(driver, op, '41');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのつららおとし
  await tapMove(driver, me, 'つららおとし', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP100
  await inputRemainHP(driver, me, '');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // ハルクジラのHP0
  await inputRemainHP(driver, op, '0');
  // ハルクジラひんし->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // ヤドキングのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'RENSHIの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハルクジラ戦2
Future<void> test21_2(
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
    battleName: 'もこうハルクジラ戦2',
    ownPartyname: '21もこクジラ',
    opponentName: 'かちょー',
    pokemon1: 'ラウドボーン',
    pokemon2: 'カバルドン',
    pokemon3: 'サザンドラ',
    pokemon4: 'ハッサム',
    pokemon5: 'マリルリ',
    pokemon6: 'コノヨザル',
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこヤドキング/',
      ownPokemon2: 'もこハルクジラ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'コノヨザル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ヤドキングのメンタルハーブ
  await addEffect(driver, 1, me, 'メンタルハーブ');
  await driver.tap(find.text('OK'));
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // コノヨザルのドレインパンチ
  await tapMove(driver, op, 'ドレインパンチ', true);
  // ハルクジラのHP115
  await inputRemainHP(driver, op, '115');
  // コノヨザルのHP100
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // コノヨザルひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ハルクジラのつららおとし
  await tapMove(driver, me, 'つららおとし', false);
  // 急所に命中
  await tapCritical(driver, me);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハルクジラ戦3
Future<void> test21_3(
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
    battleName: 'もこうハルクジラ戦3',
    ownPartyname: '21もこクジラ',
    opponentName: 'トーチ',
    pokemon1: 'ミミッキュ',
    pokemon2: 'キノガッサ',
    pokemon3: 'サーフゴー',
    pokemon4: 'ロトム(ヒートロトム)',
    pokemon5: 'ガブリアス',
    pokemon6: 'マリルリ',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこヤドキング/',
      ownPokemon2: 'もこハルクジラ/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ヤドキングのHP79
  await inputRemainHP(driver, op, '79');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // ハルクジラのHP115
  await inputRemainHP(driver, op, '115');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハルクジラ戦4
Future<void> test21_4(
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
    battleName: 'もこうハルクジラ戦4',
    ownPartyname: '21もこクジラ',
    opponentName: 'maon',
    pokemon1: 'サーフゴー',
    pokemon2: 'ウルガモス',
    pokemon3: 'サザンドラ',
    pokemon4: 'オーロンゲ',
    pokemon5: 'キョジオーン',
    pokemon6: 'ドラパルト',
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこヤドキング/',
      ownPokemon2: 'もこハルクジラ/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'オーロンゲ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりハチマキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりハチマキ')));
  // ヤドキングのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ヤドキング->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', true);
  // オーロンゲのすてゼリフ
  await tapMove(driver, op, 'すてゼリフ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // リククラゲ->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ヤドキングのHP51
  await inputRemainHP(driver, op, '51');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのテラスタル
  await inputTerastal(driver, me, '');
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // サーフゴーのトリック
  await tapMove(driver, op, 'トリック', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('おおきなねっこ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('おおきなねっこ')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->オーロンゲに交代
  await changePokemon(driver, op, 'オーロンゲ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲのすてゼリフ
  await tapMove(driver, op, 'すてゼリフ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->オーロンゲに交代
  await changePokemon(driver, op, 'オーロンゲ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // オーロンゲのテラスタル
  await inputTerastal(driver, op, 'あく');
  // オーロンゲのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // ハルクジラのHP94
  await inputRemainHP(driver, op, '94');
  // ハルクジラのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // オーロンゲのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦1
Future<void> test22_1(
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
    battleName: 'もこうモトトカゲ戦1',
    ownPartyname: '22もこトカゲ',
    opponentName: 'すこや',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'キョジオーン',
    pokemon3: 'サザンドラ',
    pokemon4: 'ドラパルト',
    pokemon5: 'サーフゴー',
    pokemon6: 'モロバレル',
    sex2: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'もこニンフィア/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // モトトカゲのHP104
  await inputRemainHP(driver, op, '104');
  // ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのテラスタル
  await inputTerastal(driver, me, '');
  // モトトカゲのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('こだわりハチマキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりハチマキ')));
  // ドラパルトひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // モトトカゲのHP31
  await inputRemainHP(driver, me, '31');
  // ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // モロバレルのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  await tapSuccess(driver, op);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦2
Future<void> test22_2(
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
    battleName: 'もこうモトトカゲ戦2',
    ownPartyname: '22もこトカゲ2',
    opponentName: 'マサハル',
    pokemon1: 'ドラパルト',
    pokemon2: 'サザンドラ',
    pokemon3: 'キョジオーン',
    pokemon4: 'アーマーガア',
    pokemon5: 'モロバレル',
    pokemon6: 'サーフゴー',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこリガメ/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのテラスタル
  await inputTerastal(driver, me, '');
  // モトトカゲのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // モトトカゲのHP0
  await inputRemainHP(driver, op, '0');
  // モトトカゲひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦3
Future<void> test22_3(
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
    battleName: 'もこうモトトカゲ戦3',
    ownPartyname: '22もこトカゲ',
    opponentName: 'ナガハマ',
    pokemon1: 'キノガッサ',
    pokemon2: 'ヘイラッシャ',
    pokemon3: 'ラウドボーン',
    pokemon4: 'サーフゴー',
    pokemon5: 'サザンドラ',
    pokemon6: 'ガブリアス',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'キノガッサ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', true);
  // モトトカゲのHP0
  await inputRemainHP(driver, op, '0');
  // モトトカゲひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦4
Future<void> test22_4(
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
    battleName: 'もこうモトトカゲ戦4',
    ownPartyname: '22もこトカゲ2',
    opponentName: 'きゃべつ',
    pokemon1: 'ハッサム',
    pokemon2: 'ラウドボーン',
    pokemon3: 'クエスパトラ',
    pokemon4: 'サザンドラ',
    pokemon5: 'ドラパルト',
    pokemon6: 'カバルドン',
    sex1: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこリガメ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // モトトカゲのテラスタル
  await inputTerastal(driver, me, '');
  // モトトカゲのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ラウドボーンのHP70
  await inputRemainHP(driver, me, '70');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('たべのこし');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('たべのこし')));
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // モトトカゲのHP73
  await inputRemainHP(driver, op, '73');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // モトトカゲのHP36
  await inputRemainHP(driver, me, '36');
  // ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP151
  await inputRemainHP(driver, op, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '1');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // ヘルガーのHP151
  await inputRemainHP(driver, op, '');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦5
Future<void> test22_5(
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
    battleName: 'もこうモトトカゲ戦5',
    ownPartyname: '22もこトカゲ2',
    opponentName: 'アルラウネ',
    pokemon1: 'ドドゲザン',
    pokemon2: 'ニンフィア',
    pokemon3: 'セグレイブ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'キョジオーン',
    pokemon6: 'ドオー',
    sex2: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'もこロローム/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // モトトカゲのHP26
  await inputRemainHP(driver, op, '26');
  // モトトカゲのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲ->ブロロロームに交代
  await changePokemon(driver, me, 'ブロロローム', true);
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ブロロロームのHP132
  await inputRemainHP(driver, op, '132');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ブロロロームのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのダストシュート
  await tapMove(driver, me, 'ダストシュート', false);
  // ロトムのHP8
  await inputRemainHP(driver, me, '8');
  // ロトムはどくにかかった
  await driver.tap(find.text('ロトムはどくにかかった'));
  // ロトムのおにび
  await tapMove(driver, op, 'おにび', true);
  // ブロロロームのラムのみ
  await addEffect(driver, 4, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // やけど削除
  await tapEffect(driver, 'やけど');
  await driver.tap(find.text('削除'));
  // ロトムひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // ブロロロームのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // セグレイブのHP40
  await inputRemainHP(driver, me, '40');
  // セグレイブはひるんで技がだせない
  await driver.tap(find.text('セグレイブはひるんで技がだせない'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ブロロロームのHP60
  await inputRemainHP(driver, op, '60');
  // ブロロロームのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// モトトカゲ戦6
Future<void> test22_6(
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
    battleName: 'もこうモトトカゲ戦6',
    ownPartyname: '22もこトカゲ',
    opponentName: 'ゆる',
    pokemon1: 'クエスパトラ',
    pokemon2: 'パルシェン',
    pokemon3: 'ドラパルト',
    pokemon4: 'ウルガモス',
    pokemon5: 'サーフゴー',
    pokemon6: 'マスカーニャ',
    sex2: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニンフィア/',
      ownPokemon2: 'もこうトカゲ/',
      ownPokemon3: 'もこリガメ/',
      opponentPokemon: 'クエスパトラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', true);
  // ニンフィアのHP150
  await inputRemainHP(driver, op, '150');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // クエスパトラのHP35
  await inputRemainHP(driver, me, '35');
  // クエスパトラのかそく
  await addEffect(driver, 2, op, 'かそく');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ニンフィアのHP45
  await inputRemainHP(driver, op, '45');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // クエスパトラのHP0
  await inputRemainHP(driver, me, '0');
  // クエスパトラひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // マスカーニャのHP75
  await inputRemainHP(driver, me, '75');
  // マスカーニャのへんげんじざい
  await addEffect(driver, 1, op, 'へんげんじざい');
  await driver.tap(find.text('OK'));
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->モトトカゲに交代
  await changePokemon(driver, me, 'モトトカゲ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->パルシェンに交代
  await changePokemon(driver, op, 'パルシェン', true);
  // モトトカゲのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのテラスタル
  await inputTerastal(driver, me, '');
  // モトトカゲのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // パルシェンのHP70
  await inputRemainHP(driver, me, '70');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('しろいハーブ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('しろいハーブ')));
  // パルシェンのからをやぶる
  await tapMove(driver, op, 'からをやぶる', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのすてみタックル
  await tapMove(driver, me, 'すてみタックル', false);
  // パルシェンのHP0
  await inputRemainHP(driver, me, '0');
  // モトトカゲのHP120
  await inputRemainHP(driver, me, '120');
  // パルシェンひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // モトトカゲのすてみタックル
  await tapMove(driver, me, 'すてみタックル', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // モトトカゲのHP85
  await inputRemainHP(driver, me, '85');

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エクスレッグ戦1
Future<void> test23_1(
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
    battleName: 'もこうエクスレッグ戦1',
    ownPartyname: '23もこレッグ',
    opponentName: 'ふぅちゃん',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'アーマーガア',
    pokemon3: 'ウルガモス',
    pokemon4: 'キノガッサ',
    pokemon5: 'ミミッキュ',
    pokemon6: 'マスカーニャ',
    sex2: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'アーマーガア');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのプレッシャー
  await addEffect(driver, 0, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // アーマーガアのHP90
  await inputRemainHP(driver, me, '90');
  // オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // アーマーガアのゴツゴツメット
  await addEffect(driver, 3, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // アーマーガアのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // オリーヴァのHP127
  await inputRemainHP(driver, op, '127');
  // マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // オリーヴァ->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグ->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // アーマーガアのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', false);
  // オリーヴァのHP131
  await inputRemainHP(driver, op, '131');
  // マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // オリーヴァのHP56
  await inputRemainHP(driver, op, '56');
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // マスカーニャのHP30
  await inputRemainHP(driver, me, '30');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // ヘルガーのHP12
  await inputRemainHP(driver, op, '12');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // アーマーガアのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // アーマーガアのHP45
  await inputRemainHP(driver, me, '45');
  // アーマーガアのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ヘルガーひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エクスレッグ戦2
Future<void> test23_2(
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
    battleName: 'もこうエクスレッグ戦2',
    ownPartyname: '23もこレッグ',
    opponentName: 'ぺんすけ',
    pokemon1: 'ウルガモス',
    pokemon2: 'サザンドラ',
    pokemon3: 'ニンフィア',
    pokemon4: 'マスカーニャ',
    pokemon5: 'セグレイブ',
    pokemon6: 'キョジオーン',
    sex1: Sex.female,
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ボーマンダのHP147
  await inputRemainHP(driver, op, '147');
  // ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ニンフィアのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ニンフィアのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // オリーヴァのHP51
  await inputRemainHP(driver, op, '51');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // オリーヴァのHP4
  await inputRemainHP(driver, op, '4');
  // ニンフィアのHP70
  await inputRemainHP(driver, me, '70');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのでんこうせっか
  await tapMove(driver, op, 'でんこうせっか', true);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ニンフィアひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 4回命中
  await setHitCount(driver, op, 4);
  // 3回命中
  await setHitCount(driver, op, 3);
  // エクスレッグのHP58
  await inputRemainHP(driver, op, '58');
  // セグレイブのHP45
  await inputRemainHP(driver, me, '45');
  // ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // セグレイブ->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // マスカーニャのHP5
  await inputRemainHP(driver, me, '5');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // ボーマンダのHP78
  await inputRemainHP(driver, op, '78');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エクスレッグ戦3
Future<void> test23_3(
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
    battleName: 'もこうエクスレッグ戦3',
    ownPartyname: '23もこレッグ',
    opponentName: 'ニセ',
    pokemon1: 'ハッサム',
    pokemon2: 'カイリュー',
    pokemon3: 'ヘイラッシャ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ラウドボーン',
    pokemon6: 'モスノウ',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーヴァ/',
      ownPokemon2: 'もこレッグ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // オリーヴァのHP161
  await inputRemainHP(driver, op, '161');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ラウドボーンのHP85
  await inputRemainHP(driver, me, '85');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // オリーヴァ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // オリーヴァのHP135
  await inputRemainHP(driver, op, '135');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // オリーヴァのHP15
  await inputRemainHP(driver, op, '15');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ラウドボーンのHP70
  await inputRemainHP(driver, me, '70');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP151
  await inputRemainHP(driver, op, '');
  // ラウドボーンはとくこうが上がった
  await driver.tap(find.text('ラウドボーンはとくこうが上がった'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // ラウドボーンのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // ヘルガーのきあいのタスキ
  await addEffect(driver, 3, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのテラスタル
  await inputTerastal(driver, me, '');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // TODO:ノーマルジュエルを効果として追加できるようにした方がよい？
  await editPokemonState(driver, 'カイリュー/ニセ', null, null, 'ノーマルジュエル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', true);
  // エクスレッグのHP34
  await inputRemainHP(driver, op, '34');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // エクスレッグのHP0
  await inputRemainHP(driver, op, '0');
  // エクスレッグひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // オリーヴァのHP2
  await inputRemainHP(driver, op, '2');
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', false);
  // オリーヴァのHP117
  await inputRemainHP(driver, op, '117');
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // カイリューのHP5
  await inputRemainHP(driver, me, '5');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', false);
  // オリーヴァのHP47
  await inputRemainHP(driver, op, '47');
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // オリーヴァのHP7
  await inputRemainHP(driver, op, '7');
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エクスレッグ戦4
Future<void> test23_4(
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
    battleName: 'もこうエクスレッグ戦4',
    ownPartyname: '23もこレッグ',
    opponentName: 'セジュン',
    pokemon1: 'ドラパルト',
    pokemon2: 'マスカーニャ',
    pokemon3: 'マリルリ',
    pokemon4: 'ドドゲザン',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'サーフゴー',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこーヴァ/',
      opponentPokemon: 'ドドゲザン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ドドゲザンのHP70
  await inputRemainHP(driver, me, '70');
  // オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ドドゲザンのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // エクスレッグのHP42
  await inputRemainHP(driver, op, '42');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('いのちのたま');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('いのちのたま')));
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // マスカーニャのHP1
  await inputRemainHP(driver, me, '1');
  // ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // マスカーニャのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // ヘルガーのHP77
  await inputRemainHP(driver, op, '77');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('きあいのタスキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ')));
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // ドラパルトのHP40
  await inputRemainHP(driver, me, '40');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 0回命中
  await setHitCount(driver, op, 0);
  // 1回命中
  await setHitCount(driver, op, 1);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ドラパルトのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ヘルガーひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// エクスレッグ戦5
Future<void> test23_5(
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
    battleName: 'もこうエクスレッグ戦5',
    ownPartyname: '23もこレッグ',
    opponentName: 'こい',
    pokemon1: 'コータス',
    pokemon2: 'スコヴィラン',
    pokemon3: 'サザンドラ',
    pokemon4: 'ケンタロス(パルデアのすがた(かくとう))',
    pokemon5: 'キノガッサ',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'コータス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コータスのひでり
  await addEffect(driver, 0, op, 'ひでり');
  await driver.tap(find.text('OK'));
  // エクスレッグのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // コータスのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // 外れる
  await tapHit(driver, op);
  // エクスレッグのHP175
  await inputRemainHP(driver, op, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // コータスのHP80
  await inputRemainHP(driver, me, '80');
  // ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // コータスのだっしゅつパック
  await addEffect(driver, 3, op, 'だっしゅつパック');
  // スコヴィランに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('スコヴィラン'));
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // スコヴィランのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // スコヴィランのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ボーマンダひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // スコヴィラン->コータスに交代
  await changePokemon(driver, op, 'コータス', true);
  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // コータスのHP30
  await inputRemainHP(driver, me, '30');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // コータスのHP0
  await inputRemainHP(driver, me, '0');
  // オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // コータスひんし->スコヴィランに交代
  await changePokemon(driver, op, 'スコヴィラン', false);
  // TODO:ここで晴れ終了しないといけない
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // スコヴィランのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // スコヴィランのHP0
  await inputRemainHP(driver, me, '0');
  // スコヴィランひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // エクスレッグのHP26
  await inputRemainHP(driver, op, '26');
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // エクスレッグのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'こいの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ムクホーク戦1
Future<void> test24_1(
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
    battleName: 'もこうムクホーク戦1',
    ownPartyname: '24もこホーク',
    opponentName: 'ミト',
    pokemon1: 'マスカーニャ',
    pokemon2: 'セグレイブ',
    pokemon3: 'ミミッキュ',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'ウルガモス',
    pokemon6: 'サザンドラ',
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこホーク/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ヘイラッシャのHP40
  await inputRemainHP(driver, me, '40');
  // ムクホークのHP96
  await inputRemainHP(driver, me, '96');
  // ムクホークのHP110
  await inputRemainHP(driver, me, '110');
  // ムクホークのHP112
  await inputRemainHP(driver, me, '112');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークのHP62
  await inputRemainHP(driver, me, '62');
  // ヘイラッシャひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ムクホークのHP0
  await inputRemainHP(driver, op, '0');
  // ムクホークひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 4回命中
  await setHitCount(driver, op, 4);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // セグレイブのHP75
  await inputRemainHP(driver, me, '75');
  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // ヘルガーのきあいのタスキ
  await addEffect(driver, 4, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ミトの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ムクホーク戦2
Future<void> test24_2(
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
    battleName: 'もこうムクホーク戦2',
    ownPartyname: '24もこホーク2',
    opponentName: 'フィク',
    pokemon1: 'ムウマ',
    pokemon2: 'ストリンダー(ローなすがた)',
    pokemon3: 'ドドゲザン',
    pokemon4: 'ニンフィア',
    pokemon5: 'ウェーニバル',
    pokemon6: 'フォレトス',
    sex1: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこホーク/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこーヴァ/',
      opponentPokemon: 'ドドゲザン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザン->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', true);
  // ムクホークのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ニンフィアのHP70
  await inputRemainHP(driver, me, '70');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークのHP120
  await inputRemainHP(driver, me, '120');
  // ムクホークのHP102
  await inputRemainHP(driver, me, '102');
  // ニンフィアひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのテラスタル
  await inputTerastal(driver, me, '');
  // ムクホークのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->ストリンダーに交代
  await changePokemon(driver, op, 'ストリンダー(ローなすがた)', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのすてみタックル
  await tapMove(driver, me, 'すてみタックル', false);
  // ストリンダーのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークのHP11
  await inputRemainHP(driver, me, '11');

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ムクホーク戦3
Future<void> test24_3(
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
    battleName: 'もこうムクホーク戦3',
    ownPartyname: '24もこホーク2',
    opponentName: 'みつきー',
    pokemon1: 'ガブリアス',
    pokemon2: 'オーロンゲ',
    pokemon3: 'ラウドボーン',
    pokemon4: 'エルレイド',
    pokemon5: 'マリルリ',
    pokemon6: 'サーフゴー',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこホーク/',
      ownPokemon2: 'もこ特殊マンダ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ムクホーク->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // サーフゴーのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP75
  await inputRemainHP(driver, op, '75');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // サーフゴーのHP75
  await inputRemainHP(driver, me, '');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ヘルガーのHP104
  await inputRemainHP(driver, op, '104');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->ムクホークに交代
  await changePokemon(driver, me, 'ムクホーク', true);
  // サーフゴー->エルレイドに交代
  await changePokemon(driver, op, 'エルレイド', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // ムクホークのHP132
  await inputRemainHP(driver, me, '132');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークのHP97
  await inputRemainHP(driver, me, '97');
  // サーフゴーひんし->エルレイドに交代
  await changePokemon(driver, op, 'エルレイド', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ムクホーク->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // エルレイドのせいなるつるぎ
  await tapMove(driver, op, 'せいなるつるぎ', true);
  // ボーマンダのHP127
  await inputRemainHP(driver, op, '127');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // エルレイド->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // ラウドボーンのHP55
  await inputRemainHP(driver, me, '55');
  // エルレイドのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ラウドボーンのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ヘルガーのHP71
  await inputRemainHP(driver, op, '71');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->エルレイドに交代
  await changePokemon(driver, op, 'エルレイド', true);
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // エルレイドのHP70
  await inputRemainHP(driver, me, '70');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // 急所に命中
  await tapCritical(driver, me);
  // エルレイドのHP5
  await inputRemainHP(driver, me, '5');
  // エルレイドのサイコカッター
  await tapMove(driver, op, 'サイコカッター', true);
  // ヘルガーのHP71
  await inputRemainHP(driver, op, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのサイコカッター
  await tapMove(driver, op, 'サイコカッター', false);
  // ヘルガーのHP71
  await inputRemainHP(driver, op, '');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // エルレイドのHP0
  await inputRemainHP(driver, me, '0');
  // エルレイドひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP20
  await inputRemainHP(driver, me, '20');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP70
  await inputRemainHP(driver, op, '70');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのテラスタル
  await inputTerastal(driver, me, '');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP20
  await inputRemainHP(driver, me, '20');
  // ラウドボーンはひるんで技がだせない
  await driver.tap(find.text('ラウドボーンはひるんで技がだせない'));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ムクホーク戦4
Future<void> test24_4(
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
    battleName: 'もこうムクホーク戦4',
    ownPartyname: '24もこホーク2',
    opponentName: 'のぶあき',
    pokemon1: 'オノノクス',
    pokemon2: 'ウルガモス',
    pokemon3: 'フワライド',
    pokemon4: 'ウインディ',
    pokemon5: 'オリーヴァ',
    pokemon6: 'マリルリ',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこホーク/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'オリーヴァ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークのHP110
  await inputRemainHP(driver, me, '110');
  // オリーヴァのこぼれダネ
  await addEffect(driver, 2, op, 'こぼれダネ');
  await driver.tap(find.text('OK'));
  // オリーヴァひんし->フワライドに交代
  await changePokemon(driver, op, 'フワライド', false);
  // オリーヴァのグラスシード
  await addEffect(driver, 4, op, 'グラスシード');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // フワライドのちいさくなる
  await tapMove(driver, op, 'ちいさくなる', true);
  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // フワライドのHP30
  await inputRemainHP(driver, me, '30');
  // ムクホークのHP40
  await inputRemainHP(driver, me, '40');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // フワライドのちからをすいとる
  await tapMove(driver, op, 'ちからをすいとる', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // フワライドのHP100
  await inputRemainHP(driver, op, '100');
  // ムクホークのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // フワライドのHP52
  await inputRemainHP(driver, me, '52');
  // ムクホークのHP0
  await inputRemainHP(driver, me, '0');
  // ムクホークひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // フワライドのテラスタル
  await inputTerastal(driver, op, 'あく');
  // フワライドのちいさくなる
  await tapMove(driver, op, 'ちいさくなる', false);
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // 外れる
  await tapHit(driver, me);
  // フワライドのHP52
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // フワライドのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // フワライドのHP33
  await inputRemainHP(driver, op, '33');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // フワライドのHP33
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // フワライドのみがわり
  await tapMove(driver, op, 'みがわり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // フワライドのHP14
  await inputRemainHP(driver, op, '14');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // フワライドのHP14
  await inputRemainHP(driver, me, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // フワライドのちいさくなる
  await tapMove(driver, op, 'ちいさくなる', false);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // フワライドのHP14
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // フワライドのバトンタッチ
  await tapMove(driver, op, 'バトンタッチ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // ウルガモスのHP100
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // ウルガモスのHP100
  await inputRemainHP(driver, me, '');
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // ウルガモスのHP100
  await inputRemainHP(driver, me, '');
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // 外れる
  await tapHit(driver, me);
  // ウルガモスのHP100
  await inputRemainHP(driver, me, '');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ランク変化確認
  await testRank(driver, op, 'B', 'Up0');
  await testRank(driver, op, 'C', 'Up3');
  await testRank(driver, op, 'D', 'Up3');
  await testRank(driver, op, 'S', 'Up3');
  // TODO: ？なぜかEv+5を判定できない
  //await testRank(driver, op, 'Ev', 'Up5');
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // ヘルガーのHP151
  await inputRemainHP(driver, op, '');
  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  await tapSuccess(driver, me);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アノホラグサ戦1
Future<void> test25_1(
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
    battleName: 'もこうアノホラグサ戦1',
    ownPartyname: '25もこホラグサ',
    opponentName: 'ユウキ',
    pokemon1: 'イルカマン',
    pokemon2: 'ジバコイル',
    pokemon3: 'オノノクス',
    pokemon4: 'オーロンゲ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアロー/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこホラグサ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ファイアローのおいかぜ
  await tapMove(driver, me, 'おいかぜ', false);
  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // ファイアローのHP87
  await inputRemainHP(driver, op, '87');
  // イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ファイアローのだっしゅつボタン
  await addEffect(driver, 2, me, 'だっしゅつボタン');
  // アノホラグサに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('アノホラグサ'));
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // アノホラグサのテラスタル
  await inputTerastal(driver, me, '');
  // アノホラグサのパワーウィップ
  await tapMove(driver, me, 'パワーウィップ', false);
  // ジバコイルのHP25
  await inputRemainHP(driver, me, '25');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ジバコイルひんし->オノノクスに交代
  await changePokemon(driver, op, 'オノノクス', false);
  // ジバコイルのかたやぶり
  await addEffect(driver, 3, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサ->ファイアローに交代
  await changePokemon(driver, me, 'ファイアロー', true);
  // オノノクスのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // ファイアローのHP0
  await inputRemainHP(driver, op, '0');
  // オノノクスのいのちのたま
  await addEffect(driver, 1, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ファイアローひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのげきりん
  await tapMove(driver, op, 'げきりん', false);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // ヘルガーのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // オノノクスのHP25
  await inputRemainHP(driver, me, '25');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // オノノクスのHP0
  await inputRemainHP(driver, me, '0');
  // オノノクスひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのれいとうパンチ
  await tapMove(driver, op, 'れいとうパンチ', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->アノホラグサに交代
  await changePokemon(driver, me, 'アノホラグサ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのれいとうパンチ
  await tapMove(driver, op, 'れいとうパンチ', false);
  // アノホラグサのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ユウキの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アノホラグサ戦2
Future<void> test25_2(
  FlutterDriver driver,
) async {
  // TODO: かぜのり自動で発動させたい
  // TODO: おいかぜが終了しない
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうアノホラグサ戦2',
    ownPartyname: '25もこホラグサ2',
    opponentName: 'やんばる',
    pokemon1: 'ドラパルト',
    pokemon2: 'ロトム(ヒートロトム)',
    pokemon3: 'モロバレル',
    pokemon4: 'マスカーニャ',
    pokemon5: 'サーフゴー',
    pokemon6: 'キョジオーン',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアロー/',
      ownPokemon2: 'もこホラグサ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ファイアローのおいかぜ
  await tapMove(driver, me, 'おいかぜ', false);
  // ドラパルトのかみなり
  await tapMove(driver, op, 'かみなり', true);
  // ファイアローのHP29
  await inputRemainHP(driver, op, '29');
  // ファイアローのだっしゅつボタン
  await addEffect(driver, 2, me, 'だっしゅつボタン');
  // アノホラグサに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('アノホラグサ'));
  await driver.tap(find.text('OK'));
  // ファイアローのかぜのり
  await addEffect(driver, 3, me, 'かぜのり');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', true);
  // アノホラグサのテラスタル
  await inputTerastal(driver, me, '');
  // アノホラグサのパワーウィップ
  await tapMove(driver, me, 'パワーウィップ', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサののろい
  await tapMove(driver, me, 'のろい', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // アノホラグサのHP0
  await inputRemainHP(driver, op, '0');
  // アノホラグサひんし->ファイアローに交代
  await changePokemon(driver, me, 'ファイアロー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ファイアローのおにび
  await tapMove(driver, me, 'おにび', false);
  await tapSuccess(driver, me);
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ファイアローのHP0
  await inputRemainHP(driver, op, '0');
  // ファイアローひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // サーフゴーのHP35
  await inputRemainHP(driver, me, '35');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ボーマンダのHP108
  await inputRemainHP(driver, op, '108');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // 急所に命中
  await tapCritical(driver, me);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// アノホラグサ戦3
Future<void> test25_3(
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
    battleName: 'もこうアノホラグサ戦3',
    ownPartyname: '25もこホラグサ3',
    opponentName: 'ごんた',
    pokemon1: 'ドラパルト',
    pokemon2: 'サーフゴー',
    pokemon3: 'ドンファン',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'サザンドラ',
    pokemon6: 'ブリムオン',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアロー/',
      ownPokemon2: 'もこホラグサ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // ファイアローのおいかぜ
  await tapMove(driver, me, 'おいかぜ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ファイアローのおにび
  await tapMove(driver, me, 'おにび', false);
  // ヘイラッシャののろい
  await tapMove(driver, op, 'のろい', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ファイアロー->アノホラグサに交代
  await changePokemon(driver, me, 'アノホラグサ', true);
  // ファイアローのかぜのり
  await addEffect(driver, 1, me, 'かぜのり');
  await driver.tap(find.text('OK'));
  // ヘイラッシャののろい
  await tapMove(driver, op, 'のろい', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサののろい
  await tapMove(driver, me, 'のろい', false);
  // ヘイラッシャのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アノホラグサのHP66
  await inputRemainHP(driver, me, '66');
  // ヘイラッシャのねむる
  await tapMove(driver, op, 'ねむる', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アノホラグサのHP131
  await inputRemainHP(driver, me, '131');
  // ヘイラッシャのねごと
  await tapMove(driver, op, 'ねごと', true);
  await tapMove(driver, op, 'ねむる', true);
  await tapSuccess(driver, op);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ヘイラッシャのHP40
  await inputRemainHP(driver, me, '40');
  // ヘイラッシャのねごと
  await tapMove(driver, op, 'ねごと', false);
  await tapMove(driver, op, 'ウェーブタックル', true);
  // アノホラグサのHP47
  await inputRemainHP(driver, op, '47');
  // ヘイラッシャのHP30
  await inputRemainHP(driver, op, '30');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アノホラグサのHP131
  await inputRemainHP(driver, me, '131');
  // ヘイラッシャのねむる
  await tapMove(driver, op, 'ねむる', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャ->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // アノホラグサのパワーウィップ
  await tapMove(driver, me, 'パワーウィップ', false);
  // サザンドラのHP30
  await inputRemainHP(driver, me, '30');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ボーマンダのHP85
  await inputRemainHP(driver, op, '85');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ヘイラッシャのHP5
  await inputRemainHP(driver, me, '5');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // ヘイラッシャひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ドラパルトのHP35
  await inputRemainHP(driver, me, '35');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 1回命中
  await setHitCount(driver, op, 1);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->ファイアローに交代
  await changePokemon(driver, me, 'ファイアロー', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ファイアローのおいかぜ
  await tapMove(driver, me, 'おいかぜ', false);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // ファイアローのHP62
  await inputRemainHP(driver, op, '62');
  // ファイアローのだっしゅつボタン
  await addEffect(driver, 2, me, 'だっしゅつボタン');
  // アノホラグサに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('アノホラグサ'));
  await driver.tap(find.text('OK'));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // アノホラグサののろい
  await tapMove(driver, me, 'のろい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // アノホラグサのHP40
  await inputRemainHP(driver, me, '40');
  // サザンドラのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // アノホラグサのHP0
  await inputRemainHP(driver, op, '0');
  // のろいダメージ編集
  await tapEffect(driver, 'のろいダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('0');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// アノホラグサ戦1
Future<void> test25_1(
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
