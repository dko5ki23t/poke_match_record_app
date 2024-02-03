import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteEditingCheckDialog extends StatelessWidget {
  final String? question;
  final void Function() onYesPressed;
  final void Function()? onNoPressed;

  const DeleteEditingCheckDialog(
    this.question,
    this.onYesPressed, {
    Key? key,
    this.onNoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: question != null
          ? Text(question!)
          : Text(loc.dialogQuestionDeleteChanges),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonNo),
          onPressed: () {
            Navigator.of(context).pop(false);
            if (onNoPressed != null) onNoPressed!();
          },
        ),
        TextButton(
          child: Text(loc.commonYes),
          onPressed: () {
            Navigator.of(context).pop(true);
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
      title: question != null
          ? Text(question!)
          : Text(loc.dialogQuestionDeleteChanges),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.of(context).pop(null);
            if (onCancelPressed != null) onCancelPressed!();
          },
        ),
        TextButton(
          child: Text(loc.commonNo),
          onPressed: () {
            Navigator.of(context).pop(false);
            onNoPressed();
          },
        ),
        TextButton(
          child: Text(loc.commonYes),
          onPressed: () {
            Navigator.of(context).pop(true);
            onYesPressed();
          },
        ),
      ],
    );
  }
}
