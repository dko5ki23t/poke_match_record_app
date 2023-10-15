import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/pokemon_mini_tile.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/pages/register_battle.dart';
import 'package:poke_reco/data_structs/battle.dart';

class BattleFirstPokemonListView extends ListView {
  BattleFirstPokemonListView(
    void Function() setState,
    Battle battle,
    ThemeData theme,
    CheckedPokemons checkedPokemons,
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('あなた', style: theme.textTheme.bodyLarge,),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(battle.opponentName, style: theme.textTheme.bodyLarge,),
                  ),
                ),
              ],
            ),
            for (int i = 0; i < 6; i++)
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: battle.getParty(PlayerType(PlayerType.me)).pokemons[i] != null ?
                    PokemonMiniTile(
                      battle.getParty(PlayerType(PlayerType.me)).pokemons[i]!,
                      theme,
                      onTap: () {checkedPokemons.own = i+1; setState();},
                      selected: checkedPokemons.own == i+1,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] != null ?
                    PokemonMiniTile(
                      battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!,
                      theme,
                      onTap: () {checkedPokemons.opponent = i+1; setState();},
                      selected: checkedPokemons.opponent == i+1,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
         ],
        ),
      ),
    ],
  );
}