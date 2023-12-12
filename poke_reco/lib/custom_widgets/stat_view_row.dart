import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

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
      String statName = '',
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: TextField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: '種族値'
          ),
          controller: raceController,
          readOnly: true,
          style: effectTemper ?
            pokemon.temper.increasedStat == statName ? increaseStateStyle :
              pokemon.temper.decreasedStat == statName ? decreaseStateStyle : null
            : null,
        ),
      ),
      SizedBox(width: 10),
      Flexible(
        child: TextField(
          controller: indiController,
          readOnly: true,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: '個体値',
          ),
        ),
      ),
      SizedBox(width: 10),
      Flexible(
        child: TextField(
          controller: effortController,
          readOnly: true,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: '努力値'
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