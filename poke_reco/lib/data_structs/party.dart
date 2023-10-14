import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

class Party {
  int id = 0;    // データベースのプライマリーキー
  String name = '';
  List<Pokemon?> _pokemons = [Pokemon(), null, null, null, null, null];
  List<Item?> _items = List.generate(6, (i) => null);
  Owner owner = Owner.mine;
  int refCount = 0;

  // getter
  Pokemon get pokemon1 => _pokemons[0]!;
  Pokemon? get pokemon2 => _pokemons[1];
  Pokemon? get pokemon3 => _pokemons[2];
  Pokemon? get pokemon4 => _pokemons[3];
  Pokemon? get pokemon5 => _pokemons[4];
  Pokemon? get pokemon6 => _pokemons[5];
  List<Pokemon?> get pokemons => _pokemons;
  Item? get item1 => _items[0];
  Item? get item2 => _items[1];
  Item? get item3 => _items[2];
  Item? get item4 => _items[3];
  Item? get item5 => _items[4];
  Item? get item6 => _items[5];
  List<Item?> get items => _items;
  int get pokemonNum {
    for (int i = 0; i < 6; i++) {
      if (pokemons[i] == null) return i;
    }
    return 6;
  }
  bool get isValid {
    return
      name != '' &&
      _pokemons[0]!.isValid;
  }

  // setter
  set pokemon1(Pokemon x)  => _pokemons[0] = x;
  set pokemon2(Pokemon? x) => _pokemons[1] = x;
  set pokemon3(Pokemon? x) => _pokemons[2] = x;
  set pokemon4(Pokemon? x) => _pokemons[3] = x;
  set pokemon5(Pokemon? x) => _pokemons[4] = x;
  set pokemon6(Pokemon? x) => _pokemons[5] = x;
  set item1(Item? x) => _items[0] = x;
  set item2(Item? x) => _items[1] = x;
  set item3(Item? x) => _items[2] = x;
  set item4(Item? x) => _items[3] = x;
  set item5(Item? x) => _items[4] = x;
  set item6(Item? x) => _items[5] = x;

  Party copyWith() =>
    Party()
    ..id = id
    ..name = name
    .._pokemons = [..._pokemons]
    .._items = [..._items]
    ..owner = owner
    ..refCount = refCount;

  // SQLite保存用
  Map<String, dynamic> toMap() {
    return {
      partyColumnId: id,
      partyColumnName: name,
      partyColumnPokemonId1: pokemon1.id,
      partyColumnPokemonItem1: item1?.id,
      partyColumnPokemonId2: pokemon2?.id,
      partyColumnPokemonItem2: item2?.id,
      partyColumnPokemonId3: pokemon3?.id,
      partyColumnPokemonItem3: item3?.id,
      partyColumnPokemonId4: pokemon4?.id,
      partyColumnPokemonItem4: item4?.id,
      partyColumnPokemonId5: pokemon5?.id,
      partyColumnPokemonItem5: item5?.id,
      partyColumnPokemonId6: pokemon6?.id,
      partyColumnPokemonItem6: item6?.id,
      partyColumnOwnerID: owner.index,
      partyColumnRefCount: refCount,
    };
  }
}