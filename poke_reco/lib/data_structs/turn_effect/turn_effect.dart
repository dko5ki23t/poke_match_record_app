import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ability.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_after_move.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ailment.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_gameset.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_individual_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_terastal.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_user_edit.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_weather.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tuple/tuple.dart';

/// 効果の種類
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
  gameset,
}

/// 効果の種類名のextension
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
    12: Tuple2('対戦終了', 'Game Set'),
  };

  /// 表示名
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

/// 共通のタイミング
const Set<Timing> allTimings = {
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
};

/// ポケモンを繰り出すときのタイミング
const List<Timing> pokemonAppearTimings = [
  Timing.pokemonAppear, // ポケモン登場時
  Timing.pokemonAppearWithChance, // ポケモン登場時(確率/条件)
  Timing
      .pokemonAppearWithChanceEveryTurnEndWithChance, // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.pokemonAppearAttacked, // ポケモン登場時・こうげきを受けたとき
];

/// 行動決定直後に発生し得るとくせい
const List<int> afterActionDecisionAbilityIDs = [
  259, // クイックドロウ
];

/// 行動決定直後に発生し得るもちもの
const List<int> afterActionDecisionItemIDs = [
  194, // せんせいのツメ
  187, // イバンのみ
];

/// 行動決定直後に発生し得るタイミング
const List<Timing> afterActionDecisionTimings = [
  Timing.afterActionDecision, // 行動決定後、行動実行前
  Timing.afterActionDecisionWithChance, // 行動決定後、行動実行前(確率)
  Timing.afterActionDecisionHP025, // HPが1/4以下で行動決定後
];

/// こうげき側に対してわざ使用前に発生し得るタイミング
const List<Timing> beforeMoveAttackerTimings = [
  Timing.beforeMoveWithChance, // わざ使用前(確率・条件)
];

/// ぼうぎょ側に対してわざ使用前に発生し得るタイミング
const List<Timing> beforeMoveDefenderTimings = [
  Timing.beforeTypeNormalOrGreatAttackedWithFullHP, // HPが満タンで等倍以上のタイプ相性わざを受ける前
];

/// こうげき側に対してわざ使用後に発生し得るタイミング
const List<Timing> afterMoveAttackerTimings = [
  Timing.attackSuccessedWithChance, // こうげきし、相手にあたったとき(確率)
  Timing.movingWithChance, // わざを使うとき(確率・条件)
  Timing.movingMovedWithCondition, // わざを使うとき(条件)、特定のわざを使ったとき
  Timing.notHit, // わざが当たらなかったとき
  Timing.runOutPP, // 1つのわざのPPが0になったとき
  Timing.chargeMoving, // ためわざを使うとき
];

/// ぼうぎょ側に対してわざ使用後に発生し得るタイミング
const List<Timing> afterMoveDefenderTimings = [
  Timing.hpMaxAndAttacked, // HPが満タンでこうげきを受けた時
  Timing.criticaled, // こうげきが急所に当たった時
];

/// 毎ターン終了時に発生し得るフィールド効果
const List<int> everyTurnEndFieldIDs = [
  Field.electricTerrain, // エレキフィールド終了
  Field.grassyTerrain, // グラスフィールド終了
  Field.mistyTerrain, // ミストフィールド終了
  Field.psychicTerrain, // サイコフィールド終了
];

/// 毎ターン終了時に発生し得るタイミング
const List<Timing> everyTurnEndTimings = [
  Timing.everyTurnEnd, // 毎ターン終了時
  Timing.everyTurnEndWithChance, // 毎ターン終了時（確率・条件）
  Timing
      .pokemonAppearWithChanceEveryTurnEndWithChance, // ポケモン登場時と毎ターン終了時（ともに条件あり）
  Timing.everyTurnEndHPNotFull, // HPが満タンでない毎ターン終了時
  Timing
      .everyTurnEndHPNotFull2, // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
];

/// ターン内で起こる効果
abstract class TurnEffect extends Equatable implements Copyable {
  /// 効果の種類
  final EffectType effectType;

  /// 効果処理前から自身のポケモンがひんしだったかどうか
  bool _alreadyOwnFainting = false;

  /// 効果処理前から相手のポケモンがひんしだったかどうか
  bool _alreadyOpponentFainting = false;

  /// 効果処理前に自身のポケモンがもちものを持っていたかどうか
  bool _ownItemHolded = false;

  /// 効果処理前に相手のポケモンがもちものを持っていたかどうか
  bool _opponentItemHolded = false;

  /// このフェーズで自身のポケモンがひんしになるかどうか
  bool _isOwnFainting = false;

  /// このフェーズで自身のポケモンがひんしになるかどうか
  bool get isOwnFainting => _isOwnFainting;

  /// このフェーズで相手のポケモンがひんしになるかどうか
  bool _isOpponentFainting = false;

  /// このフェーズで相手のポケモンがひんしになるかどうか
  bool get isOpponentFainting => _isOpponentFainting;

  /// ポケモン交代で自身のポケモンを交代したかどうか
  bool _isOwnChanged = false;

  /// ポケモン交代で相手のポケモンを交代したかどうか
  bool _isOpponentChanged = false;

  /// 自身が勝利したか（両方勝利の場合は引き分け）
  bool _isMyWin = false;

  /// 自身が勝利したか（両方勝利の場合は引き分け）
  bool get isMyWin => _isMyWin;

  /// 相手が勝利したか（両方勝利の場合は引き分け）
  bool _isYourWin = false;

  /// 相手が勝利したか（両方勝利の場合は引き分け）
  bool get isYourWin => _isYourWin;
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

  /// 有効かどうか
  bool isValid();

  /// 効果やわざの結果から、各ポケモン等の状態を更新する
  /// * ※内部の最初でbeforeProcessEffect()を必ず呼ぶこと。
  /// * ※内部の最後でbeforeProcessEffect()を必ず呼ぶこと。
  /// ```
  /// ownParty: 自身(ユーザー)のパーティ
  /// ownState: 自身(ユーザー)のポケモンの状態
  /// opponentParty: 相手のパーティ
  /// opponentState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// prevAction: この行動の直前に起きた行動(わざ使用後の処理等に用いる)
  /// ```
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownState,
    Party opponentParty,
    PokemonState opponentState,
    PhaseState state,
    TurnEffectAction? prevAction, {
    required AppLocalizations loc,
  });

  /// processEffect()内の最初に必ず呼び出す処理
  /// * 呼び出さないとisMyWinやisOwnFainting等の値が更新されない
  /// ```
  /// ownState: 自身(ユーザー)のポケモンの状態
  /// opponentState: 相手のポケモンの状態
  /// ```
  @protected
  void beforeProcessEffect(
    PokemonState ownState,
    PokemonState opponentState,
  ) {
    _alreadyOwnFainting = ownState.isFainting;
    _alreadyOpponentFainting = opponentState.isFainting;
    // もちもの失くした判定
    _ownItemHolded = ownState.holdingItem != null;
    _opponentItemHolded = opponentState.holdingItem != null;
    // ポケモン交代の場合、もちもの失くした判定用に変数セット
    _isOwnChanged =
        playerType == PlayerType.me && runtimeType == TurnEffectAction;
    _isOpponentChanged =
        playerType == PlayerType.opponent && runtimeType == TurnEffectAction;
  }

  /// processEffect()内の最後に必ず呼び出す処理
  /// * 呼び出さないとisMyWinやisOwnFainting等の値が更新されない
  /// ```
  /// ownState: 自身(ユーザー)のポケモンの状態
  /// opponentState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  @protected
  void afterProcessEffect(
    PokemonState ownState,
    PokemonState opponentState,
    PhaseState state,
  ) {
    // HP 満タン判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool isFull = player == PlayerType.me
          ? ownState.remainHP >= ownState.pokemon.h.real
          : opponentState.remainHPPercent >= 100;
      var pokeState = player == PlayerType.me ? ownState : opponentState;
      if (isFull) {
        if (pokeState.currentAbility.id == 136) {
          // マルチスケイル
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.damaged0_5);
        }
        if (pokeState.currentAbility.id == 177) {
          // はやてのつばさ
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.galeWings);
        }
      } else {
        if (pokeState.currentAbility.id == 136) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.damaged0_5); // マルチスケイル
        }
        if (pokeState.currentAbility.id == 177) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.galeWings); // はやてのつばさ
        }
      }
    }

    // HP 1/2以下判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool is1_2 = player == PlayerType.me
          ? ownState.remainHP <= (ownState.pokemon.h.real / 2).floor()
          : opponentState.remainHPPercent <= 50;
      var pokeState = player == PlayerType.me ? ownState : opponentState;
      if (is1_2) {
        if (pokeState.currentAbility.id == 129) {
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.defeatist); // よわき
        }
      } else {
        if (pokeState.currentAbility.id == 129) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.defeatist); // よわき
        }
      }
    }

    // HP 1/3以下判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      bool is1_3 = player == PlayerType.me
          ? ownState.remainHP <= (ownState.pokemon.h.real / 3).floor()
          : opponentState.remainHPPercent <= 33;
      var pokeState = player == PlayerType.me ? ownState : opponentState;
      if (is1_3) {
        if (pokeState.currentAbility.id == 65) {
          // しんりょく
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.overgrow);
        }
        if (pokeState.currentAbility.id == 66) {
          // もうか
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.blaze);
        }
        if (pokeState.currentAbility.id == 67) {
          // げきりゅう
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.torrent);
        }
        if (pokeState.currentAbility.id == 68) {
          // むしのしらせ
          pokeState.buffDebuffs.addIfNotFoundByID(BuffDebuff.swarm);
        }
      } else {
        if (pokeState.currentAbility.id == 65) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.overgrow); // しんりょく
        }
        if (pokeState.currentAbility.id == 66) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.blaze); // もうか
        }
        if (pokeState.currentAbility.id == 67) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.torrent); // げきりゅう
        }
        if (pokeState.currentAbility.id == 68) {
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.swarm); // むしのしらせ
        }
      }
    }

    // もちもの失くした判定
    for (var player in [PlayerType.me, PlayerType.opponent]) {
      var pokeState = player == PlayerType.me ? ownState : opponentState;
      if ((!_isOwnChanged &&
              player == PlayerType.me &&
              _ownItemHolded &&
              ownState.holdingItem == null) ||
          (!_isOpponentChanged &&
              player == PlayerType.opponent &&
              _opponentItemHolded &&
              opponentState.holdingItem == null)) {
        // もちもの失くした
        if (pokeState.currentAbility.id == 84) {
          // かるわざ
          pokeState.buffDebuffs
              .add(PokeDB().buffDebuffs[BuffDebuff.unburden]!.copy());
        }
      } else if ((!_isOwnChanged &&
              player == PlayerType.me &&
              !_ownItemHolded &&
              ownState.holdingItem != null) ||
          (!_isOpponentChanged &&
              player == PlayerType.opponent &&
              !_opponentItemHolded &&
              opponentState.holdingItem != null)) {
        // もちもの得た
        if (pokeState.currentAbility.id == 84) {
          // かるわざ
          pokeState.buffDebuffs.removeAllByID(BuffDebuff.unburden);
        }
      }
    }

    // 満タン以上の回復はしない
    if (ownState.remainHP >= ownState.pokemon.h.real) {
      ownState.remainHP = ownState.pokemon.h.real;
    }
    if (opponentState.remainHPPercent >= 100) {
      opponentState.remainHPPercent = 100;
    }
    // ひんし判定(本フェーズでひんしになったか)
    _isOwnFainting = false;
    if (ownState.remainHP <= 0) {
      ownState.remainHP = 0;
      ownState.isFainting = true;
      if (!_alreadyOwnFainting) {
        _isOwnFainting = true;
        state.incFaintingCount(PlayerType.me, 1);
      }
    } else {
      ownState.isFainting = false;
    }
    _isOpponentFainting = false;
    if (opponentState.remainHPPercent <= 0) {
      opponentState.remainHPPercent = 0;
      opponentState.isFainting = true;
      if (!_alreadyOpponentFainting) {
        _isOpponentFainting = true;
        state.incFaintingCount(PlayerType.opponent, 1);
      }
    } else {
      opponentState.isFainting = false;
    }

    // 勝利判定
    _isMyWin = state.isMyWin;
    _isYourWin = state.isYourWin;
    // わざの反動等で両者同時に倒れる場合あり→このTurnEffectの発動主が勝利とする
    // TODO:いのちがけ等
    if (_isMyWin && _isYourWin) {
      if (playerType == PlayerType.me) {
        _isYourWin = false;
      } else {
        _isMyWin = false;
      }
    }
  }

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  int? getChangePokemonIndex(PlayerType player);

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を設定する
  /// nullを設定すると交換していないことを表す
  /// ```
  /// player: 行動主
  /// prev: 交換前ポケモンのパーティ内インデックス(1始まり)
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  void setChangePokemonIndex(PlayerType player, int? prev, int? val);

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  int? getPrevPokemonIndex(PlayerType player);

  /// 効果のextraArg等を編集するWidgetを返す
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 対戦相手のパーティ
  /// state: フェーズの状態
  /// controller: テキスト入力コントローラ
  /// onEdit: 編集したときに呼び出すコールバック
  /// (ダイアログで、効果が有効かどうかでOKボタンの有効無効を切り替えるために使う)
  /// ```
  Widget editArgWidget(
    PokemonState myState,
    PokemonState yourState,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    TextEditingController controller,
    TextEditingController controller2, {
    required Function() onEdit,
    required AppLocalizations loc,
    required ThemeData theme,
  });

  /// 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
  /// ```
  /// ```
  static List<TurnEffect> getPossibleEffects(
      Timing timing,
      PlayerType playerType,
      EffectType effectType,
      Pokemon? pokemon,
      PokemonState? pokemonState,
      PhaseState phaseState,
      PlayerType attacker,
      TurnEffectAction turnMove,
      Turn currentTurn,
      TurnEffectAction? prevAction) {
    final pokeData = PokeDB();
    List<TurnEffect> ret = [];
    List<int> retAbilityIDs = [];
    Set<Timing> timings = {...allTimings};
    Set<Timing> attackerTimings = {...allTimings};
    Set<Timing> defenderTimings = {...allTimings};
    List<int> indiFieldEffectIDs = [];
    Map<int, int> ailmentEffectIDs = {}; // 効果IDと経過ターン数を入れる
    List<int> weatherEffectIDs = [];
    List<int> fieldEffectIDs = [];

    // 全タイミング共通
    if (phaseState.weather.id == Weather.sunny) {
      // 天気が晴れのとき
      timings.add(Timing.sunnyAbnormaled);
      attackerTimings.add(Timing.sunnyAbnormaled);
      defenderTimings.add(Timing.sunnyAbnormaled);
    }

    switch (timing) {
      case Timing.pokemonAppear: // ポケモンを繰り出すとき
        {
          timings.addAll(pokemonAppearTimings);
          attackerTimings.clear();
          defenderTimings.clear();
          if (phaseState.weather.id != Weather.rainy) {
            // ポケモン登場時(天気が雨でない)
            timings.add(Timing.pokemonAppearNotRained);
          }
          if (phaseState.weather.id != Weather.sandStorm) {
            // ポケモン登場時(天気がすなあらしでない)
            timings.add(Timing.pokemonAppearNotSandStormed);
          }
          if (phaseState.weather.id != Weather.sunny) {
            // ポケモン登場時(天気が晴れでない)
            timings.add(Timing.pokemonAppearNotSunny);
          }
          if (phaseState.weather.id != Weather.snowy) {
            // ポケモン登場時(天気がゆきでない)
            timings.add(Timing.pokemonAppearNotSnowed);
          }
          if (phaseState.field.id != Field.electricTerrain) {
            // ポケモン登場時(エレキフィールドでない)
            timings.add(Timing.pokemonAppearNotEreciField);
          }
          if (phaseState.field.id != Field.psychicTerrain) {
            // ポケモン登場時(サイコフィールドでない)
            timings.add(Timing.pokemonAppearNotPsycoField);
          }
          if (phaseState.field.id != Field.mistyTerrain) {
            // ポケモン登場時(ミストフィールドでない)
            timings.add(Timing.pokemonAppearNotMistField);
          }
          if (phaseState.field.id != Field.grassyTerrain) {
            // ポケモン登場時(グラスフィールドでない)
            timings.add(Timing.pokemonAppearNotGrassField);
          }
          var myFields = phaseState.getIndiFields(playerType);
          for (final f in myFields) {
            if (f.possiblyActive(timing)) {
              indiFieldEffectIDs.add(IndiFieldEffect.getIdFromIndiField(f));
            }
          }
        }
        break;
      case Timing.everyTurnEnd: // 毎ターン終了時
        {
          timings.addAll(everyTurnEndTimings);
          attackerTimings.clear();
          defenderTimings.clear();
          if (currentTurn.getInitialPokemonIndex(playerType) ==
              phaseState.getPokemonIndex(playerType, null)) {
            timings.add(Timing.afterActedEveryTurnEnd); // 1度でも行動した後毎ターン終了時
          }
          if (phaseState.getPokemonState(PlayerType.me, null).holdingItem ==
                  null &&
              phaseState
                      .getPokemonState(PlayerType.opponent, null)
                      .holdingItem ==
                  null) {
            timings.add(
                Timing.everyTurnEndOpponentItemConsumeed); // 相手が道具を消費したターン終了時
          }
          // 天気
          switch (phaseState.weather.id) {
            case Weather.sunny: // 天気が晴れのとき、毎ターン終了時
              timings.addAll([
                Timing.fireWaterAttackedSunnyRained,
                Timing.everyTurnEndSunny
              ]);
              weatherEffectIDs.add(WeatherEffect.sunnyEnd);
              break;
            case Weather.rainy: // 天気があめのとき、毎ターン終了時
              timings.addAll([
                Timing.everyTurnEndRained,
                Timing.fireWaterAttackedSunnyRained,
                Timing.everyTurnEndRainedWithAbnormal
              ]);
              weatherEffectIDs.add(WeatherEffect.rainyEnd);
              break;
            case Weather.snowy: // 天気がゆきのとき、毎ターン終了時
              timings.addAll([Timing.everyTurnEndSnowy]);
              weatherEffectIDs.add(WeatherEffect.snowyEnd);
              break;
            case Weather.sandStorm: // 天気がすなあらしのとき、毎ターン終了時
              weatherEffectIDs.addAll(
                  [WeatherEffect.sandStormEnd, WeatherEffect.sandStormDamage]);
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
              fieldEffectIDs.addAll(
                  [FieldEffect.grassHeal, FieldEffect.grassyTerrainEnd]);
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
          if (pokemonState != null && !pokemonState.isTerastaling) {
            // テラスタルしていないとき
            timings.add(Timing.everyTurnEndNotTerastaled);
          }
          if (pokemonState != null) {
            for (final ailment in pokemonState.ailmentsIterable) {
              if (ailment.possiblyActive(timing, pokemonState, phaseState)) {
                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] =
                    ailment.turns;
              }
            }
          }
          if (pokemonState != null &&
              pokemonState
                  .ailmentsWhere((e) =>
                      e.id == Ailment.poison || e.id == Ailment.badPoison)
                  .isNotEmpty) {
            // どく/もうどく状態のとき
            timings.add(Timing.poisonDamage);
          }
          if (playerType == PlayerType.me ||
              playerType == PlayerType.opponent) {
            if (pokemonState!
                .ailmentsWhere((e) => e.id <= Ailment.sleep)
                .isEmpty) {
              timings.add(Timing.everyTurnEndNotAbnormal); // 状態異常でない毎ターン終了時
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
      case Timing.afterActionDecision: // 行動決定直後
        {
          timings.addAll(afterActionDecisionTimings);
          attackerTimings.clear();
          defenderTimings.clear();
        }
        break;
      case Timing.beforeMove: // わざ使用前
        {
          timings.clear(); // atacker/defenderに統合するするため削除
          attackerTimings.addAll(beforeMoveAttackerTimings);
          defenderTimings.addAll(beforeMoveDefenderTimings);
          if (playerType == PlayerType.me ||
              playerType == PlayerType.opponent) {
            var attackerState =
                phaseState.getPokemonState(attacker, prevAction);
            var defenderState =
                phaseState.getPokemonState(attacker.opposite, prevAction);
            var replacedMoveType = turnMove.getReplacedMoveType(
                turnMove.move, attackerState, phaseState);
            // 対象のわざがまだ入力されていない場合=type==Type.unknownの場合、
            // すべてのタイプの可能性を考えて候補に入れる
            if (replacedMoveType == PokeType.unknown) {
              defenderTimings.addAll([
                Timing.normalAttacked,
                Timing.greatFireAttacked,
                Timing.greatWaterAttacked,
                Timing.greatElectricAttacked,
                Timing.greatgrassAttacked,
                Timing.greatIceAttacked,
                Timing.greatFightAttacked,
                Timing.greatPoisonAttacked,
                Timing.greatGroundAttacked,
                Timing.greatFlyAttacked,
                Timing.greatPsycoAttacked,
                Timing.greatBugAttacked,
                Timing.greatRockAttacked,
                Timing.greatGhostAttacked,
                Timing.greatDragonAttacked,
                Timing.greatEvilAttacked,
                Timing.greatSteelAttacked,
                Timing.greatFairyAttacked
              ]);
            }
            if (replacedMoveType == PokeType.normal) {
              // ノーマルタイプのわざを受けた時
              defenderTimings.addAll([Timing.normalAttacked]);
            }
            if (PokeTypeEffectiveness.effectiveness(
                    attackerState.currentAbility.id == 113 ||
                        attackerState.currentAbility.id == 299,
                    defenderState.holdingItem?.id == 586,
                    defenderState
                        .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                        .isNotEmpty,
                    replacedMoveType,
                    pokemonState!) ==
                MoveEffectiveness.great) {
              switch (replacedMoveType) {
                case PokeType.fire:
                  defenderTimings.add(Timing.greatFireAttacked);
                  break;
                case PokeType.water:
                  defenderTimings.add(Timing.greatWaterAttacked);
                  break;
                case PokeType.electric:
                  defenderTimings.add(Timing.greatElectricAttacked);
                  break;
                case PokeType.grass:
                  defenderTimings.add(Timing.greatgrassAttacked);
                  break;
                case PokeType.ice:
                  defenderTimings.add(Timing.greatIceAttacked);
                  break;
                case PokeType.fight:
                  defenderTimings.add(Timing.greatFightAttacked);
                  break;
                case PokeType.poison:
                  defenderTimings.add(Timing.greatPoisonAttacked);
                  break;
                case PokeType.ground:
                  defenderTimings.add(Timing.greatGroundAttacked);
                  break;
                case PokeType.fly:
                  defenderTimings.add(Timing.greatFlyAttacked);
                  break;
                case PokeType.psychic:
                  defenderTimings.add(Timing.greatPsycoAttacked);
                  break;
                case PokeType.bug:
                  defenderTimings.add(Timing.greatBugAttacked);
                  break;
                case PokeType.rock:
                  defenderTimings.add(Timing.greatRockAttacked);
                  break;
                case PokeType.ghost:
                  defenderTimings.add(Timing.greatGhostAttacked);
                  break;
                case PokeType.dragon:
                  defenderTimings.add(Timing.greatDragonAttacked);
                  break;
                case PokeType.evil:
                  defenderTimings.add(Timing.greatEvilAttacked);
                  break;
                case PokeType.steel:
                  defenderTimings.add(Timing.greatSteelAttacked);
                  break;
                case PokeType.fairy:
                  defenderTimings.add(Timing.greatFairyAttacked);
                  break;
                default:
                  break;
              }
            }
            // 状態変化
            for (final ailment in attackerState.ailmentsIterable) {
              if (ailment.possiblyActive(timing, attackerState, phaseState)) {
                ailmentEffectIDs[AilmentEffect.getIdFromAilment(ailment)] =
                    ailment.turns;
              }
            }
          }
        }
        break;
      case Timing.afterMove: // わざ使用後
        if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
          timings.clear(); // atacker/defenderに統合するするため削除
          attackerTimings.addAll(afterMoveAttackerTimings);
          defenderTimings.addAll(afterMoveDefenderTimings);
          var attackerState = phaseState.getPokemonState(attacker, prevAction);
          var defenderState =
              phaseState.getPokemonState(attacker.opposite, prevAction);
          var replacedMove =
              turnMove.getReplacedMove(turnMove.move, attackerState);
          var replacedMoveType = turnMove.getReplacedMoveType(
              turnMove.move, attackerState, phaseState);
          if (replacedMove.priority >= 1) {
            // 優先度1以上のわざを受けた時
            defenderTimings.addAll([Timing.priorityMoved]);
          }
          // へんかわざを受けた時
          if (replacedMove.damageClass.id == 1) {
            defenderTimings.addAll([Timing.statused]);
          }
          // こうげきしたとき/うけたとき
          if (replacedMove.damageClass.id >= 2) {
            defenderTimings.addAll([
              Timing.attackedHitted,
              Timing.attackedHittedWithChance,
              Timing.attackedHittedWithBake,
              Timing.pokemonAppearAttacked
            ]);
            attackerTimings
                .addAll([Timing.attackHitted, Timing.defeatOpponentWithAttack]);
            // うのみ状態/まるのみ状態で相手にこうげきされた後
            final unomis = defenderState.buffDebuffs
                .whereByAnyID([BuffDebuff.unomiForm, BuffDebuff.marunomiForm]);
            if (unomis.isNotEmpty) {
              ret.add(TurnEffectAbility(
                  player: attacker.opposite,
                  timing: Timing.afterMove,
                  abilityID: 10000 + unomis.first.id));
            }
            // ノーマルタイプのこうげきをした時
            if (replacedMoveType == PokeType.normal) {
              attackerTimings.addAll([Timing.normalAttackHit]);
            }
            // あくタイプのこうげきを受けた時
            if (replacedMoveType == PokeType.evil) {
              defenderTimings.addAll([Timing.evilAttacked]);
            }
            // みずタイプのこうげきを受けた時
            if (replacedMoveType == PokeType.water) {
              defenderTimings
                  .addAll([Timing.waterAttacked, Timing.fireWaterAttacked]);
            }
            // ほのおタイプのこうげきを受けた時
            if (replacedMoveType == PokeType.fire) {
              defenderTimings
                  .addAll([Timing.fireWaterAttacked, Timing.fireAtaccked]);
            }
            // でんきタイプのこうげきを受けた時
            if (replacedMoveType == PokeType.electric) {
              defenderTimings.addAll([Timing.electricAttacked]);
            }
            // こおりタイプのこうげきを受けた時
            if (replacedMoveType == PokeType.ice) {
              defenderTimings.addAll([Timing.iceAttacked]);
            }
            // こうげきによりひんしになっているとき
            if (defenderState.isFainting) {
              defenderTimings.add(Timing.attackedFainting);
            }
          }
          if (replacedMove.isPowder) {
            defenderTimings.addAll([Timing.powdered]); // こな系のこうげきを受けた時
          }
          if (replacedMove.isBullet) {
            defenderTimings.addAll([Timing.bulleted]); // 弾のこうげきを受けた時
          }
          if (replacedMove.damageClass.id == DamageClass.physical) {
            defenderTimings
                .addAll([Timing.phisycalAttackedHitted]); // ぶつりこうげきを受けた時
          }
          if (replacedMove.damageClass.id == DamageClass.special) {
            defenderTimings
                .addAll([Timing.specialAttackedHitted]); // とくしゅこうげきを受けた時
          }
          if (replacedMove.isDirect &&
              !(replacedMove.isPunch &&
                  attackerState.holdingItem?.id ==
                      1700) && // パンチグローブをつけたパンチわざでない
              attackerState.currentAbility.id != 203) {
            defenderTimings
                .add(Timing.directAttackedWithChance); // 直接攻撃を受けた時(確率)
            defenderTimings.add(Timing.directAttacked); // 直接攻撃を受けた時
            attackerTimings
                .add(Timing.directAttackHitWithChance); // 直接攻撃をあてたとき(確率)
            // 違う性別の相手から直接攻撃を受けた時（確率）
            if (attackerState.sex != defenderState.sex &&
                attackerState.sex != Sex.none) {
              defenderTimings.add(Timing.directAttackedByOppositeSexWithChance);
            }
            // 直接攻撃によりひんしになっているとき
            if (defenderState.isFainting) {
              defenderTimings.add(Timing.directAttackedFainting);
            }
            // まもる系統のわざ相手に直接攻撃したとき
            var findIdx = defenderState.ailmentsIndexWhere(
                (e) => e.id == Ailment.protect && e.extraArg1 != 0);
            if (findIdx >= 0 && attacker == playerType) {
              ret.add(TurnEffectAfterMove(
                  player: playerType,
                  effectID: defenderState.ailments(findIdx).extraArg1));
            }
            // みちづれ状態の相手にこうげきしてひんしにしたとき
            if (defenderState.isFainting &&
                defenderState
                    .ailmentsWhere((e) => e.id == Ailment.destinyBond)
                    .isNotEmpty) {
              ret.add(TurnEffectAfterMove(player: playerType, effectID: 194));
            }
          }
          if (replacedMove.isSound) {
            attackerTimings.add(Timing.soundAttack); // 音技を使ったとき
            defenderTimings.add(Timing.soundAttacked); // 音技を受けた時
          }
          if (replacedMove.isDrain) {
            defenderTimings.add(Timing.drained); // HP吸収わざを受けた時
          }
          if (replacedMove.isDance) {
            defenderTimings.add(Timing.otherDance); // おどり技を受けた時
          }
          if (replacedMoveType == PokeType.normal) {
            // ノーマルタイプのわざを受けた時
            defenderTimings.addAll([Timing.normalAttacked]);
          }
          if (replacedMoveType == PokeType.electric) {
            // でんきタイプのわざを受けた時
            defenderTimings.addAll([Timing.electriced, Timing.electricUse]);
          }
          if (replacedMoveType == PokeType.water) {
            // みずタイプのわざを受けた時
            defenderTimings.addAll([
              Timing.watered,
              Timing.fireWaterAttackedSunnyRained,
              Timing.waterUse
            ]);
          }
          if (replacedMoveType == PokeType.fire) {
            // ほのおタイプのわざを受けた時
            defenderTimings
                .addAll([Timing.fired, Timing.fireWaterAttackedSunnyRained]);
          }
          if (replacedMoveType == PokeType.grass) {
            // くさタイプのわざを受けた時
            defenderTimings.addAll([Timing.grassed]);
          }
          if (replacedMoveType == PokeType.ground) {
            // じめんタイプのわざを受けた時
            defenderTimings.addAll([Timing.grounded]);
          }
          if (PokeTypeEffectiveness.effectiveness(
                  attackerState.currentAbility.id == 113 ||
                      attackerState.currentAbility.id == 299,
                  defenderState.holdingItem?.id == 586,
                  defenderState
                      .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                      .isNotEmpty,
                  replacedMoveType,
                  pokemonState!) ==
              MoveEffectiveness.great) {
            defenderTimings.add(Timing.greatAttacked); // 効果ばつぐんのタイプのこうげきざわを受けた後
            switch (replacedMoveType) {
              case PokeType.fire:
                defenderTimings.add(Timing.greatFireAttacked);
                break;
              case PokeType.water:
                defenderTimings.add(Timing.greatWaterAttacked);
                break;
              case PokeType.electric:
                defenderTimings.add(Timing.greatElectricAttacked);
                break;
              case PokeType.grass:
                defenderTimings.add(Timing.greatgrassAttacked);
                break;
              case PokeType.ice:
                defenderTimings.add(Timing.greatIceAttacked);
                break;
              case PokeType.fight:
                defenderTimings.add(Timing.greatFightAttacked);
                break;
              case PokeType.poison:
                defenderTimings.add(Timing.greatPoisonAttacked);
                break;
              case PokeType.ground:
                defenderTimings.add(Timing.greatGroundAttacked);
                break;
              case PokeType.fly:
                defenderTimings.add(Timing.greatFlyAttacked);
                break;
              case PokeType.psychic:
                defenderTimings.add(Timing.greatPsycoAttacked);
                break;
              case PokeType.bug:
                defenderTimings.add(Timing.greatBugAttacked);
                break;
              case PokeType.rock:
                defenderTimings.add(Timing.greatRockAttacked);
                break;
              case PokeType.ghost:
                defenderTimings.add(Timing.greatGhostAttacked);
                break;
              case PokeType.dragon:
                defenderTimings.add(Timing.greatDragonAttacked);
                break;
              case PokeType.evil:
                defenderTimings.add(Timing.greatEvilAttacked);
                break;
              case PokeType.steel:
                defenderTimings.add(Timing.greatSteelAttacked);
                break;
              case PokeType.fairy:
                defenderTimings.add(Timing.greatFairyAttacked);
                break;
              default:
                break;
            }
          } else {
            defenderTimings
                .add(Timing.notGreatAttacked); // 効果ばつぐん以外のタイプのこうげきざわを受けた時
          }
          if (replacedMoveType == PokeType.ground) {
            if (replacedMove.id != 28 && replacedMove.id != 614) {
              // すなかけ/サウザンアローではない
              defenderTimings.add(Timing
                  .groundFieldEffected); // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
            }
          }
          // とくせいがおどりこの場合
          if (phaseState
                      .getPokemonState(PlayerType.me, prevAction)
                      .currentAbility
                      .id ==
                  216 ||
              phaseState
                      .getPokemonState(PlayerType.opponent, prevAction)
                      .currentAbility
                      .id ==
                  216) {
            attackerTimings.addAll(defenderTimings);
            defenderTimings = attackerTimings;
          }
        }
        break;
      case Timing.afterTerastal: // テラスタル後
        {
          //timings.clear();
          attackerTimings.clear();
          defenderTimings.clear();
          if (playerType == PlayerType.me ||
              playerType == PlayerType.opponent) {
            bool isMe = playerType == PlayerType.me;
            bool isTerastal = pokemonState!.isTerastaling &&
                (isMe
                    ? !currentTurn.initialOwnHasTerastal
                    : !currentTurn.initialOpponentHasTerastal);

            if (isTerastal && pokemonState.currentAbility.id == 303) {
              ret.add(TurnEffectAbility(
                  player: playerType, timing: timing, abilityID: 303));
            }
          }
        }
        break;
      default:
        return [];
    }

    if (playerType == PlayerType.me || playerType == PlayerType.opponent) {
      if (effectType == EffectType.ability) {
        if (pokemonState!.currentAbility.id != 0) {
          // とくせいが確定している場合
          if (timings.contains(pokemonState.currentAbility.timing)) {
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
          // わざ使用後に発動する効果
          if (attacker == playerType &&
                  attackerTimings
                      .contains(pokemonState.currentAbility.timing) ||
              attacker != playerType &&
                  defenderTimings
                      .contains(pokemonState.currentAbility.timing)) {
            retAbilityIDs.add(pokemonState.currentAbility.id);
          }
        } else {
          // とくせいが確定していない場合
          for (final ability in pokemonState.possibleAbilities) {
            if (timings.contains(ability.timing)) {
              retAbilityIDs.add(ability.id);
            }
            // わざ使用後に発動する効果
            if (attacker == playerType &&
                    attackerTimings.contains(ability.timing) ||
                attacker != playerType &&
                    defenderTimings.contains(ability.timing)) {
              retAbilityIDs.add(ability.id);
            }
          }
        }
        if (playerType == PlayerType.opponent && phaseState.canAnyZoroark) {
          retAbilityIDs.add(149); // イリュージョン追加
        }
        final abilityIDs = retAbilityIDs.toSet();
        for (final abilityID in abilityIDs) {
          ret.add(TurnEffectAbility(
              player: playerType, timing: timing, abilityID: abilityID));
        }
      }
      if (effectType == EffectType.individualField) {
        for (var e in indiFieldEffectIDs) {
          var adding = TurnEffectIndividualField(
              player: playerType, timing: timing, indiFieldEffectID: e);
          if (adding.indiFieldEffectID == IndiFieldEffect.trickRoomEnd) {
            // 各々の場だが効果としては両フィールドのもの
            adding.playerType = PlayerType.entireField;
            if (ret
                .where((element) =>
                    element.effectType == adding.effectType &&
                    element.playerType == adding.playerType &&
                    element.timing == adding.timing &&
                    (element as TurnEffectIndividualField).indiFieldEffectID ==
                        adding.indiFieldEffectID)
                .isNotEmpty) {
              ret.add(adding);
            }
          } else {
            ret.add(adding);
          }
        }
      }
      if (effectType == EffectType.ailment) {
        for (var e in ailmentEffectIDs.entries) {
          ret.add(TurnEffectAilment(
              player: playerType, timing: timing, ailmentEffectID: e.key)
            ..extraArg1 = e.value);
        }
      }
      if (effectType == EffectType.item) {
        if (pokemonState!.holdingItem != null) {
          if (pokemonState.holdingItem!.id != 0) {
            // もちものが確定している場合
            if (timings.contains(pokemonState.holdingItem!.timing)) {
              ret.add(TurnEffectItem(
                  player: playerType,
                  timing: timing,
                  itemID: pokemonState.holdingItem!.id));
            }
            // わざ使用後に発動する効果
            if (attacker == playerType &&
                    attackerTimings
                        .contains(pokemonState.holdingItem!.timing) ||
                attacker != playerType &&
                    defenderTimings
                        .contains(pokemonState.holdingItem!.timing)) {
              ret.add(TurnEffectItem(
                  player: playerType,
                  timing: timing,
                  itemID: pokemonState.holdingItem!.id));
            }
          } else {
            // もちものが確定していない場合
            var allItems = [for (final item in pokeData.items.values) item];
            for (final item in pokemonState.impossibleItems) {
              allItems.removeWhere((e) => e.id == item.id);
            }
            for (final item in allItems) {
              if (timings.contains(item.timing)) {
                ret.add(TurnEffectItem(
                    player: playerType, timing: timing, itemID: item.id));
              }
              // わざ使用後に発動する効果
              if (attacker == playerType &&
                      attackerTimings.contains(item.timing) ||
                  attacker != playerType &&
                      defenderTimings.contains(item.timing)) {
                ret.add(TurnEffectItem(
                    player: playerType, timing: timing, itemID: item.id));
              }
            }
          }
        }
      }
    }

    if (playerType == PlayerType.entireField) {
      for (var e in weatherEffectIDs) {
        ret.add(TurnEffectWeather(timing: timing, weatherEffectID: e));
      }
      for (var e in fieldEffectIDs) {
        ret.add(TurnEffectField(timing: timing, fieldEffectID: e));
      }
    }

    // argの自動セット
    var myState = playerType != PlayerType.opponent
        ? phaseState.getPokemonState(PlayerType.me, prevAction)
        : phaseState.getPokemonState(PlayerType.opponent, prevAction);
    var yourState = playerType != PlayerType.opponent
        ? phaseState.getPokemonState(PlayerType.opponent, prevAction)
        : phaseState.getPokemonState(PlayerType.me, prevAction);
    for (var effect in ret) {
      effect.timing = timing;
      effect.setAutoArgs(myState, yourState, phaseState, prevAction);
    }

    return ret;
  }

  /// extraArg等以外同じ、ほぼ同じかどうか
  /// ```
  /// allowTimingDiff: タイミングが異なっていても同じとみなすかどうか
  /// isChangeMe: 交代わざで「あなた」側が交代したかどうか
  ///   (trueの場合、タイミングがafterMoveのものは、allowTimingDiffがtrueでも異なる効果とみなす)
  /// ```
  bool nearEqual(
    TurnEffect t, {
    bool allowTimingDiff = false,
    bool isChangeMe = false,
    bool isChangeOpponent = false,
  });

  /// 表示名
  String displayName({
    required AppLocalizations loc,
  });

  /// 行動主
  PlayerType get playerType;
  set playerType(PlayerType type);

  /// 発生タイミング
  Timing get timing;
  set timing(Timing t);

  /// 効果に対応して、argsを自動でセット
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  void setAutoArgs(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffectAction? prevAction,
  );

  /// SQLに保存された文字列からTurnEffectをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1~split3: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
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
      case EffectType.gameset:
        return TurnEffectGameset.deserialize(
          str,
          split1,
          version: version,
        );
    }
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1~split3: 区切り文字
  /// ```
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
