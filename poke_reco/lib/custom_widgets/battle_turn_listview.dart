import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_before_move_effect_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_move_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_after_move_effect_input_column.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';

class BattleTurnListView extends ListView {
  BattleTurnListView(
    void Function() setState,
    Battle battle,
    int turnNum,
    ThemeData theme,
    PokeDB pokeData,
    Pokemon initialOwnPokemon,
    Pokemon initialOpponentPokemon,
    Pokemon currentOwnPokemon,
    Pokemon currentOpponentPokemon,
    TextEditingController move1Controller,
    TextEditingController move2Controller,
    TextEditingController hpController1,
    TextEditingController hpController2,
    ExpandableController beforeMoveExpandController,
    ExpandableController moveExpandController,
    ExpandableController afterMoveExpandController,
    MyAppState appState,
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),
            ExpandablePanel(
              controller: beforeMoveExpandController,
              header: Text('わざ選択前'),
              collapsed: Text('タップで詳細を設定'),
              expanded: BattleBeforeMoveEffectInputColumn(
                setState, theme, battle,
                battle.turns[turnNum-1],
                battle.turns[turnNum-1].beforeMoveEffects,
                appState,
              ),
            ),
            SizedBox(height: 20,),
            ExpandablePanel(
              controller: moveExpandController,
              header: Text('わざ選択'),
              collapsed: Text('タップで詳細を設定'),
              expanded: BattleMoveInputColumn(
                setState, theme, battle,
                battle.turns[turnNum-1], pokeData,
                initialOwnPokemon, initialOpponentPokemon,
                currentOwnPokemon, currentOpponentPokemon,
                battle.turns[turnNum-1].turnMove1, move1Controller,
                battle.turns[turnNum-1].turnMove2, move2Controller,
                hpController1, hpController2,
              ),
            ),
            SizedBox(height: 20,),
            ExpandablePanel(
              controller: afterMoveExpandController,
              header: Text('わざ選択後'),
              collapsed: Text('タップで詳細を設定'),
              expanded: BattleAfterMoveEffectInputColumn(
                setState, theme, battle,
                battle.turns[turnNum-1],
                battle.turns[turnNum-1].afterMoveEffects,
                appState,
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    ],
  );
}