import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

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
