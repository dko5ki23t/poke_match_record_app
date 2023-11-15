import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

// 状態変化による効果(TurnEffectのeffectIdに使用する定数を提供)
class AilmentEffect {
  static const int none = 0;
  static const int burn = 1;                // やけど
  static const int freeze = 2;              // こおり
  static const int paralysis = 3;           // まひ
  static const int poison = 4;              // どく
  static const int badPoison = 5;           // もうどく
  static const int sleep = 6;               // ねむり     ここまで、重複しない
  static const int confusion = 7;           // こんらん
  static const int curse = 8;               // のろい
  static const int encore = 9;              // アンコール
  static const int flinch = 10;             // ひるみ
  static const int identify = 11;           // みやぶる
  static const int infatuation = 12;        // メロメロ
  static const int leechSeed = 13;          // やどりぎのタネ
  static const int mindReader = 14;         // こころのめ
  static const int lockOn = 15;             // ロックオン
  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17;   // バインド(交代不可、毎ターンダメージ)
  static const int perishSong = 18;         // ほろびのうた
  static const int tauntEnd = 19;           // ちょうはつ終了
  static const int torment = 20;            // いちゃもん
  static const int noBerry = 21;            // きのみを食べられない状態(きんちょうかん)
  static const int saltCure = 22;           // しおづけ
  static const int disable = 23;            // かなしばり
  static const int magnetRise = 24;         // でんじふゆう
  static const int telekinesis = 25;        // テレキネシス
  static const int healBlock = 26;          // かいふくふうじ
  static const int embargo = 27;            // さしおさえ
  static const int sleepy = 28;             // ねむけ→ねむり
  static const int ingrain = 29;            // ねをはる
  static const int uproar = 30;             // さわぐ
  static const int antiAir = 31;            // うちおとす
  static const int magicCoat = 32;          // マジックコート
  static const int charging = 33;           // じゅうでん
  static const int thrash = 34;             // あばれる
  static const int bide = 35;               // がまん
  static const int destinyBond = 36;        // みちづれ
  static const int cannotRunAway = 37;      // にげられない
  static const int minimize = 38;           // ちいさくなる
  static const int flying = 39;             // そらをとぶ
  static const int digging = 40;            // あなをほる
  static const int curl = 41;               // まるくなる(ころがる・アイスボールの威力2倍)
  static const int stock1 = 42;             // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;             // たくわえる(2)
  static const int stock3 = 44;             // たくわえる(3)
  static const int attention = 45;          // ちゅうもくのまと   // TODO
  static const int helpHand = 46;           // てだすけ
  static const int imprison = 47;           // ふういん         // TODO(わざを確定できそう)
  static const int grudge = 48;             // おんねん
  static const int roost = 49;              // はねやすめ
  static const int miracleEye = 50;         // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51;         // パワートリック
  static const int abilityNoEffect = 52;    // とくせいなし   //TODO
  static const int aquaRing = 53;           // アクアリング
  static const int diving = 54;             // ダイビング
  static const int shadowForcing = 55;      // シャドーダイブ(姿を消した状態)
  static const int electrify = 56;          // そうでん
  static const int powder = 57;             // ふんじん
  static const int throatChop = 58;         // じごくづき
  static const int tarShot = 59;            // タールショット
  static const int octoLock = 60;           // たこがため
  static const int protect = 61;            // まもる extraArg1 =
                                            // 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
                                            // 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
                                            // 661:トーチカ(直接攻撃してきた相手をどく状態にする)
                                            // 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
                                            // 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
  static const int candyCandy = 62;         // あめまみれ     // TODO

  static const _displayNameMap = {
    0: '',
    1: 'やけど',
    2: 'こおり',
    3: 'まひ',
    4: 'どく',
    5: 'もうどく',
    6: 'ねむり',
    7: 'こんらん',
    8: 'のろい',
    9: 'アンコール',
    10: 'ひるみ',
    11: 'みやぶる',
    12: 'メロメロ',
    13: 'やどりぎのタネ',
    14: 'こころのめ',
    15: 'ロックオン',
    16: 'あくむ',
    17: 'バインド',
    18: 'ほろびのうた',
    19: 'ちょうはつ終了',   // 挑発の効果が解けた
    20: 'いちゃもん',
    21: 'きのみを食べられない状態',
    22: 'しおづけ',
    23: 'かなしばり',
    24: 'でんじふゆう',
    25: 'テレキネシス',
    26: 'かいふくふうじ',
    27: 'さしおさえ',
    28: 'ねむってしまった',
    29: 'ねをはる',
    30: 'さわぐ',
    31: 'うちおとす',
    32: 'マジックコート',
    33: 'じゅうでん',
    34: 'あばれる',
    35: 'がまん',
    36: 'みちづれ',
    37: 'にげられない',
    38: 'ちいさくなる',
    39: 'そらをとぶ',
    40: 'あなをほる',
    41: 'まるくなる',
    42: 'たくわえる(1)',
    43: 'たくわえる(2)',
    44: 'たくわえる(3)',
    45: 'ちゅうもくのまと',
    46: 'てだすけ',
    47: 'ふういん',
    48: 'おんねん',
    49: 'はねやすめ',
    50: 'ミラクルアイ',
    51: 'パワートリック',
    52: 'とくせいなし',
    53: 'アクアリング',
    54: 'ダイビング',
    55: 'シャドーダイブ',
    56: 'そうでん',
    57: 'ふんじん',
    58: 'じごくづき',
    59: 'タールショット',
    60: 'たこがため',
    61: 'まもる',
    62: 'あめまみれ',
  };

  const AilmentEffect(this.id);

  String get displayName => _displayNameMap[id]!;

  final int id;
}

// 状態変化
class Ailment {
  static const int none = 0;
  static const int burn = 1;                // やけど
  static const int freeze = 2;              // こおり
  static const int paralysis = 3;           // まひ
  static const int poison = 4;              // どく
  static const int badPoison = 5;           // もうどく
  static const int sleep = 6;               // ねむり     ここまで、重複しない
  static const int confusion = 7;           // こんらん
  static const int curse = 8;               // のろい
  static const int encore = 9;              // アンコール
  static const int flinch = 10;             // ひるみ
  static const int identify = 11;           // みやぶる
  static const int infatuation = 12;        // メロメロ
  static const int leechSeed = 13;          // やどりぎのタネ
  static const int mindReader = 14;         // こころのめ
  static const int lockOn = 15;             // ロックオン
  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17;   // バインド(交代不可、毎ターンダメージ)
  static const int perishSong = 18;         // ほろびのうた
  static const int taunt = 19;              // ちょうはつ
  static const int torment = 20;            // いちゃもん
  static const int noBerry = 21;            // きのみを食べられない状態(きんちょうかん)
  static const int saltCure = 22;           // しおづけ
  static const int disable = 23;            // かなしばり
  static const int magnetRise = 24;         // でんじふゆう
  static const int telekinesis = 25;        // テレキネシス
  static const int healBlock = 26;          // かいふくふうじ
  static const int embargo = 27;            // さしおさえ
  static const int sleepy = 28;             // ねむけ
  static const int ingrain = 29;            // ねをはる
  static const int uproar = 30;             // さわぐ
  static const int antiAir = 31;            // うちおとす
  static const int magicCoat = 32;          // マジックコート
  static const int charging = 33;           // じゅうでん
  static const int thrash = 34;             // あばれる
  static const int bide = 35;               // がまん
  static const int destinyBond = 36;        // みちづれ
  static const int cannotRunAway = 37;      // にげられない
  static const int minimize = 38;           // ちいさくなる
  static const int flying = 39;             // そらをとぶ
  static const int digging = 40;            // あなをほる
  static const int curl = 41;               // まるくなる(ころがる・アイスボールの威力2倍)
  static const int stock1 = 42;             // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;             // たくわえる(2)
  static const int stock3 = 44;             // たくわえる(3)
  static const int attention = 45;          // ちゅうもくのまと   // TODO
  static const int helpHand = 46;           // てだすけ
  static const int imprison = 47;           // ふういん         // TODO(わざを確定できそう)
  static const int grudge = 48;             // おんねん
  static const int roost = 49;              // はねやすめ
  static const int miracleEye = 50;         // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51;         // パワートリック
  static const int abilityNoEffect = 52;    // とくせいなし   //TODO
  static const int aquaRing = 53;           // アクアリング
  static const int diving = 54;             // ダイビング
  static const int shadowForcing = 55;      // シャドーダイブ(姿を消した状態)
  static const int electrify = 56;          // そうでん
  static const int powder = 57;             // ふんじん
  static const int throatChop = 58;         // じごくづき
  static const int tarShot = 59;            // タールショット
  static const int octoLock = 60;           // たこがため
  static const int protect = 61;            // まもる extraArg1 =
                                            // 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
                                            // 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
                                            // 661:トーチカ(直接攻撃してきた相手をどく状態にする)
                                            // 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
                                            // 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
  static const int candyCandy = 62;         // あめまみれ     // TODO

  static const _displayNameMap = {
    0: '',
    1: 'やけど',
    2: 'こおり',
    3: 'まひ',
    4: 'どく',
    5: 'もうどく',
    6: 'ねむり',
    7: 'こんらん',
    8: 'のろい',
    9: 'アンコール',
    10: 'ひるみ',
    11: 'みやぶる',
    12: 'メロメロ',
    13: 'やどりぎのタネ',
    14: 'こころのめ',
    15: 'ロックオン',
    16: 'あくむ',
    17: 'バインド',
    18: 'ほろびのうた',
    19: 'ちょうはつ',
    20: 'いちゃもん',
    21: 'きのみを食べられない状態',
    22: 'しおづけ',
    23: 'かなしばり',
    24: 'でんじふゆう',
    25: 'テレキネシス',
    26: 'かいふくふうじ',
    27: 'さしおさえ',
    28: 'ねむけ',
    29: 'ねをはる',
    30: 'さわぐ',
    31: 'うちおとす',
    32: 'マジックコート',
    33: 'じゅうでん',
    34: 'あばれる',
    35: 'がまん',
    36: 'みちづれ',
    37: 'にげられない',
    38: 'ちいさくなる',
    39: 'そらをとぶ',
    40: 'あなをほる',
    41: 'まるくなる',
    42: 'たくわえる(1)',
    43: 'たくわえる(2)',
    44: 'たくわえる(3)',
    45: 'ちゅうもくのまと',
    46: 'てだすけ',
    47: 'ふういん',
    48: 'おんねん',
    49: 'はねやすめ',
    50: 'ミラクルアイ',
    51: 'パワートリック',
    52: 'とくせいなし',
    53: 'アクアリング',
    54: 'ダイビング',
    55: 'シャドーダイブ',
    56: 'そうでん',
    57: 'ふんじん',
    58: 'じごくづき',
    59: 'タールショット',
    60: 'たこがため',
    61: 'まもる',
    62: 'あめまみれ',
  };

  // TODO:
  static final _bgColor = {
    0: Colors.black,
    1: Colors.black,
    2: Colors.black,
    3: Colors.yellow.shade700,
    4: Colors.black,
    5: Colors.black,
    6: Colors.black,
    7: Colors.black,
    8: Colors.black,
    9: Colors.black,
    10: Colors.black,
    11: Colors.black,
    12: Colors.black,
    13: Colors.black,
    14: Colors.black,
    15: Colors.black,
    16: Colors.black,
    17: Colors.black,
    18: Colors.black,
    19: Colors.black,
    20: Colors.black,
    21: Colors.black,
    22: Colors.black,
    23: Colors.black,
    24: Colors.black,
    25: Colors.black,
    26: Colors.black,
    27: Colors.black,
    28: Colors.black,
    29: Colors.black,
    30: Colors.black,
    31: Colors.black,
    32: Colors.black,
    33: Colors.yellow.shade700,
    34: Colors.black,
    35: Colors.black,
    36: Colors.black,
    37: Colors.black,
    38: Colors.black,
    39: Colors.black,
    40: Colors.black,
    41: Colors.black,
    42: Colors.black,
    43: Colors.black,
    44: Colors.black,
    45: Colors.black,
    46: Colors.black,
    47: Colors.black,
    48: Colors.black,
    49: Colors.black,
    50: Colors.black,
    51: Colors.black,
    52: Colors.black,
    53: Colors.black,
    54: Colors.black,
    55: Colors.black,
    56: Colors.black,
    57: Colors.black,
    58: Colors.black,
    59: Colors.black,
    60: Colors.black,
    61: Colors.black,
    62: Colors.black,
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // アンコール対象のわざID等

  Ailment(this.id);

  Ailment copyWith() =>
    Ailment(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName {
    final pokeData = PokeDB();
    String extraStr = '';
    switch (id) {
      case Ailment.disable:
      case Ailment.encore:
        extraStr = '(${pokeData.moves[extraArg1]!.displayName})';
        break;
    }
    return _displayNameMap[id]! + extraStr;
  }
  Color get bgColor => _bgColor[id]!;

  // SQLに保存された文字列からAilmentをパース
  static Ailment deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Ailment(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

class Ailments {
  List<Ailment> _ailments = [];

  Ailments();

  Ailments copyWith() {
    var ret = Ailments();
    for (var e in _ailments) {
      ret.add(e.copyWith());
    }
    return ret;
  }

  // 既に重複不可な状態異常になっていたら失敗する
  bool add(Ailment ailment) {
    if (ailment.id <= 6 && _ailments.where((element) => element.id <= 6,).isNotEmpty) return false;
    if (_ailments.where((element) => element.id == ailment.id,).isNotEmpty) return false;
    _ailments.add(ailment);
    return true;
  }

  int get length => _ailments.length;
  Iterable<Ailment> get iterable => _ailments;

  Ailment operator [](int i) {
    return _ailments[i];
  }

  Iterable<Ailment> where(bool Function(Ailment) test) {
    return _ailments.where(test);
  }

  int indexWhere(bool Function(Ailment) test) {
    return _ailments.indexWhere(test);
  }
  
  Ailment removeAt(int index) {
    return _ailments.removeAt(index);
  }

  bool remove(Object? e) {
    return _ailments.remove(e);
  }

  void removeWhere(bool Function(Ailment) test) {
    _ailments.removeWhere(test);
  }

  void clear() {
    _ailments.clear();
  }

  // SQLに保存された文字列からAilmentをパース
  static Ailments deserialize(dynamic str, String split1, String split2) {
    Ailments ret = Ailments();
    final ailmentElements = str.split(split1);
    for (final ailment in ailmentElements) {
      if (ailment == '') break;
      ret.add(Ailment.deserialize(ailment, split2));
    }
    return ret;      
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    for (final ailment in _ailments) {
      ret += ailment.serialize(split2);
      ret += split1;
    }
    return ret;
  }
}
