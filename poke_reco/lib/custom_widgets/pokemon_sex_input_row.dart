import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/poke_base.dart';

class PokemonSexInputRow extends Row {
  PokemonSexInputRow(
    String? labelPokemonText,
    List<PokeBase?> removalPokemons,
    TextEditingController pokemonController,
    void Function(PokeBase) onPokemonSuggestionSelected,
    void Function() pokemonOnClear,
    String? labelSexText,
    List<Sex> sexList,
    Sex sexValue,
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
                suffixIcon: pokemonController.text.isNotEmpty ?
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => pokemonOnClear(),
                  ) : null,
              ),
            ),
            autoFlipDirection: true,
            suggestionsCallback: (pattern) async {
              List<PokeBase> matches = [];
              matches.addAll(PokeDB().pokeBase.values);
              matches.remove(PokeDB().pokeBase[0]);
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
            for (var type in sexList)
              DropdownMenuItem(
                value: type,
                child: type.displayIcon,
            ),
          ],
          value: sexValue,
          onChanged: onSexChanged,
        ),
      ),
    ],
  );
}