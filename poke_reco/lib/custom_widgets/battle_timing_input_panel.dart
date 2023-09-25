import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_action_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_change_fainting_pokemon_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_continuous_move_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_effect_input_column.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
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
    List<TurnEffectAndStateAndGuide> sameTimingList,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    PhaseState prevState,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
    int actionCount,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _getHeader(sameTimingList.first.turnEffect.timing, actionCount),
      _getDivider(sameTimingList.first.turnEffect.timing),
      Container(
        child: _getExpandedWidget(
          sameTimingList.first.turnEffect.timing,
          pokeData, setState, theme, battle,
          turn, appState, focusPhaseIdx,
          (phaseIdx) => onFocus(phaseIdx), sameTimingList,
          textEditControllerList1, textEditControllerList2,
          prevState, prevOwnPokemon, prevOpponentPokemon,
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
      case AbilityTiming.changeFaintingPokemon:
        return Text('ポケモン交代');
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
      case AbilityTiming.changeFaintingPokemon:
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
    List<TurnEffectAndStateAndGuide> sameTimingList,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    PhaseState prevState,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
  ) {
    return 
    timing.id == AbilityTiming.action ?
    BattleActionInputColumn(
      pokeData, prevState,
      sameTimingList.first.phaseState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      turn.phases.indexWhere((element) => element == sameTimingList.first.turnEffect),
      timing, textEditControllerList1,
      textEditControllerList2,
      sameTimingList.first.guides,
    ) :
    timing.id == AbilityTiming.continuousMove ?
    BattleContinuousMoveInputColumn(
      pokeData, prevState,
      sameTimingList.first.phaseState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      turn.phases.indexWhere((element) => element == sameTimingList.first.turnEffect),
      timing, textEditControllerList1,
      textEditControllerList2,
      refMove!, continuousCount,
      sameTimingList.first.guides,
    ) :
    timing.id == AbilityTiming.changeFaintingPokemon ?
    BattleChangeFaintingPokemonInputColumn(
      pokeData, prevState,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      turn.phases.indexWhere((element) => element == sameTimingList.first.turnEffect),
      timing, textEditControllerList1,
      textEditControllerList2,
      sameTimingList.first.guides,
    ) :
    BattleEffectInputColumn(
      pokeData, theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      turn.phases.indexWhere((element) => element == sameTimingList.first.turnEffect),
      timing, textEditControllerList1, textEditControllerList2,
    );
  }
}