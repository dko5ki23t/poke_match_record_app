import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/tool.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

const String errorFileName = 'errorFile.db';
const String errorString = 'errorString';

const String configKeyPokemonsOwnerFilter = 'pokemonsOwnerFilter';
const String configKeyPokemonsTypeFilter = 'pokemonsTypeFilter';
const String configKeyPokemonsTeraTypeFilter = 'pokemonsTeraTypeFilter';
const String configKeyPokemonsMoveFilter = 'pokemonsMoveFilter';
const String configKeyPokemonsSexFilter = 'pokemonsSexFilter';
const String configKeyPokemonsAbilityFilter = 'pokemonsAbilityFilter';
const String configKeyPokemonsTemperFilter = 'pokemonsTemperFilter';

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
const String itemColumnTiming = 'timing';

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
const int pokemonMaxEffortTotal = 510;

// SQLのDatabaseにListやclassをserializeして保存する際に区切りとして使う文字
const String sqlSplit1 = ';';
const String sqlSplit2 = ':';
const String sqlSplit3 = '_';
const String sqlSplit4 = '*';
const String sqlSplit5 = '!';
const String sqlSplit6 = '}';
const String sqlSplit7 = '{';

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

class PlayerType {
  static const int none = 0;
  static const int me = 1;          // 自身
  static const int opponent = 2;    // 相手
  static const int entireField = 3; // 全体の場(両者に影響あり)

  const PlayerType(this.id);

  PlayerType get opposite {
    assert(id == me || id == opponent);
    return id == me ? PlayerType(opponent) : PlayerType(me);
  }

  final int id;
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

  // SQLに保存された文字列からSixParamsをパース
  static SixParams deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return SixParams(
      int.parse(elements[0]),
      int.parse(elements[1]),
      int.parse(elements[2]),
      int.parse(elements[3]),
    );
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$race$split1$indi$split1$effort$split1$real';
  }
}


// 対象
class Target {
/*
  // わざの対象から引用
  none(0),
  specificMove(1),
  selectedPokemonMeFirst(2),
  ally(3),                      // 味方
  usersField(4),                // 自分の場
  userOrAlly(5),                // 自分自身or味方
  opponentsField(6),            // 相手の場
  user(7),                      // 自分自身
  randomOpponent(8),            // ランダムな相手
  allOtherPokemon(9),           // 他のすべてのポケモン
  selectedPokemon(10),          // 選択した相手
  allOpponents(11),             // すべての相手ポケモン
  entireField(12),              // 両者の場
  userAndAllies(13),            // 自分自身とすべての味方
  allPokemon(14),               // すべてのポケモン 
  allAllies(15),                // すべての味方
  faintingPokemon(16),          // ひんしになったポケモン
  ;
*/

  const Target(this.id);

  final int id;
}

// 効果
class AbilityEffect {
  const AbilityEffect(this.id);

  final int id;
}

// 効果
class MoveEffect {
  static const int none = 0;
  // IDはpokeAPIのmove_effect_idに対応

  const MoveEffect(this.id);

  final int id;
}

class Ability {
  final int id;
  final String displayName;
  final AbilityTiming timing;
  final Target target;
  final AbilityEffect effect;
//  final int chance;               // 発動確率

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

  // 交換可能なとくせいかどうか
  bool get canExchange {
    const ids = [
      225, 248, 149, 241, 256, 208, 266, 211, 161, 209,
      176, 258, 25,
    ];
    return !ids.contains(id);
  }

  // TODO
  // コピー可能なとくせいかどうか
  bool get canCopy {
    const ids = [
      225, 248, 149, 241, 256, 208, 266, 211, 161, 209,
      176, 258, 25,
    ];
    return !ids.contains(id);
  }

  // SQLに保存された文字列からabilityをパース
  static Ability deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Ability(
      int.parse(elements[0]),
      elements[1],
      AbilityTiming(int.parse(elements[2])),
      Target(int.parse(elements[3])),
      AbilityEffect(int.parse(elements[4]))
    );
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$displayName$split1${timing.id}$split1${target.id}$split1${effect.id}';
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

  bool get isDirect {   // 直接攻撃かどうか
    const physicalButNot = [
      843, 788, 895, 621, 856, 88, 157, 479, 783, 854, 780, 662,
      317, 439, 616, 559, 454, 420, 143, 614, 615, 864, 89, 363,
      523, 120, 708, 90, 799, 794, 444, 328, 221, 897, 153, 833,
      591, 441, 402, 331, 41, 121, 140, 619, 556, 333, 893, 851,
      40, 839, 131, 751, 778, 870, 374, 6, 896, 75, 572, 290, 836,
      899, 364, 722, 251, 553, 824, 217, 198, 898, 809, 125, 155,
      900, 222, 443, 42, 594, 368, 350,
    ];
    const specialButNot = [
      879, 376, 447, 378, 577, 80, 611,
    ];
    return (
      (damageClass.id == DamageClass.physical && !physicalButNot.contains(id)) ||
      (damageClass.id == DamageClass.special && !specialButNot.contains(id))
    );
  }

  bool get isSound {   // 音技かどうか
    const soundMoveIDs = [
      547, 173, 215, 103, 47, 664, 497, 786, 448, 568, 319, 320,
      253, 691, 575, 775, 10016, 574, 48, 336, 590, 45, 555, 304,
      586, 826, 871, 728, 46, 195, 405, 496,
    ];
    return soundMoveIDs.contains(id);
  }

  bool get isDrain {   // HP吸収わざかどうか
    const drainMoveIDs = [
      202, 141, 71, 72, 73, 138, 409, 532, 613, 577, 570, 668, 891,
    ];
    return drainMoveIDs.contains(id);
  }

  bool get isPunch {  // パンチわざかどうか
    const punchMoveIDs = [
      359, 665, 817, 9, 264, 612, 309, 857, 325, 818, 327, 742, 409,
      223, 418, 146, 838, 721, 889, 7, 183, 5, 8, 4,
    ];
    return punchMoveIDs.contains(id);
  }

  bool get isDance {  // おどりわざかどうか
    const danceMoveIDs = [
      872, 837, 775, 483, 14, 80, 297, 298, 552, 461, 686, 349,
    ];
    return danceMoveIDs.contains(id);
  }

  Move(
    this.id, this.displayName, this.type, this.power,
    this.accuracy, this.priority, this.target,
    this.damageClass, this.effect, this.effectChance, this.pp,
  );

  Move copyWith() =>
    Move(id, displayName, type, power,
      accuracy, priority, target,
      damageClass, effect, effectChance, pp,);

  // 連続こうげきの場合、その最大回数を返す（連続こうげきではない場合は1を返す）
  int maxMoveCount() {
    if (effect.id == 30) return 5;
    if (effect.id == 45) return 2;
    if (effect.id == 78) return 2;
    if (effect.id == 105) return 3;
    if (effect.id == 155) return 6;
    if (effect.id == 361) return 5;
    if (effect.id == 428) return 2;
    if (effect.id == 443) return 5;
    return 1;
  }

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

// シングルトンクラス
// TODO: 欠点があるからライブラリを使うべき？ https://zenn.dev/shinkano/articles/c0f392fc3d218c
class PokeDB {
//  Map<int, PokeBase> pokeBase = {};
  static const String pokeApiRoute = "https://pokeapi.co/api/v2";

  // 設定等を保存する(端末の)ファイル
  late final File _saveDataFile;
  List<Owner> pokemonsOwnerFilter = [Owner.mine];
  List<int> pokemonsTypeFilter = [for (int i = 1; i < 19; i++) i];
  List<int> pokemonsTeraTypeFilter = [for (int i = 1; i < 19; i++) i];
  List<int> pokemonsMoveFilter = [];
  List<Sex> pokemonsSexFilter = Sex.values;
  List<int> pokemonsAbilityFilter = [];
  List<int> pokemonsTemperFilter = [];

  Map<int, Ability> abilities = {0: Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0))}; // 無効なとくせい
  late Database abilityDb;
  Map<int, Temper> tempers = {0: Temper(0, '', '', '')};  // 無効なせいかく
  late Database temperDb;
  Map<int, Item> items = {0: Item(0, '', AbilityTiming(0))};  // 無効なもちもの
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

  List<int> parseIntList(dynamic str) {
    List<int> ret = [];
    // なぜかintの場合もif文の中に入らないのでtoStringを使う
    if (str is int) {
      return [str];
    }
    final contents = str.split(sqlSplit1);
    for (var c in contents) {
      if (c == '') {
        continue;
      }
      ret.add(int.parse(c));
    }
    return ret;
  }

  Future<void> initialize() async {
    /////////// 各種設定
    String localPath ='';
    if (kIsWeb) {
      // Web appでは一旦各種設定の保存はできないこととする
      //localPath = 'assets/data';
    }
    else {
      final directory = await getApplicationDocumentsDirectory();
      localPath = directory.path;
      _saveDataFile = File('$localPath/poke_reco.json');
      try {
        final configText = await _saveDataFile.readAsString();
        final configJson = jsonDecode(configText);
        pokemonsOwnerFilter = [];
        for (final e in configJson[configKeyPokemonsOwnerFilter]) {
          switch (e) {
            case 0:
              pokemonsOwnerFilter.add(Owner.mine);
              break;
            case 1:
              pokemonsOwnerFilter.add(Owner.fromBattle);
              break;
            case 2:
            default:
              pokemonsOwnerFilter.add(Owner.hidden);
              break;
          }
        }
        pokemonsTypeFilter = [];
        for (final e in configJson[configKeyPokemonsTypeFilter]) {
          pokemonsTypeFilter.add(e as int);
        }
        pokemonsTeraTypeFilter = [];
        for (final e in configJson[configKeyPokemonsTeraTypeFilter]) {
          pokemonsTeraTypeFilter.add(e as int);
        }
        pokemonsMoveFilter = [];
        for (final e in configJson[configKeyPokemonsMoveFilter]) {
          pokemonsMoveFilter.add(e as int);
        }
        pokemonsSexFilter = [];
        for (final e in configJson[configKeyPokemonsSexFilter]) {
          switch (e) {
            case 1:
              pokemonsSexFilter.add(Sex.male);
              break;
            case 2:
              pokemonsSexFilter.add(Sex.female);
              break;
            case 0:
            default:
              pokemonsSexFilter.add(Sex.none);
              break;
          }
        }
        pokemonsAbilityFilter = [];
        for (final e in configJson[configKeyPokemonsAbilityFilter]) {
          pokemonsAbilityFilter.add(e as int);
        }
        pokemonsTemperFilter = [];
        for (final e in configJson[configKeyPokemonsTemperFilter]) {
          pokemonsTemperFilter.add(e as int);
        }
      }
      catch (e) {
        pokemonsOwnerFilter = [Owner.mine];
        pokemonsTypeFilter = [for (int i = 1; i < 19; i++) i];
        pokemonsTeraTypeFilter = [for (int i = 1; i < 19; i++) i];
        pokemonsMoveFilter = [];
        pokemonsSexFilter = Sex.values;
        pokemonsAbilityFilter = [];
        pokemonsTemperFilter = [];
        await saveConfig();
      }
    }

    if (kIsWeb) {
      // Webも含めてのsqflite Database準備
      databaseFactory = databaseFactoryFfiWeb;
    }

    /////////// とくせい
    abilityDb = await openAssetDatabase(abilityDBFile);
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
    temperDb = await openAssetDatabase(temperDBFile);
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
    itemDb = await openAssetDatabase(itemDBFile);
    // 内部データに変換
    maps = await itemDb.query(itemDBTable,
      columns: [itemColumnId, itemColumnName, itemColumnTiming],
    );
    for (var map in maps) {
      items[map[itemColumnId]] = Item(
        map[itemColumnId],
        map[itemColumnName],
        AbilityTiming(map[itemColumnTiming])
      );
    }


    //////////// わざ
    moveDb = await openAssetDatabase(moveDBFile);
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
    pokeBaseDb = await openAssetDatabase(pokeBaseDBFile);
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
    var exists = await databaseExists(myPokemonDBPath);

    if (!exists) {
      if (!kIsWeb) {
        try {
          await Directory(dirname(myPokemonDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createMyPokemonDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath);
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
          ..item = (map[myPokemonColumnItem] != null) ? Item(map[myPokemonColumnItem], '', AbilityTiming(0)) : null   // TODO 消す
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
      if (!kIsWeb) {
        try {
          await Directory(dirname(partyDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createPartyDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath);
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
      if (!kIsWeb) {
        try {
          await Directory(dirname(battleDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createBattleDB();
    }
    else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath);
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
          ..setParty(PlayerType(PlayerType.me), parties.where((element) => element.id == map[battleColumnOwnPartyId]).first)
          ..opponentName = map[battleColumnOpponentName]
          ..setParty(PlayerType(PlayerType.opponent), parties.where((element) => element.id == map[battleColumnOpponentPartyId]).first)
        );
        // turns
        final turns = map[battleColumnTurns].split(sqlSplit1);
        for (final turn in turns) {
          if (turn == '') break;
          battles.last.turns.add(Turn.deserialize(turn, sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6, sqlSplit7));
        }
        battleIDs.add(map[battleColumnId]);
      }
      battleIDs.sort((a, b) => a.compareTo(b));
    }


    isLoaded = true;
  }

  Future<void> saveConfig() async {
    String jsonText = jsonEncode(
      {
        configKeyPokemonsOwnerFilter: [for (final e in pokemonsOwnerFilter) e.index],
        configKeyPokemonsTypeFilter: [for (final e in pokemonsTypeFilter) e],
        configKeyPokemonsTeraTypeFilter: [for (final e in pokemonsTeraTypeFilter) e],
        configKeyPokemonsMoveFilter: [for (final e in pokemonsMoveFilter) e],
        configKeyPokemonsSexFilter: [for (final e in pokemonsSexFilter) e.index],
        configKeyPokemonsAbilityFilter: [for (final e in pokemonsAbilityFilter) e],
        configKeyPokemonsTemperFilter: [for (final e in pokemonsTemperFilter) e],
      }
    );
    await _saveDataFile.writeAsString(jsonText);
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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    var exists = await databaseExists(myPokemonDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(myPokemonDBPath)).create(recursive: true);
        } catch (_) {}
      }

      myPokemonDb = await _createMyPokemonDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath);
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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath);

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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath);

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

  Future<void> addParty(Party party) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    var exists = await databaseExists(partyDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(partyDBPath)).create(recursive: true);
        } catch (_) {}
      }

      partyDb = await _createPartyDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath);
    }

    // 既存パーティの上書きなら、各ポケモンの被参照カウントをデクリメント
    int index = parties.indexWhere((element) => element.id == party.id);
    if (index >= 0) {
      for (int i = 0; i < parties[index].pokemonNum; i++) {
        parties[index].pokemons[i]!.refCount--;
      }
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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath);

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
        if (ids.contains(e.getParty(PlayerType(PlayerType.me)).id) || ids.contains(e.getParty(PlayerType(PlayerType.opponent)).id)) {
          battleIDs.add(e.id);
          break;
        }
      }
      deleteBattle(battleIDs);
    }
  }

  Future<void> updatePartyRefCounts() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath);

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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    var exists = await databaseExists(battleDBPath);

    if (!exists) {    // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(battleDBPath)).create(recursive: true);
        } catch (_) {}
      }

      battleDb = await _createBattleDB();
    }
    else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath);
    }

    // 既存対戦の上書きなら、対戦内パーティの被参照カウントをデクリメント
    int index = battles.indexWhere((element) => element.id == battle.id);
    if (index >= 0) {
      battles[index].getParty(PlayerType(PlayerType.me)).refCount--;
      battles[index].getParty(PlayerType(PlayerType.opponent)).refCount--;
    }

    // 対戦内パーティの被参照カウントをインクリメント
    battle.getParty(PlayerType(PlayerType.me)).refCount++;
    battle.getParty(PlayerType(PlayerType.opponent)).refCount++;

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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    assert(await databaseExists(battleDBPath));

    // SQLiteのDB読み込み
    battleDb = await openDatabase(battleDBPath);

    String whereStr = '$battleColumnId=?';
    for (int i = 1; i < ids.length; i++) {
      whereStr += ' OR $battleColumnId=?';
    }
    
    // 登録対戦リストから削除
    for (final e in ids) {
      final battleIdx = battles.indexWhere((element) => element.id == e);
      // 対戦内パーティおよびポケモンの被参照カウントをデクリメント
      for (final player in [PlayerType(PlayerType.me), PlayerType(PlayerType.opponent)]) {
        for (int j = 0; j < battles[battleIdx].getParty(player).pokemonNum; j++) {
          battles[battleIdx].getParty(player).pokemons[j]!.refCount--;
        }
        battles[battleIdx].getParty(player).refCount--;
      }
      battles.removeAt(battleIdx);
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

  Future<Database> _createMyPokemonDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    var text = 'CREATE TABLE $myPokemonDBTable('
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
            '$myPokemonColumnRefCount INTEGER)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        myPokemonDBPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) {
            return db.execute(text);
          }
        ),
      );
    }
    else {
      return openDatabase(
        myPokemonDBPath,
        version: 1,
        onCreate: (db, version) {
          return db.execute(text);
        }
      );
    }
  }

  Future<Database> _createPartyDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    var text = 'CREATE TABLE $partyDBTable('
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
            '$partyColumnRefCount INTEGER)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        partyDBPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) {
            return db.execute(text);
          }
        ),
      );
    }
    else {
      return openDatabase(
        partyDBPath,
        version: 1,
        onCreate: (db, version) {
          return db.execute(text);
        }
      );
    }
  }

  Future<Database> _createBattleDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    var text = 'CREATE TABLE $battleDBTable('
            '$battleColumnId INTEGER PRIMARY KEY, '
            '$battleColumnName TEXT, '
            '$battleColumnTypeId INTEGER, '
            '$battleColumnDate INTEGER, '     // TODO
            '$battleColumnOwnPartyId INTEGER, '
            '$battleColumnOpponentName TEXT, '
            '$battleColumnOpponentPartyId INTEGER, '
            '$battleColumnTurns TEXT)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        battleDBPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) {
            return db.execute(text);
          }
        ),
      );
    }
    else {
      return openDatabase(
        battleDBPath,
        version: 1,
        onCreate: (db, version) {
          return db.execute(text);
        }
      );
    }
  }
}
