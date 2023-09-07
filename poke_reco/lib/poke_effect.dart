import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

enum EffectType {
  none(0),
  ability(1),
  item(2),
  ;

  const EffectType(this.id);

  final int id;
}

enum PlayerType {
  none(0),
  me(1),            // 自身
  opponent(2),      // 相手
  entireField(3),   // 全体の場(両者に影響あり)
  ;

  const PlayerType(this.id);

  final int id;
}

class TurnEffect {
  PlayerType playerType = PlayerType.none;
  EffectType effect = EffectType.none;
  int effectId = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..effect = effect
    ..effectId = effectId
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2;

  bool isValid() {
    return
      playerType != PlayerType.none &&
      effect != EffectType.none &&
      effectId > 0;
  }

  void processEffect(
    Pokemon currentOwnPokemon,
    PokemonState currentOwnPokemonState,
    Pokemon currentOpponentPokemon,
    PokemonState currentOpponentPokemonState,
    Turn turn,
  )
  {
    if (effect == EffectType.ability) {
      switch (effectId) {
        case 22:   // いかく
          if (playerType == PlayerType.me) {
            currentOpponentPokemonState.statChanges[0]--;
          }
          else {
            currentOwnPokemonState.statChanges[0]--;
          }
          break;
        default:
          break;
      }
    }
  }

  Widget extraInputWidget(
    void Function() setState,
  )
  {
    if (effect == EffectType.ability) {   // とくせいによる効果
      switch (effectId) {
        case 281:     // こだいかっせい
        case 282:     // クォークチャージ
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('こうげき'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('ぼうぎょ'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('とくこう'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('とくぼう'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('すばやさ'),
                    ),
                  ],
                  value: extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    setState();
                  },
                ),
              ),
              Text('があがった'),
            ],
          );
        default:
          break;
      }
    }

    return Container();
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnEffect deserialize(dynamic str, String split1) {
    TurnEffect effect = TurnEffect();
    final effectElements = str.split(split1);
    // playerType
    switch (int.parse(effectElements[0])) {
      case 1:
        effect.playerType = PlayerType.me;
        break;
      case 2:
        effect.playerType = PlayerType.opponent;
        break;
      case 3:
        effect.playerType = PlayerType.entireField;
        break;
      default:
        effect.playerType = PlayerType.none;
        break;
    }
    // effect
    switch (int.parse(effectElements[1])) {
      case 1:
        effect.effect = EffectType.ability;
        break;
      case 2:
        effect.effect = EffectType.item;
        break;
      default:
        effect.effect = EffectType.none;
        break;
    }
    // effectId
    effect.effectId = int.parse(effectElements[2]);
    // extraArg1
    effect.extraArg1 = int.parse(effectElements[3]);
    // extraArg2
    effect.extraArg2 = int.parse(effectElements[4]);

    return effect;
  }

   // SQL保存用の文字列に変換
  String serialize(String split1) {
    String ret = '';
    // playerType
    switch (playerType) {
      case PlayerType.me:
        ret += '1';
        ret += split1;
        break;
      case PlayerType.opponent:
        ret += '2';
        ret += split1;
        break;
      case PlayerType.entireField:
        ret += '3';
        ret += split1;
        break;
      default:
        ret += '0';
        ret += split1;
        break;
    }
    // effect
    switch (effect) {
      case EffectType.ability:
        ret += '1';
        ret += split1;
        break;
      case EffectType.item:
        ret += '2';
        ret += split1;
        break;
      default:
        ret += '0';
        ret += split1;
        break;
    }
    // effectId
    ret += effectId.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }

  static void swap(List<TurnEffect> list, int idx1, int idx2) {
    TurnEffect tmp = list[idx1].copyWith();
    list[idx1] = list[idx2].copyWith();
    list[idx2] = tmp;
  }
}