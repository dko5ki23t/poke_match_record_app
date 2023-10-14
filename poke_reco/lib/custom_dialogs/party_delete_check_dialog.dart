import 'package:flutter/material.dart';

class PartyDeleteCheckDialog extends StatefulWidget {
  final bool containedParty;
  final void Function() onClearPressed;
  final void Function() onRemainPressed;

  const PartyDeleteCheckDialog(
    this.containedParty,
    this.onClearPressed,
    this.onRemainPressed,
    {Key? key}) : super(key: key);

  @override
  PartyDeleteCheckDialogState createState() => PartyDeleteCheckDialogState();
}

class PartyDeleteCheckDialogState extends State<PartyDeleteCheckDialog> {
  bool isSecondDialog = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: isSecondDialog ?
        Text('関連する対戦記録を削除しますか？') :
        Text('パーティのデータを削除してもいいですか？'),
      content: isSecondDialog ?
        Text('残した場合、該当の対戦記録は編集不可となります') :
        widget.containedParty ?
        Text('対戦記録に含まれているポケモンを選択しています') : Text(''),
      actions: isSecondDialog ?
        <Widget>[
          GestureDetector(
            child: Text('キャンセル'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: Text('残す'),
            onTap: () {
              Navigator.pop(context);
              widget.onRemainPressed();
            },
          ),
          GestureDetector(
            child: Text('はい'),
            onTap: () {
              Navigator.pop(context);
              widget.onClearPressed();
            },
          )
        ] :
        <Widget>[
          GestureDetector(
            child: Text('いいえ'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: Text('はい'),
            onTap: () {
              if (widget.containedParty) {
                setState(() {
                  isSecondDialog = true;
                });
              }
              else {
                Navigator.pop(context);
                widget.onClearPressed();
              }
            },
          )
        ],
    );
  }
}