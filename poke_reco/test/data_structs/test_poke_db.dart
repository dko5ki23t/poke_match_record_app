import 'dart:io';

import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tuple/tuple.dart';

class TestPokeDB {
  static const String assetRoot = '../../../assets/';
  PokeDB data = PokeDB();

  Map<int, String> _abilityFlavors = {0: ''}; // 無効なとくせい
  Map<int, String> _abilityEnglishFlavors = {0: ''}; // 無効なとくせい
  Map<int, String> _itemFlavors = {0: ''}; // 無効なもちもの
  Map<int, String> _itemEnglishFlavors = {0: ''}; // 無効なもちもの
  Map<int, String> _moveFlavors = {0: ''}; // 無効なわざ
  Map<int, String> _moveEnglishFlavors = {0: ''}; // 無効なわざ

  List<Tuple2<int, int>> parseIntTuple2List(dynamic str) {
    List<Tuple2<int, int>> ret = [];
    // なぜかintの場合もif文の中に入らないのでtoStringを使う
    if (str is int) {
      return [];
    }
    final contents = str.split(sqlSplit1);
    for (var c in contents) {
      if (c == '') {
        continue;
      }
      final contents2 = c.split(sqlSplit2);
      ret.add(Tuple2(
          int.parse(contents2.removeAt(0)), int.parse(contents2.removeAt(0))));
    }
    return ret;
  }

  // PokeDBのinitializeの代わりに呼ぶことで、単体テストでも使えるDBとなる
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
        abilityColumnPossiblyChangeStat
      ],
    );
    for (var map in maps) {
      final rawPcs = parseIntTuple2List(map[abilityColumnPossiblyChangeStat]);
      final List<Tuple2<StatIndex, int>> possiblyChangeStat = [];
      for (final t in rawPcs) {
        possiblyChangeStat.add(Tuple2(StatIndex.values[t.item1], t.item2));
      }
      data.abilities[map[abilityColumnId]] = Ability(
          map[abilityColumnId],
          map[abilityColumnName],
          map[abilityColumnEnglishName],
          Timing.values[map[abilityColumnTiming]],
          Target.values[map[abilityColumnTarget]],
          possiblyChangeStat);
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
    final natureDb = await openDatabase(assetRoot + natureDBFile);
    // 内部データに変換
    maps = await natureDb.query(
      natureDBTable,
      columns: [
        natureColumnId,
        natureColumnName,
        natureColumnEnglishName,
        natureColumnDe,
        natureColumnIn
      ],
    );
    for (var map in maps) {
      data.natures[map[natureColumnId]] = Nature(
        map[natureColumnId],
        map[natureColumnName],
        map[natureColumnEnglishName],
        StatIndex.values[(map[natureColumnDe] as int) - 1],
        StatIndex.values[(map[natureColumnIn] as int) - 1],
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
      data.eggGroups[map[eggGroupColumnId]] = EggGroup(
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
        itemColumnImageUrl,
        itemColumnPossiblyChangeStat
      ],
    );
    for (var map in maps) {
      final rawPcs = parseIntTuple2List(map[itemColumnPossiblyChangeStat]);
      final List<Tuple2<StatIndex, int>> possiblyChangeStat = [];
      for (final t in rawPcs) {
        possiblyChangeStat.add(Tuple2(StatIndex.values[t.item1], t.item2));
      }
      data.items[map[itemColumnId]] = Item(
          id: map[itemColumnId],
          displayName: map[itemColumnName],
          displayNameEn: map[itemColumnEnglishName],
          flingPower: map[itemColumnFlingPower],
          flingEffectId: map[itemColumnFlingEffect],
          timing: Timing.values[map[itemColumnTiming]],
          isBerry: map[itemColumnIsBerry] == 1,
          imageUrl: map[itemColumnImageUrl],
          possiblyChangeStat: possiblyChangeStat);
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
    if (File(assetRoot + moveDBFile).existsSync()) {
      print('OK');
    }
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
        moveColumnPP,
        moveColumnIsDirect,
        moveColumnIsSound,
        moveColumnIsDrain,
        moveColumnIsPunch,
        moveColumnIsWave,
        moveColumnIsDance,
        moveColumnIsRecoil,
        moveColumnIsAdditionalEffect,
        moveColumnIsAdditionalEffect2,
        moveColumnIsBite,
        moveColumnIsCut,
        moveColumnIsWind,
        moveColumnIsPowder,
        moveColumnIsBullet,
        moveColumnSuccessWithProtect,
        moveColumnLoseWithRecoil,
      ],
    );
    for (var map in maps) {
      data.moves[map[moveColumnId]] = Move(
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
        map[moveColumnIsDirect] != '0',
        map[moveColumnIsSound] != '0',
        map[moveColumnIsDrain] != '0',
        map[moveColumnIsPunch] != '0',
        map[moveColumnIsWave] != '0',
        map[moveColumnIsDance] != '0',
        map[moveColumnIsRecoil] != '0',
        map[moveColumnIsAdditionalEffect] != '0',
        map[moveColumnIsAdditionalEffect2] != '0',
        map[moveColumnIsBite] != '0',
        map[moveColumnIsCut] != '0',
        map[moveColumnIsWind] != '0',
        map[moveColumnIsPowder] != '0',
        map[moveColumnIsBullet] != '0',
        map[moveColumnSuccessWithProtect] != '0',
        map[moveColumnLoseWithRecoil] != '0',
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

    /////////// その他の補正(フォルム等)
    final bdDb = await openDatabase(assetRoot + buffDebuffDBFile);
    if (File(assetRoot + buffDebuffDBFile).existsSync()) {
      print('OK');
    }
    // 内部データに変換
    maps = await bdDb.query(
      buffDebuffDBTable,
      columns: [
        buffDebuffColumnId,
        buffDebuffColumnName,
        buffDebuffColumnEnglishName,
        buffDebuffColumnColor,
        buffDebuffColumnTurns,
        buffDebuffColumnIsHidden,
        buffDebuffColumnEffectID,
        buffDebuffColumnEffectArg1,
        buffDebuffColumnEffectArg2,
        buffDebuffColumnEffectArg3,
        buffDebuffColumnEffectArg4,
        buffDebuffColumnEffectArg5,
        buffDebuffColumnEffectArg6,
        buffDebuffColumnEffectArg7,
      ],
    );
    for (var map in maps) {
      data.buffDebuffs[map[buffDebuffColumnId]] = BuffDebuff(
        map[buffDebuffColumnId],
        map[buffDebuffColumnName],
        map[buffDebuffColumnEnglishName],
        map[buffDebuffColumnColor],
        map[buffDebuffColumnTurns],
        map[buffDebuffColumnIsHidden] != '0',
        map[buffDebuffColumnEffectID],
        map[buffDebuffColumnEffectArg1],
        map[buffDebuffColumnEffectArg2],
        map[buffDebuffColumnEffectArg3],
        map[buffDebuffColumnEffectArg4],
        map[buffDebuffColumnEffectArg5],
        map[buffDebuffColumnEffectArg6],
        map[buffDebuffColumnEffectArg7],
      );
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
        pokeBaseColumnAvailableEviolite,
      ],
    );

    for (var map in maps) {
      final pokeTypes = data.parseIntList(map[pokeBaseColumnType]);
      final pokeAbilities = data.parseIntList(map[pokeBaseColumnAbility]);
      final pokeMoves = data.parseIntList(map[pokeBaseColumnMove]);
      final pokeEggGroups = data.parseIntList(map[pokeBaseColumnEggGroup]);
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
      data.pokeBase[map[pokeBaseColumnId]] = PokeBase(
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
        ability: [for (var e in pokeAbilities) data.abilities[e]!],
        move: [for (var e in pokeMoves) data.moves[e]!],
        height: map[pokeBaseColumnHeight],
        weight: map[pokeBaseColumnWeight],
        eggGroups: [for (var e in pokeEggGroups) data.eggGroups[e]!],
        imageUrl: map[pokeBaseColumnImageUrl],
        availableEviolite: map[pokeBaseColumnAvailableEviolite] != 0,
      );
    }
  }

  String? getAbilityFlavor(int abilityId) {
//    switch (language) {
//      case Language.english:
//        return _abilityEnglishFlavors[abilityId];
//      case Language.japanese:
//      default:
//        return _abilityFlavors[abilityId];
//    }
    return _abilityFlavors[abilityId];
  }

  String? getItemFlavor(int itemId) {
//    switch (language) {
//      case Language.english:
//        return _itemEnglishFlavors[itemId];
//      case Language.japanese:
//      default:
//        return _itemFlavors[itemId];
//    }
    return _itemFlavors[itemId];
  }

  String? getMoveFlavor(int moveId) {
//    switch (language) {
//      case Language.english:
//        return _moveEnglishFlavors[moveId];
//      case Language.japanese:
//      default:
//        return _moveFlavors[moveId];
//    }
    return _moveFlavors[moveId];
  }
}
