import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

class TurnMoveType {
  static const int none = 0;
  static const int move = 1;
  static const int change = 2;
  static const int surrender = 3;

  const TurnMoveType(this.id);

  final int id;
}

class MoveHit {
  static const int hit = 0;
  static const int critical = 1;
  static const int notHit = 2;
  static const int fail = 3;

  const MoveHit(this.id);

  final int id;
}

class MoveEffectiveness {
  static const int normal = 0;
  static const int great = 1;
  static const int notGood = 2;
  static const int noEffect = 3;

  const MoveEffectiveness(this.id);

  final int id;
}

class MoveAdditionalEffect {
  static const int none = 0;
  static const int speedDown = 1;

  const MoveAdditionalEffect(this.id);

  final int id;
}

class ActionFailure {
  // TODO:多い(まだ他にもある)から、何か情報が得られるものに限定したい
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
  PlayerType playerType = PlayerType(PlayerType.none);
  TurnMoveType type = TurnMoveType(TurnMoveType.none);
  PokeType teraType = PokeType.createFromId(0);   // テラスタルなし
  Move move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
  bool isSuccess = true;      // 行動の成功/失敗
  ActionFailure actionFailure = ActionFailure(0);    // 行動失敗の理由
  List<MoveHit> moveHits = [MoveHit(MoveHit.hit)];   // 命中した/急所/外した
  List<MoveEffectiveness> moveEffectivenesses = [MoveEffectiveness(MoveEffectiveness.normal)];   // こうかは(テキスト無し)/ばつぐん/いまひとつ/なし
  List<int> realDamage = [0];     // わざによって受けたダメージ（確定値）
  List<int> percentDamage = [0];  // わざによって与えたダメージ（概算値、割合）
  List<MoveAdditionalEffect> moveAdditionalEffects = [MoveAdditionalEffect(MoveAdditionalEffect.none)];
  int? changePokemonIndex;
  int? targetMyPokemonIndex;   // わざの対象ポケモン

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
    ..realDamage = [...realDamage]
    ..percentDamage = [...percentDamage]
    ..moveAdditionalEffects = [...moveAdditionalEffects]
    ..changePokemonIndex = changePokemonIndex
    ..targetMyPokemonIndex = targetMyPokemonIndex;

  List<String> processMove(
    Party ownParty,
    Party opponentParty,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    PhaseState state,
    int continousCount,
  )
  {
    List<String> ret = [];
    if (playerType.id == PlayerType.none) return ret;

    // こうさん
    if (type.id == TurnMoveType.surrender) {
      if (playerType.id == PlayerType.me) {   // パーティ全員ひんし状態にする
        for (var pokeState in state.ownPokemonStates) {
          pokeState.remainHP = 0;
          pokeState.isFainting = true;
        }
      }
      else if (playerType.id == PlayerType.opponent) {
        for (var pokeState in state.opponentPokemonStates) {
          pokeState.remainHPPercent = 0;
          pokeState.isFainting = true;
        }
      }
      return ret;
    }

    // わざ確定
    var tmp = opponentPokemonState.moves.where(
          (element) => element.id != 0 && element.id == move.id
        );
    if (playerType.id == PlayerType.opponent &&
        type.id == TurnMoveType.move &&
        opponentPokemonState.moves.length < 4 &&
        tmp.isEmpty
    ) {
      opponentPokemonState.moves.add(move);
      ret.add('わざの1つを${move.displayName}で確定しました。');
    }

    // テラスタル
    if (teraType.id != 0) {
      if (playerType.id == PlayerType.me) {
        ownPokemonState.teraType ??= teraType;
      }
      else {
        opponentPokemonState.teraType ??= teraType;
      }
    }

    if (!isSuccess) return ret;

    // ポケモン交代
    if (type.id == TurnMoveType.change) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      if (playerType.id == PlayerType.me) {
        ownPokemonState.statChanges = List.generate(7, (i) => 0);
        ownPokemonState.buffDebuffs.clear();
        ownPokemonState.fields.clear();
        state.ownPokemonIndex = changePokemonIndex!;
      }
      else {
        opponentPokemonState.statChanges = List.generate(7, (i) => 0);
        opponentPokemonState.buffDebuffs.clear();
        opponentPokemonState.fields.clear();
        state.opponentPokemonIndex = changePokemonIndex!;
      }
      return ret;
    }

    if (move.id == 0) return ret;

    PokemonState myState = ownPokemonState;
    PokemonState opponentState = opponentPokemonState;
    if (playerType.id == PlayerType.opponent) {
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
          case 16:    // ひんしの(味方)ポケモン
            if (move.id == 863) {   // TODO さいきのいのり
              if (targetMyPokemonIndex == null) break;
              if (playerType.id == PlayerType.me) {
                state.ownPokemonStates[targetMyPokemonIndex!-1].remainHP =
                  (ownParty.pokemons[targetMyPokemonIndex!-1]!.h.real / 2).floor();
              }
              else {
                state.opponentPokemonStates[targetMyPokemonIndex!-1].remainHPPercent = 50;
              }
            }
            break;
          default:
            break;
        }
        break;
      case 2:     // ぶつり
        // ダメージを負わせる
        opponentState.remainHP -= realDamage[continousCount];
        opponentState.remainHPPercent -= percentDamage[continousCount];
        break;
      case 3:     // とくしゅ
        // ダメージを負わせる
        opponentState.remainHP -= realDamage[continousCount];
        opponentState.remainHPPercent -= percentDamage[continousCount];
        break;
      default:
        break;
    }

    // 追加効果
    // 対象の相手
    PokemonState additionalEffectTargetState = opponentState;
    // TODO:追加効果の対象が自分なら変数に代入
    switch (moveAdditionalEffects[continousCount].id) {
      case MoveAdditionalEffect.speedDown:
        additionalEffectTargetState.statChanges[4]--;
        break;
      default:
        break;
    }

    return ret;
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
    int phaseIdx,
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
                appState.editingPhase[phaseIdx] = true;
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
                if (playerType.id == PlayerType.me) {
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
                appState.editingPhase[phaseIdx] = true;
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
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '行動の種類',
              ),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(
                  value: TurnMoveType.move,
                  child: Text('わざ', overflow: TextOverflow.ellipsis,),
                ),
                DropdownMenuItem(
                  value: TurnMoveType.change,
                  child: Text('ポケモン交代', overflow: TextOverflow.ellipsis,),
                ),
                DropdownMenuItem(
                  value: TurnMoveType.surrender,
                  child: Text('こうさん', overflow: TextOverflow.ellipsis,),
                ),
              ],
              value: type.id == TurnMoveType.none ? null : type.id,
              onChanged: playerType.id != PlayerType.none ? (value) {
                type = TurnMoveType(value as int);
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              } : null,
            ),
          ),
          SizedBox(width: 10,),
          type.id == TurnMoveType.move ?     // 行動がわざの場合
          Expanded(
            flex: 5,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: moveController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'わざ',
                ),
                enabled: playerType.id != PlayerType.none,
              ),
              autoFlipDirection: true,
              suggestionsCallback: (pattern) async {
                List<Move> matches = [];
                if (playerType.id == PlayerType.me) {
                  matches.add(ownPokemon.move1);
                  if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                  if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                  if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                }
                else if (opponentPokemonState.moves.length == 4) {  //　わざがすべて判明している場合
                  matches.addAll(opponentPokemonState.moves);
                }
                else {
                  matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                }
                matches.add(pokeData.moves[165]!);    // わるあがき
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
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
            ),
          ) :
          type.id == TurnMoveType.change ?     // 行動が交代の場合
          Expanded(
            flex: 5,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '交代先ポケモン',
              ),
              items: playerType.id == PlayerType.me ?
                <DropdownMenuItem>[
                  for (int i = 0; i < ownParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i+1,
                      enabled: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon),
                      child: Text(
                        ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon) ?
                          Colors.black : Colors.grey),
                        ),
                    ),
                ] :
                <DropdownMenuItem>[
                  for (int i = 0; i < opponentParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i+1,
                      enabled: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                      child: Text(
                        opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon) ?
                          Colors.black : Colors.grey),
                        ),
                    ),
                ],
              value: changePokemonIndex,
              onChanged: (value) {
                changePokemonIndex = value;
                appState.editingPhase[phaseIdx] = true;
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

  Widget terastalInputWidget(
    void Function() onFocus,
    MyAppState appState,
    Pokemon ownPokemon,
    bool alreadyTerastal,
  )
  {
    if (playerType.id != PlayerType.none && type.id == TurnMoveType.move) {
      // テラスタル有無
      return Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              title: Text('テラスタル'),
              value: teraType.id != 0,
              enabled: !alreadyTerastal,
              onChanged: (value) {
                if (value != null && value) {
                  if (playerType.id == PlayerType.me) {
                    teraType = ownPokemon.teraType;
                  }
                  else {
                    teraType = appState.pokeData.types[0];  // とりあえずノーマル
                  }
                }
                else {
                  teraType = PokeType.createFromId(0);
                }
                onFocus();
              },
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: TypeDropdownButton(
              appState.pokeData,
              'タイプ',
              teraType.id == 0 || alreadyTerastal || playerType.id == PlayerType.me ?
                null : (val) {teraType = appState.pokeData.types[val - 1];},
              teraType.id == 0 ? null : teraType.id,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget extraInputWidget2(
    void Function() onFocus,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    Party ownParty,
    Party opponentParty,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    List<PokemonState> ownPokemonStates,
    List<PokemonState> opponentPokemonStates,
    PhaseState state,
    TextEditingController hpController,
    MyAppState appState,
    int phaseIdx,
    int continousCount,
  )
  {
    if (playerType.id != PlayerType.none && type.id == TurnMoveType.move) {
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
                  value: moveAdditionalEffects[continousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
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
                    appState.editingPhase[phaseIdx] = true;
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
                      value: moveHits[continousCount].id,
                      onChanged: (value) {
                        moveHits[continousCount] = MoveHit(value);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '効果',
                      ),
                      items: <DropdownMenuItem<int>>[
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
                      value: moveEffectivenesses[continousCount].id,
                      onChanged: moveHits[continousCount].id != MoveHit.notHit && moveHits[continousCount].id != MoveHit.fail ? (value) {
                        moveEffectivenesses[continousCount] = MoveEffectiveness(value!);
                        appState.editingPhase[phaseIdx] = true;
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: hpController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: playerType.id == PlayerType.me ? 
                          '${opponentPokemon.name}の残りHP' : '${ownPokemon.name}の残りHP',
                      ),
                      enabled: moveHits[continousCount].id != MoveHit.notHit && moveHits[continousCount].id != MoveHit.fail,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () => onFocus(),
                      onChanged: (value) {
                        if (playerType.id == PlayerType.me) {
                          percentDamage[continousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                        }
                        else {
                          realDamage[continousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                        }
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                    ),
                  ),
                  playerType.id == PlayerType.me ?
                  Flexible(child: Text('% /100%')) :
                  Flexible(child: Text('/${ownPokemon.h.real}'))
                ],
              ),
            ],
          );
        case 16:    // ひんしになった(味方の)ポケモン
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '復活させるポケモン',
                  ),
                  items: playerType.id == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleOwnBattling(i) && ownPokemonStates[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOwnBattling(i) && ownPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleOpponentBattling(i) && opponentPokemonStates[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOpponentBattling(i) && opponentPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: targetMyPokemonIndex,
                  onChanged: (value) {
                    targetMyPokemonIndex = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
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
    playerType = PlayerType(PlayerType.none);
    type = TurnMoveType(TurnMoveType.none);
    teraType = PokeType.createFromId(0);
    move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
    isSuccess = true;
    moveHits = [MoveHit(MoveHit.hit)];
    moveEffectivenesses = [MoveEffectiveness(MoveEffectiveness.normal)];
    realDamage = [0];
    percentDamage = [0];
    moveAdditionalEffects = [MoveAdditionalEffect(MoveAdditionalEffect.none)];
    changePokemonIndex = null;
    targetMyPokemonIndex = null;
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnMove deserialize(dynamic str, String split1, String split2) {
    TurnMove turnMove = TurnMove();
    final turnMoveElements = str.split(split1);
    // playerType
    turnMove.playerType = PlayerType(int.parse(turnMoveElements[0]));
    // type
    turnMove.type = TurnMoveType(int.parse(turnMoveElements[1]));
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
    // actionFailure
    turnMove.actionFailure = ActionFailure(int.parse(turnMoveElements[5]));
    // moveHits
    turnMove.moveHits.clear();
    var moveHits = turnMoveElements[6].split(split2);
    for (var moveHitsElement in moveHits) {
      if (moveHitsElement == '') break;
      turnMove.moveHits.add(MoveHit(int.parse(moveHitsElement)));
    }
    // moveEffectiveness
    var moveEffectivenesses = turnMoveElements[7].split(split2);
    turnMove.moveEffectivenesses.clear();
    for (var moveEffectivenessElement in moveEffectivenesses) {
      if (moveEffectivenessElement == '') break;
      turnMove.moveEffectivenesses.add(MoveEffectiveness(int.parse(moveEffectivenessElement)));
    }
    // realDamage
    var realDamages = turnMoveElements[8].split(split2);
    turnMove.realDamage.clear();
    for (var realDamage in realDamages) {
      if (realDamage == '') break;
      turnMove.realDamage.add(int.parse(realDamage));
    }
    // percentDamage
    var percentDamages = turnMoveElements[9].split(split2);
    turnMove.percentDamage.clear();
    for (var percentDamage in percentDamages) {
      if (percentDamage == '') break;
      turnMove.percentDamage.add(int.parse(percentDamage));
    }
    // moveAdditionalEffect
    var moveAdditionalEffects = turnMoveElements[10].split(split2);
    turnMove.moveAdditionalEffects.clear();
    for (var moveAdditionalEffect in moveAdditionalEffects) {
      if (moveAdditionalEffect == '') break;
      turnMove.moveAdditionalEffects.add(MoveAdditionalEffect(int.parse(moveAdditionalEffect)));
    }
    // changePokemonIndex
    if (turnMoveElements[11] != '') {
      turnMove.changePokemonIndex = int.parse(turnMoveElements[11]);
    }
    // targetMyPokemonIndex
    if (turnMoveElements[12] != '') {
      turnMove.targetMyPokemonIndex = int.parse(turnMoveElements[12]);
    }

    return turnMove;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    // playerType
    ret += playerType.id.toString();
    ret += split1;
    // type
    ret += type.id.toString();
    ret += split1;
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
    // actionFailure
    ret += actionFailure.id.toString();
    ret += split1;
    // moveHits
    for (final moveHit in moveHits) {
      ret += moveHit.id.toString();
      ret += split2;
    }
    ret += split1;
    // moveEffectivenesses
    for (final moveEffectiveness in moveEffectivenesses) {
      ret += moveEffectiveness.id.toString();
      ret += split2;
    }
    ret += split1;
    // realDamage
    for (final damage in realDamage) {
      ret += damage.toString();
      ret += split2;
    }
    ret += split1;
    // percentDamage
    for (final damage in percentDamage) {
      ret += damage.toString();
      ret += split2;
    }
    ret += split1;
    // moveAdditionalEffects
    for (final moveAdditionalEffect in moveAdditionalEffects) {
      ret += moveAdditionalEffect.id.toString();
      ret += split2;
    }
    ret += split1;
    // changePokemonIndex
    if (changePokemonIndex != null) {
      ret += changePokemonIndex.toString();
    }
    ret += split1;
    // targetMyPokemonIndex
    if (targetMyPokemonIndex != null) {
      ret += targetMyPokemonIndex.toString();
    }

    return ret;
  }

  bool isValid() {
    switch (type.id) {
      case TurnMoveType.move:
        return
        playerType.id != PlayerType.none &&
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