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
    {
      bool showNetworkImage = false,
    }
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
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。',),
                  ),
                ),
              ],
            ),
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
                    Badge(
                      smallSize: 0,
                      offset: Offset(-10, 0),
                      //textStyle: TextStyle(fontSize: 20),
                      label: checkedPokemons.own.indexWhere((e) => e == i+1) >= 0 ? Text('${checkedPokemons.own.indexWhere((e) => e == i+1)+1}') : null,
                      child: PokemonMiniTile(
                        battle.getParty(PlayerType(PlayerType.me)).pokemons[i]!,
                        theme,
                        leading: showNetworkImage ?
                          Image.network(
                            PokeDB().pokeBase[battle.getParty(PlayerType(PlayerType.me)).pokemons[i]!.no]!.imageUrl,
                            height: theme.buttonTheme.height,
                            errorBuilder: (c, o, s) {
                              return const Icon(Icons.catching_pokemon);
                            },
                          ) : const Icon(Icons.catching_pokemon),
                        onTap: () {
                          if (checkedPokemons.own.contains(i+1)) {
                            checkedPokemons.own.removeWhere((e) => e == i+1);
                          }
                          else if (checkedPokemons.own.length < 3) {
                            checkedPokemons.own.add(i+1);
                          }
                          setState();
                        },
                        selected: checkedPokemons.own.contains(i+1),
                        selectedTileColor: Colors.black26,
                        showLevel: false,
                        showSex: false,
                      ),
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] != null ?
                    PokemonMiniTile(
                      battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!,
                      theme,
                      leading: showNetworkImage ?
                        Image.network(
                          PokeDB().pokeBase[battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!.no]!.imageUrl,
                          height: theme.buttonTheme.height,
                          errorBuilder: (c, o, s) {
                            return const Icon(Icons.catching_pokemon);
                          },
                        ) : const Icon(Icons.catching_pokemon),
                      onTap: () {checkedPokemons.opponent = i+1; setState();},
                      selected: checkedPokemons.opponent == i+1,
                      selectedTileColor: Colors.black26,
                      showLevel: false,
                      showSex: false,
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