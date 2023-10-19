import 'package:flutter/material.dart';

class DeleteEditingCheckDialog extends StatelessWidget {
  final String editingName;
  final void Function() onYesPressed;

  const DeleteEditingCheckDialog(
    this.editingName,
    this.onYesPressed,
    {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('変更を破棄してもいいですか？'),
      actions: <Widget>[
        GestureDetector(
          child: Text('いいえ'),
          onTap: () {
            Navigator.pop(context);
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