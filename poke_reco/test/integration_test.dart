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
    test('パーモット戦', timeout: Timeout(Duration(minutes: 5)), () async {
      if (doTest) {
        await test1_1(driver!);
        //await test1_2(driver!);
        //await test1_3(driver!);
        //await test1_4(driver!);
        //await test2_1(driver!);
      }
    });
  });
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
  required String pokemon2,
  required String pokemon3,
  required String pokemon4,
  required String pokemon5,
  required String pokemon6,
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
  // TODO:DropDownMenuItemをタップできないため、無視
  // https://github.com/flutter/flutter/issues/89905
  //await driver.tap(find.byValueKey('PokemonSexRowせいべつ1'));
  //final menu = find.descendant(
  //    of: find.byValueKey('PokemonSexRowせいべつ1'),
  //    matching: find.byValueKey('PokemonSexRowせいべつ1オス'),
  //    firstMatchOnly: true);
  //await driver.getBottomLeft(menu);
  //await driver.tap(menu);
  // ポケモン2
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン2',
      inputText: pokemon2,
      selectText: pokemon2);
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: pokemon3,
      selectText: pokemon3);
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: pokemon4,
      selectText: pokemon4);
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: pokemon5,
      selectText: pokemon5);
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: pokemon6,
      selectText: pokemon6);
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
  await driver
      .tap(find.byValueKey('RegisterBattleEffectAddIconButton$addButtonNo'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText(effectName);
  final designatedWidget = find.descendant(
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
  await testExistAnyWidgets(designatedWidget, driver);
}

/// ポケモンを交代する(ひんし交代含む)
Future<void> changePokemon(FlutterDriver driver, PlayerType playerType,
    String pokemonName, bool isFainting) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';

  if (!isFainting) {
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
  await driver.tap(designatedWidget);
  await Future<void>.delayed(const Duration(milliseconds: 500));
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
  await inputBattleBasicInfo(driver,
      battleName: 'もこうパーモット戦1',
      ownPartyname: '1もこパーモット',
      opponentName: 'メリタマ',
      pokemon1: 'ギャラドス',
      pokemon2: 'セグレイブ',
      pokemon3: 'テツノツツミ',
      pokemon4: 'デカヌチャン',
      pokemon5: 'テツノコウベ',
      pokemon6: 'カバルドン');
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
  await changePokemon(driver, PlayerType.opponent, 'テツノツツミ', true);
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
  await changePokemon(driver, PlayerType.opponent, 'ギャラドス', true);
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
  await inputBattleBasicInfo(driver,
      battleName: 'もこうパーモット戦2',
      ownPartyname: '1もこパーモット',
      opponentName: 'k.k',
      pokemon1: 'チヲハウハネ',
      pokemon2: 'デカヌチャン',
      pokemon3: 'キラフロル',
      pokemon4: 'ミミッキュ',
      pokemon5: 'サザンドラ',
      pokemon6: 'キノガッサ');
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
  await changePokemon(driver, PlayerType.opponent, 'ミミッキュ', false);
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
  await changePokemon(driver, PlayerType.me, 'リーフィア', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ミミッキュ→チヲハウハネに交代
  await changePokemon(driver, PlayerType.opponent, 'チヲハウハネ', false);
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
  await changePokemon(driver, PlayerType.opponent, 'サザンドラ', true);

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
  await changePokemon(driver, PlayerType.me, 'パーモット', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手サザンドラ→ミミッキュに交代
  await changePokemon(driver, PlayerType.opponent, 'ミミッキュ', false);
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
  await changePokemon(driver, PlayerType.opponent, 'サザンドラ', true);

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
  await inputBattleBasicInfo(driver,
      battleName: 'もこうパーモット戦3',
      ownPartyname: '1もこパーモット',
      opponentName: 'Daikon',
      pokemon1: 'トドロクツキ',
      pokemon2: 'バンギラス',
      pokemon3: 'ウルガモス',
      pokemon4: 'カイリュー',
      pokemon5: 'ブロロローム',
      pokemon6: 'ギャラドス');
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
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOpponent'));
  await testExistAnyWidgets(find.text('テラスタイプ'), driver);
  await driver.tap(find.text('いわ'));
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
  await changePokemon(driver, PlayerType.me, 'マリルリ', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // マリルリテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ウルガモス→トドロクツキに交代
  await changePokemon(driver, PlayerType.opponent, 'トドロクツキ', false);
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
  await changePokemon(driver, PlayerType.opponent, 'バンギラス', true);
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
  await changePokemon(driver, PlayerType.me, 'パーモット', true);

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
  await changePokemon(driver, PlayerType.opponent, 'ウルガモス', false);
  // パーモットのインファイト
  await tapMove(driver, PlayerType.me, 'インファイト', false);
  // ウルガモスの残りHP0
  await inputRemainHP(driver, PlayerType.me, '0');
  // ウルガモスひんし→バンギラスに交代
  await changePokemon(driver, PlayerType.opponent, 'バンギラス', true);
  // パーモットひんし→マリルリに交代
  await changePokemon(driver, PlayerType.me, 'マリルリ', true);

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
  await inputBattleBasicInfo(driver,
      battleName: 'もこうパーモット戦4',
      ownPartyname: '1もこパーモット',
      opponentName: 'アイアムあむ',
      pokemon1: 'ソウブレイズ',
      pokemon2: 'グレンアルマ',
      pokemon3: 'ドドゲザン',
      pokemon4: 'キラフロル',
      pokemon5: 'ウルガモス',
      pokemon6: 'セグレイブ');
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
  await changePokemon(driver, PlayerType.me, 'マリルリ', false);
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
  await changePokemon(driver, PlayerType.opponent, 'セグレイブ', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのこおりのつぶて
  await tapMove(driver, PlayerType.opponent, 'こおりのつぶて', true);
  // マリルリの残りHP0
  await inputRemainHP(driver, PlayerType.opponent, '0');
  // マリルリひんし→パーモットに交代
  await changePokemon(driver, PlayerType.me, 'パーモット', true);

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
  await changePokemon(driver, PlayerType.me, 'マリルリ', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // 相手セグレイブ->ドドゲザンに交代
  await changePokemon(driver, PlayerType.opponent, 'ドドゲザン', false);
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
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOpponent'));
  await testExistAnyWidgets(find.text('テラスタイプ'), driver);
  await driver.tap(find.text('ゴースト'));
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
  await changePokemon(driver, PlayerType.me, 'リキキリン', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リキキリンテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
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
  await changePokemon(driver, PlayerType.opponent, 'セグレイブ', true);

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
  await inputBattleBasicInfo(driver,
      battleName: 'もこうイルカマン戦1',
      ownPartyname: '2もこイルカマン',
      opponentName: 'ぜんれつなに',
      pokemon1: 'ミミッキュ',
      pokemon2: 'カバルドン',
      pokemon3: 'キラフロル',
      pokemon4: 'パオジアン',
      pokemon5: 'ロトム(ウォッシュロトム)',
      pokemon6: 'ドラパルト');
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
  await changePokemon(driver, PlayerType.me, 'ニンフィア', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, PlayerType.opponent, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, PlayerType.opponent);
  await inputRemainHP(driver, PlayerType.opponent, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのボルトチェンジ
  await tapMove(driver, PlayerType.opponent, 'ボルトチェンジ', true);
  // ニンフィアのHP157
  await inputRemainHP(driver, PlayerType.opponent, '157');
  // キラフロルに交代
  await changePokemon(driver, PlayerType.opponent, 'キラフロル', false);
  // ニンフィアのハイパーボイス
  await tapMove(driver, PlayerType.me, 'ハイパーボイス', false);
  // キラフロルのHP80
  await inputRemainHP(driver, PlayerType.me, '80');

  // 内容保存
  //await driver.tap(find.byValueKey('RegisterBattleSave'));
}
