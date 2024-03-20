import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// クエスパトラ戦1
Future<void> test16_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうクエスパトラ戦1',
    ownPartyname: '16もこパトラ',
    opponentName: 'taka',
    pokemon1: 'サザンドラ',
    pokemon2: 'サーフゴー',
    pokemon3: 'モロバレル',
    pokemon4: 'ミミッキュ',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'ガブリアス',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ/',
      ownPokemon2: 'もこ特殊マンダ/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // クエスパトラのHP90
  await inputRemainHP(driver, op, '90');
  // ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのテラスタル
  await inputTerastal(driver, me, '');
  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // クエスパトラのHP90
  await inputRemainHP(driver, op, '');
  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ロトムのテラスタル
  await inputTerastal(driver, op, 'でんき');
  // クエスパトラのバトンタッチ
  await tapMove(driver, me, 'バトンタッチ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // リククラゲのHP187
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ロトム->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ロトムのふうせん
  await addEffect(driver, 1, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP100
  await inputRemainHP(driver, me, '');
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // サーフゴーのHP90
  await inputRemainHP(driver, me, '90');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '');
  // サーフゴーのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP15
  await inputRemainHP(driver, me, '15');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // リククラゲのHP96
  await inputRemainHP(driver, op, '96');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ロトムのHP60
  await inputRemainHP(driver, me, '60');
  // リククラゲのHP143
  await inputRemainHP(driver, me, '143');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // リククラゲのHP49
  await inputRemainHP(driver, op, '49');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ロトムのHP30
  await inputRemainHP(driver, me, '30');
  // リククラゲのHP83
  await inputRemainHP(driver, me, '83');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // リククラゲのHP4
  await inputRemainHP(driver, op, '4');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲのHP34
  await inputRemainHP(driver, me, '34');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// クエスパトラ戦2
Future<void> test16_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうクエスパトラ戦2',
    ownPartyname: '16もこパトラ',
    opponentName: 'バイオレット',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'カバルドン',
    pokemon3: 'ウルガモス',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'キノガッサ',
    pokemon6: 'ドラパルト',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ/',
      ownPokemon2: 'もこ特殊マンダ/',
      ownPokemon3: 'もこリククラゲ/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラ->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', true);
  // ロトムのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ロトム->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // リククラゲ->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ドラパルトのHP70
  await inputRemainHP(driver, me, '70');
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ロトムのHP70
  await inputRemainHP(driver, me, '70');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // クエスパトラのHP80
  await inputRemainHP(driver, op, '80');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ロトムのHP10
  await inputRemainHP(driver, me, '10');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // クエスパトラのHP0
  await inputRemainHP(driver, op, '0');
  // クエスパトラひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ロトム->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ヘイラッシャのHP70
  await inputRemainHP(driver, me, '70');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '187');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャのじわれ
  await tapMove(driver, op, 'じわれ', true);
  // 外れる
  await tapHit(driver, op);
  // リククラゲのHP176
  await inputRemainHP(driver, op, '');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ヘイラッシャのHP30
  await inputRemainHP(driver, me, '30');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '187');
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '187');
  // ヘイラッシャひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// クエスパトラ戦3
Future<void> test16_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうクエスパトラ戦3',
    ownPartyname: '16もこパトラ',
    opponentName: 'あるべると',
    pokemon1: 'サーフゴー',
    pokemon2: 'サザンドラ',
    pokemon3: 'ロトム(ヒートロトム)',
    pokemon4: 'マリルリ',
    pokemon5: 'ミミッキュ',
    pokemon6: 'モロバレル',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこパトラ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのテラスタル
  await inputTerastal(driver, me, '');
  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // サザンドラのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サザンドラのHP75
  await inputRemainHP(driver, op, '75');
  // サザンドラのたべのこし
  await addEffect(driver, 4, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // サザンドラのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのバトンタッチ
  await tapMove(driver, me, 'バトンタッチ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // サザンドラのわるだくみ
  await tapMove(driver, op, 'わるだくみ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // サザンドラのHP93
  await inputRemainHP(driver, me, '');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ボーマンダのHP78
  await inputRemainHP(driver, op, '78');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // サザンドラのHP35
  await inputRemainHP(driver, me, '35');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // サザンドラのHP20
  await inputRemainHP(driver, me, '20');
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // マリルリのHP62
  await inputRemainHP(driver, op, '62');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // モロバレルのHP95
  await inputRemainHP(driver, me, '95');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // モロバレルのHP75
  await inputRemainHP(driver, me, '75');
  // モロバレルのクリアスモッグ
  await tapMove(driver, op, 'クリアスモッグ', true);
  // マリルリのHP18
  await inputRemainHP(driver, op, '18');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // モロバレルのHP50
  await inputRemainHP(driver, me, '50');
  // モロバレルのクリアスモッグ
  await tapMove(driver, op, 'クリアスモッグ', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // モロバレル->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // ミミッキュののろい
  await tapMove(driver, op, 'のろい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミッキュのHP38
  await inputRemainHP(driver, op, '38');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // モロバレルのとくせいがさいせいりょくと判明
  await editPokemonState(driver, 'モロバレル/あるべると', '83', 'さいせいりょく', null);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // モロバレル->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // サザンドラのHP2
  await inputRemainHP(driver, me, '2');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // モロバレルのHP30
  await inputRemainHP(driver, me, '30');
  // モロバレルのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  // 相手の勝利
  await testExistEffect(driver, 'あるべるとの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オリーヴァ戦1
Future<void> test17_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオリーヴァ戦1',
    ownPartyname: '17もこーヴァ',
    opponentName: 'まさ',
    pokemon1: 'サザンドラ',
    pokemon2: 'ハッサム',
    pokemon3: 'ミミッキュ',
    pokemon4: 'ユキノオー',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'ウルガモス',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーヴァ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこレイブ/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // サザンドラのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // サザンドラのHP80
  await inputRemainHP(driver, me, '80');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // サザンドラのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // TODO:ちょうはつ終了のタイミングがずれてる。ここで終了するはずが、次ターンで終了する
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // オリーヴァのHP49
  await inputRemainHP(driver, op, '49');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // オリーヴァのしゅうかく
  await addEffect(driver, 5, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オリーヴァ戦2
Future<void> test17_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオリーヴァ戦2',
    ownPartyname: '17もこーヴァ',
    opponentName: 'あらいわ',
    pokemon1: 'ドラパルト',
    pokemon2: 'キョジオーン',
    pokemon3: 'マスカーニャ',
    pokemon4: 'サーフゴー',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ロトム(ウォッシュロトム)',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーヴァ/',
      ownPokemon2: 'もこレイド/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // マスカーニャのへんげんじざい
  await addEffect(driver, 1, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('むし'));
  await driver.tap(find.text('OK'));
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // オリーヴァのHP129
  await inputRemainHP(driver, op, '129');
  // ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // オリーヴァのHP55
  await inputRemainHP(driver, op, '55');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ミミッキュのHP30
  await inputRemainHP(driver, me, '30');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', false);
  // オリーヴァのHP72
  await inputRemainHP(driver, op, '72');
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // オリーヴァのしゅうかく
  await addEffect(driver, 3, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', false);
  // オリーヴァのHP102
  await inputRemainHP(driver, op, '102');
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // マリルリのHP123
  await inputRemainHP(driver, op, '123');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // マスカーニャ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // サーフゴーのHP70
  await inputRemainHP(driver, me, '70');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // エルレイド->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのせいなるつるぎ
  await tapMove(driver, me, 'せいなるつるぎ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オリーヴァ戦3
Future<void> test17_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオリーヴァ戦3',
    ownPartyname: '17もこーヴァ2',
    opponentName: 'ああああああ',
    pokemon1: 'イッカネズミ',
    pokemon2: 'サーフゴー',
    pokemon3: 'キノガッサ',
    pokemon4: 'イルカマン',
    pokemon5: 'ドラパルト',
    pokemon6: 'ラウドボーン',
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もコータス/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこヘル2/',
      opponentPokemon: 'イッカネズミ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', true);
  // コータスのHP23
  await inputRemainHP(driver, op, '23');
  // コータスのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのフェイント
  await tapMove(driver, op, 'フェイント', true);
  // コータスのHP0
  await inputRemainHP(driver, op, '0');
  // コータスひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // イッカネズミのHP30
  await inputRemainHP(driver, me, '30');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', false);
  // オリーヴァのHP72
  await inputRemainHP(driver, op, '72');
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP181
  await inputRemainHP(driver, me, '181');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // イッカネズミ->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // ラウドボーンのHP85
  await inputRemainHP(driver, me, '85');
  // オリーヴァのしゅうかく
  await addEffect(driver, 2, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // ヘルガーのHP119
  await inputRemainHP(driver, op, '119');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->イッカネズミに交代
  await changePokemon(driver, op, 'イッカネズミ', true);
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // イッカネズミのHP0
  await inputRemainHP(driver, me, '0');
  // イッカネズミひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // オリーヴァのHP93
  await inputRemainHP(driver, op, '93');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', false);
  // オリーヴァのHP8
  await inputRemainHP(driver, op, '8');
  // オリーヴァのちからをすいとる
  await tapMove(driver, me, 'ちからをすいとる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オリーヴァのHP185
  await inputRemainHP(driver, me, '185');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // オリーヴァ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP86
  await inputRemainHP(driver, op, '86');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP2
  await inputRemainHP(driver, me, '2');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP52
  await inputRemainHP(driver, op, '52');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // ラウドボーンのHP10
  await inputRemainHP(driver, me, '10');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP60
  await inputRemainHP(driver, op, '60');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP80
  await inputRemainHP(driver, op, '80');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP50
  await inputRemainHP(driver, me, '50');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP41
  await inputRemainHP(driver, op, '41');
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP10
  await inputRemainHP(driver, me, '10');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP60
  await inputRemainHP(driver, op, '60');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP25
  await inputRemainHP(driver, me, '25');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP75
  await inputRemainHP(driver, op, '75');
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP50
  await inputRemainHP(driver, me, '50');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP95
  await inputRemainHP(driver, op, '95');
  // ターン21へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP65
  await inputRemainHP(driver, me, '65');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン22へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // オリーヴァのHP119
  await inputRemainHP(driver, op, '119');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ラウドボーンのHP25
  await inputRemainHP(driver, me, '25');
  // ターン23へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP75
  await inputRemainHP(driver, op, '75');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // オリーヴァのしゅうかく
  await addEffect(driver, 2, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // ターン24へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ああああああの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オリーヴァ戦4
Future<void> test17_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうオリーヴァ戦4',
    ownPartyname: '17もこーヴァ',
    opponentName: 'p',
    pokemon1: 'マスカーニャ',
    pokemon2: 'サーフゴー',
    pokemon3: 'カイリュー',
    pokemon4: 'セグレイブ',
    pokemon5: 'ドドゲザン',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーヴァ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // オリーヴァのHP140
  await inputRemainHP(driver, op, '140');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // サーフゴーのHP80
  await inputRemainHP(driver, me, '80');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // サーフゴーのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // マリルリのHP140
  await inputRemainHP(driver, op, '140');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ロトム->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // ロトムのそうだいしょう
  await addEffect(driver, 1, op, 'そうだいしょう');
  await driver.tap(find.text('OK'));
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ドドゲザンのHP60
  await inputRemainHP(driver, me, '60');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザン->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // マリルリのばかぢから
  await tapMove(driver, me, 'ばかぢから', false);
  // ロトムのHP40
  await inputRemainHP(driver, me, '40');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // マリルリのHP2
  await inputRemainHP(driver, op, '2');
  // ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ドドゲザンのHP35
  await inputRemainHP(driver, me, '35');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ドドゲザンのHP20
  await inputRemainHP(driver, me, '20');
  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 外れる
  await tapHit(driver, op);
  // マリルリのHP2
  await inputRemainHP(driver, op, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリのばかぢから
  await tapMove(driver, me, 'ばかぢから', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのリーフブレード
  await tapMove(driver, me, 'リーフブレード', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マスカーニャ戦1
Future<void> test18_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうマスカーニャ戦1',
    ownPartyname: '18もこカーニャ',
    opponentName: 'キリヤ',
    pokemon1: 'ハッサム',
    pokemon2: 'サザンドラ',
    pokemon3: 'サダイジャ',
    pokemon4: 'タイカイデン',
    pokemon5: 'グレンアルマ',
    pokemon6: 'バンギラス',
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ハッサム');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ハッサムのHP80
  await inputRemainHP(driver, me, '80');
  // マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ハッサムのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // ハッサムのくさわけ
  await tapMove(driver, op, 'くさわけ', true);
  // マリルリのHP120
  await inputRemainHP(driver, op, '120');
  // ハッサムのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ハッサムのHP10
  await inputRemainHP(driver, me, '10');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  // マリルリのHP29
  await inputRemainHP(driver, op, '29');
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // 外れる
  await tapHit(driver, me);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '');
  // ハッサムひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // サザンドラのHP35
  await inputRemainHP(driver, me, '35');
  // たべのこしをはたきおとす
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('たべのこし');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('たべのこし')));
  // サザンドラのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->タイカイデンに交代
  await changePokemon(driver, op, 'タイカイデン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // タイカイデンのHP1
  await inputRemainHP(driver, me, '1');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('きあいのタスキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ')));
  // タイカイデンのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', true);
  // マスカーニャのHP61
  await inputRemainHP(driver, op, '61');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // タイカイデンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マスカーニャ戦2
Future<void> test18_2(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうマスカーニャ戦2',
    ownPartyname: '18もこカーニャ',
    opponentName: 'セツ',
    pokemon1: 'ドヒドイデ',
    pokemon2: 'ヌメルゴン',
    pokemon3: 'ロトム(ヒートロトム)',
    pokemon4: 'サーフゴー',
    pokemon5: 'ガブリアス',
    pokemon6: 'ニンフィア',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこイダー2/',
      ownPokemon2: 'もこ特殊マンダ/',
      ownPokemon3: 'もこカーニャ/',
      opponentPokemon: 'ニンフィア');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのあくび
  await tapMove(driver, op, 'あくび', true);
  await tapSuccess(driver, op);
  // ワナイダーのねばねばネット
  await tapMove(driver, me, 'ねばねばネット', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのめいそう
  await tapMove(driver, op, 'めいそう', true);
  // ワナイダーのともえなげ
  await tapMove(driver, me, 'ともえなげ', true);
  // ニンフィアのHP95
  await inputRemainHP(driver, me, '95');
  // ガブリアスに交代
  await changePokemon(driver, me, 'ガブリアス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ワナイダーのともえなげ
  await tapMove(driver, me, 'ともえなげ', true);
  // ガブリアスのHP90
  await inputRemainHP(driver, me, '90');
  // ドヒドイデに交代
  await changePokemon(driver, me, 'ドヒドイデ', false);
  // TODO: ともえなげのとき、さめはだが自動入力されない＆なんか変なタイミングで出る(たぶんともえなげで登場するとき)
  // ガブリアスのさめはだ
  // TODO: さめはだ選択できるが、さめはだを持つのがドヒドイデに設定されてしまう
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ワナイダー->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ドヒドイデのどくどく
  await tapMove(driver, op, 'どくどく', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ドヒドイデのHP70
  await inputRemainHP(driver, me, '70');
  // ドヒドイデのひやみず
  await tapMove(driver, op, 'ひやみず', true);
  // ボーマンダのHP156
  await inputRemainHP(driver, op, '156');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', true);
  // ドヒドイデのトーチカ
  await tapMove(driver, op, 'トーチカ', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのテラスタル
  await inputTerastal(driver, me, '');
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ドヒドイデのHP20
  await inputRemainHP(driver, me, '20');
  // ドヒドイデのどくどく
  await tapMove(driver, op, 'どくどく', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドヒドイデのトーチカ
  await tapMove(driver, op, 'トーチカ', false);
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ドヒドイデのHP20
  await inputRemainHP(driver, me, '');
  // ドヒドイデのくろいヘドロ
  await addEffect(driver, 3, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドヒドイデのテラスタル
  await inputTerastal(driver, op, 'どく');
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ドヒドイデのHP0
  await inputRemainHP(driver, me, '0');
  // ドヒドイデひんし->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのまもる
  await tapMove(driver, op, 'まもる', true);
  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ニンフィアのHP95
  await inputRemainHP(driver, me, '');
  // ニンフィアのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ワナイダーに交代
  await changePokemon(driver, me, 'ワナイダー', true);
  // ニンフィア->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', false);
  // ワナイダーのともえなげ
  await tapMove(driver, me, 'ともえなげ', true);
  // ガブリアスのHP80
  await inputRemainHP(driver, me, '80');
  // ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ガブリアスのさめはだ
  // TODO:選べない
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ワナイダーのHP43
  await inputRemainHP(driver, op, '43');
  // ワナイダーのともえなげ
  await tapMove(driver, me, 'ともえなげ', true);
  // ニンフィアのHP95
  await inputRemainHP(driver, me, '95');
  // ガブリアスに交代
  await changePokemon(driver, me, 'ガブリアス', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのほのおのキバ
  await tapMove(driver, op, 'ほのおのキバ', true);
  // ワナイダーのHP0
  await inputRemainHP(driver, op, '0');
  // ワナイダーひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ガブリアスのHP30
  await inputRemainHP(driver, me, '30');
  // ガブリアスはひるんで技がだせない
  await driver.tap(find.text('ガブリアスはひるんで技がだせない'));
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ニンフィアのHP70
  await inputRemainHP(driver, me, '70');
  // ニンフィアのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ニンフィアのまもる
  await tapMove(driver, op, 'まもる', false);
  // ニンフィアのHP76
  await inputRemainHP(driver, me, '');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, me, 'トリックフラワー', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マスカーニャ戦3
Future<void> test18_3(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうマスカーニャ戦3',
    ownPartyname: '18もこカーニャ',
    opponentName: 'カナリア',
    pokemon1: 'キノガッサ',
    pokemon2: 'セグレイブ',
    pokemon3: 'サーフゴー',
    pokemon4: 'オノノクス',
    pokemon5: 'キョジオーン',
    pokemon6: 'ヘイラッシャ',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'キョジオーン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // キョジオーンのHP70
  await inputRemainHP(driver, me, '70');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('ゴツゴツメット');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ゴツゴツメット')));
  // キョジオーンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', true);
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // キョジオーンのじわれ
  await tapMove(driver, op, 'じわれ', true);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // キョジオーンひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // キョジオーンのHP50
  await inputRemainHP(driver, me, '50');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // ボーマンダのHP92
  await inputRemainHP(driver, op, '92');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // キョジオーンのHP2
  await inputRemainHP(driver, me, '2');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', false);
  // ボーマンダのHP26
  await inputRemainHP(driver, op, '26');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ボーマンダひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのテラスタル
  await inputTerastal(driver, me, '');
  // マスカーニャのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // サーフゴーのHP60
  await inputRemainHP(driver, me, '60');
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // カナリアの勝利
  await testExistEffect(driver, 'カナリアの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// マスカーニャ戦4
Future<void> test18_4(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうマスカーニャ戦4',
    ownPartyname: '18もこカーニャ',
    opponentName: 'わいゆー',
    pokemon1: 'オーロンゲ',
    pokemon2: 'パルシェン',
    pokemon3: 'ボーマンダ',
    pokemon4: 'リククラゲ',
    pokemon5: 'ドラパルト',
    pokemon6: 'ウルガモス',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // マリルリのHP161
  await inputRemainHP(driver, op, '161');
  // パルシェンに交代
  await changePokemon(driver, op, 'パルシェン', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // パルシェンのからをやぶる
  await tapMove(driver, op, 'からをやぶる', true);
  // マリルリのばかぢから
  await tapMove(driver, me, 'ばかぢから', false);
  // パルシェンのHP1
  await inputRemainHP(driver, me, '1');
  // パルシェンのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // パルシェンのHP0
  await inputRemainHP(driver, me, '0');
  // パルシェンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', true);
  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // マスカーニャひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // ヘルガーのHP49
  await inputRemainHP(driver, op, '49');
  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトののろわれボディ
  await addEffect(driver, 2, op, 'のろわれボディ');
  await driver.tap(find.text('OK'));
  // ドラパルトひんし->リククラゲに交代
  await changePokemon(driver, op, 'リククラゲ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // リククラゲのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウェーニバル戦1
Future<void> test19_1(
  FlutterDriver driver,
) async {
  int turnNum = 0;
  await backBattleTopPage(driver);
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうウェーニバル戦1',
    ownPartyname: '19もこニバル',
    opponentName: 'カツコ',
    pokemon1: 'ドラパルト',
    pokemon2: 'デカヌチャン',
    pokemon3: 'サザンドラ',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ミミッキュ',
    pokemon6: 'バンギラス',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニバル/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // オリーヴァのHP153
  await inputRemainHP(driver, op, '153');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトム->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', false);
  // ロトムのすなおこし
  await addEffect(driver, 3, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // バンギラスのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', true);
  // オリーヴァのHP59
  await inputRemainHP(driver, op, '59');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // バンギラスのHP50
  await inputRemainHP(driver, me, '50');
  // バンギラスのじゃくてんほけん
  await addEffect(driver, 3, op, 'じゃくてんほけん');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // バンギラスのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ウェーニバルのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', true);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', false);
  // キョジオーンのHP150
  await inputRemainHP(driver, op, '150');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトム->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', true);
  // キョジオーン->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', true);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // バンギラス->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ロトムのHP70
  await inputRemainHP(driver, me, '70');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->バンギラスに交代
  await changePokemon(driver, op, 'バンギラス', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのテラスタル
  await inputTerastal(driver, me, '');
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウェーニバル戦2
Future<void> test19_2(
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
    battleName: 'もこうウェーニバル戦2',
    ownPartyname: '19もこニバル',
    opponentName: 'ソンフンミン',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ニンフィア',
    pokemon3: 'ミミッキュ',
    pokemon4: 'カバルドン',
    pokemon5: 'ドラパルト',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニバル/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'ニンフィア');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // オリーヴァのHP88
  await inputRemainHP(driver, op, '88');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', false);
  // オリーヴァのHP37
  await inputRemainHP(driver, op, '37');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ニンフィアのHP60
  await inputRemainHP(driver, me, '60');
  // オリーヴァのしゅうかく
  await addEffect(driver, 2, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // オリーヴァのオボンのみ
  await addEffect(driver, 3, me, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', false);
  // オリーヴァのHP33
  await inputRemainHP(driver, op, '33');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ニンフィアのHP40
  await inputRemainHP(driver, me, '40');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', false);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ニンフィアひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // マスカーニャのHP1
  await inputRemainHP(driver, me, '1');
  // マスカーニャのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // ウェーニバルのHP0
  await inputRemainHP(driver, op, '0');
  // ウェーニバルひんし->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ソンフンミンの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウェーニバル戦3
Future<void> test19_3(
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
    battleName: 'もこうウェーニバル戦3',
    ownPartyname: '19もこニバル2',
    opponentName: 'ジオ',
    pokemon1: 'キラフロル',
    pokemon2: 'マスカーニャ',
    pokemon3: 'ルガルガン(たそがれのすがた)',
    pokemon4: 'アーマーガア',
    pokemon5: 'ソウブレイズ',
    pokemon6: 'オノノクス',
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこニバル/',
      ownPokemon3: 'ねつじょう/',
      opponentPokemon: 'オノノクス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オノノクスのかたやぶり
  await addEffect(driver, 0, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // オノノクスのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // ミミズズのHP45
  await inputRemainHP(driver, op, '45');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オノノクス->ルガルガンに交代
  await changePokemon(driver, op, 'ルガルガン(たそがれのすがた)', true);
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ルガルガンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ルガルガンのHP80
  await inputRemainHP(driver, me, '80');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ルガルガンのアクセルロック
  await tapMove(driver, op, 'アクセルロック', true);
  // ミミズズのHP72
  await inputRemainHP(driver, op, '72');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ルガルガンのHP60
  await inputRemainHP(driver, me, '60');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ルガルガンのアクセルロック
  await tapMove(driver, op, 'アクセルロック', false);
  // ミミズズのHP54
  await inputRemainHP(driver, op, '54');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ルガルガンのHP40
  await inputRemainHP(driver, me, '40');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ミミズズ->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', true);
  // ルガルガンのアクセルロック
  await tapMove(driver, op, 'アクセルロック', false);
  // ウェーニバルのHP123
  await inputRemainHP(driver, op, '123');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ルガルガン->オノノクスに交代
  await changePokemon(driver, op, 'オノノクス', true);
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // オノノクスのHP70
  await inputRemainHP(driver, me, '70');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // オノノクスのHP0
  await inputRemainHP(driver, me, '0');
  // オノノクスひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのテラスタル
  await inputTerastal(driver, me, '');
  // マスカーニャのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // マスカーニャのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // ウェーニバルのHP14
  await inputRemainHP(driver, op, '14');
  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->ルガルガンに交代
  await changePokemon(driver, op, 'ルガルガン(たそがれのすがた)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ルガルガンのアクセルロック
  await tapMove(driver, op, 'アクセルロック', false);
  // ウェーニバルのHP0
  await inputRemainHP(driver, op, '0');
  // ウェーニバルひんし->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ルガルガンのきしかいせい
  await tapMove(driver, op, 'きしかいせい', true);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // ルガルガンのHP0
  await inputRemainHP(driver, me, '0');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウェーニバル戦4
Future<void> test19_4(
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
    battleName: 'もこうウェーニバル戦4',
    ownPartyname: '19もこニバル2',
    opponentName: 'まさにー',
    pokemon1: 'カイリュー',
    pokemon2: 'サーフゴー',
    pokemon3: 'セグレイブ',
    pokemon4: 'サザンドラ',
    pokemon5: 'ドラパルト',
    pokemon6: 'デカヌチャン',
    sex1: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこニバル/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ミミズズのHP78
  await inputRemainHP(driver, op, '78');
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ミミズズのHP28
  await inputRemainHP(driver, op, '28');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ドラパルトのHP80
  await inputRemainHP(driver, me, '80');
  // ドラパルトのすばやさが下がらない
  await driver.tap(find.text('ドラパルトはすばやさが下がった'));
  // ドラパルトのとくせいがクリアボディと断定
  await editPokemonState(driver, 'ドラパルト/まさにー', null, 'クリアボディ', null);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // TODO:ウェーにバルに対するシャドーボールのダメージ表示が大きい値～小さい値になっている？
  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ウェーニバルのHP44
  await inputRemainHP(driver, op, '44');
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ドラパルトのHP52
  await inputRemainHP(driver, me, '52');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // ウェーニバルのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウェーニバル戦5
Future<void> test19_5(
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
    battleName: 'もこうウェーニバル戦5',
    ownPartyname: '19もこニバル',
    opponentName: 'あやのごう',
    pokemon1: 'ラウドボーン',
    pokemon2: 'ミミッキュ',
    pokemon3: 'マスカーニャ',
    pokemon4: 'サーフゴー',
    pokemon5: 'ハッサム',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'ねつじょう/',
      ownPokemon2: 'もこニバル/',
      ownPokemon3: 'もこーヴァ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ヘルガーのHP75
  await inputRemainHP(driver, op, '75');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ヘルガーのあくのはどう
  await tapMove(driver, me, 'あくのはどう', false);
  // ラウドボーンのHP20
  await inputRemainHP(driver, me, '20');
  // マスカーニャのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのふいうち
  await tapMove(driver, me, 'ふいうち', false);
  // マスカーニャのHP85
  await inputRemainHP(driver, me, '85');
  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // オリーヴァのHP88
  await inputRemainHP(driver, op, '88');
  // オリーヴァのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // マスカーニャのふうせん
  await addEffect(driver, 3, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // サーフゴーのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP75
  await inputRemainHP(driver, op, '75');
  // オリーヴァのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // サーフゴーのHP75
  await inputRemainHP(driver, me, '');
  // TODO: ふうせん自動で割れてほしい
  // サーフゴーのふうせん
  await addEffect(driver, 4, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // オリーヴァのHP0
  await inputRemainHP(driver, op, '0');
  // オリーヴァひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ウェーニバルのHP31
  await inputRemainHP(driver, op, '31');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カラミンゴ戦1
Future<void> test20_1(
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
    battleName: 'もこうカラミンゴ戦1',
    ownPartyname: '20もこミンゴ',
    opponentName: 'リンウェル',
    pokemon1: 'サザンドラ',
    pokemon2: 'サーフゴー',
    pokemon3: 'ドラパルト',
    pokemon4: 'マスカーニャ',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'ウルガモス',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミンゴ/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ヘイラッシャのあくび
  await tapMove(driver, op, 'あくび', true);
  await tapSuccess(driver, op);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴ->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', true);
  // ヘイラッシャのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // オリーヴァのHP142
  await inputRemainHP(driver, op, '142');
  // ヘイラッシャのHP95
  await inputRemainHP(driver, op, '95');
  // ヘイラッシャのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ヘイラッシャのHP30
  await inputRemainHP(driver, me, '30');
  // ヘイラッシャのじわれ
  await tapMove(driver, op, 'じわれ', true);
  // 外れる
  await tapHit(driver, op);
  // オリーヴァのHP142
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // ヘイラッシャひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ウルガモスのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オリーヴァのテラスタル
  await inputTerastal(driver, me, '');
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // オリーヴァのHP91
  await inputRemainHP(driver, op, '91');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ウルガモスのHP70
  await inputRemainHP(driver, me, '70');
  // オリーヴァのしゅうかく
  await addEffect(driver, 4, me, 'しゅうかく');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', false);
  // オリーヴァのHP86
  await inputRemainHP(driver, op, '86');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // ウルガモスのHP30
  await inputRemainHP(driver, me, '30');
  // ウルガモスはとくぼうが下がった
  await driver.tap(find.text('ウルガモスはとくぼうが下がった'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カラミンゴ戦2
Future<void> test20_2(
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
    battleName: 'もこうカラミンゴ戦2',
    ownPartyname: '20もこミンゴ2',
    opponentName: 'ふなびと',
    pokemon1: 'ウルガモス',
    pokemon2: 'ドラパルト',
    pokemon3: 'ドドゲザン',
    pokemon4: 'モロバレル',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex1: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミンゴ/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'ドドゲザン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザン->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ロトムのHP2
  await inputRemainHP(driver, me, '2');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴ->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', true);
  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // キョジオーンのHP134
  await inputRemainHP(driver, op, '134');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ロトムの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', false);
  // キョジオーンのHP71
  await inputRemainHP(driver, op, '71');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // キョジオーンひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ドラパルトのとくせいがドラゴンアローと判明
  await editPokemonState(driver, 'ドラパルト/ふなびと', null, 'クリアボディ', null);
  // TODO:ランク変化も編集できるようにしたい
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', true);
  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // ドドゲザンのHP60
  await inputRemainHP(driver, me, '60');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->カラミンゴに交代
  await changePokemon(driver, me, 'カラミンゴ', true);
  // ドドゲザンのかわらわり
  await tapMove(driver, op, 'かわらわり', true);
  // カラミンゴのHP108
  await inputRemainHP(driver, op, '108');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // ドドゲザンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', true);
  // カラミンゴのHP93
  await inputRemainHP(driver, op, '');
  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP100
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // カラミンゴのHP0
  await inputRemainHP(driver, op, '0');
  // カラミンゴひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カラミンゴ戦3
Future<void> test20_3(
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
    battleName: 'もこうカラミンゴ戦3',
    ownPartyname: '20もこミンゴ',
    opponentName: 'セジュン',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ドドゲザン',
    pokemon3: 'モロバレル',
    pokemon4: 'サーフゴー',
    pokemon5: 'ラウドボーン',
    pokemon6: 'マスカーニャ',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミンゴ/',
      ownPokemon2: 'もこーヴァ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // カラミンゴのHP140
  await inputRemainHP(driver, op, '140');
  // ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ラウドボーンのHP55
  await inputRemainHP(driver, me, '55');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ラウドボーンのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // TODO: このテラバーストのダメージ計算間違ってるっぽい？
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ラウドボーンひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ボーマンダのHP56
  await inputRemainHP(driver, op, '56');
  // ボーマンダのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // マスカーニャのHP40
  await inputRemainHP(driver, me, '40');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->カラミンゴに交代
  await changePokemon(driver, me, 'カラミンゴ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // マスカーニャのふうせん
  await addEffect(driver, 1, op, 'ふうせん');
  await driver.tap(find.text('OK'));
  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // カラミンゴのHP0
  await inputRemainHP(driver, op, '0');
  // カラミンゴひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // オリーヴァのHP101
  await inputRemainHP(driver, op, '101');
  // オリーヴァのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// カラミンゴ戦4
Future<void> test20_4(
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
    battleName: 'もこうカラミンゴ戦4',
    ownPartyname: '20もこミンゴ',
    opponentName: 'アオイ',
    pokemon1: 'サザンドラ',
    pokemon2: 'ミミッキュ',
    pokemon3: 'サーフゴー',
    pokemon4: 'モロバレル',
    pokemon5: 'ドラパルト',
    pokemon6: 'マスカーニャ',
    sex1: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニンフィア/',
      ownPokemon2: 'もこミンゴ/',
      ownPokemon3: 'もこーヴァ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->カラミンゴに交代
  await changePokemon(driver, me, 'カラミンゴ', true);
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // カラミンゴのHP137
  await inputRemainHP(driver, op, '137');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', false);
  // ニンフィアのHP175
  await inputRemainHP(driver, op, '175');
  // モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // ニンフィアのHP164
  await inputRemainHP(driver, op, '164');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // モロバレルのHP85
  await inputRemainHP(driver, me, '85');
  // モロバレルのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->カラミンゴに交代
  await changePokemon(driver, me, 'カラミンゴ', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カラミンゴのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // モロバレルのHP0
  await inputRemainHP(driver, me, '0');
  // カラミンゴのHP62
  await inputRemainHP(driver, me, '62');
  // モロバレルひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', true);
  // カラミンゴのHP47
  await inputRemainHP(driver, op, '');
  // カラミンゴのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // 外れる
  await tapHit(driver, me);
  // ドラパルトのHP100
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのゴーストダイブ
  await tapMove(driver, op, 'ゴーストダイブ', false);
  // カラミンゴのHP0
  await inputRemainHP(driver, op, '0');
  // カラミンゴひんし->オリーヴァに交代
  await changePokemon(driver, me, 'オリーヴァ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// カラミンゴ戦1
Future<void> test20_1(
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
