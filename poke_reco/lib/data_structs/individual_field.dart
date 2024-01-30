// 各々の場

import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

class IndividualField extends Equatable implements Copyable {
  static const int none = 0;
  static const int toxicSpikes =
      1; // どくびし (extraArg1 <= 1ならどくびし、2以上ならどくどくびしを表す)
  static const int spikes = 2; // まきびし (extraArg1に重ね掛けした回数を保持。最大3回まで重ね掛け可)
  static const int stealthRock = 3; // ステルスロック
  static const int stickyWeb = 4; // ねばねばネット
  static const int healingWish = 5; // いやしのねがい
  static const int lunarDance = 6; // みかづきのまい
  static const int futureAttack =
      8; // みらいにこうげき(TODO? このダメージによりもちものやとくせいは発動し得るが、ユーザが選択できる候補には入れていない)
  static const int wish = 10; // ねがいごと
  static const int reflector = 12; // リフレクター(extraArg1に持続ターン数を保持(わかる範囲で))
  static const int lightScreen = 13; // ひかりのかべ(extraArg1に持続ターン数を保持(わかる範囲で))
  static const int safeGuard = 14; // しんぴのまもり
  static const int mist = 15; // しろいきり
  static const int tailwind = 16; // おいかぜ
//  static const int luckyChant = 17;       // おまじない(SVで使用不可)
  static const int auroraVeil = 18; // オーロラベール
  static const int gravity = 19; // じゅうりょく
  static const int trickRoom = 20; // トリックルーム
  static const int waterSport = 21; // みずあそび
  static const int mudSport = 22; // どろあそび
  static const int wonderRoom = 23; // ワンダールーム
  static const int magicRoom = 24; // マジックルーム
  static const int ionDeluge = 25; // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLock = 26; // フェアリーロック
  static const int noBerry = 27; // きのみを食べられない状態(きんちょうかん)

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap =
      {
    0: Tuple4('', '', Colors.black, 0),
    1: Tuple4('どくびし', 'Toxic Spikes', PokeTypeColor.poison, 0),
    2: Tuple4('まきびし', 'Spikes', PokeTypeColor.rock, 0),
    3: Tuple4('ステルスロック', 'Stealth Rock', PokeTypeColor.rock, 0),
    4: Tuple4('ねばねばネット', 'Sticky Web', PokeTypeColor.bug, 0),
    5: Tuple4('いやしのねがい', 'Healing Wish', Colors.green, 0),
    6: Tuple4('みかづきのまい', 'Lunar Dance', Colors.green, 0),
    8: Tuple4('みらいにこうげき', 'Future Sight', PokeTypeColor.psychic, 3),
    10: Tuple4('ねがいごと', 'Wish', Colors.green, 2),
    12: Tuple4('リフレクター', 'Reflector', Colors.green, 5),
    13: Tuple4('ひかりのかべ', 'Light Screen', Colors.green, 5),
    14: Tuple4('しんぴのまもり', 'Safe Guard', Colors.green, 5),
    15: Tuple4('しろいきり', 'Mist', Colors.green, 5),
    16: Tuple4('おいかぜ', 'Tailwind', Colors.green, 4),
//    17: Tuple4('おまじない', 'Lucky Chant', Colors.green, 0),
    18: Tuple4('オーロラベール', 'Aurora Veil', Colors.green, 5),
    19: Tuple4('じゅうりょく', 'Gravity', PokeTypeColor.psychic, 5),
    20: Tuple4('トリックルーム', 'Trick Room', PokeTypeColor.psychic, 5),
    21: Tuple4('みずあそび', 'Water Sport', PokeTypeColor.water, 5),
    22: Tuple4('どろあそび', 'Mud Sport', PokeTypeColor.ground, 5),
    23: Tuple4('ワンダールーム', 'Wonder Room', PokeTypeColor.psychic, 5),
    24: Tuple4('マジックルーム', 'Magic Room', PokeTypeColor.psychic, 5),
    25: Tuple4('プラズマシャワー', 'Ion Deluge', PokeTypeColor.electric, 0),
    26: Tuple4('フェアリーロック', 'Fairy Lock', PokeTypeColor.fairy, 2),
    27: Tuple4('きのみを食べられない状態', 'Cannot eat berrys', PokeTypeColor.evil, 0),
  };

  final int id;
  int turns = 0; // 経過ターン
  int extraArg1 = 0; //

  @override
  List<Object?> get props => [
        id,
        turns,
        extraArg1,
      ];

  IndividualField(this.id);

  @override
  IndividualField copy() => IndividualField(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName {
    String extraStr = '';
    switch (id) {
      case toxicSpikes:
        switch (PokeDB().language) {
          case Language.japanese:
            extraStr = extraArg1 >= 2 ? '(もうどく)' : '(どく)';
            break;
          case Language.english:
          default:
            extraStr = extraArg1 >= 2 ? '(Bad Poison)' : '(Poison)';
            break;
        }
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
    if (id == reflector || id == lightScreen || id == auroraVeil) {
      ret = extraArg1;
    }
    return ret;
  }

  bool get isEntireField {
    return id == gravity ||
        id == trickRoom ||
        id == waterSport ||
        id == mudSport ||
        id == wonderRoom ||
        id == magicRoom ||
        id == ionDeluge ||
        id == fairyLock;
  }

  // 発動するタイミング・条件かどうかを返す
  bool isActive(Timing timing, PokemonState pokemonState, PhaseState state) {
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する場
        var indiField = state.getIndiFields(pokemonState.playerType);
        switch (id) {
          case healingWish: // いやしのねがい
            return pokemonState.isMe &&
                    (pokemonState.remainHP < pokemonState.pokemon.h.real ||
                        pokemonState
                            .ailmentsWhere((e) => e.id <= Ailment.sleep)
                            .isNotEmpty) ||
                !pokemonState.isMe &&
                    (pokemonState.remainHPPercent < 100 ||
                        pokemonState
                            .ailmentsWhere((e) => e.id <= Ailment.sleep)
                            .isNotEmpty);
          case lunarDance: // みかづきのまい
            return pokemonState.isMe &&
                    (pokemonState.remainHP < pokemonState.pokemon.h.real ||
                        pokemonState
                            .ailmentsWhere((e) => e.id <= Ailment.sleep)
                            .isNotEmpty ||
                        pokemonState.usedAnyPP) ||
                !pokemonState.isMe &&
                    (pokemonState.remainHPPercent < 100 ||
                        pokemonState
                            .ailmentsWhere((e) => e.id <= Ailment.sleep)
                            .isNotEmpty ||
                        pokemonState.usedAnyPP);
          case stealthRock: // ステルスロック
            return pokemonState.isNotAttackedDamaged && // こうげきわざ以外のダメージを負うか
                pokemonState.holdingItem?.id != Item.atsuzoko; // あつぞこブーツ
          case toxicSpikes: // どくびし/どくどくびし
            return pokemonState.isGround(indiField) && // 地面にいるか
                pokemonState
                    .copy()
                    .ailmentsAdd(Ailment(Ailment.poison), state) && // どくになるかどうか
                pokemonState.holdingItem?.id != Item.atsuzoko; // あつぞこブーツ
          case spikes: // まきびし
            return pokemonState.isGround(indiField) &&
                pokemonState.isNotAttackedDamaged &&
                pokemonState.holdingItem?.id != Item.atsuzoko;
          case stickyWeb: // ねばねばネット
            return pokemonState.isGround(indiField) &&
                pokemonState.holdingItem?.id != Item.atsuzoko;
          default:
            return false;
        }
      case Timing.everyTurnEnd: // ターン経過で終了する場
        return maxTurn > 0 && turns >= maxTurn - 1;
      default:
        return false;
    }
  }

  // 発動する可能性のあるタイミング・条件かどうかを返す
  bool possiblyActive(Timing timing) {
    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時発動する場
        switch (id) {
          case healingWish: // いやしのねがい
          case lunarDance: // みかづきのまい
          case stealthRock: // ステルスロック
          case toxicSpikes: // どくびし/どくどくびし
          case spikes: // まきびし
          case stickyWeb: // ねばねばネット
            return true;
          default:
            return false;
        }
      case Timing.everyTurnEnd: // ターン経過で終了する場
        return maxTurn > 0;
      default:
        return false;
    }
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
