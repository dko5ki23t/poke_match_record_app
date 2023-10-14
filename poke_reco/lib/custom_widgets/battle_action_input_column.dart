import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';

class BattleActionInputColumn extends Column {
  BattleActionInputColumn(
    PhaseState prevState,       // 直前までの状態
    PhaseState currentState,
    Pokemon ownPokemon,         // 行動直前でのポケモン(ポケモン交代する場合は、交代前ポケモン)
    Pokemon opponentPokemon,
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
                Center(child: Text(
                  _getTitle(turn.phases[phaseIdx].move!, ownPokemon, opponentPokemon)
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    appState.editingPhase[phaseIdx] ?
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: turn.phases[phaseIdx].move!.isValid() ? () {
                        appState.editingPhase[phaseIdx] = false;
                        onFocus(phaseIdx+1);
                      } : null,
                    ) : Container(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        turn.phases[phaseIdx].move!.clear();
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
                          child: Text('${ownPokemon.name}/あなた', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: PlayerType.opponent,
                          child: Text('${opponentPokemon.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                      value: turn.phases[phaseIdx].move!.playerType.id == PlayerType.none ? null : turn.phases[phaseIdx].move!.playerType.id,
                      onChanged: (value) {
                        turn.phases[phaseIdx].playerType = PlayerType(value);
                        turn.phases[phaseIdx].move!.clear();
                        turn.phases[phaseIdx].move!.playerType = PlayerType(value);
                        moveControllerList[phaseIdx].text = '';
                        hpControllerList[phaseIdx].text =
                          turn.phases[phaseIdx].getEditingControllerText2(currentState);
                        appState.editingPhase[phaseIdx] = true;
                        onFocus(phaseIdx+1);
                      },
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
                      value: turn.phases[phaseIdx].move!.isSuccess,
                      onChanged: turn.phases[phaseIdx].move!.playerType.id != PlayerType.none ?
                        (value) {
                          turn.phases[phaseIdx].move!.isSuccess = value!;
                          if (!value) turn.phases[phaseIdx].move!.type = TurnMoveType(TurnMoveType.move);
                          appState.editingPhase[phaseIdx] = true;
                          onFocus(phaseIdx+1);
                        } : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.extraInputWidget1(
                () => onFocus(phaseIdx+1), battle.ownParty, 
                battle.opponentParty, prevState, ownPokemon, opponentPokemon,
                prevState.ownPokemonState,
                prevState.opponentPokemonState,
                moveControllerList[phaseIdx], hpControllerList[phaseIdx],
                appState, phaseIdx,
              ),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.terastalInputWidget(
                () => onFocus(phaseIdx+1),
                ownPokemon, turn.phases[phaseIdx].playerType.id == PlayerType.me ?
                  prevState.hasOwnTerastal : prevState.hasOpponentTerastal,
              ),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.extraInputWidget2(
                () => onFocus(phaseIdx+1), ownPokemon, opponentPokemon,
                battle.ownParty, battle.opponentParty,
                prevState.ownPokemonState,
                prevState.opponentPokemonState,
                prevState.ownPokemonStates,
                prevState.opponentPokemonStates,
                prevState,
                hpControllerList[phaseIdx],
                textEditingControllerList3[phaseIdx],
                appState, phaseIdx, 0,
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

  static String _getTitle(TurnMove turnMove, Pokemon own, Pokemon opponent) {
    switch (turnMove.type.id) {
      case TurnMoveType.move:
        if (turnMove.move.id != 0) {
          String continous = turnMove.move.maxMoveCount() > 1 ? '【1回目】' : '';
          if (turnMove.playerType.id == PlayerType.opponent) {
            return '$continous${turnMove.move.displayName}-${opponent.name}';
          }
          else {
            return '$continous${turnMove.move.displayName}-${own.name}';
          }
        }
        break;
      case TurnMoveType.change:
        return 'ポケモン交代';
      case TurnMoveType.surrender:
        return 'こうさん';
      default:
        break;
    }

    return '行動';
  }
}
