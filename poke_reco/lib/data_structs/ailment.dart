import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

/// 状態変化
class Ailment extends Equatable implements Copyable {
  /// 状態変化なし
  static const int none = 0;

  /// やけど
  static const int burn = 1;

  /// こおり
  static const int freeze = 2;

  /// まひ
  static const int paralysis = 3;

  /// どく
  static const int poison = 4;

  /// もうどく
  static const int badPoison = 5;

  /// ねむり(ここまでは重複しない)
  static const int sleep = 6;

  /// こんらん
  static const int confusion = 7;

  /// のろい
  static const int curse = 8;

  /// アンコール
  static const int encore = 9;

  /// ひるみ
  static const int flinch = 10;

  /// みやぶられている
  static const int identify = 11;

  /// メロメロ
  static const int infatuation = 12;

  /// やどりぎのタネ
  static const int leechSeed = 13;

  /// ロックオン
  static const int lockOn = 15;
//  static const int nightmare = 16;          // あくむ
  /// バインド(交代不可、毎ターンダメージ)
  static const int partiallyTrapped = 17;

  /// ほろびのうた
  static const int perishSong = 18;

  /// ちょうはつ(3ターンの間へんかわざ使用不可)  行動後にちょうはつを受けた場合(=4ターン)はextraArg=1
  static const int taunt = 19;

  /// いちゃもん
  static const int torment = 20;

  /// しおづけ
  static const int saltCure = 22;

  /// かなしばり
  static const int disable = 23;

  /// でんじふゆう
  static const int magnetRise = 24;

  /// テレキネシス
  static const int telekinesis = 25;

  /// かいふくふうじ(extraArgに継続ターン数)
  static const int healBlock = 26;

  /// さしおさえ
  static const int embargo = 27;

  /// ねむけ
  static const int sleepy = 28;

  /// ねをはる
  static const int ingrain = 29;

  /// さわぐ
  static const int uproar = 30;

  /// うちおとす
  static const int antiAir = 31;

  /// マジックコート
  static const int magicCoat = 32;

  /// じゅうでん
  static const int charging = 33;

  /// あばれる
  static const int thrash = 34;

//  static const int bide = 35;               // がまん
  /// みちづれ
  static const int destinyBond = 36;

  /// にげられない
  /// * あいてに使われた場合はextraArg1 >= 1,
  /// * extraArg1 == 2→「じりょく」によるにげられない
  /// * extraArg1 == 3→「ありじごく」によるにげられない)
  static const int cannotRunAway = 37;

  /// ちいさくなる
  static const int minimize = 38;

  /// そらをとぶ
  static const int flying = 39;

  /// あなをほる
  static const int digging = 40;

  /// まるくなる(ころがる・アイスボール当てるたびに威力2倍。extraArg1に連続で当たった回数を格納)
  static const int curl = 41;

  /// たくわえる(1)
  /// * extraArg1の1の位：たくわえたときに上がったぼうぎょ
  /// * extraArg1の10の位：たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock1 = 42;

  /// たくわえる(2)
  /// * extraArg1の1の位：たくわえたときに上がったぼうぎょ
  /// * extraArg1の10の位：たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;

  /// たくわえる(3)
  /// * extraArg1の1の位：たくわえたときに上がったぼうぎょ
  /// * extraArg1の10の位：たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock3 = 44;

  /// ちゅうもくのまと
  static const int attention = 45;

//  static const int helpHand = 46;           // てだすけ(シングルバトルではこの状態にできない)
  /// ふういん
  static const int imprison = 47;

  /// おんねん
  static const int grudge = 48;

  /// はねやすめ
  static const int roost = 49;

  /// ミラクルアイ(+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int miracleEye = 50;

  /// パワートリック
  static const int powerTrick = 51;

  /// とくせいなし
  static const int abilityNoEffect = 52;

  /// アクアリング
  static const int aquaRing = 53;

  /// ダイビング
  static const int diving = 54;

  /// シャドーダイブ(姿を消した状態)
  static const int shadowForcing = 55;

  /// そうでん
  static const int electrify = 56;
//  static const int powder = 57;             // ふんじん
  /// じごくづき
  static const int throatChop = 58;

  /// タールショット
  static const int tarShot = 59;

  /// たこがため
  static const int octoLock = 60;

  /// まもる extraArg1 =
  /// * 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
  /// * 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
  /// * 661:トーチカ(直接攻撃してきた相手をどく状態にする)
  /// * 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
  /// * 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
  /// * 908:かえんのまもり(直接攻撃してきた相手をやけど状態にする)
  static const int protect = 61;

  /// あめまみれ
  static const int candyCandy = 62;

  /// ハロウィン(ゴーストタイプ)
  static const int halloween = 63;

  /// もりののろい(くさタイプ)
  static const int forestCurse = 64;

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap =
      {
    0: Tuple4('', '', Colors.black, 0),
    1: Tuple4('やけど', 'Burn', PokeTypeColor.fire, 0),
    2: Tuple4('こおり', 'Freeze', PokeTypeColor.ice, 0),
    3: Tuple4('まひ', 'Paralysis', PokeTypeColor.electric, 0),
    4: Tuple4('どく', 'Poison', PokeTypeColor.poison, 0),
    5: Tuple4('もうどく', 'Bad poison', PokeTypeColor.poison, 0),
    6: Tuple4('ねむり', 'Sleep', PokeTypeColor.fly, 4),
    7: Tuple4('こんらん', 'Confusion', PokeTypeColor.electric, 0),
    8: Tuple4('のろい', 'Curse', PokeTypeColor.ghost, 0),
    9: Tuple4('アンコール', 'Encore', PokeTypeColor.evil, 3),
    10: Tuple4('ひるみ', 'Flinch', PokeTypeColor.evil, 0),
    11: Tuple4('みやぶられている', 'Foresighted', PokeTypeColor.evil, 0),
    12: Tuple4('メロメロ', 'Attracted', PokeTypeColor.fairy, 0),
    13: Tuple4('やどりぎのタネ', 'Leech Seed', PokeTypeColor.grass, 0),
    15: Tuple4('ロックオン', 'Lock-On', PokeTypeColor.fight, 2),
//    16: Tuple4('あくむ', 'Nightmare', PokeTypeColor.evil, 0),
    17: Tuple4('バインド', 'Partially Trapped', PokeTypeColor.evil, 5),
    18: Tuple4('ほろびのうた', 'Perish Song', PokeTypeColor.evil, 3),
    19: Tuple4('ちょうはつ', 'Taunt', PokeTypeColor.ghost, 3),
    20: Tuple4('いちゃもん', 'Torment', PokeTypeColor.evil, 0),
    22: Tuple4('しおづけ', 'Salt Cure', PokeTypeColor.rock, 0),
    23: Tuple4('かなしばり', 'Disable', PokeTypeColor.ghost, 5),
    24: Tuple4('でんじふゆう', 'Magnet Rise', PokeTypeColor.electric, 5),
    25: Tuple4('テレキネシス', 'Telekinesis', PokeTypeColor.psychic, 3),
    26: Tuple4('かいふくふうじ', 'Heal Block', PokeTypeColor.evil, 5),
    27: Tuple4('さしおさえ', 'Embargo', PokeTypeColor.evil, 5),
    28: Tuple4('ねむけ', 'Sleepy', PokeTypeColor.fly, 0),
    29: Tuple4('ねをはる', 'Ingrain', PokeTypeColor.grass, 0),
    30: Tuple4('さわぐ', 'Uproar', PokeTypeColor.evil, 3),
    31: Tuple4('うちおとす', 'Anti Air', PokeTypeColor.ground, 0),
    32: Tuple4('マジックコート', 'Magic Coat', PokeTypeColor.psychic, 0),
    33: Tuple4('じゅうでん', 'Charging', PokeTypeColor.electric, 0),
    34: Tuple4('あばれる', 'Thrash', PokeTypeColor.dragon, 0),
//    35: Tuple4('がまん', 'Bide', PokeTypeColor.fight, 0),
    36: Tuple4('みちづれ', 'Destiny Bond', PokeTypeColor.ghost, 0),
    37: Tuple4('にげられない', 'Cannot run away', PokeTypeColor.evil, 0),
    38: Tuple4('ちいさくなる', 'Minimize', PokeTypeColor.psychic, 0),
    39: Tuple4('そらをとぶ', 'Flying', PokeTypeColor.fly, 0),
    40: Tuple4('あなをほる', 'Digging', PokeTypeColor.ground, 0),
    41: Tuple4('まるくなる', 'Curl', PokeTypeColor.fight, 0),
    42: Tuple4('たくわえる(1)', 'Stock(1)', PokeTypeColor.fight, 0),
    43: Tuple4('たくわえる(2)', 'Stock(2)', PokeTypeColor.fight, 0),
    44: Tuple4('たくわえる(3)', 'Stock(3)', PokeTypeColor.fight, 0),
    45: Tuple4('ちゅうもくのまと', 'Attention', PokeTypeColor.psychic, 0),
//    46: Tuple4('てだすけ', 'Help Hand', PokeTypeColor.fairy, 0),
    47: Tuple4('ふういん', 'Imprison', PokeTypeColor.evil, 0),
    48: Tuple4('おんねん', 'Grudge', PokeTypeColor.ghost, 0),
    49: Tuple4('はねやすめ', 'Roost', PokeTypeColor.fly, 0),
    50: Tuple4('ミラクルアイ', 'Miracle Eye', PokeTypeColor.psychic, 0),
    51: Tuple4('パワートリック', 'Power Trick', PokeTypeColor.psychic, 0),
    52: Tuple4('とくせいなし', 'Ability no effect', PokeTypeColor.evil, 0),
    53: Tuple4('アクアリング', 'Aqua Ring', PokeTypeColor.water, 0),
    54: Tuple4('ダイビング', 'Diving', PokeTypeColor.water, 0),
    55: Tuple4('シャドーダイブ', 'Shadow Forcing', PokeTypeColor.ghost, 0),
    56: Tuple4('そうでん', 'Electrify', PokeTypeColor.electric, 0),
//    57: Tuple4('ふんじん', 'Powder', PokeTypeColor.rock, 0),
    58: Tuple4('じごくづき', 'Throat Chop', PokeTypeColor.evil, 2),
    59: Tuple4('タールショット', 'Tar Shot', PokeTypeColor.evil, 0),
    60: Tuple4('たこがため', 'Octo Lock', PokeTypeColor.evil, 0),
    61: Tuple4('まもる', 'Protect', Colors.green, 0),
    62: Tuple4('あめまみれ', 'Covered in candy', PokeTypeColor.poison, 3),
    63: Tuple4('ハロウィン', 'Halloween', PokeTypeColor.ghost, 0),
    64: Tuple4('もりののろい', 'Forest Curse', PokeTypeColor.grass, 0),
  };

  /// ID
  final int id;

  /// 経過ターン
  int turns = 0;

  /// アンコール対象のわざID等
  int extraArg1 = 0;

  @override
  List<Object?> get props => [
        id,
        turns,
        extraArg1,
      ];

  Ailment(this.id);

  @override
  Ailment copy() => Ailment(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  /// 表示名(経過ターン数含む)
  String get displayName {
    final pokeData = PokeDB();
    String extraStr = '';
    if (_nameColorTurnMap[id]!.item4 > 0) extraStr = ' ($turns/$maxTurn)';
    switch (id) {
      case Ailment.badPoison:
        extraStr = ' (${(turns + 1).clamp(1, 15)}';
        break;
      case Ailment.sleep:
        extraStr = ' ($turns/${extraArg1 == 3 ? '3' : '2 ~ 4'})';
        break;
      case Ailment.confusion:
        extraStr = ' ($turns/2 ~ 5)';
        break;
      case Ailment.disable:
        extraStr = '(${pokeData.moves[extraArg1]!.displayName}) ($turns/4 ~ 5)';
        break;
      case Ailment.encore:
        extraStr =
            '(${pokeData.moves[extraArg1]!.displayName}) ($turns/$maxTurn)';
        break;
      case Ailment.partiallyTrapped:
        extraStr = ' ($turns/${extraArg1 % 10 == 7 ? '7' : '4 ~ 5'})';
        break;
    }

    switch (PokeDB().language) {
      case Language.japanese:
        return _nameColorTurnMap[id]!.item1 + extraStr;
      case Language.english:
      default:
        return _nameColorTurnMap[id]!.item2 + extraStr;
    }
  }

  /// 表示背景色
  Color get bgColor => _nameColorTurnMap[id]!.item3;
  int get maxTurn {
    int ret = _nameColorTurnMap[id]!.item4;
    if (id == sleep && extraArg1 == 3) ret = 3;
    if (id == partiallyTrapped && extraArg1 % 10 == 7) ret = 7;
    if (id == healBlock) ret = extraArg1;
    return ret;
  }

  /// 発動するタイミング・条件かどうかを返す
  /// ```
  /// isMe: 状態変化の持ち主が自身(ユーザー)かどうか
  /// timing: タイミング
  /// pokemonState: 状態変化の持ち主ポケモンの状態
  /// state: フェーズの状態
  /// ```
  bool isActive(
      bool isMe, Timing timing, PokemonState pokemonState, PhaseState state) {
    var yourState = isMe
        ? state.getPokemonState(PlayerType.opponent, null)
        : state.getPokemonState(PlayerType.me, null);
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case Timing.beforeMove: // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return turns >= 4;
          default:
            return false;
        }
      case Timing.everyTurnEnd: // ターン終了時に発動する状態変化
        switch (id) {
          case burn:
          case curse:
          case saltCure:
            return pokemonState.isNotAttackedDamaged;
          case leechSeed:
            return !yourState.isFainting && pokemonState.isNotAttackedDamaged;
          case poison:
          case badPoison:
            return pokemonState.isNotAttackedDamaged &&
                pokemonState.currentAbility.id != 90;
          case encore:
            return turns >= maxTurn;
          case lockOn:
          case perishSong:
          case taunt:
          case disable:
          case magnetRise:
          case telekinesis:
          case healBlock:
          case embargo:
          case uproar:
            return turns >= maxTurn - 1;
          case partiallyTrapped:
          case octoLock:
          case candyCandy:
            return true;
          case sleepy:
            return turns >= 1 &&
                pokemonState.copy().ailmentsAdd(
                    Ailment(Ailment.sleep), state); // ねむけ状態のとき&ねむりになるとき
          case aquaRing:
          case ingrain:
            return isMe
                ? pokemonState.remainHP < pokemonState.pokemon.h.real
                : pokemonState.remainHPPercent < 100;
          default:
            return false;
        }
      default:
        return false;
    }
  }

  /// 発動する可能性のあるタイミング・条件かどうかを返す
  /// ```
  /// timing: タイミング
  /// pokemonState: 状態変化の持ち主ポケモンの状態
  /// state: フェーズの状態
  /// ```
  bool possiblyActive(
      Timing timing, PokemonState pokemonState, PhaseState state) {
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case Timing.beforeMove: // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return true;
          default:
            return false;
        }
      case Timing.everyTurnEnd: // ターン終了時に発動する状態変化
        switch (id) {
          case burn:
          case poison:
          case badPoison:
          case curse:
          case encore:
          case leechSeed:
          case lockOn:
          case partiallyTrapped:
          case perishSong:
          case taunt:
          case saltCure:
          case disable:
          case magnetRise:
          case telekinesis:
          case healBlock:
          case embargo:
          case sleepy:
          case ingrain:
          case uproar:
          case aquaRing:
          case octoLock:
          case candyCandy:
            return true;
          default:
            return false;
        }
      default:
        return false;
    }
  }

  /// SQLに保存された文字列からAilmentをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// ```
  static Ailment deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Ailment(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1: 区切り文字
  /// ```
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

/// 状態変化のリスト
class Ailments extends Equatable implements Copyable {
  List<Ailment> _ailments = [];

  @override
  List<Object?> get props => [_ailments];

  /// 状態変化のリスト
  Ailments();

  @override
  Ailments copy() {
    var ret = Ailments();
    for (var e in _ailments) {
      ret.add(e.copy());
    }
    return ret;
  }

  /// 状態変化を追加し、成功すればtrue、失敗すればfalseを返す。
  /// 既に重複不可な状態変化になっていた場合失敗する
  /// ```
  /// ailment: 追加する状態変化
  /// ```
  bool add(Ailment ailment) {
    if (ailment.id <= 6 &&
        _ailments
            .where(
              (element) => element.id <= 6,
            )
            .isNotEmpty) return false;
    if (_ailments
        .where(
          (element) => element.id == ailment.id,
        )
        .isNotEmpty) return false;
    _ailments.add(ailment);
    return true;
  }

  /// 状態変化の数
  int get length => _ailments.length;

  /// 状態変化のイテレータ
  Iterable<Ailment> get iterable => _ailments;

  /// 要素アクセス
  Ailment operator [](int i) => _ailments[i];

  /// 条件に合う状態変化
  Iterable<Ailment> where(bool Function(Ailment) test) => _ailments.where(test);

  /// 条件に合う最初の状態変化のインデックス
  int indexWhere(bool Function(Ailment) test) => _ailments.indexWhere(test);

  /// 指定インデックスの状態変化を削除
  Ailment removeAt(int index) => _ailments.removeAt(index);

  /// 指定した状態変化を削除し、成否を返す
  bool remove(Object? e) => _ailments.remove(e);

  /// 条件に合う状態変化をすべて削除
  void removeWhere(bool Function(Ailment) test) => _ailments.removeWhere(test);

  /// すべての状態変化を削除
  void clear() => _ailments.clear();

  /// SQLに保存された文字列からAilmentをパース
  /// /// ```
  /// str: SQLに保存された文字列
  /// split1,split2: 区切り文字
  /// ```
  static Ailments deserialize(dynamic str, String split1, String split2) {
    Ailments ret = Ailments();
    final ailmentElements = str.split(split1);
    for (final ailment in ailmentElements) {
      if (ailment == '') break;
      ret.add(Ailment.deserialize(ailment, split2));
    }
    return ret;
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1,split2: 区切り文字
  /// ```
  String serialize(String split1, String split2) {
    String ret = '';
    for (final ailment in _ailments) {
      ret += ailment.serialize(split2);
      ret += split1;
    }
    return ret;
  }
}
