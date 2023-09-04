import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/poke_db.dart';

enum MoveHit {
  hit,
  critical,
  notHit,
}

enum MoveEffectiveness {
  normal,
  great,
  notGood,
  noEffect,
}

enum MoveAdditionalEffect {
  none,
  speedDown,
}

class TurnMove {
  PlayerType playerType = PlayerType.none;
  Move move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
  bool isSuccess = true;      // へんかわざの成功/失敗
  List<MoveHit> moveHits = [MoveHit.hit];   // 命中した/急所/外した
  MoveEffectiveness moveEffectiveness = MoveEffectiveness.normal;   // こうかは(テキスト無し)/ばつぐん/いまひとつ/なし
  int realDamage = 0;     // わざによって受けたダメージ（確定値）
  int percentDamage = 0;  // わざによって与えたダメージ（概算値、割合）
  MoveAdditionalEffect moveAdditionalEffect = MoveAdditionalEffect.none;
  int? changePokemonIndex;

  TurnMove copyWith() =>
    TurnMove()
    ..playerType = playerType
    ..move = move.copyWith()
    ..isSuccess = isSuccess
    ..moveHits = [...moveHits]
    ..moveEffectiveness = moveEffectiveness
    ..realDamage = realDamage
    ..percentDamage = percentDamage
    ..moveAdditionalEffect = moveAdditionalEffect
    ..changePokemonIndex = changePokemonIndex;

  void processMove(
    Pokemon currentOwnPokemon,
    PokemonState currentOwnPokemonState,
    Pokemon currentOpponentPokemon,
    PokemonState currentOpponentPokemonState,
    Turn turn,
  )
  {
    if (playerType == PlayerType.none) return;

    // ポケモン交換
    if (changePokemonIndex != null) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      if (playerType == PlayerType.me) {
        currentOwnPokemonState.statChanges = List.generate(6, (i) => 0);
        turn.currentOwnPokemonIndex = changePokemonIndex!;
        turn.changedOwnPokemon = true;
      }
      else {
        currentOpponentPokemonState.statChanges = List.generate(6, (i) => 0);
        turn.currentOpponentPokemonIndex = changePokemonIndex!;
        turn.changedOpponentPokemon = true;
      }
      return;
    }

    if (move.id == 0) return;

    PokemonState myState = currentOwnPokemonState;
    PokemonState opponentState = currentOpponentPokemonState;
    if (playerType == PlayerType.opponent) {
      myState = currentOpponentPokemonState;
      opponentState = currentOwnPokemonState;
    }

    switch (move.damageClass.id) {
      case 1:     // へんか
        switch (move.target.id) {
          case 1:
            break;
          case 2:
            break;
          case 3:
            break;
          case 4:
            break;
          case 5:
            break;
          case 6:
            break;
          case 7:     // 自分自身
            if (isSuccess) {
              switch (move.effect.id) {
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  break;
                case 4:
                  break;
                case 5:
                  break;
                case 6:
                  break;
                case 7:
                  break;
                case 8:
                  break;
                case 213:   // こうげきとすばやさを1段階上げる
                  myState.statChanges[0]++;
                  myState.statChanges[4]++;
                  break;
                default:
                  break;
              }
            }
            break;
          case 8:
            break;
          case 9:
            break;
          case 10:
            break;
          case 11:
            break;
          case 12:
            break;
          case 13:
            break;
          case 14:
            break;
          case 15:
            break;
          case 16:
            break;
          default:
            break;
        }
        break;
      case 2:     // ぶつり
        // ダメージを負わせる
        opponentState.hp -= realDamage;
        if (opponentState.hp < 0) opponentState.hp = 0;
        opponentState.hpPercent -= percentDamage;
        if (opponentState.hpPercent < 0) opponentState.hpPercent = 0;
        break;
      case 3:     // とくしゅ
        // ダメージを負わせる
        opponentState.hp -= realDamage;
        if (opponentState.hp < 0) opponentState.hp = 0;
        opponentState.hpPercent -= percentDamage;
        if (opponentState.hpPercent < 0) opponentState.hpPercent = 0;
        break;
      default:
        break;
    }

    // 追加効果
    // 対象の相手
    PokemonState additionalEffectTargetState = opponentState;
    // TODO:追加効果の対象が自分なら変数に代入
    switch (moveAdditionalEffect) {
      case MoveAdditionalEffect.speedDown:
        additionalEffectTargetState.statChanges[4]--;
        break;
      default:
        break;
    }
  }

  Widget extraInputWidget(
    void Function() setState,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    TextEditingController hpController,
  )
  {
    if (playerType != PlayerType.none && move.id != 0) {
      // 追加効果
      Row effectInputRow = Row();
      switch (move.effect.id) {
        case 71:
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveAdditionalEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: MoveAdditionalEffect.speedDown,
                      child: Text('すばやさが下がった'),
                    ),
                  ],
                  value: moveAdditionalEffect,
                  onChanged: (value) {
                    moveAdditionalEffect = value;
                    setState();
                  },
                ),
              ),
            ],
          );
          break;
        case 148:   // 相手が「あなをほる」状態でも命中し、ダメージ2倍
        default:
          break;
      }

      switch (move.target.id) {
        case 7:   // 自分自身 -> 成功/失敗
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '成否',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: true,
                      child: Text('成功'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('うまくきまらなかった！'),
                    ),
                  ],
                  value: isSuccess,
                  onChanged: (value) {
                    isSuccess = value;
                    setState();
                  },
                ),
              ),
            ],
          );
        case 9:       // 場の他のポケモン全員
        case 10:      // 選択した相手
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '命中',
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: MoveHit.hit,
                          child: Text('命中'),
                        ),
                        DropdownMenuItem(
                          value: MoveHit.critical,
                          child: Text('急所に命中'),
                        ),
                        DropdownMenuItem(
                          value: MoveHit.notHit,
                          child: Text('当たらなかった'),
                        ),
                      ],
                      value: moveHits[0],
                      onChanged: (value) {
                        moveHits[0] = value;
                        setState();
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '効果',
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: MoveEffectiveness.normal,
                          child: Text('（テキストなし）', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: MoveEffectiveness.great,
                          child: Text('ばつぐんだ', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: MoveEffectiveness.notGood,
                          child: Text('いまひとつのようだ', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: MoveEffectiveness.noEffect,
                          child: Text('ないようだ', overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                      value: moveEffectiveness,
                      onChanged: (value) {
                        moveEffectiveness = value;
                        setState();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              effectInputRow,
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: NumberInputWithIncrementDecrement(
                      controller: hpController,
                      numberFieldDecoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'HP'
                      ),
                      widgetContainerDecoration: const BoxDecoration(
                        border: null,
                      ),
                      initialValue: playerType == PlayerType.me ? opponentPokemonState.hpPercent : ownPokemonState.hp,
                      min: 0,
                      max: playerType == PlayerType.me ? 100 : ownPokemon.h.real,
                      onIncrement: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.hpPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.hp - value) as int;
                        }
                      },
                      onDecrement: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.hpPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.hp - value) as int;
                        }
                      },
                      onChanged: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.hpPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.hp - value) as int;
                        }
                      },
                    ),
                  ),
                  playerType == PlayerType.me ?
                  Text('% /100%') :
                  Text('/${ownPokemon.h.real}')
                ],
              ),
            ],
          );
        default:
          break;
      }
    }

    return Container();
  }

  void clear() {
    playerType = PlayerType.none;
    move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
  }

  bool isValid() {
    // ポケモン交換なら
    if (changePokemonIndex != null) {
      return true;
    }
    else {
      return
        playerType != PlayerType.none &&
        move.id != 0;
    }
  }
}