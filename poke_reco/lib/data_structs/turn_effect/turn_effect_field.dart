import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:tuple/tuple.dart';

// フィールドによる効果(TurnEffectのeffectIdに使用する定数を提供)
class FieldEffect {
  static const int none = 0;
  static const int electricTerrainEnd = 1; // エレキフィールド終了
  static const int grassyTerrainEnd = 2; // グラスフィールド終了
  static const int mistyTerrainEnd = 3; // ミストフィールド終了
  static const int psychicTerrainEnd = 4; // サイコフィールド終了
  static const int grassHeal = 5; // グラスフィールドによる回復

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('エレキフィールド終了', 'Electric Terrain ends'),
    2: Tuple2('グラスフィールド終了', 'Grassy Terrain ends'),
    3: Tuple2('ミストフィールド終了', 'Misty Terrain ends'),
    4: Tuple2('サイコフィールド終了', 'Psychic Terrain ends'),
    5: Tuple2('グラスフィールドによる回復', 'Recovery by Grassy Terrain'),
  };

  const FieldEffect(this.id);

  static int getIdFromField(Field field) {
    switch (field.id) {
      case Field.electricTerrain:
      case Field.grassyTerrain:
      case Field.mistyTerrain:
      case Field.psychicTerrain:
        return field.id;
      default:
        return 0;
    }
  }

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  final int id;
}

class TurnEffectField extends TurnEffect {
  TurnEffectField({required this.timing, required this.fieldEffectID})
      : super(EffectType.field);

  Timing timing;
  int fieldEffectID;
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        timing,
        fieldEffectID,
        extraArg1,
        extraArg2,
      ];

  @override
  TurnEffectField copy() =>
      TurnEffectField(timing: timing, fieldEffectID: fieldEffectID);

  @override
  String displayName({required AppLocalizations loc}) =>
      FieldEffect(fieldEffectID).displayName;

  @override
  PlayerType get playerType => PlayerType.entireField;

  @override
  set playerType(type) {}

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffect? prevAction,
      int continuousCount,
      {required AppLocalizations loc}) {
    switch (fieldEffectID) {
      case FieldEffect.electricTerrainEnd:
      case FieldEffect.grassyTerrainEnd:
      case FieldEffect.mistyTerrainEnd:
      case FieldEffect.psychicTerrainEnd:
        state.field = Field(Field.none);
        break;
      case FieldEffect.grassHeal:
        ownState.remainHP -= extraArg1;
        opponentState.remainHPPercent -= extraArg2;
        break;
    }

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      fieldEffectID != 0;

  // SQLに保存された文字列からTurnEffectFieldをパース
  static TurnEffectField deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // timing
    final timing = Timing.values[int.parse(turnEffectElements.removeAt(0))];
    // fieldEffectID
    final fieldEffectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectField turnEffect =
        TurnEffectField(timing: timing, fieldEffectID: fieldEffectID);
    // extraArg1
    turnEffect.extraArg1 = int.parse(turnEffectElements.removeAt(0));
    // extraArg2
    turnEffect.extraArg2 = int.parse(turnEffectElements.removeAt(0));

    return turnEffect;
  }

  // SQL保存用の文字列に変換
  @override
  String serialize(
    String split1,
    String split2,
    String split3,
  ) {
    String ret = '';
    // effectType
    ret += effectType.index.toString();
    ret += split1;
    // timing
    ret += timing.index.toString();
    ret += split1;
    // fieldEffectID
    ret += fieldEffectID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }
}
