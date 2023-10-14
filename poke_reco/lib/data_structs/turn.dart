import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';

class Turn {
  int initialOwnPokemonIndex = 0;         // 0は無効値
  int initialOpponentPokemonIndex = 0;    // 0は無効値
  List<PokemonState> initialOwnPokemonStates = [];
  List<PokemonState> initialOpponentPokemonStates = [];
  Weather initialWeather = Weather(0);
  Field initialField = Field(0);
  List<TurnEffect> phases = [];

  PokemonState get initialOwnPokemonState => initialOwnPokemonStates[initialOwnPokemonIndex-1];
  PokemonState get initialOpponentPokemonState => initialOpponentPokemonStates[initialOpponentPokemonIndex-1];

  Turn copyWith() =>
    Turn()
    ..initialOwnPokemonIndex = initialOwnPokemonIndex
    ..initialOpponentPokemonIndex = initialOpponentPokemonIndex
    ..initialOwnPokemonStates = [
      for (final state in initialOwnPokemonStates)
      state.copyWith()
    ]
    ..initialOpponentPokemonStates = [
      for (final state in initialOpponentPokemonStates)
      state.copyWith()
    ]
    ..initialWeather = initialWeather.copyWith()
    ..initialField = initialField.copyWith()
    ..phases = [
      for (final phase in phases)
      phase.copyWith()
    ];

  PhaseState copyInitialState() {
    var ret = PhaseState()
    ..ownPokemonIndex = initialOwnPokemonIndex
    ..opponentPokemonIndex = initialOpponentPokemonIndex
    ..ownPokemonStates = [
      for (final state in initialOwnPokemonStates)
      state.copyWith()
    ]
    ..opponentPokemonStates = [
      for (final state in initialOpponentPokemonStates)
      state.copyWith()
    ];
    ret.forceSetWeather(initialWeather.copyWith());
    ret.forceSetField(initialField.copyWith());
    return ret;
  }

  bool isValid() {
    int actionCount = 0;
    int validCount = 0;
    for (final phase in phases) {
      if (phase.timing.id == AbilityTiming.action ||
          phase.timing.id == AbilityTiming.changeFaintingPokemon
      ) {
        actionCount++;
        if (phase.isValid()) validCount++;
      }
    }
    return actionCount == validCount && actionCount >= 2;
  }

  void setInitialState(PhaseState state) {
    initialOwnPokemonIndex = state.ownPokemonIndex;
    initialOpponentPokemonIndex = state.opponentPokemonIndex;
    initialOwnPokemonStates = [
      for (final s in state.ownPokemonStates)
      s.copyWith()
    ];
    initialOpponentPokemonStates = [
      for (final s in state.opponentPokemonStates)
      s.copyWith()
    ];
    // ひるみ状態は自動的に解除
    var idx = initialOwnPokemonStates[initialOwnPokemonIndex-1].ailmentsIndexWhere((element) => element.id == Ailment.flinch);
    if (idx >= 0) initialOwnPokemonStates[initialOwnPokemonIndex-1].ailmentsRemoveAt(idx);
    idx = initialOpponentPokemonStates[initialOpponentPokemonIndex-1].ailmentsIndexWhere((element) => element.id == Ailment.flinch);
    if (idx >= 0) initialOpponentPokemonStates[initialOpponentPokemonIndex-1].ailmentsRemoveAt(idx);
    initialWeather = state.weather;
    initialField = state.field;
  }

  // とある時点(フェーズ)での状態を取得
  PhaseState getProcessedStates(
    int phaseIdx, Party ownParty, Party opponentParty)
  {
    PhaseState ret = copyInitialState();
    int continousCount = 0;
    TurnEffect? lastAction;

    for (int i = 0; i < phaseIdx+1; i++) {
      final effect = phases[i];
      if (effect.isAdding) continue;
      if (effect.timing.id == AbilityTiming.continuousMove) {
        lastAction = effect;
        continousCount++;
      }
      else if (effect.timing.id == AbilityTiming.action) {
        lastAction = effect;
        continousCount = 0;
      }
      effect.processEffect(
        ownParty,
        ret.ownPokemonState,
        opponentParty,
        ret.opponentPokemonState,
        ret, lastAction, continousCount,
      );
    }
    return ret;
  }

  // SQLに保存された文字列からTurnをパース
  static Turn deserialize(
    dynamic str, String split1, String split2,
    String split3, String split4, String split5,)
  {
    Turn ret = Turn();
    final turnElements = str.split(split1);
    // initialOwnPokemonIndex
    ret.initialOwnPokemonIndex = int.parse(turnElements[0]);
    // initialOpponentPokemonIndex
    ret.initialOpponentPokemonIndex = int.parse(turnElements[1]);
    // initialOwnPokemonStates
    var states = turnElements[2].split(split2);
    for (final state in states) {
      if (state == '') break;
      ret.initialOwnPokemonStates.add(PokemonState.deserialize(state, split3, split4, split5));
    }
    // initialOpponentPokemonStates
    states = turnElements[3].split(split2);
    for (final state in states) {
      if (state == '') break;
      ret.initialOpponentPokemonStates.add(PokemonState.deserialize(state, split3, split4, split5));
    }
    // initialWeather
    ret.initialWeather = Weather.deserialize(turnElements[4], split2);
    // initialField
    ret.initialField = Field.deserialize(turnElements[5], split2);
    // phases
    var turnEffects = turnElements[6].split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5));
    }

    return ret;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3, String split4, String split5) {
    String ret = '';
    // initialOwnPokemonIndex
    ret += initialOwnPokemonIndex.toString();
    ret += split1;
    // initialOpponentPokemonIndex
    ret += initialOpponentPokemonIndex.toString();
    ret += split1;
    // initialOwnPokemonStates
    for (final state in initialOwnPokemonStates) {
      ret += state.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // initialOpponentPokemonStates
    for (final state in initialOpponentPokemonStates) {
      ret += state.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // initialWeather
    ret += initialWeather.serialize(split2);
    ret += split1;
    // initialField
    ret += initialField.serialize(split2);
    ret += split1;
    // phases
    for (final turnEffect in phases) {
      ret += turnEffect.serialize(split3, split4, split5);
      ret += split2;
    }

    return ret;
  }
}
