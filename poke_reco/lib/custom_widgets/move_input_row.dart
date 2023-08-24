import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

class MoveInputRow extends Row {
  MoveInputRow(
    PokeDB pokeData,
    Pokemon pokemon,
    String? labelMove,
    String? labelPP,
    TextEditingController moveController,
    List<Move?> removalMoves,
    void Function(Move) moveOnSuggestionSelected,
    TextEditingController ppController,
    void Function(num)? ppChanged,
    {
      bool moveEnabled = true,
      bool ppEnabled = true,
      num initialPPValue = 0,
    }
  ) : 
  super(
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
            ),
            enabled: moveEnabled,
          ),
          autoFlipDirection: true,
          suggestionsCallback: (pattern) async {
            List<Move> matches = [];
            matches.addAll(pokeData.pokeBase[pokemon.no]!.move);
            matches.retainWhere((s){
              return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
            });
            for (final move in removalMoves) {
              matches.remove(move);
            }
            return matches;
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion.displayName),
            );
          },
          onSuggestionSelected: moveOnSuggestionSelected,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: NumberInputWithIncrementDecrement(
          controller: ppController,
          numberFieldDecoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: labelPP
          ),
          widgetContainerDecoration: const BoxDecoration(
            border: null,
          ),
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