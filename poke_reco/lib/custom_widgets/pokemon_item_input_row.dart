import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/item.dart';
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
    int pokemonNo,
    int? itemId,
    ThemeData theme,
    bool isEditPokemon,
    void Function() pokemonOnEdit, {
    bool enabledPokemon = true,
    bool enabledItem = true,
    bool showNetworkImage = false,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            showNetworkImage
                ? Image.network(
                    PokeDB().pokeBase[pokemonNo]!.imageUrl,
                    height: theme.buttonTheme.height,
                    errorBuilder: (c, o, s) {
                      return const Icon(Icons.catching_pokemon);
                    },
                  )
                : const Icon(Icons.catching_pokemon),
            Flexible(
              flex: 5,
              child: TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: labelPokemonText,
                  suffixIcon: canClear
                      ? IconButton(
                          icon: isEditPokemon
                              ? Icon(Icons.edit)
                              : Icon(Icons.clear),
                          onPressed: () => isEditPokemon
                              ? pokemonOnEdit()
                              : pokemonOnClear(),
                        )
                      : Icon(Icons.arrow_drop_down),
                ),
                controller: pokemonController,
                onTap: isEditPokemon ? pokemonOnEdit : onPokemonTap,
                enabled: enabledPokemon,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
                flex: 5,
                child: enabledItem
                    ? AppBaseTypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: itemController,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: labelItemText,
                            suffixIcon: itemController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () => itemOnClear(),
                                  )
                                : null,
                          ),
                        ),
                        autoFlipDirection: true,
                        hideOnEmpty: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(PokeDB().items.values);
                          matches.retainWhere((s) {
                            return toKatakana50(s.displayName.toLowerCase())
                                .contains(toKatakana50(pattern.toLowerCase()));
                          });
                          for (final item in removalItems) {
                            matches.remove(item);
                          }
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(
                              suggestion.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        onSuggestionSelected: onItemSuggestionSelected,
                      )
                    : TextFormField(
                        controller: itemController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: labelItemText,
                        ),
                        enabled: false,
                      )),
            itemId != null && showNetworkImage
                ? Image.network(
                    PokeDB().items[itemId]!.imageUrl,
                    height: theme.buttonTheme.height,
                    errorBuilder: (c, o, s) {
                      return const Icon(Icons.category);
                    },
                  )
                : const Icon(Icons.category),
          ],
        );
}
