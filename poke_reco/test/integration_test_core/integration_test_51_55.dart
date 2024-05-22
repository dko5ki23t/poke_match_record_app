import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ブースター戦1
Future<void> test51_1(
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
    battleName: 'もこうブースター戦1',
    ownPartyname: '51もこブースター',
    opponentName: 'minasi',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'ガブリアス',
    pokemon3: 'サーフゴー',
    pokemon4: 'セグレイブ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ドータクン',
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブースター/',
      ownPokemon2: 'もこ炎マリルリ/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ブースターのテラスタル
  await inputTerastal(driver, me, '');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // ブースターのHP72
  await inputRemainHP(driver, op, '72');
  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // ロトムのHP65
  await inputRemainHP(driver, me, '65');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // 外れる
  await tapHit(driver, op);
  // ブースターのHP72
  await inputRemainHP(driver, op, '');
  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ガブリアスのHP1
  await inputRemainHP(driver, me, '1');
  // ガブリアスのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ガブリアスのさめはだ
  await addEffect(driver, 2, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのがんせきふうじ
  await tapMove(driver, op, 'がんせきふうじ', true);
  // ブースターのHP0
  await inputRemainHP(driver, op, '0');
  // ブースターひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ドータクンに交代
  await changePokemon(driver, op, 'ドータクン', true);
  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '90');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', true);
  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // ドータクンのトリック
  await tapMove(driver, op, 'トリック', true);
  await tapMoveNext(driver, op);
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こうこうのしっぽ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こうこうのしっぽ')));
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ドータクンのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '');
  // 外れる
  await tapHit(driver, me);
  // ドータクンのHP90
  await inputRemainHP(driver, me, '');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドータクンのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ドータクンのHP40
  await inputRemainHP(driver, me, '40');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドータクンのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ハラバリーのHP3
  await inputRemainHP(driver, op, '3');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // ドータクンのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP37
  await inputRemainHP(driver, me, '37');
  // ドータクンひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ブースター戦2
Future<void> test51_2(
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
    battleName: 'もこうブースター戦2',
    ownPartyname: '51もこブースター',
    opponentName: 'うっちー',
    pokemon1: 'セグレイブ',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ドドゲザン',
    pokemon4: 'ガブリアス',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ラウドボーン',
    sex1: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこうトカゲ/',
      ownPokemon2: 'もこブースター/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // モトトカゲのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapMoveNext(driver, me);
  // モトトカゲのHP73
  await inputRemainHP(driver, me, '73');
  // ブースターに交代
  await changePokemon(driver, me, 'ブースター', false);
  // TODO: みがわりが「状態」欄に現れない
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // ブースターのHP141
  await inputRemainHP(driver, op, '');
  // ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // TODO: ミミッキュに変わってない
  // ターン2へ
  await goTurnPage(driver, turnNum++);
  // TODO:かえんだまが発動してまう

  // ミミッキュ->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ブースターのテラスタル
  await inputTerastal(driver, me, '');
  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // ロトムのHP75
  await inputRemainHP(driver, me, '75');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ブースターのフレアドライブ
  await tapMove(driver, me, 'フレアドライブ', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ブースターのHP87
  await inputRemainHP(driver, me, '87');
  await tapMoveNext(driver, me);
  // ミミッキュひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ブースターのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // ドドゲザンのHP95
  await inputRemainHP(driver, me, '95');
  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 外れる
  await tapHit(driver, op);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // ブースターのHP117
  await inputRemainHP(driver, op, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ブースターのフレアドライブ
  await tapMove(driver, me, 'フレアドライブ', false);
  // ドドゲザンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ブースター戦3
Future<void> test51_3(
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
    battleName: 'もこうブースター戦',
    ownPartyname: '51もこブースター',
    opponentName: 'KA',
    pokemon1: 'ドドゲザン',
    pokemon2: 'キノガッサ',
    pokemon3: 'デカヌチャン',
    pokemon4: 'マスカーニャ',
    pokemon5: 'サーフゴー',
    pokemon6: 'ミミッキュ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブースター/',
      ownPokemon2: 'もこバリー/',
      ownPokemon3: 'もこカイリュー/',
      opponentPokemon: 'デカヌチャン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのかたやぶり
  await addEffect(driver, 0, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // デカヌチャンのHP95
  await inputRemainHP(driver, me, '95');
  // デカヌチャンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ブースターのフレアドライブ
  await tapMove(driver, me, 'フレアドライブ', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // ブースターのHP86
  await inputRemainHP(driver, me, '86');
  await tapMoveNext(driver, me);
  // デカヌチャンひんし->キノガッサに交代
  // なぜか選べない
  await changePokemon(driver, op, 'キノガッサ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', true);
  // ブースターのHP0
  await inputRemainHP(driver, op, '0');
  // ブースターひんし->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのテラスタル
  await inputTerastal(driver, me, '');
  // キノガッサのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  await tapSuccess(driver, op);
  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // キノガッサのHP40
  await inputRemainHP(driver, me, '40');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // キノガッサのマッハパンチ
  await tapMove(driver, op, 'マッハパンチ', false);
  // ハラバリーのHP126
  await inputRemainHP(driver, op, '126');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // キノガッサのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP151
  await inputRemainHP(driver, me, '151');
  // キノガッサひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('あく'));
  await driver.tap(find.text('OK'));
  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ハラバリーのHP22
  await inputRemainHP(driver, op, '22');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('じしゃく');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('じしゃく')));
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP100
  await inputRemainHP(driver, me, '100');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ブースター戦4
Future<void> test51_4(
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
    battleName: 'もこうブースター戦4',
    ownPartyname: '51もこブースター2',
    opponentName: 'ふゆ',
    pokemon1: 'セグレイブ',
    pokemon2: 'ドオー',
    pokemon3: 'ハッサム',
    pokemon4: 'ブラッキー',
    pokemon5: 'ギャラドス',
    pokemon6: 'ラッキー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこバリー/',
      ownPokemon2: 'もこブースター/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ドオーに交代
  await changePokemon(driver, op, 'ドオー', true);
  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // セグレイブのちょすい
  await addEffect(driver, 2, op, 'ちょすい');
  await driver.tap(find.text('OK'));
  await tapSuccess(driver, me);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハラバリー->ブースターに交代
  await changePokemon(driver, me, 'ブースター', true);
  // ドオーのどくどく
  await tapMove(driver, op, 'どくどく', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドオー->ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', true);
  // ドオーのいかく
  await addEffect(driver, 1, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ブースターのテラスタル
  await inputTerastal(driver, me, '');
  // ブースターのくさわけ
  await tapMove(driver, me, 'くさわけ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ギャラドスのHP65
  await inputRemainHP(driver, me, '65');
  // ドオーのゴツゴツメット
  await addEffect(driver, 4, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // ギャラドスひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ブースター->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', true);
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ハラバリーのHP170
  await inputRemainHP(driver, op, '170');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ドオーに交代
  await changePokemon(driver, op, 'ドオー', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // 外れる
  await tapHit(driver, me);
  // ドオーのHP100
  await inputRemainHP(driver, me, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ドオーのHP99
  await inputRemainHP(driver, me, '99');
  // ドオーのじしん
  await tapMove(driver, op, 'じしん', true);
  // ハラバリーのHP66
  await inputRemainHP(driver, op, '66');
  // ドオーのくろいヘドロ
  await addEffect(driver, 3, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ドオーのHP98
  await inputRemainHP(driver, me, '98');
  // ドオーのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  await tapSuccess(driver, me);
  // ドオーのじしん
  await tapMove(driver, op, 'じしん', false);
  // ハラバリーのHP0
  await inputRemainHP(driver, op, '0');
  // ハラバリーひんし->ブースターに交代
  await changePokemon(driver, me, 'ブースター', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ブースターのからげんき
  await tapMove(driver, me, 'からげんき', false);
  // ドオーのHP0
  await inputRemainHP(driver, me, '0');
  // ドオーひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ブースターのでんこうせっか
  await tapMove(driver, me, 'でんこうせっか', false);
  // セグレイブのHP80
  await inputRemainHP(driver, me, '80');
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ブースターのHP0
  await inputRemainHP(driver, op, '0');
  // ブースターひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'エスパー');
  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // マリルリのHP89
  await inputRemainHP(driver, op, '89');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // セグレイブのHP15
  await inputRemainHP(driver, me, '15');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// デカヌチャン戦1
Future<void> test52_1(
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
    battleName: 'もこうデカヌチャン戦1',
    ownPartyname: '52もこヌチャン',
    opponentName: 'しょう',
    pokemon1: 'カイリュー',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ウルガモス',
    pokemon4: 'ブラッキー',
    pokemon5: 'デカヌチャン',
    pokemon6: 'サーフゴー',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'カヌぎゃく/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこギャラドス/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのテラスタル
  await inputTerastal(driver, me, '');
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // 外れる
  await tapHit(driver, op);
  // デカヌチャンのHP161
  await inputRemainHP(driver, op, '');
  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP20
  await inputRemainHP(driver, me, '20');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトム->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // ウルガモスのHP40
  await inputRemainHP(driver, me, '40');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', true);
  // ウルガモスのギガドレイン
  await tapMove(driver, op, 'ギガドレイン', true);
  // ギャラドスのHP120
  await inputRemainHP(driver, op, '120');
  // ウルガモスのHP70
  await inputRemainHP(driver, op, '70');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのギガドレイン
  await tapMove(driver, op, 'ギガドレイン', false);
  // ギャラドスのHP43
  await inputRemainHP(driver, op, '43');
  // ウルガモスのHP85
  await inputRemainHP(driver, op, '85');
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ギャラドスのたきのぼり
  await tapMove(driver, me, 'たきのぼり', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, op, '0');
  // サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ギャラドスひんし->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // 外れる
  await tapHit(driver, me);
  // サーフゴーのHP100
  await inputRemainHP(driver, me, '');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // デカヌチャンのHP63
  await inputRemainHP(driver, op, '63');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // サーフゴーのHP35
  await inputRemainHP(driver, me, '35');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, op, '0');
  // デカヌチャンひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // パーモットのでんこうそうげき
  await tapMove(driver, me, 'でんこうそうげき', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // 外れる
  await tapHit(driver, op);
  // パーモットのHP150
  await inputRemainHP(driver, op, '');
  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// デカヌチャン戦2
Future<void> test52_2(
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
    battleName: 'もこうデカヌチャン戦2',
    ownPartyname: '52もこヌチャン',
    opponentName: 'リュウ',
    pokemon1: 'デカヌチャン',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ラウドボーン',
    pokemon4: 'マスカーニャ',
    pokemon5: 'キラフロル',
    pokemon6: 'カイリュー',
    sex1: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'カヌぎゃく/',
      ownPokemon2: 'もこギャラドス/',
      ownPokemon3: 'もこパモ/',
      opponentPokemon: 'デカヌチャン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのかたやぶり
  await addEffect(driver, 1, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // デカヌチャン->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // ロトムのHP85
  await inputRemainHP(driver, me, '85');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのテラスタル
  await inputTerastal(driver, me, '');
  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.byValueKey('TypeDropdownButton'));
  await driver.tap(find.text('くさ'));
  await driver.tap(find.text('OK'));
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // デカヌチャンのHP0
  await inputRemainHP(driver, op, '0');
  // デカヌチャンひんし->パーモットに交代
  await changePokemon(driver, me, 'パーモット', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', false);
  // パーモットのHP18
  await inputRemainHP(driver, op, '18');
  // パーモットのほっぺすりすり
  await tapMove(driver, me, 'ほっぺすりすり', false);
  // マスカーニャのHP95
  await inputRemainHP(driver, me, '95');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // パーモットのさいきのいのり
  await tapMove(driver, me, 'さいきのいのり', false);
  // デカヌチャンを復活
  await changePokemon(driver, me, 'デカヌチャン', false);
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', false);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', true);
  // デカヌチャンのデカハンマー
  await tapMove(driver, op, 'デカハンマー', true);
  // ギャラドスのHP157
  await inputRemainHP(driver, op, '157');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ギャラドスのHP130
  await inputRemainHP(driver, op, '130');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('オボンのみ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('オボンのみ')));
  // ギャラドスのじしん
  await tapMove(driver, me, 'じしん', false);
  // デカヌチャンのHP10
  await inputRemainHP(driver, me, '10');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ギャラドスのHP96
  await inputRemainHP(driver, op, '96');
  // ギャラドスのたきのぼり
  await tapMove(driver, me, 'たきのぼり', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// デカヌチャン戦3
Future<void> test52_3(
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
    battleName: 'もこうデカヌチャン戦3',
    ownPartyname: '52もこヌチャン2',
    opponentName: 'はやさ',
    pokemon1: 'サーフゴー',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ガブリアス',
    pokemon4: 'ウルガモス',
    pokemon5: 'ドドゲザン',
    pokemon6: 'カイリュー',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'カヌぎゃく/',
      ownPokemon2: 'もこギャラドス/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのテラスタル
  await inputTerastal(driver, me, '');
  // ロトムのトリック
  await tapMove(driver, op, 'トリック', true);
  await tapMoveNext(driver, op);
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりスカーフ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりスカーフ')));
  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP35
  await inputRemainHP(driver, me, '35');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', true);
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ギャラドス->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', true);
  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // デカヌチャンのHP23
  await inputRemainHP(driver, op, '23');
  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // カイリューのHP50
  await inputRemainHP(driver, me, '50');
  // カイリューのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', true);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ギャラドスのHP88
  await inputRemainHP(driver, op, '88');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await tapMoveNext(driver, op);
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ギャラドス->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', true);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, op, '0');
  // デカヌチャンひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ロトムのHP82
  await inputRemainHP(driver, op, '82');
  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', false);
  // カイリューのHP80
  await inputRemainHP(driver, me, '80');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ロトムのHP4
  await inputRemainHP(driver, op, '4');
  // ロトムのほうでん
  await tapMove(driver, me, 'ほうでん', false);
  // カイリューのHP25
  await inputRemainHP(driver, me, '25');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ロトムのHP0
  await inputRemainHP(driver, op, '0');
  // ロトムひんし->ギャラドスに交代
  await changePokemon(driver, me, 'ギャラドス', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await tapMoveNext(driver, op);
  // カイリューのHP90
  await inputRemainHP(driver, op, '90');
  // ギャラドスのちょうはつ
  await tapMove(driver, me, 'ちょうはつ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ギャラドスのHP71
  await inputRemainHP(driver, op, '71');
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ギャラドスのHP10
  await inputRemainHP(driver, op, '10');
  // ギャラドスのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', true);
  // ギャラドスのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'はやさの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// デカヌチャン戦4
Future<void> test52_4(
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
    battleName: 'もこうデカヌチャン戦4',
    ownPartyname: '52もこヌチャン',
    opponentName: 'JIRO',
    pokemon1: 'ミミッキュ',
    pokemon2: 'デカヌチャン',
    pokemon3: 'セグレイブ',
    pokemon4: 'カイリュー',
    pokemon5: 'ロトム(ウォッシュロトム)',
    pokemon6: 'サーフゴー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'カヌぎゃく/',
      ownPokemon2: 'もこパモ/',
      ownPokemon3: 'もこニンフィア3/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのテラスタル
  await inputTerastal(driver, me, '');
  // デカヌチャンのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ロトムのHP2
  await inputRemainHP(driver, me, '2');
  // ロトムのトリック
  await tapMove(driver, op, 'トリック', true);
  await tapMoveNext(driver, op);
  await driver.tap(find.byValueKey('SelectItemTextFieldOpponent'));
  await driver.enterText('こだわりメガネ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('こだわりメガネ')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトム->デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', true);
  // ロトムのかたやぶり
  await addEffect(driver, 1, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // デカヌチャンのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 急所に命中
  await tapCritical(driver, me);
  // デカヌチャンのHP80
  await inputRemainHP(driver, me, '80');
  // デカヌチャンはこうげきが下がった
  await driver.tap(find.text('デカヌチャンはこうげきが下がった'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->パーモットに交代
  await changePokemon(driver, me, 'パーモット', true);
  // デカヌチャンのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // デカヌチャンのHP10
  await inputRemainHP(driver, me, '10');
  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // パーモットのHP118
  await inputRemainHP(driver, op, '118');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // パーモットのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // デカヌチャンひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // パーモットのHP0
  await inputRemainHP(driver, op, '0');
  // パーモットひんし->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // カイリューのHP30
  await inputRemainHP(driver, me, '30');
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャン->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ニンフィアのHP59
  await inputRemainHP(driver, op, '59');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->デカヌチャンに交代
  await changePokemon(driver, me, 'デカヌチャン', false);
  // カイリューひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのデカハンマー
  await tapMove(driver, me, 'デカハンマー', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハリテヤマ戦1
Future<void> test53_1(
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
    battleName: 'もこうハリテヤマ戦1',
    ownPartyname: '53もこテヤマ',
    opponentName: 'ひろしやま',
    pokemon1: 'キラフロル',
    pokemon2: 'サーフゴー',
    pokemon3: 'カイリュー',
    pokemon4: 'コノヨザル',
    pokemon5: 'ケンタロス(パルデアのすがた(かくとう・ほのお))',
    pokemon6: 'ドオー',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこテヤマ/',
      ownPokemon2: 'もこカス/',
      ownPokemon3: 'もこアルマ2/',
      opponentPokemon: 'キラフロル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハリテヤマのねこだまし
  await tapMove(driver, me, 'ねこだまし', false);
  // キラフロルのHP95
  await inputRemainHP(driver, me, '95');
  // キラフロルのどくげしょう
  await addEffect(driver, 1, op, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ハリテヤマのドレインパンチ
  await tapMove(driver, me, 'ドレインパンチ', false);
  // キラフロルのHP30
  await inputRemainHP(driver, me, '30');
  // ハリテヤマのHP221
  await inputRemainHP(driver, me, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハリテヤマのバレットパンチ
  await tapMove(driver, me, 'バレットパンチ', false);
  // キラフロルのHP0
  await inputRemainHP(driver, me, '0');
  // キラフロルひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // ハリテヤマのHP32
  await inputRemainHP(driver, op, '32');
  // ハリテヤマのぶちかまし
  await tapMove(driver, me, 'ぶちかまし', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ドオーに交代
  await changePokemon(driver, op, 'ドオー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハリテヤマのぶちかまし
  await tapMove(driver, me, 'ぶちかまし', false);
  // ドオーのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/*
/// ハリテヤマ戦2
Future<void> test53_2(
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

/// ハリテヤマ戦3
Future<void> test53_3(
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

/// ハリテヤマ戦4
Future<void> test53_4(
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

/// ハリテヤマ戦5
Future<void> test53_5(
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

// テンプレ
/*
/// ハリテヤマ戦1
Future<void> test53_1(
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
