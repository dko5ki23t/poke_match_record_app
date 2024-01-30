import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/tool.dart';

class Pokemon extends Equatable implements Copyable {
  int id = 0; // データベースのプライマリーキー
  int viewOrder = 0; // 表示順
  String _name = ''; // ポケモン名(日本語)
  String _nameEn = ''; // ポケモン名(英語)
  String nickname = ''; // ニックネーム
  int level = 50; // レベル
  Sex sex = Sex.none; // せいべつ
  int _no = 0; // 図鑑No.
  PokeType type1 = PokeType.unknown; // タイプ1
  PokeType? type2; // タイプ2(null OK)
  PokeType teraType = PokeType.unknown; // テラスタルタイプ
  Temper temper = Temper(0, '', '', StatIndex.none, StatIndex.none); // せいかく
  // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ
  List<SixParams> _stats = List.generate(
      StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, 0, 0));
  Ability ability = Ability(0, '', '', Timing.none, Target.none); // とくせい
  Item? item; // もちもの(null OK)
  List<Move?> _moves = [
    Move(0, '', '', PokeType.unknown, 0, 0, 0, Target.none, DamageClass(0),
        MoveEffect(0), 0, 0),
    null,
    null,
    null
  ]; // わざ
  List<int?> _pps = [0, null, null, null]; // PP
  Owner owner = Owner.mine; // 自分でつくったか、対戦相手が作ったものか

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
        temper,
        _stats,
        ability,
        item,
        _moves,
        _pps,
        owner
      ];

  Pokemon();

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
    temper = pokeData.tempers[map[myPokemonColumnTemper]]!;
    h = SixParams(
      pokeData.pokeBase[pokeNo]!.h,
      map[myPokemonColumnIndividual[0]],
      map[myPokemonColumnEffort[0]],
      0,
    );
    a = SixParams(
      pokeData.pokeBase[pokeNo]!.a,
      map[myPokemonColumnIndividual[1]],
      map[myPokemonColumnEffort[1]],
      0,
    );
    b = SixParams(
      pokeData.pokeBase[pokeNo]!.b,
      map[myPokemonColumnIndividual[2]],
      map[myPokemonColumnEffort[2]],
      0,
    );
    c = SixParams(
      pokeData.pokeBase[pokeNo]!.c,
      map[myPokemonColumnIndividual[3]],
      map[myPokemonColumnEffort[3]],
      0,
    );
    d = SixParams(
      pokeData.pokeBase[pokeNo]!.d,
      map[myPokemonColumnIndividual[4]],
      map[myPokemonColumnEffort[4]],
      0,
    );
    s = SixParams(
      pokeData.pokeBase[pokeNo]!.s,
      map[myPokemonColumnIndividual[5]],
      map[myPokemonColumnEffort[5]],
      0,
    );
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

  // getter
  String get name {
    switch (PokeDB().language) {
      case Language.english:
        return _nameEn;
      case Language.japanese:
      default:
        return _name;
    }
  }

  // getter
  String get omittedName {
    return name.split('(')[0];
  }

  int get no => _no;
  SixParams get h => _stats[StatIndex.H.index];
  SixParams get a => _stats[StatIndex.A.index];
  SixParams get b => _stats[StatIndex.B.index];
  SixParams get c => _stats[StatIndex.C.index];
  SixParams get d => _stats[StatIndex.D.index];
  SixParams get s => _stats[StatIndex.S.index];
  List<SixParams> get stats => _stats;
  Move get move1 => _moves[0]!;
  int get pp1 => _pps[0]!;
  Move? get move2 => _moves[1];
  int? get pp2 => _pps[1];
  Move? get move3 => _moves[2];
  int? get pp3 => _pps[2];
  Move? get move4 => _moves[3];
  int? get pp4 => _pps[3];
  List<Move?> get moves => _moves;
  List<int?> get pps => _pps;
  int get moveNum {
    for (int i = 0; i < 4; i++) {
      if (moves[i] == null) return i;
    }
    return 4;
  }

  bool get isValid {
    return (name != '' &&
        (level >= pokemonMinLevel && level <= pokemonMaxLevel) &&
        no >= pokemonMinNo &&
        temper.id != 0 &&
        teraType != PokeType.unknown &&
        ability.id != 0 &&
        _moves[0]!.id != 0 &&
        totalEffort() <= pokemonMaxEffortTotal);
  }

  bool get refs {
    for (final e in PokeDB().parties.values) {
      for (int i = 0; i < e.pokemonNum; i++) {
        if (e.pokemons[i]!.id == id) return true;
      }
    }
    return false;
  }

  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;

  // setter
  set no(int n) {
    // No変えると名前も変える
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

  set h(SixParams x) {
    _stats[StatIndex.H.index] = x;
  }

  set a(SixParams x) {
    _stats[StatIndex.A.index] = x;
  }

  set b(SixParams x) {
    _stats[StatIndex.B.index] = x;
  }

  set c(SixParams x) {
    _stats[StatIndex.C.index] = x;
  }

  set d(SixParams x) {
    _stats[StatIndex.D.index] = x;
  }

  set s(SixParams x) {
    _stats[StatIndex.S.index] = x;
  }

  set move1(Move x) => _moves[0] = x;
  set pp1(int x) => _pps[0] = x;
  set move2(Move? x) => _moves[1] = x;
  set pp2(int? x) => _pps[1] = x;
  set move3(Move? x) => _moves[2] = x;
  set pp3(int? x) => _pps[2] = x;
  set move4(Move? x) => _moves[3] = x;
  set pp4(int? x) => _pps[3] = x;

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
    ..temper = temper
    .._stats = List.generate(
        StatIndex.size.index,
        (i) => SixParams(
            _stats[i].race, _stats[i].indi, _stats[i].effort, _stats[i].real))
    ..ability = ability.copy()
    ..item = item?.copy()
    .._moves = [move1.copy(), move2?.copy(), move3?.copy(), move4?.copy()]
    .._pps = [..._pps]
    ..owner = owner;

  // 編集したかどうかのチェックに使う
  bool isDiff(Pokemon pokemon) {
    bool ret = id != pokemon.id ||
        name != pokemon.name ||
        nickname != pokemon.nickname ||
        level != pokemon.level ||
        sex != pokemon.sex ||
        no != pokemon.no ||
        type1 != pokemon.type1 ||
        type2 != pokemon.type2 ||
        teraType != pokemon.teraType ||
        temper.id != pokemon.temper.id ||
        ability.id != pokemon.ability.id ||
        item?.id != pokemon.item?.id ||
        owner != pokemon.owner;
    if (ret) return true;
    if (_stats.length != pokemon._stats.length) return true;
    if (_moves.length != pokemon._moves.length) return true;
    if (_pps.length != pokemon._pps.length) return true;
    for (int i = 0; i < _stats.length; i++) {
      if (_stats[i] != pokemon._stats[i]) return true;
    }
    for (int i = 0; i < _moves.length; i++) {
      if (_moves[i]?.id != pokemon._moves[i]?.id) return true;
    }
    for (int i = 0; i < _pps.length; i++) {
      if (_pps[i] != pokemon._pps[i]) return true;
    }
    return false;
  }

  // レベル、種族値、個体値、努力値、せいかくから実数値を更新
  // TODO habcdsのsetterで自動的に呼ぶ？
  void updateRealStats() {
    final temperBias = Temper.getTemperBias(temper);
    _stats[StatIndex.H.index].real =
        SixParams.getRealH(level, h.race, h.indi, h.effort);
    _stats[StatIndex.A.index].real =
        SixParams.getRealABCDS(level, a.race, a.indi, a.effort, temperBias[0]);
    _stats[StatIndex.B.index].real =
        SixParams.getRealABCDS(level, b.race, b.indi, b.effort, temperBias[1]);
    _stats[StatIndex.C.index].real =
        SixParams.getRealABCDS(level, c.race, c.indi, c.effort, temperBias[2]);
    _stats[StatIndex.D.index].real =
        SixParams.getRealABCDS(level, d.race, d.indi, d.effort, temperBias[3]);
    _stats[StatIndex.S.index].real =
        SixParams.getRealABCDS(level, s.race, s.indi, s.effort, temperBias[4]);
  }

  // 実数値から努力値、個体値を更新
  void updateStatsRefReal(int statIndex) {
    if (statIndex == StatIndex.H.index) {
      int effort = SixParams.getEffortH(level, h.race, h.indi, h.real);
      // 努力値の変化だけでは実数値が出せない場合は個体値を更新
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[StatIndex.H.index].effort =
            effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiH(level, h.race, h.effort, h.real);
        // 努力値・個体値の変化では実数値が出せない場合は実数値を更新
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[StatIndex.H.index].indi =
              indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[StatIndex.H.index].real =
              SixParams.getRealH(level, h.race, h.indi, h.effort);
        } else {
          _stats[StatIndex.H.index].indi = indi;
        }
      } else {
        _stats[StatIndex.H.index].effort = effort;
      }
    } else if (statIndex < StatIndex.size.index) {
      final temperBias = Temper.getTemperBias(temper);
      int i = statIndex;
      int effort = SixParams.getEffortABCDS(level, _stats[i].race,
          _stats[i].indi, _stats[i].real, temperBias[i - 1]);
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[i].effort = effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiABCDS(level, _stats[i].race,
            _stats[i].effort, _stats[i].real, temperBias[i - 1]);
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[i].indi =
              indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[i].real = SixParams.getRealABCDS(level, _stats[i].race,
              _stats[i].indi, _stats[i].effort, temperBias[i - 1]);
        } else {
          _stats[i].indi = indi;
        }
      } else {
        _stats[i].effort = effort;
      }
    }
  }

  // 種族値の合計
  int totalRace() {
    return h.race + a.race + b.race + c.race + d.race + s.race;
  }

  // 努力値の合計
  int totalEffort() {
    return h.effort + a.effort + b.effort + c.effort + d.effort + s.effort;
  }

  // SQLite保存用
  Map<String, dynamic> toMap() {
    return {
      myPokemonColumnId: id,
      myPokemonColumnViewOrder: viewOrder,
      myPokemonColumnNo: no,
      myPokemonColumnNickName: nickname,
      myPokemonColumnTeraType: teraType.index,
      myPokemonColumnLevel: level,
      myPokemonColumnSex: sex.id,
      myPokemonColumnTemper: temper.id,
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
