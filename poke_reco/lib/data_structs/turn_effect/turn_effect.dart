import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ability.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_after_move.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ailment.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_individual_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_terastal.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_user_edit.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_weather.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
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
  action,
  changeFaintingPokemon,
  terastal,
  afterMove,
  userEdit,
}

extension EffectTypename on EffectType {
  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('とくせい', 'Ability'),
    2: Tuple2('もちもの', 'Item'),
    3: Tuple2('場', 'Individual Field'),
    4: Tuple2('状態変化', 'Status conditions'),
    5: Tuple2('', ''),
    6: Tuple2('', ''),
    7: Tuple2('', ''),
    8: Tuple2('', ''),
    9: Tuple2('', ''),
    10: Tuple2('行動', 'Action'),
    11: Tuple2('', ''),
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
  Timing.blasted, // ばくはつ系のわざ、とくせいが発動したとき
  Timing.paralysised, // まひするわざ、とくせいを受けた時
  Timing.attractedTauntedIntimidated, // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
  Timing.sleeped, // ねむり・ねむけの効果を受けた時
  Timing.poisoned, // どく・もうどくの効果を受けた時
  Timing.confusedIntimidated, // こんらん/いかくの効果を受けた時
  Timing.changeForced, // こうたいわざやレッドカードによるこうたいを強制されたとき
  Timing
      .groundFieldEffected, // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  Timing.poisonedParalysisedBurnedByOppositeMove, // 相手から受けた技でどく/まひ/やけど状態にされたとき
  Timing.statChangedByNotMyself, // 自身以外の効果によって能力変化が起きるとき
  Timing.flinchedIntimidated, // ひるみやいかくを受けた時
  Timing.frozen, // こおり状態になったとき
  Timing.burned, // やけど状態になったとき
  Timing.accuracyDownedAttack, // 命中率が下がるとき、こうげきするとき
  Timing.itemLostByOpponent, // もちものを奪われたり失ったりするとき
  Timing.attackChangedByNotMyself, // 自身以外の効果によってこうげきランクが下がるとき
  Timing.flinched, // ひるんだとき
  Timing.intimidated, // いかくを受けた時
  Timing.guardChangedByNotMyself, // 自身以外の効果によってぼうぎょランクが下がるとき
  Timing.evilGhostBugAttackedIntimidated, // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  Timing.mentalAilments, // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  Timing.firedWaterAttackBurned, // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  Timing.otherFainting, // 場にいるポケモンがひんしになったとき
  Timing.phisycalAttackedHittedSnowed, // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  Timing.fieldChanged, // フィールドが変化したとき
  Timing.abnormaledSleepy, // 状態異常・ねむけになるとき
  Timing.winded, // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  Timing.changeForcedIntimidated, // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  Timing.sunnyBoostEnergy, // 天気が晴れかブーストエナジーを持っているとき
  Timing.elecFieldBoostEnergy, // エレキフィールドかブーストエナジーを持っているとき
  Timing.opponentStatUp, // 相手の能力ランクが上昇したとき
  Timing.hp025, // HPが1/4以下になったとき
  Timing.elecField, // エレキフィールドのとき
  Timing.grassField, // グラスフィールドのとき
  Timing.psycoField, // サイコフィールドのとき
  Timing.mistField, // ミストフィールドのとき
  Timing.statDowned, // 能力ランクが下がったとき
  Timing.trickRoom, // トリックルームのとき
  Timing.hp050, // HPが1/2以下になったとき
  Timing.abnormaledConfused, // 状態異常・こんらんになるとき
  Timing.confused, // こんらんになるとき
  Timing.infatuation, // メロメロになるとき
  Timing.changedIgnoredAbility, // とくせいを変更される、無効化される、無視されるとき
];

// ポケモンを繰り出すとき
// タイミング
const List<Timing> pokemonAppearTimings = [
  Timing.pokemonAppear, // ポケモン登場時
  Timing.pokemonAppearWithChance, // ポケモン登場時(確率/条件)
  Timing
      .pokemonAppearWithChanceEveryTurnEndWithChance, // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.pokemonAppearAttacked, // ポケモン登場時・こうげきを受けたとき
];

// 行動決定直後
// とくせい
const List<int> afterActionDecisionAbilityIDs = [
  259, // クイックドロウ
];
// もちもの
const List<int> afterActionDecisionItemIDs = [
  194, // せんせいのツメ
  187, // イバンのみ
];
// タイミング
const List<Timing> afterActionDecisionTimings = [
  Timing.afterActionDecision, // 行動決定後、行動実行前
  Timing.afterActionDecisionWithChance, // 行動決定後、行動実行前(確率)
  Timing.afterActionDecisionHP025, // HPが1/4以下で行動決定後
];

// わざ使用前
// タイミング
const List<Timing> beforeMoveAttackerTimings = [
  Timing.beforeMoveWithChance, // わざ使用前(確率・条件)
];
const List<Timing> beforeMoveDefenderTimings = [
  Timing.beforeTypeNormalOrGreatAttackedWithFullHP, // HPが満タンで等倍以上のタイプ相性わざを受ける前
];

// わざ使用後
// タイミング
const List<Timing> afterMoveAttackerTimings = [
  Timing.attackSuccessedWithChance, // こうげきし、相手にあたったとき(確率)
  Timing.movingWithChance, // わざを使うとき(確率・条件)
  Timing.movingMovedWithCondition, // わざを使うとき(条件)、特定のわざを使ったとき
  Timing.notHit, // わざが当たらなかったとき
  Timing.runOutPP, // 1つのわざのPPが0になったとき
  Timing.chargeMoving, // ためわざを使うとき
];
const List<Timing> afterMoveDefenderTimings = [
  Timing.hpMaxAndAttacked, // HPが満タンでこうげきを受けた時
  Timing.criticaled, // こうげきが急所に当たった時
];

// 毎ターン終了時
// フィールド
const List<int> everyTurnEndFieldIDs = [
  Field.electricTerrain, // エレキフィールド終了
  Field.grassyTerrain, // グラスフィールド終了
  Field.mistyTerrain, // ミストフィールド終了
  Field.psychicTerrain, // サイコフィールド終了
];
// タイミング
const List<Timing> everyTurnEndTimings = [
  Timing.everyTurnEnd, // 毎ターン終了時
  Timing.everyTurnEndWithChance, // 毎ターン終了時（確率・条件）
  Timing
      .pokemonAppearWithChanceEveryTurnEndWithChance, // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.everyTurnEndHPNotFull, // HPが満タンでない毎ターン終了時
  Timing
      .everyTurnEndHPNotFull2, // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
];

abstract class TurnEffect extends Equatable implements Copyable {
  final EffectType effectType;
//  PlayerType playerType = PlayerType.none;
//  Timing timing = Timing.none;
//  bool isOwnFainting = false; // このフェーズで自身のポケモンがひんしになるかどうか
//  bool isOpponentFainting = false;
//  bool isMyWin = false; // 自身の勝利（両方勝利の場合は引き分け）
//  bool isYourWin = false;
//  bool isAutoSet = false; // trueの場合、プログラムにて自動で追加されたもの

  TurnEffect(this.effectType);

//  int effectId = 0;
//  int extraArg1 = 0;
//  int extraArg2 = 0;
//  TurnMove? move; // タイプがわざの場合は非null
//  bool isAdding = false; // trueの場合、追加待ち状態
//  bool isOwnFainting = false; // このフェーズで自身のポケモンがひんしになるかどうか
//  bool isOpponentFainting = false;
//  bool isMyWin = false; // 自身の勝利（両方勝利の場合は引き分け）
//  bool isYourWin = false;
//  List<int?> _changePokemonIndexes = [
//    null,
//    null
//  ]; // (ポケモン交代という行動ではなく)効果によってポケモンを交代する場合はその交換先インデックス
//  List<int> _prevPokemonIndexes = [
//    0,
//    0
//  ]; // (ポケモン交代という行動ではなく)効果によってポケモンを交代する場合はその交換前インデックス
//
//  List<int> invalidGuideIDs = [];

//  @override
//  List<Object?> get props => [
//        playerType,
//        timing,
//        effectType,
//        isOwnFainting,
//        isOpponentFainting,
//        isMyWin,
//        isYourWin,
//        isAutoSet,
//      ];

//  @override
//  TurnEffect copy() => TurnEffect()
//    ..playerType = playerType
//    ..timing = timing
//    ..effectType = effectType
//    ..isOwnFainting = isOwnFainting
//    ..isOpponentFainting = isOpponentFainting
//    ..isMyWin = isMyWin
//    ..isYourWin = isYourWin
//    ..isAutoSet = isAutoSet;

  bool isValid();

  // 効果やわざの結果から、各ポケモン等の状態を更新する
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownState,
    Party opponentParty,
    PokemonState opponentState,
    PhaseState state,
    TurnEffect? prevAction,
    int continuousCount, {
    required AppLocalizations loc,
  });

  // 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
//  static List<TurnEffect> getPossibleEffects(
//      Timing timing,
//      PlayerType playerType,
//      EffectType effectType,
//      Pokemon? pokemon,
//      PokemonState? pokemonState,
//      PhaseState phaseState,
//      PlayerType attacker,
//      TurnMove turnMove,
//      Turn currentTurn,
//      TurnEffect? prevAction) {
//    final pokeData = PokeDB();
//    List<TurnEffect> ret = [];
//    List<int> retAbilityIDs = [];
//    List<Timing> timings = [...allTimings];
//    List<Timing> attackerTimings = [...allTimings];
//    List<Timing> defenderTimings = [...allTimings];
//    List<int> indiFieldEffectIDs = [];
//    Map<int, int> ailmentEffectIDs = {}; // 効果IDと経過ターン数を入れる
//    List<int> weatherEffectIDs = [];
//    List<int> fieldEffectIDs = [];
//
//    // 全タイミング共通
//    if (phaseState.weather.id == Weather.sunny) {
//      // 天気が晴れのとき
//      timings.add(Timing.sunnyAbnormaled);
//      attackerTimings.add(Timing.sunnyAbnormaled);
//      defenderTimings.add(Timing.sunnyAbnormaled);
//    }
//
//    switch (timing) {
//      case Timing.pokemonAppear: // ポケモンを繰り出すとき
//        {
//          timings.addAll(pokemonAppearTimings);
//          attackerTimings.clear();
//          defenderTimings.clear();
//          if (phaseState.weather.id != Weather.rainy) {
//            // ポケモン登場時(天気が雨でない)
//            timings.add(Timing.pokemonAppearNotRained);
//          }
//          if (phaseState.weather.id != Weather.sandStorm) {
//            // ポケモン登場時(天気がすなあらしでない)
//            timings.add(Timing.pokemonAppearNotSandStormed);
//          }
//          if (phaseState.weather.id != Weather.sunny) {
//            // ポケモン登場時(天気が晴れでない)
//            timings.add(Timing.pokemonAppearNotSunny);
//          }
//          if (phaseState.weather.id != Weather.snowy) {
//            // ポケモン登場時(天気がゆきでない)
//            timings.add(Timing.pokemonAppearNotSnowed);
//          }
//          if (phaseState.field.id != Field.electricTerrain) {
//            // ポケモン登場時(エレキフィールドでない)
//            timings.add(Timing.pokemonAppearNotEreciField);
//          }
//          if (phaseState.field.id != Field.psychicTerrain) {
//            // ポケモン登場時(サイコフィールドでない)
//            timings.add(Timing.pokemonAppearNotPsycoField);
//          }
//          if (phaseState.field.id != Field.mistyTerrain) {
//            // ポケモン登場時(ミストフィールドでない)
//            timings.add(Timing.pokemonAppearNotMistField);
//          }
//          if (phaseState.field.id != Field.grassyTerrain) {
//            // ポケモン登場時(グラスフィールドでない)
//            timings.add(Timing.pokemonAppearNotGrassField);
//          }
//          var myFields = phaseState.getIndiFields(playerType);
//          for (final f in myFields) {
//            if (f.possiblyActive(timing)) {
//              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(f));
//            }
//          }
//        }
//        break;
//      case Timing.everyTurnEnd: // 毎ターン終了時
//        {
//          timings.addAll(everyTurnEndTimings);
//          attackerTimings.clear();
//          defenderTimings.clear();
//          if (currentTurn.getInitialPokemonIndex(playerType) ==
//              phaseState.getPokemonIndex(playerType, null)) {
//            timings.add(Timing.afterActedEveryTurnEnd); // 1度でも行動した後毎ターン終了時
//          }
//          if (phaseState.getPokemonState(PlayerType.me, null).holdingItem ==
//                  null &&
//              phaseState
//                      .getPokemonState(PlayerType.opponent, null)
//                      .holdingItem ==
//                  null) {
//            timings.add(
//                Timing.everyTurnEndOpponentItemConsumeed); // 相手が道具を消費したターン終了時
//          }
//          // 天気
//          switch (phaseState.weather.id) {
//            case Weather.sunny: // 天気が晴れのとき、毎ターン終了時
//              timings.addAll([
//                Timing.fireWaterAttackedSunnyRained,
//                Timing.everyTurnEndSunny
//              ]);
//              weatherEffectIDs.add(WeatherEffect.sunnyEnd);
//              break;
//            case Weather.rainy: // 天気があめのとき、毎ターン終了時
//              timings.addAll([
//                Timing.everyTurnEndRained,
//                Timing.fireWaterAttackedSunnyRained,
//                Timing.everyTurnEndRainedWithAbnormal
//              ]);
//              weatherEffectIDs.add(WeatherEffect.rainyEnd);
//              break;
//            case Weather.snowy: // 天気がゆきのとき、毎ターン終了時
//              timings.addAll([Timing.everyTurnEndSnowy]);
//              weatherEffectIDs.add(WeatherEffect.snowyEnd);
//              break;
//            case Weather.sandStorm: // 天気がすなあらしのとき、毎ターン終了時
//              weatherEffectIDs.addAll(
//                  [WeatherEffect.sandStormEnd, WeatherEffect.sandStormDamage]);
//              break;
//            default:
//              break;
//          }
//          // フィールド
//          switch (phaseState.field.id) {
//            case Field.electricTerrain:
//              fieldEffectIDs.add(FieldEffect.electricTerrainEnd);
//              break;
//            case Field.grassyTerrain:
//              fieldEffectIDs.addAll(
//                  [FieldEffect.grassHeal, FieldEffect.grassyTerrainEnd]);
//              break;
//            case Field.mistyTerrain:
//              fieldEffectIDs.add(FieldEffect.mistyTerrainEnd);
//              break;
//            case Field.psychicTerrain:
//              fieldEffectIDs.add(FieldEffect.psychicTerrainEnd);
//              break;
//            default:
//              break;
//          }
//          // 状態変化等
//          if (pokemonState != null && !pokemonState.isTerastaling) {
//            // テラスタルしていないとき
//            timings.add(Timing.everyTurnEndNotTerastaled);
//          }
//          if (pokemonState != null) {
//            for (final ailment in pokemonState.ailmentsIterable) {
//              if (ailment.possiblyActive(timing, pokemonState, phaseState)) {
//                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] =
//                    ailment.turns;
//              }
//            }
//          }
//          if (pokemonState != null &&
//              pokemonState
//                  .ailmentsWhere((e) =>
//                      e.id == Ailment.poison || e.id == Ailment.badPoison)
//                  .isNotEmpty) {
//            // どく/もうどく状態のとき
//            timings.add(Timing.poisonDamage);
//          }
  ///*
//          if (pokemonState != null && pokemonState.ailmentsWhere((e) => e.id == Ailment.ingrain).isNotEmpty) {    // ねをはる状態のとき
//            ailmentEffectIDs.add(AilmentEffect.ingrain);
//          }
//*/
//          if (playerType == PlayerType.me ||
//              playerType == PlayerType.opponent) {
//            if (pokemonState!
//                .ailmentsWhere((e) => e.id <= Ailment.sleep)
//                .isEmpty) {
//              timings.add(Timing.everyTurnEndNotAbnormal); // 状態異常でない毎ターン終了時
//            }
//          }
//          // 各々の場
//          var myFields = phaseState.getIndiFields(playerType);
//          for (final field in myFields) {
//            if (field.possiblyActive(timing)) {
//              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(field));
//            }
//          }
//        }
//        break;
//      case Timing.afterActionDecision: // 行動決定直後
//        {
//          timings.addAll(afterActionDecisionTimings);
//          attackerTimings.clear();
//          defenderTimings.clear();
//        }
//        break;
//      case Timing.beforeMove: // わざ使用前
//        {
//          timings.clear();
//          attackerTimings.clear();
//          defenderTimings.clear();
//          attackerTimings.addAll(beforeMoveAttackerTimings);
//          defenderTimings.addAll(beforeMoveDefenderTimings);
//          if (playerType == PlayerType.me ||
//              playerType == PlayerType.opponent) {
//            var attackerState =
//                phaseState.getPokemonState(attacker, prevAction);
//            var defenderState =
//                phaseState.getPokemonState(attacker.opposite, prevAction);
//            var replacedMoveType = turnMove.getReplacedMoveType(
//                turnMove.move, 0, attackerState, phaseState);
//            if (replacedMoveType == PokeType.normal) {
//              // ノーマルタイプのわざを受けた時
//              defenderTimings.addAll([Timing.normalAttacked]);
//            }
//            if (PokeTypeEffectiveness.effectiveness(
//                    attackerState.currentAbility.id == 113 ||
//                        attackerState.currentAbility.id == 299,
//                    defenderState.holdingItem?.id == 586,
//                    defenderState
//                        .ailmentsWhere((e) => e.id == Ailment.miracleEye)
//                        .isNotEmpty,
//                    replacedMoveType,
//                    pokemonState!) ==
//                MoveEffectiveness.great) {
//              defenderTimings
//                  .add(Timing.greatAttacked); // 効果ばつぐんのタイプのこうげきざわを受けた時
//              switch (replacedMoveType) {
//                case PokeType.fire:
//                  defenderTimings.add(Timing.greatFireAttacked);
//                  break;
//                case PokeType.water:
//                  defenderTimings.add(Timing.greatWaterAttacked);
//                  break;
//                case PokeType.electric:
//                  defenderTimings.add(Timing.greatElectricAttacked);
//                  break;
//                case PokeType.grass:
//                  defenderTimings.add(Timing.greatgrassAttacked);
//                  break;
//                case PokeType.ice:
//                  defenderTimings.add(Timing.greatIceAttacked);
//                  break;
//                case PokeType.fight:
//                  defenderTimings.add(Timing.greatFightAttacked);
//                  break;
//                case PokeType.poison:
//                  defenderTimings.add(Timing.greatPoisonAttacked);
//                  break;
//                case PokeType.ground:
//                  defenderTimings.add(Timing.greatGroundAttacked);
//                  break;
//                case PokeType.fly:
//                  defenderTimings.add(Timing.greatFlyAttacked);
//                  break;
//                case PokeType.psychic:
//                  defenderTimings.add(Timing.greatPsycoAttacked);
//                  break;
//                case PokeType.bug:
//                  defenderTimings.add(Timing.greatBugAttacked);
//                  break;
//                case PokeType.rock:
//                  defenderTimings.add(Timing.greatRockAttacked);
//                  break;
//                case PokeType.ghost:
//                  defenderTimings.add(Timing.greatGhostAttacked);
//                  break;
//                case PokeType.dragon:
//                  defenderTimings.add(Timing.greatDragonAttacked);
//                  break;
//                case PokeType.evil:
//                  defenderTimings.add(Timing.greatEvilAttacked);
//                  break;
//                case PokeType.steel:
//                  defenderTimings.add(Timing.greatSteelAttacked);
//                  break;
//                case PokeType.fairy:
//                  defenderTimings.add(Timing.greatFairyAttacked);
//                  break;
//                default:
//                  break;
//              }
//            }
//            // 状態変化
//            for (final ailment in attackerState.ailmentsIterable) {
//              if (ailment.possiblyActive(timing, attackerState, phaseState)) {
//                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] =
//                    ailment.turns;
//              }
//            }
//          }
//        }
//        break;
//      case Timing.afterMove: // わざ使用後
//        if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
//          timings.clear(); // atacker/defenderに統合するするため削除
//          attackerTimings.addAll(afterMoveAttackerTimings);
//          defenderTimings.addAll(afterMoveDefenderTimings);
//          var attackerState = phaseState.getPokemonState(attacker, prevAction);
//          var defenderState =
//              phaseState.getPokemonState(attacker.opposite, prevAction);
//          var replacedMove =
//              turnMove.getReplacedMove(turnMove.move, 0, attackerState);
//          var replacedMoveType = turnMove.getReplacedMoveType(
//              turnMove.move, 0, attackerState, phaseState);
//          if (replacedMove.priority >= 1) {
//            // 優先度1以上のわざを受けた時
//            defenderTimings.addAll([Timing.priorityMoved]);
//          }
//          // へんかわざを受けた時
//          if (replacedMove.damageClass.id == 1) {
//            defenderTimings.addAll([Timing.statused]);
//          }
//          // こうげきしたとき/うけたとき
//          if (replacedMove.damageClass.id >= 2) {
//            defenderTimings.addAll([
//              Timing.attackedHitted,
//              Timing.attackedHittedWithChance,
//              Timing.attackedHittedWithBake,
//              Timing.pokemonAppearAttacked
//            ]);
//            attackerTimings
//                .addAll([Timing.attackHitted, Timing.defeatOpponentWithAttack]);
//            // うのみ状態/まるのみ状態で相手にこうげきされた後
//            final unomis = defenderState.buffDebuffs
//                .whereByAnyID([BuffDebuff.unomiForm, BuffDebuff.marunomiForm]);
//            if (unomis.isNotEmpty) {
//              ret.add(TurnEffect()
//                ..playerType = attacker.opposite
//                ..timing = Timing.afterMove
//                ..effectType = EffectType.ability
//                ..effectId = 10000 + unomis.first.id);
//            }
//            // ノーマルタイプのこうげきをした時
//            if (replacedMoveType == PokeType.normal) {
//              attackerTimings.addAll([Timing.normalAttackHit]);
//            }
//            // あくタイプのこうげきを受けた時
//            if (replacedMoveType == PokeType.evil) {
//              defenderTimings.addAll([Timing.evilAttacked]);
//            }
//            // みずタイプのこうげきを受けた時
//            if (replacedMoveType == PokeType.water) {
//              defenderTimings
//                  .addAll([Timing.waterAttacked, Timing.fireWaterAttacked]);
//            }
//            // ほのおタイプのこうげきを受けた時
//            if (replacedMoveType == PokeType.fire) {
//              defenderTimings
//                  .addAll([Timing.fireWaterAttacked, Timing.fireAtaccked]);
//            }
//            // でんきタイプのこうげきを受けた時
//            if (replacedMoveType == PokeType.electric) {
//              defenderTimings.addAll([Timing.electricAttacked]);
//            }
//            // こおりタイプのこうげきを受けた時
//            if (replacedMoveType == PokeType.ice) {
//              defenderTimings.addAll([Timing.iceAttacked]);
//            }
//            // こうげきによりひんしになっているとき
//            if (defenderState.isFainting) {
//              defenderTimings.add(Timing.attackedFainting);
//            }
//          }
//          if (replacedMove.isPowder) {
//            defenderTimings.addAll([Timing.powdered]); // こな系のこうげきを受けた時
//          }
//          if (replacedMove.isBullet) {
//            defenderTimings.addAll([Timing.bulleted]); // 弾のこうげきを受けた時
//          }
//          if (replacedMove.damageClass.id == DamageClass.physical) {
//            defenderTimings
//                .addAll([Timing.phisycalAttackedHitted]); // ぶつりこうげきを受けた時
//          }
//          if (replacedMove.damageClass.id == DamageClass.special) {
//            defenderTimings
//                .addAll([Timing.specialAttackedHitted]); // とくしゅこうげきを受けた時
//          }
//          if (replacedMove.isDirect &&
//              !(replacedMove.isPunch &&
//                  attackerState.holdingItem?.id ==
//                      1700) && // パンチグローブをつけたパンチわざでない
//              attackerState.currentAbility.id != 203) {
//            defenderTimings
//                .add(Timing.directAttackedWithChance); // 直接攻撃を受けた時(確率)
//            defenderTimings.add(Timing.directAttacked); // 直接攻撃を受けた時
//            attackerTimings
//                .add(Timing.directAttackHitWithChance); // 直接攻撃をあてたとき(確率)
//            // 違う性別の相手から直接攻撃を受けた時（確率）
//            if (attackerState.sex != defenderState.sex &&
//                attackerState.sex != Sex.none) {
//              defenderTimings.add(Timing.directAttackedByOppositeSexWithChance);
//            }
//            // 直接攻撃によりひんしになっているとき
//            if (defenderState.isFainting) {
//              defenderTimings.add(Timing.directAttackedFainting);
//            }
//            // まもる系統のわざ相手に直接攻撃したとき
//            var findIdx = defenderState.ailmentsIndexWhere(
//                (e) => e.id == Ailment.protect && e.extraArg1 != 0);
//            if (findIdx >= 0 && attacker == playerType) {
//              ret.add(TurnEffect()
//                ..playerType = playerType
//                ..effectType = EffectType.afterMove
//                ..effectId = defenderState.ailments(findIdx).extraArg1);
//            }
//            // みちづれ状態の相手にこうげきしてひんしにしたとき
//            if (defenderState.isFainting &&
//                defenderState
//                    .ailmentsWhere((e) => e.id == Ailment.destinyBond)
//                    .isNotEmpty) {
//              ret.add(TurnEffect()
//                ..playerType = playerType
//                ..effectType = EffectType.afterMove
//                ..effectId = 194);
//            }
//          }
//          if (replacedMove.isSound) {
//            attackerTimings.add(Timing.soundAttack); // 音技を使ったとき
//            defenderTimings.add(Timing.soundAttacked); // 音技を受けた時
//          }
//          if (replacedMove.isDrain) {
//            defenderTimings.add(Timing.drained); // HP吸収わざを受けた時
//          }
//          if (replacedMove.isDance) {
//            defenderTimings.add(Timing.otherDance); // おどり技を受けた時
//          }
//          if (replacedMoveType == PokeType.normal) {
//            // ノーマルタイプのわざを受けた時
//            defenderTimings.addAll([Timing.normalAttacked]);
//          }
//          if (replacedMoveType == PokeType.electric) {
//            // でんきタイプのわざを受けた時
//            defenderTimings.addAll([Timing.electriced, Timing.electricUse]);
//          }
//          if (replacedMoveType == PokeType.water) {
//            // みずタイプのわざを受けた時
//            defenderTimings.addAll([
//              Timing.watered,
//              Timing.fireWaterAttackedSunnyRained,
//              Timing.waterUse
//            ]);
//          }
//          if (replacedMoveType == PokeType.fire) {
//            // ほのおタイプのわざを受けた時
//            defenderTimings
//                .addAll([Timing.fired, Timing.fireWaterAttackedSunnyRained]);
//          }
//          if (replacedMoveType == PokeType.grass) {
//            // くさタイプのわざを受けた時
//            defenderTimings.addAll([Timing.grassed]);
//          }
//          if (replacedMoveType == PokeType.ground) {
//            // じめんタイプのわざを受けた時
//            defenderTimings.addAll([Timing.grounded]);
//          }
//          if (PokeTypeEffectiveness.effectiveness(
//                  attackerState.currentAbility.id == 113 ||
//                      attackerState.currentAbility.id == 299,
//                  defenderState.holdingItem?.id == 586,
//                  defenderState
//                      .ailmentsWhere((e) => e.id == Ailment.miracleEye)
//                      .isNotEmpty,
//                  replacedMoveType,
//                  pokemonState!) ==
//              MoveEffectiveness.great) {
//            defenderTimings.add(Timing.greatAttacked); // 効果ばつぐんのタイプのこうげきざわを受けた時
//            switch (replacedMoveType) {
//              case PokeType.fire:
//                defenderTimings.add(Timing.greatFireAttacked);
//                break;
//              case PokeType.water:
//                defenderTimings.add(Timing.greatWaterAttacked);
//                break;
//              case PokeType.electric:
//                defenderTimings.add(Timing.greatElectricAttacked);
//                break;
//              case PokeType.grass:
//                defenderTimings.add(Timing.greatgrassAttacked);
//                break;
//              case PokeType.ice:
//                defenderTimings.add(Timing.greatIceAttacked);
//                break;
//              case PokeType.fight:
//                defenderTimings.add(Timing.greatFightAttacked);
//                break;
//              case PokeType.poison:
//                defenderTimings.add(Timing.greatPoisonAttacked);
//                break;
//              case PokeType.ground:
//                defenderTimings.add(Timing.greatGroundAttacked);
//                break;
//              case PokeType.fly:
//                defenderTimings.add(Timing.greatFlyAttacked);
//                break;
//              case PokeType.psychic:
//                defenderTimings.add(Timing.greatPsycoAttacked);
//                break;
//              case PokeType.bug:
//                defenderTimings.add(Timing.greatBugAttacked);
//                break;
//              case PokeType.rock:
//                defenderTimings.add(Timing.greatRockAttacked);
//                break;
//              case PokeType.ghost:
//                defenderTimings.add(Timing.greatGhostAttacked);
//                break;
//              case PokeType.dragon:
//                defenderTimings.add(Timing.greatDragonAttacked);
//                break;
//              case PokeType.evil:
//                defenderTimings.add(Timing.greatEvilAttacked);
//                break;
//              case PokeType.steel:
//                defenderTimings.add(Timing.greatSteelAttacked);
//                break;
//              case PokeType.fairy:
//                defenderTimings.add(Timing.greatFairyAttacked);
//                break;
//              default:
//                break;
//            }
//          } else {
//            defenderTimings
//                .add(Timing.notGreatAttacked); // 効果ばつぐん以外のタイプのこうげきざわを受けた時
//          }
//          if (replacedMoveType == PokeType.ground) {
//            if (replacedMove.id != 28 && replacedMove.id != 614) {
//              // すなかけ/サウザンアローではない
//              defenderTimings.add(Timing
//                  .groundFieldEffected); // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
//            }
//          }
//          // とくせいがおどりこの場合
//          if (phaseState
//                      .getPokemonState(PlayerType.me, prevAction)
//                      .currentAbility
//                      .id ==
//                  216 ||
//              phaseState
//                      .getPokemonState(PlayerType.opponent, prevAction)
//                      .currentAbility
//                      .id ==
//                  216) {
//            attackerTimings.addAll(defenderTimings);
//            attackerTimings = attackerTimings.toSet().toList();
//            defenderTimings = attackerTimings;
//          }
//        }
//        break;
//      case Timing.afterTerastal: // テラスタル後
//        {
//          timings.clear();
//          attackerTimings.clear();
//          defenderTimings.clear();
//          if (playerType == PlayerType.me ||
//              playerType == PlayerType.opponent) {
//            bool isMe = playerType == PlayerType.me;
//            bool isTerastal = pokemonState!.isTerastaling &&
//                (isMe
//                    ? !currentTurn.initialOwnHasTerastal
//                    : !currentTurn.initialOpponentHasTerastal);
//
//            if (isTerastal && pokemonState.currentAbility.id == 303) {
//              ret.add(TurnEffect()
//                ..playerType = playerType
//                ..effectType = EffectType.ability
//                ..effectId = 303);
//            }
//          }
//        }
//        break;
//      default:
//        return [];
//    }
//
//    if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
//      if (effectType == EffectType.ability) {
//        if (pokemonState!.currentAbility.id != 0) {
//          // とくせいが確定している場合
//          if (timings.contains(pokemonState.currentAbility.timing)) {
//            retAbilityIDs.add(pokemonState.currentAbility.id);
//          }
//          // わざ使用後に発動する効果
//          if (attacker == playerType &&
//                  attackerTimings
//                      .contains(pokemonState.currentAbility.timing) ||
//              attacker != playerType &&
//                  defenderTimings
//                      .contains(pokemonState.currentAbility.timing)) {
//            retAbilityIDs.add(pokemonState.currentAbility.id);
//          }
//        } else {
//          // とくせいが確定していない場合
//          for (final ability in pokemonState.possibleAbilities) {
//            if (timings.contains(ability.timing)) {
//              retAbilityIDs.add(ability.id);
//            }
//            // わざ使用後に発動する効果
//            if (attacker == playerType &&
//                    attackerTimings.contains(ability.timing) ||
//                attacker != playerType &&
//                    defenderTimings.contains(ability.timing)) {
//              retAbilityIDs.add(ability.id);
//            }
//          }
//        }
//        if (playerType == PlayerType.opponent && phaseState.canAnyZoroark) {
//          retAbilityIDs.add(149); // イリュージョン追加
//        }
//        final abilityIDs = retAbilityIDs.toSet();
//        for (final abilityID in abilityIDs) {
//          ret.add(TurnEffect()
//            ..playerType = playerType
//            ..effectType = EffectType.ability
//            ..effectId = abilityID);
//        }
//      }
//      if (effectType == EffectType.individualField) {
//        for (var e in indiFieldEffectIDs) {
//          var adding = TurnEffect()
//            ..playerType = playerType
//            ..effectType = EffectType.individualField
//            ..effectId = e;
//          if (adding.effectId == IndiFieldEffect.trickRoomEnd) {
//            // 各々の場だが効果としては両フィールドのもの
//            adding.playerType = PlayerType.entireField;
//            if (ret.where((element) => element.nearEqual(adding)).isNotEmpty) {
//              ret.add(adding);
//            }
//          } else {
//            ret.add(adding);
//          }
//        }
//      }
//      if (effectType == EffectType.ailment) {
//        for (var e in ailmentEffectIDs.entries) {
//          ret.add(TurnEffect()
//            ..playerType = playerType
//            ..effectType = EffectType.ailment
//            ..effectId = e.key
//            ..extraArg1 = e.value);
//        }
//      }
//      if (effectType == EffectType.item) {
//        if (pokemonState!.holdingItem != null) {
//          if (pokemonState.holdingItem!.id != 0) {
//            // もちものが確定している場合
//            if (timings.contains(pokemonState.holdingItem!.timing)) {
//              ret.add(TurnEffect()
//                ..playerType = playerType
//                ..effectType = EffectType.item
//                ..effectId = pokemonState.holdingItem!.id);
//            }
//            // わざ使用後に発動する効果
//            if (attacker == playerType &&
//                    attackerTimings
//                        .contains(pokemonState.holdingItem!.timing) ||
//                attacker != playerType &&
//                    defenderTimings
//                        .contains(pokemonState.holdingItem!.timing)) {
//              ret.add(TurnEffect()
//                ..playerType = playerType
//                ..effectType = EffectType.item
//                ..effectId = pokemonState.holdingItem!.id);
//            }
//          } else {
//            // もちものが確定していない場合
//            var allItems = [for (final item in pokeData.items.values) item];
//            for (final item in pokemonState.impossibleItems) {
//              allItems.removeWhere((e) => e.id == item.id);
//            }
//            for (final item in allItems) {
//              if (timings.contains(item.timing)) {
//                ret.add(TurnEffect()
//                  ..playerType = playerType
//                  ..effectType = EffectType.item
//                  ..effectId = item.id);
//              }
//              // わざ使用後に発動する効果
//              if (attacker == playerType &&
//                      attackerTimings.contains(item.timing) ||
//                  attacker != playerType &&
//                      defenderTimings.contains(item.timing)) {
//                ret.add(TurnEffect()
//                  ..playerType = playerType
//                  ..effectType = EffectType.item
//                  ..effectId = item.id);
//              }
//            }
//          }
//        }
//      }
//    }
//
//    if (playerType == PlayerType.entireField) {
//      for (var e in weatherEffectIDs) {
//        ret.add(TurnEffect()
//          ..playerType = PlayerType.entireField
//          ..effectType = EffectType.weather
//          ..effectId = e);
//      }
//      for (var e in fieldEffectIDs) {
//        ret.add(TurnEffect()
//          ..playerType = PlayerType.entireField
//          ..effectType = EffectType.field
//          ..effectId = e);
//      }
//    }
//
//    // argの自動セット
//    var myState = playerType != PlayerType.opponent
//        ? phaseState.getPokemonState(PlayerType.me, prevAction)
//        : phaseState.getPokemonState(PlayerType.opponent, prevAction);
//    var yourState = playerType != PlayerType.opponent
//        ? phaseState.getPokemonState(PlayerType.opponent, prevAction)
//        : phaseState.getPokemonState(PlayerType.me, prevAction);
//    for (var effect in ret) {
//      effect.timing = timing;
//      effect.setAutoArgs(myState, yourState, phaseState, prevAction);
//    }
//
//    return ret;
//  }

  String displayName({
    required AppLocalizations loc,
  });

  PlayerType get playerType;
  set playerType(PlayerType type);

/*
  // 効果に対応して、argsを自動でセット
  void setAutoArgs(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffect? prevAction,
  ) {
    switch (effectType) {
      case EffectType.ability:
        extraArg1 = Ability.getAutoArg1(effectId, playerType, myState,
            yourState, state, prevAction, timing);
        extraArg2 = Ability.getAutoArg2(effectId, playerType, myState,
            yourState, state, prevAction, timing);
        break;
      case EffectType.item:
        extraArg1 = Item.getAutoArg1(effectId, playerType, myState, yourState,
            state, prevAction, timing);
        extraArg2 = Item.getAutoArg2(effectId, playerType, myState, yourState,
            state, prevAction, timing);
        break;
      case EffectType.ailment:
        // extraArg1にはあらかじめ経過ターン数を代入しておく。
        extraArg1 = Ailment.getAutoArg1(effectId, playerType, myState,
            yourState, state, prevAction, timing, extraArg1);
        extraArg2 = Ailment.getAutoArg2(effectId, playerType, myState,
            yourState, state, prevAction, timing);
        break;
      case EffectType.individualField:
        extraArg1 = IndividualField.getAutoArg1(effectId, playerType, myState,
            yourState, state, prevAction, timing);
        extraArg2 = IndividualField.getAutoArg2(effectId, playerType, myState,
            yourState, state, prevAction, timing);
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
    var myState = state.getPokemonState(
        playerType, timing == Timing.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(
        playerType.opposite, timing == Timing.afterMove ? prevAction : null);
    switch (timing) {
      case Timing.action:
      case Timing.continuousMove:
        {
          if (move == null) return '';
          if (move!.playerType == PlayerType.me) {
            return yourState.remainHPPercent.toString();
          } else if (move!.playerType == PlayerType.opponent) {
            return yourState.remainHP.toString();
          }
          return '';
        }
      default:
        {
          switch (effectType) {
            case EffectType.item:
              return pokeData.items[effectId]!
                  .getEditingControllerText2(playerType, myState, yourState);
            case EffectType.ability:
              switch (effectId) {
                case 10: // ちくでん
                case 11: // ちょすい
                case 44: // あめうけざら
                case 87: // かんそうはだ
                case 90: // ポイズンヒール
                case 94: // サンパワー
                case 115: // アイスボディ
                case 209: // ばけのかわ
                case 211: // スワームチェンジ
                case 297: // どしょく
                  if (playerType == PlayerType.me) {
                    return myState.remainHP.toString();
                  } else {
                    return myState.remainHPPercent.toString();
                  }
                case 24: // さめはだ
                case 106: // ゆうばく
                case 123: // ナイトメア
                case 160: // てつのトゲ
                case 215: // とびだすなかみ
                  if (playerType == PlayerType.me) {
                    return yourState.remainHPPercent.toString();
                  } else {
                    return yourState.remainHP.toString();
                  }
                case 36: // トレース
                  if (playerType == PlayerType.me) {
                    if (yourState.getCurrentAbility().id != 0) {
                      extraArg1 = yourState.getCurrentAbility().id;
                      return yourState.getCurrentAbility().displayName;
                    } else {
                      return '';
                    }
                  } else {
                    extraArg1 = myState.getCurrentAbility().id;
                    return myState.getCurrentAbility().displayName;
                  }
                case 53: // ものひろい
                case 119: // おみとおし
                case 124: // わるいてぐせ
                case 139: // しゅうかく
                case 170: // マジシャン
                  return pokeData.items[extraArg1]!.displayName;
                case 108: // よちむ
                  return pokeData.moves[extraArg1]!.displayName;
                case 216: // おどりこ
                  return pokeData.moves[extraArg1 % 10000]!.displayName;
              }
              break;
            case EffectType.ailment:
              switch (effectId) {
                case AilmentEffect.burn: // やけど
                case AilmentEffect.poison: // どく
                case AilmentEffect.badPoison: // もうどく
                case AilmentEffect.saltCure: // しおづけ
                case AilmentEffect.curse: // のろい
                case AilmentEffect.leechSeed: // やどりぎのタネ
                case AilmentEffect.partiallyTrapped: // バインド
                case AilmentEffect.ingrain: // ねをはる
                  if (playerType == PlayerType.me) {
                    return myState.remainHP.toString();
                  } else {
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
                  } else {
                    return myState.remainHPPercent.toString();
                  }
              }
              break;
            case EffectType.weather:
              switch (effectId) {
                case WeatherEffect.sandStormDamage:
                  return state
                      .getPokemonState(PlayerType.me, null)
                      .remainHP
                      .toString();
              }
              break;
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal: // グラスフィールドによる回復
                  return state
                      .getPokemonState(PlayerType.me, null)
                      .remainHP
                      .toString();
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
    TurnEffect? prevAction, {
    bool isOnMoveSelected = false,
  }) {
    var myState = state.getPokemonState(
        playerType, timing == Timing.afterMove ? prevAction : null);
    var yourState = state.getPokemonState(
        playerType.opposite, timing == Timing.afterMove ? prevAction : null);
    var pokeData = PokeDB();

    // わざが選択されたときのみ、extraArgを引いたHPの値をセット
    if (isOnMoveSelected) {
      switch (timing) {
        case Timing.action:
        case Timing.continuousMove:
          {
            if (move == null) return '';
            switch (move!.moveAdditionalEffects[0].id) {
              case 33: // 最大HPの半分だけ回復する
              case 215: // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
              case 80: // 場に「みがわり」を発生させる
              case 133: // 使用者のHP回復。回復量は天気による
              case 163: // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
              case 382: // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
              case 387: // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
              case 441: // 最大HP1/4だけ回復
              case 420: // 最大HP1/2(小数点切り上げ)を削ってこうげき
              case 433: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
              case 461: // 最大HP1/4回復、状態異常を治す
              case 492: // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
                if (move!.playerType == PlayerType.me) {
                  return (myState.remainHP - move!.extraArg1[0]).toString();
                } else if (move!.playerType == PlayerType.opponent) {
                  return (myState.remainHPPercent - move!.extraArg2[0])
                      .toString();
                }
                break;
              case 110: // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
                if (myState.isTypeContain(PokeType.ghost)) {
                  if (move!.playerType == PlayerType.me) {
                    return (myState.remainHP - move!.extraArg1[0]).toString();
                  } else if (move!.playerType == PlayerType.opponent) {
                    return (myState.remainHPPercent - move!.extraArg2[0])
                        .toString();
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
            case 106: // もちものを盗む
            case 178: // 使用者ともちものを入れ替える
            case 185: // 戦闘中自分が最後に使用したもちものを復活させる
            case 189: // もちものを持っていれば失わせ、威力1.5倍
            case 225: // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            case 234: // 使用者のもちものによって威力と追加効果が変わる
            case 324: // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
            case 424: // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
              return pokeData.items[move!.extraArg1[0]]!.displayName;
            case 83: // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
              return pokeData.moves[move!.extraArg3[0]]!.displayName;
            case 179: // 相手と同じとくせいになる
            case 192: // 使用者ととくせいを入れ替える
            case 300: // 相手のとくせいを使用者のとくせいと同じにする
              return pokeData.abilities[move!.extraArg1[0]]!.displayName;
            case 456: // 対象にもちものがあるときのみ成功
            case 457: // 対象のもちものを消失させる
              return pokeData.items[move!.extraArg1[0]]!.displayName;
            default:
              if (move!.playerType == PlayerType.me) {
                return myState.remainHP.toString();
              } else if (move!.playerType == PlayerType.opponent) {
                return myState.remainHPPercent.toString();
              }
              return '';
          }
        }
      default:
        {
          switch (effectType) {
            case EffectType.item:
              switch (effectId) {}
              break;
            case EffectType.ability:
              switch (effectId) {
                case 216: // おどりこ
                  switch (extraArg1) {
                    case 872: // アクアステップ
                    case 80: // はなびらのまい
                    case 552: // ほのおのまい
                    case 10552: // ほのおのまい(とくこう1段階上昇)
                    case 686: // めざめるダンス
                      {
                        if (playerType == PlayerType.me) {
                          return yourState.remainHPPercent.toString();
                        } else {
                          return yourState.remainHP.toString();
                        }
                      }
                    case 837: // しょうりのまい
                    case 483: // ちょうのまい
                    case 14: // つるぎのまい
                    case 297: // フェザーダンス
                    case 298: // フラフラダンス
                    case 461: // みかづきのまい
                    case 349: // りゅうのまい
                      return '';
                    case 775: // ソウルビート
                      {
                        if (playerType == PlayerType.me) {
                          return myState.remainHP.toString();
                        } else {
                          return myState.remainHPPercent.toString();
                        }
                      }
                  }
                  break;
                case 139: // しゅうかく
                  return pokeData.items[extraArg1]!.displayName;
              }
              break;
            case EffectType.ailment:
              switch (effectId) {
                case AilmentEffect.leechSeed: // やどりぎのタネ
                  if (playerType == PlayerType.me) {
                    return yourState.remainHPPercent.toString();
                  } else {
                    return yourState.remainHP.toString();
                  }
              }
              break;
            case EffectType.weather:
              switch (effectId) {
                case WeatherEffect.sandStormDamage:
                  return state
                      .getPokemonState(PlayerType.opponent, null)
                      .remainHPPercent
                      .toString();
              }
              break;
            case EffectType.field:
              switch (effectId) {
                case FieldEffect.grassHeal: // グラスフィールドによる回復
                  return state
                      .getPokemonState(PlayerType.opponent, null)
                      .remainHPPercent
                      .toString();
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
    int phaseIdx, {
    required bool isInput,
    required AppLocalizations loc,
  }) {
    var myPokemon = prevAction != null && timing == Timing.afterMove
        ? state.getPokemonState(playerType, prevAction).pokemon
        : playerType == PlayerType.me
            ? ownPokemon
            : opponentPokemon;
    var yourPokemon = prevAction != null && timing == Timing.afterMove
        ? state.getPokemonState(playerType.opposite, prevAction).pokemon
        : playerType == PlayerType.me
            ? opponentPokemon
            : ownPokemon;
    var myState = prevAction != null && timing == Timing.afterMove
        ? state.getPokemonState(playerType, prevAction)
        : playerType == PlayerType.me
            ? ownPokemonState
            : opponentPokemonState;
    var yourState = prevAction != null && timing == Timing.afterMove
        ? state.getPokemonState(playerType.opposite, prevAction)
        : playerType == PlayerType.me
            ? opponentPokemonState
            : ownPokemonState;
    var myParty = playerType == PlayerType.me ? ownParty : opponentParty;
    var yourParty = playerType == PlayerType.me ? opponentParty : ownParty;

    if (effectType == EffectType.ability) {
      // とくせいによる効果
      switch (effectId) {
        case 10: // ちくでん
        case 11: // ちょすい
        case 44: // あめうけざら
        case 87: // かんそうはだ
        case 90: // ポイズンヒール
        case 94: // サンパワー
        case 115: // アイスボディ
        case 209: // ばけのかわ
        case 211: // スワームチェンジ
        case 297: // どしょく
          return DamageIndicateRow(
            myPokemon,
            controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
              } else {
                extraArg1 =
                    myState.remainHPPercent - (int.tryParse(value) ?? 0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
            loc: loc,
          );
        case 16: // へんしょく
        case 168: // へんげんじざい
        case 236: // リベロ
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
        case 24: // さめはだ
        case 106: // ゆうばく
        case 123: // ナイトメア
        case 160: // てつのトゲ
        case 215: // とびだすなかみ
          return DamageIndicateRow(
            yourPokemon,
            controller,
            playerType != PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 =
                    yourState.remainHPPercent - (int.tryParse(value) ?? 0);
              } else {
                extraArg1 = yourState.remainHP - (int.tryParse(value) ?? 0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
            loc: loc,
          );
        case 27: // ほうし
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
        case 36: // トレース
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
                      } else {
                        matches.addAll(yourState.possibleAbilities);
                      }
                      if (state.canAnyZoroark) {
                        matches.add(PokeDB().abilities[149]!);
                      }
                    } else {
                      matches.add(yourState.getCurrentAbility());
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        case 53: // ものひろい
        case 139: // しゅうかく
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
                    List<Item> matches =
                        appState.pokeData.items.values.toList();
                    matches.removeWhere((e) => e.id == 0);
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        case 88: // ダウンロード
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
                  textValue:
                      extraArg1 == 0 ? loc.commonAttack : loc.commonSAttack,
                ),
              ),
              Text(loc.battleRankUp1),
            ],
          );
        case 108: // よちむ
        case 130: // のろわれボディ
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
                    } else {
                      matches.add(yourPokemon.move1);
                      if (yourPokemon.move2 != null) {
                        matches.add(yourPokemon.move2!);
                      }
                      if (yourPokemon.move3 != null) {
                        matches.add(yourPokemon.move3!);
                      }
                      if (yourPokemon.move4 != null) {
                        matches.add(yourPokemon.move4!);
                      }
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        case 119: // おみとおし
        case 124: // わるいてぐせ
        case 170: // マジシャン
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
                      if (yourState.holdingItem != null &&
                          yourState.holdingItem!.id != 0) {
                        matches.add(yourState.holdingItem!);
                      } else {
                        matches = appState.pokeData.items.values.toList();
                        for (var item in yourState.impossibleItems) {
                          matches
                              .removeWhere((element) => element.id == item.id);
                        }
                      }
                    } else if (yourState.holdingItem != null) {
                      matches = [yourState.holdingItem!];
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        case 141: // ムラっけ
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
                            value: statIndex.index - 1,
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
                      textValue:
                          StatIndexNumber.getStatIndexFromIndex(extraArg1 + 1)
                              .name,
                    ),
                  ),
                  Text(loc.battleRankUp2),
                ],
              ),
              SizedBox(
                height: 10,
              ),
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
                            value: statIndex.index - 1,
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
                      textValue:
                          StatIndexNumber.getStatIndexFromIndex(extraArg2 + 1)
                              .name,
                    ),
                  ),
                  Text(loc.battleRankDown1),
                ],
              ),
            ],
          );
        case 149: // イリュージョン
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
                          value: i + 1,
                          //enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                          child: Text(
                            opponentParty.pokemons[i]!.name,
                            overflow: TextOverflow.ellipsis,
                            /*style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon) ?
                              Colors.black : Colors.grey),*/
                          ),
                        ),
                    ],
                    value: extraArg1 <= 0 ? null : extraArg1,
                    onChanged: (value) {
                      extraArg1 = value;
                      appState.editingPhase[phaseIdx] = true;
                      appState.needAdjustPhases = phaseIdx + 1;
                      onFocus();
                    },
                    onFocus: onFocus,
                    isInput: isInput,
                    textValue: extraArg1 > 0
                        ? opponentParty.pokemons[extraArg1 - 1]?.name
                        : '',
                  ),
                ),
              ],
            );
          }
          break;
        case 281: // こだいかっせい
        case 282: // クォークチャージ
        case 224: // ビーストブースト
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
                        value: statIndex.index - 1,
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
                  textValue: extraArg1 == -1
                      ? loc.battleEffectExpired
                      : StatIndexNumber.getStatIndexFromIndex(extraArg1 + 1)
                          .name,
                ),
              ),
              extraArg1 >= 0 ? Text(loc.battleStatIncrease) : Text(''),
            ],
          );
        case 290: // びんじょう
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
                        value: statIndex.index - 1,
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
                  textValue:
                      StatIndexNumber.getStatIndexFromIndex(extraArg1 + 1).name,
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
        case 216: // おどりこ
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
                      872,
                      837,
                      775,
                      483,
                      14,
                      80,
                      297,
                      298,
                      552,
                      461,
                      686,
                      349,
                    ];
                    List<Move> matches = [];
                    for (var i in ids) {
                      matches.add(appState.pokeData.moves[i]!);
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              SizedBox(
                height: 10,
              ),
              extraArg1 == 872 ||
                      extraArg1 == 80 ||
                      extraArg1 == 552 ||
                      extraArg1 == 10552 ||
                      extraArg1 == 686
                  ? DamageIndicateRow(
                      yourPokemon,
                      controller,
                      playerType != PlayerType.me,
                      onFocus,
                      (value) {
                        if (playerType == PlayerType.me) {
                          extraArg2 = yourState.remainHPPercent -
                              (int.tryParse(value) ?? 0);
                        } else {
                          extraArg2 =
                              yourState.remainHP - (int.tryParse(value) ?? 0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                      extraArg2,
                      isInput,
                      loc: loc,
                    )
                  : extraArg1 == 775
                      ? DamageIndicateRow(
                          myPokemon,
                          controller,
                          playerType == PlayerType.me,
                          onFocus,
                          (value) {
                            if (playerType == PlayerType.me) {
                              extraArg2 =
                                  myState.remainHP - (int.tryParse(value) ?? 0);
                            } else {
                              extraArg2 = myState.remainHPPercent -
                                  (int.tryParse(value) ?? 0);
                            }
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                          extraArg2,
                          isInput,
                          loc: loc,
                        )
                      : Container(),
              extraArg1 == 552 || extraArg1 == 10552
                  ? SizedBox(
                      height: 10,
                    )
                  : Container(),
              extraArg1 == 552 || extraArg1 == 10552
                  ? Expanded(
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
                            child: Text(loc
                                .battleSAttackUp1(myState.pokemon.omittedName)),
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
                        textValue: extraArg1 == 552
                            ? loc.commonNone
                            : loc.battleSAttackUp1(myState.pokemon.omittedName),
                      ),
                    )
                  : Container(),
            ],
          );
        default:
          break;
      }
    } else if (effectType == EffectType.item) {
      // もちものによる効果
      return appState.pokeData.items[effectId]!.extraWidget(
        onFocus,
        theme,
        playerType,
        myPokemon,
        yourPokemon,
        myState,
        yourState,
        myParty,
        yourParty,
        state,
        controller,
        extraArg1,
        extraArg2,
        getChangePokemonIndex(playerType),
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
    } else if (effectType == EffectType.individualField) {
      // 各ポケモンの場による効果
      switch (effectId) {
        case IndiFieldEffect.spikes1: // まきびし
        case IndiFieldEffect.spikes2:
        case IndiFieldEffect.spikes3:
        case IndiFieldEffect.futureAttack: // みらいにこうげき
        case IndiFieldEffect.stealthRock: // ステルスロック
        case IndiFieldEffect.wish: // ねがいごと
          return DamageIndicateRow(
            myPokemon,
            controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
              } else {
                extraArg1 =
                    myState.remainHPPercent - (int.tryParse(value) ?? 0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
            loc: loc,
          );
      }
    } else if (effectType == EffectType.ailment) {
      // 状態変化による効果
      switch (effectId) {
        case AilmentEffect.poison: // どく
        case AilmentEffect.badPoison: // もうどく
        case AilmentEffect.burn: // やけど
        case AilmentEffect.saltCure: // しおづけ
        case AilmentEffect.curse: // のろい
        case AilmentEffect.ingrain: // ねをはる
          return DamageIndicateRow(
            myPokemon,
            controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
              } else {
                extraArg1 =
                    myState.remainHPPercent - (int.tryParse(value) ?? 0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg1,
            isInput,
            loc: loc,
          );
        case AilmentEffect.leechSeed: // やどりぎのタネ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                myPokemon,
                controller,
                playerType == PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
                    extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
                  } else {
                    extraArg1 =
                        myState.remainHPPercent - (int.tryParse(value) ?? 0);
                  }
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
                loc: loc,
              ),
              SizedBox(
                height: 10,
              ),
              DamageIndicateRow(
                yourPokemon,
                controller2,
                playerType != PlayerType.me,
                onFocus,
                (value) {
                  if (playerType == PlayerType.me) {
                    extraArg2 =
                        yourState.remainHPPercent - (int.tryParse(value) ?? 0);
                  } else {
                    extraArg2 = yourState.remainHP - (int.tryParse(value) ?? 0);
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
        case AilmentEffect.partiallyTrapped: // バインド
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
                textValue: extraArg2 == 1
                    ? loc.battleEffectExpired
                    : loc.battleDamaged,
              ),
              SizedBox(
                height: 10,
              ),
              extraArg2 == 0
                  ? DamageIndicateRow(
                      myPokemon,
                      controller,
                      playerType == PlayerType.me,
                      onFocus,
                      (value) {
                        if (playerType == PlayerType.me) {
                          extraArg1 =
                              myState.remainHP - (int.tryParse(value) ?? 0);
                        } else {
                          extraArg1 = myState.remainHPPercent -
                              (int.tryParse(value) ?? 0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                      extraArg1,
                      isInput,
                      loc: loc,
                    )
                  : Container(),
            ],
          );
        case AilmentEffect.candyCandy: // あめまみれ
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
                      child: Text(
                          loc.battleSpeedDown1(myState.pokemon.omittedName)),
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
                  textValue: extraArg2 == 1
                      ? loc.battleEffectExpired
                      : loc.battleSpeedDown1(myState.pokemon.omittedName),
                ),
              ),
            ],
          );
      }
    } else if (effectType == EffectType.weather) {
      // 天気による効果
      switch (effectId) {
        case WeatherEffect.sandStormDamage: // すなあらしによるダメージ
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                ownPokemon,
                controller,
                true,
                onFocus,
                (value) {
                  extraArg1 =
                      ownPokemonState.remainHP - (int.tryParse(value) ?? 0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
                loc: loc,
              ),
              SizedBox(
                height: 10,
              ),
              DamageIndicateRow(
                opponentPokemon,
                controller2,
                false,
                onFocus,
                (value) {
                  extraArg2 = opponentPokemonState.remainHPPercent -
                      (int.tryParse(value) ?? 0);
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
    } else if (effectType == EffectType.field) {
      // フィールドによる効果
      switch (effectId) {
        case FieldEffect.grassHeal: // グラスフィールドによる回復
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                ownPokemon,
                controller,
                true,
                onFocus,
                (value) {
                  extraArg1 =
                      ownPokemonState.remainHP - (int.tryParse(value) ?? 0);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                },
                extraArg1,
                isInput,
                loc: loc,
              ),
              SizedBox(
                height: 10,
              ),
              DamageIndicateRow(
                opponentPokemon,
                controller2,
                false,
                onFocus,
                (value) {
                  extraArg2 = opponentPokemonState.remainHPPercent -
                      (int.tryParse(value) ?? 0);
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
    } else if (effectType == EffectType.afterMove) {
      // わざによる効果
      switch (effectId) {
        case 596: // ニードルガード
          return DamageIndicateRow(
            myPokemon,
            controller,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
              } else {
                extraArg1 =
                    myState.remainHPPercent - (int.tryParse(value) ?? 0);
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
    TextFieldConfiguration textFieldConfiguration =
        const TextFieldConfiguration(),
    SuggestionsBoxDecoration suggestionsBoxDecoration =
        const SuggestionsBoxDecoration(),
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
  }) {
    if (isInput) {
      return TypeAheadField(
        suggestionsCallback: suggestionsCallback,
        itemBuilder: itemBuilder,
        onSuggestionSelected: onSuggestionSelected,
        textFieldConfiguration: textFieldConfiguration,
        suggestionsBoxDecoration: suggestionsBoxDecoration,
        debounceDuration: debounceDuration,
        suggestionsBoxController: suggestionsBoxController,
        scrollController: scrollController,
        loadingBuilder: loadingBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder,
        animationStart: animationStart,
        animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions,
        suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction,
        hideOnLoading: hideOnLoading,
        hideOnEmpty: hideOnEmpty,
        hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
        keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected:
            keepSuggestionsOnSuggestionSelected,
        autoFlipDirection: autoFlipDirection,
        autoFlipListDirection: autoFlipListDirection,
        hideKeyboard: hideKeyboard,
        minCharsForSuggestions: minCharsForSuggestions,
        onSuggestionsBoxToggle: onSuggestionsBoxToggle,
        hideKeyboardOnDrag: hideKeyboardOnDrag,
        key: key,
      );
    } else {
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
    required String? textValue, // isInput==falseのとき、出力する文字列として必須
    required void Function() onFocus,
  }) {
    if (isInput) {
      return DropdownButtonFormField(
        key: key,
        items: items,
        selectedItemBuilder: selectedItemBuilder,
        value: value,
        hint: hint,
        disabledHint: disabledHint,
        onChanged: onChanged,
        onTap: onTap,
        elevation: elevation,
        style: style,
        icon: icon,
        iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor,
        iconSize: iconSize,
        isDense: isDense,
        isExpanded: isExpanded,
        itemHeight: itemHeight,
        focusColor: focusColor,
        focusNode: focusNode,
        autofocus: autofocus,
        dropdownColor: dropdownColor,
        decoration: decoration,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight,
        enableFeedback: enableFeedback,
        alignment: alignment,
        borderRadius: borderRadius,
        padding: padding,
      );
    } else {
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
    int? value, {
    required bool isInput,
    bool isError = false,
    bool isTeraType = false,
  }) {
    if (isInput) {
      return TypeDropdownButton(
        labelText,
        onChanged,
        value != null ? PokeType.values[value] : null,
        isError: isError,
        isTeraType: isTeraType,
      );
    } else {
      return TextField(
        controller: TextEditingController(
            text: PokeType.values[value ?? 0].displayName),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: labelText,
          prefixIcon: PokeType.values[value ?? 0].displayIcon,
        ),
        onTap: onFocus,
        readOnly: true,
      );
    }
  }
*/

  // SQLに保存された文字列からTurnEffectをパース
  static TurnEffect deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    final EffectType effectType =
        EffectType.values[int.parse(str.split(split1)[0])];
    switch (effectType) {
      case EffectType.none:
        throw Exception('arienai');
      case EffectType.action:
        return TurnEffectAction.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.ability:
        return TurnEffectAbility.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.item:
        return TurnEffectItem.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.individualField:
        return TurnEffectIndividualField.deserialize(
            str, split1, split2, split3,
            version: version);
      case EffectType.ailment:
        return TurnEffectAilment.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.weather:
        return TurnEffectWeather.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.field:
        return TurnEffectField.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.changeFaintingPokemon:
        return TurnEffectChangeFaintingPokemon.deserialize(
            str, split1, split2, split3,
            version: version);
      case EffectType.afterMove:
        return TurnEffectAfterMove.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.userEdit:
        return TurnEffectUserEdit.deserialize(str, split1, split2, split3,
            version: version);
      case EffectType.terastal:
        return TurnEffectTerastal.deserialize(str, split1, split2, split3,
            version: version);
    }
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3);

//  static void swap(List<TurnEffect> list, int idx1, int idx2) {
//    TurnEffect tmp = list[idx1].copy();
//    list[idx1] = list[idx2].copy();
//    list[idx2] = tmp;
//  }
}

/*
class TurnEffectAndStateAndGuide {
  int phaseIdx = -1;
  TurnEffect turnEffect = TurnEffect();
  PhaseState phaseState = PhaseState();
  List<Guide> guides = [];
  bool needAssist = false;
  List<TurnEffect> candidateEffect = []; // 入力される候補となるTurnEffectのリスト

  // candidateEffectを更新する
  // candidateEffectは、各タイミングの最初の要素に入れておくのがbetter？
  void updateEffectCandidates(Turn currentTurn, PhaseState prevState) {
    candidateEffect.clear();
    candidateEffect.addAll(_getEffectCandidates(
      turnEffect.timing,
      PlayerType.me,
      null,
      currentTurn,
      prevState,
    ));
    candidateEffect.addAll(_getEffectCandidates(
      turnEffect.timing,
      PlayerType.opponent,
      null,
      currentTurn,
      prevState,
    ));
    candidateEffect.addAll(_getEffectCandidates(
      turnEffect.timing,
      PlayerType.entireField,
      null,
      currentTurn,
      prevState,
    ));
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
      for (int i = phaseIdx - 1; i >= 0; i--) {
        if (turn.phases[i].timing == Timing.action) {
          prevAction = turn.phases[i];
          break;
        } else if (turn.phases[i].timing != timing) {
          break;
        }
      }
    } else if (timing == Timing.beforeMove) {
      for (int i = phaseIdx + 1; i < turn.phases.length; i++) {
        if (turn.phases[i].timing == Timing.action) {
          prevAction = turn.phases[i];
          break;
        } else if (turn.phases[i].timing != timing) {
          break;
        }
      }
    }
    PlayerType attacker =
        prevAction != null ? prevAction.playerType : PlayerType.none;
    TurnMove turnMove =
        prevAction?.move != null ? prevAction!.move! : TurnMove();

    if (playerType == PlayerType.entireField) {
      return _getEffectCandidatesWithEffectType(timing, playerType,
          EffectType.ability, attacker, turnMove, turn, prevAction, phaseState);
    }
    if (effectType == null) {
      List<TurnEffect> ret = [];
      ret.addAll(_getEffectCandidatesWithEffectType(
          timing,
          playerType,
          EffectType.ability,
          attacker,
          turnMove,
          turn,
          prevAction,
          phaseState));
      ret.addAll(_getEffectCandidatesWithEffectType(timing, playerType,
          EffectType.item, attacker, turnMove, turn, prevAction, phaseState));
      ret.addAll(_getEffectCandidatesWithEffectType(
          timing,
          playerType,
          EffectType.individualField,
          attacker,
          turnMove,
          turn,
          prevAction,
          phaseState));
      ret.addAll(_getEffectCandidatesWithEffectType(
          timing,
          playerType,
          EffectType.ailment,
          attacker,
          turnMove,
          turn,
          prevAction,
          phaseState));
      return ret;
    } else {
      return _getEffectCandidatesWithEffectType(timing, playerType, effectType,
          attacker, turnMove, turn, prevAction, phaseState);
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
    return TurnEffect.getPossibleEffects(
        timing,
        playerType,
        effectType,
        playerType == PlayerType.me || playerType == PlayerType.opponent
            ? phaseState.getPokemonState(playerType, prevAction).pokemon
            : null,
        playerType == PlayerType.me || playerType == PlayerType.opponent
            ? phaseState.getPokemonState(playerType, prevAction)
            : null,
        phaseState,
        attacker,
        turnMove,
        turn,
        prevAction);
  }
}
*/
