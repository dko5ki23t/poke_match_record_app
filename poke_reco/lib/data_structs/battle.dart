import 'package:intl/intl.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/tool.dart';

/// バトルの種類
enum BattleType {
  //casual(0, 'カジュアルバトル', 'Casual Battle'),
  rankmatch(0, 'ランクバトル', 'Ranked Battle'),
  ;

  const BattleType(this.id, this.ja, this.en);

  /// IDからバトルの種類を生成
  factory BattleType.createFromId(int id) {
    switch (id) {
//      case 1:
//        return casual;
      case 0:
      default:
        return rankmatch;
    }
  }

  /// 表示名
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

/// 対戦記録を管理するclass
class Battle extends Equatable implements Copyable {
  /// データベースのプライマリーキー
  int id = 0;

  /// 表示順
  int viewOrder = 0;

  /// 名前
  String name = '';

  /// 対戦の種類
  BattleType type = BattleType.rankmatch;

  /// 対戦日時
  DateTime datetime = DateTime.now();

  /// 両者のパーティ
  List<Party> _parties = [Party(), Party()];

  /// 対戦相手の名前
  String opponentName = '';

  /// ターン
  List<Turn> turns = [];

  /// 自身(ユーザー)が勝利したかどうか
  bool isMyWin = false;

  /// 対戦相手が勝利したかどうか
  bool isYourWin = false;

  @override
  List<Object?> get props => [
        id,
        viewOrder,
        name,
        type,
        datetime,
        _parties,
        opponentName,
        turns,
        isMyWin,
        isYourWin
      ];

  static DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');

  Battle();

  /// Databaseから取得したMapからclassを生成
  /// ```
  /// map: Databaseから取得したMap
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
  Battle.createFromDBMap(Map<String, dynamic> map, {int version = -1}) {
    // -1は最新バージョン
    final pokeData = PokeDB();
    id = map[battleColumnId];
    viewOrder = map[battleColumnViewOrder];
    name = map[battleColumnName];
    type = BattleType.createFromId(map[battleColumnTypeId]);
    datetimeFromStr = map[battleColumnDate];
    _parties[0] = pokeData.parties.values
        .where((element) => element.id == map[battleColumnOwnPartyId])
        .first
        .copy();
    opponentName = map[battleColumnOpponentName];
    _parties[1] = pokeData.parties.values
        .where((element) => element.id == map[battleColumnOpponentPartyId])
        .first
        .copy();
    isMyWin = map[battleColumnIsMyWin] == 1;
    isYourWin = map[battleColumnIsYourWin] == 1;
    // 各ポケモンのレベルを50に
    for (int j = 0; j < 2; j++) {
      var party = _parties[j];
      for (int i = 0; i < party.pokemonNum; i++) {
        party.pokemons[i] = party.pokemons[i]!.copy();
        party.pokemons[i]!.level = 50;
        party.pokemons[i]!.updateRealStats();
      }
    }
    // turns
    final strTurns = map[battleColumnTurns].split(sqlSplit1);
    for (final strTurn in strTurns) {
      if (strTurn == '') break;
      turns.add(Turn.deserialize(strTurn, sqlSplit2, sqlSplit3, sqlSplit4,
          sqlSplit5, sqlSplit6, sqlSplit7, sqlSplit8,
          version: version));
    }
  }

  @override
  Battle copy() => Battle()
    ..id = id
    ..viewOrder = viewOrder
    ..name = name
    ..type = type
    ..datetime = datetime
    .._parties[0] = _parties[0].copy()
    .._parties[1] = _parties[1].copy()
    ..opponentName = opponentName
    ..turns = [for (final turn in turns) turn.copy()]
    ..isMyWin = isMyWin
    ..isYourWin = isYourWin;

  /// 有効かどうか
  bool get isValid {
    return name != '' &&
        _parties[0].isValid &&
        opponentName != '' &&
        _parties[1].pokemons[0]!.name != '';
  }

  /// 内容をクリア
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

  /// フォーマットされた対戦日時
  /// ```dart
  /// 'yyyy-MM-dd HH:mm'
  /// ```
  String get formattedDateTime {
    return outputFormat.format(datetime);
  }

  /// 対戦日
  set date(DateTime t) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateFormat timeFormat = DateFormat('HH:mm');
    String p = '${dateFormat.format(t)} ${timeFormat.format(datetime)}';
    datetime = outputFormat.parse(p);
  }

  /// 対戦時
  set time(DateTime t) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateFormat timeFormat = DateFormat('HH:mm');
    String p = '${dateFormat.format(datetime)} ${timeFormat.format(t)}';
    datetime = outputFormat.parse(p);
  }

  /// フォーマットされた文字列から対戦日時をセット
  /// ```dart
  /// 'yyyy-MM-dd HH:mm'
  /// ```
  set datetimeFromStr(String s) {
    datetime = outputFormat.parse(s);
  }

  /// パーティを取得
  /// ```
  /// player: 取得対象のプレイヤー
  /// ```
  Party getParty(PlayerType player) {
    assert(player == PlayerType.me || player == PlayerType.opponent);
    return player == PlayerType.me ? _parties[0] : _parties[1];
  }

  /// パーティを設定
  /// ```
  /// player: 設定対象のプレイヤー
  /// party: 設定するパーティ
  /// ```
  void setParty(PlayerType player, Party party) {
    assert(player == PlayerType.me || player == PlayerType.opponent);
    if (player == PlayerType.me) {
      _parties[0] = party;
    } else {
      _parties[1] = party;
    }
  }

  /// SQLite保存用Mapを返す
  Map<String, dynamic> toMap() {
    String turnsStr = '';
    for (final turn in turns) {
      turnsStr += turn.serialize(sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5,
          sqlSplit6, sqlSplit7, sqlSplit8);
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
