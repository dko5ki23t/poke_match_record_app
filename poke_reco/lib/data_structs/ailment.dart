// 状態変化

import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

// 状態変化による効果(TurnEffectのeffectIdに使用する定数を提供)
class AilmentEffect {
  static const int none = 0;
  static const int burn = 1;                // やけど
  static const int freezeEnd = 2;           // こおりがとけた
  static const int paralysis = 3;           // まひ
  static const int poison = 4;              // どく
  static const int badPoison = 5;           // もうどく
  static const int sleep = 6;               // ねむり     ここまで、重複しない
  static const int confusionEnd = 7;        // こんらんがとけた
  static const int curse = 8;               // のろい
  static const int encoreEnd = 9;           // アンコール
  static const int flinch = 10;             // ひるみ
  static const int identify = 11;           // みやぶられている
  static const int infatuation = 12;        // メロメロ
  static const int leechSeed = 13;          // やどりぎのタネ
  static const int lockOnEnd = 15;          // ロックオン終了
//  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17;   // バインド(交代不可、毎ターンダメージ) / 終了も含む
  static const int perishSong = 18;         // ほろびのうた
  static const int tauntEnd = 19;           // ちょうはつ終了
  static const int torment = 20;            // いちゃもん
  static const int saltCure = 22;           // しおづけ
  static const int disableEnd = 23;         // かなしばり終了
  static const int magnetRiseEnd = 24;      // でんじふゆう終了
  static const int telekinesisEnd = 25;     // テレキネシス終了
  static const int healBlockEnd = 26;       // かいふくふうじ終了
  static const int embargoEnd = 27;         // さしおさえ終了
  static const int sleepy = 28;             // ねむけ→ねむり
  static const int ingrain = 29;            // ねをはる
  static const int uproarEnd = 30;          // さわぐ終了
  static const int antiAir = 31;            // うちおとす
  static const int magicCoat = 32;          // マジックコート
  static const int charging = 33;           // じゅうでん
  static const int thrash = 34;             // あばれる
//  static const int bide = 35;               // がまん
  static const int destinyBond = 36;        // みちづれ
  static const int cannotRunAway = 37;      // にげられない
  static const int minimize = 38;           // ちいさくなる
  static const int flying = 39;             // そらをとぶ
  static const int digging = 40;            // あなをほる
  static const int curl = 41;               // まるくなる(ころがる・アイスボールの威力2倍)
  static const int stock1 = 42;             // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;             // たくわえる(2)
  static const int stock3 = 44;             // たくわえる(3)
  static const int attention = 45;          // ちゅうもくのまと
//  static const int helpHand = 46;           // てだすけ
  static const int imprison = 47;           // ふういん
  static const int grudge = 48;             // おんねん
  static const int roost = 49;              // はねやすめ
  static const int miracleEye = 50;         // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51;         // パワートリック
  static const int abilityNoEffect = 52;    // とくせいなし
  static const int aquaRing = 53;           // アクアリング
  static const int diving = 54;             // ダイビング
  static const int shadowForcing = 55;      // シャドーダイブ(姿を消した状態)
  static const int electrify = 56;          // そうでん
//  static const int powder = 57;             // ふんじん
  static const int throatChopEnd = 58;      // じごくづき終了(画面には出ない)
  static const int tarShot = 59;            // タールショット
  static const int octoLock = 60;           // たこがため
  static const int protect = 61;            // まもる extraArg1 =
                                            // 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
                                            // 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
                                            // 661:トーチカ(直接攻撃してきた相手をどく状態にする)
                                            // 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
                                            // 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
                                            // 908:かえんのまもり(直接攻撃してきた相手をやけど状態にする)
  static const int candyCandy = 62;         // あめまみれ / 終了も含む
  static const int halloween = 63;          // ハロウィン(ゴーストタイプ)
  static const int forestCurse = 64;        // もりののろい(くさタイプ)

  static int getIdFromAilment(Ailment ailment) {
    switch (ailment.id) {
      default:
        break;
    }
    return ailment.id;
  }

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('やけど', 'Burn'),
    2: Tuple2('こおりが溶けた', 'Defrosted'),
    3: Tuple2('まひ', 'Paralysis'),
    4: Tuple2('どく', 'Poison'),
    5: Tuple2('もうどく', 'Bad poison'),
    6: Tuple2('ねむり', 'Sleep'),
    7: Tuple2('こんらんが解けた', 'Confused no more'),
    8: Tuple2('のろい', 'Curse'),
    9: Tuple2('アンコールが解けた', 'Encore is resolved'),
    10: Tuple2('ひるみ', 'Flinch'),
    11: Tuple2('みやぶられている', 'Foresighted'),
    12: Tuple2('メロメロ', 'Attracted'),
    13: Tuple2('やどりぎのタネ', 'Leech Seed'),
    15: Tuple2('ロックオン終了', 'Lock-On end'),
//    16: Tuple2('あくむ', 'Nightmare'),
    17: Tuple2('バインド', 'Partially Trapped'),
    18: Tuple2('ほろびのうた', 'Perish Song'),
    19: Tuple2('ちょうはつ終了', 'Taunt is resolved'),   // 挑発の効果が解けた
    20: Tuple2('いちゃもん', 'Torment'),
    22: Tuple2('しおづけ', 'Salt Cure'),
    23: Tuple2('かなしばりが解けた', 'Disable is resolved'),
    24: Tuple2('でんじふゆう終了', 'Magnet Rise end'),
    25: Tuple2('テレキネシス終了', 'Telekinesis end'),
    26: Tuple2('かいふくふうじ終了', 'Heal Block end'),
    27: Tuple2('さしおさえ終了', 'Embargo end'),
    28: Tuple2('ねむってしまった', 'Fell asleap'),
    29: Tuple2('ねをはる', 'Ingrain'),
    30: Tuple2('さわぐ終了', 'Uproar end'),
    31: Tuple2('うちおとす', 'Anti Air'),
    32: Tuple2('マジックコート', 'Magic Coat'),
    33: Tuple2('じゅうでん', 'Charging'),
    34: Tuple2('あばれる', 'Thrash'),
//    35: Tuple2('がまん', 'Bide'),
    36: Tuple2('みちづれ', 'Destiny Bond'),
    37: Tuple2('にげられない', 'Cannot run away'),
    38: Tuple2('ちいさくなる', 'Minimize'),
    39: Tuple2('そらをとぶ', 'Flying'),
    40: Tuple2('あなをほる', 'Digging'),
    41: Tuple2('まるくなる', 'Curl'),
    42: Tuple2('たくわえる(1)', 'Stock(1)'),
    43: Tuple2('たくわえる(2)', 'Stock(2)'),
    44: Tuple2('たくわえる(3)', 'Stock(3)'),
    45: Tuple2('ちゅうもくのまと', 'Attention'),
//    46: Tuple2('てだすけ', 'Help Hand'),
    47: Tuple2('ふういん', 'Imprison'),
    48: Tuple2('おんねん', 'Grudge'),
    49: Tuple2('はねやすめ', 'Roost'),
    50: Tuple2('ミラクルアイ', 'Miracle Eye'),
    51: Tuple2('パワートリック', 'Power Trick'),
    52: Tuple2('とくせいなし', 'Ability no effect'),
    53: Tuple2('アクアリング', 'Aqua Ring'),
    54: Tuple2('ダイビング', 'Diving'),
    55: Tuple2('シャドーダイブ', 'Shadow Forcing'),
    56: Tuple2('そうでん', 'Electrify'),
//    57: Tuple2('ふんじん', 'Powder'),
    58: Tuple2('じごくづき', 'Throat Chop end'),
    59: Tuple2('タールショット', 'Tar Shot'),
    60: Tuple2('たこがため', 'Octo Lock'),
    61: Tuple2('まもる', 'Protect'),
    62: Tuple2('あめまみれ', 'Covered in candy'),
    63: Tuple2('ハロウィン', 'Halloween'),
    64: Tuple2('もりののろい', 'Forest Curse'),
  };

  const AilmentEffect(this.id);

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  // ただ状態変化を終了させるだけの処理を行う
  static void processRemove(int effectId, PokemonState pokemonState) {
    switch (effectId) {
      case AilmentEffect.confusionEnd:
      case AilmentEffect.tauntEnd:
      case AilmentEffect.encoreEnd:
      case AilmentEffect.lockOnEnd:
      case AilmentEffect.disableEnd:
      case AilmentEffect.magnetRiseEnd:
      case AilmentEffect.telekinesisEnd:
      case AilmentEffect.embargoEnd:
      case AilmentEffect.uproarEnd:
        pokemonState.ailmentsRemoveWhere((e) => e.id == effectId);
        break;
      default:
        break;
    }
  }

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
  static const int identify = 11;           // みやぶられている
  static const int infatuation = 12;        // メロメロ
  static const int leechSeed = 13;          // やどりぎのタネ
  static const int lockOn = 15;             // ロックオン
//  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17;   // バインド(交代不可、毎ターンダメージ)
  static const int perishSong = 18;         // ほろびのうた
  static const int taunt = 19;              // ちょうはつ(3ターンの間へんかわざ使用不可)  extraArg1に、ちょうはつ状態になってからのわざ使用回数を記録
  static const int torment = 20;            // いちゃもん
  static const int saltCure = 22;           // しおづけ
  static const int disable = 23;            // かなしばり
  static const int magnetRise = 24;         // でんじふゆう
  static const int telekinesis = 25;        // テレキネシス
  static const int healBlock = 26;          // かいふくふうじ(extraArgに継続ターン数)
  static const int embargo = 27;            // さしおさえ
  static const int sleepy = 28;             // ねむけ
  static const int ingrain = 29;            // ねをはる
  static const int uproar = 30;             // さわぐ
  static const int antiAir = 31;            // うちおとす
  static const int magicCoat = 32;          // マジックコート
  static const int charging = 33;           // じゅうでん
  static const int thrash = 34;             // あばれる
//  static const int bide = 35;               // がまん
  static const int destinyBond = 36;        // みちづれ
  static const int cannotRunAway = 37;      // にげられない(あいてに使われた場合はextraArg1 >= 1, extraArg1 == 2→「じりょく」によるにげられない extraArg == 3→「ありじごく」によるにげられない)
  static const int minimize = 38;           // ちいさくなる
  static const int flying = 39;             // そらをとぶ
  static const int digging = 40;            // あなをほる
  static const int curl = 41;               // まるくなる(ころがる・アイスボールの威力2倍)
  static const int stock1 = 42;             // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43;             // たくわえる(2)
  static const int stock3 = 44;             // たくわえる(3)
  static const int attention = 45;          // ちゅうもくのまと
//  static const int helpHand = 46;           // てだすけ(シングルバトルではこの状態にできない)
  static const int imprison = 47;           // ふういん
  static const int grudge = 48;             // おんねん
  static const int roost = 49;              // はねやすめ
  static const int miracleEye = 50;         // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51;         // パワートリック
  static const int abilityNoEffect = 52;    // とくせいなし
  static const int aquaRing = 53;           // アクアリング
  static const int diving = 54;             // ダイビング
  static const int shadowForcing = 55;      // シャドーダイブ(姿を消した状態)
  static const int electrify = 56;          // そうでん
//  static const int powder = 57;             // ふんじん
  static const int throatChop = 58;         // じごくづき
  static const int tarShot = 59;            // タールショット
  static const int octoLock = 60;           // たこがため
  static const int protect = 61;            // まもる extraArg1 =
                                            // 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
                                            // 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
                                            // 661:トーチカ(直接攻撃してきた相手をどく状態にする)
                                            // 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
                                            // 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
                                            // 908:かえんのまもり(直接攻撃してきた相手をやけど状態にする)
  static const int candyCandy = 62;         // あめまみれ
  static const int halloween = 63;          // ハロウィン(ゴーストタイプ)
  static const int forestCurse = 64;        // もりののろい(くさタイプ)

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap = {
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
    19: Tuple4('ちょうはつ', 'Taunt', PokeTypeColor.ghost, 4),
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
    if (_nameColorTurnMap[id]!.item4 > 0) extraStr = ' ($turns/?)';
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
        extraStr = '(${pokeData.moves[extraArg1]!.displayName}) ($turns/3)';
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
  Color get bgColor => _nameColorTurnMap[id]!.item3;
  int get maxTurn {
    int ret = _nameColorTurnMap[id]!.item4;
    if (id == sleep && extraArg1 == 3) ret = 3;
    if (id == partiallyTrapped && extraArg1 % 10 == 7) ret = 7;
    if (id == healBlock) ret = extraArg1;
    return ret;
  }

  // 発動するタイミング・条件かどうかを返す
  bool isActive(bool isMe, Timing timing, PokemonState pokemonState, PhaseState state) {
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case Timing.beforeMove:    // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return turns >= 4;
          default:
            return false;
        }
      case Timing.everyTurnEnd:  // ターン終了時に発動する状態変化
        switch (id) {
          case burn:
          case curse:
          case leechSeed:
          case saltCure:
            return pokemonState.isNotAttackedDamaged;
          case poison:
          case badPoison:
            return pokemonState.isNotAttackedDamaged && pokemonState.currentAbility.id != 90;
          case encore:
            return turns >= 3;
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
            return turns >= 1 && pokemonState.copyWith().ailmentsAdd(Ailment(Ailment.sleep), state);    // ねむけ状態のとき&ねむりになるとき
          case aquaRing:
          case ingrain:
            return isMe ? pokemonState.remainHP < pokemonState.pokemon.h.real : pokemonState.remainHPPercent < 100;
          default:
            return false;
        }
      default:
        return false;
    }
  }

  // 発動する可能性のあるタイミング・条件かどうかを返す
  bool possiblyActive(Timing timing, PokemonState pokemonState, PhaseState state) {
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case Timing.beforeMove:    // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return true;
          default:
            return false;
        }
      case Timing.everyTurnEnd:  // ターン終了時に発動する状態変化
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

  // TurnEffectのarg1が決定できる場合はその値を返す
  static int getAutoArg1(
    int ailmentId, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, Timing timing, int turns,
  ) {
    bool isMe = player == PlayerType.me;

    switch (ailmentId) {
      case burn:
        if (myState.buffDebuffs.where((element) => element.id == BuffDebuff.heatproof).isNotEmpty) {
          return isMe ? (myState.pokemon.h.real / 32). floor() : 3;
        }
        else {
          return isMe ? (myState.pokemon.h.real / 16). floor() : 6;
        }
      case poison:
      case leechSeed:
      case partiallyTrapped:
        return isMe ? turns >= 10 ? (myState.pokemon.h.real / 6). floor() : (myState.pokemon.h.real / 8). floor() :
          turns >= 10 ? 16 : 12;
      case badPoison:
        return isMe ? (myState.pokemon.h.real * (turns + 1).clamp(1, 15) / 16). floor() :
                      (100 * (turns + 1).clamp(1, 15) / 16).floor();
      case curse:
        return isMe ? (myState.pokemon.h.real / 4). floor() : 25;
      case saltCure:
        {
          int bunbo = myState.isTypeContain(PokeTypeId.steel) || myState.isTypeContain(PokeTypeId.water) ? 4 : 8;
          return isMe ? (myState.pokemon.h.real / bunbo).floor() : (100 / bunbo).floor();
        }
      case ingrain:
      case aquaRing:
        {
          int rec = isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
          return myState.holdingItem?.id == 273 ? -((-rec * 1.3).floor()) : rec;
        }
      default:
        break;
    }

    return 0;
  }

  // TurnEffectのarg2が決定できる場合はその値を返す
  static int getAutoArg2(
    int ailmentId, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, Timing timing,
  ) {
    return 0;
  }

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
