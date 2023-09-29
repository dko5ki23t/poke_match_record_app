import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/poke_effect.dart';
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
//  defeatOpponent(2),    // 相手を倒したとき
  static const int attackSuccessedWithChance = 3;          // こうげきし、相手にあたったとき(確率)
  static const int everyTurnEnd = 4;      // 毎ターン終了時
//  HPMaxAndAttacked(5),  // HPが満タンでこうげきを受けた時
//  blasted(6),           // ばくはつ系のわざ、とくせいが発動したとき
//  paralysised(7),       // まひするわざ、とくせいを受けた時
//  sandstormed(8),       // 天気がすなあらしのとき
//  directAttacked(9),    // 直接攻撃を受けた時
//  electriced(10),       // でんきタイプのわざを受けた時
//  watered(11),          // みずタイプのわざを受けた時
//  attractedTauntedIntimidated(12),    // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
//  weather(13),          // 天気があるとき
//  moving(14),           // わざを使うとき
//  sleeped(15),          // ねむり・ねむけの効果を受けた時
//  poisoned(16),         // どく・もうどくの効果を受けた時
//  fired(17),            // ほのおタイプのわざを受けた時
//  confusedIntimidated(18),  // こんらん/いかくの効果を受けた時
//  afterActedEveryTurnEnd(19),   // 1度でも行動した後毎ターン終了時
//  changeForced(20),     // こうたいわざやレッドカードによるこうたいを強制されたとき
//  notGreatAttacked(21), // 効果ばつぐん以外のタイプのこうげきざわを受けた時
//  groundFieldEffected(22),  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
//  poisonedParalysisedBurnedByOppositeMove(23),    // 相手から受けた技でどく/まひ/やけど状態にされたとき
//  statChangedByNotMyself(24),   // 自身以外の効果によって能力変化が起きるとき
//  change(25),           // 当該ポケモンを交代するとき
//  electricUse(26),      // 自分以外のポケモンがでんきわざを使ったとき
//  attack(27),           // こうげきわざを使うとき
//  rained(28),           // 天気があめのとき
//  sunny(29),            // 天気が晴れのとき
//  pokemonAppearAndChanged(30),     // ポケモン登場時、ポケモン交代時(場にいるときのみの効果)
//  always(31),           // 常に発動(バトル開始時に1度発動とする)
//  flinchedIntimidated(32),  // ひるみやいかくを受けた時
//  frozen(33),           // こおり状態になったとき
//  burned(34),           // やけど状態になったとき
//  moveUsed(35),         // わざを受けた時
//  icedFired(36),        // こおり/ほのおタイプのこうげき技を受けた時
//  accuracyDownedAttack(37),    // 命中率が下がるとき、こうげきするとき
//  itemLostByOpponent(38),   // もちものを奪われたり失ったりするとき
//  ailment(39),          // 状態異常のとき
//  drained(40),          // HP吸収技を受けた時
//  HP033(41),            // HPが1/3以下のとき
//  recoilAttack(42),     // 反動ダメージを受ける技を使ったとき
//  confusedAttacked(43), // こんらん状態でこうげきを受けた時
//  flinched(44),         // ひるんだとき
//  snowed(45),           // 天気がゆきのとき
//  HP025(46),            // HPが1/2のとき
//  criticaled(47),       // こうげきが急所に当たった時
//  itemLost(48),         // 場に出た後にもちものを失ったとき、再度もちものを得た時
//  firedBurned(49),      // ほのお技を受けるとき、やけどダメージを負うとき
//  fireWaterAttackedSunnyRained(50),   // ほのお/みずタイプのこうげきを受けた時、天気が晴れ/あめのとき
//  punchAttack(51),      // パンチ技を使用するとき
//  poisonDamage(52),     // どく/もうどくでダメージを負うとき
  static const int afterActionDecision = 53;    // 行動決定後、行動実行前
  static const int action = 54;                 // 行動時
  static const int afterMove = 55;              // わざ使用後
  static const int continuousMove = 56;         // 連続こうげき時(1回目除く)
  static const int changeFaintingPokemon = 57;  // ポケモンがひんしになったため交代
  static const int changePokemonMove = 58;      // 交代わざによる交代
  static const int gameSet = 59;                // 対戦終了
  static const int attackSuccessed = 60;        // こうげきし、相手に当たったとき

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

  Move(
    this.id, this.displayName, this.type, this.power,
    this.accuracy, this.priority, this.target,
    this.damageClass, this.effect, this.effectChance, this.pp,
  );

  Move copyWith() =>
    Move(id, displayName, type, power,
      accuracy, priority, target,
      damageClass, effect, effectChance, pp,);

  // TODO(今はダブルウイングだけ)
  // 連続こうげきの場合、その最大回数を返す（連続こうげきではない場合は1を返す）
  int maxMoveCount() {
    if (id == 814) return 2;
    if (id == 350) return 5;
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
  };

  // TODO:
  static const _bgColor = {
    0: Colors.black,
    1: Colors.black,
    2: Colors.black,
    3: Colors.black,
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
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // アンコール対象のわざID等

  Ailment(this.id);

  Ailment copyWith() =>
    Ailment(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _displayNameMap[id]!;
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

// その他の補正(フォルムとか)
class BuffDebuff {
  static const int none = 0;
  static const int attack1_3 = 1;         // こうげき1.3倍
  static const int defense1_3 = 2;        // ぼうぎょ1.3倍
  static const int specialAttack1_3 = 3;  // とくこう1.3倍
  static const int specialDefense1_3 = 4; // とくぼう1.3倍
  static const int speed1_5 = 5;          // すばやさ1.5倍

  static const _displayNameMap = {
    0: '',
    1: 'こうげき1.3倍',
    2: 'ぼうぎょ1.3倍',
    3: 'とくこう1.3倍',
    4: 'とくぼう1.3倍',
    5: 'すばやさ1.5倍',
  };

  static const _bgColorMap = {
    0: Colors.black,
    1: Colors.red,
    2: Colors.red,
    3: Colors.red,
    4: Colors.red,
    5: Colors.red,
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

  static const _displayNameMap = {
    0: '',
    1: '晴れ',
    2: 'あめ',
    3: 'すなあらし',
    4: 'ゆき',
  };

  String get displayName => _displayNameMap[id]!;

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  Weather(this.id);

  Weather copyWith() =>
    Weather(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

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
  static const int trickRoom = 5;          // トリックルーム
  static const int gravity = 6;            // じゅうりょく
  static const int waterSport = 7;         // みずあそび
  static const int mudSport = 8;           // どろあそび
  static const int wonderRoom = 9;         // ワンダールーム
  static const int magicRoom = 10;         // マジックルーム

  static const _displayNameMap = {
    0: '',
    1: 'エレキフィールド',
    2: 'グラスフィールド',
    3: 'ミストフィールド',
    4: 'サイコフィールド',
    5: 'トリックルーム',
    6: 'じゅうりょく',
    7: 'みずあそび',
    8: 'どろあそび',
    9: 'ワンダールーム',
    10: 'マジックルーム',
  };

  String get displayName => _displayNameMap[id]!;

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  Field(this.id);

  Field copyWith() =>
    Field(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

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
  Item? holdingItem = Item(0, '', AbilityTiming(0));  // 持っているもちもの(失えばnullにする)
  List<int> usedPPs = List.generate(4, (index) => 0);       // 各わざの消費PP
  List<int> statChanges = List.generate(7, (i) => 0);   // のうりょく変化
  List<BuffDebuff> buffDebuffs = [];    // その他の補正(フォルムとか)
  Ability currentAbility = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0)); // 現在のとくせい(バトル中にとくせいが変わることあるので)
  List<IndividualField> fields = [];        // 場(天気やフィールドを含まない、かべ等)
  List<Ailment> ailments = [];   // 状態異常
  List<SixParams> minStats = List.generate(StatIndex.size.index, (i) => SixParams(0, 0, 0, 0));     // 個体値や努力値のあり得る範囲の最小値
  List<SixParams> maxStats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, pokemonMaxEffort, 0));   // 個体値や努力値のあり得る範囲の最大値
  List<Ability> possibleAbilities = [];     // 候補のとくせい
  List<Item> impossibleItems = [];          // 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Move> moves = [];         // 判明しているわざ

  PokemonState copyWith() =>
    PokemonState()
    ..pokemon = pokemon
    ..remainHP = remainHP
    ..remainHPPercent = remainHPPercent
    ..teraType = teraType
    ..isFainting = isFainting
    ..isBattling = isBattling
    ..holdingItem = holdingItem?.copyWith()
    ..usedPPs = [...usedPPs]
    ..statChanges = [...statChanges]
    ..buffDebuffs = [for (final e in buffDebuffs) e.copyWith()]
    ..currentAbility = currentAbility.copyWith()
    ..fields = [for (final e in fields) e.copyWith()]
    ..ailments = [for (final e in ailments) e.copyWith()]
    ..minStats = [...minStats]        // TODO:よい？
    ..maxStats = [...maxStats]        // TODO:よい？
    ..possibleAbilities = [for (final e in possibleAbilities) e.copyWith()]
    ..impossibleItems = [for (final e in impossibleItems) e.copyWith()]
    ..moves = [...moves];
  
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
      pokemonState.statChanges[i] = int.parse(statChangeElements[i]);
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
    final ailmentElements = stateElements[12].split(split2);
    for (final ailment in ailmentElements) {
      if (ailment == '') break;
      pokemonState.ailments.add(Ailment.deserialize(ailment, split3));
    }
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
      ret += statChanges[i].toString();
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
    for (final ailment in ailments) {
      ret += ailment.serialize(split3);
      ret += split2;
    }
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
  Weather weather = Weather(0);
  Field field = Field(0);

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
    PokeDB pokeData, AbilityTiming timing, bool changedOwn, bool changedOpponent,
    TurnEffect? prevAction,
  ) {
    List<TurnEffect> ret = [];
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:   // ポケモン登場時
        {
          // ポケモン登場時には無条件で発動する効果
          var abilityIDList = [];
          for (var ability in pokeData.abilities.values) {
            if (ability.timing.id == AbilityTiming.pokemonAppear) abilityIDList.add(ability.id);
          }
          // TODO アイテムとかも
          // TODO 追加順はすばやさを考慮したい
          if (changedOwn) {
            if (abilityIDList.contains(ownPokemonState.currentAbility.id)) {
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.me)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = ownPokemonState.currentAbility.id
              );
            }
          }
          if (changedOpponent) {
            if (abilityIDList.contains(opponentPokemonState.currentAbility.id)) {
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.opponent)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = opponentPokemonState.currentAbility.id
              );
            }
          }
        }
        break;
      case AbilityTiming.afterMove:   // わざ使用後
        {
          if (prevAction != null && prevAction.move != null && prevAction.move!.isSuccess && prevAction.move!.move.damageClass.id >= 2) {
            // こうげきわざ使用＆成功後に発動する効果
            // TODO とくせいとかも
            var itemIDList = [];
            for (var item in pokeData.items.values) {
              if (item.timing.id == AbilityTiming.attackSuccessed) itemIDList.add(item.id);
            }
            // TODO 追加順はすばやさを考慮したい
            if (prevAction.playerType.id == PlayerType.me) {
              if (itemIDList.contains(ownPokemonState.holdingItem?.id)) {
                int extraArg1 = 0;
                if (ownPokemonState.holdingItem!.id == 247) {   // いのちのたま
                  extraArg1 = (ownPokemonState.pokemon.h.real / 10).floor();
                }
                ret.add(TurnEffect()
                  ..playerType = PlayerType(PlayerType.me)
                  ..timing = AbilityTiming(AbilityTiming.afterMove)
                  ..effect = EffectType(EffectType.item)
                  ..effectId = ownPokemonState.holdingItem!.id
                  ..extraArg1 = extraArg1
                );
              }
            }
            else if (prevAction.playerType.id == PlayerType.opponent) {
              if (itemIDList.contains(opponentPokemonState.holdingItem?.id)) {
                int extraArg1 = 0;
                if (ownPokemonState.holdingItem!.id == 247) {   // いのちのたま
                  extraArg1 = 10;
                }
                ret.add(TurnEffect()
                  ..playerType = PlayerType(PlayerType.opponent)
                  ..timing = AbilityTiming(AbilityTiming.afterMove)
                  ..effect = EffectType(EffectType.item)
                  ..effectId = opponentPokemonState.holdingItem!.id
                  ..extraArg1 = extraArg1
                );
              }
            }
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

  PhaseState copyInitialState() =>
    PhaseState()
    ..ownPokemonIndex = initialOwnPokemonIndex
    ..opponentPokemonIndex = initialOpponentPokemonIndex
    ..ownPokemonStates = [
      for (final state in initialOwnPokemonStates)
      state.copyWith()
    ]
    ..opponentPokemonStates = [
      for (final state in initialOpponentPokemonStates)
      state.copyWith()
    ]
    ..weather = initialWeather.copyWith()
    ..field = initialField.copyWith();

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
    initialWeather = state.weather;
    initialField = state.field;
  }

  // とある時点(フェーズ)での状態を取得
  PhaseState getProcessedStates(
    int phaseIdx, Party ownParty, Party opponentParty, PokeDB pokeData)
  {
    PhaseState ret = copyInitialState();
    int continousCount = 0;

    for (int i = 0; i < phaseIdx+1; i++) {
      final effect = phases[i];
      if (effect.isAdding) continue;
      if (effect.timing.id == AbilityTiming.continuousMove) {
        continousCount++;
      }
      else if (effect.timing.id == AbilityTiming.action) {
        continousCount = 0;
      }
      effect.processEffect(
        ownParty,
        ret.ownPokemonState,
        opponentParty,
        ret.opponentPokemonState,
        ret, pokeData, continousCount,
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
