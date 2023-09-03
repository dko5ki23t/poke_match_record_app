import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text('対戦記録のデータを削除してもいいですか？'),
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
            widget.onClearPressed();
          },
        ),
      ],
    );
  }
}