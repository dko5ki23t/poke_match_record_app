import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Turn {
  PhaseState _initialState = PhaseState();
  List<TurnEffect> phases = [];
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
    ..phases = [...phases]
    .._endingState = _endingState.copyWith()
    ..noAutoAddEffect = [
      for (final effect in noAutoAddEffect)
      effect.copyWith()
    ];

  PhaseState copyInitialState(Party ownParty, Party opponentParty,) {
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

  void setInitialState(PhaseState state, Party ownParty, Party opponentParty,) {
    _initialState = state.copyWith();
  }

  // とある時点(フェーズ)での状態を取得
  PhaseState getProcessedStates(
    int phaseIdx, Party ownParty, Party opponentParty, AppLocalizations loc,)
  {
    PhaseState ret = copyInitialState(ownParty, opponentParty,);
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

  // 初期状態のみ残してクリア
  void clearWithInitialState() {
    phases = [];
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
