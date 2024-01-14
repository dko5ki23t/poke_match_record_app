import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/pokemon_mini_tile.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/pages/register_battle.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleFirstPokemonListView extends ListView {
  BattleFirstPokemonListView(
    void Function() setState,
    Battle battle,
    ThemeData theme,
    CheckedPokemons checkedPokemons,
    {
      required bool isInput,
      bool showNetworkImage = false,
      List<PokemonState>? ownPokemonStates,
      int? opponentPokemonIndex,
      required AppLocalizations loc,
    }
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isInput ?
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(loc.battleSelectPokemonPrompt),
                  ),
                ),
              ],
            ) : Container(),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(loc.battleYou, style: theme.textTheme.bodyLarge,),
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
                    child: battle.getParty(PlayerType.me).pokemons[i] != null ?
                    Badge(
                      smallSize: 0,
                      offset: Offset(-10, 0),
                      label: isInput ?
                        checkedPokemons.own.indexWhere((e) => e == i+1) >= 0 ? Text('${checkedPokemons.own.indexWhere((e) => e == i+1)+1}') : null :
                        ownPokemonStates![i].battlingNum != 0 ? Text('${ownPokemonStates[i].battlingNum}') : null,
                      child: PokemonMiniTile(
                        battle.getParty(PlayerType.me).pokemons[i]!,
                        theme,
                        leading: showNetworkImage ?
                          Image.network(
                            PokeDB().pokeBase[battle.getParty(PlayerType.me).pokemons[i]!.no]!.imageUrl,
                            height: theme.buttonTheme.height,
                            errorBuilder: (c, o, s) {
                              return const Icon(Icons.catching_pokemon);
                            },
                          ) : const Icon(Icons.catching_pokemon),
                        onTap: isInput ? () {
                          if (checkedPokemons.own.contains(i+1)) {
                            checkedPokemons.own.removeWhere((e) => e == i+1);
                          }
                          else if (checkedPokemons.own.length < 3) {
                            checkedPokemons.own.add(i+1);
                          }
                          setState();
                        } : null,
                        selected: isInput ? checkedPokemons.own.contains(i+1) : ownPokemonStates![i].battlingNum != 0,
                        selectedTileColor: Colors.black26,
                        showLevel: false,
                        showSex: false,
                      ),
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: battle.getParty(PlayerType.opponent).pokemons[i] != null ?
                    PokemonMiniTile(
                      battle.getParty(PlayerType.opponent).pokemons[i]!,
                      theme,
                      leading: showNetworkImage ?
                        Image.network(
                          PokeDB().pokeBase[battle.getParty(PlayerType.opponent).pokemons[i]!.no]!.imageUrl,
                          height: theme.buttonTheme.height,
                          errorBuilder: (c, o, s) {
                            return const Icon(Icons.catching_pokemon);
                          },
                        ) : const Icon(Icons.catching_pokemon),
                      onTap: isInput ? () {checkedPokemons.opponent = i+1; setState();} : null,
                      selected: isInput ? checkedPokemons.opponent == i+1 : opponentPokemonIndex == i+1,
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