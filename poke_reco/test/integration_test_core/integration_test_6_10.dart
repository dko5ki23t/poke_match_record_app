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
  // キョジオーンひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// キョジオーン戦1
Future<void> test8_1(
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
