import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: question != null ? Text(question!) : Text('変更を破棄してもいいですか？'),
      actions: <Widget>[
        GestureDetector(
          child: Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
            if (onNoPressed != null) onNoPressed!();
          },
        ),
        GestureDetector(
          child: Text('はい'),
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
    return AlertDialog(
      title: question != null ? Text(question!) : Text('変更を破棄してもいいですか？'),
      actions: <Widget>[
        GestureDetector(
          child: Text('キャンセル'),
          onTap: () {
            Navigator.pop(context);
            if (onCancelPressed != null) onCancelPressed!();
          },
        ),
        GestureDetector(
          child: Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
            onNoPressed();
          },
        ),
        GestureDetector(
          child: Text('はい'),
          onTap: () {
            Navigator.pop(context);
            onYesPressed();
          },
        ),
      ],
    );
  }
}
