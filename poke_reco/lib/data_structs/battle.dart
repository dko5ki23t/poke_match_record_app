import 'package:intl/intl.dart';
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
  int viewOrder = 0;  // 無効値
  String name = '';
  BattleType type = BattleType.rankmatch;
  DateTime datetime = DateTime.now();
  List<Party> _parties = [Party(), Party()];
  String opponentName = '';
  List<Turn> turns = [];
  bool isMyWin = false;
  bool isYourWin = false;

  static DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

  Battle copyWith() =>
    Battle()
    ..id = id
    ..viewOrder = viewOrder
    ..name = name
    ..type = type
    ..datetime = datetime
    .._parties[0] = _parties[0].copyWith()
    .._parties[1] = _parties[1].copyWith()
    ..opponentName = opponentName
    ..turns = [
      for (final turn in turns)
      turn.copyWith()
    ]
    ..isMyWin = isMyWin
    ..isYourWin = isYourWin;

  // getter
  bool get isValid {
    return
      name != '' &&
      _parties[0].isValid &&
      opponentName != '' &&
      _parties[1].pokemon1.name != '';
  }

  String get formattedDateTime {
    return outputFormat.format(datetime);
  }

  set date(DateTime t) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateFormat timeFormat = DateFormat('HH:mm');
    String p = '${dateFormat.format(t)} ${timeFormat.format(datetime)}';
    datetime = outputFormat.parse(p);
  }

  set time(DateTime t) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateFormat timeFormat = DateFormat('HH:mm');
    String p = '${dateFormat.format(datetime)} ${timeFormat.format(t)}';
    datetime = outputFormat.parse(p);
  }

  set datetimeFromStr(String s) {
    datetime = outputFormat.parse(s);
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
      battleColumnViewOrder: viewOrder,
      battleColumnName: name,
      battleColumnTypeId: type.id,
      battleColumnDate: formattedDateTime,
      battleColumnOwnPartyId: _parties[0].id,
      battleColumnOpponentName: opponentName,
      battleColumnOpponentPartyId: _parties[1].id,
      battleColumnTurns: turnsStr,
      battleColumnIsMyWin: isMyWin ? 1 : 0,
      battleColumnIsYourWin: isYourWin ? 1 : 0,
    };
  }
}