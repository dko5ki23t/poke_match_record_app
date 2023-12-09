// 各々の場

import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

// 各々の場による効果(TurnEffectのeffectIdに使用する定数を提供)
class IndiFieldEffect {
  static const int none = 0;
  static const int toxicSpikes = 1;       // どくびし
  static const int spikes1 = 2;           // まきびし(重ね掛けなし)
  static const int stealthRock = 3;       // ステルスロック
  static const int stickyWeb = 4;         // ねばねばネット
  static const int healingWish = 5;       // いやしのねがい
  static const int lunarDance = 6;        // みかづきのまい
  static const int badToxicSpikes = 7;    // どくどくびし
  static const int futureAttack = 8;      // みらいにこうげき
  static const int wish = 10;             // ねがいごと
  static const int reflectorEnd = 12;     // リフレクター終了
  static const int lightScreenEnd = 13;   // ひかりのかべ終了
  static const int safeGuardEnd = 14;     // しんぴのまもり終了
  static const int mistEnd = 15;          // しろいきり
  static const int tailwindEnd = 16;      // おいかぜ終了
  //static const int luckyChant = 17;       // おまじない
  static const int auroraVeilEnd = 18;    // オーロラベール終了
  static const int gravityEnd = 19;       // じゅうりょく終了
  static const int trickRoomEnd = 20;     // トリックルーム終了
  static const int waterSportEnd = 21;    // みずあそび終了
  static const int mudSportEnd = 22;      // どろあそび終了
  static const int wonderRoomEnd = 23;    // ワンダールーム
  static const int magicRoomEnd = 24;     // マジックルーム
  static const int ionDeluge = 25;        // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLockEnd = 26;     // フェアリーロック終了
  static const int spikes2 = 27;            // まきびし(重ね掛け2回)
  static const int spikes3 = 28;            // まきびし(重ね掛け3回)

  static const _displayNameMap = {
    0: '',
    1: 'どくをあびた',
    2: 'まきびし',
    3: 'ステルスロック',
    4: 'ねばねばネット',
    5: 'いやしのねがい',
    6: 'みかづきのまい',
    7: 'もうどくをあびた',
    10: 'ねがいごと',
    12: 'リフレクターがなくなった',
    13: 'ひかりのかべがなくなった',
    14: 'しんぴのまもり終了',
    15: 'しろいきりが消えた',
    16: 'おいかぜがやんだ',
    18: 'オーロラベールがなくなった',
    19: 'じゅうりょく終了',
    20: 'トリックルーム終了',   // ゆがんだ時空がもとにもどった
    21: 'みずあそび終了',
    22: 'どろあそび終了',
    23: 'ワンダールーム終了',
    24: 'マジックルーム終了',
    26: 'フェアリーロック終了',
    27: 'まきびし',
    28: 'まきびし',
  };

  const IndiFieldEffect(this.id);

  String get displayName => _displayNameMap[id]!;

  static int getIdFromIndiField(IndividualField field) {
    switch (field.id) {
      case IndividualField.toxicSpikes:
        if (field.extraArg1 >= 2) {return badToxicSpikes;}
        break;
      case IndividualField.spikes:
        if (field.extraArg1 >= 3) {return spikes3;}
        if (field.extraArg1 >= 2) {return spikes2;}
        break;
      default:
        break;
    }
    return field.id;
  }

  final int id;
}

class IndividualField {
  static const int none = 0;
  static const int toxicSpikes = 1;       // どくびし (extraArg1 <= 1ならどくびし、2以上ならどくどくびしを表す)
  static const int spikes = 2;            // まきびし (extraArg1に重ね掛けした回数を保持。最大3回まで重ね掛け可)
  static const int stealthRock = 3;       // ステルスロック
  static const int stickyWeb = 4;         // ねばねばネット
  static const int healingWish = 5;       // いやしのねがい
  static const int lunarDance = 6;        // みかづきのまい
  static const int futureAttack = 8;      // みらいにこうげき(TODO? このダメージによりもちものやとくせいは発動し得るが、ユーザが選択できる候補には入れていない)
  static const int wish = 10;             // ねがいごと
  static const int reflector = 12;        // リフレクター(extraArg1に持続ターン数を保持(わかる範囲で))
  static const int lightScreen = 13;      // ひかりのかべ(extraArg1に持続ターン数を保持(わかる範囲で))
  static const int safeGuard = 14;        // しんぴのまもり
  static const int mist = 15;             // しろいきり
  static const int tailwind = 16;         // おいかぜ
//  static const int luckyChant = 17;       // おまじない(SVで使用不可)
  static const int auroraVeil = 18;       // オーロラベール
  static const int gravity = 19;          // じゅうりょく
  static const int trickRoom = 20;        // トリックルーム
  static const int waterSport = 21;       // みずあそび
  static const int mudSport = 22;         // どろあそび
  static const int wonderRoom = 23;       // ワンダールーム
  static const int magicRoom = 24;        // マジックルーム   // TODO
  static const int ionDeluge = 25;        // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLock = 26;        // フェアリーロック

  static const Map<int, Tuple3<String, Color, int>> _nameColorTurnMap = {
    0: Tuple3('', Colors.black, 0),
    1: Tuple3('どくびし', PokeTypeColor.poison, 0),
    2: Tuple3('まきびし', PokeTypeColor.rock, 0),
    3: Tuple3('ステルスロック', PokeTypeColor.rock, 0),
    4: Tuple3('ねばねばネット', PokeTypeColor.bug, 0),
    5: Tuple3('いやしのねがい', Colors.green, 0),
    6: Tuple3('みかづきのまい', Colors.green, 0),
    8: Tuple3('みらいにこうげき', PokeTypeColor.psychic, 3),
    10: Tuple3('ねがいごと', Colors.green, 2),
    12: Tuple3('リフレクター', Colors.green, 5),
    13: Tuple3('ひかりのかべ', Colors.green, 5),
    14: Tuple3('しんぴのまもり', Colors.green, 5),
    15: Tuple3('しろいきり', Colors.green, 5),
    16: Tuple3('おいかぜ', Colors.green, 4),
//    17: Tuple3('おまじない', Colors.green, 0),
    18: Tuple3('オーロラベール', Colors.green, 5),
    19: Tuple3('じゅうりょく', PokeTypeColor.psychic, 5),
    20: Tuple3('トリックルーム', PokeTypeColor.psychic, 5),
    21: Tuple3('みずあそび', PokeTypeColor.water, 5),
    22: Tuple3('どろあそび', PokeTypeColor.ground, 5),
    23: Tuple3('ワンダールーム', PokeTypeColor.psychic, 5),
    24: Tuple3('マジックルーム', PokeTypeColor.psychic, 5),
    25: Tuple3('プラズマシャワー', PokeTypeColor.electric, 0),
    26: Tuple3('フェアリーロック', PokeTypeColor.fairy, 2),
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  IndividualField(this.id);

  IndividualField copyWith() =>
    IndividualField(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName {
    String extraStr = '';
    switch (id) {
      case toxicSpikes:
        extraStr = extraArg1 >= 2 ? '(もうどく)' : '(どく)';
        break;
      case spikes:
        extraStr = extraArg1 > 0 ? '($extraArg1)' : '';
        break;
      default:
        break;
    }
    if (maxTurn > 0) {
      extraStr += ' ($turns/$maxTurn)';
    }
    return _nameColorTurnMap[id]!.item1 + extraStr;
  }
  Color get bgColor => _nameColorTurnMap[id]!.item2;
  int get maxTurn {
    int ret = _nameColorTurnMap[id]!.item3;
    if (id == reflector || id == lightScreen || id == auroraVeil) {
      ret = extraArg1;
    }
    return ret;
  }
  bool get isEntireField {
    return id == gravity || id == trickRoom || id == waterSport || id == mudSport ||
           id == wonderRoom || id == magicRoom || id == ionDeluge || id == fairyLock;
  }

  // 発動するタイミング・条件かどうかを返す
  bool isActive(AbilityTiming timing, PokemonState pokemonState, PhaseState state) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear: // ポケモン登場時発動する場
        var indiField = pokemonState.isMe ? state.ownFields : state.opponentFields;
        switch (id) {
          case healingWish:   // いやしのねがい
            return pokemonState.isMe && (pokemonState.remainHP < pokemonState.pokemon.h.real || pokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty) ||
                   !pokemonState.isMe && (pokemonState.remainHPPercent < 100 || pokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty);
          case lunarDance:    // みかづきのまい
            return pokemonState.isMe && (pokemonState.remainHP < pokemonState.pokemon.h.real || pokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty || pokemonState.usedAnyPP) ||
                   !pokemonState.isMe && (pokemonState.remainHPPercent < 100 || pokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty || pokemonState.usedAnyPP);
          case stealthRock:   // ステルスロック
            return pokemonState.isNotAttackedDamaged &&             // こうげきわざ以外のダメージを負うか
                   pokemonState.holdingItem?.id != Item.atsuzoko;   // あつぞこブーツ
          case toxicSpikes:   // どくびし/どくどくびし
            return pokemonState.isGround(indiField) &&  // 地面にいるか
                   pokemonState.copyWith().ailmentsAdd(Ailment(Ailment.poison), state) && // どくになるかどうか
                   pokemonState.holdingItem?.id != Item.atsuzoko;   // あつぞこブーツ
          case spikes:        // まきびし
            return pokemonState.isGround(indiField) &&
                   pokemonState.isNotAttackedDamaged &&
                   pokemonState.holdingItem?.id != Item.atsuzoko;
          case stickyWeb:     // ねばねばネット
            return pokemonState.isGround(indiField) &&
                   pokemonState.holdingItem?.id != Item.atsuzoko;
          default:
            return false;
        }
      case AbilityTiming.everyTurnEnd:  // ターン経過で終了する場
        return maxTurn > 0 && turns >= maxTurn-1;
      default:
        return false;
    }
  }

  // 発動する可能性のあるタイミング・条件かどうかを返す
  bool possiblyActive(AbilityTiming timing) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear: // ポケモン登場時発動する場
        switch (id) {
          case healingWish:   // いやしのねがい
          case lunarDance:    // みかづきのまい
          case stealthRock:   // ステルスロック
          case toxicSpikes:   // どくびし/どくどくびし
          case spikes:        // まきびし
          case stickyWeb:     // ねばねばネット
            return true;
          default:
            return false;
        }
      case AbilityTiming.everyTurnEnd:  // ターン経過で終了する場
        return maxTurn > 0;
      default:
        return false;
    }
  }

  // TurnEffectのarg1が決定できる場合はその値を返す
  static int getAutoArg1(
    int fieldEffectId, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    bool isMe = player.id == PlayerType.me;

    switch (fieldEffectId) {
      case IndiFieldEffect.spikes1:     // まきびし(重ね掛けなし)
        return isMe ? (myState.pokemon.h.real / 8).floor() : 12;
      case IndiFieldEffect.spikes2:     // まきびし(2回重ね掛け)
        return isMe ? (myState.pokemon.h.real / 6).floor() : 16;
      case IndiFieldEffect.spikes3:     // まきびし(3回重ね掛け)
        return isMe ? (myState.pokemon.h.real / 4).floor() : 25;
      case IndiFieldEffect.stealthRock: // ステルスロック
        {
          var rate = PokeType.effectivenessRate(
            false, false, false, PokeType.createFromId(PokeTypeId.rock), myState) / 8;
          return isMe ? (myState.pokemon.h.real * rate).floor() : (100 * rate).floor();
        }
      default:
        break;
    }

    return 0;
  }

  // TurnEffectのarg2が決定できる場合はその値を返す
  static int getAutoArg2(
    int fieldEffectId, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    return 0;
  }
  
  // SQLに保存された文字列からIndividualFieldをパース
  static IndividualField deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return IndividualField(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}
