import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/poke_move.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart';

const String errorFileName = 'errorFile.db';
const String errorString = 'errorString';

const String abilityDBFile = 'Abilities.db';
const String abilityDBTable = 'abilityDB';
const String abilityColumnId = 'id';
const String abilityColumnName = 'name';
const String abilityColumnTiming = 'timing';
const String abilityColumnTarget = 'target';
const String abilityColumnEffect = 'effect';

const String temperDBFile = 'Tempers.db';
const String temperDBTable = 'temperDB';
const String temperColumnId = 'id';
const String temperColumnName = 'name';
const String temperColumnDe = 'decreased_stat';
const String temperColumnIn = 'increased_stat';

const String itemDBFile = 'Items.db';
const String itemDBTable = 'itemDB';
const String itemColumnId = 'id';
const String itemColumnName = 'name';

const String moveDBFile = 'Moves.db';
const String moveDBTable = 'moveDB';
const String moveColumnId = 'id';
const String moveColumnName = 'name';
const String moveColumnType = 'type';
const String moveColumnPower = 'power';
const String moveColumnAccuracy = 'accuracy';
const String moveColumnPriority = 'priority';
const String moveColumnTarget = 'target';
const String moveColumnDamageClass = 'damage_class';
const String moveColumnEffect = 'effect';
const String moveColumnEffectChance = 'effect_chance';
const String moveColumnPP = 'PP';

const String pokeBaseDBFile = 'PokeBases.db';
const String pokeBaseDBTable = 'pokeBaseDB';
const String pokeBaseColumnId = 'id';
const String pokeBaseColumnName = 'name';
const String pokeBaseColumnAbility = 'ability';
const String pokeBaseColumnForm = 'form';
const String pokeBaseColumnFemaleRate = 'femaleRate';
const String pokeBaseColumnMove = 'move';
const List<String> pokeBaseColumnStats = [
  'h',
  'a',
  'b',
  'c',
  'd',
  's',
];
const String pokeBaseColumnType = 'type';

const String myPokemonDBFile = 'MyPokemons.db';
const String myPokemonDBTable = 'myPokemonDB';
const String myPokemonColumnId = 'id';
const String myPokemonColumnNo = 'no';
const String myPokemonColumnNickName = 'nickname';
const String myPokemonColumnTeraType = 'teratype';
const String myPokemonColumnLevel = 'level';
const String myPokemonColumnSex = 'sex';
const String myPokemonColumnTemper = 'temper';
const String myPokemonColumnAbility = 'ability';
const String myPokemonColumnItem = 'item';
const List<String> myPokemonColumnIndividual = [
  'indiH',
  'indiA',
  'indiB',
  'indiC',
  'indiD',
  'indiS',
];
const List<String> myPokemonColumnEffort = [
  'effH',
  'effA',
  'effB',
  'effC',
  'effD',
  'effS',
];
const String myPokemonColumnMove1 = 'move1';
const String myPokemonColumnPP1 = 'pp1';
const String myPokemonColumnMove2 = 'move2';
const String myPokemonColumnPP2 = 'pp2';
const String myPokemonColumnMove3 = 'move3';
const String myPokemonColumnPP3 = 'pp3';
const String myPokemonColumnMove4 = 'move4';
const String myPokemonColumnPP4 = 'pp4';
const String myPokemonColumnOwnerID = 'owner';
const String myPokemonColumnRefCount = 'refCount';


const String partyDBFile = 'parties.db';
const String partyDBTable = 'partyDB';
const String partyColumnId = 'id';
const String partyColumnName = 'name';
const String partyColumnPokemonId1 = 'pokemonID1';
const String partyColumnPokemonItem1 = 'pokemonItem1';
const String partyColumnPokemonId2 = 'pokemonID2';
const String partyColumnPokemonItem2 = 'pokemonItem2';
const String partyColumnPokemonId3 = 'pokemonID3';
const String partyColumnPokemonItem3 = 'pokemonItem3';
const String partyColumnPokemonId4 = 'pokemonID4';
const String partyColumnPokemonItem4 = 'pokemonItem4';
const String partyColumnPokemonId5 = 'pokemonID5';
const String partyColumnPokemonItem5 = 'pokemonItem5';
const String partyColumnPokemonId6 = 'pokemonID6';
const String partyColumnPokemonItem6 = 'pokemonItem6';
const String partyColumnOwnerID = 'owner';
const String partyColumnRefCount = 'refCount';

const String battleDBFile = 'battles.db';
const String battleDBTable = 'battleDB';
const String battleColumnId = 'id';
const String battleColumnName = 'name';
const String battleColumnTypeId = 'battleType';
const String battleColumnDate = 'date';
const String battleColumnOwnPartyId = 'ownParty';
const String battleColumnOpponentName = 'opponentName';
const String battleColumnOpponentPartyId = 'opponentParty';
const String battleColumnTurns = 'turns';

// 今後変更されないとも限らない
const int pokemonMinLevel = 1;
const int pokemonMaxLevel = 100;
const int pokemonMinNo = 1;
const int pokemonMinIndividual = 0;
const int pokemonMaxIndividual = 31;
const int pokemonMinEffort = 0;
const int pokemonMaxEffort = 252;

/*
pokeBaseNameToIdx = {     # (pokeAPIでの名称/tableの列名 : idx)
    'hp': 0,
    'attack' : 1,
    'defense' : 2,
    'special-attack' : 3,
    'special-defense' : 4,
    'speed' : 5,
}*/

enum TabItem {
  battles,
  pokemons,
  parties,
}

const Map<TabItem, String> tabName = {
  TabItem.battles: '対戦',
  TabItem.pokemons: 'ポケモン',
  TabItem.parties: 'パーティ',
};

const Map<TabItem, IconData> tabIcon = {
  TabItem.battles: Icons.list,
  TabItem.pokemons: Icons.catching_pokemon,
  TabItem.parties: Icons.groups,
};

enum Sex {
  none(0, 'なし', Icon(Icons.minimize, color: Colors.grey)),
  male(1, 'オス', Icon(Icons.male, color: Colors.blue)),
  female(2, 'メス', Icon(Icons.female, color: Colors.red)),
  ;

  const Sex(this.id, this.displayName, this.displayIcon);

  factory Sex.createFromId(int id) {
    switch (id) {
      case 1:
        return male;
      case 2:
        return female;
      case 0:
      default:
        return none;
    }
  }

  final int id;
  final String displayName;
  final Icon displayIcon;
}

// 使い方：print(PokeType.normal.displayName) -> 'ノーマル'
// TODO:これもPokeAPIから取得すべき。変な感じになってしまった。
class PokeType {
  final int id;
  final String displayName;
  final Icon displayIcon;

  static const Map<int, Tuple2<String, Icon>> officialTypes = {
    0 : Tuple2('不明', Icon(Icons.question_mark, color: Colors.grey)),
    1 : Tuple2('ノーマル', Icon(Icons.radio_button_unchecked, color: Color(0xffaeaeae))),
    2 : Tuple2('かくとう', Icon(Icons.sports_mma, color: Color(0xffee6969))),
    3 : Tuple2('ひこう', Icon(Icons.air, color: Color(0xff64a7f1))),
    4 : Tuple2('どく', Icon(Icons.coronavirus, color: Color(0xffab7aca))),
    5 : Tuple2('じめん', Icon(Icons.landscape, color: Color(0xffc8a841))),
    6 : Tuple2('いわ', Icon(Icons.diamond, color: Color(0xfffac727))),
    7 : Tuple2('むし', Icon(Icons.bug_report, color: Color(0xff51cb5a))),
    8 : Tuple2('ゴースト', Icon(Icons.nightlight, color: Color(0xff756eb4))),
    9 : Tuple2('はがね', Icon(Icons.hexagon, color: Color(0xff818aa4))),
    10 : Tuple2('ほのお', Icon(Icons.whatshot, color: Color(0xffffa766))),
    11 : Tuple2('みず', Icon(Icons.opacity, color: Color(0xff64c5f7))),
    12 : Tuple2('くさ', Icon(Icons.grass, color: Color(0xff9ac30e))),
    13 : Tuple2('でんき', Icon(Icons.bolt, color: Color(0xffe7d400))),
    14 : Tuple2('エスパー', Icon(Icons.psychology, color: Color(0xffeb7ff4))),
    15 : Tuple2('こおり', Icon(Icons.ac_unit, color: Color(0xff60e9f5))),
    16 : Tuple2('ドラゴン', Icon(Icons.cruelty_free, color: Color(0xff6881d4))),
    17 : Tuple2('あく', Icon(Icons.remove_red_eye, color: Colors.black54)),
    18 : Tuple2('フェアリー', Icon(Icons.emoji_nature, color: Color(0xfffc7799))),
  };

  const PokeType(this.id, this.displayName, this.displayIcon);

  factory PokeType.createFromId(int id) {
    final tuple = officialTypes[id];

    return PokeType(
      id,
      tuple!.item1,
      tuple.item2,
    );
  }
}

class Temper {
  final int id;
  final String displayName;
  final String decreasedStat;
  final String increasedStat;

  const Temper(this.id, this.displayName, this.decreasedStat, this.increasedStat);

  static List<double> getTemperBias(Temper temper) {
    const Map<String, int> statNameToIdx = {
      'attack' : 0,
      'defense' : 1,
      'special-attack' : 2,
      'special-defense' : 3,
      'speed' : 4,
    };
    var ret = [1.0, 1.0, 1.0, 1.0, 1.0]; // A, B, C, D, S
    final incIdx = statNameToIdx[temper.increasedStat];
    if (incIdx != null) {
      ret[incIdx] = 1.1;
    }
    final decIdx = statNameToIdx[temper.decreasedStat];
    if (decIdx != null) {
      ret[decIdx] = 0.9;
    }

    return ret;
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      temperColumnId: id,
      temperColumnName: displayName,
      temperColumnDe: decreasedStat,
      temperColumnIn: increasedStat,
    };
    return map;
  }
}

class SixParams {
  int race = 0;
  int indi = 0;
  int effort = 0;
  int real = 0;

  SixParams(this.race, this.indi, this.effort, this.real);

  static int getRealH(int level, int race, int indi, int effort) {
    return (race * 2 + indi + (effort ~/ 4)) * level ~/ 100 + level + 10;
  }

  static int getRealABCDS(int level, int race, int indi, int effort, double temperBias) {
    return (((race * 2 + indi + (effort ~/ 4)) * level ~/ 100 + 5) * temperBias).toInt();
  }

  static int getEffortH(int level, int race, int indi, int real) {
    // TODO ミスってるかも
    int ret = (((real - level - 10) * 100) ~/ level - race * 2 - indi) * 4; // 暫定値
    while (real > getRealH(level, race, indi, ret)) {    // 足りてない
      ret += (4 - ret % 4);
    }
    while (real < getRealH(level, race, indi, ret)) {    // 大きい(たぶんこのwhileには入らない？)
      ret -= ret % 4 == 0 ? 4 : ret % 4;
    }
    return ret;
  }

  static int getEffortABCDS(int level, int race, int indi, int real, double temperBias) {
    // TODO ミスってるかも
    int ret = ((real ~/ temperBias - 5) * 100 ~/ level - race * 2 - indi) * 4;
    while (real > getRealABCDS(level, race, indi, ret, temperBias)) {    // 足りてない
      ret += (4 - ret % 4);
    }
    while (real < getRealABCDS(level, race, indi, ret, temperBias)) {    // 大きい(たぶんこのwhileには入らない？)
      ret -= ret % 4 == 0 ? 4 : ret % 4;
    }
    return ret;
  }

  static int getIndiH(int level, int race, int effort, int real) {
    // TODO ミスってるかも
    int ret = ((real - level - 10) * 100) ~/ level - race * 2 - (effort ~/ 4);
    while (real > getRealH(level, race, ret, effort)) {    // 足りてない
      ret++;
    }
    while (real < getRealH(level, race, ret, effort)) {    // 大きい(たぶんこのwhileには入らない？)
      ret--;
    }
    return ret;
  }

  static int getIndiABCDS(int level, int race, int effort, int real, double temperBias) {
    // TODO ミスってるかも
    int ret = ((real ~/ temperBias - 5) * 100) ~/ level - race * 2 - (effort ~/ 4);
    while (real > getRealABCDS(level, race, ret, effort, temperBias)) {    // 足りてない
      ret++;
    }
    while (real < getRealABCDS(level, race, ret, effort, temperBias)) {    // 大きい(たぶんこのwhileには入らない？)
      ret--;
    }
    return ret; 
  }

  factory SixParams.createFromLRIEtoH(int level, int race, int indi, int effort) {
    return SixParams(race, indi, effort, getRealH(level, race, indi, effort));
  }

  factory SixParams.createFromLRIEBtoABCDS(int level, int race, int indi, int effort, double temperBias) {
    return SixParams(race, indi, effort, getRealABCDS(level, race, indi, effort, temperBias));
  }

  set(race, indi, effort, real) {
    this.race = race;
    this.indi = indi;
    this.effort = effort;
    this.real = real;
  }
}

// 発動タイミング
class AbilityTiming {
/*
  none(0),
  pokemonAppear(1),     // ポケモン登場時
  defeatOpponent(2),    // 相手を倒したとき
  ;
*/

  const AbilityTiming(this.id);

  final int id;
}

// 対象
class Target {
/*
  // わざの対象から引用
  none(0),
  specificMove(1),
  selectedPokemonMeFirst(2),
  ally(3),
  usersField(4),
  userOrAlly(5),
  opponentsField(6),
  user(7),                      // 自分自身
  randomOpponent(8),
  allOtherPokemon(9),
  selectedPokemon(10),          // 選択した相手
  allOpponents(11),
  entireField(12),
  userAndAllies(13),
  allPokemon(14),
  allAllies(15),
  faintingPokemon(16),
  ;
*/

  const Target(this.id);

  final int id;
}

// ダメージ
class DamageClass {
/*
  none(0),
  status(1),              // へんか(ダメージなし)
  physical(2),            // ぶつり
  special(3),             // とくしゅ
  ;
*/

  const DamageClass(this.id);

  final int id;
}

// 効果
class AbilityEffect {
/*
  none(0),
  attackDown1(1),         // こうげき1段階ダウン
  attackUp1(2),           // こうげき1段階アップ
  ;
*/

  const AbilityEffect(this.id);

  final int id;
}

// 効果
class MoveEffect {
/*
  none(0),
  attackDown1(1),         // こうげき1段階ダウン
  attackUp1(2),           // こうげき1段階アップ
  ;
*/

  const MoveEffect(this.id);

  final int id;
}

class Ability {
  final int id;
  final String displayName;
  final AbilityTiming timing;
  final Target target;
  final AbilityEffect effect;

  const Ability(
    this.id, this.displayName, this.timing, this.target, this.effect
  );

  Ability copyWith() =>
    Ability(id, displayName, timing, target, effect);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      abilityColumnId: id,
      abilityColumnName: displayName,
      abilityColumnTiming: timing.id,
      abilityColumnTarget: target.id,
      abilityColumnEffect: effect.id,
    };
    return map;
  }
}

class Item {
  final int id;
  final String displayName;

  const Item(this.id, this.displayName);

  Item copyWith() =>
    Item(id, displayName);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      itemColumnId: id,
      itemColumnName: displayName
    };
    return map;
  }
}

class Move {
  final int id;
  final String displayName;
  final PokeType type;
  int power;
  int accuracy;
  int priority;
  Target target;
  DamageClass damageClass;
  MoveEffect effect;
  int effectChance;
  final int pp;

  Move(
    this.id, this.displayName, this.type, this.power,
    this.accuracy, this.priority, this.target,
    this.damageClass, this.effect, this.effectChance, this.pp,
  );

  Move copyWith() =>
    Move(id, displayName, type, power,
      accuracy, priority, target,
      damageClass, effect, effectChance, pp,);

/*
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      moveColumnId: id,
      moveColumnName: displayName,
      moveColumnPP: pp,
    };
    return map;
  }
*/
}

class PokeBase {    // 各ポケモンの種族ごとの値
  final String name;              // ポケモン名
  final List<Sex> sex;            // せいべつの種類
  final int no;                   // 図鑑No.
  final PokeType type1;           // タイプ1
  final PokeType? type2;          // タイプ2(null OK)
  final int h;                    // HP(種族値)
  final int a;                    // こうげき(種族値)
  final int b;                    // ぼうぎょ(種族値)
  final int c;                    // とくこう(種族値)
  final int d;                    // とくぼう(種族値)
  final int s;                    // すばやさ(種族値)
  final List<Ability> ability;    // とくせいの種類
  final List<Move> move;          // おぼえるわざ

  PokeBase({
    required this.name,
    required this.sex,
    required this.no,
    required this.type1,
    required this.type2,
    required this.h,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.s,
    required this.ability,
    required this.move,
  });

/*
  factory PokeBase.fromJson(Map<String, dynamic> json, Map<String, dynamic> speciesJson) {
    String getJAName(dynamic species) {
      return species['names'].firstWhere((e) => e['language']['name'] == 'ja')['name'];
    }
    
    List<String> typesToList(dynamic types) {
      List<String> ret = [];
      for (int i = 0; i < types.length; i++) {
        ret.add(types[i]['type']['name']);
      }
      return ret;
    }

    Map<String, int> statusToMap(dynamic status) {
      Map<String, int> ret = {};
      for (int i = 0; i < status.length; i++) {
        ret[status[i]['stat']['name']] = status[i]['base_stat'];
      }
      return ret;
    }

    List<String> movesToList(dynamic moves) {
      List<String> ret = [];
      for (int i = 0; i < moves.length; i++) {
        ret.add(moves[i]['move']['name']);
      }
      return ret;
    }

    List<String> abilitiesToList(dynamic abilities) {
      List<String> ret = [];
      for (int i = 0; i < abilities.length; i++) {
        ret.add(abilities[i]['ability']['name']);
      }
      return ret;
    }

    final List<String> types = typesToList(json['types']);
    final Map<String, int> status = statusToMap(json['stats']);
    final List<String> moves = movesToList(json['moves']);
    final List<String> abilities = abilitiesToList(json['abilities']);

    return PokeBase(
      name: getJAName(speciesJson),
      sex: [Sex.none, Sex.male, Sex.female],
      no: json['id'],
      type1: PokeType.values.byName(types[0]),
      type2: (types.length > 1) ? PokeType.values.byName(types[1]) : null,
      h: status['hp'] ?? 0,
      a: status['hp'] ?? 0,
      b: status['hp'] ?? 0,
      c: status['hp'] ?? 0,
      d: status['hp'] ?? 0,
      s: status['hp'] ?? 0,
      ability: [
//        for (var name in abilities)
//          Ability.values.byName(name)
      ],
      move: [
//        for (var name in moves)
//          Move.values.byName(name)
      ],
    );
  }
*/
}

// Pokemonのstatsのインデックスに使う
// ex) pokemon.stat[StatIndex.H.index]
enum StatIndex {
  H,
  A,
  B,
  C,
  D,
  S,
  size,
}

// 登録しているポケモンの作成者
enum Owner {
  mine,
  fromBattle,
  hidden,
}

// TODO
Owner toOwner(int idx) {
  switch (idx) {
    case 0:
      return Owner.mine;
    case 1:
      return Owner.fromBattle;
    case 2:
    default:
      return Owner.hidden;
  }
}

class Pokemon {
  int id = 0;    // データベースのプライマリーキー
  String _name = '';       // ポケモン名
  String nickname = '';            // ニックネーム
  int _level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int _no = 0;                      // 図鑑No.
  PokeType type1 = PokeType.createFromId(0);        // タイプ1
  PokeType? type2;                     // タイプ2(null OK)
  PokeType teraType = PokeType.createFromId(0);     // テラスタルタイプ
  Temper temper = Temper(0, '', '', ''); // せいかく
  // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ
  List<SixParams> _stats = List.generate(StatIndex.size.index, (i) => SixParams(0, 31, 0, 0));
  Ability ability = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0));     // とくせい
  Item? item;                      // もちもの(null OK)
  List<Move?> _moves = [
    Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0),
    null, null, null
  ];  // わざ
  List<int?> _pps = [0, null, null, null];  // PP
  Owner owner = Owner.mine;     // 自分でつくったか、対戦相手が作ったものか
  int refCount = 0;                 // パーティに含まれている数（削除時に警告出す用の変数）       
  //bool _isValid = false;            // 必要な情報が入力されているか

  // getter
  String get name => _name;
  int get level => _level;
  int get no => _no;
  SixParams get h => _stats[StatIndex.H.index];
  SixParams get a => _stats[StatIndex.A.index];
  SixParams get b => _stats[StatIndex.B.index];
  SixParams get c => _stats[StatIndex.C.index];
  SixParams get d => _stats[StatIndex.D.index];
  SixParams get s => _stats[StatIndex.S.index];
  List<SixParams> get stats => _stats;
  Move get move1 => _moves[0]!;
  int get pp1 => _pps[0]!;
  Move? get move2 => _moves[1];
  int? get pp2 => _pps[1];
  Move? get move3 => _moves[2];
  int? get pp3 => _pps[2];
  Move? get move4 => _moves[3];
  int? get pp4 => _pps[3];
  List<Move?> get moves => _moves;
  List<int?> get pps => _pps;
  bool get isValid {
    if (
      _name != '' &&
      (_level >= pokemonMinLevel && _level <= pokemonMaxLevel) &&
      _no >= pokemonMinNo && temper.id != 0 &&
      teraType.id != 0 &&
      ability.id != 0 && _moves[0]!.id != 0
    ) {
      return true;
    }
    else {
      return false;
    }
  }

  // setter
  set name(String x) {_name = x;}
  set level(int x) {_level = x;}
  set no(int x) {_no = x;}
  set h(SixParams x) {_stats[StatIndex.H.index] = x;}
  set a(SixParams x) {_stats[StatIndex.A.index] = x;}
  set b(SixParams x) {_stats[StatIndex.B.index] = x;}
  set c(SixParams x) {_stats[StatIndex.C.index] = x;}
  set d(SixParams x) {_stats[StatIndex.D.index] = x;}
  set s(SixParams x) {_stats[StatIndex.S.index] = x;}
  set move1(Move x) => _moves[0] = x;
  set pp1(int x) => _pps[0] = x;
  set move2(Move? x) => _moves[1] = x;
  set pp2(int? x) => _pps[1] = x;
  set move3(Move? x) => _moves[2] = x;
  set pp3(int? x) => _pps[2] = x;
  set move4(Move? x) => _moves[3] = x;
  set pp4(int? x) => _pps[3] = x;

  Pokemon copyWith() =>
    Pokemon()
    ..id = id
    .._name = _name
    ..nickname = nickname
    .._level = _level
    ..sex = sex
    .._no = _no
    ..type1 = type1
    ..type2 = type2
    ..teraType = teraType
    ..temper = temper
    .._stats = List.generate(
      StatIndex.size.index,
      (i) => SixParams(_stats[i].race, _stats[i].indi, _stats[i].effort, _stats[i].real))
    ..ability = ability.copyWith()
    ..item = item?.copyWith()
    .._moves = [move1.copyWith(), move2?.copyWith(), move3?.copyWith(), move4?.copyWith()]
    .._pps = [..._pps]
    ..owner = owner
    ..refCount = refCount;

  // レベル、種族値、個体値、努力値、せいかくから実数値を更新
  // TODO habcdsのsetterで自動的に呼ぶ？
  void updateRealStats() {
    final temperBias = Temper.getTemperBias(temper);
    _stats[StatIndex.H.index].real = SixParams.getRealH(level, h.race, h.indi, h.effort);
    _stats[StatIndex.A.index].real = SixParams.getRealABCDS(level, a.race, a.indi, a.effort, temperBias[0]);
    _stats[StatIndex.B.index].real = SixParams.getRealABCDS(level, b.race, b.indi, b.effort, temperBias[1]);
    _stats[StatIndex.C.index].real = SixParams.getRealABCDS(level, c.race, c.indi, c.effort, temperBias[2]);
    _stats[StatIndex.D.index].real = SixParams.getRealABCDS(level, d.race, d.indi, d.effort, temperBias[3]);
    _stats[StatIndex.S.index].real = SixParams.getRealABCDS(level, s.race, s.indi, s.effort, temperBias[4]);
  }

  // 実数値から努力値、個体値を更新
  void updateStatsRefReal(int statIndex) {
    if (statIndex == StatIndex.H.index) {
      int effort = SixParams.getEffortH(level, h.race, h.indi, h.real);
      // 努力値の変化だけでは実数値が出せない場合は個体値を更新
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[StatIndex.H.index].effort = effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiH(level, h.race, h.effort, h.real);
        // 努力値・個体値の変化では実数値が出せない場合は実数値を更新
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[StatIndex.H.index].indi = indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[StatIndex.H.index].real = SixParams.getRealH(level, h.race, h.indi, h.effort);
        }
        else {
          _stats[StatIndex.H.index].indi = indi;
        }
      }
      else {
        _stats[StatIndex.H.index].effort = effort;
      }
    }
    else if (statIndex < StatIndex.size.index) {
      final temperBias = Temper.getTemperBias(temper);
      int i = statIndex;
      int effort = SixParams.getEffortABCDS(level, _stats[i].race, _stats[i].indi, _stats[i].real, temperBias[i-1]);
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[i].effort = effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiABCDS(level, _stats[i].race, _stats[i].effort, _stats[i].real, temperBias[i-1]);
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[i].indi = indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[i].real = SixParams.getRealABCDS(level, _stats[i].race, _stats[i].indi, _stats[i].effort, temperBias[i-1]);
        }
        else {
          _stats[i].indi = indi;
        }
      }
      else {
        _stats[i].effort = effort;
      }
    }
  }

  // SQLite保存用
  Map<String, dynamic> toMap() {
    return {
      myPokemonColumnId: id,
      myPokemonColumnNo: _no,
      myPokemonColumnNickName: nickname,
      myPokemonColumnTeraType: teraType.id,
      myPokemonColumnLevel: _level,
      myPokemonColumnSex: sex.id,
      myPokemonColumnTemper: temper.id,
      myPokemonColumnAbility: ability.id,
      myPokemonColumnItem: item?.id,
      myPokemonColumnIndividual[0]: h.indi,
      myPokemonColumnIndividual[1]: a.indi,
      myPokemonColumnIndividual[2]: b.indi,
      myPokemonColumnIndividual[3]: c.indi,
      myPokemonColumnIndividual[4]: d.indi,
      myPokemonColumnIndividual[5]: s.indi,
      myPokemonColumnEffort[0]: h.effort,
      myPokemonColumnEffort[1]: a.effort,
      myPokemonColumnEffort[2]: b.effort,
      myPokemonColumnEffort[3]: c.effort,
      myPokemonColumnEffort[4]: d.effort,
      myPokemonColumnEffort[5]: s.effort,
      myPokemonColumnMove1: move1.id,
      myPokemonColumnPP1: pp1,
      myPokemonColumnMove2: move2?.id,
      myPokemonColumnPP2: pp2,
      myPokemonColumnMove3: move3?.id,
      myPokemonColumnPP3: pp3,
      myPokemonColumnMove4: move4?.id,
      myPokemonColumnPP4: pp4,
      myPokemonColumnOwnerID: owner.index,
      myPokemonColumnRefCount: refCount,
    };
  }
}

// TODO
enum Ailment {
  none(0),
  burn(1),    // やけど
  freeze(2),  // こおり
  ;

  const Ailment(this.id);

  final int id;
}

class PokemonState {
  //Pokemon pokemonBaseInfo;
  int no = 0;   // ずかんNo
  int hp = 0;   // HP
  int hpPercent = 100;  // 残りHP割合
  PokeType teraType = PokeType.createFromId(0);   // テラスタイプ
  List<Ability> possibleAbilities = [];     // 候補のあるとくせい
  Ability ability = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0)); // 現在のとくせい
  List<int> statChanges = List.generate(6, (i) => 0);   // のうりょく変化
  List<Ailment> ailments = [];   // 状態異常

  PokemonState copyWith() =>
    PokemonState()
    ..no = no
    ..hp = hp
    ..hpPercent = hpPercent
    ..teraType = teraType
    ..possibleAbilities = [...possibleAbilities]
    ..ability = ability
    ..statChanges = [...statChanges]
    ..ailments = [...ailments];
}

class Party {
  int id = 0;    // データベースのプライマリーキー
  String name = '';
  List<Pokemon?> _pokemons = [Pokemon(), null, null, null, null, null];
  List<Item?> _items = List.generate(6, (i) => null);
  Owner owner = Owner.mine;
  int refCount = 0;

  // getter
  Pokemon get pokemon1 => _pokemons[0]!;
  Pokemon? get pokemon2 => _pokemons[1];
  Pokemon? get pokemon3 => _pokemons[2];
  Pokemon? get pokemon4 => _pokemons[3];
  Pokemon? get pokemon5 => _pokemons[4];
  Pokemon? get pokemon6 => _pokemons[5];
  List<Pokemon?> get pokemons => _pokemons;
  Item? get item1 => _items[0];
  Item? get item2 => _items[1];
  Item? get item3 => _items[2];
  Item? get item4 => _items[3];
  Item? get item5 => _items[4];
  Item? get item6 => _items[5];
  List<Item?> get items => _items;
  int get pokemonNum {
    for (int i = 0; i < 6; i++) {
      if (pokemons[i] == null) return i;
    }
    return 6;
  }
  bool get isValid {
    return
      name != '' &&
      _pokemons[0]!.isValid;
  }

  // setter
  set pokemon1(Pokemon x)  => _pokemons[0] = x;
  set pokemon2(Pokemon? x) => _pokemons[1] = x;
  set pokemon3(Pokemon? x) => _pokemons[2] = x;
  set pokemon4(Pokemon? x) => _pokemons[3] = x;
  set pokemon5(Pokemon? x) => _pokemons[4] = x;
  set pokemon6(Pokemon? x) => _pokemons[5] = x;
  set item1(Item? x) => _items[0] = x;
  set item2(Item? x) => _items[1] = x;
  set item3(Item? x) => _items[2] = x;
  set item4(Item? x) => _items[3] = x;
  set item5(Item? x) => _items[4] = x;
  set item6(Item? x) => _items[5] = x;

  Party copyWith() =>
    Party()
    ..id = id
    ..name = name
    .._pokemons = [..._pokemons]
    .._items = [..._items]
    ..owner = owner
    ..refCount = refCount;

  // SQLite保存用
  Map<String, dynamic> toMap() {
    return {
      partyColumnId: id,
      partyColumnName: name,
      partyColumnPokemonId1: pokemon1.id,
      partyColumnPokemonItem1: item1?.id,
      partyColumnPokemonId2: pokemon2?.id,
      partyColumnPokemonItem2: item2?.id,
      partyColumnPokemonId3: pokemon3?.id,
      partyColumnPokemonItem3: item3?.id,
      partyColumnPokemonId4: pokemon4?.id,
      partyColumnPokemonItem4: item4?.id,
      partyColumnPokemonId5: pokemon5?.id,
      partyColumnPokemonItem5: item5?.id,
      partyColumnPokemonId6: pokemon6?.id,
      partyColumnPokemonItem6: item6?.id,
      partyColumnOwnerID: owner.index,
      partyColumnRefCount: refCount,
    };
  }
}

enum BattleType {
  casual(0, 'カジュアルバトル'),
  rankmatch(1, 'ランクバトル'),
  ;

  const BattleType(this.id, this.displayName);

  factory BattleType.createFromId(int id) {
    switch (id) {
      case 1:
        return casual;
      case 0:
      default:
        return rankmatch;
    }
  }

  final int id;
  final String displayName;
}

enum PlayerType {
  none(0),
  me(1),
  opponent(2),
  ;

  const PlayerType(this.id);

  final int id;
}



enum EffectType {
  none(0),
  ability(1),
  item(2),
  ;

  const EffectType(this.id);

  final int id;
}

class TurnEffect {
  PlayerType playerType = PlayerType.none;
  EffectType effect = EffectType.none;
  int effectId = 0;

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..effect = effect
    ..effectId = effectId;

  bool isValid() {
    return
      playerType != PlayerType.none &&
      effect != EffectType.none &&
      effectId > 0;
  }
}

class Turn {
  bool changedOwnPokemon = false;
  bool changedOpponentPokemon = false;
  int initialOwnPokemonIndex = 0;         // 0は無効値
  int initialOpponentPokemonIndex = 0;    // 0は無効値
  int currentOwnPokemonIndex = 0;         // 0は無効値
  int currentOpponentPokemonIndex = 0;    // 0は無効値
  List<PokemonState> ownPokemonInitialStates = [];
  List<PokemonState> opponentPokemonInitialStates = [];
  List<PokemonState> ownPokemonCurrentStates = [];
  List<PokemonState> opponentPokemonCurrentStates = [];
  List<TurnEffect> beforeMoveEffects = [];
  TurnMove turnMove1 = TurnMove();
  TurnMove turnMove2 = TurnMove();
  List<TurnEffect> afterMoveEffects = [];

  Turn copyWith() =>
    Turn()
    ..changedOwnPokemon = changedOwnPokemon
    ..changedOpponentPokemon = changedOpponentPokemon
    ..initialOwnPokemonIndex = initialOwnPokemonIndex
    ..initialOpponentPokemonIndex = initialOpponentPokemonIndex
    ..currentOwnPokemonIndex = currentOwnPokemonIndex
    ..currentOpponentPokemonIndex = currentOpponentPokemonIndex
    ..ownPokemonInitialStates = [
      for (final state in ownPokemonInitialStates)
      state.copyWith()
    ]
    ..opponentPokemonInitialStates = [
      for (final state in opponentPokemonInitialStates)
      state.copyWith()
    ]
    ..ownPokemonCurrentStates = [
      for (final state in ownPokemonCurrentStates)
      state.copyWith()
    ]
    ..opponentPokemonCurrentStates = [
      for (final state in opponentPokemonCurrentStates)
      state.copyWith()
    ]
    ..beforeMoveEffects = [
      for (final effect in beforeMoveEffects)
      effect.copyWith()
    ]
    ..turnMove1 = turnMove1.copyWith()
    ..turnMove2 = turnMove2.copyWith()
    ..afterMoveEffects = [
      for (final effect in afterMoveEffects)
      effect.copyWith()
    ];

  bool canAddBeforemoveEffects() {
    for (final effect in beforeMoveEffects) {
      if (!effect.isValid()) return false;
    }
    return true;
  }

  // TODO:とある時点でのHPとか取得できるようにしたほうがいい
  void updateCurrentStates(Party ownParty, Party opponentParty) {
    ownPokemonCurrentStates = [];
    for (final e in ownPokemonInitialStates) {
      ownPokemonCurrentStates.add(e.copyWith());
    }
    opponentPokemonCurrentStates = [];
    for (final e in opponentPokemonInitialStates) {
      opponentPokemonCurrentStates.add(e.copyWith());
    }
    currentOwnPokemonIndex = initialOwnPokemonIndex;
    currentOpponentPokemonIndex = initialOpponentPokemonIndex;

    // わざ選択前の処理
    for (final effect in beforeMoveEffects) {
      if (effect.effect == EffectType.ability) {
        switch (effect.effectId) {
          case 22:   // いかく
            if (effect.playerType == PlayerType.me) {
              opponentPokemonCurrentStates[currentOpponentPokemonIndex-1].statChanges[0]--;
            }
            else {
              ownPokemonCurrentStates[currentOwnPokemonIndex-1].statChanges[0]--;
            }
            break;
          default:
            break;
        }
      }
    }

    // わざ1
    turnMove1.processMove(
      ownParty.pokemons[currentOwnPokemonIndex-1]!,
      ownPokemonCurrentStates[currentOwnPokemonIndex-1],
      opponentParty.pokemons[currentOpponentPokemonIndex-1]!,
      opponentPokemonCurrentStates[currentOpponentPokemonIndex-1],
      this,
    );

    // わざ2
    turnMove2.processMove(
      ownParty.pokemons[currentOwnPokemonIndex-1]!,
      ownPokemonCurrentStates[currentOwnPokemonIndex-1],
      opponentParty.pokemons[currentOpponentPokemonIndex-1]!,
      opponentPokemonCurrentStates[currentOpponentPokemonIndex-1],
      this,
    );
  }
}

PokemonState parsePokemonState(dynamic str, String split1, String split2, String split3) {
  PokemonState pokemonState = PokemonState();
  final stateElements = str.split(split1);
  // no
  pokemonState.no = int.parse(stateElements[0]);
  // hp
  pokemonState.hp = int.parse(stateElements[1]);
  // hpPercent
  pokemonState.hpPercent = int.parse(stateElements[2]);
  // teraType
  pokemonState.teraType = PokeType.createFromId(int.parse(stateElements[3]));
  // possibleAbilities
  final abilities = stateElements[4].split(split2);
  for (var ability in abilities) {
    if (ability == '') break;
    final abilityElements = ability.split(split3);
    pokemonState.possibleAbilities.add(
      Ability(
        int.parse(abilityElements[0]),
        abilityElements[1],
        AbilityTiming(int.parse(abilityElements[2])),
        Target(int.parse(abilityElements[3])),
        AbilityEffect(int.parse(abilityElements[4])),
      ),
    );
  }
  // ability
  final abilityElements = stateElements[5].split(split2);
  pokemonState.ability = Ability(
    int.parse(abilityElements[0]),
    abilityElements[1],
    AbilityTiming(int.parse(abilityElements[2])),
    Target(int.parse(abilityElements[3])),
    AbilityEffect(int.parse(abilityElements[4])),
  );
  // statChanges
  final statChangeElements = stateElements[6].split(split2);
  for (int i = 0; i < 6; i++) {
    pokemonState.statChanges[i] = int.parse(statChangeElements[i]);
  }
  // ailments
  final ailments = stateElements[7].split(split2);
  for (var ailment in ailments) {
    if (ailment == '') break;
    pokemonState.ailments.add(
      Ailment.none,         // TODO
    );
  }

  return pokemonState;
}

TurnMove parseTurnMove(dynamic str, String split1, String split2) {
  TurnMove turnMove = TurnMove();
  final turnMoveElements = str.split(split1);
  // playerType
  switch (int.parse(turnMoveElements[0])) {
    case 1:
      turnMove.playerType = PlayerType.me;
      break;
    case 2:
      turnMove.playerType = PlayerType.opponent;
      break;
    default:
      turnMove.playerType = PlayerType.none;
      break;
  }
  // move
  var moveElements = turnMoveElements[1].split(split2);
  turnMove.move = Move(
    int.parse(moveElements[0]),
    moveElements[1],
    PokeType.createFromId(int.parse(moveElements[2])),
    int.parse(moveElements[3]),
    int.parse(moveElements[4]),
    int.parse(moveElements[5]),
    Target(int.parse(moveElements[6])),
    DamageClass(int.parse(moveElements[7])),
    MoveEffect(int.parse(moveElements[8])),
    int.parse(moveElements[9]),
    int.parse(moveElements[10]),
  );
  // isSuccess
  turnMove.isSuccess = int.parse(turnMoveElements[2]) != 0;
  // moveHits
  var moveHits = turnMoveElements[3].split(split2);
  for (var moveHitsElement in moveHits) {
    if (moveHitsElement == '') break;
    MoveHit t = MoveHit.hit;
    if (int.parse(moveHitsElement) == 1) {
      t = MoveHit.critical;
    }
    else if (int.parse(moveHitsElement) == 2) {
      t = MoveHit.notHit;
    }
    turnMove.moveHits.add(t);
  }
  // moveEffectiveness
  switch (int.parse(turnMoveElements[4])) {
    case 1:
      turnMove.moveEffectiveness = MoveEffectiveness.great;
      break;
    case 2:
      turnMove.moveEffectiveness = MoveEffectiveness.notGood;
      break;
    case 3:
      turnMove.moveEffectiveness = MoveEffectiveness.noEffect;
      break;
    default:
      turnMove.moveEffectiveness = MoveEffectiveness.normal;
      break;
  }
  // realDamage
  turnMove.realDamage = int.parse(turnMoveElements[5]);
  // percentDamage
  turnMove.percentDamage = int.parse(turnMoveElements[6]);
  // moveAdditionalEffect
  switch (int.parse(turnMoveElements[7])) {
    case 1:
      turnMove.moveAdditionalEffect = MoveAdditionalEffect.speedDown;
      break;
    default:
      turnMove.moveAdditionalEffect = MoveAdditionalEffect.none;
      break;
  }
  // changePokemonIndex
  if (turnMoveElements[8] != '') {
    turnMove.changePokemonIndex = int.parse(turnMoveElements[8]);
  }

  return turnMove;
}

List<Turn> parseTurnList(dynamic str) {
  List<Turn> ret = [];
  final turns = str.split(';');
  for (var turn in turns) {
    if (turn == '') break;
    Turn element = Turn();
    final turnElements = turn.split(':');
    // changedOwnPokemon
    if (int.parse(turnElements[0]) != 0) {
      element.changedOwnPokemon = true;
    }
    else {
      element.changedOwnPokemon = false;
    }
    // changedOpponentPokemon
    if (int.parse(turnElements[1]) != 0) {
      element.changedOpponentPokemon = true;
    }
    else {
      element.changedOpponentPokemon = false;
    }
    // initialOwnPokemonIndex
    element.initialOwnPokemonIndex = int.parse(turnElements[2]);
    // initialOpponentPokemonIndex
    element.initialOpponentPokemonIndex = int.parse(turnElements[3]);
    // currentOwnPokemonIndex
    element.currentOwnPokemonIndex = int.parse(turnElements[4]);
    // currentOpponentPokemonIndex
    element.currentOpponentPokemonIndex = int.parse(turnElements[5]);
    // ownPokemonInitialStates
    var states = turnElements[6].split('_');
    for (var state in states) {
      if (state == '') break;
      element.ownPokemonInitialStates.add(parsePokemonState(state, '*', '!', '}'));
    }
    // opponentPokemonInitialStates
    states = turnElements[7].split('_');
    for (var state in states) {
      if (state == '') break;
      element.opponentPokemonInitialStates.add(parsePokemonState(state, '*', '!', '}'));
    }
    // ownPokemonCurrentStates
    states = turnElements[8].split('_');
    for (var state in states) {
      if (state == '') break;
      element.ownPokemonCurrentStates.add(parsePokemonState(state, '*', '!', '}'));
    }
    // opponentPokemonCurrentStates
    states = turnElements[9].split('_');
    for (var state in states) {
      if (state == '') break;
      element.opponentPokemonCurrentStates.add(parsePokemonState(state, '*', '!', '}'));
    }
    // beforeMoveEffects
    var turnEffects = turnElements[10].split('_');
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      TurnEffect effect = TurnEffect();
      final effectElements = turnEffect.split('*');
      // playerType
      switch (int.parse(effectElements[0])) {
        case 1:
          effect.playerType = PlayerType.me;
          break;
        case 2:
          effect.playerType = PlayerType.opponent;
          break;
        default:
          effect.playerType = PlayerType.none;
          break;
      }
      // effect
      switch (int.parse(effectElements[1])) {
        case 1:
          effect.effect = EffectType.ability;
          break;
        case 2:
          effect.effect = EffectType.item;
          break;
        default:
          effect.effect = EffectType.none;
          break;
      }
      // effectId
      effect.effectId = int.parse(effectElements[2]);
      element.beforeMoveEffects.add(effect);
    }
    // turnMove1
    element.turnMove1 = parseTurnMove(turnElements[11], '_', '*');
    // turnMove2
    element.turnMove2 = parseTurnMove(turnElements[12], '_', '*');
    // afterMoveEffects
    turnEffects = turnElements[13].split('_');
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      TurnEffect effect = TurnEffect();
      final effectElements = turnEffect.split('*');
      // playerType
      switch (int.parse(effectElements[0])) {
        case 1:
          effect.playerType = PlayerType.me;
          break;
        case 2:
          effect.playerType = PlayerType.opponent;
          break;
        default:
          effect.playerType = PlayerType.none;
          break;
      }
      // effect
      switch (int.parse(effectElements[1])) {
        case 1:
          effect.effect = EffectType.ability;
          break;
        case 2:
          effect.effect = EffectType.item;
          break;
        default:
          effect.effect = EffectType.none;
          break;
      }
      // effectId
      effect.effectId = int.parse(effectElements[2]);
      element.afterMoveEffects.add(effect);
    }

    ret.add(element);
  }
  return ret;
}

String pokemonStateToStr(PokemonState state, String split1, String split2, String split3) {
  String ret = '';
  // no
  ret += state.no.toString();
  ret += split1;
  // hp
  ret += state.hp.toString();
  ret += split1;
  // hpPercent
  ret += state.hpPercent.toString();
  ret += split1;
  // teraType
  ret += state.teraType.id.toString();
  ret += split1;
  // possibleAbilities
  for (final ability in state.possibleAbilities) {
    // id
    ret += ability.id.toString();
    ret += split3;
    // displayName
    ret += ability.displayName;
    ret += split3;
    // timing
    ret += ability.timing.id.toString();
    ret += split3;
    // target
    ret += ability.target.id.toString();
    ret += split3;
    // effect
    ret += ability.effect.id.toString();

    ret += split2;
  }
  ret += split1;
  // ability
    // id
    ret += state.ability.id.toString();
    ret += split2;
    // displayName
    ret += state.ability.displayName;
    ret += split2;
    // timing
    ret += state.ability.timing.id.toString();
    ret += split2;
    // target
    ret += state.ability.target.id.toString();
    ret += split2;
    // effect
    ret += state.ability.effect.id.toString();
    
    ret += split1;
  // statChanges
  ret += state.statChanges[0].toString();
  for (int i = 1; i < 6; i++) {
    ret += split2;
    ret += state.statChanges[i].toString();
  }
  ret += split1;
  // ailments
  for (final ailment in state.ailments) {
    ret += '0';     // TODO
    ret += split2;
  }
  ret += split1;

  return ret;
}

String turnMoveToStr(TurnMove turnMove, String split1, String split2) {
  String ret = '';
  // playerType
  switch (turnMove.playerType) {
    case PlayerType.me:
      ret += '1';
      ret += split1;
      break;
    case PlayerType.opponent:
      ret += '2';
      ret += split1;
      break;
    default:
      ret += '0';
      ret += split1;
      break;
  }
  // move
    // id
    ret += turnMove.move.id.toString();
    ret += split2;
    // displayName
    ret += turnMove.move.displayName;
    ret += split2;
    // type
    ret += turnMove.move.type.id.toString();
    ret += split2;
    // power
    ret += turnMove.move.power.toString();
    ret += split2;
    // accuracy
    ret += turnMove.move.accuracy.toString();
    ret += split2;
    // priority
    ret += turnMove.move.priority.toString();
    ret += split2;
    // target
    ret += turnMove.move.target.id.toString();
    ret += split2;
    // damageClass
    ret += turnMove.move.damageClass.id.toString();
    ret += split2;
    // effect
    ret += turnMove.move.effect.id.toString();
    ret += split2;
    // effectChance
    ret += turnMove.move.effectChance.toString();
    ret += split2;
    // pp
    ret += turnMove.move.pp.toString();

  ret += split1;
  // isSuccess
  ret += turnMove.isSuccess ? '1' : '0';
  ret += split1;
  // moveHits
  for (final moveHit in turnMove.moveHits) {
    switch (moveHit) {
      case MoveHit.critical:
        ret += '1';
        break;
      case MoveHit.notHit:
        ret += '2';
        break;
      default:
        ret += '0';
        break;
    }
    ret += split2;
  }
  ret += split1;
  // moveEffectiveness
  switch (turnMove.moveEffectiveness) {
    case MoveEffectiveness.great:
      ret += '1';
      break;
    case MoveEffectiveness.notGood:
      ret += '2';
      break;
    case MoveEffectiveness.noEffect:
      ret += '3';
      break;
    default:
      ret += '0';
      break;
  }
  ret += split1;
  // realDamage
  ret += turnMove.realDamage.toString();
  ret += split1;
  // percentDamage
  ret += turnMove.percentDamage.toString();
  ret += split1;
  // moveAdditionalEffect
  switch (turnMove.moveAdditionalEffect) {
    case MoveAdditionalEffect.speedDown:
      ret += '1';
      break;
    default:
      ret += '0';
      break;
  }
  ret += split1;
  // changePokemonIndex
  if (turnMove.changePokemonIndex != null) {
    ret += turnMove.changePokemonIndex.toString();
  }

  return ret;
}

String turnListToStr(List<Turn> turns) {
  String ret = '';
  for (final turn in turns) {
    // changedOwnPokemon
    ret += turn.changedOwnPokemon ? '1' : '0';
    ret += ':';
    // changedOpponentPokemon
    ret += turn.changedOpponentPokemon ? '1' : '0';
    ret += ':';
    // initialOwnPokemonIndex
    ret += turn.initialOwnPokemonIndex.toString();
    ret += ':';
    // initialOpponentPokemonIndex
    ret += turn.initialOpponentPokemonIndex.toString();
    ret += ':';
    // currentOwnPokemonIndex
    ret += turn.currentOwnPokemonIndex.toString();
    ret += ':';
    // currentOpponentPokemonIndex
    ret += turn.currentOpponentPokemonIndex.toString();
    ret += ':';
    // ownPokemonInitialStates
    for (final state in turn.ownPokemonInitialStates) {
      ret += pokemonStateToStr(state, '*', '!', '}');
      ret += '_';
    }
    ret += ':';
    // opponentPokemonInitialStates
    for (final state in turn.opponentPokemonInitialStates) {
      ret += pokemonStateToStr(state, '*', '!', '}');
      ret += '_';
    }
    ret += ':';
    // ownPokemonCurrentStates
    for (final state in turn.ownPokemonCurrentStates) {
      ret += pokemonStateToStr(state, '*', '!', '}');
      ret += '_';
    }
    ret += ':';
    // opponentPokemonCurrentStates
    for (final state in turn.opponentPokemonCurrentStates) {
      ret += pokemonStateToStr(state, '*', '!', '}');
      ret += '_';
    }
    ret += ':';
    // beforeMoveEffects
    for (final turnEffect in turn.beforeMoveEffects) {
      // playerType
      switch (turnEffect.playerType) {
        case PlayerType.me:
          ret += '1';
          ret += '*';
          break;
        case PlayerType.opponent:
          ret += '2';
          ret += '*';
          break;
        default:
          ret += '0';
          ret += '*';
          break;
      }
      // effect
      switch (turnEffect.effect) {
        case EffectType.ability:
          ret += '1';
          ret += '*';
          break;
        case EffectType.item:
          ret += '2';
          ret += '*';
          break;
        default:
          ret += '0';
          ret += '*';
          break;
      }
      // effectId
      ret += turnEffect.effectId.toString();

      ret += '_';
    }
    ret += ':';
    // turnMove1
    ret += turnMoveToStr(turn.turnMove1, '_', '*');
    ret += ':';
    // turnMove2
    ret += turnMoveToStr(turn.turnMove2, '_', '*');
    ret += ':';
    // afterMoveEffects
    for (final turnEffect in turn.afterMoveEffects) {
      // playerType
      switch (turnEffect.playerType) {
        case PlayerType.me:
          ret += '1';
          ret += '*';
          break;
        case PlayerType.opponent:
          ret += '2';
          ret += '*';
          break;
        default:
          ret += '0';
          ret += '*';
          break;
      }
      // effect
      switch (turnEffect.effect) {
        case EffectType.ability:
          ret += '1';
          ret += '*';
          break;
        case EffectType.item:
          ret += '2';
          ret += '*';
          break;
        default:
          ret += '0';
          ret += '*';
          break;
      }
      // effectId
      ret += turnEffect.effectId.toString();

      ret += '_';
    }

    ret += ';';
  }
  return ret;
}

class Battle {
  int id = 0; // 無効値
  String name = '';
  BattleType type = BattleType.rankmatch;
  DateTime datetime = DateTime.now();
  Party ownParty = Party();
  List<PokemonState> ownPokemonStates = [];
  String opponentName = '';
  Party opponentParty = Party();
  List<PokemonState> opponentPokemonStates = [];
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
    return {
      battleColumnId: id,
      battleColumnName: name,
      battleColumnTypeId: type.id,
      battleColumnDate: 0,      // TODO
      battleColumnOwnPartyId: ownParty.id,
      battleColumnOpponentName: opponentName,
      battleColumnOpponentPartyId: opponentParty.id,
//      battleColumnTurns: '0',     // TODO
      battleColumnTurns: turnListToStr(turns),
    };
  }
}

// シングルトンクラス
// TODO: 欠点があるからライブラリを使うべき？ https://zenn.dev/shinkano/articles/c0f392fc3d218c
class PokeDB {
//  Map<int, PokeBase> pokeBase = {};
  static const String pokeApiRoute = "https://pokeapi.co/api/v2";
  
  Map<int, Ability> abilities = {0: Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0))}; // 無効なとくせい
  late Database abilityDb;
  Map<int, Temper> tempers = {0: Temper(0, '', '', '')};  // 無効なせいかく
  late Database temperDb;
  Map<int, Item> items = {};
  late Database itemDb;
  Map<int, Move> moves = {0: Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0)}; // 無効なわざ
  late Database moveDb;
  List<PokeType> types = [
    for (final i in range(1, 19)) PokeType.createFromId(i.toInt())
  ];
  Map<int, PokeBase> pokeBase = {   // 無効なポケモン
    0: PokeBase(
      name: '',
      sex: [Sex.createFromId(0)],
      no: 0, type1: PokeType.createFromId(0),
      type2: null, h: 0, a: 0, b: 0, c: 0, d: 0, s: 0,
      ability: [], move: []),
  };
  late Database pokeBaseDb;
  List<Pokemon> pokemons = [];
  late Database myPokemonDb;
  List<Party> parties = [];
  late Database partyDb;
  List<Battle> battles = [];
  late Database battleDb;

  // DBに使われているIDのリスト。常に降順に並び替えておく
  List<int> myPokemonIDs = [];
  List<int> partyIDs = [];
  List<int> battleIDs = [];

  bool isLoaded = false;

  // コンストラクタ（private）
  PokeDB._internal();
  // インスタンスはただ１つだけ
  static final PokeDB instance = PokeDB._internal();
  // キャッシュしたインスタンスを返す
  factory PokeDB() => instance;

/*
  Future<void> fetchAllAbility() async {
    var res = await http.get(Uri.parse('$pokeApiRoute/ability'));
    if (res.statusCode == 200) {
      var jsonBody = jsonDecode(res.body);
      while (true) {
        // results(デフォルト20件まで)を内部データに変換
        for (var e in jsonBody['results']) {
          final ability = await http.get(Uri.parse(e['url']));
          if (ability.statusCode == 200) {
            final jsonAbility = jsonDecode(ability.body);
            abilities[jsonAbility['id']] = Ability(
              jsonAbility['id'],
              // 日本語見つからんかったら英語名で(orElseでjsonAbility返してるのがミソ)
              jsonAbility['names'].firstWhere((e) => e['language']['name'] == 'ja', orElse: () => jsonAbility)['name']
            );
          } else {
            // 失敗したら無視して次
            // TODO:ログは残す
            continue;
          }
        }

        if (jsonBody['next'] == null) {   // リストを網羅したので終了
          break;
        }

        // 次のURLから取得
        res = await http.get(Uri.parse(jsonBody['next']));
        if (res.statusCode == 200) {
          jsonBody = jsonDecode(res.body);
          continue;
        } else {
          // 失敗したらあきらめる
          // TODO:ログは残す
          break;
        }
      }
    } else {
      throw Exception('Failed to Load Ability');
    }
  }
*/

/*
  Future<void> fetchPokemon(int id) async {
    if (pokeBase[id] != null) {
      return;
    }
    final res = await http.get(Uri.parse('$pokeApiRoute/pokemon/$id'));
    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);
      final speciesURL = jsonBody['species']['url'];
      final species = await http.get(Uri.parse(speciesURL));
      pokeBase[id] = (PokeBase.fromJson(jsonBody, jsonDecode(species.body)));
    } else {
      throw Exception('Failed to Load Pokemon');
    }
  }
*/

  List<int> parseIntList(dynamic str) {
    List<int> ret = [];
    // なぜかintの場合もif文の中に入らないのでtoStringを使う
    if (str is int) {
      return [str];
    }
    final contents = str.split(';');
    for (var c in contents) {
      if (c == '') {
        continue;
      }
      ret.add(int.parse(c));
    }
    return ret;
  }

  Future<void> initialize() async {
    /////////// とくせい
    final abilityDBPath = join(await getDatabasesPath(), abilityDBFile);
    // TODO:アップデート時とかのみ消せばいい。設定から消せるとか、そういうのにしたい。
    await deleteDatabase(abilityDBPath);
    var exists = await databaseExists(abilityDBPath);

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
      print('Creating new copy from asset');

      try {
        await Directory(dirname(abilityDBPath)).create(recursive: true);
      } catch (_) {}

      // アセットからコピー
      ByteData data = await rootBundle.load(join('assets', abilityDBFile));
      List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 書き込まれたバイトを書き込み、フラッシュする
      await File(abilityDBPath).writeAsBytes(bytes, flush: true);
    }
    else {
      print("Opening existing database");
    }

    // SQLiteのDB読み込み
    abilityDb = await openDatabase(abilityDBPath, readOnly: true);
    // 内部データに変換
    List<Map<String, dynamic>> maps = await abilityDb.query(abilityDBTable,
      columns: [abilityColumnId, abilityColumnName, abilityColumnTiming, abilityColumnTarget, abilityColumnEffect],
    );
    for (var map in maps) {
      abilities[map[abilityColumnId]] = Ability(
        map[abilityColumnId],
        map[abilityColumnName],
        AbilityTiming(map[abilityColumnTiming]),
        Target(map[abilityColumnTarget]),
        AbilityEffect(map[abilityColumnEffect]),
      );
    }


    //////////// せいかく
    final temperDBPath = join(await getDatabasesPath(), temperDBFile);
    await deleteDatabase(temperDBPath);
    exists = await databaseExists(temperDBPath);

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
      print('Creating new copy from asset');

      try {
        await Directory(dirname(temperDBPath)).create(recursive: true);
      } catch (_) {}

      // アセットからコピー
      ByteData data = await rootBundle.load(join('assets', temperDBFile));
      List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 書き込まれたバイトを書き込み、フラッシュする
      await File(temperDBPath).writeAsBytes(bytes, flush: true);
    }
    else {
      print("Opening existing database");
    }

    // SQLiteのDB読み込み
    temperDb = await openDatabase(temperDBPath, readOnly: true);
    // 内部データに変換
    maps = await temperDb.query(temperDBTable,
      columns: [temperColumnId, temperColumnName, temperColumnDe, temperColumnIn],
    );
    for (var map in maps) {
      tempers[map[temperColumnId]] = Temper(
        map[temperColumnId],
        map[temperColumnName],
        map[temperColumnDe],
        map[temperColumnIn],
      );
    }


    //////////// もちもの
    final itemDBPath = join(await getDatabasesPath(), itemDBFile);
    await deleteDatabase(itemDBPath);
    exists = await databaseExists(itemDBPath);

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
      print('Creating new copy from asset');

      try {
        await Directory(dirname(itemDBPath)).create(recursive: true);
      } catch (_) {}

      // アセットからコピー
      ByteData data = await rootBundle.load(join('assets', itemDBFile));
      List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 書き込まれたバイトを書き込み、フラッシュする
      await File(itemDBPath).writeAsBytes(bytes, flush: true);
    }
    else {
      print("Opening existing database");
    }

    // SQLiteのDB読み込み
    itemDb = await openDatabase(itemDBPath, readOnly: true);
    // 内部データに変換
    maps = await itemDb.query(itemDBTable,
      columns: [itemColumnId, itemColumnName],
    );
    for (var map in maps) {
      items[map[itemColumnId]] = Item(
        map[itemColumnId],
        map[itemColumnName],
      );
    }


    //////////// わざ
    final moveDBPath = join(await getDatabasesPath(), moveDBFile);
    await deleteDatabase(moveDBPath);
    exists = await databaseExists(moveDBPath);

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
      print('Creating new copy from asset');

      try {
        await Directory(dirname(moveDBPath)).create(recursive: true);
      } catch (_) {}

      // アセットからコピー
      ByteData data = await rootBundle.load(join('assets', moveDBFile));
      List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 書き込まれたバイトを書き込み、フラッシュする
      await File(moveDBPath).writeAsBytes(bytes, flush: true);
    }
    else {
      print("Opening existing database");
    }

    // SQLiteのDB読み込み
    moveDb = await openDatabase(moveDBPath, readOnly: true);
    // 内部データに変換
    maps = await moveDb.query(moveDBTable,
      columns: [moveColumnId, moveColumnName, moveColumnType, moveColumnPower, moveColumnAccuracy, moveColumnPriority, moveColumnTarget, moveColumnDamageClass, moveColumnEffect, moveColumnEffectChance, moveColumnPP],
    );
    for (var map in maps) {
      moves[map[moveColumnId]] = Move(
        map[moveColumnId],
        map[moveColumnName],
        PokeType.createFromId(map[moveColumnType]),
        map[moveColumnPower],
        map[moveColumnAccuracy],
        map[moveColumnPriority],
        Target(map[moveColumnTarget]),
        DamageClass(map[moveColumnDamageClass]),
        MoveEffect(map[moveColumnEffect]),
        map[moveColumnEffectChance],
        map[moveColumnPP],
      );
    }

    //////////// ポケモン図鑑
    final pokeBaseDBPath = join(await getDatabasesPath(), pokeBaseDBFile);
    await deleteDatabase(pokeBaseDBPath);
    exists = await databaseExists(pokeBaseDBPath);

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
      print('Creating new copy from asset');

      try {
        await Directory(dirname(pokeBaseDBPath)).create(recursive: true);
      } catch (_) {}

      // アセットからコピー
      ByteData data = await rootBundle.load(join('assets', pokeBaseDBFile));
      List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 書き込まれたバイトを書き込み、フラッシュする
      await File(pokeBaseDBPath).writeAsBytes(bytes, flush: true);
    }
    else {
      print("Opening existing database");
    }

    // SQLiteのDB読み込み
    pokeBaseDb = await openDatabase(pokeBaseDBPath, readOnly: true);
    // 内部データに変換
    maps = await pokeBaseDb.query(pokeBaseDBTable,
      columns: [
        pokeBaseColumnId, pokeBaseColumnName, pokeBaseColumnAbility,
        pokeBaseColumnForm, pokeBaseColumnFemaleRate, pokeBaseColumnMove,
        for (var e in pokeBaseColumnStats) e,
        pokeBaseColumnType],
    );

    for (var map in maps) {
      final pokeTypes = parseIntList(map[pokeBaseColumnType]);
      final pokeAbilities = parseIntList(map[pokeBaseColumnAbility]);
      final pokeMoves = parseIntList(map[pokeBaseColumnMove]);
      List<Sex> sexList = [];
      if (map[pokeBaseColumnFemaleRate] == -1) {
        sexList = [Sex.none];
      }
      else if (map[pokeBaseColumnFemaleRate] == 8) {
        sexList = [Sex.female];
      }
      else if (map[pokeBaseColumnFemaleRate] == 0) {
        sexList = [Sex.male];
      }
      else {
        sexList = [Sex.male, Sex.female];
      }
      pokeBase[map[pokeBaseColumnId]] = PokeBase(
        name: map[pokeBaseColumnName],
        sex: sexList,
        no: map[pokeBaseColumnId],
        type1: PokeType.createFromId(pokeTypes[0]),
        type2: (pokeTypes.length > 1) ? PokeType.createFromId(pokeTypes[1]) : null,
        h: map[pokeBaseColumnStats[0]],
        a: map[pokeBaseColumnStats[1]],
        b: map[pokeBaseColumnStats[2]],
        c: map[pokeBaseColumnStats[3]],
        d: map[pokeBaseColumnStats[4]],
        s: map[pokeBaseColumnStats[5]],
        ability: [for (var e in pokeAbilities) abilities[e]!],
        move: [for (var e in pokeMoves) moves[e]!],
      );
    }

    //////////// 登録したポケモン
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    //await deleteDatabase(myPokemonDBPath);
    exists = await databaseExists(myPokemonDBPath);

    if (!exists) {
      try {
        await Directory(dirname(myPokemonDBPath)).create(recursive: true);
      } catch (_) {}

      await _createMyPokemonDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);
      // 内部データに変換
      maps = await myPokemonDb.query(myPokemonDBTable,
        columns: [
          myPokemonColumnId, myPokemonColumnNo, myPokemonColumnNickName,
          myPokemonColumnTeraType, myPokemonColumnLevel,
          myPokemonColumnSex, myPokemonColumnTemper,
          myPokemonColumnAbility, myPokemonColumnItem,
          for (var e in myPokemonColumnIndividual) e,
          for (var e in myPokemonColumnEffort) e,
          myPokemonColumnMove1, myPokemonColumnPP1,
          myPokemonColumnMove2, myPokemonColumnPP2,
          myPokemonColumnMove3, myPokemonColumnPP3,
          myPokemonColumnMove4, myPokemonColumnPP4,
          myPokemonColumnOwnerID, myPokemonColumnRefCount,
        ],
      );

      for (var map in maps) {
        int pokeNo = map[myPokemonColumnNo];
        pokemons.add(Pokemon()
          ..id = map[myPokemonColumnId]
          ..name = pokeBase[pokeNo]!.name
          ..nickname = map[myPokemonColumnNickName]
          ..level = map[myPokemonColumnLevel]
          ..sex = Sex.createFromId(map[myPokemonColumnSex])
          ..no = pokeNo
          ..type1 = pokeBase[pokeNo]!.type1
          ..type2 = pokeBase[pokeNo]!.type2
          ..teraType = PokeType.createFromId(map[myPokemonColumnTeraType])
          ..temper = tempers[map[myPokemonColumnTemper]]!
          ..h = SixParams(
            pokeBase[pokeNo]!.h,
            map[myPokemonColumnIndividual[0]],
            map[myPokemonColumnEffort[0]],
            0)
          ..a = SixParams(
            pokeBase[pokeNo]!.a,
            map[myPokemonColumnIndividual[1]],
            map[myPokemonColumnEffort[1]],
            0)
          ..b = SixParams(
            pokeBase[pokeNo]!.b,
            map[myPokemonColumnIndividual[2]],
            map[myPokemonColumnEffort[2]],
            0)
          ..c = SixParams(
            pokeBase[pokeNo]!.c,
            map[myPokemonColumnIndividual[3]],
            map[myPokemonColumnEffort[3]],
            0)
          ..d = SixParams(
            pokeBase[pokeNo]!.d,
            map[myPokemonColumnIndividual[4]],
            map[myPokemonColumnEffort[4]],
            0)
          ..s = SixParams(
            pokeBase[pokeNo]!.s,
            map[myPokemonColumnIndividual[5]],
            map[myPokemonColumnEffort[5]],
            0)
          ..ability = abilities[map[myPokemonColumnAbility]]!
          ..item = (map[myPokemonColumnItem] != null) ? Item(map[myPokemonColumnItem], '') : null
          ..move1 = moves[map[myPokemonColumnMove1]]!
          ..pp1 = map[myPokemonColumnPP1]
          ..move2 = map[myPokemonColumnMove2] != null ? moves[map[myPokemonColumnMove2]]! : null
          ..pp2 = map[myPokemonColumnPP2]
          ..move3 = map[myPokemonColumnMove3] != null ? moves[map[myPokemonColumnMove3]]! : null
          ..pp3 = map[myPokemonColumnPP3]
          ..move4 = map[myPokemonColumnMove4] != null ? moves[map[myPokemonColumnMove4]]! : null
          ..pp4 = map[myPokemonColumnPP4]
          ..owner = toOwner(map[myPokemonColumnOwnerID])
          ..refCount = map[myPokemonColumnRefCount]
          ..updateRealStats()
        );
        myPokemonIDs.add(map[myPokemonColumnId]);
      }
      myPokemonIDs.sort((a, b) => a.compareTo(b));
    }

    //////////// 登録したパーティ
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    //await deleteDatabase(partyDBPath);
    exists = await databaseExists(partyDBPath);

    if (!exists) {
      try {
        await Directory(dirname(partyDBPath)).create(recursive: true);
      } catch (_) {}

      await _createPartyDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath, readOnly: false);
      // 内部データに変換
      maps = await partyDb.query(partyDBTable,
        columns: [
          partyColumnId, partyColumnName,
          partyColumnPokemonId1, partyColumnPokemonItem1,
          partyColumnPokemonId2, partyColumnPokemonItem2,
          partyColumnPokemonId3, partyColumnPokemonItem3,
          partyColumnPokemonId4, partyColumnPokemonItem4,
          partyColumnPokemonId5, partyColumnPokemonItem5,
          partyColumnPokemonId6, partyColumnPokemonItem6,
          partyColumnOwnerID, partyColumnRefCount,
        ],
      );

      for (var map in maps) {
        parties.add(Party()
          ..id = map[partyColumnId]
          ..name = map[partyColumnName]
          ..pokemon1 = pokemons.where((element) => element.id == map[partyColumnPokemonId1]).first
          ..item1 = map[partyColumnPokemonItem1] != null ? items[map[partyColumnPokemonItem1]] : null
          ..pokemon2 = map[partyColumnPokemonId2] != null ?
              pokemons.where((element) => element.id == map[partyColumnPokemonId2]).first : null
          ..item2 = map[partyColumnPokemonItem2] != null ? items[map[partyColumnPokemonItem2]] : null
          ..pokemon3 = map[partyColumnPokemonId3] != null ?
              pokemons.where((element) => element.id == map[partyColumnPokemonId3]).first : null
          ..item3 = map[partyColumnPokemonItem3] != null ? items[map[partyColumnPokemonItem3]] : null
          ..pokemon4 = map[partyColumnPokemonId4] != null ?
              pokemons.where((element) => element.id == map[partyColumnPokemonId4]).first : null
          ..item4 = map[partyColumnPokemonItem4] != null ? items[map[partyColumnPokemonItem4]] : null
          ..pokemon5 = map[partyColumnPokemonId5] != null ?
              pokemons.where((element) => element.id == map[partyColumnPokemonId5]).first : null
          ..item5 = map[partyColumnPokemonItem5] != null ? items[map[partyColumnPokemonItem5]] : null
          ..pokemon6 = map[partyColumnPokemonId6] != null ?
              pokemons.where((element) => element.id == map[partyColumnPokemonId6]).first : null
          ..item6 = map[partyColumnPokemonItem6] != null ? items[map[partyColumnPokemonItem6]] : null
          ..owner = toOwner(map[partyColumnOwnerID])
        );
        partyIDs.add(map[partyColumnId]);
      }
      partyIDs.sort((a, b) => a.compareTo(b));
    }

    //////////// 登録した対戦
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    //await deleteDatabase(battleDBPath);
    exists = await databaseExists(battleDBPath);

    if (!exists) {
      try {
        await Directory(dirname(battleDBPath)).create(recursive: true);
      } catch (_) {}

      await _createBattleDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath, readOnly: false);
      // 内部データに変換
      maps = await battleDb.query(battleDBTable,
        columns: [
          battleColumnId, battleColumnName, battleColumnTypeId,
          battleColumnDate, battleColumnOwnPartyId,
          battleColumnOpponentName, battleColumnOpponentPartyId,
          battleColumnTurns,
        ],
      );

      for (var map in maps) {
        battles.add(Battle()
          ..id = map[battleColumnId]
          ..name = map[battleColumnName]
          ..type = BattleType.createFromId(map[battleColumnTypeId])
          //..datetime = map[battleColumnDate]    // TODO
          ..ownParty = parties.where((element) => element.id == map[battleColumnOwnPartyId]).first
          ..opponentName = map[battleColumnOpponentName]
          ..opponentParty = parties.where((element) => element.id == map[battleColumnOpponentPartyId]).first
          ..turns = parseTurnList(map[battleColumnTurns])
        );
        battleIDs.add(map[battleColumnId]);
      }
      battleIDs.sort((a, b) => a.compareTo(b));
    }


    isLoaded = true;

/*  TODO: assetsから読まない場合も検討（下記コードは動作未保障）
    abilityDb = await openDatabase(
      join(await getDatabasesPath(), abilityDBFile),    // TODO:iOSだとパスが良くない？ https://zenn.dev/beeeyan/articles/b9f1b42de9cb67
      version: 1, // onCreateを指定する場合はバージョンを指定する
      onCreate: (db, version) async {
        await fetchAllAbility();
        for (int id = 1; id <= 10; id++) {
          await fetchPokemon(id);
        }
        // とくせいのDB作成
        await db.execute(
          'CREATE TABLE $abilityDBTable ('
          '  $abilityColumnId interger primary key,'
          '  $abilityColumnName text not null)'
        );
        for (var ability in abilities) {
          await db.insert(abilityDBTable, ability.toMap());
        }
        isLoaded = true;
      },
    );
    if (!isLoaded) {  // 読み込んだDBから内部データに変換(TODO: いる？)
      List<Map<String, dynamic>> maps = await abilityDb.query(abilityDBTable,
        columns: [abilityColumnId, abilityColumnName],
      );
      for (var map in maps) {
        abilities.add(Ability(
          map[abilityColumnId],
          map[abilityColumnName]
        ));
      }
      isLoaded = true;
    }
*/
  }

  int getUniqueMyPokemonID() {
    int ret = 1;
    for (final e in myPokemonIDs) {
      if (e > ret) break;
      ret++;
    }
    assert(ret <= 0xffffffff);
    return ret;
  }

  int getUniquePartyID() {
    int ret = 1;
    for (final e in partyIDs) {
      if (e > ret) break;
      ret++;
    }
    assert(ret <= 0xffffffff);
    return ret;
  }

  int getUniqueBattleID() {
    int ret = 1;
    for (final e in battleIDs) {
      if (e > ret) break;
      ret++;
    }
    assert(ret <= 0xffffffff);
    return ret;
  }

  Future<void> addMyPokemon(Pokemon myPokemon) async {
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    var exists = await databaseExists(myPokemonDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      try {
        await Directory(dirname(myPokemonDBPath)).create(recursive: true);
      } catch (_) {}

      myPokemonDb = await _createMyPokemonDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);
    }

    // DBのIDリストを更新
    myPokemonIDs.add(myPokemon.id);
    myPokemonIDs.sort((a, b) => a.compareTo(b));

    // SQLiteのDBに挿入
    await myPokemonDb.insert(
      myPokemonDBTable,
      myPokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMyPokemon(List<int> ids, bool remainRelations) async {
    //assert(ids.isNotEmpty);
    if (ids.isEmpty) return;
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);

    if (remainRelations) {
      // TODO
    }
    else {
      String whereStr = '$myPokemonColumnId=?';
      for (int i = 1; i < ids.length; i++) {
        whereStr += ' OR $myPokemonColumnId=?';
      }
      
      // 登録ポケモンリストから削除
      for (final e in ids) {
        pokemons.removeWhere((element) => element.id == e);
      }

      // DBのIDリストから削除
      for (final e in ids) {
        myPokemonIDs.remove(e);
      }

      // SQLiteのDBから削除
      await myPokemonDb.delete(
        myPokemonDBTable,
        where: whereStr,
        whereArgs: ids,
      );

      // 各パーティに、削除したポケモンが含まれているか調べる
      List<int> partyIDs = [];
      for (final e in parties) {
        for (int i = 0; i < e.pokemonNum; i++) {
          if (ids.contains(e.pokemons[i]?.id)) {
            partyIDs.add(e.id);
            break;
          }
        }
      }
      deleteParty(partyIDs, false);
    }
  }

  Future<void> updateMyPokemonRefCounts() async {
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);

    String whereStr = '$myPokemonColumnId=?';

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    for (final e in pokemons) {
      await myPokemonDb.update(
        myPokemonDBTable,
        {myPokemonColumnRefCount: e.refCount},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

/*
  Future<void> recreateMyPokemon(List<Pokemon> pokemons) async {
    // ID振り直しとかするの面倒だから表を一旦消してしまって整理しなおせばよいという方針
    // TODO:これでいいのか？

    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);
    
    // SQLiteのDB表ごと削除
    await myPokemonDb.delete(
      myPokemonDBTable,
    );

    // 表再作成
    myPokemonDb = await _createMyPokemonDB();

    // 登録ポケモンのID振り直し & DBに登録
    for (int i = 0; i < pokemons.length; i++) {
      pokemons[i].id = i + 1;
      await myPokemonDb.insert(
        myPokemonDBTable,
        pokemons[i].toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
*/

  Future<void> addParty(Party party) async {
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    var exists = await databaseExists(partyDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      try {
        await Directory(dirname(partyDBPath)).create(recursive: true);
      } catch (_) {}

      partyDb = await _createPartyDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath, readOnly: false);
    }

    // パーティ内ポケモンの被参照カウントをインクリメント
    for (int i = 0; i < party.pokemonNum; i++) {
      party.pokemons[i]!.refCount++;
    }

    // DBのIDリストを更新
    partyIDs.add(party.id);
    partyIDs.sort((a, b) => a.compareTo(b));

    // SQLiteのDBに挿入
    await partyDb.insert(
      partyDBTable,
      party.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // refCountの更新をデータベースに反映
    await updateMyPokemonRefCounts();
  }

  Future<void> deleteParty(List<int> ids, bool remainRelations) async {
    //assert(ids.isNotEmpty);
    if (ids.isEmpty) return;
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath, readOnly: false);

    if (remainRelations) {
      // TODO
    }
    else {
      String whereStr = '$partyColumnId=?';
      for (int i = 1; i < ids.length; i++) {
        whereStr += ' OR $partyColumnId=?';
      }

      // 登録パーティリストから削除
      for (final e in ids) {
        final partyIdx = parties.indexWhere((element) => element.id == e);
        // パーティ内ポケモンの被参照カウントをデクリメント
        for (int j = 0; j < parties[partyIdx].pokemonNum; j++) {
          parties[partyIdx].pokemons[j]!.refCount--;
        }
        parties.removeAt(partyIdx);
      }
      
      // DBのIDリストから削除
      for (final e in ids) {
        partyIDs.remove(e);
      }

      // SQLiteのDBから削除
      await partyDb.delete(
        partyDBTable,
        where: whereStr,
        whereArgs: ids,
      );

      // refCountの更新をデータベースに反映
      await updateMyPokemonRefCounts();

      // 各対戦に、削除したパーティが含まれているか調べる
      List<int> battleIDs = [];
      for (final e in battles) {
        if (ids.contains(e.ownParty.id) || ids.contains(e.opponentParty.id)) {
          battleIDs.add(e.id);
          break;
        }
      }
      deleteBattle(battleIDs);
    }
  }

  Future<void> updatePartyRefCounts() async {
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath, readOnly: false);

    String whereStr = '$partyColumnId=?';

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    for (final e in parties) {
      await partyDb.update(
        partyDBTable,
        {partyColumnRefCount: e.refCount},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> addBattle(Battle battle) async {
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    var exists = await databaseExists(battleDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      try {
        await Directory(dirname(battleDBPath)).create(recursive: true);
      } catch (_) {}

      battleDb = await _createBattleDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath, readOnly: false);
    }

    // 対戦内パーティの被参照カウントをインクリメント
    // TODO:毎回やってたらダメ
    battle.ownParty.refCount++;
    battle.opponentParty.refCount++;

    // DBのIDリストを更新
    battleIDs.add(battle.id);
    battleIDs.sort((a, b) => a.compareTo(b));

    // SQLiteのDBに挿入
    await battleDb.insert(
      battleDBTable,
      battle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // refCountの更新をデータベースに反映
    await updatePartyRefCounts();
  }

  Future<void> deleteBattle(List<int> ids) async {
    //assert(ids.isNotEmpty);
    if (ids.isEmpty) return;
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    assert(await databaseExists(battleDBPath));

    // SQLiteのDB読み込み
    battleDb = await openDatabase(battleDBPath, readOnly: false);

    String whereStr = '$battleColumnId=?';
    for (int i = 1; i < ids.length; i++) {
      whereStr += ' OR $battleColumnId=?';
    }
    
    // 登録対戦リストから削除
    for (final e in ids) {
      battles.removeWhere((element) => element.id == e);
    }

    // DBのIDリストから削除
    for (final e in ids) {
      battleIDs.remove(e);
    }

    // SQLiteのDBから削除
    await battleDb.delete(
      battleDBTable,
      where: whereStr,
      whereArgs: ids,
    );
  }

/*
  Future<void> recreateParty(List<Party> parties) async {
    // ID振り直しとかするの面倒だから表を一旦消してしまって整理しなおせばよいという方針
    // TODO:これでいいのか？

    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath, readOnly: false);
    
    // SQLiteのDB表ごと削除
    await partyDb.delete(
      partyDBTable,
    );

    // 表再作成
    partyDb = await _createPartyDB();

    // 登録パーティのID振り直し & DBに登録
    for (int i = 0; i < parties.length; i++) {
      parties[i].id = i + 1;
      await partyDb.insert(
        partyDBTable,
        parties[i].toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
*/

  Future<Database> _createMyPokemonDB() async {
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);

    // SQLiteのDB作成
    return openDatabase(
      myPokemonDBPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $myPokemonDBTable('
          '$myPokemonColumnId INTEGER PRIMARY KEY, '
          '$myPokemonColumnNo INTEGER, '
          '$myPokemonColumnNickName TEXT, '
          '$myPokemonColumnTeraType INTEGER, '
          '$myPokemonColumnLevel INTEGER, '
          '$myPokemonColumnSex INTEGER, '
          '$myPokemonColumnTemper INTEGER, '
          '$myPokemonColumnAbility INTEGER, '
          '$myPokemonColumnItem INTEGER, '
          '${myPokemonColumnIndividual[0]} INTEGER, '
          '${myPokemonColumnIndividual[1]} INTEGER, '
          '${myPokemonColumnIndividual[2]} INTEGER, '
          '${myPokemonColumnIndividual[3]} INTEGER, '
          '${myPokemonColumnIndividual[4]} INTEGER, '
          '${myPokemonColumnIndividual[5]} INTEGER, '
          '${myPokemonColumnEffort[0]} INTEGER, '
          '${myPokemonColumnEffort[1]} INTEGER, '
          '${myPokemonColumnEffort[2]} INTEGER, '
          '${myPokemonColumnEffort[3]} INTEGER, '
          '${myPokemonColumnEffort[4]} INTEGER, '
          '${myPokemonColumnEffort[5]} INTEGER, '
          '$myPokemonColumnMove1 INTEGER, '
          '$myPokemonColumnPP1 INTEGER, '
          '$myPokemonColumnMove2 INTEGER, '
          '$myPokemonColumnPP2 INTEGER, '
          '$myPokemonColumnMove3 INTEGER, '
          '$myPokemonColumnPP3 INTEGER, '
          '$myPokemonColumnMove4 INTEGER, '
          '$myPokemonColumnPP4 INTEGER, '
          '$myPokemonColumnOwnerID INTEGER, '
          '$myPokemonColumnRefCount INTEGER)'
        );
      }
    );
  }

  Future<Database> _createPartyDB() async {
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);

    // SQLiteのDB作成
    return openDatabase(
      partyDBPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $partyDBTable('
          '$partyColumnId INTEGER PRIMARY KEY, '
          '$partyColumnName TEXT, '
          '$partyColumnPokemonId1 INTEGER, '
          '$partyColumnPokemonItem1 INTEGER, '
          '$partyColumnPokemonId2 INTEGER, '
          '$partyColumnPokemonItem2 INTEGER, '
          '$partyColumnPokemonId3 INTEGER, '
          '$partyColumnPokemonItem3 INTEGER, '
          '$partyColumnPokemonId4 INTEGER, '
          '$partyColumnPokemonItem4 INTEGER, '
          '$partyColumnPokemonId5 INTEGER, '
          '$partyColumnPokemonItem5 INTEGER, '
          '$partyColumnPokemonId6 INTEGER, '
          '$partyColumnPokemonItem6 INTEGER, '
          '$partyColumnOwnerID INTEGER, '
          '$partyColumnRefCount INTEGER)'
        );
      }
    );
  }

  Future<Database> _createBattleDB() async {
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);

    // SQLiteのDB作成
    return openDatabase(
      battleDBPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $battleDBTable('
          '$battleColumnId INTEGER PRIMARY KEY, '
          '$battleColumnName TEXT, '
          '$battleColumnTypeId INTEGER, '
          '$battleColumnDate INTEGER, '     // TODO
          '$battleColumnOwnPartyId INTEGER, '
          '$battleColumnOpponentName TEXT, '
          '$battleColumnOpponentPartyId INTEGER, '
          '$battleColumnTurns TEXT)'
        );
      }
    );
  }
}
