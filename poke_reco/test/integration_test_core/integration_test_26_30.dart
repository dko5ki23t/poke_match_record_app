import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ハラバリー戦1
Future<void> test26_1(
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
    battleName: 'もこうハラバリー戦1',
    ownPartyname: '26もこバリー',
    opponentName: 'tstshm',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ガブリアス',
    pokemon3: 'ウルガモス',
    pokemon4: 'カイリュー',
    pokemon5: 'ミミッキュ',
    pokemon6: 'サーフゴー',
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'ねつじょう/',
      ownPokemon2: 'もこバリー/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // マスカーニャのけたぐり
  await tapMove(driver, op, 'けたぐり', true);
  // ヘルガーのHP13
  await inputRemainHP(driver, op, '13');
  // マスカーニャのHP1
  await inputRemainHP(driver, me, '1');
  // マスカーニャのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 外れる
  await tapHit(driver, op);
  // ヘルガーのHP13
  await inputRemainHP(driver, op, '');
  // ヘルガーのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // マスカーニャひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ヘルガーひんし->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ハラバリーのHP135
  await inputRemainHP(driver, op, '135');
  // でんきにかえるが発動していることを確認
  await testExistEffect(driver, 'でんきにかえる');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // 急所に命中
  await tapCritical(driver, me);
  // サーフゴーのHP25
  await inputRemainHP(driver, me, '25');
  // ハラバリーのHP211
  await inputRemainHP(driver, me, '211');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP75
  await inputRemainHP(driver, op, '75');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // サーフゴーのHP40
  await inputRemainHP(driver, me, '40');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '216');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハラバリー->エルレイドに交代
  await changePokemon(driver, me, 'エルレイド', true);
  // サーフゴーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP90
  await inputRemainHP(driver, op, '90');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのテラスタル
  await inputTerastal(driver, me, '');
  // エルレイドのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // エルレイドのHP92
  await inputRemainHP(driver, op, '92');
  // エルレイドはとくぼうが下がった
  await driver.tap(find.text('エルレイドはとくぼうが下がった'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのつじぎり
  await tapMove(driver, me, 'つじぎり', false);
  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // エルレイドのHP0
  await inputRemainHP(driver, op, '0');
  // 急所に命中
  await tapCritical(driver, op);
  // エルレイドひんし->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ハラバリーのHP80
  await inputRemainHP(driver, op, '80');
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // ハラバリーのHP106
  await inputRemainHP(driver, me, '106');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // ハラバリーのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'tstshmの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハラバリー戦2
Future<void> test26_2(
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
    battleName: 'もこうハラバリー戦2',
    ownPartyname: '26もこバリー2',
    opponentName: 'ラリホー',
    pokemon1: 'オーロンゲ',
    pokemon2: 'アーマーガア',
    pokemon3: 'ドラミドロ',
    pokemon4: 'サーフゴー',
    pokemon5: 'ドドゲザン',
    pokemon6: 'キノガッサ',
    sex2: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこバリー/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこレイド/',
      opponentPokemon: 'ドラミドロ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // ドラミドロのりゅうのはどう
  await tapMove(driver, op, 'りゅうのはどう', true);
  // ハラバリーのHP136
  await inputRemainHP(driver, op, '136');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラミドロ->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // サーフゴーのHP3
  await inputRemainHP(driver, me, '3');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '216');
  // ハラバリーのHP214
  await inputRemainHP(driver, me, '214');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // ハラバリーのHP97
  await inputRemainHP(driver, op, '97');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP120
  await inputRemainHP(driver, me, '120');
  // サーフゴーひんし->ドラミドロに交代
  await changePokemon(driver, op, 'ドラミドロ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラミドロのテラスタル
  await inputTerastal(driver, op, 'みず');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // ドラミドロのHP40
  await inputRemainHP(driver, me, '40');
  // ハラバリーのHP155
  await inputRemainHP(driver, me, '155');
  // ドラミドロのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // 外れる
  await tapHit(driver, op);
  // ハラバリーのHP134
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハラバリー戦3
Future<void> test26_3(
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
    battleName: 'もこうハラバリー戦3',
    ownPartyname: '26もこバリー2',
    opponentName: 'クライスラー',
    pokemon1: 'イルカマン',
    pokemon2: 'ガブリアス',
    pokemon3: 'ドドゲザン',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ハッサム',
    pokemon6: 'ウルガモス',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこバリー/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのテラスタル
  await inputTerastal(driver, me, '');
  // ガブリアス->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // ウルガモスのHP65
  await inputRemainHP(driver, me, '65');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '');
  // ガブリアスのたべのこし
  await addEffect(driver, 4, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハラバリー->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ヤドキングのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', true);
  // ハルクジラのはらだいこ
  await tapMove(driver, me, 'はらだいこ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのテラスタル
  await inputTerastal(driver, op, 'みず');
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', true);
  // ハルクジラのHP13
  await inputRemainHP(driver, op, '13');
  // ハルクジラのじしん
  await tapMove(driver, me, 'じしん', false);
  // イルカマンのHP3
  await inputRemainHP(driver, me, '3');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラ->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', true);
  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // ヤドキングのHP115
  await inputRemainHP(driver, op, '115');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // イルカマン->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ヤドキングのなみのり
  await tapMove(driver, me, 'なみのり', false);
  // ガブリアスのHP70
  await inputRemainHP(driver, me, '70');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ヤドキング->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ガブリアスのHP65
  await inputRemainHP(driver, me, '65');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ハラバリーのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ウルガモスのHP70
  await inputRemainHP(driver, me, '70');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ハラバリー->ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', true);
  // ハルクジラひんし->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // ハラバリーのHP30
  await inputRemainHP(driver, op, '30');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP90
  await inputRemainHP(driver, me, '90');
  // ガブリアスひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ハラバリーのアシッドボム
  await tapMove(driver, me, 'アシッドボム', false);
  // ウルガモスのHP65
  await inputRemainHP(driver, me, '65');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // ハラバリーのHP0
  await inputRemainHP(driver, op, '0');
  // ハラバリーひんし->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', false);
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ヤドキングのなみのり
  await tapMove(driver, me, 'なみのり', false);
  // ウルガモスのHP1
  await inputRemainHP(driver, me, '1');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', false);
  // ヤドキングのHP93
  await inputRemainHP(driver, op, '93');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // ヤドキングのなみのり
  await tapMove(driver, me, 'なみのり', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // ヤドキングのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'クライスラーの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
  //! TODO: 保存時、引き分けの表示になってしまっている
}

/// ハラバリー戦4
Future<void> test26_4(
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
    battleName: 'もこうハラバリー戦4',
    ownPartyname: '26もこバリー2',
    opponentName: 'もっくん',
    pokemon1: 'イルカマン',
    pokemon2: 'キノガッサ',
    pokemon3: 'サザンドラ',
    pokemon4: 'カバルドン',
    pokemon5: 'ジバコイル',
    pokemon6: 'サーフゴー',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこバリー/',
      ownPokemon2: 'もこヤドキング/',
      ownPokemon3: 'もこハルクジラ2/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // ハラバリーのHP153
  await inputRemainHP(driver, op, '153');
  // カバルドンに交代
  await changePokemon(driver, op, 'カバルドン', false);
  // ハラバリーのみずびたし
  await tapMove(driver, me, 'みずびたし', false);
  // イルカマンのすなおこし
  await addEffect(driver, 2, op, 'すなおこし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // カバルドンのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP216
  await inputRemainHP(driver, me, '216');
  // カバルドンひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのテラスタル
  await inputTerastal(driver, me, '');
  // イルカマンのテラスタル
  await inputTerastal(driver, op, 'みず');
  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // ハラバリーのHP30
  await inputRemainHP(driver, op, '30');
  // イルカマンのHP90
  await inputRemainHP(driver, op, '90');
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // イルカマンのHP0
  await inputRemainHP(driver, me, '0');
  // ハラバリーのHP69
  await inputRemainHP(driver, me, '69');
  // ハラバリーのHP103
  await inputRemainHP(driver, me, '103');
  // イルカマンひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ハラバリーのHP0
  await inputRemainHP(driver, op, '0');
  // ハラバリーひんし->ヤドキングに交代
  await changePokemon(driver, me, 'ヤドキング', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ヤドキングのHP7
  await inputRemainHP(driver, op, '7');
  // ヤドキングのさむいギャグ
  await tapMove(driver, me, 'さむいギャグ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ハルクジラに交代
  await changePokemon(driver, me, 'ハルクジラ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // サザンドラのHP30
  await inputRemainHP(driver, me, '30');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ハルクジラのHP110
  await inputRemainHP(driver, op, '110');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハルクジラのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リングマ戦1
Future<void> test27_1(
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
    battleName: 'もこうリングマ戦1',
    ownPartyname: '27もこリングマ',
    opponentName: 'Koba',
    pokemon1: 'キョジオーン',
    pokemon2: 'オーロンゲ',
    pokemon3: 'カイリュー',
    pokemon4: 'サーフゴー',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリングマ/',
      ownPokemon2: 'もこシャリ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'カイリュー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // リングマのテラスタル
  await inputTerastal(driver, me, '');
  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // 外れる
  await tapHit(driver, op);
  // リングマのHP191
  await inputRemainHP(driver, op, '');
  // リングマののしかかり
  await tapMove(driver, me, 'のしかかり', false);
  // カイリューのHP80
  await inputRemainHP(driver, me, '80');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', true);
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP20
  await inputRemainHP(driver, me, '20');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // リングマのHP65
  await inputRemainHP(driver, op, '65');
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // リングマ->シャリタツに交代
  await changePokemon(driver, me, 'シャリタツ', true);
  // ドラパルトのだいもんじ
  await tapMove(driver, op, 'だいもんじ', true);
  // シャリタツのHP121
  await inputRemainHP(driver, op, '121');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // カイリューのHP40
  await inputRemainHP(driver, me, '40');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // 外れる
  await tapHit(driver, me);
  // カイリューのHP40
  await inputRemainHP(driver, me, '');
  // カイリューのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // シャリタツのHP0
  await inputRemainHP(driver, op, '0');
  // シャリタツひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのげきりん
  await tapMove(driver, op, 'げきりん', false);
  // 外れる
  await tapHit(driver, op);
  // マリルリのHP201
  await inputRemainHP(driver, op, '');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // マリルリのHP126
  await inputRemainHP(driver, op, '126');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リングマ戦2
Future<void> test27_2(
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
    battleName: 'もこうリングマ戦2',
    ownPartyname: '27もこリングマ2',
    opponentName: 'ほうじ',
    pokemon1: 'ミミッキュ',
    pokemon2: 'マスカーニャ',
    pokemon3: 'ジバコイル',
    pokemon4: 'モロバレル',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ボーマンダ',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリングマ2/',
      ownPokemon2: 'もこパトラ/',
      ownPokemon3: 'もこシャリ/',
      opponentPokemon: 'ジバコイル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ジバコイル->ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', true);
  // ジバコイルのいかく
  await addEffect(driver, 1, op, 'いかく');
  await driver.tap(find.text('OK'));
  // リングマのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのドラゴンクロー
  await tapMove(driver, op, 'ドラゴンクロー', true);
  // リングマのHP121
  await inputRemainHP(driver, op, '121');
  // リングマのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, me, '0');
  // ボーマンダひんし->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // リングマののしかかり
  await tapMove(driver, me, 'のしかかり', false);
  // モロバレルのHP40
  await inputRemainHP(driver, me, '40');
  // モロバレルのキノコのほうし
  await tapMove(driver, op, 'キノコのほうし', true);
  // モロバレルのくろいヘドロ
  await addEffect(driver, 2, op, 'くろいヘドロ');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // モロバレルのイカサマ
  await tapMove(driver, op, 'イカサマ', true);
  // リングマのHP31
  await inputRemainHP(driver, op, '31');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // モロバレル->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ジバコイルのほうでん
  await tapMove(driver, op, 'ほうでん', true);
  // リングマのHP0
  await inputRemainHP(driver, op, '0');
  // リングマひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // ジバコイルのほうでん
  await tapMove(driver, op, 'ほうでん', false);
  // クエスパトラのHP87
  await inputRemainHP(driver, op, '87');
  // クエスパトラはしびれてしまった
  await driver.tap(find.text('クエスパトラはしびれてしまった'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのめいそう
  await tapMove(driver, me, 'めいそう', false);
  // ジバコイルのほうでん
  await tapMove(driver, op, 'ほうでん', false);
  // 外れる
  await tapHit(driver, op);
  // クエスパトラのHP87
  await inputRemainHP(driver, op, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのバトンタッチ
  await tapMove(driver, me, 'バトンタッチ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // シャリタツに交代
  await changePokemon(driver, me, 'シャリタツ', false);
  // ジバコイルのほうでん
  await tapMove(driver, op, 'ほうでん', false);
  // シャリタツのHP86
  await inputRemainHP(driver, op, '86');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ジバコイル->モロバレルに交代
  await changePokemon(driver, op, 'モロバレル', true);
  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // モロバレルのHP40
  await inputRemainHP(driver, me, '40');
  // TODO: パラメータ編集により自動で追加されてしまっているが、なくしたい
  // くろいヘドロ編集
  await tapEffect(driver, 'くろいヘドロ');
  await driver.tap(find.text('削除'));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // モロバレルのHP0
  await inputRemainHP(driver, me, '0');
  // モロバレルひんし->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // シャリタツのハイドロポンプ
  await tapMove(driver, me, 'ハイドロポンプ', false);
  // 外れる
  await tapHit(driver, me);
  // ジバコイルのほうでん
  await tapMove(driver, op, 'ほうでん', false);
  // 急所に命中
  await tapCritical(driver, op);
  // シャリタツのHP0
  await inputRemainHP(driver, op, '0');
  // シャリタツひんし->クエスパトラに交代
  await changePokemon(driver, me, 'クエスパトラ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, me, 'ルミナコリジョン', false);
  // ジバコイルのHP80
  await inputRemainHP(driver, me, '80');
  // ジバコイルのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // クエスパトラのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ほうじの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リングマ戦3
Future<void> test27_3(
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
    battleName: 'もこうリングマ戦3',
    ownPartyname: '27もこリングマ2',
    opponentName: 'えいいち',
    pokemon1: 'キラフロル',
    pokemon2: 'サーフゴー',
    pokemon3: 'サザンドラ',
    pokemon4: 'ロトム(ヒートロトム)',
    pokemon5: 'ミミッキュ',
    pokemon6: 'マリルリ',
    sex1: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこリングマ2/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ロトム(ヒートロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // ミミズズのHP7
  await inputRemainHP(driver, op, '7');
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await tapSuccess(driver, me);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトム->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マリルリのばかぢから
  await tapMove(driver, me, 'ばかぢから', false);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // マリルリのHP159
  await inputRemainHP(driver, op, '159');
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->リングマに交代
  await changePokemon(driver, me, 'リングマ', true);
  // サーフゴーのでんじは
  await tapMove(driver, op, 'でんじは', true);
  // サーフゴーのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // サーフゴー->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ヒートロトム)', true);
  // リングマのシャドークロー
  await tapMove(driver, me, 'シャドークロー', false);
  // ロトムのHP30
  await inputRemainHP(driver, me, '30');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ロトムのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', false);
  // リングマのHP119
  await inputRemainHP(driver, op, '119');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ロトムのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', false);
  // リングマのHP85
  await inputRemainHP(driver, op, '85');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ロトムのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', false);
  // リングマのHP63
  await inputRemainHP(driver, op, '63');
  // リングマのシャドークロー
  await tapMove(driver, me, 'シャドークロー', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->サーフゴーに交代
  await changePokemon(driver, op, 'サーフゴー', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // リングマのHP0
  await inputRemainHP(driver, op, '0');
  // リングマひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのでんじは
  await tapMove(driver, op, 'でんじは', false);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP55
  await inputRemainHP(driver, me, '55');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのじこさいせい
  await tapMove(driver, op, 'じこさいせい', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP100
  await inputRemainHP(driver, op, '100');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // サーフゴーのHP50
  await inputRemainHP(driver, me, '50');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// リングマ戦4
Future<void> test27_4(
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
    battleName: 'もこうリングマ戦4',
    ownPartyname: '27もこリングマ',
    opponentName: 'ライト',
    pokemon1: 'ミミッキュ',
    pokemon2: 'サーフゴー',
    pokemon3: 'キラフロル',
    pokemon4: 'ウルガモス',
    pokemon5: 'ドドゲザン',
    pokemon6: 'イルカマン',
    sex1: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリングマ/',
      ownPokemon2: 'もこルリ/',
      ownPokemon3: 'もこシャリ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // リングマのHP113
  await inputRemainHP(driver, op, '113');
  // イルカマンのだっしゅつパック
  await addEffect(driver, 1, op, 'だっしゅつパック');
  // サーフゴーに交代
  await driver.tap(find.byValueKey('ItemEffectSelectPokemon'));
  await driver.tap(find.text('サーフゴー'));
  await driver.tap(find.text('OK'));
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP30
  await inputRemainHP(driver, me, '30');
  // イルカマンのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // リングマのHP31
  await inputRemainHP(driver, op, '31');
  // リングマのじしん
  await tapMove(driver, me, 'じしん', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', true);
  // リングマのHP0
  await inputRemainHP(driver, op, '0');
  // リングマひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのアクロバット
  await tapMove(driver, op, 'アクロバット', true);
  // マリルリのHP108
  await inputRemainHP(driver, op, '108');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 外れる
  await tapHit(driver, me);
  // イルカマンのHP100
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのアクロバット
  await tapMove(driver, op, 'アクロバット', false);
  // マリルリのHP17
  await inputRemainHP(driver, op, '17');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 急所に命中
  await tapCritical(driver, me);
  // イルカマンのHP10
  await inputRemainHP(driver, me, '10');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのジェットパンチ
  await tapMove(driver, op, 'ジェットパンチ', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // マリルリひんし->シャリタツに交代
  await changePokemon(driver, me, 'シャリタツ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのりゅうのはどう
  await tapMove(driver, me, 'りゅうのはどう', false);
  // イルカマンのインファイト
  await tapMove(driver, op, 'インファイト', false);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '16');
  // イルカマンのHP0
  await inputRemainHP(driver, me, '0');
  // イルカマンひんし->ドドゲザンに交代
  await changePokemon(driver, op, 'ドドゲザン', false);
  // ドドゲザンのとくせいがそうだいしょうと判明
  await addEffect(driver, 3, op, 'そうだいしょう');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ドドゲザンのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // 外れる
  await tapHit(driver, op);
  // シャリタツのHP16
  await inputRemainHP(driver, op, '');
  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // シャリタツのわるだくみ
  await tapMove(driver, me, 'わるだくみ', false);
  // ドドゲザンのドゲザン
  await tapMove(driver, op, 'ドゲザン', true);
  // シャリタツのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'ライトの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハカドッグ戦1
Future<void> test28_1(
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
    battleName: 'もこうハカドッグ戦1',
    ownPartyname: '28もこドッグ',
    opponentName: 'あいじょーく',
    pokemon1: 'ルカリオ',
    pokemon2: 'ニンフィア',
    pokemon3: 'ソウブレイズ',
    pokemon4: 'カイリュー',
    pokemon5: 'ロトム(カットロトム)',
    pokemon6: 'ドラパルト',
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこレッグ/',
      ownPokemon2: 'もこドッグ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '1');
  // ドラパルトのきあいのタスキ
  await addEffect(driver, 3, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ドラパルトのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // エクスレッグのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // カイリューのHP90
  await inputRemainHP(driver, me, '90');
  // ハカドッグに交代
  await changePokemon(driver, me, 'ハカドッグ', false);
  // ドラパルトのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->ルカリオに交代
  await changePokemon(driver, op, 'ルカリオ', true);
  // ハカドッグのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 外れる
  await tapHit(driver, me);
  // ルカリオのHP100
  await inputRemainHP(driver, me, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ルカリオのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ハカドッグのHP36
  await inputRemainHP(driver, op, '36');
  // ハカドッグのじだんだ
  await tapMove(driver, me, 'じだんだ', false);
  // ルカリオのHP0
  await inputRemainHP(driver, me, '0');
  // ルカリオひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ハカドッグのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // 外れる
  await tapHit(driver, me);
  // カイリューのHP96
  await inputRemainHP(driver, me, '');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', true);
  // ハカドッグのHP0
  await inputRemainHP(driver, op, '0');
  // ハカドッグひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // カイリューのHP85
  await inputRemainHP(driver, me, '85');
  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', true);
  // エクスレッグのHP0
  await inputRemainHP(driver, op, '0');
  // エクスレッグひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // マリルリのHP32
  await inputRemainHP(driver, op, '32');
  // マリルリのばかぢから
  await tapMove(driver, me, 'ばかぢから', false);
  // カイリューのHP5
  await inputRemainHP(driver, me, '5');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのしんそく
  await tapMove(driver, op, 'しんそく', false);
  // マリルリのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'あいじょーくの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハカドッグ戦2
Future<void> test28_2(
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
    battleName: 'もこうハカドッグ戦2',
    ownPartyname: '28もこドッグ',
    opponentName: 'BEN',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'カイリュー',
    pokemon3: 'サーフゴー',
    pokemon4: 'ウルガモス',
    pokemon5: 'マスカーニャ',
    pokemon6: 'ミミッキュ',
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこドッグ/',
      ownPokemon2: 'もこレッグ/',
      ownPokemon3: 'もこ特殊マンダ/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグ->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', true);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ウルガモスのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのテラスタル
  await inputTerastal(driver, me, '');
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグ->ハカドッグに交代
  await changePokemon(driver, me, 'ハカドッグ', true);
  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // 外れる
  await tapHit(driver, op);
  // ハカドッグのHP179
  await inputRemainHP(driver, op, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのじゃれつく
  await tapMove(driver, op, 'じゃれつく', false);
  // ハカドッグのHP143
  await inputRemainHP(driver, op, '143');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // マスカーニャのHP30
  await inputRemainHP(driver, me, '30');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // マスカーニャひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', true);
  // ハカドッグのHP92
  await inputRemainHP(driver, op, '92');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // カイリューのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // カイリューのHP30
  await inputRemainHP(driver, me, '30');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // カイリューのHP8
  await inputRemainHP(driver, me, '8');
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP58
  await inputRemainHP(driver, op, '58');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', false);
  // ハカドッグのHP10
  await inputRemainHP(driver, op, '10');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // カイリューのHP30
  await inputRemainHP(driver, me, '30');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP86
  await inputRemainHP(driver, op, '86');
  // ハカドッグのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // カイリューのHP20
  await inputRemainHP(driver, me, '20');
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハカドッグ戦3
Future<void> test28_3(
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
    battleName: 'もこうハカドッグ戦2',
    ownPartyname: '28もこドッグ2',
    opponentName: 'まさや',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ジバコイル',
    pokemon3: 'サザンドラ',
    pokemon4: 'ウルガモス',
    pokemon5: 'キノガッサ',
    pokemon6: 'ミミッキュ',
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこドッグ/',
      ownPokemon2: 'もこレッグ/',
      ownPokemon3: 'もこカーニャ/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグ->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', true);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // マスカーニャのHP77
  await inputRemainHP(driver, op, '77');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // ジバコイルのHP85
  await inputRemainHP(driver, me, '85');
  // ハカドッグに交代
  await changePokemon(driver, me, 'ハカドッグ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのじだんだ
  await tapMove(driver, me, 'じだんだ', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ジバコイルひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグ->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', true);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // エクスレッグのHP81
  await inputRemainHP(driver, op, '81');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', true);
  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグ->ハカドッグに交代
  await changePokemon(driver, me, 'ハカドッグ', true);
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ハカドッグのHP140
  await inputRemainHP(driver, op, '140');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // ハカドッグのHP104
  await inputRemainHP(driver, op, '104');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ハカドッグのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // サザンドラのHP60
  await inputRemainHP(driver, me, '60');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ハカドッグのHP0
  await inputRemainHP(driver, op, '0');
  // ハカドッグひんし->エクスレッグに交代
  await changePokemon(driver, me, 'エクスレッグ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // エクスレッグのであいがしら
  await tapMove(driver, me, 'であいがしら', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ハカドッグ戦4
Future<void> test28_4(
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
    battleName: 'もこうハカドッグ戦4',
    ownPartyname: '28もこドッグ2',
    opponentName: 'しょけん',
    pokemon1: 'ウルガモス',
    pokemon2: 'ヌメルゴン',
    pokemon3: 'コノヨザル',
    pokemon4: 'ドラパルト',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ヘイラッシャ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこ特殊マンダ/',
      ownPokemon3: 'もこドッグ/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ウルガモスのHP30
  await inputRemainHP(driver, me, '30');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('オボンのみ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('オボンのみ')));
  // ウルガモスのほのおのからだ
  await addEffect(driver, 2, op, 'ほのおのからだ');
  await driver.tap(find.text('OK'));
  // ウルガモスのむしのさざめき
  await tapMove(driver, op, 'むしのさざめき', true);
  // マスカーニャのHP0
  await inputRemainHP(driver, op, '0');
  // マスカーニャひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', true);
  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ヘイラッシャのHP60
  await inputRemainHP(driver, me, '60');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ヘイラッシャのHP5
  await inputRemainHP(driver, me, '5');
  // ヘイラッシャのじわれ
  await tapMove(driver, op, 'じわれ', true);
  // 外れる
  await tapHit(driver, op);
  // ボーマンダのHP178
  await inputRemainHP(driver, op, '');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのりゅうせいぐん
  await tapMove(driver, me, 'りゅうせいぐん', false);
  // ヘイラッシャのHP0
  await inputRemainHP(driver, me, '0');
  // ヘイラッシャひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->ハカドッグに交代
  await changePokemon(driver, me, 'ハカドッグ', true);
  // コノヨザルのビルドアップ
  await tapMove(driver, op, 'ビルドアップ', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // コノヨザルのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', true);
  // ハカドッグのHP125
  await inputRemainHP(driver, op, '125');
  // コノヨザルのHP55
  await inputRemainHP(driver, me, '55');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのふんどのこぶし
  await tapMove(driver, op, 'ふんどのこぶし', false);
  // TODO: ふんどのこぶしのダメージ推定おかしい
  // ハカドッグのHP14
  await inputRemainHP(driver, op, '14');
  // ハカドッグのおはかまいり
  await tapMove(driver, me, 'おはかまいり', false);
  // コノヨザルのHP5
  await inputRemainHP(driver, me, '5');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ハカドッグのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // コノヨザルひんし->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イキリンコ戦1
Future<void> test29_1(
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
    battleName: 'もこうイキリンコ戦1',
    ownPartyname: '29もこリンコ',
    opponentName: 'ミツバ',
    pokemon1: 'ガブリアス',
    pokemon2: 'ムクホーク',
    pokemon3: 'エルレイド',
    pokemon4: 'ドオー',
    pokemon5: 'ウルガモス',
    pokemon6: 'ボーマンダ',
    sex1: Sex.female,
    sex2: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこニバル/',
      opponentPokemon: 'エルレイド');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // エルレイドのHP0
  await inputRemainHP(driver, me, '0');
  // イキリンコのHP109
  await inputRemainHP(driver, me, '109');
  // エルレイドひんし->ムクホークに交代
  await changePokemon(driver, op, 'ムクホーク', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのテラスタル
  await inputTerastal(driver, me, '');
  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ムクホークのHP0
  await inputRemainHP(driver, me, '0');
  // イキリンコのHP56
  await inputRemainHP(driver, me, '56');
  // ムクホークひんし->ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イキリンコ戦2
Future<void> test29_2(
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
    battleName: 'もこうイキリンコ戦2',
    ownPartyname: '29もこリンコ2',
    opponentName: 'とまと',
    pokemon1: 'ジバコイル',
    pokemon2: 'クエスパトラ',
    pokemon3: 'サザンドラ',
    pokemon4: 'リキキリン',
    pokemon5: 'セグレイブ',
    pokemon6: 'ウルガモス',
    sex2: Sex.female,
    sex4: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ2/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこニバル/',
      opponentPokemon: 'セグレイブ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのすてゼリフ
  await tapMove(driver, me, 'すてゼリフ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // ウェーニバルのHP80
  await inputRemainHP(driver, op, '80');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ウルガモスのHP65
  await inputRemainHP(driver, me, '65');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルのテラスタル
  await inputTerastal(driver, op, 'ひこう');
  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ジバコイルのHP75
  await inputRemainHP(driver, me, '75');
  // ジバコイルのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ジバコイルのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // ジバコイルのHP50
  await inputRemainHP(driver, me, '50');
  // ジバコイルのてっぺき
  await tapMove(driver, op, 'てっぺき', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアイススピナー
  await tapMove(driver, me, 'アイススピナー', false);
  // ジバコイルのHP35
  await inputRemainHP(driver, me, '35');
  // ジバコイルのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ジバコイルのHP10
  await inputRemainHP(driver, op, '10');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', true);
  // ジバコイルのボディプレス
  await tapMove(driver, op, 'ボディプレス', true);
  // ウェーニバルのHP0
  await inputRemainHP(driver, op, '0');
  // ウェーニバルひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ジバコイルのHP22
  await inputRemainHP(driver, me, '');
  // ジバコイルのボディプレス
  await tapMove(driver, op, 'ボディプレス', false);
  // ボーマンダのHP32
  await inputRemainHP(driver, op, '32');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ジバコイルひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 0回命中
  await setHitCount(driver, me, 0);
  // 0回命中
  await setHitCount(driver, me, 0);
  // セグレイブのHP100
  await inputRemainHP(driver, me, '');
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->イキリンコに交代
  await changePokemon(driver, me, 'イキリンコ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // セグレイブのHP10
  await inputRemainHP(driver, me, '10');
  // イキリンコのHP90
  await inputRemainHP(driver, me, '90');
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', false);
  // 0回命中
  await setHitCount(driver, op, 0);
  // 1回命中
  await setHitCount(driver, op, 1);
  // イキリンコのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'とまとの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イキリンコ戦3
Future<void> test29_3(
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
    battleName: 'もこうイキリンコ戦3',
    ownPartyname: '29もこリンコ',
    opponentName: 'ひろし',
    pokemon1: 'ドラパルト',
    pokemon2: 'サザンドラ',
    pokemon3: 'ニンフィア',
    pokemon4: 'ジバコイル',
    pokemon5: 'アーマーガア',
    pokemon6: 'ミミッキュ',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこニバル/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // イキリンコのHP103
  await inputRemainHP(driver, me, '103');
  // ドラパルトひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ドラパルトのプレッシャー
  await addEffect(driver, 2, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イキリンコ->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', true);
  // アーマーガアのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ウェーニバルのHP146
  await inputRemainHP(driver, op, '146');
  // ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ニンフィアのHP70
  await inputRemainHP(driver, me, '70');
  // ニンフィアのあくび
  await tapMove(driver, op, 'あくび', true);
  // ニンフィアのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ニンフィアのHP50
  await inputRemainHP(driver, me, '50');
  // ニンフィアのハイパーボイス
  await tapMove(driver, op, 'ハイパーボイス', true);
  // ウェーニバルのHP0
  await inputRemainHP(driver, op, '0');
  // ウェーニバルひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ニンフィアひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // アーマーガアのHP30
  await inputRemainHP(driver, me, '30');
  // アーマーガアのてっぺき
  await tapMove(driver, op, 'てっぺき', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イキリンコ戦4
Future<void> test29_4(
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
    battleName: 'もこうイキリンコ戦4',
    ownPartyname: '29もこリンコ',
    opponentName: 'さゆき',
    pokemon1: 'マスカーニャ',
    pokemon2: 'ギャラドス',
    pokemon3: 'ストリンダー(ローなすがた)',
    pokemon4: 'パルシェン',
    pokemon5: 'キョジオーン',
    pokemon6: 'ミミッキュ',
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこロローム/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのすてゼリフ
  await tapMove(driver, me, 'すてゼリフ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ブロロロームに交代
  await changePokemon(driver, me, 'ブロロローム', false);
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // ブロロロームのHP137
  await inputRemainHP(driver, op, '137');
  // ギャラドスに交代
  await changePokemon(driver, op, 'ギャラドス', false);
  // ギャラドスのいかく
  await addEffect(driver, 2, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ブロロローム->イキリンコに交代
  await changePokemon(driver, me, 'イキリンコ', true);
  // ギャラドスのじしん
  await tapMove(driver, op, 'じしん', true);
  // イキリンコのHP157
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのテラスタル
  await inputTerastal(driver, me, '');
  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ギャラドスのHP0
  await inputRemainHP(driver, me, '0');
  // イキリンコのHP99
  await inputRemainHP(driver, me, '99');
  // ギャラドスひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのブレイブバード
  await tapMove(driver, me, 'ブレイブバード', false);
  // ミミッキュのHP100
  await inputRemainHP(driver, me, '');
  // イキリンコのHP99
  await inputRemainHP(driver, me, '');
  // ミミッキュのつるぎのまい
  await tapMove(driver, op, 'つるぎのまい', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', true);
  // イキリンコのHP0
  await inputRemainHP(driver, op, '0');
  // ミミッキュのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // イキリンコひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回命中
  await setHitCount(driver, me, 1);
  // 0回命中
  await setHitCount(driver, me, 0);
  // ミミッキュのHP78
  await inputRemainHP(driver, me, '');
  // ミミッキュのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->ブロロロームに交代
  await changePokemon(driver, me, 'ブロロローム', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', false);
  // ブロロロームのHP67
  await inputRemainHP(driver, op, '67');
  // ブロロロームのギアチェンジ
  await tapMove(driver, me, 'ギアチェンジ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのかげうち
  await tapMove(driver, op, 'かげうち', false);
  // ブロロロームのHP31
  await inputRemainHP(driver, op, '31');
  // ブロロロームのアイアンヘッド
  await tapMove(driver, me, 'アイアンヘッド', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ブロロロームのダストシュート
  await tapMove(driver, me, 'ダストシュート', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// イキリンコ戦5
Future<void> test29_5(
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
    battleName: 'もこうイキリンコ戦5',
    ownPartyname: '29もこリンコ',
    opponentName: 'MOL53',
    pokemon1: 'サザンドラ',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'アーマーガア',
    pokemon4: 'パーモット',
    pokemon5: 'セグレイブ',
    pokemon6: 'ニンフィア',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリンコ/',
      ownPokemon2: 'もこ両刀マンダ/',
      ownPokemon3: 'もこロローム/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのすてゼリフ
  await tapMove(driver, me, 'すてゼリフ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ブロロロームに交代
  await changePokemon(driver, me, 'ブロロローム', false);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // ブロロロームのHP57
  await inputRemainHP(driver, op, '57');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ブロロロームのHP0
  await inputRemainHP(driver, op, '0');
  // ブロロロームひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', true);
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // アーマーガアのHP30
  await inputRemainHP(driver, me, '30');
  // アーマーガアのちょうはつ
  await tapMove(driver, op, 'ちょうはつ', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // アーマーガアのHP0
  await inputRemainHP(driver, me, '0');
  // アーマーガアひんし->パーモットに交代
  await changePokemon(driver, op, 'パーモット', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // パーモットのHP0
  await inputRemainHP(driver, me, '0');
  // パーモットひんし->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // サザンドラのHP1
  await inputRemainHP(driver, me, '1');
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->イキリンコに交代
  await changePokemon(driver, me, 'イキリンコ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // イキリンコのまねっこ
  await tapMove(driver, me, 'まねっこ', false);
  await driver.tap(find.byValueKey('BattleActionCommandMoveSearchOwn'));
  await driver.enterText('あくのはどう');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('あくのはどう')));
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オドリドリ戦1
Future<void> test30_1(
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
    battleName: 'もこうオドリドリ戦1',
    ownPartyname: '30もこリドリ',
    opponentName: 'Nether',
    pokemon1: 'イッカネズミ',
    pokemon2: 'サーフゴー',
    pokemon3: 'サザンドラ',
    pokemon4: 'モロバレル',
    pokemon5: 'ウルガモス',
    pokemon6: 'ガブリアス',
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこリドリ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'サーフゴー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // サーフゴーのHP95
  await inputRemainHP(driver, me, '95');
  // オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', false);
  // サーフゴーのゴールドラッシュ
  await tapMove(driver, op, 'ゴールドラッシュ', true);
  // オドリドリのHP83
  await inputRemainHP(driver, op, '83');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // サーフゴーのみがわり
  await tapMove(driver, op, 'みがわり', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // サーフゴーのHP70
  await inputRemainHP(driver, op, '70');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // サーフゴーのHP70
  await inputRemainHP(driver, me, '');
  // サーフゴーのわるだくみ
  await tapMove(driver, op, 'わるだくみ', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // サーフゴーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // オドリドリのHP16
  await inputRemainHP(driver, op, '16');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // サーフゴーのHP0
  await inputRemainHP(driver, me, '0');
  // サーフゴーひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのテラスタル
  await inputTerastal(driver, me, '');
  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->イッカネズミに交代
  await changePokemon(driver, op, 'イッカネズミ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // イッカネズミのHP0
  await inputRemainHP(driver, me, '0');

  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オドリドリ戦2
Future<void> test30_2(
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
    battleName: 'もこうオドリドリ戦2',
    ownPartyname: '30もこリドリ',
    opponentName: 'しょう',
    pokemon1: 'カバルドン',
    pokemon2: 'セグレイブ',
    pokemon3: 'カイリュー',
    pokemon4: 'サーフゴー',
    pokemon5: 'ウルガモス',
    pokemon6: 'マスカーニャ',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこカーニャ/',
      ownPokemon2: 'もこリングマ/',
      ownPokemon3: 'もこリドリ/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->オドリドリに交代
  await changePokemon(driver, me, 'オドリドリ(ぱちぱちスタイル)', true);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // オドリドリのおどりこ
  await addEffect(driver, 2, me, 'おどりこ');
  await driver.tap(find.byValueKey('DanceTypeAheadField'));
  await driver.enterText('ちょうのまい');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ちょうのまい')));
  await driver.tap(find.text('OK'));
  // C・D・Sが上がっていることを確認
  await testRank(driver, me, 'C', 'Up0');
  await testRank(driver, me, 'D', 'Up0');
  await testRank(driver, me, 'S', 'Up0');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // ウルガモスのほのおのまい
  await tapMove(driver, op, 'ほのおのまい', true);
  // オドリドリのHP82
  await inputRemainHP(driver, op, '82');
  // ウルガモスはとくこうが上がった
  await driver.tap(find.text('ウルガモスはとくこうが上がった'));
  // オドリドリのおどりこ
  await addEffect(driver, 2, me, 'おどりこ');
  await driver.tap(find.byValueKey('DanceTypeAheadField'));
  await driver.enterText('ほのおのまい');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ほのおのまい')));
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('70');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのはねやすめ
  await tapMove(driver, me, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // オドリドリのHP151
  await inputRemainHP(driver, me, '151');
  // ウルガモスのおにび
  await tapMove(driver, op, 'おにび', true);
  // オドリドリのラムのみ
  await addEffect(driver, 2, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // やけど編集
  await tapEffect(driver, 'やけど');
  await driver.tap(find.text('削除'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // カイリューのHP70
  await inputRemainHP(driver, me, '70');
  // カイリューのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', true);
  // 外れる
  await tapHit(driver, op);
  // オドリドリのHP151
  await inputRemainHP(driver, op, '');
  // カイリューのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // カイリューのHP5
  await inputRemainHP(driver, me, '5');
  // カイリューのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // オドリドリのHP0
  await inputRemainHP(driver, op, '0');
  // オドリドリひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // リングマに交代
  await changePokemon(driver, me, 'リングマ', false);
  // マスカーニャひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // カイリューのストーンエッジ
  await tapMove(driver, op, 'ストーンエッジ', false);
  // リングマのHP133
  await inputRemainHP(driver, op, '133');
  // リングマののしかかり
  await tapMove(driver, me, 'のしかかり', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オドリドリ戦3
Future<void> test30_3(
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
    battleName: 'もこうオドリドリ戦3',
    ownPartyname: '30もこリドリ',
    opponentName: 'じじねい',
    pokemon1: 'ドラパルト',
    pokemon2: 'サーフゴー',
    pokemon3: 'ウインディ',
    pokemon4: 'アーマーガア',
    pokemon5: 'ニンフィア',
    pokemon6: 'ガブリアス',
    sex1: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリドリ/',
      ownPokemon2: 'もこリングマ/',
      ownPokemon3: 'もこアルマ/',
      opponentPokemon: 'ウインディ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウインディのいかく
  await addEffect(driver, 0, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ウインディ->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // オドリドリのちょうのまい
  await tapMove(driver, me, 'ちょうのまい', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのテラスタル
  await inputTerastal(driver, me, '');
  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オドリドリのエアスラッシュ
  await tapMove(driver, me, 'エアスラッシュ', false);
  // ウインディのHP50
  await inputRemainHP(driver, me, '50');
  // ウインディのフレアドライブ
  await tapMove(driver, op, 'フレアドライブ', true);
  // オドリドリのHP0
  await inputRemainHP(driver, op, '0');
  // ウインディのHP20
  await inputRemainHP(driver, op, '20');
  // ウインディのいのちのたま
  await addEffect(driver, 2, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // オドリドリひんし->グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // ウインディのHP0
  await inputRemainHP(driver, me, '0');
  // ウインディひんし->アーマーガアに交代
  await changePokemon(driver, op, 'アーマーガア', false);
  // ウインディのプレッシャー
  await addEffect(driver, 2, op, 'プレッシャー');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// オドリドリ戦4
Future<void> test30_4(
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
    battleName: 'もこうオドリドリ戦4',
    ownPartyname: '30もこリドリ',
    opponentName: 'バイオレット',
    pokemon1: 'エルレイド',
    pokemon2: 'サーナイト',
    pokemon3: 'ウルガモス',
    pokemon4: 'ドラパルト',
    pokemon5: 'サザンドラ',
    pokemon6: 'ドオー',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこリドリ/',
      ownPokemon2: 'もこカーニャ/',
      ownPokemon3: 'もこアルマ/',
      opponentPokemon: 'サーナイト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // サーナイトのトレース
  await addEffect(driver, 0, op, 'トレース');
  await driver.tap(find.text('OK'));
  // オドリドリのめざめるダンス
  await tapMove(driver, me, 'めざめるダンス', false);
  // サーナイトのHP65
  await inputRemainHP(driver, me, '65');
  // サーナイトのおどりこ
  await addEffect(driver, 2, op, 'おどりこ');
  await driver.tap(find.byValueKey('DanceTypeAheadField'));
  await driver.enterText('めざめるダンス');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('めざめるダンス')));
  await driver.tap(find.byValueKey('DamageIndicateTextField'));
  await driver.enterText('43');
  await driver.tap(find.text('OK'));
  // サーナイトのムーンフォース
  await tapMove(driver, op, 'ムーンフォース', true);
  // オドリドリのHP0
  await inputRemainHP(driver, op, '0');
  // オドリドリひんし->マスカーニャに交代
  await changePokemon(driver, me, 'マスカーニャ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのとんぼがえり
  await tapMove(driver, me, 'とんぼがえり', false);
  // サーナイトのHP0
  await inputRemainHP(driver, me, '0');
  // グレンアルマに交代
  await changePokemon(driver, me, 'グレンアルマ', false);
  // サーナイトひんし->エルレイドに交代
  await changePokemon(driver, op, 'エルレイド', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // エルレイドのアクアカッター
  await tapMove(driver, op, 'アクアカッター', true);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '1');
  // グレンアルマのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // グレンアルマのサイコショック
  await tapMove(driver, me, 'サイコショック', false);
  // エルレイドのHP28
  await inputRemainHP(driver, me, '28');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // グレンアルマのアーマーキャノン
  await tapMove(driver, me, 'アーマーキャノン', false);
  // エルレイドのHP0
  await inputRemainHP(driver, me, '0');
  // エルレイドひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ドラゴン');
  // ドラパルトのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // 外れる
  await tapHit(driver, op);
  // グレンアルマのHP1
  await inputRemainHP(driver, op, '');
  // グレンアルマのみちづれ
  await tapMove(driver, me, 'みちづれ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのふいうち
  await tapMove(driver, op, 'ふいうち', false);
  // グレンアルマのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// イキリンコ戦1
Future<void> test29_1(
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
