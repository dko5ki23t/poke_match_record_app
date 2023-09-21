import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

class BattleEffectInputColumn extends Column {
  BattleEffectInputColumn(
    PokeDB pokeData,
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    List<TurnEffectAndStateAndGuide> sameTimingList,
    int firstIdx,
    AbilityTiming timing,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
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
                              setState();
                            }: null,
                          ) : Container(),
                          !appState.editingPhase[firstIdx+i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: i < sameTimingList.length-1 && !sameTimingList[i+1].turnEffect.isAdding ? () {
                              TurnEffect.swap(turn.phases, firstIdx+i, firstIdx+i+1);
                              listShallowSwap(appState.editingPhase, firstIdx+i, firstIdx+i+1);
                              setState();
                            } : null,
                          ) :
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: turn.phases[firstIdx+i].isValid() ? () {
                              appState.editingPhase[firstIdx+i] = false;
                              setState();
                            } : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              turn.phases.removeAt(firstIdx+i);
                              appState.editingPhase.removeAt(firstIdx+i);
                              textEditControllerList1.removeAt(firstIdx+i);
                              textEditControllerList2.removeAt(firstIdx+i);
                              onFocus(0);   // フォーカスリセット
                              //setState();
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
                              DropdownMenuItem(
                                value: PlayerType.me,
                                child: Text('${battle.ownParty.pokemons[sameTimingList[i].phaseState.ownPokemonIndex-1]!.name}/あなた', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.opponent,
                                child: Text('${battle.opponentParty.pokemons[sameTimingList[i].phaseState.opponentPokemonIndex-1]!.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.entireField,
                                child: Text('天気・フィールド', overflow: TextOverflow.ellipsis,),
                              ),
                            ],
                            value: turn.phases[firstIdx+i].playerType.id == PlayerType.none ? null : turn.phases[firstIdx+i].playerType.id,
                            onChanged: (value) {
                              turn.phases[firstIdx+i].playerType = PlayerType(value);
                              turn.phases[firstIdx+i].effectId = 0;
                              appState.editingPhase[firstIdx+i] = true;
                              setState();
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
                            items: <DropdownMenuItem<int>>[
                              DropdownMenuItem(
                                value: EffectType.ability,
                                child: Text('とくせい', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: EffectType.item,
                                child: Text('もちもの', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: EffectType.individualField,
                                child: Text('場', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: EffectType.ailment,
                                child: Text('状態異常', overflow: TextOverflow.ellipsis,),
                              ),
                            ],
                            value: (turn.phases[firstIdx+i].effect.id == EffectType.none ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.weather ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.field ||
                                    turn.phases[firstIdx+i].effect.id == EffectType.move) ? null : turn.phases[firstIdx+i].effect.id,
                            onChanged: turn.phases[firstIdx+i].playerType.id != PlayerType.entireField && turn.phases[firstIdx+i].playerType.id != PlayerType.none ?
                            (value) {
                              turn.phases[firstIdx+i].effect = EffectType(value!);
                              turn.phases[firstIdx+i].effectId = 0;
                              appState.editingPhase[firstIdx+i] = true;
                              setState();
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
                                TurnEffect.getPossibleEffects(timing, turn.phases[firstIdx+i].playerType, turn.phases[firstIdx+i].effect,
                                turn.phases[firstIdx+i].playerType.id == PlayerType.me ? battle.ownParty.pokemons[sameTimingList[i].phaseState.ownPokemonIndex-1] :
                                turn.phases[firstIdx+i].playerType.id == PlayerType.opponent ? battle.opponentParty.pokemons[sameTimingList[i].phaseState.opponentPokemonIndex-1] : null,
                                turn.phases[firstIdx+i].playerType.id == PlayerType.me ? sameTimingList[i].phaseState.ownPokemonState :
                                turn.phases[firstIdx+i].playerType.id == PlayerType.opponent ? sameTimingList[i].phaseState.opponentPokemonState : null,
                                sameTimingList[i].phaseState);
                              matches.retainWhere((s){
                                return toKatakana(s.getDisplayName(pokeData).toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                              });
                              return matches;
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.getDisplayName(pokeData), overflow: TextOverflow.ellipsis,),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              textEditControllerList1[firstIdx+i].text = suggestion.getDisplayName(pokeData);
                              turn.phases[firstIdx+i].effectId = suggestion.effectId;
                              appState.editingPhase[firstIdx+i] = true;
                              onFocus(firstIdx+i);
                            },
                          ),
                        ),
                      ],
                    ),
                    turn.phases[firstIdx+i].extraInputWidget(setState),
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
        TextButton(
          onPressed: getSelectedNum(appState.editingPhase.sublist(firstIdx, firstIdx+sameTimingList.length)) == 0 ?
            () {
              turn.phases[firstIdx+i].isAdding = false;
              turn.phases.insert(firstIdx+i+1,
                TurnEffect()
                ..timing = timing
                ..isAdding = true
              );
              appState.editingPhase[firstIdx+i] = true;
              appState.editingPhase.insert(firstIdx+i+1, false);
              textEditControllerList1.insert(firstIdx+i+1, TextEditingController());
              textEditControllerList2.insert(firstIdx+i+1, TextEditingController());
              onFocus(firstIdx+i);
              //setState();
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
        ),
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
      case AbilityTiming.afterMove:
        return 'わざ使用後';
      default:
        return '';
    }
  }
}