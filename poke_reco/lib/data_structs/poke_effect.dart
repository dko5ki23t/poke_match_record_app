import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/guide.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tuple/tuple.dart';

enum EffectType {
  none,
  ability,
  item,
  individualField,
  ailment,
  weather,
  field,
  move,
  changeFaintingPokemon,
  terastal,
  afterMove,
}

extension EffectTypename on EffectType {
  static const Map<int, Tuple2<String, String>>_displayNameMap = {
    0:  Tuple2('', ''),
    1:  Tuple2('とくせい', 'Ability'),
    2:  Tuple2('もちもの', 'Item'),
    3:  Tuple2('場', 'Individual Field'),
    4:  Tuple2('状態変化', 'Status conditions'),
    5:  Tuple2('', ''),
    6:  Tuple2('', ''),
    7:  Tuple2('', ''),
    8:  Tuple2('', ''),
    9:  Tuple2('', ''),
    10: Tuple2('わざ', 'Move'),
  };

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[index]!.item1;
      case Language.english:
      default:
        return _displayNameMap[index]!.item2;
    }
  }
}

// 各タイミング共通
const List<Timing> allTimings = [
  Timing.blasted,           // ばくはつ系のわざ、とくせいが発動したとき
  Timing.paralysised,       // まひするわざ、とくせいを受けた時
  Timing.attractedTauntedIntimidated,    // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
  Timing.sleeped,          // ねむり・ねむけの効果を受けた時
  Timing.poisoned,         // どく・もうどくの効果を受けた時
  Timing.confusedIntimidated,  // こんらん/いかくの効果を受けた時
  Timing.changeForced,     // こうたいわざやレッドカードによるこうたいを強制されたとき
  Timing.groundFieldEffected,  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  Timing.poisonedParalysisedBurnedByOppositeMove,    // 相手から受けた技でどく/まひ/やけど状態にされたとき
  Timing.statChangedByNotMyself,   // 自身以外の効果によって能力変化が起きるとき
  Timing.flinchedIntimidated,  // ひるみやいかくを受けた時
  Timing.frozen,           // こおり状態になったとき
  Timing.burned,           // やけど状態になったとき
  Timing.accuracyDownedAttack,    // 命中率が下がるとき、こうげきするとき
  Timing.itemLostByOpponent,   // もちものを奪われたり失ったりするとき
  Timing.attackChangedByNotMyself,   // 自身以外の効果によってこうげきランクが下がるとき
  Timing.flinched,         // ひるんだとき
  Timing.intimidated,            // いかくを受けた時
  Timing.guardChangedByNotMyself,    // 自身以外の効果によってぼうぎょランクが下がるとき
  Timing.evilGhostBugAttackedIntimidated,  // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  Timing.mentalAilments,         // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  Timing.firedWaterAttackBurned, // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  Timing.otherFainting,          // 場にいるポケモンがひんしになったとき
  Timing.phisycalAttackedHittedSnowed,  // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  Timing.fieldChanged,           // フィールドが変化したとき
  Timing.abnormaledSleepy,       // 状態異常・ねむけになるとき
  Timing.winded,                 // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  Timing.changeForcedIntimidated,  // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  Timing.sunnyBoostEnergy,       // 天気が晴れかブーストエナジーを持っているとき
  Timing.elecFieldBoostEnergy,   // エレキフィールドかブーストエナジーを持っているとき
  Timing.opponentStatUp,         // 相手の能力ランクが上昇したとき
  Timing.hp025,                  // HPが1/4以下になったとき
  Timing.elecField,              // エレキフィールドのとき
  Timing.grassField,             // グラスフィールドのとき
  Timing.psycoField,             // サイコフィールドのとき
  Timing.mistField,              // ミストフィールドのとき
  Timing.statDowned,             // 能力ランクが下がったとき
  Timing.trickRoom,              // トリックルームのとき
  Timing.hp050,                  // HPが1/2以下になったとき
  Timing.abnormaledConfused,     // 状態異常・こんらんになるとき
  Timing.confused,               // こんらんになるとき
  Timing.infatuation,            // メロメロになるとき
  Timing.changedIgnoredAbility,  // とくせいを変更される、無効化される、無視されるとき
];

// ポケモンを繰り出すとき
// タイミング
const List<Timing> pokemonAppearTimings = [
  Timing.pokemonAppear,     // ポケモン登場時
  Timing.pokemonAppearWithChance,    // ポケモン登場時(確率/条件)
  Timing.pokemonAppearWithChanceEveryTurnEndWithChance,  // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.pokemonAppearAttacked,  // ポケモン登場時・こうげきを受けたとき
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
const List<Timing> afterActionDecisionTimings = [
  Timing.afterActionDecision,    // 行動決定後、行動実行前
  Timing.afterActionDecisionWithChance,    // 行動決定後、行動実行前(確率)
  Timing.afterActionDecisionHP025,  // HPが1/4以下で行動決定後
];

// わざ使用前
// タイミング
const List<Timing> beforeMoveAttackerTimings = [
  Timing.beforeMoveWithChance,   // わざ使用前(確率・条件)
];
const List<Timing> beforeMoveDefenderTimings = [
  Timing.beforeTypeNormalOrGreatAttackedWithFullHP,   // HPが満タンで等倍以上のタイプ相性わざを受ける前
];

// わざ使用後
// タイミング
const List<Timing> afterMoveAttackerTimings = [
  Timing.attackSuccessedWithChance,          // こうげきし、相手にあたったとき(確率)
  Timing.movingWithChance, // わざを使うとき(確率・条件)
  Timing.movingMovedWithCondition,   // わざを使うとき(条件)、特定のわざを使ったとき
  Timing.notHit,                 // わざが当たらなかったとき
  Timing.runOutPP,               // 1つのわざのPPが0になったとき
  Timing.chargeMoving,           // ためわざを使うとき
];
const List<Timing> afterMoveDefenderTimings = [
  Timing.hpMaxAndAttacked,  // HPが満タンでこうげきを受けた時
  Timing.criticaled,       // こうげきが急所に当たった時
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
const List<Timing> everyTurnEndTimings = [
  Timing.everyTurnEnd,      // 毎ターン終了時
  Timing.everyTurnEndWithChance,  // 毎ターン終了時（確率・条件）
  Timing.pokemonAppearWithChanceEveryTurnEndWithChance,  // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.everyTurnEndHPNotFull,  // HPが満タンでない毎ターン終了時
  Timing.everyTurnEndHPNotFull2, // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
];

class TurnEffect {
  PlayerType playerType = PlayerType.none;
  Timing timing = Timing.none;
  EffectType effectType = EffectType.none;
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
  List<int> invalidGuideIDs = [];

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..timing = timing
    ..effectType = effectType
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
    ..isAutoSet = isAutoSet
    ..invalidGuideIDs = [...invalidGuideIDs];

  int? getChangePokemonIndex(PlayerType player) {
    if (player == PlayerType.me) return _changePokemonIndexes[0];
    return _changePokemonIndexes[1];
  }

  void setChangePokemonIndex(PlayerType player, int? val) {
    if (player == PlayerType.me) {
      _changePokemonIndexes[0] = val;
    }
    else {
      _changePokemonIndexes[1] = val;
    }
  }

  int getPrevPokemonIndex(PlayerType player) {
    if (player == PlayerType.me) return _prevPokemonIndexes[0];
    return _prevPokemonIndexes[1];
  }

  void setPrevPokemonIndex(PlayerType player, int val) {
    if (player == PlayerType.me) {
      _prevPokemonIndexes[0] = val;
    }
    else {
      _prevPokemonIndexes[1] = val;
    }
  }

  bool isValid() {
    return
      playerType != PlayerType.none &&
      effectType != EffectType.none &&
      (effectType == EffectType.move && move != null && move!.isValid() || effectId > 0);
  }

  bool nearEqual(TurnEffect other) {
    return playerType == other.playerType &&
      timing == other.timing &&
      effectType == other.effectType &&
      effectId == other.effectId;
  }

  // 効果やわざの結果から、各ポケモン等の状態を更新する
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentParty,
    PokemonState opponentPokemonState,
    PhaseState state,
    TurnEffect? prevAction,
    int continuousCount,
    {
      required AppLocalizations loc,
    }
  )
  {
    final pokeData = PokeDB();
    List<Guide> ret = [];
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
    setPrevPokemonIndex(PlayerType.me, state.getPokemonIndex(PlayerType.me, null));
    setPrevPokemonIndex(PlayerType.opponent, state.getPokemonIndex(PlayerType.opponent, null));

    bool isMe = playerType == PlayerType.me;
    var myState = timing == Timing.afterMove && prevAction != null ?
      state.getPokemonState(playerType, prevAction) : isMe ? ownPokemonState : opponentPokemonState;
    var yourState = timing == Timing.afterMove && prevAction != null ?
      state.getPokemonState(playerType.opposite, prevAction) : isMe ? opponentPokemonState : ownPokemonState;
    var myFields = state.getIndiFields(playerType);
    var yourFields = state.getIndiFields(playerType.opposite);
    var myParty = isMe ? ownParty : opponentParty;
    var myPokemonIndex = state.getPokemonIndex(playerType, timing == Timing.afterMove ? prevAction : null);

    switch (effectType) {
      case EffectType.ability:
        ret.addAll(Ability.processEffect(
          effectId, playerType, myState, yourState, state,
          myParty, myPokemonIndex, opponentPokemonState,
          extraArg1, extraArg2, getChangePokemonIndex(playerType),
          loc: loc,
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
            default:
              IndiFieldEffect.processRemove(effectId, myFields, yourFields);
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
          yourState, state, extraArg1, extraArg2,
          getChangePokemonIndex(playerType), loc: loc,
        ));
        break;
      case EffectType.move:
        {
          // テラスタル済みならわざもテラスタル化
          if (myState.isTerastaling) {
            move!.teraType = myState.teraType1;
          }
          ret.addAll(
            move!.processMove(
              ownParty, opponentParty, ownPokemonState, opponentPokemonState,
              state, continuousCount, invalidGuideIDs, loc: loc,)
          );
          // ポケモン交代の場合、もちもの失くした判定用に変数セット
          if (move!.type.id == TurnMoveType.change) {
            if (playerType == PlayerType.me) isOwnChanged = true;
            if (playerType == PlayerType.opponent) isOpponentChanged = false;
          }
        }
        break;
      case EffectType.changeFaintingPokemon:    // ひんし後のポケモン交代
        // のうりょく変化リセット、現在のポケモンを表すインデックス更新
        myState.processExitEffect(true, yourState, state);
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
            yourState, playerType == PlayerType.me, state
          );
        }
        if (myState.pokemon.id == 1024) {   //テラパゴスがテラスタルした場合
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.terastalForm);
          if (findIdx < 0) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.stellarForm));
          }
          else {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.stellarForm);
          }
          // TODO この2行csvに移したい
          myState.maxStats.h.race = 160; myState.maxStats.a.race = 105; myState.maxStats.b.race = 110; myState.maxStats.c.race = 130; myState.maxStats.d.race = 110; myState.maxStats.s.race = 85;
          myState.minStats.h.race = 160; myState.minStats.a.race = 105; myState.minStats.b.race = 110; myState.minStats.c.race = 130; myState.minStats.d.race = 110; myState.minStats.s.race = 85;
          for (final stat in StatIndexList.listHtoS) {
            var biases = Temper.getTemperBias(myState.pokemon.temper);
            myState.maxStats[stat].real = SixParams.getRealABCDS(
              myState.pokemon.level, myState.maxStats[stat].race, myState.maxStats[stat].indi, myState.maxStats[stat].effort, biases[stat.index-1]);
            myState.minStats[stat].real = SixParams.getRealABCDS(
              myState.pokemon.level, myState.minStats[stat].race, myState.minStats[stat].indi, myState.minStats[stat].effort, biases[stat.index-1]);
          }
          if (playerType == PlayerType.me) {
            myState.remainHP += (65 * 2 * myState.pokemon.level / 100).floor();
          }
        }
        if (playerType == PlayerType.me) {
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
            if (playerType == PlayerType.me) {
              myState.remainHP -= extraArg1;
            }
            else {
              myState.remainHPPercent -= extraArg1;
            }
            break;
          case AilmentEffect.leechSeed:
            if (playerType == PlayerType.me) {
              myState.remainHP -= extraArg1;
              yourState.remainHPPercent -= extraArg2;
            }
            else {
              myState.remainHPPercent -= extraArg1;
              yourState.remainHP -= extraArg2;
            }
            // 相手HP確定
            if (playerType == PlayerType.opponent) {
              int drain = extraArg2.abs();
              if (yourState.remainHP < yourState.pokemon.h.real && myState.remainHPPercent > 0 && drain > 0) {
                if (yourState.holdingItem?.id == 273) {   // おおきなねっこ
                  int tmp = ((drain.toDouble() + 0.5) / 1.3).round();
                  while (roundOff5(tmp * 1.3) > drain) {tmp--;}
                  drain = tmp;
                }
                int hpMin = drain * 8;
                int hpMax = hpMin + 3;
                if (hpMin != myState.minStats.h.real || hpMax != myState.maxStats.h.real) {
                  ret.add(Guide()
                    ..guideId = Guide.leechSeedConfHP
                    ..args = [hpMin, hpMax]
                    ..guideStr = loc.battleGuideLeechSeedConfHP(hpMax, hpMin, myState.pokemon.omittedName)
                  );
                }
              }
            }
            break;
          case AilmentEffect.partiallyTrapped:
            if (extraArg2 > 0) {
              myState.ailmentsRemoveWhere((e) => e.id == Ailment.partiallyTrapped);
            }
            else {
              if (playerType == PlayerType.me) {
                myState.remainHP -= extraArg1;
              }
              else {
                myState.remainHPPercent -= extraArg1;
              }
            }
            break;
          case AilmentEffect.perishSong:
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case AilmentEffect.octoLock:
            myState.addStatChanges(true, 1, -1, yourState);
            myState.addStatChanges(true, 3, -1, yourState);
            break;
          case AilmentEffect.candyCandy:
            if (extraArg2 > 0) {
              myState.ailmentsRemoveWhere((e) => e.id == Ailment.candyCandy);
            }
            else {
              myState.addStatChanges(false, 4, -1, yourState);
            }
            break;
          default:
            AilmentEffect.processRemove(effectId, myState);
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
            if (playerType == PlayerType.me) {
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
          case 508:   // かえんのまもり
            myState.ailmentsAdd(Ailment(Ailment.burn), state);
            break;
        }
        break;
      default:
        break;
    }

    // 相手のパラメータ等推定(これ以降でretへの追加禁止)
    ret.removeWhere((element) => invalidGuideIDs.contains(element.guideId));
    // パラメータ等推定
    for (final guide in ret) {
      guide.processEffect(isMe ? myState : yourState, isMe ? yourState : myState, state);
    }
    // ユーザ手動入力による修正
    userForces.processEffect(state.getPokemonState(PlayerType.me, null), state.getPokemonState(PlayerType.opponent, null), state, ownParty, opponentParty);

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
          pokeState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.unburden);
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
        state.incFaintingCount(PlayerType.me, 1);
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
        state.incFaintingCount(PlayerType.opponent, 1);
      }
    }
    else {
      opponentPokemonState.isFainting = false;
    }

    // 勝利判定
    isMyWin = state.isMyWin;
    isYourWin = state.isYourWin;
    // わざの反動等で両者同時に倒れる場合あり→このTurnEffectの発動主が勝利とする
    if (isMyWin && isYourWin) {
      if (playerType == PlayerType.me) {
        isYourWin = false;
      }
      else {
        isMyWin = false;
      }
    }

    return ret;
  }

  // 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
  static List<TurnEffect> getPossibleEffects(
    Timing timing, PlayerType playerType,
    EffectType effectType, Pokemon? pokemon, PokemonState? pokemonState, PhaseState phaseState,
    PlayerType attacker, TurnMove turnMove, Turn currentTurn, TurnEffect? prevAction)
  {
    final pokeData = PokeDB();
    List<TurnEffect> ret = [];
    List<int> retAbilityIDs = [];
    List<Timing> timings = [...allTimings];
    List<Timing> attackerTimings = [...allTimings];
    List<Timing> defenderTimings = [...allTimings];
    List<int> indiFieldEffectIDs = [];
    Map<int, int> ailmentEffectIDs = {};    // 効果IDと経過ターン数を入れる
    List<int> weatherEffectIDs = [];
    List<int> fieldEffectIDs = [];

    // 全タイミング共通
    if (phaseState.weather.id == Weather.sunny) { // 天気が晴れのとき
      timings.add(Timing.sunnyAbnormaled);
      attackerTimings.add(Timing.sunnyAbnormaled);
      defenderTimings.add(Timing.sunnyAbnormaled);
    }

    switch (timing) {
      case Timing.pokemonAppear:   // ポケモンを繰り出すとき
        {
          timings.addAll(pokemonAppearTimings);
          attackerTimings.clear();
          defenderTimings.clear();
          if (phaseState.weather.id != Weather.rainy) timings.add(Timing.pokemonAppearNotRained);      // ポケモン登場時(天気が雨でない)
          if (phaseState.weather.id != Weather.sandStorm) timings.add(Timing.pokemonAppearNotSandStormed);  // ポケモン登場時(天気がすなあらしでない)
          if (phaseState.weather.id != Weather.sunny) timings.add(Timing.pokemonAppearNotSunny);      // ポケモン登場時(天気が晴れでない)
          if (phaseState.weather.id != Weather.snowy) timings.add(Timing.pokemonAppearNotSnowed);      // ポケモン登場時(天気がゆきでない)
          if (phaseState.field.id != Field.electricTerrain) timings.add(Timing.pokemonAppearNotEreciField);  // ポケモン登場時(エレキフィールドでない)
          if (phaseState.field.id != Field.psychicTerrain) timings.add(Timing.pokemonAppearNotPsycoField);  // ポケモン登場時(サイコフィールドでない)
          if (phaseState.field.id != Field.mistyTerrain) timings.add(Timing.pokemonAppearNotMistField);    // ポケモン登場時(ミストフィールドでない)
          if (phaseState.field.id != Field.grassyTerrain) timings.add(Timing.pokemonAppearNotGrassField);   // ポケモン登場時(グラスフィールドでない)
          var myFields = phaseState.getIndiFields(playerType);
          for (final f in myFields) {
            if (f.possiblyActive(timing)) {
              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(f));
            }
          }
        }
        break;
      case Timing.everyTurnEnd:           // 毎ターン終了時
        {
          timings.addAll(everyTurnEndTimings);
          attackerTimings.clear();
          defenderTimings.clear();
          if (currentTurn.getInitialPokemonIndex(playerType) == phaseState.getPokemonIndex(playerType, null)) {
            timings.add(Timing.afterActedEveryTurnEnd);     // 1度でも行動した後毎ターン終了時
          }
          if (phaseState.getPokemonState(PlayerType.me, null).holdingItem == null &&
              phaseState.getPokemonState(PlayerType.opponent, null).holdingItem == null
          ) {
            timings.add(Timing.everyTurnEndOpponentItemConsumeed);     // 相手が道具を消費したターン終了時
          }
          // 天気
          switch (phaseState.weather.id) {
            case Weather.sunny:   // 天気が晴れのとき、毎ターン終了時
              timings.addAll([Timing.fireWaterAttackedSunnyRained, Timing.everyTurnEndSunny]);
              weatherEffectIDs.add(WeatherEffect.sunnyEnd);
              break;
            case Weather.rainy:   // 天気があめのとき、毎ターン終了時
              timings.addAll([Timing.everyTurnEndRained, Timing.fireWaterAttackedSunnyRained, Timing.everyTurnEndRainedWithAbnormal]);
              weatherEffectIDs.add(WeatherEffect.rainyEnd);
              break;
            case Weather.snowy:   // 天気がゆきのとき、毎ターン終了時
              timings.addAll([Timing.everyTurnEndSnowy]);
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
            timings.add(Timing.everyTurnEndNotTerastaled);
          }
          if (pokemonState != null) {
            for (final ailment in pokemonState.ailmentsIterable) {
              if (ailment.possiblyActive(timing, pokemonState, phaseState)) {
                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] = ailment.turns;
              }
            }
          }
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {    // どく/もうどく状態のとき
            timings.add(Timing.poisonDamage);
          }
/*
          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.ingrain).isNotEmpty) {    // ねをはる状態のとき
            ailmentEffectIDs.add(AilmentEffect.ingrain);
          }
*/
          if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
            if (pokemonState!.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) {
              timings.add(Timing.everyTurnEndNotAbnormal);     // 状態異常でない毎ターン終了時
            }
          }
          // 各々の場
          var myFields = phaseState.getIndiFields(playerType);
          for (final field in myFields) {
            if (field.possiblyActive(timing)) {
              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(field));
            }
          }
        }
        break;
      case Timing.afterActionDecision:    // 行動決定直後
        {
          timings.addAll(afterActionDecisionTimings);
          attackerTimings.clear();
          defenderTimings.clear();
        }
        break;
      case Timing.beforeMove:    // わざ使用前
        {
          timings.clear();
          attackerTimings.clear();
          defenderTimings.clear();
          attackerTimings.addAll(beforeMoveAttackerTimings);
          defenderTimings.addAll(beforeMoveDefenderTimings);
          if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
            var attackerState = phaseState.getPokemonState(attacker, prevAction);
            var defenderState = phaseState.getPokemonState(attacker.opposite, prevAction);
            var replacedMoveType = turnMove.getReplacedMoveType(turnMove.move, 0, attackerState, phaseState);
            if (replacedMoveType.id == 1) {  // ノーマルタイプのわざを受けた時
              defenderTimings.addAll([Timing.normalAttacked]);
            }
            if (PokeType.effectiveness(
                attackerState.currentAbility.id == 113 || attackerState.currentAbility.id == 299, defenderState.holdingItem?.id == 586,
                defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                replacedMoveType, pokemonState!
              ).id == MoveEffectiveness.great
            ) {
              defenderTimings.add(Timing.greatAttacked);  // 効果ばつぐんのタイプのこうげきざわを受けた時
              if (replacedMoveType.id == PokeTypeId.fire) defenderTimings.add(Timing.greatFireAttacked);
              if (replacedMoveType.id == PokeTypeId.water) defenderTimings.add(Timing.greatWaterAttacked);
              if (replacedMoveType.id == PokeTypeId.electric) defenderTimings.add(Timing.greatElectricAttacked);
              if (replacedMoveType.id == PokeTypeId.grass) defenderTimings.add(Timing.greatgrassAttacked);
              if (replacedMoveType.id == PokeTypeId.ice) defenderTimings.add(Timing.greatIceAttacked);
              if (replacedMoveType.id == PokeTypeId.fight) defenderTimings.add(Timing.greatFightAttacked);
              if (replacedMoveType.id == PokeTypeId.poison) defenderTimings.add(Timing.greatPoisonAttacked);
              if (replacedMoveType.id == PokeTypeId.ground) defenderTimings.add(Timing.greatGroundAttacked);
              if (replacedMoveType.id == PokeTypeId.fly) defenderTimings.add(Timing.greatFlyAttacked);
              if (replacedMoveType.id == PokeTypeId.psychic) defenderTimings.add(Timing.greatPsycoAttacked);
              if (replacedMoveType.id == PokeTypeId.bug) defenderTimings.add(Timing.greatBugAttacked);
              if (replacedMoveType.id == PokeTypeId.rock) defenderTimings.add(Timing.greatRockAttacked);
              if (replacedMoveType.id == PokeTypeId.ghost) defenderTimings.add(Timing.greatGhostAttacked);
              if (replacedMoveType.id == PokeTypeId.dragon) defenderTimings.add(Timing.greatDragonAttacked);
              if (replacedMoveType.id == PokeTypeId.evil) defenderTimings.add(Timing.greatEvilAttacked);
              if (replacedMoveType.id == PokeTypeId.steel) defenderTimings.add(Timing.greatSteelAttacked);
              if (replacedMoveType.id == PokeTypeId.fairy) defenderTimings.add(Timing.greatFairyAttacked);
            }
            // 状態変化
            for (final ailment in attackerState.ailmentsIterable) {
              if (ailment.possiblyActive(timing, attackerState, phaseState)) {
                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] = ailment.turns;
              }
            }
          }
        }
        break;
      case Timing.afterMove:     // わざ使用後
        if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
          timings.clear();    // atacker/defenderに統合するするため削除
          attackerTimings.addAll(afterMoveAttackerTimings);
          defenderTimings.addAll(afterMoveDefenderTimings);
          var attackerState = phaseState.getPokemonState(attacker, prevAction);
          var defenderState = phaseState.getPokemonState(attacker.opposite, prevAction);
          var replacedMove = turnMove.getReplacedMove(turnMove.move, 0, attackerState);
          var replacedMoveType = turnMove.getReplacedMoveType(turnMove.move, 0, attackerState, phaseState);
          if (replacedMove.priority >= 1) defenderTimings.addAll([Timing.priorityMoved]);   // 優先度1以上のわざを受けた時
          // へんかわざを受けた時
          if (replacedMove.damageClass.id == 1) defenderTimings.addAll([Timing.statused]);
          // こうげきしたとき/うけたとき
          if (replacedMove.damageClass.id >= 2) {
            defenderTimings.addAll([Timing.attackedHitted, Timing.attackedHittedWithChance, Timing.attackedHittedWithBake, Timing.pokemonAppearAttacked]);
            attackerTimings.addAll([Timing.attackHitted, Timing.defeatOpponentWithAttack]);
            // うのみ状態/まるのみ状態で相手にこうげきされた後
            int findIdx = defenderState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.unomiForm || e.id == BuffDebuff.marunomiForm);
            if (findIdx >= 0) {
              ret.add(TurnEffect()
                ..playerType = attacker.opposite
                ..timing = Timing.afterMove
                ..effectType = EffectType.ability
                ..effectId = 10000 + defenderState.buffDebuffs[findIdx].id
              );
            }
            // ノーマルタイプのこうげきをした時
            if (replacedMoveType.id == 1) attackerTimings.addAll([Timing.normalAttackHit]);
            // あくタイプのこうげきを受けた時
            if (replacedMoveType.id == 17) defenderTimings.addAll([Timing.evilAttacked]);
            // みずタイプのこうげきを受けた時
            if (replacedMoveType.id == 11) defenderTimings.addAll([Timing.waterAttacked, Timing.fireWaterAttacked]);
            // ほのおタイプのこうげきを受けた時
            if (replacedMoveType.id == 10) defenderTimings.addAll([Timing.fireWaterAttacked, Timing.fireAtaccked]);
            // でんきタイプのこうげきを受けた時
            if (replacedMoveType.id == 13) defenderTimings.addAll([Timing.electricAttacked]);
            // こおりタイプのこうげきを受けた時
            if (replacedMoveType.id == 15) defenderTimings.addAll([Timing.iceAttacked]);
            // こうげきによりひんしになっているとき
            if (defenderState.isFainting) defenderTimings.add(Timing.attackedFainting);
          }
          if (replacedMove.isPowder) defenderTimings.addAll([Timing.powdered]);   // こな系のこうげきを受けた時
          if (replacedMove.isBullet) defenderTimings.addAll([Timing.bulleted]);   // 弾のこうげきを受けた時
          if (replacedMove.damageClass.id == DamageClass.physical) defenderTimings.addAll([Timing.phisycalAttackedHitted]);   // ぶつりこうげきを受けた時
          if (replacedMove.damageClass.id == DamageClass.special) defenderTimings.addAll([Timing.specialAttackedHitted]);   // とくしゅこうげきを受けた時
          if (replacedMove.isDirect && !(replacedMove.isPunch && attackerState.holdingItem?.id == 1700) &&  // パンチグローブをつけたパンチわざでない
              attackerState.currentAbility.id != 203
          ) {
            defenderTimings.add(Timing.directAttackedWithChance);  // 直接攻撃を受けた時(確率)
            defenderTimings.add(Timing.directAttacked);  // 直接攻撃を受けた時
            attackerTimings.add(Timing.directAttackHitWithChance);  // 直接攻撃をあてたとき(確率)
            // 違う性別の相手から直接攻撃を受けた時（確率）
            if (attackerState.sex != defenderState.sex && attackerState.sex != Sex.none) defenderTimings.add(Timing.directAttackedByOppositeSexWithChance);
            // 直接攻撃によりひんしになっているとき
            if (defenderState.isFainting) defenderTimings.add(Timing.directAttackedFainting);
            // まもる系統のわざ相手に直接攻撃したとき
            var findIdx = defenderState.ailmentsIndexWhere((e) => e.id == Ailment.protect && e.extraArg1 != 0);
            if (findIdx >= 0 && attacker == playerType) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effectType = EffectType.afterMove
                ..effectId = defenderState.ailments(findIdx).extraArg1
              );
            }
            // みちづれ状態の相手にこうげきしてひんしにしたとき
            if (defenderState.isFainting && defenderState.ailmentsWhere((e) => e.id == Ailment.destinyBond).isNotEmpty) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effectType = EffectType.afterMove
                ..effectId = 194
              );
            }
          }
          if (replacedMove.isSound) {
            attackerTimings.add(Timing.soundAttack);  // 音技を使ったとき
            defenderTimings.add(Timing.soundAttacked);  // 音技を受けた時
          }
          if (replacedMove.isDrain) defenderTimings.add(Timing.drained);  // HP吸収わざを受けた時
          if (replacedMove.isDance) defenderTimings.add(Timing.otherDance);  // おどり技を受けた時
          if (replacedMoveType.id == PokeTypeId.normal) {  // ノーマルタイプのわざを受けた時
            defenderTimings.addAll([Timing.normalAttacked]);
          }
          if (replacedMoveType.id == PokeTypeId.electric) {  // でんきタイプのわざを受けた時
            defenderTimings.addAll([Timing.electriced, Timing.electricUse]);
          }
          if (replacedMoveType.id == PokeTypeId.water) {  // みずタイプのわざを受けた時
            defenderTimings.addAll([Timing.watered, Timing.fireWaterAttackedSunnyRained, Timing.waterUse]);
          }
          if (replacedMoveType.id == PokeTypeId.fire) {  // ほのおタイプのわざを受けた時
            defenderTimings.addAll([Timing.fired, Timing.fireWaterAttackedSunnyRained]);
          }
          if (replacedMoveType.id == PokeTypeId.grass) {  // くさタイプのわざを受けた時
            defenderTimings.addAll([Timing.grassed]);
          }
          if (replacedMoveType.id == PokeTypeId.ground) {   // じめんタイプのわざを受けた時
            defenderTimings.addAll([Timing.grounded]);
          }
          if (PokeType.effectiveness(
              attackerState.currentAbility.id == 113 || attackerState.currentAbility.id == 299, defenderState.holdingItem?.id == 586,
              defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              replacedMoveType, pokemonState!
            ).id == MoveEffectiveness.great
          ) {
            defenderTimings.add(Timing.greatAttacked);  // 効果ばつぐんのタイプのこうげきざわを受けた時
            if (replacedMoveType.id == PokeTypeId.fire) defenderTimings.add(Timing.greatFireAttacked);
            if (replacedMoveType.id == PokeTypeId.water) defenderTimings.add(Timing.greatWaterAttacked);
            if (replacedMoveType.id == PokeTypeId.electric) defenderTimings.add(Timing.greatElectricAttacked);
            if (replacedMoveType.id == PokeTypeId.grass) defenderTimings.add(Timing.greatgrassAttacked);
            if (replacedMoveType.id == PokeTypeId.ice) defenderTimings.add(Timing.greatIceAttacked);
            if (replacedMoveType.id == PokeTypeId.fight) defenderTimings.add(Timing.greatFightAttacked);
            if (replacedMoveType.id == PokeTypeId.poison) defenderTimings.add(Timing.greatPoisonAttacked);
            if (replacedMoveType.id == PokeTypeId.ground) defenderTimings.add(Timing.greatGroundAttacked);
            if (replacedMoveType.id == PokeTypeId.fly) defenderTimings.add(Timing.greatFlyAttacked);
            if (replacedMoveType.id == PokeTypeId.psychic) defenderTimings.add(Timing.greatPsycoAttacked);
            if (replacedMoveType.id == PokeTypeId.bug) defenderTimings.add(Timing.greatBugAttacked);
            if (replacedMoveType.id == PokeTypeId.rock) defenderTimings.add(Timing.greatRockAttacked);
            if (replacedMoveType.id == PokeTypeId.ghost) defenderTimings.add(Timing.greatGhostAttacked);
            if (replacedMoveType.id == PokeTypeId.dragon) defenderTimings.add(Timing.greatDragonAttacked);
            if (replacedMoveType.id == PokeTypeId.evil) defenderTimings.add(Timing.greatEvilAttacked);
            if (replacedMoveType.id == PokeTypeId.steel) defenderTimings.add(Timing.greatSteelAttacked);
            if (replacedMoveType.id == PokeTypeId.fairy) defenderTimings.add(Timing.greatFairyAttacked);
          }
          else {
            defenderTimings.add(Timing.notGreatAttacked);  // 効果ばつぐん以外のタイプのこうげきざわを受けた時
          }
          if (replacedMoveType.id == 5) {
            if (replacedMove.id != 28 && replacedMove.id != 614) {  // すなかけ/サウザンアローではない
              defenderTimings.add(Timing.groundFieldEffected);  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
            }
          }
          // とくせいがおどりこの場合
          if (phaseState.getPokemonState(PlayerType.me, prevAction).currentAbility.id == 216 ||
              phaseState.getPokemonState(PlayerType.opponent, prevAction).currentAbility.id == 216
          ) {
            attackerTimings.addAll(defenderTimings);
            attackerTimings = attackerTimings.toSet().toList();
            defenderTimings = attackerTimings;
          }
        }
        break;
      case Timing.afterTerastal:   // テラスタル後
        {
          timings.clear();
          attackerTimings.clear();
          defenderTimings.clear();
          if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
            bool isMe = playerType == PlayerType.me;
            bool isTerastal = pokemonState!.isTerastaling && (isMe ? !currentTurn.initialOwnHasTerastal : !currentTurn.initialOpponentHasTerastal);

            if (isTerastal && pokemonState.currentAbility.id == 303) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effectType = EffectType.ability
                ..effectId = 303
              );
            }
          }
        }
        break;
      default:
        return [];
    }

    if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
      if (effectType == EffectType.ability) {
        if (pokemonState!.currentAbility.id != 0) {   // とくせいが確定している場合
          if (timings.contains(pokemonState.currentAbility.timing)) {
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
          // わざ使用後に発動する効果
          if (attacker == playerType && attackerTimings.contains(pokemonState.currentAbility.timing) ||
              attacker != playerType && defenderTimings.contains(pokemonState.currentAbility.timing)
          ) {
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
        }
        else {      // とくせいが確定していない場合
          for (final ability in pokemonState.possibleAbilities) {
            if (timings.contains(ability.timing)) {
              retAbilityIDs.add(ability.id);
            }
            // わざ使用後に発動する効果
            if (attacker == playerType && attackerTimings.contains(ability.timing) ||
                attacker != playerType && defenderTimings.contains(ability.timing)
            ) {
              retAbilityIDs.add(ability.id);
            }
          }
        }
        if (playerType == PlayerType.opponent && phaseState.canAnyZoroark) {
          retAbilityIDs.add(149);   // イリュージョン追加
        }
        final abilityIDs = retAbilityIDs.toSet();
        for (final abilityID in abilityIDs) {
          ret.add(TurnEffect()
            ..playerType = playerType
            ..effectType = EffectType.ability
            ..effectId = abilityID
          );
        }
      }
      if (effectType == EffectType.individualField) {
        for (var e in indiFieldEffectIDs) {
          var adding = TurnEffect()
            ..playerType = playerType
            ..effectType = EffectType.individualField
            ..effectId = e;
          if (adding.effectId == IndiFieldEffect.trickRoomEnd) {    // 各々の場だが効果としては両フィールドのもの
            adding.playerType = PlayerType.entireField;
            if (ret.where((element) => element.nearEqual(adding)).isNotEmpty) {
              ret.add(adding);
            }
          }
          else {
            ret.add(adding);
          }
        }
      }
      if (effectType == EffectType.ailment) {
        for (var e in ailmentEffectIDs.entries) {
          ret.add(TurnEffect()
            ..playerType = playerType
            ..effectType = EffectType.ailment
            ..effectId = e.key
            ..extraArg1 = e.value
          );
        }
      }
      if (effectType == EffectType.item) {
        if (pokemonState!.holdingItem != null) {
          if (pokemonState.holdingItem!.id != 0) {   // もちものが確定している場合
            if (timings.contains(pokemonState.holdingItem!.timing)) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effectType = EffectType.item
                ..effectId = pokemonState.holdingItem!.id
              );
            }
            // わざ使用後に発動する効果
            if (attacker == playerType && attackerTimings.contains(pokemonState.holdingItem!.timing) ||
                attacker != playerType && defenderTimings.contains(pokemonState.holdingItem!.timing)
            ) {
              ret.add(TurnEffect()
                ..playerType = playerType
                ..effectType = EffectType.item
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
              if (timings.contains(item.timing)) {
                ret.add(TurnEffect()
                  ..playerType = playerType
                  ..effectType = EffectType.item
                  ..effectId = item.id
                );
              }
              // わざ使用後に発動する効果
              if (attacker == playerType && attackerTimings.contains(item.timing) ||
                  attacker != playerType && defenderTimings.contains(item.timing)
              ) {
                ret.add(TurnEffect()
                  ..playerType = playerType
                  ..effectType = EffectType.item
                  ..effectId = item.id
                );
              }
            }
          }
        }
      }
    }

    if (playerType == PlayerType.entireField) {
      for (var e in weatherEffectIDs) {
        ret.add(TurnEffect()
          ..playerType = PlayerType.entireField
          ..effectType = EffectType.weather
          ..effectId = e
        );
      }
      for (var e in fieldEffectIDs) {
        ret.add(TurnEffect()
          ..playerType = PlayerType.entireField
          ..effectType = EffectType.field
          ..effectId = e
        );
      }
    }

    // argの自動セット
    var myState = playerType != PlayerType.opponent ?
      phaseState.getPokemonState(PlayerType.me, prevAction) : phaseState.getPokemonState(PlayerType.opponent, prevAction);
    var yourState = playerType != PlayerType.opponent ?
      phaseState.getPokemonState(PlayerType.opponent, prevAction) : phaseState.getPokemonState(PlayerType.me, prevAction);
    for (var effect in ret) {
      effect.timing = timing;
      effect.setAutoArgs(myState, yourState, phaseState, prevAction);
    }

    return ret;
  }

  String get displayName {
    final pokeData = PokeDB();
    switch (effectType) {
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
    switch (effectType) {
      case EffectType.ability:
        extraArg1 = Ability.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = Ability.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.item:
        extraArg1 = Item.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = Item.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.ailment:
        // extraArg1にはあらかじめ経過ターン数を代入しておく。
        extraArg1 = Ailment.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing, extraArg1);
        extraArg2 = Ailment.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      case EffectType.individualField:
        extraArg1 = IndividualField.getAutoArg1(effectId, playerType, myState, yourState, state, prevAction, timing);
        extraArg2 = IndividualField.getAutoArg2(effectId, playerType, myState, yourState, state, prevAction, timing);
        break;
      default:
        break;
    }
  }

  String getEditingControllerText1() {
    switch (timing) {
      case Timing.action:
      case Timing.continuousMove:
        return move == null ? '' : move!.move.displayName;
      case Timing.afterActionDecision:
      case Timing.afterMove:
      case Timing.pokemonAppear:
      case Timing.everyTurnEnd:
      case Timing.afterTerastal:
        return displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText2(PhaseState state, TurnEffect? prevAction) {
    final pokeData = PokeDB();
    var myState = state.getPokemonState(playerType, timing == Timing.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(playerType.opposite, timing == Timing.afterMove ? prevAction : null);
    switch (timing) {
      case Timing.action:
      case Timing.continuousMove:
        {
          if (move == null) return '';
          if (move!.playerType == PlayerType.me) {
            return yourState.remainHPPercent.toString();
          }
          else if (move!.playerType == PlayerType.opponent) {
            return yourState.remainHP.toString();
          }
          return '';
        }
      default:
        {
          switch (effectType) {
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
                  if (playerType == PlayerType.me) {
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
                  if (playerType == PlayerType.me) {
                    return yourState.remainHPPercent.toString();
                  }
                  else {
                    return yourState.remainHP.toString();
                  }
                case 36:    // トレース
                  if (playerType == PlayerType.me) {
                    if (yourState.getCurrentAbility().id != 0) {
                      extraArg1 = yourState.getCurrentAbility().id;
                      return yourState.getCurrentAbility().displayName;
                    }
                    else {
                      return '';
                    }
                  }
                  else {
                    extraArg1 = myState.getCurrentAbility().id;
                    return myState.getCurrentAbility().displayName;
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
                case AilmentEffect.partiallyTrapped:  // バインド
                case AilmentEffect.ingrain:     // ねをはる
                  if (playerType == PlayerType.me) {
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
                case IndiFieldEffect.spikes1:
                case IndiFieldEffect.spikes2:
                case IndiFieldEffect.spikes3:
                case IndiFieldEffect.futureAttack:
                case IndiFieldEffect.wish:
                  if (playerType == PlayerType.me) {
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
                  return state.getPokemonState(PlayerType.me, null).remainHP.toString();
              }
              break;
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal:   // グラスフィールドによる回復
                  return state.getPokemonState(PlayerType.me, null).remainHP.toString();
              }
              break;
            default:
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
    var myState = state.getPokemonState(playerType, timing == Timing.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(playerType.opposite, timing == Timing.afterMove ? prevAction : null);
    var pokeData = PokeDB();

    // わざが選択されたときのみ、extraArgを引いたHPの値をセット
    if (isOnMoveSelected) {
      switch (timing) {
        case Timing.action:
        case Timing.continuousMove:
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
                if (move!.playerType == PlayerType.me) {
                  return (myState.remainHP - move!.extraArg1[0]).toString();
                }
                else if (move!.playerType == PlayerType.opponent) {
                  return (myState.remainHPPercent - move!.extraArg2[0]).toString();
                }
                break;
              case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
                if (myState.isTypeContain(8)) {
                  if (move!.playerType == PlayerType.me) {
                    return (myState.remainHP - move!.extraArg1[0]).toString();
                  }
                  else if (move!.playerType == PlayerType.opponent) {
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

    switch (timing) {
      case Timing.action:
      case Timing.continuousMove:
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
            case 456:   // 対象にもちものがあるときのみ成功
            case 457:   // 対象のもちものを消失させる
              return pokeData.items[move!.extraArg1[0]]!.displayName;
            default:
              if (move!.playerType == PlayerType.me) {
                return myState.remainHP.toString();
              }
              else if (move!.playerType == PlayerType.opponent) {
                return myState.remainHPPercent.toString();
              }
              return '';
          }
        }
      default:
        {
          switch (effectType) {
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
                        if (playerType == PlayerType.me) {
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
                        if (playerType == PlayerType.me) {
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
                  if (playerType == PlayerType.me) {
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
                  return state.getPokemonState(PlayerType.opponent, null).remainHPPercent.toString();
              }
              break;
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal:   // グラスフィールドによる回復
                  return state.getPokemonState(PlayerType.opponent, null).remainHPPercent.toString();
              }
              break;
            default:
              break;
          }
        }
    }
    return '';
  }

  String getEditingControllerText4(PhaseState state) {
    switch (timing) {
      case Timing.action:
      case Timing.continuousMove:
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
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  )
  {
    var myPokemon = prevAction != null && timing == Timing.afterMove ?
      state.getPokemonState(playerType, prevAction).pokemon :
      playerType == PlayerType.me ? ownPokemon : opponentPokemon;
    var yourPokemon = prevAction != null && timing == Timing.afterMove ?
      state.getPokemonState(playerType.opposite, prevAction).pokemon :
      playerType == PlayerType.me ? opponentPokemon : ownPokemon;
    var myState = prevAction != null && timing == Timing.afterMove ?
      state.getPokemonState(playerType, prevAction) :
      playerType == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = prevAction != null && timing == Timing.afterMove ?
      state.getPokemonState(playerType.opposite, prevAction) :
      playerType == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var myParty = playerType == PlayerType.me ? ownParty : opponentParty;
    var yourParty = playerType == PlayerType.me ? opponentParty : ownParty;

    if (effectType == EffectType.ability) {   // とくせいによる効果
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
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
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
            loc: loc,
          );
        case 16:      // へんしょく
        case 168:     // へんげんじざい
        case 236:     // リベロ
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myTypeDropdownButton(
                  loc.battleTypeToChange,
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
            playerType != PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
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
            loc: loc,
          );
        case 27:    // ほうし
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    label: Text(loc.battleOpponentAilments),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: Ailment.poison,
                      child: Text(Ailment(Ailment.poison).displayName),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text(Ailment(Ailment.paralysis).displayName),
                    ),
                    DropdownMenuItem(
                      value: Ailment.sleep,
                      child: Text(Ailment(Ailment.sleep).displayName),
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
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleAbilityTraced,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType == PlayerType.me) {
                      if (yourState.getCurrentAbility().id != 0) {
                        matches.add(yourState.getCurrentAbility());
                      }
                      else {
                        matches.addAll(yourState.possibleAbilities);
                      }
                      if (state.canAnyZoroark) matches.add(PokeDB().abilities[149]!);
                    }
                    else {
                      matches.add(yourState.getCurrentAbility());
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
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
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
                      child: Text(loc.commonAttack),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(loc.commonSAttack),
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
                  textValue: extraArg1 == 0 ? loc.commonAttack : loc.commonSAttack,
                ),
              ),
              Text(loc.battleRankUp1),
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
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType == PlayerType.me) {
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
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.me) {
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
                        for (final statIndex in StatIndexList.listAtoS)
                        DropdownMenuItem(
                          value: statIndex.index-1,
                          child: Text(statIndex.name),
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
                      textValue: StatIndexNumber.getStatIndexFromIndex(extraArg1+1).name,
                    ),
                  ),
                  Text(loc.battleRankUp2),
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
                        for (final statIndex in StatIndexList.listAtoS)
                        DropdownMenuItem(
                          value: statIndex.index-1,
                          child: Text(statIndex.name),
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
                      textValue: StatIndexNumber.getStatIndexFromIndex(extraArg2+1).name,
                    ),
                  ),
                  Text(loc.battleRankDown1),
                ],
              ),
            ],
          );
        case 149:     // イリュージョン
          if (playerType == PlayerType.opponent) {
            return Row(
              children: [
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleIllusionedPokemon,
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
                    value: extraArg1 <= 0 ? null : extraArg1,
                    onChanged: (value) {
                      extraArg1 = value;
                      appState.editingPhase[phaseIdx] = true;
                      appState.needAdjustPhases = phaseIdx+1;
                      onFocus();
                    },
                    onFocus: onFocus,
                    isInput: isInput,
                    textValue: extraArg1 > 0 ? opponentParty.pokemons[extraArg1-1]?.name : '',
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
                      child: Text(loc.battleEffectExpired),
                    ),
                    for (final statIndex in StatIndexList.listAtoS)
                    DropdownMenuItem(
                      value: statIndex.index-1,
                      child: Text(statIndex.name),
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
                  textValue: extraArg1 == -1 ? loc.battleEffectExpired : StatIndexNumber.getStatIndexFromIndex(extraArg1+1).name,
                ),
              ),
              extraArg1 >= 0 ? Text(loc.battleStatIncrease) : Text(''),
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
                    for (final statIndex in StatIndexList.listAtoS)
                    DropdownMenuItem(
                      value: statIndex.index-1,
                      child: Text(statIndex.name),
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
                  textValue: StatIndexNumber.getStatIndexFromIndex(extraArg1+1).name,
                ),
              ),
              Text(loc.battleOpportunist1),
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
              Text(loc.battleOpportunist2),
            ],
          );
        case 216:   // おどりこ
          return Column(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
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
                playerType != PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
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
                loc: loc,
              ) :
              extraArg1 == 775 ?
              DamageIndicateRow(
                myPokemon, controller,
                playerType == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
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
                loc: loc,
              ) :
              Container(),
              extraArg1 == 552 || extraArg1 == 10552 ? SizedBox(height: 10,) : Container(),
              extraArg1 == 552 || extraArg1 == 10552 ?
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleAdditionalEffect,
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 552,
                      child: Text(loc.commonNone),
                    ),
                    DropdownMenuItem(
                      value: 10552,
                      child: Text(loc.battleSAttackUp1(myState.pokemon.omittedName)),
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
                  textValue: extraArg1 == 552 ? loc.commonNone : loc.battleSAttackUp1(myState.pokemon.omittedName),
                ),
              ) : Container(),
            ],
          );
        default:
          break;
      }
    }
    else if (effectType == EffectType.item) {   // もちものによる効果
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
        loc: loc,
      );
    }
    else if (effectType == EffectType.individualField) {   // 各ポケモンの場による効果
      switch (effectId) {
        case IndiFieldEffect.spikes1:           // まきびし
        case IndiFieldEffect.spikes2:
        case IndiFieldEffect.spikes3:
        case IndiFieldEffect.futureAttack:      // みらいにこうげき
        case IndiFieldEffect.stealthRock:       // ステルスロック
        case IndiFieldEffect.wish:              // ねがいごと
          return DamageIndicateRow(
            myPokemon, controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
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
            loc: loc,
          );
      }
    }
    else if (effectType == EffectType.ailment) {   // 状態変化による効果
      switch (effectId) {
        case AilmentEffect.poison:    // どく
        case AilmentEffect.badPoison: // もうどく
        case AilmentEffect.burn:      // やけど
        case AilmentEffect.saltCure:  // しおづけ
        case AilmentEffect.curse:     // のろい
        case AilmentEffect.ingrain:   // ねをはる
          return DamageIndicateRow(
            myPokemon, controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
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
            loc: loc,
          );
        case AilmentEffect.leechSeed:   // やどりぎのタネ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                myPokemon, controller,
                playerType == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
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
                loc: loc,
              ),
              SizedBox(height: 10,),
              DamageIndicateRow(
                yourPokemon, controller2,
                playerType != PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
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
                loc: loc,
              ),
            ],
          );
        case AilmentEffect.partiallyTrapped:    // バインド
          return Column(
            children: [
              _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battleEffect,
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: 0,
                    child: Text(loc.battleDamaged),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(loc.battleEffectExpired),
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
                textValue: extraArg2 == 1 ? loc.battleEffectExpired : loc.battleDamaged,
              ),
              SizedBox(height: 10,),
              extraArg2 == 0 ?
              DamageIndicateRow(
                myPokemon, controller,
                playerType == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
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
                loc: loc,
              ) : Container(),
            ],
          );
        case AilmentEffect.candyCandy:    // あめまみれ
          return Row(
            children: [
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleEffect,
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.battleSpeedDown1(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(loc.battleEffectExpired),
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
                  textValue: extraArg2 == 1 ? loc.battleEffectExpired : loc.battleSpeedDown1(myState.pokemon.omittedName),
                ),
              ),
            ],
          );
      }
    }
    else if (effectType == EffectType.weather) {   // 天気による効果
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
                loc: loc,
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
                loc: loc,
              ),
            ],
          );
      }
    }
    else if (effectType == EffectType.field) {   // フィールドによる効果
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
                loc: loc,
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
                loc: loc,
              ),
            ],
          );
      }
    }
    else if (effectType == EffectType.afterMove) {   // わざによる効果
      switch (effectId) {
        case 596:   // ニードルガード
          return DamageIndicateRow(
            myPokemon, controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
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
            loc: loc,
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
      bool isTeraType = false,
    }
  )
  {
    if (isInput) {
      return TypeDropdownButton(
        labelText, onChanged, value,
        isError: isError, isTeraType: isTeraType,
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
  static TurnEffect deserialize(dynamic str, String split1, String split2, String split3, {int version = -1}) {   // -1は最新バージョン
    TurnEffect effect = TurnEffect();
    final effectElements = str.split(split1);
    // playerType
    effect.playerType = PlayerTypeNum.createFromNumber(int.parse(effectElements[0]));
    // timing
    effect.timing = Timing.values[int.parse(effectElements[1])];
    // effectType
    effect.effectType = EffectType.values[int.parse(effectElements[2])];
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
      effect.move = TurnMove.deserialize(effectElements[6], split2, split3, version: version);
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
    // invalidGuideIDs
    var invalidGuideIDs = effectElements[16].split(split2);
    for (final id in invalidGuideIDs) {
      if (id == '') break;
      effect.invalidGuideIDs.add(int.parse(id));
    }

    return effect;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3) {
    String ret = '';
    // playerType
    ret += playerType.number.toString();
    ret += split1;
    // timing
    ret += timing.index.toString();
    ret += split1;
    // effectType
    ret += '${effectType.index}';
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
    ret += split1;
    // invalidGuideIDs
    for (final id in invalidGuideIDs) {
      ret += id.toString();
      ret += split2;
    }

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
  List<Guide> guides = [];
  bool needAssist = false;
  List<TurnEffect> candidateEffect = [];    // 入力される候補となるTurnEffectのリスト

  // candidateEffectを更新する
  // candidateEffectは、各タイミングの最初の要素に入れておくのがbetter？
  void updateEffectCandidates(Turn currentTurn, PhaseState prevState) {
    candidateEffect.clear();
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType.me, null, currentTurn, prevState,)
    );
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType.opponent, null, currentTurn, prevState,)
    );
    candidateEffect.addAll(
      _getEffectCandidates(turnEffect.timing, PlayerType.entireField, null, currentTurn, prevState,)
    );
  }

  List<TurnEffect> _getEffectCandidates(
    Timing timing,
    PlayerType playerType,
    EffectType? effectType,
    Turn turn,
    PhaseState phaseState,
  ) {
    if (playerType == PlayerType.none) return [];
    
    // prevActionを設定
    TurnEffect? prevAction;
    if (timing == Timing.afterMove) {
      for (int i = phaseIdx-1; i >= 0; i--) {
        if (turn.phases[i].timing == Timing.action) {
          prevAction = turn.phases[i];
          break;
        }
        else if (turn.phases[i].timing != timing) {
          break;
        }
      }
    }
    else if (timing == Timing.beforeMove) {
      for (int i = phaseIdx+1; i < turn.phases.length; i++) {
        if (turn.phases[i].timing == Timing.action) {
          prevAction = turn.phases[i];
          break;
        }
        else if (turn.phases[i].timing != timing) {
          break;
        }
      }
    }
    PlayerType attacker = prevAction != null ? prevAction.playerType : PlayerType.none;
    TurnMove turnMove = prevAction?.move != null ? prevAction!.move! : TurnMove();
    
    if (playerType == PlayerType.entireField) {
      return _getEffectCandidatesWithEffectType(timing, playerType, EffectType.ability, attacker, turnMove, turn, prevAction, phaseState);
    }
    if (effectType == null) {
      List<TurnEffect> ret = [];
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType.ability, attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType.item, attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType.individualField, attacker, turnMove, turn, prevAction, phaseState)
      );
      ret.addAll(
        _getEffectCandidatesWithEffectType(timing, playerType, EffectType.ailment, attacker, turnMove, turn, prevAction, phaseState)
      );
      return ret;
    }
    else {
      return _getEffectCandidatesWithEffectType(timing, playerType, effectType, attacker, turnMove, turn, prevAction, phaseState);
    }
  }

  List<TurnEffect> _getEffectCandidatesWithEffectType(
    Timing timing,
    PlayerType playerType,
    EffectType effectType,
    PlayerType attacker,
    TurnMove turnMove,
    Turn turn,
    TurnEffect? prevAction,
    PhaseState phaseState,
  ) {
    return TurnEffect.getPossibleEffects(timing, playerType, effectType,
    playerType == PlayerType.me || playerType == PlayerType.opponent ?
      phaseState.getPokemonState(playerType, prevAction).pokemon : null,
    playerType == PlayerType.me || playerType == PlayerType.opponent ? phaseState.getPokemonState(playerType, prevAction) : null,
    phaseState, attacker, turnMove, turn, prevAction);
  }
}
