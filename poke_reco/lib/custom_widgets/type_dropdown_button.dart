import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_dropdown_button_form_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

// TODO: 削除
class TypeDropdownButtonOld extends DropdownButtonFormField<PokeType> {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );

  TypeDropdownButtonOld(
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
          onChanged: onChanged != null
              ? (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                }
              : null,
          value: value,
        );
}

class TypeDropdownButton extends AppBaseDropdownButtonFormField<PokeType> {
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
          enabled: onChanged != null,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: isError ? notAllowedStyle : null,
          ),
          childWhenNullValueSelected: Row(
            children: [
              Icon(
                Icons.question_mark_outlined,
                color: Color.fromARGB(0, 0, 0, 0),
              ),
              Text('')
            ],
          ),
          items: [
            for (final type in isTeraType ? PokeDB().teraTypes : PokeDB().types)
              ColoredPopupMenuItem(
                value: type,
                child: Row(
                  children: [type.displayIcon, Text(type.displayName)],
                ),
              )
          ],
          onChanged: onChanged,
          value: value,
        );
}
