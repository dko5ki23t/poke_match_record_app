import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

class TypeDropdownButton extends DropdownButtonFormField {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  TypeDropdownButton(
    String? labelText,
    void Function(dynamic)? onChanged,
    int? value,
    {
      bool isError = false,
      bool isTeraType = false,
    }
  ) :
  super (
    isExpanded: true,
    decoration: InputDecoration(
      border: UnderlineInputBorder(),
      labelText: labelText,
      labelStyle: isError ? notAllowedStyle : null,
    ),
    items: <DropdownMenuItem>[
      for (var type in isTeraType ? PokeDB().teraTypes : PokeDB().types)
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
