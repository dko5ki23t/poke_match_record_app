import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/poke_move.dart';

class BattleContinuousMoveInputColumn extends Column {
  BattleContinuousMoveInputColumn(
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
    PhaseState? moveState,
    AbilityTiming timing,
    List<TextEditingController> moveControllerList,
    List<TextEditingController> hpControllerList,
    TurnMove refMove,
    int continuousCount,
    List<String> guides,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      !turn.phases[processIdx].isAdding ?
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
                  _getTitle(turn.phases[processIdx].move!, ownPokemon, opponentPokemon, continuousCount)
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
                        refMove.moveHits.removeAt(continuousCount);
                        refMove.moveEffectivenesses.removeAt(continuousCount);
                        refMove.moveAdditionalEffects.removeAt(continuousCount);
                        turn.phases.removeAt(processIdx);
                        appState.editingPhase.removeAt(processIdx);
                        moveControllerList.removeAt(processIdx);
                        hpControllerList.removeAt(processIdx);
                        onFocus(0); // フォーカスリセット
                      },
                    ),
                  ],
                ),
              ],),
              SizedBox(height: 10,),
              turn.phases[processIdx].move!.extraInputWidget2(
                () => onFocus(processIdx+1), ownPokemon, opponentPokemon,
                moveState!.ownPokemonStates[moveState.ownPokemonIndex-1],
                moveState.opponentPokemonStates[moveState.opponentPokemonIndex-1],
                hpControllerList[processIdx], appState, processIdx, continuousCount,
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
            refMove.moveAdditionalEffects.add(MoveAdditionalEffect(MoveAdditionalEffect.none));
            turn.phases[processIdx]
            ..effect = EffectType(EffectType.move)
            ..move = refMove
            ..isAdding = false;
            onFocus(processIdx+1);
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
        return 'ポケモン交換';
      case TurnMoveType.surrender:
        return 'こうさん';
      default:
        break;
    }

    return '行動';
  }
}
