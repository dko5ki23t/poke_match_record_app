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
import 'package:poke_reco/tool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleContinuousMoveColumn extends Column {
  BattleContinuousMoveColumn(
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
    List<TextEditingController> textEditingControllerList4,
    TurnMove refMove,
    int continuousCount,
    TurnEffectAndStateAndGuide turnEffectAndStateAndGuide,
    TurnEffectAndStateAndGuide? nextSameTimingFirst,
    {
      required bool isInput,
      required AppLocalizations loc,
    }
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
              isInput ?
                Stack(
                  children: [
                  Center(child: Text(
                    _getTitle(turn.phases[phaseIdx].move!, ownPokemon, opponentPokemon, continuousCount, loc)
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                      appState.editingPhase[phaseIdx] ?
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: turn.phases[phaseIdx].move!.isValid() ? () {
                          nextSameTimingFirst?.needAssist = true;
                          appState.editingPhase[phaseIdx] = false;
                          appState.needAdjustPhases = phaseIdx+1;
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
                          textEditingControllerList3.removeAt(phaseIdx);
                          textEditingControllerList4.removeAt(phaseIdx);
                          onFocus(0); // フォーカスリセット
                        },
                      ),
                    ],
                  ),
                ],) :
                Center(child: Text(
                  _getTitle(turn.phases[phaseIdx].move!, ownPokemon, opponentPokemon, continuousCount, loc)
                )),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.extraWidget2(
                () => onFocus(phaseIdx+1), theme, ownPokemon, opponentPokemon,
                battle.getParty(PlayerType(PlayerType.me)),
                battle.getParty(PlayerType(PlayerType.opponent)),
                prevState.getPokemonState(PlayerType(PlayerType.me), null),
                prevState.getPokemonState(PlayerType(PlayerType.opponent), null),
                prevState.getPokemonStates(PlayerType(PlayerType.me)),
                prevState.getPokemonStates(PlayerType(PlayerType.opponent)),
                prevState,
                hpControllerList[phaseIdx],
                textEditingControllerList3[phaseIdx],
                textEditingControllerList4[phaseIdx],
                appState, phaseIdx, continuousCount,
                turnEffectAndStateAndGuide,
                turn.phases[phaseIdx].invalidGuideIDs,
                isInput: isInput,
                loc: loc,
              ),
              SizedBox(height: 10,),
              for (final e in turnEffectAndStateAndGuide.guides)
              Row(
                children: [
                  Expanded(child: Icon(Icons.info, color: Colors.lightGreen,)),
                  Expanded(flex: 10, child: Text(e.guideStr)),
                  e.canDelete && isInput ?
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        turn.phases[phaseIdx].invalidGuideIDs.add(e.guideId);
                        appState.needAdjustPhases = phaseIdx+1;
                        onFocus(phaseIdx+1);
                      },
                      icon: Icon(Icons.cancel, color: Colors.grey[800],)
                    ),
                  ) : Container(),
                ],
              ),
            ],
          ),
        ),
      ) :
      // 連続こうげき追加ボタン
      isInput ?
        TextButton(
          onPressed:
            getSelectedNum(appState.editingPhase) == 0 ?
            () {
              var myState = prevState.getPokemonState(refMove.playerType, null);
              var yourState = prevState.getPokemonState(refMove.playerType.opposite, null);
              var yourFields = refMove.playerType.id == PlayerType.me ? prevState.opponentFields : prevState.ownFields;
              refMove.moveHits.add(refMove.getMoveHit(refMove.move, continuousCount, myState, yourState, yourFields));
              refMove.moveEffectivenesses.add(refMove.moveEffectivenesses[0]);
              refMove.moveAdditionalEffects.add(MoveEffect(refMove.move.effect.id));
              refMove.extraArg1.add(0);
              refMove.extraArg2.add(0);
              refMove.extraArg3.add(0);
              refMove.realDamage.add(0);
              refMove.percentDamage.add(0);
              turn.phases[phaseIdx]
              ..effect = EffectType(EffectType.move)
              ..move = refMove
              ..playerType = refMove.playerType
              ..isAdding = false;
              hpControllerList[phaseIdx].text =
                turn.phases[phaseIdx].getEditingControllerText2(currentState, null);
              textEditingControllerList3[phaseIdx].text =
                turn.phases[phaseIdx].getEditingControllerText3(currentState, null);
              textEditingControllerList4[phaseIdx].text =
                turn.phases[phaseIdx].getEditingControllerText4(currentState);
              onFocus(phaseIdx+1);
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
                Text(continuousCount == 1 ? loc.battleAddMoveTimes2(refMove.move.displayName) : continuousCount == 2 ? loc.battleAddMoveTimes3(refMove.move.displayName) : loc.battleAddMoveTimes4(continuousCount+1, refMove.move.displayName)),
              ],
            ),
          ),
        ) :
        Container(),
    ],
  );

  static String _getTitle(TurnMove turnMove, Pokemon own, Pokemon opponent, int continuousCount, AppLocalizations loc) {
    switch (turnMove.type.id) {
      case TurnMoveType.move:
        if (turnMove.move.id != 0) {
          var str = continuousCount == 0 ? loc.battleMoveTimes1 :
            continuousCount == 1 ? loc.battleMoveTimes2 :
            continuousCount == 2 ? loc.battleMoveTimes3 : loc.battleMoveTimes4;
          if (turnMove.playerType.id == PlayerType.opponent) {
            return '$str${turnMove.move.displayName}-${opponent.name}';
          }
          else {
            return '$str${turnMove.move.displayName}-${own.name}';
          }
        }
        break;
      case TurnMoveType.change:
        return loc.battlePokemonChange;
      case TurnMoveType.surrender:
        return loc.battleSurrender;
      default:
        break;
    }

    return loc.battleAction;
  }
}
