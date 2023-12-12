import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

class StatTotalRow extends Row {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  StatTotalRow(
    int totalRace,
    int totalEffort,
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
            '合計：$totalRace'
          ),
      ),
      SizedBox(width: 10),
      Flexible(child: Container()),
      SizedBox(width: 10),
      Flexible(
          child: Text(
            '合計：$totalEffort/$pokemonMaxEffortTotal',
            style: totalEffort > pokemonMaxEffortTotal ? notAllowedStyle : null,
          ),
      ),
      SizedBox(width: 10),
      Flexible(child: Container()),
    ],
  );
}