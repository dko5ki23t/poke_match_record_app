import 'package:intl/intl.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/turn.dart';

enum BattleType {
  //casual(0, 'カジュアルバトル', 'Casual Battle'),
  rankmatch(0, 'ランクバトル', 'Ranked Battle'),
  ;

  const BattleType(this.id, this.ja, this.en);

  factory BattleType.createFromId(int id) {
    switch (id) {
//      case 1:
//        return casual;
      case 0:
      default:
        return rankmatch;
    }
  }

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return ja;
      case Language.english:
      default:
        return en;
    }
  }

  final int id;
  final String ja;
  final String en;
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

  Battle();

  Battle.createFromDBMap(Map<String, dynamic> map, {int version = -1}) {  // -1は最新バージョン
    var pokeData = PokeDB();
    id = map[battleColumnId];
    viewOrder = map[battleColumnViewOrder];
    name = map[battleColumnName];
    type = BattleType.createFromId(map[battleColumnTypeId]);
    datetimeFromStr = map[battleColumnDate];
    _parties[0] = pokeData.parties.values.where(
      (element) => element.id == map[battleColumnOwnPartyId]).first.copyWith();
    opponentName = map[battleColumnOpponentName];
    _parties[1] = pokeData.parties.values.where(
      (element) => element.id == map[battleColumnOpponentPartyId]).first.copyWith();
    isMyWin = map[battleColumnIsMyWin] == 1;
    isYourWin = map[battleColumnIsYourWin] == 1;
    // 各ポケモンのレベルを50に
    for (int j = 0; j < 2; j++) {
      var party = _parties[j];
      for (int i = 0; i < party.pokemonNum; i++) {
        party.pokemons[i] = party.pokemons[i]!.copyWith();
        party.pokemons[i]!.level = 50;
        party.pokemons[i]!.updateRealStats();
      }
    }
    // turns
    final strTurns = map[battleColumnTurns].split(sqlSplit1);
    for (final strTurn in strTurns) {
      if (strTurn == '') break;
      turns.add(Turn.deserialize(strTurn, sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6, sqlSplit7, sqlSplit8, version: version));
    }
  }

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
      _parties[1].pokemons[0]!.name != '';
  }

  // 編集したかどうかのチェックに使う
  bool isDiff(Battle battle) {
    bool ret =
      id != battle.id ||
      name != battle.name ||
      type != battle.type ||
      datetime != battle.datetime ||
      _parties[0].id != battle._parties[0].id ||
      _parties[1].id != battle._parties[1].id ||
      opponentName != battle.opponentName ||
      isMyWin != battle.isMyWin ||
      isYourWin != battle.isYourWin;
    if (ret) return true;
    if (turns.length != battle.turns.length) return true;
    for (int i = 0; i < turns.length; i++) {
      if (turns[i] != battle.turns[i]) return true;
    }
    return false;
  }

  void clear() {
    name = '';
    type = BattleType.rankmatch;
    datetime = DateTime.now();
    _parties = [Party(), Party()];
    opponentName = '';
    turns = [];
    isMyWin = false;
    isYourWin = false;
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
    assert(player == PlayerType.me || player == PlayerType.opponent);
    return player == PlayerType.me ? _parties[0] : _parties[1];
  }

  void setParty(PlayerType player, Party party) {
    assert(player == PlayerType.me || player == PlayerType.opponent);
    if (player == PlayerType.me) {
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
      turnsStr += turn.serialize(sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6, sqlSplit7, sqlSplit8);
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