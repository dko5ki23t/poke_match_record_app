import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestPokeDB {
  static const String assetRoot = '../../../assets/';
  Map<int, Ability> abilities = {
    0: Ability(0, '', '', Timing.none, Target.none, AbilityEffect(0))
  }; // 無効なとくせい
  Map<int, String> _abilityFlavors = {0: ''}; // 無効なとくせい
  Map<int, String> _abilityEnglishFlavors = {0: ''}; // 無効なとくせい
  Map<int, Temper> tempers = {
    0: Temper(0, '', '', StatIndex.none, StatIndex.none)
  }; // 無効なせいかく
  Map<int, Item> items = {
    0: Item(
        id: 0,
        displayName: '',
        displayNameEn: '',
        flingPower: 0,
        flingEffectId: 0,
        timing: Timing.none,
        isBerry: false,
        imageUrl: '')
  }; // 無効なもちもの
  Map<int, String> _itemFlavors = {0: ''}; // 無効なもちもの
  Map<int, String> _itemEnglishFlavors = {0: ''}; // 無効なもちもの
  Map<int, Move> moves = {
    0: Move(0, '', '', PokeType.unknown, 0, 0, 0, Target.none, DamageClass(0),
        MoveEffect(0), 0, 0)
  }; // 無効なわざ
  Map<int, String> _moveFlavors = {0: ''}; // 無効なわざ
  Map<int, String> _moveEnglishFlavors = {0: ''}; // 無効なわざ
  List<PokeType> types = PokeType.values.sublist(1, 19);
  List<PokeType> teraTypes = PokeType.values.sublist(1, PokeType.values.length);
  Map<int, EggGroup> eggGroups = {0: EggGroup(0, '')}; // 無効なタマゴグループ
  Map<int, PokeBase> pokeBase = {
    // 無効なポケモン
    0: PokeBase(
      name: '',
      nameEn: '',
      sex: [Sex.createFromId(0)],
      no: 0,
      type1: PokeType.unknown,
      type2: null,
      h: 0,
      a: 0,
      b: 0,
      c: 0,
      d: 0,
      s: 0,
      ability: [],
      move: [],
      height: 0,
      weight: 0,
      eggGroups: [],
      imageUrl: 'https://dammy',
    ),
  };

  List<int> parseIntList(dynamic str) {
    List<int> ret = [];
    // なぜかintの場合もif文の中に入らないのでtoStringを使う
    if (str is int) {
      return [str];
    }
    final contents = str.split(sqlSplit1);
    for (var c in contents) {
      if (c == '') {
        continue;
      }
      ret.add(int.parse(c));
    }
    return ret;
  }

  Future<void> initialize() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    /////////// とくせい
    final abilityDb = await openDatabase(assetRoot + abilityDBFile);
    // 内部データに変換
    List<Map<String, dynamic>> maps = await abilityDb.query(
      abilityDBTable,
      columns: [
        abilityColumnId,
        abilityColumnName,
        abilityColumnEnglishName,
        abilityColumnTiming,
        abilityColumnTarget,
        abilityColumnEffect
      ],
    );
    for (var map in maps) {
      abilities[map[abilityColumnId]] = Ability(
        map[abilityColumnId],
        map[abilityColumnName],
        map[abilityColumnEnglishName],
        Timing.values[map[abilityColumnTiming]],
        Target.values[map[abilityColumnTarget]],
        AbilityEffect(map[abilityColumnEffect]),
      );
    }

    //////////// とくせいの説明
    final abilityFlavorDb = await openDatabase(assetRoot + abilityFlavorDBFile);
    // 内部データに変換
    maps = await abilityFlavorDb.query(
      abilityFlavorDBTable,
      columns: [
        abilityFlavorColumnId,
        abilityFlavorColumnFlavor,
        abilityFlavorColumnEnglishFlavor,
      ],
    );
    for (var map in maps) {
      _abilityFlavors[map[abilityFlavorColumnId]] =
          map[abilityFlavorColumnFlavor];
      _abilityEnglishFlavors[map[abilityFlavorColumnId]] =
          map[abilityFlavorColumnEnglishFlavor];
    }

    //////////// せいかく
    final temperDb = await openDatabase(assetRoot + temperDBFile);
    // 内部データに変換
    maps = await temperDb.query(
      temperDBTable,
      columns: [
        temperColumnId,
        temperColumnName,
        temperColumnEnglishName,
        temperColumnDe,
        temperColumnIn
      ],
    );
    for (var map in maps) {
      tempers[map[temperColumnId]] = Temper(
        map[temperColumnId],
        map[temperColumnName],
        map[temperColumnEnglishName],
        StatIndexNumber.getStatIndexFromIndex((map[temperColumnDe] as int) - 1),
        StatIndexNumber.getStatIndexFromIndex((map[temperColumnIn] as int) - 1),
      );
    }

    //////////// タマゴグループ
    final eggGroupDb = await openDatabase(assetRoot + eggGroupDBFile);
    // 内部データに変換
    maps = await eggGroupDb.query(
      eggGroupDBTable,
      columns: [eggGroupColumnId, eggGroupColumnName],
    );
    for (var map in maps) {
      eggGroups[map[eggGroupColumnId]] = EggGroup(
        map[eggGroupColumnId],
        map[eggGroupColumnName],
      );
    }

    //////////// もちもの
    final itemDb = await openDatabase(assetRoot + itemDBFile);
    // 内部データに変換
    maps = await itemDb.query(
      itemDBTable,
      columns: [
        itemColumnId,
        itemColumnName,
        itemColumnEnglishName,
        itemColumnFlingPower,
        itemColumnFlingEffect,
        itemColumnTiming,
        itemColumnIsBerry,
        itemColumnImageUrl
      ],
    );
    for (var map in maps) {
      items[map[itemColumnId]] = Item(
          id: map[itemColumnId],
          displayName: map[itemColumnName],
          displayNameEn: map[itemColumnEnglishName],
          flingPower: map[itemColumnFlingPower],
          flingEffectId: map[itemColumnFlingEffect],
          timing: Timing.values[map[itemColumnTiming]],
          isBerry: map[itemColumnIsBerry] == 1,
          imageUrl: map[itemColumnImageUrl]);
    }

    //////////// もちものの説明
    final itemFlavorDb = await openDatabase(assetRoot + itemFlavorDBFile);
    // 内部データに変換
    maps = await itemFlavorDb.query(
      itemFlavorDBTable,
      columns: [
        itemFlavorColumnId,
        itemFlavorColumnFlavor,
        itemFlavorColumnEnglishFlavor
      ],
    );
    for (var map in maps) {
      _itemFlavors[map[itemFlavorColumnId]] = map[itemFlavorColumnFlavor];
      _itemEnglishFlavors[map[itemFlavorColumnId]] =
          map[itemFlavorColumnEnglishFlavor];
    }

    //////////// わざ
    final moveDb = await openDatabase(assetRoot + moveDBFile);
    // 内部データに変換
    maps = await moveDb.query(
      moveDBTable,
      columns: [
        moveColumnId,
        moveColumnName,
        moveColumnEnglishName,
        moveColumnType,
        moveColumnPower,
        moveColumnAccuracy,
        moveColumnPriority,
        moveColumnTarget,
        moveColumnDamageClass,
        moveColumnEffect,
        moveColumnEffectChance,
        moveColumnPP
      ],
    );
    for (var map in maps) {
      moves[map[moveColumnId]] = Move(
        map[moveColumnId],
        map[moveColumnName],
        map[moveColumnEnglishName],
        PokeType.values[map[moveColumnType]],
        map[moveColumnPower],
        map[moveColumnAccuracy],
        map[moveColumnPriority],
        Target.values[map[moveColumnTarget]],
        DamageClass(map[moveColumnDamageClass]),
        MoveEffect(map[moveColumnEffect]),
        map[moveColumnEffectChance],
        map[moveColumnPP],
      );
    }

    //////////// わざの説明
    final moveFlavorDb = await openDatabase(assetRoot + moveFlavorDBFile);
    // 内部データに変換
    maps = await moveFlavorDb.query(
      moveFlavorDBTable,
      columns: [
        moveFlavorColumnId,
        moveFlavorColumnFlavor,
        moveFlavorColumnEnglishFlavor,
      ],
    );
    for (var map in maps) {
      _moveFlavors[map[moveFlavorColumnId]] = map[moveFlavorColumnFlavor];
      _moveEnglishFlavors[map[moveFlavorColumnId]] =
          map[moveFlavorColumnEnglishFlavor];
    }

    //////////// ポケモン図鑑
    final pokeBaseDb = await openDatabase(assetRoot + pokeBaseDBFile);
    // 内部データに変換
    maps = await pokeBaseDb.query(
      pokeBaseDBTable,
      columns: [
        pokeBaseColumnId,
        pokeBaseColumnName,
        pokeBaseColumnEnglishName,
        pokeBaseColumnAbility,
        pokeBaseColumnForm,
        pokeBaseColumnFemaleRate,
        pokeBaseColumnMove,
        for (var e in pokeBaseColumnStats) e,
        pokeBaseColumnType,
        pokeBaseColumnHeight,
        pokeBaseColumnWeight,
        pokeBaseColumnEggGroup,
        pokeBaseColumnImageUrl,
      ],
    );

    for (var map in maps) {
      final pokeTypes = parseIntList(map[pokeBaseColumnType]);
      final pokeAbilities = parseIntList(map[pokeBaseColumnAbility]);
      final pokeMoves = parseIntList(map[pokeBaseColumnMove]);
      final pokeEggGroups = parseIntList(map[pokeBaseColumnEggGroup]);
      List<Sex> sexList = [];
      if (map[pokeBaseColumnFemaleRate] == -1) {
        sexList = [Sex.none];
      } else if (map[pokeBaseColumnFemaleRate] == 8) {
        sexList = [Sex.female];
      } else if (map[pokeBaseColumnFemaleRate] == 0) {
        sexList = [Sex.male];
      } else {
        sexList = [Sex.male, Sex.female];
      }
      pokeBase[map[pokeBaseColumnId]] = PokeBase(
        name: map[pokeBaseColumnName],
        nameEn: map[pokeBaseColumnEnglishName],
        sex: sexList,
        no: map[pokeBaseColumnId],
        type1: PokeType.values[pokeTypes[0]],
        type2: (pokeTypes.length > 1) ? PokeType.values[pokeTypes[1]] : null,
        h: map[pokeBaseColumnStats[0]],
        a: map[pokeBaseColumnStats[1]],
        b: map[pokeBaseColumnStats[2]],
        c: map[pokeBaseColumnStats[3]],
        d: map[pokeBaseColumnStats[4]],
        s: map[pokeBaseColumnStats[5]],
        ability: [for (var e in pokeAbilities) abilities[e]!],
        move: [for (var e in pokeMoves) moves[e]!],
        height: map[pokeBaseColumnHeight],
        weight: map[pokeBaseColumnWeight],
        eggGroups: [for (var e in pokeEggGroups) eggGroups[e]!],
        imageUrl: map[pokeBaseColumnImageUrl],
      );
    }
  }
}
