import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

class PokemonSexInputRow extends Row {
  PokemonSexInputRow(
    String? labelPokemonText,
    PokeDB pokeData,
    List<PokeBase?> removalPokemons,
    TextEditingController pokemonController,
    void Function(PokeBase) onPokemonSuggestionSelected,
    String? labelSexText,
    void Function(dynamic)? onSexChanged,
    {
      bool enabledPokemon = true,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        flex: 8,
        child: enabledPokemon ?
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: pokemonController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: labelPokemonText,
              ),
            ),
            autoFlipDirection: true,
            suggestionsCallback: (pattern) async {
              List<PokeBase> matches = [];
              matches.addAll(pokeData.pokeBase.values);
              matches.remove(pokeData.pokeBase[0]);
              matches.retainWhere((s){
                return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
              });
              for (final pokemon in removalPokemons) {
                matches.remove(pokemon);
              }
              return matches;
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion.name),
                autofocus: true,
              );
            },
            onSuggestionSelected: onPokemonSuggestionSelected,
          ) :
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: labelPokemonText,
            ),
            enabled: false,
          ),
      ),
      SizedBox(width: 10),
      Expanded(
        flex: 2,
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: labelSexText,
          ),
          items: <DropdownMenuItem>[
            for (var type in Sex.values)
              DropdownMenuItem(
                value: type,
                child: type.displayIcon,
            ),
          ],
          value: Sex.none,
          onChanged: onSexChanged,
        ),
      ),
    ],
  );
}