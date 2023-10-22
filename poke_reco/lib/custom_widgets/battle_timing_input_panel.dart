import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_action_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_change_fainting_pokemon_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_continuous_move_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_effect_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_gameset_column.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/phase_state.dart';

class BattleTimingInputPanel extends Column {
  BattleTimingInputPanel(
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
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    PhaseState prevState,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
    int actionCount,
    PlayerType attacker,
    TurnMove turnMove,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _getHeader(sameTimingList.first.turnEffect.timing, actionCount),
      _getDivider(sameTimingList.first.turnEffect.timing),
      Container(
        child: _getExpandedWidget(
          sameTimingList.first.turnEffect.timing,
          setState, theme, battle,
          turn, appState, focusPhaseIdx,
          (phaseIdx) => onFocus(phaseIdx), sameTimingList,
          textEditControllerList1, textEditControllerList2,
          textEditControllerList3, textEditControllerList4,
          prevState, prevOwnPokemon, prevOpponentPokemon,
          refMove, continuousCount, attacker, turnMove,
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
      case AbilityTiming.gameSet:
        return Text('対戦終了！');
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
      case AbilityTiming.gameSet:
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
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    PhaseState prevState,
    Pokemon prevOwnPokemon,
    Pokemon prevOpponentPokemon,
    TurnMove? refMove,
    int continuousCount,
    PlayerType attacker,
    TurnMove turnMove,
  ) {
    return 
    timing.id == AbilityTiming.action ?
    BattleActionInputColumn(
      prevState,
      sameTimingList.first.phaseState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1,
      textEditControllerList2,
      textEditControllerList3,
      textEditControllerList4,
      sameTimingList.first,
    ) :
    timing.id == AbilityTiming.continuousMove ?
    BattleContinuousMoveInputColumn(
      prevState,
      sameTimingList.first.phaseState,
      prevOwnPokemon, prevOpponentPokemon,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1,
      textEditControllerList2,
      textEditControllerList3,
      textEditControllerList4,
      refMove!, continuousCount,
      sameTimingList.first,
    ) :
    timing.id == AbilityTiming.changeFaintingPokemon ?
    BattleChangeFaintingPokemonInputColumn(
      prevState,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1,
      textEditControllerList2,
      textEditControllerList3,
      sameTimingList.first.guides,
    ) :
    timing.id == AbilityTiming.gameSet ?
    BattleGamesetColumn(
      theme, sameTimingList.first.turnEffect,
      battle.opponentName) :
    BattleEffectInputColumn(
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1, textEditControllerList2,
      textEditControllerList3, textEditControllerList4,
      attacker, turnMove,
    );
  }
}