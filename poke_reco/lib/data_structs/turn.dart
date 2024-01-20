import 'dart:collection';

import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 自身・相手の行動(timing==Timing.action)をそれぞれ1つずつ含んだリスト
class PhaseList extends ListBase<TurnEffect> {
  // https://stackoverflow.com/questions/16247045/how-do-i-extend-a-list-in-dart
  final List<TurnEffect> l = [];
  
  PhaseList() {
    TurnMove ownAction = TurnMove()
      ..playerType = PlayerType.me
      ..type = TurnMoveType.move;
    TurnMove opponentAction = TurnMove()
      ..playerType = PlayerType.opponent
      ..type = TurnMoveType.move;
    l.addAll([
      TurnEffect()
        ..playerType = PlayerType.me
        ..timing = Timing.action
        ..effectType = EffectType.move
        ..move = ownAction,
      TurnEffect()
        ..playerType = PlayerType.opponent
        ..timing = Timing.action
        ..effectType = EffectType.move
        ..move = opponentAction
    ]);
  }

  @override
  set length(int newLength) { l.length = newLength; }
  @override
  int get length => l.length;
  @override
  TurnEffect operator [](int index) => l[index];
  @override
  void operator []=(int index, TurnEffect value) { l[index] = value; }
  
  PhaseList copyWith() => PhaseList()..l.addAll(l);

  @override
  void add(TurnEffect element) {
    if (element.timing == Timing.action) {
      assert(
        element.playerType == PlayerType.me || element.playerType == PlayerType.opponent,
        'action effect\'s player must be me or opponent',
      );
      // 自身・相手の行動は1つずつまで
      assert(
        l.where((e) => e.timing == Timing.action && e.playerType == element.playerType).isEmpty,
        'only 1 action effect for each player is allowed in 1 turn',
      );
    }
    super.add(element);
  }

  TurnEffect get ownAction => l.where((element) => element.timing == Timing.action && element.playerType == PlayerType.me).first;
  TurnEffect get opponentAction => l.where((element) => element.timing == Timing.action && element.playerType == PlayerType.opponent).first;
}

class Turn {
  PhaseState _initialState = PhaseState();
  PhaseList phases = PhaseList();
  PhaseState _endingState = PhaseState();
  List<TurnEffect> noAutoAddEffect = [];

  PokemonState get initialOwnPokemonState => _initialState.getPokemonState(PlayerType.me, null);
  PokemonState get initialOpponentPokemonState => _initialState.getPokemonState(PlayerType.opponent, null);
  List<IndividualField> get initialOwnIndiField => _initialState.getIndiFields(PlayerType.me);
  List<IndividualField> get initialOpponentIndiField => _initialState.getIndiFields(PlayerType.opponent);
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
    return player == PlayerType.me ? _initialState.lastExitedStates[0] : _initialState.lastExitedStates[1];
  }


  Turn copyWith() =>
    Turn()
    .._initialState = _initialState.copyWith()
    ..phases = phases.copyWith()
    .._endingState = _endingState.copyWith()
    ..noAutoAddEffect = [
      for (final effect in noAutoAddEffect)
      effect.copyWith()
    ];

  PhaseState copyInitialState() {
    return _initialState.copyWith();
  }

  bool isValid() {
    int actionCount = 0;
    int validCount = 0;
    for (final phase in phases) {
      if (phase.timing == Timing.action ||
          phase.timing == Timing.changeFaintingPokemon
      ) {
        actionCount++;
        if (phase.isValid()) validCount++;
      }
    }
    return actionCount == validCount && actionCount >= 2;
  }

  void setInitialState(PhaseState state) {
    _initialState = state.copyWith();
  }

  // とある時点(フェーズ)での状態を取得
  PhaseState getProcessedStates(
    int phaseIdx, Party ownParty, Party opponentParty, AppLocalizations loc,)
  {
    PhaseState ret = copyInitialState();
    int continousCount = 0;
    TurnEffect? lastAction;

    for (int i = 0; i < phaseIdx+1; i++) {
      final effect = phases[i];
      if (effect.isAdding) continue;
      if (effect.timing == Timing.continuousMove) {
        lastAction = effect;
        continousCount++;
      }
      else if (effect.timing == Timing.action) {
        lastAction = effect;
        continousCount = 0;
      }
      effect.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me, effect.timing == Timing.afterMove ? lastAction : null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent, effect.timing == Timing.afterMove ? lastAction : null),
        ret, lastAction, continousCount, loc: loc,
      );
    }
    return ret;
  }

  // ターンの最終状態(_endingState)を更新する
  // phasesに入っている各処理のうち有効な値が入っているphaseのみ処理を適用する
  // _endingStateのコピーを返す
  PhaseState updateEndingState(Party ownParty, Party opponentParty, AppLocalizations loc,) {
    _endingState = _initialState.copyWith();
    int continousCount = 0;
    TurnEffect? lastAction;

    for (final phase in phases) {
      if (phase.isAdding) continue;   // TODO
      if (!phase.isValid()) continue;
      if (phase.timing == Timing.continuousMove) {
        lastAction = phase;
        continousCount++;
      }
      else if (phase.timing == Timing.action) {
        lastAction = phase;
        continousCount = 0;
      }
      phase.processEffect(
        ownParty,
        _endingState.getPokemonState(PlayerType.me, phase.timing == Timing.afterMove ? lastAction : null),
        opponentParty,
        _endingState.getPokemonState(PlayerType.opponent, phase.timing == Timing.afterMove ? lastAction : null),
        _endingState, lastAction, continousCount, loc: loc,
      );
    }
    return _endingState.copyWith();
  }

  // 初期状態のみ残してクリア
  void clearWithInitialState() {
    phases = PhaseList();
    _endingState = PhaseState();
    noAutoAddEffect = [];
  }

  // SQLに保存された文字列からTurnをパース
  static Turn deserialize(
    dynamic str, String split1, String split2,
    String split3, String split4, String split5,
    String split6, String split7, {int version = -1})  // -1は最新バージョン
  {
    Turn ret = Turn();
    final List turnElements = str.split(split1);
    // _initialState
    ret._initialState = PhaseState.deserialize(turnElements.removeAt(0), split2, split3, split4, split5, split6, split7);
    // phases
    var turnEffects = turnElements.removeAt(0).split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5, version: version));
    }
    // _endingState
    ret._endingState = PhaseState.deserialize(turnElements.removeAt(0), split2, split3, split4, split5, split6, split7);
    // noAutoAddEffect
    var effects = turnElements.removeAt(0).split(split2);
    ret.noAutoAddEffect.clear();
    for (final effect in effects) {
      if (effect == '') break;
      ret.noAutoAddEffect.add(TurnEffect.deserialize(effect, split3, split4, split5, version: version));
    }

    return ret;
  }

  // SQL保存用の文字列に変換
  String serialize(
    String split1, String split2, String split3, String split4,
    String split5, String split6, String split7
  ) {
    String ret = '';
    // _initialState
    ret += _initialState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // phases
    for (final turnEffect in phases) {
      ret += turnEffect.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // _endingState
    ret += _endingState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // noAutoAddEffect
    for (final effect in noAutoAddEffect) {
      ret += effect.serialize(split3, split4, split5);
      ret += split2;
    }

    return ret;
  }
}
