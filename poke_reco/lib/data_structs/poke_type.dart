import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

class PokeTypeColor {
  static const unknown = Colors.grey;
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
  static const stellar = Colors.white;
}

const _displayNames = {
    PokeType.unknown : '不明',
    PokeType.normal : 'ノーマル',
    PokeType.fight : 'かくとう',
    PokeType.fly : 'ひこう',
    PokeType.poison : 'どく',
    PokeType.ground : 'じめん',
    PokeType.rock : 'いわ',
    PokeType.bug : 'むし',
    PokeType.ghost : 'ゴースト',
    PokeType.steel : 'はがね',
    PokeType.fire : 'ほのお',
    PokeType.water : 'みず',
    PokeType.grass : 'くさ',
    PokeType.electric : 'でんき',
    PokeType.psychic : 'エスパー',
    PokeType.ice : 'こおり',
    PokeType.dragon : 'ドラゴン',
    PokeType.evil : 'あく',
    PokeType.fairy : 'フェアリー',
    PokeType.stellar : 'ステラ',
  };

  const _displayNamesEn = {
    PokeType.unknown : 'Unknown',
    PokeType.normal : 'Normal',
    PokeType.fight : 'Fighting',
    PokeType.fly : 'Flying',
    PokeType.poison : 'Poison',
    PokeType.ground : 'Ground',
    PokeType.rock : 'Rock',
    PokeType.bug : 'Bug',
    PokeType.ghost : 'Ghost',
    PokeType.steel : 'Steel',
    PokeType.fire : 'Fire',
    PokeType.water : 'Water',
    PokeType.grass : 'Grass',
    PokeType.electric : 'Electric',
    PokeType.psychic : 'Psychic',
    PokeType.ice : 'Ice',
    PokeType.dragon : 'Dragon',
    PokeType.evil : 'Dark',
    PokeType.fairy : 'Fairy',
    PokeType.stellar : 'Stellar',
  };

  const _displayColors = {
    PokeType.unknown : PokeTypeColor.unknown,
    PokeType.normal : PokeTypeColor.normal,
    PokeType.fight : PokeTypeColor.fight,
    PokeType.fly : PokeTypeColor.fly,
    PokeType.poison : PokeTypeColor.poison,
    PokeType.ground : PokeTypeColor.ground,
    PokeType.rock : PokeTypeColor.rock,
    PokeType.bug : PokeTypeColor.bug,
    PokeType.ghost : PokeTypeColor.ghost,
    PokeType.steel : PokeTypeColor.steel,
    PokeType.fire : PokeTypeColor.fire,
    PokeType.water : PokeTypeColor.water,
    PokeType.grass : PokeTypeColor.grass,
    PokeType.electric : PokeTypeColor.electric,
    PokeType.psychic : PokeTypeColor.psychic,
    PokeType.ice : PokeTypeColor.ice,
    PokeType.dragon : PokeTypeColor.dragon,
    PokeType.evil : PokeTypeColor.evil,
    PokeType.fairy : PokeTypeColor.fairy,
  };

  const _displayIcons = {
    PokeType.unknown : Icon(Icons.question_mark, color: PokeTypeColor.unknown),
    PokeType.normal : Icon(Icons.radio_button_unchecked, color: PokeTypeColor.normal),
    PokeType.fight : Icon(Icons.sports_mma, color: PokeTypeColor.fight),
    PokeType.fly : Icon(Icons.air, color: PokeTypeColor.fly),
    PokeType.poison : Icon(Icons.coronavirus, color: PokeTypeColor.poison),
    PokeType.ground : Icon(Icons.landscape, color: PokeTypeColor.ground),
    PokeType.rock : Icon(Icons.diamond, color: PokeTypeColor.rock),
    PokeType.bug : Icon(Icons.bug_report, color: PokeTypeColor.bug),
    PokeType.ghost : Icon(Icons.nightlight, color: PokeTypeColor.ghost),
    PokeType.steel : Icon(Icons.hexagon, color: PokeTypeColor.steel),
    PokeType.fire : Icon(Icons.whatshot, color: PokeTypeColor.fire),
    PokeType.water : Icon(Icons.opacity, color: PokeTypeColor.water),
    PokeType.grass : Icon(Icons.grass, color: PokeTypeColor.grass),
    PokeType.electric : Icon(Icons.bolt, color: PokeTypeColor.electric),
    PokeType.psychic : Icon(Icons.psychology, color: PokeTypeColor.psychic),
    PokeType.ice : Icon(Icons.ac_unit, color: PokeTypeColor.ice),
    PokeType.dragon : Icon(Icons.cruelty_free, color: PokeTypeColor.dragon),
    PokeType.evil : Icon(Icons.remove_red_eye, color: PokeTypeColor.evil),
    PokeType.fairy : Icon(Icons.emoji_nature, color: PokeTypeColor.fairy),
  };

enum PokeType {
  unknown,
  normal,
  fight,
  fly,
  poison,
  ground,
  rock,
  bug,
  ghost,
  steel,
  fire,
  water,
  grass,
  electric,
  psychic,
  ice,
  dragon,
  evil,
  fairy,
  stellar,
}

// 表示用extension
extension PokeTypeDisplay on PokeType {
  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNames[this]!;
      case Language.english:
      default:
        return _displayNamesEn[this]!;
    }
  }

  Widget get displayIcon {
    if (this == PokeType.stellar) {
      return ShaderMask(
        child: const Icon(Icons.hive, color: PokeTypeColor.stellar),
        shaderCallback: (Rect rect) {
          return SweepGradient(
            center: FractionalOffset.center,
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.red,
              Colors.purple,
            ],
            stops: <double>[0.0, 0.25, 0.5, 0.75, 0.875, 1.0],
          ).createShader(rect);
        },
      );
    }
    else {
      return _displayIcons[this]!;
    }
  }

  Color get displayColor {
    return _displayColors[this]!;
  }
}

// タイプ相性用extension
extension PokeTypeEffectiveness on PokeType {
  static MoveEffectiveness effectiveness(
    bool isScrappyMindEye, bool isRingTarget, bool isMiracleEye, PokeType attackType, PokemonState defenseState,
    // きもったま/しんがん, ねらいのまと, ミラクルアイ
  )
  {
    double rate = effectivenessRate(isScrappyMindEye, isRingTarget, isMiracleEye, attackType, defenseState);
    if (rate == 0) {
      return MoveEffectiveness.noEffect;
    }
    else if (rate == 1) {
      return MoveEffectiveness.normal;
    }
    else if (rate > 1) {
      return MoveEffectiveness.great;
    }
    else {
      return MoveEffectiveness.notGood;
    }
  }

  static double effectivenessRate(
    bool isScrappyMindEye, bool isRingTarget, bool isMiracleEye, PokeType attackType, PokemonState state,
  )
  {
    bool canNormalFightToGhost = isScrappyMindEye || state.ailmentsWhere((e) => e.id == Ailment.identify).isNotEmpty;
    List<PokeType> types = [];
    if (state.isTerastaling && state.teraType1 != PokeType.stellar) {
      types = [state.teraType1];
    }
    else {
      types = [state.type1];
      if (state.type2 != null) types.add(state.type2!);
      if (state.ailmentsWhere((e) => e.id == Ailment.halloween).isNotEmpty) types.add(PokeType.ghost);
      if (state.ailmentsWhere((e) => e.id == Ailment.forestCurse).isNotEmpty) types.add(PokeType.grass);
    }
    int deg = 0;
    if (attackType == PokeType.stellar) {
      if (state.isTerastaling) {    // ステラ->テラスタルしたポケモン
        deg = 1;
      }
    }
    else {
      for (final type in types) {
        switch (attackType) {
          case PokeType.normal:
            if (type == PokeType.rock || type == PokeType.steel) deg--;    // ノーマル->いわ/はがね
            if (!isRingTarget && !canNormalFightToGhost && type == PokeType.ghost) return 0;   // ノーマル->ゴースト
            break;
          case PokeType.fight:
            if (type == PokeType.normal || type == PokeType.ice || type == PokeType.rock || type == PokeType.evil || type == PokeType.steel) deg++;
            if (type == PokeType.poison || type == PokeType.fly || type == PokeType.psychic || type == PokeType.bug || type == PokeType.fairy) deg--;
            if (!isRingTarget && !canNormalFightToGhost && type == PokeType.ghost) return 0;
            break;
          case PokeType.fly:
            if (type == PokeType.fight || type == PokeType.grass || type == PokeType.bug) deg++;
            if (type == PokeType.electric || type == PokeType.rock || type == PokeType.steel) deg--;
            break;
          case PokeType.poison:
            if (type == PokeType.grass || type == PokeType.fairy) deg++;
            if (type == PokeType.poison || type == PokeType.ground || type == PokeType.rock || type == PokeType.ghost) deg--;
            if (!isRingTarget && type == PokeType.steel) return 0;
            break;
          case PokeType.ground:
            if (type == PokeType.fire || type == PokeType.electric || type == PokeType.poison || type == PokeType.rock || type == PokeType.steel) deg++;
            if (type == PokeType.grass || type == PokeType.bug) deg--;
            if (!isRingTarget && (type == PokeType.fly || state.holdingItem?.id == 584)) return 0;
            break;
          case PokeType.rock:
            if (type == PokeType.fire || type == PokeType.fly || type == PokeType.ice || type == PokeType.bug) deg++;
            if (type == PokeType.fight || type == PokeType.ground || type == PokeType.steel) deg--;
            break;
          case PokeType.bug:
            if (type == PokeType.grass || type == PokeType.psychic || type == PokeType.evil) deg++;
            if (type == PokeType.fire || type == PokeType.fight || type == PokeType.poison || type == PokeType.fly || type == PokeType.ghost || type == PokeType.steel || type == PokeType.fairy) deg--;
            break;
          case PokeType.ghost:
            if (type == PokeType.psychic || type == PokeType.ghost) deg++;
            if (type == PokeType.evil) deg--;
            if (!isRingTarget && type == PokeType.normal) return 0;
            break;
          case PokeType.steel:
            if (type == PokeType.ice || type == PokeType.rock || type == PokeType.fairy) deg++;
            if (type == PokeType.fire || type == PokeType.water || type == PokeType.electric || type == PokeType.steel) deg--;
            break;
          case PokeType.fire:
            if (type == PokeType.grass || type == PokeType.ice || type == PokeType.bug || type == PokeType.steel) deg++;
            if (type == PokeType.fire || type == PokeType.water || type == PokeType.rock || type == PokeType.dragon) deg--;
            break;
          case PokeType.water:
            if (type == PokeType.fire || type == PokeType.ground || type == PokeType.rock) deg++;
            if (type == PokeType.water || type == PokeType.grass || type == PokeType.dragon) deg--;
            break;
          case PokeType.grass:
            if (type == PokeType.water || type == PokeType.ground || type == PokeType.rock) deg++;
            if (type == PokeType.fire || type == PokeType.grass || type == PokeType.poison || type == PokeType.fly || type == PokeType.bug || type == PokeType.dragon || type == PokeType.steel) deg--;
            break;
          case PokeType.electric:
            if (type == PokeType.water || type == PokeType.fly) deg++;
            if (type == PokeType.electric || type == PokeType.grass || type == PokeType.dragon) deg--;
            if (!isRingTarget && type == PokeType.ground) return 0;
            break;
          case PokeType.psychic:
            if (type == PokeType.fight || type == PokeType.poison) deg++;
            if (type == PokeType.psychic || type == PokeType.steel) deg--;
            if (!isRingTarget && !isMiracleEye && type == PokeType.evil) return 0;
            break;
          case PokeType.ice:
            if (type == PokeType.grass || type == PokeType.ground || type == PokeType.fly || type == PokeType.dragon) deg++;
            if (type == PokeType.fire || type == PokeType.water || type == PokeType.ice || type == PokeType.steel) deg--;
            break;
          case PokeType.dragon:
            if (type == PokeType.dragon) deg++;
            if (type == PokeType.steel) deg--;
            if (!isRingTarget && type == PokeType.fairy) return 0;
            break;
          case PokeType.evil:
            if (type == PokeType.psychic || type == PokeType.ghost) deg++;
            if (type == PokeType.fight || type == PokeType.evil || type == PokeType.fairy) deg--;
            break;
          case PokeType.fairy:
            if (type == PokeType.fight || type == PokeType.dragon || type == PokeType.evil) deg++;
            if (type == PokeType.fire || type == PokeType.poison || type == PokeType.steel) deg--;
            break;
          default:
            break;
        }
      }
    }
    if (!state.isTerastaling && attackType == PokeType.fire && state.ailmentsWhere((e) => e.id == Ailment.tarShot).isNotEmpty) deg++;
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
