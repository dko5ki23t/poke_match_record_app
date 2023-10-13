import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/poke_move.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart';
import 'package:path_provider/path_provider.dart';

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

  // タイプ相性
  static MoveEffectiveness effectiveness(
    bool isScrappy, bool isRingTarget, bool isMiracleEye, PokeType attackType, PokemonState defenseState,
  )
  {
    double rate = effectivenessRate(isScrappy, isRingTarget, isMiracleEye, attackType, defenseState);
    if (rate == 0) {
      return MoveEffectiveness(MoveEffectiveness.noEffect);
    }
    else if (rate == 1) {
      return MoveEffectiveness(MoveEffectiveness.normal);
    }
    else if (rate > 1) {
      return MoveEffectiveness(MoveEffectiveness.great);
    }
    else {
      return MoveEffectiveness(MoveEffectiveness.notGood);
    }
  }

  static double effectivenessRate(
    bool isScrappy, bool isRingTarget, bool isMiracleEye, PokeType attackType, PokemonState state,
  )
  {
    PokeType defenseType1 = state.type1;
    PokeType? defenseType2 = state.type2;
    if (state.teraType != null) {
      defenseType1 = state.teraType!;
      defenseType2 = null;
    }
    int deg = 0;
    PokeType? type = defenseType1;
    for (int i = 0; i < 2; i++) {
      if (type == null) break;
      switch (attackType.id) {
        case 1:
          if (type.id == 6 || type.id == 9) deg--;    // ノーマル->いわ/はがね
          if (!isRingTarget && !isScrappy && type.id == 8) return 0;   // ノーマル->ゴースト
          break;
        case 2:
          if (type.id == 1 || type.id == 15 || type.id == 6 || type.id == 17 || type.id == 9) deg++;
          if (type.id == 4 || type.id == 3 || type.id == 14 || type.id == 7 || type.id == 18) deg--;
          if (!isRingTarget && !isScrappy && type.id == 8) return 0;
          break;
        case 3:
          if (type.id == 2 || type.id == 12 || type.id == 7) deg++;
          if (type.id == 13 || type.id == 6 || type.id == 9) deg--;
          break;
        case 4:
          if (type.id == 12 || type.id == 18) deg++;
          if (type.id == 4 || type.id == 5 || type.id == 6 || type.id == 8) deg--;
          if (!isRingTarget && type.id == 9) return 0;
          break;
        case 5:
          if (type.id == 10 || type.id == 13 || type.id == 4 || type.id == 6 || type.id == 9) deg++;
          if (type.id == 12 || type.id == 7) deg--;
          if (!isRingTarget && type.id == 3) return 0;
          break;
        case 6:
          if (type.id == 10 || type.id == 3 || type.id == 15 || type.id == 7) deg++;
          if (type.id == 2 || type.id == 5 || type.id == 9) deg--;
          break;
        case 7:
          if (type.id == 12 || type.id == 14 || type.id == 17) deg++;
          if (type.id == 10 || type.id == 2 || type.id == 4 || type.id == 3 || type.id == 8 || type.id == 9 || type.id == 18) deg--;
          break;
        case 8:
          if (type.id == 14 || type.id == 8) deg++;
          if (type.id == 17) deg--;
          if (!isRingTarget && type.id == 1) return 0;
          break;
        case 9:
          if (type.id == 15 || type.id == 6 || type.id == 18) deg++;
          if (type.id == 10 || type.id == 11 || type.id == 13 || type.id == 9) deg--;
          break;
        case 10:
          if (type.id == 12 || type.id == 15 || type.id == 7 || type.id == 9) deg++;
          if (type.id == 10 || type.id == 11 || type.id == 6 || type.id == 16) deg--;
          break;
        case 11:
          if (type.id == 10 || type.id == 5 || type.id == 6) deg++;
          if (type.id == 11 || type.id == 12 || type.id == 16) deg--;
          break;
        case 12:
          if (type.id == 11 || type.id == 5 || type.id == 6) deg++;
          if (type.id == 10 || type.id == 12 || type.id == 4 || type.id == 3 || type.id == 7 || type.id == 16 || type.id == 9) deg--;
          break;
        case 13:
          if (type.id == 11 || type.id == 3) deg++;
          if (type.id == 13 || type.id == 12 || type.id == 16) deg--;
          if (!isRingTarget && type.id == 5) return 0;
          break;
        case 14:
          if (type.id == 2 || type.id == 4) deg++;
          if (type.id == 14 || type.id == 9) deg--;
          if (!isRingTarget && !isMiracleEye && type.id == 17) return 0;
          break;
        case 15:
          if (type.id == 12 || type.id == 5 || type.id == 3 || type.id == 16) deg++;
          if (type.id == 10 || type.id == 11 || type.id == 15 || type.id == 9) deg--;
          break;
        case 16:
          if (type.id == 16) deg++;
          if (type.id == 9) deg--;
          if (!isRingTarget && type.id == 18) return 0;
          break;
        case 17:
          if (type.id == 14 || type.id == 8) deg++;
          if (type.id == 2 || type.id == 17 || type.id == 18) deg--;
          break;
        case 18:
          if (type.id == 2 || type.id == 16 || type.id == 17) deg++;
          if (type.id == 10 || type.id == 4 || type.id == 9) deg--;
          break;
        default:
          break;
      }
      type = defenseType2;
    }
    if (deg == 2) {
      return 4;
    }
    else if (deg == 1) {
      return 2;
    }
    else if (deg == -1) {
      return 0.5;
    }
    else if (deg == -2) {
      return 0.25;
    }
    else {
      return 1;
    }
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

// 発動タイミング
class AbilityTiming {
  static const int none = 0;
  static const int pokemonAppear = 1;     // ポケモン登場時
  static const int defeatOpponentWithAttack = 2;    // こうげきわざで相手を倒したとき
  static const int attackSuccessedWithChance = 3;          // こうげきし、相手にあたったとき(確率)
  static const int everyTurnEnd = 4;      // 毎ターン終了時
  static const int hpMaxAndAttacked = 5;  // HPが満タンでこうげきを受けた時
  static const int blasted = 6;           // ばくはつ系のわざ、とくせいが発動したとき
  static const int paralysised = 7;       // まひするわざ、とくせいを受けた時
  static const int sandstormed = 8;       // 天気がすなあらしのとき(永続、効果は明示されない)
  static const int directAttackedWithChance = 9;          // 直接攻撃を受けた時(確率・条件)
  static const int electriced = 10;       // でんきタイプのわざを受けた時
  static const int watered = 11;          // みずタイプのわざを受けた時
  static const int attractedTauntedIntimidated = 12;    // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
//  weather(13),          // 天気があるとき
  static const int movingWithChance = 14; // わざを使うとき(確率・条件)
  static const int sleeped = 15;          // ねむり・ねむけの効果を受けた時
  static const int poisoned = 16;         // どく・もうどくの効果を受けた時
  static const int fired = 17;            // ほのおタイプのわざを受けた時
  static const int confusedIntimidated = 18;  // こんらん/いかくの効果を受けた時
  static const int afterActedEveryTurnEnd = 19;   // 1度でも行動した後毎ターン終了時
  static const int changeForced = 20;     // こうたいわざやレッドカードによるこうたいを強制されたとき
  static const int notGreatAttacked = 21; // 効果ばつぐん以外のタイプのこうげきざわを受けた時
  static const int groundFieldEffected = 22;  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  static const int poisonedParalysisedBurnedByOppositeMove = 23;    // 相手から受けた技でどく/まひ/やけど状態にされたとき
  static const int statChangedByNotMyself = 24;   // 自身以外の効果によって能力変化が起きるとき
  static const int change = 25;           // 当該ポケモンを交代するとき(とくせい発動は明示されない)
  static const int electricUse = 26;      // 自分以外のポケモンがでんきわざを使ったとき
//  attack(27),           // こうげきわざを使うとき
  static const int rained = 28;           // 天気があめのとき(永続、効果は明示されない)
  static const int sunny = 29;            // 天気が晴れのとき(永続、効果は明示されない)
//  pokemonAppearAndChanged(30),     // ポケモン登場時、ポケモン交代時(場にいるときのみの効果)
  static const int passive = 31;          // 常に発動(ただし画面には表示されない)
  static const int flinchedIntimidated = 32;  // ひるみやいかくを受けた時
  static const int frozen = 33;           // こおり状態になったとき
  static const int burned = 34;           // やけど状態になったとき
//  moveUsed(35),         // わざを受けた時
  static const int icedFired = 36;        // こおり/ほのおタイプのこうげき技を受けた時
  static const int accuracyDownedAttack = 37;    // 命中率が下がるとき、こうげきするとき
  static const int itemLostByOpponent = 38;   // もちものを奪われたり失ったりするとき
//  ailment(39),          // 状態異常のとき
  static const int drained = 40;          // HP吸収技を受けた時
//  HP033(41),            // HPが1/3以下のとき
//  recoilAttack(42),     // 反動ダメージを受ける技を使ったとき
//  confusedAttacked(43), // こんらん状態でこうげきを受けた時
  static const int flinched = 44;         // ひるんだとき
  static const int snowed = 45;           // 天気がゆきのとき(永続、効果は明示されない)
  static const int hp050 = 46;                  // HPが1/2以下になったとき
  static const int criticaled = 47;       // こうげきが急所に当たった時
//  static const int itemLost = 48;         // 場に出た後にもちものを失っている状態のとき(効果は明示されない)
//  firedBurned(49),      // ほのお技を受けるとき、やけどダメージを負うとき
  static const int fireWaterAttackedSunnyRained = 50;   // ほのお/みずタイプのこうげきを受けた時、天気が晴れ/あめのとき
//  static const int punchAttack = 51;      // パンチ技を使用するとき
  static const int poisonDamage = 52;           // どく/もうどくでダメージを負うとき
  static const int afterActionDecision = 53;    // 行動決定後、行動実行前
  static const int action = 54;                 // 行動時
  static const int afterMove = 55;              // わざ使用後
  static const int continuousMove = 56;         // 連続こうげき時(1回目除く)
  static const int changeFaintingPokemon = 57;  // ポケモンがひんしになったため交代
  static const int changePokemonMove = 58;      // 交代わざによる交代
  static const int gameSet = 59;                // 対戦終了
  static const int attackHitted = 60;           // こうげきし、相手に当たったとき
  static const int pokemonAppearNotRained = 61; // ポケモン登場時(天気が雨でない)
  static const int attackedHitted = 62;         // こうげきを受けたとき
  static const int directAttacked = 63;         // 直接攻撃を受けた時
  static const int soundAttacked = 64;          // 音技を受けた時
  static const int everyTurnEndRained = 65;     // 天気があめのとき、毎ターン終了時
  static const int pokemonAppearNotSandStormed = 66; // ポケモン登場時(天気がすなあらしでない)
  static const int attackChangedByNotMyself = 67;   // 自身以外の効果によってこうげきランクが下がるとき
  static const int everyTurnEndOpponentItemConsumeed = 68;  // 相手が道具を消費したターン終了時
  static const int directAttackedByOppositeSexWithChance = 69;  // 違う性別の相手から直接攻撃を受けた時（確率）
  static const int everyTurnEndWithChance = 70;  // 毎ターン終了時（確率・条件）
  static const int pokemonAppearNotSunny = 71;  // ポケモン登場時(天気が晴れでない)
  static const int everyTurnEndRainedWithAbnormal = 72;     // 天気があめのとき、毎ターン終了時、かつ状態異常時
  static const int everyTurnEndSunny = 73;      // 天気が晴れのとき、毎ターン終了時
  static const int sunnyAbnormaled = 74;        // 天気が晴れ状態で、状態異常にされるとき
  static const int directAttackedFainting = 75; // 直接攻撃を受けてひんしになったとき
  static const int pokemonAppearWithChance = 76;    // ポケモン登場時(確率/条件)
  static const int intimidated = 77;            // いかくを受けた時
  static const int waterUse = 78;               // 自分以外のポケモンがみずわざを使ったとき
  static const int everyTurnEndSnowy = 79;      // 天気がゆきのとき、毎ターン終了時
  static const int pokemonAppearNotSnowed = 80; // ポケモン登場時(天気がゆきでない)
  static const int everyTurnEndOpponentSleep = 81;  // 毎ターン終了時、相手がねむっているとき
  static const int attackedHittedWithChance = 82;   // こうげきを受けたとき(確率・条件)
  static const int phisycalAttackedHitted = 83;     // ぶつりこうげきを受けたとき
  static const int directAttackHitWithChance = 84;  // 直接攻撃をあてたとき(確率)
  static const int guardChangedByNotMyself = 85;    // 自身以外の効果によってぼうぎょランクが下がるとき
  static const int evilAttacked = 86;               // あくタイプのこうげきを受けた時
  static const int evilGhostBugAttackedIntimidated = 87;  // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  static const int grassed = 88;                    // くさタイプのわざを受けた時
  static const int mentalAilments = 89;         // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  static const int statChangeAbnormal = 90;     // 能力を下げられたり状態異常・ねむけになるとき
  static const int movingMovedWithCondition = 91;   // わざを使うとき(条件)、特定のわざを使ったとき
  static const int waterAttacked = 92;          // みずタイプのこうげきを受けた時
  static const int firedWaterAttackBurned = 93; // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  static const int pokemonAppearWithChanceEveryTurnEndWithChance = 94;  // ポケモン登場時と毎ターン終了時（ともに条件あり）
  static const int priorityMoved = 95;          // 優先度1以上のわざを受けた時
  static const int attackedFainting = 96;       // こうげきを受けてひんしになったとき
  static const int otherDance = 97;             // 自身以外がおどりわざをつかったとき
  static const int otherFainting = 98;          // 場にいるポケモンがひんしになったとき
  static const int pokemonAppearNotEreciField = 99;   // ポケモン登場時(エレキフィールドでない)
  static const int pokemonAppearNotPsycoField = 100;  // ポケモン登場時(サイコフィールドでない)
  static const int pokemonAppearNotMistField = 101;   // ポケモン登場時(ミストフィールドでない)
  static const int pokemonAppearNotGrassField = 102;  // ポケモン登場時(グラスフィールドでない)
  static const int movingAttacked = 103;        // 特定のわざを使ったとき、こうげきわざを受けたとき(条件)
  static const int fireWaterAttacked = 104;     // ほのお/みずタイプのこうげきを受けた時
  static const int phisycalAttackedHittedSnowed = 105;  // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  static const int fieldChanged = 106;          // フィールドが変化したとき
  static const int afterActionDecisionWithChance = 107;    // 行動決定後、行動実行前(確率)
  static const int fireAtaccked = 107;          // ほのおタイプのこうげきを受けた時
  static const int abnormaledSleepy = 108;      // 状態異常・ねむけになるとき
  static const int winded = 109;                // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  static const int changeForcedIntimidated = 110;   // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  static const int sunnyBoostEnergy = 111;      // 天気が晴れかブーストエナジーを持っているとき
  static const int elecFieldBoostEnergy = 112;  // エレキフィールドかブーストエナジーを持っているとき
  static const int statused = 113;              // へんかわざを受けた時
  static const int opponentStatUp = 114;        // 相手の能力ランクが上昇したとき
  static const int grounded = 115;              // じめんタイプのわざを受けるとき
  static const int everyTurnEndNotTerastaled = 116;   // テラスタルしていない毎ターン終了時
  static const int hp025 = 117;                 // HPが1/4以下になったとき
  static const int electricAttacked = 118;      // でんきタイプのこうげきを受けた時
  static const int iceAttacked = 119;           // こおりタイプのこうげきを受けた時
  static const int greatAttacked = 120;         // 効果ばつぐんのタイプのこうげきざわを受けた時
  static const int elecField = 121;             // エレキフィールドのとき
  static const int grassField = 122;            // グラスフィールドのとき
  static const int soundAttack = 123;           // 音技を使ったとき
  static const int specialAttackedHitted = 124; // とくしゅこうげきを受けたとき
  static const int psycoField = 125;            // サイコフィールドのとき
  static const int mistField = 126;             // ミストフィールドのとき
  static const int notHit = 127;                // わざが当たらなかったとき
  static const int statDowned = 128;            // 能力ランクが下がったとき
  static const int trickRoom = 129;             // トリックルームのとき
  static const int normalAttackHit = 130;       // ノーマルタイプのこうげきわざが当たった時
  static const int greatFireAttacked = 131;     // 効果ばつぐんのほのおタイプのこうげきわざを受けた時
  static const int greatWaterAttacked = 132;    // 効果ばつぐんのみずタイプのこうげきわざを受けた時
  static const int greatElectricAttacked = 133; // 効果ばつぐんのでんきタイプのこうげきわざを受けた時
  static const int greatgrassAttacked = 134;    // 効果ばつぐんのくさタイプのこうげきわざを受けた時
  static const int greatIceAttacked = 135;      // 効果ばつぐんのこおりタイプのこうげきわざを受けた時
  static const int greatFightAttacked = 136;    // 効果ばつぐんのかくとうタイプのこうげきわざを受けた時
  static const int greatPoisonAttacked = 137;   // 効果ばつぐんのどくタイプのこうげきわざを受けた時
  static const int greatGroundAttacked = 138;   // 効果ばつぐんのじめんタイプのこうげきわざを受けた時
  static const int greatAirAttacked = 139;      // 効果ばつぐんのひこうタイプのこうげきわざを受けた時
  static const int greatPsycoAttacked = 140;    // 効果ばつぐんのエスパータイプのこうげきわざを受けた時
  static const int greatBugAttacked = 141;      // 効果ばつぐんのむしタイプのこうげきわざを受けた時
  static const int greatRockAttacked = 142;     // 効果ばつぐんのいわタイプのこうげきわざを受けた時
  static const int greatGhostAttacked = 143;    // 効果ばつぐんのゴーストタイプのこうげきわざを受けた時
  static const int greatDragonAttacked = 144;   // 効果ばつぐんのドラゴンタイプのこうげきわざを受けた時
  static const int greatEvilAttacked = 145;     // 効果ばつぐんのあくタイプのこうげきわざを受けた時
  static const int greatSteelAttacked = 146;    // 効果ばつぐんのはがねタイプのこうげきわざを受けた時
  static const int greatFairyAttacked = 147;    // 効果ばつぐんのフェアリータイプのこうげきわざを受けた時
  static const int normalAttacked = 148;        // ノーマルタイプのこうげきわざを受けた時
  static const int runOutPP = 149;              // 1つのわざのPPが0になったとき
  static const int abnormaledConfused = 150;    // 状態異常・こんらんになるとき
  static const int confused = 151;              // こんらんになるとき
  static const int everyTurnEndNotAbnormal = 152;   // 状態異常でない毎ターン終了時
  static const int infatuation = 153;           // メロメロになるとき
  static const int afterActionDecisionHP025 = 154;  // HPが1/4以下で行動決定後
  static const int chargeMoving = 155;          // ためわざを使うとき
  static const int changedIgnoredAbility = 156; // とくせいを変更される、無効化される、無視されるとき

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

// ダメージ
class DamageClass {
  static const int none = 0;
  static const int status = 1;    // へんか(ダメージなし)
  static const int physical = 2;  // ぶつり
  static const int special = 3;   // とくしゅ

  const DamageClass(this.id);

  final int id;
}

// 効果
class AbilityEffect {
/*
  none(0),
  attackDown1(1),         // こうげき1段階ダウン
  attackUp1(2),           // こうげき1段階アップ
  defenseDown1(3),        // ぼうぎょ1段階ダウン
  defenseUp1(4),          // ぼうぎょ1段階アップ
  specialAttackDown1(5),  // とくこう1段階ダウン
  specialAttackUp1(6),    // とくこう1段階アップ
  specialDefenseDown1(7), // とくぼう1段階ダウン
  specialDefenseUp1(8),   // とくぼう1段階アップ
  speedDown1(9),          // すばやさ1段階ダウン
  speedUp1(10),           // すばやさ1段階アップ
  evasionDown1(11),       // かいひ1段階ダウン
  evasionUp1(12),         // かいひ1段階アップ
  flinch(13),             // ひるませる
  sunny(14),              // 天気を晴れにする
  rain(15),               // 天気をあめにする
  sandstorm(16),          // 天気をすなあらしにする
  snow(17),               // 天気を雪にする
  noCritical(18),         // 急所にあたらない
  noDeath(19),            // 一撃必殺技を無効化、HP満タンならばHP1は残る
  noExplode(20),          // ばくはつ系のわざ・とくせいが不発になる
  noparalysised(21),      // まひにならない
  sandVeil(22),           // 受ける技の命中率が0.8倍になる、すなあらしのダメージを受けない
  paralysised(23),        // まひにさせる
  voltRecover(24),        // でんきタイプわざを無効化、最大HP1/4分回復(小数点以下切り捨て)
  waterRecover(25),       // 水タイプわざを無効化、最大HP1/4分回復(小数点以下切り捨て)
  noEffect(26),           // 何も起きない(能力変化等無効)
  noWeatherEffect(27),    // 天気の効果がなくなる
  accuracy13(28),         // わざの命中率が1.3倍になる
  oppositeMoveType(29),   // 受けたわざと同じタイプになる
  flashFire(30),          // ほのおタイプわざを無効化、自身のほのおわざのこうげき、とくこうが1.5倍になる
  noAdditionalEffect(31), // 追加効果を受けない
  shadowTag(32),          // ゴーストタイプおよびかげふみをとくせいに持つポケモン以外はこうたい・にげるができない(場から交代すると効果は消える)
  damage0125(33),         // 最大HPの1/8のダメージを与える(小数点以下切り捨て、ただし最小でも1)
  noDamage(34),           // ダメージを受けない
  poisonParalysisedSleep(35),   // どく/まひ/ねむり/のいずれかの状態にする
  synchronoize(36),       // 相手にも自分と同じ状態異常を付与する
  purge(37),              // 状態異常を回復する
  lightningRod(38),       // でんきわざを受ける対象が自分になる。また、でんき技を無効化し、とくこうを1段階あげる。
  additionalEffect2(39),  // 追加効果発動確率が2倍になる
  speedUp2(40),           // すばやさが2倍になる
  trace(41),              // 相手と同じとくせいにする(手持ちに戻るととくせいはトレースに戻る)
  attackUp2(42),          // こうげきが2倍になる
  poison(43),             // どくにさせる
  magnetPull(44),         // はがねタイプ(ただしゴーストを含まない)ポケモンは交代・にげるができない
  soundProof(45),         // 音技を無効化する
  recover00625(46),       // 最大HPの1/16を回復する(小数点以下切り捨て)
  PPdecreasePuls1(47),    // 消費PPの減りが1増える
  thickFat(48),           // こうげき/とくこうを半減してダメージを計算する
  earlyBird(49),          // ねむりの経過カウントを2消費する
  burn(50),               // やけどにする
  keenEye(51),            // 命中率が下がらない、回避率の変動を無視してこうげきする
  pockUp(52),             // もちものを持っていない場合、他ポケモンが消費したどうぐを拾う
  truant(53),             // 2ターンに1回しかわざを出せない
  hustle(54),             // こうげきが1.5倍になるが、物理技の命中率が0.8倍になる
  attract(55),            // 別の性別を持つ場合はメロメロにする
  forecase(56),           // てんきに対応したタイプになる(晴れ→ほのお,あめ→みず,ゆき→こおり)
  guts(57),               // こうげきが1.5倍になり、やけどによるダメージ半減効果を受けない
  defense15(58),          // ぼうぎょが1.5倍になる
  drainReverse(59),       // HP回復効果をダメージ効果に変える
  grass15(60),            // くさタイプわざを使うときのこうげき・とくこうが1.5倍になる
  fire15(61),             // ほのおタイプわざを使うときのこうげき・とくこうが1.5倍になる
  water15(62),            // みずタイプわざを使うときのこうげき・とくこうが1.5倍になる
  bug15(63),              // むしタイプわざを使うときのこうげき・とくこうが1.5倍になる
  noRecoil(64),           // 反動ダメージを受けない
  arenaTrap(65),          // 地面にいるゴーストタイプ以外のポケモンは交代/にげるができない
  accracy05(66),          // 命中率が0.5倍になる
  voltSpeedUp1(67),       // でんきタイプわざを無効化、すばやさが1段階あがる
  rivalry(68),            // お互いの性別が同じならいりょくが1.25倍、異なれば0.75倍、どちらかが性別不明なら1倍になる
  snowCloak(69),          // 受ける技の命中率が0.8倍になる、すなあらしのダメージを受けない
  gluttony(70),           // HP1/4以下で発動するきのみを食べる
  attackUp6(71),          // こうげきが6段階(最大)まで上がる
  heatProof(72),          // ほのお技のダメージを半減する、やけどによるダメージが半減する
  statChange2(73),        // 能力変化による変化を2倍にする
  drySkin(74),            // みずタイプのわざを受ける→無効化、最大HPの1/4だけ回復。ほのおタイプのわざを受ける→ダメージ5/4倍。あめ状態→ターン終了時最大HPの1/8だけ回復。はれ状態→ターン終了時最大HPの1/8ダメージ。
  download(75),           // 場に出た時の相手のぼうぎょ/とくぼうの値をもとに、こうげき/とくこうのうち有利なほうを1段階上げる
  damage12(76),           // わざの威力を1.2倍にする
  recover0125(77),        // 最大HPの1/8を回復する(小数点以下切り捨て)
  ;
*/

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

class Item {
  final int id;
  final String displayName;
  final AbilityTiming timing;

  const Item(this.id, this.displayName, this.timing,);

  Item copyWith() =>
    Item(id, displayName, timing);

  static List<String> processEffect(
    int itemID,
    PlayerType playerType,
    Party myParty,
    int myPokemonIndex,
    PokemonState myState,
    Party yourParty,
    int yourPokemonIndex,
    PokemonState yourState,
    PhaseState state,
    PokeDB pokeData,
    int extraArg1,
    int extraArg2,
    TurnEffect? prevAction,
  ) {
    List<String> ret = [];
    if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
      myParty.items[myPokemonIndex-1] = pokeData.items[itemID];   // もちもの確定
      ret.add('もちものを${pokeData.items[itemID]!.displayName}で確定しました。');
    }
    switch (itemID) {
      case 161:     // オッカのみ
      case 162:     // イトケのみ
      case 163:     // ソクノのみ
      case 164:     // リンドのみ
      case 165:     // ヤチェのみ
      case 166:     // ヨプのみ
      case 167:     // ビアーのみ
      case 168:     // シュカのみ
      case 169:     // バコウのみ
      case 170:     // ウタンのみ
      case 171:     // タンガのみ
      case 172:     // ヨロギのみ
      case 173:     // カシブのみ
      case 174:     // ハバンのみ
      case 175:     // ナモのみ
      case 176:     // リリバのみ
      case 723:     // ロゼルのみ
      case 177:     // ホズのみ
      case 187:     // イバンのみ
      case 248:     // パワフルハーブ
      case 585:     // レッドカード
      case 590:     // だっしゅつボタン
      case 1177:    // だっしゅつパック
        // ダメージ軽減効果はユーザ入力に任せる
        myState.holdingItem = null;   // アイテム消費
        break;
      case 194:     // せんせいのツメ
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 178:     // チイラのみ
      case 589:     // じゅうでんち
      case 689:     // ゆきだま
        myState.addStatChanges(true, 0, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 179:     // リュガのみ
      case 724:     // アッキのみ
      case 898:     // エレキシード
      case 901:     // グラスシード
        myState.addStatChanges(true, 1, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 181:     // ヤタピのみ
      case 588:     // きゅうこん
      case 1176:    // のどスプレー
        myState.addStatChanges(true, 2, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 182:     // ズアのみ
      case 725:     // タラプのみ
      case 688:     // ひかりごけ
      case 899:     // サイコシード
      case 900:     // ミストシード
        myState.addStatChanges(true, 3, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 180:     // カムラのみ
      case 883:     // ビビリだま
        myState.addStatChanges(true, 4, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 183:     // サンのみ
        myState.addVitalRank(1);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 184:     // スターのみ
        myState.addStatChanges(true, extraArg1, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 186:     // ミクルのみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceAccuracy1_2));
        myState.holdingItem = null;   // アイテム消費
        break;
      case 188:   // ジャポのみ
      case 189:   // レンブのみ
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 191:     // しろいハーブ
        myState.resetDownedStatChanges();
        myState.holdingItem = null;   // アイテム消費
        break;
      case 682:     // じゃくてんほけん
        myState.addStatChanges(true, 0, 2, yourState, itemId: itemID);
        myState.addStatChanges(true, 2, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 247:     // いのちのたま
      case 265:     // くっつきバリ
      case 258:     // くろいヘドロ
      case 211:     // たべのこし
      case 230:     // かいがらのすず
        if (playerType.id == PlayerType.me) {
          myState.remainHP -= extraArg1;
        }
        else {
          myState.remainHPPercent -= extraArg1;
        }
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 132:     // オレンのみ
      case 43:      // きのみジュース
      case 135:     // オボンのみ
      case 185:     // ナゾのみ
        if (playerType.id == PlayerType.me) {
          myState.remainHP -= extraArg1;
        }
        else {
          myState.remainHPPercent -= extraArg1;
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 136:     // フィラのみ
      case 137:     // ウイのみ
      case 138:     // マゴのみ
      case 139:     // バンジのみ
      case 140:     // イアのみ
        if (extraArg2 == 0) {
          if (playerType.id == PlayerType.me) {
            myState.remainHP -= extraArg1;
          }
          else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        else {
          myState.ailmentsAdd(Ailment(Ailment.confusion), state.weather, state.field);
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 126:   // クラボのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.paralysis);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 127:   // カゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.sleep);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 128:   // モモンのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 129:   // チーゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.burn);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 130:   // ナナシのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.freeze);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 133:   // キーのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 134:   // ラムのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id <= Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 196:   // メンタルハーブ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => 
            e.id == Ailment.infatuation || e.id == Ailment.encore ||
            e.id == Ailment.torment || e.id == Ailment.disable ||
            e.id == Ailment.taunt || e.id == Ailment.healBlock);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 249:   // どくどくだま
        myState.ailmentsAdd(Ailment(Ailment.badPoison), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 250:   // かえんだま
        myState.ailmentsAdd(Ailment(Ailment.burn), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 257:   // あかいいと
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 207:   // きあいのハチマキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 252:   // きあいのタスキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 583:   // ゴツゴツメット
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 1179:  // からぶりほけん
        myState.addStatChanges(true, 4, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 1180:  // ルームサービス
        myState.addStatChanges(true, 4, -1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      default:
        break;
    }
    return ret;
  }

  void processPassiveEffect(/*bool isOwn, Weather weather, Field field,*/ PokemonState myState, /*PokemonState yourState*/) {
    switch (id) {
      case 112:   // こんごうだま
        if (myState.pokemon.no == 483) {    // ディアルガ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        }
        break;
      case 113:   // しらたま
        if (myState.pokemon.no == 484) {    // パルキア
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        }
        break;
      case 442:   // はっきんだま
        if (myState.pokemon.no == 487) {    // ギラティナ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        }
        break;
      case 202:   // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {   // ラティアス/ラティオス
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        }
        break;
      case 190:   // ひかりのこな
      case 232:   // のんきのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_9));
        break;
      case 197:   // こだわりハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 203:   // しんかいのキバ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack2));
        }
        break;
      case 204:   // しんかいのウロコ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense2));
        }
        break;
      case 209:   // ピントレンズ
      case 303:   // するどいツメ
        myState.addVitalRank(1);
        break;
      case 213:   // でんきだま
        if (myState.pokemon.no == 25) {     // ピカチュウ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove2));
        }
        break;
      case 235:   // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {   // カラカラ/ガラガラ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        }
        break;
      case 233:   // ラッキーパンチ
        if (myState.pokemon.no == 113) {   // ラッキー
          myState.addVitalRank(2);
        }
        break;
      case 236:   // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {   // カモネギ/ネギガナイト
          myState.addVitalRank(2);
        }
        break;
      case 242:   // こうかくレンズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 243:   // ちからのハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_1));
        break;
      case 244:   // ものしりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_1));
        break;
      case 245:   // たつじんのおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_2));
        break;
      case 247:   // いのちのたま
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.lifeOrb));
        break;
      case 253:   // フォーカスレンズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.movedAccuracy1_2));
        break;
      case 254:   // メトロノーム
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.continuousMoveDamageInc0_2));
        break;
      case 255:   // くろいてっきゅう
      case 192:   // きょうせいギプス
      case 266:   // パワーリスト
      case 267:   // パワーベルト
      case 268:   // パワーレンズ
      case 269:   // パワーバンド
      case 270:   // パワーアンクル
      case 271:   // パワーウエイト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed0_5));
        break;
      case 264:   // こだわりスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceScarf));
        break;
      case 274:   // こだわりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceSpecs));
        break;
      case 275:   // ひのたまプレート
      case 226:   // もくたん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttack1_2));
        break;
      case 276:   // しずくプレート
      case 220:   // しんぴのしずく
      case 231:   // うしおのおこう
      case 294:   // さざなみのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        break;
      case 277:   // いかずちプレート
      case 219:   // じしゃく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricAttack1_2));
        break;
      case 278:   // みどりのプレート
      case 216:   // きせきのタネ
      case 295:   // おはなのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.grassAttack1_2));
        break;
      case 279:   // つららのプレート
      case 223:   // とけないこおり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceAttack1_2));
        break;
      case 280:   // こぶしのプレート
      case 218:   // くろおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fightAttack1_2));
        break;
      case 281:   // もうどくプレート
      case 222:   // どくバリ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.poisonAttack1_2));
        break;
      case 282:   // だいちのプレート
      case 214:   // やわらかいすな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.groundAttack1_2));
        break;
      case 283:   // あおぞらプレート
      case 221:   // するどいくちばし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airAttack1_2));
        break;
      case 284:   // ふしぎのプレート
      case 225:   // まがったスプーン
      case 291:   // あやしいおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        break;
      case 285:   // たまむしプレート
      case 199:   // ぎんのこな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bugAttack1_2));
        break;
      case 286:   // がんせきプレート
      case 215:   // かたいいし
      case 292:   // がんせきおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockAttack1_2));
        break;
      case 287:   // もののけプレート
      case 224:   // のろいのおふだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        break;
      case 288:   // りゅうのプレート
      case 227:   // りゅうのキバ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
        break;
      case 289:   // こわもてプレート
      case 217:   // くろいメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.evilAttack1_2));
        break;
      case 290:   // こうてつプレート
      case 210:   // メタルコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        break;
      case 684:   // せいれいプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAttack1_2));
        break;
      case 1664:  // レジェンドプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.moveAttack1_2));
        break;
      case 581:   // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense1_5));
        }
        break;
      case 587:   // しめつけバンド
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bindDamage1_6));
        break;
      case 669:   // ノーマルジュエル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceNormalAttack1_3));
        break;
      case 683:   // とつげきチョッキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onlyAttackSpecialDefense1_5));
        break;
      case 690:   // ぼうじんゴーグル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignorePowder));
        break;
      case 897:   // ぼうごパット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreDirectAtackEffect));
        break;
      case 1178:  // あつぞこブーツ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreInstallingEffect));
        break;
      case 1662:  // まっさらプレート
      case 228:   // シルクのスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalAttack1_2));
        break;
      case 1696:  // パンチグローブ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punchNotDirect1_1));
        break;
    }
  }

  void clearPassiveEffect(/*bool isOwn, Weather weather, Field field,*/ PokemonState myState, /*PokemonState yourState*/) {
    switch (id) {
      case 112:     // こんごうだま
        if (myState.pokemon.no == 483) {    // ディアルガ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 113:     // しらたま
        if (myState.pokemon.no == 484) {    // パルキア
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 442:     // はっきんだま
        if (myState.pokemon.no == 487) {    // ギラティナ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 202:     // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {   // ラティアス/ラティオス
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 190:   // ひかりのこな
      case 232:   // のんきのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_9);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 197:   // こだわりハチマキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.gorimuchu);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 213:   // でんきだま
        if (myState.pokemon.no == 25) {     // ピカチュウ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 235:   // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {   // カラカラ/ガラガラ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 233:   // ラッキーパンチ
        if (myState.pokemon.no == 113) {   // ラッキー
          myState.addVitalRank(-2);
        }
        break;
      case 236:   // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {   // カモネギ/ネギガナイト
          myState.addVitalRank(-2);
        }
        break;
      case 203:   // しんかいのキバ
        if (myState.pokemon.no == 366) {    // パールル
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 204:   // しんかいのウロコ
        if (myState.pokemon.no == 366) {    // パールル
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 209:   // ピントレンズ
      case 303:   // するどいツメ
        myState.addVitalRank(-1);
        break;
      case 242:   // こうかくレンズ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.accuracy1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 243:   // ちからのハチマキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 244:   // ものしりメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 245:   // たつじんのおび
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.greatDamage1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 247:   // いのちのたま
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.lifeOrb);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 253:   // フォーカスレンズ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.movedAccuracy1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 254:   // メトロノーム
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 255:   // くろいてっきゅう
      case 192:   // きょうせいギプス
      case 266:   // パワーリスト
      case 267:   // パワーベルト
      case 268:   // パワーレンズ
      case 269:   // パワーバンド
      case 270:   // パワーアンクル
      case 271:   // パワーウエイト
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed0_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 264:   // こだわりスカーフ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceScarf);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 274:   // こだわりメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceSpecs);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 275:   // ひのたまプレート
      case 226:   // もくたん
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fireAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 276:   // しずくプレート
      case 220:   // しんぴのしずく
      case 231:   // うしおのおこう
      case 294:   // さざなみのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 277:   // いかずちプレート
      case 219:   // じしゃく
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 278:   // みどりのプレート
      case 216:   // きせきのタネ
      case 295:   // おはなのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.grassAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 279:   // つららのプレート
      case 223:   // とけないこおり
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 280:   // こぶしのプレート
      case 218:   // くろおび
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fightAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 281:   // もうどくプレート
      case 222:   // どくバリ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.poisonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 282:   // だいちのプレート
      case 214:   // やわらかいすな
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.groundAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 283:   // あおぞらプレート
      case 221:   // するどいくちばし
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 284:   // ふしぎのプレート
      case 225:   // まがったスプーン
      case 291:   // あやしいおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 285:   // たまむしプレート
      case 199:   // ぎんのこな
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bugAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 286:   // がんせきプレート
      case 215:   // かたいいし
      case 292:   // がんせきおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 287:   // もののけプレート
      case 224:   // のろいのおふだ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 288:   // りゅうのプレート
      case 227:   // りゅうのキバ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 289:   // こわもてプレート
      case 217:   // くろいメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.evilAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 290:   // こうてつプレート
      case 210:   // メタルコート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 684:   // せいれいプレート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1664:  // レジェンドプレート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.moveAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 581:   // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 587:   // しめつけバンド
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bindDamage1_6);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 669:   // ノーマルジュエル
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 683:   // とつげきチョッキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onlyAttackSpecialDefense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 690:   // ぼうじんゴーグル
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignorePowder);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 897:   // ぼうごパット
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignoreDirectAtackEffect);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1178:  // あつぞこブーツ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignoreInstallingEffect);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1662:  // まっさらプレート
      case 228:   // シルクのスカーフ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.normalAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1696:  // パンチグローブ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punchNotDirect1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
    }
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      itemColumnId: id,
      itemColumnName: displayName,
      itemColumnTiming: timing.id,
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

  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;
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
  List<SixParams> _stats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, 0, 0));
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
  int get moveNum {
    for (int i = 0; i < 4; i++) {
      if (moves[i] == null) return i;
    }
    return 4;
  }
  bool get isValid {
    return (
      _name != '' &&
      (_level >= pokemonMinLevel && _level <= pokemonMaxLevel) &&
      _no >= pokemonMinNo && temper.id != 0 &&
      teraType.id != 0 &&
      ability.id != 0 && _moves[0]!.id != 0 &&
      totalEffort() <= pokemonMaxEffortTotal
    );
  }
  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;

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

  // 種族値の合計
  int totalRace() {
    return h.race + a.race + b.race + c.race + d.race + s.race;
  }

  // 努力値の合計
  int totalEffort() {
    return h.effort + a.effort + b.effort + c.effort + d.effort + s.effort;
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

// 状態変化
class Ailment {
  static const int none = 0;
  static const int burn = 1;                // やけど
  static const int freeze = 2;              // こおり
  static const int paralysis = 3;           // まひ
  static const int poison = 4;              // どく
  static const int badPoison = 5;           // もうどく
  static const int sleep = 6;               // ねむり     ここまで、重複しない
  static const int confusion = 7;           // こんらん
  static const int curse = 8;               // のろい
  static const int encore = 9;              // アンコール
  static const int flinch = 10;             // ひるみ
  static const int identify = 11;           // みやぶる
  static const int infatuation = 12;        // メロメロ
  static const int leechSeed = 13;          // やどりぎのタネ
  static const int mindReader = 14;         // こころのめ
  static const int lockOn = 15;             // ロックオン
  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17;   // バインド(交代不可、毎ターンダメージ)
  static const int perishSong = 18;         // ほろびのうた
  static const int taunt = 19;              // ちょうはつ
  static const int torment = 20;            // いちゃもん
  static const int noBerry = 21;            // きのみを食べられない状態(きんちょうかん)
  static const int saltCure = 22;           // しおづけ
  static const int disable = 23;            // かなしばり
  static const int magnetRise = 24;         // でんじふゆう
  static const int telekinesis = 25;        // テレキネシス
  static const int healBlock = 26;          // かいふくふうじ
  static const int embargo = 27;            // さしおさえ
  static const int sleepy = 28;             // ねむけ
  static const int ingrain = 29;            // ねをはる
  static const int uproar = 30;             // さわぐ
  static const int antiAir = 31;            // うちおとす
  static const int magicCoat = 32;          // マジックコート
  static const int charging = 33;           // じゅうでん
  static const int thrash = 34;             // あばれる
  static const int bide = 35;               // がまん
  static const int destinyBond = 36;        // みちづれ     // TODO
  static const int cannotRunAway = 37;      // にげられない
  static const int minimize = 38;           // ちいさくなる
  static const int flying = 39;             // そらをとぶ
  static const int digging = 40;            // あなをほる
  static const int curl = 41;               // まるくなる(ころがる・アイスボールの威力2倍)
  static const int stock1 = 42;             // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;             // たくわえる(2)
  static const int stock3 = 44;             // たくわえる(3)
  static const int attention = 45;          // ちゅうもくのまと
  static const int helpHand = 46;           // てだすけ
  static const int imprison = 47;           // ふういん
  static const int grudge = 48;             // おんねん
  static const int roost = 49;              // はねやすめ
  static const int miracleEye = 50;         // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51;         // パワートリック
  static const int abilityNoEffect = 52;    // とくせいなし
  static const int aquaRing = 53;           // アクアリング
  static const int diving = 54;             // ダイビング
  static const int shadowForcing = 55;      // シャドーダイブ(姿を消した状態)
  static const int electrify = 56;          // そうでん
  static const int powder = 57;             // ふんじん
  static const int throatChop = 58;         // じごくづき
  static const int tarShot = 59;            // タールショット
  static const int octoLock = 60;           // たこがため

  static const _displayNameMap = {
    0: '',
    1: 'やけど',
    2: 'こおり',
    3: 'まひ',
    4: 'どく',
    5: 'もうどく',
    6: 'ねむり',
    7: 'こんらん',
    8: 'のろい',
    9: 'アンコール',
    10: 'ひるみ',
    11: 'みやぶる',
    12: 'メロメロ',
    13: 'やどりぎのタネ',
    14: 'こころのめ',
    15: 'ロックオン',
    16: 'あくむ',
    17: 'バインド',
    18: 'ほろびのうた',
    19: 'ちょうはつ',
    20: 'いちゃもん',
    21: 'きのみを食べられない状態',
    22: 'しおづけ',
    23: 'かなしばり',
    24: 'でんじふゆう',
    25: 'テレキネシス',
    26: 'かいふくふうじ',
    27: 'さしおさえ',
    28: 'ねむけ',
    29: 'ねをはる',
    30: 'さわぐ',
    31: 'うちおとす',
    32: 'マジックコート',
    33: 'じゅうでん',
    34: 'あばれる',
    35: 'がまん',
    36: 'みちづれ',
    37: 'にげられない',
    38: 'ちいさくなる',
    39: 'そらをとぶ',
    40: 'あなをほる',
    41: 'まるくなる',
    42: 'たくわえる(1)',
    43: 'たくわえる(2)',
    44: 'たくわえる(3)',
    45: 'ちゅうもくのまと',
    46: 'てだすけ',
    47: 'ふういん',
    48: 'おんねん',
    49: 'はねやすめ',
    50: 'ミラクルアイ',
    51: 'パワートリック',
    52: 'とくせいなし',
    53: 'アクアリング',
    54: 'ダイビング',
    55: 'シャドーダイブ',
    56: 'そうでん',
    57: 'ふんじん',
    58: 'じごくづき',
    59: 'タールショット',
    60: 'たこがため',
  };

  // TODO:
  static final _bgColor = {
    0: Colors.black,
    1: Colors.black,
    2: Colors.black,
    3: Colors.yellow.shade700,
    4: Colors.black,
    5: Colors.black,
    6: Colors.black,
    7: Colors.black,
    8: Colors.black,
    9: Colors.black,
    10: Colors.black,
    11: Colors.black,
    12: Colors.black,
    13: Colors.black,
    14: Colors.black,
    15: Colors.black,
    16: Colors.black,
    17: Colors.black,
    18: Colors.black,
    19: Colors.black,
    20: Colors.black,
    21: Colors.black,
    22: Colors.black,
    23: Colors.black,
    24: Colors.black,
    25: Colors.black,
    26: Colors.black,
    27: Colors.black,
    28: Colors.black,
    29: Colors.black,
    30: Colors.black,
    31: Colors.black,
    32: Colors.black,
    33: Colors.yellow.shade700,
    34: Colors.black,
    35: Colors.black,
    36: Colors.black,
    37: Colors.black,
    38: Colors.black,
    39: Colors.black,
    40: Colors.black,
    41: Colors.black,
    42: Colors.black,
    43: Colors.black,
    44: Colors.black,
    45: Colors.black,
    46: Colors.black,
    47: Colors.black,
    48: Colors.black,
    49: Colors.black,
    50: Colors.black,
    51: Colors.black,
    52: Colors.black,
    53: Colors.black,
    54: Colors.black,
    55: Colors.black,
    56: Colors.black,
    57: Colors.black,
    58: Colors.black,
    59: Colors.black,
    60: Colors.black,
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // アンコール対象のわざID等

  Ailment(this.id);

  Ailment copyWith() =>
    Ailment(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String displayName(PokeDB pokeData) {
    if (id == Ailment.disable) return '${_displayNameMap[id]!}(${pokeData.moves[extraArg1]!.displayName})';
    return _displayNameMap[id]!;
  }
  Color get bgColor => _bgColor[id]!;

  // SQLに保存された文字列からAilmentをパース
  static Ailment deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Ailment(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

class Ailments {
  List<Ailment> _ailments = [];

  Ailments();

  Ailments copyWith() {
    var ret = Ailments();
    for (var e in _ailments) {
      ret.add(e.copyWith());
    }
    return ret;
  }

  // 既に重複不可な状態異常になっていたら失敗する
  bool add(Ailment ailment) {
    if (ailment.id <= 6 && _ailments.where((element) => element.id <= 6,).isNotEmpty) return false;
    if (_ailments.where((element) => element.id == ailment.id,).isNotEmpty) return false;
    _ailments.add(ailment);
    return true;
  }

  int get length => _ailments.length;
  Iterable<Ailment> get iterable => _ailments;

  Ailment operator [](int i) {
    return _ailments[i];
  }

  Iterable<Ailment> where(bool Function(Ailment) test) {
    return _ailments.where(test);
  }

  int indexWhere(bool Function(Ailment) test) {
    return _ailments.indexWhere(test);
  }
  
  Ailment removeAt(int index) {
    return _ailments.removeAt(index);
  }

  bool remove(Object? e) {
    return _ailments.remove(e);
  }

  void removeWhere(bool Function(Ailment) test) {
    _ailments.removeWhere(test);
  }

  void clear() {
    _ailments.clear();
  }

  // SQLに保存された文字列からAilmentをパース
  static Ailments deserialize(dynamic str, String split1, String split2) {
    Ailments ret = Ailments();
    final ailmentElements = str.split(split1);
    for (final ailment in ailmentElements) {
      if (ailment == '') break;
      ret.add(Ailment.deserialize(ailment, split2));
    }
    return ret;      
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    for (final ailment in _ailments) {
      ret += ailment.serialize(split2);
      ret += split1;
    }
    return ret;
  }
}

// その他の補正(フォルムとか)
class BuffDebuff {
  static const int none = 0;
  static const int attack1_3 = 1;         // こうげき1.3倍
  static const int defense1_3 = 2;        // ぼうぎょ1.3倍
  static const int specialAttack1_3 = 3;  // とくこう1.3倍
  static const int specialDefense1_3 = 4; // とくぼう1.3倍
  static const int speed1_5 = 5;          // すばやさ1.5倍
  static const int yourAccuracy0_8 = 6;   // 相手わざ命中率0.8倍
  static const int accuracy1_3 = 7;       // 命中率1.3倍
  static const int flashFired = 8;        // もらいび状態（ほのおわざ1.5倍）、重複不可
  static const int additionalEffect2 = 9; // わざ追加効果発動確率2倍
  static const int speed2 = 10;           // すばやさ2倍
  static const int attack2 = 11;          // こうげき2倍
  static const int attack1_5 = 12;        // こうげき1.5倍
  static const int physicalAccuracy0_8 = 13;      // 物理技命中率0.8倍
  static const int powalenNormal = 14;    // ポワルンのすがた
  static const int powalenSun = 15;       // たいようのすがた
  static const int powalenRain = 16;      // あまみずのすがた
  static const int powalenSnow = 17;      // ゆきぐものすがた
  static const int attack1_5WithIgnBurn = 18;   // こうげき1.5倍(やけど無視)
  static const int defense1_5 = 19;       // ぼうぎょ1.5倍
  static const int overgrow = 20;         // くさわざ威力1.5倍(しんりょくによる)、重複不可
  static const int blaze = 21;            // ほのおわざ威力1.5倍(もうかによる)、重複不可
  static const int torrent = 22;          // みずわざ威力1.5倍(げきりゅうによる)、重複不可
  static const int swarm = 23;            // むしわざ威力1.5倍(むしのしらせによる)、重複不可
  static const int yourAccuracy0_5 = 24;  // 相手わざ命中率0.5倍(ちどりあしによる)、重複不可
  static const int unburden = 25;         // すばやさ2倍(かるわざによる)、重複不可
  static const int opponentSex1_5 = 26;   // 同性への威力1.25倍/異性への威力0.75倍
  static const int heatproof = 27;        // ほのおわざ被ダメ半減計算・やけどダメ半減(たいねつ)
  static const int drySkin = 28;          // ほのおわざ受ける威力1.25倍
  static const int punch1_2 = 29;         // パンチわざ威力1.2倍
  static const int typeBonus2 = 30;       // タイプ一致ボーナス2倍
  static const int speed1_5IgnPara = 31;  // すばやさ1.5倍(まひ無視)
  static const int normalize = 32;        // すべてのわざタイプ→ノーマル
  static const int sniper = 33;           // 急所時ダメージ1.5倍
  static const int magicGuard = 34;       // 相手こうげき以外ダメージ無効
  static const int noGuard = 35;          // 出すわざ/受けるわざ必中
  static const int stall = 36;            // 同優先度行動で最後に行動
  static const int technician = 37;       // 60以下威力わざの威力1.5倍
  static const int noItemEffect= 38;      // もちものの効果なし
  static const int noAbilityEffect= 39;   // 相手とくせい無視
  static const int vital1 = 40;           // 急所率+1
  static const int vital2 = 41;           // 急所率+2
  static const int vital3 = 42;           // 急所率+3
  static const int ignoreRank = 43;       // 相手のランク補正無視
  static const int notGoodType2 = 44;     // タイプ相性いまひとつ時ダメージ2倍
  static const int greatDamaged0_75 = 45; // こうかばつぐん被ダメージ0.75倍
  static const int attackSpeed0_5 = 46;   // こうげき・すばやさ0.5倍
  static const int recoil1_2 = 47;        // 反動わざ威力1.2倍
  static const int negaForm = 48;         // チェリムのネガフォルム
  static const int posiForm = 49;         // チェリムのポジフォルム
  static const int sheerForce = 50;       // わざの追加効果なし・威力1.3倍
  static const int defeatist = 51;        // こうげき・とくこう半減(よわきによる)、重複不可
  static const int heavy2 = 52;           // おもさ2倍
  static const int heavy0_5 = 53;         // おもさ0.5倍
  static const int damaged0_5 = 54;       // 受けるダメージ0.5倍
  static const int physical1_5 = 55;      // ぶつりわざ威力1.5倍
  static const int special1_5 = 56;       // とくしゅわざ威力1.5倍
  static const int overcoat = 57;         // こな・ほうし・すなあらしダメージ無効
  static const int yourStatusAccuracy50 = 58;   // 相手のへんかわざ命中率50
  static const int analytic = 59;         // 最後行動時わざ威力1.3倍
  static const int ignoreWall = 60;       // かべ・みがわり無視
  static const int prankster = 61;        // へんかわざ優先度+1(あくタイプには無効)
  static const int rockGroundSteel1_3 = 62; // いわ・じめん・はがねわざ威力1.3倍
  static const int zenMode = 63;          // ダルマモード
  static const int accuracy1_1 = 64;      // 命中率1.1倍
  static const int guard2 = 65;           // ぼうぎょ2倍
  static const int bulletProof = 66;      // 弾のわざ無効
  static const int bite1_5 = 67;          // かみつきわざ威力1.5倍
  static const int freezeSkin = 68;       // ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍
  static const int bladeForm = 69;        // ブレードフォルム
  static const int shieldForm = 70;       // シールドフォルム
  static const int galeWings = 71;        // ひこうわざ優先度+1
  static const int wave1_5 = 72;          // はどうわざ威力1.5倍
  static const int guard1_5 = 73;         // ぼうぎょ1.5倍
  static const int directAttack1_3 = 74;  // 直接攻撃威力1.3倍
  static const int fairySkin = 75;        // ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍
  static const int airSkin = 76;          // ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍
  static const int darkAura = 77;         // あくわざ威力1.33倍
  static const int fairyAura = 78;        // フェアリーわざ威力1.33倍
  static const int antiDarkAura = 79;     // あくわざ威力0.75倍
  static const int antiFairyAura = 80;    // フェアリーわざ威力0.75倍
  static const int merciless = 81;        // どく・もうどく状態へのこうげき急所率100%
  static const int change2 = 82;          // こうたい後ポケモンへのこうげき・とくこう2倍
  static const int waterBubble1 = 83;     // 相手ほのおわざこうげき・とくこう0.5倍
  static const int waterBubble2 = 84;     // みずわざこうげき・とくこう2倍
  static const int steelWorker = 85;      // はがねわざこうげき・とくこう1.5倍
  static const int liquidVoice = 86;      // 音わざタイプ→みず
  static const int healingShift = 87;     // かいふくわざ優先度+3
  static const int electricSkin = 88;     // ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍
  static const int singleForm = 89;       // たんどくのすがた
  static const int multipleForm = 90;     // むれたすがた
  static const int transedForm = 91;      // ばけたすがた
  static const int revealedForm = 92;     // ばれたすがた
  static const int satoshiGekkoga = 93;   // サトシゲッコウガ
  static const int tenPercentForm = 94;   // 10%フォルム
  static const int fiftyPercentForm = 95; // 50%フォルム
  static const int perfectForm = 96;      // パーフェクトフォルム
  static const int priorityCut = 97;      // 相手の優先度1以上わざ無効
  static const int directAttackedDamage0_5 = 98;  // 直接攻撃被ダメージ半減
  static const int fireAttackedDamage2 = 99;  // ほのおわざ被ダメージ2倍
  static const int greatDamage1_25 = 100; // こうかばつぐんわざダメージ1.25倍
  static const int targetRock = 101;      // わざの対象相手が変更されない
  static const int unomiForm = 102;       // うのみのすがた
  static const int marunomiForm = 103;    // まるのみのすがた
  static const int sound1_3 = 104;        // 音わざ威力1.3倍
  static const int soundedDamage0_5 = 105;  // 音わざ被ダメージ半減
  static const int specialDamaged0_5 = 106; // とくしゅわざ被ダメージ半減
  static const int nuts2 = 107;           // きのみ効果2倍
  static const int iceFace = 108;         // アイスフェイス
  static const int niceFace = 109;        // ナイスフェイス
  static const int attackMove1_3 = 110;   // こうげきわざ威力1.3倍
  static const int steel1_5 = 111;        // はがねわざ威力1.5倍
  static const int gorimuchu = 112;       // わざこだわり・こうげき1.5倍
  static const int manpukuForm = 113;     // まんぷくもよう
  static const int harapekoForm = 114;    // はらぺこもよう
  static const int directAttackIgnoreGurad = 115;   // まもり不可の直接こうげき
  static const int electric1_3 = 116;     // でんきわざ時こうげき・とくこう1.3倍
  static const int dragon1_5 = 117;       // ドラゴンわざ時こうげき・とくこう1.5倍
  static const int ghosted0_5 = 118;      // ゴーストわざ被ダメ計算時こうげき・とくこう半減
  static const int rock1_5 = 119;         // いわわざ時こうげき・とくこう1.5倍
  static const int naiveForm = 120;       // ナイーブフォルム
  static const int mightyForm = 121;      // マイティフォルム
  static const int specialAttack0_75 = 122;   // とくこう0.75倍
  static const int defense0_75 = 123;     // ぼうぎょ0.75倍
  static const int attack0_75 = 124;      // こうげき0.75倍
  static const int specialDefense0_75 = 125;  // とくぼう0.75倍
  static const int attack1_33 = 126;      // こうげき1.33倍
  static const int specialAttack1_33 = 127;   // とくこう1.33倍
  static const int cut1_5 = 128;          // 切るわざ威力1.5倍
  static const int power10 = 129;         // わざ威力10%アップ
  static const int power20 = 130;         // わざ威力20%アップ
  static const int power30 = 131;         // わざ威力30%アップ
  static const int power40 = 132;         // わざ威力40%アップ
  static const int power50 = 133;         // わざ威力50%アップ
  static const int myceliumMight = 134;   // へんかわざ最後に行動＆相手のとくせい無視
  static const int specialDefense1_5 = 135;   // とくぼう1.5倍
  static const int choiceSpecs = 136;     // わざこだわり・とくこう1.5倍
  static const int specialAttack2 = 137;  // とくこう2倍
  static const int onlyAttackSpecialDefense1_5 = 138;   // こうげきわざのみ選択可・とくぼう1.5倍
  static const int specialDefense2 = 139; // とくぼう2倍
  static const int choiceScarf = 140;     // わざこだわり・すばやさ1.5倍
  static const int onceAccuracy1_2 = 141;      // 次に使うわざ命中率1.2倍
  static const int movedAccuracy1_2 = 142;     // 当ターン行動済み相手へのわざ命中率1.2倍
  static const int attackMove2 = 143;        // こうげきわざ時こうげき・とくこう2倍
  static const int speed0_5 = 144;           // すばやさ0.5倍
  static const int yourAccuracy0_9 = 145; // 相手わざ命中率0.9倍
  static const int physical1_1 = 146;     // ぶつりわざ威力1.1倍
  static const int special1_1 = 147;      // とくしゅわざ威力1.1倍
  static const int onceNormalAttack1_3 = 148;   // ノーマルわざ威力1.3倍
  static const int normalAttack1_2 = 149; // ノーマルわざ威力1.2倍
  static const int fireAttack1_2 = 150;   // ほのおわざ威力1.2倍
  static const int waterAttack1_2 = 151;  // みずわざ威力1.2倍
  static const int electricAttack1_2 = 152;   // でんきわざ威力1.2倍
  static const int grassAttack1_2 = 153;  // くさわざ威力1.2倍
  static const int iceAttack1_2 = 154;    // こおりわざ威力1.2倍
  static const int fightAttack1_2 = 155;  // かくとうわざ威力1.2倍
  static const int poisonAttack1_2 = 156; // どくわざ威力1.2倍
  static const int groundAttack1_2 = 157; // じめんわざ威力1.2倍
  static const int airAttack1_2 = 158;    // ひこうわざ威力1.2倍
  static const int psycoAttack1_2 = 159;  // エスパーわざ威力1.2倍
  static const int bugAttack1_2 = 160;    // むしわざ威力1.2倍
  static const int rockAttack1_2 = 161;   // いわわざ威力1.2倍
  static const int ghostAttack1_2 = 162;  // ゴーストわざ威力1.2倍
  static const int dragonAttack1_2 = 163; // ドラゴンわざ威力1.2倍
  static const int evilAttack1_2 = 164;   // あくわざ威力1.2倍
  static const int steelAttack1_2 = 165;  // はがねわざ威力1.2倍
  static const int fairyAttack1_2 = 166;  // フェアリーわざ威力1.2倍
  static const int moveAttack1_2 = 167;   // わざ威力1.2倍
  static const int lifeOrb = 168;         // こうげきわざダメージ1.3倍・自身HP1/10ダメージ
  static const int greatDamage1_2 = 169;  // こうかばつぐん時ダメージ1.2倍
  static const int continuousMoveDamageInc0_2 = 170;  // 同じわざ連続使用ごとにダメージ+20%(MAX 200%)
  static const int bindDamage1_6 = 171;   // バインド与ダメージ→最大HP1/6
  static const int ignorePowder = 172;    // すなあらしダメージ・こな・ほうし無効
  static const int ignoreDirectAtackEffect = 173; // 直接こうげきに対して発動する効果無効
  static const int ignoreInstallingEffect = 174;  // 設置わざ効果無効
  static const int attackWithFlinch10 = 175;      // こうげき時10%ひるみ
  static const int substitute = 176;      // みがわり
  static const int rage = 177;            // わざによるダメージでこうげき1段階上昇
  static const int punchNotDirect1_1 = 178;   // パンチわざ非接触化・威力1.1倍
  static const int voiceForm = 179;       // ボイスフォルム
  static const int stepForm = 180;        // ステップフォルム

  static const _displayNameMap = {
    0:  '',
    1:  'こうげき1.3倍',
    2:  'ぼうぎょ1.3倍',
    3:  'とくこう1.3倍',
    4:  'とくぼう1.3倍',
    5:  'すばやさ1.5倍',
    6:  '相手わざ命中率0.8倍',
    7:  '命中率1.3倍',
    8:  'ほのおわざ威力1.5倍',
    9:  'わざ追加効果発動確率2倍',
    10: 'すばやさ2倍',
    11: 'こうげき2倍',
    12: 'こうげき1.5倍',
    13: '物理技命中率0.8倍',
    14: 'ポワルンのすがた',
    15: 'たいようのすがた',
    16: 'あまみずのすがた',
    17: 'ゆきぐものすがた',
    18: 'こうげき1.5倍(やけど無視)',
    19: 'ぼうぎょ1.5倍',
    20: 'くさわざ威力1.5倍',
    21: 'ほのおわざ威力1.5倍',
    22: 'みずわざ威力1.5倍',
    23: 'むしわざ威力1.5倍',
    24: '相手わざ命中率0.5倍',
    25: 'すばやさ2倍',
    26: '同性への威力1.25倍/異性への威力0.75倍',
    27: 'ほのおわざ被ダメ半減計算・やけどダメ半減',
    28: 'ほのおわざ受ける威力1.25倍',
    29: 'パンチわざ威力1.2倍',
    30: 'タイプ一致ボーナス2倍',
    31: 'すばやさ1.5倍(まひ無視)',
    32: 'すべてのわざタイプ→ノーマル',
    33: '急所時ダメージ1.5倍',
    34: '相手こうげき以外ダメージ無効',
    35: '出すわざ/受けるわざ必中',
    36: '同優先度行動で最後に行動',
    37: '60以下威力わざの威力1.5倍',
    38: 'もちものの効果なし',
    39: '相手とくせい無視',
    40: '急所率アップ+1',
    41: '急所率アップ+2',
    42: '急所率アップ+3',
    43: '相手のランク補正無視',
    44: 'タイプ相性いまひとつ時ダメージ2倍',
    45: 'こうかばつぐん被ダメージ0.75倍',
    46: 'こうげき・すばやさ0.5倍',
    47: '反動わざ威力1.2倍',
    48: 'ネガフォルム',
    49: 'ポジフォルム',
    50: 'わざの追加効果なし・威力1.3倍',
    51: 'こうげき・とくこう半減',
    52: 'おもさ2倍',
    53: 'おもさ0.5倍',
    54: '受けるダメージ0.5倍',
    55: 'ぶつりわざ威力1.5倍',
    56: 'とくしゅわざ威力1.5倍',
    57: 'こな・ほうし・すなあらしダメージ無効',
    58: '相手のへんかわざ命中率50',
    59: '最後行動時わざ威力1.3倍',
    60: 'かべ・みがわり無視',
    61: 'へんかわざ優先度+1(あくタイプには無効)',
    62: 'いわ・じめん・はがねわざ威力1.3倍',
    63: 'ダルマモード',
    64: '命中率1.1倍',
    65: 'ぼうぎょ2倍',
    66: '弾のわざ無効',
    67: 'かみつきわざ威力1.5倍',
    68: 'ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍',
    69: 'ブレードフォルム',
    70: 'シールドフォルム',
    71: 'ひこうわざ優先度+1',
    72: ' はどうわざ威力1.5倍',
    73: 'ぼうぎょ1.5倍',
    74: '直接攻撃威力1.3倍',
    75: 'ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍',
    76: 'ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍',
    77: 'あくわざ威力1.33倍',
    78: 'フェアリーわざ威力1.33倍',
    79: 'あくわざ威力0.75倍',
    80: 'フェアリーわざ威力0.75倍',
    81: 'どく・もうどく状態へのこうげき急所率100%',
    82: 'こうたい後ポケモンへのこうげき・とくこう2倍',
    83: '相手ほのおわざこうげき・とくこう0.5倍',
    84: 'みずわざこうげき・とくこう2倍',
    85: 'はがねわざこうげき・とくこう1.5倍',
    86: '音わざタイプ→みず',
    87: 'かいふくわざ優先度+3',
    88: 'ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍',
    89: 'たんどくのすがた',
    90: 'むれたすがた',
    91: 'ばけたすがた',
    92: 'ばれたすがた',
    93: 'サトシゲッコウガ',
    94: '10%フォルム',
    95: '50%フォルム',
    96: 'パーフェクトフォルム',
    97: '相手の優先度1以上わざ無効',
    98: '直接攻撃被ダメージ半減',
    99: 'ほのおわざ被ダメージ2倍',
    100: 'こうかばつぐんわざダメージ1.25倍',
    101: 'わざの対象相手が変更されない',
    102: 'うのみのすがた',
    103: 'まるのみのすがた',
    104: '音わざ威力1.3倍',
    105: '音わざ被ダメージ半減',
    106: 'とくしゅわざ被ダメージ半減',
    107: 'きのみ効果2倍',
    108: 'アイスフェイス',
    109: 'ナイスフェイス',
    110: 'こうげきわざ威力1.3倍',
    111: 'はがねわざ威力1.5倍',
    112: 'わざこだわり・こうげき1.5倍',
    113: 'まんぷくもよう',
    114: 'はらぺこもよう',
    115: '直接こうげきのまもり不可',
    116: 'でんきわざ時こうげき・とくこう1.3倍',
    117: 'ドラゴンわざ時こうげき・とくこう1.5倍',
    118: 'ゴーストわざ被ダメ計算時こうげき・とくこう半減',
    119: 'いわわざ時こうげき・とくこう1.5倍',
    120: 'ナイーブフォルム',
    121: 'マイティフォルム',
    122: 'とくこう0.75倍',
    123: 'ぼうぎょ0.75倍',
    124: 'こうげき0.75倍',
    125: 'とくぼう0.75倍',
    126: 'こうげき1.33倍',
    127: 'とくこう1.33倍',
    128: '切るわざ威力1.5倍',
    129: 'わざ威力10%アップ',
    130: 'わざ威力20%アップ',
    131: 'わざ威力30%アップ',
    132: 'わざ威力40%アップ',
    133: 'わざ威力50%アップ',
    134: 'へんかわざ最後に行動＆相手のとくせい無視',
    135: 'とくぼう1.5倍',
    136: 'わざこだわり・とくこう1.5倍',
    137: 'とくこう2倍',
    138: 'こうげきわざのみ選択可・とくぼう1.5倍',
    139: 'とくぼう2倍',
    140: 'わざこだわり・すばやさ1.5倍',
    141: '次に使うわざ命中率1.2倍',
    142: '当ターン行動済み相手へのわざ命中率1.2倍',
    143: 'こうげきわざ時こうげき・とくこう2倍',
    144: 'すばやさ0.5倍',
    145: '相手わざ命中率0.9倍',
    146: 'ぶつりわざ威力1.1倍',
    147: 'とくしゅわざ威力1.1倍',
    148: 'ノーマルわざ威力1.3倍',
    149: 'ノーマルわざ威力1.2倍',
    150: 'ほのおわざ威力1.2倍',
    151: 'みずわざ威力1.2倍',
    152: 'でんきわざ威力1.2倍',
    153: 'くさわざ威力1.2倍',
    154: 'こおりわざ威力1.2倍',
    155: 'かくとうわざ威力1.2倍',
    156: 'どくわざ威力1.2倍',
    157: 'じめんわざ威力1.2倍',
    158: 'ひこうわざ威力1.2倍',
    159: 'エスパーわざ威力1.2倍',
    160: 'むしわざ威力1.2倍',
    161: 'いわわざ威力1.2倍',
    162: 'ゴーストわざ威力1.2倍',
    163: 'ドラゴンわざ威力1.2倍',
    164: 'あくわざ威力1.2倍',
    165: 'はがねわざ威力1.2倍',
    166: 'フェアリーわざ威力1.2倍',
    167: 'わざ威力1.2倍',
    168: 'こうげきわざダメージ1.3倍・自身HP1/10ダメージ',
    169: 'こうかばつぐん時ダメージ1.2倍',
    170: '同じわざ連続使用ごとにダメージ+20%(MAX 200%)',
    171: 'バインド与ダメージ→最大HP1/6',
    172: 'すなあらしダメージ・こな・ほうし無効',
    173: '直接こうげきに対して発動する効果無効',
    174: '設置わざ効果無効',
    175: 'こうげき時10%ひるみ',
    176: 'みがわり',
    177: 'わざによるダメージでこうげき1段階上昇',
    178: 'パンチわざ非接触化・威力1.1倍',
    179: 'ボイスフォルム',
    180: 'ステップフォルム',
  };

  static const _bgColorMap = {
    0:  Colors.black,
    1:  Colors.red,
    2:  Colors.red,
    3:  Colors.red,
    4:  Colors.red,
    5:  Colors.red,
    6:  Colors.red,
    7:  Colors.red,
    8:  Colors.red,
    9:  Colors.red,
    10: Colors.red,
    11: Colors.red,
    12: Colors.red,
    13: Colors.blue,
    14: Colors.orange,
    15: Colors.orange,
    16: Colors.orange,
    17: Colors.orange,
    18: Colors.red,
    19: Colors.red,
    20: Colors.red,
    21: Colors.red,
    22: Colors.red,
    23: Colors.red,
    24: Colors.red,
    25: Colors.red,
    26: Colors.red,
    27: Colors.red,
    28: Colors.blue,
    29: Colors.red,
    30: Colors.red,
    31: Colors.red,
    32: Color(0xffaeaeae),
    33: Colors.red,
    34: Colors.red,
    35: Colors.red,
    36: Colors.red,
    37: Colors.red,
    38: Colors.red,
    39: Colors.red,
    40: Colors.red,
    41: Colors.red,
    42: Colors.red,
    43: Colors.red,
    44: Colors.red,
    45: Colors.red,
    46: Colors.blue,
    47: Colors.red,
    48: Colors.orange,
    49: Colors.orange,
    50: Colors.red,
    51: Colors.blue,
    52: Colors.orange,
    53: Colors.orange,
    54: Colors.red,
    55: Colors.red,
    56: Colors.red,
    57: Colors.red,
    58: Colors.red,
    59: Colors.red,
    60: Colors.red,
    61: Colors.red,
    62: Colors.red,
    63: Colors.orange,
    64: Colors.red,
    65: Colors.red,
    66: Colors.red,
    67: Colors.red,
    68: Colors.orange,
    69: Colors.orange,
    70: Colors.orange,
    71: Colors.red,
    72: Colors.red,
    73: Colors.red,
    74: Colors.red,
    75: Colors.red,
    76: Colors.red,
    77: Colors.red,
    78: Colors.red,
    79: Colors.blue,
    80: Colors.blue,
    81: Colors.red,
    82: Colors.red,
    83: Colors.red,
    84: Colors.red,
    85: Colors.red,
    86: Colors.orange,
    87: Colors.red,
    88: Colors.red,
    89: Colors.orange,
    90: Colors.orange,
    91: Colors.orange,
    92: Colors.orange,
    93: Colors.orange,
    94: Colors.orange,
    95: Colors.orange,
    96: Colors.orange,
    97: Colors.red,
    98: Colors.red,
    99: Colors.blue,
    100: Colors.red,
    101: Colors.red,
    102: Colors.orange,
    103: Colors.orange,
    104: Colors.red,
    105: Colors.red,
    106: Colors.red,
    107: Colors.red,
    108: Colors.orange,
    109: Colors.orange,
    110: Colors.red,
    111: Colors.red,
    112: Colors.red,
    113: Colors.orange,
    114: Colors.orange,
    115: Colors.red,
    116: Colors.red,
    117: Colors.red,
    118: Colors.red,
    119: Colors.red,
    120: Colors.orange,
    121: Colors.orange,
    122: Colors.blue,
    123: Colors.blue,
    124: Colors.blue,
    125: Colors.blue,
    126: Colors.red,
    127: Colors.red,
    128: Colors.red,
    129: Colors.red,
    130: Colors.red,
    131: Colors.red,
    132: Colors.red,
    133: Colors.red,
    134: Colors.red,
    135: Colors.red,
    136: Colors.red,
    137: Colors.red,
    138: Colors.red,
    139: Colors.red,
    140: Colors.red,
    141: Colors.red,
    142: Colors.red,
    143: Colors.red,
    144: Colors.blue,
    145: Colors.red,
    146: Colors.red,
    147: Colors.red,
    148: Colors.red,
    150: Colors.red,
    151: Colors.red,
    152: Colors.red,
    153: Colors.red,
    154: Colors.red,
    155: Colors.red,
    156: Colors.red,
    157: Colors.red,
    158: Colors.red,
    159: Colors.red,
    160: Colors.red,
    161: Colors.red,
    162: Colors.red,
    163: Colors.red,
    164: Colors.red,
    165: Colors.red,
    166: Colors.red,
    167: Colors.red,
    168: Colors.red,
    169: Colors.red,
    170: Colors.red,
    171: Colors.red,
    172: Colors.red,
    173: Colors.red,
    174: Colors.red,
    175: Colors.red,
    176: Colors.green,
    177: Colors.red,
    178: Colors.red,
    179: Colors.orange,
    180: Colors.orange,
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  BuffDebuff(this.id);

  BuffDebuff copyWith() =>
    BuffDebuff(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _displayNameMap[id]!;
  Color get bgColor => _bgColorMap[id]!;
  
  // SQLに保存された文字列からBuffDebuffをパース
  static BuffDebuff deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return BuffDebuff(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

// 各々の場
class IndividualField {
  static const int none = 0;
  static const int toxicSpikes = 1;       // どくびし
  static const int spikes = 2;            // まきびし
  static const int stealthRock = 3;       // ステルスロック
  static const int stickyWeb = 4;         // ねばねばネット
  static const int healingWish = 5;       // いやしのねがい
  static const int lunarDance = 6;        // みかづきのまい
  static const int sandStormDamage = 7;   // すなあらしによるダメージ
  static const int futureAttack = 8;      // みらいにこうげき
  static const int futureAttackSteel = 9; // はめつのねがい
  static const int wish = 10;             // ねがいごと
  static const int grassFieldRecovery = 11;   // グラスフィールドによる回復
  static const int reflector = 12;        // リフレクター
  static const int lightScreen = 13;      // ひかりのかべ
  static const int safeGuard = 14;        // しんぴのまもり
  static const int mist = 15;             // しろいきり
  static const int tailwind = 16;         // おいかぜ
  static const int luckyChant = 17;       // おまじない
  static const int auroraVeil = 18;       // オーロラベール
  static const int gravity = 19;          // じゅうりょく
  static const int trickRoom = 20;        // トリックルーム
  static const int waterSport = 21;       // みずあそび
  static const int mudSport = 22;         // どろあそび
  static const int wonderRoom = 23;       // ワンダールーム
  static const int magicRoom = 24;        // マジックルーム
  static const int ionDeluge = 25;        // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLock = 26;        // フェアリーロック

  static const _displayNameMap = {
    0: '',
    1: 'どくびし',
    2: 'まきびし',
    3: 'ステルスロック',
    4: 'ねばねばネット',
    5: 'いやしのねがい',
    6: 'みかづきのまい',
    7: 'すなあらしによるダメージ',
    8: 'みらいにこうげき',
    9: 'はめつのねがい',
    10: 'ねがいごと',
    11: 'グラスフィールドによる回復',
    12: 'ねをはる',
    13: 'ひかりのかべ',
    14: 'しんぴのまもり',
    15: 'しろいきり',
    16: 'おいかぜ',
    17: 'おまじない',
    18: 'オーロラベール',
    19: 'じゅうりょく',
    20: 'トリックルーム',
    21: 'みずあそび',
    22: 'どろあそび',
    23: 'ワンダールーム',
    24: 'マジックルーム',
    25: 'プラズマシャワー',
    26: 'フェアリーロック',
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  IndividualField(this.id);

  IndividualField copyWith() =>
    IndividualField(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _displayNameMap[id]!;
  
  // SQLに保存された文字列からIndividualFieldをパース
  static IndividualField deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return IndividualField(elements[0])
      ..turns = elements[1]
      ..extraArg1 = elements[2];
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

// 天気
class Weather {
  static const int none = 0;
  static const int sunny = 1;              // 晴れ
  static const int rainy = 2;              // あめ
  static const int sandStorm = 3;          // すなあらし
  static const int snowy = 4;              // ゆき
  
  static const int invalid = 100;          // 天気無効化

  static const _displayNameMap = {
    0: '',
    1: '晴れ',
    2: 'あめ',
    3: 'すなあらし',
    4: 'ゆき',
  };

  static const _bgColorMap = {
    0: Colors.black,
    1: Colors.orange,
    2: Colors.blueAccent,
    3: Colors.brown,
    4: Colors.blue
  };

  String get displayName => isValid ? _displayNameMap[id]! : '${_displayNameMap[id]!}(無効)';
  Color get bgColor => isValid ? _bgColorMap[id]! : Colors.grey;

  int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    //

  Weather(this.id);

  Weather copyWith() =>
    Weather(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  bool get isValid => id < invalid;
  set valid(bool b) {
    if (b && id >= invalid) {
      id -= invalid;
    }
    else if (!b && id < invalid) {
      id += invalid;
    }
  }

  // 天気変化もしくは場に登場したポケモンに対して天気の効果をかける
  // (場に出たポケモンに対しては、変化前を「天気なし」として引数を渡すとよい)
  static void processWeatherEffect(Weather before, Weather after, PokemonState? ownPokemonState, PokemonState? opponentPokemonState) {
    if (ownPokemonState != null && (ownPokemonState.currentAbility.id == 13 || ownPokemonState.currentAbility.id == 76)) {   // ノーてんき/エアロック
      after.valid = false;
    }
    else if (opponentPokemonState != null && (opponentPokemonState.currentAbility.id == 13 || opponentPokemonState.currentAbility.id == 76)) {   // ノーてんき/エアロック
      after.valid = false;
    }
    else {
      after.valid = true;
    }
    
    if (after.isValid) {
      if (before.id != Weather.sandStorm && after.id == Weather.sandStorm) {  // すなあらしになる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 8) {   // すながくれ
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 146) {   // すなかき
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 8) {   // すながくれ
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 146) {   // すなかき
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.sandStorm && after.id != Weather.sandStorm) {  // すなあらしではなくなる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 8) {   // すながくれ
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 146) {   // すなかき
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 8) {   // すながくれ
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 146) {   // すなかき
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
      }
      if (before.id != Weather.rainy && after.id == Weather.rainy) {  // あめになる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 33) {   // すいすい
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 33) {   // すいすい
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.rainy && after.id != Weather.rainy) {  // あめではなくなる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 33) {   // すいすい
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 33) {   // すいすい
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
      }
      if (before.id != Weather.sunny && after.id == Weather.sunny) {  // 晴れになる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 34) {   // ようりょくそ
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 288) {   // ひひいろのこどう
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_33));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 34) {   // ようりょくそ
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 288) {   // ひひいろのこどう
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_33));
        }
      }
      if (before.id == Weather.sunny && after.id != Weather.sunny) {  // 晴れではなくなる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 34) {   // ようりょくそ
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 288) {   // ひひいろのこどう
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.attack1_33));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 34) {   // ようりょくそ
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 288) {   // ひひいろのこどう
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.attack1_33));
        }
      }
      if (before.id != Weather.snowy && after.id == Weather.snowy) {  // ゆきになる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 81) {   // ゆきがくれ
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 202) {   // ゆきかき
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 81) {   // ゆきがくれ
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 202) {   // ゆきかき
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.snowy && after.id != Weather.snowy) {  // ゆきではなくなる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 81) {   // ゆきがくれ
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 202) {   // ゆきかき
          ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 81) {   // ゆきがくれ
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 202) {   // ゆきかき
          opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
        }
      }

      // ポワルンのフォルムチェンジ
      for (var pokeState in [ownPokemonState, opponentPokemonState]) {
        if (pokeState == null) continue;
        if (pokeState.currentAbility.id != 59) continue;    // てんきや
        int findIdx = pokeState.buffDebuffs.indexWhere((element) => BuffDebuff.powalenNormal <= element.id && element.id <= BuffDebuff.powalenSnow);
        BuffDebuff newForm = BuffDebuff(BuffDebuff.powalenNormal);
        switch (after.id) {
          case Weather.sunny:
            newForm = BuffDebuff(BuffDebuff.powalenSun);
            break;
          case Weather.rainy:
            newForm = BuffDebuff(BuffDebuff.powalenRain);
            break;
          case Weather.snowy:
            newForm = BuffDebuff(BuffDebuff.powalenSnow);
            break;
        }
        if (findIdx >= 0) {
          pokeState.buffDebuffs[findIdx] = newForm;
        }
        else {
          pokeState.buffDebuffs.add(newForm);
        }
      }

      // チェリムのフォルムチェンジ
      for (var pokeState in [ownPokemonState, opponentPokemonState]) {
        if (pokeState == null) continue;
        if (pokeState.currentAbility.id != 122) continue;    // フラワーギフト
        int findIdx = pokeState.buffDebuffs.indexWhere((element) => BuffDebuff.negaForm <= element.id && element.id <= BuffDebuff.posiForm);
        BuffDebuff newForm = BuffDebuff(BuffDebuff.negaForm);
        if (after.id == Weather.sunny) newForm = BuffDebuff(BuffDebuff.posiForm);
        if (findIdx >= 0) {
          pokeState.buffDebuffs[findIdx] = newForm;
        }
        else {
          pokeState.buffDebuffs.add(newForm);
        }
      }
    }
  }

  // SQLに保存された文字列からWeatherをパース
  static Weather deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Weather(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

// フィールド
class Field {
  static const int none = 0;
  static const int electricTerrain = 1;    // エレキフィールド
  static const int grassyTerrain = 2;      // グラスフィールド
  static const int mistyTerrain = 3;       // ミストフィールド
  static const int psychicTerrain = 4;     // サイコフィールド

  static const _displayNameMap = {
    0: '',
    1: 'エレキフィールド',
    2: 'グラスフィールド',
    3: 'ミストフィールド',
    4: 'サイコフィールド',
  };

  static const _bgColorMap = {
    0: Colors.black,
    1: Colors.yellow,
    2: Colors.green,
    3: Colors.pinkAccent,
    4: Colors.pink,
    5: Colors.purple,
    // TODO
  };

  String get displayName => _displayNameMap[id]!;
  Color get bgColor => _bgColorMap[id]!;

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  Field(this.id);

  Field copyWith() =>
    Field(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  // フィールド変化もしくは場に登場したポケモンに対してフィールドの効果をかける
  // (場に出たポケモンに対しては、変化前を「フィールドなし」として引数を渡すとよい)
  static void processFieldEffect(Field before, Field after, PokemonState? ownPokemonState, PokemonState? opponentPokemonState) {
    // ぎたい
    int newTypeID = 0;
    switch (after.id) {
      case Field.electricTerrain:
        newTypeID = 13;
        break;
      case Field.grassyTerrain:
        newTypeID = 12;
        break;
      case Field.mistyTerrain:
        newTypeID = 18;
        break;
      case Field.psychicTerrain:
        newTypeID = 14;
        break;
    }
    if (ownPokemonState != null && ownPokemonState.currentAbility.id == 250) {
      ownPokemonState.type1 = newTypeID == 0 ? ownPokemonState.pokemon.type1 : PokeType.createFromId(newTypeID);
      ownPokemonState.type2 = newTypeID == 0 ? ownPokemonState.pokemon.type2 : null;
    }
    if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 250) {
      opponentPokemonState.type1 = newTypeID == 0 ? opponentPokemonState.pokemon.type1 : PokeType.createFromId(newTypeID);
      opponentPokemonState.type2 = newTypeID == 0 ? opponentPokemonState.pokemon.type2 : null;
    }

    if (before.id != Field.grassyTerrain && after.id == Field.grassyTerrain) {  // グラスフィールドになる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 179) {   // くさのけがわ
        ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.guard1_5));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 179) {   // くさのけがわ
        opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.guard1_5));
      }
    }
    if (before.id == Field.grassyTerrain && after.id != Field.grassyTerrain) {  // グラスフィールドではなくなる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 179) {   // くさのけがわ
        ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.guard1_5));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 179) {   // くさのけがわ
        opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.guard1_5));
      }
    }
    if (before.id != Field.electricTerrain && after.id == Field.electricTerrain) {  // エレキフィールドになる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 207) {   // サーフテール
        ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
      }
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 289) {   // ハドロンエンジン
        ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack1_33));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 207) {   // サーフテール
        opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 289) {   // ハドロンエンジン
        opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack1_33));
      }
    }
    if (before.id == Field.electricTerrain && after.id != Field.electricTerrain) {  // エレキフィールドではなくなる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 207) {   // サーフテール
        ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
      }
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 289) {   // ハドロンエンジン
        ownPokemonState.buffDebuffs.removeAt(ownPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialAttack1_33));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 207) {   // サーフテール
        opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.speed2));
      }
      if (opponentPokemonState != null && opponentPokemonState.currentAbility.id == 289) {   // ハドロンエンジン
        opponentPokemonState.buffDebuffs.removeAt(opponentPokemonState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialAttack1_33));
      }
    }
  }

  // SQLに保存された文字列からFieldをパース
  static Field deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Field(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

class PokemonState {
  Pokemon pokemon = Pokemon();  // ポケモン(DBへの保存時はIDだけ)
  int remainHP = 0;             // 残りHP
  int remainHPPercent = 100;    // 残りHP割合
  PokeType? teraType;           // テラスタルしているかどうか、している場合はそのタイプ
  bool isFainting = false;      // ひんしかどうか
  bool isBattling = false;      // バトルに参加しているかどうか
  Item? _holdingItem = Item(0, '', AbilityTiming(0));  // 持っているもちもの(失えばnullにする)
  List<int> usedPPs = List.generate(4, (index) => 0);       // 各わざの消費PP
  List<int> _statChanges = List.generate(7, (i) => 0);   // のうりょく変化
  List<BuffDebuff> buffDebuffs = [];    // その他の補正(フォルムとか)
  Ability currentAbility = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0)); // 現在のとくせい(バトル中にとくせいが変わることあるので)
  List<IndividualField> fields = [];        // 場(天気やフィールドを含まない、かべ等)
  Ailments _ailments = Ailments();   // 状態異常
  List<SixParams> minStats = List.generate(StatIndex.size.index, (i) => SixParams(0, 0, 0, 0));     // 個体値や努力値のあり得る範囲の最小値
  List<SixParams> maxStats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, pokemonMaxEffort, 0));   // 個体値や努力値のあり得る範囲の最大値
  List<Ability> possibleAbilities = [];     // 候補のとくせい
  List<Item> impossibleItems = [];          // 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Move> moves = [];         // 判明しているわざ
  PokeType type1 = PokeType.createFromId(0);  // ポケモンのタイプ1(対戦中変わることもある)
  PokeType? type2;                // ポケモンのタイプ2

  PokemonState copyWith() =>
    PokemonState()
    ..pokemon = pokemon
    ..remainHP = remainHP
    ..remainHPPercent = remainHPPercent
    ..teraType = teraType
    ..isFainting = isFainting
    ..isBattling = isBattling
    .._holdingItem = _holdingItem?.copyWith()
    ..usedPPs = [...usedPPs]
    .._statChanges = [..._statChanges]
    ..buffDebuffs = [for (final e in buffDebuffs) e.copyWith()]
    ..currentAbility = currentAbility.copyWith()
    ..fields = [for (final e in fields) e.copyWith()]
    .._ailments = _ailments.copyWith()
    ..minStats = [...minStats]        // TODO:よい？
    ..maxStats = [...maxStats]        // TODO:よい？
    ..possibleAbilities = [for (final e in possibleAbilities) e.copyWith()]
    ..impossibleItems = [for (final e in impossibleItems) e.copyWith()]
    ..moves = [...moves]
    ..type1 = type1
    ..type2 = type2;

  Item? get holdingItem => _holdingItem;

  set holdingItem(Item? item) {
    _holdingItem?.clearPassiveEffect(this);
    item?.processPassiveEffect(this);
    _holdingItem = item;
  }

  // 地面にいるかどうかの判定
  bool get isGround {
    if (ailmentsWhere((e) => e.id == Ailment.ingrain || e.id == Ailment.antiAir).isNotEmpty ||
        fields.where((e) => e.id == IndividualField.gravity).isNotEmpty ||
        holdingItem?.id == 255) {
      return true;
    }
    if (isTypeContain(3) || currentAbility.id == 26 || holdingItem?.id == 584 ||
        ailmentsWhere((e) => e.id == Ailment.magnetRise || e.id == Ailment.telekinesis).isNotEmpty) {
      return false;
    }
    return true;
  }

  // きゅうしょランク加算
  void addVitalRank(int i) {
    int findIdx = buffDebuffs.indexWhere((element) => BuffDebuff.vital1 <= element.id && element.id <= BuffDebuff.vital3);
    if (findIdx < 0) {
      int vitalRank = (BuffDebuff.vital1 + (i-1)).clamp(BuffDebuff.vital1, BuffDebuff.vital3);
      buffDebuffs.add(BuffDebuff(vitalRank));
    }
    else {
      int newRank = buffDebuffs[findIdx].id + i;
      if (newRank < BuffDebuff.vital1) {
        buffDebuffs.removeAt(findIdx);
      }
      else {
        int vitalRank = (newRank).clamp(BuffDebuff.vital1, BuffDebuff.vital3);
        buffDebuffs[findIdx] = BuffDebuff(vitalRank);
      }
    }
  }

  // タイプが含まれるか判定(テラスタル後ならテラスタイプで判定)
  bool isTypeContain(int typeId) {
    if (teraType != null) {
      return teraType!.id == typeId;
    }
    else {
      return type1.id == typeId || type2?.id == typeId;
    }
  }

  // ポケモン交代やひんしにより退場する場合の処理
  void processExitEffect(bool isOwn, PokemonState yourState) {
    resetStatChanges();
    currentAbility = pokemon.ability;
    ailmentsRemoveWhere((e) => e.id > Ailment.sleep);   // 状態変化の回復
    if (isFainting) ailmentsClear();
    // 退場後も継続するフォルム以外をクリア
    var unchangingForms = buffDebuffs.where((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace).toList();
    unchangingForms.addAll(buffDebuffs.where((e) => e.id == BuffDebuff.manpukuForm || e.id == BuffDebuff.harapekoForm));
    buffDebuffs.clear();
    buffDebuffs.addAll(unchangingForms);
    fields.clear();
    // 場にいると両者にバフ/デバフがかかる場合
    if (currentAbility.id == 186 && yourState.currentAbility.id != 186) { // ダークオーラ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura || element.id == BuffDebuff.antiDarkAura);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 187 && yourState.currentAbility.id == 187) { // フェアリーオーラ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura || element.id == BuffDebuff.antiFairyAura);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    // 場にいると相手にバフ/デバフがかかる場合
    if (currentAbility.id == 284) { // わざわいのうつわ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialAttack0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 285) { // わざわいのつるぎ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.defense0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 286) { // わざわいのおふだ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.attack0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 287) { // わざわいのたま
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialDefense0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    // にげられない状態の解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.cannotRunAway);
    // 退場することで自身に効果がある場合
    if (!isFainting && currentAbility.id == 30) { // しぜんかいふく
      ailmentsClear();
    }
    if (!isFainting && currentAbility.id == 144) { // さいせいりょく
      if (isOwn) {
        remainHP += (pokemon.h.real / 3).floor();
      }
      else {
        remainHPPercent += 33;
      }
    }
  }

  // ポケモン交代や死に出しにより登場する場合の処理
  void processEnterEffect(bool isOwn, Weather weather, Field field, PokemonState yourState) {
    isBattling = true;
    currentAbility = pokemon.ability;
    processPassiveEffect(isOwn, weather, field, yourState);   // パッシブ効果
    Weather.processWeatherEffect(Weather(0), weather, isOwn ? this : null, isOwn ? null : this);  // 天気の影響
    Field.processFieldEffect(Field(0), field, isOwn ? this : null, isOwn ? null : this);  // フィールドの影響
  }

  // ポケモンのとくせい/もちもの等で常に働く効果を付与。ポケモン登場時に一度だけ呼ぶ
  void processPassiveEffect(bool isOwn, Weather weather, Field field, PokemonState yourState) {
    // ポケモン固有のフォルム等
    if (pokemon.no == 648) {  // メロエッタ
      buffDebuffs.add(BuffDebuff(BuffDebuff.voiceForm));
    }

    switch (currentAbility.id) {
      case 14:  // ふくがん
        buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_3));
        break;
      case 32:  // てんのめぐみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.additionalEffect2));
        break;
      case 37:  // ちからもち
      case 74:  // ヨガパワー
        buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        break;
      case 55:  // はりきり
        buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5));
        buffDebuffs.add(BuffDebuff(BuffDebuff.physicalAccuracy0_8));
        break;
      case 59:  // てんきや
        buffDebuffs.add(BuffDebuff(BuffDebuff.powalenNormal));
        break;
      case 62:  // こんじょう
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
        }
        break;
      case 63:  // ふしぎなうろこ
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
        }
        break;
      case 77:  // ちどりあし
        if (ailmentsIndexWhere((e) => e.id == Ailment.confusion) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
        }
        break;
      case 79:  // とうそうしん
        buffDebuffs.add(BuffDebuff(BuffDebuff.opponentSex1_5));
        break;
      case 85:  // たいねつ
        buffDebuffs.add(BuffDebuff(BuffDebuff.heatproof));
        break;
      case 87:  // かんそうはだ
        buffDebuffs.add(BuffDebuff(BuffDebuff.drySkin));
        break;
      case 89:  // てつのこぶし
        buffDebuffs.add(BuffDebuff(BuffDebuff.punch1_2));
        break;
      case 91:  // てきおうりょく
        buffDebuffs.add(BuffDebuff(BuffDebuff.typeBonus2));
        break;
      case 95:  // はやあし
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
        }
        break;
      case 96:  // ノーマルスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.normalize));
        break;
      case 97:  // スナイパー
        buffDebuffs.add(BuffDebuff(BuffDebuff.sniper));
        break;
      case 98:  // マジックガード
        buffDebuffs.add(BuffDebuff(BuffDebuff.magicGuard));
        break;
      case 99:  // ノーガード
        buffDebuffs.add(BuffDebuff(BuffDebuff.noGuard));
        break;
      case 100: // あとだし
        buffDebuffs.add(BuffDebuff(BuffDebuff.stall));
        break;
      case 101: // テクニシャン
        buffDebuffs.add(BuffDebuff(BuffDebuff.technician));
        break;
      case 103: // ぶきよう
        buffDebuffs.add(BuffDebuff(BuffDebuff.noItemEffect));
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        buffDebuffs.add(BuffDebuff(BuffDebuff.noAbilityEffect));
        break;
      case 105: // きょううん
        addVitalRank(1);
        break;
      case 109: // てんねん
        buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreRank));
        break;
      case 110: // いろめがね
        buffDebuffs.add(BuffDebuff(BuffDebuff.notGoodType2));
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamaged0_75));
        break;
      case 120: // すてみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.recoil1_2));
        break;
      case 122: // フラワーギフト
        buffDebuffs.add(BuffDebuff(BuffDebuff.negaForm));
        break;
      case 125: // ちからずく
        buffDebuffs.add(BuffDebuff(BuffDebuff.sheerForce));
        break;
      case 134: // ヘヴィメタル
        buffDebuffs.add(BuffDebuff(BuffDebuff.heavy2));
        break;
      case 135: // ライトメタル
        buffDebuffs.add(BuffDebuff(BuffDebuff.heavy0_5));
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        if ((isOwn && remainHP == pokemon.h.real) || (!isOwn && remainHPPercent == 100)) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        break;
      case 137:  // どくぼうそう
        if (ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
        }
        break;
      case 138:  // ねつぼうそう
        if (ailmentsIndexWhere((e) => e.id == Ailment.burn) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        }
        break;
      case 142:  // ぼうじん
        buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 147:  // ミラクルスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.yourStatusAccuracy50));
        break;
      case 148:  // アナライズ
        buffDebuffs.add(BuffDebuff(BuffDebuff.analytic));
        break;
      case 151:  // すりぬけ
        buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreWall));
        break;
      case 156:  // マジックミラー
        ailmentsAdd(Ailment(Ailment.magicCoat), weather, field);
        break;
      case 158:  // いたずらごころ
        buffDebuffs.add(BuffDebuff(BuffDebuff.prankster));
        break;
      case 159:   // すなのちから
        buffDebuffs.add(BuffDebuff(BuffDebuff.rockGroundSteel1_3));
        break;
      case 162:   // しょうりのほし
        buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 169:   // ファーコート
        buffDebuffs.add(BuffDebuff(BuffDebuff.guard2));
        break;
      case 171:   // ぼうだん
        buffDebuffs.add(BuffDebuff(BuffDebuff.bulletProof));
        break;
      case 173:   // がんじょうあご
        buffDebuffs.add(BuffDebuff(BuffDebuff.bite1_5));
        break;
      case 174:   // フリーズスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.freezeSkin));
        break;
      case 176:   // バトルスイッチ
        buffDebuffs.add(BuffDebuff(BuffDebuff.shieldForm));
        break;
      case 177: // はやてのつばさ
        if ((isOwn && remainHP == pokemon.h.real) || (!isOwn && remainHPPercent == 100)) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
        break;
      case 178:   // メガランチャー
        buffDebuffs.add(BuffDebuff(BuffDebuff.wave1_5));
        break;
      case 181:   // かたいツメ
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttack1_3));
        break;
      case 182:   // フェアリースキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.fairySkin));
        break;
      case 184:   // スカイスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.airSkin));
        break;
      case 196:   // ひとでなし
        buffDebuffs.add(BuffDebuff(BuffDebuff.merciless));
        break;
      case 198:   // はりこみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.change2));
        break;
      case 199:   // すいほう
        buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble1));
        buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble2));
        break;
      case 200:   // はがねつかい
        buffDebuffs.add(BuffDebuff(BuffDebuff.steelWorker));
        break;
      case 204:   // うるおいボイス
        buffDebuffs.add(BuffDebuff(BuffDebuff.liquidVoice));
        break;
      case 205:   // ヒーリングシフト
        buffDebuffs.add(BuffDebuff(BuffDebuff.healingShift));
        break;
      case 206:   // エレキスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.electricSkin));
        break;
      case 208:   // ぎょぐん
        buffDebuffs.add(BuffDebuff(BuffDebuff.singleForm));
        break;
      case 209:   // ばけのかわ
        buffDebuffs.add(BuffDebuff(BuffDebuff.transedForm));
        break;
      case 217:   // バッテリー
        buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        break;
      case 218:   // もふもふ
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackedDamage0_5));
        buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttackedDamage2));
        break;
      case 233:   // ブレインフォース
        buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_25));
        break;
      case 239:   // スクリューおびれ
      case 242:   // すじがねいり
        buffDebuffs.add(BuffDebuff(BuffDebuff.targetRock));
        break;
      case 244:   // パンクロック
        buffDebuffs.add(BuffDebuff(BuffDebuff.sound1_3));
        buffDebuffs.add(BuffDebuff(BuffDebuff.soundedDamage0_5));
        break;
      case 246:   // こおりのりんぷん
        buffDebuffs.add(BuffDebuff(BuffDebuff.specialDamaged0_5));
        break;
      case 247:   // じゅくせい
        buffDebuffs.add(BuffDebuff(BuffDebuff.nuts2));
        break;
      case 248:   // アイスフェイス
        {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace);
          if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.iceFace));
        }
        break;
      case 249:   // パワースポット
        buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove1_3));
        break;
      case 252:   // はがねのせいしん
        buffDebuffs.add(BuffDebuff(BuffDebuff.steel1_5));
        break;
      case 255:   // ごりむちゅう
        buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 258:   // はらぺこスイッチ
        if (teraType == null || teraType!.id == 0) {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.harapekoForm || e.id == BuffDebuff.manpukuForm);
          if (findIdx < 0) {
            buffDebuffs.add(BuffDebuff(BuffDebuff.manpukuForm));
          }
          else {
            buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.manpukuForm);
          }
        }
        break;
      case 260:   // ふかしのこぶし
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackIgnoreGurad));
        break;
      case 262:   // トランジスタ
        buffDebuffs.add(BuffDebuff(BuffDebuff.electric1_3));
        break;
      case 263:   // りゅうのあぎと
        buffDebuffs.add(BuffDebuff(BuffDebuff.dragon1_5));
        break;
      case 272:   // きよめのしお
        buffDebuffs.add(BuffDebuff(BuffDebuff.ghosted0_5));
        break;
      case 276:   // いわはこび
        buffDebuffs.add(BuffDebuff(BuffDebuff.rock1_5));
        break;
      case 278:   // マイティチェンジ
        {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm);
          if (findIdx < 0) {
            buffDebuffs.add(BuffDebuff(BuffDebuff.naiveForm));
          }
          else {
            buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.mightyForm);
          }
        }
        break;
      case 284:   // わざわいのうつわ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack0_75));
        break;
      case 285:   // わざわいのつるぎ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense0_75));
        break;
      case 286:   // わざわいのおふだ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack0_75));
        break;
      case 287:   // わざわいのたま
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense0_75));
        break;
      case 292:   // きれあじ
        buffDebuffs.add(BuffDebuff(BuffDebuff.cut1_5));
        break;
      case 298:   // きんしのちから
        buffDebuffs.add(BuffDebuff(BuffDebuff.myceliumMight));
        break;
    }
    
    // もちものの効果を反映
    holdingItem?.processPassiveEffect(this);
  
    // 両者のバフ/デバフに関係する場合
    if (currentAbility.id == 186 || yourState.currentAbility.id == 186) { // ダークオーラ
      if (currentAbility.id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
      }
      else {
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
    }
    if (currentAbility.id == 187 || yourState.currentAbility.id == 187) { // フェアリーオーラ
      if (currentAbility.id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
      }
      else {
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  // 状態異常に関する関数群ここから
  bool ailmentsAdd(Ailment ailment, Weather weather, Field field, {bool forceAdd = false}) {
    // すでに同じものになっている場合は何も起こらない
    if (_ailments.where((e) => e.id == ailment.id).isNotEmpty) return false;
    // タイプによる耐性
    if ((isTypeContain(9) || isTypeContain(4)) &&
        (ailment.id == Ailment.poison || (!forceAdd && ailment.id == Ailment.badPoison))    // もうどくに関しては、わざ使用者のとくせいがふしょくなら可能
    ) return false;
    if (isTypeContain(10) && ailment.id == Ailment.burn) return false;
    if (isTypeContain(13) && ailment.id == Ailment.paralysis) return false;
    // とくせいによる耐性
    if ((currentAbility.id == 17 || currentAbility.id == 257) && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) return false;
    if ((currentAbility.id == 7) && (ailment.id == Ailment.paralysis)) return false;
    if ((currentAbility.id == 41 || currentAbility.id == 199 || currentAbility.id == 270) && (ailment.id == Ailment.burn)) return false;    // みずのベール/ねつこうかん<-やけど
    if (currentAbility.id == 166 && isTypeContain(12) && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // フラワーベール
    if ((currentAbility.id == 39) && (ailment.id == Ailment.flinch)) return false;      // せいしんりょく<-ひるみ
    if ((currentAbility.id == 40) && (ailment.id == Ailment.freeze)) return false;      // マグマのよろい<-こおり
    if ((currentAbility.id == 102) && (weather.id == Weather.sunny) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // 晴れ下リーフガード<-状態異常＋ねむけ
    if (currentAbility.id == 213 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // ぜったいねむり<-状態異常＋ねむけ
    // TODO:リミットシールド
    if (currentAbility.id == 213) return false;
    if (field.id == Field.mistyTerrain) return false;

    bool isAdded = _ailments.add(ailment);

    if (isAdded && ailment.id <= Ailment.sleep && ailment.id != 0) {    // 状態異常時
      if (currentAbility.id == 62) buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));  // こんじょう
      if (currentAbility.id == 63) buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));            // ふしぎなうろこ
      if (currentAbility.id == 95) buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));       // はやあし
    }
    else if (isAdded && ailment.id == Ailment.confusion) {    // こんらん時
      if (currentAbility.id == 77) buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));  // ちどりあし
    }
    else if (isAdded && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {    // どく/もうどく時
      if (currentAbility.id == 137) buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));        // どくぼうそう
    }
    else if (isAdded && ailment.id == Ailment.burn) {    // やけど時
      if (currentAbility.id == 138) buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));         // ねつぼうそう
    }
    return true;
  }

  int get ailmentsLength => _ailments.length;
  Iterable<Ailment> get ailmentsIterable => _ailments.iterable;

  Ailment ailments(int i) {
    return _ailments[i];
  }

  Iterable<Ailment> ailmentsWhere(bool Function(Ailment) test) {
    return _ailments.where(test);
  }

  int ailmentsIndexWhere(bool Function(Ailment) test) {
    return _ailments.indexWhere(test);
  }

  Ailment ailmentsRemoveAt(int index) {
    var ret = _ailments.removeAt(index);
    if (ret.id <= Ailment.sleep && ret.id != 0) {
      if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.confusion) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.poison || ret.id == Ailment.badPoison) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.burn) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    
    return ret;
  }

  void ailmentsRemoveWhere(bool Function(Ailment) test) {
    _ailments.removeWhere(test);
    if (_ailments.indexWhere((e) => e.id <= Ailment.sleep && e.id != 0) < 0) {
      if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.confusion) < 0) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) < 0) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.burn) < 0) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
  }

  void ailmentsClear() {
    _ailments.clear();
    if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
  }
  // 状態異常に関する関数群ここまで
  
  // ランク変化に関する関数群ここから
  int statChanges(int i) {return _statChanges[i];}

  // 引数で指定した値そのものにする。とくせいの効果等に影響されない変化をさせたいときに使う
  void forceSetStatChanges(int index, int num,) {
    _statChanges[index] = num;
    if (_statChanges[index] < -6) _statChanges[index] = -6;
    if (_statChanges[index] > 6) _statChanges[index] = 6;
  }

  // とくせい等によって変化できなかった場合はfalseが返る
  bool addStatChanges(
    bool isMyEffect, int index, int num, PokemonState yourState,
    {int? moveId, int? abilityId, int? itemId, bool lastMirror = false}
  ) {
    int change = num;
    if (!isMyEffect && holdingItem?.id == 1698 && num < 0) return false;    // クリアチャーム
    if (!isMyEffect && currentAbility.id == 12 && moveId == 445) return false;   // どんかん
    if (!isMyEffect && abilityId == 22 &&        // いかくに対する
        (currentAbility.id == 12 || currentAbility.id == 20  || currentAbility.id == 39 ||    // どんかん/マイペース/せいしんりょく
         currentAbility.id == 113)) return false;                                             // きもったま
    if (!isMyEffect && currentAbility.id == 20 && abilityId == 22) return false;   // マイペース
    if (!isMyEffect && (currentAbility.id == 29 || currentAbility.id == 73 || currentAbility.id == 230) && num < 0) return false;   // クリアボディ/しろいけむり/メタルプロテクト
    if (!isMyEffect && (currentAbility.id == 35 || currentAbility.id == 51) && index == 5 && num < 0) return false;   // はっこう/するどいめ
    if (!isMyEffect && currentAbility.id == 52 && index == 0 && num < 0) return false;   // かいりきバサミ
    if (!isMyEffect && currentAbility.id == 145 && index == 1 && num < 0) return false;   // はとむね
    if (!isMyEffect && currentAbility.id == 166 && isTypeContain(12) && num < 0) return false;   // フラワーベール
    if (!isMyEffect && currentAbility.id == 240 && num < 0 && !lastMirror) {    // ミラーアーマー
      yourState.addStatChanges(isMyEffect, index, num, this, lastMirror: true);
      return false;
    }
    if (!isMyEffect && abilityId == 22 && currentAbility.id == 275) num = 1;   // いかくに対するばんけん

    if (currentAbility.id == 86) change *= 2;   // たんじゅん
    if (currentAbility.id == 126) change *= -1; // あまのじゃく
    if (!isMyEffect && currentAbility.id == 128 && num < 0) {  // まけんき
      _statChanges[0] =  (_statChanges[0] + 2).clamp(-6, 6);
    }

    _statChanges[index] = (_statChanges[index] + change).clamp(-6, 6);
    return true;
  }

  void resetStatChanges() {
    _statChanges = List.generate(7, (index) => 0);
  }

  void resetDownedStatChanges() {
    for (int i = 0; i < 7; i++) {
      if (_statChanges[i] < 0) _statChanges[i] = 0;
    }
  }
  // ランク変化に関する関数群ここまで

  // SQLに保存された文字列からPokemonStateをパース
  static PokemonState deserialize(dynamic str, PokeDB pokeData, String split1, String split2, String split3) {
    PokemonState pokemonState = PokemonState();
    final stateElements = str.split(split1);
    // pokemon
    pokemonState.pokemon = pokeData.pokemons.where((element) => element.id == int.parse(stateElements[0])).first;
    // remainHP
    pokemonState.remainHP = int.parse(stateElements[1]);
    // remainHPPercent
    pokemonState.remainHPPercent = int.parse(stateElements[2]);
    // teraType
    if (stateElements[3] != '') {
      pokemonState.teraType = PokeType.createFromId(int.parse(stateElements[3]));
    }
    // isFainting
    pokemonState.isFainting = int.parse(stateElements[4]) != 0;
    // isBattling
    pokemonState.isBattling = int.parse(stateElements[5]) != 0;
    // holdingItem
    pokemonState.holdingItem = stateElements[6] == '' ? null : pokeData.items[int.parse(stateElements[6])];
    // usedPPs
    pokemonState.usedPPs.clear();
    final pps = stateElements[7].split(split2);
    for (final pp in pps) {
      if (pp == '') break;
      pokemonState.usedPPs.add(int.parse(pp));
    }
    // statChanges
    final statChangeElements = stateElements[8].split(split2);
    for (int i = 0; i < 7; i++) {
      pokemonState._statChanges[i] = int.parse(statChangeElements[i]);
    }
    // buffDebuffs
    final buffDebuffElements = stateElements[9].split(split2);
    for (final buffDebuff in buffDebuffElements) {
      if (buffDebuff == '') break;
      pokemonState.buffDebuffs.add(BuffDebuff.deserialize(buffDebuff, split3));
    }
    // currentAbility
    pokemonState.currentAbility = Ability.deserialize(stateElements[10], split2);
    // fields
    final fieldElements = stateElements[11].split(split2);
    for (final field in fieldElements) {
      if (field == '') break;
      pokemonState.fields.add(IndividualField.deserialize(field, split3));
    }
    // ailments
    pokemonState._ailments = Ailments.deserialize(stateElements[12], split2, split3);
    // minStats
    final minStatElements = stateElements[13].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.minStats[i] = SixParams.deserialize(minStatElements[i], split3);
    }
    // maxStats
    final maxStatElements = stateElements[14].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.maxStats[i] = SixParams.deserialize(maxStatElements[i], split3);
    }
    // possibleAbilities
    final abilities = stateElements[15].split(split2);
    for (var ability in abilities) {
      if (ability == '') break;
      pokemonState.possibleAbilities.add(Ability.deserialize(ability, split3));
    }
    // impossibleItems
    final items = stateElements[16].split(split2);
    for (var item in items) {
      if (item == '') break;
      pokemonState.impossibleItems.add(pokeData.items[int.parse(item)]!);
    }
    // moves
    final moves = stateElements[17].split(split2);
    for (var move in moves) {
      if (move == '') break;
      pokemonState.moves.add(pokeData.moves[int.parse(move)]!);
    }
    // type1
    pokemonState.type1 = PokeType.createFromId(int.parse(stateElements[18]));
    // type2
    if (stateElements[19] != '') {
      pokemonState.type2 = PokeType.createFromId(int.parse(stateElements[19]));
    }

    return pokemonState;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3) {
    String ret = '';
    // pokemon
    ret += pokemon.id.toString();
    ret += split1;
    // remainHP
    ret += remainHP.toString();
    ret += split1;
    // remainHPPercent
    ret += remainHPPercent.toString();
    ret += split1;
    // teraType
    if (teraType != null) {
      ret += teraType!.id.toString();
    }
    ret += split1;
    // isFainting
    ret += isFainting ? '1' : '0';
    ret += split1;
    // isBattling
    ret += isBattling ? '1' : '0';
    ret += split1;
    // holdingItem
    ret += holdingItem != null ? holdingItem!.id.toString() : '';
    ret += split1;
    // usedPPs
    for (final pp in usedPPs) {
      ret += pp.toString();
      ret += split2;
    }
    ret += split1;
    // statChanges
    for (int i = 0; i < 7; i++) {
      ret += _statChanges[i].toString();
      ret += split2;
    }
    ret += split1;
    // buffDebuffs
    for (final buffDebuff in buffDebuffs) {
      ret += buffDebuff.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // currentAbility
    ret += currentAbility.serialize(split2);
    ret += split1;
    // fields
    for (final field in fields) {
      ret += field.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // ailments
    ret += _ailments.serialize(split2, split3);
    ret += split1;
    // minStats
    for (int i = 0; i < 6; i++) {
      ret += minStats[i].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // maxStats
    for (int i = 0; i < 6; i++) {
      ret += maxStats[i].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // possibleAbilities
    for (final ability in possibleAbilities) {
      ret += ability.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // impossibleItems
    for (final item in impossibleItems) {
      ret += item.id.toString();
      ret += split2;
    }
    ret += split1;
    // moves
    for (final move in moves) {
      ret += move.id.toString();
      ret += split2;
    }
    ret += split1;
    // type1
    ret += type1.id.toString();
    ret += split1;
    // type2
    if (type2 != null) {
      ret += type2!.id.toString();
    }

    return ret;
  }
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

// ある時点(ターン内のフェーズ)での状態
class PhaseState {
  int ownPokemonIndex = 0;          // 0は無効値
  int opponentPokemonIndex = 0;     // 0は無効値
  List<PokemonState> ownPokemonStates = [];
  List<PokemonState> opponentPokemonStates = [];
  Weather _weather = Weather(0);
  Field _field = Field(0);

  Weather get weather => _weather;
  Field get field => _field;
  int get ownFaintingNum => ownPokemonStates.where((e) => e.isFainting).length;
  int get opponentFaintingNum => opponentPokemonStates.where((e) => e.isFainting).length;

  set weather(Weather w) {
    Weather.processWeatherEffect(_weather, w, ownPokemonState, opponentPokemonState);

    _weather = w;
  }
  set field(Field f) {
    Field.processFieldEffect(_field, f, ownPokemonState, opponentPokemonState);

    _field = f;
  }

  void forceSetWeather(Weather w) {
    _weather = w;
  }
  void forceSetField(Field f) {
    _field = f;
  }

  PhaseState copyWith() =>
    PhaseState()
    ..ownPokemonIndex = ownPokemonIndex
    ..opponentPokemonIndex = opponentPokemonIndex
    ..ownPokemonStates = [
      for (final state in ownPokemonStates)
      state.copyWith()
    ]
    ..opponentPokemonStates = [
      for (final state in opponentPokemonStates)
      state.copyWith()
    ]
    ..weather = weather.copyWith()
    ..field = field.copyWith();
  
  PokemonState get ownPokemonState => ownPokemonStates[ownPokemonIndex-1];
  PokemonState get opponentPokemonState => opponentPokemonStates[opponentPokemonIndex-1];
  bool get hasOwnTerastal => ownPokemonStates.where((element) => element.teraType != null).isNotEmpty;
  bool get hasOpponentTerastal => opponentPokemonStates.where((element) => element.teraType != null).isNotEmpty;
  bool get isMyWin {
    var n = opponentPokemonStates.where((element) => element.isFainting).length;
    return n >= 3 || n >= opponentPokemonStates.length;
  }
  bool get isYourWin {
    var n = ownPokemonStates.where((element) => element.isFainting).length;
    return n >= 3 || n >= ownPokemonStates.length;
  }
  
  // 対戦に登場する3匹が確定していた場合、対象のポケモンが登場しているかどうか
  // 3匹が確定していない場合は常にtrue
  bool isPossibleOwnBattling(int i) {
    if (ownPokemonStates.where((element) => element.isBattling).length < 3) {
      return true;
    }
    return ownPokemonStates[i].isBattling;
  }
  bool isPossibleOpponentBattling(int i) {
    if (opponentPokemonStates.where((element) => element.isBattling).length < 3) {
      return true;
    }
    return opponentPokemonStates[i].isBattling;
  }

  // 現在の状態で、指定されたタイミングで起こるべき効果のリストを返す
  List<TurnEffect> getDefaultEffectList(
    PokeDB pokeData, Turn currentTurn, AbilityTiming timing, bool changedOwn, bool changedOpponent,
    TurnEffect? prevAction, int continuousCount
  ) {
    List<TurnEffect> ret = [];
    var attackerState = ownPokemonState;
    var defenderState = opponentPokemonState;
    var attackerPlayerTypeId = PlayerType.me;
    var defenderPlayerTypeId = PlayerType.opponent;
    if (prevAction != null && prevAction.playerType.id == PlayerType.opponent) {
      attackerState = opponentPokemonState;
      defenderState = ownPokemonState;
      attackerPlayerTypeId = PlayerType.opponent;
      defenderPlayerTypeId = PlayerType.me;
    }
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:   // ポケモン登場時
        {
          // ポケモン登場時には無条件で発動する効果
          var timingIDs = [AbilityTiming.pokemonAppear];
          // ポケモン登場時&天気がxxでない
          if (weather.id != Weather.rainy) timingIDs.add(AbilityTiming.pokemonAppearNotRained);
          if (weather.id != Weather.sandStorm) timingIDs.add(AbilityTiming.pokemonAppearNotSandStormed);
          if (weather.id != Weather.sunny) timingIDs.add(AbilityTiming.pokemonAppearNotSunny);
          if (weather.id != Weather.snowy) timingIDs.add(AbilityTiming.pokemonAppearNotSnowed);
          // TODO アイテムとかも
          // TODO 追加順はすばやさを考慮したい
          if (changedOwn) {
            if (timingIDs.contains(ownPokemonState.currentAbility.timing.id)) {
              int extraArg1 = 0;
              if (ownPokemonState.currentAbility.id == 36) {    // トレース
                extraArg1 = opponentPokemonState.currentAbility.id; 
              }
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.me)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = ownPokemonState.currentAbility.id
                ..extraArg1 = extraArg1
              );
            }
          }
          if (changedOpponent) {
            if (timingIDs.contains(opponentPokemonState.currentAbility.timing.id)) {
              int extraArg1 = 0;
              if (ownPokemonState.currentAbility.id == 36) {    // トレース
                extraArg1 = ownPokemonState.currentAbility.id;
              }
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.opponent)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = opponentPokemonState.currentAbility.id
                ..extraArg1 = extraArg1
              );
            }
          }
        }
        break;
      case AbilityTiming.afterMove:   // わざ使用後
        {
          var defenderTimingIDList = [];
          var attackerTimingIDList = [];
          int variedExtraArg1 = 0;
          if (prevAction != null && prevAction.move != null && prevAction.move!.isNormallyHit(continuousCount)) {  // わざ成功時
            if (prevAction.move!.move.damageClass.id == 1) {
              // へんかわざを受けた後
              defenderTimingIDList.add(AbilityTiming.statused);
            }
            if (prevAction.move!.move.damageClass.id >= 2) {
              // こうげきわざヒット後
              attackerTimingIDList.add(AbilityTiming.attackHitted);
              // ぶつりこうげきを受けた時
              if (prevAction.move!.move.damageClass.id == DamageClass.physical) {
                defenderTimingIDList.add(AbilityTiming.phisycalAttackedHitted);
              }
              // こうげきわざを受けた後
              defenderTimingIDList.add(AbilityTiming.attackedHitted);
              // こうげきわざを受けてひんしになったとき
              if (defenderState.isFainting) {
                defenderTimingIDList.add(AbilityTiming.attackedFainting);
              }
              // ノーマルタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 1) {
                defenderTimingIDList.add(148);
              }
              // あくタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 17) {
                defenderTimingIDList.addAll([86, 87]);
              }
              // みずタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 11) {
                defenderTimingIDList.addAll([92, 104]);
              }
              // ほのおタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 10) {
                defenderTimingIDList.addAll([104, 107]);
              }
              // でんきタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 13) {
                defenderTimingIDList.addAll([118]);
              }
              // こおりタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 15) {
                defenderTimingIDList.addAll([119]);
              }
              // ゴーストタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 8) {
                defenderTimingIDList.addAll([87]);
              }
              // むしタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 7) {
                defenderTimingIDList.addAll([92]);
              }
              // 直接こうげきを受けた後
              if (prevAction.move!.move.isDirect &&
                  !(prevAction.move!.move.isPunch && attackerState.holdingItem?.id == 1696) &&  // パンチグローブをつけたパンチわざでない
                  attackerState.currentAbility.id != 203    // とくせいがえんかくでない
              ) {
                // ぼうごパットで防がれないなら
                if (attackerState.holdingItem?.id != 897) {
                  defenderTimingIDList.addAll([AbilityTiming.directAttacked]);
                  // 直接攻撃によってひんしになった場合
                  if (defenderState.isFainting) {
                    defenderTimingIDList.addAll([AbilityTiming.directAttackedFainting]);
                  }
                }
              }
            }
            // 優先度1以上のわざを受けた後
            if (prevAction.move!.move.priority >= 1) {
              defenderTimingIDList.add(AbilityTiming.priorityMoved);
            }
            // 音技を受けた後
            if (prevAction.move!.move.isSound) {
              defenderTimingIDList.add(AbilityTiming.soundAttacked);
            }
            // HP吸収わざを受けた後
            if (prevAction.move!.move.isDrain) {
              defenderTimingIDList.add(AbilityTiming.drained);
            }
            if (prevAction.move!.move.type.id == 13) {    // でんきタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.electriced, AbilityTiming.electricUse]);
            }
            if (prevAction.move!.move.type.id == 11) {    // みずタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.watered, AbilityTiming.fireWaterAttackedSunnyRained, AbilityTiming.waterUse]);
              if (defenderState.currentAbility.id == 87) {   // かんそうはだ
                variedExtraArg1 = defenderPlayerTypeId == PlayerType.me ? -((ownPokemonState.pokemon.h.real / 4).floor()) : -25;
              }
            }
            if (prevAction.move!.move.type.id == 10) {    // ほのおタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.fired, AbilityTiming.fireWaterAttackedSunnyRained]);
            }
            if (prevAction.move!.move.type.id == 12) {    // くさタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grassed]);
            }
            if (prevAction.move!.move.type.id == 5) {    // じめんタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grounded]);
              if (prevAction.move!.move.id != 28 && prevAction.move!.move.id != 614) {  // すなかけ/サウザンアローではない
                defenderTimingIDList.addAll([AbilityTiming.groundFieldEffected]);
              }
            }
            if (PokeType.effectiveness(
                  attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
                  defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                  prevAction.move!.move.type, defenderState
                ).id == MoveEffectiveness.great
            ) {
              // 効果ばつぐんのわざを受けたとき
              defenderTimingIDList.addAll([AbilityTiming.greatAttacked]);
              var moveTypeId = prevAction.move!.move.type.id;
              if (moveTypeId == 10) defenderTimingIDList.add(131);
              if (moveTypeId == 11) defenderTimingIDList.add(132);
              if (moveTypeId == 13) defenderTimingIDList.add(133);
              if (moveTypeId == 12) defenderTimingIDList.add(134);
              if (moveTypeId == 15) defenderTimingIDList.add(135);
              if (moveTypeId == 2) defenderTimingIDList.add(136);
              if (moveTypeId == 4) defenderTimingIDList.add(137);
              if (moveTypeId == 5) defenderTimingIDList.add(138);
              if (moveTypeId == 3) defenderTimingIDList.add(139);
              if (moveTypeId == 14) defenderTimingIDList.add(140);
              if (moveTypeId == 7) defenderTimingIDList.add(141);
              if (moveTypeId == 6) defenderTimingIDList.add(142);
              if (moveTypeId == 8) defenderTimingIDList.add(143);
              if (moveTypeId == 16) defenderTimingIDList.add(144);
              if (moveTypeId == 17) defenderTimingIDList.add(145);
              if (moveTypeId == 9) defenderTimingIDList.add(146);
              if (moveTypeId == 18) defenderTimingIDList.add(147);
            }
            else {
              // 効果ばつぐん以外のわざを受けたとき
              defenderTimingIDList.addAll([AbilityTiming.notGreatAttacked]);
            }
          }

          // 対応するタイミングに該当するとくせい
          // TODO 追加順はすばやさを考慮したい
          if (attackerTimingIDList.contains(attackerState.currentAbility.timing.id)) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = attackerState.currentAbility.id
            );
          }
          if (defenderTimingIDList.contains(defenderState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (defenderState.currentAbility.id == 10 ||  // ちくでん
                defenderState.currentAbility.id == 11     // ちょすい
            ) {
              extraArg1 = defenderPlayerTypeId == PlayerType.me ? -((ownPokemonState.pokemon.h.real / 4).floor()) : -25;
            }
            if (defenderState.currentAbility.id == 16) {   // へんしょく
              extraArg1 = prevAction!.move!.move.type.id;
            }
            if (defenderState.currentAbility.id == 24 || defenderState.currentAbility.id == 160) {   // さめはだ/てつのトゲ
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 8).floor() : 12;
            }
            if (defenderState.currentAbility.id == 87) {    // かんそうはだ
              extraArg1 = variedExtraArg1;
            }
            if (defenderState.currentAbility.id == 106) {   // ゆうばく
                extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 4).floor() : 25;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = defenderState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }
          // 対応するタイミングに該当するもちもの
          if (attackerState.holdingItem != null && attackerTimingIDList.contains(attackerState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            if (attackerState.holdingItem!.id == 247) {   // いのちのたま
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 10).floor() : 10;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = attackerState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
          if (defenderState.holdingItem != null && defenderTimingIDList.contains(defenderState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            if (defenderState.holdingItem!.id == 583) {   // ゴツゴツメット
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 6).floor() : 16;
            }
            if (defenderState.holdingItem!.id == 188 || defenderState.holdingItem!.id == 189) {   // ジャポのみ/レンブのみ
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 8).floor() : 12;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = defenderState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
        }
        break;
      case AbilityTiming.everyTurnEnd:   // 毎ターン終了時
        {
          // 毎ターン終了時には無条件で発動する効果
          var timingIDs = [AbilityTiming.everyTurnEnd];
          var ownTimingIDs = [];
          var opponentTimingIDs = [];
          // 1度でも行動した後毎ターン終了時
          if (currentTurn.initialOwnPokemonIndex == ownPokemonIndex) ownTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
          if (currentTurn.initialOpponentPokemonIndex == opponentPokemonIndex) opponentTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
          if (weather.id == Weather.rainy) {
            timingIDs.addAll([65,50]);   // 天気があめのとき、毎ターン終了時
            if (ownPokemonState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) ownTimingIDs.add(72);       // かつ状態異常のとき
            if (opponentPokemonState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) opponentTimingIDs.add(72);
          }
          if (weather.id == Weather.sunny) timingIDs.addAll([50, 73]);   // 天気が晴れのとき、毎ターン終了時
          if (weather.id == Weather.sunny) timingIDs.addAll([79]);        // 天気がゆきのとき、毎ターン終了時
          if (ownPokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
            ownTimingIDs.add(52);
          }
          if (opponentPokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
            opponentTimingIDs.add(52);
          }
          if (ownPokemonState.teraType == null || ownPokemonState.teraType!.id == 0) {  // テラスタルしていない
            ownTimingIDs.add(116);
          }
          if (opponentPokemonState.teraType == null || opponentPokemonState.teraType!.id == 0) {  // テラスタルしていない
            opponentTimingIDs.add(116);
          }
          if (ownPokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) ownTimingIDs.add(152);             // 状態異常でない毎ターン終了時
          if (opponentPokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) opponentTimingIDs.add(152);   // 状態異常でない毎ターン終了時
          ownTimingIDs.addAll(timingIDs);
          opponentTimingIDs.addAll(timingIDs);

          if (ownTimingIDs.contains(ownPokemonState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (ownPokemonState.currentAbility.id == 44 || ownPokemonState.currentAbility.id == 115) {   // あめうけざら/アイスボディ
              extraArg1 = -((ownPokemonState.pokemon.h.real / 16).floor());
            }
            if (ownPokemonState.currentAbility.id == 94) {   // サンパワー
              extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
            }
            if (ownPokemonState.currentAbility.id == 87 && weather.id == Weather.sunny) {   // かんそうはだ＆晴れ
              extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
            }
            if ((ownPokemonState.currentAbility.id == 87 && weather.id == Weather.rainy) ||   // かんそうはだ＆雨
                ownPokemonState.currentAbility.id == 90   // ポイズンヒール
            ) {
              extraArg1 = -((ownPokemonState.pokemon.h.real / 8).floor());
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.me)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.ability)
              ..effectId = ownPokemonState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }
          if (opponentTimingIDs.contains(opponentPokemonState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (opponentPokemonState.currentAbility.id == 44 || opponentPokemonState.currentAbility.id == 115) {   // あめうけざら/アイスボディ
              extraArg1 = -6;
            }
            if (opponentPokemonState.currentAbility.id == 94) {   // サンパワー
              extraArg1 = 12;
            }
            if (opponentPokemonState.currentAbility.id == 87 && weather.id == Weather.sunny) {   // かんそうはだ＆晴れ
              extraArg1 = 12;
            }
            if ((opponentPokemonState.currentAbility.id == 87 && weather.id == Weather.rainy) ||   // かんそうはだ＆雨
                opponentPokemonState.currentAbility.id == 90    // ポイズンヒール
            ) {
              extraArg1 = -12;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.ability)
              ..effectId = opponentPokemonState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }

          if (ownPokemonState.holdingItem != null && ownTimingIDs.contains(ownPokemonState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            switch (ownPokemonState.holdingItem!.id) {
              case 265:     // くっつきバリ
                extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
                break;
              case 132:     // オレンのみ
                extraArg1 = -10;
                break;
              case 43:      // きのみジュース
                extraArg1 = -20;
                break;
              case 135:     // オボンのみ
              case 185:     // ナゾのみ
                extraArg1 = -(ownPokemonState.pokemon.h.real / 4).floor();
                break;
              case 136:     // フィラのみ
              case 137:     // ウイのみ
              case 138:     // マゴのみ
              case 139:     // バンジのみ
              case 140:     // イアのみ
                extraArg1 = -(ownPokemonState.pokemon.h.real / 3).floor();
                break;
              case 258:     // くろいヘドロ
                if (ownPokemonState.isTypeContain(4)) {   // どくタイプか
                  extraArg1 = -(ownPokemonState.pokemon.h.real / 16).floor();
                }
                else {
                  extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
                }
                break;
              case 211:     // たべのこし
                extraArg1 = -(ownPokemonState.pokemon.h.real / 16).floor();
                break;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.me)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.item)
              ..effectId = ownPokemonState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
          if (opponentPokemonState.holdingItem != null && opponentTimingIDs.contains(opponentPokemonState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            switch (ownPokemonState.holdingItem!.id) {
              case 265:     // くっつきバリ
                extraArg1 = 12;
                break;
              case 135:     // オボンのみ
              case 185:     // ナゾのみ
                extraArg1 = -25;
                break;
              case 136:     // フィラのみ
              case 137:     // ウイのみ
              case 138:     // マゴのみ
              case 139:     // バンジのみ
              case 140:     // イアのみ
                extraArg1 = -33;
                break;
              case 258:     // くろいヘドロ
                if (ownPokemonState.isTypeContain(4)) {   // どくタイプか
                  extraArg1 = -6;
                }
                else {
                  extraArg1 = 12;
                }
                break;
              case 211:     // たべのこし
                extraArg1 = -6;
                break;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.item)
              ..effectId = opponentPokemonState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
        }
        break;
    }
    return ret;
  }
}

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
    int phaseIdx, Party ownParty, Party opponentParty, PokeDB pokeData)
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
        ret, pokeData, lastAction, continousCount,
      );
    }
    return ret;
  }

  // SQLに保存された文字列からTurnをパース
  static Turn deserialize(
    dynamic str, PokeDB pokeData, String split1, String split2,
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
      ret.initialOwnPokemonStates.add(PokemonState.deserialize(state, pokeData, split3, split4, split5));
    }
    // initialOpponentPokemonStates
    states = turnElements[3].split(split2);
    for (final state in states) {
      if (state == '') break;
      ret.initialOpponentPokemonStates.add(PokemonState.deserialize(state, pokeData, split3, split4, split5));
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
    final directory = await getApplicationDocumentsDirectory();
    final localPath = directory.path;
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
    // await deleteDatabase(battleDBPath);
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
        );
        // turns
        final turns = map[battleColumnTurns].split(sqlSplit1);
        for (final turn in turns) {
          if (turn == '') break;
          battles.last.turns.add(Turn.deserialize(turn, this, sqlSplit2, sqlSplit3, sqlSplit4, sqlSplit5, sqlSplit6));
        }
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

    // 既存対戦の上書きなら、対戦内パーティの被参照カウントをデクリメント
    int index = battles.indexWhere((element) => element.id == battle.id);
    if (index >= 0) {
      battles[index].ownParty.refCount--;
      battles[index].opponentParty.refCount--;
    }

    // 対戦内パーティの被参照カウントをインクリメント
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
      final battleIdx = battles.indexWhere((element) => element.id == e);
      // 対戦内パーティおよびポケモンの被参照カウントをデクリメント
      for (int j = 0; j < battles[battleIdx].ownParty.pokemonNum; j++) {
        battles[battleIdx].ownParty.pokemons[j]!.refCount--;
      }
      battles[battleIdx].ownParty.refCount--;
      for (int j = 0; j < battles[battleIdx].opponentParty.pokemonNum; j++) {
        battles[battleIdx].opponentParty.pokemons[j]!.refCount--;
      }
      battles[battleIdx].opponentParty.refCount--;
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
