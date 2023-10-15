import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
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
  List<Party> _parties = [Party(), Party()];
  String opponentName = '';
  List<Turn> turns = [];

  Battle copyWith() =>
    Battle()
    ..id = id
    ..name = name
    ..type = type
    ..datetime = datetime
    .._parties[0] = _parties[0].copyWith()
    .._parties[1] = _parties[1].copyWith()
    ..opponentName = opponentName
    ..turns = [
      for (final turn in turns)
      turn.copyWith()
    ];

  // getter
  bool get isValid {
    // TODO
    return
      name != '' &&
      _parties[0].isValid &&
      opponentName != '' &&
      _parties[1].pokemon1.name != '';
  }

  Party getParty(PlayerType player) {
    assert(player.id == PlayerType.me || player.id == PlayerType.opponent);
    return player.id == PlayerType.me ? _parties[0] : _parties[1];
  }

  void setParty(PlayerType player, Party party) {
    assert(player.id == PlayerType.me || player.id == PlayerType.opponent);
    if (player.id == PlayerType.me) {
      _parties[0] = party;
    }
    else {
      _parties[1] = party;
    }
  }

  // SQLite保存用
  Map<String, dynamic> toMap() {
    String turnsStr = '';
    for (final turn in turns) {
      turnsStr += turn.serialize(sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6, sqlSplit7);
      turnsStr += sqlSplit1;
    }
    return {
      battleColumnId: id,
      battleColumnName: name,
      battleColumnTypeId: type.id,
      battleColumnDate: 0,      // TODO
      battleColumnOwnPartyId: _parties[0].id,
      battleColumnOpponentName: opponentName,
      battleColumnOpponentPartyId: _parties[1].id,
      battleColumnTurns: turnsStr,
    };
  }
}