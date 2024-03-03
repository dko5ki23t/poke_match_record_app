import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver? driver;
  bool doTest = true;

  setUpAll(() async {
    try {
      driver = await FlutterDriver.connect(
              dartVmServiceUrl: 'http://localhost:8888/')
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception();
      });
    } catch (e) {
      print('Flutter driver connection failed');
      doTest = false;
    }
  });

  tearDownAll(() async {
    if (driver != null) {
      await driver!.close();
    }
  });

  group('統合テスト(もこうの実況を記録)', () {
    int minutesPerTest = 3;
    test('パーモット戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_1(driver!);
      }
    });
    test('パーモット戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_2(driver!);
      }
    });
    test('パーモット戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_3(driver!);
      }
    });
    test('パーモット戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_4(driver!);
      }
    });
    test('イルカマン戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_1(driver!);
      }
    });
    test('イルカマン戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_2(driver!);
      }
    });
    test('イルカマン戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_3(driver!);
      }
    });
    test('イルカマン戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_4(driver!);
      }
    });
    test('イッカネズミ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_1(driver!);
      }
    });
    test('イッカネズミ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_2(driver!);
      }
    });
    test('イッカネズミ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_3(driver!);
      }
    });
    test('イッカネズミ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_4(driver!);
      }
    });
    test('ミミズズ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_1(driver!);
      }
    });
    test('ミミズズ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_2(driver!);
      }
    });
  });
}

/// パーモット戦1
Future<void> test1_1(
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
  await tapMove(driver, PlayerType.me, 'りゅうのまい', false);
  await testExistAnyWidgets(find.text('成功'), driver);
  // デカヌチャンのがんせきふうじ
  await tapMove(driver, PlayerType.opponent, 'がんせきふうじ', true);
  // ボーマンダの残りHP127
  await inputRemainHP(driver, PlayerType.opponent, '127');
  await testExistAnyWidgets(find.text('ボーマンダはすばやさが下がった'), driver);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのじしん
  await tapMove(driver, PlayerType.me, 'じしん', false);
  // デカヌチャンの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // デカヌチャンひんし→テツノツツミに交代
  await changePokemon(driver, PlayerType.opponent, 'テツノツツミ', false);
  // クォークチャージ発動
  await addEffect(driver, 2, 'クォークチャージ');
  // クォークチャージの内容編集
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // 追加されてるか確認
  await testExistEffect(driver, 'クォークチャージ');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, PlayerType.me, 'げきりん', false);
  // テツノツツミの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // テツノツツミひんし→ギャラドスに交代
  await changePokemon(driver, PlayerType.opponent, 'ギャラドス', false);
  // いかく発動
  await addEffect(driver, 2, 'いかく');
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
  await addEffect(driver, 1, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // 追加されてるか確認
  await testExistEffect(driver, 'こだいかっせい');
  // ボーマンダのダブルウイング
  await tapMove(driver, PlayerType.me, 'ダブルウイング', false);
  // チヲハウハネ->ミミッキュに交代
  await changePokemon(driver, PlayerType.opponent, 'ミミッキュ', true);
  // ボーマンダのダブルウイングが外れる
  await setHitCount(driver, PlayerType.me, 0);
  await inputRemainHP(driver, PlayerType.me, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのダブルウイング
  await tapMove(driver, PlayerType.me, 'ダブルウイング', false);
  // ミミッキュの残りHP70
  await inputRemainHP(driver, PlayerType.me, '70');
  // ミミッキュのじゃれつく
  await tapMove(driver, PlayerType.opponent, 'じゃれつく', true);
  // ボーマンダの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ミミッキュのもちものがいのちのたまと判明
  await editPokemonState(driver, 'ミミッキュ/k.k', null, null, 'いのちのたま');
  // ボーマンダひんし→リーフィアに交代
  await changePokemon(driver, PlayerType.me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // 相手ミミッキュ→チヲハウハネに交代
  await changePokemon(driver, PlayerType.opponent, 'チヲハウハネ', true);
  // リーフィアのリーフブレード
  await tapMove(driver, PlayerType.me, 'リーフブレード', false);
  // チヲハウハネの残りHP70
  await inputRemainHP(driver, PlayerType.me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのテラバースト
  await tapMove(driver, PlayerType.me, 'テラバースト', false);
  // チヲハウハネの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // チヲハウハネひんし→サザンドラに交代
  await changePokemon(driver, PlayerType.opponent, 'サザンドラ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのでんこうせっか
  await tapMove(driver, PlayerType.me, 'でんこうせっか', false);
  // サザンドラの残りHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // サザンドラのあくのはどう
  await tapMove(driver, PlayerType.opponent, 'あくのはどう', true);
  // リーフィアの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // リーフィアひんし→パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手サザンドラ→ミミッキュに交代
  await changePokemon(driver, PlayerType.opponent, 'ミミッキュ', true);
  // パーモットのさいきのいのりでボーマンダ復活
  await tapMove(driver, PlayerType.me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('ボーマンダ'), driver);
  await driver.tap(find.text('ボーマンダ'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミッキュのじゃれつく
  await tapMove(driver, PlayerType.opponent, 'じゃれつく', false);
  // パーモットの残りHP1
  await inputRemainHP(driver, PlayerType.opponent, '1');
  // きあいのタスキ発動
  await addEffect(driver, 1, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'きあいのタスキ');
  // パーモットのでんこうそうげき
  await tapMove(driver, PlayerType.me, 'でんこうそうげき', false);
  // ミミッキュの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ミミッキュひんし→サザンドラに交代
  await changePokemon(driver, PlayerType.opponent, 'サザンドラ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのりゅうせいぐん
  await tapMove(driver, PlayerType.opponent, 'りゅうせいぐん', true);
  // サザンドラのりゅうせいぐんが外れる
  await tapHit(driver, PlayerType.opponent);
  await inputRemainHP(driver, PlayerType.opponent, '');
  // パーモットのインファイト
  await tapMove(driver, PlayerType.me, 'インファイト', false);
  // サザンドラの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦3
Future<void> test1_3(
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
  await inputTerastal(driver, PlayerType.opponent, 'いわ');
  // ウルガモスのちょうのまい
  await tapMove(driver, PlayerType.opponent, 'ちょうのまい', true);
  // ボーマンダのダブルウイング
  await tapMove(driver, PlayerType.me, 'ダブルウイング', false);
  // ウルガモスの残りHP70
  await inputRemainHP(driver, PlayerType.me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのテラバースト
  await tapMove(driver, PlayerType.opponent, 'テラバースト', true);
  // ボーマンダの残りHP70
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ボーマンダひんし→マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // 相手ウルガモス→トドロクツキに交代
  await changePokemon(driver, PlayerType.opponent, 'トドロクツキ', true);
  // トドロクツキのこだいかっせい
  await addEffect(driver, 2, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'こだいかっせい');
  // マリルリのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // トドロクツキの残りHP70
  await inputRemainHP(driver, PlayerType.me, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのつじぎり
  await tapMove(driver, PlayerType.opponent, 'つじぎり', true);
  // マリルリの残りHP93
  await inputRemainHP(driver, PlayerType.opponent, '93');
  // マリルリのじゃれつく
  await tapMove(driver, PlayerType.me, 'じゃれつく', false);
  // きゅうしょ命中
  await tapCritical(driver, PlayerType.me);
  // トドロクツキの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // トドロクツキひんし→バンギラスに交代
  await changePokemon(driver, PlayerType.opponent, 'バンギラス', false);
  // バンギラスのとくせいがすなおこしと判明
  //await editPokemonState(driver, 'バンギラス/Daikon', null, 'すなおこし', null);
  // バンギラスのすなおこし
  await addEffect(driver, 3, 'すなおこし');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'すなおこし');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // バンギラスのいわなだれ
  await tapMove(driver, PlayerType.opponent, 'いわなだれ', true);
  // マリルリの残りHP48
  await inputRemainHP(driver, PlayerType.opponent, '48');
  await testExistAnyWidgets(find.text('マリルリはひるんで技がだせない'), driver);
  await driver.tap(find.text('マリルリはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // きゅうしょ命中
  await tapCritical(driver, PlayerType.me);
  // バンギラスの残りHP30
  await inputRemainHP(driver, PlayerType.me, '30');
  // バンギラスのじだんだ
  await tapMove(driver, PlayerType.opponent, 'じだんだ', true);
  // マリルリの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // マリルリひんし→パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのりでボーマンダ復活
  await tapMove(driver, PlayerType.me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('マリルリ'), driver);
  await driver.tap(find.text('マリルリ'));
  // バンギラスのじだんだ
  await tapMove(driver, PlayerType.opponent, 'じだんだ', false);
  // パーモットの残りHP12
  await inputRemainHP(driver, PlayerType.opponent, '12');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手バンギラス→ウルガモスに交代
  await changePokemon(driver, PlayerType.opponent, 'ウルガモス', true);
  // パーモットのインファイト
  await tapMove(driver, PlayerType.me, 'インファイト', false);
  // ウルガモスの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ウルガモスひんし→バンギラスに交代
  await changePokemon(driver, PlayerType.opponent, 'バンギラス', false);
  // パーモットひんし→マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // バンギラスの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦4
Future<void> test1_4(
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
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // ソウブレイズの残りHP40
  await inputRemainHP(driver, PlayerType.me, '40');
  // ソウブレイズのくだけるよろい
  await addEffect(driver, 1, 'くだけるよろい');
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'くだけるよろい');
  // ソウブレイズのレッドカード
  await addEffect(driver, 2, 'レッドカード');
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('パーモット'));
  await driver.tap(find.text('OK'));
  await testExistEffect(driver, 'レッドカード');
  // ソウブレイズのつるぎのまい
  await tapMove(driver, PlayerType.opponent, 'つるぎのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモット->マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', true);
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, PlayerType.opponent, 'むねんのつるぎ', true);
  // マリルリの残りHP90
  await inputRemainHP(driver, PlayerType.opponent, '90');
  // ソウブレイズの残りHP70に回復
  await inputRemainHP(driver, PlayerType.opponent, '70');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ソウブレイズのかげうち
  await tapMove(driver, PlayerType.opponent, 'かげうち', true);
  // マリルリの残りHP2
  await inputRemainHP(driver, PlayerType.opponent, '2');
  // マリルリのアクアジェット
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ソウブレイズひんし→セグレイブに交代
  await changePokemon(driver, PlayerType.opponent, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのこおりのつぶて
  await tapMove(driver, PlayerType.opponent, 'こおりのつぶて', true);
  // マリルリの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // マリルリひんし→パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのりでマリルリ復活
  await tapMove(driver, PlayerType.me, 'さいきのいのり', false);
  await testExistAnyWidgets(find.text('マリルリ'), driver);
  await driver.tap(find.text('マリルリ'));
  // セグレイブのきょけんとつげき
  await tapMove(driver, PlayerType.opponent, 'きょけんとつげき', true);
  // パーモットの残りHP1
  await inputRemainHP(driver, PlayerType.opponent, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, 'きあいのタスキ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのこおりのつぶて
  await tapMove(driver, PlayerType.opponent, 'こおりのつぶて', false);
  // パーモットの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // パーモットひんし→マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手セグレイブ->ドドゲザンに交代
  await changePokemon(driver, PlayerType.opponent, 'ドドゲザン', true);
  // ドドゲザンのプレッシャー
  await addEffect(driver, 1, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // マリルリのじゃれつく
  await tapMove(driver, PlayerType.me, 'じゃれつく', false);
  // ドドゲザンの残りHP60
  await inputRemainHP(driver, PlayerType.me, '60');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドドゲザンのテラスタル
  await inputTerastal(driver, PlayerType.opponent, 'ゴースト');
  // マリルリのアクアジェット
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // ドドゲザンの残りHP35
  await inputRemainHP(driver, PlayerType.me, '35');
  // ドドゲザンのテラバースト
  await tapMove(driver, PlayerType.opponent, 'テラバースト', true);
  // 急所に命中
  await tapCritical(driver, PlayerType.opponent);
  // マリルリの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // マリルリひんし→リキキリンに交代
  await changePokemon(driver, PlayerType.me, 'リキキリン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // リキキリンのこうそくいどう
  await tapMove(driver, PlayerType.me, 'こうそくいどう', false);
  // ドドゲザンのドゲザン
  await tapMove(driver, PlayerType.opponent, 'ドゲザン', true);
  // リキキリンの残りHP163
  await inputRemainHP(driver, PlayerType.opponent, '163');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのツインビーム
  await tapMove(driver, PlayerType.me, 'ツインビーム', false);
  // ドドゲザンの残りHP5
  await inputRemainHP(driver, PlayerType.me, '5');
  // ドドゲザンのテラバースト
  await tapMove(driver, PlayerType.opponent, 'テラバースト', false);
  // リキキリンの残りHP54
  await inputRemainHP(driver, PlayerType.opponent, '54');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのツインビーム
  await tapMove(driver, PlayerType.me, 'ツインビーム', false);
  // ドドゲザンの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ドドゲザンひんし→セグレイブに交代
  await changePokemon(driver, PlayerType.opponent, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンのテラバースト
  await tapMove(driver, PlayerType.me, 'テラバースト', false);
  // セグレイブの残りHP25
  await inputRemainHP(driver, PlayerType.me, '25');
  // セグレイブのじゃくてんほけん
  await addEffect(driver, 1, 'じゃくてんほけん');
  await driver.tap(find.text('OK'));
  // セグレイブのきょけんとつげき
  await tapMove(driver, PlayerType.opponent, 'きょけんとつげき', false);
  // リキキリンの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // あいての勝利
  await testExistEffect(driver, 'アイアムあむの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦1
Future<void> test2_1(
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
  await changePokemon(driver, PlayerType.me, 'ニンフィア', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, PlayerType.opponent, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, PlayerType.opponent);
  await inputRemainHP(driver, PlayerType.opponent, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのボルトチェンジ
  await tapMove(driver, PlayerType.opponent, 'ボルトチェンジ', false);
  // ニンフィアのHP157
  await inputRemainHP(driver, PlayerType.opponent, '157');
  // キラフロルに交代
  await changePokemon(driver, PlayerType.opponent, 'キラフロル', false);
  // ニンフィアのハイパーボイス
  await tapMove(driver, PlayerType.me, 'ハイパーボイス', false);
  // キラフロルのHP80
  await inputRemainHP(driver, PlayerType.me, '80');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キラフロルのステルスロック
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);
  // ニンフィアのあくび
  await tapMove(driver, PlayerType.me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンに交代
  await changePokemon(driver, PlayerType.me, 'イルカマン', true);
  // キラフロルのヘドロウェーブ
  await tapMove(driver, PlayerType.opponent, 'ヘドロウェーブ', true);
  // イルカマンのHP71
  await inputRemainHP(driver, PlayerType.opponent, '71');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キラフロルはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // イルカマンのウェーブタックル
  await tapMove(driver, PlayerType.me, 'ウェーブタックル', false);
  // キラフロルのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // イルカマンのHP83
  await inputRemainHP(driver, PlayerType.me, '83');
  // どくげしょう発動
  await addEffect(driver, 2, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // キラフロルひんし→パオジアンに交代
  await changePokemon(driver, PlayerType.opponent, 'パオジアン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, PlayerType.me, 'ジェットパンチ', false);
  // パオジアンのHP45
  await inputRemainHP(driver, PlayerType.me, '45');
  // パオジアンのつるぎのまい
  await tapMove(driver, PlayerType.opponent, 'つるぎのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パオジアンのテラスタル
  await inputTerastal(driver, PlayerType.opponent, 'こおり');
  // イルカマンのジェットパンチ
  await tapMove(driver, PlayerType.me, 'ジェットパンチ', false);
  // パオジアンのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // パオジアンひんし→ロトムに交代
  await changePokemon(driver, PlayerType.opponent, 'ロトム(ウォッシュロトム)', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムの１０まんボルト
  await tapMove(driver, PlayerType.opponent, '１０まんボルト', true);
  // イルカマンのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // イルカマンひんし→リーフィアに交代
  await changePokemon(driver, PlayerType.me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムの１０まんボルト
  await tapMove(driver, PlayerType.opponent, '１０まんボルト', false);
  // 急所に命中
  await tapCritical(driver, PlayerType.opponent);
  // リーフィアのHP39
  await inputRemainHP(driver, PlayerType.opponent, '39');
  // リーフィアのリーフブレード
  await tapMove(driver, PlayerType.me, 'リーフブレード', false);
  // ロトムの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦2
Future<void> test2_2(
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
  await addEffect(driver, 0, 'ひでり');
  await driver.tap(find.text('OK'));
  // イルカマンのクイックターン
  await tapMove(driver, PlayerType.me, 'クイックターン', false);
  // コータスのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // ニンフィアに交代
  await changePokemon(driver, PlayerType.me, 'ニンフィア', false);
  // コータスのステルスロック
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのあくび
  await tapMove(driver, PlayerType.me, 'あくび', false);
  // コータスのかえんほうしゃ
  await tapMove(driver, PlayerType.opponent, 'かえんほうしゃ', true);
  // ニンフィアのHP115
  await inputRemainHP(driver, PlayerType.opponent, '115');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィア->イルカマンに交代
  await changePokemon(driver, PlayerType.me, 'イルカマン', true);
  // 相手コータス->ハバタクカミに交代
  await changePokemon(driver, PlayerType.opponent, 'ハバタクカミ', true);
  // こだいかっせい編集
  await tapEffect(driver, 'こだいかっせい');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // ハバタクカミのムーンフォース
  await tapMove(driver, PlayerType.opponent, 'ムーンフォース', true);
  // イルカマンのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // イルカマンひんし→リーフィアに交代
  await changePokemon(driver, PlayerType.me, 'リーフィア', false);
  // ハバタクカミのいのちのたま
  await addEffect(driver, 2, 'いのちのたま');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのリーフブレード
  await tapMove(driver, PlayerType.me, 'リーフブレード', false);
  // ハバタクカミのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ハバタクカミひんし→スコヴィランに交代
  await changePokemon(driver, PlayerType.opponent, 'スコヴィラン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのテラバースト
  await tapMove(driver, PlayerType.me, 'テラバースト', false);
  // スコヴィランのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // スコヴィランのかえんほうしゃ
  await tapMove(driver, PlayerType.opponent, 'かえんほうしゃ', true);
  // リーフィアのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // リーフィアひんし→ニンフィアに交代
  await changePokemon(driver, PlayerType.me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // スコヴィランのオーバーヒート
  await tapMove(driver, PlayerType.opponent, 'オーバーヒート', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // 相手の勝利
  await testExistEffect(driver, '雪見櫻の勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦3
Future<void> test2_3(
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
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);
  // イルカマンのクイックターン
  await tapMove(driver, PlayerType.me, 'クイックターン', false);
  // コータスのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // ニンフィアに交代
  await changePokemon(driver, PlayerType.me, 'ニンフィア', false);
  // ガブリアスのさめはだ
  await addEffect(driver, 2, 'さめはだ');
  await driver.tap(find.text('OK'));
  // 交換先のニンフィアにさめはだダメージが入っていないことを確認
  await testHP(driver, PlayerType.me, '202/202');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ガブリアスのじしん
  await tapMove(driver, PlayerType.opponent, 'じしん', true);
  // ニンフィアのHP86
  await inputRemainHP(driver, PlayerType.opponent, '86');
  // ニンフィアのハイパーボイス
  await tapMove(driver, PlayerType.me, 'ハイパーボイス', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ガブリアスひんし→テツノツツミに交代
  await changePokemon(driver, PlayerType.opponent, 'テツノツツミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのでんこうせっか
  await tapMove(driver, PlayerType.me, 'でんこうせっか', false);
  // テツノツツミのHP95
  await inputRemainHP(driver, PlayerType.me, '95');
  // テツノツツミのゆきげしき
  await tapMove(driver, PlayerType.opponent, 'ゆきげしき', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのフリーズドライ
  await tapMove(driver, PlayerType.opponent, 'フリーズドライ', true);
  // ニンフィアのHP37
  await inputRemainHP(driver, PlayerType.opponent, '37');
  // ニンフィアのあくび
  await tapMove(driver, PlayerType.me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのエレキフィールド
  await tapMove(driver, PlayerType.opponent, 'エレキフィールド', true);
  // クォークチャージ編集
  await tapEffect(driver, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));
  // ニンフィアのハイパーボイス
  await tapMove(driver, PlayerType.me, 'ハイパーボイス', false);
  // テツノツツミのHP20
  await inputRemainHP(driver, PlayerType.me, '20');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのでんこうせっか
  await tapMove(driver, PlayerType.me, 'でんこうせっか', false);
  // テツノツツミのHP15
  await inputRemainHP(driver, PlayerType.me, '15');
  // テツノツツミのオーロラベール
  await tapMove(driver, PlayerType.opponent, 'オーロラベール', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノツツミのフリーズドライ
  await tapMove(driver, PlayerType.opponent, 'フリーズドライ', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ニンフィアひんし→イルカマンに交代
  await changePokemon(driver, PlayerType.me, 'イルカマン', false);
  // イルカマンにさめはだダメージ＆ステロダメージが入っていること確認
  await testHP(driver, PlayerType.me, '157/207');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, PlayerType.me, 'ジェットパンチ', false);
  // テツノツツミのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // テツノツツミひんし→テツノブジンに交代
  await changePokemon(driver, PlayerType.opponent, 'テツノブジン', false);
  // クォークチャージ編集
  await tapEffect(driver, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // テツノブジンのインファイト
  await tapMove(driver, PlayerType.opponent, 'インファイト', true);
  // イルカマンのHP99
  await inputRemainHP(driver, PlayerType.opponent, '99');
  // イルカマンのアクロバット
  await tapMove(driver, PlayerType.me, 'アクロバット', false);
  // テツノブジンのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イルカマン戦4
Future<void> test2_4(
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
  await tapMove(driver, PlayerType.opponent, 'リフレクター', true);
  // イルカマンのクイックターン
  await tapMove(driver, PlayerType.me, 'クイックターン', false);
  // オーロンゲのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // ニンフィアに交代
  await changePokemon(driver, PlayerType.me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // オーロンゲのひかりのかべ
  await tapMove(driver, PlayerType.opponent, 'ひかりのかべ', true);
  // ニンフィアのあくび
  await tapMove(driver, PlayerType.me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手オーロンゲ->テツノドクガに交代
  await changePokemon(driver, PlayerType.opponent, 'テツノドクガ', true);
  // クォークチャージでとくこうが高まる
  await addEffect(driver, 1, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // ニンフィアのあくび
  await tapMove(driver, PlayerType.me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノドクガのヘドロウェーブ
  await tapMove(driver, PlayerType.opponent, 'ヘドロウェーブ', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ニンフィアひんし->イルカマンに交代
  await changePokemon(driver, PlayerType.me, 'イルカマン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノドクガはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // イルカマンのウェーブタックル
  await tapMove(driver, PlayerType.me, 'ウェーブタックル', false);
  // テツノドクガのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // イルカマンのHP155
  await inputRemainHP(driver, PlayerType.me, '155');
  // テツノドクガひんし->セグレイブに交代
  await changePokemon(driver, PlayerType.opponent, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのりゅうのまい
  await tapMove(driver, PlayerType.opponent, 'りゅうのまい', true);
  // イルカマンのクイックターン
  await tapMove(driver, PlayerType.me, 'クイックターン', false);
  // セグレイブのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // ヘルガーに交代
  await changePokemon(driver, PlayerType.me, 'ヘルガー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのテラスタル
  await inputTerastal(driver, PlayerType.opponent, 'くさ');
  // セグレイブのじしん
  await tapMove(driver, PlayerType.opponent, 'じしん', true);
  // ヘルガーのHP1
  await inputRemainHP(driver, PlayerType.opponent, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ヘルガーのほうふく
  await tapMove(driver, PlayerType.me, 'ほうふく', false);
  // セグレイブのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // セグレイブひんし->オーロンゲに交代
  await changePokemon(driver, PlayerType.opponent, 'オーロンゲ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ヘルガーのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // ヘルガーのテラバースト
  await tapMove(driver, PlayerType.me, 'テラバースト', false);
  // オーロンゲのHP60
  await inputRemainHP(driver, PlayerType.me, '60');
  // オーロンゲのソウルクラッシュ
  await tapMove(driver, PlayerType.opponent, 'ソウルクラッシュ', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ヘルガーひんし->イルカマンに交代
  await changePokemon(driver, PlayerType.me, 'イルカマン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イルカマンのジェットパンチ
  await tapMove(driver, PlayerType.me, 'ジェットパンチ', false);
  // オーロンゲのHP20
  await inputRemainHP(driver, PlayerType.me, '20');
  // オーロンゲのでんじは
  await tapMove(driver, PlayerType.opponent, 'でんじは', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // オーロンゲのソウルクラッシュ
  await tapMove(driver, PlayerType.opponent, 'ソウルクラッシュ', true);
  // イルカマンのHP98
  await inputRemainHP(driver, PlayerType.opponent, '98');
  // イルカマンはとくこうが下がった(デフォルトでオン)
  //await driver.tap(find.text('イルカマンはとくこうが下がった'));
  // イルカマンのウェーブタックル
  await tapMove(driver, PlayerType.me, 'ウェーブタックル', false);
  // オーロンゲのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // イルカマンのHP138
  await inputRemainHP(driver, PlayerType.me, '138');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦1
Future<void> test3_1(
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
  await tapMove(driver, PlayerType.opponent, 'であいがしら', true);
  // イッカネズミのHP17
  await inputRemainHP(driver, PlayerType.opponent, '17');
  // イッカネズミのおかたづけ
  await tapMove(driver, PlayerType.me, 'おかたづけ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // 6回命中
  await setHitCount(driver, PlayerType.me, 6);
  // チヲハウハネのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // チヲハウハネひんし->テツノドクガに交代
  await changePokemon(driver, PlayerType.opponent, 'テツノドクガ', false);
  // クォークチャージでとくこうが高まる
  await addEffect(driver, 2, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // 4回命中
  await setHitCount(driver, PlayerType.me, 4);
  // 2回急所に命中
  await setHitCount(driver, PlayerType.me, 2);
  // テツノドクガのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // テツノドクガひんし->ウルガモスに交代
  await changePokemon(driver, PlayerType.opponent, 'ウルガモス', false);

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
  await tapMove(driver, PlayerType.me, 'おかたづけ', false);
  // ミミズズのステルスロック
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // ミミズズのHP40
  await inputRemainHP(driver, PlayerType.me, '40');
  // ミミズズのオボンのみ
  await addEffect(driver, 2, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ミミズズのしっぽきり
  await tapMove(driver, PlayerType.opponent, 'しっぽきり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミズズのHP15
  await inputRemainHP(driver, PlayerType.opponent, '15');
  // ミミズズ->トドロクツキに交代
  await changePokemon(driver, PlayerType.opponent, 'トドロクツキ', false);
  // こだいかっせいですばやさが高まる
  await addEffect(driver, 4, 'こだいかっせい');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // トドロクツキのテラスタル
  await inputTerastal(driver, PlayerType.opponent, 'はがね');
  // トドロクツキのりゅうのまい
  await tapMove(driver, PlayerType.opponent, 'りゅうのまい', true);
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // 1回急所に命中
  await setCriticalCount(driver, PlayerType.me, 1);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // トドロクツキのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // トドロクツキひんし->ミミズズに交代
  await changePokemon(driver, PlayerType.opponent, 'ミミズズ', false);

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
  await addEffect(driver, 0, 'いかく');
  await driver.tap(find.text('OK'));
  // イッカネズミのおかたづけ
  await tapMove(driver, PlayerType.me, 'おかたづけ', false);
  // ギャラドスのりゅうのまい
  await tapMove(driver, PlayerType.opponent, 'りゅうのまい', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // 6回命中
  await setHitCount(driver, PlayerType.me, 6);
  // ギャラドス->コノヨザルに交代
  await changePokemon(driver, PlayerType.opponent, 'コノヨザル', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, PlayerType.me, 'かみつく', false);
  // コノヨザルのHP80
  await inputRemainHP(driver, PlayerType.me, '80');
  // コノヨザルのインファイト
  await tapMove(driver, PlayerType.opponent, 'インファイト', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // イッカネズミひんし->パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのさいきのいのり
  await tapMove(driver, PlayerType.me, 'さいきのいのり', false);
  // イッカネズミを復活
  await changePokemon(driver, PlayerType.me, 'イッカネズミ', false);
  // コノヨザルのじだんだ
  await tapMove(driver, PlayerType.opponent, 'じだんだ', true);
  // パーモットのHP56
  await inputRemainHP(driver, PlayerType.opponent, '56');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのでんこうそうげき
  await tapMove(driver, PlayerType.me, 'でんこうそうげき', false);
  // 急所に命中
  await tapCritical(driver, PlayerType.me);
  // コノヨザルのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // コノヨザル->ソウブレイズに交代
  await changePokemon(driver, PlayerType.opponent, 'ソウブレイズ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのほっぺすりすり
  await tapMove(driver, PlayerType.me, 'ほっぺすりすり', false);
  // ソウブレイズのHP95
  await inputRemainHP(driver, PlayerType.me, '95');
  // ソウブレイズのサイコカッター
  await tapMove(driver, PlayerType.opponent, 'サイコカッター', true);
  // パーモットのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // パーモット->イッカネズミに交代
  await changePokemon(driver, PlayerType.me, 'イッカネズミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, PlayerType.me, 'かみつく', false);
  // ソウブレイズのHP30
  await inputRemainHP(driver, PlayerType.me, '30');
  // ソウブレイズのニトロチャージ
  await tapMove(driver, PlayerType.opponent, 'ニトロチャージ', true);
  // イッカネズミのHP24
  await inputRemainHP(driver, PlayerType.opponent, '24');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, PlayerType.me, 'かみつく', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イッカネズミ戦4
Future<void> test3_4(
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
  await addEffect(driver, 0, 'すなおこし');
  await driver.tap(find.text('OK'));
  // イッカネズミのネズミざん
  await tapMove(driver, PlayerType.me, 'ネズミざん', false);
  // カバルドンのHP45
  await inputRemainHP(driver, PlayerType.me, '45');
  // カバルドンのオボンのみ
  await addEffect(driver, 2, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // カバルドンのあくび
  await tapMove(driver, PlayerType.opponent, 'あくび', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミ->マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', true);
  // カバルドンのステルスロック
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // 急所に命中
  await tapCritical(driver, PlayerType.me);
  // カバルドンのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // カバルドンひんし->サーフゴー
  await changePokemon(driver, PlayerType.opponent, 'サーフゴー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, PlayerType.opponent, 'ゴールドラッシュ', true);
  // マリルリのHP74
  await inputRemainHP(driver, PlayerType.opponent, '74');
  // マリルリのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // サーフゴーのHP50
  await inputRemainHP(driver, PlayerType.me, '50');
  // サーフゴーのゴツゴツメット
  await addEffect(driver, 2, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ゴツゴツメット＋すなあらしダメージでマリルリのHP29
  await testHP(driver, PlayerType.me, '29/201');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリのアクアジェット
  await tapMove(driver, PlayerType.me, 'アクアジェット', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, PlayerType.me, '30');
  // サーフゴーのシャドーボール空打ち
  await tapMove(driver, PlayerType.opponent, 'シャドーボール', true);
  await tapHit(driver, PlayerType.opponent);
  await inputRemainHP(driver, PlayerType.opponent, '');
  // マリルリひんし->イッカネズミに交代
  await changePokemon(driver, PlayerType.me, 'イッカネズミ', false);
  // 死に出しで出てきたイッカネズミはステルスロックのダメージのみ受けてHP123
  // (バグってゴツメダメージが入ることがあったので確認)
  await testHP(driver, PlayerType.me, '123/150');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, PlayerType.me, 'おかたづけ', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, PlayerType.opponent, 'ゴールドラッシュ', false);
  // イッカネズミのHP26
  await inputRemainHP(driver, PlayerType.opponent, '26');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, PlayerType.me, 'かみつく', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // サーフゴーひんし->ミミッキュに交代
  await changePokemon(driver, PlayerType.opponent, 'ミミッキュ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのタネマシンガン
  await tapMove(driver, PlayerType.me, 'タネマシンガン', false);
  // 2回命中
  await setHitCount(driver, PlayerType.me, 2);
  // ミミッキュのHP80
  await inputRemainHP(driver, PlayerType.me, '80');
  // ミミッキュのドレインパンチ
  await tapMove(driver, PlayerType.opponent, 'ドレインパンチ', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ミミッキュのHP75
  await inputRemainHP(driver, PlayerType.opponent, '75');
  // ミミッキュのいのちのたま
  await addEffect(driver, 3, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // イッカネズミひんし->パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦1
Future<void> test4_1(
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
  await tapMove(driver, PlayerType.opponent, 'ステルスロック', true);
  // こちらのミミズズのしっぽきり
  await tapMove(driver, PlayerType.me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, PlayerType.me, '88');
  // ミミズズ->カジリガメに交代
  await changePokemon(driver, PlayerType.me, 'カジリガメ', false);
  // ステルスロックダメージ
  await testExistEffect(driver, 'ステルスロック');
  await testHP(driver, PlayerType.me, '146/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミズズのじならし
  await tapMove(driver, PlayerType.opponent, 'じならし', true);
  // みがわりは壊れない
  await inputRemainHP(driver, PlayerType.opponent, '');
  // カジリガメのからをやぶる
  await tapMove(driver, PlayerType.me, 'からをやぶる', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // ミミズズのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ミミズズひんし->ドヒドイデに交代
  await changePokemon(driver, PlayerType.opponent, 'ドヒドイデ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデのトーチカ
  await tapMove(driver, PlayerType.opponent, 'トーチカ', true);
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // トーチカで失敗、失敗のためいのちのたまダメージは受けない
  await inputRemainHP(driver, PlayerType.me, '');
  await testHP(driver, PlayerType.me, '110/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // ドヒドイデのHP45
  await inputRemainHP(driver, PlayerType.me, '45');
  // ドヒドイデのくろいきり
  await tapMove(driver, PlayerType.opponent, 'くろいきり', true);
  // ドヒドイデのくろいヘドロ
  await addEffect(driver, 3, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // どくダメージ計算合ってるか確認
  await testHP(driver, PlayerType.me, '74/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドヒドイデのトーチカ
  await tapMove(driver, PlayerType.opponent, 'トーチカ', false);
  // カジリガメのからをやぶる
  await tapMove(driver, PlayerType.me, 'からをやぶる', false);
  // どくダメージ計算合ってるか確認
  await testHP(driver, PlayerType.me, '54/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // ドヒドイデのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  //ドヒドイデひんし->デカヌチャン
  await changePokemon(driver, PlayerType.opponent, 'デカヌチャン', false);
  // どくダメージ計算合ってるか確認
  await testHP(driver, PlayerType.me, '18/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // デカヌチャンのテラスタル
  await inputTerastal(driver, PlayerType.opponent, 'ノーマル');
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミミズズ戦2
Future<void> test4_2(
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
  await addEffect(driver, 0, 'いかく');
  await driver.tap(find.text('OK'));
  // ギャラドスのちょうはつ
  await tapMove(driver, PlayerType.opponent, 'ちょうはつ', true);
  // ミミズズのしっぽきり失敗
  await tapMove(driver, PlayerType.me, 'しっぽきり', false);
  await tapSuccess(driver, PlayerType.me);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ミミズズ->ボーマンダに交代
  await changePokemon(driver, PlayerType.me, 'ボーマンダ', true);
  // ギャラドスのでんじは
  await tapMove(driver, PlayerType.opponent, 'でんじは', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手ギャラドス->バンギラスに交代
  await changePokemon(driver, PlayerType.opponent, 'バンギラス', true);
  // バンギラスのすなおこし
  await addEffect(driver, 1, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ボーマンダのダブルウイング
  await tapMove(driver, PlayerType.me, 'ダブルウイング', false);
  // バンギラスのHP90
  await inputRemainHP(driver, PlayerType.me, '90');
  // すなあらしダメージでHP161になっていることを確認
  await testHP(driver, PlayerType.me, '161/171');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダ->ミミズズに交代
  await changePokemon(driver, PlayerType.me, 'ミミズズ', true);
  // バンギラスのかみくだく
  await tapMove(driver, PlayerType.opponent, 'かみくだく', true);
  // ミミズズのHP120
  await inputRemainHP(driver, PlayerType.opponent, '120');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // バンギラスのじしん
  await tapMove(driver, PlayerType.opponent, 'じしん', true);
  // ミミズズのどしょくが発動するのでダメージ変動なし
  await inputRemainHP(driver, PlayerType.opponent, '');
  // どしょくが発動していることを確認
  await testExistEffect(driver, 'どしょく');
  await testHP(driver, PlayerType.me, '164/177');
  // ミミズズのしっぽきり
  await tapMove(driver, PlayerType.me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP75
  await inputRemainHP(driver, PlayerType.me, '75');
  // ミミズズ->カジリガメに交代
  await changePokemon(driver, PlayerType.me, 'カジリガメ', false);
  // カジリガメにすなあらしダメージが入らないことを確認
  await testHP(driver, PlayerType.me, '166/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのからをやぶる
  await tapMove(driver, PlayerType.me, 'からをやぶる', false);
  // バンギラスのじしん
  await tapMove(driver, PlayerType.opponent, 'じしん', false);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // カジリガメは無傷
  await inputRemainHP(driver, PlayerType.opponent, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // バンギラスのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // バンギラスひんし->ギャラドス
  await changePokemon(driver, PlayerType.opponent, 'ギャラドス', false);
  // すなあらしが終了するか確認
  await testExistEffect(driver, 'すなあらし終了');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ギャラドス->ヒートロトムに交代
  await changePokemon(driver, PlayerType.opponent, 'ロトム(ヒートロトム)', true);
  // カジリガメのロックブラスト
  await tapMove(driver, PlayerType.me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, PlayerType.me, 2);
  // ロトムのHP10
  await inputRemainHP(driver, PlayerType.me, '10');
  // ロトムのオボンのみ
  await addEffect(driver, 2, 'オボンのみ');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('10');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, PlayerType.me, 'アクアブレイク', false);
  // ロトムのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ひんしロトム->ギャラドスに交代
  await changePokemon(driver, PlayerType.opponent, 'ギャラドス', false);
  // カジリガメのHP確認
  await testHP(driver, PlayerType.me, '118/166');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのロックブラスト
  await tapMove(driver, PlayerType.me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, PlayerType.me, 2);
  // 1回急所
  await setCriticalCount(driver, PlayerType.me, 1);
  // ギャラドスのHP40
  await inputRemainHP(driver, PlayerType.me, '40');
  // ギャラドスのたきのぼり
  await tapMove(driver, PlayerType.opponent, 'たきのぼり', true);
  // カジリガメのHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // ひんしカジリガメ->ボーマンダに交代
  await changePokemon(driver, PlayerType.opponent, 'ボーマンダ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのテラスタル
  await inputTerastal(driver, PlayerType.me, '');
  // ギャラドスのこおりのキバ
  await tapMove(driver, PlayerType.opponent, 'こおりのキバ', true);
  // ボーマンダのHP107
  await inputRemainHP(driver, PlayerType.opponent, '107');
  // ボーマンダのげきりん
  await tapMove(driver, PlayerType.me, 'げきりん', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ギャラドスのゴツゴツメット
  await addEffect(driver, 3, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// 検索対象Widgetが1つ以上あるかをテストする
/// ```
/// finder: 検索
/// driver: FlutterDriver
/// timeout: 検索のタイムアウト
/// ```
Future<void> testExistAnyWidgets(
    SerializableFinder finder, FlutterDriver driver,
    {Duration timeout = const Duration(seconds: 1)}) async {
  bool test = await isPresent(finder, driver);
  expect(test, true);
}

// https://stackoverflow.com/questions/49442872/how-to-check-if-an-element-exists-or-not-in-flutter-driverqa-environment
Future<bool> isPresent(SerializableFinder finder, FlutterDriver driver,
    {Duration timeout = const Duration(seconds: 1)}) async {
  try {
    await driver.waitForTappable(finder, timeout: timeout);
    return true;
  } catch (e) {
    return false;
  }
}

/// 基本情報を入力する
Future<void> inputBattleBasicInfo(
  FlutterDriver driver, {
  required String battleName,
  required String ownPartyname,
  required String opponentName,
  required String pokemon1,
  Sex? sex1,
  required String pokemon2,
  Sex? sex2,
  required String pokemon3,
  Sex? sex3,
  required String pokemon4,
  Sex? sex4,
  required String pokemon5,
  Sex? sex5,
  required String pokemon6,
  Sex? sex6,
}) async {
  // 対戦名
  await driver.tap(find.byValueKey('BattleBasicListViewBattleName'));
  await driver.enterText(battleName);
  // あなたのパーティ
  await driver.tap(find.byValueKey('BattleBasicListViewYourParty'));
  await testExistAnyWidgets(find.byType('PartyTile'), driver);
  await driver.tap(find.text(ownPartyname));
  // 元の画面に戻るのを待つ
  await driver
      .waitForTappable(find.byValueKey('BattleBasicListViewOpponentName'));
  // あいての名前
  await driver.tap(find.byValueKey('BattleBasicListViewOpponentName'));
  await driver.enterText(opponentName);
  // ポケモン1
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン1',
      inputText: pokemon1,
      selectText: pokemon1);
  // せいべつ1
  if (sex1 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ1'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ1${sex1.displayName}'));
  }
  // ポケモン2
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン2',
      inputText: pokemon2,
      selectText: pokemon2);
  // せいべつ2
  if (sex2 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ2'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ2${sex2.displayName}'));
  }
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: pokemon3,
      selectText: pokemon3);
  // せいべつ3
  if (sex3 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ3'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ3${sex3.displayName}'));
  }
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: pokemon4,
      selectText: pokemon4);
  // せいべつ4
  if (sex4 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ4'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ4${sex4.displayName}'));
  }
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: pokemon5,
      selectText: pokemon5);
  // せいべつ5
  if (sex5 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ5'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ5${sex5.displayName}'));
  }
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: pokemon6,
      selectText: pokemon6);
// せいべつ6
  if (sex6 != null) {
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ6'));
    await driver.tap(find.byValueKey('PokemonSexRowせいべつ6${sex6.displayName}'));
  }
}

/// 基本情報入力のあいてのポケモンを入力する
Future<void> inputPokemonInBattleBasic(FlutterDriver driver,
    {required String fieldKey,
    required String listViewKey,
    required String inputText,
    required String selectText}) async {
  if (!await isPresent(find.byValueKey(fieldKey), driver)) {
    // 入力フィールドまでスクロール
    await scrollUntilTappable(
        driver, find.byValueKey(listViewKey), find.byValueKey(fieldKey),
        dyScroll: -100);
  }
  await driver.tap(find.byValueKey(fieldKey));
  await driver.enterText(inputText);
  final selectListTile = find.ancestor(
    matching: find.byType('ListTile'),
    of: find.text(selectText),
    firstMatchOnly: true,
  );
  if (!await isPresent(selectListTile, driver)) {
    // 入力候補までスクロール
    await scrollUntilTappable(
        driver, find.byValueKey(listViewKey), selectListTile,
        dyScroll: -100);
  }
  await testExistAnyWidgets(selectListTile, driver);
  await driver.tap(selectListTile);
}

/// 基本情報入力後、選出ポケモン選択画面へ進む
Future<void> goSelectPokemonPage(FlutterDriver driver) async {
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(
      find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver);
}

/// 選出ポケモンを選択する
Future<void> selectPokemons(
  FlutterDriver driver, {
  required String ownPokemon1,
  required String ownPokemon2,
  required String ownPokemon3,
  required String opponentPokemon,
}) async {
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text(ownPokemon1),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text(ownPokemon2),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text(ownPokemon3),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text(opponentPokemon),
    firstMatchOnly: true,
  ));
}

/// 選出ポケモン入力後、各ターン入力画面へ進む
Future<void> goTurnPage(FlutterDriver driver, int currentTurnNum) async {
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン${currentTurnNum + 1}'), driver);
}

/// わざを選択する
Future<void> tapMove(FlutterDriver driver, PlayerType playerType,
    String moveName, bool search) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  if (search) {
    // わざ名検索
    await driver
        .tap(find.byValueKey('BattleActionCommandMoveSearch$ownOrOpponent'));
    await driver.enterText(moveName);
  }
  // (これキー指定するのは不本意。find.textがうまく動作しない・・・)
  final designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTile$ownOrOpponent$moveName');
  if (!await isPresent(designatedWidget, driver)) {
    await scrollUntilTappable(
        driver,
        find.byValueKey('BattleActionCommandMoveListView$ownOrOpponent'),
        designatedWidget,
        dyScroll: -50);
  }
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
}

/// 相手の残りHPを入力する
Future<void> inputRemainHP(
    FlutterDriver driver, PlayerType playerType, String remainHP) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  for (int i = 0; i < remainHP.length; i++) {
    final designatedWidget = find.descendant(
        of: find.byValueKey('NumberInputButtons$ownOrOpponent'),
        matching: find.ancestor(
            of: find.text(remainHP[i]),
            matching: find.byType('_NumberInputButton')));
    await driver.tap(designatedWidget);
  }
  final designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtons$ownOrOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
}

/// 効果を追加する
Future<void> addEffect(
    FlutterDriver driver, int addButtonNo, String effectName) async {
  var designatedWidget =
      find.byValueKey('RegisterBattleEffectAddIconButton$addButtonNo');
  if (!await isPresent(designatedWidget, driver)) {
    await scrollUntilTappable(
        driver, find.byValueKey('EffectListView'), designatedWidget,
        dxScroll: -100);
  }
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText(effectName);
  designatedWidget = find.descendant(
    of: find.byType('ListTile'),
    matching: find.text(effectName),
  );
  await driver.tap(designatedWidget);
}

/// 効果を示す吹き出しが存在するかチェックする
Future<void> testExistEffect(FlutterDriver driver, String effectName) async {
  final designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text(effectName),
  );
  if (!await isPresent(designatedWidget, driver)) {
    await scrollUntilTappable(
        driver, find.byValueKey('EffectListView'), designatedWidget,
        dxScroll: -100);
  }
  await testExistAnyWidgets(designatedWidget, driver);
}

/// 効果を示す吹き出しをタップする(編集用)
Future<void> tapEffect(FlutterDriver driver, String effectName) async {
  final designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text(effectName),
  );
  if (!await isPresent(designatedWidget, driver)) {
    await scrollUntilTappable(
        driver, find.byValueKey('EffectListView'), designatedWidget,
        dxScroll: -100);
  }
  await driver.tap(designatedWidget);
}

/// ポケモンを交代する(ひんし交代やわざ等での交代含む)
Future<void> changePokemon(FlutterDriver driver, PlayerType playerType,
    String pokemonName, bool needChangeButtonTap) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  if (needChangeButtonTap) {
    await driver
        .tap(find.byValueKey('BattleActionCommandChange$ownOrOpponent'));
  }
  if (!await isPresent(find.text(pokemonName), driver)) {
    await scrollUntilTappable(
        driver,
        find.byValueKey('ChangePokemonListView$ownOrOpponent'),
        find.text(pokemonName),
        dyScroll: -100);
  }
  await driver.tap(find.text(pokemonName));
}

/// 命中のチェックを付ける/外す
Future<void> tapHit(FlutterDriver driver, PlayerType playerType) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  await driver.tap(find.byValueKey('HitInput$ownOrOpponent'));
}

/// 急所のチェックを付ける/外す
Future<void> tapCritical(FlutterDriver driver, PlayerType playerType) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  await driver.tap(find.byValueKey('CriticalInput$ownOrOpponent'));
}

/// 命中回数を入力する
Future<void> setHitCount(
    FlutterDriver driver, PlayerType playerType, int count) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  var designatedWidget = find.descendant(
      matching: find.byType('TextFormField'),
      of: find.byValueKey('HitInput$ownOrOpponent'));
  await driver.tap(designatedWidget);
  await driver.enterText(count.toString());
  // 以下のように再度タップする等しないと反映されない
  await driver.tap(designatedWidget);
  await Future<void>.delayed(const Duration(milliseconds: 500));
}

/// 急所回数を入力する
Future<void> setCriticalCount(
    FlutterDriver driver, PlayerType playerType, int count) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  var designatedWidget = find.descendant(
      matching: find.byType('TextFormField'),
      of: find.byValueKey('CriticalInput$ownOrOpponent'));
  await driver.tap(designatedWidget);
  await driver.enterText(count.toString());
  // 以下のように再度タップする等しないと反映されない
  //await driver.tap(designatedWidget);
  //await Future<void>.delayed(const Duration(milliseconds: 500));
}

/// 成功のオンオフを切り替える
Future<void> tapSuccess(FlutterDriver driver, PlayerType playerType) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  await driver.tap(find.byValueKey('SuccessSwitch$ownOrOpponent'));
}

/// テラスタルする
Future<void> inputTerastal(
    FlutterDriver driver, PlayerType playerType, String typeName) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  await driver
      .tap(find.byValueKey('BattleActionCommandTerastal$ownOrOpponent'));
  if (playerType == PlayerType.opponent) {
    await testExistAnyWidgets(find.text('テラスタイプ'), driver);
    if (!await isPresent(find.text(typeName), driver)) {
      await scrollUntilTappable(driver,
          find.byValueKey('SelectTypeDialogScrollView'), find.text(typeName),
          dyScroll: -100);
    }
    await driver.tap(find.text(typeName));
  }
}

/// ポケモンのパラメータを編集する
Future<void> editPokemonState(
  FlutterDriver driver,
  String tapString,
  String? remainHP,
  String? ability,
  String? item,
) async {
  await driver.tap(find.text(tapString));
  if (ability != null) {
    await driver.tap(find.byValueKey('PokemonStateEditDialogAbility'));
    await driver.enterText(ability);
    final selectListTile = find.ancestor(
      matching: find.byType('ListTile'),
      of: find.text(ability),
      firstMatchOnly: true,
    );
    await driver.tap(selectListTile);
  }
  if (item != null) {
    await driver.tap(find.byValueKey('PokemonStateEditDialogItem'));
    await driver.enterText(item);
    final selectListTile = find.ancestor(
      matching: find.byType('ListTile'),
      of: find.text(item),
      firstMatchOnly: true,
    );
    await driver.tap(selectListTile);
  }
  await driver.tap(find.text('適用'));
}

/// HPが正しいかテストする
Future<void> testHP(
    FlutterDriver driver, PlayerType playerType, String hpText) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  final designatedWidget = find.descendant(
    of: find.byValueKey('PokemonStateInfoHP$ownOrOpponent'),
    matching: find.text(hpText),
  );
  await testExistAnyWidgets(designatedWidget, driver);
}

Future<void> scrollUntilTappable(
  FlutterDriver driver,
  SerializableFinder scrollable,
  SerializableFinder item, {
  double alignment = 0.0,
  double dxScroll = 0.0,
  double dyScroll = 0.0,
  Duration? timeout,
}) async {
  assert(dxScroll != 0.0 || dyScroll != 0.0);

  bool isTappale = false;
  driver.waitForTappable(item, timeout: timeout).then<void>((_) {
    isTappale = true;
  });
  await Future<void>.delayed(const Duration(milliseconds: 500));
  while (!isTappale) {
    await driver.scroll(
        scrollable, dxScroll, dyScroll, const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  return driver.scrollIntoView(item, alignment: alignment);
}
