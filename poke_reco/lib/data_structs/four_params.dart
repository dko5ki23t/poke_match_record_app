import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

/// ポケモンのステータス(HABCDS)のインデックス
enum StatIndex {
  /// HP
  H,

  /// こうげき
  A,

  /// ぼうぎょ
  B,

  /// とくこう
  C,

  /// とくぼう
  D,

  /// すばやさ
  S,

  /// サイズ
  size,

  /// なし
  none,
}

/// StatIndexのリスト用extension
extension StatIndexList on StatIndex {
  /// HABCDSの6要素リスト
  static List<StatIndex> get listHtoS {
    return [
      StatIndex.H,
      StatIndex.A,
      StatIndex.B,
      StatIndex.C,
      StatIndex.D,
      StatIndex.S
    ];
  }

  /// HABCDSの5要素リスト
  static List<StatIndex> get listAtoS {
    return [StatIndex.A, StatIndex.B, StatIndex.C, StatIndex.D, StatIndex.S];
  }
}

/// StatIndexを表す文字列を出力するためのextension
extension StatStr on StatIndex {
  /// ステータス名
  String get name {
    switch (PokeDB().language) {
      case Language.japanese:
        switch (this) {
          case StatIndex.H:
            return 'HP';
          case StatIndex.A:
            return 'こうげき';
          case StatIndex.B:
            return 'ぼうぎょ';
          case StatIndex.C:
            return 'とくこう';
          case StatIndex.D:
            return 'とくぼう';
          case StatIndex.S:
            return 'すばやさ';
          default:
            return '';
        }
      case Language.english:
      default:
        switch (this) {
          case StatIndex.H:
            return 'HP';
          case StatIndex.A:
            return 'Attack';
          case StatIndex.B:
            return 'Defense';
          case StatIndex.C:
            return 'Special Attack';
          case StatIndex.D:
            return 'Special Defense';
          case StatIndex.S:
            return 'Speed';
          default:
            return '';
        }
    }
  }

  /// ステータスを表すアルファベット
  String get alphabet {
    switch (this) {
      case StatIndex.H:
        return 'H';
      case StatIndex.A:
        return 'A';
      case StatIndex.B:
        return 'B';
      case StatIndex.C:
        return 'C';
      case StatIndex.D:
        return 'D';
      case StatIndex.S:
        return 'S';
      default:
        return '';
    }
  }
}

/// 4つのパラメータを管理するclass
/// * 種族値
/// * 個体値
/// * 努力値
/// * 実数値
class FourParams extends Equatable implements Copyable {
  /// パラメータの種類
  final StatIndex statIndex;

  /// 種族値
  int race = 0;

  /// 個体値
  int indi = 0;

  /// 努力値
  int effort = 0;

  /// 実数値
  int real = 0;

  @override
  List<Object?> get props => [
        statIndex,
        race,
        indi,
        effort,
        real,
      ];

  FourParams(this.statIndex);

  /// 実数値を更新し、新たな実数値を返す(値は範囲チェックしていない)
  /// ```
  /// level: ポケモンのレベル
  /// temper: ポケモンのせいかく
  /// ```
  int updateReal(int level, Temper? temper) {
    if (statIndex == StatIndex.H) {
      real = (race * 2 + indi + (effort ~/ 4)) * level ~/ 100 + level + 10;
    } else {
      final temperBias = temper != null
          ? Temper.getTemperBias(temper)[statIndex.index - 1]
          : 1.0;
      real =
          (((race * 2 + indi + (effort ~/ 4)) * level ~/ 100 + 5) * temperBias)
              .toInt();
    }
    return real;
  }

  /// 努力値を更新し、新たな努力値を返す(値は範囲チェックしていない)
  /// ※同じ実数値になる努力値のうち、最小の値を返す
  /// ```
  /// level: ポケモンのレベル
  /// temper: せいかく
  /// ```
  int updateEffort(int level, Temper? temper) {
    int savedReal = real;
    if (statIndex == StatIndex.H) {
      effort =
          (((real - level - 10) * 100) ~/ level - race * 2 - indi) * 4; // 暫定値
    } else {
      final temperBias = temper != null
          ? Temper.getTemperBias(temper)[statIndex.index - 1]
          : 1.0;
      effort = ((real ~/ temperBias - 5) * 100 ~/ level - race * 2 - indi) *
          4; // 暫定値
    }
    updateReal(level, temper);
    while (savedReal > real) {
      // 努力値が足りてない
      effort += (4 - effort % 4);
      updateReal(level, temper);
    }
    while (savedReal < real) {
      // 努力値が大きい(たぶんこのwhileには入らない？)
      effort -= effort % 4 == 0 ? 4 : effort % 4;
      updateReal(level, temper);
    }
    return effort;
  }

  /// 個体値を更新し、新たな個体値を返す(値は範囲チェックしていない)
  /// ※同じ実数値になる個体値のうち、最小の値を返す
  /// ```
  /// level: ポケモンのレベル
  /// temper: せいかく
  /// ```
  int updateIndi(int level, Temper? temper) {
    int savedReal = real;
    if (statIndex == StatIndex.H) {
      indi =
          ((real - level - 10) * 100) ~/ level - race * 2 - (effort ~/ 4); // 暫定
    } else {
      final temperBias = temper != null
          ? Temper.getTemperBias(temper)[statIndex.index - 1]
          : 1.0;
      indi = ((real ~/ temperBias - 5) * 100) ~/ level -
          race * 2 -
          (effort ~/ 4); // 暫定
    }
    updateReal(level, temper);
    while (savedReal > real) {
      // 個体値が足りてない
      indi++;
      updateReal(level, temper);
    }
    while (savedReal < real) {
      // 個体値が大きい(たぶんこのwhileには入らない？)
      indi--;
      updateReal(level, temper);
    }
    return indi;
  }

  /// 実数値以外の値から実数値算出済みパラメータを生成
  /// ```
  /// statIndex: 対象のパラメータ
  /// level: ポケモンのレベル
  /// race: 種族値
  /// indi: 個体値
  /// effort: 努力値
  /// temper: せいかく
  /// ```
  factory FourParams.createFromValues({
    required StatIndex statIndex,
    int level = 50,
    required int race,
    required int indi,
    required int effort,
    Temper? temper,
  }) {
    FourParams ret = FourParams(statIndex)
      ..race = race
      ..indi = indi
      ..effort = effort;
    ret.updateReal(level, temper);
    return ret;
  }

  /// 種族値・個体値・努力値・実数値をセット
  set(race, indi, effort, real) {
    this.race = race;
    this.indi = indi;
    this.effort = effort;
    this.real = real;
  }

  @override
  FourParams copy() => FourParams(statIndex)
    ..race = race
    ..indi = indi
    ..effort = effort
    ..real = real;

  /// SQLに保存された文字列からFourParamsをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// statIndex: 対象のパラメータ(※versionが2以下ならば必須)
  /// ```
  static FourParams deserialize(dynamic str, String split1,
      {int version = -1, StatIndex statIndex = StatIndex.H}) {
    final elements = str.split(split1);
    if (1 <= version && version <= 2) {
      return FourParams(statIndex)
        ..race = int.parse(elements[0])
        ..indi = int.parse(elements[1])
        ..effort = int.parse(elements[2])
        ..real = int.parse(elements[3]);
    }
    return FourParams(StatIndex.values[int.parse(elements[0])])
      ..race = int.parse(elements[1])
      ..indi = int.parse(elements[2])
      ..effort = int.parse(elements[3])
      ..real = int.parse(elements[4]);
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1: 区切り文字
  /// ```
  String serialize(String split1) {
    return '${statIndex.index}$split1$race$split1$indi$split1$effort$split1$real';
  }
}
