import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

enum PartySort {
  registerUp(1, '登録(昇)'),
  registerDown(2, '登録(降)'),
  nameUp(3, 'パーティ名(昇)'),
  nameDown(4, 'パーティ名(降)'),
  winRateUp(5, '勝率(昇)'),
  winRateDown(6, '勝率(降)');

  final int id;
  final String displayName;
  const PartySort(this.id, this.displayName);

  factory PartySort.createFromId(int id) {
    switch (id) {
      case 1:
        return registerUp;
      case 2:
        return registerDown;
      case 3:
        return nameUp;
      case 4:
        return nameDown;
      case 5:
        return winRateUp;
      case 6:
        return winRateDown;
      default:
        return registerUp;
    }
  }
}

class PartySortDialog extends StatefulWidget {
  final Future<void> Function (
    PartySort? partySort) onOK;
  final PartySort? currentSort;

  const PartySortDialog(
    this.onOK,
    this.currentSort,
    {Key? key}) : super(key: key);

  @override
  PartySortDialogState createState() => PartySortDialogState();
}

class PartySortDialogState extends State<PartySortDialog> {
  bool isFirstBuild = true;
  PartySort? _partySort;

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      _partySort = widget.currentSort;
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('並べ替え'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (var e in PartySort.values)
            ListTile(
              title: Text(e.displayName),
              leading: Radio<PartySort>(
                value: e,
                groupValue: _partySort,
                onChanged: (PartySort? value) {
                  setState(() {
                    _partySort = value;
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
              await widget.onOK(_partySort);
            },
          ),
        ],
    );
  }
}