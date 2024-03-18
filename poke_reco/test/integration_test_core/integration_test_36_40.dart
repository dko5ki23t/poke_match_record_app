import 'package:flutter_driver/flutter_driver.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'integration_test_tool.dart';

const PlayerType me = PlayerType.me;
const PlayerType op = PlayerType.opponent;

/// ガケガニ戦1
Future<void> test36_1(
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
    battleName: 'もこうガケガニ戦1',
    ownPartyname: '36もこガニ',
    opponentName: 'ジン',
    pokemon1: 'ガブリアス',
    pokemon2: 'ドラパルト',
    pokemon3: 'カイリュー',
    pokemon4: 'ゲンガー',
    pokemon5: 'ジバコイル',
    pokemon6: 'ラウドボーン',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこッサン/',
      ownPokemon2: 'もこガニ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ゲンガー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ゲンガーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', true);
  // イエッサンのHP177
  await inputRemainHP(driver, op, '');
  // イエッサンのひかりのかべ
  await tapMove(driver, me, 'ひかりのかべ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ゲンガーのアンコール
  await tapMove(driver, op, 'アンコール', true);
  // イエッサンのひかりのかべ
  await tapMove(driver, me, 'ひかりのかべ', false);
  await tapSuccess(driver, me);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イエッサン->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', true);
  // ゲンガーのヘドロばくだん
  await tapMove(driver, op, 'ヘドロばくだん', true);
  // ガケガニのHP112
  await inputRemainHP(driver, op, '112');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ゲンガーのシャドーボール
  await tapMove(driver, op, 'シャドーボール', false);
  // ガケガニのHP52
  await inputRemainHP(driver, op, '52');
  // TODO:自動で入力されてほしい
  // ガケガニのいかりのこうら
  await addEffect(driver, 1, me, 'いかりのこうら');
  await driver.tap(find.text('OK'));
  // ガケガニのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ゲンガーのHP0
  await inputRemainHP(driver, me, '0');
  // ゲンガーののろわれボディ
  await addEffect(driver, 2, op, 'のろわれボディ');
  await driver.tap(find.text('OK'));
  // ゲンガーひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのゴツゴツメット
  await addEffect(driver, 2, op, 'ゴツゴツメット');
  await driver.tap(find.text('OK'));
  // ガブリアスひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ガケガニ戦2
Future<void> test36_2(
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
    battleName: 'もこうガケガニ戦2',
    ownPartyname: '36もこガニ',
    opponentName: 'バーランダー',
    pokemon1: 'ゲンガー',
    pokemon2: 'ガブリアス',
    pokemon3: 'ドヒドイデ',
    pokemon4: 'マリルリ',
    pokemon5: 'サーフゴー',
    pokemon6: 'ニンフィア',
    sex2: Sex.female,
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこッサン/',
      ownPokemon2: 'もこガニ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'マリルリ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(find.text('OK'));
  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // マリルリのHP80
  await inputRemainHP(driver, me, '80');
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // イエッサンのHP90
  await inputRemainHP(driver, op, '90');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イエッサンのリフレクター
  await tapMove(driver, me, 'リフレクター', false);
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // イエッサンのHP45
  await inputRemainHP(driver, op, '45');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イエッサン->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', true);
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', false);
  // ガケガニのHP56
  await inputRemainHP(driver, op, '56');
  // イエッサンのいかりのこうら
  await addEffect(driver, 2, me, 'いかりのこうら');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ゲンガーに交代
  await changePokemon(driver, op, 'ゲンガー', true);
  // ガケガニのテラスタル
  await inputTerastal(driver, me, '');
  // ガケガニのつるぎのまい
  await tapMove(driver, me, 'つるぎのまい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ゲンガーのHP0
  await inputRemainHP(driver, me, '0');
  // ゲンガーののろわれボディ
  await addEffect(driver, 1, op, 'のろわれボディ');
  await driver.tap(find.text('OK'));
  // ゲンガーひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, op, 'ほのお');
  // ガケガニの１０まんばりき
  await tapMove(driver, me, '１０まんばりき', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ガケガニの１０まんばりき
  await tapMove(driver, me, '１０まんばりき', false);
  // ガブリアスのHP30
  await inputRemainHP(driver, me, '30');
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // ガケガニのHP0
  await inputRemainHP(driver, op, '0');
  // ガケガニひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのげきりん
  await tapMove(driver, op, 'げきりん', false);
  // マリルリのHP201
  await inputRemainHP(driver, op, '');
  // 疲れ果ててこんらんした
  await driver.tap(find.text('疲れ果ててこんらんした'));
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ガケガニ戦3
Future<void> test36_3(
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
    battleName: 'もこうガケガニ戦3',
    ownPartyname: '36もこガニ',
    opponentName: 'かるびやで',
    pokemon1: 'カイリュー',
    pokemon2: 'セグレイブ',
    pokemon3: 'ハッサム',
    pokemon4: 'マリルリ',
    pokemon5: 'シビルドン',
    pokemon6: 'ロトム(ウォッシュロトム)',
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこッサン/',
      ownPokemon2: 'もこガニ/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'ハッサム');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イエッサンのリフレクター
  await tapMove(driver, me, 'リフレクター', false);
  // ハッサムのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // イエッサンのHP77
  await inputRemainHP(driver, op, '77');
  // ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // イエッサンのHP34
  await inputRemainHP(driver, op, '34');
  // ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // ハッサムのHP80
  await inputRemainHP(driver, me, '80');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イエッサン->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', true);
  // ハッサムのかわらわり
  await tapMove(driver, op, 'かわらわり', true);
  // ガケガニのHP14
  await inputRemainHP(driver, op, '14');
  // イエッサンのいかりのこうら
  await addEffect(driver, 2, me, 'いかりのこうら');
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハッサム->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', true);
  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // ロトムのHP25
  await inputRemainHP(driver, me, '25');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 2回命中
  await setHitCount(driver, me, 2);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ハッサムのバレットパンチ
  await tapMove(driver, op, 'バレットパンチ', true);
  // 外れる
  await tapHit(driver, op);
  // ガケガニのHP14
  await inputRemainHP(driver, op, '');
  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '0');
  // ハッサムひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ガケガニのロックブラスト
  await tapMove(driver, me, 'ロックブラスト', false);
  // 4回命中
  await setHitCount(driver, me, 4);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ガケガニ戦4
Future<void> test36_4(
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
    battleName: 'もこうガケガニ戦4',
    ownPartyname: '36もこガニ',
    opponentName: 'カミちゃん',
    pokemon1: 'サザンドラ',
    pokemon2: 'モロバレル',
    pokemon3: 'マリルリ',
    pokemon4: 'ラウドボーン',
    pokemon5: 'サーフゴー',
    pokemon6: 'カイリュー',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこッサン/',
      ownPokemon2: 'もこガニ/',
      ownPokemon3: 'もこルリ/',
      opponentPokemon: 'カイリュー');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // イエッサンのリフレクター
  await tapMove(driver, me, 'リフレクター', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // マリルリのHP80
  await inputRemainHP(driver, me, '80');
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // イエッサンのHP135
  await inputRemainHP(driver, op, '135');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // マリルリのHP50
  await inputRemainHP(driver, me, '50');
  // マリルリはとくぼうが下がった
  await driver.tap(find.text('マリルリはとくぼうが下がった'));
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // イエッサンのHP90
  await inputRemainHP(driver, op, '90');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // イエッサン->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', true);
  // マリルリ->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ガケガニ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // サザンドラのあくのはどう
  await tapMove(driver, op, 'あくのはどう', true);
  // マリルリのHP156
  await inputRemainHP(driver, op, '156');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // マリルリひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // カイリューのでんじは
  await tapMove(driver, op, 'でんじは', true);
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリのアクアジェット
  await tapMove(driver, me, 'アクアジェット', false);
  // 外れる
  await tapHit(driver, me);
  // カイリューのHP100
  await inputRemainHP(driver, me, '');
  // カイリューのアンコール
  await tapMove(driver, op, 'アンコール', true);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->イエッサンに交代
  await changePokemon(driver, me, 'イエッサン(メスのすがた)', true);
  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', true);
  // イエッサンのHP75
  await inputRemainHP(driver, op, '75');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // カイリューのでんじは
  await tapMove(driver, op, 'でんじは', false);
  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // カイリューのHP90
  await inputRemainHP(driver, me, '90');
  // カイリューのたべのこし
  await addEffect(driver, 3, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // イエッサンのサイコキネシス
  await tapMove(driver, me, 'サイコキネシス', false);
  // カイリューのHP90
  await inputRemainHP(driver, me, '90');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // イエッサンのHP0
  await inputRemainHP(driver, op, '0');
  // イエッサンひんし->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // カイリューのでんじは
  await tapMove(driver, op, 'でんじは', false);
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // ガケガニのHP135
  await inputRemainHP(driver, op, '135');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // ガケガニのHP106
  await inputRemainHP(driver, op, '106');
  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // 外れる
  await tapHit(driver, me);
  // カイリューのHP100
  await inputRemainHP(driver, me, '');
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // 外れる
  await tapHit(driver, me);
  // サザンドラのHP100
  await inputRemainHP(driver, me, '');
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // ガケガニ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // マリルリのHP103
  await inputRemainHP(driver, op, '103');
  // ターン18へ
  await goTurnPage(driver, turnNum++);

  // サザンドラ->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // ターン19へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', true);
  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ターン20へ
  await goTurnPage(driver, turnNum++);

  // カイリュー->サザンドラに交代
  await changePokemon(driver, op, 'サザンドラ', true);
  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // 外れる
  await tapHit(driver, me);
  // サザンドラのHP100
  await inputRemainHP(driver, me, '');
  // ターン21へ
  await goTurnPage(driver, turnNum++);

  // ガケガニ->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', false);
  // マリルリのHP44
  await inputRemainHP(driver, op, '44');
  // ターン22へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // サザンドラのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', false);
  // マリルリのHP16
  await inputRemainHP(driver, op, '16');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', false);
  // ターン23へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // マリルリのHP10
  await inputRemainHP(driver, op, '10');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // カイリューのHP75
  await inputRemainHP(driver, me, '75');
  // マリルリひんし->ガケガニに交代
  await changePokemon(driver, me, 'ガケガニ', false);
  // ターン24へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのうず
  await tapMove(driver, op, 'ほのおのうず', false);
  // 外れる
  await tapHit(driver, op);
  // ガケガニのHP70
  await inputRemainHP(driver, op, '');
  // ガケガニのハサミギロチン
  await tapMove(driver, me, 'ハサミギロチン', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ソウブレイズ戦1
Future<void> test37_1(
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
    battleName: 'もこうソウブレイズ戦1',
    ownPartyname: '37もこブレイズ',
    opponentName: 'ケス',
    pokemon1: 'サザンドラ',
    pokemon2: 'マリルリ',
    pokemon3: 'ラウドボーン',
    pokemon4: 'ガブリアス',
    pokemon5: 'ミミッキュ',
    pokemon6: 'ジバコイル',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブレイズ/',
      ownPokemon2: 'もこニンフィア2/',
      ownPokemon3: 'もこカーニャ/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // ニンフィアのHP120
  await inputRemainHP(driver, op, '120');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ガブリアスのアイアンヘッド
  await tapMove(driver, op, 'アイアンヘッド', true);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // ニンフィアひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', false);
  // ソウブレイズのHP134
  await inputRemainHP(driver, op, '134');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのげきりん
  await tapMove(driver, op, 'げきりん', true);
  // ソウブレイズのHP56
  await inputRemainHP(driver, op, '56');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP133
  await inputRemainHP(driver, me, '133');
  // ガブリアスひんし->ミミッキュに交代
  await changePokemon(driver, op, 'ミミッキュ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ミミッキュのくさわけ
  await tapMove(driver, op, 'くさわけ', true);
  // ソウブレイズのHP97
  await inputRemainHP(driver, op, '97');
  // ミミッキュのいのちのたま
  await addEffect(driver, 1, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ミミッキュのHP90
  await inputRemainHP(driver, me, '');
  // ソウブレイズのHP97
  await inputRemainHP(driver, me, '');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ミミッキュのHP0
  await inputRemainHP(driver, me, '0');
  // ミミッキュひんし->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ジバコイルのHP1
  await inputRemainHP(driver, me, '1');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '182');
  // ジバコイルのがんじょう
  await addEffect(driver, 1, op, 'がんじょう');
  await driver.tap(find.text('OK'));
  // ジバコイルのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // ソウブレイズのHP59
  await inputRemainHP(driver, op, '59');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ソウブレイズ戦2
Future<void> test37_2(
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
    battleName: 'もこうソウブレイズ戦2',
    ownPartyname: '37もこブレイズ',
    opponentName: 'ゆうきあおい',
    pokemon1: 'マリルリ',
    pokemon2: 'ドラパルト',
    pokemon3: 'アーマーガア',
    pokemon4: 'サザンドラ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'モロバレル',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブレイズ/',
      ownPokemon2: 'もこニンフィア2/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // 0回命中
  await setHitCount(driver, op, 0);
  // ニンフィアのHP202
  await inputRemainHP(driver, op, '');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ラウドボーンのHP90
  await inputRemainHP(driver, me, '90');
  // ドラパルトのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', true);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // ソウブレイズのHP182
  await inputRemainHP(driver, op, '');
  // ラウドボーンはとくこうが上がった
  await driver.tap(find.text('ラウドボーンはとくこうが上がった'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // ソウブレイズのHP124
  await inputRemainHP(driver, op, '124');
  // ソウブレイズはこうげきが下がった
  await driver.tap(find.text('ソウブレイズはこうげきが下がった'));
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ラウドボーンのHP40
  await inputRemainHP(driver, me, '40');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '182');
  // ラウドボーンのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ソウブレイズのHP124
  await inputRemainHP(driver, op, '124');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP171
  await inputRemainHP(driver, me, '171');
  // ラウドボーンひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ソウブレイズ戦3
Future<void> test37_3(
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
    battleName: 'もこうソウブレイズ戦3',
    ownPartyname: '37もこブレイズ',
    opponentName: 'マツオミユ',
    pokemon1: 'ドドゲザン',
    pokemon2: 'ガブリアス',
    pokemon3: 'ツンベアー',
    pokemon4: 'リングマ',
    pokemon5: 'ペリッパー',
    pokemon6: 'ブリムオン',
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシドリ/',
      ownPokemon2: 'もこブレイズ/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ガブリアスのHP55
  await inputRemainHP(driver, me, '55');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('きあいのタスキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('きあいのタスキ')));
  // ガブリアスのさめはだ
  await addEffect(driver, 1, op, 'さめはだ');
  await driver.tap(find.text('OK'));
  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ガブリアスのHP30
  await inputRemainHP(driver, me, '30');
  await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));
  // ガブリアスのりゅうせいぐん
  await tapMove(driver, op, 'りゅうせいぐん', true);
  // オトシドリのHP13
  await inputRemainHP(driver, op, '13');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのはたきおとす
  await tapMove(driver, me, 'はたきおとす', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // オトシドリひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ガブリアスひんし->ブリムオンに交代
  await changePokemon(driver, op, 'ブリムオン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // ブリムオンのHP45
  await inputRemainHP(driver, me, '45');
  // ブリムオンのオボンのみ
  await addEffect(driver, 2, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ブリムオンのトリックルーム
  await tapMove(driver, op, 'トリックルーム', true);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ブリムオンのマジカルシャイン
  await tapMove(driver, op, 'マジカルシャイン', true);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ブリムオンのサイコキネシス
  await tapMove(driver, op, 'サイコキネシス', true);
  // ソウブレイズのHP41
  await inputRemainHP(driver, op, '41');
  // ブリムオンのHP10
  await inputRemainHP(driver, me, '10');
  // ソウブレイズのHP87
  await inputRemainHP(driver, me, '87');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ブリムオンのテラスタル
  await inputTerastal(driver, op, 'エスパー');
  // ソウブレイズのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ブリムオンのHP0
  await inputRemainHP(driver, me, '0');
  // ブリムオンひんし->リングマに交代
  await changePokemon(driver, op, 'リングマ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // リングマのじしん
  await tapMove(driver, op, 'じしん', true);
  // ソウブレイズのHP47
  await inputRemainHP(driver, op, '47');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // リングマのもちものがかえんだま&とくせいがこんじょうであることが判明
  await editPokemonState(driver, 'リングマ/マツオミユ', null, 'こんじょう', 'かえんだま');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // リングマのHP30
  await inputRemainHP(driver, me, '30');
  // ソウブレイズのHP121
  await inputRemainHP(driver, me, '121');
  // リングマのからげんき
  await tapMove(driver, op, 'からげんき', true);
  // ソウブレイズのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'マツオミユの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ソウブレイズ戦4
Future<void> test37_4(
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
    battleName: 'もこうソウブレイズ戦4',
    ownPartyname: '37もこブレイズ',
    opponentName: 'アリス',
    pokemon1: 'マスカーニャ',
    pokemon2: 'デカヌチャン',
    pokemon3: 'トリトドン',
    pokemon4: 'ボーマンダ',
    pokemon5: 'ドドゲザン',
    pokemon6: 'ラウドボーン',
    sex1: Sex.female,
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこブレイズ/',
      ownPokemon2: 'もこシドリ/',
      ownPokemon3: 'もこバリー/',
      opponentPokemon: 'デカヌチャン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのかたやぶり
  await addEffect(driver, 0, op, 'かたやぶり');
  await driver.tap(find.text('OK'));
  // デカヌチャン->ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', true);
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ボーマンダのいかく
  await addEffect(driver, 2, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', true);
  // ソウブレイズのHP95
  await inputRemainHP(driver, op, '95');
  // ソウブレイズはひるんで技がだせない
  await driver.tap(find.text('ソウブレイズはひるんで技がだせない'));
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズ->ハラバリーに交代
  await changePokemon(driver, me, 'ハラバリー', true);
  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // ハラバリーのHP159
  await inputRemainHP(driver, op, '159');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->トリトドンに交代
  await changePokemon(driver, op, 'トリトドン', true);
  // ハラバリーのパラボラチャージ
  await tapMove(driver, me, 'パラボラチャージ', false);
  // トリトドンのHP100
  await inputRemainHP(driver, me, '');
  // ハラバリーのHP159
  await inputRemainHP(driver, me, '');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ハラバリーのテラスタル
  await inputTerastal(driver, me, '');
  // ハラバリーのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // トリトドンのHP0
  await inputRemainHP(driver, me, '0');
  // トリトドンひんし->ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // ハラバリーのHP0
  await inputRemainHP(driver, op, '0');
  // ハラバリーひんし->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->デカヌチャンに交代
  await changePokemon(driver, op, 'デカヌチャン', true);
  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // デカヌチャンのHP75
  await inputRemainHP(driver, me, '75');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // オトシドリ->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', true);
  // デカヌチャンのでんじは
  await tapMove(driver, op, 'でんじは', true);
  // オトシドリのラムのみ
  await addEffect(driver, 2, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // デカヌチャンのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // ソウブレイズのHP37
  await inputRemainHP(driver, op, '37');
  await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // デカヌチャンのHP0
  await inputRemainHP(driver, me, '0');
  // ソウブレイズのHP104
  await inputRemainHP(driver, me, '104');
  // デカヌチャンひんし->ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ソウブレイズのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ボーマンダのHP90
  await inputRemainHP(driver, me, '90');
  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // ソウブレイズのHP5
  await inputRemainHP(driver, op, '5');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ボーマンダのHP75
  await inputRemainHP(driver, me, '75');
  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // ソウブレイズのHP0
  await inputRemainHP(driver, op, '0');
  // ソウブレイズひんし->オトシドリに交代
  await changePokemon(driver, me, 'オトシドリ', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // ボーマンダのHP1
  await inputRemainHP(driver, me, '1');
  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // オトシドリのHP41
  await inputRemainHP(driver, op, '41');
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのストーンエッジ
  await tapMove(driver, me, 'ストーンエッジ', false);
  // 外れる
  await tapHit(driver, me);
  // ボーマンダのHP1
  await inputRemainHP(driver, me, '');
  // ボーマンダのエアスラッシュ
  await tapMove(driver, op, 'エアスラッシュ', false);
  // オトシドリのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'アリスの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ソウブレイズ戦5
Future<void> test37_5(
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
    battleName: 'もこうソウブレイズ戦5',
    ownPartyname: '37もこブレイズ',
    opponentName: 'ぐれい',
    pokemon1: 'サザンドラ',
    pokemon2: 'ドラパルト',
    pokemon3: 'サーフゴー',
    pokemon4: 'ウルガモス',
    pokemon5: 'マリルリ',
    pokemon6: 'モロバレル',
    sex2: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこシドリ/',
      ownPokemon2: 'もこニンフィア2/',
      ownPokemon3: 'もこブレイズ/',
      opponentPokemon: 'ウルガモス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', true);
  // オトシドリのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ドラパルトのHP50
  await inputRemainHP(driver, me, '50');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // オトシドリのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // マリルリのHP70
  await inputRemainHP(driver, me, '70');
  // マリルリのじゃれつく
  await tapMove(driver, op, 'じゃれつく', true);
  // オトシドリのHP0
  await inputRemainHP(driver, op, '0');
  // オトシドリひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // マリルリのアクアブレイク
  await tapMove(driver, op, 'アクアブレイク', true);
  // ニンフィアのHP118
  await inputRemainHP(driver, op, '118');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ニンフィアのひかりのかべ
  await tapMove(driver, me, 'ひかりのかべ', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ソウブレイズに交代
  await changePokemon(driver, me, 'ソウブレイズ', true);
  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウルガモス->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', true);
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ウルガモスに交代
  await changePokemon(driver, op, 'ウルガモス', true);
  // ソウブレイズのテラスタル
  await inputTerastal(driver, me, '');
  // ソウブレイズのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ウルガモスのちょうのまい
  await tapMove(driver, op, 'ちょうのまい', false);
  // ソウブレイズのむねんのつるぎ
  await tapMove(driver, me, 'むねんのつるぎ', false);
  // ウルガモスのHP10
  await inputRemainHP(driver, me, '10');
  // ソウブレイズのHP182
  await inputRemainHP(driver, me, '');
  // ウルガモスのオボンのみ
  await addEffect(driver, 3, op, 'オボンのみ');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのかげうち
  await tapMove(driver, me, 'かげうち', false);
  // ウルガモスのHP0
  await inputRemainHP(driver, me, '0');
  // ウルガモスひんし->マリルリに交代
  await changePokemon(driver, op, 'マリルリ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ソウブレイズのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // マリルリのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キラフロル戦1
Future<void> test38_1(
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
    battleName: 'もこうキラフロル戦1',
    ownPartyname: '38もこフロル',
    opponentName: 'ちこたん',
    pokemon1: 'ガブリアス',
    pokemon2: 'ニンフィア',
    pokemon3: 'パーモット',
    pokemon4: 'ラウドボーン',
    pokemon5: 'サザンドラ',
    pokemon6: 'マスカーニャ',
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'もこレトス/',
      ownPokemon3: 'もこーゼル/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', false);
  // ガブリアスのとくせいがさめはだと判明
  await editPokemonState(driver, 'ガブリアス/ちこたん', null, 'さめはだ', null);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キラフロル->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', true);
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', true);
  // フォレトスのHP125
  await inputRemainHP(driver, op, '125');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', true);
  // フォレトスのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // フォレトスのHP0
  await inputRemainHP(driver, op, '0');
  // フォレトスひんし->フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'みず');
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ラウドボーンのHP75
  await inputRemainHP(driver, me, '75');
  // フローゼルのHP142
  await inputRemainHP(driver, me, '142');
  // ラウドボーンのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーン->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ガブリアスのHP55
  await inputRemainHP(driver, me, '55');
  // フローゼルのHP107
  await inputRemainHP(driver, me, '107');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', false);
  // フローゼルのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルひんし->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのテラスタル
  await inputTerastal(driver, me, '');
  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ガブリアスのHP30
  await inputRemainHP(driver, me, '30');
  // ガブリアスはどくにかかった
  await driver.tap(find.text('ガブリアスはどくにかかった'));
  // ガブリアスのじしん
  await tapMove(driver, op, 'じしん', false);
  // 外れる
  await tapHit(driver, op);
  // キラフロルのHP159
  await inputRemainHP(driver, op, '');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ラウドボーンのHP15
  await inputRemainHP(driver, me, '15');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP65
  await inputRemainHP(driver, op, '65');
  // ラウドボーンのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キラフロル戦2
Future<void> test38_2(
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
    battleName: 'もこうキラフロル戦2',
    ownPartyname: '38もこフロル',
    opponentName: 'ぱんさ〜',
    pokemon1: 'イルカマン',
    pokemon2: 'キョジオーン',
    pokemon3: 'ウインディ',
    pokemon4: 'マスカーニャ',
    pokemon5: 'ドラパルト',
    pokemon6: 'エルレイド',
    sex2: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'もこレトス/',
      ownPokemon3: 'もこーゼル/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのへんげんじざい
  await addEffect(driver, 0, op, 'へんげんじざい');
  await driver.tap(find.text('OK'));
  await driver.tap(find.text('OK'));
  // マスカーニャのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // キラフロルのHP129
  await inputRemainHP(driver, op, '129');
  // エルレイドに交代
  await changePokemon(driver, op, 'エルレイド', false);
  // エルレイドのHP45
  await inputRemainHP(driver, me, '45');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // エルレイドのHP0
  await inputRemainHP(driver, me, '0');
  // エルレイドひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // キラフロル->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', true);
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // フォレトスのHP170
  await inputRemainHP(driver, op, '170');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', true);
  // フォレトスのあまごい
  await tapMove(driver, me, 'あまごい', false);
  // マスカーニャのいかく
  await addEffect(driver, 1, op, 'いかく');
  await driver.tap(find.text('OK'));
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ウインディのオーバーヒート
  await tapMove(driver, op, 'オーバーヒート', true);
  // フォレトスのHP0
  await inputRemainHP(driver, op, '0');
  // フォレトスひんし->フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ウインディ->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', true);
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // フローゼルのHP117
  await inputRemainHP(driver, me, '117');
  // マスカーニャひんし->ウインディに交代
  await changePokemon(driver, op, 'ウインディ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウインディのテラスタル
  await inputTerastal(driver, op, 'くさ');
  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  // ウインディのHP30
  await inputRemainHP(driver, me, '30');
  // ウインディのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // フローゼルのHP88
  await inputRemainHP(driver, me, '88');
  // フローゼルのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルひんし->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのテラスタル
  await inputTerastal(driver, me, '');
  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ウインディのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キラフロル戦3
Future<void> test38_3(
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
    battleName: 'もこうキラフロル戦3',
    ownPartyname: '38もこフロル',
    opponentName: 'れジぇんド',
    pokemon1: 'サザンドラ',
    pokemon2: 'アーマーガア',
    pokemon3: 'イルカマン',
    pokemon4: 'オーロンゲ',
    pokemon5: 'ドラパルト',
    pokemon6: 'ラウドボーン',
    sex1: Sex.female,
    sex3: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'もこレトス/',
      ownPokemon3: 'もこーゼル/',
      opponentPokemon: 'サザンドラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // サザンドラのHP0
  await inputRemainHP(driver, me, '0');
  // サザンドラひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラスタル
  await inputTerastal(driver, op, 'ゴースト');
  // キラフロルのマジカルシャイン
  await tapMove(driver, me, 'マジカルシャイン', false);
  // ドラパルトのHP70
  await inputRemainHP(driver, me, '70');
  // ドラパルトのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのドラゴンアロー
  await tapMove(driver, op, 'ドラゴンアロー', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルのどくげしょう
  await addEffect(driver, 2, me, 'どくげしょう');
  await driver.tap(find.text('OK'));
  // ドラパルトのいのちのたま
  await addEffect(driver, 3, op, 'いのちのたま');
  await driver.tap(find.text('OK'));
  // キラフロルひんし->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // フォレトスのHP60
  await inputRemainHP(driver, op, '60');
  // フォレトスのあまごい
  await tapMove(driver, me, 'あまごい', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのみがわり
  await tapMove(driver, op, 'みがわり', true);
  // フォレトスのボルトチェンジ
  await tapMove(driver, me, 'ボルトチェンジ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ドラパルトのHP25
  await inputRemainHP(driver, op, '25');
  // ドラパルトのHP50
  await inputRemainHP(driver, me, '50');
  // フローゼルに交代
  await changePokemon(driver, me, 'フローゼル', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // フローゼルのウェーブタックル
  await tapMove(driver, me, 'ウェーブタックル', false);
  await driver.tap(find.byValueKey('SubstituteInputOwn'));
  // ドラパルトのHP50
  await inputRemainHP(driver, me, '');
  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // フローゼルのHP154
  await inputRemainHP(driver, me, '154');
  // フローゼルのHP0
  await inputRemainHP(driver, op, '0');
  // フローゼルひんし->フォレトスに交代
  await changePokemon(driver, me, 'フォレトス', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // フォレトスのHP0
  await inputRemainHP(driver, op, '0');
  // 相手の勝利
  await testExistEffect(driver, 'れジぇんドの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// キラフロル戦4
Future<void> test38_4(
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
    battleName: 'もこうキラフロル戦4',
    ownPartyname: '38もこフロル',
    opponentName: 'セナ',
    pokemon1: 'ラウドボーン',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'キョジオーン',
    pokemon4: 'デカヌチャン',
    pokemon5: 'ドラパルト',
    pokemon6: 'マスカーニャ',
    sex3: Sex.female,
    sex4: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'オモダカさん/',
      ownPokemon2: 'ねつじょう/',
      ownPokemon3: 'もこ炎マリルリ/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // キラフロルのHP92
  await inputRemainHP(driver, op, '92');
  // ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // キラフロルのパワージェム
  await tapMove(driver, me, 'パワージェム', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ドラパルトのHP15
  await inputRemainHP(driver, me, '15');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのパワージェム
  await tapMove(driver, me, 'パワージェム', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ドラパルトひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのパワージェム
  await tapMove(driver, me, 'パワージェム', false);
  // ロトムのHP45
  await inputRemainHP(driver, me, '45');
  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // マリルリのHP166
  await inputRemainHP(driver, op, '166');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ロトムのHP5
  await inputRemainHP(driver, me, '5');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ロトムのハイドロポンプ
  await tapMove(driver, op, 'ハイドロポンプ', false);
  // マリルリのHP133
  await inputRemainHP(driver, op, '133');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // ロトムひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ラウドボーンのあくび
  await tapMove(driver, op, 'あくび', true);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ヘルガー->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', true);
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // マリルリのHP112
  await inputRemainHP(driver, op, '112');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ヘルガーに交代
  await changePokemon(driver, me, 'ヘルガー', true);
  // ラウドボーンのあくび
  await tapMove(driver, op, 'あくび', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ヘルガーのかえんほうしゃ
  await tapMove(driver, me, 'かえんほうしゃ', false);
  // ラウドボーンのHP60
  await inputRemainHP(driver, me, '60');
  // ラウドボーンのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ヘルガーのHP61
  await inputRemainHP(driver, op, '61');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのテラバースト
  await tapMove(driver, op, 'テラバースト', false);
  // ヘルガーのHP0
  await inputRemainHP(driver, op, '0');
  // ヘルガーひんし->マリルリに交代
  await changePokemon(driver, me, 'マリルリ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // マリルリのテラスタル
  await inputTerastal(driver, me, '');
  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP100
  await inputRemainHP(driver, op, '100');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ラウドボーンのHP70
  await inputRemainHP(driver, me, '70');
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのあくび
  await tapMove(driver, op, 'あくび', false);
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンはぼうぎょが下がった
  await driver.tap(find.text('ラウドボーンはぼうぎょが下がった'));
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのなまける
  await tapMove(driver, op, 'なまける', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ラウドボーンのHP80
  await inputRemainHP(driver, op, '80');
  // マリルリのじゃれつく
  await tapMove(driver, me, 'じゃれつく', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンはこうげきが下がった
  await driver.tap(find.text('ラウドボーンはこうげきが下がった'));
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // マリルリのHP78
  await inputRemainHP(driver, op, '78');
  await driver.tap(
      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // マリルリのHP36
  await inputRemainHP(driver, op, '36');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // 急所に命中
  await tapCritical(driver, me);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ポットデス戦1
Future<void> test39_1(
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
    battleName: 'もこうポットデス戦1',
    ownPartyname: '39もこトデス',
    opponentName: 'ぽいこ',
    pokemon1: 'ブラッキー',
    pokemon2: 'ドラパルト',
    pokemon3: 'コータス',
    pokemon4: 'ロトム(ウォッシュロトム)',
    pokemon5: 'ガブリアス',
    pokemon6: 'ゲンガー',
    sex2: Sex.female,
    sex3: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこトデス/',
      ownPokemon2: 'もこニバル/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'コータス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // コータスのひでり
  await addEffect(driver, 0, op, 'ひでり');
  await driver.tap(find.text('OK'));
  // コータス->ブラッキーに交代
  await changePokemon(driver, op, 'ブラッキー', true);
  // ポットデスのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのテラスタル
  await inputTerastal(driver, me, '');
  // ポットデスのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ブラッキーのHP0
  await inputRemainHP(driver, me, '0');
  // ブラッキーひんし->ゲンガーに交代
  await changePokemon(driver, op, 'ゲンガー', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのアシストパワー
  await tapMove(driver, me, 'アシストパワー', false);
  // ゲンガーのHP1
  await inputRemainHP(driver, me, '1');
  // ゲンガーのきあいのタスキ
  await addEffect(driver, 1, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ゲンガーののろわれボディ
  await addEffect(driver, 2, op, 'のろわれボディ');
  await driver.tap(find.byValueKey('EffectMoveField'));
  await driver.enterText('アシストパワー');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  await driver.tap(find.text('OK'));
  // ゲンガーのヘドロばくだん
  await tapMove(driver, op, 'ヘドロばくだん', true);
  // ポットデスのHP25
  await inputRemainHP(driver, op, '25');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ポットデス戦2
Future<void> test39_2(
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
    battleName: 'もこうポットデス戦2',
    ownPartyname: '39もこトデス',
    opponentName: 'ふじ',
    pokemon1: 'ロトム(ウォッシュロトム)',
    pokemon2: 'カバルドン',
    pokemon3: 'サーフゴー',
    pokemon4: 'ウルガモス',
    pokemon5: 'セグレイブ',
    pokemon6: 'ハッサム',
    sex4: Sex.female,
    sex5: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニバル/',
      ownPokemon2: 'もこッサン/',
      ownPokemon3: 'もこトデス/',
      opponentPokemon: 'ロトム(ウォッシュロトム)');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバル->イエッサンに交代
  await changePokemon(driver, me, 'イエッサン(メスのすがた)', true);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // イエッサンのHP86
  await inputRemainHP(driver, op, '86');
  // ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // イエッサンのリフレクター
  await tapMove(driver, me, 'リフレクター', false);
  // ハッサムのとんぼがえり
  await tapMove(driver, op, 'とんぼがえり', true);
  // イエッサンのHP0
  await inputRemainHP(driver, op, '0');
  // ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // イエッサンひんし->ポットデスに交代
  await changePokemon(driver, me, 'ポットデス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // ロトムのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // ポットデスのHP30
  await inputRemainHP(driver, op, '30');
  // ハッサムに交代
  await changePokemon(driver, op, 'ハッサム', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのシャドーボール
  await tapMove(driver, me, 'シャドーボール', false);
  // ハッサムのHP0
  await inputRemainHP(driver, me, '0');
  // ハッサムひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'じめん');
  // ポットデスのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // セグレイブのHP2
  await inputRemainHP(driver, me, '2');
  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 2回命中
  await setHitCount(driver, op, 2);
  // ポットデスのHP0
  await inputRemainHP(driver, op, '0');
  // ポットデスひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのじしん
  await tapMove(driver, op, 'じしん', true);
  // ウェーニバルのHP95
  await inputRemainHP(driver, op, '95');
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // セグレイブひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ロトムのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ポットデス戦3
Future<void> test39_3(
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
    battleName: 'もこうポットデス戦3',
    ownPartyname: '39もこトデス',
    opponentName: 'ずじゃく',
    pokemon1: 'クエスパトラ',
    pokemon2: 'ロトム(ウォッシュロトム)',
    pokemon3: 'ノココッチ',
    pokemon4: 'ドオー',
    pokemon5: 'ドドゲザン',
    pokemon6: 'ドラパルト',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこトデス/',
      ownPokemon2: 'もこニバル/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'クエスパトラ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', true);
  // ポットデスのHP87
  await inputRemainHP(driver, op, '87');
  // ポットデスのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // クエスパトラのかそく
  await addEffect(driver, 2, op, 'かそく');
  await driver.tap(find.text('OK'));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ポットデスのHP0
  await inputRemainHP(driver, op, '0');
  // ポットデスひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ボーマンダのHP84
  await inputRemainHP(driver, op, '84');
  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // クエスパトラのHP10
  await inputRemainHP(driver, me, '10');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのテラスタル
  await inputTerastal(driver, me, '');
  // クエスパトラのルミナコリジョン
  await tapMove(driver, op, 'ルミナコリジョン', false);
  // ウェーニバルのHP65
  await inputRemainHP(driver, op, '65');
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // クエスパトラのHP0
  await inputRemainHP(driver, me, '0');
  // クエスパトラひんし->ロトムに交代
  await changePokemon(driver, op, 'ロトム(ウォッシュロトム)', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ロトムのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // あなた降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOwn'));

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ポットデス戦4
Future<void> test39_4(
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
    battleName: 'もこうポットデス戦4',
    ownPartyname: '39もこトデス2',
    opponentName: 'ナッツ',
    pokemon1: 'ゲンガー',
    pokemon2: 'コノヨザル',
    pokemon3: 'ドドゲザン',
    pokemon4: 'ジバコイル',
    pokemon5: 'ヘイラッシャ',
    pokemon6: 'カイリュー',
    sex1: Sex.female,
    sex2: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこトデス/',
      ownPokemon3: 'もこニバル/',
      opponentPokemon: 'ジバコイル');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', true);
  // ミミズズのHP44
  await inputRemainHP(driver, op, '44');
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', false);
  // ミミズズのHP0
  await inputRemainHP(driver, op, '0');
  // ミミズズひんし->ウェーニバルに交代
  await changePokemon(driver, me, 'ウェーニバル', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのテラスタル
  await inputTerastal(driver, me, '');
  // ウェーニバルのアクアステップ
  await tapMove(driver, me, 'アクアステップ', false);
  // ジバコイルのHP60
  await inputRemainHP(driver, me, '60');
  // ジバコイルの１０まんボルト
  await tapMove(driver, op, '１０まんボルト', false);
  // ウェーニバルのHP72
  await inputRemainHP(driver, op, '72');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ウェーニバルのインファイト
  await tapMove(driver, me, 'インファイト', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ジバコイルひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのインファイト
  await tapMove(driver, op, 'インファイト', true);
  // ウェーニバルのHP0
  await inputRemainHP(driver, op, '0');
  // ウェーニバルひんし->ポットデスに交代
  await changePokemon(driver, me, 'ポットデス', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // コノヨザル->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // ポットデスのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // カイリューのテラスタル
  await inputTerastal(driver, op, 'ノーマル');
  // ポットデスのアシストパワー
  await tapMove(driver, me, 'アシストパワー', false);
  // 急所に命中
  await tapCritical(driver, me);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->コノヨザルに交代
  await changePokemon(driver, op, 'コノヨザル', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // コノヨザルのシャドークロー
  await tapMove(driver, op, 'シャドークロー', true);
  // ポットデスのHP1
  await inputRemainHP(driver, op, '1');
  // ポットデスのきあいのタスキ
  await addEffect(driver, 2, me, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ポットデスのシャドーボール
  await tapMove(driver, me, 'シャドーボール', false);
  // コノヨザルのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ポットデス戦5
Future<void> test39_5(
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
    battleName: 'もこうポットデス戦5',
    ownPartyname: '39もこトデス2',
    opponentName: 'RGB',
    pokemon1: 'カイリュー',
    pokemon2: 'ハピナス',
    pokemon3: 'キョジオーン',
    pokemon4: 'ヘイラッシャ',
    pokemon5: 'クレベース',
    pokemon6: 'モロバレル',
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
      ownPokemon1: 'もこミミズ/',
      ownPokemon2: 'もこトデス/',
      ownPokemon3: 'もこヒートロトム/',
      opponentPokemon: 'ハピナス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ハピナス->カイリューに交代
  await changePokemon(driver, op, 'カイリュー', true);
  // ミミズズのステルスロック
  await tapMove(driver, me, 'ステルスロック', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // カイリューのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ミミズズのしっぽきり
  await tapMove(driver, me, 'しっぽきり', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOwn'));
  // ミミズズのHP88
  await inputRemainHP(driver, me, '88');
  // ポットデスに交代
  await changePokemon(driver, me, 'ポットデス', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // カイリューのほのおのパンチ
  await tapMove(driver, op, 'ほのおのパンチ', true);
  await driver.tap(find.byValueKey('SubstituteInputOpponent'));
  // ポットデスのHP148
  await inputRemainHP(driver, op, '');
  // ポットデスのシャドーボール
  await tapMove(driver, me, 'シャドーボール', false);
  // カイリューのHP85
  await inputRemainHP(driver, me, '85');
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // カイリューのでんじは
  await tapMove(driver, op, 'でんじは', true);
  // ポットデスのからをやぶる
  await tapMove(driver, me, 'からをやぶる', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP100
  await inputRemainHP(driver, op, '100');
  // ポットデスのアシストパワー
  await tapMove(driver, me, 'アシストパワー', false);
  // カイリューのHP50
  await inputRemainHP(driver, me, '50');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // カイリューのはねやすめ
  await tapMove(driver, op, 'はねやすめ', false);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // カイリューのHP99
  await inputRemainHP(driver, op, '99');
  // ポットデスのアシストパワー
  await tapMove(driver, me, 'アシストパワー', false);
  // カイリューのHP0
  await inputRemainHP(driver, me, '0');
  // カイリューひんし->ハピナスに交代
  await changePokemon(driver, op, 'ハピナス', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ハピナスのテラスタル
  await inputTerastal(driver, op, 'あく');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ハピナスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', true);
  // ポットデスのHP111
  await inputRemainHP(driver, op, '111');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのテラスタル
  await inputTerastal(driver, me, '');
  // ポットデスのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ハピナスのHP35
  await inputRemainHP(driver, me, '35');
  // ハピナスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', false);
  // ポットデスのHP69
  await inputRemainHP(driver, op, '69');
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ハピナスのタマゴうみ
  await tapMove(driver, op, 'タマゴうみ', true);
  await driver.tap(find.byValueKey('StatusMoveNextButtonOpponent'));
  // ハピナスのHP85
  await inputRemainHP(driver, op, '85');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ハピナスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', false);
  // ポットデスのHP28
  await inputRemainHP(driver, op, '28');
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ポットデスのテラバースト
  await tapMove(driver, me, 'テラバースト', false);
  // ハピナスのHP30
  await inputRemainHP(driver, me, '30');
  // ハピナスのかえんほうしゃ
  await tapMove(driver, op, 'かえんほうしゃ', false);
  // ポットデスのHP0
  await inputRemainHP(driver, op, '0');
  // ポットデスひんし->ロトムに交代
  await changePokemon(driver, me, 'ロトム(ヒートロトム)', false);
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ロトムのオーバーヒート
  await tapMove(driver, me, 'オーバーヒート', false);
  // ハピナスのHP0
  await inputRemainHP(driver, me, '0');
  // ハピナスひんし->ヘイラッシャに交代
  await changePokemon(driver, op, 'ヘイラッシャ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // あいて降参
  await driver.tap(find.byValueKey('BattleActionCommandSurrenderOpponent'));
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ゴーゴート戦1
Future<void> test40_1(
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
    battleName: 'もこうゴーゴート戦1',
    ownPartyname: '40もこーゴート',
    opponentName: 'ケーロン',
    pokemon1: 'ドラパルト',
    pokemon2: 'セグレイブ',
    pokemon3: 'ジバコイル',
    pokemon4: 'マリルリ',
    pokemon5: 'ラウドボーン',
    pokemon6: 'カイリュー',
    sex1: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーゴート/',
      ownPokemon2: 'もこニンフィア2/',
      ownPokemon3: 'オモダカさん/',
      opponentPokemon: 'ドラパルト');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴート->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // ドラパルトのおにび
  await tapMove(driver, op, 'おにび', true);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', true);
  // ニンフィアのHP117
  await inputRemainHP(driver, op, '117');
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ドラパルトのHP1
  await inputRemainHP(driver, me, '1');
  // ドラパルトのきあいのタスキ
  await addEffect(driver, 2, op, 'きあいのタスキ');
  await driver.tap(find.text('OK'));
  // ドラパルトののろわれボディ
  await addEffect(driver, 4, op, 'のろわれボディ');
  await driver.tap(find.byValueKey('EffectMoveField'));
  await driver.enterText('ハイパーボイス');
  await driver.tap(find.ancestor(
      of: find.text('ハイパーボイス'), matching: find.byType('ListTile')));
  await driver.tap(find.text('OK'));
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ドラパルト->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // ニンフィアのひかりのかべ
  await tapMove(driver, me, 'ひかりのかべ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ゴーゴートに交代
  await changePokemon(driver, me, 'ゴーゴート', true);
  // ジバコイルのラスターカノン
  await tapMove(driver, op, 'ラスターカノン', true);
  // ゴーゴートのHP148
  await inputRemainHP(driver, op, '148');
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ジバコイルのテラスタル
  await inputTerastal(driver, op, 'みず');
  // ゴーゴートのじしん
  await tapMove(driver, me, 'じしん', false);
  // ジバコイルのHP75
  await inputRemainHP(driver, me, '75');
  // ジバコイルのボルトチェンジ
  await tapMove(driver, op, 'ボルトチェンジ', false);
  // ゴーゴートのHP121
  await inputRemainHP(driver, op, '121');
  // セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ジバコイルに交代
  await changePokemon(driver, op, 'ジバコイル', true);
  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ジバコイルのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのHP183
  await inputRemainHP(driver, me, '183');
  // ジバコイルひんし->ドラパルトに交代
  await changePokemon(driver, op, 'ドラパルト', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ドラパルトのおにび
  await tapMove(driver, op, 'おにび', false);
  // ゴーゴートのラムのみ
  await addEffect(driver, 1, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ドラパルトのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのHP184
  await inputRemainHP(driver, me, '184');
  // ドラパルトひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', false);
  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのきょけんとつげき
  await tapMove(driver, op, 'きょけんとつげき', true);
  // ゴーゴートのHP79
  await inputRemainHP(driver, op, '79');
  // ゴーゴートのじしん
  await tapMove(driver, me, 'じしん', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ゴーゴート戦2
Future<void> test40_2(
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
    battleName: 'もこうゴーゴート戦2',
    ownPartyname: '40もこーゴート',
    opponentName: 'ハスミ',
    pokemon1: 'ドラパルト',
    pokemon2: 'オリーヴァ',
    pokemon3: 'ガブリアス',
    pokemon4: 'エルレイド',
    pokemon5: 'セグレイブ',
    pokemon6: 'ハピナス',
    sex1: Sex.female,
    sex2: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこニンフィア2/',
      ownPokemon2: 'もこーゴート/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'ガブリアス');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのテラスタル
  await inputTerastal(driver, op, 'はがね');
  // ガブリアスのステルスロック
  await tapMove(driver, op, 'ステルスロック', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ガブリアスのHP90
  await inputRemainHP(driver, me, '90');
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ガブリアスのじならし
  await tapMove(driver, op, 'じならし', true);
  // ニンフィアのHP156
  await inputRemainHP(driver, op, '156');
  // ニンフィアのあくび
  await tapMove(driver, me, 'あくび', false);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ガブリアス->ハピナスに交代
  await changePokemon(driver, op, 'ハピナス', true);
  // ニンフィア->ゴーゴートに交代
  await changePokemon(driver, me, 'ゴーゴート', true);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ハピナス->ガブリアスに交代
  await changePokemon(driver, op, 'ガブリアス', true);
  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのじしん
  await tapMove(driver, me, 'じしん', false);
  // ガブリアスのHP25
  await inputRemainHP(driver, me, '25');
  // ガブリアスのドラゴンテール
  await tapMove(driver, op, 'ドラゴンテール', true);
  // ゴーゴートのHP145
  await inputRemainHP(driver, op, '145');
  // ボーマンダに交代
  await changePokemon(driver, op, 'ボーマンダ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // ガブリアスのHP0
  await inputRemainHP(driver, me, '0');
  // ガブリアスひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダ->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', true);
  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', true);
  // ニンフィアのHP95
  await inputRemainHP(driver, op, '95');
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // セグレイブ->ハピナスに交代
  await changePokemon(driver, op, 'ハピナス', true);
  // ニンフィアのハイパーボイス
  await tapMove(driver, me, 'ハイパーボイス', false);
  // ハピナスのHP90
  await inputRemainHP(driver, me, '90');
  // セグレイブのたべのこし
  await addEffect(driver, 2, op, 'たべのこし');
  await driver.tap(find.text('OK'));
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ニンフィア->ゴーゴートに交代
  await changePokemon(driver, me, 'ゴーゴート', true);
  // ハピナスのでんじは
  await tapMove(driver, op, 'でんじは', true);
  // ニンフィアのラムのみ
  await addEffect(driver, 3, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ハピナスのでんじは
  await tapMove(driver, op, 'でんじは', false);
  // ターン11へ
  await goTurnPage(driver, turnNum++);

  // ハピナスのれいとうビーム
  await tapMove(driver, op, 'れいとうビーム', true);
  // ゴーゴートのHP23
  await inputRemainHP(driver, op, '23');
  await driver.tap(
      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));
  // ターン12へ
  await goTurnPage(driver, turnNum++);

  // ハピナスのれいとうビーム
  await tapMove(driver, op, 'れいとうビーム', false);
  // ゴーゴートのHP0
  await inputRemainHP(driver, op, '0');
  // ゴーゴートひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン13へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのテラスタル
  await inputTerastal(driver, me, '');
  // ボーマンダのりゅうのまい
  await tapMove(driver, me, 'りゅうのまい', false);
  // ハピナスのれいとうビーム
  await tapMove(driver, op, 'れいとうビーム', false);
  // ボーマンダのHP43
  await inputRemainHP(driver, op, '43');
  // ターン14へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // ハピナスのHP20
  await inputRemainHP(driver, me, '20');
  // ハピナスのでんじは
  await tapMove(driver, op, 'でんじは', false);
  await tapSuccess(driver, op);
  // ターン15へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのじしん
  await tapMove(driver, me, 'じしん', false);
  // ハピナスのHP0
  await inputRemainHP(driver, me, '0');
  // ハピナスひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン16へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのこおりのつぶて
  await tapMove(driver, op, 'こおりのつぶて', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // ボーマンダひんし->ニンフィアに交代
  await changePokemon(driver, me, 'ニンフィア', false);
  // ターン17へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのつららばり
  await tapMove(driver, op, 'つららばり', true);
  // 4回命中
  await setHitCount(driver, op, 4);
  // ニンフィアのHP0
  await inputRemainHP(driver, op, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ゴーゴート戦3
Future<void> test40_3(
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
    battleName: 'もこうゴーゴート戦3',
    ownPartyname: '40もこーゴート2',
    opponentName: 'イトリス',
    pokemon1: 'サザンドラ',
    pokemon2: 'ガブリアス',
    pokemon3: 'イルカマン',
    pokemon4: 'アーマーガア',
    pokemon5: 'ラウドボーン',
    pokemon6: 'ドオー',
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこーゴート/',
      ownPokemon2: 'オモダカさん/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'イルカマン');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのクイックターン
  await tapMove(driver, op, 'クイックターン', true);
  // ゴーゴートのHP175
  await inputRemainHP(driver, op, '175');
  // ドオーに交代
  await changePokemon(driver, op, 'ドオー', false);
  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ドオーのあくび
  await tapMove(driver, op, 'あくび', true);
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのじしん
  await tapMove(driver, me, 'じしん', false);
  // ドオーのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのラムのみ
  await addEffect(driver, 2, me, 'ラムのみ');
  await driver.tap(find.text('OK'));
  // ドオーひんし->ラウドボーンに交代
  await changePokemon(driver, op, 'ラウドボーン', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴート->キラフロルに交代
  await changePokemon(driver, me, 'キラフロル', true);
  // ラウドボーンのテラスタル
  await inputTerastal(driver, op, 'フェアリー');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', true);
  // キラフロルのHP126
  await inputRemainHP(driver, op, '126');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // キラフロルのヘドロウェーブ
  await tapMove(driver, me, 'ヘドロウェーブ', false);
  // ラウドボーンのHP30
  await inputRemainHP(driver, me, '30');
  // ラウドボーンのだいちのちから
  await tapMove(driver, op, 'だいちのちから', true);
  // キラフロルのHP0
  await inputRemainHP(driver, op, '0');
  // キラフロルひんし->ゴーゴートに交代
  await changePokemon(driver, me, 'ゴーゴート', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ラウドボーンのHP2
  await inputRemainHP(driver, me, '2');
  // ゴーゴートのHP200
  await inputRemainHP(driver, me, '200');
  // ラウドボーンのフレアソング
  await tapMove(driver, op, 'フレアソング', false);
  // ゴーゴートのHP2
  await inputRemainHP(driver, op, '2');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ラウドボーンのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのHP5
  await inputRemainHP(driver, me, '5');
  // ラウドボーンひんし->イルカマンに交代
  await changePokemon(driver, op, 'イルカマン', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', true);
  // ゴーゴートのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP99
  await inputRemainHP(driver, op, '99');
  // ゴーゴートひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // ボーマンダのダブルウイング
  await tapMove(driver, me, 'ダブルウイング', false);
  // 1回急所
  await setCriticalCount(driver, me, 1);
  // イルカマンのHP40
  await inputRemainHP(driver, me, '40');
  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // ボーマンダのHP71
  await inputRemainHP(driver, op, '71');
  // イルカマンのHP20
  await inputRemainHP(driver, op, '20');
  // ターン10へ
  await goTurnPage(driver, turnNum++);

  // イルカマンのウェーブタックル
  await tapMove(driver, op, 'ウェーブタックル', false);
  // ボーマンダのHP0
  await inputRemainHP(driver, op, '0');
  // イルカマンのHP5
  await inputRemainHP(driver, op, '5');
  // 相手の勝利
  await testExistEffect(driver, 'イトリスの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

/// ゴーゴート戦4
Future<void> test40_4(
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
    battleName: 'もこうゴーゴート戦4',
    ownPartyname: '40もこーゴート2',
    opponentName: 'コンゴリラ',
    pokemon1: 'ニンフィア',
    pokemon2: 'ドラパルト',
    pokemon3: 'セグレイブ',
    pokemon4: 'クエスパトラ',
    pokemon5: 'マスカーニャ',
    pokemon6: 'アーマーガア',
    sex3: Sex.female,
    sex4: Sex.female,
    sex5: Sex.female,
    sex6: Sex.female,
  );
  // 選出ポケモン選択ページへ
  await goSelectPokemonPage(driver);
  // 選出ポケモンを選ぶ
  await selectPokemons(driver,
      ownPokemon1: 'もこ炎マリルリ/',
      ownPokemon2: 'もこーゴート/',
      ownPokemon3: 'もこ両刀マンダ/',
      opponentPokemon: 'マスカーニャ');
  // 各ターン入力画面へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', true);
  // マリルリのHP144
  await inputRemainHP(driver, op, '144');
  // マリルリのアクアブレイク
  await tapMove(driver, me, 'アクアブレイク', false);
  // マスカーニャのHP60
  await inputRemainHP(driver, me, '60');
  // マスカーニャはぼうぎょが下がった
  await driver.tap(find.text('マスカーニャはぼうぎょが下がった'));
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('とつげきチョッキ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('とつげきチョッキ')));
  // ターン2へ
  await goTurnPage(driver, turnNum++);

  // マリルリ->ゴーゴートに交代
  await changePokemon(driver, me, 'ゴーゴート', true);
  // マスカーニャのトリックフラワー
  await tapMove(driver, op, 'トリックフラワー', true);
  // ゴーゴートのHP211
  await inputRemainHP(driver, op, '');
  // ターン3へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // ゴーゴートのHP106
  await inputRemainHP(driver, op, '106');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('ラムのみ');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('ラムのみ')));
  // ゴーゴートのビルドアップ
  await tapMove(driver, me, 'ビルドアップ', false);
  // ターン4へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャ->ニンフィアに交代
  await changePokemon(driver, op, 'ニンフィア', true);
  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ニンフィアのHP10
  await inputRemainHP(driver, me, '10');
  // ゴーゴートのHP191
  await inputRemainHP(driver, me, '191');
  // ターン5へ
  await goTurnPage(driver, turnNum++);

  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // ニンフィアのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのHP202
  await inputRemainHP(driver, me, '202');
  // ニンフィアひんし->セグレイブに交代
  await changePokemon(driver, op, 'セグレイブ', false);
  // ターン6へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラスタル
  await inputTerastal(driver, op, 'でんき');
  // ゴーゴートのテラスタル
  await inputTerastal(driver, me, '');
  // セグレイブのりゅうのまい
  await tapMove(driver, op, 'りゅうのまい', true);
  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // セグレイブのHP35
  await inputRemainHP(driver, me, '35');
  // ゴーゴートのHP211
  await inputRemainHP(driver, me, '211');
  // ターン7へ
  await goTurnPage(driver, turnNum++);

  // セグレイブのテラバースト
  await tapMove(driver, op, 'テラバースト', true);
  // ゴーゴートのHP11
  await inputRemainHP(driver, op, '11');
  // ゴーゴートのウッドホーン
  await tapMove(driver, me, 'ウッドホーン', false);
  // セグレイブのHP0
  await inputRemainHP(driver, me, '0');
  // ゴーゴートのHP42
  await inputRemainHP(driver, me, '42');
  // セグレイブひんし->マスカーニャに交代
  await changePokemon(driver, op, 'マスカーニャ', false);
  // ターン8へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのふいうち
  await tapMove(driver, op, 'ふいうち', true);
  // ゴーゴートのHP0
  await inputRemainHP(driver, op, '0');
  // ゴーゴートひんし->ボーマンダに交代
  await changePokemon(driver, me, 'ボーマンダ', false);
  // ターン9へ
  await goTurnPage(driver, turnNum++);

  // マスカーニャのはたきおとす
  await tapMove(driver, op, 'はたきおとす', false);
  // ボーマンダのHP104
  await inputRemainHP(driver, op, '104');
  await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));
  await driver.enterText('いのちのたま');
  await driver.tap(find.descendant(
      of: find.byType('ListTile'), matching: find.text('いのちのたま')));
  // ボーマンダのだいもんじ
  await tapMove(driver, me, 'だいもんじ', false);
  // マスカーニャのHP0
  await inputRemainHP(driver, me, '0');
  // あなたの勝利
  await testExistEffect(driver, 'あなたの勝利！');

  // 内容保存
  await driver.tap(find.byValueKey('RegisterBattleSave'));
}

// テンプレ
/*
/// ゴーゴート戦1
Future<void> test40_1(
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
