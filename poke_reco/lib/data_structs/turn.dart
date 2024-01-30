import 'dart:collection';

import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/tool.dart';

// 自身・相手の行動(timing==Timing.action)をそれぞれ1つずつ含んだリスト
class PhaseList extends ListBase<TurnEffect> implements Copyable, Equatable {
  // https://stackoverflow.com/questions/16247045/how-do-i-extend-a-list-in-dart
  final List<TurnEffect> l = [];

  @override
  List<Object?> get props => [l];

  PhaseList() {
    l.addAll([
      TurnEffectAction(player: PlayerType.me)..type = TurnMoveType.move,
      TurnEffectAction(player: PlayerType.opponent)..type = TurnMoveType.move,
    ]);
  }

  @override
  set length(int newLength) {
    l.length = newLength;
  }

  @override
  int get length => l.length;
  @override
  TurnEffect operator [](int index) => l[index];
  @override
  void operator []=(int index, TurnEffect value) {
    l[index] = value;
  }

  @override
  PhaseList copy() => PhaseList()..l.addAll(l);

  void checkAdd(TurnEffect element) {
    if (element is TurnEffectAction ||
        element is TurnEffectChangeFaintingPokemon) {
      assert(
        element.playerType == PlayerType.me ||
            element.playerType == PlayerType.opponent,
        'action effect\'s player must be me or opponent',
      );
      // 自身・相手の行動は1つずつまで
      assert(
        l
            .where((e) =>
                (e.runtimeType == element.runtimeType) &&
                e.playerType == element.playerType)
            .isEmpty,
        'only 1 action effect for each player is allowed in 1 turn',
      );
    }
  }

  @override
  void add(TurnEffect element) {
    checkAdd(element);
    l.add(element);
  }

  @override
  void insert(int index, TurnEffect element) {
    checkAdd(element);
    l.insert(index, element);
  }

  void addNextToValid(TurnEffect element) {
    checkAdd(element);
    int insertIdx = l.lastIndexWhere((element) => element.isValid());
    l.insert(insertIdx, element);
  }

  bool isExistAction(PlayerType playerType) => l
      .where((e) =>
          (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
          e.playerType == playerType)
      .isNotEmpty;
  TurnEffect getLatestAction(PlayerType playerType) => l
      .where((e) =>
          (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
          e.playerType == playerType)
      .last;
  int getLatestActionIndex(PlayerType playerType) => l.lastIndexWhere((e) =>
      (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
      e.playerType == playerType);
  PlayerType? get firstActionPlayer {
    // 有効なactionで先に行動しているプレイヤーを返す
    int ownPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == PlayerType.me);
    int opponentPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == PlayerType.opponent);
    //どちらも(存在しない/無効)
    if ((ownPlayerActionIndex < 0 || !l[ownPlayerActionIndex].isValid()) &&
        (opponentPlayerActionIndex < 0 ||
            !l[opponentPlayerActionIndex].isValid())) return null;
    // 片方の行動のみ(存在かつ有効)
    if (ownPlayerActionIndex >= 0 &&
        l[ownPlayerActionIndex].isValid() &&
        (opponentPlayerActionIndex < 0 ||
            !l[opponentPlayerActionIndex].isValid())) return PlayerType.me;
    if (opponentPlayerActionIndex >= 0 &&
        l[opponentPlayerActionIndex].isValid() &&
        (ownPlayerActionIndex < 0 || !l[ownPlayerActionIndex].isValid())) {
      return PlayerType.opponent;
    }
    // 両行動ともに(存在かつ有効)
    if (ownPlayerActionIndex > opponentPlayerActionIndex) {
      return PlayerType.me;
    } else {
      return PlayerType.opponent;
    }
  }

  // 指定したプレイヤーの行動順を先にする
  void setActionOrderFirst(PlayerType playerType) {
    // 行動がない
    assert(
      isExistAction(PlayerType.me) && isExistAction(PlayerType.opponent),
      'there are no own action or opponent action',
    );
    int myPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == playerType);
    int yourPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == playerType.opposite);
    // 対象の行動が後にあるなら
    if (myPlayerActionIndex > yourPlayerActionIndex) {
      // TODO:今後もっと複雑になる
      final removed = l.removeAt(yourPlayerActionIndex);
      l.add(removed);
    }
  }
}

class Turn extends Equatable implements Copyable {
  PhaseState _initialState = PhaseState();
  PhaseList phases = PhaseList();
  PhaseState _endingState = PhaseState();
  List<TurnEffect> noAutoAddEffect = [];

  @override
  List<Object?> get props => [
        _initialState,
        phases,
        _endingState,
        noAutoAddEffect,
      ];

  PokemonState get initialOwnPokemonState =>
      _initialState.getPokemonState(PlayerType.me, null);
  PokemonState get initialOpponentPokemonState =>
      _initialState.getPokemonState(PlayerType.opponent, null);
  List<IndividualField> get initialOwnIndiField =>
      _initialState.getIndiFields(PlayerType.me);
  List<IndividualField> get initialOpponentIndiField =>
      _initialState.getIndiFields(PlayerType.opponent);
  bool get initialOwnHasTerastal => _initialState.hasOwnTerastal;
  bool get initialOpponentHasTerastal => _initialState.hasOpponentTerastal;

  int getInitialPokemonIndex(PlayerType player) {
    return _initialState.getPokemonIndex(player, null);
  }

  void setInitialPokemonIndex(PlayerType player, int index) {
    _initialState.setPokemonIndex(player, index);
  }

  List<PokemonState> getInitialPokemonStates(PlayerType player) {
    return _initialState.getPokemonStates(player);
  }

  List<PokemonState> getInitialLastExitedStates(PlayerType player) {
    return player == PlayerType.me
        ? _initialState.lastExitedStates[0]
        : _initialState.lastExitedStates[1];
  }

  @override
  Turn copy() => Turn()
    .._initialState = _initialState.copy()
    ..phases = phases.copy()
    .._endingState = _endingState.copy()
    ..noAutoAddEffect = [for (final effect in noAutoAddEffect) effect.copy()];

  PhaseState copyInitialState() {
    return _initialState.copy();
  }

  bool isValid() {
    int actionCount = 0;
    int validCount = 0;
    for (final phase in phases) {
      if (phase is TurnEffectAction ||
          phase is TurnEffectChangeFaintingPokemon) {
        actionCount++;
        if (phase.isValid()) validCount++;
      }
    }
    return actionCount == validCount && actionCount >= 2;
  }

  bool get isMyWin => _endingState.isMyWin;
  bool get isYourWin => _endingState.isYourWin;
  bool get isGameSet => isMyWin || isYourWin;

  void setInitialState(PhaseState state) {
    _initialState = state.copy();
  }

  // とある時点(フェーズ)での状態を取得
  PhaseState getProcessedStates(
    int phaseIdx,
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    PhaseState ret = copyInitialState();
    int continousCount = 0;
    TurnEffect? lastAction;

    for (int i = 0; i < phaseIdx + 1; i++) {
      final effect = phases[i];
      //if (effect.isAdding) continue;
      //if (effect.timing == Timing.continuousMove) {
      //  lastAction = effect;
      //  continousCount++;
      //} else if (effect.timing == Timing.action) {
      //  lastAction = effect;
      //  continousCount = 0;
      //}
      if (effect is TurnEffectAction) lastAction = effect;
      effect.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me,
            /*effect.timing == Timing.afterMove ? lastAction :*/ null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent,
            /*effect.timing == Timing.afterMove ? lastAction :*/ null),
        ret,
        lastAction,
        continousCount,
        loc: loc,
      );
    }
    return ret;
  }

  // ターンの最終状態(_endingState)を更新する
  // phasesに入っている各処理のうち有効な値が入っているphaseのみ処理を適用する
  // _endingStateのコピーを返す
  PhaseState updateEndingState(
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    _endingState = _initialState.copy();
    int continousCount = 0;
    TurnEffect? lastAction;
    PlayerType? needChangeFaintingPlayer;
    Map<PlayerType, bool> alreadyActioned = {
      PlayerType.me: false,
      PlayerType.opponent: false,
    };

    int i = 0;
    while (i < phases.length) {
      final phase = phases[i];
//      if (phase.isAdding) {
//        i++;
//        continue; // TODO
//      }
      if (!phase.isValid()) {
        i++;
        continue;
      }
      //if (phase.timing == Timing.continuousMove) {
      //  lastAction = phase;
      //  continousCount++;
      //} else if (phase.timing == Timing.action) {
      //  lastAction = phase;
      //  continousCount = 0;
      //}
      if (phase is TurnEffectAction) lastAction = phase;
      phase.processEffect(
        ownParty,
        _endingState.getPokemonState(PlayerType.me,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        opponentParty,
        _endingState.getPokemonState(PlayerType.opponent,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        _endingState,
        lastAction,
        continousCount,
        loc: loc,
      );
      if (phase is TurnEffectAction) {
        alreadyActioned[phase.playerType] = true;
      }
      // ポケモンがひんしになっている場合、無ければひんし交代phaseを追加
      final ownState = _endingState.getPokemonState(PlayerType.me, null);
      final opponentState =
          _endingState.getPokemonState(PlayerType.opponent, null);
      if (ownState.remainHP <= 0) {
        ownState.remainHP = 0;
        ownState.isFainting = true;
        _endingState.incFaintingCount(PlayerType.me, 1);
        needChangeFaintingPlayer = PlayerType.me;
      } else {
        ownState.isFainting = false;
      }
      if (opponentState.remainHPPercent <= 0) {
        opponentState.remainHPPercent = 0;
        opponentState.isFainting = true;
        _endingState.incFaintingCount(PlayerType.opponent, 1);
        needChangeFaintingPlayer = PlayerType.opponent;
      } else {
        opponentState.isFainting = false;
      }
      if (needChangeFaintingPlayer != null) {
        if (phase is! TurnEffectChangeFaintingPokemon) {
          // ひんし対象がまだ行動していないとき
          if (!alreadyActioned[needChangeFaintingPlayer]!) {
            final target =
                phases.getLatestActionIndex(needChangeFaintingPlayer);
            // TODO
            phases[target] = TurnEffectChangeFaintingPokemon(
                player: needChangeFaintingPlayer, timing: Timing.afterMove);
          }
          // ひんし対象が行動済みのとき
          else {
            if (i == phases.length - 1 ||
                phases[i + 1] is! TurnEffectChangeFaintingPokemon) {
              phases.insert(
                  i + 1,
                  // TODO
                  TurnEffectChangeFaintingPokemon(
                      player: needChangeFaintingPlayer,
                      timing: Timing.afterMove));
            }
          }
          needChangeFaintingPlayer = null;
        }
      }
      i++;
    }
    return _endingState.copy();
  }

  // 初期状態のみ残してクリア
  void clearWithInitialState() {
    phases = PhaseList();
    _endingState = PhaseState();
    noAutoAddEffect = [];
  }

  // SQLに保存された文字列からTurnをパース
  static Turn deserialize(dynamic str, String split1, String split2,
      String split3, String split4, String split5, String split6, String split7,
      {int version = -1}) // -1は最新バージョン
  {
    Turn ret = Turn();
    final List turnElements = str.split(split1);
    // _initialState
    ret._initialState = PhaseState.deserialize(turnElements.removeAt(0), split2,
        split3, split4, split5, split6, split7);
    // phases
    var turnEffects = turnElements.removeAt(0).split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5,
          version: version));
    }
    // _endingState
    ret._endingState = PhaseState.deserialize(turnElements.removeAt(0), split2,
        split3, split4, split5, split6, split7);
    // noAutoAddEffect
    var effects = turnElements.removeAt(0).split(split2);
    ret.noAutoAddEffect.clear();
    for (final effect in effects) {
      if (effect == '') break;
      ret.noAutoAddEffect.add(TurnEffect.deserialize(
          effect, split3, split4, split5,
          version: version));
    }

    return ret;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3, String split4,
      String split5, String split6, String split7) {
    String ret = '';
    // _initialState
    ret +=
        _initialState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // phases
    for (final turnEffect in phases) {
      ret += turnEffect.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // _endingState
    ret +=
        _endingState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // noAutoAddEffect
    for (final effect in noAutoAddEffect) {
      ret += effect.serialize(split3, split4, split5);
      ret += split2;
    }

    return ret;
  }
}
