import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleDeleteCheckDialog extends StatefulWidget {
  final void Function() onClearPressed;

  const BattleDeleteCheckDialog(this.onClearPressed, {Key? key})
      : super(key: key);

  @override
  BattleDeleteCheckDialogState createState() => BattleDeleteCheckDialogState();
}

class BattleDeleteCheckDialogState extends State<BattleDeleteCheckDialog> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.dialogQuestionDeleteChanges),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonNo),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(loc.commonYes),
          onPressed: () {
            Navigator.pop(context);
            widget.onClearPressed();
          },
        ),
      ],
    );
  }
}
