import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatInputRow extends Row {
  static const increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  static const decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  StatInputRow(
    String? labelText,
    Pokemon pokemon,
    TextEditingController raceController,
    TextEditingController indiController,
    num pokemonMinIndividual,
    num pokemonMaxIndividual,
    num initialIndiValue,
    void Function(num)? indiChangeFunc,
    TextEditingController effortController,
    num pokemonMinEffort,
    num pokemonMaxEffort,
    num initialEffortValue,
    void Function(num)? effortChangeFunc,
    TextEditingController realController,
    num initialRealValue,
    void Function(num)? realChangeFunc, {
    bool effectTemper = false,
    StatIndex statIndex = StatIndex.none,
    required AppLocalizations loc,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.commonStatRace,
                ),
                controller: raceController,
                enabled: false,
                style: effectTemper
                    ? pokemon.temper.increasedStat == statIndex
                        ? increaseStateStyle
                        : pokemon.temper.decreasedStat == statIndex
                            ? decreaseStateStyle
                            : null
                    : null,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: NumberInputWithIncrementDecrement(
                controller: indiController,
                numberFieldDecoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.commonStatIndividual,
                ),
                widgetContainerDecoration: const BoxDecoration(
                  border: null,
                ),
                min: pokemonMinIndividual,
                max: pokemonMaxIndividual,
                initialValue: initialIndiValue,
                onIncrement: indiChangeFunc,
                onDecrement: indiChangeFunc,
                onChanged: indiChangeFunc,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: NumberInputWithIncrementDecrement(
                controller: effortController,
                numberFieldDecoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.commonStatEffort,
                ),
                widgetContainerDecoration: const BoxDecoration(
                  border: null,
                ),
                min: pokemonMinEffort,
                max: pokemonMaxEffort,
                initialValue: initialEffortValue,
                onIncrement: effortChangeFunc,
                onDecrement: effortChangeFunc,
                onChanged: effortChangeFunc,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: NumberInputWithIncrementDecrement(
                controller: realController,
                numberFieldDecoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: labelText,
                ),
                widgetContainerDecoration: const BoxDecoration(
                  border: null,
                ),
                initialValue: initialRealValue,
                onIncrement: realChangeFunc,
                onDecrement: realChangeFunc,
                onChanged: realChangeFunc,
              ),
            ),
          ],
        );
}
