import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_timing_panel.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleTurnListView extends ListView {
  BattleTurnListView(
    ScrollController controller,
    void Function() setState,
    Battle battle,
    int turnNum,
    ThemeData theme,
    Pokemon initialOwnPokemon,
    Pokemon initialOpponentPokemon,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  ) : 
  super(
    controller: controller,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),
            for (int i = 0; i < sameTimingList.length; i++)
            BattleTimingPanel(
              setState, theme, battle, battle.turns[turnNum-1],
              appState, focusPhaseIdx, onFocus,
              sameTimingList[i],
              textEditControllerList1, textEditControllerList2,
              textEditControllerList3, textEditControllerList4,
              _getPrevPhase(
                battle.turns[turnNum-1], i, sameTimingList,
                battle.getParty(PlayerType.me),
                battle.getParty(PlayerType.opponent),
              ),
              _getPrevPhasePokemon(PlayerType.me, battle, battle.turns[turnNum-1], i, sameTimingList),
              _getPrevPhasePokemon(PlayerType.opponent, battle, battle.turns[turnNum-1], i, sameTimingList),
              _getRefMove(sameTimingList, i, battle.turns[turnNum-1]),
              _getContinuousCount(sameTimingList, i, battle.turns[turnNum-1]),
              _getActionCount(sameTimingList, i),
              sameTimingList[i].first.turnEffect.timing == Timing.beforeMove && i < sameTimingList.length-1 ?
                sameTimingList[i+1].first.turnEffect.playerType :           // わざ使用前の場合、そのわざの発動主を渡す
                i > 0 ? sameTimingList[i-1].first.turnEffect.playerType :   // わざ使用後の場合、そのわざの発動主を渡す
                PlayerType.none,
              i > 0 ? sameTimingList[i-1].first.turnEffect.move ?? TurnMove() : TurnMove(),
              i+1 < sameTimingList.length ? sameTimingList[i+1].first : null,
              isInput: isInput,
              loc: loc,
            )
          ],
        ),
      ),
    ],
  );

  static Pokemon _getPrevPhasePokemon(
    PlayerType player, Battle battle, Turn turn, int i,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
  ) {
    if (i <= 0 || i > sameTimingList.length) {
      return battle.getParty(player).pokemons[turn.getInitialPokemonIndex(player)-1]!;
    }
    return battle.getParty(player).pokemons[sameTimingList[i-1].last.phaseState.getPokemonIndex(player, null)-1]!;
  }

  static PhaseState _getPrevPhase(
    Turn turn, int i,
    List<List<TurnEffectAndStateAndGuide>> sameTimingList,
    Party ownParty, Party opponentParty,
  ) {
    if (i <= 0 || i > sameTimingList.length) {
      return turn.copyInitialState(ownParty, opponentParty);
    }
    return sameTimingList[i-1].last.phaseState;
  }

  static TurnMove? _getRefMove(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i, Turn turn) {
    if (sameTimingList[i].last.turnEffect.timing != Timing.continuousMove) return null;
    TurnMove? ret;
    for (int j = 0; j < i; j++) {
      var turnMove = sameTimingList[j].first.turnEffect.move;
      if (sameTimingList[j].first.turnEffect.timing == Timing.action &&
          turnMove?.type.id == TurnMoveType.move
      ) {
        ret = turnMove;
      }
    }
    return ret;
  }

  static int _getContinuousCount(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i, Turn turn) {
    if (sameTimingList[i].last.turnEffect.timing != Timing.continuousMove) return 0;
    int ret = 0;
    for (int j = 0; j <= i; j++) {
      var turnMove = sameTimingList[j].first.turnEffect.move;
      if (sameTimingList[j].first.turnEffect.timing == Timing.action &&
          turnMove?.type.id == TurnMoveType.move
      ) {
        ret = 0;
      }
      else if (sameTimingList[j].first.turnEffect.timing == Timing.continuousMove) {
        ret++;
      }
    }
    return ret;
  }

  static int _getActionCount(List<List<TurnEffectAndStateAndGuide>> sameTimingList, int i,) {
    int ret = 0;
    for (int j = 0; j < i; j++) {
      if (sameTimingList[j].first.turnEffect.timing == Timing.action) {
        ret++;
      }
    }
    return ret;
  }

}