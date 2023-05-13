import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pokeapi/pokeapi.dart';
import 'package:http/http.dart';

enum PokeName {
  none('アーマーガア'),
  male('アオガラス'),
  female('アサナン'),
  ;

  const PokeName(this.displayName);

  final String displayName;
}

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
  none('なし', Icons.minimize),
  male('オス', Icons.male),
  female('メス', Icons.female),
  ;

  const Sex(this.displayName, this.displayIcon);

  final String displayName;
  final IconData displayIcon;
}

// 使い方：print(PokeType.normal.displayName) -> 'ノーマル'
enum PokeType {
  normal('ノーマル', Icons.radio_button_unchecked),
  fire('ほのお', Icons.whatshot),
  water('みず', Icons.opacity),
  grass('くさ', Icons.grass),
  electric('でんき', Icons.bolt),
  ice('こおり', Icons.ac_unit),
  fighting('かくとう', Icons.sports_mma),
  poison('どく', Icons.coronavirus),
  ground('じめん', Icons.abc),
  flying('ひこう', Icons.air),
  psychic('エスパー', Icons.psychology),
  bug('むし', Icons.bug_report),
  rock('いわ', Icons.abc),
  ghost('ゴースト', Icons.abc),
  dragon('ドラゴン', Icons.abc),
  dark('あく', Icons.abc),
  steel('はがね', Icons.abc),
  fairy('フェアリー', Icons.abc),
  ;

  const PokeType(this.displayName, this.displayIcon);

  final String displayName;
  final IconData displayIcon;
}

// TODO: 全部追加する
enum Temper {
  ijippari('いじっぱり'),
  tereya('てれや'),
  ;

  const Temper(this.displayName);

  final String displayName;
}

class SixParams {
  int race = 0;
  int indi = 0;
  int effort = 0;
  int real = 0;

  set(race, indi, effort, real) {
    this.race = race;
    this.indi = indi;
    this.effort = effort;
    this.real = real;
  }
}

// TODO: 全部追加する
enum Ability {
  ikaku('いかく'),
  bakenokawa('ばけのかわ'),
  ;

  const Ability(this.displayName);

  final String displayName;
}

// TODO: 全部追加する
enum Item {
  tabenokoshi('たべのこし'),
  kodawarimegane('こだわりメガネ'),
  ;

  const Item(this.displayName);

  final String displayName;
}

// TODO: 全部追加する
enum Move {
  jumanboruto('10まんボルト', 15),
  meiso('めいそう', 20),
  ;

  const Move(this.displayName, this.defaultPP);

  final String displayName;
  final int defaultPP;
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

  factory PokeBase.fromJson(Map<String, dynamic> json) {
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
      name: json['name'],
      sex: [Sex.none, Sex.male, Sex.female],
      no: json['id'],
      type1: PokeType.values.byName(types[0]),
      type2: PokeType.values.byName(types[1]),
      h: status['hp'] ?? 0,
      a: status['hp'] ?? 0,
      b: status['hp'] ?? 0,
      c: status['hp'] ?? 0,
      d: status['hp'] ?? 0,
      s: status['hp'] ?? 0,
      ability: [
        for (var name in abilities)
          Ability.values.byName(name)
      ],
      move: [
        for (var name in moves)
          Move.values.byName(name)
      ],
    );
  }
}

class Pokemon {
  String name = 'アンノーン';       // ポケモン名
  String nickname = '';            // ニックネーム
  int level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int no = 1;                      // 図鑑No.
  PokeType type1 = PokeType.normal;        // タイプ1
  PokeType? type2;                     // タイプ2(null OK)
  PokeType teraType = PokeType.normal;     // テラスタルタイプ
  Temper temper = Temper.ijippari; // せいかく
  SixParams h = SixParams();       // HP
  SixParams a = SixParams();       // こうげき
  SixParams b = SixParams();       // ぼうぎょ
  SixParams c = SixParams();       // とくこう
  SixParams d = SixParams();       // とくぼう
  SixParams s = SixParams();       // すばやさ
  Ability ability = Ability.ikaku; // とくせい
  Item? item;                      // もちもの(null OK)
  Move move1 = Move.meiso;         // わざ1
  int pp1 = 5;                     // PP1
  Move? move2;                     // わざ2
  int? pp2 = 5;                    // PP2
  Move? move3;                     // わざ3
  int? pp3 = 5;                    // PP3
  Move? move4;                     // わざ4
  int? pp4 = 5;                    // PP4
}

// シングルトンクラス
// TODO: 欠点があるからライブラリを使うべき？ https://zenn.dev/shinkano/articles/c0f392fc3d218c
/*
class PokeDB {
  // コンストラクタ（private）
  PokeDB._internal();
  // インスタンスはただ１つだけ
  static final PokeDB instance = PokeDB._internal();
  // キャッシュしたインスタンスを返す
  factory PokeDB() => instance;

  void initialize() {
    () async {
      db = await openDatabase(
        'poke_data.db',
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS posts ('
            '  id INTEGER PRIMARY KEY AUTOINCREMENT,'
            '  content TEXT,'
            '  created_at INTEGER'
            ')',
          );
        },
      );
    }();
  }

  Database? db;
}
*/

class PokeDB {

}
