import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/custom_widgets/battle_move_input_column.dart';
import 'package:poke_reco/custom_widgets/battle_turn_effect_input_column.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

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
    TextEditingController hpController,
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
              header: Text('わざ選択前'),
              collapsed: Text('タップで詳細を設定'),
              expanded: BattleTurnEffectInputColumn(
                setState, theme, battle,
                battle.turns[turnNum-1],
                battle.turns[turnNum-1].beforeMoveEffects,
              ),
            ),
            SizedBox(height: 20,),
            ExpandablePanel(
              header: Text('わざ選択'),
              collapsed: Text('タップで詳細を設定'),
              expanded: BattleMoveInputColumn(
                setState, theme, battle,
                battle.turns[turnNum-1], pokeData,
                initialOwnPokemon, initialOpponentPokemon,
                currentOwnPokemon, currentOpponentPokemon,
                battle.turns[turnNum-1].turnMove1, move1Controller,
                battle.turns[turnNum-1].turnMove2, move2Controller,
                hpController,
              ),
            ),
            SizedBox(height: 20,),
            ExpandablePanel(
              header: Text('わざ選択後'),
              collapsed: Text('タップで詳細を設定'),
              expanded: Text('hoge'),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    ],
  );
}