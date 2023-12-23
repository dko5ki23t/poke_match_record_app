import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleActionColumn extends Column {
  BattleActionColumn(
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
                    _getTitle(turn.phases[phaseIdx].move, ownPokemon, opponentPokemon, loc)
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                      // 編集中でなければ並べ替えボタン
                      !appState.editingPhase[phaseIdx] ?
                      IconButton(
                        icon: Icon(Icons.swap_vert),
                        onPressed: () {
                          appState.requestActionSwap = true;
                          onFocus(phaseIdx+1);
                        },
                      ) :
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: turn.phases[phaseIdx].move!.isValid() ? () {
                          nextSameTimingFirst?.needAssist = true;
                          appState.editingPhase[phaseIdx] = false;
                          appState.needAdjustPhases = phaseIdx+1;
                          onFocus(phaseIdx+1);
                        } : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          turn.phases[phaseIdx].move!.clear();
                          moveControllerList[phaseIdx].text = '';
                          hpControllerList[phaseIdx].text = '';
                          textEditingControllerList3[phaseIdx].text = '';
                          textEditingControllerList4[phaseIdx].text = '';
                          turnEffectAndStateAndGuide.guides.clear();
                          onFocus(phaseIdx+1);
                        },
                      ),
                    ],
                  ),
                ],) :
                Center(child: Text(
                  _getTitle(turn.phases[phaseIdx].move, ownPokemon, opponentPokemon, loc)
                )),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: isInput ?
                      DropdownButtonFormField(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePlayer,
                        ),
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            value: PlayerType.me,
                            child: Text('${ownPokemon.name}/${loc.battleYou}', overflow: TextOverflow.ellipsis,),
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
                          var myState = prevState.getPokemonState(PlayerType(value), null);
                          if (myState.isTerastaling) {
                            turn.phases[phaseIdx].move!.teraType = myState.teraType1;
                          }
                          turn.phases[phaseIdx].move!.type = TurnMoveType(TurnMoveType.move);
                          moveControllerList[phaseIdx].text = '';
                          hpControllerList[phaseIdx].text =
                            turn.phases[phaseIdx].getEditingControllerText2(currentState, null);
                          textEditingControllerList3[phaseIdx].text =
                            turn.phases[phaseIdx].getEditingControllerText3(currentState, null);
                          textEditingControllerList4[phaseIdx].text =
                            turn.phases[phaseIdx].getEditingControllerText4(currentState);
                          appState.editingPhase[phaseIdx] = true;
                          onFocus(phaseIdx+1);
                        },
                      ) :
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePlayer,
                        ),
                        controller: TextEditingController(
                          text: turn.phases[phaseIdx].move!.playerType.id == PlayerType.me ? '${ownPokemon.name}/${loc.battleYou}' :
                                turn.phases[phaseIdx].move!.playerType.id == PlayerType.opponent ?'${opponentPokemon.name}/${battle.opponentName}' : '',
                        ),
                        readOnly: true,
                        onTap:() => onFocus(phaseIdx+1),
                      ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: isInput ?
                      DropdownButtonFormField<bool>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battleSuccessFailureOfAction,
                        ),
                        items: <DropdownMenuItem<bool>>[
                          DropdownMenuItem(
                            value: true,
                            child: Text(loc.battleActionSuccessed, overflow: TextOverflow.ellipsis,),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(loc.battleActionFailed, overflow: TextOverflow.ellipsis,),
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
                      ) :
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battleSuccessFailureOfAction,
                        ),
                        controller: TextEditingController(
                          text: turn.phases[phaseIdx].move!.isSuccess ?
                            loc.battleSucceeded : loc.battleFailed,
                        ),
                        readOnly: true,
                        onTap: () => onFocus(phaseIdx+1),
                      ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              turn.phases[phaseIdx].move!.extraWidget1(
                () => onFocus(phaseIdx+1),
                () {
                  hpControllerList[phaseIdx].text =
                    turn.phases[phaseIdx].getEditingControllerText2(currentState, null);
                  textEditingControllerList3[phaseIdx].text =
                    turn.phases[phaseIdx].getEditingControllerText3(currentState, null, isOnMoveSelected: true,);
                  textEditingControllerList4[phaseIdx].text =
                    turn.phases[phaseIdx].getEditingControllerText4(currentState);
                  appState.needAdjustPhases = phaseIdx;
                  onFocus(phaseIdx+1);
                },
                battle.getParty(PlayerType(PlayerType.me)), 
                battle.getParty(PlayerType(PlayerType.opponent)), prevState, ownPokemon, opponentPokemon,
                prevState.getPokemonState(PlayerType(PlayerType.me), null),
                prevState.getPokemonState(PlayerType(PlayerType.opponent), null),
                moveControllerList[phaseIdx], hpControllerList[phaseIdx],
                appState, phaseIdx, 0, turnEffectAndStateAndGuide, theme,
                turn.phases[phaseIdx].invalidGuideIDs,
                isInput: isInput,
                loc: loc,
              ),
              SizedBox(height: turn.phases[phaseIdx].move!.isSuccess ? 10 : 0,),
              turn.phases[phaseIdx].move!.isSuccess || turn.phases[phaseIdx].move!.actionFailure.id == ActionFailure.confusion ?
              turn.phases[phaseIdx].move!.extraWidget2(
                () => onFocus(phaseIdx+1), theme, ownPokemon, opponentPokemon,
                battle.getParty(PlayerType(PlayerType.me)), battle.getParty(PlayerType(PlayerType.opponent)),
                prevState.getPokemonState(PlayerType(PlayerType.me), null),
                prevState.getPokemonState(PlayerType(PlayerType.opponent), null),
                prevState.getPokemonStates(PlayerType(PlayerType.me)),
                prevState.getPokemonStates(PlayerType(PlayerType.opponent)),
                prevState,
                hpControllerList[phaseIdx],
                textEditingControllerList3[phaseIdx],
                textEditingControllerList4[phaseIdx],
                appState, phaseIdx, 0,
                turnEffectAndStateAndGuide, 
                turn.phases[phaseIdx].invalidGuideIDs,
                isInput: isInput,
                loc: loc,
              ) : Container(),
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
                      icon: Icon(Icons.cancel, color: Colors.grey[800],),),
                   ) : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );

  static String _getTitle(TurnMove? turnMove, Pokemon own, Pokemon opponent, AppLocalizations loc,) {
    if (turnMove != null) {
      switch (turnMove.type.id) {
        case TurnMoveType.move:
          if (turnMove.move.id != 0) {
            String continous = turnMove.move.maxMoveCount() > 1 ? loc.battleMoveTimes1 : '';
            if (turnMove.playerType.id == PlayerType.opponent) {
              return '$continous${turnMove.move.displayName}-${opponent.name}';
            }
            else {
              return '$continous${turnMove.move.displayName}-${own.name}';
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
    }

    return loc.battleAction;
  }
}
