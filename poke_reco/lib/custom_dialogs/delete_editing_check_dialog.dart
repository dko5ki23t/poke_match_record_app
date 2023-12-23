import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteEditingCheckDialog extends StatelessWidget {
  final String? question;
  final void Function() onYesPressed;
  final void Function()? onNoPressed;

  const DeleteEditingCheckDialog(
    this.question,
    this.onYesPressed,
    {
      Key? key,
      this.onNoPressed,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: question != null ? Text(question!) : Text(loc.dialogQuestionDeleteChanges),
      actions: <Widget>[
        GestureDetector(
          child: Text(loc.commonNo),
          onTap: () {
            Navigator.pop(context);
            if (onNoPressed != null) onNoPressed!();
          },
        ),
        GestureDetector(
          child: Text(loc.commonYes),
          onTap: () {
            Navigator.pop(context);
            onYesPressed();
          },
        ),
      ],
    );
  }
}

class DeleteEditingCheckDialogWithCancel extends StatelessWidget {
  final String? question;
  final void Function() onYesPressed;
  final void Function() onNoPressed;
  final void Function()? onCancelPressed;

  const DeleteEditingCheckDialogWithCancel({
    required this.question,
    required this.onYesPressed,
    required this.onNoPressed,
    Key? key,
    this.onCancelPressed,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: question != null ? Text(question!) : Text(loc.dialogQuestionDeleteChanges),
      actions: <Widget>[
        GestureDetector(
          child: Text(loc.commonCancel),
          onTap: () {
            Navigator.pop(context);
            if (onCancelPressed != null) onCancelPressed!();
          },
        ),
        GestureDetector(
          child: Text(loc.commonNo),
          onTap: () {
            Navigator.pop(context);
            onNoPressed();
          },
        ),
        GestureDetector(
          child: Text(loc.commonYes),
          onTap: () {
            Navigator.pop(context);
            onYesPressed();
          },
        ),
      ],
    );
  }
}
