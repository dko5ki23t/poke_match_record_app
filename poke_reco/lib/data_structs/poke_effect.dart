import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/user_force.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

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
  static const int terastal = 9;
  static const int afterMove = 10;

  const EffectType(this.id);

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
  93,     // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  98,     // 場にいるポケモンがひんしになったとき
  105,    // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  106,    // フィールドが変化したとき
  108,    // 状態異常・ねむけになるとき
  109,    // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  110,    // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  111,    // 天気が晴れかブーストエナジーを持っているとき
  112,    // エレキフィールドかブーストエナジーを持っているとき
  114,    // 相手の能力ランクが上昇したとき
  117,    // HPが1/4以下になったとき
  121,    // エレキフィールドのとき
  122,    // グラスフィールドのとき
  125,    // サイコフィールドのとき
  126,    // ミストフィールドのとき
  128,    // 能力ランクが下がったとき
  129,    // トリックルームのとき
  46,     // HPが1/2以下になったとき
  150,    // 状態異常・こんらんになるとき
  151,    // こんらんになるとき
  153,    // メロメロになるとき
  156,    // とくせいを変更される、無効化される、無視されるとき
];

// ポケモンを繰り出すとき
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
  94,     // ポケモン登場時と毎ターン終了時（ともに条件あり）
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
  53,     // 行動決定後、行動実行前
  107,    // 行動決定後、行動実行前(確率)
  154,    // HPが1/4以下で行動決定後
];

// わざ使用後
// タイミング
const List<int> afterMoveAttackerTimingIDs = [
  3,      // こうげきし、相手にあたったとき(確率)
  14,     // わざを使うとき(確率・条件)
  91,     // わざを使うとき(条件)、特定のわざを使ったとき
  127,    // わざが当たらなかったとき
  149,    // 1つのわざのPPが0になったとき
  155,    // ためわざを使うとき
];
const List<int> afterMoveDefenderTimingIDs = [
  5,      // HPが満タンでこうげきを受けた時
  47,     // こうげきが急所に当たった時
];

// 毎ターン終了時
// フィールド
const List<int> everyTurnEndFieldIDs = [
//  Field.trickRoom,      // トリックルーム終了
//  Field.gravity,        // じゅうりょく終了
//  Field.waterSport,     // みずあそび終了
//  Field.mudSport,       // どろあそび終了
//  Field.wonderRoom,     // ワンダールーム終了
//  Field.magicRoom,      // マジックルーム終了
  Field.electricTerrain,// エレキフィールド終了
  Field.grassyTerrain,  // グラスフィールド終了
  Field.mistyTerrain,   // ミストフィールド終了
  Field.psychicTerrain, // サイコフィールド終了
];
// タイミング
const List<int> everyTurnEndTimingIDs = [
  4,      // 毎ターン終了時
  70,     // 毎ターン終了時（確率）
  94,     // ポケモン登場時と毎ターン終了時（ともに条件あり）
  159,    // HPが満タンでない毎ターン終了時
  160,    // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
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
  List<int?> _changePokemonIndexes = [null, null];    // (ポケモン交代という行動ではなく)効果によってポケモンを交代する場合はその交換先インデックス
  List<int> _prevPokemonIndexes = [0, 0];             // (ポケモン交代という行動ではなく)効果によってポケモンを交代する場合はその交換前インデックス
  UserForces userForces = UserForces();     // ユーザによる手動修正

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
    ..isYourWin = isYourWin
    .._changePokemonIndexes = [..._changePokemonIndexes]
    .._prevPokemonIndexes = [..._prevPokemonIndexes]
    ..userForces = userForces.copyWith();

  int? getChangePokemonIndex(PlayerType player) {
    if (player.id == PlayerType.me) return _changePokemonIndexes[0];
    return _changePokemonIndexes[1];
  }

  void setChangePokemonIndex(PlayerType player, int? val) {
    if (player.id == PlayerType.me) {
      _changePokemonIndexes[0] = val;
    }
    else {
      _changePokemonIndexes[1] = val;
    }
  }

  int getPrevPokemonIndex(PlayerType player) {
    if (player.id == PlayerType.me) return _prevPokemonIndexes[0];
    return _prevPokemonIndexes[1];
  }

  void setPrevPokemonIndex(PlayerType player, int val) {
    if (player.id == PlayerType.me) {
      _prevPokemonIndexes[0] = val;
    }
    else {
      _prevPokemonIndexes[1] = val;
    }
  }

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

  // 効果やわざの結果から、各ポケモン等の状態を更新する
  List<String> processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentParty,
    PokemonState opponentPokemonState,
    PhaseState state,
    TurnEffect? prevAction,
    int continuousCount,
  )
  {
    final pokeData = PokeDB();
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

    // 交代が伴う効果用に、効果前のポケモンインデックスを保存
    setPrevPokemonIndex(PlayerType(PlayerType.me), state.getPokemonIndex(PlayerType(PlayerType.me), null));
    setPrevPokemonIndex(PlayerType(PlayerType.opponent), state.getPokemonIndex(PlayerType(PlayerType.opponent), null));

    // TODO 呼び出し元で判定してたらprevActionの判定不要？
    var myState = timing.id == AbilityTiming.afterMove && prevAction != null ?
      state.getPokemonState(playerType, prevAction) : playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = timing.id == AbilityTiming.afterMove && prevAction != null ?
      state.getPokemonState(playerType.opposite, prevAction) : playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var myFields = playerType.id == PlayerType.me ? state.ownFields : state.opponentFields;
    var yourFields = playerType.id == PlayerType.me ? state.opponentFields : state.ownFields;
    var myParty = playerType.id == PlayerType.me ? ownParty : opponentParty;
    /*var yourParty = opponentParty;
    if (playerType.id == PlayerType.opponent) {
      myParty = opponentParty;
      yourParty = ownParty;
    }*/
    var myPokemonIndex = state.getPokemonIndex(playerType, timing.id == AbilityTiming.afterMove ? prevAction : null);
    //var yourPokemonIndex = state.getPokemonIndex(playerType.opposite);
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
              yourState.ailmentsAdd(Ailment(Ailment.flinch), state);  // ひるませる
              break;
            case 2:     // あめふらし
              state.weather = Weather(Weather.rainy);
              break;
            case 3:     // かそく
            case 78:    // でんきエンジン
            case 80:    // ふくつのこころ
            case 155:   // びびり
              myState.addStatChanges(true, 4, 1, yourState, abilityId: effectId);
              break;
            case 7:     // じゅうなん
              {   // まひになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 9:     // せいでんき
              yourState.ailmentsAdd(Ailment(Ailment.paralysis), state);
              break;
            case 10:    // ちくでん
            case 11:    // ちょすい
            case 44:    // あめうけざら
            case 87:    // かんそうはだ
            case 90:    // ポイズンヒール
            case 94:    // サンパワー
            case 115:   // アイスボディ
            case 297:   // どしょく
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
            case 257:   // パステルベール
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
              yourState.addStatChanges(false, 0, -1, myState, myFields: yourFields, yourFields: myFields, abilityId: effectId);
              break;
            case 24:    // さめはだ
            case 106:   // ゆうばく
            case 123:   // ナイトメア
            case 160:   // てつのトゲ
            case 215:   // とびだすなかみ
              if (yourPlayerID == PlayerType.me) {
                yourState.remainHP -= extraArg1;
              }
              else {
                yourState.remainHPPercent -= extraArg1;
              }
              break;
            case 27:    // ほうし
              if (extraArg1 != 0) {
                yourState.ailmentsAdd(Ailment(extraArg1), state);
              }
              break;
            case 28:    // シンクロ
              {
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.poison);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
                if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
                if (findIdx >= 0) yourState.ailmentsAdd(myState.ailments(findIdx), state);
              }
              break;
            case 31:    // ひらいしん
            case 114:   // よびみず
            case 201:   // ぎゃくじょう
            case 220:   // ソウルハート
            case 265:   // くろのいななき
            case 267:   // じんばいったい（くろのいななき）
              myState.addStatChanges(true, 2, 1, yourState, abilityId: effectId);
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
                myState.processPassiveEffect(myPlayerID == PlayerType.me, state, yourState);
              }
              break;
            case 38:    // どくのトゲ
            case 143:   // どくしゅ
              yourState.ailmentsAdd(Ailment(Ailment.poison), state);
              break;
            case 40:    // マグマのよろい
              {   // こおりになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.freeze);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 41:    // みずのベール
            case 199:   // すいほう
              {   // やけどになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 45:    // すなおこし
            case 245:   // すなはき
              state.weather = Weather(Weather.sandStorm);
              break;
            case 49:    // ほのおのからだ
              yourState.ailmentsAdd(Ailment(Ailment.burn), state);
              break;
            case 53:    // ものひろい
            case 139:   // しゅうかく
              myState.holdingItem = pokeData.items[extraArg1];
              break;
            case 56:    // メロメロボディ
              yourState.ailmentsAdd(Ailment(Ailment.infatuation), state);
              break;
            case 61:    // だっぴ
            case 93:    // うるおいボディ
              {   // まひ/こおり/やけど/どく/もうどく/ねむりになっていれば消す
                int findIdx = myState.ailmentsIndexWhere((element) => element.id <= Ailment.sleep);
                if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
              }
              break;
            case 70:      // ひでり
            case 288:     // ひひいろのこどう
              state.weather = Weather(Weather.sunny);
              break;
            case 83:    // いかりのつぼ
              myState.addStatChanges(true, 0, 6, yourState, abilityId: effectId);
              break;
            case 88:    // ダウンロード
            case 224:   // ビーストブースト
              myState.addStatChanges(true, extraArg1, 1, yourState, abilityId: effectId);
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
              yourState.ailmentsAdd(Ailment(Ailment.disable)..extraArg1 = extraArg1, state);
              break;
            case 133:     // くだけるよろい
              myState.addStatChanges(true, 1, -1, yourState, abilityId: effectId);
              myState.addStatChanges(true, 4, 2, yourState, abilityId: effectId);
              break;
            case 141:     // ムラっけ
              myState.addStatChanges(true, extraArg1, 2, yourState, abilityId: effectId);
              myState.addStatChanges(true, extraArg2, -1, yourState, abilityId: effectId);
              break;
            case 152:   // ミイラ
            case 268:   // とれないにおい
              yourState.currentAbility = myState.currentAbility;
              break;
            case 153:     // じしんかじょう
            case 154:     // せいぎのこころ
            case 157:     // そうしょく
            case 234:     // ふとうのけん
            case 264:     // しろのいななき
            case 266:     // じんばいったい（しろのいななき）
            case 270:     // ねつこうかん
            case 274:     // かぜのり
              myState.addStatChanges(true, 0, 1, yourState, abilityId: effectId);
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
            case 166:     // フラワーベール
            case 272:     // きよめのしお
              {   // まひ/こおり/やけど/どく/もうどく/ねむり/ねむけになっていれば消す
                myState.ailmentsRemoveWhere((element) => element.id <= Ailment.sleep || element.id == Ailment.sleepy);
              }
              break;
            case 168:   // へんげんじざい
            case 236:   // リベロ
              myState.type1 = PokeType.createFromId(extraArg1);
              myState.type2 = null;
              break;
            case 172:   // かちき
              myState.addStatChanges(true, 2, 2, yourState, abilityId: effectId);
              break;
            case 183:   // ぬめぬめ
            case 238:   // わたげ
              yourState.addStatChanges(false, 4, -1, myState, myFields: yourFields, yourFields: myFields, abilityId: effectId);
              break;
            case 176:   // バトルスイッチ
              {
                int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bladeForm);
                if (findIdx >= 0) {
                  myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.shieldForm);
                }
                else {
                  findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.shieldForm);
                  if (findIdx >= 0) myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.bladeForm);
                }
              }
              break;
            case 192:   // じきゅうりょく
            case 235:   // ふくつのたて
              myState.addStatChanges(true, 1, 1, yourState, abilityId: effectId);
              break;
            case 195:   // みずがため
            case 273:   // こんがりボディ
              myState.addStatChanges(true, 1, 2, yourState, abilityId: effectId);
              break;
            case 208:     // ぎょぐん
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.singleForm);
                if (findIdx >= 0) {
                  myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.multipleForm);
                }
                else {
                  findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.multipleForm);
                  if (findIdx >= 0) {
                    myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.singleForm);
                  }
                }
              }
              break;
            case 209:   // ばけのかわ
              {
                int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.transedForm);
                if (findIdx >= 0) {
                  myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.revealedForm);
                }
                if (playerType.id == PlayerType.me) {
                  myState.remainHP -= extraArg1;
                }
                else {
                  myState.remainHPPercent -= extraArg1;
                }
              }
              break;
            case 210:   // きずなへんげ
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.satoshiGekkoga);
                if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.satoshiGekkoga));
              }
              break;
            case 211:   // スワームチェンジ
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.perfectForm);
                if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.perfectForm));
                if (playerType.id == PlayerType.me) {
                  myState.remainHP -= extraArg1;
                }
                else {
                  myState.remainHPPercent -= extraArg1;
                }
              }
              break;
            case 216:   // おどりこ
              switch (extraArg1) {
                case 872:   // アクアステップ
                case 10552: // ほのおのまい(とくこう1段階上昇)
                  if (yourPlayerID == PlayerType.me) {
                    yourState.remainHP -= extraArg2;
                  }
                  else {
                    yourState.remainHPPercent -= extraArg2;
                  }
                  myState.addStatChanges(true, extraArg1 == 872 ? 4 : 2, 1, yourState, moveId: extraArg1);
                  break;
                case 80:    // はなびらのまい
                  if (yourPlayerID == PlayerType.me) {
                    yourState.remainHP -= extraArg2;
                  }
                  else {
                    yourState.remainHPPercent -= extraArg2;
                  }
                  myState.ailmentsAdd(Ailment(Ailment.thrash), state);
                  break;
                case 552:   // ほのおのまい
                case 686:   // めざめるダンス
                  if (yourPlayerID == PlayerType.me) {
                    yourState.remainHP -= extraArg2;
                  }
                  else {
                    yourState.remainHPPercent -= extraArg2;
                  }
                  break;
                case 837:   // しょうりのまい
                  myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
                  myState.addStatChanges(true, 1, 1, yourState, moveId: extraArg1);
                  myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
                  break;
                case 483:   // ちょうのまい
                  myState.addStatChanges(true, 2, 1, yourState, moveId: extraArg1);
                  myState.addStatChanges(true, 3, 1, yourState, moveId: extraArg1);
                  myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
                  break;
                case 14:    // つるぎのまい
                  myState.addStatChanges(true, 0, 2, yourState, moveId: extraArg1);
                  break;
                case 297:   // フェザーダンス
                  yourState.addStatChanges(false, 0, -2, myState, myFields: yourFields, yourFields: myFields, moveId: extraArg1);
                  break;
                case 298:   // フラフラダンス
                  yourState.ailmentsAdd(Ailment(Ailment.confusion), state);
                  break;
                case 461:   // みかづきのまい
                  if (myPlayerID == PlayerType.me) {
                    myState.remainHP = 0;
                  }
                  else {
                    myState.remainHPPercent = 0;
                  }
                  myFields.add(IndividualField(IndividualField.lunarDance));
                  break;
                case 349:   // りゅうのまい
                  myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
                  myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
                  break;
                case 775:   // ソウルビート
                  {
                    if (myPlayerID == PlayerType.me) {
                      myState.remainHP -= extraArg2;
                    }
                    else {
                      myState.remainHPPercent -= extraArg2;
                    }
                    myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
                    myState.addStatChanges(true, 1, 1, yourState, moveId: extraArg1);
                    myState.addStatChanges(true, 2, 1, yourState, moveId: extraArg1);
                    myState.addStatChanges(true, 3, 1, yourState, moveId: extraArg1);
                    myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
                  }
                  break;
                default:
                  break;
              }
              break;
            case 221:   // カーリーヘアー
              yourState.addStatChanges(true, 4, -1, myState, abilityId: effectId);
              break;
            case 226:   // エレキメイカー
            case 289:   // ハドロンエンジン
              state.field = Field(Field.electricTerrain);
              break;
            case 227:   // サイコメイカー
              state.field = Field(Field.psychicTerrain);
              break;
            case 228:   // ミストメイカー
              state.field = Field(Field.mistyTerrain);
              break;
            case 229:   // グラスメイカー
              state.field = Field(Field.grassyTerrain);
              break;
            case 243:   // じょうききかん
              myState.addStatChanges(true, 4, 6, yourState, abilityId: effectId);
              break;
            case 248:   // アイスフェイス
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.iceFace);
                if (findIdx >= 0) {
                  myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.niceFace);
                }
                else {
                  findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.niceFace);
                  if (findIdx >= 0) {
                    myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.iceFace);
                  }
                }
              }
              break;
            case 251:   // バリアフリー
              myFields.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
              yourFields.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
              break;
            case 253:   // ほろびのボディ
              myState.ailmentsAdd(Ailment(Ailment.perishSong), state);
              yourState.ailmentsAdd(Ailment(Ailment.perishSong), state);
              break;
            case 254:   // さまようたましい
              if (yourState.currentAbility.canExchange) {
                var tmp = yourState.currentAbility;
                yourState.currentAbility = myState.currentAbility;
                myState.currentAbility = tmp;
              }
              break;
            case 258:   // はらぺこスイッチ
              {
                int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.manpukuForm);
                if (findIdx >= 0) {
                  myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.harapekoForm);
                }
                else {
                  findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.harapekoForm);
                  if (findIdx >= 0) {
                    myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.manpukuForm);
                  }
                }
              }
              break;
            case 269:   // こぼれダネ
              state.field = Field(Field.grassyTerrain);
              break;
            case 271:   // いかりのこうら
              myState.addStatChanges(true, 0, 1, yourState, abilityId: effectId);
              myState.addStatChanges(true, 1, -1, yourState, abilityId: effectId);
              myState.addStatChanges(true, 2, 1, yourState, abilityId: effectId);
              myState.addStatChanges(true, 3, -1, yourState, abilityId: effectId);
              myState.addStatChanges(true, 4, 1, yourState, abilityId: effectId);
              break;
            case 277:   // ふうりょくでんき
            case 280:   // でんきにかえる
              myState.ailmentsAdd(Ailment(Ailment.charging), state);
              break;
            case 281:   // こだいかっせい
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1));
              if (state.weather.id != Weather.sunny) {  // 晴れではないのに発動したら
                if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
                  myParty.items[myPokemonIndex-1] = pokeData.items[1696];   // ブーストエナジー確定
                  ret.add('もちものを${pokeData.items[1696]!.displayName}で確定しました。');
                }
                myState.holdingItem = null;   // アイテム消費
              }
              break;
            case 282:   // クォークチャージ
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1));
              if (state.field.id != Field.electricTerrain) {  // エレキフィールドではないのに発動したら
                if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
                  myParty.items[myPokemonIndex-1] = pokeData.items[1696];   // ブーストエナジー確定
                  ret.add('もちものを${pokeData.items[1696]!.displayName}で確定しました。');
                }
                myState.holdingItem = null;   // アイテム消費
              }
              break;
            case 290:   // びんじょう
              myState.addStatChanges(true, extraArg1, extraArg2, yourState, abilityId: effectId);
              break;
            case 291:   // はんすう
              ret.addAll(Item.processEffect(
                extraArg1, playerType, myState,
                yourState, state,
                extraArg2, 0, getChangePokemonIndex(playerType),
              ));
              break;
            case 293:   // そうだいしょう
              {
                int faintingNum = myPlayerID == PlayerType.me ?
                      state.ownFaintingNum : state.opponentFaintingNum;
                if (faintingNum > 0) {
                  myState.buffDebuffs.add(BuffDebuff(BuffDebuff.power10 + faintingNum - 1));
                }
              }
              break;
            case 295:   // どくげしょう
              int findIdx = yourFields.indexWhere((e) => e.id == IndividualField.toxicSpikes);
              if (findIdx < 0) {
                yourFields.add(IndividualField(IndividualField.toxicSpikes)..extraArg1 = 1);
              }
              else {
                yourFields[findIdx].extraArg1 = 2;
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
      case EffectType.individualField:
        {
          switch (effectId) {
            case IndiFieldEffect.toxicSpikes:     // どくびし
              myState.ailmentsAdd(Ailment(Ailment.poison), state);
              break;
            case IndiFieldEffect.badToxicSpikes:  // どくどくびし
              myState.ailmentsAdd(Ailment(Ailment.badPoison), state);
              break;
            case IndividualField.futureAttack:    // みらいにこうげき
            case IndiFieldEffect.stealthRock:     // ステルスロック
              if (playerType.id == PlayerType.me) {
                myState.remainHP -= extraArg1;
              }
              else {
                myState.remainHPPercent -= extraArg1;
              }
              break;
            case IndividualField.healingWish:     // いやしのねがい
              if (playerType.id == PlayerType.me) {
                myState.remainHP = myState.pokemon.h.real;
              }
              else {
                myState.remainHPPercent = 100;
              }
              myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
              break;
            case IndividualField.lunarDance:      // みかづきのまい
              if (playerType.id == PlayerType.me) {
                myState.remainHP = myState.pokemon.h.real;
              }
              else {
                myState.remainHPPercent = 100;
              }
              myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
              for (int i = 0; i < myState.usedPPs.length; i++) {
                myState.usedPPs[i] = 0;
              }
              break;
            case IndiFieldEffect.stickyWeb:       // ねばねばネット
              if (myState.isGround(myFields) && myState.holdingItem?.id != 1178) {
                myState.addStatChanges(false, 4, -1, yourState, myFields: myFields, yourFields: yourFields);
              }
              break;
            case IndiFieldEffect.reflectorEnd:
              myFields.removeWhere((e) => e.id == IndividualField.reflector);
              break;
            case IndiFieldEffect.lightScreenEnd:
              myFields.removeWhere((e) => e.id == IndividualField.lightScreen);
              break;
            case IndiFieldEffect.tailwindEnd:
              myFields.removeWhere((e) => e.id == IndividualField.tailwind);
              break;
            case IndiFieldEffect.auroraVeilEnd:
              myFields.removeWhere((e) => e.id == IndividualField.auroraVeil);
              break;
            case IndiFieldEffect.trickRoomEnd:
              myFields.removeWhere((e) => e.id == IndividualField.trickRoom);
              yourFields.removeWhere((e) => e.id == IndividualField.trickRoom);
              break;
          }
        }
        break;      
      case EffectType.weather:
        {
          switch (effectId) {
            case WeatherEffect.sunnyEnd:
            case WeatherEffect.rainyEnd:
            case WeatherEffect.sandStormEnd:
            case WeatherEffect.snowyEnd:
              state.weather = Weather(Weather.none);
              break;
            case WeatherEffect.sandStormDamage:
              ownPokemonState.remainHP -= extraArg1;
              opponentPokemonState.remainHPPercent -= extraArg2;
              break;
          }
        }
        break;
      case EffectType.field:
        {
          switch (effectId) {
            case FieldEffect.electricTerrainEnd:
            case FieldEffect.grassyTerrainEnd:
            case FieldEffect.mistyTerrainEnd:
            case FieldEffect.psychicTerrainEnd:
              state.field = Field(Field.none);
              break;
            case FieldEffect.grassHeal:
              ownPokemonState.remainHP -= extraArg1;
              opponentPokemonState.remainHPPercent -= extraArg2;
              break;
          }
        }
        break;
      case EffectType.item:
        ret.addAll(Item.processEffect(
          effectId, playerType, myState,
          yourState, state,
          extraArg1, extraArg2, getChangePokemonIndex(playerType),
        ));
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
        myState.processExitEffect(true, yourState);
        if (effectId != 0) {
          state.setPokemonIndex(playerType, effectId);
          state.getPokemonState(playerType, null).processEnterEffect(true, state, yourState);
        }
        break;
      case EffectType.terastal:
        myState.teraType = PokeType.createFromId(effectId);
        if (playerType.id == PlayerType.me) {
          state.hasOwnTerastal = true;
        }
        else {
          state.hasOpponentTerastal = true;
        }
        break;
      case EffectType.ailment:
        switch (effectId) {
          case AilmentEffect.sleepy:
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleepy);
            myState.ailmentsAdd(Ailment(Ailment.sleep), state);
            break;
          case AilmentEffect.burn:
          case AilmentEffect.poison:
          case AilmentEffect.badPoison:
          case AilmentEffect.saltCure:
          case AilmentEffect.curse:
            if (playerType.id == PlayerType.me) {
              myState.remainHP -= extraArg1;
            }
            else {
              myState.remainHPPercent -= extraArg1;
            }
            break;
          case AilmentEffect.leechSeed:
            if (playerType.id == PlayerType.me) {
              myState.remainHP -= extraArg1;
              yourState.remainHPPercent -= extraArg2;
            }
            else {
              myState.remainHPPercent -= extraArg1;
              yourState.remainHP -= extraArg2;
            }
            break;
          case AilmentEffect.tauntEnd:
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.taunt);
            break;
        }
        break;
      case EffectType.afterMove:
        switch (effectId) {
          case 194:   // みちづれ
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 588:   // キングシールド
            myState.addStatChanges(false, 0, -1, yourState, myFields: myFields, yourFields: yourFields, moveId: effectId);
            break;
          case 596:   // ニードルガード
            if (playerType.id == PlayerType.me) {
              myState.remainHP -= extraArg1;
            }
            else {
              myState.remainHPPercent -= extraArg1;
            }
            break;
          case 661:   // トーチカ
            myState.ailmentsAdd(Ailment(Ailment.poison), state);
            break;
          case 792:   // ブロッキング
            myState.addStatChanges(false, 1, -2, yourState, myFields: myFields, yourFields: yourFields, moveId: effectId);
            break;
          case 852:   // スレッドトラップ
            myState.addStatChanges(false, 4, -1, yourState, myFields: myFields, yourFields: yourFields, moveId: effectId);
            break;
        }
        break;
      default:
        break;
    }

    // ユーザ手動入力による修正
    userForces.processEffect(ownParty, state.getPokemonState(PlayerType(PlayerType.me), null), opponentParty,
                              state.getPokemonState(PlayerType(PlayerType.opponent), null), state, prevAction, continuousCount);

    // HP 満タン判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool isFull = player == PlayerType.me ? ownPokemonState.remainHP >= ownPokemonState.pokemon.h.real :
                    opponentPokemonState.remainHPPercent >= 100;
      var pokeState = player == PlayerType.me ? ownPokemonState : opponentPokemonState;
      if (isFull) {
        if (pokeState.currentAbility.id == 136) {   // マルチスケイル
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.damaged0_5) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        if (pokeState.currentAbility.id == 177) {   // はやてのつばさ
          if (pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.galeWings) < 0) pokeState.buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
      }
      else {
        if (pokeState.currentAbility.id == 136) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.damaged0_5); // マルチスケイル
        if (pokeState.currentAbility.id == 177) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.galeWings);  // はやてのつばさ
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
        if (pokeState.currentAbility.id == 129) pokeState.buffDebuffs.removeAt(pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defeatist)); // よわき
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
        if (pokeState.currentAbility.id == 65) pokeState.buffDebuffs.removeAt(pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.overgrow));   // しんりょく
        if (pokeState.currentAbility.id == 66) pokeState.buffDebuffs.removeAt(pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.blaze));      // もうか
        if (pokeState.currentAbility.id == 67) pokeState.buffDebuffs.removeAt(pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.torrent));       // げきりゅう
        if (pokeState.currentAbility.id == 68) pokeState.buffDebuffs.removeAt(pokeState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.swarm));         // むしのしらせ
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
    AbilityTiming timing, PlayerType playerType,
    EffectType type, Pokemon? pokemon, PokemonState? pokemonState, PhaseState phaseState,
    PlayerType attacker, TurnMove turnMove, Turn currentTurn, TurnEffect? prevAction)
  {
    final pokeData = PokeDB();
    List<TurnEffect> ret = [];
    List<int> retAbilityIDs = [];
    List<int> timingIDs = [...allTimingIDs];
    List<int> attackerTimingIDs = [...allTimingIDs];
    List<int> defenderTimingIDs = [...allTimingIDs];
    List<int> indiFieldEffectIDs = [];
    List<int> ailmentEffectIDs = [];
    List<int> weatherEffectIDs = [];
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
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
          if (phaseState.weather.id != Weather.rainy) timingIDs.add(61);      // ポケモン登場時(天気が雨でない)
          if (phaseState.weather.id != Weather.sandStorm) timingIDs.add(66);  // ポケモン登場時(天気がすなあらしでない)
          if (phaseState.weather.id != Weather.sunny) timingIDs.add(71);      // ポケモン登場時(天気が晴れでない)
          if (phaseState.weather.id != Weather.snowy) timingIDs.add(80);      // ポケモン登場時(天気がゆきでない)
          if (phaseState.field.id != Field.electricTerrain) timingIDs.add(99);  // ポケモン登場時(エレキフィールドでない)
          if (phaseState.field.id != Field.psychicTerrain) timingIDs.add(100);  // ポケモン登場時(サイコフィールドでない)
          if (phaseState.field.id != Field.mistyTerrain) timingIDs.add(101);    // ポケモン登場時(ミストフィールドでない)
          if (phaseState.field.id != Field.grassyTerrain) timingIDs.add(102);   // ポケモン登場時(グラスフィールドでない)
          if ((playerType.id == PlayerType.me && phaseState.ownFields.where((e) => e.id == IndividualField.stealthRock).isNotEmpty) ||
              (playerType.id == PlayerType.opponent && phaseState.opponentFields.where((e) => e.id == IndividualField.stealthRock).isNotEmpty)
          ) {         // ステルスロックがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.stealthRock);
          }
          var findIdx = playerType.id == PlayerType.me ? phaseState.ownFields.indexWhere((e) => e.id == IndividualField.toxicSpikes) :
                        playerType.id == PlayerType.opponent ? phaseState.opponentFields.indexWhere((e) => e.id == IndividualField.toxicSpikes) : -1;
          var extraArg1 = findIdx >= 0 ? playerType.id == PlayerType.me ? phaseState.ownFields[findIdx].extraArg1 : phaseState.opponentFields[findIdx].extraArg1 : 0;
          if (findIdx >= 0) {       // どくびしがあるとき
            if (extraArg1 <= 1) {
              indiFieldEffectIDs.add(IndiFieldEffect.toxicSpikes);
            }
            else {
              indiFieldEffectIDs.add(IndiFieldEffect.badToxicSpikes);
            }
          }
          if ((playerType.id == PlayerType.me && phaseState.ownFields.where((e) => e.id == IndividualField.stickyWeb).isNotEmpty) ||
              (playerType.id == PlayerType.opponent && phaseState.opponentFields.where((e) => e.id == IndividualField.stickyWeb).isNotEmpty)
          ) {         // ねばねばネットがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.stickyWeb);
          }
        }
        break;
      case AbilityTiming.everyTurnEnd:           // 毎ターン終了時
        {
          timingIDs.addAll(everyTurnEndTimingIDs);
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
          if (currentTurn.getInitialPokemonIndex(playerType) == phaseState.getPokemonIndex(playerType, null)) {
            timingIDs.add(19);     // 1度でも行動した後毎ターン終了時
          }
          if (phaseState.getPokemonState(PlayerType(PlayerType.me), null).holdingItem == null &&
              phaseState.getPokemonState(PlayerType(PlayerType.opponent), null).holdingItem == null
          ) {
            timingIDs.add(68);     // 相手が道具を消費したターン終了時
          }
          if (phaseState.weather.id == Weather.sunny) { // 天気が晴れのとき、毎ターン終了時
            timingIDs.addAll([50, 73]);
            weatherEffectIDs.add(WeatherEffect.sunnyEnd);
          }
          if (phaseState.weather.id == Weather.rainy) { // 天気があめのとき、毎ターン終了時
            timingIDs.addAll([65, 50, 72]);
            weatherEffectIDs.add(WeatherEffect.rainyEnd);
          }
          if (phaseState.weather.id == Weather.snowy) { // 天気がゆきのとき、毎ターン終了時
            timingIDs.addAll([79]);
            weatherEffectIDs.add(WeatherEffect.snowyEnd);
          }
          if (phaseState.weather.id == Weather.sandStorm) { // 天気がすなあらしのとき、毎ターン終了時
            weatherEffectIDs.addAll([WeatherEffect.sandStormEnd, WeatherEffect.sandStormDamage]);
          }
          if (pokemonState != null && (pokemonState.teraType == null || pokemonState.teraType!.id == 0)) {   // テラスタルしていないとき
            timingIDs.add(116);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.sleepy).isNotEmpty) {   // ねむけ状態のとき
            ailmentEffectIDs.add(AilmentEffect.sleepy);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.poison).isNotEmpty) {   // どく状態のとき
            ailmentEffectIDs.add(AilmentEffect.poison);
            timingIDs.add(52);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.badPoison).isNotEmpty) {  // もうどく状態のとき
            ailmentEffectIDs.add(AilmentEffect.badPoison);
            timingIDs.add(52);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty) {     // やけど状態のとき
            ailmentEffectIDs.add(AilmentEffect.burn);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.saltCure).isNotEmpty) {   // しおづけ状態のとき
            ailmentEffectIDs.add(AilmentEffect.saltCure);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.curse).isNotEmpty) {      // のろい状態のとき
            ailmentEffectIDs.add(AilmentEffect.curse);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.leechSeed).isNotEmpty) {  // やどりぎのタネ状態のとき
            ailmentEffectIDs.add(AilmentEffect.leechSeed);
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.taunt).isNotEmpty) {      // ちょうはつ状態のとき
            ailmentEffectIDs.add(AilmentEffect.tauntEnd);
          }
          if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
            if (pokemonState!.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) {
              timingIDs.add(152);     // 状態異常でない毎ターン終了時
            }
          }
          // 各々の場
          var myFields = playerType.id == PlayerType.me ? phaseState.ownFields : phaseState.opponentFields;
          if (myFields.where((e) => e.id == IndividualField.reflector).isNotEmpty) {      // リフレクターがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.reflectorEnd);
          }
          if (myFields.where((e) => e.id == IndividualField.lightScreen).isNotEmpty) {    // ひかりのかべがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.lightScreenEnd);
          }
          if (myFields.where((e) => e.id == IndividualField.auroraVeil).isNotEmpty) {     // オーロラベールがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.auroraVeilEnd);
          }
          if (myFields.where((e) => e.id == IndividualField.tailwind).isNotEmpty) {       // おいかぜがあるとき
            indiFieldEffectIDs.add(IndiFieldEffect.tailwindEnd);
          }
          if (myFields.where((e) => e.id == IndividualField.trickRoom).isNotEmpty) {      // トリックルーム中
            indiFieldEffectIDs.add(IndiFieldEffect.trickRoomEnd);
          }
          fieldIDs = [...everyTurnEndFieldIDs];
        }
        break;
      case AbilityTiming.afterActionDecision:    // 行動決定直後
        {
          timingIDs.addAll(afterActionDecisionTimingIDs);
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
        }
        break;
      case AbilityTiming.afterMove:     // わざ使用後
        if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
          timingIDs.clear();    // atacker/defenderに統合するするため削除
          attackerTimingIDs.addAll(afterMoveAttackerTimingIDs);
          defenderTimingIDs.addAll(afterMoveDefenderTimingIDs);
          var attackerState = phaseState.getPokemonState(attacker, prevAction);
          var defenderState = phaseState.getPokemonState(attacker.opposite, prevAction);
          if (turnMove.move.priority >= 1) defenderTimingIDs.addAll([95]);   // 優先度1以上のわざを受けた時
          // へんかわざを受けた時
          if (turnMove.move.damageClass.id == 1) defenderTimingIDs.addAll([113]);
          // こうげきしたとき/うけたとき
          if (turnMove.move.damageClass.id >= 2) {
            defenderTimingIDs.addAll([62, 82, 157]);
            attackerTimingIDs.addAll([60, 2]);
            // ノーマルタイプのこうげきをした時
            if (turnMove.moveType.id == 1) attackerTimingIDs.addAll([130]);
            // あくタイプのこうげきを受けた時
            if (turnMove.moveType.id == 17) defenderTimingIDs.addAll([86]);
            // みずタイプのこうげきを受けた時
            if (turnMove.moveType.id == 11) defenderTimingIDs.addAll([92, 104]);
            // ほのおタイプのこうげきを受けた時
            if (turnMove.moveType.id == 10) defenderTimingIDs.addAll([104, 107]);
            // でんきタイプのこうげきを受けた時
            if (turnMove.moveType.id == 13) defenderTimingIDs.addAll([118]);
            // こおりタイプのこうげきを受けた時
            if (turnMove.moveType.id == 15) defenderTimingIDs.addAll([119]);
            // こうげきによりひんしになっているとき
            if (defenderState.isFainting) defenderTimingIDs.add(96);
          }
          if (turnMove.move.damageClass.id == DamageClass.physical) defenderTimingIDs.addAll([83]);   // ぶつりこうげきを受けた時
          if (turnMove.move.damageClass.id == DamageClass.special) defenderTimingIDs.addAll([124]);   // とくしゅこうげきを受けた時
          if (turnMove.move.isDirect && attackerState.currentAbility.id != 203) {
            defenderTimingIDs.add(9);  // 直接攻撃を受けた時(確率)
            defenderTimingIDs.add(63);  // 直接攻撃を受けた時
            attackerTimingIDs.add(84);  // 直接攻撃をあてたとき(確率)
            // 違う性別の相手から直接攻撃を受けた時（確率）
            if (attackerState.pokemon.sex != defenderState.pokemon.sex && attackerState.pokemon.sex != Sex.none) defenderTimingIDs.add(69);
            // 直接攻撃によりひんしになっているとき
            if (defenderState.isFainting) defenderTimingIDs.add(75);
            // まもる系統のわざ相手に直接攻撃したとき
            var findIdx = defenderState.ailmentsIndexWhere((e) => e.id == Ailment.protect && e.extraArg1 != 0);
            if (findIdx >= 0 && attacker.id == playerType.id) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.afterMove)
                ..effectId = defenderState.ailments(findIdx).extraArg1
              );
            }
            // みちづれ状態の相手にこうげきしてひんしにしたとき
            if (defenderState.isFainting && defenderState.ailmentsWhere((e) => e.id == Ailment.destinyBond).isNotEmpty) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.afterMove)
                ..effectId = 194
              );
            }
          }
          if (turnMove.move.isSound) {
            attackerTimingIDs.add(123);  // 音技を使ったとき
            defenderTimingIDs.add(64);  // 音技を受けた時
          }
          if (turnMove.move.isDrain) defenderTimingIDs.add(40);  // HP吸収わざを受けた時
          if (turnMove.move.isDance) defenderTimingIDs.add(97);  // おどり技を受けた時
          if (turnMove.moveType.id == 1) {  // ノーマルタイプのわざを受けた時
            defenderTimingIDs.addAll([148]);
          }
          if (turnMove.moveType.id == 13) {  // でんきタイプのわざを受けた時
            defenderTimingIDs.addAll([10, 26]);
          }
          if (turnMove.moveType.id == 11) {  // みずタイプのわざを受けた時
            defenderTimingIDs.addAll([11, 50, 78]);
          }
          if (turnMove.moveType.id == 10) {  // ほのおタイプのわざを受けた時
            defenderTimingIDs.addAll([17, 50]);
          }
          if (turnMove.moveType.id == 12) {  // くさタイプのわざを受けた時
            defenderTimingIDs.addAll([88]);
          }
          if (turnMove.moveType.id == 5) {   // じめんタイプのわざを受けた時
            defenderTimingIDs.addAll([115]);
          }
          if (PokeType.effectiveness(
              attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
              defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              turnMove.moveType, pokemonState!
            ).id == MoveEffectiveness.great
          ) {
            defenderTimingIDs.add(120);  // 効果ばつぐんのタイプのこうげきざわを受けた時
            if (turnMove.moveType.id == 10) defenderTimingIDs.add(131);
            if (turnMove.moveType.id == 11) defenderTimingIDs.add(132);
            if (turnMove.moveType.id == 13) defenderTimingIDs.add(133);
            if (turnMove.moveType.id == 12) defenderTimingIDs.add(134);
            if (turnMove.moveType.id == 15) defenderTimingIDs.add(135);
            if (turnMove.moveType.id == 2) defenderTimingIDs.add(136);
            if (turnMove.moveType.id == 4) defenderTimingIDs.add(137);
            if (turnMove.moveType.id == 5) defenderTimingIDs.add(138);
            if (turnMove.moveType.id == 3) defenderTimingIDs.add(139);
            if (turnMove.moveType.id == 14) defenderTimingIDs.add(140);
            if (turnMove.moveType.id == 7) defenderTimingIDs.add(141);
            if (turnMove.moveType.id == 6) defenderTimingIDs.add(142);
            if (turnMove.moveType.id == 8) defenderTimingIDs.add(143);
            if (turnMove.moveType.id == 16) defenderTimingIDs.add(144);
            if (turnMove.moveType.id == 17) defenderTimingIDs.add(145);
            if (turnMove.moveType.id == 9) defenderTimingIDs.add(146);
            if (turnMove.moveType.id == 18) defenderTimingIDs.add(147);
          }
          else {
            defenderTimingIDs.add(21);  // 効果ばつぐん以外のタイプのこうげきざわを受けた時
          }
          if (turnMove.moveType.id == 5) {
            if (turnMove.move.id != 28 && turnMove.move.id != 614) {  // すなかけ/サウザンアローではない
              defenderTimingIDs.add(22);  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
            }
          }
          // とくせいがおどりこの場合
          if (phaseState.getPokemonState(PlayerType(PlayerType.me), prevAction).currentAbility.id == 216 ||
              phaseState.getPokemonState(PlayerType(PlayerType.opponent), prevAction).currentAbility.id == 216
          ) {
            attackerTimingIDs.addAll(defenderTimingIDs);
            attackerTimingIDs = attackerTimingIDs.toSet().toList();
            defenderTimingIDs = attackerTimingIDs;
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
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
          // わざ使用後に発動する効果
          if (attacker.id == playerType.id && attackerTimingIDs.contains(pokemonState.currentAbility.timing.id) ||
              attacker.id != playerType.id && defenderTimingIDs.contains(pokemonState.currentAbility.timing.id)
          ) {
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
        }
        else {      // とくせいが確定していない場合
          for (final ability in pokemonState.possibleAbilities) {
            if (timingIDs.contains(ability.timing.id)) {
              retAbilityIDs.add(ability.id);
            }
            // わざ使用後に発動する効果
            if (attacker.id == playerType.id && attackerTimingIDs.contains(ability.timing.id) ||
                attacker.id != playerType.id && defenderTimingIDs.contains(ability.timing.id)
            ) {
              retAbilityIDs.add(ability.id);
            }
          }
        }
        final abilityIDs = retAbilityIDs.toSet();
        for (final abilityID in abilityIDs) {
          ret.add(TurnEffect()
            ..playerType = playerType
            ..effect = EffectType(EffectType.ability)
            ..effectId = abilityID
          );
        }
      }
      if (type.id == EffectType.individualField) {
        for (var e in indiFieldEffectIDs) {
          ret.add(TurnEffect()
            ..playerType = playerType
            ..effect = EffectType(EffectType.individualField)
            ..effectId = e
          );
        }
      }
      if (type.id == EffectType.ailment) {
        for (var e in ailmentEffectIDs) {
          ret.add(TurnEffect()
            ..playerType = playerType
            ..effect = EffectType(EffectType.ailment)
            ..effectId = e
          );
        }
      }
      if (type.id == EffectType.item) {
        if (pokemonState!.holdingItem != null) {
          if (pokemonState.holdingItem!.id != 0) {   // もちものが確定している場合
            if (timingIDs.contains(pokemonState.holdingItem!.timing.id)) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.item)
                ..effectId = pokemonState.holdingItem!.id
              );
            }
            // わざ使用後に発動する効果
            if (attacker.id == playerType.id && attackerTimingIDs.contains(pokemonState.holdingItem!.timing.id) ||
                attacker.id != playerType.id && defenderTimingIDs.contains(pokemonState.holdingItem!.timing.id)
            ) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.item)
                ..effectId = pokemonState.holdingItem!.id
              );
            }
          }
          else {      // もちものが確定していない場合
            var allItems = [for (final item in pokeData.items.values) item];
            for (final item in pokemonState.impossibleItems) {
              allItems.removeWhere((e) => e.id == item.id);
            }
            for (final item in allItems) {
              if (timingIDs.contains(item.timing.id)) {
                ret.add(TurnEffect()
                  ..playerType = playerType
                  ..effect = EffectType(EffectType.item)
                  ..effectId = item.id
                );
              }
              // わざ使用後に発動する効果
              if (attacker.id == playerType.id && attackerTimingIDs.contains(item.timing.id) ||
                  attacker.id != playerType.id && defenderTimingIDs.contains(item.timing.id)
              ) {
                ret.add(TurnEffect()
                  ..playerType = playerType
                  ..effect = EffectType(EffectType.item)
                  ..effectId = item.id
                );
              }
            }
          }
        }
      }
    }

    if (playerType.id == PlayerType.entireField) {
      for (var e in weatherEffectIDs) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.weather)
          ..effectId = e
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

  String get displayName {
    final pokeData = PokeDB();
    switch (effect.id) {
      case EffectType.ability:
        return pokeData.abilities[effectId]!.displayName;
      case EffectType.item:
        return pokeData.items[effectId]!.displayName;
      case EffectType.ailment:
        return AilmentEffect(effectId).displayName;
      case EffectType.individualField:
        return IndiFieldEffect(effectId).displayName;
      case EffectType.weather:
        return WeatherEffect(effectId).displayName;
      case EffectType.field:
        return FieldEffect(effectId).displayName;
      case EffectType.move:
        return move!.move.displayName;
      case EffectType.afterMove:
        return pokeData.moves[effectId]!.displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText1() {
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        return move == null ? '' : move!.move.displayName;
      case AbilityTiming.afterActionDecision:
      case AbilityTiming.afterMove:
      case AbilityTiming.pokemonAppear:
      case AbilityTiming.everyTurnEnd:
        return displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText2(PhaseState state, TurnEffect? prevAction) {
    final pokeData = PokeDB();
    var myState = state.getPokemonState(playerType, timing.id == AbilityTiming.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(playerType.opposite, timing.id == AbilityTiming.afterMove ? prevAction : null);
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        {
          if (move == null) return '';
          if (move!.playerType.id == PlayerType.me) {
            return yourState.remainHPPercent.toString();
          }
          else if (move!.playerType.id == PlayerType.opponent) {
            return yourState.remainHP.toString();
          }
          return '';
        }
      default:
        {
          switch (effect.id) {
            case EffectType.item:
              return pokeData.items[effectId]!.getEditingControllerText2(playerType, myState, yourState);
            case EffectType.ability:
              switch (effectId) {
                case 10:    // ちくでん
                case 11:    // ちょすい
                case 44:    // あめうけざら
                case 87:    // かんそうはだ
                case 90:    // ポイズンヒール
                case 94:    // サンパワー
                case 115:   // アイスボディ
                case 209:   // ばけのかわ
                case 211:   // スワームチェンジ
                case 297:   // どしょく
                  if (playerType.id == PlayerType.me) {
                    return myState.remainHP.toString();
                  }
                  else {
                    return myState.remainHPPercent.toString();
                  }
                case 24:    // さめはだ
                case 106:   // ゆうばく
                case 123:   // ナイトメア
                case 160:   // てつのトゲ
                case 215:   // とびだすなかみ
                  if (playerType.id == PlayerType.me) {
                    return yourState.remainHPPercent.toString();
                  }
                  else {
                    return yourState.remainHP.toString();
                  }
                case 36:    // トレース
                  if (playerType.id == PlayerType.me) {
                    if (yourState.currentAbility.id != 0) {
                      extraArg1 = yourState.currentAbility.id;
                      return yourState.currentAbility.displayName;
                    }
                    else {
                      return '';
                    }
                  }
                  else {
                    extraArg1 = myState.currentAbility.id;
                    return myState.currentAbility.displayName;
                  }
                case 53:    // ものひろい
                case 119:   // おみとおし
                case 124:   // わるいてぐせ
                case 139:   // しゅうかく
                case 170:   // マジシャン
                  return pokeData.items[extraArg1]!.displayName;
                case 108:   // よちむ
                  return pokeData.moves[extraArg1]!.displayName;
                case 216:   // おどりこ
                  return pokeData.moves[extraArg1 % 10000]!.displayName;
              }
              break;
            case EffectType.ailment:
              switch (effectId) {
                case AilmentEffect.burn:        // やけど
                case AilmentEffect.poison:      // どく
                case AilmentEffect.badPoison:   // もうどく
                case AilmentEffect.saltCure:    // しおづけ
                case AilmentEffect.curse:       // のろい
                  if (playerType.id == PlayerType.me) {
                    return myState.remainHP.toString();
                  }
                  else {
                    return myState.remainHPPercent.toString();
                  }
                case AilmentEffect.leechSeed:   // やどりぎのタネ
                  if (playerType.id == PlayerType.me) {
                    return myState.remainHP.toString();
                  }
                  else {
                    return myState.remainHPPercent.toString();
                  }
              }
              break;
            case EffectType.individualField:
              switch (effectId) {
                case IndiFieldEffect.stealthRock:
                  if (playerType.id == PlayerType.me) {
                    return myState.remainHP.toString();
                  }
                  else {
                    return myState.remainHPPercent.toString();
                  }
              }
              break;
            case EffectType.weather:
              switch (effectId) {
                case WeatherEffect.sandStormDamage:
                  return state.getPokemonState(PlayerType(PlayerType.me), null).remainHP.toString();
              }
              break;
          }
        }
    }
    return '';
  }

  String getEditingControllerText3(PhaseState state, TurnEffect? prevAction) {
    var myState = state.getPokemonState(playerType, timing.id == AbilityTiming.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(playerType.opposite, timing.id == AbilityTiming.afterMove ? prevAction : null);
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        {
          if (move == null) return '';
          switch (move!.moveAdditionalEffects[0].id) {
            case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
            case 106:   // もちものを盗む
            case 178:   // 使用者ともちものを入れ替える
            case 179:   // 相手と同じとくせいになる
            case 185:   // 戦闘中自分が最後に使用したもちものを復活させる
            case 324:   // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
            case 456:   // 対象にもちものがあるときのみ成功
            case 457:   // 対象のもちものを消失させる
            case 189:   // もちものを持っていれば失わせ、威力1.5倍
            case 192:   // 使用者ととくせいを入れ替える
            case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            case 234:   // 使用者のもちものによって威力と追加効果が変わる
            case 300:   // 相手のとくせいを使用者のとくせいと同じにする
            case 315:   // 相手のきのみ・ノーマルジュエルを失わせる
            case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
              return '';
            default:
              if (move!.playerType.id == PlayerType.me) {
                return myState.remainHP.toString();
              }
              else if (move!.playerType.id == PlayerType.opponent) {
                return myState.remainHPPercent.toString();
              }
              return '';
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
                case 216:   // おどりこ
                  switch (extraArg1) {
                    case 872:   // アクアステップ
                    case 80:    // はなびらのまい
                    case 552:   // ほのおのまい
                    case 10552: // ほのおのまい(とくこう1段階上昇)
                    case 686:   // めざめるダンス
                      {
                        if (playerType.id == PlayerType.me) {
                          return yourState.remainHPPercent.toString();
                        }
                        else {
                          return yourState.remainHP.toString();
                        }
                      }
                    case 837:   // しょうりのまい
                    case 483:   // ちょうのまい
                    case 14:    // つるぎのまい
                    case 297:   // フェザーダンス
                    case 298:   // フラフラダンス
                    case 461:   // みかづきのまい
                    case 349:   // りゅうのまい
                      return '';
                    case 775:   // ソウルビート
                       {
                        if (playerType.id == PlayerType.me) {
                          return myState.remainHP.toString();
                        }
                        else {
                          return myState.remainHPPercent.toString();
                        }
                      }
                  }
                  break;
              }
              break;
            case EffectType.ailment:
              switch (effectId) {
                case AilmentEffect.leechSeed:   // やどりぎのタネ
                  if (playerType.id == PlayerType.me) {
                    return yourState.remainHPPercent.toString();
                  }
                  else {
                    return yourState.remainHP.toString();
                  }
              }
              break;
            case EffectType.weather:
              switch (effectId) {
                case WeatherEffect.sandStormDamage:
                  return state.getPokemonState(PlayerType(PlayerType.opponent), null).remainHPPercent.toString();
              }
              break;
          }
        }
    }
    return '';
  }

  String getEditingControllerText4(PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        if (move == null) break;
        return move!.getEditingControllerText4(state);
      default:
        break;
    }
    return '';
  }

  Widget extraInputWidget(
    void Function() onFocus,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    TurnEffect? prevAction,
    TextEditingController controller,
    TextEditingController controller2,
    MyAppState appState,
    int phaseIdx,
  )
  {
    // TODO:呼び出し元で判定してたらprevAction関連の判定不要かも？
    var myPokemon = prevAction != null && timing.id == AbilityTiming.afterMove ?
      state.getPokemonState(playerType, prevAction).pokemon :
      playerType.id == PlayerType.me ? ownPokemon : opponentPokemon;
    var yourPokemon = prevAction != null && timing.id == AbilityTiming.afterMove ?
      state.getPokemonState(playerType.opposite, prevAction).pokemon :
      playerType.id == PlayerType.me ? opponentPokemon : ownPokemon;
    var myState = prevAction != null && timing.id == AbilityTiming.afterMove ?
      state.getPokemonState(playerType, prevAction) :
      playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = prevAction != null && timing.id == AbilityTiming.afterMove ?
      state.getPokemonState(playerType.opposite, prevAction) :
      playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var myParty = playerType.id == PlayerType.me ? ownParty : opponentParty;
    var yourParty = playerType.id == PlayerType.me ? opponentParty : ownParty;

    if (effect.id == EffectType.ability) {   // とくせいによる効果
      switch (effectId) {
        case 10:    // ちくでん
        case 11:    // ちょすい
        case 44:    // あめうけざら
        case 87:    // かんそうはだ
        case 90:    // ポイズンヒール
        case 94:    // サンパワー
        case 115:   // アイスボディ
        case 209:   // ばけのかわ
        case 211:   // スワームチェンジ
        case 297:   // どしょく
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${myPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${myPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
        case 16:      // へんしょく
        case 168:     // へんげんじざい
        case 236:     // リベロ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TypeDropdownButton(
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
        case 215:   // とびだすなかみ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${yourPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = yourState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = yourState.remainHP - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('% /100%')) :
              Flexible(child: Text('/${yourPokemon.h.real}')),
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
                      if (yourState.currentAbility.id != 0) {
                        matches.add(yourState.currentAbility);
                      }
                      else {
                        matches.addAll(yourState.possibleAbilities);
                      }
                    }
                    else {
                      matches.add(yourState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
                      matches.addAll(yourState.moves);
                    }
                    else {
                      matches.add(yourPokemon.move1);
                      if (yourPokemon.move2 != null) matches.add(yourPokemon.move2!);
                      if (yourPokemon.move3 != null) matches.add(yourPokemon.move3!);
                      if (yourPokemon.move4 != null) matches.add(yourPokemon.move4!);
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
                      if (yourState.holdingItem != null && yourState.holdingItem!.id != 0) {
                        matches.add(yourState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        for (var item in yourState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (yourState.holdingItem != null) {
                      matches = [yourState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
        case 224:     // ビーストブースト
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
        case 290:     // びんじょう
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
              Text('が'),
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('3'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('4'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('5'),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text('6'),
                    ),
                  ],
                  value: extraArg2 == 0 ? null : extraArg2,
                  onChanged: (value) {
                    extraArg2 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              Text('段階あがった'),
            ],
          );
        case 216:   // おどりこ
          return Column(
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
                    List<int> ids = [
                      872, 837, 775, 483, 14, 80, 297, 298, 552, 461, 686, 349,
                    ];
                    List<Move> matches = [];
                    for (var i in ids) {
                      matches.add(appState.pokeData.moves[i]!);
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
              SizedBox(height: 10,),
              extraArg1 == 872 || extraArg1 == 80 || extraArg1 == 552 || extraArg1 == 10552 || extraArg1 == 686 ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${yourPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        if (playerType.id == PlayerType.me) {
                          extraArg2 = yourState.remainHPPercent - (int.tryParse(value)??0);
                        }
                        else {
                          extraArg2 = yourState.remainHP - (int.tryParse(value)??0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  playerType.id == PlayerType.me ?
                  Flexible(child: Text('% /100%')) :
                  Flexible(child: Text('/${yourPokemon.h.real}')),
                ],
              ) :
              extraArg1 == 775 ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${myPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        if (playerType.id == PlayerType.me) {
                          extraArg2 = myState.remainHP - (int.tryParse(value)??0);
                        }
                        else {
                          extraArg2 = myState.remainHPPercent - (int.tryParse(value)??0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  playerType.id == PlayerType.me ?
                  Flexible(child: Text('/${myPokemon.h.real}')) :
                  Flexible(child: Text('% /100%')),
                ],
              ) :
              Container(),
              extraArg1 == 552 || extraArg1 == 10552 ? SizedBox(height: 10,) : Container(),
              extraArg1 == 552 || extraArg1 == 10552 ?
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 552,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: 10552,
                      child: Text('とくこうがあがった'),
                    ),
                  ],
                  value: extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ) : Container(),
            ],
          );
        default:
          break;
      }
    }
    else if (effect.id == EffectType.item) {   // もちものによる効果
      // TODO myStateとかを使う？
      return appState.pokeData.items[effectId]!.extraInputWidget(
        onFocus, playerType, myPokemon, yourPokemon, myState,
        yourState, myParty, yourParty, state,
        controller, extraArg1, extraArg2, getChangePokemonIndex(playerType),
        (value) {
          extraArg1 = value;
          appState.editingPhase[phaseIdx] = true;
          onFocus();
        },
        (value) {
          extraArg2 = value;
          appState.editingPhase[phaseIdx] = true;
          onFocus();
        },
        (value) {
          setChangePokemonIndex(playerType, value);
          appState.editingPhase[phaseIdx] = true;
          onFocus();
        },
      );
    }
    else if (effect.id == EffectType.individualField) {   // 各ポケモンの場による効果
      switch (effectId) {
        case IndividualField.futureAttack:      // みらいにこうげき
        case IndiFieldEffect.stealthRock:       // ステルスロック
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${myPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${myPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
      }
    }
    else if (effect.id == EffectType.ailment) {   // 状態変化による効果
      switch (effectId) {
        case AilmentEffect.poison:    // どく
        case AilmentEffect.badPoison: // もうどく
        case AilmentEffect.burn:      // やけど
        case AilmentEffect.saltCure:  // しおづけ
        case AilmentEffect.curse:     // のろい
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${myPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${myPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
        case AilmentEffect.leechSeed:   // やどりぎのタネ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${myPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        if (playerType.id == PlayerType.me) {
                          extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                        }
                        else {
                          extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  playerType.id == PlayerType.me ?
                  Flexible(child: Text('/${myPokemon.h.real}')) :
                  Flexible(child: Text('% /100%')),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller2,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${yourPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        if (playerType.id == PlayerType.me) {
                          extraArg2 = yourState.remainHPPercent - (int.tryParse(value)??0);
                        }
                        else {
                          extraArg2 = yourState.remainHP - (int.tryParse(value)??0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  playerType.id == PlayerType.me ?
                  Flexible(child: Text('% /100%')) :
                  Flexible(child: Text('/${yourPokemon.h.real}')),
                ],
              ),
            ],
          );
      }
    }
    else if (effect.id == EffectType.weather) {   // 天気による効果
      switch (effectId) {
        case WeatherEffect.sandStormDamage:   // すなあらしによるダメージ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${ownPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Flexible(child: Text('/${ownPokemon.h.real}')),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller2,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${opponentPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        extraArg2 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Flexible(child: Text('% /100%')),
                ],
              ),
            ],
          );
      }
    }
    else if (effect.id == EffectType.field) {   // フィールドによる効果
      switch (effectId) {
        case FieldEffect.grassHeal:   // グラスフィールドによる回復
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${ownPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Flexible(child: Text('/${ownPokemon.h.real}')),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller2,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '${opponentPokemon.name}の残りHP',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        extraArg2 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  Flexible(child: Text('% /100%')),
                ],
              ),
            ],
          );
      }
    }
    else if (effect.id == EffectType.afterMove) {   // わざによる効果
      switch (effectId) {
        case 596:   // ニードルガード
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${myPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${myPokemon.h.real}')) :
              Flexible(child: Text('% /100%')),
            ],
          );
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
    // _changePokemonIndexes
    var changePokemonIndexes = effectElements[12].split(split2);
    for (int i = 0; i < 2; i++) {
      if (changePokemonIndexes[i] == '') {
        effect._changePokemonIndexes[i] = null;
      }
      else {
        effect._changePokemonIndexes[i] = int.parse(changePokemonIndexes[i]);
      }
    }
    // _prevPokemonIndexes
    var prevPokemonIndexes = effectElements[13].split(split2);
    for (int i = 0; i < 2; i++) {
      effect._prevPokemonIndexes[i] = int.parse(prevPokemonIndexes[i]);
    }
    // userForces
    effect.userForces = UserForces.deserialize(effectElements[14], split2, split3);

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
    ret += split1;
    // _changePokemonIndexes
    for (int i = 0; i < 2; i++) {
      if (_changePokemonIndexes[i] != null) ret += _changePokemonIndexes[i].toString();
      ret += split2;
    }
    ret += split1;
    // _prevPokemonIndexes
    for (int i = 0; i < 2; i++) {
      ret += _prevPokemonIndexes[i].toString();
      ret += split2;
    }
    ret += split1;
    // userForces
    ret += userForces.serialize(split2, split3);

    return ret;
  }

  static void swap(List<TurnEffect> list, int idx1, int idx2) {
    TurnEffect tmp = list[idx1].copyWith();
    list[idx1] = list[idx2].copyWith();
    list[idx2] = tmp;
  }
}

class TurnEffectAndStateAndGuide {
  int phaseIdx = -1;
  TurnEffect turnEffect = TurnEffect();
  PhaseState phaseState = PhaseState();
  List<String> guides = [];
  bool needAssist = false;
}
