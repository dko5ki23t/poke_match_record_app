import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

class TypeDropdownButton extends DropdownButtonFormField<PokeType> {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  TypeDropdownButton(
    String? labelText,
    void Function(PokeType)? onChanged,
    PokeType? value, {
    bool isError = false,
    bool isTeraType = false,
  }) : super(
          key: Key('TypeDropdownButton'),
          isExpanded: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: labelText,
            labelStyle: isError ? notAllowedStyle : null,
          ),
          items: <DropdownMenuItem<PokeType>>[
            for (var type in isTeraType ? PokeDB().teraTypes : PokeDB().types)
              DropdownMenuItem<PokeType>(
                value: type,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [type.displayIcon, Text(type.displayName)],
                  ),
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null && onChanged != null) {
              onChanged(value);
            }
          },
          value: value,
        );
}
