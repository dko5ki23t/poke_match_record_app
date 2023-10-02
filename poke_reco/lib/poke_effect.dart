import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_move.dart';
import 'package:poke_reco/tool.dart';

class EffectType {
  static const int none = 0;
  static const int ability = 1;
  static const int item = 2;
  static const int individualField = 3;
  static const int ailment = 4;
  static const int weather = 5;
  static const int field = 6;
  static const int move = 7;
  static const int changeFaintingPokemon = 8;

  const EffectType(this.id);

  final int id;
}

class PlayerType {
  static const int none = 0;
  static const int me = 1;          // 自身
  static const int opponent = 2;    // 相手
  static const int entireField = 3; // 全体の場(両者に影響あり)

  const PlayerType(this.id);

  final int id;
}

// 各タイミング共通
const List<int> allTimingIDs = [
  6,      // ばくはつ系のわざ、とくせいが発動したとき
  7,      // まひするわざ、とくせいを受けた時
  12,     // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
  15,     // ねむり・ねむけの効果を受けた時
  16,     // どく・もうどくの効果を受けた時
  18,     // こんらん/いかくの効果を受けた時
  20,     // こうたいわざやレッドカードによるこうたいを強制されたとき
  22,     // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  23,     // 相手から受けた技でどく/まひ/やけど状態にされたとき
  24,     // 自身以外の効果によって能力変化が起きるとき
  32,     // ひるみやいかくを受けた時
  33,     // こおり状態になったとき
  34,     // やけど状態になったとき
  37,     // 命中率が下がるとき、こうげきするとき
  38,     // もちものを奪われたり失ったりするとき
  67,     // 自身以外の効果によってこうげきランクが下がるとき
  44,     // ひるんだとき
  77,     // いかくを受けた時
  85,     // 自身以外の効果によってぼうぎょランクが下がるとき
  87,     // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  89,     // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
];

// ポケモンを繰り出すとき
// とくせい
const List<int> pokemonAppearAbilityIDs = [
  256,    // かがくへんかガス
  127,    // きんちょうかん
  266,    // じんばいったい
  267,    // じんばいったい
  2,      // あめふらし
  22,     // いかく
  76,     // エアロック
  226,    // エレキメイカー
  188,    // オーラブレイク
  119,    // おみとおし
  190,    // おわりのだいち
  104,    // かたやぶり
  150,    // かわりもの
  107,    // きけんよち
  261,    // きみょうなくすり
  229,    // グラスメイカー
  227,    // サイコメイカー
  112,    // スロースタート
  45,     // すなおこし
  213,    // ぜったいねむり
  293,    // そうだいしょう
  186,    // ダークオーラ
  163,    // ターボブレイズ
  88,     // ダウンロード
  164,    // テラボルテージ
  191,    // デルタストリーム
  36,     // トレース
  13,     // ノーてんき
  189,    // はじまりのうみ
  289,    // ハドロンエンジン
  251,    // バリアフリー
  70,     // ひでり
  288,    // ひひいろのこどう
  187,    // フェアリーオーラ
  235,    // ふくつのたて
  234,    // ふとうのけん
  46,     // プレッシャー
  278,    // マイティチェンジ
  228,    // ミストメイカー
  117,    // ゆきふらし
  108,    // よちむ
  284,    // わざわいのうつわ
  286,    // わざわいのおふだ
  287,    // わざわいのたま
  285,    // わざわいのつるぎ
  7,      // じゅうなん
  199,    // すいほう
  270,    // ねつこうかん
  257,    // パステルベール
  15,     // ふみん
  40,     // マグマのよろい
  41,     // みずのベール
  17,     // めんえき
  72,     // やるき
  250,    // ぎたい
  208,    // ぎょぐん
  197,    // リミットシールド
  248,    // アイスフェイス
  294,    // きょうえん
  282,    // クォークチャージ
  281,    // こだいかっせい
  279,    // しれいとう
  59,     // てんきや
  122,    // フラワーギフト
  290,    // びんじょう
];
// もちもの
const List<int> pokemonAppearItemIDs = [
  126,      // クラボのみ	持たせるとまひを回復する
  127,      // カゴのみ	持たせると眠りを回復する
  128,      // モモンのみ	持たせるとどくを回復する
  129,      // チーゴのみ	持たせるとやけどを回復する
  130,      // ナナシのみ	持たせるとこおりを回復する
  131,      // ヒメリのみ	持たせるとPPを10回復する
  132,      // オレンのみ	持たせるとHPを10回復する
  133,      // キーのみ	持たせると混乱を回復する
  134,      // ラムのみ	持たせると全ての状態異常を回復する
  135,      // オボンのみ	持たせるとHPを少しだけ回復する
  136,      // フィラのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  137,      // ウイのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  138,      // マゴのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  139,      // バンジのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  140,      // イアのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  178,      // チイラのみ	持たせるとピンチの時に攻撃が上がる
  179,      // リュガのみ	持たせるとピンチの時に防御が上がる
  181,      // ヤタビのみ	持たせるとピンチの時に特攻が上がる
  182,      // ズアのみ	持たせるとピンチの時に特防が上がる
  180,      // カムラのみ	持たせるとピンチの時に素早さが上がる
  898,      // エレキシード
  901,      // グラスシード
  899,      // サイコシード
  900,      // ミストシード
  1180,     // ルームサービス
  1696,     // ブーストエナジー
  191,      // しろいハーブ
  1699,     // ものまねハーブ
  1177,     // だっしゅつパック
];
// ポケモンの場
const List<int> pokemonAppearFieldIDs = [
  IndividualField.healingWish,  // いやしのねがい
  IndividualField.lunarDance,   // みかづきのまい
  IndividualField.spikes,       // まきびし
  IndividualField.toxicSpikes,  // どくびし
  IndividualField.stealthRock,  // ステルスロック
  IndividualField.stickyWeb,    // ねばねばネット
];
// タイミング
const List<int> pokemonAppearTimingIDs = [
  1,      // ポケモン登場時
  76,     // ポケモン登場時(確率/条件)
];

// 行動決定直後
// とくせい
const List<int> afterActionDecisionAbilityIDs = [
  259,    // クイックドロウ
];
// もちもの
const List <int> afterActionDecisionItemIDs = [
  194,      // せんせいのツメ
  187,      // イバンのみ
];
// タイミング
const List<int> afterActionDecisionTimingIDs = [
];

// わざ使用後
// とくせい
const List<int> afterMoveAbilityIDs = [
  209,      // ばけのかわ
  248,      // アイスフェイス
  5,        // がんじょう
  157,      // そうしょく
  18,       // もらいび
  87,       // かんそうはだ
  114,      // よびみず
  11,       // ちょすい
  31,       // ひらいしん
  78,       // でんきエンジン
  10,       // ちくでん
  43,       // ぼうおん
  25,       // ふしぎなまもり
  142,      // ぼうじん
  143,      // どくしゅ
  106,      // ゆうばく
  215,      // とびだすなかみ
  28,       // シンクロ
  160,      // てつのトゲ
  24,       // さめはだ
  27,       // ほうし
  38,       // どくのトゲ
  9,        // せいでんき
  49,       // ほのおのからだ
  56,       // メロメロボディ
  152,      // ミイラ
  183,      // ぬめぬめ
  221,      // カーリーヘアー
  254,      // さまようたましい
  253,      // ほろびのボディ
  268,      // とれないにおい
  130,      // のろわれボディ
  149,      // イリュージョン
  192,      // じきゅうりょく
  245,      // すなはき
  238,      // わたげ
  241,      // うのミサイル
  269,      // こぼれダネ
  280,      // でんきにかえる
  133,      // くだけるよろい
  295,      // どくげしょう
  195,      // みずがため
  154,      // せいぎのこころ
  155,      // びびり
  243,      // じょうききかん
  277,      // ふうりょくでんき
  83,       // いかりのつぼ
  170,      // マジシャン
  153,      // じしんかじょう
  224,      // ビーストブースト
  265,      // くろのいななき
  264,      // しろのいななき
  16,       // へんしょく
  201,      // ぎゃくじょう
  271,      // いかりのこうら
//  547,      // いにしえのうた
  219,      // きずなへんげ
  194,      // ききかいひ
  193,      // にげごし
  124,      // わるいてぐせ
  7,        // じゅうなん
  199,      // すいほう
  12,       // どんかん
  270,      // ねつこうかん
  257,      // パステルベール
  15,       // ふみん
  201,      // マイペース
  40,       // マグマのよろい
  41,       // みずのベール
  17,       // めんえき
  72,       // やるき
  290,      // びんじょう
  216,      // おどりこ
];
// もちもの
const List<int> afterMoveItemIDs = [
  584,      // ふうせん
  252,      // きあいのタスキ
  207,      // きあいのハチマキ
  723,      // ロゼルのみ
  177,      // ホズのみ
  176,      // リリバのみ
  175,      // ナモのみ
  174,      // ハバンのみ
  173,      // カシブのみ
  172,      // ヨロギのみ
  171,      // タンガのみ
  170,      // ウタンのみ
  169,      // バコウのみ
  168,      // シュカのみ
  167,      // ビアーのみ
  166,      // ヨプのみ
  165,      // ヤチェのみ
  164,      // リンドのみ
  163,      // ソクノのみ
  162,      // イトケのみ
  161,      // オッカのみ
  185,      // ナゾのみ
  682,      // じゃくてんほけん
  589,      // じゅうでんち
  689,      // ゆきだま
  588,      // きゅうこん
  688,      // ひかりごけ
  583,      // ゴツゴツメット
  265,      // くっつきバリ
  584,      // ふうせん
  188,      // ジャポのみ
  189,      // レンブのみ
  724,      // アッキのみ
  725,      // タラプのみ
  590,      // だっしゅつボタン
  585,      // レッドカード
  247,      // いのちのたま
  230,      // かいがらのすず
  135,      // オボンのみ
  136,      // フィラのみ
  137,      // ウイのみ
  138,      // マゴのみ
  139,      // バンジのみ
  140,      // イアのみ
  178,      // チイラのみ
  179,      // リュガのみ
  181,      // ヤタピのみ
  182,      // ズアのみ
  180,      // カムラのみ
  183,      // サンのみ
  184,      // スターのみ
  186,      // ミクルのみ
  43,       // きのみジュース
  898,      // エレキシード
  901,      // グラスシード
  900,      // ミストシード
  899,      // サイコシード
  1180,     // ルームサービス
  131,      // ヒメリのみ
  1176,     // のどスプレー
  1179,     // からぶりほけん
  191,      // しろいハーブ
  1699,     // ものまねハーブ
  1177,     // だっしゅつパック
];
// タイミング
const List<int> afterMoveAttackerTimingIDs = [
  3,      // こうげきし、相手にあたったとき(確率)
  14,     // わざを使うとき(確率・条件)
];
const List<int> afterMoveDefenderTimingIDs = [
  5,      // HPが満タンでこうげきを受けた時
  47,     // こうげきが急所に当たった時
];

// 毎ターン終了時
// とくせい
const List<int> everyTurnEndAbilityIDs = [
  87,           // かんそうはだ
  94,           // サンパワー
  44,           // あめうけざら
  115,          // アイスボディ
  194,          // ききかいひ
  193,          // にげごし
  93,           // うるおいボディ
  61,           // だっぴ
  131,          // いやしのこころ
  392,          // アクアリング
  90,           // ポイズンヒール
  3,            // かそく
  141,          // ムラっけ
  112,          // スロースタート
  123,          // ナイトメア
  291,          // はんすう
  53,           // ものひろい
  139,          // しゅうかく
  237,          // たまひろい
  161,          // ダルマモード
  197,          // リミットシールド
  211,          // スワームチェンジ
  208,          // ぎょぐん
  258,          // はらぺこスイッチ
];
// もちもの
const List<int> everyTurnEndItemIDs = [
  211,      // たべのこし
  258,      // くろいヘドロ
  265,      // くっつきバリ
  249,      // どくどくだま
  250,      // かえんだま
  191,      // しろいハーブ
  1177,     // だっしゅつパック
];
// 状態異常
const List<int> everyTurnEndAilmentIDs = [
  Ailment.leechSeed,          // やどりぎのタネ
  Ailment.poison,             // どく
  Ailment.badPoison,          // もうどく
  Ailment.burn,               // やけど
  Ailment.nightmare,          // あくむ
  Ailment.curse,              // のろい
  Ailment.partiallyTrapped,   // バインド
  Ailment.saltCure,           // しおづけ
  Ailment.taunt,              // ちょうはつ終了
  Ailment.torment,            // いちゃもん終了
  Ailment.encore,             // アンコール終了
  Ailment.disable,            // かなしばり終了
  Ailment.magnetRise,         // でんじふゆう終了
  Ailment.telekinesis,        // テレキネシス終了
  Ailment.healBlock,          // かいふくふうじ終了
  Ailment.embargo,            // さしおさえ終了
  Ailment.sleepy,             // ねむけによるねむり
  Ailment.perishSong,         // ほろびのうた
  Ailment.ingrain,            // ねをはる
  Ailment.uproar,             // さわぐ終了
];
// 天気
const List<int> everyTurnEndWeatherIDs = [
  Weather.sunny,            // 晴れ終了
  Weather.rainy,            // あめ終了
  Weather.sandStorm,        // すなあらし終了
  Weather.snowy,            // ゆき終了
];
// ポケモンの場
const List<int> everyTurnEndIndividualFieldIDs = [
  IndividualField.sandStormDamage,    // すなあらしによるダメージ
  IndividualField.futureAttack,       // みらいにこうげき
  IndividualField.futureAttackSteel,  // はめつのねがい
  IndividualField.grassFieldRecovery, // グラスフィールドによる回復
  IndividualField.reflector,          // リフレクター終了
  IndividualField.lightScreen,        // ひかりのかべ終了
  IndividualField.safeGuard,          // しんぴのまもり
  IndividualField.mist,               // しろいきり終了
  IndividualField.tailwind,           // おいかぜ終了
  IndividualField.luckyChant,         // おまじない終了
  IndividualField.auroraVeil,         // オーロラベール終了
];
// フィールド
const List<int> everyTurnEndFieldIDs = [
  Field.trickRoom,      // トリックルーム終了
//  Field.gravity,        // じゅうりょく終了
  Field.waterSport,     // みずあそび終了
  Field.mudSport,       // どろあそび終了
  Field.wonderRoom,     // ワンダールーム終了
  Field.magicRoom,      // マジックルーム終了
  Field.electricTerrain,// エレキフィールド終了
  Field.grassyTerrain,  // グラスフィールド終了
  Field.mistyTerrain,   // ミストフィールド終了
  Field.psychicTerrain, // サイコフィールド終了
];
// タイミング
const List<int> everyTurnEndTimingIDs = [
  4,      // 毎ターン終了時
  70,     // 毎ターン終了時（確率）
];

class TurnEffect {
  PlayerType playerType = PlayerType(PlayerType.none);
  AbilityTiming timing = AbilityTiming(AbilityTiming.none);
  EffectType effect = EffectType(EffectType.none);
  int effectId = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;
  TurnMove? move;         // タイプがわざの場合は非null
  bool isAdding = false;  // trueの場合、追加待ち状態
  bool isOwnFainting = false;   // このフェーズで自身のポケモンがひんしになるかどうか
  bool isOpponentFainting = false;
  bool isMyWin = false;   // 自身の勝利（両方勝利の場合は引き分け）
  bool isYourWin = false;

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..timing = AbilityTiming(timing.id)
    ..effect = effect
    ..effectId = effectId
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2
    ..move = move?.copyWith()
    ..isAdding = isAdding
    ..isOwnFainting = isOwnFainting
    ..isOpponentFainting = isOpponentFainting
    ..isMyWin = isMyWin
    ..isYourWin = isYourWin;

  bool isValid() {
    return
      playerType.id != PlayerType.none &&
      effect.id != EffectType.none &&
      (effect.id == EffectType.move && move != null && move!.isValid() || effectId > 0);
  }

  bool nearEqual(TurnEffect other) {
    return playerType.id == other.playerType.id &&
      timing.id == other.timing.id &&
      effect.id == other.effect.id &&
      effectId == other.effectId;
  }

  // processEffect前処理
  /*
  void preprocessEffect(
    List<TurnEffect> phases,
    int index,
  )
  {
    if (!isValid()) return;

    int prevMoveIdx = index;
    for (int i = index-1; i >= 0; i--) {    // 直前のわざのインデックスを探す
      if ((phases[i].timing.id == AbilityTiming.action || phases[i].timing.id == AbilityTiming.continuousMove) &&
          phases[i].effect.id == EffectType.move)
      {
        prevMoveIdx = i;
        break;
      }
    }

    switch (effect.id) {
      case EffectType.ability:
        switch (effectId) {
          case 209:   // ばけのかわ
            if (playerType.id == PlayerType.opponent) {   // ダメージは1/8にする(自身のダメージはゆーざの入力に任せる)
              phases[prevMoveIdx].move!.percentDamage = 12;
            }
            break;
          case 248:   // アイスフェイス
            if (playerType.id == PlayerType.opponent) {   // ダメージは0にする(自身のダメージはゆーざの入力に任せる)
              phases[prevMoveIdx].move!.percentDamage = 0;
            }
            break;
        }
    }
  }
  */

  // 効果やわざの結果から、各ポケモン等の状態を更新する
  List<String> processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentParty,
    PokemonState opponentPokemonState,
    PhaseState state,
    PokeDB pokeData,
    TurnEffect? prevAction,
    int continuousCount,
  )
  {
    List<String> ret = [];
    if (!isValid()) return ret;

    // もちもの失くした判定
    bool ownItemHolded = ownPokemonState.holdingItem != null;
    bool opponentItemHolded = opponentPokemonState.holdingItem != null;

    // ポケモン交代？
    bool isOwnChanged = false;
    bool isOpponentChanged = false;

    // ひんし判定
    bool alreadyOwnFainting = ownPokemonState.isFainting;
    bool alreadyOpponentFainting = opponentPokemonState.isFainting;

    var myState = ownPokemonState;
    var yourState = opponentPokemonState;
    if (playerType.id == PlayerType.opponent) {
      myState = opponentPokemonState;
      yourState = ownPokemonState;
    }
    var myParty = ownParty;
    var yourParty = opponentParty;
    if (playerType.id == PlayerType.opponent) {
      myParty = opponentParty;
      yourParty = ownParty;
    }
    var myPokemonIndex = state.ownPokemonIndex;
    var yourPokemonIndex = state.opponentPokemonIndex;
    if (playerType.id == PlayerType.opponent) {
      myPokemonIndex = state.opponentPokemonIndex;
      yourPokemonIndex = state.ownPokemonIndex;
    }
    var myPokemon = myParty.pokemons[myPokemonIndex-1];
    var yourPokemon = yourParty.pokemons[yourPokemonIndex-1];
    var myPlayerID = PlayerType.me;
    var yourPlayerID = PlayerType.opponent;
    if (playerType.id == PlayerType.opponent) {
      myPlayerID = PlayerType.opponent;
      yourPlayerID = PlayerType.me;
    }

    switch (effect.id) {
      case EffectType.ability:
        {
          switch (effectId) {
            case 1:     // あくしゅう
              yourState.ailmentsAdd(Ailment(Ailment.flinch), state.weather, state.field);  // ひるませる
              break;
            case 2:     // あめふらし
              state.weather = Weather(Weather.rainy);
              break;
            case 3:     // かそく
            case 78:    // でんきエンジン
            case 80:    // ふくつのこころ
            case 155:   // びびり
              myState.addStatChanges(true, 4, 1, abilityId: effectId);
              break;
            case 7:     // じゅうなん
              {   // まひになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 9:     // せいでんき
              yourState.ailmentsAdd(Ailment(Ailment.paralysis), state.weather, state.field);
              break;
            case 10:    // ちくでん
            case 11:    // ちょすい
            case 44:    // あめうけざら
            case 87:    // かんそうはだ
            case 90:    // ポイズンヒール
            case 94:    // サンパワー
            case 115:   // アイスボディ
              if (playerType.id == PlayerType.me) {
                myState.remainHP -= extraArg1;
              }
              else {
                myState.remainHPPercent -= extraArg1;
              }
              break;
            case 12:    // どんかん
              {
                // メロメロ/ちょうはつになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.infatuation);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
                findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.taunt);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 13:    // ノーてんき
            case 76:    // エアロック
              Weather.processWeatherEffect(state.weather, state.weather, myState, null);
              break;
            case 15:    // ふみん
            case 72:    // やるき
            case 175:   // スイートベール
              {   // ねむりになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.sleep || element.id == Ailment.sleepy);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 16:    // へんしょく
              {
                myState.pokemon.type1 = PokeType.createFromId(extraArg1);
                myState.pokemon.type2 = null;
              }
              break;
            case 17:    // めんえき
              {   // どく/もうどくになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.poison);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
                findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 18:    // もらいび
              {   // ほのおわざ威力1.5倍
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.flashFired);
                if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.flashFired));
              }
              break;
            case 20:    // マイペース
              {   // こんらんになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.confusion);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 22:    // いかく
              yourState.addStatChanges(false, 0, -1, abilityId: effectId);
              break;
            case 24:    // さめはだ
            case 106:   // ゆうばく
            case 123:   // ナイトメア
            case 160:   // てつのトゲ
              if (yourPlayerID == PlayerType.me) {
                yourState.remainHP -= extraArg1;
              }
              else {
                yourState.remainHPPercent -= extraArg1;
              }
              break;
            case 27:    // ほうし
              if (extraArg1 != 0) {
                yourState.ailmentsAdd(Ailment(extraArg1), state.weather, state.field);
              }
              break;
            case 28:    // シンクロ
              {
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.poison);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
                if (findIdx >= 0) yourState.ailmentsAdd(myState.ailments(findIdx), state.weather, state.field);
              }
              break;
            case 31:    // ひらいしん
            case 114:   // よびみず
              myState.addStatChanges(true, 2, 1, abilityId: effectId);
              break;
            case 36:    // トレース
              {
                if (playerType.id == PlayerType.opponent && myState.currentAbility.id == 0) {
                  myState.pokemon.ability = pokeData.abilities[effectId]!;
                  myState.currentAbility = myState.pokemon.ability;   // とくせい確定
                  ret.add('とくせいを${myState.currentAbility.displayName}で確定しました。');
                }
                myState.currentAbility = pokeData.abilities[extraArg1]!;
                if (playerType.id == PlayerType.me && yourState.currentAbility.id == 0) {
                  yourState.pokemon.ability = pokeData.abilities[extraArg1]!;
                  yourState.currentAbility = yourState.pokemon.ability;   // とくせい確定
                  ret.add('とくせいを${yourState.currentAbility.displayName}で確定しました。');
                }
                myState.processPassiveEffect(myPlayerID == PlayerType.me, state.weather, state.field);
              }
              break;
            case 38:    // どくのトゲ
            case 143:   // どくしゅ
              yourState.ailmentsAdd(Ailment(Ailment.poison), state.weather, state.field);
              break;
            case 40:    // マグマのよろい
              {   // こおりになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.freeze);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 41:    // みずのベール
              {   // やけどになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 45:    // すなおこし
              state.weather = Weather(Weather.sandStorm);
              break;
            case 49:    // ほのおのからだ
              yourState.ailmentsAdd(Ailment(Ailment.burn), state.weather, state.field);
              break;
            case 53:    // ものひろい
            case 139:   // しゅうかく
              myState.holdingItem = pokeData.items[extraArg1];
              break;
            case 56:    // メロメロボディ
              yourState.ailmentsAdd(Ailment(Ailment.infatuation), state.weather, state.field);
              break;
            case 61:    // だっぴ
            case 93:    // うるおいボディ
              {   // まひ/こおり/やけど/どく/もうどく/ねむりになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id <= Ailment.sleep);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 70:     // ひでり
              state.weather = Weather(Weather.sunny);
              break;
            case 83:    // いかりのつぼ
              myState.addStatChanges(true, 0, 6, abilityId: effectId);
              break;
            case 88:    // ダウンロード
              myState.addStatChanges(true, extraArg1, 1, abilityId: effectId);
              break;
            case 108:   // よちむ
              // わざ確定
              {
                var tmp = opponentPokemonState.moves.where(
                      (element) => element.id != 0 && element.id == extraArg1
                    );
                if (extraArg1 != 165 &&     // わるあがきは除外
                    myPlayerID == PlayerType.me &&
                    opponentPokemonState.moves.length < 4 &&
                    tmp.isEmpty
                ) {
                  opponentPokemonState.moves.add(pokeData.moves[extraArg1]!);
                  ret.add('わざの1つを${pokeData.moves[extraArg1]!.displayName}で確定しました。');
                }
              }
              break;
            case 112:   // スロースタート
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackSpeed0_5));
              break;
            case 117:     // ゆきふらし
              state.weather = Weather(Weather.snowy);
              break;
            case 119:     // おみとおし
              // もちもの確定
              {
                if (extraArg1 != 0 &&
                    myPlayerID == PlayerType.me &&
                    opponentPokemonState.holdingItem?.id == 0
                ) {
                  opponentPokemonState.holdingItem = pokeData.items[extraArg1]!;
                  ret.add('もちものを${pokeData.items[extraArg1]!.displayName}で確定しました。');
                }
              }
              break;
            case 124:     // わるいてぐせ
            case 170:     // マジシャン
              myState.holdingItem = pokeData.items[extraArg1]!;
              yourState.holdingItem = null;
              break;
            case 130:     // のろわれボディ
              yourState.ailmentsAdd(Ailment(Ailment.disable)..extraArg1 = extraArg1, state.weather, state.field);
              break;
            case 133:     // くだけるよろい
              myState.addStatChanges(true, 1, -1);
              myState.addStatChanges(true, 4, 2);
              break;
            case 141:     // ムラっけ
              myState.addStatChanges(true, extraArg1, 2);
              myState.addStatChanges(true, extraArg2, -1);
              break;
            case 152:   // ミイラ
              yourState.currentAbility = myState.currentAbility.copyWith();
              break;
            case 153:     // じしんかじょう
            case 154:     // せいぎのこころ
            case 157:     // そうしょく
              myState.addStatChanges(true, 0, 1, abilityId: effectId);
              break;
            case 161:     // ダルマモード
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.zenMode);
                if (findIdx >= 0) {
                  myState.buffDebuffs.removeAt(findIdx);
                }
                else {
                  myState.buffDebuffs.add(BuffDebuff(BuffDebuff.zenMode));
                }
              }
              break;
            case 165:     // アロマベール
              {
                // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじになっていれば消す
                myState.ailmentsRemoveWhere((e) =>
                  e.id == Ailment.infatuation || e.id == Ailment.encore || e.id == Ailment.torment ||
                  e.id == Ailment.disable || e.id == Ailment.taunt || e.id == Ailment.healBlock);
              }
              break;
            case 166:    // フラワーベール
              {   // まひ/こおり/やけど/どく/もうどく/ねむり/ねむけになっていれば消す
                myState.ailmentsRemoveWhere((element) => element.id <= Ailment.sleep || element.id == Ailment.sleepy);
              }
              break;
            case 168:   // へんげんじざい
              myState.type1 = PokeType.createFromId(extraArg1);
              myState.type2 = null;
              break;
            case 172:   // かちき
              myState.addStatChanges(true, 2, 2);
              break;
            case 281:   // こだいかっせい
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1));
              if (state.weather.id != Weather.sunny) {  // 晴れではないのに発動したら
                if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
                  myParty.items[myPokemonIndex-1] = pokeData.items[1696];   // ブーストエナジー確定
                  ret.add('もちものをブーストエナジーで確定しました。');
                }
                myState.holdingItem = null;   // アイテム消費
              }
              break;
            case 282:   // クォークチャージ
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1));
              if (state.field.id != Field.electricTerrain) {  // エレキフィールドではないのに発動したら
                if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
                  myParty.items[myPokemonIndex-1] = pokeData.items[1696];   // ブーストエナジー確定
                  ret.add('もちものをブーストエナジーで確定しました。');
                }
                myState.holdingItem = null;   // アイテム消費
              }
              break;
            default:
              break;
          }
        }
        if (playerType.id == PlayerType.opponent && myState.currentAbility.id == 0) {
          myState.pokemon.ability = pokeData.abilities[effectId]!;
          myState.currentAbility = myState.pokemon.ability;   // とくせい確定
          ret.add('とくせいを${myState.currentAbility.displayName}で確定しました。');
        }
        break;
      case EffectType.item:
        switch (effectId) {
          case 247:    // いのちのたま
            if (playerType.id == PlayerType.me) {
              myState.remainHP -= extraArg1;
            }
            else {
              myState.remainHPPercent -= extraArg1;
            }
            if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
              myParty.items[myPokemonIndex-1] = pokeData.items[247];   // いのちのたま確定
              ret.add('もちものをいのちのたまで確定しました。');
            }
            myState.holdingItem = pokeData.items[247];
            break;
          // 消費系アイテム
          case 252:   // きあいのタスキ
            if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
              myParty.items[myPokemonIndex-1] = pokeData.items[effectId];   // もちもの確定
                ret.add('もちものを${pokeData.items[effectId]!.displayName}で確定しました。');
              }
              myState.holdingItem = null;   // アイテム消費
            break;
          default:
            break;
        }
        break;
      case EffectType.move:
        {
          // テラスタル済みならわざもテラスタル化
          if (myState.teraType != null) {
            move!.teraType = myState.teraType!;
          }
          ret.addAll(move!.processMove(ownParty, opponentParty, ownPokemonState, opponentPokemonState, state, continuousCount));
          // ポケモン交代の場合、もちもの失くした判定用に変数セット
          if (move!.type.id == TurnMoveType.change) {
            if (playerType.id == PlayerType.me) isOwnChanged = true;
            if (playerType.id == PlayerType.opponent) isOpponentChanged = false;
          }
        }
        break;
      case EffectType.changeFaintingPokemon:    // ひんし後のポケモン交代
        // のうりょく変化リセット、現在のポケモンを表すインデックス更新
        if (playerType.id == PlayerType.me) {
          ownPokemonState.processExitEffect(true);
          if (effectId != 0) {
            state.ownPokemonIndex = effectId;
            state.ownPokemonState.processEnterEffect(true, state.weather, state.field);
          }
        }
        else {
          opponentPokemonState.processExitEffect(false);
          if (effectId != 0) {
            state.opponentPokemonIndex = effectId;
            state.opponentPokemonState.processEnterEffect(false, state.weather, state.field);
          }
        }
        break;
      default:
        break;
    }

    // HP 満タン判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool isFull = player == PlayerType.me ? ownPokemonState.remainHP >= ownPokemonState.pokemon.h.real :
                    opponentPokemonState.remainHPPercent >= 100;
      var pokeState = player == PlayerType.me ? ownPokemonState : opponentPokemonState;
      if (isFull) {
        if (pokeState.currentAbility.id == 136) {   // マルチスケイル
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.damaged0_5) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
      }
      else {
        if (pokeState.currentAbility.id == 136) pokeState.buffDebuffs.remove(BuffDebuff(BuffDebuff.damaged0_5)); // マルチスケイル
      }
    }

    // HP 1/2以下判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool is1_2 = player == PlayerType.me ? ownPokemonState.remainHP <= (ownPokemonState.pokemon.h.real / 2).floor() :
                    opponentPokemonState.remainHPPercent <= 50;
      var pokeState = player == PlayerType.me ? ownPokemonState : opponentPokemonState;
      if (is1_2) {
        if (pokeState.currentAbility.id == 129) {   // よわき
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defeatist) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.defeatist));
        }
      }
      else {
        if (pokeState.currentAbility.id == 129) pokeState.buffDebuffs.remove(BuffDebuff(BuffDebuff.defeatist)); // よわき
      }
    }

    // HP 1/3以下判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool is1_3 = player == PlayerType.me ? ownPokemonState.remainHP <= (ownPokemonState.pokemon.h.real / 3).floor() :
                    opponentPokemonState.remainHPPercent <= 33;
      var pokeState = player == PlayerType.me ? ownPokemonState : opponentPokemonState;
      if (is1_3) {
        if (pokeState.currentAbility.id == 65) {    // しんりょく
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.overgrow) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.overgrow));
        }
        if (pokeState.currentAbility.id == 66) {    // もうか
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.blaze) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.blaze));
        }
        if (pokeState.currentAbility.id == 67) {    // げきりゅう
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.torrent) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.torrent));
        }
        if (pokeState.currentAbility.id == 68) {    // むしのしらせ
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.swarm) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.swarm));
        }
      }
      else {
        if (pokeState.currentAbility.id == 65) pokeState.buffDebuffs.remove(BuffDebuff(BuffDebuff.overgrow));   // しんりょく
        if (pokeState.currentAbility.id == 66) pokeState.buffDebuffs.remove(BuffDebuff(BuffDebuff.blaze));      // もうか
        if (pokeState.currentAbility.id == 67) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.torrent));       // げきりゅう
        if (pokeState.currentAbility.id == 68) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.swarm));         // むしのしらせ
      }
    }

    // もちもの失くした判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      var pokeState = player == PlayerType.me ? ownPokemonState : opponentPokemonState;
      if ((!isOwnChanged && player == PlayerType.me && ownItemHolded && ownPokemonState.holdingItem == null) ||
          (!isOpponentChanged && player == PlayerType.opponent && opponentItemHolded && opponentPokemonState.holdingItem == null)
      ) {
        // もちもの失くした
        if (pokeState.currentAbility.id == 84) {  // かるわざ
          pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.unburden));
        }
      }
      else if ((!isOwnChanged && player == PlayerType.me && !ownItemHolded && ownPokemonState.holdingItem != null) ||
          (!isOpponentChanged && player == PlayerType.opponent && !opponentItemHolded && opponentPokemonState.holdingItem != null)
      ) {
        // もちもの得た
        if (pokeState.currentAbility.id == 84) {  // かるわざ
          pokeState.buffDebuffs.remove(BuffDebuff(BuffDebuff.unburden));
        }
      }
    }

    // 満タン以上の回復はしない
    if (ownPokemonState.remainHP >= ownPokemonState.pokemon.h.real) ownPokemonState.remainHP = ownPokemonState.pokemon.h.real;
    if (opponentPokemonState.remainHPPercent >= 100) opponentPokemonState.remainHPPercent = 100;
    // ひんし判定(本フェーズでひんしになったか)
    isOwnFainting = false;
    if (ownPokemonState.remainHP <= 0) {
      ownPokemonState.remainHP = 0;
      ownPokemonState.isFainting = true;
      if (!alreadyOwnFainting) {
        isOwnFainting = true;
      }
    }
    else {
      ownPokemonState.isFainting = false;
    }
    isOpponentFainting = false;
    if (opponentPokemonState.remainHPPercent <= 0) {
      opponentPokemonState.remainHPPercent = 0;
      opponentPokemonState.isFainting = true;
      if (!alreadyOpponentFainting) {
        isOpponentFainting = true;
      }
    }
    else {
      opponentPokemonState.isFainting = false;
    }

    // 勝利判定
    isMyWin = state.isMyWin;
    isYourWin = state.isYourWin;
    // TODO わざの反動とかで同時に倒れる場合あり、その場合の勝者判定必要

    return ret;
  }

  // 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
  static List<TurnEffect> getPossibleEffects(
    PokeDB pokeData, AbilityTiming timing, PlayerType playerType,
    EffectType type, Pokemon? pokemon, PokemonState? pokemonState, PhaseState phaseState,
    PlayerType attacker, TurnMove turnMove, Turn currentTurn)
  {
    List<TurnEffect> ret = [];
    List<int> timingIDs = [...allTimingIDs];
    List<int> attackerTimingIDs = [...allTimingIDs];
    List<int> defenderTimingIDs = [...allTimingIDs];
    List<int> individualFieldIDs = [];
    List<int> ailmentIDs = [];
    List<int> weatherIDs = [];
    List<int> fieldIDs = [];

    // 全タイミング共通
    if (phaseState.weather.id == Weather.sunny) { // 天気が晴れのとき
      timingIDs.add(74);
      attackerTimingIDs.add(74);
      defenderTimingIDs.add(74);
    }

    switch (timing.id) {
      case AbilityTiming.pokemonAppear:   // ポケモンを繰り出すとき
        {
          timingIDs.addAll(pokemonAppearTimingIDs);
          if (phaseState.weather.id != Weather.rainy) timingIDs.add(61);      // ポケモン登場時(天気が雨でない)
          if (phaseState.weather.id != Weather.sandStorm) timingIDs.add(66);  // ポケモン登場時(天気がすなあらしでない)
          if (phaseState.weather.id != Weather.sunny) timingIDs.add(71);      // ポケモン登場時(天気が晴れでない)
          if (phaseState.weather.id != Weather.snowy) timingIDs.add(80);      // ポケモン登場時(天気がゆきでない)
          individualFieldIDs = [...pokemonAppearFieldIDs];
        }
        break;
      case AbilityTiming.everyTurnEnd:           // 毎ターン終了時
        {
          timingIDs.addAll(everyTurnEndTimingIDs);
          if (playerType.id == PlayerType.me && currentTurn.initialOwnPokemonIndex == phaseState.ownPokemonIndex ||
              playerType.id == PlayerType.opponent && currentTurn.initialOpponentPokemonIndex == phaseState.opponentPokemonIndex
          ) {
            timingIDs.add(19);     // 1度でも行動した後毎ターン終了時
          }
          if (phaseState.ownPokemonState.holdingItem == null &&
              phaseState.opponentPokemonState.holdingItem == null
          ) {
            timingIDs.add(68);     // 相手が道具を消費したターン終了時
          }
          if (phaseState.weather.id == Weather.sunny) { // 天気が晴れのとき、毎ターン終了時
            timingIDs.addAll([50, 73]);
          }
          if (phaseState.weather.id == Weather.rainy) { // 天気があめのとき、毎ターン終了時
            timingIDs.addAll([65, 50, 72]);
          }
          if (phaseState.weather.id == Weather.snowy) { // 天気がゆきのとき、毎ターン終了時
            timingIDs.addAll([79]);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {   // どく/もうどく状態のとき
            timingIDs.add(52);
          }
          individualFieldIDs = [...everyTurnEndIndividualFieldIDs];
          ailmentIDs = [...everyTurnEndAilmentIDs];
          weatherIDs = [...everyTurnEndWeatherIDs];
          fieldIDs = [...everyTurnEndFieldIDs];
        }
        break;
      case AbilityTiming.afterActionDecision:    // 行動決定直後
        {
          timingIDs.addAll(afterActionDecisionTimingIDs);
        }
        break;
      case AbilityTiming.afterMove:     // わざ使用後
        {
          attackerTimingIDs.addAll(afterMoveAttackerTimingIDs);
          defenderTimingIDs.addAll(afterMoveDefenderTimingIDs);
          var attackerState = attacker.id == PlayerType.me ? phaseState.ownPokemonState : phaseState.opponentPokemonState;
          var defenderState = attacker.id == PlayerType.me ? phaseState.opponentPokemonState : phaseState.ownPokemonState;
          // こうげきしたとき/うけたとき
          if (turnMove.move.damageClass.id >= 2) {
            defenderTimingIDs.addAll([62, 82]);
            attackerTimingIDs.addAll([2]);
            // あくタイプのこうげきを受けた時
            if (turnMove.move.type.id == 17) defenderTimingIDs.addAll([86]);
          }
          if (turnMove.move.damageClass.id == DamageClass.physical) defenderTimingIDs.addAll([83]);   // ぶつりこうげきを受けた時
          if (turnMove.move.isDirect) {
            defenderTimingIDs.add(9);  // 直接攻撃を受けた時(確率)
            defenderTimingIDs.add(63);  // 直接攻撃を受けた時
            attackerTimingIDs.add(84);  // 直接攻撃をあてたとき(確率)
            // 違う性別の相手から直接攻撃を受けた時（確率）
            if (attackerState.pokemon.sex != defenderState.pokemon.sex && attackerState.pokemon.sex != Sex.none) defenderTimingIDs.add(69);
            // 直接攻撃によりひんしになっているとき
            if (defenderState.isFainting) defenderTimingIDs.add(75);
          }
          if (turnMove.move.isSound) defenderTimingIDs.add(64);  // 音技を受けた時
          if (turnMove.move.isDrain) defenderTimingIDs.add(40);  // HP吸収わざを受けた時
          if (turnMove.move.type.id == 13) {  // でんきタイプのわざを受けた時
            defenderTimingIDs.addAll([10, 26]);
          }
          if (turnMove.move.type.id == 11) {  // みずタイプのわざを受けた時
            defenderTimingIDs.addAll([11, 50, 78]);
          }
          if (turnMove.move.type.id == 10) {  // ほのおタイプのわざを受けた時
            defenderTimingIDs.addAll([17, 50]);
          }
          if (turnMove.move.type.id == 12) {  // くさタイプのわざを受けた時
            defenderTimingIDs.addAll([88]);
          }
          if (PokeType.effectiveness(attackerState.currentAbility.id == 113, turnMove.move.type, pokemonState!.type1, pokemonState.type2).id != MoveEffectiveness.great) {
            defenderTimingIDs.add(21);  // 効果ばつぐん以外のタイプのこうげきざわを受けた時
          }
          if (turnMove.move.type.id == 5) {
            if (turnMove.move.id != 28 && turnMove.move.id != 614) {  // すなかけ/サウザンアローではない
              defenderTimingIDs.add(22);  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
            }
          }
        }
        break;
      default:
        break;
    }

    if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
      if (type.id == EffectType.ability) {
        if (pokemonState!.currentAbility.id != 0) {   // とくせいが確定している場合
          if (timingIDs.contains(pokemonState.currentAbility.timing.id)) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.ability)
              ..effectId = pokemonState.currentAbility.id
            );
          }
          // わざ使用後に発動する効果
          if (attacker.id == playerType.id && attackerTimingIDs.contains(pokemonState.currentAbility.timing.id) ||
              attacker.id != playerType.id && defenderTimingIDs.contains(pokemonState.currentAbility.timing.id)
          ) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.ability)
              ..effectId = pokemonState.currentAbility.id
            );
          }
        }
        else {      // とくせいが確定していない場合
          for (final ability in pokemonState.possibleAbilities) {
            if (timingIDs.contains(ability.timing.id)) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.ability)
                ..effectId = ability.id
              );
            }
            // わざ使用後に発動する効果
            if (attacker.id == playerType.id && attackerTimingIDs.contains(ability.timing.id) ||
                attacker.id != playerType.id && defenderTimingIDs.contains(ability.timing.id)
            ) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.ability)
                ..effectId = ability.id
              );
            }
          }
        }
      }
      if (type.id == EffectType.individualField) {
        for (final field in pokemonState!.fields) {
          if (individualFieldIDs.contains(field.id)) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.individualField)
              ..effectId = field.id
            );
          }
        }
      }
      if (type.id == EffectType.ailment) {
        for (final ailment in pokemonState!.ailmentsIterable) {
          if (ailmentIDs.contains(ailment.id)) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.ailment)
              ..effectId = ailment.id
            );
          }
        }
      }
      if (playerType.id == PlayerType.me && type.id == EffectType.item) {
        if (timingIDs.contains(pokemonState!.holdingItem?.timing.id)) {
          ret.add(TurnEffect()
            ..playerType = PlayerType(PlayerType.me)
            ..effect = EffectType(EffectType.item)
            ..effectId = pokemonState.holdingItem!.id
          );
        }
        // わざ使用後に発動する効果
        if (attacker.id == PlayerType.me && attackerTimingIDs.contains(pokemonState.holdingItem?.timing.id) ||
            attacker.id == PlayerType.opponent && defenderTimingIDs.contains(pokemonState.holdingItem?.timing.id)
        ) {
          ret.add(TurnEffect()
            ..playerType = PlayerType(PlayerType.me)
            ..effect = EffectType(EffectType.item)
            ..effectId = pokemonState.holdingItem!.id
          );
        }
      }
      else if (playerType.id == PlayerType.opponent && type.id == EffectType.item) {
        if (pokemonState!.holdingItem?.id != 0) {
          if (timingIDs.contains(pokemonState.holdingItem?.timing.id)) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..effect = EffectType(EffectType.item)
              ..effectId = pokemonState.holdingItem!.id
            );
          }
          // わざ使用後に発動する効果
          if (attacker.id == PlayerType.opponent && attackerTimingIDs.contains(pokemonState.holdingItem?.timing.id) ||
              attacker.id == PlayerType.me && defenderTimingIDs.contains(pokemonState.holdingItem?.timing.id)
          ) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..effect = EffectType(EffectType.item)
              ..effectId = pokemonState.holdingItem!.id
            );
          }
        }
        else {
          var allItemIDs = [for (final item in pokeData.items.values) item.id];
          for (final item in pokemonState.impossibleItems) {
            allItemIDs.remove(item.id);
          }
          for (final itemID in allItemIDs) {
            if (timingIDs.contains(pokeData.items[itemID]!.timing.id)) {
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.opponent)
                ..effect = EffectType(EffectType.item)
                ..effectId = itemID
              );
            }
          }
        }
      }
    }

    if (playerType.id == PlayerType.entireField) {
      if (weatherIDs.contains(phaseState.weather.id)) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.weather)
          ..effectId = phaseState.weather.id
        );
      }
      if (fieldIDs.contains(phaseState.field.id)) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.field)
          ..effectId = phaseState.field.id
        );
      }
    }

    return ret;
  }

  String getDisplayName(PokeDB pokeData) {
    switch (effect.id) {
      case EffectType.ability:
        return pokeData.abilities[effectId]!.displayName;
      case EffectType.item:
        return pokeData.items[effectId]!.displayName;
      case EffectType.individualField:
        return IndividualField(effectId).displayName;
      case EffectType.weather:
        return Weather(effectId).displayName;
      case EffectType.field:
        return Field(effectId).displayName;
      case EffectType.move:
        return move!.move.displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText1(PokeDB pokeData) {
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        return move == null ? '' : move!.move.displayName;
      case AbilityTiming.afterActionDecision:
      case AbilityTiming.afterMove:
      case AbilityTiming.pokemonAppear:
      case AbilityTiming.everyTurnEnd:
        return getDisplayName(pokeData);
      default:
        return '';
    }
  }

  String getEditingControllerText2(PokeDB pokeData, PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        {
          if (move == null) return '';
          if (move!.playerType.id == PlayerType.me) {
            return state.opponentPokemonState.remainHPPercent.toString();
          }
          else {
            return state.ownPokemonState.remainHP.toString();
          }
        }
      default:
        {
          switch (effect.id) {
            case EffectType.item:
              switch (effectId) {
                case 247:     // いのちのたま
                  if (playerType.id == PlayerType.me) {
                    return state.ownPokemonState.remainHP.toString();
                  }
                  else {
                    return state.opponentPokemonState.remainHPPercent.toString();
                  }
              }
              break;
            case EffectType.ability:
              switch (effectId) {
                case 10:    // ちくでん
                case 11:    // ちょすい
                case 44:    // あめうけざら
                case 87:    // かんそうはだ
                case 90:    // ポイズンヒール
                case 94:    // サンパワー
                case 115:   // アイスボディ
                  if (playerType.id == PlayerType.me) {
                    return state.ownPokemonState.remainHP.toString();
                  }
                  else {
                    return state.opponentPokemonState.remainHPPercent.toString();
                  }
                case 24:    // さめはだ
                case 106:   // ゆうばく
                case 123:   // ナイトメア
                case 160:   // てつのトゲ
                  if (playerType.id == PlayerType.me) {
                    return state.opponentPokemonState.remainHPPercent.toString();
                  }
                  else {
                    return state.ownPokemonState.remainHP.toString();
                  }
                case 36:    // トレース
                  if (playerType.id == PlayerType.me) {
                    if (state.opponentPokemonState.currentAbility.id != 0) {
                      extraArg1 = state.opponentPokemonState.currentAbility.id;
                      return state.opponentPokemonState.currentAbility.displayName;
                    }
                    else {
                      return '';
                    }
                  }
                  else {
                    extraArg1 = state.ownPokemonState.currentAbility.id;
                    return state.ownPokemonState.currentAbility.displayName;
                  }
                case 53:    // ものひろい
                case 119:   // おみとおし
                case 124:   // わるいてぐせ
                case 139:   // しゅうかく
                case 170:   // マジシャン
                  return pokeData.items[extraArg1]!.displayName;
                case 108:   // よちむ
                  return pokeData.moves[extraArg1]!.displayName;
              }
              break;
          }
        }
    }
    return '';
  }

  String getEditingControllerText3(PokeDB pokeData, PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        {
          if (move == null) return '';
          if (move!.playerType.id == PlayerType.me) {
            return state.ownPokemonState.remainHP.toString();
          }
          else {
            return state.opponentPokemonState.remainHPPercent.toString();
          }
        }
      default:
        {
          switch (effect.id) {
            case EffectType.item:
              switch (effectId) {
              }
              break;
            case EffectType.ability:
              switch (effectId) {
              }
              break;
          }
        }
    }
    return '';
  }

  Widget extraInputWidget(
    void Function() onFocus,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    TextEditingController controller,
    TextEditingController controller2,
    MyAppState appState,
    int phaseIdx,
  )
  {
    if (effect.id == EffectType.ability) {   // とくせいによる効果
      switch (effectId) {
        case 10:      // ちくでん
        case 11:      // ちょすい
        case 44:      // あめうけざら
        case 87:      // かんそうはだ
        case 90:      // ポイズンヒール
        case 94:      // サンパワー
        case 115:     // アイスボディ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${ownPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
        case 16:      // へんしょく
        case 168:     // へんげんじざい
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TypeDropdownButton(
                  appState.pokeData,
                  '変化後のタイプ',
                  (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  extraArg1 == 0 ? null : extraArg1,
                ),
              ),
            ],
          );
        case 24:    // さめはだ
        case 106:   // ゆうばく
        case 123:   // ナイトメア
        case 160:   // てつのトゲ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${opponentPokemon.name}の残りHP' : '${ownPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('% /100%')) :
              Flexible(child: Text('/${ownPokemon.h.real}')),
            ],
          );
        case 27:    // ほうし
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    label: Text('相手が起こした状態異常'),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: Ailment.poison,
                      child: Text('どく'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text('まひ'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.sleep,
                      child: Text('ねむり'),
                    ),
                  ],
                  value: extraArg1 == 0 ? null : extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        case 36:    // トレース
          return Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'トレース後のとくせい',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.currentAbility.id != 0) {
                        matches.add(opponentPokemonState.currentAbility);
                      }
                      else {
                        matches.addAll(opponentPokemonState.possibleAbilities);
                      }
                    }
                    else {
                      matches.add(ownPokemonState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        case 53:    // ものひろい
        case 139:   // しゅうかく
          return Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = appState.pokeData.items.values.toList();
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        case 88:     // ダウンロード
          return Row(
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('こうげき'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('とくこう'),
                    ),
                  ],
                  value: extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              Text('があがった'),
            ],
          );
        case 108:     // よちむ
        case 130:     // のろわれボディ
          return Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'わざ',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType.id == PlayerType.me) {
                      matches.addAll(opponentPokemonState.moves);
                    }
                    else {
                      matches.add(ownPokemon.move1);
                      if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                      if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                      if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        case 119:     // おみとおし
        case 124:     // わるいてぐせ
        case 170:     // マジシャン
          return Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                        matches.add(opponentPokemonState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.holdingItem != null) {
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        case 141:       // ムラっけ
          return Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: 0,
                          child: Text('こうげき'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('ぼうぎょ'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('とくこう'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('とくぼう'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('すばやさ'),
                        ),
                      ],
                      value: extraArg1,
                      onChanged: (value) {
                        extraArg1 = value;
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Text('がぐーんとあがった'),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Flexible(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: 0,
                          child: Text('こうげき'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('ぼうぎょ'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('とくこう'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('とくぼう'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('すばやさ'),
                        ),
                      ],
                      value: extraArg2,
                      onChanged: (value) {
                        extraArg2 = value;
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Text('がさがった'),
                ],
              ),
            ],
          );
        case 281:     // こだいかっせい
        case 282:     // クォークチャージ
          return Row(
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('こうげき'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('ぼうぎょ'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('とくこう'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('とくぼう'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('すばやさ'),
                    ),
                  ],
                  value: extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              Text('があがった'),
            ],
          );
        default:
          break;
      }
    }
    else if (effect.id == EffectType.item) {   // もちものによる効果
      switch (effectId) {
        case 247:     // いのちのたま
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${ownPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
        default:
          break;
      }
    }

    return Container();
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnEffect deserialize(dynamic str, String split1, String split2, String split3) {
    TurnEffect effect = TurnEffect();
    final effectElements = str.split(split1);
    // playerType
    effect.playerType = PlayerType(int.parse(effectElements[0]));
    // timing
    effect.timing = AbilityTiming(int.parse(effectElements[1]));
    // effect
    effect.effect = EffectType(int.parse(effectElements[2]));
    // effectId
    effect.effectId = int.parse(effectElements[3]);
    // extraArg1
    effect.extraArg1 = int.parse(effectElements[4]);
    // extraArg2
    effect.extraArg2 = int.parse(effectElements[5]);
    // move
    if (effectElements[6] == '') {
      effect.move = null;
    }
    else {
      effect.move = TurnMove.deserialize(effectElements[6], split2, split3);
    }
    // isAdding
    effect.isAdding = int.parse(effectElements[7]) != 0;
    // isOwnFainting
    effect.isOwnFainting = int.parse(effectElements[8]) != 0;
    // isOpponentFainting
    effect.isOpponentFainting = int.parse(effectElements[9]) != 0;
    // isMyWin
    effect.isMyWin = int.parse(effectElements[10]) != 0;
    // isYourWin
    effect.isYourWin = int.parse(effectElements[11]) != 0;

    return effect;
  }

   // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3) {
    String ret = '';
    // playerType
    ret += playerType.id.toString();
    ret += split1;
    // timing
    ret += timing.id.toString();
    ret += split1;
    // effect
    ret += '${effect.id}';
    ret += split1;
    // effectId
    ret += effectId.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();
    ret += split1;
    // move
    ret += move == null ? '' : move!.serialize(split2, split3);
    ret += split1;
    // isAdding
    ret += isAdding ? '1' : '0';
    ret += split1;
    // isOwnFainting
    ret += isOwnFainting ? '1' : '0';
    ret += split1;
    // isOpponentFainting
    ret += isOpponentFainting ? '1' : '0';
    ret += split1;
    // isMyWin
    ret += isMyWin ? '1' : '0';
    ret += split1;
    // isYourWin
    ret += isYourWin ? '1' : '0';

    return ret;
  }

  static void swap(List<TurnEffect> list, int idx1, int idx2) {
    TurnEffect tmp = list[idx1].copyWith();
    list[idx1] = list[idx2].copyWith();
    list[idx2] = tmp;
  }
}

class TurnEffectAndStateAndGuide {
  TurnEffect turnEffect = TurnEffect();
  PhaseState phaseState = PhaseState();
  List<String> guides = [];
  bool needAssist = false;
}
