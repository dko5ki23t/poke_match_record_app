import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

class PokemonItemInputRow extends Row {
  PokemonItemInputRow(
    String? labelPokemonText,
    TextEditingController pokemonController,
    void Function()? onPokemonTap,
    String? labelItemText,
    TextEditingController itemController,
    PokeDB pokeData,
    List<Item?> removalItems,
    void Function(Item) onItemSuggestionSelected,
    {
      bool enabledPokemon = true,
      bool enabledItem = true,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 6,
          child: TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: labelPokemonText,
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            controller: pokemonController,
            onTap: onPokemonTap,
            enabled: enabledPokemon,
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: 4,
          child: enabledItem ?
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: itemController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: labelItemText,
                ),
              ),
              autoFlipDirection: true,
              hideOnEmpty: true,
              suggestionsCallback: (pattern) async {
                List<Item> matches = [];
                matches.addAll(pokeData.items.values);
                matches.retainWhere((s){
                  return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                });
                for (final item in removalItems) {
                  matches.remove(item);
                }
                return matches;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                );
              },
              onSuggestionSelected: onItemSuggestionSelected,
            ) :
            TextFormField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: labelItemText,
              ),
              enabled: false,
            )
        ),
      ],
  );
}