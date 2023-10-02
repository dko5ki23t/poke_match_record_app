import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_timing_input_panel.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
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
    List<TextEditingController> textEditControllerList3,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),
            for (int i = 0; i < sameTimingList.length; i++)
            BattleTimingInputPanel(
              pokeData, setState, theme, battle, battle.turns[turnNum-1],
              appState, focusPhaseIdx, onFocus,
              sameTimingList[i],
              textEditControllerList1, textEditControllerList2, textEditControllerList3,
              _getPrevPhase(battle.turns[turnNum-1], i, sameTimingList),
              _getPrevPhaseOwnPokemon(battle, battle.turns[turnNum-1], i, sameTimingList),
              _getPrevPhaseOpponentPokemon(battle, battle.turns[turnNum-1], i, sameTimingList),
              _getRefMove(sameTimingList, i, battle.turns[turnNum-1]),
              _getContinuousCount(sameTimingList, i, battle.turns[turnNum-1]),
              _getActionCount(sameTimingList, i),
              i > 0 ? sameTimingList[i-1].first.turnEffect.playerType : PlayerType(PlayerType.none),  // わざ使用後の場合、そのわざの発動主を渡す
              i > 0 ? sameTimingList[i-1].first.turnEffect.move ?? TurnMove() : TurnMove(),
            )
          ],
        ),
      ),
    ],
  );

  static Pokemon _getPrevPhaseOwnPokemon(
    Battle battle, Turn turn, int i,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
  ) {
    if (i <= 0 || i > sameTimingList.length) {
      return battle.ownParty.pokemons[turn.initialOwnPokemonIndex-1]!;
    }
    return battle.ownParty.pokemons[sameTimingList[i-1].last.phaseState.ownPokemonIndex-1]!;
  }

  static Pokemon _getPrevPhaseOpponentPokemon(
    Battle battle, Turn turn, int i,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
  ) {
    if (i <= 0 || i > sameTimingList.length) {
      return battle.opponentParty.pokemons[turn.initialOpponentPokemonIndex-1]!;
    }
    return battle.opponentParty.pokemons[sameTimingList[i-1].last.phaseState.opponentPokemonIndex-1]!;
  }

  static PhaseState _getPrevPhase(
    Turn turn, int i,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
  ) {
    if (i <= 0 || i > sameTimingList.length) {
      return turn.copyInitialState();
    }
    return sameTimingList[i-1].last.phaseState;
  }

  static TurnMove? _getRefMove(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i, Turn turn) {
    if (sameTimingList[i].last.turnEffect.timing.id != AbilityTiming.continuousMove) return null;
    TurnMove? ret;
    for (int j = 0; j < i; j++) {
      var turnMove = sameTimingList[j].first.turnEffect.move;
      if (sameTimingList[j].first.turnEffect.timing.id == AbilityTiming.action &&
          turnMove?.type.id == TurnMoveType.move
      ) {
        ret = turnMove;
      }
    }
    return ret;
  }

  static int _getContinuousCount(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i, Turn turn) {
    if (sameTimingList[i].last.turnEffect.timing.id != AbilityTiming.continuousMove) return 0;
    int ret = 0;
    for (int j = 0; j <= i; j++) {
      var turnMove = sameTimingList[j].first.turnEffect.move;
      if (sameTimingList[j].first.turnEffect.timing.id == AbilityTiming.action &&
          turnMove?.type.id == TurnMoveType.move
      ) {
        ret = 0;
      }
      else if (sameTimingList[j].first.turnEffect.timing.id == AbilityTiming.continuousMove) {
        ret++;
      }
    }
    return ret;
  }

  static int _getActionCount(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i,) {
    if (sameTimingList[i].last.turnEffect.timing.id != AbilityTiming.action) return 0;
    int ret = 0;
    for (int j = 0; j < i; j++) {
      if (sameTimingList[j].first.turnEffect.timing.id == AbilityTiming.action) {
        ret++;
      }
    }
    return ret;
  }

}