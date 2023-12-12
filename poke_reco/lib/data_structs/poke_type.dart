import 'package:poke_reco/data_structs/ailment.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

enum TypeIdAndColor {
  normal(1, Color(0xffaeaeae)),
  ;

  const TypeIdAndColor(this.id, this.color);

  final int id;
  final Color color;
}

class IdAndColor {
  final int id;
  final Color color;

  const IdAndColor(this.id, this.color);
}

class PokeTypeId {
  static const int normal = 1;
  static const int fight = 2;
  static const int fly = 3;
  static const int poison = 4;
  static const int ground = 5;
  static const int rock = 6;
  static const int bug = 7;
  static const int ghost = 8;
  static const int steel = 9;
  static const int fire = 10;
  static const int water = 11;
  static const int grass = 12;
  static const int electric = 13;
  static const int psychic = 14;
  static const int ice = 15;
  static const int dragon = 16;
  static const int evil = 17;
  static const int fairy = 18;
}

class PokeTypeColor {
  static const normal = Color(0xffaeaeae);
  static const fight = Color(0xffee6969);
  static const fly = Color(0xff64a7f1);
  static const poison = Color(0xffab7aca);
  static const ground = Color(0xffc8a841);
  static const rock = Color(0xfffac727);
  static const bug = Color(0xff51cb5a);
  static const ghost = Color(0xff756eb4);
  static const steel = Color(0xff818aa4);
  static const fire = Color(0xffffa766);
  static const water = Color(0xff64c5f7);
  static const grass = Color(0xff9ac30e);
  static const electric = Color(0xffe7d400);
  static const psychic = Color(0xffeb7ff4);
  static const ice = Color(0xff60e9f5);
  static const dragon = Color(0xff6881d4);
  static const evil = Colors.black54;
  static const fairy = Color(0xfffc7799);
}

// 使い方：print(PokeType.normal.displayName) -> 'ノーマル'
// TODO:これもPokeAPIから取得すべき。変な感じになってしまった。
class PokeType {
  final int id;
  final String displayName;
  final Icon displayIcon;

  static const Map<int, Tuple2<String, Icon>> officialTypes = {
    0 : Tuple2('不明', Icon(Icons.question_mark, color: Colors.grey)),
    PokeTypeId.normal : Tuple2('ノーマル', Icon(Icons.radio_button_unchecked, color: PokeTypeColor.normal)),
    PokeTypeId.fight : Tuple2('かくとう', Icon(Icons.sports_mma, color: PokeTypeColor.fight)),
    PokeTypeId.fly : Tuple2('ひこう', Icon(Icons.air, color: PokeTypeColor.fly)),
    PokeTypeId.poison : Tuple2('どく', Icon(Icons.coronavirus, color: PokeTypeColor.poison)),
    PokeTypeId.ground : Tuple2('じめん', Icon(Icons.landscape, color: PokeTypeColor.ground)),
    PokeTypeId.rock : Tuple2('いわ', Icon(Icons.diamond, color: PokeTypeColor.rock)),
    PokeTypeId.bug : Tuple2('むし', Icon(Icons.bug_report, color: PokeTypeColor.bug)),
    PokeTypeId.ghost : Tuple2('ゴースト', Icon(Icons.nightlight, color: PokeTypeColor.ghost)),
    PokeTypeId.steel : Tuple2('はがね', Icon(Icons.hexagon, color: PokeTypeColor.steel)),
    PokeTypeId.fire : Tuple2('ほのお', Icon(Icons.whatshot, color: PokeTypeColor.fire)),
    PokeTypeId.water : Tuple2('みず', Icon(Icons.opacity, color: PokeTypeColor.water)),
    PokeTypeId.grass : Tuple2('くさ', Icon(Icons.grass, color: PokeTypeColor.grass)),
    PokeTypeId.electric : Tuple2('でんき', Icon(Icons.bolt, color: PokeTypeColor.electric)),
    PokeTypeId.psychic : Tuple2('エスパー', Icon(Icons.psychology, color: PokeTypeColor.psychic)),
    PokeTypeId.ice : Tuple2('こおり', Icon(Icons.ac_unit, color: PokeTypeColor.ice)),
    PokeTypeId.dragon : Tuple2('ドラゴン', Icon(Icons.cruelty_free, color: PokeTypeColor.dragon)),
    PokeTypeId.evil : Tuple2('あく', Icon(Icons.remove_red_eye, color: PokeTypeColor.evil)),
    PokeTypeId.fairy : Tuple2('フェアリー', Icon(Icons.emoji_nature, color: PokeTypeColor.fairy)),
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
    // きもったま, ねらいのまと, ミラクルアイ
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
    bool canNormalFightToGhost = isScrappy || state.ailmentsWhere((e) => e.id == Ailment.identify).isNotEmpty;
    if (state.isTerastaling) {
      defenseType1 = state.teraType1;
      defenseType2 = null;
    }
    int deg = 0;
    PokeType? type = defenseType1;
    for (int i = 0; i < 2; i++) {
      if (type == null) break;
      switch (attackType.id) {
        case 1:
          if (type.id == 6 || type.id == 9) deg--;    // ノーマル->いわ/はがね
          if (!isRingTarget && !canNormalFightToGhost && type.id == 8) return 0;   // ノーマル->ゴースト
          break;
        case 2:
          if (type.id == 1 || type.id == 15 || type.id == 6 || type.id == 17 || type.id == 9) deg++;
          if (type.id == 4 || type.id == 3 || type.id == 14 || type.id == 7 || type.id == 18) deg--;
          if (!isRingTarget && !canNormalFightToGhost && type.id == 8) return 0;
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
          if (!isRingTarget && (type.id == 3 || state.holdingItem?.id == 584)) return 0;
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
    if (attackType.id == PokeTypeId.fire && state.ailmentsWhere((e) => e.id == Ailment.tarShot).isNotEmpty) deg++;
    if (deg == 3) {
      return 8;
    }
    else if (deg == 2) {
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
