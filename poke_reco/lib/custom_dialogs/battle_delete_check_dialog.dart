import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleDeleteCheckDialog extends StatefulWidget {
  final void Function() onClearPressed;

  const BattleDeleteCheckDialog(
    this.onClearPressed,
    {Key? key}) : super(key: key);

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
        GestureDetector(
          child: Text(loc.commonNo),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: Text(loc.commonYes),
          onTap: () {
            Navigator.pop(context);
            widget.onClearPressed();
          },
        ),
      ],
    );
  }
}