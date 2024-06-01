import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';

/// 検索対象Widgetが1つ以上あるかをテストする
/// ```
/// finder: 検索
/// driver: FlutterDriver
/// timeout: 検索のタイムアウト
/// ```
Future<void> testExistAnyWidgets(
    SerializableFinder finder, FlutterDriver driver,
    {Duration timeout = const Duration(seconds: 5)}) async {
  bool test = await isPresent(finder, driver);
  expect(test, true);
}

// https://stackoverflow.com/questions/49442872/how-to-check-if-an-element-exists-or-not-in-flutter-driverqa-environment
Future<bool> isPresent(SerializableFinder finder, FlutterDriver driver,
    {Duration timeout = const Duration(seconds: 5)}) async {
  try {
    await driver.waitForTappable(finder, timeout: timeout);
    return true;
  } catch (e) {
    return false;
  }
}

/// 対戦登録中ページにいるならそこから戻る(対戦のトップページに移動する)
Future<void> backBattleTopPage(
  FlutterDriver driver,
) async {
  // 前テストの結果保存中の場合があるため、2秒待つ
  await Future.delayed(Duration(seconds: 2));
  // 編集ダイアログが表示されている場合はキャンセルを押す
  if (await isPresent(find.text('キャンセル'), driver)) {
    await driver.tap(find.text('キャンセル'));
  }
  if (await isPresent(find.byTooltip('戻る'), driver)) {
    await driver.tap(find.byTooltip('戻る'));
    await driver.tap(find.text('はい'));
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
  // わざ名検索
  await driver.tap(find.byValueKey('PartiesSearch'));
  await driver.enterText(ownPartyname);
  /*if (!await isPresent(find.text(ownPartyname), driver)) {
    // 入力候補までスクロール
    await scrollUntilTappable(
        driver, find.byValueKey('PartiesListView'), find.text(ownPartyname),
        dyScroll: -100);
  }*/
  await driver.tap(find.descendant(
      of: find.byType('PartyTile'), matching: find.text(ownPartyname)));
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
        dyScroll: -50);
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
    matching: find.byValueKey('BattleFirstPokemonListviewOwn'),
    of: find.text(ownPokemon1),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byValueKey('BattleFirstPokemonListviewOwn'),
    of: find.text(ownPokemon2),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byValueKey('BattleFirstPokemonListviewOwn'),
    of: find.text(ownPokemon3),
    firstMatchOnly: true,
  ));
  await driver.tap(find.ancestor(
    matching: find.byValueKey('BattleFirstPokemonListviewOpponent'),
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
Future<void> tapMove(
    FlutterDriver driver, PlayerType playerType, String moveName, bool search,
    {bool isSecondary = false}) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  if (search) {
    // わざ名検索
    final searchKey = isSecondary
        ? 'StandAloneMoveSearch$ownOrOpponent'
        : 'BattleActionCommandMoveSearch$ownOrOpponent';
    await driver.tap(find.byValueKey(searchKey));
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
Future<void> addEffect(FlutterDriver driver, int addButtonNo,
    PlayerType playerType, String effectName) async {
  // sematicsLabelで検索するには必要
  await driver.setSemantics(true);
  String ownOrOpponent = playerType == PlayerType.me
      ? 'Own'
      : playerType == PlayerType.opponent
          ? 'Opponent'
          : 'Entire';
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
  await testExistAnyWidgets(
      find.bySemanticsLabel(RegExp("EffectListTile${ownOrOpponent}1")), driver);
  designatedWidget = find.descendant(
    of: find.descendant(
        of: find.bySemanticsLabel(RegExp("EffectListTile${ownOrOpponent}1")),
        matching: find.byType('ListTile')),
    matching: find.text(effectName),
  );
  await driver.tap(designatedWidget);
}

/// わざの選択後、次ボタンを押す
Future<void> tapMoveNext(FlutterDriver driver, PlayerType playerType) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  await driver.tap(find.byValueKey('StatusMoveNextButton$ownOrOpponent'));
  await driver.waitUntilNoTransientCallbacks();
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
  final target = find.descendant(
      matching: find.text(pokemonName),
      of: find.byValueKey('ChangePokemonTile$ownOrOpponent'));
  if (!await isPresent(target, driver)) {
    await scrollUntilTappable(
        driver, find.byValueKey('ChangePokemonListView$ownOrOpponent'), target,
        dyScroll: -100);
  }
  await driver.tap(target);
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

  var designatedWidget = find.byValueKey('HitInput$ownOrOpponent');
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

  var designatedWidget = find.byValueKey('CriticalInput$ownOrOpponent');
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
  if (remainHP != null) {
    await driver.tap(find.byValueKey('PokemonStateEditDialogRemainHP'));
    await driver.enterText(remainHP);
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

/// 対象のランク変化が正しいかテストする。
/// ```
/// [ex.]C+1かどうか調べる
/// rankAlphabet = 'C'
/// rankStr = 'Up0'
/// [ex.]A-2かどうか調べる
/// rankAlphabet = 'A'
/// rankStr = 'Down1'
/// [ex.]S+0かどうか調べる
/// rankAlphabet = 'S'
/// rankStr = 'Zero0'
/// ```
Future<void> testRank(FlutterDriver driver, PlayerType playerType,
    String rankAlphabet, String rankStr) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  String rankAlp = rankAlphabet;
  if (rankAlp.length == 1) {
    rankAlp += ' ';
  }
  final designatedWidget =
      find.byValueKey('BattlePokemonStateInfoRank$ownOrOpponent');
  if (!await isPresent(designatedWidget, driver)) {
    // ランク変化のページまで移動
    for (int i = 0; i < 5; i++) {
      // 右のページへ
      await driver.tap(
          find.byValueKey('BattlePokemonStateInfoNextButton$ownOrOpponent'));
      if (await isPresent(designatedWidget, driver)) break;
    }
    if (!await isPresent(designatedWidget, driver)) {
      for (int i = 0; i < 5; i++) {
        // 左のページへ
        await driver.tap(
            find.byValueKey('BattlePokemonStateInfoPrevButton$ownOrOpponent'));
        if (await isPresent(designatedWidget, driver)) break;
      }
    }
  }
  await testExistAnyWidgets(
      find.byValueKey('Rank$rankAlp$ownOrOpponent$rankStr'), driver);
}

/// 対象の状態変化の有無をチェックする。
Future<bool> isExistAilment(
    FlutterDriver driver, PlayerType playerType, String ailmentStr) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  final designatedWidget =
      find.byValueKey('BattlePokemonStateInfoAilment$ownOrOpponent');
  if (!await isPresent(designatedWidget, driver)) {
    // ランク変化のページまで移動
    for (int i = 0; i < 5; i++) {
      // 右のページへ
      await driver.tap(
          find.byValueKey('BattlePokemonStateInfoNextButton$ownOrOpponent'));
      if (await isPresent(designatedWidget, driver)) break;
    }
    if (!await isPresent(designatedWidget, driver)) {
      for (int i = 0; i < 5; i++) {
        // 左のページへ
        await driver.tap(
            find.byValueKey('BattlePokemonStateInfoPrevButton$ownOrOpponent'));
        if (await isPresent(designatedWidget, driver)) break;
      }
    }
  }
  return isPresent(find.text(ailmentStr), driver);
}

/// 対象の場の有無をチェックする。
Future<bool> isExistField(
    FlutterDriver driver, PlayerType playerType, String fieldStr) async {
  String ownOrOpponent = playerType == PlayerType.me ? 'Own' : 'Opponent';
  final designatedWidget =
      find.byValueKey('BattlePokemonStateInfoField$ownOrOpponent');
  if (!await isPresent(designatedWidget, driver)) {
    // ランク変化のページまで移動
    for (int i = 0; i < 5; i++) {
      // 右のページへ
      await driver.tap(
          find.byValueKey('BattlePokemonStateInfoNextButton$ownOrOpponent'));
      if (await isPresent(designatedWidget, driver)) break;
    }
    if (!await isPresent(designatedWidget, driver)) {
      for (int i = 0; i < 5; i++) {
        // 左のページへ
        await driver.tap(
            find.byValueKey('BattlePokemonStateInfoPrevButton$ownOrOpponent'));
        if (await isPresent(designatedWidget, driver)) break;
      }
    }
  }
  return isPresent(find.text(fieldStr), driver);
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
  driver
      .waitForTappable(item, timeout: timeout ?? Duration(seconds: 30))
      .then<void>((_) {
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
