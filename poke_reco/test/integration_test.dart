import 'package:flutter_driver/flutter_driver.dart';
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
      //await tester.pumpWidget(MyApp(initialLocale: locale));
      // TODO
      // ポケモンタブボタンタップ
      //await tester.tap(find.text('ポケモン'));
      //await tester.pumpAndSettle();
      //expect(find.text('もこパモ'), findsWidgets);
      if (doTest) {
        //await test1_1(driver!);
        //await test1_2(driver!);
        await test1_3(driver!);
        //await test1_4(driver!);
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
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  // 対戦名
  await driver.tap(find.byValueKey('BattleBasicListViewBattleName'));
  await driver.enterText('もこうパーモット戦1');
  // あなたのパーティ
  await driver.tap(find.byValueKey('BattleBasicListViewYourParty'));
  await testExistAnyWidgets(find.byType('PartyTile'), driver);
  await driver.tap(find.text('1もこパーモット'));
  // 元の画面に戻るのを待つ
  await driver
      .waitForTappable(find.byValueKey('BattleBasicListViewOpponentName'));
  // あいての名前
  await driver.tap(find.byValueKey('BattleBasicListViewOpponentName'));
  await driver.enterText('メリタマ');
  // ポケモン1
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン1',
      inputText: 'きやら',
      selectText: 'ギャラドス');
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
      inputText: 'せくれ',
      selectText: 'セグレイブ');
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: 'てつのつ',
      selectText: 'テツノツツミ');
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: 'てかぬ',
      selectText: 'デカヌチャン');
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: 'てつのこ',
      selectText: 'テツノコウベ');
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: 'かはる',
      selectText: 'カバルドン');
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(
      find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver);
  // 選出ポケモンを選ぶ
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこいかくマンダ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこパモ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこロローム/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('デカヌチャン/'),
    firstMatchOnly: true,
  ));
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン1'), driver);
  // ボーマンダのりゅうのまい
  // (これキー指定するのは不本意。find.textがうまく動作しない・・・)
  var designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnりゅうのまい');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('成功'), driver);
  // デカヌチャンのがんせきふうじ
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('かんせき');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentがんせきふうじ');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダの残りHP127
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('1'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('2'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('ボーマンダはすばやさが下がった'), driver);

  // 次のターンへボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン2'), driver);
  // ボーマンダのじしん
  designatedWidget = find.byValueKey('BattleActionCommandMoveListTileOwnじしん');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // デカヌチャンの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // デカヌチャンひんし→テツノツツミに交代
  await testExistAnyWidgets(find.text('テツノツツミ'), driver);
  await driver.tap(find.text('テツノツツミ'));
  // クォークチャージ発動
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('クォーク');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'),
      matching: find.text('クォークチャージ'),
      //TODO ほんとは1つしかないから不要のはず
      firstMatchOnly: true);
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('クォークチャージ'),
  );
  // クォークチャージの内容編集
  await driver.tap(designatedWidget);
  // TODO? 「効果が切れた」は期待通りか・・・？
  await driver.tap(find.text('効果が切れた'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン3'), driver);
  // ボーマンダのげきりん
  designatedWidget = find.byValueKey('BattleActionCommandMoveListTileOwnげきりん');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // テツノツツミの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // テツノツツミひんし→ギャラドスに交代
  await testExistAnyWidgets(find.text('ギャラドス'), driver);
  await driver.tap(find.text('ギャラドス'));
  // いかく発動
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('いかく');
  await driver.tap(find.byValueKey('EffectListTileOpponentいかく'));

  // 次のターンへボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン4'), driver);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦2
Future<void> test1_2(
  FlutterDriver driver,
) async {
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  // 対戦名
  await driver.tap(find.byValueKey('BattleBasicListViewBattleName'));
  await driver.enterText('もこうパーモット戦2');
  // あなたのパーティ
  await driver.tap(find.byValueKey('BattleBasicListViewYourParty'));
  await testExistAnyWidgets(find.byType('PartyTile'), driver);
  await driver.tap(find.text('1もこパーモット'));
  // 元の画面に戻るのを待つ
  await driver
      .waitForTappable(find.byValueKey('BattleBasicListViewOpponentName'));
  // あいての名前
  await driver.tap(find.byValueKey('BattleBasicListViewOpponentName'));
  await driver.enterText('k.k');
  // ポケモン1
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン1',
      inputText: 'ちを',
      selectText: 'チヲハウハネ');
  // ポケモン2
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン2',
      inputText: 'てかぬ',
      selectText: 'デカヌチャン');
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: 'きらふ',
      selectText: 'キラフロル');
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: 'みみつ',
      selectText: 'ミミッキュ');
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: 'ささん',
      selectText: 'サザンドラ');
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: 'きのか',
      selectText: 'キノガッサ');
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(
      find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver);
  // 選出ポケモンを選ぶ
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこいかくマンダ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこパモ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこフィア/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('チヲハウハネ/'),
    firstMatchOnly: true,
  ));
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン1'), driver);
  // チヲハウハネのこだいかっせい
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('こだい');
  var designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだいかっせい'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('こだいかっせい'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネ->ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // ボーマンダのダブルウイングが外れる
  designatedWidget = find.descendant(
      matching: find.byType('TextFormField'),
      of: find.byValueKey('HitInputOwn'));
  await driver.tap(designatedWidget);
  await driver.enterText('0');
  // 以下のように再度タップする等しないと反映されない
  await driver.tap(designatedWidget);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン2'), driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのじゃれつく
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('しやれ');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのもちものがいのちのたまと判明
  await driver.tap(find.text('ミミッキュ/k.k'));
  await driver.tap(find.byValueKey('PokemonStateEditDialogItem'));
  await driver.enterText('いのちの');
  await driver.tap(find.text('いのちのたま'));
  await driver.tap(find.text('適用'));
  // ボーマンダひんし→リーフィアに交代
  await testExistAnyWidgets(find.text('リーフィア'), driver);
  await driver.tap(find.text('リーフィア'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン3'), driver);
  // リーフィアテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ミミッキュ→チヲハウハネに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('チヲハウハネ'), driver);
  await driver.tap(find.text('チヲハウハネ'));
  // リーフィアのリーフブレード
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnリーフブレード');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン4'), driver);
  // リーフィアのテラバースト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnテラバースト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // チヲハウハネひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン5'), driver);
  // リーフィアのでんこうせっか
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうせっか');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP90
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('9'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // サザンドラのあくのはどう
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('あくのは');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentあくのはどう');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // リーフィアの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // リーフィアひんし→パーモットに交代
  await testExistAnyWidgets(find.text('パーモット'), driver);
  await driver.tap(find.text('パーモット'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン6'), driver);
  // 相手サザンドラ→ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // パーモットのさいきのいのりでボーマンダ復活
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnさいきのいのり');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('ボーマンダ'), driver);
  await driver.tap(find.text('ボーマンダ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン7'), driver);
  // ミミッキュのじゃれつく
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // パーモットの残りHP1
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('1'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // きあいのタスキ発動
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('きあいの');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('きあいのタスキ'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // パーモットのでんこうそうげき
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうそうげき');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン8'), driver);
  // サザンドラのりゅうせいぐん
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('りゅうせい');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentりゅうせいぐん');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラのりゅうせいぐんが外れる
  await driver.tap(find.byValueKey('HitInputOpponent'));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // パーモットのインファイト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnインファイト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // あなたの勝利
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('あなたの勝利！'),
  );
  await testExistAnyWidgets(designatedWidget, driver);

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// パーモット戦3
Future<void> test1_3(
  FlutterDriver driver,
) async {
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  // 対戦名
  await driver.tap(find.byValueKey('BattleBasicListViewBattleName'));
  await driver.enterText('もこうパーモット戦3');
  // あなたのパーティ
  await driver.tap(find.byValueKey('BattleBasicListViewYourParty'));
  await testExistAnyWidgets(find.byType('PartyTile'), driver);
  await driver.tap(find.text('1もこパーモット'));
  // 元の画面に戻るのを待つ
  await driver
      .waitForTappable(find.byValueKey('BattleBasicListViewOpponentName'));
  // あいての名前
  await driver.tap(find.byValueKey('BattleBasicListViewOpponentName'));
  await driver.enterText('Daikon');
  // ポケモン1
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン1',
      inputText: 'ととろく',
      selectText: 'トドロクツキ');
  // ポケモン2
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン2',
      inputText: 'はんき',
      selectText: 'バンギラス');
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: 'うるかも',
      selectText: 'ウルガモス');
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: 'かいりゆ',
      selectText: 'カイリュー');
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: 'ふろろろ',
      selectText: 'ブロロローム');
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: 'きやら',
      selectText: 'ギャラドス');
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(
      find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver);
  // 選出ポケモンを選ぶ
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこいかくマンダ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこパモ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこルリ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('ウルガモス/'),
    firstMatchOnly: true,
  ));
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン1'), driver);
  // ウルガモステラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOpponent'));
  await testExistAnyWidgets(find.text('テラスタイプ'), driver);
  await driver.tap(find.text('いわ'));
  // ウルガモスのちょうのまい
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('ちょうの');
  var designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentちょうのまい');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ウルガモスの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン2'), driver);
  // ウルガモスのテラバースト
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('てらば');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentテラバースト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ボーマンダひんし→マリルリに交代
  await testExistAnyWidgets(find.text('マリルリ'), driver);
  await driver.tap(find.text('マリルリ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン3'), driver);
  // マリルリテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ウルガモス→トドロクツキに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('トドロクツキ'), driver);
  await driver.tap(find.text('トドロクツキ'));
  // トドロクツキのこだいかっせい
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('こだい');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだいかっせい'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('こだいかっせい'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // マリルリのアクアブレイク
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnアクアブレイク');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // トドロクツキの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン4'), driver);
  // トドロクツキのつじぎり
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('つしき');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentつじぎり');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // マリルリの残りHP93
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('9'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('3'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // マリルリのじゃれつく
  designatedWidget = find.byValueKey('BattleActionCommandMoveListTileOwnじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // きゅうしょ命中
  await driver.tap(find.byValueKey('CriticalInputOwn'));
  // トドロクツキの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // トドロクツキひんし→バンギラスに交代
  await testExistAnyWidgets(find.text('バンギラス'), driver);
  await driver.tap(find.text('バンギラス'));
  // バンギラスのとくせいがすなおこしと判明
  await driver.tap(find.text('バンギラス/Daikon'));
  await driver.tap(find.byValueKey('PokemonStateEditDialogAbility'));
  await driver.tap(find.text('すなおこし'));
  await driver.tap(find.text('適用'));
  // バンギラスのすなおこし
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton4'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('すなおこ');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('すなおこし'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('すなおこし'),
  );
  await testExistAnyWidgets(designatedWidget, driver);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン5'), driver);
  // バンギラスのいわなだれ
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('いわなた');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentいわなだれ');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // マリルリの残りHP48
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('4'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('8'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('マリルリはひるんで技がだせない'), driver);
  await driver.tap(find.text('マリルリはひるんで技がだせない'));

/*
  // チヲハウハネのこだいかっせい
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('こだい');
  var designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだいかっせい'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('こだいかっせい'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネ->ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // ボーマンダのダブルウイングが外れる
  designatedWidget = find.descendant(
      matching: find.byType('TextFormField'),
      of: find.byValueKey('HitInputOwn'));
  await driver.tap(designatedWidget);
  await driver.enterText('0');
  // 以下のように再度タップする等しないと反映されない
  await driver.tap(designatedWidget);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン2'), driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのじゃれつく
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('しやれ');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのもちものがいのちのたまと判明
  await driver.tap(find.text('ミミッキュ/k.k'));
  await driver.tap(find.byValueKey('PokemonStateEditDialogItem'));
  await driver.enterText('いのちの');
  await driver.tap(find.text('いのちのたま'));
  await driver.tap(find.text('適用'));
  // ボーマンダひんし→リーフィアに交代
  await testExistAnyWidgets(find.text('リーフィア'), driver);
  await driver.tap(find.text('リーフィア'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン3'), driver);
  // リーフィアテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ミミッキュ→チヲハウハネに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('チヲハウハネ'), driver);
  await driver.tap(find.text('チヲハウハネ'));
  // リーフィアのリーフブレード
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnリーフブレード');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン4'), driver);
  // リーフィアのテラバースト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnテラバースト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // チヲハウハネひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン5'), driver);
  // リーフィアのでんこうせっか
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうせっか');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP90
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('9'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // サザンドラのあくのはどう
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('あくのは');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentあくのはどう');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // リーフィアの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // リーフィアひんし→パーモットに交代
  await testExistAnyWidgets(find.text('パーモット'), driver);
  await driver.tap(find.text('パーモット'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン6'), driver);
  // 相手サザンドラ→ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // パーモットのさいきのいのりでボーマンダ復活
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnさいきのいのり');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('ボーマンダ'), driver);
  await driver.tap(find.text('ボーマンダ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン7'), driver);
  // ミミッキュのじゃれつく
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // パーモットの残りHP1
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('1'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // きあいのタスキ発動
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('きあいの');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('きあいのタスキ'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // パーモットのでんこうそうげき
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうそうげき');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン8'), driver);
  // サザンドラのりゅうせいぐん
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('りゅうせい');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentりゅうせいぐん');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラのりゅうせいぐんが外れる
  await driver.tap(find.byValueKey('HitInputOpponent'));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // パーモットのインファイト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnインファイト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // あなたの勝利
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('あなたの勝利！'),
  );
  await testExistAnyWidgets(designatedWidget, driver);

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
*/
}

/// パーモット戦4
Future<void> test1_4(
  FlutterDriver driver,
) async {
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  // 対戦名
  await driver.tap(find.byValueKey('BattleBasicListViewBattleName'));
  await driver.enterText('もこうパーモット戦4');
  // あなたのパーティ
  await driver.tap(find.byValueKey('BattleBasicListViewYourParty'));
  await testExistAnyWidgets(find.byType('PartyTile'), driver);
  await driver.tap(find.text('1もこパーモット'));
  // 元の画面に戻るのを待つ
  await driver
      .waitForTappable(find.byValueKey('BattleBasicListViewOpponentName'));
  // あいての名前
  await driver.tap(find.byValueKey('BattleBasicListViewOpponentName'));
  await driver.enterText('アイアムあむ');
  // ポケモン1
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン1',
      inputText: 'そうふれ',
      selectText: 'ソウブレイズ');
  // ポケモン2
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン2',
      inputText: 'くれん',
      selectText: 'グレンアルマ');
  // ポケモン3
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン3',
      inputText: 'ととけ',
      selectText: 'ドドゲザン');
  // ポケモン4
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン4',
      inputText: 'きらふ',
      selectText: 'キラフロル');
  // ポケモン5
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン5',
      inputText: 'うるかも',
      selectText: 'ウルガモス');
  // ポケモン6
  await inputPokemonInBattleBasic(driver,
      listViewKey: 'BattleBasicListView',
      fieldKey: 'PokemonSexRowポケモン6',
      inputText: 'せくれ',
      selectText: 'セグレイブ');
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(
      find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver);
  // 選出ポケモンを選ぶ
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこルリ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこキリン/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('もこパモ/'),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byType('PokemonMiniTile'),
    of: find.text('ソウブレイズ/'),
    firstMatchOnly: true,
  ));
  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン1'), driver);
  // マリルリのアクアジェット
  var designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnアクアジェット');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ソウブレイズの残りHP40
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('4'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ソウブレイズのくだけるよろい
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('くだける');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('くだけるよろい'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('くだけるよろい'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // ソウブレイズのレッドカード
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('れつと');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('レッドカード'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('レッドカード'),
  );
  await testExistAnyWidgets(designatedWidget, driver);

/*
  // チヲハウハネのこだいかっせい
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('こだい');
  var designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだいかっせい'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('こだいかっせい'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネ->ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // ボーマンダのダブルウイングが外れる
  designatedWidget = find.descendant(
      matching: find.byType('TextFormField'),
      of: find.byValueKey('HitInputOwn'));
  await driver.tap(designatedWidget);
  await driver.enterText('0');
  // 以下のように再度タップする等しないと反映されない
  await driver.tap(designatedWidget);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン2'), driver);
  // ボーマンダのダブルウイング
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnダブルウイング');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのじゃれつく
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('しやれ');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ボーマンダの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュのもちものがいのちのたまと判明
  await driver.tap(find.text('ミミッキュ/k.k'));
  await driver.tap(find.byValueKey('PokemonStateEditDialogItem'));
  await driver.enterText('いのちの');
  await driver.tap(find.text('いのちのたま'));
  await driver.tap(find.text('適用'));
  // ボーマンダひんし→リーフィアに交代
  await testExistAnyWidgets(find.text('リーフィア'), driver);
  await driver.tap(find.text('リーフィア'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン3'), driver);
  // リーフィアテラスタル
  await driver.tap(find.byValueKey('BattleActionCommandTerastalOwn'));
  // 相手ミミッキュ→チヲハウハネに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('チヲハウハネ'), driver);
  await driver.tap(find.text('チヲハウハネ'));
  // リーフィアのリーフブレード
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnリーフブレード');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP70
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('7'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン4'), driver);
  // リーフィアのテラバースト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnテラバースト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // チヲハウハネの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // チヲハウハネひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン5'), driver);
  // リーフィアのでんこうせっか
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうせっか');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP90
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('9'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // サザンドラのあくのはどう
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('あくのは');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentあくのはどう');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // リーフィアの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // リーフィアひんし→パーモットに交代
  await testExistAnyWidgets(find.text('パーモット'), driver);
  await driver.tap(find.text('パーモット'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン6'), driver);
  // 相手サザンドラ→ミミッキュに交代
  await driver.tap(find.byValueKey('BattleActionCommandChangeOpponent'));
  await testExistAnyWidgets(find.text('ミミッキュ'), driver);
  await driver.tap(find.text('ミミッキュ'));
  // パーモットのさいきのいのりでボーマンダ復活
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnさいきのいのり');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  await testExistAnyWidgets(find.text('ボーマンダ'), driver);
  await driver.tap(find.text('ボーマンダ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン7'), driver);
  // ミミッキュのじゃれつく
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentじゃれつく');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // パーモットの残りHP1
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.ancestor(
          of: find.text('1'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // きあいのタスキ発動
  await driver.tap(find.byValueKey('RegisterBattleEffectAddIconButton1'));
  await testExistAnyWidgets(
      find.byValueKey('AddEffectDialogSearchBar'), driver);
  await driver.tap(find.byValueKey('AddEffectDialogSearchBar'));
  await driver.enterText('きあいの');
  designatedWidget = find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ'));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('きあいのタスキ'),
  );
  await testExistAnyWidgets(designatedWidget, driver);
  // パーモットのでんこうそうげき
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnでんこうそうげき');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // ミミッキュの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // ミミッキュひんし→サザンドラに交代
  await testExistAnyWidgets(find.text('サザンドラ'), driver);
  await driver.tap(find.text('サザンドラ'));

  // 次へボタンタップ
  await driver.tap(find.byValueKey('RegisterBattleNext'));
  await testExistAnyWidgets(find.text('ターン8'), driver);
  // サザンドラのりゅうせいぐん
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
  await driver.enterText('りゅうせい');
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOpponentりゅうせいぐん');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラのりゅうせいぐんが外れる
  await driver.tap(find.byValueKey('HitInputOpponent'));
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOpponent'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // パーモットのインファイト
  designatedWidget =
      find.byValueKey('BattleActionCommandMoveListTileOwnインファイト');
  await testExistAnyWidgets(designatedWidget, driver);
  await driver.tap(designatedWidget);
  // サザンドラの残りHP0
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.ancestor(
          of: find.text('0'), matching: find.byType('_NumberInputButton')));
  await driver.tap(designatedWidget);
  designatedWidget = find.descendant(
      of: find.byValueKey('NumberInputButtonsOwn'),
      matching: find.byValueKey('EnterButton'));
  await driver.tap(designatedWidget);
  // あなたの勝利
  designatedWidget = find.descendant(
    of: find.byValueKey('EffectContainer'),
    matching: find.text('あなたの勝利！'),
  );
  await testExistAnyWidgets(designatedWidget, driver);

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
*/
}
