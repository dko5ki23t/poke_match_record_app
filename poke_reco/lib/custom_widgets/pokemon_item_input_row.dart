import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

class PokemonItemInputRow extends Row {
  PokemonItemInputRow(
    String? labelPokemonText,
    TextEditingController pokemonController,
    void Function()? onPokemonTap,
    bool canClear,
    void Function() pokemonOnClear,
    String? labelItemText,
    TextEditingController itemController,
    List<Item?> removalItems,
    void Function(Item) onItemSuggestionSelected,
    void Function() itemOnClear,
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
              suffixIcon: canClear ? 
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => pokemonOnClear(),
                ) :
                Icon(Icons.arrow_drop_down),
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
                  suffixIcon: itemController.text.isNotEmpty ?
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => itemOnClear(),
                    ) : null,
                ),
              ),
              autoFlipDirection: true,
              hideOnEmpty: true,
              suggestionsCallback: (pattern) async {
                List<Item> matches = [];
                matches.addAll(PokeDB().items.values);
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