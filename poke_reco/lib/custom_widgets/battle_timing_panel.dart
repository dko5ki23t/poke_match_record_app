import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_action_column.dart';
import 'package:poke_reco/custom_widgets/battle_change_fainting_pokemon_column.dart';
import 'package:poke_reco/custom_widgets/battle_continuous_move_column.dart';
import 'package:poke_reco/custom_widgets/battle_effect_column.dart';
import 'package:poke_reco/custom_widgets/battle_gameset_column.dart';
import 'package:poke_reco/custom_widgets/battle_terastal_column.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/phase_state.dart';

class BattleTimingPanel extends Column {
  BattleTimingPanel(
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
    TurnEffectAndStateAndGuide? nextSameTimingFirst,
    {required bool isInput,}
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _getHeader(sameTimingList.first.turnEffect.timing, actionCount, sameTimingList),
      _getDivider(sameTimingList.first.turnEffect.timing, sameTimingList),
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
          nextSameTimingFirst, isInput: isInput,
        ),
      ),
      SizedBox(height: 20,),
    ],
  );

  static Widget _getHeader(AbilityTiming timing, int actionCount, List<TurnEffectAndStateAndGuide> sameTimingList) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text('ポケモン登場時');
        }
        break;
      case AbilityTiming.everyTurnEnd:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text('ターン終了時');
        }
        break;
      case AbilityTiming.afterActionDecision:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text('行動決定直後');
        }
        break;
      case AbilityTiming.terastaling:
        return Text('テラスタル');
      case AbilityTiming.action:
        return Text('行動${actionCount+1}');
      case AbilityTiming.beforeMove:
        return Column(
          children: [
            Text('行動${actionCount+1}'),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            sameTimingList.first.candidateEffect.isNotEmpty ?
            Text('わざ使用前') : Container(),
          ],
        );
      case AbilityTiming.afterMove:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text('わざ使用後');
        }
        break;
      case AbilityTiming.changeFaintingPokemon:
        return Text('ポケモン交代');
      case AbilityTiming.gameSet:
        return Text('対戦終了！');
      case AbilityTiming.continuousMove:
      default:
        break;
    }
    return Container();
  }

  static Widget _getDivider(AbilityTiming timing, List<TurnEffectAndStateAndGuide> sameTimingList) {
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:
      case AbilityTiming.everyTurnEnd:
      case AbilityTiming.afterActionDecision:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return const Divider(
            height: 10,
            thickness: 1,
          );
        }
        break;
      case AbilityTiming.terastaling:
      case AbilityTiming.changeFaintingPokemon:
      case AbilityTiming.gameSet:
        return const Divider(
          height: 10,
          thickness: 1,
        );
      case AbilityTiming.beforeMove:
      case AbilityTiming.action:
      case AbilityTiming.afterMove:
      case AbilityTiming.continuousMove:
      default:
        break;
    }
    return Container();
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
    TurnEffectAndStateAndGuide? nextSameTimingFirst,
    {required bool isInput,}
  ) {
    return 
    timing.id == AbilityTiming.action ?
    BattleActionColumn(
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
      nextSameTimingFirst,
      isInput: isInput,
    ) :
    timing.id == AbilityTiming.continuousMove ?
    BattleContinuousMoveColumn(
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
      nextSameTimingFirst,
      isInput: isInput,
    ) :
    timing.id == AbilityTiming.changeFaintingPokemon ?
    BattleChangeFaintingPokemonColumn(
      prevState,
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1,
      textEditControllerList2,
      textEditControllerList3,
      sameTimingList.first.guides,
      isInput: isInput,
    ) :
    timing.id == AbilityTiming.gameSet ?
    BattleGamesetColumn(
      theme, sameTimingList.first.turnEffect,
      battle.opponentName) :
    timing.id == AbilityTiming.terastaling ?
    BattleTerastalColumn(
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1, textEditControllerList2,
      textEditControllerList3, textEditControllerList4,
      isInput: isInput,
    ) :
    BattleEffectColumn(
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1, textEditControllerList2,
      textEditControllerList3, textEditControllerList4,
      attacker, turnMove, isInput: isInput,
    );
  }
}