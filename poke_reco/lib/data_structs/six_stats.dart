import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

/// HABCDSの6ステータスを管理するclass
class SixStats extends Equatable implements Copyable {
  /// HABCDSの6ステータス
  List<FourParams> sixParams =
      List.generate(6, (index) => FourParams(StatIndex.values[index]));

  @override
  List<Object?> get props => [sixParams];

  /// HP
  FourParams get h => sixParams[StatIndex.H.index];

  /// こうげき
  FourParams get a => sixParams[StatIndex.A.index];

  /// ぼうぎょ
  FourParams get b => sixParams[StatIndex.B.index];

  /// とくこう
  FourParams get c => sixParams[StatIndex.C.index];

  /// とくぼう
  FourParams get d => sixParams[StatIndex.D.index];

  /// すばやさ
  FourParams get s => sixParams[StatIndex.S.index];

  /// 種族値の合計
  int get totalRace {
    return h.race + a.race + b.race + c.race + d.race + s.race;
  }

  /// 努力値の合計
  int get totalEffort {
    return h.effort + a.effort + b.effort + c.effort + d.effort + s.effort;
  }

  FourParams operator [](StatIndex index) => sixParams[index.index];

  void operator []=(StatIndex index, FourParams value) {
    sixParams[index.index] = value;
  }

  @override
  SixStats copy() =>
      SixStats()..sixParams = [for (final e in sixParams) e.copy()];

  /// 引数で渡された関数を用いて6ステータス生成
  /// ```
  /// func: 引数に0~5を取る、生成用関数
  /// ```
  static SixStats generate(FourParams Function(int) func) {
    SixStats ret = SixStats();
    ret.sixParams = List.generate(6, func);
    return ret;
  }

  /// すべての値が最小の6ステータス生成
  static SixStats generateMinStat() {
    return SixStats();
  }

  /// 個体値・努力値が最大の6ステータス生成
  static SixStats generateMaxStat() {
    SixStats ret = SixStats();
    ret.sixParams = List.generate(
        6,
        (index) => FourParams(StatIndex.values[index])
          ..indi = pokemonMaxIndividual
          ..effort = pokemonMaxEffort);
    return ret;
  }

  /// すべての値が統一された6ステータス生成
  static SixStats generateUniformedStat({
    int race = 0,
    int indi = 0,
    int effort = 0,
    int real = 0,
  }) {
    return SixStats.generate((index) => FourParams(StatIndex.values[index])
      ..race = race
      ..indi = indi
      ..effort = effort
      ..real = real);
  }
}
