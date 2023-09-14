import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

class BattleFirstTurnFirstEffectInputColumn extends Column {
  BattleFirstTurnFirstEffectInputColumn(
    PokeDB pokeData,
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    SameTimingEffectRange sameTimingEffectRange,
    List<PhaseState> stateList,
    AbilityTiming timing,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = sameTimingEffectRange.beginIdx; i <= sameTimingEffectRange.endIdx; i++)
        Column(
          children: [
            GestureDetector(
              onTap: focusPhaseIdx != i+1 ? () => onFocus(i+1) : (){},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: focusPhaseIdx == i+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                      Center(child: Text('処理${i-sameTimingEffectRange.beginIdx+1}')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children:[
                          // 編集中でなければ並べ替えボタン
                          !appState.editingPhase[i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: i != 0 ? () {
                              TurnEffect.swap(turn.processes, i-1, i);
                              listShallowSwap(appState.editingPhase, i-1, i);
                              setState();
                            }: null,
                          ) : Container(),
                          !appState.editingPhase[i] ?
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: i < sameTimingEffectRange.endIdx ? () {
                              TurnEffect.swap(turn.processes, i, i+1);
                              listShallowSwap(appState.editingPhase, i, i+1);
                              setState();
                            } : null,
                          ) :
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: turn.processes[i].isValid() ? () {
                              appState.editingPhase[i] = false;
                              setState();
                            } : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              turn.processes.removeAt(i);
                              appState.editingPhase.removeAt(i);
                              textEditControllerList1.removeAt(i);
                              textEditControllerList2.removeAt(i);
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
                                child: Text('${battle.ownParty.pokemons[stateList[i-sameTimingEffectRange.beginIdx].ownPokemonIndex-1]!.name}/あなた', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.opponent,
                                child: Text('${battle.opponentParty.pokemons[stateList[i-sameTimingEffectRange.beginIdx].opponentPokemonIndex-1]!.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                              ),
                              DropdownMenuItem(
                                value: PlayerType.entireField,
                                child: Text('天気・フィールド', overflow: TextOverflow.ellipsis,),
                              ),
                            ],
                            value: turn.processes[i].playerType == PlayerType.none ? null : turn.processes[i].playerType,
                            onChanged: (value) {
                              turn.processes[i].playerType = value;
                              turn.processes[i].effectId = 0;
                              appState.editingPhase[i] = true;
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
                            value: (turn.processes[i].effect.id == EffectType.none ||
                                    turn.processes[i].effect.id == EffectType.weather ||
                                    turn.processes[i].effect.id == EffectType.field ||
                                    turn.processes[i].effect.id == EffectType.move) ? null : turn.processes[i].effect.id,
                            onChanged: turn.processes[i].playerType != PlayerType.entireField && turn.processes[i].playerType != PlayerType.none ?
                            (value) {
                              turn.processes[i].effect = EffectType(value!);
                              turn.processes[i].effectId = 0;
                              appState.editingPhase[i] = true;
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
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '発動効果',
                            ),
                            items:
                              <DropdownMenuItem>[
                                for (final effect in TurnEffect.getPossibleEffects(timing, turn.processes[i].playerType, turn.processes[i].effect,
                                  turn.processes[i].playerType == PlayerType.me ? battle.ownParty.pokemons[stateList[i-sameTimingEffectRange.beginIdx].ownPokemonIndex-1] :
                                  turn.processes[i].playerType == PlayerType.opponent ? battle.opponentParty.pokemons[stateList[i-sameTimingEffectRange.beginIdx].opponentPokemonIndex-1] : null,
                                  turn.processes[i].playerType == PlayerType.me ? stateList[i-sameTimingEffectRange.beginIdx].ownPokemonStates[stateList[i-sameTimingEffectRange.beginIdx].ownPokemonIndex-1] :
                                  turn.processes[i].playerType == PlayerType.opponent ? stateList[i-sameTimingEffectRange.beginIdx].opponentPokemonStates[stateList[i-sameTimingEffectRange.beginIdx].opponentPokemonIndex-1] : null,
                                   stateList[i-sameTimingEffectRange.beginIdx]))
                                  DropdownMenuItem(
                                    value: effect.effectId,
                                    child: Text(effect.getDisplayName(pokeData), overflow: TextOverflow.ellipsis,),
                                  ),
                              ],
                            value: turn.processes[i].effectId == 0 ? null : turn.processes[i].effectId,
                            onChanged: (value) {
                              turn.processes[i].effectId = value;
                              appState.editingPhase[i] = true;
                              setState();
                            },
                          ),
                        ),
                      ],
                    ),
                    turn.processes[i].extraInputWidget(setState),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      // 処理追加ボタン
      TextButton(
        onPressed: /*turn.canAddBeforemoveEffects() && */getSelectedNum(appState.editingPhase.sublist(sameTimingEffectRange.beginIdx, sameTimingEffectRange.endIdx+1)) == 0 ?
          () {
            turn.processes.insert(
              sameTimingEffectRange.endIdx+1,
              TurnEffect()
              ..timing = AbilityTiming(timing.id)
            );
            appState.editingPhase.insert(sameTimingEffectRange.endIdx+1, true);
            textEditControllerList1.insert(sameTimingEffectRange.endIdx+1, TextEditingController());
            textEditControllerList2.insert(sameTimingEffectRange.endIdx+1, TextEditingController());
            onFocus(sameTimingEffectRange.endIdx+2);
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