// TODO:わざ選択前後で全く同じ中身のwidgetとなっている（クラスに変数を持てない関係で）。なんとかしたい

import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

class BattleBeforeMoveEffectInputColumn extends Column {
  BattleBeforeMoveEffectInputColumn(
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    List<TurnEffect> turnEffects,
    MyAppState appState,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < turnEffects.length; i++)
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor),
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
                            turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                            setState();
                          } : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            turnEffects.removeAt(i);
                            appState.beforeMoveEditing[i] = false;
                            turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                            setState();
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
                              child: Text('${battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.name}/あなた', overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: PlayerType.opponent,
                              child: Text('${battle.opponentParty.pokemons[turn.currentOpponentPokemonIndex-1]!.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
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
                            labelText: '発動効果',
                          ),
                          items: turnEffects[i].playerType == PlayerType.me ?
                            <DropdownMenuItem>[
                              DropdownMenuItem(
                                value: battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.ability.id,
                                child: Text(battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.ability.displayName, overflow: TextOverflow.ellipsis,),
                              ),
                            ] :
                            turnEffects[i].playerType == PlayerType.opponent ?
                            <DropdownMenuItem>[
                              for (final ability in turn.opponentPokemonCurrentStates[turn.currentOpponentPokemonIndex-1].possibleAbilities)
                              DropdownMenuItem(
                                value: ability.id,
                                child: Text(ability.displayName, overflow: TextOverflow.ellipsis,),
                              ),
                            ] : [],
                          value: turnEffects[i].effectId == 0 ? null : turnEffects[i].effectId,
                          onChanged: (value) {
                            turnEffects[i].effectId = value! as int;
                            appState.beforeMoveEditing[i] = true;
                            setState();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  turnEffects[i].extraInputWidget(setState),
                ],
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
            setState();
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
              Text('わざ選択前処理を追加'),
            ],
          ),
        ),
      ),
    ],
  );
}