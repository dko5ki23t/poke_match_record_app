import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

class TypeDropdownButton extends DropdownButtonFormField {
  TypeDropdownButton(
    PokeDB pokeData,
    String? labelText,
    void Function(dynamic)? onChanged,
    int? value,
  ) :
  super (
    isExpanded: true,
    decoration: InputDecoration(
      border: UnderlineInputBorder(),
      labelText: labelText,
    ),
    items: <DropdownMenuItem>[
      for (var type in pokeData.types)
        DropdownMenuItem(
          value: type.id,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              children: [
                type.displayIcon,
                Text(type.displayName)
              ],
            ),
          ),
      ),
    ],
    onChanged: onChanged,
    value: value,
  );
}
