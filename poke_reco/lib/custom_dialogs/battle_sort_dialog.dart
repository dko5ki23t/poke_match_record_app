import 'package:flutter/material.dart';

enum BattleSort {
  registerUp(1, '登録(昇)'),
  registerDown(2, '登録(降)'),
  dateUp(3, '対戦日時(昇)'),
  dateDown(4, '対戦日時(降)');

  final int id;
  final String displayName;
  const BattleSort(this.id, this.displayName);

  factory BattleSort.createFromId(int id) {
    switch (id) {
      case 1:
        return registerUp;
      case 2:
        return registerDown;
      case 3:
        return dateUp;
      case 4:
        return dateDown;
      default:
        return registerUp;
    }
  }
}

class BattleSortDialog extends StatefulWidget {
  final Future<void> Function (
    BattleSort? battleSort) onOK;
  final BattleSort? currentSort;

  const BattleSortDialog(
    this.onOK,
    this.currentSort,
    {Key? key}) : super(key: key);

  @override
  BattleSortDialogState createState() => BattleSortDialogState();
}

class BattleSortDialogState extends State<BattleSortDialog> {
  bool isFirstBuild = true;
  BattleSort? _battleSort;

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      _battleSort = widget.currentSort;
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('並べ替え'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (var e in BattleSort.values)
            ListTile(
              title: Text(e.displayName),
              leading: Radio<BattleSort>(
                value: e,
                groupValue: _battleSort,
                onChanged: (BattleSort? value) {
                  setState(() {
                    _battleSort = value;
                  });
                }
              ),
            ),
          ],
        ),
      ),
      actions:
        <Widget>[
          GestureDetector(
            child: Text('キャンセル'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: Text('OK'),
            onTap: () async {
              Navigator.pop(context);
              await widget.onOK(_battleSort);
            },
          ),
        ],
    );
  }
}