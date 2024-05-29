import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/poke_base.dart';

class PokemonSexRow extends Row {
  PokemonSexRow(
    ThemeData theme,
    String? labelPokemonText,
    List<PokeBase?> removalPokemons,
    int pokemonNo,
    TextEditingController pokemonController,
    void Function(PokeBase) onPokemonSuggestionSelected,
    void Function() pokemonOnClear,
    String? labelSexText,
    List<Sex> sexList,
    Sex sexValue,
    void Function(dynamic)? onSexChanged, {
    required bool isInput,
    bool enabledPokemon = true,
    bool showNetworkImage = false,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pokemonNo != 0)
              showNetworkImage
                  ? Image.network(
                      PokeDB().pokeBase[pokemonNo]!.imageUrl,
                      height: theme.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    )
                  : const Icon(Icons.catching_pokemon),
            SizedBox(
              width: 10,
            ),
            isInput
                ? Expanded(
                    flex: 8,
                    child: enabledPokemon
                        ? AppBaseTypeAheadField(
                            key: Key(
                                'PokemonSexRow$labelPokemonText'), // テストでの識別用
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: pokemonController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: labelPokemonText,
                                suffixIcon: pokemonController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () => pokemonOnClear(),
                                      )
                                    : null,
                              ),
                            ),
                            autoFlipDirection: true,
                            suggestionsCallback: (pattern) async {
                              List<PokeBase> matches = [];
                              matches.addAll(PokeDB().pokeBase.values);
                              matches.remove(PokeDB().pokeBase[0]);
                              matches.retainWhere((s) {
                                return toKatakana50(s.name.toLowerCase())
                                    .contains(
                                        toKatakana50(pattern.toLowerCase()));
                              });
                              for (final pokemon in removalPokemons) {
                                matches.remove(pokemon);
                              }
                              return matches;
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                leading: showNetworkImage
                                    ? Image.network(
                                        suggestion.imageUrl,
                                        height: theme.buttonTheme.height,
                                        errorBuilder: (c, o, s) {
                                          return const Icon(
                                              Icons.catching_pokemon);
                                        },
                                      )
                                    : const Icon(Icons.catching_pokemon),
                                title: Text(suggestion.name),
                                autofocus: true,
                              );
                            },
                            onSuggestionSelected: onPokemonSuggestionSelected,
                          )
                        : TextFormField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: labelPokemonText,
                            ),
                            enabled: false,
                          ),
                  )
                : Expanded(
                    child: TextField(
                      controller: pokemonController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: labelPokemonText,
                        suffixIcon: sexValue.displayIcon,
                      ),
                      readOnly: true,
                    ),
                  ),
            isInput ? SizedBox(width: 10) : Container(),
            isInput
                ? Expanded(
                    flex: 3,
                    child: DropdownButtonFormField(
                      key: Key('PokemonSexRow$labelSexText'), // テストでの識別用
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: labelSexText,
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in sexList)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: Container(
                              key: Key(
                                  'PokemonSexRow$labelSexText${type.displayName}'), // テストでの識別用
                              child: type.displayIcon,
                            ),
                          ),
                      ],
                      value: sexValue,
                      onChanged: onSexChanged,
                    ),
                  )
                : Container(),
          ],
        );
}
