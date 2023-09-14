import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_timing_input_panel.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_move.dart';

class BattleTurnListView extends ListView {
  BattleTurnListView(
    void Function() setState,
    Battle battle,
    int turnNum,
    ThemeData theme,
    PokeDB pokeData,
    Pokemon initialOwnPokemon,
    Pokemon initialOpponentPokemon,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    ExpandableController beforeMoveExpandController,
    ExpandableController moveExpandController,
    ExpandableController afterMoveExpandController,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    List<SameTimingEffectRange> sameTimingEffectRangeList,
    List<PhaseState> stateList,
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),
            for (int i = 0; i < sameTimingEffectRangeList.length; i++)
            BattleTimingInputPanel(
              pokeData, setState, theme, battle, battle.turns[turnNum-1],
              appState, focusPhaseIdx, onFocus,
              beforeMoveExpandController, sameTimingEffectRangeList[i],
              stateList.sublist(sameTimingEffectRangeList[i].beginIdx, sameTimingEffectRangeList[i].endIdx+1),
              textEditControllerList1, textEditControllerList2,
              _getPrevPhaseOwnPokemon(battle, battle.turns[turnNum-1], i, sameTimingEffectRangeList, stateList),
              _getPrevPhaseOpponentPokemon(battle, battle.turns[turnNum-1], i, sameTimingEffectRangeList, stateList),
              _getRefMove(sameTimingEffectRangeList, i, battle.turns[turnNum-1]),
              _getContinuousCount(sameTimingEffectRangeList, i, battle.turns[turnNum-1]),
              _getActionCount(sameTimingEffectRangeList, i),
            )
          ],
        ),
      ),
    ],
  );

  static Pokemon _getPrevPhaseOwnPokemon(
    Battle battle, Turn turn, int i,
    List<SameTimingEffectRange> sameTimingEffectRangeList,
    List<PhaseState> stateList,
  ) {
    if (i <= 0 || i > sameTimingEffectRangeList.length) {
      return battle.ownParty.pokemons[turn.initialOwnPokemonIndex-1]!;
    }
    int prevEnd = sameTimingEffectRangeList[i-1].endIdx;
    if (prevEnd < stateList.length && prevEnd >= 0) {
      return battle.ownParty.pokemons[stateList[prevEnd].ownPokemonIndex-1]!;
    }
    else {
      return battle.ownParty.pokemons[turn.initialOwnPokemonIndex-1]!;
    }
  }

  static Pokemon _getPrevPhaseOpponentPokemon(
    Battle battle, Turn turn, int i,
    List<SameTimingEffectRange> sameTimingEffectRangeList,
    List<PhaseState> stateList,
  ) {
    if (i <= 0 || i > sameTimingEffectRangeList.length) {
      return battle.opponentParty.pokemons[turn.initialOpponentPokemonIndex-1]!;
    }
    int prevEnd = sameTimingEffectRangeList[i-1].endIdx;
    if (prevEnd < stateList.length && prevEnd >= 0) {
      return battle.opponentParty.pokemons[stateList[prevEnd].opponentPokemonIndex-1]!;
    }
    else {
      return battle.opponentParty.pokemons[turn.initialOpponentPokemonIndex-1]!;
    }
  }

  static TurnMove? _getRefMove(List<SameTimingEffectRange> sameTimingEffectRangeList, int i, Turn turn) {
    if (sameTimingEffectRangeList[i].timing.id != AbilityTiming.continuousMove) return null;
    TurnMove? ret;
    for (int j = 0; j < i; j++) {
      if (sameTimingEffectRangeList[j].beginIdx >= turn.processes.length) {
        continue;
      }
      var turnMove = turn.processes[sameTimingEffectRangeList[j].beginIdx].move;
      if (sameTimingEffectRangeList[j].timing.id == AbilityTiming.action &&
          turnMove?.type == TurnMoveType.move &&
          turnMove!.move.maxMoveCount() > 1
      ) {
        ret = turnMove;
      }
    }
    return ret;
  }

  static int _getContinuousCount(List<SameTimingEffectRange> sameTimingEffectRangeList, int i, Turn turn) {
    if (sameTimingEffectRangeList[i].timing.id != AbilityTiming.continuousMove) return 0;
    int ret = 0;
    for (int j = 0; j <= i; j++) {
      if (sameTimingEffectRangeList[j].beginIdx >= turn.processes.length) {
        continue;
      }
      var turnMove = turn.processes[sameTimingEffectRangeList[j].beginIdx].move;
      if (sameTimingEffectRangeList[j].timing.id == AbilityTiming.action &&
          turnMove?.type == TurnMoveType.move &&
          turnMove!.move.maxMoveCount() > 1
      ) {
        ret = 0;
      }
      else if (sameTimingEffectRangeList[j].timing.id == AbilityTiming.continuousMove) {
        ret++;
      }
    }
    return ret;
  }

  static int _getActionCount(List<SameTimingEffectRange> sameTimingEffectRangeList, int i,) {
    if (sameTimingEffectRangeList[i].timing.id != AbilityTiming.action) return 0;
    int ret = 0;
    for (int j = 0; j < i; j++) {
      if (sameTimingEffectRangeList[j].timing.id == AbilityTiming.action) {
        ret++;
      }
    }
    return ret;
  }

}