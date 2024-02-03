import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PartyDeleteCheckDialog extends StatefulWidget {
  final bool containedParty;
  final void Function() onClearPressed;

  const PartyDeleteCheckDialog(this.containedParty, this.onClearPressed,
      {Key? key})
      : super(key: key);

  @override
  PartyDeleteCheckDialogState createState() => PartyDeleteCheckDialogState();
}

class PartyDeleteCheckDialogState extends State<PartyDeleteCheckDialog> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.dialogQuestionDeleteParties1),
      content: widget.containedParty
          ? Text(loc.dialogQuestionDeleteParties2)
          : Text(''),
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
        )
      ],
    );
  }
}
