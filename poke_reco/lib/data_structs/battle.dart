import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/turn.dart';

enum BattleType {
  //casual(0, 'カジュアルバトル'),
  rankmatch(0, 'ランクバトル'),
  ;

  const BattleType(this.id, this.displayName);

  factory BattleType.createFromId(int id) {
    switch (id) {
//      case 1:
//        return casual;
      case 0:
      default:
        return rankmatch;
    }
  }

  final int id;
  final String displayName;
}

class Battle {
  int id = 0; // 無効値
  String name = '';
  BattleType type = BattleType.rankmatch;
  DateTime datetime = DateTime.now();
  Party ownParty = Party();
  List<PokemonState> ownPokemonStates = [];     // TODO:必要？現在、使わずに実装してる
  String opponentName = '';
  Party opponentParty = Party();
  List<PokemonState> opponentPokemonStates = [];  // TODO:必要？現在、使わずに実装してる
  List<Turn> turns = [];

  Battle copyWith() =>
    Battle()
    ..id = id
    ..name = name
    ..type = type
    ..datetime = datetime
    ..ownParty = ownParty.copyWith()
    ..ownPokemonStates = [
      for (final state in ownPokemonStates)
      state.copyWith()
    ]
    ..opponentName = opponentName
    ..opponentParty = opponentParty.copyWith()
    ..opponentPokemonStates = [
      for (final state in opponentPokemonStates)
      state.copyWith()
    ]
    ..turns = [
      for (final turn in turns)
      turn.copyWith()
    ];

  // getter
  bool get isValid {
    // TODO
    return
      name != '' &&
      ownParty.isValid &&
      opponentName != '' &&
      opponentParty.pokemon1.name != '';
  }

  // SQLite保存用
  Map<String, dynamic> toMap() {
    String turnsStr = '';
    for (final turn in turns) {
      turnsStr += turn.serialize(sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6);
      turnsStr += sqlSplit1;
    }
    return {
      battleColumnId: id,
      battleColumnName: name,
      battleColumnTypeId: type.id,
      battleColumnDate: 0,      // TODO
      battleColumnOwnPartyId: ownParty.id,
      battleColumnOpponentName: opponentName,
      battleColumnOpponentPartyId: opponentParty.id,
      battleColumnTurns: turnsStr,
    };
  }
}