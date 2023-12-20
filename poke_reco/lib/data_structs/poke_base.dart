import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/ability.dart';

class PokeBase {    // 各ポケモンの種族ごとの値
  late final String _name;             // ポケモン名(日本語)
  late final String _nameEn;           // ポケモン名(英語)
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
  final String imageUrl;          // 画像

  PokeBase({
    required String name,
    required String nameEn,
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
    required this.imageUrl,
  })
  {
    _name = name;
    _nameEn = nameEn;
  }

  // 特徴的なポケモンのNo
  static int zoruaNo = 570;
  static int zoroarkNo = 571;
  static int zoruaHisuiNo = 10238;
  static int zoroarkHisuiNo = 10239;

  String get name {
    switch (PokeDB().language) {
      case Language.english:
        return _nameEn;
      case Language.japanese:
      default:
        return _name;
    }
  }
  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;

  // テラスタイプが固定ならそのタイプを返す
  PokeType get fixedTeraType {
    switch (no) {
      case 1017:    // オーガポン(みどりのめん)->くさ
        return PokeType.createFromId(12);
      case 10273:   // オーガポン(いどのめん)->みず
        return PokeType.createFromId(11);
      case 10274:   // オーガポン(かまどのめん)->ほのお
        return PokeType.createFromId(10);
      case 10275:   // オーガポン(いしずえのめん)->いわ
        return PokeType.createFromId(6);
    }
    return PokeType.createFromId(0);    // 固定テラスタイプなし
  }

  // 固定のもちものがあればそのもちもののIDを返す
  int get fixedItemID {
    switch (no) {
      case 10273:   // オーガポン(いどのめん)->いどのめん
        return 2106;
      case 10274:   // オーガポン(かまどのめん)->かまどのめん
        return 2107;
      case 10275:   // オーガポン(いしずえのめん)->いしずえのめん
        return 2108;
    }
    return 0;     // 固定もちものなし
  }

  // テラスタイプ後にとくせいが変化する場合はそのとくせいのIDを返す
  int get teraTypedAbilityID {
    switch (no) {
      case 1017:    // オーガポン(みどりのめん)
      case 10273:   // オーガポン(いどのめん)
      case 10274:   // オーガポン(かまどのめん)
      case 10275:   // オーガポン(いしずえのめん)
        return 303; // おもかげやどし
    }
    return 0;   // 変化とくせいなし
  }
}
