import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_action_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_continuous_move_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_first_turn_first_effect_input_column.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_move.dart';

class BattleTimingInputPanel extends Column {
  BattleTimingInputPanel(
    PokeDB pokeData,
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    ExpandableController expandableController,
    SameTimingEffectRange sameTimingEffectRange,
    List<PhaseState> stateList,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
    int actionCount,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
/*
      ExpandablePanel(
        controller: expandableController,
        header: Text(_getHeaderString(sameTimingEffectRange.timing)),
        collapsed: Text('タップで詳細を設定'),
        expanded: _getExpandedWidget(
          sameTimingEffectRange.timing,
          pokeData, setState, theme, battle,
          turn, appState, focusPhaseIdx,
          (phaseIdx) => onFocus(phaseIdx), sameTimingEffectRange,
          stateList, textEditControllerList1, textEditControllerList2,
          prevOwnPokemon, prevOpponentPokemon,
        ),
      ),
*/
      _getHeader(sameTimingEffectRange.timing, actionCount),
      _getDivider(sameTimingEffectRange.timing),
      Container(
        child: _getExpandedWidget(
          sameTimingEffectRange.timing,
          pokeData, setState, theme, battle,
          turn, appState, focusPhaseIdx,
          (phaseIdx) => onFocus(phaseIdx), sameTimingEffectRange,
          stateList, textEditControllerList1, textEditControllerList2,
          prevOwnPokemon, prevOpponentPokemon,
          refMove, continuousCount,
        ),
      ),
      SizedBox(height: 20,),
    ],
  );

  static Widget _getHeader(AbilityTiming timing, int actionCount) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:
        return Text('ポケモン登場時');
      case AbilityTiming.everyTurnEnd:
        return Text('ターン終了時');
      case AbilityTiming.afterActionDecision:
        return Text('行動決定直後');
      case AbilityTiming.action:
        return Text('行動${actionCount+1}');
      case AbilityTiming.continuousMove:
        return Container();
      case AbilityTiming.afterMove:
        return Text('わざ使用後');
      default:
        return Container();
    }
  }

  static Widget _getDivider(AbilityTiming timing) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:
      case AbilityTiming.everyTurnEnd:
      case AbilityTiming.afterActionDecision:
      case AbilityTiming.action:
        return const Divider(
          height: 10,
          thickness: 1,
        );
      case AbilityTiming.afterMove:
      case AbilityTiming.continuousMove:
      default:
        return Container();
    }
  }

  static Widget _getExpandedWidget(
    AbilityTiming timing,
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
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
  ) {
    return 
    timing.id == AbilityTiming.action ?
    BattleActionInputColumn(
      pokeData, setState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingEffectRange.beginIdx, stateList[0], timing,
      textEditControllerList1, textEditControllerList2,
    ) :
    timing.id == AbilityTiming.continuousMove ?
    BattleContinuousMoveInputColumn(
      pokeData, setState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingEffectRange.beginIdx, stateList.isEmpty ? null : stateList[0], timing,
      textEditControllerList1, textEditControllerList2,
      sameTimingEffectRange.endIdx - sameTimingEffectRange.beginIdx >= 0,
      refMove!, continuousCount
    ) :
    BattleFirstTurnFirstEffectInputColumn(
      pokeData, setState, theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingEffectRange, stateList, timing,
      textEditControllerList1, textEditControllerList2,
    );
  }
}