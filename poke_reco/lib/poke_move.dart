import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';

enum TurnMoveType {
  none,
  move,
  change,
  surrender,
}

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
  TurnMoveType type = TurnMoveType.none;
  PokeType teraType = PokeType.createFromId(0);   // テラスタルなし
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
    ..type = type
    ..teraType = teraType
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
        case 71:  // すばやさを1段階下げる
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
        case 28:    // 2-3ターン連続でこうげきし、自身はこんらんする
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
        case 8:       // ランダムな相手1体
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
                    child: DropdownButtonFormField<MoveEffectiveness>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '効果',
                      ),
                      items: <DropdownMenuItem<MoveEffectiveness>>[
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
                      onChanged: moveHits[0] != MoveHit.notHit ? (value) {
                        moveEffectiveness = value as MoveEffectiveness;
                        setState();
                      } : null,
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
                      numberFieldDecoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: playerType == PlayerType.me ? 
                          '${opponentPokemon.name}の残りHP' : '${ownPokemon.name}の残りHP',
                      ),
                      widgetContainerDecoration: const BoxDecoration(
                        border: null,
                      ),
                      initialValue: playerType == PlayerType.me ? opponentPokemonState.hpPercent : ownPokemonState.hp,
                      min: 0,
                      max: playerType == PlayerType.me ? 100 : ownPokemon.h.real,
                      enabled: moveHits[0] != MoveHit.notHit,
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
    type = TurnMoveType.none;
    teraType = PokeType.createFromId(0);
    move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
    isSuccess = true;
    moveHits = [MoveHit.hit];
    moveEffectiveness = MoveEffectiveness.normal;
    realDamage = 0;
    percentDamage = 0;
    moveAdditionalEffect = MoveAdditionalEffect.none;
    changePokemonIndex = null;
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnMove deserialize(dynamic str, String split1, String split2) {
    TurnMove turnMove = TurnMove();
    final turnMoveElements = str.split(split1);
    // playerType
    switch (int.parse(turnMoveElements[0])) {
      case 1:
        turnMove.playerType = PlayerType.me;
        break;
      case 2:
        turnMove.playerType = PlayerType.opponent;
        break;
      case 3:
        turnMove.playerType = PlayerType.entireField;
        break;
      default:
        turnMove.playerType = PlayerType.none;
        break;
    }
    // type
    switch (int.parse(turnMoveElements[1])) {
      case 1:
        turnMove.type = TurnMoveType.move;
        break;
      case 2:
        turnMove.type = TurnMoveType.change;
        break;
      case 3:
        turnMove.type = TurnMoveType.surrender;
        break;
      case 0:
      default:
        turnMove.type = TurnMoveType.none;
        break;
    }
    // teraType
    turnMove.teraType = PokeType.createFromId(int.parse(turnMoveElements[2]));
    // move
    var moveElements = turnMoveElements[3].split(split2);
    turnMove.move = Move(
      int.parse(moveElements[0]),
      moveElements[1],
      PokeType.createFromId(int.parse(moveElements[2])),
      int.parse(moveElements[3]),
      int.parse(moveElements[4]),
      int.parse(moveElements[5]),
      Target(int.parse(moveElements[6])),
      DamageClass(int.parse(moveElements[7])),
      MoveEffect(int.parse(moveElements[8])),
      int.parse(moveElements[9]),
      int.parse(moveElements[10]),
    );
    // isSuccess
    turnMove.isSuccess = int.parse(turnMoveElements[4]) != 0;
    // moveHits
    var moveHits = turnMoveElements[5].split(split2);
    for (var moveHitsElement in moveHits) {
      if (moveHitsElement == '') break;
      MoveHit t = MoveHit.hit;
      if (int.parse(moveHitsElement) == 1) {
        t = MoveHit.critical;
      }
      else if (int.parse(moveHitsElement) == 2) {
        t = MoveHit.notHit;
      }
      turnMove.moveHits.add(t);
    }
    // moveEffectiveness
    switch (int.parse(turnMoveElements[6])) {
      case 1:
        turnMove.moveEffectiveness = MoveEffectiveness.great;
        break;
      case 2:
        turnMove.moveEffectiveness = MoveEffectiveness.notGood;
        break;
      case 3:
        turnMove.moveEffectiveness = MoveEffectiveness.noEffect;
        break;
      default:
        turnMove.moveEffectiveness = MoveEffectiveness.normal;
        break;
    }
    // realDamage
    turnMove.realDamage = int.parse(turnMoveElements[7]);
    // percentDamage
    turnMove.percentDamage = int.parse(turnMoveElements[8]);
    // moveAdditionalEffect
    switch (int.parse(turnMoveElements[9])) {
      case 1:
        turnMove.moveAdditionalEffect = MoveAdditionalEffect.speedDown;
        break;
      default:
        turnMove.moveAdditionalEffect = MoveAdditionalEffect.none;
        break;
    }
    // changePokemonIndex
    if (turnMoveElements[10] != '') {
      turnMove.changePokemonIndex = int.parse(turnMoveElements[10]);
    }

    return turnMove;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
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
    // type
    switch (type) {
      case TurnMoveType.move:
        ret += '1';
        ret += split1;
        break;
      case TurnMoveType.change:
        ret += '2';
        ret += split1;
        break;
      case TurnMoveType.surrender:
        ret += '3';
        ret += split1;
        break;
      case TurnMoveType.none:
      default:
        ret += '0';
        ret += split1;
        break;
    }
    // teraType
    ret += teraType.id.toString();
    ret += split1;
    // move
      // id
      ret += move.id.toString();
      ret += split2;
      // displayName
      ret += move.displayName;
      ret += split2;
      // type
      ret += move.type.id.toString();
      ret += split2;
      // power
      ret += move.power.toString();
      ret += split2;
      // accuracy
      ret += move.accuracy.toString();
      ret += split2;
      // priority
      ret += move.priority.toString();
      ret += split2;
      // target
      ret += move.target.id.toString();
      ret += split2;
      // damageClass
      ret += move.damageClass.id.toString();
      ret += split2;
      // effect
      ret += move.effect.id.toString();
      ret += split2;
      // effectChance
      ret += move.effectChance.toString();
      ret += split2;
      // pp
      ret += move.pp.toString();

    ret += split1;
    // isSuccess
    ret += isSuccess ? '1' : '0';
    ret += split1;
    // moveHits
    for (final moveHit in moveHits) {
      switch (moveHit) {
        case MoveHit.critical:
          ret += '1';
          break;
        case MoveHit.notHit:
          ret += '2';
          break;
        default:
          ret += '0';
          break;
      }
      ret += split2;
    }
    ret += split1;
    // moveEffectiveness
    switch (moveEffectiveness) {
      case MoveEffectiveness.great:
        ret += '1';
        break;
      case MoveEffectiveness.notGood:
        ret += '2';
        break;
      case MoveEffectiveness.noEffect:
        ret += '3';
        break;
      default:
        ret += '0';
        break;
    }
    ret += split1;
    // realDamage
    ret += realDamage.toString();
    ret += split1;
    // percentDamage
    ret += percentDamage.toString();
    ret += split1;
    // moveAdditionalEffect
    switch (moveAdditionalEffect) {
      case MoveAdditionalEffect.speedDown:
        ret += '1';
        break;
      default:
        ret += '0';
        break;
    }
    ret += split1;
    // changePokemonIndex
    if (changePokemonIndex != null) {
      ret += changePokemonIndex.toString();
    }

    return ret;
  }

  bool isValid() {
    switch (type) {
      case TurnMoveType.move:
        return
        playerType != PlayerType.none &&
        move.id != 0;
      case TurnMoveType.change:
        return changePokemonIndex != null;
      case TurnMoveType.surrender:
        return true;
      default:
        return false;
    }
  }
}