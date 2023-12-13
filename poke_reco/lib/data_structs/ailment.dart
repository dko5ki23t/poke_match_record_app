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

  static const _displayNameMap = {
    0: '',
    1: 'やけど',
    2: 'こおりが溶けた',
    3: 'まひ',
    4: 'どく',
    5: 'もうどく',
    6: 'ねむり',
    7: 'こんらんが解けた',
    8: 'のろい',
    9: 'アンコールが解けた',
    10: 'ひるみ',
    11: 'みやぶられている',
    12: 'メロメロ',
    13: 'やどりぎのタネ',
    15: 'ロックオン終了',
//    16: 'あくむ',
    17: 'バインド',
    18: 'ほろびのうた',
    19: 'ちょうはつ終了',   // 挑発の効果が解けた
    20: 'いちゃもん',
    22: 'しおづけ',
    23: 'かなしばりが解けた',
    24: 'でんじふゆう終了',
    25: 'テレキネシス終了',
    26: 'かいふくふうじ終了',
    27: 'さしおさえ終了',
    28: 'ねむってしまった',
    29: 'ねをはる',
    30: 'さわぐ終了',
    31: 'うちおとす',
    32: 'マジックコート',
    33: 'じゅうでん',
    34: 'あばれる',
//    35: 'がまん',
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
//    46: 'てだすけ',
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
//    57: 'ふんじん',
    58: 'じごくづき',
    59: 'タールショット',
    60: 'たこがため',
    61: 'まもる',
    62: 'あめまみれ',
    63: 'ハロウィン',
    64: 'もりののろい',
  };

  const AilmentEffect(this.id);

  String get displayName => _displayNameMap[id]!;

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
  static const int healBlock = 26;          // かいふくふうじ
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
  static const int candyCandy = 62;         // あめまみれ
  static const int halloween = 63;          // ハロウィン(ゴーストタイプ)
  static const int forestCurse = 64;        // もりののろい(くさタイプ)

  static const Map<int, Tuple3<String, Color, int>> _nameColorTurnMap = {
    0: Tuple3('', Colors.black, 0),
    1: Tuple3('やけど', PokeTypeColor.fire, 0),
    2: Tuple3('こおり', PokeTypeColor.ice, 0),
    3: Tuple3('まひ', PokeTypeColor.electric, 0),
    4: Tuple3('どく', PokeTypeColor.poison, 0),
    5: Tuple3('もうどく', PokeTypeColor.poison, 0),
    6: Tuple3('ねむり', PokeTypeColor.fly, 4),
    7: Tuple3('こんらん', PokeTypeColor.electric, 0),
    8: Tuple3('のろい', PokeTypeColor.ghost, 0),
    9: Tuple3('アンコール', PokeTypeColor.evil, 3),
    10: Tuple3('ひるみ', PokeTypeColor.evil, 0),
    11: Tuple3('みやぶられている', PokeTypeColor.evil, 0),
    12: Tuple3('メロメロ', PokeTypeColor.fairy, 0),
    13: Tuple3('やどりぎのタネ', PokeTypeColor.grass, 0),
    15: Tuple3('ロックオン', PokeTypeColor.fight, 2),
//    16: Tuple3('あくむ', PokeTypeColor.evil, 0),
    17: Tuple3('バインド', PokeTypeColor.evil, 5),
    18: Tuple3('ほろびのうた', PokeTypeColor.evil, 3),
    19: Tuple3('ちょうはつ', PokeTypeColor.ghost, 4),
    20: Tuple3('いちゃもん', PokeTypeColor.evil, 0),
    22: Tuple3('しおづけ', PokeTypeColor.rock, 0),
    23: Tuple3('かなしばり', PokeTypeColor.ghost, 5),
    24: Tuple3('でんじふゆう', PokeTypeColor.electric, 5),
    25: Tuple3('テレキネシス', PokeTypeColor.psychic, 3),
    26: Tuple3('かいふくふうじ', PokeTypeColor.evil, 5),
    27: Tuple3('さしおさえ', PokeTypeColor.evil, 5),
    28: Tuple3('ねむけ', PokeTypeColor.fly, 0),
    29: Tuple3('ねをはる', PokeTypeColor.grass, 0),
    30: Tuple3('さわぐ', PokeTypeColor.evil, 3),
    31: Tuple3('うちおとす', PokeTypeColor.ground, 0),
    32: Tuple3('マジックコート', PokeTypeColor.psychic, 0),
    33: Tuple3('じゅうでん', PokeTypeColor.electric, 0),
    34: Tuple3('あばれる', PokeTypeColor.dragon, 0),
//    35: Tuple3('がまん', PokeTypeColor.fight, 0),
    36: Tuple3('みちづれ', PokeTypeColor.ghost, 0),
    37: Tuple3('にげられない', PokeTypeColor.evil, 0),
    38: Tuple3('ちいさくなる', PokeTypeColor.psychic, 0),
    39: Tuple3('そらをとぶ', PokeTypeColor.fly, 0),
    40: Tuple3('あなをほる', PokeTypeColor.ground, 0),
    41: Tuple3('まるくなる', PokeTypeColor.fight, 0),
    42: Tuple3('たくわえる(1)', PokeTypeColor.fight, 0),
    43: Tuple3('たくわえる(2)', PokeTypeColor.fight, 0),
    44: Tuple3('たくわえる(3)', PokeTypeColor.fight, 0),
    45: Tuple3('ちゅうもくのまと', PokeTypeColor.psychic, 0),
//    46: Tuple3('てだすけ', PokeTypeColor.fairy, 0),
    47: Tuple3('ふういん', PokeTypeColor.evil, 0),
    48: Tuple3('おんねん', PokeTypeColor.ghost, 0),
    49: Tuple3('はねやすめ', PokeTypeColor.fly, 0),
    50: Tuple3('ミラクルアイ', PokeTypeColor.psychic, 0),
    51: Tuple3('パワートリック', PokeTypeColor.psychic, 0),
    52: Tuple3('とくせいなし', PokeTypeColor.evil, 0),
    53: Tuple3('アクアリング', PokeTypeColor.water, 0),
    54: Tuple3('ダイビング', PokeTypeColor.water, 0),
    55: Tuple3('シャドーダイブ', PokeTypeColor.ghost, 0),
    56: Tuple3('そうでん', PokeTypeColor.electric, 0),
//    57: Tuple3('ふんじん', PokeTypeColor.rock, 0),
    58: Tuple3('じごくづき', PokeTypeColor.evil, 2),
    59: Tuple3('タールショット', PokeTypeColor.evil, 0),
    60: Tuple3('たこがため', PokeTypeColor.evil, 0),
    61: Tuple3('まもる', Colors.green, 0),
    62: Tuple3('あめまみれ', PokeTypeColor.poison, 3),
    63: Tuple3('ハロウィン', PokeTypeColor.ghost, 0),
    64: Tuple3('もりののろい', PokeTypeColor.grass, 0),
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
    if (_nameColorTurnMap[id]!.item3 > 0) extraStr = ' ($turns/?)';
    switch (id) {
      case Ailment.badPoison:
        extraStr = ' (${(turns + 1).clamp(1, 15)}';
        break;
      case Ailment.sleep:
        extraStr = ' ($turns/${extraArg1 == 3 ? '3' : '2～4'})';
        break;
      case Ailment.confusion:
        extraStr = ' ($turns/2～5)';
        break;
      case Ailment.disable:
        extraStr = '(${pokeData.moves[extraArg1]!.displayName}) ($turns/4～5)';
        break;
      case Ailment.encore:
        extraStr = '(${pokeData.moves[extraArg1]!.displayName}) ($turns/3)';
        break;
      case Ailment.partiallyTrapped:
        extraStr = ' ($turns/${extraArg1 % 10 == 7 ? '7' : '4～5'})';
        break;
    }
    return _nameColorTurnMap[id]!.item1 + extraStr;
  }
  Color get bgColor => _nameColorTurnMap[id]!.item2;
  int get maxTurn {
    int ret = _nameColorTurnMap[id]!.item3;
    if (id == sleep && extraArg1 == 3) ret = 3;
    if (id == partiallyTrapped && extraArg1 % 10 == 7) ret = 7;
    return ret;
  }

  // 発動するタイミング・条件かどうかを返す
  bool isActive(bool isMe, AbilityTiming timing, PokemonState pokemonState, PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case AbilityTiming.beforeMove:    // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return turns >= 4;
          default:
            return false;
        }
      case AbilityTiming.everyTurnEnd:  // ターン終了時に発動する状態変化
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
  bool possiblyActive(AbilityTiming timing, PokemonState pokemonState, PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear: // ポケモン登場時発動する状態変化
        return false;
      case AbilityTiming.beforeMove:    // わざ使用前に発動する状態変化
        switch (id) {
          case confusion:
            return true;
          default:
            return false;
        }
      case AbilityTiming.everyTurnEnd:  // ターン終了時に発動する状態変化
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
    TurnEffect? prevAction, AbilityTiming timing, int turns,
  ) {
    bool isMe = player.id == PlayerType.me;

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
        return isMe ? turns >= 10 ? (myState.pokemon.h.real / 8). floor() : (myState.pokemon.h.real / 6). floor() :
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
    TurnEffect? prevAction, AbilityTiming timing,
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
