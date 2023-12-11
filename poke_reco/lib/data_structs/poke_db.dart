import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_sort_dialog.dart';
import 'package:poke_reco/custom_dialogs/party_sort_dialog.dart';
import 'package:poke_reco/custom_dialogs/battle_sort_dialog.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/ability.dart';
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
const String configKeyPokemonsNoFilter = 'pokemonsNoFilter';
const String configKeyPokemonsTypeFilter = 'pokemonsTypeFilter';
const String configKeyPokemonsTeraTypeFilter = 'pokemonsTeraTypeFilter';
const String configKeyPokemonsMoveFilter = 'pokemonsMoveFilter';
const String configKeyPokemonsSexFilter = 'pokemonsSexFilter';
const String configKeyPokemonsAbilityFilter = 'pokemonsAbilityFilter';
const String configKeyPokemonsTemperFilter = 'pokemonsTemperFilter';

const String configKeyPokemonsSort = 'pokemonsSort';

const String configKeyPartiesOwnerFilter = 'partiesOwnerFilter';
const String configKeyPartiesWinRateMinFilter = 'partiesWinRateMinFilter';
const String configKeyPartiesWinRateMaxFilter = 'partiesWinRateMaxFilter';
const String configKeyPartiesPokemonNoFilter = 'partiesPokemonNoFilter';

const String configKeyPartiesSort = 'partiesSort';

const String configKeyBattlesWinFilter = 'partiesWinFilter';
const String configKeyBattlesPartyIDFilter = 'partiesPartyIDFilter';

const String configKeyBattlesSort = 'battlesSort';

const String configKeyGetNetworkImage = 'getNetworkImage';

const String abilityDBFile = 'Abilities.db';
const String abilityDBTable = 'abilityDB';
const String abilityColumnId = 'id';
const String abilityColumnName = 'name';
const String abilityColumnTiming = 'timing';
const String abilityColumnTarget = 'target';
const String abilityColumnEffect = 'effect';

const String abilityFlavorDBFile = 'AbilityFlavors.db';
const String abilityFlavorDBTable = 'abilityFlavorDB';
const String abilityFlavorColumnId = 'id';
const String abilityFlavorColumnFlavor = 'flavor';

const String temperDBFile = 'Tempers.db';
const String temperDBTable = 'temperDB';
const String temperColumnId = 'id';
const String temperColumnName = 'name';
const String temperColumnDe = 'decreased_stat';
const String temperColumnIn = 'increased_stat';

const String eggGroupDBFile = 'EggGroup.db';
const String eggGroupDBTable = 'eggGroupDB';
const String eggGroupColumnId = 'id';
const String eggGroupColumnName = 'name';

const String itemDBFile = 'Items.db';
const String itemDBTable = 'itemDB';
const String itemColumnId = 'id';
const String itemColumnName = 'name';
const String itemColumnFlingPower = 'fling_power';
const String itemColumnFlingEffect = 'fling_effect';
const String itemColumnTiming = 'timing';
const String itemColumnIsBerry = 'is_berry';
const String itemColumnImageUrl = 'image_url';

const String itemFlavorDBFile = 'ItemFlavors.db';
const String itemFlavorDBTable = 'itemFlavorDB';
const String itemFlavorColumnId = 'id';
const String itemFlavorColumnFlavor = 'flavor';

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

const String moveFlavorDBFile = 'MoveFlavors.db';
const String moveFlavorDBTable = 'moveFlavorDB';
const String moveFlavorColumnId = 'id';
const String moveFlavorColumnFlavor = 'flavor';

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
const String pokeBaseColumnHeight = 'height';
const String pokeBaseColumnWeight = 'weight';
const String pokeBaseColumnEggGroup = 'eggGroup';
const String pokeBaseColumnImageUrl = 'imageUrl';

const String myPokemonDBFile = 'MyPokemons.db';
const String myPokemonDBTable = 'myPokemonDB';
const String myPokemonColumnId = 'id';
const String myPokemonColumnViewOrder = 'viewOrder';
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


const String partyDBFile = 'parties.db';
const String partyDBTable = 'partyDB';
const String partyColumnId = 'id';
const String partyColumnViewOrder = 'viewOrder';
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

const String battleDBFile = 'battles.db';
const String battleDBTable = 'battleDB';
const String battleColumnId = 'id';
const String battleColumnViewOrder = 'viewOrder';
const String battleColumnName = 'name';
const String battleColumnTypeId = 'battleType';
const String battleColumnDate = 'date';
const String battleColumnOwnPartyId = 'ownParty';
const String battleColumnOpponentName = 'opponentName';
const String battleColumnOpponentPartyId = 'opponentParty';
const String battleColumnTurns = 'turns';
const String battleColumnIsMyWin = 'isMyWin';
const String battleColumnIsYourWin = 'isYourWin';

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

enum Sex {
  none(0, 'なし', Icon(Icons.remove, color: Colors.grey)),
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

  static const Map<String, String> statNameToAlphabet = {
    'attack' : 'A',
    'defense' : 'B',
    'special-attack' : 'C',
    'special-defense' : 'D',
    'speed' : 'S',
  };

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

  String get increasedAlphabet {
    return statNameToAlphabet.containsKey(increasedStat) ? statNameToAlphabet[increasedStat]! : '';
  }

  String get decreasedAlphabet {
    return statNameToAlphabet.containsKey(decreasedStat) ? statNameToAlphabet[decreasedStat]! : '';
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

  SixParams copyWith() => SixParams(race, indi, effort, real);

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

class EggGroup {
  final int id;
  final String displayName;

  const EggGroup(this.id, this.displayName);
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

  bool get isTargetYou {  // 相手を対象に含むかどうか
    return target.id == 6 || (8 <= target.id && target.id <= 11) || target.id == 14; 
  }

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
      (damageClass.id == DamageClass.special && specialButNot.contains(id))
    );
  }

  bool get isSound {   // 音技かどうか
    const soundMoveIDs = [
      547, 173, 215, 103, 47, 664, 497, 786, 448, 568, 319, 320,
      253, 691, 575, 775, 10016, 574, 48, 336, 590, 45, 555, 304,
      586, 826, 871, 728, 46, 195, 405, 496, 463,
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

  bool get isRecoil {  // 反動わざかどうか(とくせい「すてみ」の対象)
    const recoilMoveIDs = [
      543, 834, 452, 853, 66, 38, 36, 26, 136, 617, 394, 413,
      344, 457, 528,
    ];
    return recoilMoveIDs.contains(id);
  }

  bool get isBite {  // かみつきわざかどうか
    const biteMoveIDs = [
      755, 242, 44, 422, 746, 423, 706, 305, 158, 424,
    ];
    return biteMoveIDs.contains(id);
  }

  bool get isCut {  // 切るわざかどうか
    const cutMoveIDs = [
      895, 15, 314, 403, 830, 781, 163, 440, 427, 875, 534, 404,
      548, 533, 669, 400, 332, 869, 860, 75, 845, 891, 348, 210,
    ];
    return cutMoveIDs.contains(id);
  }

  bool get isWind { // 風わざかどうか
    const windMoveIDs = [
      314, 16, 847, 846, 196, 239, 848, 257, 572, 831, 18, 59, 542, 584,
    ];
    return windMoveIDs.contains(id);
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
    if (effect.id == 459) return 3;
    if (effect.id == 462) return 3;
    if (effect.id == 480) return 10;
    if (effect.id == 483) return 3;
    return 1;
  }

  // 必ず追加効果が起こるかどうかを返す
  bool isSurelyEffect() {
    switch (effect.id) {
      case 3:     // どくにする(確率)
      case 78:    // 2回こうげき、どくにする(確率)
      case 210:   // どくにする(確率)。急所に当たりやすい
      case 5:     // やけどにする(確率)
      case 201:   // やけどにする(確率)。急所に当たりやすい
      case 6:     // こおりにする(確率)
      case 261:   // こおりにする(確率)。天気がゆきのときは必中
      case 7:     // まひにする(確率)
      case 153:   // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
      case 372:   // まひにする(確率)
      case 140:   // 使用者のこうげきを1段階上げる(確率)
      case 139:   // 使用者のぼうぎょを1段階上げる(確率)
      case 277:   // 使用者のとくこうを1段階上げる(確率)
      case 69:    // こうげきを1段階下げる(確率)
      case 70:    // ぼうぎょを1段階下げる(確率)
      case 71:    // すばやさを1段階下げる(確率)
      case 74:    // めいちゅうを1段階下げる(確率)
      case 32:    // ひるませる(確率)
      case 93:    // ひるませる(確率)。ねむり状態のときのみ成功
      case 203:   // もうどくにする(確率)
      case 37:    // やけど・こおり・まひのいずれかにする(確率)
      case 77:    // こんらんさせる(確率)
      case 268:   // こんらんさせる(確率)
      case 334:   // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
      case 359:   // 使用者のぼうぎょを2段階上げる(確率)
      case 272:   // とくぼうを2段階下げる(確率)
      case 72:    // とくこうを1段階下げる(確率)
      case 73:    // とくぼうを1段階下げる(確率)
      case 141:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
      case 227:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
      case 254:   // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
      case 263:   // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
        if (effectChance < 100) {
          return false;
        }
        return true;
      default:
        return true;
    }
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
  static const String pokeApiRoute = "https://pokeapi.co/api/v2";

  // 設定等を保存する(端末の)ファイル
  late final File _saveDataFile;
  List<Owner> pokemonsOwnerFilter = [Owner.mine];
  List<int> pokemonsNoFilter = [];
  List<int> pokemonsTypeFilter = [for (int i = 1; i < 19; i++) i];
  List<int> pokemonsTeraTypeFilter = [for (int i = 1; i < 19; i++) i];
  List<int> pokemonsMoveFilter = [];
  List<int> pokemonsSexFilter = [for (var sex in Sex.values) sex.id];
  List<int> pokemonsAbilityFilter = [];
  List<int> pokemonsTemperFilter = [];
  PokemonSort? pokemonsSort;

  List<Owner> partiesOwnerFilter = [Owner.mine];
  int partiesWinRateMinFilter = 0;
  int partiesWinRateMaxFilter = 100;
  List<int> partiesPokemonNoFilter = [];
  PartySort? partiesSort;

  List<int> battlesWinFilter = [for (int i = 1; i < 4; i++) i];  // 1: 勝敗未決 2:勝ち 3:負け
  List<int> battlesPartyIDFilter = [];
  BattleSort? battlesSort;

  Map<int, Ability> abilities = {0: Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0))}; // 無効なとくせい
  late Database abilityDb;
  Map<int, String> abilityFlavors = {0: ''};  // 無効なとくせい
  late Database abilityFlavorDb;
  Map<int, Temper> tempers = {0: Temper(0, '', '', '')};  // 無効なせいかく
  late Database temperDb;
  Map<int, Item> items = {
    0: Item(
      id: 0, displayName: '', flingPower: 0, flingEffectId: 0,
      timing: AbilityTiming(0), isBerry: false, imageUrl: ''
    )
  };  // 無効なもちもの
  late Database itemDb;
  Map<int, String> itemFlavors = {0: ''};   // 無効なもちもの
  late Database itemFlavorDb;
  Map<int, Move> moves = {0: Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0)}; // 無効なわざ
  late Database moveDb;
  Map<int, String> moveFlavors = {0: ''};   // 無効なわざ
  late Database moveFlavorDb;
  List<PokeType> types = [
    for (final i in range(1, 19)) PokeType.createFromId(i.toInt())
  ];
  Map<int, EggGroup> eggGroups = {0: EggGroup(0, '')};  // 無効なタマゴグループ
  late Database eggGroupDb;
  Map<int, PokeBase> pokeBase = {   // 無効なポケモン
    0: PokeBase(
      name: '',
      sex: [Sex.createFromId(0)],
      no: 0, type1: PokeType.createFromId(0),
      type2: null, h: 0, a: 0, b: 0, c: 0, d: 0, s: 0,
      ability: [], move: [], height: 0, weight: 0, eggGroups: [], imageUrl: 'https://dammy',),
  };
  late Database pokeBaseDb;
  Map<int, Pokemon> pokemons = {0: Pokemon()};
  late Database myPokemonDb;
  Map<int, Party> parties = {0: Party()};
  late Database partyDb;
  Map<int, Battle> battles = {0: Battle()};
  late Database battleDb;

  bool getPokeAPI = true;     // インターネットに接続してポケモンの画像を取得するか

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
        pokemonsNoFilter = [];
        for (final e in configJson[configKeyPokemonsNoFilter]) {
          pokemonsNoFilter.add(e as int);
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
          pokemonsSexFilter.add(e as int);
        }
        pokemonsAbilityFilter = [];
        for (final e in configJson[configKeyPokemonsAbilityFilter]) {
          pokemonsAbilityFilter.add(e as int);
        }
        pokemonsTemperFilter = [];
        for (final e in configJson[configKeyPokemonsTemperFilter]) {
          pokemonsTemperFilter.add(e as int);
        }
        int sort = configJson[configKeyPokemonsSort] as int;
        pokemonsSort = sort == 0 ? null : PokemonSort.createFromId(sort);

        partiesOwnerFilter = [];
        for (final e in configJson[configKeyPartiesOwnerFilter]) {
          switch (e) {
            case 0:
              partiesOwnerFilter.add(Owner.mine);
              break;
            case 1:
              partiesOwnerFilter.add(Owner.fromBattle);
              break;
            case 2:
            default:
              partiesOwnerFilter.add(Owner.hidden);
              break;
          }
        }
        partiesWinRateMinFilter = configJson[configKeyPartiesWinRateMinFilter] as int;
        partiesWinRateMaxFilter = configJson[configKeyPartiesWinRateMaxFilter] as int;
        partiesPokemonNoFilter = [];
        for (final e in configJson[configKeyPartiesPokemonNoFilter]) {
          partiesPokemonNoFilter.add(e as int);
        }
        sort = configJson[configKeyPartiesSort] as int;
        partiesSort = sort == 0 ? null : PartySort.createFromId(sort);
        
        battlesWinFilter = [];
        for (final e in configJson[configKeyBattlesWinFilter]) {
          battlesWinFilter.add(e as int);
        }
        battlesPartyIDFilter = [];
        for (final e in configJson[configKeyBattlesPartyIDFilter]) {
          battlesPartyIDFilter.add(e as int);
        }
        sort = configJson[configKeyBattlesSort] as int;
        battlesSort = sort == 0 ? null : BattleSort.createFromId(sort);
        getPokeAPI = (configJson[configKeyGetNetworkImage] as int) != 0;
      }
      catch (e) {
        pokemonsOwnerFilter = [Owner.mine];
        pokemonsNoFilter = [];
        pokemonsTypeFilter = [for (int i = 1; i < 19; i++) i];
        pokemonsTeraTypeFilter = [for (int i = 1; i < 19; i++) i];
        pokemonsMoveFilter = [];
        pokemonsSexFilter = [for (var sex in Sex.values) sex.id];
        pokemonsAbilityFilter = [];
        pokemonsTemperFilter = [];
        pokemonsSort = null;
        partiesOwnerFilter = [Owner.mine];
        partiesWinRateMinFilter = 0;
        partiesWinRateMaxFilter = 100;
        partiesPokemonNoFilter = [];
        partiesSort = null;
        battlesWinFilter = [for (int i = 1; i < 4; i++) i];
        battlesPartyIDFilter = [];
        battlesSort = null;
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


    //////////// とくせいの説明
    abilityFlavorDb = await openAssetDatabase(abilityFlavorDBFile);
    // 内部データに変換
    maps = await abilityFlavorDb.query(abilityFlavorDBTable,
      columns: [abilityFlavorColumnId, abilityFlavorColumnFlavor,],
    );
    for (var map in maps) {
      abilityFlavors[map[abilityFlavorColumnId]] = map[abilityFlavorColumnFlavor];
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


    //////////// タマゴグループ
    eggGroupDb = await openAssetDatabase(eggGroupDBFile);
    // 内部データに変換
    maps = await eggGroupDb.query(eggGroupDBTable,
      columns: [eggGroupColumnId, eggGroupColumnName],
    );
    for (var map in maps) {
      eggGroups[map[eggGroupColumnId]] = EggGroup(
        map[eggGroupColumnId],
        map[eggGroupColumnName],
      );
    }


    //////////// もちもの
    itemDb = await openAssetDatabase(itemDBFile);
    // 内部データに変換
    maps = await itemDb.query(itemDBTable,
      columns: [itemColumnId, itemColumnName, itemColumnFlingPower, itemColumnFlingEffect, itemColumnTiming, itemColumnIsBerry, itemColumnImageUrl],
    );
    for (var map in maps) {
      items[map[itemColumnId]] = Item(
        id: map[itemColumnId],
        displayName: map[itemColumnName],
        flingPower: map[itemColumnFlingPower],
        flingEffectId: map[itemColumnFlingEffect],
        timing: AbilityTiming(map[itemColumnTiming]),
        isBerry: map[itemColumnIsBerry] == 1,
        imageUrl: map[itemColumnImageUrl]
      );
    }


    //////////// もちものの説明
    itemFlavorDb = await openAssetDatabase(itemFlavorDBFile);
    // 内部データに変換
    maps = await itemFlavorDb.query(itemFlavorDBTable,
      columns: [itemFlavorColumnId, itemFlavorColumnFlavor,],
    );
    for (var map in maps) {
      itemFlavors[map[itemFlavorColumnId]] = map[itemFlavorColumnFlavor];
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


    //////////// わざの説明
    moveFlavorDb = await openAssetDatabase(moveFlavorDBFile);
    // 内部データに変換
    maps = await moveFlavorDb.query(moveFlavorDBTable,
      columns: [moveFlavorColumnId, moveFlavorColumnFlavor,],
    );
    for (var map in maps) {
      moveFlavors[map[moveFlavorColumnId]] = map[moveFlavorColumnFlavor];
    }


    //////////// ポケモン図鑑
    pokeBaseDb = await openAssetDatabase(pokeBaseDBFile);
    // 内部データに変換
    maps = await pokeBaseDb.query(pokeBaseDBTable,
      columns: [
        pokeBaseColumnId, pokeBaseColumnName, pokeBaseColumnAbility,
        pokeBaseColumnForm, pokeBaseColumnFemaleRate, pokeBaseColumnMove,
        for (var e in pokeBaseColumnStats) e,
        pokeBaseColumnType, pokeBaseColumnHeight,
        pokeBaseColumnWeight, pokeBaseColumnEggGroup, pokeBaseColumnImageUrl,],
    );

    for (var map in maps) {
      final pokeTypes = parseIntList(map[pokeBaseColumnType]);
      final pokeAbilities = parseIntList(map[pokeBaseColumnAbility]);
      final pokeMoves = parseIntList(map[pokeBaseColumnMove]);
      final pokeEggGroups = parseIntList(map[pokeBaseColumnEggGroup]);
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
        height: map[pokeBaseColumnHeight],
        weight: map[pokeBaseColumnWeight],
        eggGroups: [for (var e in pokeEggGroups) eggGroups[e]!],
        imageUrl: map[pokeBaseColumnImageUrl],
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
          myPokemonColumnId, myPokemonColumnViewOrder,
          myPokemonColumnNo, myPokemonColumnNickName,
          myPokemonColumnTeraType, myPokemonColumnLevel,
          myPokemonColumnSex, myPokemonColumnTemper,
          myPokemonColumnAbility, myPokemonColumnItem,
          for (var e in myPokemonColumnIndividual) e,
          for (var e in myPokemonColumnEffort) e,
          myPokemonColumnMove1, myPokemonColumnPP1,
          myPokemonColumnMove2, myPokemonColumnPP2,
          myPokemonColumnMove3, myPokemonColumnPP3,
          myPokemonColumnMove4, myPokemonColumnPP4,
          myPokemonColumnOwnerID,
        ],
      );

      for (var map in maps) {
        var pokemon = Pokemon.createFromDBMap(map);
        pokemons[pokemon.id] = pokemon;
      }
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
          partyColumnId, partyColumnViewOrder, partyColumnName,
          partyColumnPokemonId1, partyColumnPokemonItem1,
          partyColumnPokemonId2, partyColumnPokemonItem2,
          partyColumnPokemonId3, partyColumnPokemonItem3,
          partyColumnPokemonId4, partyColumnPokemonItem4,
          partyColumnPokemonId5, partyColumnPokemonItem5,
          partyColumnPokemonId6, partyColumnPokemonItem6,
          partyColumnOwnerID,
        ],
      );

      for (var map in maps) {
        var party = Party.createFromDBMap(map);
        parties[party.id] = party;
      }
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
          battleColumnId, battleColumnViewOrder, battleColumnName,
          battleColumnTypeId, battleColumnDate, battleColumnOwnPartyId,
          battleColumnOpponentName, battleColumnOpponentPartyId,
          battleColumnTurns, battleColumnIsMyWin, battleColumnIsYourWin,
        ],
      );

      for (var map in maps) {
        var battle = Battle.createFromDBMap(map);
        battles[battle.id] = battle;
      }
    }

    // 各パーティの勝率算出
    updatePartyWinRate();

    isLoaded = true;
  }

  void updatePartyWinRate() {
    for (final party in parties.values) {
      party.usedCount = 0;
      party.winCount = 0;
    }
    for (final battle in battles.values) {
      int partyID = battle.getParty(PlayerType(PlayerType.me)).id;
      parties[partyID]!.usedCount++;
      if (battle.isMyWin) parties[partyID]!.winCount++;
    }
    for (final party in parties.values) {
      if (party.usedCount == 0) {
        party.winRate = 0;
      }
      else {
        party.winRate = (party.winCount / party.usedCount * 100).floor();
      }
    }
  }

  Future<void> saveConfig() async {
    String jsonText = jsonEncode(
      {
        configKeyPokemonsOwnerFilter: [for (final e in pokemonsOwnerFilter) e.index],
        configKeyPokemonsNoFilter: [for (final e in pokemonsNoFilter) e],
        configKeyPokemonsTypeFilter: [for (final e in pokemonsTypeFilter) e],
        configKeyPokemonsTeraTypeFilter: [for (final e in pokemonsTeraTypeFilter) e],
        configKeyPokemonsMoveFilter: [for (final e in pokemonsMoveFilter) e],
        configKeyPokemonsSexFilter: [for (final e in pokemonsSexFilter) e],
        configKeyPokemonsAbilityFilter: [for (final e in pokemonsAbilityFilter) e],
        configKeyPokemonsTemperFilter: [for (final e in pokemonsTemperFilter) e],
        configKeyPokemonsSort: pokemonsSort == null ? 0 : pokemonsSort!.id,

        configKeyPartiesOwnerFilter: [for (final e in partiesOwnerFilter) e.index],
        configKeyPartiesWinRateMinFilter: partiesWinRateMinFilter,
        configKeyPartiesWinRateMaxFilter: partiesWinRateMaxFilter,
        configKeyPartiesPokemonNoFilter: [for (final e in partiesPokemonNoFilter) e],
        configKeyPartiesSort: partiesSort == null ? 0 : partiesSort!.id,

        configKeyBattlesWinFilter: battlesWinFilter,
        configKeyBattlesPartyIDFilter: battlesPartyIDFilter,
        configKeyBattlesSort: battlesSort == null ? 0 : battlesSort!.id,

        configKeyGetNetworkImage: getPokeAPI ? 1 : 0,
      }
    );
    await _saveDataFile.writeAsString(jsonText);
  }

  int _getUniqueID(List<int> ids) {
    int ret = 1;
    ids.sort((a, b) => a.compareTo(b));
    assert(ids.last < 0xffffffff);
    /*for (final e in ids) {
      if (e > ret) break;
      ret++;
    }*/
    if (ids.isNotEmpty) ret = ids.last+1;
    return ret;
  }

  int _getUniqueMyPokemonID() {
    return _getUniqueID(pokemons.keys.toList());
  }

  int _getUniquePartyID() {
    return _getUniqueID(parties.keys.toList());
  }

  int _getUniqueBattleID() {
    return _getUniqueID(battles.keys.toList());
  }

  Future<void> _deleteUnrefs() async {
    // 各パーティが対戦で参照されているか判定
    Map<int, bool> partyRefs = {};
    for (final e in parties.keys) {
      partyRefs[e] = false;
    }
    for (final e in battles.values) {
      partyRefs[e.getParty(PlayerType(PlayerType.me)).id] = true;
      partyRefs[e.getParty(PlayerType(PlayerType.opponent)).id] = true;
    }
    // 参照されておらず、削除可なら削除する
    List<int> deleteIDs = [];
    for (final e in partyRefs.entries) {
      if (!e.value && parties.containsKey(e.key) && parties[e.key]!.owner == Owner.hidden) deleteIDs.add(e.key);
    }
    parties.removeWhere((k, v) => deleteIDs.contains(k));
    String whereStr = '$partyColumnId=?';
    for (int i = 1; i < deleteIDs.length; i++) {
      whereStr += ' OR $partyColumnId=?';
    }
    await partyDb.delete(
      partyDBTable,
      where: whereStr,
      whereArgs: deleteIDs,
    );
    // 参照している対戦用のフィルタからも削除
    battlesPartyIDFilter.removeWhere((e) => deleteIDs.contains(e));
    
    // 各ポケモンがパーティで参照されているか判定
    Map<int, bool> myPokemonRefs = {};
    for (final e in pokemons.keys) {
      myPokemonRefs[e] = false;
    }
    for (final e in parties.values) {
      for (int i = 0; i < e.pokemonNum; i++) {
        myPokemonRefs[e.pokemons[i]!.id] = true;
      }
    }
    // 参照されておらず、削除可なら削除する
    deleteIDs = [];
    for (final e in myPokemonRefs.entries) {
      if (!e.value && pokemons.containsKey(e.key) && pokemons[e.key]!.owner == Owner.hidden) deleteIDs.add(e.key);
    }
    pokemons.removeWhere((k, v) => deleteIDs.contains(k));
    whereStr = '$myPokemonColumnId=?';
    for (int i = 1; i < deleteIDs.length; i++) {
      whereStr += ' OR $partyColumnId=?';
    }
    await myPokemonDb.delete(
      myPokemonDBTable,
      where: whereStr,
      whereArgs: deleteIDs,
    );
  }

  Future<void> _prepareMyPokemonDB() async {
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
  }

  Future<void> addMyPokemon(Pokemon myPokemon, bool createNew) async {
    await _prepareMyPokemonDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      myPokemon.id = _getUniqueMyPokemonID();
      myPokemon.viewOrder = myPokemon.id;
    }
    pokemons[myPokemon.id] = myPokemon;

    // SQLiteのDBに挿入
    await myPokemonDb.insert(
      myPokemonDBTable,
      myPokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAllMyPokemonViewOrder() async {
    await _prepareMyPokemonDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$myPokemonColumnId=?';
    for (final e in pokemons.values) {
      await myPokemonDb.update(
        myPokemonDBTable,
        {myPokemonColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteMyPokemon(List<int> ids) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath);

    // 削除可フラグを付与
    for (int e in ids) {
      pokemons[e]!.owner = Owner.hidden;
    }

    await _deleteUnrefs();
  }

  Future<void> _preparePartyDB() async {
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
  }

  Future<void> addParty(Party party, bool createNew) async {
    await _preparePartyDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      party.id = _getUniquePartyID();
      party.viewOrder = party.id;
    }
    parties[party.id] = party;

    // SQLiteのDBに挿入
    await partyDb.insert(
      partyDBTable,
      party.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAllPartyViewOrder() async {
    await _preparePartyDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$partyColumnId=?';
    for (final e in parties.values) {
      await partyDb.update(
        partyDBTable,
        {partyColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteParty(List<int> ids) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(await getDatabasesPath(), partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath);

    // 削除可フラグを付与
    for (int e in ids) {
      parties[e]!.owner = Owner.hidden;
    }

    await _deleteUnrefs();
  }

  Future<void> _prepareBattleDB() async {
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
  }

  Future<void> addBattle(Battle battle, bool createNew) async {
    await _prepareBattleDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      battle.id = _getUniqueBattleID();
      battle.viewOrder = battle.id;
    }
    battles[battle.id] = battle;

    // パーティの勝率を更新
    updatePartyWinRate();

    // SQLiteのDBに挿入
    await battleDb.insert(
      battleDBTable,
      battle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAllBattleViewOrder() async {
    await _prepareBattleDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$battleColumnId=?';
    for (final e in battles.values) {
      await battleDb.update(
        battleDBTable,
        {battleColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteBattle(List<int> ids) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(), battleDBFile);
    assert(await databaseExists(battleDBPath));

    // SQLiteのDB読み込み
    battleDb = await openDatabase(battleDBPath);
    
    // 登録対戦リストから削除
    battles.removeWhere((k, v) => ids.contains(k));

    String whereStr = '$battleColumnId=?';
    for (int i = 1; i < ids.length; i++) {
      whereStr += ' OR $battleColumnId=?';
    }
    // SQLiteのDBから削除
    await battleDb.delete(
      battleDBTable,
      where: whereStr,
      whereArgs: ids,
    );

    _deleteUnrefs();
    // パーティの勝率を更新
    updatePartyWinRate();
  }

  Future<Database> _createMyPokemonDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    var text = 'CREATE TABLE $myPokemonDBTable('
            '$myPokemonColumnId INTEGER PRIMARY KEY, '
            '$myPokemonColumnViewOrder INTEGER, '
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
            '$myPokemonColumnOwnerID INTEGER)';

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
            '$partyColumnViewOrder INTEGER, '
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
            '$partyColumnOwnerID INTEGER)';

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
            '$battleColumnViewOrder INTEGER, '
            '$battleColumnName TEXT, '
            '$battleColumnTypeId INTEGER, '
            '$battleColumnDate TEXT, '
            '$battleColumnOwnPartyId INTEGER, '
            '$battleColumnOpponentName TEXT, '
            '$battleColumnOpponentPartyId INTEGER, '
            '$battleColumnTurns TEXT, '
            '$battleColumnIsMyWin INTEGER, '
            '$battleColumnIsYourWin INTEGER)';

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
