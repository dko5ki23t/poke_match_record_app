import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class MoveInputRow extends Row {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  MoveInputRow(
    Pokemon pokemon,
    String? labelMove,
    String? labelPP,
    TextEditingController moveController,
    List<Move?> removalMoves,
    void Function(Move) moveOnSuggestionSelected,
    void Function() moveOnClear,
    TextEditingController ppController,
    void Function(num)? ppChanged, {
    required int minPP,
    required int maxPP,
    bool moveEnabled = true,
    bool ppEnabled = true,
    num initialPPValue = 0,
    bool isError = false,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 7,
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: moveController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: labelMove,
                    labelStyle: isError ? notAllowedStyle : null,
                    suffixIcon: moveController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => moveOnClear(),
                          )
                        : null,
                  ),
                  enabled: moveEnabled,
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<Move> matches = [];
                  matches.addAll(PokeDB().pokeBase[pokemon.no]!.move);
                  matches.retainWhere((s) {
                    return toKatakana50(s.displayName.toLowerCase())
                        .contains(toKatakana50(pattern.toLowerCase()));
                  });
                  for (final move in removalMoves) {
                    matches.remove(move);
                  }
                  return matches;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: suggestion.type.displayIcon,
                    title: Text(suggestion.displayName),
                  );
                },
                onSuggestionSelected: (suggestion) =>
                    moveOnSuggestionSelected(suggestion),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: NumberInputWithIncrementDecrement(
                controller: ppController,
                numberFieldDecoration: InputDecoration(
                    border: UnderlineInputBorder(), labelText: labelPP),
                widgetContainerDecoration: const BoxDecoration(
                  border: null,
                ),
                min: minPP,
                max: maxPP,
                onIncrement: ppChanged,
                onDecrement: ppChanged,
                onChanged: ppChanged,
                initialValue: initialPPValue,
                enabled: ppEnabled,
              ),
            ),
          ],
        );
}
