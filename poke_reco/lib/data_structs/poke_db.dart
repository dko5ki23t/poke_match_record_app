import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_sort_dialog.dart';
import 'package:poke_reco/custom_dialogs/party_sort_dialog.dart';
import 'package:poke_reco/custom_dialogs/battle_sort_dialog.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

const String errorFileName = 'errorFile.db';
const String errorString = 'errorString';

const String configKeyPokemonsOwnerFilter = 'pokemonsOwnerFilter';
const String configKeyPokemonsNoFilter = 'pokemonsNoFilter';
const String configKeyPokemonsTypeFilter = 'pokemonsTypeFilter';
const String configKeyPokemonsTeraTypeFilter = 'pokemonsTeraTypeFilter';
const String configKeyPokemonsMoveFilter = 'pokemonsMoveFilter';
const String configKeyPokemonsSexFilter = 'pokemonsSexFilter';
const String configKeyPokemonsAbilityFilter = 'pokemonsAbilityFilter';
const String configKeyPokemonsTemperFilter = 'pokemonsTemperFilter';

const String configKeyPokemonsSort = 'pokemonsSort';

const String configKeyPartiesOwnerFilter = 'partiesOwnerFilter';
const String configKeyPartiesWinRateMinFilter = 'partiesWinRateMinFilter';
const String configKeyPartiesWinRateMaxFilter = 'partiesWinRateMaxFilter';
const String configKeyPartiesPokemonNoFilter = 'partiesPokemonNoFilter';

const String configKeyPartiesSort = 'partiesSort';

const String configKeyBattlesWinFilter = 'partiesWinFilter';
const String configKeyBattlesPartyIDFilter = 'partiesPartyIDFilter';

const String configKeyBattlesSort = 'battlesSort';

const String configKeyGetNetworkImage = 'getNetworkImage';

const String configKeyLanguage = 'language';

const String configKeyTutorialStep = 'tutorialStep';

const String configKeyBattleOwnMoveSort = 'battleOwnMoveSort';
const String configKeyBattleOpponentMoveSort = 'battleOpponentMoveSort';

const String abilityDBFile = 'Abilities.db';
const String abilityDBTable = 'abilityDB';
const String abilityColumnId = 'id';
const String abilityColumnName = 'name';
const String abilityColumnEnglishName = 'englishName';
const String abilityColumnTiming = 'timing';
const String abilityColumnTarget = 'target';

const String abilityFlavorDBFile = 'AbilityFlavors.db';
const String abilityFlavorDBTable = 'abilityFlavorDB';
const String abilityFlavorColumnId = 'id';
const String abilityFlavorColumnFlavor = 'flavor';
const String abilityFlavorColumnEnglishFlavor = 'englishFlavor';

const String temperDBFile = 'Tempers.db';
const String temperDBTable = 'temperDB';
const String temperColumnId = 'id';
const String temperColumnName = 'name';
const String temperColumnEnglishName = 'englishName';
const String temperColumnDe = 'decreased_stat';
const String temperColumnIn = 'increased_stat';

const String eggGroupDBFile = 'EggGroup.db';
const String eggGroupDBTable = 'eggGroupDB';
const String eggGroupColumnId = 'id';
const String eggGroupColumnName = 'name';

const String itemDBFile = 'Items.db';
const String itemDBTable = 'itemDB';
const String itemColumnId = 'id';
const String itemColumnName = 'name';
const String itemColumnEnglishName = 'englishName';
const String itemColumnFlingPower = 'fling_power';
const String itemColumnFlingEffect = 'fling_effect';
const String itemColumnTiming = 'timing';
const String itemColumnIsBerry = 'is_berry';
const String itemColumnImageUrl = 'image_url';

const String itemFlavorDBFile = 'ItemFlavors.db';
const String itemFlavorDBTable = 'itemFlavorDB';
const String itemFlavorColumnId = 'id';
const String itemFlavorColumnFlavor = 'flavor';
const String itemFlavorColumnEnglishFlavor = 'englishFlavor';

const String moveDBFile = 'Moves.db';
const String moveDBTable = 'moveDB';
const String moveColumnId = 'id';
const String moveColumnName = 'name';
const String moveColumnEnglishName = 'englishName';
const String moveColumnType = 'type';
const String moveColumnPower = 'power';
const String moveColumnAccuracy = 'accuracy';
const String moveColumnPriority = 'priority';
const String moveColumnTarget = 'target';
const String moveColumnDamageClass = 'damage_class';
const String moveColumnEffect = 'effect';
const String moveColumnEffectChance = 'effect_chance';
const String moveColumnPP = 'PP';

const String moveFlavorDBFile = 'MoveFlavors.db';
const String moveFlavorDBTable = 'moveFlavorDB';
const String moveFlavorColumnId = 'id';
const String moveFlavorColumnFlavor = 'flavor';
const String moveFlavorColumnEnglishFlavor = 'englishFlavor';

const String pokeBaseDBFile = 'PokeBases.db';
const String pokeBaseDBTable = 'pokeBaseDB';
const String pokeBaseColumnId = 'id';
const String pokeBaseColumnName = 'name';
const String pokeBaseColumnEnglishName = 'englishName';
const String pokeBaseColumnAbility = 'ability';
const String pokeBaseColumnForm = 'form';
const String pokeBaseColumnFemaleRate = 'femaleRate';
const String pokeBaseColumnMove = 'move';
const List<String> pokeBaseColumnStats = [
  'h',
  'a',
  'b',
  'c',
  'd',
  's',
];
const String pokeBaseColumnType = 'type';
const String pokeBaseColumnHeight = 'height';
const String pokeBaseColumnWeight = 'weight';
const String pokeBaseColumnEggGroup = 'eggGroup';
const String pokeBaseColumnImageUrl = 'imageUrl';

const String preparedDBFile = 'Prepared.db';

const String myPokemonDBFile = 'MyPokemons.db';
const String myPokemonDBTable = 'myPokemonDB';
const String preparedMyPokemonDBTable = 'PreparedMyPokemonDB';
const String myPokemonTestDBFile = 'MyPokemonsTest.db';
const String myPokemonTestDBTable = 'myPokemonTestDB';
const String myPokemonColumnId = 'id';
const String myPokemonColumnViewOrder = 'viewOrder';
const String myPokemonColumnNo = 'no';
const String myPokemonColumnNickName = 'nickname';
const String myPokemonColumnTeraType = 'teratype';
const String myPokemonColumnLevel = 'level';
const String myPokemonColumnSex = 'sex';
const String myPokemonColumnTemper = 'temper';
const String myPokemonColumnAbility = 'ability';
const String myPokemonColumnItem = 'item';
const List<String> myPokemonColumnIndividual = [
  'indiH',
  'indiA',
  'indiB',
  'indiC',
  'indiD',
  'indiS',
];
const List<String> myPokemonColumnEffort = [
  'effH',
  'effA',
  'effB',
  'effC',
  'effD',
  'effS',
];
const String myPokemonColumnMove1 = 'move1';
const String myPokemonColumnPP1 = 'pp1';
const String myPokemonColumnMove2 = 'move2';
const String myPokemonColumnPP2 = 'pp2';
const String myPokemonColumnMove3 = 'move3';
const String myPokemonColumnPP3 = 'pp3';
const String myPokemonColumnMove4 = 'move4';
const String myPokemonColumnPP4 = 'pp4';
const String myPokemonColumnOwnerID = 'owner';

const String partyDBFile = 'parties.db';
const String partyDBTable = 'partyDB';
const String preparedPartyDBTable = 'PreparedPartyDB';
const String partyTestDBFile = 'parties.db';
const String partyTestDBTable = 'partyDB';
const String partyColumnId = 'id';
const String partyColumnViewOrder = 'viewOrder';
const String partyColumnName = 'name';
const String partyColumnPokemonId1 = 'pokemonID1';
const String partyColumnPokemonItem1 = 'pokemonItem1';
const String partyColumnPokemonId2 = 'pokemonID2';
const String partyColumnPokemonItem2 = 'pokemonItem2';
const String partyColumnPokemonId3 = 'pokemonID3';
const String partyColumnPokemonItem3 = 'pokemonItem3';
const String partyColumnPokemonId4 = 'pokemonID4';
const String partyColumnPokemonItem4 = 'pokemonItem4';
const String partyColumnPokemonId5 = 'pokemonID5';
const String partyColumnPokemonItem5 = 'pokemonItem5';
const String partyColumnPokemonId6 = 'pokemonID6';
const String partyColumnPokemonItem6 = 'pokemonItem6';
const String partyColumnOwnerID = 'owner';

const String battleDBFile = 'battles.db';
const String battleDBTable = 'battleDB';
const String battleTestDBFile = 'battles.db';
const String battleTestDBTable = 'battleDB';
const String battleColumnId = 'id';
const String battleColumnViewOrder = 'viewOrder';
const String battleColumnName = 'name';
const String battleColumnTypeId = 'battleType';
const String battleColumnDate = 'date';
const String battleColumnOwnPartyId = 'ownParty';
const String battleColumnOpponentName = 'opponentName';
const String battleColumnOpponentPartyId = 'opponentParty';
const String battleColumnTurns = 'turns';
const String battleColumnIsMyWin = 'isMyWin';
const String battleColumnIsYourWin = 'isYourWin';

// 今後変更されないとも限らない
const int pokemonMinLevel = 1;
const int pokemonMaxLevel = 100;
const int pokemonMinNo = 1;
const int pokemonMinIndividual = 0;
const int pokemonMaxIndividual = 31;
const int pokemonMinEffort = 0;
const int pokemonMaxEffort = 252;
const int pokemonMaxEffortTotal = 510;

/// SQLのDatabaseにListやclassをserializeして保存する際に区切りとして使う文字
const String sqlSplit1 = ';';
const String sqlSplit2 = ':';
const String sqlSplit3 = '_';
const String sqlSplit4 = '*';
const String sqlSplit5 = '!';
const String sqlSplit6 = '}';
const String sqlSplit7 = '{';
const String sqlSplit8 = '|';

/// せいべつ
enum Sex {
  none(0, 'なし', 'Unknown', Icon(Icons.remove, color: Colors.grey)),
  male(1, 'オス', 'Male', Icon(Icons.male, color: Colors.blue)),
  female(2, 'メス', 'Female', Icon(Icons.female, color: Colors.red)),
  ;

  const Sex(this.id, this.ja, this.en, this.displayIcon);

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return ja;
      case Language.english:
      default:
        return en;
    }
  }

  factory Sex.createFromId(int id) {
    switch (id) {
      case 1:
        return male;
      case 2:
        return female;
      case 0:
      default:
        return none;
    }
  }

  final int id;
  final String ja;
  final String en;
  final Icon displayIcon;
}

/// 行動主
enum PlayerType {
  /// なし
  none,

  /// 自身
  me,

  /// 相手
  opponent,

  /// 全体の場(両者に影響あり)
  entireField,
}

/// 行動者の反対を表すextension
extension PlayerTypeOpp on PlayerType {
  /// 行動者の反対
  PlayerType get opposite {
    return this == PlayerType.me ? PlayerType.opponent : PlayerType.me;
  }
}

/// リストのインデックス等に使うextension
extension PlayerTypeNum on PlayerType {
  /// リストのインデックス等に使う番号
  int get number {
    switch (this) {
      case PlayerType.me:
        return 0;
      case PlayerType.opponent:
        return 1;
      case PlayerType.entireField:
        return 2;
      case PlayerType.none:
      default:
        return -1;
    }
  }

  /// 番号から行動主を生成
  static PlayerType createFromNumber(int number) {
    switch (number) {
      case 0:
        return PlayerType.me;
      case 1:
        return PlayerType.opponent;
      case 2:
        return PlayerType.entireField;
      default:
        return PlayerType.none;
    }
  }
}

/// せいかく
class Temper {
  final int id;
  final String _displayName;
  final String _displayNameEn;
  late final StatIndex decreasedStat;
  late final StatIndex increasedStat;

  Temper(this.id, this._displayName, this._displayNameEn, StatIndex dec,
      StatIndex inc) {
    if (dec == inc) {
      decreasedStat = StatIndex.none;
      increasedStat = StatIndex.none;
    } else {
      decreasedStat = dec;
      increasedStat = inc;
    }
  }

  /// 無効なせいかくを返す
  factory Temper.none() {
    return Temper(0, '', '', StatIndex.none, StatIndex.none);
  }

  /// 名前
  String get displayName {
    switch (PokeDB().language) {
      case Language.english:
        return _displayNameEn;
      case Language.japanese:
      default:
        return _displayName;
    }
  }

  /// ABCDSそれぞれのステータスに対するせいかく補正値をリストにして返す
  static List<double> getTemperBias(Temper temper) {
    var ret = [1.0, 1.0, 1.0, 1.0, 1.0]; // A, B, C, D, S
    if (StatIndex.H.index < temper.increasedStat.index &&
        temper.increasedStat.index < StatIndex.size.index) {
      ret[temper.increasedStat.index - 1] = 1.1;
    }
    if (StatIndex.H.index < temper.decreasedStat.index &&
        temper.decreasedStat.index < StatIndex.size.index) {
      ret[temper.decreasedStat.index - 1] = 0.9;
    }

    return ret;
  }
}

/// タマゴグループを管理するclass
class EggGroup {
  final int id;
  final String displayName;

  const EggGroup(this.id, this.displayName);
}

/// 効果
class AbilityEffect {
  const AbilityEffect(this.id);

  final int id;
}

/// 登録しているポケモン・パーティの作成者
enum Owner {
  /// 自身
  mine,

  /// 対戦から(対戦相手が作成)
  fromBattle,

  /// 非表示
  hidden,
}

Owner toOwner(int idx) {
  switch (idx) {
    case 0:
      return Owner.mine;
    case 1:
      return Owner.fromBattle;
    case 2:
    default:
      return Owner.hidden;
  }
}

/// 表示言語
enum Language {
  /// 日本語
  japanese,

  /// 英語
  english,
}

// シングルトンクラス
// 欠点があるからライブラリを使うべき？ https://zenn.dev/shinkano/articles/c0f392fc3d218c
class PokeDB {
  static const String pokeApiRoute = "https://pokeapi.co/api/v2";

  // 設定等を保存する(端末の)ファイル
  late final File _saveDataFile;
  List<Owner> pokemonsOwnerFilter = [Owner.mine];
  List<int> pokemonsNoFilter = [];
  List<PokeType> pokemonsTypeFilter =
      PokeType.values.sublist(1, PokeType.stellar.index);
  List<PokeType> pokemonsTeraTypeFilter = PokeType.values.sublist(1);
  List<int> pokemonsMoveFilter = [];
  List<int> pokemonsSexFilter = [for (var sex in Sex.values) sex.id];
  List<int> pokemonsAbilityFilter = [];
  List<int> pokemonsTemperFilter = [];
  PokemonSort? pokemonsSort;

  List<Owner> partiesOwnerFilter = [Owner.mine];
  int partiesWinRateMinFilter = 0;
  int partiesWinRateMaxFilter = 100;
  List<int> partiesPokemonNoFilter = [];
  PartySort? partiesSort;

  List<int> battlesWinFilter = [
    for (int i = 1; i < 4; i++) i
  ]; // 1: 勝敗未決 2:勝ち 3:負け
  List<int> battlesPartyIDFilter = [];
  BattleSort? battlesSort;

  /// チュートリアルの段階(マイナス値は終了済み)
  int tutorialStep = 0;

  /// 対戦入力画面の相手わざの表示順
  /// * 0:ダメージ大きい順
  /// * 1:採用率高い順
  int battleOwnMoveSort = 0;
  int battleOpponentMoveSort = 0;

  Map<int, Ability> abilities = {0: Ability.none()}; // 無効なとくせい
  late Database abilityDb;
  Map<int, String> _abilityFlavors = {0: ''}; // 無効なとくせい
  Map<int, String> _abilityEnglishFlavors = {0: ''}; // 無効なとくせい
  late Database abilityFlavorDb;
  Map<int, Temper> tempers = {0: Temper.none()}; // 無効なせいかく
  late Database temperDb;
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
  late Database itemDb;
  Map<int, String> _itemFlavors = {0: ''}; // 無効なもちもの
  Map<int, String> _itemEnglishFlavors = {0: ''}; // 無効なもちもの
  late Database itemFlavorDb;
  Map<int, Move> moves = {0: Move.none()}; // 無効なわざ
  late Database moveDb;
  Map<int, String> _moveFlavors = {0: ''}; // 無効なわざ
  Map<int, String> _moveEnglishFlavors = {0: ''}; // 無効なわざ
  late Database moveFlavorDb;
  List<PokeType> types = PokeType.values.sublist(1, 19);
  List<PokeType> teraTypes = PokeType.values.sublist(1, PokeType.values.length);
  Map<int, EggGroup> eggGroups = {0: EggGroup(0, '')}; // 無効なタマゴグループ
  late Database eggGroupDb;
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
  late Database pokeBaseDb;
  Map<int, Pokemon> pokemons = {0: Pokemon()};
  late Database myPokemonDb;
  Map<int, Party> parties = {0: Party()};
  late Database partyDb;
  Map<int, Battle> battles = {0: Battle()};
  late Database battleDb;

  /// インターネットに接続してポケモンの画像を取得するか
  bool getPokeAPI = true;

  /// 表示言語
  Language language = Language.japanese;

  /// テストモード
  bool _isTestMode = false;

  /// 広告を表示するかどうか
  bool showAd = true;

  /// 事前準備したデータを使うかどうか
  bool replacePrepared = false;

  /// 読み込みが完了したか
  bool isLoaded = false;

  /// コンストラクタ（private）
  PokeDB._internal();

  /// 唯一のインスタンス
  static final PokeDB instance = PokeDB._internal();

  /// 唯一のインスタンスを返す
  factory PokeDB() => instance;

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

  Future<void> initialize(Locale locale) async {
    /////////// 各種設定
    String localPath = '';
    if (kIsWeb) {
      // Web appでは一旦各種設定の保存はできないこととする
      //localPath = 'assets/data';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      localPath = directory.path;
      _saveDataFile = File('$localPath/poke_reco.json');
      String configText;
      dynamic configJson;
      bool continueToLoad = true;
      try {
        configText = await _saveDataFile.readAsString();
        configJson = jsonDecode(configText);
      } catch (e) {
        pokemonsOwnerFilter = [Owner.mine];
        pokemonsNoFilter = [];
        pokemonsTypeFilter = PokeType.values.sublist(1, PokeType.stellar.index);
        pokemonsTeraTypeFilter = PokeType.values.sublist(1);
        pokemonsMoveFilter = [];
        pokemonsSexFilter = [for (var sex in Sex.values) sex.id];
        pokemonsAbilityFilter = [];
        pokemonsTemperFilter = [];
        pokemonsSort = null;
        partiesOwnerFilter = [Owner.mine];
        partiesWinRateMinFilter = 0;
        partiesWinRateMaxFilter = 100;
        partiesPokemonNoFilter = [];
        partiesSort = null;
        battlesWinFilter = [for (int i = 1; i < 4; i++) i];
        battlesPartyIDFilter = [];
        battlesSort = null;
        getPokeAPI = true;
        tutorialStep = 0;
        battleOwnMoveSort = 0;
        battleOpponentMoveSort = 0;
        await saveConfig();
        continueToLoad = false;
      }
      if (continueToLoad) {
        try {
          pokemonsOwnerFilter = [];
          for (final e in configJson[configKeyPokemonsOwnerFilter]) {
            switch (e) {
              case 0:
                pokemonsOwnerFilter.add(Owner.mine);
                break;
              case 1:
                pokemonsOwnerFilter.add(Owner.fromBattle);
                break;
              case 2:
              default:
                pokemonsOwnerFilter.add(Owner.hidden);
                break;
            }
          }
        } catch (e) {
          pokemonsOwnerFilter = [Owner.mine];
        }
        try {
          pokemonsNoFilter = [];
          for (final e in configJson[configKeyPokemonsNoFilter]) {
            pokemonsNoFilter.add(e as int);
          }
        } catch (e) {
          pokemonsNoFilter = [];
        }
        try {
          pokemonsTypeFilter = [];
          for (final e in configJson[configKeyPokemonsTypeFilter]) {
            pokemonsTypeFilter.add(PokeType.values[e as int]);
          }
        } catch (e) {
          pokemonsTypeFilter =
              PokeType.values.sublist(1, PokeType.stellar.index);
        }
        try {
          pokemonsTeraTypeFilter = [];
          for (final e in configJson[configKeyPokemonsTeraTypeFilter]) {
            pokemonsTeraTypeFilter.add(PokeType.values[e as int]);
          }
        } catch (e) {
          pokemonsTeraTypeFilter = PokeType.values.sublist(1);
        }
        try {
          pokemonsMoveFilter = [];
          for (final e in configJson[configKeyPokemonsMoveFilter]) {
            pokemonsMoveFilter.add(e as int);
          }
        } catch (e) {
          pokemonsMoveFilter = [];
        }
        try {
          pokemonsSexFilter = [];
          for (final e in configJson[configKeyPokemonsSexFilter]) {
            pokemonsSexFilter.add(e as int);
          }
        } catch (e) {
          pokemonsSexFilter = [for (var sex in Sex.values) sex.id];
        }
        try {
          pokemonsAbilityFilter = [];
          for (final e in configJson[configKeyPokemonsAbilityFilter]) {
            pokemonsAbilityFilter.add(e as int);
          }
        } catch (e) {
          pokemonsAbilityFilter = [];
        }
        try {
          pokemonsTemperFilter = [];
          for (final e in configJson[configKeyPokemonsTemperFilter]) {
            pokemonsTemperFilter.add(e as int);
          }
        } catch (e) {
          pokemonsTemperFilter = [];
        }
        try {
          int sort = configJson[configKeyPokemonsSort] as int;
          pokemonsSort = sort == 0 ? null : PokemonSort.createFromId(sort);
        } catch (e) {
          pokemonsSort = null;
        }

        try {
          partiesOwnerFilter = [];
          for (final e in configJson[configKeyPartiesOwnerFilter]) {
            switch (e) {
              case 0:
                partiesOwnerFilter.add(Owner.mine);
                break;
              case 1:
                partiesOwnerFilter.add(Owner.fromBattle);
                break;
              case 2:
              default:
                partiesOwnerFilter.add(Owner.hidden);
                break;
            }
          }
        } catch (e) {
          partiesOwnerFilter = [Owner.mine];
        }
        try {
          partiesWinRateMinFilter =
              configJson[configKeyPartiesWinRateMinFilter] as int;
        } catch (e) {
          partiesWinRateMinFilter = 0;
        }
        try {
          partiesWinRateMaxFilter =
              configJson[configKeyPartiesWinRateMaxFilter] as int;
        } catch (e) {
          partiesWinRateMaxFilter = 100;
        }
        try {
          partiesPokemonNoFilter = [];
          for (final e in configJson[configKeyPartiesPokemonNoFilter]) {
            partiesPokemonNoFilter.add(e as int);
          }
        } catch (e) {
          partiesPokemonNoFilter = [];
        }
        try {
          int sort = configJson[configKeyPartiesSort] as int;
          partiesSort = sort == 0 ? null : PartySort.createFromId(sort);
        } catch (e) {
          partiesSort = null;
        }

        try {
          battlesWinFilter = [];
          for (final e in configJson[configKeyBattlesWinFilter]) {
            battlesWinFilter.add(e as int);
          }
        } catch (e) {
          battlesWinFilter = [for (int i = 1; i < 4; i++) i];
        }
        try {
          battlesPartyIDFilter = [];
          for (final e in configJson[configKeyBattlesPartyIDFilter]) {
            battlesPartyIDFilter.add(e as int);
          }
        } catch (e) {
          battlesPartyIDFilter = [];
        }
        try {
          int sort = configJson[configKeyBattlesSort] as int;
          battlesSort = sort == 0 ? null : BattleSort.createFromId(sort);
        } catch (e) {
          battlesSort = null;
        }
        try {
          getPokeAPI = (configJson[configKeyGetNetworkImage] as int) != 0;
        } catch (e) {
          getPokeAPI = true;
        }
        try {
          tutorialStep = configJson[configKeyTutorialStep] as int;
        } catch (e) {
          tutorialStep = 0;
        }
        try {
          battleOwnMoveSort = configJson[configKeyBattleOwnMoveSort] as int;
        } catch (e) {
          battleOwnMoveSort = 0;
        }
        try {
          battleOpponentMoveSort =
              configJson[configKeyBattleOpponentMoveSort] as int;
        } catch (e) {
          battleOpponentMoveSort = 0;
        }
      }
      switch (locale.languageCode) {
        case 'ja':
          language = Language.japanese;
          break;
        case 'en':
        default:
          language = Language.english;
          break;
      }
    }

    if (kIsWeb) {
      // Webも含めてのsqflite Database準備
      databaseFactory = databaseFactoryFfiWeb;
    }

    /////////// とくせい
    abilityDb = await openAssetDatabase(abilityDBFile);
    // 内部データに変換
    List<Map<String, dynamic>> maps = await abilityDb.query(
      abilityDBTable,
      columns: [
        abilityColumnId,
        abilityColumnName,
        abilityColumnEnglishName,
        abilityColumnTiming,
        abilityColumnTarget
      ],
    );
    for (var map in maps) {
      abilities[map[abilityColumnId]] = Ability(
        map[abilityColumnId],
        map[abilityColumnName],
        map[abilityColumnEnglishName],
        Timing.values[map[abilityColumnTiming]],
        Target.values[map[abilityColumnTarget]],
      );
    }

    //////////// とくせいの説明
    abilityFlavorDb = await openAssetDatabase(abilityFlavorDBFile);
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
    temperDb = await openAssetDatabase(temperDBFile);
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
        StatIndex.values[(map[temperColumnDe] as int) - 1],
        StatIndex.values[(map[temperColumnIn] as int) - 1],
      );
    }

    //////////// タマゴグループ
    eggGroupDb = await openAssetDatabase(eggGroupDBFile);
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
    itemDb = await openAssetDatabase(itemDBFile);
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
    itemFlavorDb = await openAssetDatabase(itemFlavorDBFile);
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
    moveDb = await openAssetDatabase(moveDBFile);
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
    moveFlavorDb = await openAssetDatabase(moveFlavorDBFile);
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
    pokeBaseDb = await openAssetDatabase(pokeBaseDBFile);
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

    //////////// 登録したポケモン
    final myPokemonDBPath = join(await getDatabasesPath(),
        _isTestMode ? myPokemonTestDBFile : myPokemonDBFile);
    if (_isTestMode) {
      await deleteDatabase(myPokemonDBPath);
    }
    var exists = await databaseExists(myPokemonDBPath);

    if (!exists) {
      if (!kIsWeb) {
        try {
          await Directory(dirname(myPokemonDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createMyPokemonDB();
    } else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath);
      // バージョン間のデータ構造差異を埋める
      await _fillMyPokemonVersionDiff(myPokemonDb);
      // 内部データに変換
      maps = await myPokemonDb.query(
        _isTestMode ? myPokemonTestDBTable : myPokemonDBTable,
        columns: [
          myPokemonColumnId,
          myPokemonColumnViewOrder,
          myPokemonColumnNo,
          myPokemonColumnNickName,
          myPokemonColumnTeraType,
          myPokemonColumnLevel,
          myPokemonColumnSex,
          myPokemonColumnTemper,
          myPokemonColumnAbility,
          myPokemonColumnItem,
          for (var e in myPokemonColumnIndividual) e,
          for (var e in myPokemonColumnEffort) e,
          myPokemonColumnMove1,
          myPokemonColumnPP1,
          myPokemonColumnMove2,
          myPokemonColumnPP2,
          myPokemonColumnMove3,
          myPokemonColumnPP3,
          myPokemonColumnMove4,
          myPokemonColumnPP4,
          myPokemonColumnOwnerID,
        ],
      );

      for (var map in maps) {
        var pokemon = Pokemon.createFromDBMap(map);
        pokemons[pokemon.id] = pokemon;
        print(
            'Pokemon(${pokemon.id}, ${pokemon.viewOrder}, ${pokemon.no}, "${pokemon.nickname}", PokeType.${pokemon.teraType.displayName}, ${pokemon.level}, Sex.${pokemon.sex.displayName}, Temper.${pokemon.temper.displayName}, ${pokemon.ability.id}, 0, [${pokemon.h.indi}, ${pokemon.h.effort}], [${pokemon.a.indi}, ${pokemon.a.effort}], [${pokemon.b.indi}, ${pokemon.b.effort}], [${pokemon.c.indi}, ${pokemon.c.effort}], [${pokemon.d.indi}, ${pokemon.d.effort}], [${pokemon.s.indi}, ${pokemon.s.effort}], [${pokemon.move1.id}, ${pokemon.move2?.id}, ${pokemon.move3?.id}, ${pokemon.move4?.id}], [${pokemon.pp1}, ${pokemon.pp2}, ${pokemon.pp3}, ${pokemon.pp4}], Owner.mine).toSet(),');
      }
    }

    //////////// 登録したパーティ
    final partyDBPath = join(
        await getDatabasesPath(), _isTestMode ? partyTestDBFile : partyDBFile);
    if (_isTestMode) {
      await deleteDatabase(partyDBPath);
    }
    exists = await databaseExists(partyDBPath);

    if (!exists) {
      if (!kIsWeb) {
        try {
          await Directory(dirname(partyDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createPartyDB();
    } else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath);
      // バージョン間のデータ構造差異を埋める
      await _fillPartyVersionDiff(myPokemonDb);
      // 内部データに変換
      maps = await partyDb.query(
        _isTestMode ? partyTestDBTable : partyDBTable,
        columns: [
          partyColumnId,
          partyColumnViewOrder,
          partyColumnName,
          partyColumnPokemonId1,
          partyColumnPokemonItem1,
          partyColumnPokemonId2,
          partyColumnPokemonItem2,
          partyColumnPokemonId3,
          partyColumnPokemonItem3,
          partyColumnPokemonId4,
          partyColumnPokemonItem4,
          partyColumnPokemonId5,
          partyColumnPokemonItem5,
          partyColumnPokemonId6,
          partyColumnPokemonItem6,
          partyColumnOwnerID,
        ],
      );

      for (var map in maps) {
        var party = Party.createFromDBMap(map);
        parties[party.id] = party;
        print(
            'Party(${party.id}, ${party.viewOrder}, "${party.name}", ${party.pokemons[0]?.id}, ${party.items[0]?.id}, ${party.pokemons[1]?.id}, ${party.items[1]?.id}, ${party.pokemons[2]?.id}, ${party.items[2]?.id}, ${party.pokemons[3]?.id}, ${party.items[3]?.id}, ${party.pokemons[4]?.id}, ${party.items[4]?.id}, ${party.pokemons[5]?.id}, ${party.items[5]?.id}, Owner.mine).toSet(),');
      }
    }

    //////////// 登録した対戦
    final battleDBPath = join(await getDatabasesPath(),
        _isTestMode ? battleTestDBFile : battleDBFile);
    if (_isTestMode) {
      await deleteDatabase(battleDBPath);
    }
    exists = await databaseExists(battleDBPath);

    if (!exists) {
      if (!kIsWeb) {
        try {
          await Directory(dirname(battleDBPath)).create(recursive: true);
        } catch (_) {}
      }

      await _createBattleDB();
    } else {
      print("Opening existing database");

      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath);
      // バージョン間のデータ構造差異を埋める
      await _fillBattleVersionDiff(myPokemonDb);
      // 内部データに変換
      maps = await battleDb.query(
        _isTestMode ? battleTestDBTable : battleDBTable,
        columns: [
          battleColumnId,
          battleColumnViewOrder,
          battleColumnName,
          battleColumnTypeId,
          battleColumnDate,
          battleColumnOwnPartyId,
          battleColumnOpponentName,
          battleColumnOpponentPartyId,
          battleColumnTurns,
          battleColumnIsMyWin,
          battleColumnIsYourWin,
        ],
      );

      for (var map in maps) {
        var battle = Battle.createFromDBMap(map);
        battles[battle.id] = battle;
      }
    }

    // デバッグ時のみ
    if (kDebugMode || _isTestMode) {
      // 用意しているポケモンデータベースに置き換える
      if (replacePrepared || _isTestMode) {
        final preparedDb = await openAssetDatabase(preparedDBFile);
        ///////// 登録したポケモン
        {
          // 内部データに変換
          maps = await preparedDb.query(
            preparedMyPokemonDBTable,
            columns: [
              myPokemonColumnId,
              myPokemonColumnViewOrder,
              myPokemonColumnNo,
              myPokemonColumnNickName,
              myPokemonColumnTeraType,
              myPokemonColumnLevel,
              myPokemonColumnSex,
              myPokemonColumnTemper,
              myPokemonColumnAbility,
              myPokemonColumnItem,
              for (var e in myPokemonColumnIndividual) e,
              for (var e in myPokemonColumnEffort) e,
              myPokemonColumnMove1,
              myPokemonColumnPP1,
              myPokemonColumnMove2,
              myPokemonColumnPP2,
              myPokemonColumnMove3,
              myPokemonColumnPP3,
              myPokemonColumnMove4,
              myPokemonColumnPP4,
              myPokemonColumnOwnerID,
            ],
          );

          pokemons = {0: Pokemon()};
          for (var map in maps) {
            var pokemon = Pokemon.createFromDBMap(map);
            pokemons[pokemon.id] = pokemon;
          }

          await deleteDatabase(myPokemonDBPath);
          await _createMyPokemonDB();
          for (final pokemon in pokemons.values) {
            addMyPokemon(pokemon, false, () {});
          }
        }

        ///////// 登録したパーティ
        {
          // 内部データに変換
          maps = await preparedDb.query(
            preparedPartyDBTable,
            columns: [
              partyColumnId,
              partyColumnViewOrder,
              partyColumnName,
              partyColumnPokemonId1,
              partyColumnPokemonItem1,
              partyColumnPokemonId2,
              partyColumnPokemonItem2,
              partyColumnPokemonId3,
              partyColumnPokemonItem3,
              partyColumnPokemonId4,
              partyColumnPokemonItem4,
              partyColumnPokemonId5,
              partyColumnPokemonItem5,
              partyColumnPokemonId6,
              partyColumnPokemonItem6,
              partyColumnOwnerID,
            ],
          );

          parties = {0: Party()};
          for (var map in maps) {
            var party = Party.createFromDBMap(map);
            parties[party.id] = party;
          }

          await deleteDatabase(partyDBPath);
          await _createPartyDB();
          for (final party in parties.values) {
            addParty(party, false, () {});
          }
        }

        ///////// 登録した対戦
        {
          await deleteDatabase(battleDBPath);
        }
      }
    }

    // 各パーティの勝率算出
    updatePartyWinRate();

    isLoaded = true;
  }

  void updatePartyWinRate() {
    for (final party in parties.values) {
      party.usedCount = 0;
      party.winCount = 0;
    }
    for (final battle in battles.values) {
      int partyID = battle.getParty(PlayerType.me).id;
      parties[partyID]!.usedCount++;
      if (battle.isMyWin) parties[partyID]!.winCount++;
    }
    for (final party in parties.values) {
      if (party.usedCount == 0) {
        party.winRate = 0;
      } else {
        party.winRate = (party.winCount / party.usedCount * 100).floor();
      }
    }
  }

  Future<void> saveConfig() async {
    String jsonText = jsonEncode({
      configKeyPokemonsOwnerFilter: [
        for (final e in pokemonsOwnerFilter) e.index
      ],
      configKeyPokemonsNoFilter: [for (final e in pokemonsNoFilter) e],
      configKeyPokemonsTypeFilter: [
        for (final e in pokemonsTypeFilter) e.index
      ],
      configKeyPokemonsTeraTypeFilter: [
        for (final e in pokemonsTeraTypeFilter) e.index
      ],
      configKeyPokemonsMoveFilter: [for (final e in pokemonsMoveFilter) e],
      configKeyPokemonsSexFilter: [for (final e in pokemonsSexFilter) e],
      configKeyPokemonsAbilityFilter: [
        for (final e in pokemonsAbilityFilter) e
      ],
      configKeyPokemonsTemperFilter: [for (final e in pokemonsTemperFilter) e],
      configKeyPokemonsSort: pokemonsSort == null ? 0 : pokemonsSort!.id,
      configKeyPartiesOwnerFilter: [
        for (final e in partiesOwnerFilter) e.index
      ],
      configKeyPartiesWinRateMinFilter: partiesWinRateMinFilter,
      configKeyPartiesWinRateMaxFilter: partiesWinRateMaxFilter,
      configKeyPartiesPokemonNoFilter: [
        for (final e in partiesPokemonNoFilter) e
      ],
      configKeyPartiesSort: partiesSort == null ? 0 : partiesSort!.id,
      configKeyBattlesWinFilter: battlesWinFilter,
      configKeyBattlesPartyIDFilter: battlesPartyIDFilter,
      configKeyBattlesSort: battlesSort == null ? 0 : battlesSort!.id,
      configKeyGetNetworkImage: getPokeAPI ? 1 : 0,
      configKeyLanguage: language.index,
      configKeyTutorialStep: tutorialStep,
      configKeyBattleOwnMoveSort: battleOwnMoveSort,
      configKeyBattleOpponentMoveSort: battleOpponentMoveSort,
    });
    await _saveDataFile.writeAsString(jsonText);
  }

  String? getAbilityFlavor(int abilityId) {
    switch (language) {
      case Language.english:
        return _abilityEnglishFlavors[abilityId];
      case Language.japanese:
      default:
        return _abilityFlavors[abilityId];
    }
  }

  String? getItemFlavor(int itemId) {
    switch (language) {
      case Language.english:
        return _itemEnglishFlavors[itemId];
      case Language.japanese:
      default:
        return _itemFlavors[itemId];
    }
  }

  String? getMoveFlavor(int moveId) {
    switch (language) {
      case Language.english:
        return _moveEnglishFlavors[moveId];
      case Language.japanese:
      default:
        return _moveFlavors[moveId];
    }
  }

  int _getUniqueID(List<int> ids) {
    int ret = 1;
    ids.sort((a, b) => a.compareTo(b));
    assert(ids.last < 0xffffffff);
    /*for (final e in ids) {
      if (e > ret) break;
      ret++;
    }*/
    if (ids.isNotEmpty) ret = ids.last + 1;
    return ret;
  }

  int _getUniqueMyPokemonID() {
    return _getUniqueID(pokemons.keys.toList());
  }

  int _getUniquePartyID() {
    return _getUniqueID(parties.keys.toList());
  }

  int _getUniqueBattleID() {
    return _getUniqueID(battles.keys.toList());
  }

  Future<void> _deleteUnrefs() async {
    // 各パーティが対戦で参照されているか判定
    Map<int, bool> partyRefs = {};
    for (final e in parties.keys) {
      partyRefs[e] = false;
    }
    for (final e in battles.values) {
      partyRefs[e.getParty(PlayerType.me).id] = true;
      partyRefs[e.getParty(PlayerType.opponent).id] = true;
    }
    // 参照されておらず、削除可なら削除する
    List<int> deleteIDs = [];
    for (final e in partyRefs.entries) {
      if (!e.value &&
          parties.containsKey(e.key) &&
          parties[e.key]!.owner == Owner.hidden) deleteIDs.add(e.key);
    }
    parties.removeWhere((k, v) => deleteIDs.contains(k));
    String whereStr = '$partyColumnId=?';
    for (int i = 1; i < deleteIDs.length; i++) {
      whereStr += ' OR $partyColumnId=?';
    }
    await partyDb.delete(
      _isTestMode ? partyTestDBTable : partyDBTable,
      where: whereStr,
      whereArgs: deleteIDs,
    );
    // 参照している対戦用のフィルタからも削除
    battlesPartyIDFilter.removeWhere((e) => deleteIDs.contains(e));

    // 各ポケモンがパーティで参照されているか判定
    Map<int, bool> myPokemonRefs = {};
    for (final e in pokemons.keys) {
      myPokemonRefs[e] = false;
    }
    for (final e in parties.values) {
      for (int i = 0; i < e.pokemonNum; i++) {
        myPokemonRefs[e.pokemons[i]!.id] = true;
      }
    }
    // 参照されておらず、削除可なら削除する
    deleteIDs = [];
    for (final e in myPokemonRefs.entries) {
      if (!e.value &&
          pokemons.containsKey(e.key) &&
          pokemons[e.key]!.owner == Owner.hidden) deleteIDs.add(e.key);
    }
    pokemons.removeWhere((k, v) => deleteIDs.contains(k));
    whereStr = '$myPokemonColumnId=?';
    for (int i = 1; i < deleteIDs.length; i++) {
      whereStr += ' OR $partyColumnId=?';
    }
    await myPokemonDb.delete(
      _isTestMode ? myPokemonTestDBTable : myPokemonDBTable,
      where: whereStr,
      whereArgs: deleteIDs,
    );
  }

  Future<void> _prepareMyPokemonDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(),
        _isTestMode ? myPokemonTestDBFile : myPokemonDBFile);
    var exists = await databaseExists(myPokemonDBPath);

    if (!exists) {
      // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(myPokemonDBPath)).create(recursive: true);
        } catch (_) {}
      }

      myPokemonDb = await _createMyPokemonDB();
    } else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      myPokemonDb = await openDatabase(myPokemonDBPath);
    }
  }

  Future<void> addMyPokemon(
    Pokemon myPokemon,
    bool createNew,
    void Function() notify,
  ) async {
    await _prepareMyPokemonDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      myPokemon.id = _getUniqueMyPokemonID();
      myPokemon.viewOrder = myPokemon.id;
    }
    pokemons[myPokemon.id] = myPokemon;

    // SQLiteのDBに挿入
    await myPokemonDb.insert(
      _isTestMode ? myPokemonTestDBTable : myPokemonDBTable,
      myPokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 通知
    notify();
  }

  Future<void> updateAllMyPokemonViewOrder() async {
    await _prepareMyPokemonDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$myPokemonColumnId=?';
    for (final e in pokemons.values) {
      await myPokemonDb.update(
        _isTestMode ? myPokemonTestDBTable : myPokemonDBTable,
        {myPokemonColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _fillMyPokemonVersionDiff(Database database) async {
    int v = await database.getVersion();
    if (v != pokeRecoInternalVersion) {
      switch (v) {
        case 1: // バージョンなんて表示する前 -> バージョン1.0.1(内部バージョン2)
          // バージョン変えるだけでいい
          database.setVersion(pokeRecoInternalVersion);
          break;
        default:
          break;
      }
    }
  }

  Future<void> _fillPartyVersionDiff(Database database) async {
    int v = await database.getVersion();
    if (v != pokeRecoInternalVersion) {
      switch (v) {
        case 1: // バージョンなんて表示する前 -> バージョン1.0.1(内部バージョン2)
          // バージョン変えるだけでいい
          database.setVersion(pokeRecoInternalVersion);
          break;
        default:
          break;
      }
    }
  }

  Future<void> _fillBattleVersionDiff(Database database) async {
    int v = await database.getVersion();
    if (v != pokeRecoInternalVersion) {
      switch (v) {
        case 1: // バージョンなんて表示する前 -> バージョン1.0.1(内部バージョン2)
          {
            List<Map<String, dynamic>> maps = await battleDb.query(
              _isTestMode ? battleTestDBTable : battleDBTable,
              columns: [
                battleColumnId,
                battleColumnViewOrder,
                battleColumnName,
                battleColumnTypeId,
                battleColumnDate,
                battleColumnOwnPartyId,
                battleColumnOpponentName,
                battleColumnOpponentPartyId,
                battleColumnTurns,
                battleColumnIsMyWin,
                battleColumnIsYourWin,
              ],
            );
            // 内部データに変換
            maps = await battleDb.query(
              _isTestMode ? battleTestDBTable : battleDBTable,
              columns: [
                battleColumnId,
                battleColumnViewOrder,
                battleColumnName,
                battleColumnTypeId,
                battleColumnDate,
                battleColumnOwnPartyId,
                battleColumnOpponentName,
                battleColumnOpponentPartyId,
                battleColumnTurns,
                battleColumnIsMyWin,
                battleColumnIsYourWin,
              ],
            );

            // 一度過去バージョンで読み込み
            for (var map in maps) {
              var battle = Battle.createFromDBMap(map, version: v);
              // 現バージョンで保存し直す
              await addBattle(battle, false, () {});
            }
            // バージョン変更
            database.setVersion(pokeRecoInternalVersion);
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> deleteMyPokemon(
    List<int> ids,
    void Function() notify,
  ) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(),
        _isTestMode ? myPokemonTestDBFile : myPokemonDBFile);
    assert(await databaseExists(myPokemonDBPath));

    // SQLiteのDB読み込み
    myPokemonDb = await openDatabase(myPokemonDBPath);

    // 削除可フラグを付与
    for (int e in ids) {
      pokemons[e]!.owner = Owner.hidden;
    }

    await _deleteUnrefs();

    // 通知
    notify();
  }

  Future<void> _preparePartyDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(
        await getDatabasesPath(), _isTestMode ? partyTestDBFile : partyDBFile);
    var exists = await databaseExists(partyDBPath);

    if (!exists) {
      // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(partyDBPath)).create(recursive: true);
        } catch (_) {}
      }

      partyDb = await _createPartyDB();
    } else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      partyDb = await openDatabase(partyDBPath);
    }
  }

  Future<void> addParty(
    Party party,
    bool createNew,
    void Function() notify,
  ) async {
    await _preparePartyDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      party.id = _getUniquePartyID();
      party.viewOrder = party.id;
    }
    parties[party.id] = party;

    // SQLiteのDBに挿入
    await partyDb.insert(
      _isTestMode ? partyTestDBTable : partyDBTable,
      party.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 通知
    notify();
  }

  Future<void> updateAllPartyViewOrder() async {
    await _preparePartyDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$partyColumnId=?';
    for (final e in parties.values) {
      await partyDb.update(
        _isTestMode ? partyTestDBTable : partyDBTable,
        {partyColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteParty(
    List<int> ids,
    void Function() notify,
  ) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(
        await getDatabasesPath(), _isTestMode ? partyTestDBFile : partyDBFile);
    assert(await databaseExists(partyDBPath));

    // SQLiteのDB読み込み
    partyDb = await openDatabase(partyDBPath);

    // 削除可フラグを付与
    for (int e in ids) {
      parties[e]!.owner = Owner.hidden;
    }

    await _deleteUnrefs();

    // 通知
    notify();
  }

  Future<void> _prepareBattleDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(),
        _isTestMode ? battleTestDBFile : battleDBFile);
    var exists = await databaseExists(battleDBPath);

    if (!exists) {
      // ファイル作成
      print('Creating new copy from asset');

      if (!kIsWeb) {
        try {
          await Directory(dirname(battleDBPath)).create(recursive: true);
        } catch (_) {}
      }

      battleDb = await _createBattleDB();
    } else {
      print("Opening existing database");
      // SQLiteのDB読み込み
      battleDb = await openDatabase(battleDBPath);
    }
  }

  Future<void> addBattle(
    Battle battle,
    bool createNew,
    void Function() notify,
  ) async {
    await _prepareBattleDB();

    // 新規作成なら新たなIDを割り振る
    if (createNew) {
      battle.id = _getUniqueBattleID();
      battle.viewOrder = battle.id;
    }
    battles[battle.id] = battle;

    // パーティの勝率を更新
    updatePartyWinRate();

    // SQLiteのDBに挿入
    await battleDb.insert(
      _isTestMode ? battleTestDBTable : battleDBTable,
      battle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // 通知
    notify();
  }

  Future<void> updateAllBattleViewOrder() async {
    await _prepareBattleDB();

    // SQLiteのDBを更新
    // TODO: for文なしで一文でできないかな？
    String whereStr = '$battleColumnId=?';
    for (final e in battles.values) {
      await battleDb.update(
        _isTestMode ? battleTestDBTable : battleDBTable,
        {battleColumnViewOrder: e.viewOrder},
        where: whereStr,
        whereArgs: [e.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteBattle(
    List<int> ids,
    void Function() notify,
  ) async {
    if (ids.isEmpty) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(),
        _isTestMode ? battleTestDBFile : battleDBFile);
    assert(await databaseExists(battleDBPath));

    // SQLiteのDB読み込み
    battleDb = await openDatabase(battleDBPath);

    // 登録対戦リストから削除
    battles.removeWhere((k, v) => ids.contains(k));

    String whereStr = '$battleColumnId=?';
    for (int i = 1; i < ids.length; i++) {
      whereStr += ' OR $battleColumnId=?';
    }
    // SQLiteのDBから削除
    await battleDb.delete(
      _isTestMode ? battleTestDBTable : battleDBTable,
      where: whereStr,
      whereArgs: ids,
    );

    _deleteUnrefs();
    // パーティの勝率を更新
    updatePartyWinRate();
    // 通知
    notify();
  }

  Future<Database> _createMyPokemonDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final myPokemonDBPath = join(await getDatabasesPath(),
        _isTestMode ? myPokemonTestDBFile : myPokemonDBFile);
    var text =
        'CREATE TABLE ${_isTestMode ? myPokemonTestDBTable : myPokemonDBTable}('
        '$myPokemonColumnId INTEGER PRIMARY KEY, '
        '$myPokemonColumnViewOrder INTEGER, '
        '$myPokemonColumnNo INTEGER, '
        '$myPokemonColumnNickName TEXT, '
        '$myPokemonColumnTeraType INTEGER, '
        '$myPokemonColumnLevel INTEGER, '
        '$myPokemonColumnSex INTEGER, '
        '$myPokemonColumnTemper INTEGER, '
        '$myPokemonColumnAbility INTEGER, '
        '$myPokemonColumnItem INTEGER, '
        '${myPokemonColumnIndividual[0]} INTEGER, '
        '${myPokemonColumnIndividual[1]} INTEGER, '
        '${myPokemonColumnIndividual[2]} INTEGER, '
        '${myPokemonColumnIndividual[3]} INTEGER, '
        '${myPokemonColumnIndividual[4]} INTEGER, '
        '${myPokemonColumnIndividual[5]} INTEGER, '
        '${myPokemonColumnEffort[0]} INTEGER, '
        '${myPokemonColumnEffort[1]} INTEGER, '
        '${myPokemonColumnEffort[2]} INTEGER, '
        '${myPokemonColumnEffort[3]} INTEGER, '
        '${myPokemonColumnEffort[4]} INTEGER, '
        '${myPokemonColumnEffort[5]} INTEGER, '
        '$myPokemonColumnMove1 INTEGER, '
        '$myPokemonColumnPP1 INTEGER, '
        '$myPokemonColumnMove2 INTEGER, '
        '$myPokemonColumnPP2 INTEGER, '
        '$myPokemonColumnMove3 INTEGER, '
        '$myPokemonColumnPP3 INTEGER, '
        '$myPokemonColumnMove4 INTEGER, '
        '$myPokemonColumnPP4 INTEGER, '
        '$myPokemonColumnOwnerID INTEGER)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        myPokemonDBPath,
        options: OpenDatabaseOptions(
            version: pokeRecoInternalVersion,
            onCreate: (db, version) {
              return db.execute(text);
            }),
      );
    } else {
      return openDatabase(myPokemonDBPath, version: pokeRecoInternalVersion,
          onCreate: (db, version) {
        return db.execute(text);
      });
    }
  }

  Future<Database> _createPartyDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final partyDBPath = join(
        await getDatabasesPath(), _isTestMode ? partyTestDBFile : partyDBFile);
    var text = 'CREATE TABLE ${_isTestMode ? partyTestDBTable : partyDBTable}('
        '$partyColumnId INTEGER PRIMARY KEY, '
        '$partyColumnViewOrder INTEGER, '
        '$partyColumnName TEXT, '
        '$partyColumnPokemonId1 INTEGER, '
        '$partyColumnPokemonItem1 INTEGER, '
        '$partyColumnPokemonId2 INTEGER, '
        '$partyColumnPokemonItem2 INTEGER, '
        '$partyColumnPokemonId3 INTEGER, '
        '$partyColumnPokemonItem3 INTEGER, '
        '$partyColumnPokemonId4 INTEGER, '
        '$partyColumnPokemonItem4 INTEGER, '
        '$partyColumnPokemonId5 INTEGER, '
        '$partyColumnPokemonItem5 INTEGER, '
        '$partyColumnPokemonId6 INTEGER, '
        '$partyColumnPokemonItem6 INTEGER, '
        '$partyColumnOwnerID INTEGER)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        partyDBPath,
        options: OpenDatabaseOptions(
            version: pokeRecoInternalVersion,
            onCreate: (db, version) {
              return db.execute(text);
            }),
      );
    } else {
      return openDatabase(partyDBPath, version: pokeRecoInternalVersion,
          onCreate: (db, version) {
        return db.execute(text);
      });
    }
  }

  Future<Database> _createBattleDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final battleDBPath = join(await getDatabasesPath(),
        _isTestMode ? battleTestDBFile : battleDBFile);
    var text =
        'CREATE TABLE ${_isTestMode ? battleTestDBTable : battleDBTable}('
        '$battleColumnId INTEGER PRIMARY KEY, '
        '$battleColumnViewOrder INTEGER, '
        '$battleColumnName TEXT, '
        '$battleColumnTypeId INTEGER, '
        '$battleColumnDate TEXT, '
        '$battleColumnOwnPartyId INTEGER, '
        '$battleColumnOpponentName TEXT, '
        '$battleColumnOpponentPartyId INTEGER, '
        '$battleColumnTurns TEXT, '
        '$battleColumnIsMyWin INTEGER, '
        '$battleColumnIsYourWin INTEGER)';

    // SQLiteのDB作成
    if (kIsWeb) {
      return databaseFactoryFfiWeb.openDatabase(
        battleDBPath,
        options: OpenDatabaseOptions(
            version: pokeRecoInternalVersion,
            onCreate: (db, version) {
              return db.execute(text);
            }),
      );
    } else {
      return openDatabase(battleDBPath, version: pokeRecoInternalVersion,
          onCreate: (db, version) {
        return db.execute(text);
      });
    }
  }

  void setTestMode() {
    _isTestMode = true;
    showAd = false;
  }
}
