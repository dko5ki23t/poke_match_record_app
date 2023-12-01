import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text('選択したパーティを削除してもいいですか？'),
      content: widget.containedParty ?
        Text('対戦記録に含まれているパーティを選択しています') : Text(''),
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
          )
        ],
    );
  }
}