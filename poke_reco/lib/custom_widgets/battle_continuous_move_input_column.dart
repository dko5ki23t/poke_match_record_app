import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/timing.dart';

class BattleContinuousMoveInputColumn extends Column {
  BattleContinuousMoveInputColumn(
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
    TurnMove refMove,
    int continuousCount,
    List<String> guides,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      !turn.phases[phaseIdx].isAdding ?
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
                  _getTitle(turn.phases[phaseIdx].move!, ownPokemon, opponentPokemon, continuousCount)
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
                        refMove.moveHits.removeAt(continuousCount);
                        refMove.moveEffectivenesses.removeAt(continuousCount);
                        refMove.moveAdditionalEffects.removeAt(continuousCount);
                        refMove.realDamage.removeAt(continuousCount);
                        refMove.percentDamage.removeAt(continuousCount);
                        turn.phases.removeAt(phaseIdx);
                        appState.editingPhase.removeAt(phaseIdx);
                        moveControllerList.removeAt(phaseIdx);
                        hpControllerList.removeAt(phaseIdx);
                        onFocus(0); // フォーカスリセット
                      },
                    ),
                  ],
                ),
              ],),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.extraInputWidget2(
                () => onFocus(phaseIdx+1), ownPokemon, opponentPokemon,
                battle.ownParty,
                battle.opponentParty,
                prevState.ownPokemonState,
                prevState.opponentPokemonState,
                prevState.ownPokemonStates,
                prevState.opponentPokemonStates,
                prevState,
                hpControllerList[phaseIdx],
                textEditingControllerList3[phaseIdx],
                appState, phaseIdx, continuousCount,
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
      ) :
      // 連続こうげき追加ボタン
      TextButton(
        onPressed:
          () {
            refMove.moveHits.add(MoveHit(MoveHit.hit));
            refMove.moveEffectivenesses.add(MoveEffectiveness(MoveEffectiveness.normal));
            refMove.moveAdditionalEffects.add(MoveEffect(refMove.move.effect.id));
            refMove.extraArg1.add(0);
            refMove.extraArg2.add(0);
            refMove.realDamage.add(0);
            refMove.percentDamage.add(0);
            turn.phases[phaseIdx]
            ..effect = EffectType(EffectType.move)
            ..move = refMove
            ..playerType = refMove.playerType
            ..isAdding = false;
            hpControllerList[phaseIdx].text =
              turn.phases[phaseIdx].getEditingControllerText2(currentState);
            onFocus(phaseIdx+1);
          },
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
              Text('${refMove.move.displayName}(${continuousCount+1}回目)を追加'),
            ],
          ),
        ),
      ),
    ],
  );

  static String _getTitle(TurnMove turnMove, Pokemon own, Pokemon opponent, int continuousCount) {
    switch (turnMove.type.id) {
      case TurnMoveType.move:
        if (turnMove.move.id != 0) {
          if (turnMove.playerType.id == PlayerType.opponent) {
            return '【${continuousCount+1}回目】${turnMove.move.displayName}-${opponent.name}';
          }
          else {
            return '【${continuousCount+1}回目】${turnMove.move.displayName}-${own.name}';
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
