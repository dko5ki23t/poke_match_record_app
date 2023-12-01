import 'package:flutter/material.dart';

class PokemonDeleteCheckDialog extends StatefulWidget {
  final bool containedParty;
  final void Function() onClearPressed;

  const PokemonDeleteCheckDialog(
    this.containedParty,
    this.onClearPressed,
    {Key? key}) : super(key: key);

  @override
  PokemonDeleteCheckDialogState createState() => PokemonDeleteCheckDialogState();
}

class PokemonDeleteCheckDialogState extends State<PokemonDeleteCheckDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('選択したポケモンを削除してもいいですか？'),
      content: widget.containedParty ?
        Text('パーティに含まれているポケモンを選択しています') : Text(''),
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