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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _getHeader(sameTimingList.first.turnEffect.timing, actionCount, sameTimingList, loc),
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
          nextSameTimingFirst, isInput: isInput, loc: loc,
        ),
      ),
      SizedBox(height: 20,),
    ],
  );

  static Widget _getHeader(Timing timing, int actionCount, List<TurnEffectAndStateAndGuide> sameTimingList, AppLocalizations loc) {
    switch (timing) {
      case Timing.pokemonAppear:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text(loc.battleTimingPokemonAppear);
        }
        break;
      case Timing.everyTurnEnd:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text(loc.battleTimingTurnEnd);
        }
        break;
      case Timing.afterActionDecision:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text(loc.battleTimingAfterActionDecision);
        }
        break;
      case Timing.terastaling:
        return Text(loc.commonTerastal);
      case Timing.action:
        return Text('${loc.battleAction}${actionCount+1}');
      case Timing.beforeMove:
        return Column(
          children: [
            Text('${loc.battleAction}${actionCount+1}'),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            sameTimingList.first.candidateEffect.isNotEmpty ?
            Text(loc.battleTimingBeforeMove) : Container(),
          ],
        );
      case Timing.afterMove:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return Text(loc.battleTimingAfterMove);
        }
        break;
      case Timing.changeFaintingPokemon:
        return Text(loc.battlePokemonChange);
      case Timing.gameSet:
        return Text(loc.battleTimingGameSet);
      case Timing.continuousMove:
      default:
        break;
    }
    return Container();
  }

  static Widget _getDivider(Timing timing, List<TurnEffectAndStateAndGuide> sameTimingList) {
    switch (timing) {
      case Timing.pokemonAppear:
      case Timing.everyTurnEnd:
      case Timing.afterActionDecision:
        if (sameTimingList.first.candidateEffect.isNotEmpty) {
          return const Divider(
            height: 10,
            thickness: 1,
          );
        }
        break;
      case Timing.terastaling:
      case Timing.changeFaintingPokemon:
      case Timing.gameSet:
        return const Divider(
          height: 10,
          thickness: 1,
        );
      case Timing.beforeMove:
      case Timing.action:
      case Timing.afterMove:
      case Timing.continuousMove:
      default:
        break;
    }
    return Container();
  }

  static Widget _getExpandedWidget(
    Timing timing,
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
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  ) {
    return 
    timing == Timing.action ?
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
      loc: loc,
    ) :
    timing == Timing.continuousMove ?
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
      loc: loc,
    ) :
    timing == Timing.changeFaintingPokemon ?
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
      loc: loc,
    ) :
    timing == Timing.gameSet ?
    BattleGamesetColumn(
      theme, sameTimingList.first.turnEffect,
      battle.opponentName, loc: loc) :
    timing == Timing.terastaling ?
    BattleTerastalColumn(
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1, textEditControllerList2,
      textEditControllerList3, textEditControllerList4,
      isInput: isInput, loc: loc
    ) :
    BattleEffectColumn(
      theme, battle, turn,
      appState, focusPhaseIdx,
      (phaseIdx) => onFocus(phaseIdx),
      prevState, sameTimingList,
      sameTimingList.first.phaseIdx,
      timing, textEditControllerList1, textEditControllerList2,
      textEditControllerList3, textEditControllerList4,
      attacker, turnMove, isInput: isInput, loc: loc,
    );
  }
}