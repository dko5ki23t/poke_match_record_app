// TODO:わざ選択前後で全く同じ中身のwidgetとなっている（クラスに変数を持てない関係で）。なんとかしたい

import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

class BattleBeforeMoveEffectInputColumn extends Column {
  BattleBeforeMoveEffectInputColumn(
    PokeDB pokeData,
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    List<TurnEffect> turnEffects,
    MyAppState appState,
    TurnPhase focusPhase,
    int focusPhaseIdx,
    void Function(TurnPhase, int) onFocus,
    List<PhaseState> stateList,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < turnEffects.length; i++)
        Column(
          children: [
            GestureDetector(
              onTap: focusPhase != TurnPhase.beforeMove || focusPhaseIdx != i+1 ? () => onFocus(TurnPhase.beforeMove, i+1) : (){},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: focusPhase == TurnPhase.beforeMove && focusPhaseIdx == i+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
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
                          !appState.beforeMoveEditing[i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: i != 0 ? () {
                              TurnEffect.swap(turnEffects, i-1, i);
                              listShallowSwap(appState.beforeMoveEditing, i-1, i);
                              setState();
                            }: null,
                          ) : Container(),
                          !appState.beforeMoveEditing[i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: i < turnEffects.length-1 ? () {
                              TurnEffect.swap(turnEffects, i, i+1);
                              listShallowSwap(appState.beforeMoveEditing, i, i+1);
                              setState();
                            } : null,
                          ) :
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: turnEffects[i].isValid() ? () {
                              appState.beforeMoveEditing[i] = false;
                              setState();
                            } : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              turnEffects.removeAt(i);
                              appState.beforeMoveEditing.removeAt(i);
                              onFocus(TurnPhase.beforeMove, 0);   // フォーカスリセット
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
                                child: Text('${battle.ownParty.pokemons[stateList[i].ownPokemonIndex-1]!.name}/あなた', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.opponent,
                                child: Text('${battle.opponentParty.pokemons[stateList[i].opponentPokemonIndex-1]!.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.entireField,
                                child: Text('天気・フィールド', overflow: TextOverflow.ellipsis,),
                              ),
                            ],
                            value: turnEffects[i].playerType == PlayerType.none ? null : turnEffects[i].playerType,
                            onChanged: (value) {
                              turnEffects[i].playerType = value;
                              turnEffects[i].effectId = 0;
                              appState.beforeMoveEditing[i] = true;
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
                              labelText: '種別',
                            ),
                            items: <DropdownMenuItem>[
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
                            ],
                            value: turnEffects[i].effect == EffectType.none ? null : turnEffects[i].effect,
                            onChanged: (value) {
                              turnEffects[i].effect = value;
                              appState.beforeMoveEditing[i] = true;
                              setState();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '発動効果',
                            ),
                            items:
                              <DropdownMenuItem>[
                                for (final effect in TurnEffect.getPossibleEffects(AbilityTiming(1), turnEffects[i].playerType, turnEffects[i].effect,
                                  turnEffects[i].playerType == PlayerType.me ? battle.ownParty.pokemons[stateList[i].ownPokemonIndex-1] :
                                  turnEffects[i].playerType == PlayerType.opponent ? battle.opponentParty.pokemons[stateList[i].opponentPokemonIndex-1] : null,
                                  turnEffects[i].playerType == PlayerType.me ? stateList[i].ownPokemonStates[stateList[i].ownPokemonIndex-1] :
                                  turnEffects[i].playerType == PlayerType.opponent ? stateList[i].opponentPokemonStates[stateList[i].opponentPokemonIndex-1] : null))
                                  DropdownMenuItem(
                                    value: effect.effectId,
                                    child: Text(effect.getDisplayName(pokeData), overflow: TextOverflow.ellipsis,),
                                  ),
                              ],
                            value: turnEffects[i].effectId == 0 ? null : turnEffects[i].effectId,
                            onChanged: (value) {
                              turnEffects[i].effectId = value;
                              appState.beforeMoveEditing[i] = true;
                              setState();
                            },
                          ),
                        ),
                      ],
                    ),
                    turnEffects[i].extraInputWidget(setState),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      // 処理追加ボタン
      TextButton(
        onPressed: turn.canAddBeforemoveEffects() && getSelectedNum(appState.beforeMoveEditing) == 0 ?
          () {
            turnEffects.add(TurnEffect()..effect = EffectType.ability);
            appState.beforeMoveEditing.add(true);
            onFocus(TurnPhase.beforeMove, turnEffects.length);
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
              Text('ポケモン登場時処理を追加'),
            ],
          ),
        ),
      ),
    ],
  );
}