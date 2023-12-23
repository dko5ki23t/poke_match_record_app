import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PartyDeleteCheckDialog extends StatefulWidget {
  final bool containedParty;
  final void Function() onClearPressed;

  const PartyDeleteCheckDialog(
    this.containedParty,
    this.onClearPressed,
    {Key? key}) : super(key: key);

  @override
  PartyDeleteCheckDialogState createState() => PartyDeleteCheckDialogState();
}

class PartyDeleteCheckDialogState extends State<PartyDeleteCheckDialog> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.dialogQuestionDeleteParties1),
      content: widget.containedParty ?
        Text(loc.dialogQuestionDeleteParties2) : Text(''),
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
          )
        ],
    );
  }
}