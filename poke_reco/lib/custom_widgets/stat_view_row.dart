import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatViewRow extends Row {
  static const increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  static const decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  StatViewRow(
    String? labelText,
    Pokemon pokemon,
    TextEditingController raceController,
    TextEditingController indiController,
    TextEditingController effortController,
    TextEditingController realController,
    {
      bool effectTemper = false,
      StatIndex statIndex = StatIndex.none,
      required AppLocalizations loc,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: TextField(
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: loc.commonStatRace,
          ),
          controller: raceController,
          readOnly: true,
          style: effectTemper ?
            pokemon.temper.increasedStat == statIndex ? increaseStateStyle :
              pokemon.temper.decreasedStat == statIndex ? decreaseStateStyle : null
            : null,
        ),
      ),
      SizedBox(width: 10),
      Flexible(
        child: TextField(
          controller: indiController,
          readOnly: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: loc.commonStatIndividual,
          ),
        ),
      ),
      SizedBox(width: 10),
      Flexible(
        child: TextField(
          controller: effortController,
          readOnly: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: loc.commonStatEffort,
          ),
        ),
      ),
      SizedBox(width: 10),
      Flexible(
        child: TextField(
          controller: realController,
          readOnly: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: labelText,
          ),
        ),
      ),
    ],
  );
}