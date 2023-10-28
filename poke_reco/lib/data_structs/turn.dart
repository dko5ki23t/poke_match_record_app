import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';

class Turn {
  List<int> _initialPokemonIndexes = [0, 0];    // 0は無効値
  List<List<PokemonState>> _initialPokemonStates = [[], []];
  List<List<IndividualField>> _initialIndiFields = [[], []];
  Weather initialWeather = Weather(0);
  Field initialField = Field(0);
  List<bool> _initialHasTerastal = [false, false];
  List<TurnEffect> phases = [];

  PokemonState get initialOwnPokemonState => _initialPokemonStates[0][_initialPokemonIndexes[0]-1];
  PokemonState get initialOpponentPokemonState => _initialPokemonStates[1][_initialPokemonIndexes[1]-1];
  List<IndividualField> get initialOwnIndiField => _initialIndiFields[0];
  List<IndividualField> get initialOpponentIndiField => _initialIndiFields[1];
  bool get initialOwnHasTerastal => _initialHasTerastal[0];
  bool get initialOpponentHasTerastal => _initialHasTerastal[1];

  int getInitialPokemonIndex(PlayerType player) {
    return player.id == PlayerType.me ? _initialPokemonIndexes[0] : _initialPokemonIndexes[1];
  }

  void setInitialPokemonIndex(PlayerType player, int index) {
    if (player.id == PlayerType.me) {
      _initialPokemonIndexes[0] = index;
    }
    else {
      _initialPokemonIndexes[1] = index;
    }
  }

  List<PokemonState> getInitialPokemonStates(PlayerType player) {
    return player.id == PlayerType.me ? _initialPokemonStates[0] : _initialPokemonStates[1];
  }


  Turn copyWith() =>
    Turn()
    .._initialPokemonIndexes = [..._initialPokemonIndexes]
    .._initialPokemonStates[0] = [
      for (final state in _initialPokemonStates[0])
      state.copyWith()
    ]
    .._initialPokemonStates[1] = [
      for (final state in _initialPokemonStates[1])
      state.copyWith()
    ]
    .._initialIndiFields[0] = [
      for (final field in _initialIndiFields[0])
      field.copyWith()
    ]
    .._initialIndiFields[1] = [
      for (final field in _initialIndiFields[1])
      field.copyWith()
    ]
    ..initialWeather = initialWeather.copyWith()
    ..initialField = initialField.copyWith()
    .._initialHasTerastal = [..._initialHasTerastal]
    ..phases = [
      for (final phase in phases)
      phase.copyWith()
    ];

  PhaseState copyInitialState() {
    var ret = PhaseState()
    ..setPokemonIndex(PlayerType(PlayerType.me), _initialPokemonIndexes[0])
    ..setPokemonIndex(PlayerType(PlayerType.opponent), _initialPokemonIndexes[1])
    ..ownFields = [for (final field in _initialIndiFields[0]) field.copyWith()]
    ..opponentFields = [for (final field in _initialIndiFields[1]) field.copyWith()]
    ..hasOwnTerastal = _initialHasTerastal[0]
    ..hasOpponentTerastal = _initialHasTerastal[1];
    ret.getPokemonStates(PlayerType(PlayerType.me)).clear();
    ret.getPokemonStates(PlayerType(PlayerType.me)).addAll([
      for (final state in _initialPokemonStates[0])
      state.copyWith()
    ]);
    ret.getPokemonStates(PlayerType(PlayerType.opponent)).clear();
    ret.getPokemonStates(PlayerType(PlayerType.opponent)).addAll([
      for (final state in _initialPokemonStates[1])
      state.copyWith()
    ]);
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
    _initialPokemonIndexes[0] = state.getPokemonIndex(PlayerType(PlayerType.me));
    _initialPokemonIndexes[1] = state.getPokemonIndex(PlayerType(PlayerType.opponent));
    _initialPokemonStates[0] = [
      for (final s in state.getPokemonStates(PlayerType(PlayerType.me)))
      s.copyWith()
    ];
    _initialPokemonStates[1] = [
      for (final s in state.getPokemonStates(PlayerType(PlayerType.opponent)))
      s.copyWith()
    ];
    _initialIndiFields[0] = [
      for (final f in state.ownFields)
      f.copyWith()
    ];
    _initialIndiFields[1] = [
      for (final f in state.opponentFields)
      f.copyWith()
    ];
    // ひるみ状態は自動的に解除
    // TODO これするなら他にも？
    for (var id in [PlayerType.me, PlayerType.opponent]) {
      var pokeIdx = getInitialPokemonIndex(PlayerType(id)) - 1;
      var idx = getInitialPokemonStates(PlayerType(id))[pokeIdx].ailmentsIndexWhere((element) => element.id == Ailment.flinch);
      if (idx >= 0) getInitialPokemonStates(PlayerType(id))[pokeIdx].ailmentsRemoveAt(idx);
    }
    initialWeather = state.weather;
    initialField = state.field;
    _initialHasTerastal[0] = state.hasOwnTerastal;
    _initialHasTerastal[1] = state.hasOpponentTerastal;
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
        ret.getPokemonState(PlayerType(PlayerType.me)),
        opponentParty,
        ret.getPokemonState(PlayerType(PlayerType.opponent)),
        ret, lastAction, continousCount,
      );
    }
    return ret;
  }

  // SQLに保存された文字列からTurnをパース
  static Turn deserialize(
    dynamic str, String split1, String split2,
    String split3, String split4, String split5, String split6)
  {
    Turn ret = Turn();
    final turnElements = str.split(split1);
    // _initialPokemonIndexes
    var indexes = turnElements[0].split(split2);
    ret._initialPokemonIndexes.clear();
    for (final index in indexes) {
      if (index == '') break;
      ret._initialPokemonIndexes.add(int.parse(index));
    }
    // _initialPokemonStates
    var pokeStates = turnElements[1].split(split2);
    ret._initialPokemonStates.clear();
    for (final pokeState in pokeStates) {
      if (pokeState == '') break;
      var states = pokeState.split(split3);
      List<PokemonState> adding = [];
      for (final state in states) {
        if (state == '') break;
        adding.add(PokemonState.deserialize(state, split4, split5, split6));
      }
      ret._initialPokemonStates.add(adding);
    }
    // _initialIndiFields
    var indiFields = turnElements[2].split(split2);
    ret._initialIndiFields = [[], []];
    for (int i = 0; i < indiFields.length; i++) {
      if (indiFields[i] == '') break;
      var fields = indiFields[i].split(split3);
      List<IndividualField> adding = [];
      for (final field in fields) {
        if (field == '') break;
        adding.add(IndividualField.deserialize(field, split4));
      }
      ret._initialIndiFields[i] = adding;
    }
    // initialWeather
    ret.initialWeather = Weather.deserialize(turnElements[3], split2);
    // initialField
    ret.initialField = Field.deserialize(turnElements[4], split2);
    // _initialHasTerastal
    var hasTerastals = turnElements[5].split(split2);
    ret._initialHasTerastal.clear();
    for (final hasTerastal in hasTerastals) {
      if (hasTerastal == '') break;
      ret._initialHasTerastal.add(hasTerastal == '1');
    }
    // phases
    var turnEffects = turnElements[6].split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5));
    }

    return ret;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3, String split4, String split5, String split6) {
    String ret = '';
    // _initialOwnPokemonIndexes
    for (final index in _initialPokemonIndexes) {
      ret += index.toString();
      ret += split2;
    }
    ret += split1;
    // _initialPokemonStates
    for (final states in _initialPokemonStates) {
      for (final state in states) {
        ret += state.serialize(split4, split5, split6);
        ret += split3;
      }
      ret += split2;
    }
    ret += split1;
    // _initialIndiFields
    for (final fields in _initialIndiFields) {
      for (final field in fields) {
        ret += field.serialize(split4);
        ret += split3;
      }
      ret += split2;
    }
    ret += split1;
    // initialWeather
    ret += initialWeather.serialize(split2);
    ret += split1;
    // initialField
    ret += initialField.serialize(split2);
    ret += split1;
    // _initialHasTerastal
    for (final hasTerastal in _initialHasTerastal) {
      ret += hasTerastal ? '1' : '0';
      ret += split2;
    }
    ret += split1;
    // phases
    for (final turnEffect in phases) {
      ret += turnEffect.serialize(split3, split4, split5);
      ret += split2;
    }

    return ret;
  }
}
