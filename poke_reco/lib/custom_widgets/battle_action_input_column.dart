import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/poke_move.dart';

class BattleActionInputColumn extends Column {
  BattleActionInputColumn(
    PokeDB pokeData,
    void Function() setState,
    Pokemon ownPokemon,         // 行動直前でのポケモン(ポケモン交換する場合は、交換前ポケモン)
    Pokemon opponentPokemon,
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    int processIdx,
    PhaseState moveState,
    AbilityTiming timing,
    List<TextEditingController> moveControllerList,
    List<TextEditingController> hpControllerList,
    List<String> guides,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: focusPhaseIdx != processIdx+1 ? () => onFocus(processIdx+1) : () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: focusPhaseIdx == processIdx+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                Center(child: Text(
                  _getTitle(turn.phases[processIdx].move!, ownPokemon, opponentPokemon)
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    appState.editingPhase[processIdx] ?
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: turn.phases[processIdx].move!.isValid() ? () {
                        appState.editingPhase[processIdx] = false;
                        setState();
                      } : null,
                    ) : Container(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        turn.phases[processIdx].move!.clear();
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
                      value: turn.phases[processIdx].move!.playerType.id == PlayerType.none ? null : turn.phases[processIdx].move!.playerType.id,
                      onChanged: (value) {
                        turn.phases[processIdx].playerType = PlayerType(value);
                        turn.phases[processIdx].move!.playerType = PlayerType(value);
                        appState.editingPhase[processIdx] = true;
                        onFocus(processIdx+1);
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
                      value: turn.phases[processIdx].move!.isSuccess,
                      onChanged: turn.phases[processIdx].move!.playerType.id != PlayerType.none ?
                        (value) {
                          turn.phases[processIdx].move!.isSuccess = value!;
                          appState.editingPhase[processIdx] = true;
                          onFocus(processIdx+1);
                        } : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              turn.phases[processIdx].move!.extraInputWidget1(
                () => onFocus(processIdx+1), battle.ownParty, 
                battle.opponentParty, moveState, ownPokemon, opponentPokemon,
                moveState.ownPokemonStates[moveState.ownPokemonIndex-1], 
                moveState.opponentPokemonStates[moveState.opponentPokemonIndex-1],
                moveControllerList[processIdx], hpControllerList[processIdx], pokeData,
                appState, processIdx,
              ),
              SizedBox(height: 10,),
              turn.phases[processIdx].move!.extraInputWidget2(
                () => onFocus(processIdx+1), ownPokemon, opponentPokemon,
                moveState.ownPokemonStates[moveState.ownPokemonIndex-1],
                moveState.opponentPokemonStates[moveState.opponentPokemonIndex-1],
                hpControllerList[processIdx], appState, processIdx, 0,
              ),
              SizedBox(height: 10,),
              for (final e in guides)
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
        return 'ポケモン交換';
      case TurnMoveType.surrender:
        return 'こうさん';
      default:
        break;
    }

    return '行動';
  }
}
