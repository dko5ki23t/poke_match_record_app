import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

/// フィールド
class Field extends Equatable implements Copyable {
  /// なし
  static const int none = 0;

  /// エレキフィールド
  static const int electricTerrain = 1;

  /// グラスフィールド
  static const int grassyTerrain = 2;

  /// ミストフィールド
  static const int mistyTerrain = 3;

  /// サイコフィールド
  static const int psychicTerrain = 4;

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap =
      {
    0: Tuple4('', '', Colors.black, 0),
    1: Tuple4('エレキフィールド', 'Electric Terrain', PokeTypeColor.electric, 5),
    2: Tuple4('グラスフィールド', 'Grassy Terrain', PokeTypeColor.grass, 5),
    3: Tuple4('ミストフィールド', 'Misty Terrain', PokeTypeColor.fairy, 5),
    4: Tuple4('サイコフィールド', 'Psychic Terrain', PokeTypeColor.psychic, 5),
  };

  /// 表示名
  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return '${_nameColorTurnMap[id]!.item1} ($turns/$maxTurns)';
      case Language.english:
      default:
        return '${_nameColorTurnMap[id]!.item2} ($turns/$maxTurns)';
    }
  }

  /// 表示背景色
  Color get bgColor => _nameColorTurnMap[id]!.item3;

  /// 最大継続ターン
  int get maxTurns {
    if (extraArg1 == 8) {
      return 8;
    }
    return _nameColorTurnMap[id]!.item4;
  }

  /// ID
  final int id;

  /// 経過ターン
  int turns = 0;

  /// 引数1
  int extraArg1 = 0;

  @override
  List<Object?> get props => [
        id,
        turns,
        extraArg1,
      ];

  /// フィールド
  Field(this.id);

  @override
  Field copy() => Field(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  /// フィールド変化もしくは場に登場したポケモンに対してフィールドの効果をかける
  /// (場に出たポケモンに対しては、変化前を「フィールドなし」として引数を渡すとよい)
  /// ```
  /// before: 変化前フィールド
  /// after: 変化後フィールド
  /// ownPokemonState: 自身(ユーザー)のポケモンの状態
  /// opponentPokemonState: 相手のポケモンの状態
  /// ```
  static void processFieldEffect(Field before, Field after,
      PokemonState? ownPokemonState, PokemonState? opponentPokemonState) {
    final pokeData = PokeDB();
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
      ownPokemonState.type1 = newTypeID == 0
          ? ownPokemonState.pokemon.type1
          : PokeType.values[newTypeID];
      ownPokemonState.type2 =
          newTypeID == 0 ? ownPokemonState.pokemon.type2 : null;
    }
    if (opponentPokemonState != null &&
        opponentPokemonState.currentAbility.id == 250) {
      opponentPokemonState.type1 = newTypeID == 0
          ? opponentPokemonState.pokemon.type1
          : PokeType.values[newTypeID];
      opponentPokemonState.type2 =
          newTypeID == 0 ? opponentPokemonState.pokemon.type2 : null;
    }

    if (before.id != Field.grassyTerrain && after.id == Field.grassyTerrain) {
      // グラスフィールドになる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 179) {
        // くさのけがわ
        ownPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.guard1_5]!);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 179) {
        // くさのけがわ
        opponentPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.guard1_5]!);
      }
    }
    if (before.id == Field.grassyTerrain && after.id != Field.grassyTerrain) {
      // グラスフィールドではなくなる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 179) {
        // くさのけがわ
        ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.guard1_5);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 179) {
        // くさのけがわ
        opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.guard1_5);
      }
    }
    if (before.id != Field.electricTerrain &&
        after.id == Field.electricTerrain) {
      // エレキフィールドになる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 207) {
        // サーフテール
        ownPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.speed2]!);
      }
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 289) {
        // ハドロンエンジン
        ownPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.specialAttack1_33]!);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 207) {
        // サーフテール
        opponentPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.speed2]!);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 289) {
        // ハドロンエンジン
        opponentPokemonState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.specialAttack1_33]!);
      }
    }
    if (before.id == Field.electricTerrain &&
        after.id != Field.electricTerrain) {
      // エレキフィールドではなくなる時
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 207) {
        // サーフテール
        ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
      }
      if (ownPokemonState != null && ownPokemonState.currentAbility.id == 289) {
        // ハドロンエンジン
        ownPokemonState.buffDebuffs
            .removeFirstByID(BuffDebuff.specialAttack1_33);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 207) {
        // サーフテール
        opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
      }
      if (opponentPokemonState != null &&
          opponentPokemonState.currentAbility.id == 289) {
        // ハドロンエンジン
        opponentPokemonState.buffDebuffs
            .removeFirstByID(BuffDebuff.specialAttack1_33);
      }
    }
  }

  /// SQLに保存された文字列からFieldをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// ```
  static Field deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Field(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1: 区切り文字
  /// ```
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}
