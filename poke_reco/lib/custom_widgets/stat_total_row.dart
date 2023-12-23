import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatTotalRow extends Row {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  StatTotalRow(
    int totalRace,
    int totalEffort,
    {
      required AppLocalizations loc,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
            '${loc.commonTotal} : $totalRace'
          ),
      ),
      SizedBox(width: 10),
      Flexible(child: Container()),
      SizedBox(width: 10),
      Flexible(
          child: Text(
            '${loc.commonTotal} : $totalEffort/$pokemonMaxEffortTotal',
            style: totalEffort > pokemonMaxEffortTotal ? notAllowedStyle : null,
          ),
      ),
      SizedBox(width: 10),
      Flexible(child: Container()),
    ],
  );
}