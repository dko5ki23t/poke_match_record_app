import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

class SelectTypeDialog extends StatefulWidget {
  final void Function(PokeType type) onSelect;
  final String title;
  final bool isTeraType;

  const SelectTypeDialog(
    this.onSelect,
    this.title, {
    this.isTeraType = false,
    Key? key,
  }) : super(key: key);

  @override
  SelectTypeDialogState createState() => SelectTypeDialogState();
}

class SelectTypeDialogState extends State<SelectTypeDialog> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (final type
                in widget.isTeraType ? PokeDB().teraTypes : PokeDB().types)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onSelect(type);
                },
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      type.displayIcon,
                      SizedBox(
                        width: 10,
                      ),
                      Text(type.displayName),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
