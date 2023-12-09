import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/user_force.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/ability.dart';
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

  static const _displayNameMap = {
    0:  '',
    1:  'とくせい',
    2:  'もちもの',
    3:  '場',
    4:  '状態変化',
    5:  '',
    6:  '',
    7:  '',
    8:  '',
    9:  '',
    10: 'わざ',
  };

  String get displayName => _displayNameMap[id]!;

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
// タイミング
const List<int> pokemonAppearTimingIDs = [
  1,      // ポケモン登場時
  76,     // ポケモン登場時(確率/条件)
  94,     // ポケモン登場時と毎ターン終了時（ともに条件あり）
  161,    // ポケモン登場時・こうげきを受けた時
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

// わざ使用前
// タイミング
const List<int> beforeMoveAttackerTimingIDs = [
  164,    // わざ使用前(確率・条件)
];
const List<int> beforeMoveDefenderTimingIDs = [
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
  bool isAutoSet = false; // trueの場合、プログラムにて自動で追加されたもの

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
    ..userForces = userForces.copyWith()
    ..isAutoSet = isAutoSet;

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

    bool isMe = playerType.id == PlayerType.me;
    var myState = timing.id == AbilityTiming.afterMove && prevAction != null ?
      state.getPokemonState(playerType, prevAction) : isMe ? ownPokemonState : opponentPokemonState;
    var yourState = timing.id == AbilityTiming.afterMove && prevAction != null ?
      state.getPokemonState(playerType.opposite, prevAction) : isMe ? opponentPokemonState : ownPokemonState;
    var myFields = isMe ? state.ownFields : state.opponentFields;
    var yourFields = isMe ? state.opponentFields : state.ownFields;
    var myParty = isMe ? ownParty : opponentParty;
    var myPokemonIndex = state.getPokemonIndex(playerType, timing.id == AbilityTiming.afterMove ? prevAction : null);

    switch (effect.id) {
      case EffectType.ability:
        ret.addAll(Ability.processEffect(
          effectId, playerType, myState, yourState, state,
          myParty, myPokemonIndex, opponentPokemonState,
          extraArg1, extraArg2, getChangePokemonIndex(playerType)
        ));
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
            case IndiFieldEffect.spikes1:         // まきびし
            case IndiFieldEffect.spikes2:
            case IndiFieldEffect.spikes3:
            case IndiFieldEffect.futureAttack:    // みらいにこうげき
            case IndiFieldEffect.stealthRock:     // ステルスロック
            case IndiFieldEffect.wish:            // ねがいごと
              if (isMe) {
                myState.remainHP -= extraArg1;
              }
              else {
                myState.remainHPPercent -= extraArg1;
              }
              break;
            case IndiFieldEffect.healingWish:     // いやしのねがい
              if (isMe) {
                myState.remainHP = myState.pokemon.h.real;
              }
              else {
                myState.remainHPPercent = 100;
              }
              myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
              myFields.removeWhere((e) => e.id == IndividualField.healingWish);
              break;
            case IndiFieldEffect.lunarDance:      // みかづきのまい
              if (isMe) {
                myState.remainHP = myState.pokemon.h.real;
              }
              else {
                myState.remainHPPercent = 100;
              }
              myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
              for (int i = 0; i < myState.usedPPs.length; i++) {
                myState.usedPPs[i] = 0;
              }
              myFields.removeWhere((e) => e.id == IndividualField.lunarDance);
              break;
            case IndiFieldEffect.stickyWeb:       // ねばねばネット
              myState.addStatChanges(false, 4, -1, yourState, myFields: myFields, yourFields: yourFields);
              break;
            case IndiFieldEffect.reflectorEnd:    // リフレクター終了
              myFields.removeWhere((e) => e.id == IndividualField.reflector);
              break;
            case IndiFieldEffect.lightScreenEnd:  // ひかりのかべ終了
              myFields.removeWhere((e) => e.id == IndividualField.lightScreen);
              break;
            case IndiFieldEffect.safeGuardEnd:    // しんぴのまもり終了
              myFields.removeWhere((e) => e.id == IndividualField.safeGuard);
              break;
            case IndiFieldEffect.mistEnd:         // しろいきり終了
              myFields.removeWhere((e) => e.id == IndividualField.mist);
              break;
            case IndiFieldEffect.tailwindEnd:     // おいかぜ終了
              myFields.removeWhere((e) => e.id == IndividualField.tailwind);
              break;
            case IndiFieldEffect.auroraVeilEnd:   // オーロラベール終了
              myFields.removeWhere((e) => e.id == IndividualField.auroraVeil);
              break;
            case IndiFieldEffect.gravityEnd:      // じゅうりょく終了
              myFields.removeWhere((e) => e.id == IndividualField.gravity);
              break;
            case IndiFieldEffect.trickRoomEnd:    // トリックルーム終了
              myFields.removeWhere((e) => e.id == IndividualField.trickRoom);
              yourFields.removeWhere((e) => e.id == IndividualField.trickRoom);
              break;
            case IndiFieldEffect.waterSportEnd:   // みずあそび終了
              myFields.removeWhere((e) => e.id == IndividualField.waterSport);
              yourFields.removeWhere((e) => e.id == IndividualField.waterSport);
              break;
            case IndiFieldEffect.mudSportEnd:     // どろあそび終了
              myFields.removeWhere((e) => e.id == IndividualField.mudSport);
              yourFields.removeWhere((e) => e.id == IndividualField.mudSport);
              break;
            case IndiFieldEffect.wonderRoomEnd:   // ワンダールーム終了
              myFields.removeWhere((e) => e.id == IndividualField.wonderRoom);
              yourFields.removeWhere((e) => e.id == IndividualField.wonderRoom);
              break;
            case IndiFieldEffect.magicRoomEnd:    // マジックルーム終了
              myFields.removeWhere((e) => e.id == IndividualField.magicRoom);
              yourFields.removeWhere((e) => e.id == IndividualField.magicRoom);
              break;
            case IndiFieldEffect.fairyLockEnd:    // フェアリーロック終了
              myFields.removeWhere((e) => e.id == IndividualField.fairyLock);
              yourFields.removeWhere((e) => e.id == IndividualField.fairyLock);
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
          if (myState.isTerastaling) {
            move!.teraType = myState.teraType1;
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
        myState.isTerastaling = true;
        myState.teraType1 = PokeType.createFromId(effectId);
        if (pokeData.pokeBase[myState.pokemon.no]!.teraTypedAbilityID != 0) {   // テラスタルによってとくせいが変わる場合
          myState.setCurrentAbility(
            pokeData.abilities[pokeData.pokeBase[myState.pokemon.no]!.teraTypedAbilityID]!,
            yourState, playerType.id == PlayerType.me, state
          );
        }
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
          case AilmentEffect.ingrain:
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
            // 相手HP確定
            if (playerType.id == PlayerType.opponent) {
              int drain = extraArg2.abs();
              if (yourState.remainHP < yourState.pokemon.h.real && myState.remainHPPercent > 0 && drain > 0) {
                if (yourState.holdingItem?.id == 273) {   // おおきなねっこ
                  int tmp = ((drain.toDouble() + 0.5) / 1.3).round();
                  while (roundOff5(tmp * 1.3) > drain) {tmp--;}
                  drain = tmp;
                }
                int hpMin = drain * 8;
                int hpMax = hpMin + 3;
                // TODO: この時点で努力値等を反映するのかどうかとか
                if (hpMin != myState.minStats[0].real || hpMax != myState.maxStats[0].real) {
                  myState.minStats[0].real = hpMin;
                  myState.maxStats[0].real = hpMax;
                  ret.add('相手の${myState.pokemon.name}のHP実数値を$hpMin～$hpMaxで確定しました。');
                }
              }
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
    userForces.processEffect(state.getPokemonState(PlayerType(PlayerType.me), null),
                             state.getPokemonState(PlayerType(PlayerType.opponent), null), state);

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
        if (pokeState.currentAbility.id == 129) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defeatist); // よわき
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
        if (pokeState.currentAbility.id == 65) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.overgrow);   // しんりょく
        if (pokeState.currentAbility.id == 66) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.blaze);      // もうか
        if (pokeState.currentAbility.id == 67) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.torrent);       // げきりゅう
        if (pokeState.currentAbility.id == 68) pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.swarm);         // むしのしらせ
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
        state.incFaintingCount(PlayerType(PlayerType.me), 1);
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
        state.incFaintingCount(PlayerType(PlayerType.opponent), 1);
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
    List<int> fieldEffectIDs = [];

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
          var myFields = playerType.id == PlayerType.me ? phaseState.ownFields : phaseState.opponentFields;
          for (final field in myFields) {
            if (field.possiblyActive(timing)) {
              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(field));
            }
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
          // 天気
          switch (phaseState.weather.id) {
            case Weather.sunny:   // 天気が晴れのとき、毎ターン終了時
              timingIDs.addAll([50, 73]);
              weatherEffectIDs.add(WeatherEffect.sunnyEnd);
              break;
            case Weather.rainy:   // 天気があめのとき、毎ターン終了時
              timingIDs.addAll([65, 50, 72]);
              weatherEffectIDs.add(WeatherEffect.rainyEnd);
              break;
            case Weather.snowy:   // 天気がゆきのとき、毎ターン終了時
              timingIDs.addAll([79]);
              weatherEffectIDs.add(WeatherEffect.snowyEnd);
              break;
            case Weather.sandStorm:   // 天気がすなあらしのとき、毎ターン終了時
              weatherEffectIDs.addAll([WeatherEffect.sandStormEnd, WeatherEffect.sandStormDamage]);
              break;
            default:
              break;
          }
          // フィールド
          switch (phaseState.field.id) {
            case Field.electricTerrain:
              fieldEffectIDs.add(FieldEffect.electricTerrainEnd);
              break;
            case Field.grassyTerrain:
              fieldEffectIDs.addAll([FieldEffect.grassHeal, FieldEffect.grassyTerrainEnd]);
              break;
            case Field.mistyTerrain:
              fieldEffectIDs.add(FieldEffect.mistyTerrainEnd);
              break;
            case Field.psychicTerrain:
              fieldEffectIDs.add(FieldEffect.psychicTerrainEnd);
              break;
            default:
              break;
          }
          // 状態変化等
          if (pokemonState != null && !pokemonState.isTerastaling) {   // テラスタルしていないとき
            timingIDs.add(116);
          }
          if (pokemonState != null) {
            for (final ailment in pokemonState.ailmentsIterable) {
              if (ailment.possiblyActive(timing, pokemonState, phaseState)) {
                ailmentEffectIDs.add(AilmentEffect.getIdFromAilment(ailment));
              }
            }
          }
/*
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
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.ingrain).isNotEmpty) {    // ねをはる状態のとき
            ailmentEffectIDs.add(AilmentEffect.ingrain);
          }
*/
          if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
            if (pokemonState!.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) {
              timingIDs.add(152);     // 状態異常でない毎ターン終了時
            }
          }
          // 各々の場
          var myFields = playerType.id == PlayerType.me ? phaseState.ownFields : phaseState.opponentFields;
          for (final field in myFields) {
            if (field.possiblyActive(timing)) {
              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(field));
            }
          }
        }
        break;
      case AbilityTiming.afterActionDecision:    // 行動決定直後
        {
          timingIDs.addAll(afterActionDecisionTimingIDs);
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
        }
        break;
      case AbilityTiming.beforeMove:    // わざ使用前
        {
          timingIDs.clear();
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
          attackerTimingIDs.addAll(beforeMoveAttackerTimingIDs);
          defenderTimingIDs.addAll(beforeMoveDefenderTimingIDs);
          if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
            var attackerState = phaseState.getPokemonState(attacker, prevAction);
            var defenderState = phaseState.getPokemonState(attacker.opposite, prevAction);
            var replacedMoveType = turnMove.getReplacedMoveType(turnMove.move, 0, attackerState, phaseState);
            if (replacedMoveType.id == 1) {  // ノーマルタイプのわざを受けた時
              defenderTimingIDs.addAll([148]);
            }
            if (PokeType.effectiveness(
                attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
                defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                replacedMoveType, pokemonState!
              ).id == MoveEffectiveness.great
            ) {
              defenderTimingIDs.add(120);  // 効果ばつぐんのタイプのこうげきざわを受けた時
              if (replacedMoveType.id == 10) defenderTimingIDs.add(131);
              if (replacedMoveType.id == 11) defenderTimingIDs.add(132);
              if (replacedMoveType.id == 13) defenderTimingIDs.add(133);
              if (replacedMoveType.id == 12) defenderTimingIDs.add(134);
              if (replacedMoveType.id == 15) defenderTimingIDs.add(135);
              if (replacedMoveType.id == 2) defenderTimingIDs.add(136);
              if (replacedMoveType.id == 4) defenderTimingIDs.add(137);
              if (replacedMoveType.id == 5) defenderTimingIDs.add(138);
              if (replacedMoveType.id == 3) defenderTimingIDs.add(139);
              if (replacedMoveType.id == 14) defenderTimingIDs.add(140);
              if (replacedMoveType.id == 7) defenderTimingIDs.add(141);
              if (replacedMoveType.id == 6) defenderTimingIDs.add(142);
              if (replacedMoveType.id == 8) defenderTimingIDs.add(143);
              if (replacedMoveType.id == 16) defenderTimingIDs.add(144);
              if (replacedMoveType.id == 17) defenderTimingIDs.add(145);
              if (replacedMoveType.id == 9) defenderTimingIDs.add(146);
              if (replacedMoveType.id == 18) defenderTimingIDs.add(147);
            }
          }
        }
        break;
      case AbilityTiming.afterMove:     // わざ使用後
        if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
          timingIDs.clear();    // atacker/defenderに統合するするため削除
          attackerTimingIDs.addAll(afterMoveAttackerTimingIDs);
          defenderTimingIDs.addAll(afterMoveDefenderTimingIDs);
          var attackerState = phaseState.getPokemonState(attacker, prevAction);
          var defenderState = phaseState.getPokemonState(attacker.opposite, prevAction);
          var replacedMove = turnMove.getReplacedMove(turnMove.move, 0, attackerState);
          var replacedMoveType = turnMove.getReplacedMoveType(turnMove.move, 0, attackerState, phaseState);
          if (replacedMove.priority >= 1) defenderTimingIDs.addAll([95]);   // 優先度1以上のわざを受けた時
          // へんかわざを受けた時
          if (replacedMove.damageClass.id == 1) defenderTimingIDs.addAll([113]);
          // こうげきしたとき/うけたとき
          if (replacedMove.damageClass.id >= 2) {
            defenderTimingIDs.addAll([62, 82, 157, 161]);
            attackerTimingIDs.addAll([60, 2]);
            // ノーマルタイプのこうげきをした時
            if (replacedMoveType.id == 1) attackerTimingIDs.addAll([130]);
            // あくタイプのこうげきを受けた時
            if (replacedMoveType.id == 17) defenderTimingIDs.addAll([86]);
            // みずタイプのこうげきを受けた時
            if (replacedMoveType.id == 11) defenderTimingIDs.addAll([92, 104]);
            // ほのおタイプのこうげきを受けた時
            if (replacedMoveType.id == 10) defenderTimingIDs.addAll([104, 107]);
            // でんきタイプのこうげきを受けた時
            if (replacedMoveType.id == 13) defenderTimingIDs.addAll([118]);
            // こおりタイプのこうげきを受けた時
            if (replacedMoveType.id == 15) defenderTimingIDs.addAll([119]);
            // こうげきによりひんしになっているとき
            if (defenderState.isFainting) defenderTimingIDs.add(96);
          }
          if (replacedMove.damageClass.id == DamageClass.physical) defenderTimingIDs.addAll([83]);   // ぶつりこうげきを受けた時
          if (replacedMove.damageClass.id == DamageClass.special) defenderTimingIDs.addAll([124]);   // とくしゅこうげきを受けた時
          if (replacedMove.isDirect && attackerState.currentAbility.id != 203) {
            defenderTimingIDs.add(9);  // 直接攻撃を受けた時(確率)
            defenderTimingIDs.add(63);  // 直接攻撃を受けた時
            attackerTimingIDs.add(84);  // 直接攻撃をあてたとき(確率)
            // 違う性別の相手から直接攻撃を受けた時（確率）
            if (attackerState.sex != defenderState.sex && attackerState.sex != Sex.none) defenderTimingIDs.add(69);
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
          if (replacedMove.isSound) {
            attackerTimingIDs.add(123);  // 音技を使ったとき
            defenderTimingIDs.add(64);  // 音技を受けた時
          }
          if (replacedMove.isDrain) defenderTimingIDs.add(40);  // HP吸収わざを受けた時
          if (replacedMove.isDance) defenderTimingIDs.add(97);  // おどり技を受けた時
          if (replacedMoveType.id == 1) {  // ノーマルタイプのわざを受けた時
            defenderTimingIDs.addAll([148]);
          }
          if (replacedMoveType.id == 13) {  // でんきタイプのわざを受けた時
            defenderTimingIDs.addAll([10, 26]);
          }
          if (replacedMoveType.id == 11) {  // みずタイプのわざを受けた時
            defenderTimingIDs.addAll([11, 50, 78]);
          }
          if (replacedMoveType.id == 10) {  // ほのおタイプのわざを受けた時
            defenderTimingIDs.addAll([17, 50]);
          }
          if (replacedMoveType.id == 12) {  // くさタイプのわざを受けた時
            defenderTimingIDs.addAll([88]);
          }
          if (replacedMoveType.id == 5) {   // じめんタイプのわざを受けた時
            defenderTimingIDs.addAll([115]);
          }
          if (PokeType.effectiveness(
              attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
              defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              replacedMoveType, pokemonState!
            ).id == MoveEffectiveness.great
          ) {
            defenderTimingIDs.add(120);  // 効果ばつぐんのタイプのこうげきざわを受けた時
            if (replacedMoveType.id == 10) defenderTimingIDs.add(131);
            if (replacedMoveType.id == 11) defenderTimingIDs.add(132);
            if (replacedMoveType.id == 13) defenderTimingIDs.add(133);
            if (replacedMoveType.id == 12) defenderTimingIDs.add(134);
            if (replacedMoveType.id == 15) defenderTimingIDs.add(135);
            if (replacedMoveType.id == 2) defenderTimingIDs.add(136);
            if (replacedMoveType.id == 4) defenderTimingIDs.add(137);
            if (replacedMoveType.id == 5) defenderTimingIDs.add(138);
            if (replacedMoveType.id == 3) defenderTimingIDs.add(139);
            if (replacedMoveType.id == 14) defenderTimingIDs.add(140);
            if (replacedMoveType.id == 7) defenderTimingIDs.add(141);
            if (replacedMoveType.id == 6) defenderTimingIDs.add(142);
            if (replacedMoveType.id == 8) defenderTimingIDs.add(143);
            if (replacedMoveType.id == 16) defenderTimingIDs.add(144);
            if (replacedMoveType.id == 17) defenderTimingIDs.add(145);
            if (replacedMoveType.id == 9) defenderTimingIDs.add(146);
            if (replacedMoveType.id == 18) defenderTimingIDs.add(147);
          }
          else {
            defenderTimingIDs.add(21);  // 効果ばつぐん以外のタイプのこうげきざわを受けた時
          }
          if (replacedMoveType.id == 5) {
            if (replacedMove.id != 28 && replacedMove.id != 614) {  // すなかけ/サウザンアローではない
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
      case AbilityTiming.afterTerastal:   // テラスタル後
        {
          timingIDs.clear();
          attackerTimingIDs.clear();
          defenderTimingIDs.clear();
          if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
            bool isMe = playerType.id == PlayerType.me;
            bool isTerastal = pokemonState!.isTerastaling && (isMe ? !currentTurn.initialOwnHasTerastal : !currentTurn.initialOpponentHasTerastal);

            if (isTerastal && pokemonState.currentAbility.id == 303) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effect = EffectType(EffectType.ability)
                ..effectId = 303
              );
            }
          }
        }
        break;
      default:
        return [];
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
          var adding = TurnEffect()
            ..playerType = playerType
            ..effect = EffectType(EffectType.individualField)
            ..effectId = e;
          if (adding.effectId == IndiFieldEffect.trickRoomEnd) {    // 各々の場だが効果としては両フィールドのもの
            adding.playerType = PlayerType(PlayerType.entireField);
            if (ret.where((element) => element.nearEqual(adding)).isNotEmpty) {
              ret.add(adding);
            }
          }
          else {
            ret.add(adding);
          }
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
      for (var e in fieldEffectIDs) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.field)
          ..effectId = e
        );
      }
    }

    // argの自動セット
    var myState = playerType.id != PlayerType.opponent ?
      phaseState.getPokemonState(PlayerType(PlayerType.me), prevAction) : phaseState.getPokemonState(PlayerType(PlayerType.opponent), prevAction);
    var yourState = playerType.id != PlayerType.opponent ?
      phaseState.getPokemonState(PlayerType(PlayerType.opponent), prevAction) : phaseState.getPokemonState(PlayerType(PlayerType.me), prevAction);
    for (var effect in ret) {
      effect.timing = timing;
      effect.setAutoArgs(myState, yourState, phaseState, prevAction);
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

  // 効果に対応して、argsを自動でセット
  void setAutoArgs(
    PokemonState myState, PokemonState yourState, PhaseState state, TurnEffect? prevAction,
  ) {
    switch (effect.id) {
      case EffectType.ability:
        extraArg1 = Ability.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = Ability.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.item:
        extraArg1 = Item.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = Item.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.ailment:
        extraArg1 = Ailment.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = Ailment.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.individualField:
        extraArg1 = IndividualField.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = IndividualField.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
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
      case AbilityTiming.afterTerastal:
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
                case AilmentEffect.leechSeed:   // やどりぎのタネ
                case AilmentEffect.ingrain:     // ねをはる
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
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal:   // グラスフィールドによる回復
                  return state.getPokemonState(PlayerType(PlayerType.me), null).remainHP.toString();
              }
              break;
          }
        }
    }
    return '';
  }

  String getEditingControllerText3(
    PhaseState state,
    TurnEffect? prevAction,
    {
      bool isOnMoveSelected = false,
    }
  ) {
    var myState = state.getPokemonState(playerType, timing.id == AbilityTiming.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(playerType.opposite, timing.id == AbilityTiming.afterMove ? prevAction : null);
    var pokeData = PokeDB();

    // わざが選択されたときのみ、extraArgを引いたHPの値をセット
    if (isOnMoveSelected) {
      switch (timing.id) {
        case AbilityTiming.action:
        case AbilityTiming.continuousMove:
          {
            if (move == null) return '';
            switch (move!.moveAdditionalEffects[0].id) {
              case 33:    // 最大HPの半分だけ回復する
              case 215:   // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
              case 80:    // 場に「みがわり」を発生させる
              case 133:   // 使用者のHP回復。回復量は天気による
              case 163:   // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
              case 382:   // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
              case 387:   // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
              case 441:   // 最大HP1/4だけ回復
              case 420:   // 最大HP1/2(小数点切り上げ)を削ってこうげき
              case 433:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
              case 461:   // 最大HP1/4回復、状態異常を治す
              case 492:   // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
                if (move!.playerType.id == PlayerType.me) {
                  return (myState.remainHP - move!.extraArg1[0]).toString();
                }
                else if (move!.playerType.id == PlayerType.opponent) {
                  return (myState.remainHPPercent - move!.extraArg2[0]).toString();
                }
                break;
              case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
                if (myState.isTypeContain(8)) {
                  if (move!.playerType.id == PlayerType.me) {
                    return (myState.remainHP - move!.extraArg1[0]).toString();
                  }
                  else if (move!.playerType.id == PlayerType.opponent) {
                    return (myState.remainHPPercent - move!.extraArg2[0]).toString();
                  }
                }
                break;
              default:
                break;
            }
          }
          break;
        default:
          break;
      }
    }

    switch (timing.id) {
      case AbilityTiming.action:
      case AbilityTiming.continuousMove:
        {
          if (move == null) return '';
          switch (move!.moveAdditionalEffects[0].id) {
            case 106:   // もちものを盗む
            case 178:   // 使用者ともちものを入れ替える
            case 185:   // 戦闘中自分が最後に使用したもちものを復活させる
            case 189:   // もちものを持っていれば失わせ、威力1.5倍
            case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            case 234:   // 使用者のもちものによって威力と追加効果が変わる
            case 324:   // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
            case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
              return pokeData.items[move!.extraArg1[0]]!.displayName;
            case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
              return pokeData.moves[move!.extraArg3[0]]!.displayName;
            case 179:   // 相手と同じとくせいになる
            case 192:   // 使用者ととくせいを入れ替える
            case 300:   // 相手のとくせいを使用者のとくせいと同じにする
              return pokeData.abilities[move!.extraArg1[0]]!.displayName;
            //TODO
            case 456:   // 対象にもちものがあるときのみ成功
            case 457:   // 対象のもちものを消失させる
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
                case 139:   // しゅうかく
                  return pokeData.items[extraArg1]!.displayName;
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
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal:   // グラスフィールドによる回復
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

  Widget extraWidget(
    void Function() onFocus,
    ThemeData theme,
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
    {required bool isInput,}
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
          return DamageIndicateRow(
            myPokemon, controller,
            playerType.id == PlayerType.me,
            onFocus,
            (value) {
              if (playerType.id == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
          );
        case 16:      // へんしょく
        case 168:     // へんげんじざい
        case 236:     // リベロ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myTypeDropdownButton(
                  '変化後のタイプ',
                  (value) {
                    extraArg1 = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus,
                  extraArg1 == 0 ? null : extraArg1,
                  isInput: isInput,
                ),
              ),
            ],
          );
        case 24:    // さめはだ
        case 106:   // ゆうばく
        case 123:   // ナイトメア
        case 160:   // てつのトゲ
        case 215:   // とびだすなかみ
          return DamageIndicateRow(
            yourPokemon, controller,
            playerType.id != PlayerType.me,
            onFocus,
            (value) {
              if (playerType.id == PlayerType.me) {
                extraArg1 = yourState.remainHPPercent - (int.tryParse(value)??0);
              }
              else {
                extraArg1 = yourState.remainHP - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
          );
        case 27:    // ほうし
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: Ailment(extraArg1).displayName,
                ),
              ),
            ],
          );
        case 36:    // トレース
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
        case 53:    // ものひろい
        case 139:   // しゅうかく
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
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
                    matches.removeWhere((e) => e.id == 0);
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
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
        case 88:     // ダウンロード
          return Row(
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1 == 0 ? 'こうげき' : 'とくこう',
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
                child: _myTypeAheadField(
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
                  onFocus: onFocus,
                  isInput: isInput,
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
                child: _myTypeAheadField(
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
                  onFocus: onFocus,
                  isInput: isInput,
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
                    child: _myDropdownButtonFormField(
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
                      onFocus: onFocus,
                      isInput: isInput,
                      textValue: extraArg1 == 0 ? 'こうげき' : extraArg1 == 1 ? 'ぼうぎょ' :
                        extraArg1 == 2 ? 'とくこう' : extraArg1 == 3 ? 'とくぼう' : 'すばやさ',
                    ),
                  ),
                  Text('がぐーんとあがった'),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Flexible(
                    child: _myDropdownButtonFormField(
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
                      onFocus: onFocus,
                      isInput: isInput,
                      textValue: extraArg2 == 0 ? 'こうげき' : extraArg2 == 1 ? 'ぼうぎょ' :
                        extraArg2 == 2 ? 'とくこう' : extraArg2 == 3 ? 'とくぼう' : 'すばやさ',
                    ),
                  ),
                  Text('がさがった'),
                ],
              ),
            ],
          );
        case 149:     // イリュージョン
          if (playerType.id == PlayerType.opponent) {
            return Row(
              children: [
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'イリュージョンしていたポケモン',
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          //enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            /*style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon) ?
                              Colors.black : Colors.grey),*/
                            ),
                        ),
                    ],
                    value: extraArg1,
                    onChanged: (value) {
                      extraArg1 = value;
                      appState.editingPhase[phaseIdx] = true;
                      appState.needAdjustPhases = phaseIdx+1;
                      onFocus();
                    },
                    onFocus: onFocus,
                    isInput: isInput,
                    textValue: opponentParty.pokemons[extraArg1-1]?.name,
                  ),
                ),
              ],
            );
          }
          break;
        case 281:     // こだいかっせい
        case 282:     // クォークチャージ
        case 224:     // ビーストブースト
          return Row(
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: -1,
                      child: Text('効果が切れた'),
                    ),
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1 == 0 ? 'こうげき' : extraArg1 == 1 ? 'ぼうぎょ' :
                    extraArg1 == 2 ? 'とくこう' : extraArg1 == 3 ? 'とくぼう' : extraArg1 == 4 ? 'すばやさ' : '効果が切れた',
                ),
              ),
              extraArg1 >= 0 ? Text('が高まった') : Text(''),
            ],
          );
        case 290:     // びんじょう
          return Row(
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1 == 0 ? 'こうげき' : extraArg1 == 1 ? 'ぼうぎょ' :
                    extraArg1 == 2 ? 'とくこう' : extraArg1 == 3 ? 'とくぼう' : 'すばやさ',
                ),
              ),
              Text('が'),
              Flexible(
                child: _myDropdownButtonFormField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg2.toString(),
                ),
              ),
              Text('段階あがった'),
            ],
          );
        case 216:   // おどりこ
          return Column(
            children: [
              Expanded(
                child: _myTypeAheadField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
              SizedBox(height: 10,),
              extraArg1 == 872 || extraArg1 == 80 || extraArg1 == 552 || extraArg1 == 10552 || extraArg1 == 686 ?
              DamageIndicateRow(
                yourPokemon, controller,
                playerType.id != PlayerType.me,
                onFocus,
                (value) {
                  if (playerType.id == PlayerType.me) {
                    extraArg2 = yourState.remainHPPercent - (int.tryParse(value)??0);
                  }
                  else {
                    extraArg2 = yourState.remainHP - (int.tryParse(value)??0);
                  }
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg2,
                isInput,
              ) :
              extraArg1 == 775 ?
              DamageIndicateRow(
                myPokemon, controller,
                playerType.id == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType.id == PlayerType.me) {
                    extraArg2 = myState.remainHP - (int.tryParse(value)??0);
                  }
                  else {
                    extraArg2 = myState.remainHPPercent - (int.tryParse(value)??0);
                  }
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg2,
                isInput,
              ) :
              Container(),
              extraArg1 == 552 || extraArg1 == 10552 ? SizedBox(height: 10,) : Container(),
              extraArg1 == 552 || extraArg1 == 10552 ?
              Expanded(
                child: _myDropdownButtonFormField(
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
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1 == 552 ? 'なし' : 'とくこうがあがった',
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
      return appState.pokeData.items[effectId]!.extraWidget(
        onFocus, theme, playerType, myPokemon, yourPokemon, myState,
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
        isInput,
        showNetworkImage: PokeDB().getPokeAPI,
      );
    }
    else if (effect.id == EffectType.individualField) {   // 各ポケモンの場による効果
      switch (effectId) {
        case IndiFieldEffect.spikes1:           // まきびし
        case IndiFieldEffect.spikes2:
        case IndiFieldEffect.spikes3:
        case IndiFieldEffect.futureAttack:      // みらいにこうげき
        case IndiFieldEffect.stealthRock:       // ステルスロック
        case IndiFieldEffect.wish:              // ねがいごと
          return DamageIndicateRow(
            myPokemon, controller,
            playerType.id == PlayerType.me,
            onFocus,
            (value) {
              if (playerType.id == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
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
        case AilmentEffect.ingrain:   // ねをはる
          return DamageIndicateRow(
            myPokemon, controller,
            playerType.id == PlayerType.me,
            onFocus,
            (value) {
              if (playerType.id == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
          );
        case AilmentEffect.leechSeed:   // やどりぎのタネ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                myPokemon, controller,
                playerType.id == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType.id == PlayerType.me) {
                    extraArg1 = myState.remainHP - (int.tryParse(value)??0);
                  }
                  else {
                    extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
                  }
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
              ),
              SizedBox(height: 10,),
              DamageIndicateRow(
                yourPokemon, controller2,
                playerType.id != PlayerType.me,
                onFocus,
                (value) {
                  if (playerType.id == PlayerType.me) {
                    extraArg2 = yourState.remainHPPercent - (int.tryParse(value)??0);
                  }
                  else {
                    extraArg2 = yourState.remainHP - (int.tryParse(value)??0);
                  }
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg2,
                isInput,
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
              DamageIndicateRow(
                ownPokemon, controller,
                true,
                onFocus,
                (value) {
                  extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
              ),
              SizedBox(height: 10,),
              DamageIndicateRow(
                opponentPokemon, controller2,
                false,
                onFocus,
                (value) {
                  extraArg2 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg2,
                isInput,
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
              DamageIndicateRow(
                ownPokemon, controller,
                true,
                onFocus,
                (value) {
                  extraArg1 = ownPokemonState.remainHP - (int.tryParse(value)??0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
              ),
              SizedBox(height: 10,),
              DamageIndicateRow(
                opponentPokemon, controller2,
                false,
                onFocus,
                (value) {
                  extraArg2 = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg2,
                isInput,
              ),
            ],
          );
      }
    }
    else if (effect.id == EffectType.afterMove) {   // わざによる効果
      switch (effectId) {
        case 596:   // ニードルガード
          return DamageIndicateRow(
            myPokemon, controller,
            playerType.id == PlayerType.me,
            onFocus,
            (value) {
              if (playerType.id == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg1 = myState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
          );
      }
    }

    return Container();
  }

  Widget _myTypeAheadField<T>({
    required SuggestionsCallback<T> suggestionsCallback,
    required ItemBuilder<T> itemBuilder,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    TextFieldConfiguration textFieldConfiguration = const TextFieldConfiguration(),
    SuggestionsBoxDecoration suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    Duration debounceDuration = const Duration(milliseconds: 300),
    SuggestionsBoxController? suggestionsBoxController,
    ScrollController? scrollController,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? noItemsFoundBuilder,
    ErrorBuilder? errorBuilder,
    AnimationTransitionBuilder? transitionBuilder,
    double animationStart = 0.25,
    Duration animationDuration = const Duration(milliseconds: 500),
    bool getImmediateSuggestions = false,
    double suggestionsBoxVerticalOffset = 5.0,
    AxisDirection direction = AxisDirection.down,
    bool hideOnLoading = false,
    bool hideOnEmpty = false,
    bool hideOnError = false,
    bool hideSuggestionsOnKeyboardHide = true,
    bool keepSuggestionsOnLoading = true,
    bool keepSuggestionsOnSuggestionSelected = false,
    bool autoFlipDirection = false,
    bool autoFlipListDirection = true,
    bool hideKeyboard = false,
    int minCharsForSuggestions = 0,
    void Function(bool)? onSuggestionsBoxToggle,
    bool hideKeyboardOnDrag = false,
    Key? key,
    required void Function() onFocus,
    required bool isInput,
  })
  {
    if (isInput) {
      return TypeAheadField(
        suggestionsCallback: suggestionsCallback, itemBuilder: itemBuilder, onSuggestionSelected: onSuggestionSelected,
        textFieldConfiguration: textFieldConfiguration, suggestionsBoxDecoration: suggestionsBoxDecoration,
        debounceDuration: debounceDuration, suggestionsBoxController: suggestionsBoxController, scrollController: scrollController,
        loadingBuilder: loadingBuilder, noItemsFoundBuilder: noItemsFoundBuilder, errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder, animationStart: animationStart, animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions, suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction, hideOnLoading: hideOnLoading, hideOnEmpty: hideOnEmpty, hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide, keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected, autoFlipDirection: autoFlipDirection,
        autoFlipListDirection: autoFlipListDirection, hideKeyboard: hideKeyboard, minCharsForSuggestions: minCharsForSuggestions,
        onSuggestionsBoxToggle: onSuggestionsBoxToggle, hideKeyboardOnDrag: hideKeyboardOnDrag, key: key,
      );
    }
    else {
      return TextField(
        controller: textFieldConfiguration.controller,
        decoration: textFieldConfiguration.decoration,
        readOnly: true,
        onTap: onFocus,
      );
    }
  }

  Widget _myDropdownButtonFormField<T>({
    Key? key,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    T? value,
    Widget? hint,
    Widget? disabledHint,
    required ValueChanged<T?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    required bool isInput,
    required String? textValue,   // isInput==falseのとき、出力する文字列として必須
    required void Function() onFocus,
  })
  {
    if (isInput) {
      return DropdownButtonFormField(
        key: key, items: items, selectedItemBuilder: selectedItemBuilder, value: value,
        hint: hint, disabledHint: disabledHint, onChanged: onChanged, onTap: onTap,
        elevation: elevation, style: style, icon: icon, iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor, iconSize: iconSize, isDense: isDense,
        isExpanded: isExpanded, itemHeight: itemHeight, focusColor: focusColor,
        focusNode: focusNode, autofocus: autofocus, dropdownColor: dropdownColor,
        decoration: decoration, onSaved: onSaved, validator: validator, autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight, enableFeedback: enableFeedback, alignment: alignment,
        borderRadius: borderRadius, padding: padding,
      );
    }
    else {
      return TextField(
        decoration: decoration,
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
        onTap: onFocus,
      );
    }
  }

  Widget _myTypeDropdownButton(
    String? labelText,
    void Function(dynamic)? onChanged,
    void Function() onFocus,
    int? value,
    {
      required bool isInput,
      bool isError = false,
    }
  )
  {
    if (isInput) {
      return TypeDropdownButton(
        labelText, onChanged, value,
        isError: isError,
      );
    }
    else {
      return TextField(
        controller: TextEditingController(text: PokeType.createFromId(value ?? 0).displayName),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: labelText,
          prefixIcon: PokeType.createFromId(value ?? 0).displayIcon,
        ),
        onTap: onFocus,
        readOnly: true,
      );
    } 
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
    // isAutoSet
    effect.isAutoSet = int.parse(effectElements[15]) != 0;

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
    ret += split1;
    // isAutoSet
    ret += isAutoSet ? '1' : '0';

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
  List<TurnEffect> candidateEffect = [];    // 入力される候補となるTurnEffectのリスト

  // candidateEffectを更新する
  // candidateEffectは、各タイミングの最初の要素に入れておくのがbetter？
  void updateEffectCandidates(Turn currentTurn, PhaseState prevState) {
    candidateEffect.clear();
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType(PlayerType.me), null, currentTurn, prevState,)
    );
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType(PlayerType.opponent), null, currentTurn, prevState,)
    );
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType(PlayerType.entireField), null, currentTurn, prevState,)
    );
  }

  List<TurnEffect> _getEffectCandidates(
    AbilityTiming timing,
    PlayerType playerType,
    EffectType? effectType,
    Turn turn,
    PhaseState phaseState,
  ) {
    if (playerType.id == PlayerType.none) return [];
    
    // prevActionを設定
    TurnEffect? prevAction;
    if (timing.id == AbilityTiming.afterMove) {
      for (int i = phaseIdx-1; i >= 0; i--) {
        if (turn.phases[i].timing.id == AbilityTiming.action) {
          prevAction = turn.phases[i];
          break;
        }
        else if (turn.phases[i].timing.id != timing.id) {
          break;
        }
      }
    }
    else if (timing.id == AbilityTiming.beforeMove) {
      for (int i = phaseIdx+1; i < turn.phases.length; i++) {
        if (turn.phases[i].timing.id == AbilityTiming.action) {
          prevAction = turn.phases[i];
          break;
        }
        else if (turn.phases[i].timing.id != timing.id) {
          break;
        }
      }
    }
    PlayerType attacker = prevAction != null ? prevAction.playerType : PlayerType(PlayerType.none);
    TurnMove turnMove = prevAction?.move != null ? prevAction!.move! : TurnMove();
    
    if (playerType.id == PlayerType.entireField) {
      return _getEffectCandidatesWithEffectType(timing, playerType, EffectType(EffectType.ability), attacker, turnMove, turn, prevAction, phaseState);
    }
    if (effectType == null) {
      List<TurnEffect> ret = [];
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType(EffectType.ability), attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType(EffectType.item), attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType(EffectType.individualField), attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType(EffectType.ailment), attacker, turnMove, turn, prevAction, phaseState)
      );
      return ret;
    }
    else {
      return _getEffectCandidatesWithEffectType(timing, playerType, effectType, attacker, turnMove, turn, prevAction, phaseState);
    }
  }

  List<TurnEffect> _getEffectCandidatesWithEffectType(
    AbilityTiming timing,
    PlayerType playerType,
    EffectType effectType,
    PlayerType attacker,
    TurnMove turnMove,
    Turn turn,
    TurnEffect? prevAction,
    PhaseState phaseState,
  ) {
    return TurnEffect.getPossibleEffects(timing, playerType, effectType,
    playerType.id == PlayerType.me || playerType.id == PlayerType.opponent ?
      phaseState.getPokemonState(playerType, prevAction).pokemon : null,
    playerType.id == PlayerType.me || playerType.id == PlayerType.opponent ? phaseState.getPokemonState(playerType, prevAction) : null,
    phaseState, attacker, turnMove, turn, prevAction);
  }
}
