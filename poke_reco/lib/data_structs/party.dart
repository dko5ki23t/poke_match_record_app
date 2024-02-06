import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/tool.dart';

/// パーティを管理するclass
class Party extends Equatable implements Copyable {
  /// データベースのプライマリーキー
  int id = 0;

  /// 表示順
  int viewOrder = 0;

  /// パーティ名
  String name = '';

  /// パーティ内のポケモンリスト
  List<Pokemon?> _pokemons = [Pokemon(), null, null, null, null, null];

  /// パーティ内ポケモンのもちものリスト
  List<Item?> items = List.generate(6, (i) => null);

  /// 所有者
  Owner owner = Owner.mine;

  /// パーティの勝利数
  int winCount = 0;

  /// パーティが対戦で使われた回数
  int usedCount = 0;

  /// パーティの勝率
  int winRate = 0;

  @override
  List<Object> get props => [
        id,
        viewOrder,
        name,
        _pokemons,
        items,
        owner,
        winCount,
        usedCount,
        winRate,
      ];

  Party();

  /// Databaseから取得したMapからclassを生成
  /// ```
  /// map: Databaseから取得したMap
  /// ```
  Party.createFromDBMap(Map<String, dynamic> map) {
    var pokeData = PokeDB();
    id = map[partyColumnId];
    viewOrder = map[partyColumnViewOrder];
    name = map[partyColumnName];
    pokemons[0] = pokeData.pokemons.values
        .where((element) => element.id == map[partyColumnPokemonId1])
        .first;
    items[0] = map[partyColumnPokemonItem1] != null
        ? pokeData.items[map[partyColumnPokemonItem1]]
        : null;
    pokemons[1] = map[partyColumnPokemonId2] != null
        ? pokeData.pokemons.values
            .where((element) => element.id == map[partyColumnPokemonId2])
            .first
        : null;
    items[1] = map[partyColumnPokemonItem2] != null
        ? pokeData.items[map[partyColumnPokemonItem2]]
        : null;
    pokemons[2] = map[partyColumnPokemonId3] != null
        ? pokeData.pokemons.values
            .where((element) => element.id == map[partyColumnPokemonId3])
            .first
        : null;
    items[2] = map[partyColumnPokemonItem3] != null
        ? pokeData.items[map[partyColumnPokemonItem3]]
        : null;
    pokemons[3] = map[partyColumnPokemonId4] != null
        ? pokeData.pokemons.values
            .where((element) => element.id == map[partyColumnPokemonId4])
            .first
        : null;
    items[3] = map[partyColumnPokemonItem4] != null
        ? pokeData.items[map[partyColumnPokemonItem4]]
        : null;
    pokemons[4] = map[partyColumnPokemonId5] != null
        ? pokeData.pokemons.values
            .where((element) => element.id == map[partyColumnPokemonId5])
            .first
        : null;
    items[4] = map[partyColumnPokemonItem5] != null
        ? pokeData.items[map[partyColumnPokemonItem5]]
        : null;
    pokemons[5] = map[partyColumnPokemonId6] != null
        ? pokeData.pokemons.values
            .where((element) => element.id == map[partyColumnPokemonId6])
            .first
        : null;
    items[5] = map[partyColumnPokemonItem6] != null
        ? pokeData.items[map[partyColumnPokemonItem6]]
        : null;
    owner = toOwner(map[partyColumnOwnerID]);
  }

  /// パーティ内のポケモンリスト
  List<Pokemon?> get pokemons => _pokemons;

  /// パーティ内のポケモン数
  int get pokemonNum {
    for (int i = 0; i < 6; i++) {
      if (pokemons[i] == null) return i;
    }
    return 6;
  }

  /// 有効かどうか
  bool get isValid {
    return name != '' && _pokemons[0]!.isValid;
  }

  /// このパーティが参照されている数
  bool get refs {
    for (final e in PokeDB().battles.values) {
      if (e.getParty(PlayerType.me).id == id) return true;
      if (e.getParty(PlayerType.opponent).id == id) return true;
    }
    return false;
  }

  @override
  Party copy() {
    return Party()
      ..id = id
      ..viewOrder = viewOrder
      ..name = name
      .._pokemons = [..._pokemons]
      ..items = [...items]
      ..owner = owner;
  }

  /// 指定したポケモンが、パーティ内の各ポケモンに対してタイプ相性有利か不利かを判定し、色で結果を返す
  /// * 有利：赤(半透明)
  /// * 不利：青(半透明)
  /// * 有利不利なし：透明
  List<Color> getCompatibilities(Pokemon pokemon) {
    List<Color> ret = [];
    for (int i = 0; i < pokemonNum; i++) {
      final partyPokemon = _pokemons[i]!;
      double point = 1.0;
      // 引数のポケモンがこうげきするとき
      point += PokeTypeEffectiveness.effectivenessRate(
              pokemon.type1,
              PokemonState()
                ..type1 = partyPokemon.type1
                ..type2 = partyPokemon.type2) -
          1.0;
      if (pokemon.type2 != null) {
        point += PokeTypeEffectiveness.effectivenessRate(
                pokemon.type2!,
                PokemonState()
                  ..type1 = partyPokemon.type1
                  ..type2 = partyPokemon.type2) -
            1.0;
      }
      // パーティ内のポケモンがこうげきするとき
      point += PokeTypeEffectiveness.effectivenessRate(
              partyPokemon.type1,
              PokemonState()
                ..type1 = pokemon.type1
                ..type2 = pokemon.type2) -
          1.0;
      if (partyPokemon.type2 != null) {
        point += PokeTypeEffectiveness.effectivenessRate(
                partyPokemon.type2!,
                PokemonState()
                  ..type1 = pokemon.type1
                  ..type2 = pokemon.type2) -
            1.0;
      }
      if (point >= 1.5) {
        ret.add(Color(0x80ff0000));
      } else if (point <= 0.5) {
        ret.add(Color(0x800000ff));
      } else {
        ret.add(Color(0x00ffffff));
      }
    }
    return ret;
  }

  /// SQLite保存用Mapを返す
  Map<String, dynamic> toMap() {
    return {
      partyColumnId: id,
      partyColumnViewOrder: viewOrder,
      partyColumnName: name,
      partyColumnPokemonId1: pokemons[0]!.id,
      partyColumnPokemonItem1: items[0]?.id,
      partyColumnPokemonId2: pokemons[1]?.id,
      partyColumnPokemonItem2: items[1]?.id,
      partyColumnPokemonId3: pokemons[2]?.id,
      partyColumnPokemonItem3: items[2]?.id,
      partyColumnPokemonId4: pokemons[3]?.id,
      partyColumnPokemonItem4: items[3]?.id,
      partyColumnPokemonId5: pokemons[4]?.id,
      partyColumnPokemonItem5: items[4]?.id,
      partyColumnPokemonId6: pokemons[5]?.id,
      partyColumnPokemonItem6: items[5]?.id,
      partyColumnOwnerID: owner.index,
    };
  }
}
