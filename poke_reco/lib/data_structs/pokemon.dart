import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_move.dart';

class Pokemon {
  int id = 0;    // データベースのプライマリーキー
  int viewOrder = 0;      // 表示順
  String _name = '';       // ポケモン名
  String nickname = '';            // ニックネーム
  int _level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int _no = 0;                      // 図鑑No.
  PokeType type1 = PokeType.createFromId(0);        // タイプ1
  PokeType? type2;                     // タイプ2(null OK)
  PokeType teraType = PokeType.createFromId(0);     // テラスタルタイプ
  Temper temper = Temper(0, '', '', ''); // せいかく
  // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ
  List<SixParams> _stats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, 0, 0));
  Ability ability = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0));     // とくせい
  Item? item;                      // もちもの(null OK)
  List<Move?> _moves = [
    Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0),
    null, null, null
  ];  // わざ
  List<int?> _pps = [0, null, null, null];  // PP
  Owner owner = Owner.mine;     // 自分でつくったか、対戦相手が作ったものか
  int refCount = 0;                 // パーティに含まれている数（削除時に警告出す用の変数）       
  //bool _isValid = false;            // 必要な情報が入力されているか

  // getter
  String get name => _name;
  int get level => _level;
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
    return (
      _name != '' &&
      (_level >= pokemonMinLevel && _level <= pokemonMaxLevel) &&
      _no >= pokemonMinNo && temper.id != 0 &&
      teraType.id != 0 &&
      ability.id != 0 && _moves[0]!.id != 0 &&
      totalEffort() <= pokemonMaxEffortTotal
    );
  }
  // TODO:しんかのきせきが適用できるかどうか
  bool get isEvolvable => true;

  // setter
  set name(String x) {_name = x;}
  set level(int x) {_level = x;}
  set no(int x) {_no = x;}
  set h(SixParams x) {_stats[StatIndex.H.index] = x;}
  set a(SixParams x) {_stats[StatIndex.A.index] = x;}
  set b(SixParams x) {_stats[StatIndex.B.index] = x;}
  set c(SixParams x) {_stats[StatIndex.C.index] = x;}
  set d(SixParams x) {_stats[StatIndex.D.index] = x;}
  set s(SixParams x) {_stats[StatIndex.S.index] = x;}
  set move1(Move x) => _moves[0] = x;
  set pp1(int x) => _pps[0] = x;
  set move2(Move? x) => _moves[1] = x;
  set pp2(int? x) => _pps[1] = x;
  set move3(Move? x) => _moves[2] = x;
  set pp3(int? x) => _pps[2] = x;
  set move4(Move? x) => _moves[3] = x;
  set pp4(int? x) => _pps[3] = x;

  Pokemon copyWith() =>
    Pokemon()
    ..id = id
    ..viewOrder = viewOrder
    .._name = _name
    ..nickname = nickname
    .._level = _level
    ..sex = sex
    .._no = _no
    ..type1 = type1
    ..type2 = type2
    ..teraType = teraType
    ..temper = temper
    .._stats = List.generate(
      StatIndex.size.index,
      (i) => SixParams(_stats[i].race, _stats[i].indi, _stats[i].effort, _stats[i].real))
    ..ability = ability.copyWith()
    ..item = item?.copyWith()
    .._moves = [move1.copyWith(), move2?.copyWith(), move3?.copyWith(), move4?.copyWith()]
    .._pps = [..._pps]
    ..owner = owner
    ..refCount = refCount;

  // レベル、種族値、個体値、努力値、せいかくから実数値を更新
  // TODO habcdsのsetterで自動的に呼ぶ？
  void updateRealStats() {
    final temperBias = Temper.getTemperBias(temper);
    _stats[StatIndex.H.index].real = SixParams.getRealH(level, h.race, h.indi, h.effort);
    _stats[StatIndex.A.index].real = SixParams.getRealABCDS(level, a.race, a.indi, a.effort, temperBias[0]);
    _stats[StatIndex.B.index].real = SixParams.getRealABCDS(level, b.race, b.indi, b.effort, temperBias[1]);
    _stats[StatIndex.C.index].real = SixParams.getRealABCDS(level, c.race, c.indi, c.effort, temperBias[2]);
    _stats[StatIndex.D.index].real = SixParams.getRealABCDS(level, d.race, d.indi, d.effort, temperBias[3]);
    _stats[StatIndex.S.index].real = SixParams.getRealABCDS(level, s.race, s.indi, s.effort, temperBias[4]);
  }

  // 実数値から努力値、個体値を更新
  void updateStatsRefReal(int statIndex) {
    if (statIndex == StatIndex.H.index) {
      int effort = SixParams.getEffortH(level, h.race, h.indi, h.real);
      // 努力値の変化だけでは実数値が出せない場合は個体値を更新
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[StatIndex.H.index].effort = effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiH(level, h.race, h.effort, h.real);
        // 努力値・個体値の変化では実数値が出せない場合は実数値を更新
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[StatIndex.H.index].indi = indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[StatIndex.H.index].real = SixParams.getRealH(level, h.race, h.indi, h.effort);
        }
        else {
          _stats[StatIndex.H.index].indi = indi;
        }
      }
      else {
        _stats[StatIndex.H.index].effort = effort;
      }
    }
    else if (statIndex < StatIndex.size.index) {
      final temperBias = Temper.getTemperBias(temper);
      int i = statIndex;
      int effort = SixParams.getEffortABCDS(level, _stats[i].race, _stats[i].indi, _stats[i].real, temperBias[i-1]);
      if (effort < pokemonMinEffort || effort > pokemonMaxEffort) {
        _stats[i].effort = effort.clamp(pokemonMinEffort, pokemonMaxEffort);
        int indi = SixParams.getIndiABCDS(level, _stats[i].race, _stats[i].effort, _stats[i].real, temperBias[i-1]);
        if (indi < pokemonMinIndividual || indi > pokemonMaxIndividual) {
          _stats[i].indi = indi.clamp(pokemonMinIndividual, pokemonMaxIndividual);
          _stats[i].real = SixParams.getRealABCDS(level, _stats[i].race, _stats[i].indi, _stats[i].effort, temperBias[i-1]);
        }
        else {
          _stats[i].indi = indi;
        }
      }
      else {
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
      myPokemonColumnNo: _no,
      myPokemonColumnNickName: nickname,
      myPokemonColumnTeraType: teraType.id,
      myPokemonColumnLevel: _level,
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
      myPokemonColumnRefCount: refCount,
    };
  }
}
