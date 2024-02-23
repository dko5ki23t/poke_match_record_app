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
        await driver!.waitForTappable(find.byType('FloatingActionButton'));
        // 追加ボタン(+)タップ
        await driver!.tap(find.byType('FloatingActionButton'));
        await testExistAnyWidgets(
            find.byValueKey('BattleBasicListViewBattleName'), driver!);
        // 基本情報を入力
        // 対戦名
        await driver!.tap(find.byValueKey('BattleBasicListViewBattleName'));
        await driver!.enterText('もこうパーモット戦1');
        // あなたのパーティ
        await driver!.tap(find.byValueKey('BattleBasicListViewYourParty'));
        await testExistAnyWidgets(find.byType('PartyTile'), driver!);
        await driver!.tap(find.text('1もこパーモット'));
        // 元の画面に戻るのを待つ
        await driver!.waitForTappable(
            find.byValueKey('BattleBasicListViewOpponentName'));
        // あいての名前
        await driver!.tap(find.byValueKey('BattleBasicListViewOpponentName'));
        await driver!.enterText('メリタマ');
        // ポケモン1
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン1',
            inputText: 'きやら',
            selectText: 'ギャラドス');
        // せいべつ1
        // TODO:DropDownMenuItemをタップできないため、無視
        // https://github.com/flutter/flutter/issues/89905
        //await driver!.tap(find.byValueKey('PokemonSexRowせいべつ1'));
        //final menu = find.descendant(
        //    of: find.byValueKey('PokemonSexRowせいべつ1'),
        //    matching: find.byValueKey('PokemonSexRowせいべつ1オス'),
        //    firstMatchOnly: true);
        //await driver!.getBottomLeft(menu);
        //await driver!.tap(menu);
        // ポケモン2
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン2',
            inputText: 'せくれ',
            selectText: 'セグレイブ');
        // ポケモン3
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン3',
            inputText: 'てつのつ',
            selectText: 'テツノツツミ');
        // ポケモン4
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン4',
            inputText: 'てかぬ',
            selectText: 'デカヌチャン');
        // ポケモン5
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン5',
            inputText: 'てつのこ',
            selectText: 'テツノコウベ');
        // ポケモン6
        await inputPokemonInBattleBasic(driver!,
            listViewKey: 'BattleBasicListView',
            fieldKey: 'PokemonSexRowポケモン6',
            inputText: 'かはる',
            selectText: 'カバルドン');
        // 次へボタンタップ
        await driver!.tap(find.byValueKey('RegisterBattleNext'));
        await testExistAnyWidgets(
            find.text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), driver!);
        // 選出ポケモンを選ぶ
        await driver!.tap(find.ancestor(
          matching: find.byType('PokemonMiniTile'),
          of: find.text('もこいかくマンダ/'),
          firstMatchOnly: true,
        ));
        await driver!.tap(find.ancestor(
          matching: find.byType('PokemonMiniTile'),
          of: find.text('もこパモ/'),
          firstMatchOnly: true,
        ));
        await driver!.tap(find.ancestor(
          matching: find.byType('PokemonMiniTile'),
          of: find.text('もこロローム/'),
          firstMatchOnly: true,
        ));
        await driver!.tap(find.ancestor(
          matching: find.byType('PokemonMiniTile'),
          of: find.text('デカヌチャン/'),
          firstMatchOnly: true,
        ));
        // 次へボタンタップ
        await driver!.tap(find.byValueKey('RegisterBattleNext'));
        await testExistAnyWidgets(find.text('ターン1'), driver!);
        // ボーマンダのりゅうのまい
        // (これキー指定するのは不本意。find.textがうまく動作しない・・・)
        var designatedWidget =
            find.byValueKey('BattleActionCommandMoveListTileOwnりゅうのまい');
        await testExistAnyWidgets(designatedWidget, driver!);
        await driver!.tap(designatedWidget);
        await testExistAnyWidgets(find.text('成功'), driver!);
        // デカヌチャンのがんせきふうじ
        await driver!
            .tap(find.byValueKey('BattleActionCommandMoveSearchOpponent'));
        await driver!.enterText('かんせき');
        designatedWidget =
            find.byValueKey('BattleActionCommandMoveListTileOpponentがんせきふうじ');
        await testExistAnyWidgets(designatedWidget, driver!);
        await driver!.tap(designatedWidget);
        // ボーマンダの残りHP127
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOpponent'),
            matching: find.ancestor(
                of: find.text('1'),
                matching: find.byType('_NumberInputButton')));
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOpponent'),
            matching: find.ancestor(
                of: find.text('2'),
                matching: find.byType('_NumberInputButton')));
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOpponent'),
            matching: find.ancestor(
                of: find.text('7'),
                matching: find.byType('_NumberInputButton')));
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOpponent'),
            matching: find.byValueKey('EnterButton'));
        await driver!.tap(designatedWidget);
        await testExistAnyWidgets(find.text('ボーマンダはすばやさが下がった'), driver!);

        // 次のターンへボタンタップ
        await driver!.tap(find.byValueKey('RegisterBattleNext'));
        await testExistAnyWidgets(find.text('ターン2'), driver!);
        // ボーマンダのじしん
        designatedWidget =
            find.byValueKey('BattleActionCommandMoveListTileOwnじしん');
        await testExistAnyWidgets(designatedWidget, driver!);
        await driver!.tap(designatedWidget);
        // デカヌチャンの残りHP0
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOwn'),
            matching: find.ancestor(
                of: find.text('0'),
                matching: find.byType('_NumberInputButton')));
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOwn'),
            matching: find.byValueKey('EnterButton'));
        await driver!.tap(designatedWidget);
        // デカヌチャンひんし→テツノツツミに交代
        await testExistAnyWidgets(find.text('テツノツツミ'), driver!);
        await driver!.tap(find.text('テツノツツミ'));
        // クォークチャージ発動
        await driver!
            .tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
        await testExistAnyWidgets(
            find.byValueKey('AddEffectDialogSearchBar'), driver!);
        await driver!.tap(find.byValueKey('AddEffectDialogSearchBar'));
        await driver!.enterText('クォーク');
        designatedWidget = find.descendant(
            of: find.byType('ListTile'),
            matching: find.text('クォークチャージ'),
            //TODO ほんとは1つしかないから不要のはず
            firstMatchOnly: true);
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
          of: find.byValueKey('EffectContainer'),
          matching: find.text('クォークチャージ'),
        );
        // クォークチャージの内容編集
        await driver!.tap(designatedWidget);
        // TODO? 「効果が切れた」は期待通りか・・・？
        await driver!.tap(find.text('効果が切れた'));
        await driver!.tap(find.text('とくこう'));
        await driver!.tap(find.text('OK'));

        // 次のターンへボタンタップ
        await driver!.tap(find.byValueKey('RegisterBattleNext'));
        await testExistAnyWidgets(find.text('ターン3'), driver!);
        // ボーマンダのげきりん
        designatedWidget =
            find.byValueKey('BattleActionCommandMoveListTileOwnげきりん');
        await testExistAnyWidgets(designatedWidget, driver!);
        await driver!.tap(designatedWidget);
        // テツノツツミの残りHP0
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOwn'),
            matching: find.ancestor(
                of: find.text('0'),
                matching: find.byType('_NumberInputButton')));
        await driver!.tap(designatedWidget);
        designatedWidget = find.descendant(
            of: find.byValueKey('NumberInputButtonsOwn'),
            matching: find.byValueKey('EnterButton'));
        await driver!.tap(designatedWidget);
        // テツノツツミひんし→ギャラドスに交代
        await testExistAnyWidgets(find.text('ギャラドス'), driver!);
        await driver!.tap(find.text('ギャラドス'));
        // いかく発動
        await driver!
            .tap(find.byValueKey('RegisterBattleEffectAddIconButton2'));
        await testExistAnyWidgets(
            find.byValueKey('AddEffectDialogSearchBar'), driver!);
        await driver!.tap(find.byValueKey('AddEffectDialogSearchBar'));
        await driver!.enterText('いかく');
        await driver!.tap(find.byValueKey('EffectListTileOpponentいかく'));

        // 次のターンへボタンタップ
        await driver!.tap(find.byValueKey('RegisterBattleNext'));
        await testExistAnyWidgets(find.text('ターン4'), driver!);
        // あいて降参
        await driver!
            .tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

        // 内容保存
        await driver!.tap(find.byValueKey('RegisterBattleSave'));
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
