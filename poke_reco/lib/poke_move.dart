import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

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
  fail,
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

class ActionFailure {
  static const int none = 0;
  static const int recoil = 1;        // わざの反動
  static const int sleep = 2;         // ねむり(カウント消費)
  static const int freeze = 3;        // こおり(回復判定で失敗)
  static const int pp = 4;            // PPが残っていない
  static const int lazy = 5;          // なまけ(カウント消費(反動で動けなくても消費はする))
  static const int focusPunch = 6;    // きあいパンチ使用時、そのターンにダメージを受けていて動けない
  static const int flinch = 7;        // ひるみ
  static const int disable = 8;       // かなしばり
  static const int gravity = 9;       // じゅうりょく
  static const int healBlock = 10;    // かいふくふうじ
  static const int throatChop = 11;   // じごくづき
  static const int choice = 12;       // こだわり
  static const int taunt = 13;        // ちょうはつ
  static const int imprison = 14;     // ふういん
  static const int confusion = 15;    // こんらんにより自傷
  static const int paralysis = 16;    // まひ
  static const int infatuation = 17;  // メロメロ
  static const int size = 18;

  static const _displayNameMap = {
    0: '',
    1: 'わざの反動',
    2: 'ねむり',
    3: 'こおり',
    4: 'PPが残っていない',
    5: 'なまけ',
    6: 'きあいパンチ中にダメージを受けた',
    7: 'ひるみ',
    8: 'かなしばり',
    9: 'じゅうりょく',
    10: 'かいふくふうじ',
    11: 'じごくづき',
    12: 'こだわり中以外のわざを使った',
    13: 'ちょうはつ',
    14: 'ふういん',
    15: 'こんらん',
    16: 'まひ',
    17: 'メロメロ'
  };

  String get displayName => _displayNameMap[id]!;

  const ActionFailure(this.id);

  final int id;
}

class TurnMove {
  PlayerType playerType = PlayerType.none;
  TurnMoveType type = TurnMoveType.none;
  PokeType teraType = PokeType.createFromId(0);   // テラスタルなし
  Move move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
  bool isSuccess = true;      // 行動の成功/失敗
  ActionFailure actionFailure = ActionFailure(0);    // 行動失敗の理由
  List<MoveHit> moveHits = [MoveHit.hit];   // 命中した/急所/外した
  List<MoveEffectiveness> moveEffectivenesses = [MoveEffectiveness.normal];   // こうかは(テキスト無し)/ばつぐん/いまひとつ/なし
  int realDamage = 0;     // わざによって受けたダメージ（確定値）
  int percentDamage = 0;  // わざによって与えたダメージ（概算値、割合）
  List<MoveAdditionalEffect> moveAdditionalEffects = [MoveAdditionalEffect.none];
  int? changePokemonIndex;

  TurnMove copyWith() =>
    TurnMove()
    ..playerType = playerType
    ..type = type
    ..teraType = teraType
    ..move = move.copyWith()
    ..isSuccess = isSuccess
    ..actionFailure = actionFailure
    ..moveHits = [...moveHits]
    ..moveEffectivenesses = [...moveEffectivenesses]
    ..realDamage = realDamage
    ..percentDamage = percentDamage
    ..moveAdditionalEffects = [...moveAdditionalEffects]
    ..changePokemonIndex = changePokemonIndex;

  void processMove(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentPokemon,
    PokemonState opponentPokemonState,
    PhaseState state,
    int continousCount,
  )
  {
    if (playerType == PlayerType.none) return;

    // ポケモン交換
    if (changePokemonIndex != null) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      if (playerType == PlayerType.me) {
        ownPokemonState.statChanges = List.generate(6, (i) => 0);
        state.ownPokemonIndex = changePokemonIndex!;
      }
      else {
        opponentPokemonState.statChanges = List.generate(6, (i) => 0);
        state.opponentPokemonIndex = changePokemonIndex!;
      }
      return;
    }

    if (move.id == 0) return;

    PokemonState myState = ownPokemonState;
    PokemonState opponentState = opponentPokemonState;
    if (playerType == PlayerType.opponent) {
      myState = opponentPokemonState;
      opponentState = ownPokemonState;
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
        opponentState.remainHP -= realDamage;
        if (opponentState.remainHP < 0) opponentState.remainHP = 0;
        opponentState.remainHPPercent -= percentDamage;
        if (opponentState.remainHPPercent < 0) opponentState.remainHPPercent = 0;
        break;
      case 3:     // とくしゅ
        // ダメージを負わせる
        opponentState.remainHP -= realDamage;
        if (opponentState.remainHP < 0) opponentState.remainHP = 0;
        opponentState.remainHPPercent -= percentDamage;
        if (opponentState.remainHPPercent < 0) opponentState.remainHPPercent = 0;
        break;
      default:
        break;
    }

    // 追加効果
    // 対象の相手
    PokemonState additionalEffectTargetState = opponentState;
    // TODO:追加効果の対象が自分なら変数に代入
    switch (moveAdditionalEffects[continousCount]) {
      case MoveAdditionalEffect.speedDown:
        additionalEffectTargetState.statChanges[4]--;
        break;
      default:
        break;
    }
  }

  Widget extraInputWidget1(
    void Function() onFocus,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    TextEditingController moveController,
    TextEditingController hpController,
    PokeDB pokeData,
    MyAppState appState,
    int processIdx,
  )
  {
    // 行動失敗時
    if (!isSuccess) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '失敗の原因',
              ),
              items: <DropdownMenuItem>[
                for (int i = 1; i < ActionFailure.size; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(ActionFailure(i).displayName, overflow: TextOverflow.ellipsis,),
                ),
              ],
              value: actionFailure.id == 0 ? null : actionFailure.id,
              onChanged: (value) {
                actionFailure = ActionFailure(value);
                appState.editingPhase[processIdx] = true;
                onFocus();
              },
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 5,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: moveController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '使用しようとしたわざ',
                ),
              ),
              autoFlipDirection: true,
              suggestionsCallback: (pattern) async {
                List<Move> matches = [];
                if (playerType == PlayerType.me) {
                  matches.add(ownPokemon.move1);
                  if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                  if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                  if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                }
                else {
                  matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                }
                matches.retainWhere((s){
                  return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                });
                return matches;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.displayName),
                );
              },
              onSuggestionSelected: (suggestion) {
                moveController.text = suggestion.displayName;
                move = suggestion;
                appState.editingPhase[processIdx] = true;
                onFocus();
              },
            ),
          ),
        ],
      );
    }
    // 行動成功時
    else {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<TurnMoveType>(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '行動の種類',
              ),
              items: <DropdownMenuItem<TurnMoveType>>[
                DropdownMenuItem(
                  value: TurnMoveType.move,
                  child: Text('わざ', overflow: TextOverflow.ellipsis,),
                ),
                DropdownMenuItem(
                  value: TurnMoveType.change,
                  child: Text('ポケモン交換', overflow: TextOverflow.ellipsis,),
                ),
                DropdownMenuItem(
                  value: TurnMoveType.surrender,
                  child: Text('こうさん', overflow: TextOverflow.ellipsis,),
                ),
              ],
              value: type == TurnMoveType.none ? null : type,
              onChanged: playerType != PlayerType.none ? (value) {
                type = value!;
                appState.editingPhase[processIdx] = true;
                onFocus();
              } : null,
            ),
          ),
          SizedBox(width: 10,),
          type == TurnMoveType.move ?     // 行動がわざの場合
          Expanded(
            flex: 5,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: moveController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'わざ',
                ),
                enabled: playerType != PlayerType.none,
              ),
              autoFlipDirection: true,
              suggestionsCallback: (pattern) async {
                List<Move> matches = [];
                if (playerType == PlayerType.me) {
                  matches.add(ownPokemon.move1);
                  if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                  if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                  if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                }
                else {
                  matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                }
                matches.retainWhere((s){
                  return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                });
                return matches;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.displayName),
                );
              },
              onSuggestionSelected: (suggestion) {
                moveController.text = suggestion.displayName;
                move = suggestion;
                appState.editingPhase[processIdx] = true;
                onFocus();
              },
            ),
          ) :
          type == TurnMoveType.change ?     // 行動が交代の場合
          Expanded(
            flex: 5,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '交換先ポケモン',
              ),
              items: playerType == PlayerType.me ?
                <DropdownMenuItem>[
                  for (int i = 0; i < ownParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i+1,
                      enabled: i+1 != state.ownPokemonIndex,
                      child: Text(ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,),
                    ),
                ] :
                <DropdownMenuItem>[
                  for (int i = 0; i < opponentParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i+1,
                      enabled: i+1 != state.opponentPokemonIndex,
                      child: Text(opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,),
                    ),
                ],
              value: changePokemonIndex,
              onChanged: (value) {
                changePokemonIndex = value;
                appState.editingPhase[processIdx] = true;
                onFocus();
              },
            ),
          ) :
          // 行動がにげる/こうさんのとき
          Container(),
        ],
      );
    }
  }

  Widget extraInputWidget2(
    void Function() onFocus,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    TextEditingController hpController,
    MyAppState appState,
    int processIdx,
    int continousCount,
  )
  {
    if (playerType != PlayerType.none && type == TurnMoveType.move) {
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
                  value: moveAdditionalEffects[continousCount],
                  onChanged: (value) {
                    moveAdditionalEffects[continousCount] = value;
                    appState.editingPhase[processIdx] = true;
                    onFocus();
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
                    appState.editingPhase[processIdx] = true;
                    onFocus();
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
                        labelText: '命中/失敗',
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
                        DropdownMenuItem(
                          value: MoveHit.fail,
                          child: Text('うまく決まらなかった'),
                        ),
                      ],
                      value: moveHits[continousCount],
                      onChanged: (value) {
                        moveHits[continousCount] = value;
                        appState.editingPhase[processIdx] = true;
                        onFocus();
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
                      value: moveEffectivenesses[continousCount],
                      onChanged: moveHits[continousCount] != MoveHit.notHit && moveHits[continousCount] != MoveHit.fail ? (value) {
                        moveEffectivenesses[continousCount] = value as MoveEffectiveness;
                        appState.editingPhase[processIdx] = true;
                        onFocus();
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
                      initialValue: playerType == PlayerType.me ? opponentPokemonState.remainHPPercent : ownPokemonState.remainHP,
                      min: 0,
                      max: playerType == PlayerType.me ? 100 : ownPokemon.h.real,
                      enabled: moveHits[continousCount] != MoveHit.notHit && moveHits[continousCount] != MoveHit.fail,
                      onIncrement: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.remainHPPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.remainHP - value) as int;
                        }
                        appState.editingPhase[processIdx] = true;
                        onFocus();
                      },
                      onDecrement: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.remainHPPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.remainHP - value) as int;
                        }
                        appState.editingPhase[processIdx] = true;
                        onFocus();
                      },
                      onChanged: (value) {
                        if (playerType == PlayerType.me) {
                          percentDamage = (opponentPokemonState.remainHPPercent - value) as int;
                        }
                        else {
                          realDamage = (ownPokemonState.remainHP - value) as int;
                        }
                        appState.editingPhase[processIdx] = true;
                        onFocus();
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
    moveEffectivenesses = [MoveEffectiveness.normal];
    realDamage = 0;
    percentDamage = 0;
    moveAdditionalEffects = [MoveAdditionalEffect.none];
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
    var moveEffectivenesses = turnMoveElements[6].split(split2);
    turnMove.moveEffectivenesses.clear();
    for (var moveEffectivenessElement in moveEffectivenesses) {
      if (moveEffectivenessElement == '') break;
      MoveEffectiveness t = MoveEffectiveness.normal;
      switch (int.parse(moveEffectivenessElement)) {
        case 1:
          t = MoveEffectiveness.great;
          break;
        case 2:
          t = MoveEffectiveness.notGood;
          break;
        case 3:
          t = MoveEffectiveness.noEffect;
          break;
        default:
          t = MoveEffectiveness.normal;
          break;
      }
      turnMove.moveEffectivenesses.add(t);
    }
    // realDamage
    turnMove.realDamage = int.parse(turnMoveElements[7]);
    // percentDamage
    turnMove.percentDamage = int.parse(turnMoveElements[8]);
    // moveAdditionalEffect
    var moveAdditionalEffects = turnMoveElements[9].split(split2);
    turnMove.moveAdditionalEffects.clear();
    for (var moveAdditionalEffect in moveAdditionalEffects) {
      if (moveAdditionalEffect == '') break;
      MoveAdditionalEffect t = MoveAdditionalEffect.none;
      switch (int.parse(moveAdditionalEffect)) {
        case 1:
          t = MoveAdditionalEffect.speedDown;
          break;
        default:
          t = MoveAdditionalEffect.none;
          break;
      }
      turnMove.moveAdditionalEffects.add(t);
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
    // moveEffectivenesses
    for (final moveEffectiveness in moveEffectivenesses) {
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
      ret += split2;
    }
    ret += split1;
    // realDamage
    ret += realDamage.toString();
    ret += split1;
    // percentDamage
    ret += percentDamage.toString();
    ret += split1;
    // moveAdditionalEffects
    for (final moveAdditionalEffect in moveAdditionalEffects) {
      switch (moveAdditionalEffect) {
        case MoveAdditionalEffect.speedDown:
          ret += '1';
          break;
        default:
          ret += '0';
          break;
      }
      ret += split2;
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