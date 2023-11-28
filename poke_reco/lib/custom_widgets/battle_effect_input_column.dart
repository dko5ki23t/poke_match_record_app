import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/tool.dart';

class BattleEffectInputColumn extends Column {
  BattleEffectInputColumn(
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    PhaseState prevState,       // 直前までの状態
    List<TurnEffectAndStateAndGuide> sameTimingList,
    int firstIdx,
    AbilityTiming timing,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    PlayerType attacker,
    TurnMove turnMove,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < sameTimingList.length; i++)
        !sameTimingList[i].turnEffect.isAdding ?
        Column(
          children: [
            GestureDetector(
              onTap: focusPhaseIdx != firstIdx+i+1 ? () => onFocus(firstIdx+i+1) : (){},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: focusPhaseIdx == firstIdx+i+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                      Center(child: Text('処理${i+1}')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children:[
                          // 編集中でなければ並べ替えボタン
                          !appState.editingPhase[firstIdx+i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: i != 0 ? () {
                              TurnEffect.swap(turn.phases, firstIdx+i-1, firstIdx+i);
                              listShallowSwap(appState.editingPhase, firstIdx+i-1, firstIdx+i);
                              appState.needAdjustPhases = firstIdx+i-1;
                              onFocus(firstIdx+i);
                            }: null,
                          ) : Container(),
                          !appState.editingPhase[firstIdx+i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: i < sameTimingList.length-1 && !sameTimingList[i+1].turnEffect.isAdding ? () {
                              TurnEffect.swap(turn.phases, firstIdx+i, firstIdx+i+1);
                              listShallowSwap(appState.editingPhase, firstIdx+i, firstIdx+i+1);
                              appState.needAdjustPhases = firstIdx+i;
                              onFocus(firstIdx+i+2);
                            } : null,
                          ) :
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: turn.phases[firstIdx+i].isValid() ? () {
                              turn.phases[firstIdx+i].isAutoSet = false;  // 自動補完されたものでも、編集後はそのフラグを消す
                              appState.editingPhase[firstIdx+i] = false;
                              onFocus(firstIdx+i+1);
                            } : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              if (i == 0) {
                                var timing = turn.phases[firstIdx+i].timing;
                                turn.phases[firstIdx+i] =
                                  TurnEffect()
                                  ..timing = timing
                                  ..isAdding = true;
                                appState.editingPhase[firstIdx+i] = false;
                                textEditControllerList1[firstIdx+i].text = '';
                                textEditControllerList2[firstIdx+i].text = '';
                                textEditControllerList3[firstIdx+i].text = '';
                                textEditControllerList4[firstIdx+i].text = '';
                              }
                              else {
                                turn.phases.removeAt(firstIdx+i);
                                appState.editingPhase.removeAt(firstIdx+i);
                                textEditControllerList1.removeAt(firstIdx+i);
                                textEditControllerList2.removeAt(firstIdx+i);
                                textEditControllerList3.removeAt(firstIdx+i);
                                textEditControllerList4.removeAt(firstIdx+i);
                              }
                              appState.adjustPhaseByDelete = true;
                              appState.needAdjustPhases = firstIdx+i;
                              onFocus(0);   // フォーカスリセット
                            },
                          ),
                        ],
                      ),
                    ],),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '発動主',
                            ),
                            items: <DropdownMenuItem>[
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) => e.playerType.id == PlayerType.me).isNotEmpty,
                                PlayerType.me,
                                '${sameTimingList[i].phaseState.getPokemonState(
                                  PlayerType(PlayerType.me),
                                  sameTimingList.first.phaseIdx-1 >= 0 && timing.id == AbilityTiming.afterMove ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                ).pokemon.name}/あなた',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) => e.playerType.id == PlayerType.opponent).isNotEmpty,
                                PlayerType.opponent,
                                '${sameTimingList[i].phaseState.getPokemonState(
                                  PlayerType(PlayerType.opponent),
                                  sameTimingList.first.phaseIdx-1 >= 0 && timing.id == AbilityTiming.afterMove ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                ).pokemon.name}/${battle.opponentName}',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) => e.playerType.id == PlayerType.entireField).isNotEmpty,
                                PlayerType.entireField,
                                '天気・フィールド',
                              ),
                            ],
                            value: turn.phases[firstIdx+i].playerType.id == PlayerType.none ? null : turn.phases[firstIdx+i].playerType.id,
                            onChanged: (value) {
                              turn.phases[firstIdx+i].playerType = PlayerType(value);
                              var candidates = sameTimingList.first.candidateEffect;
                              if (candidates.length == 1) {       // 候補が1つだけなら
                                turn.phases[firstIdx+i].effect = candidates.first.effect;
                                turn.phases[firstIdx+i].effectId = candidates.first.effectId;
                                turn.phases[firstIdx+i].extraArg1 = candidates.first.extraArg1;
                                turn.phases[firstIdx+i].extraArg2 = candidates.first.extraArg2;
                              }
                              else {
                                turn.phases[firstIdx+i].effect = EffectType(EffectType.none);
                                turn.phases[firstIdx+i].effectId = 0;
                              }
                              textEditControllerList1[firstIdx+i].text = turn.phases[firstIdx+i].displayName;
                              textEditControllerList2[firstIdx+i].text =
                                turn.phases[firstIdx+i].getEditingControllerText2(
                                  sameTimingList[i].phaseState,
                                  sameTimingList.first.phaseIdx-1 >= 0 ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                );
                              textEditControllerList3[firstIdx+i].text =
                                turn.phases[firstIdx+i].getEditingControllerText3(
                                  sameTimingList[i].phaseState,
                                  sameTimingList.first.phaseIdx-1 >= 0 ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                );
                              appState.editingPhase[firstIdx+i] = true;
                              onFocus(firstIdx+i+1);
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
                              labelText: '種別',
                            ),
                            items: timing.id == AbilityTiming.afterMove ?
                            <DropdownMenuItem<int>>[
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.afterMove
                                ).isNotEmpty,
                                EffectType.afterMove, 'わざ',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.ability
                                ).isNotEmpty,
                                EffectType.ability, 'とくせい',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.item
                                ).isNotEmpty,
                                EffectType.item, 'もちもの',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.individualField
                                ).isNotEmpty,
                                EffectType.individualField, '場',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.ailment
                                ).isNotEmpty,
                                EffectType.ailment, '状態異常',
                              ),
                            ] :
                            <DropdownMenuItem<int>>[
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.ability
                                ).isNotEmpty,
                                EffectType.ability, 'とくせい',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.item
                                ).isNotEmpty,
                                EffectType.item, 'もちもの',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.individualField
                                ).isNotEmpty,
                                EffectType.individualField, '場',
                              ),
                              _myDropDown(
                                sameTimingList.first.candidateEffect.where((e) =>
                                  e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                  e.effect.id == EffectType.ailment
                                ).isNotEmpty,
                                EffectType.ailment, '状態異常',
                              ),
                            ],
                            value: (turn.phases[firstIdx+i].effect.id == EffectType.none ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.weather ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.field ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.move) ? null : turn.phases[firstIdx+i].effect.id,
                            onChanged: turn.phases[firstIdx+i].playerType.id != PlayerType.entireField && turn.phases[firstIdx+i].playerType.id != PlayerType.none ?
                            (value) {
                              turn.phases[firstIdx+i].effect = EffectType(value!);
                              var candidates = sameTimingList.first.candidateEffect.where((e) =>
                                e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                e.effect.id == turn.phases[firstIdx+i].effect.id
                              );
                              if (candidates.length == 1) {   // 候補が一つしかないならそれに決めてしまう
                                turn.phases[firstIdx+i].effectId = candidates.first.effectId;
                                turn.phases[firstIdx+i].extraArg1 = candidates.first.extraArg1;
                                turn.phases[firstIdx+i].extraArg2 = candidates.first.extraArg2;
                              }
                              else {
                                turn.phases[firstIdx+i].effectId = 0;
                              }
                              textEditControllerList1[firstIdx+i].text = turn.phases[firstIdx+i].displayName;
                              textEditControllerList2[firstIdx+i].text =
                                turn.phases[firstIdx+i].getEditingControllerText2(
                                  sameTimingList[i].phaseState,
                                  sameTimingList.first.phaseIdx-1 >= 0 ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                );
                              textEditControllerList3[firstIdx+i].text =
                                turn.phases[firstIdx+i].getEditingControllerText3(
                                  sameTimingList[i].phaseState,
                                  sameTimingList.first.phaseIdx-1 >= 0 ? turn.phases[sameTimingList.first.phaseIdx-1] : null
                                );
                              appState.editingPhase[firstIdx+i] = true;
                              onFocus(firstIdx+i+1);
                            } : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: textEditControllerList1[firstIdx+i],
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: '発動効果',
                              ),
                            ),
                            autoFlipDirection: true,
                            suggestionsCallback: (pattern) async {
                              List<TurnEffect> matches =
                                sameTimingList.first.candidateEffect.where((e) =>
                                e.playerType.id == turn.phases[firstIdx+i].playerType.id &&
                                e.effect.id == turn.phases[firstIdx+i].effect.id
                              ).toList();
                              matches.retainWhere((s){
                                return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                              });
                              return matches;
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              textEditControllerList1[firstIdx+i].text = suggestion.displayName;
                              // 発動主が天気やフィールドの場合はEffectTypeも決まっていないため、ここで決定する
                              turn.phases[firstIdx+i].effect = suggestion.effect;
                              turn.phases[firstIdx+i].effectId = suggestion.effectId;
                              turn.phases[firstIdx+i].extraArg1 = suggestion.extraArg1;
                              turn.phases[firstIdx+i].extraArg2 = suggestion.extraArg2;
                              appState.needAdjustPhases = firstIdx+i;
                              appState.editingPhase[firstIdx+i] = true;
                              onFocus(firstIdx+i+1);
                            },
                          ),
                        ),
                      ],
                    ),
                    turn.phases[firstIdx+i].extraInputWidget(
                      //focusPhaseIdx != firstIdx+i+1 ? () => onFocus(firstIdx+i+1) : () {},
                      () {
                        appState.needAdjustPhases = firstIdx+i+1;
                        onFocus(firstIdx+i+1);
                      },
                      battle.getParty(PlayerType(PlayerType.me)).pokemons[_getPrevState(prevState, firstIdx, i, sameTimingList).getPokemonIndex(PlayerType(PlayerType.me), null)-1]!,
                      battle.getParty(PlayerType(PlayerType.opponent)).pokemons[_getPrevState(prevState, firstIdx, i, sameTimingList).getPokemonIndex(PlayerType(PlayerType.opponent), null)-1]!,
                      _getPrevState(prevState, firstIdx, i, sameTimingList).getPokemonState(PlayerType(PlayerType.me), null),
                      _getPrevState(prevState, firstIdx, i, sameTimingList).getPokemonState(PlayerType(PlayerType.opponent), null),
                      battle.getParty(PlayerType(PlayerType.me)),
                      battle.getParty(PlayerType(PlayerType.opponent)),
                      _getPrevState(prevState, firstIdx, i, sameTimingList),
                      firstIdx-1 >= 0 ? turn.phases[firstIdx-1] : null,
                      textEditControllerList2[firstIdx+i], textEditControllerList3[firstIdx+i],
                      appState, firstIdx+i),
                    SizedBox(height: 10),
                    for (final e in sameTimingList[i].guides)
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.lightGreen,),
                        Text(e, overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ) :
        // 処理追加ボタン
        sameTimingList.first.candidateEffect.isNotEmpty ?
        TextButton(
          onPressed: getSelectedNum(appState.editingPhase.sublist(firstIdx, firstIdx+sameTimingList.length)) == 0 ?
            () {
              turn.phases[firstIdx+i].isAdding = false;
              appState.editingPhase[firstIdx+i] = true;
              onFocus(firstIdx+i+1);
            } : null,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle),
                Text('${_getTimingText(timing)}処理を追加'),
              ],
            ),
          ),
        ) : Container(),
    ],
  );

  static String _getTimingText(AbilityTiming timing) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:
        return 'ポケモン登場時';
      case AbilityTiming.everyTurnEnd:
        return 'ターン終了時';
      case AbilityTiming.afterActionDecision:
        return '行動決定直後';
      case AbilityTiming.beforeMove:
        return 'わざ使用前';
      case AbilityTiming.afterMove:
        return 'わざ使用後';
      case AbilityTiming.afterTerastal:
        return 'テラスタル後';
      default:
        return '';
    }
  }


  static PhaseState _getPrevState(
    PhaseState prevState, int firstIdx, int i,
    List<TurnEffectAndStateAndGuide> sameTimingList)
  {
    if (i==0) return prevState;
    return sameTimingList[i-1].phaseState;
  }

  static DropdownMenuItem<int> _myDropDown(bool enabled, int value, String label) {
    return DropdownMenuItem(
      enabled: enabled,
      value: value,
      child: Text(label, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey,),
      ),
    );
  }

}