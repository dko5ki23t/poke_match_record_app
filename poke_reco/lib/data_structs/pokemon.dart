import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/tool.dart';

/// 各ポケモンの個体を管理するclass
class Pokemon extends Equatable implements Copyable {
  /// データベースのプライマリーキー
  int id = 0;

  /// 表示順
  int viewOrder = 0;

  /// ポケモン名(日本語)
  String _name = '';

  /// ポケモン名(英語)
  String _nameEn = '';

  /// ニックネーム
  String nickname = '';

  /// レベル
  int level = 50;

  /// せいべつ
  Sex sex = Sex.none;

  /// 図鑑No
  int _no = 0;

  /// タイプ1
  PokeType type1 = PokeType.unknown;

  /// タイプ2(null OK)
  PokeType? type2;

  /// テラスタルタイプ
  PokeType teraType = PokeType.unknown;

  /// せいかく
  Nature nature = Nature.none();

  /// 6つのステータス[HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ]
  SixStats _stats = SixStats.generateUniformedStat(indi: pokemonMaxIndividual);

  /// とくせい
  Ability ability = Ability.none();

  /// もちもの(null OK)
  Item? item;

  /// 覚えているわざ
  List<Move?> _moves = [Move.none(), null, null, null];

  /// 各わざの最大PP
  List<int?> _pps = [0, null, null, null];

  /// 自分でつくったか、対戦相手が作ったものか
  Owner owner = Owner.mine;

  @override
  List<Object?> get props => [
        id,
        viewOrder,
        _name,
        _nameEn,
        nickname,
        level,
        sex,
        _no,
        type1,
        type2,
        teraType,
        nature,
        _stats,
        ability,
        item,
        _moves,
        _pps,
        owner
      ];

  Pokemon();

  /// Databaseから取得したMapからclassを生成
  /// ```
  /// map: Databaseから取得したMap
  /// ```
  Pokemon.createFromDBMap(Map<String, dynamic> map) {
    var pokeData = PokeDB();
    int pokeNo = map[myPokemonColumnNo];
    id = map[myPokemonColumnId];
    viewOrder = map[myPokemonColumnViewOrder];
    if (pokeData.language == Language.japanese) {
      _name = pokeData.pokeBase[pokeNo]!.name;
      pokeData.language = Language.english;
      _nameEn = pokeData.pokeBase[pokeNo]!.name;
      pokeData.language = Language.japanese;
    } else if (pokeData.language == Language.english) {
      _nameEn = pokeData.pokeBase[pokeNo]!.name;
      pokeData.language = Language.japanese;
      _name = pokeData.pokeBase[pokeNo]!.name;
      pokeData.language = Language.english;
    }
    nickname = map[myPokemonColumnNickName];
    level = map[myPokemonColumnLevel];
    sex = Sex.createFromId(map[myPokemonColumnSex]);
    _no = pokeNo;
    type1 = pokeData.pokeBase[pokeNo]!.type1;
    type2 = pokeData.pokeBase[pokeNo]!.type2;
    teraType = PokeType.values[map[myPokemonColumnTeraType]];
    nature = pokeData.natures[map[myPokemonColumnNature]]!;
    // 実数値はあとでまとめて更新
    _stats.h.set(pokeData.pokeBase[pokeNo]!.h,
        map[myPokemonColumnIndividual[0]], map[myPokemonColumnEffort[0]], 0);
    _stats.a.set(pokeData.pokeBase[pokeNo]!.a,
        map[myPokemonColumnIndividual[1]], map[myPokemonColumnEffort[1]], 0);
    _stats.b.set(pokeData.pokeBase[pokeNo]!.b,
        map[myPokemonColumnIndividual[2]], map[myPokemonColumnEffort[2]], 0);
    _stats.c.set(pokeData.pokeBase[pokeNo]!.c,
        map[myPokemonColumnIndividual[3]], map[myPokemonColumnEffort[3]], 0);
    _stats.d.set(pokeData.pokeBase[pokeNo]!.d,
        map[myPokemonColumnIndividual[4]], map[myPokemonColumnEffort[4]], 0);
    _stats.s.set(pokeData.pokeBase[pokeNo]!.s,
        map[myPokemonColumnIndividual[5]], map[myPokemonColumnEffort[5]], 0);
    ability = pokeData.abilities[map[myPokemonColumnAbility]]!;
    item = (map[myPokemonColumnItem] != null)
        ? pokeData.items[map[myPokemonColumnItem]]
        : null;
    move1 = pokeData.moves[map[myPokemonColumnMove1]]!;
    pp1 = map[myPokemonColumnPP1];
    move2 = map[myPokemonColumnMove2] != null
        ? pokeData.moves[map[myPokemonColumnMove2]]!
        : null;
    pp2 = map[myPokemonColumnPP2];
    move3 = map[myPokemonColumnMove3] != null
        ? pokeData.moves[map[myPokemonColumnMove3]]!
        : null;
    pp3 = map[myPokemonColumnPP3];
    move4 = map[myPokemonColumnMove4] != null
        ? pokeData.moves[map[myPokemonColumnMove4]]!
        : null;
    pp4 = map[myPokemonColumnPP4];
    owner = toOwner(map[myPokemonColumnOwnerID]);
    updateRealStats();
  }

  /// 図鑑Noを基に基本的な情報をセットする
  /// 基本的な情報＝No,名前,タイプ1・2,[せいべつ,とくせい]
  /// ```
  /// number: 図鑑No
  /// setDefaultSex: 適当にせいべつをセットするかどうか
  /// setDefaultAbility: 適当にとくせいをセットするかどうか
  /// ```
  void setBasicInfoFromNo(
    int number, {
    bool setDefaultSex = true,
    bool setDefaultAbility = true,
  }) {
    no = number;
    final pokeBase = PokeDB().pokeBase[no]!;
    type1 = pokeBase.type1;
    type2 = pokeBase.type2;
    if (setDefaultSex) {
      sex = pokeBase.sex[0];
    }
    if (setDefaultAbility) {
      ability = pokeBase.ability[0];
    }
  }

  /// ポケモン名
  String get name {
    switch (PokeDB().language) {
      case Language.english:
        return _nameEn;
      case Language.japanese:
      default:
        return _name;
    }
  }

  /// フォーム名等を除いたポケモン名
  String get omittedName {
    return name.split('(')[0];
  }

  /// 図鑑No(変更すると名前も変更する)
  int get no => _no;
  set no(int n) {
    var pokeData = PokeDB();
    _no = n;
    if (pokeData.language == Language.japanese) {
      _name = pokeData.pokeBase[n]!.name;
      pokeData.language = Language.english;
      _nameEn = pokeData.pokeBase[n]!.name;
      pokeData.language = Language.japanese;
    } else if (pokeData.language == Language.english) {
      _nameEn = pokeData.pokeBase[n]!.name;
      pokeData.language = Language.japanese;
      _name = pokeData.pokeBase[n]!.name;
      pokeData.language = Language.english;
    }
  }

  /// HP
  FourParams get h => _stats.h;

  /// こうげき
  FourParams get a => _stats.a;

  /// ぼうぎょ
  FourParams get b => _stats.b;

  /// とくこう
  FourParams get c => _stats.c;

  /// とくぼう
  FourParams get d => _stats.d;

  /// すばやさ
  FourParams get s => _stats.s;

  /// 6つのステータス[HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ]
  SixStats get stats => _stats;

  /// わざ1
  Move get move1 => _moves[0]!;
  set move1(Move x) => _moves[0] = x;

  /// わざ1の最大PP
  int get pp1 => _pps[0]!;
  set pp1(int x) => _pps[0] = x;

  /// わざ2
  Move? get move2 => _moves[1];
  set move2(Move? x) => _moves[1] = x;

  /// わざ2の最大PP
  int? get pp2 => _pps[1];
  set pp2(int? x) => _pps[1] = x;

  /// わざ3
  Move? get move3 => _moves[2];
  set move3(Move? x) => _moves[2] = x;

  /// わざ3の最大PP
  int? get pp3 => _pps[2];
  set pp3(int? x) => _pps[2] = x;

  /// わざ4
  Move? get move4 => _moves[3];
  set move4(Move? x) => _moves[3] = x;

  /// わざ4の最大PP
  int? get pp4 => _pps[3];
  set pp4(int? x) => _pps[3] = x;

  /// 覚えているわざ
  List<Move?> get moves => _moves;

  /// 各わざの最大PP
  List<int?> get pps => _pps;

  /// 覚えているわざの数
  int get moveNum {
    for (int i = 0; i < 4; i++) {
      if (moves[i] == null) return i;
    }
    return 4;
  }

  /// 有効かどうか
  bool get isValid {
    return (name != '' &&
        (level >= pokemonMinLevel && level <= pokemonMaxLevel) &&
        no >= pokemonMinNo &&
        nature.id != 0 &&
        teraType != PokeType.unknown &&
        ability.id != 0 &&
        _moves[0]!.id != 0 &&
        totalEffort <= pokemonMaxEffortTotal);
  }

  /// このポケモンが参照されている数
  bool get refs {
    for (final e in PokeDB().parties.values) {
      for (int i = 0; i < e.pokemonNum; i++) {
        if (e.pokemons[i]!.id == id) return true;
      }
    }
    return false;
  }

  /// 種族値の合計
  int get totalRace => _stats.totalRace;

  /// 努力値の合計
  int get totalEffort => _stats.totalEffort;

  /// TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;

  @override
  Pokemon copy() => Pokemon()
    ..id = id
    ..viewOrder = viewOrder
    .._name = _name
    .._nameEn = _nameEn
    ..nickname = nickname
    ..level = level
    ..sex = sex
    .._no = _no
    ..type1 = type1
    ..type2 = type2
    ..teraType = teraType
    ..nature = nature
    .._stats = _stats.copy()
    ..ability = ability.copy()
    ..item = item?.copy()
    .._moves = [move1.copy(), move2?.copy(), move3?.copy(), move4?.copy()]
    .._pps = [..._pps]
    ..owner = owner;

  /// レベル、種族値、個体値、努力値、せいかくから実数値を更新
  void updateRealStats() {
    for (final stat in _stats.sixParams) {
      stat.updateReal(level, nature);
    }
  }

  /// 実数値から努力値、個体値を更新
  /// ```
  /// statIndex: 更新対象のパラメータ
  /// ```
  void updateStatsRefReal(StatIndex statIndex) {
    int effort = _stats.sixParams[statIndex.index].updateEffort(level, nature);
    // 努力値の変化だけでは実数値が出せない場合は個体値を更新
    if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
      _stats.sixParams[statIndex.index].effort =
          effort.clamp(pokemonMinEffort, pokemonMaxEffort);
      int indi = _stats.sixParams[statIndex.index].updateIndi(level, nature);
      // 努力値・個体値の変化では実数値が出せない場合は実数値を更新
      if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
        _stats.sixParams[statIndex.index].indi =
            indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
        _stats.sixParams[statIndex.index].updateReal(level, nature);
      }
    }
  }

  /// SQLite保存用Mapを返す
  Map<String, dynamic> toMap() {
    return {
      myPokemonColumnId: id,
      myPokemonColumnViewOrder: viewOrder,
      myPokemonColumnNo: no,
      myPokemonColumnNickName: nickname,
      myPokemonColumnTeraType: teraType.index,
      myPokemonColumnLevel: level,
      myPokemonColumnSex: sex.id,
      myPokemonColumnNature: nature.id,
      myPokemonColumnAbility: ability.id,
      myPokemonColumnItem: item?.id,
      myPokemonColumnIndividual[0]: h.indi,
      myPokemonColumnIndividual[1]: a.indi,
      myPokemonColumnIndividual[2]: b.indi,
      myPokemonColumnIndividual[3]: c.indi,
      myPokemonColumnIndividual[4]: d.indi,
      myPokemonColumnIndividual[5]: s.indi,
      myPokemonColumnEffort[0]: h.effort,
      myPokemonColumnEffort[1]: a.effort,
      myPokemonColumnEffort[2]: b.effort,
      myPokemonColumnEffort[3]: c.effort,
      myPokemonColumnEffort[4]: d.effort,
      myPokemonColumnEffort[5]: s.effort,
      myPokemonColumnMove1: move1.id,
      myPokemonColumnPP1: pp1,
      myPokemonColumnMove2: move2?.id,
      myPokemonColumnPP2: pp2,
      myPokemonColumnMove3: move3?.id,
      myPokemonColumnPP3: pp3,
      myPokemonColumnMove4: move4?.id,
      myPokemonColumnPP4: pp4,
      myPokemonColumnOwnerID: owner.index,
    };
  }
}
