import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ノココッチ戦1
Future<void> test6_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうノココッチ戦1',
    ownPartyname: '6もこコッチ',
    opponentName: 'ふがし',
    pokemon1: 'ドラパルト',
    pokemon2: 'キノガッサ',
    pokemon3: 'パオジアン',
    pokemon4: 'キョジオーン',
    pokemon5: 'ウルガモス',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこコッチ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ドラパルトのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ノココッチのHP155
  await inputRemainHP(driver, op, '155');
  // ドラパルト->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ばけのかわなのでダメージなし
  await inputRemainHP(driver, me, '');
  // ひるむ
  await testExistAnyWidgets(find.text('ミミッキュはひるんで技がだせない'), driver);
  await driver.tap(find.text('ミミッキュはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ミミッキュのHP60
  await inputRemainHP(driver, me, '60');
  // ひるむ
  await testExistAnyWidgets(find.text('ミミッキュはひるんで技がだせない'), driver);
  await driver.tap(find.text('ミミッキュはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ミミッキュのHP35
  await inputRemainHP(driver, me, '35');
  // ひるむ
  await testExistAnyWidgets(find.text('ミミッキュはひるんで技がだせない'), driver);
  await driver.tap(find.text('ミミッキュはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ミミッキュのHP3
  await inputRemainHP(driver, me, '3');
  // ひるむ
  await testExistAnyWidgets(find.text('ミミッキュはひるんで技がだせない'), driver);
  await driver.tap(find.text('ミミッキュはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->パオジアンに交代
  await changePokemon(driver, op, 'パオジアン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パオジアンのかみくだく
  await tapMove(driver, op, 'かみくだく', true);
  // ノココッチのHP35
  await inputRemainHP(driver, op, '35');
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パオジアンはしびれて動けない
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP136
  await inputRemainHP(driver, me, '136');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // パオジアンのHP40
  await inputRemainHP(driver, me, '40');
  // ひるむ
  await testExistAnyWidgets(find.text('パオジアンはひるんで技がだせない'), driver);
  await driver.tap(find.text('パオジアンはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // パオジアンのHP0
  await inputRemainHP(driver, me, '0');
  // パオジアンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ドラゴン');
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // ノココッチのHP0
  await inputRemainHP(driver, op, '0');
  // ノココッチひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ノココッチ戦2
Future<void> test6_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうノココッチ戦2',
    ownPartyname: '6もこコッチ',
    opponentName: 'バクシーシ',
    pokemon1: 'ハバタクカミ',
    pokemon2: 'キョジオーン',
    pokemon3: 'デカヌチャン',
    pokemon4: 'タイカイデン',
    pokemon5: 'シャワーズ',
    pokemon6: 'キラフロル',
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこコッチ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'キラフロル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // キラフロルのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キラフロルのニードルガード
  await tapMove(driver, op, 'ニードルガード', true);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ニードルガードで失敗、直接攻撃ではないのでダメージは受けない
  await inputRemainHP(driver, me, '');
  await testHP(driver, me, '201/201');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP90
  await inputRemainHP(driver, me, '90');
  // ひるむ
  await testExistAnyWidgets(find.text('キラフロルはひるんで技がだせない'), driver);
  await driver.tap(find.text('キラフロルはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP80
  await inputRemainHP(driver, me, '80');
  // ひるむ
  await testExistAnyWidgets(find.text('キラフロルはひるんで技がだせない'), driver);
  await driver.tap(find.text('キラフロルはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP70
  await inputRemainHP(driver, me, '70');
  // ひるむ
  await testExistAnyWidgets(find.text('キラフロルはひるんで技がだせない'), driver);
  await driver.tap(find.text('キラフロルはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP55
  await inputRemainHP(driver, me, '55');
  // ひるむ
  await testExistAnyWidgets(find.text('キラフロルはひるんで技がだせない'), driver);
  await driver.tap(find.text('キラフロルはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP40
  await inputRemainHP(driver, me, '40');
  // ひるむ
  await testExistAnyWidgets(find.text('キラフロルはひるんで技がだせない'), driver);
  await driver.tap(find.text('キラフロルはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // キラフロルのHP30
  await inputRemainHP(driver, me, '30');
  // キラフロルはしびれて動けない
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのばくおんぱ
  await tapMove(driver, me, 'ばくおんぱ', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルひんし->ハバタクカミに交代
  await changePokemon(driver, op, 'ハバタクカミ', false);
  // ハバタクカミのこだいかっせい
  await addEffect(driver, 2, op, 'こだいかっせい');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // ノココッチのHP35
  await inputRemainHP(driver, op, '35');
  // ノココッチのとくこうが下がる
  await driver.tap(find.text('ノココッチはとくこうが下がった'));
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ハバタクカミのHP85
  await inputRemainHP(driver, me, '85');
  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // ノココッチのHP0
  await inputRemainHP(driver, op, '0');
  // ノココッチひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ハバタクカミのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // ハバタクカミのHP0
  await inputRemainHP(driver, me, '0');
  // ハバタクカミひんし->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ノココッチ戦3
Future<void> test6_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうノココッチ戦3',
    ownPartyname: '6もこコッチ',
    opponentName: '冷汗',
    pokemon1: 'サーフゴー',
    pokemon2: 'ブリムオン',
    pokemon3: 'サザンドラ',
    pokemon4: 'ウルガモス',
    pokemon5: 'パーモット',
    pokemon6: 'ドヒドイデ',
    sex2: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこコッチ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // サザンドラ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);
  // おうごんのからだで失敗
  // TODO:自動で失敗にする
  await tapSuccess(driver, me);
  // サーフゴーに効果がなく、まひにならないことを確認する
  bool test = await isExistAilment(driver, op, 'まひ');
  expect(test, false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチ->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // サーフゴーのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // サーフゴーのHP90
  await inputRemainHP(driver, me, '90');
  // ここはおそらくサーフゴーがおんみつマントを持っているためまひにできない
  await testExistAnyWidgets(find.text('サーフゴーはしびれてしまった'), driver);
  await driver.tap(find.text('サーフゴーはしびれてしまった'));
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->リーフィアに交代
  await changePokemon(driver, me, 'リーフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのテラスタル
  await inputTerastal(driver, me, '');
  // リーフィアのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // リーフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // サザンドラのHP85
  await inputRemainHP(driver, me, '85');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // 急所に命中
  await tapCritical(driver, op);
  // リーフィアのHP0
  await inputRemainHP(driver, op, '0');
  // リーフィアひんし->ノココッチに交代
  await changePokemon(driver, op, 'ノココッチ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP111
  await inputRemainHP(driver, op, '111');
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP12
  await inputRemainHP(driver, op, '12');
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP113
  await inputRemainHP(driver, me, '113');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP16
  await inputRemainHP(driver, op, '16');
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP117
  await inputRemainHP(driver, me, '117');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP27
  await inputRemainHP(driver, op, '27');
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP128
  await inputRemainHP(driver, me, '128');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP35
  await inputRemainHP(driver, op, '35');
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP136
  await inputRemainHP(driver, me, '136');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP49
  await inputRemainHP(driver, op, '49');
  // ノココッチのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ノココッチのHP150
  await inputRemainHP(driver, me, '150');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP63
  await inputRemainHP(driver, op, '63');
  // ひるむ
  await testExistAnyWidgets(find.text('ノココッチはひるんで技がだせない'), driver);
  await driver.tap(find.text('ノココッチはひるんで技がだせない'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ノココッチのHP0
  await inputRemainHP(driver, op, '0');
  // あいての勝利
  await testExistEffect(driver, '冷汗の勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ノココッチ戦4
Future<void> test6_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうノココッチ戦4',
    ownPartyname: '6もこコッチ',
    opponentName: 'ゆう',
    pokemon1: 'カイリュー',
    pokemon2: 'ゲンガー',
    pokemon3: 'イッカネズミ',
    pokemon4: 'テツノブジン',
    pokemon5: 'テツノカイナ',
    pokemon6: 'キョジオーン',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこコッチ/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこニンフィア/',
      opponentPokemon: 'イッカネズミ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, op, 'おかたづけ', true);
  // ノココッチのものまねハーブ
  await addEffect(driver, 1, me, 'ものまねハーブ');
  // こうげきとすばやさが1段階上がる
  await driver.tap(find.byValueKey('ItemEffectRankAMenu'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.byValueKey('ItemEffectRankSMenu'));
  await driver.tap(find.text('+1'));
  await driver.tap(find.text('OK'));
  // ノココッチのへびにらみ
  await tapMove(driver, me, 'へびにらみ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // イッカネズミのHP70
  await inputRemainHP(driver, me, '70');
  // イッカネズミのアンコール
  await tapMove(driver, op, 'アンコール', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // 外す
  await tapHit(driver, me);
  await inputRemainHP(driver, me, '');
  // イッカネズミのおかたづけ
  await tapMove(driver, op, 'おかたづけ', true);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, op, 'おかたづけ', false);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // イッカネズミのHP30
  await inputRemainHP(driver, me, '30');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, op, 'ネズミざん', true);
  // 3回命中
  await setHitCount(driver, op, 3);
  // 1回急所
  await setCriticalCount(driver, op, 1);
  // ノココッチのHP0
  await inputRemainHP(driver, op, '0');
  // ノココッチひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // イッカネズミのHP10
  await inputRemainHP(driver, me, '10');
  // イッカネズミはしびれて動けない
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ニンフィアのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // 急所に命中
  await tapCritical(driver, me);
  // イッカネズミのHP0
  await inputRemainHP(driver, me, '0');
  // イッカネズミひんし->ゲンガーに交代
  await changePokemon(driver, op, 'ゲンガー', false);
  // ふうせんで浮いている
  await addEffect(driver, 2, op, 'ふうせん');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ゲンガーのヘドロばくだん
  await tapMove(driver, op, 'ヘドロばくだん', true);
  // リーフィアのHP62
  await inputRemainHP(driver, op, '62');
  // リーフィアのあくび
  await tapMove(driver, me, 'あくび', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ゲンガーのヘドロばくだん
  await tapMove(driver, op, 'ヘドロばくだん', true);
  // リーフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ゲンガー->テツノブジンに交代
  await changePokemon(driver, op, 'テツノブジン', true);
  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // ノココッチを復活させる
  await changePokemon(driver, me, 'ノココッチ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノブジンのソウルクラッシュ
  await tapMove(driver, op, 'ソウルクラッシュ', true);
  // パーモットのHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // テツノブジンのHP90
  await inputRemainHP(driver, me, '90');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // テツノブジン->ゲンガーに交代
  await changePokemon(driver, op, 'ゲンガー', true);
  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // ゲンガーのHP0
  await inputRemainHP(driver, me, '0');
  // ゲンガーひんし->テツノブジンに交代
  await changePokemon(driver, op, 'テツノブジン', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // テツノブジンのHP50
  await inputRemainHP(driver, me, '50');
  // テツノブジンのソウルクラッシュ
  await tapMove(driver, op, 'ソウルクラッシュ', false);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->ノココッチに交代
  await changePokemon(driver, op, 'ノココッチ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ノココッチのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // テツノブジンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウミトリオ戦1
Future<void> test7_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうウミトリオ戦1',
    ownPartyname: '7もこウミトリオ',
    opponentName: 'バース',
    pokemon1: 'ドオー',
    pokemon2: 'テツノドクガ',
    pokemon3: 'チオンジェン',
    pokemon4: 'ミミッキュ',
    pokemon5: 'キノガッサ',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこウミトリオ/',
      ownPokemon2: 'もこいかくマンダ/',
      ownPokemon3: 'もこネズミ/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // ウミトリオのHP1
  await inputRemainHP(driver, op, '1');
  // テツノドクガに交代
  await changePokemon(driver, op, 'テツノドクガ', false);
  // ウミトリオのきあいのタスキ
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // テツノドクガのクォークチャージ
  await addEffect(driver, 2, op, 'クォークチャージ');
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));
  // ウミトリオのトリプルダイブ
  await tapMove(driver, me, 'トリプルダイブ', false);
  // テツノドクガのHP0
  await inputRemainHP(driver, me, '0');
  // テツノドクガひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ウミトリオのHP0
  await inputRemainHP(driver, op, '0');
  // ウミトリオひんし->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // イッカネズミのHP95
  await inputRemainHP(driver, op, '95');
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ロトムのテラスタル
  await inputTerastal(driver, op, 'こおり');
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 5回命中
  await setHitCount(driver, me, 5);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->キノガッサに交代
  await changePokemon(driver, op, 'キノガッサ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // イッカネズミひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // キノガッサのHP0
  await inputRemainHP(driver, me, '0');
  // キノガッサのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウミトリオ戦2
Future<void> test7_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうウミトリオ戦2',
    ownPartyname: '7もこウミトリオ2',
    opponentName: 'Bananajoe',
    pokemon1: 'キラフロル',
    pokemon2: 'ライチュウ',
    pokemon3: 'モスノウ',
    pokemon4: 'ソウブレイズ',
    pokemon5: 'ハラバリー',
    pokemon6: 'セグレイブ',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこウミトリオ/',
      ownPokemon2: 'もこリガメ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'キラフロル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウミトリオのテラスタル
  await inputTerastal(driver, me, '');
  // ウミトリオのトリプルダイブ
  await tapMove(driver, me, 'トリプルダイブ', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルのどくげしょう*2
  await addEffect(driver, 2, op, 'どくげしょう');
  await driver.tap(find.text('OK'));
  await addEffect(driver, 3, op, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // 味方の場に「どくびし(もうどく)」があることを確認
  bool test = await isExistField(driver, me, 'どくびし(もうどく)');
  expect(test, true);
  // キラフロルひんし->ライチュウに交代
  await changePokemon(driver, op, 'ライチュウ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ウミトリオのトリプルダイブ
  await tapMove(driver, me, 'トリプルダイブ', false);
  // ライチュウのテラスタル
  await inputTerastal(driver, op, 'でんき');
  // ライチュウのHP0
  await inputRemainHP(driver, me, '0');
  // ライチュウのせいでんき
  await addEffect(driver, 2, op, 'せいでんき');
  await driver.tap(find.text('OK'));
  // ライチュウひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // セグレイブのドラゴンクロー
  await tapMove(driver, op, 'ドラゴンクロー', true);
  // ウミトリオのHP1
  await inputRemainHP(driver, op, '1');
  // きあいのタスキ発動
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ウミトリオのおきみやげ
  await tapMove(driver, me, 'おきみやげ', false);
  // ウミトリオひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // 相手のランク確認(A-3,C-2, S-1)
  await testRank(driver, op, 'A', 'Down2');
  await testRank(driver, op, 'C', 'Down1');
  await testRank(driver, op, 'S', 'Down0');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウミトリオ戦3
Future<void> test7_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうウミトリオ戦3',
    ownPartyname: '7もこウミトリオ2',
    opponentName: 'にぎるお',
    pokemon1: 'ハラバリー',
    pokemon2: 'サケブシッポ',
    pokemon3: 'パオジアン',
    pokemon4: 'イルカマン',
    pokemon5: 'ガブリアス',
    pokemon6: 'サーフゴー',
    sex1: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこウミトリオ/',
      ownPokemon2: 'もこネズミ/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウミトリオのおきみやげ
  await tapMove(driver, me, 'おきみやげ', false);
  // ウミトリオひんし->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);
  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // 外れる
  await tapHit(driver, op);
  // イッカネズミのHP150
  await inputRemainHP(driver, op, '');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのおかたづけ
  await tapMove(driver, me, 'おかたづけ', false);
  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', false);
  // イッカネズミのHP110
  await inputRemainHP(driver, op, '110');
  // ハラバリーに交代
  await changePokemon(driver, op, 'ハラバリー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ハラバリー->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // イッカネズミのテラスタル
  await inputTerastal(driver, me, '');
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  // ガブリアスのHP30
  await inputRemainHP(driver, me, '30');
  // ガブリアスのさめはだ＋ゴツゴツメット
  await addEffect(driver, 3, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  await addEffect(driver, 4, op, 'ゴツゴツメット');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('0');
  await driver.tap(find.text('OK'));
  // イッカネズミひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウミトリオ戦4
Future<void> test7_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこウミトリオ戦4',
    ownPartyname: '7もこウミトリオ2',
    opponentName: 'ばんかい',
    pokemon1: 'ジバコイル',
    pokemon2: 'マリルリ',
    pokemon3: 'ガブリアス',
    pokemon4: 'テツノドクガ',
    pokemon5: 'マスカーニャ',
    pokemon6: 'セグレイブ',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこウミトリオ/',
      ownPokemon2: 'もこネズミ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウミトリオのおきみやげ
  await tapMove(driver, me, 'おきみやげ', false);
  // ウミトリオひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのつららおとし
  await tapMove(driver, op, 'つららおとし', true);
  // ボーマンダのHP69
  await inputRemainHP(driver, op, '69');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ガブリアスのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ガブリアスのHP100
  await inputRemainHP(driver, me, '');
  // ガブリアスのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ガブリアスのいのちのたま
  await addEffect(driver, 3, PlayerType.opponent, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ボーマンダひんし->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのネズミざん
  await tapMove(driver, me, 'ネズミざん', false);
  // 7回命中
  await setHitCount(driver, me, 7);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  // イッカネズミのHP24
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('24');
  await driver.tap(find.text('OK'));
  // ガブリアスひんし->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // イッカネズミのかみつく
  await tapMove(driver, me, 'かみつく', false);
  // ジバコイルのHP85
  await inputRemainHP(driver, me, '85');
  // ジバコイルのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // あいての勝利
  await testExistEffect(driver, 'ばんかいの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ウミトリオ戦5
Future<void> test7_5(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうウミトリオ戦5',
    ownPartyname: '7もこウミトリオ2',
    opponentName: 'コズエ',
    pokemon1: 'ディンルー',
    pokemon2: 'ギャラドス',
    pokemon3: 'サーフゴー',
    pokemon4: 'ロトム(ヒートロトム)',
    pokemon5: 'ドラパルト',
    pokemon6: 'マスカーニャ',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこウミトリオ/',
      ownPokemon2: 'もこリガメ/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'ロトム(ヒートロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウミトリオのテラスタル
  await inputTerastal(driver, me, '');
  // ウミトリオのトリプルダイブ
  await tapMove(driver, me, 'トリプルダイブ', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // ウミトリオのHP1
  await inputRemainHP(driver, op, '1');
  // ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', false);
  // ウミトリオのきあいのタスキ
  await addEffect(driver, 2, PlayerType.me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // 1回命中
  await setHitCount(driver, me, 1);
  // ギャラドスのHP97
  await inputRemainHP(driver, me, '97');
  // ギャラドスのゴツゴツメット
  await addEffect(driver, 4, PlayerType.opponent, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ウミトリオひんし->カジリガメに交代
  await changePokemon(driver, me, 'カジリガメ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // ギャラドスのでんじは
  await tapMove(driver, op, 'でんじは', true);
  // カジリガメのラムのみ
  await addEffect(driver, 2, PlayerType.me, 'ラムのみ');
  await driver.tap(find.text('OK'));

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // 3回命中
  await setHitCount(driver, me, 3);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // ギャラドスひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // カジリガメのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP20
  await inputRemainHP(driver, me, '20');
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // カジリガメのHP0
  await inputRemainHP(driver, op, '0');
  // カジリガメひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', false);
  // ボーマンダのHP15
  await inputRemainHP(driver, op, '15');

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ヒートロトム)', false);

  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // ボーマンダのげきりん
  await tapMove(driver, me, 'げきりん', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キョジオーン戦1
Future<void> test8_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうキョジオーン戦1',
    ownPartyname: '8もこオーン',
    opponentName: 'つよそう',
    pokemon1: 'カイリュー',
    pokemon2: 'イーユイ',
    pokemon3: 'ハッサム',
    pokemon4: 'モロバレル',
    pokemon5: 'ミミッキュ',
    pokemon6: 'カバルドン',
    sex1: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこオーン/',
      ownPokemon2: 'もこルリ2/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'モロバレル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // キョジオーンのテラスタル
  await inputTerastal(driver, me, '');
  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // モロバレルのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  await tapSuccess(driver, op);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // モロバレルのHP92
  await inputRemainHP(driver, me, '92');
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // キョジオーンのHP157
  await inputRemainHP(driver, op, '157');
  // キョジオーンのHP169であることを確認
  await testHP(driver, me, '169/207');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP66
  await inputRemainHP(driver, me, '66');
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', false);
  // キョジオーンのHP16
  await inputRemainHP(driver, op, '16');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP132
  await inputRemainHP(driver, me, '132');
  // モロバレルのこうごうせい
  await tapMove(driver, op, 'こうごうせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // モロバレルのHP93
  await inputRemainHP(driver, op, '93');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // モロバレルのHP43
  await inputRemainHP(driver, me, '43');
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', false);
  // キョジオーンのHP94
  await inputRemainHP(driver, op, '94');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP207
  await inputRemainHP(driver, me, '207');
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', false);
  // キョジオーンのHP153
  await inputRemainHP(driver, op, '153');
  // モロバレルひんし->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハッサムのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ハッサムのHP90
  await inputRemainHP(driver, me, '90');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  // キョジオーンのHP96
  await inputRemainHP(driver, op, '96');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP200
  await inputRemainHP(driver, me, '200');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', false);
  // キョジオーンのHP137
  await inputRemainHP(driver, op, '137');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP207
  await inputRemainHP(driver, me, '207');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', false);
  // キョジオーンのHP128
  await inputRemainHP(driver, op, '128');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP207
  await inputRemainHP(driver, me, '207');
  // ハッサムひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // キョジオーンのHP119
  await inputRemainHP(driver, op, '119');
  // ミミッキュのいのちのたま
  await addEffect(driver, 1, PlayerType.opponent, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP16
  await inputRemainHP(driver, me, '16');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キョジオーン戦2
Future<void> test8_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうキョジオーン戦2',
    ownPartyname: '8もこオーン',
    opponentName: 'カメキチ',
    pokemon1: 'コータス',
    pokemon2: 'ハッサム',
    pokemon3: 'アーマーガア',
    pokemon4: 'カイリュー',
    pokemon5: 'グレンアルマ',
    pokemon6: 'ハバタクカミ',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこオーン/',
      ownPokemon2: 'もこアルマ/',
      ownPokemon3: 'もこルリ2/',
      opponentPokemon: 'コータス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // コータスのひでり
  await addEffect(driver, 0, PlayerType.opponent, 'ひでり');
  await driver.tap(find.text('OK'));
  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // コータスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // コータスのあくび
  await tapMove(driver, op, 'あくび', true);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // コータスのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // 外れる
  await tapHit(driver, op);
  await inputRemainHP(driver, op, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // コータスのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', false);
  // キョジオーンのHP151
  await inputRemainHP(driver, op, '151');
  // コータスのだっしゅつパック
  await addEffect(driver, 1, PlayerType.opponent, 'だっしゅつパック');
  // ハバタクカミに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('ハバタクカミ'));
  await driver.tap(find.text('OK'));
  // こだいかっせい編集
  await tapEffect(driver, 'こだいかっせい');
  // すばやさが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // キョジオーンのHP70
  await inputRemainHP(driver, op, '70');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP174
  await inputRemainHP(driver, me, '174');
  // こだいかっせいの効果が切れる
  await testExistEffect(driver, 'こだいかっせい');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ハバタクカミのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // キョジオーンのHP130
  await inputRemainHP(driver, op, '130');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ハバタクカミのHP26
  await inputRemainHP(driver, me, '26');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', false);
  // キョジオーンのHP39
  await inputRemainHP(driver, op, '39');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP143
  await inputRemainHP(driver, me, '143');
  // しおづけダメージ編集
  await tapEffect(driver, 'しおづけダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('0');
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('0');
  await driver.tap(find.text('OK'));
  // ハバタクカミひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キョジオーン戦3
Future<void> test8_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこう',
    ownPartyname: '8もこオーン',
    opponentName: 'MOMON',
    pokemon1: 'ハバタクカミ',
    pokemon2: 'トドロクツキ',
    pokemon3: 'ウルガモス',
    pokemon4: 'イルカマン',
    pokemon5: 'キラフロル',
    pokemon6: 'デカヌチャン',
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアルマ/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // グレンアルマのHP82
  await inputRemainHP(driver, op, '82');
  // キラフロルに交代
  await changePokemon(driver, op, 'キラフロル', false);
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // キラフロルのHP60
  await inputRemainHP(driver, me, '60');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', true);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // グレンアルマひんし->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // イルカマンのテラスタル
  await inputTerastal(driver, op, 'みず');
  // キョジオーンのテラスタル
  await inputTerastal(driver, me, '');
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // キョジオーンのHP143
  await inputRemainHP(driver, op, '143');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // イルカマンのHP90
  await inputRemainHP(driver, me, '90');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', false);
  // キョジオーンのHP93
  await inputRemainHP(driver, op, '93');
  // デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', false);
  // デカヌチャンのかたやぶり
  await addEffect(driver, 1, PlayerType.opponent, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // デカヌチャンのHP95
  await inputRemainHP(driver, me, '95');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // キョジオーンのHP17
  await inputRemainHP(driver, op, '17');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP121
  await inputRemainHP(driver, me, '121');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのデカハンマー
  await tapMove(driver, op, 'デカハンマー', true);
  // キョジオーンのHP48
  await inputRemainHP(driver, op, '48');
  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // キョジオーンのHP10
  await inputRemainHP(driver, op, '10');
  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP114
  await inputRemainHP(driver, me, '114');
  // デカヌチャンひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // キョジオーンのHP52
  await inputRemainHP(driver, op, '52');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // イルカマンのHP50
  await inputRemainHP(driver, me, '50');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーン->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // ボーマンダのHP130
  await inputRemainHP(driver, op, '130');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キョジオーン戦4
Future<void> test8_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうキョジオーン戦4',
    ownPartyname: '8もこオーン',
    opponentName: 'Pega',
    pokemon1: 'キョジオーン',
    pokemon2: 'ドラパルト',
    pokemon3: 'キノガッサ',
    pokemon4: 'ギャラドス',
    pokemon5: 'ミミズズ',
    pokemon6: 'サーフゴー',
    sex1: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこアルマ/',
      ownPokemon2: 'もこオーン/',
      ownPokemon3: 'もこいかくマンダ/',
      opponentPokemon: 'ミミズズ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ミミズズ->キョジオーンに交代
  await changePokemon(driver, op, 'キョジオーン', true);
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // キョジオーンのHP85
  await inputRemainHP(driver, me, '85');
  // キョジオーンのたべのこし
  await addEffect(driver, 2, PlayerType.opponent, 'たべのこし');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // キョジオーンのHP40
  await inputRemainHP(driver, me, '40');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', true);
  // グレンアルマのHP82
  await inputRemainHP(driver, op, '82');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのまもる
  await tapMove(driver, op, 'まもる', true);
  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // キョジオーンのHP46
  await inputRemainHP(driver, me, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // グレンアルマのエナジーボール
  await tapMove(driver, me, 'エナジーボール', false);
  // キョジオーンのHP30
  await inputRemainHP(driver, me, '30');
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP80
  await inputRemainHP(driver, op, '80');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // キョジオーンのHP40
  await inputRemainHP(driver, me, '40');
  // キョジオーンのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // グレンアルマ->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', true);
  // キョジオーンのまもる
  await tapMove(driver, op, 'まもる', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのテラスタル
  await inputTerastal(driver, me, '');
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP104
  await inputRemainHP(driver, me, '104');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', false);
  // キョジオーンのHP89
  await inputRemainHP(driver, op, '89');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのまもる
  await tapMove(driver, op, 'まもる', false);
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // キョジオーンのHP75
  await inputRemainHP(driver, me, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP100
  await inputRemainHP(driver, op, '100');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // キョジオーンのHP95
  await inputRemainHP(driver, me, '95');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのじこさいせい
  await tapMove(driver, me, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP153
  await inputRemainHP(driver, me, '153');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', false);
  // キョジオーンのHP139
  await inputRemainHP(driver, op, '139');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // キョジオーンのHP85
  await inputRemainHP(driver, op, '85');
  // キョジオーンのとおせんぼう
  await tapMove(driver, me, 'とおせんぼう', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // キョジオーンのHP48
  await inputRemainHP(driver, me, '48');
  // キョジオーンのしおづけ
  await tapMove(driver, op, 'しおづけ', false);
  // キョジオーンのHP97
  await inputRemainHP(driver, op, '97');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // キョジオーンのHP0
  await inputRemainHP(driver, me, '0');
  // キョジオーンひんし->ミミズズに交代
  await changePokemon(driver, op, 'ミミズズ', false);
  // パラメータ編集
  await editPokemonState(driver, 'キョジオーン/あなた', '160', null, null);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ミミズズのしっぽきり
  await tapMove(driver, op, 'しっぽきり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ミミズズのHP50
  await inputRemainHP(driver, op, '50');
  // ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', false);
  // ミミズズのオボンのみ
  // TODO:ミミズズを対象にしたオボンのみが無い
  await addEffect(driver, 1, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ギャラドスのいかく
  await addEffect(driver, 2, op, 'いかく');
  await driver.tap(find.text('OK'));
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // キョジオーンのHP57
  await inputRemainHP(driver, me, '57');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, op, 'たきのぼり', true);
  // キョジオーンのHP0
  await inputRemainHP(driver, op, '0');
  // キョジオーンひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ギャラドスのこおりのキバ
  await tapMove(driver, op, 'こおりのキバ', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, op, 'たきのぼり', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');

  // 相手の勝利
  await testExistEffect(driver, 'Pegaの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミガルーサ戦1
Future<void> test9_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミガルーサ戦1',
    ownPartyname: '9もこルーサ',
    opponentName: 'なぴか',
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
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこルーサ/',
      ownPokemon3: 'もこロローム/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // ミガルーサに交代
  await changePokemon(driver, me, 'ミガルーサ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのむしのさざめき
  await tapMove(driver, op, 'むしのさざめき', true);
  // ミガルーサのHP0
  await inputRemainHP(driver, op, '0');
  // ミガルーサひんし->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);
  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミガルーサ戦2
Future<void> test9_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミガルーサ戦2',
    ownPartyname: '9もこルーサ',
    opponentName: 'なぴか',
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
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこルーサ/',
      ownPokemon3: 'もこネズミ/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのねっぷう
  await tapMove(driver, op, 'ねっぷう', true);
  // 外れる
  await tapHit(driver, op);
  // ミミズズのHP177
  await inputRemainHP(driver, op, '');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ウルガモスのHP30
  await inputRemainHP(driver, me, '30');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->ブロロロームに交代
  await changePokemon(driver, op, 'ブロロローム', true);
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ブロロロームのHP95
  await inputRemainHP(driver, me, '95');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのギアチェンジ
  await tapMove(driver, op, 'ギアチェンジ', true);
  // ミミズズのじしん
  await tapMove(driver, me, 'じしん', false);
  // ブロロロームのHP50
  await inputRemainHP(driver, me, '50');
  // TODO:じしんをシュカのみで耐えることできず。(候補になかった)
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのホイールスピン
  await tapMove(driver, op, 'ホイールスピン', true);
  // ミミズズのHP132
  await inputRemainHP(driver, op, '132');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP43
  await inputRemainHP(driver, me, '43');
  // ミガルーサに交代
  await changePokemon(driver, me, 'ミガルーサ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのみをけずる
  await tapMove(driver, me, 'みをけずる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミガルーサのHP83
  await inputRemainHP(driver, me, '83');
  // ブロロロームのどくづき
  await tapMove(driver, op, 'どくづき', true);
  // みがわりは消える
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  await inputRemainHP(driver, op, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのアクアカッター
  await tapMove(driver, me, 'アクアカッター', false);
  // ブロロロームのHP0
  await inputRemainHP(driver, me, '0');
  // ブロロロームひんし->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', false);
  // トドロクツキのこだいかっせい
  await addEffect(driver, 2, PlayerType.opponent, 'こだいかっせい');
  // こうげきがあがる
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('こうげき'));
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのテラスタル
  await inputTerastal(driver, me, '');
  // トドロクツキのテラスタル
  await inputTerastal(driver, op, 'あく');
  // ミガルーサのアクアカッター
  await tapMove(driver, me, 'アクアカッター', false);
  // トドロクツキのHP0
  await inputRemainHP(driver, me, '0');
  // トドロクツキひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのアクアカッター
  await tapMove(driver, me, 'アクアカッター', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミガルーサ戦3
Future<void> test9_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミガルーサ戦3',
    ownPartyname: '9もこルーサ2',
    opponentName: 'アカネ',
    pokemon1: 'サケブシッポ',
    pokemon2: 'ウルガモス',
    pokemon3: 'ハバタクカミ',
    pokemon4: 'キノガッサ',
    pokemon5: 'トリトドン',
    pokemon6: 'パルシェン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこネズミ/',
      ownPokemon3: 'もこルーサ/',
      opponentPokemon: 'サケブシッポ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // サケブシッポのこだいかっせい
  await addEffect(driver, 0, PlayerType.opponent, 'こだいかっせい');
  // すばやさが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('すばやさ'));
  await driver.tap(find.text('OK'));
  // サケブシッポのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サケブシッポのHP75
  await inputRemainHP(driver, op, '75');
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // サケブシッポのアンコール
  await tapMove(driver, op, 'アンコール', true);
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  await tapSuccess(driver, me);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミズズ->イッカネズミに交代
  await changePokemon(driver, me, 'イッカネズミ', true);
  // サケブシッポのバトンタッチ
  await tapMove(driver, op, 'バトンタッチ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ハバタクカミに交代
  await changePokemon(driver, op, 'ハバタクカミ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // イッカネズミのHP4
  await inputRemainHP(driver, op, '4');
  // ハバタクカミのいのちのたま
  await addEffect(driver, 1, PlayerType.opponent, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // イッカネズミのタネマシンガン
  await tapMove(driver, me, 'タネマシンガン', false);
  // 3回命中
  await setHitCount(driver, me, 3);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ハバタクカミのHP78
  await inputRemainHP(driver, me, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのマジカルフレイム
  await tapMove(driver, op, 'マジカルフレイム', true);
  // イッカネズミのHP0
  await inputRemainHP(driver, op, '0');
  // イッカネズミひんし->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ハバタクカミのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのマジカルフレイム
  await tapMove(driver, op, 'マジカルフレイム', false);
  // ミミズズのHP47
  await inputRemainHP(driver, op, '47');
  // ミミズズのがんせきふうじ
  await tapMove(driver, me, 'がんせきふうじ', false);
  // ハバタクカミのHP30
  await inputRemainHP(driver, me, '30');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのマジカルフレイム
  await tapMove(driver, op, 'マジカルフレイム', false);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->ミガルーサに交代
  await changePokemon(driver, me, 'ミガルーサ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのテラスタル
  await inputTerastal(driver, me, '');
  // ハバタクカミのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ミガルーサのHP76
  await inputRemainHP(driver, op, '76');
  // ミガルーサのみをけずる
  await tapMove(driver, me, 'みをけずる', false);
  await tapSuccess(driver, me);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ハバタクカミのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', false);
  // ミガルーサのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'アカネの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ミガルーサ戦4
Future<void> test9_4(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうミガルーサ戦4',
    ownPartyname: '9もこルーサ3',
    opponentName: 'ナオキ',
    pokemon1: 'パオジアン',
    pokemon2: 'タイカイデン',
    pokemon3: 'ヘイラッシャ',
    pokemon4: 'ガブリアス',
    pokemon5: 'セグレイブ',
    pokemon6: 'サーフゴー',
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこルーサ/',
      ownPokemon3: 'もこヘル/',
      opponentPokemon: 'ヘイラッシャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // ミガルーサに交代
  await changePokemon(driver, me, 'ミガルーサ', false);
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ミガルーサのHP166
  await inputRemainHP(driver, op, '');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ヘイラッシャ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ミガルーサのみをけずる
  await tapMove(driver, me, 'みをけずる', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミガルーサのHP83
  await inputRemainHP(driver, me, '83');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのテラスタル
  await inputTerastal(driver, me, '');
  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // ミガルーサのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // ヘイラッシャのHP75
  await inputRemainHP(driver, me, '75');
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // ミガルーサのHP83
  await inputRemainHP(driver, op, '');
  // ヘイラッシャのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // ヘイラッシャのHP50
  await inputRemainHP(driver, me, '50');
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ミガルーサのHP26
  await inputRemainHP(driver, op, '26');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミガルーサのサイコカッター
  await tapMove(driver, me, 'サイコカッター', false);
  // ヘイラッシャのHP30
  await inputRemainHP(driver, me, '30');
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ミガルーサのHP0
  await inputRemainHP(driver, op, '0');
  // ミガルーサひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // ミガルーサひんし->ミミズズに交代
  await changePokemon(driver, me, 'ミミズズ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ミミズズのじしん
  await tapMove(driver, me, 'じしん', false);
  // ヘイラッシャのHP20
  await inputRemainHP(driver, me, '20');
  // ヘイラッシャのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // 急所に命中
  await tapCritical(driver, op);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // ヘイラッシャひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // ヘルガーのHP1
  await inputRemainHP(driver, op, '1');
  // ヘルガーのきあいのタスキ
  await addEffect(driver, 1, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ガブリアスのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ヘルガーのほうふく
  await tapMove(driver, me, 'ほうふく', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスのさめはだ
  await addEffect(driver, 4, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リククラゲ戦1
Future<void> test10_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // TODO: トリックの入力欄キツキツ
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうリククラゲ戦1',
    ownPartyname: '10もこリククラゲ',
    opponentName: 'たるたる',
    pokemon1: 'ガブリアス',
    pokemon2: 'カバルドン',
    pokemon3: 'ファイアロー',
    pokemon4: 'ジバコイル',
    pokemon5: 'マリルリ',
    pokemon6: 'サーフゴー',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリククラゲ/',
      ownPokemon2: 'もこルリ2/',
      ownPokemon3: 'もこフィア/',
      opponentPokemon: 'カバルドン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // カバルドンのすなおこし
  await addEffect(driver, 0, PlayerType.opponent, 'すなおこし');
  await driver.tap(find.text('OK'));
  // カバルドンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // カバルドンのHP55
  await inputRemainHP(driver, me, '55');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '');
  // カバルドンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // カバルドンのHP2
  await inputRemainHP(driver, me, '2');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '');
  // カバルドンのオボンのみ
  await addEffect(driver, 1, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // カバルドンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // カバルドンのHP0
  await inputRemainHP(driver, me, '0');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '');
  // カバルドンひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのほのおのキバ
  await tapMove(driver, op, 'ほのおのキバ', true);
  // リククラゲのHP71
  await inputRemainHP(driver, op, '71');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ガブリアスはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('143');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのテラスタル
  await inputTerastal(driver, me, '');
  // ガブリアスのほのおのキバ
  await tapMove(driver, op, 'ほのおのキバ', false);
  // リククラゲのHP115
  await inputRemainHP(driver, op, '115');
  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ガブリアスのHP60
  await inputRemainHP(driver, me, '60');
  // リククラゲのHP152
  await inputRemainHP(driver, me, '152');
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('178');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのほのおのキバ
  await tapMove(driver, op, 'ほのおのキバ', false);
  // 外れる
  await tapHit(driver, op);
  // リククラゲのHP178
  await inputRemainHP(driver, op, '');
  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ガブリアスのHP20
  await inputRemainHP(driver, me, '20');
  // リククラゲのHP187
  await inputRemainHP(driver, me, '187');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのほのおのキバ
  await tapMove(driver, op, 'ほのおのキバ', false);
  // リククラゲのHP158
  await inputRemainHP(driver, op, '158');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('174');
  await driver.tap(find.text('OK'));
  // ガブリアスひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP80
  await inputRemainHP(driver, me, '80');
  // サーフゴーのトリック
  await tapMove(driver, op, 'トリック', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // リククラゲはこだわりメガネを入手する
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりメガネ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりメガネ')));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // サーフゴーのHP40
  await inputRemainHP(driver, me, '40');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // サーフゴーはとくぼうが下がった
  await driver.tap(find.text('サーフゴーはとくぼうが下がった'));
  // リククラゲのHP90
  await inputRemainHP(driver, op, '90');
  // 次のターンへ
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

/// リククラゲ戦2
Future<void> test10_2(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうリククラゲ戦2',
    ownPartyname: '10もこリククラゲ',
    opponentName: 'ナー',
    pokemon1: 'ミミッキュ',
    pokemon2: 'ギャラドス',
    pokemon3: 'ニンフィア',
    pokemon4: 'パオジアン',
    pokemon5: 'テツノドクガ',
    pokemon6: 'キョジオーン',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリククラゲ/',
      ownPokemon2: 'もこルリ2/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'テツノドクガ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // テツノドクガのクォークチャージ
  await addEffect(driver, 0, op, 'クォークチャージ');
  // とくこうが高まった
  await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));
  await driver.tap(find.text('とくこう'));
  await driver.tap(find.text('OK'));
  // テツノドクガのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // リククラゲのテラスタル
  await inputTerastal(driver, me, '');
  // テツノドクガのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // リククラゲのHP142
  await inputRemainHP(driver, op, '142');
  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // テツノドクガのHP90
  await inputRemainHP(driver, me, '90');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // テツノドクガのエナジーボール
  await tapMove(driver, op, 'エナジーボール', true);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // リククラゲひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リククラゲ戦3
Future<void> test10_3(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
  int turnNum = 0;
  await driver.waitForTappable(find.byType('FloatingActionButton'));
  // 追加ボタン(+)タップ
  await driver.tap(find.byType('FloatingActionButton'));
  await testExistAnyWidgets(
      find.byValueKey('BattleBasicListViewBattleName'), driver);
  // 基本情報を入力
  await inputBattleBasicInfo(
    driver,
    battleName: 'もこうリククラゲ戦3',
    ownPartyname: '10もこリククラゲ',
    opponentName: 'ヴァロル',
    pokemon1: 'リキキリン',
    pokemon2: 'ウルガモス',
    pokemon3: 'アーマーガア',
    pokemon4: 'トドロクツキ',
    pokemon5: 'キノガッサ',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリククラゲ/',
      ownPokemon2: 'もこルリ2/',
      ownPokemon3: 'もこオーン/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // リククラゲのHP85
  await inputRemainHP(driver, op, '85');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモスはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('151');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', false);
  // マリルリのHP162
  await inputRemainHP(driver, op, '162');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('182');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->リキキリンに交代
  await changePokemon(driver, op, 'リキキリン', true);
  // マリルリのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // 外れる
  await tapHit(driver, me);
  // リキキリンのとくせいがテイルアーマーと判明
  await editPokemonState(driver, 'リキキリン/ヴァロル', null, 'テイルアーマー', null);
  // リキキリンのHP100
  await inputRemainHP(driver, me, '');
  // リキキリンのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // マリルリのHP10
  await inputRemainHP(driver, op, '10');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リキキリンのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->リククラゲに交代
  await changePokemon(driver, me, 'リククラゲ', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リキキリンのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // リキキリンのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', false);
  // リククラゲのHP71
  await inputRemainHP(driver, op, '71');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リキキリンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('95');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // 急所に命中
  await tapCritical(driver, me);
  // リキキリンのHP40
  await inputRemainHP(driver, me, '40');
  // リククラゲのHP139
  await inputRemainHP(driver, me, '139');
  // リキキリンはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('163');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リキキリン->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // リククラゲのギガドレイン
  await tapMove(driver, me, 'ギガドレイン', false);
  // ウルガモスのHP60
  await inputRemainHP(driver, me, '60');
  // リククラゲのHP168
  await inputRemainHP(driver, me, '168');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', false);
  // リククラゲのHP52
  await inputRemainHP(driver, op, '52');
  // リククラゲのキノコのほうし
  await tapMove(driver, me, 'キノコのほうし', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモスはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのやどりぎのタネ
  await tapMove(driver, me, 'やどりぎのタネ', false);
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('72');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リククラゲのテラスタル
  await inputTerastal(driver, me, '');
  // ウルガモスはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // ウルガモスのHP30
  await inputRemainHP(driver, me, '30');
  // やどりぎのタネダメージ編集
  await tapEffect(driver, 'やどりぎのタネダメージ');
  await driver.tap(find.byValueKey('DamageIndicateTextField2'));
  await driver.enterText('92');
  await driver.tap(find.text('OK'));
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->トドロクツキに交代
  await changePokemon(driver, op, 'トドロクツキ', true);
  // ウルガモスのこだいかっせい
  await addEffect(driver, 1, op, 'こだいかっせい');
  await driver.tap(find.text('OK'));
  // リククラゲのだいちのちから
  await tapMove(driver, me, 'だいちのちから', false);
  // トドロクツキのHP80
  await inputRemainHP(driver, me, '80');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのスケイルショット
  await tapMove(driver, op, 'スケイルショット', true);
  // 2回命中
  await setHitCount(driver, op, 2);
  // リククラゲのHP0
  await inputRemainHP(driver, op, '0');
  // リククラゲひんし->キョジオーンに交代
  await changePokemon(driver, me, 'キョジオーン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのしねんのずつき
  await tapMove(driver, op, 'しねんのずつき', true);
  // 外れる
  await tapHit(driver, op);
  // キョジオーンのHP207
  await inputRemainHP(driver, op, '');
  // キョジオーンののろい
  await tapMove(driver, me, 'のろい', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, op, 'じごくづき', true);
  // キョジオーンのHP167
  await inputRemainHP(driver, op, '167');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // トドロクツキのHP30
  await inputRemainHP(driver, me, '30');
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // トドロクツキのじごくづき
  await tapMove(driver, op, 'じごくづき', false);
  // キョジオーンのHP136
  await inputRemainHP(driver, op, '136');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // トドロクツキのHP0
  await inputRemainHP(driver, me, '0');
  // トドロクツキひんし->リキキリンに交代
  await changePokemon(driver, op, 'リキキリン', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // リキキリンのくさむすび
  await tapMove(driver, op, 'くさむすび', true);
  // キョジオーンのHP24
  await inputRemainHP(driver, op, '24');
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // リキキリンのHP5
  await inputRemainHP(driver, me, '5');
  // リキキリンひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // 次のターンへ
  await goTurnPage(driver, turnNum++);

  // ウルガモスはねむっている
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // キョジオーンのしおづけ
  await tapMove(driver, me, 'しおづけ', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// リククラゲ戦1
Future<void> test10_1(
  FlutterDriver driver,
) async {
  await backBattleTopPage(driver);
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
