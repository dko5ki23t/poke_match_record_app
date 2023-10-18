import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

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
  final int height;               // たかさ(*10)(m)
  final int weight;               // おもさ(*10)(kg)
  final List<EggGroup> eggGroups; // タマゴグループ

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
    required this.height,
    required this.weight,
    required this.eggGroups,
  });

  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;
}
