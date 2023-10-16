import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';

class BattleChangeFaintingPokemonInputColumn extends Column {
  BattleChangeFaintingPokemonInputColumn(
    PhaseState prevState,       // 直前までの状態
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    int phaseIdx,
    AbilityTiming timing,
    List<TextEditingController> moveControllerList,
    List<TextEditingController> hpControllerList,
    List<TextEditingController> textEditingControllerList3,
    List<String> guides,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: focusPhaseIdx != phaseIdx+1 ? () => onFocus(phaseIdx+1) : () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: focusPhaseIdx == phaseIdx+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                Center(child: Text('ポケモン交代')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    appState.editingPhase[phaseIdx] ?
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: turn.phases[phaseIdx].isValid() ? () {
                        appState.editingPhase[phaseIdx] = false;
                        onFocus(phaseIdx+1);
                      } : null,
                    ) : Container(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        turn.phases[phaseIdx].effectId = 0;
                        onFocus(phaseIdx+1);
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
                        labelText: '行動主',
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: PlayerType.me,
                          child: Text('あなた', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: PlayerType.opponent,
                          child: Text(battle.opponentName, overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                      value: turn.phases[phaseIdx].playerType.id == PlayerType.none ? null : turn.phases[phaseIdx].playerType.id,
                      onChanged: null,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<bool>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '行動の成否',
                      ),
                      items: <DropdownMenuItem<bool>>[
                        DropdownMenuItem(
                          value: true,
                          child: Text('行動成功', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('行動失敗', overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                      value: true,
                      onChanged: null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '交代先ポケモン',
                      ),
                      items: 
                        <DropdownMenuItem>[
                        for (int i = 0; i < battle.getParty(turn.phases[phaseIdx].playerType).pokemonNum; i++)
                          DropdownMenuItem(
                            value: i+1,
                            enabled: prevState.isPossibleBattling(turn.phases[phaseIdx].playerType, i) && !prevState.getPokemonStates(turn.phases[phaseIdx].playerType)[i].isFainting,
                            child: Text(
                              battle.getParty(turn.phases[phaseIdx].playerType).pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: prevState.isPossibleBattling(turn.phases[phaseIdx].playerType, i) && !prevState.getPokemonStates(turn.phases[phaseIdx].playerType)[i].isFainting ?
                                Colors.black : Colors.grey),
                              ),
                          ),
                        ],
                      value: turn.phases[phaseIdx].effectId == 0 ? null : turn.phases[phaseIdx].effectId,
                      onChanged: (value) {
                        turn.phases[phaseIdx].effectId = value;
                        appState.editingPhase[phaseIdx] = true;
                        onFocus(phaseIdx+1);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              for (final e in guides)
              Row(
                children: [
                  Expanded(child: Icon(Icons.info, color: Colors.lightGreen,)),
                  Expanded(flex: 10, child: Text(e)),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
