import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart';
import 'package:http/http.dart' as http;

const String errorFileName = 'errorFile.db';
const String errorString = 'errorString';

const String abilityDBFile = 'Abilities.db';
const String abilityDBTable = 'abilityDB';
const String abilityColumnId = 'id';
const String abilityColumnName = 'name';

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
const String moveColumnPP = 'PP';

const String pokeBaseDBFile = 'PokeBases.db';
const String pokeBaseDBTable = 'pokeBaseDB';
const String pokeBaseColumnId = 'id';
const String pokeBaseColumnName = 'name';
const String pokeBaseColumnAbility = 'ability';
const String pokeBaseColumnForm = 'form';
const String pokeBaseColumnMove = 'move';
const List<String> pokeBaseColumnStats = [
  'h',
  'a',
  'b',
  'c',
  'd',
  's',
];

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
const String pokeBaseColumnType = 'type';

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
  none(0, 'なし', Icons.minimize),
  male(1, 'オス', Icons.male),
  female(2, 'メス', Icons.female),
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
  final IconData displayIcon;
}

// 使い方：print(PokeType.normal.displayName) -> 'ノーマル'
// TODO:これもPokeAPIから取得すべき。変な感じになってしまった。
class PokeType {
  final int id;
  final String displayName;
  final IconData displayIcon;

  static const Map<int, Tuple2<String, IconData>> officialTypes = {
    1 : Tuple2('ノーマル', Icons.radio_button_unchecked),
    2 : Tuple2('かくとう', Icons.sports_mma),
    3 : Tuple2('ひこう', Icons.air),
    4 : Tuple2('どく', Icons.coronavirus),
    5 : Tuple2('じめん', Icons.abc),
    6 : Tuple2('いわ', Icons.abc),
    7 : Tuple2('むし', Icons.bug_report),
    8 : Tuple2('ゴースト', Icons.abc),
    9 : Tuple2('はがね', Icons.abc),
    10 : Tuple2('ほのお', Icons.whatshot),
    11 : Tuple2('みず', Icons.opacity),
    12 : Tuple2('くさ', Icons.grass),
    13 : Tuple2('でんき', Icons.bolt),
    14 : Tuple2('エスパー', Icons.psychology),
    15 : Tuple2('こおり', Icons.ac_unit),
    16 : Tuple2('ドラゴン', Icons.abc),
    17 : Tuple2('あく', Icons.abc),  
    18 : Tuple2('フェアリー', Icons.abc),
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

class Ability {
  final int id;
  final String displayName;

  const Ability(this.id, this.displayName);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      abilityColumnId: id,
      abilityColumnName: displayName
    };
    return map;
  }
}

class Item {
  final int id;
  final String displayName;

  const Item(this.id, this.displayName);

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
  final int pp;

  const Move(this.id, this.displayName, this.pp);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      moveColumnId: id,
      moveColumnName: displayName,
      moveColumnPP: pp,
    };
    return map;
  }
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

class Pokemon {
  int id = 0;    // データベースのプライマリーキー
  String _name = '';       // ポケモン名
  String nickname = '';            // ニックネーム
  int _level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int _no = 1;                      // 図鑑No.
  PokeType type1 = PokeType.createFromId(1);        // タイプ1
  PokeType? type2;                     // タイプ2(null OK)
  PokeType teraType = PokeType.createFromId(1);     // テラスタルタイプ
  Temper temper = Temper(0, '', '', ''); // せいかく
  SixParams _h = SixParams(0, 31, 0, 0);       // HP
  SixParams _a = SixParams(0, 31, 0, 0);       // こうげき
  SixParams _b = SixParams(0, 31, 0, 0);       // ぼうぎょ
  SixParams _c = SixParams(0, 31, 0, 0);       // とくこう
  SixParams _d = SixParams(0, 31, 0, 0);       // とくぼう
  SixParams _s = SixParams(0, 31, 0, 0);       // すばやさ
  Ability ability = Ability(0, '');     // とくせい
  Item? item;                      // もちもの(null OK)
  Move move1 = Move(0, '', 0);     // わざ1
  int pp1 = 5;                     // PP1
  Move? move2;                     // わざ2
  int? pp2 = 5;                    // PP2
  Move? move3;                     // わざ3
  int? pp3 = 5;                    // PP3
  Move? move4;                     // わざ4
  int? pp4 = 5;                    // PP4
  bool _isValid = false;            // 必要な情報が入力されているか

  // getter
  String get name => _name;
  int get level => _level;
  int get no => _no;
  SixParams get h => _h;
  SixParams get a => _a;
  SixParams get b => _b;
  SixParams get c => _c;
  SixParams get d => _d;
  SixParams get s => _s;
  bool get isValid => _isValid;

  // setter
  set name(String x) {_name = x; updateIsValid();}
  set level(int x) {_level = x; updateIsValid();}
  set no(int x) {_no = x; updateIsValid();}
  set h(SixParams x) {_h = x; updateIsValid();}
  set a(SixParams x) {_a = x; updateIsValid();}
  set b(SixParams x) {_b = x; updateIsValid();}
  set c(SixParams x) {_c = x; updateIsValid();}
  set d(SixParams x) {_d = x; updateIsValid();}
  set s(SixParams x) {_s = x; updateIsValid();}

  // 正しく情報が入力されているかどうか
  void updateIsValid() {
    if (
      _name != '' &&
      (_level >= pokemonMinLevel && _level <= pokemonMaxLevel) &&
      _no >= pokemonMinNo
    ) {
      _isValid = true;
    }
    else {
      _isValid = false;
    }
  }

  // レベル、種族値、個体値、努力値、せいかくから実数値を更新
  // TODO habcdsのsetterで自動的に呼ぶ？
  void updateRealStats() {
    final temperBias = Temper.getTemperBias(temper);
    _h.real = SixParams.getRealH(level, _h.race, _h.indi, _h.effort);
    _a.real = SixParams.getRealABCDS(level, _a.race, _a.indi, _a.effort, temperBias[0]);
    _b.real = SixParams.getRealABCDS(level, _b.race, _b.indi, _b.effort, temperBias[1]);
    _c.real = SixParams.getRealABCDS(level, _c.race, _c.indi, _c.effort, temperBias[2]);
    _d.real = SixParams.getRealABCDS(level, _d.race, _d.indi, _d.effort, temperBias[3]);
    _s.real = SixParams.getRealABCDS(level, _s.race, _s.indi, _s.effort, temperBias[4]);
  }

  // SQLite保存用
  Map<String, dynamic> toMap(int id) {
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
      myPokemonColumnIndividual[0]: _h.indi,
      myPokemonColumnIndividual[1]: _a.indi,
      myPokemonColumnIndividual[2]: _b.indi,
      myPokemonColumnIndividual[3]: _c.indi,
      myPokemonColumnIndividual[4]: _d.indi,
      myPokemonColumnIndividual[5]: _s.indi,
      myPokemonColumnEffort[0]: _h.effort,
      myPokemonColumnEffort[1]: _a.effort,
      myPokemonColumnEffort[2]: _b.effort,
      myPokemonColumnEffort[3]: _c.effort,
      myPokemonColumnEffort[4]: _d.effort,
      myPokemonColumnEffort[5]: _s.effort,
      myPokemonColumnMove1: move1.id,
      myPokemonColumnPP1: pp1,
      myPokemonColumnMove2: move2?.id,
      myPokemonColumnPP2: pp2,
      myPokemonColumnMove3: move3?.id,
      myPokemonColumnPP3: pp3,
      myPokemonColumnMove4: move4?.id,
      myPokemonColumnPP4: pp4,
    };
  }
}

// シングルトンクラス
// TODO: 欠点があるからライブラリを使うべき？ https://zenn.dev/shinkano/articles/c0f392fc3d218c
class PokeDB {
//  Map<int, PokeBase> pokeBase = {};
  static const String pokeApiRoute = "https://pokeapi.co/api/v2";
  
  Map<int, Ability> abilities = {};
  late Database abilityDb;
  Map<int, Temper> tempers = {};
  late Database temperDb;
  List<Item> items = [];
  late Database itemDb;
  Map<int, Move> moves = {};
  late Database moveDb;
  List<PokeType> types = [
    for (final i in range(1, 19)) PokeType.createFromId(i.toInt())
  ];
  Map<int, PokeBase> pokeBase = {};
  late Database pokeBaseDb;
  late Database myPokemonDb;

  bool isLoaded = false;

  // コンストラクタ（private）
  PokeDB._internal();
  // インスタンスはただ１つだけ
  static final PokeDB instance = PokeDB._internal();
  // キャッシュしたインスタンスを返す
  factory PokeDB() => instance;

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

  Future<List<Pokemon>> initialize() async {
    List<Pokemon> ret = [];

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
      columns: [abilityColumnId, abilityColumnName],
    );
    for (var map in maps) {
      abilities[map[abilityColumnId]] = Ability(
        map[abilityColumnId],
        map[abilityColumnName]
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
      items.add(Item(
        map[itemColumnId],
        map[itemColumnName],
      ));
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
      columns: [moveColumnId, moveColumnName, moveColumnPP],
    );
    for (var map in maps) {
      moves[map[moveColumnId]] = Move(
        map[moveColumnId],
        map[moveColumnName],
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
        pokeBaseColumnForm, pokeBaseColumnMove,
        for (var e in pokeBaseColumnStats) e,
        pokeBaseColumnType],
    );

    for (var map in maps) {
      final pokeTypes = parseIntList(map[pokeBaseColumnType]);
      final pokeAbilities = parseIntList(map[pokeBaseColumnAbility]);
      final pokeMoves = parseIntList(map[pokeBaseColumnMove]);
      pokeBase[map[pokeBaseColumnId]] = PokeBase(
        name: map[pokeBaseColumnName],
        sex: [Sex.none, Sex.male, Sex.female],   // TODO:
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

    if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
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
        ],
      );

      for (var map in maps) {
        int pokeNo = map[myPokemonColumnNo];
        ret.add(Pokemon()
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
          ..ability = Ability(map[myPokemonColumnAbility], '')
          ..item = (map[myPokemonColumnItem] != null) ? Item(map[myPokemonColumnItem], '') : null
          ..move1 = moves[map[myPokemonColumnMove1]]!
          ..pp1 = map[myPokemonColumnPP1]
          ..move2 = map[myPokemonColumnMove2] != null ? moves[map[myPokemonColumnMove2]]! : null
          ..pp2 = map[myPokemonColumnPP2]
          ..move3 = map[myPokemonColumnMove3] != null ? moves[map[myPokemonColumnMove3]]! : null
          ..pp3 = map[myPokemonColumnPP3]
          ..move4 = map[myPokemonColumnMove4] != null ? moves[map[myPokemonColumnMove4]]! : null
          ..pp4 = map[myPokemonColumnPP4]
          ..updateRealStats()
          ..updateIsValid()
        );
      }
    }

    isLoaded = true;
    return ret;

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

  Future<void> addMyPokemon(Pokemon myPokemon, int id) async {
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

    // SQLiteのDBに挿入
    await myPokemonDb.insert(
      myPokemonDBTable,
      myPokemon.toMap(id),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMyPokemon(List<int> ids) async {
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));
    assert(ids.isNotEmpty);

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath, readOnly: false);

    String whereStr = '$myPokemonColumnId=?';
    for (int i = 1; i < ids.length; i++) {
      whereStr += ' OR $myPokemonColumnId=?';
    }

    // SQLiteのDBから削除
    await myPokemonDb.delete(
      myPokemonDBTable,
      where: whereStr,
      whereArgs: ids,
    );
  }

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
        pokemons[i].toMap(i + 1),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Database> _createMyPokemonDB() async {
    final myPokemonDBPath = join(await getDatabasesPath(), myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

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
          '$myPokemonColumnPP4 INTEGER)'
        );
      }
    );
  }
}
