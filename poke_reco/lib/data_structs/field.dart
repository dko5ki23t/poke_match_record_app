// フィールド

import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

// フィールドによる効果(TurnEffectのeffectIdに使用する定数を提供)
class FieldEffect {
  static const int none = 0;
  static const int electricTerrainEnd = 1;  // エレキフィールド終了
  static const int grassyTerrainEnd = 2;    // グラスフィールド終了
  static const int mistyTerrainEnd = 3;     // ミストフィールド終了
  static const int psychicTerrainEnd = 4;   // サイコフィールド終了
  static const int grassHeal = 5;           // グラスフィールドによる回復

  static const _displayNameMap = {
    0: '',
    1: 'エレキフィールド終了',
    2: 'グラスフィールド終了',
    3: 'ミストフィールド終了',
    4: 'サイコフィールド終了',
    5: 'グラスフィールドによる回復',
  };

  const FieldEffect(this.id);

  static int getIdFromField(Field field) {
    switch (field.id) {
      case Field.electricTerrain:
      case Field.grassyTerrain:
      case Field.mistyTerrain:
      case Field.psychicTerrain:
        return field.id;
      default:
        return 0;
    }
  }

  String get displayName => _displayNameMap[id]!;

  final int id;
}

// フィールド
class Field {
  static const int none = 0;
  static const int electricTerrain = 1;    // エレキフィールド
  static const int grassyTerrain = 2;      // グラスフィールド
  static const int mistyTerrain = 3;       // ミストフィールド
  static const int psychicTerrain = 4;     // サイコフィールド

  static const Map<int, Tuple3<String, Color, int>> _nameColorTurnMap = {
    0:  Tuple3('', Colors.black, 0),
    1:  Tuple3('エレキフィールド', PokeTypeColor.electric, 5),
    2:  Tuple3('グラスフィールド', PokeTypeColor.grass, 5),
    3:  Tuple3('ミストフィールド', PokeTypeColor.fairy, 5),
    4:  Tuple3('サイコフィールド', PokeTypeColor.psychic, 5),
  };

  String get displayName => '${_nameColorTurnMap[id]!.item1} ($turns/$maxTurns)';
  Color get bgColor => _nameColorTurnMap[id]!.item2;
  int get maxTurns {
    if (extraArg1 == 8) {
      return 8;
    }
    return _nameColorTurnMap[id]!.item3;
  }

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
