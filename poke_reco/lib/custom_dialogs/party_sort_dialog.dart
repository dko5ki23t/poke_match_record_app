import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

enum PartySort {
  registerUp(1, '登録(昇)', 'Register(asc)'),
  registerDown(2, '登録(降)', 'Register(desc)'),
  nameUp(3, 'パーティ名(昇)', 'Party\'s name(asc)'),
  nameDown(4, 'パーティ名(降)', 'Party\'s name(desc)'),
  winRateUp(5, '勝率(昇)', 'Winning rate(asc)'),
  winRateDown(6, '勝率(降)', 'Winning rate(desc)');

  final int id;
  final String ja;
  final String en;
  const PartySort(this.id, this.ja, this.en);

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

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return ja;
      case Language.english:
      default:
        return en;
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
    var loc = AppLocalizations.of(context)!;
    if (isFirstBuild) {
      _partySort = widget.currentSort;
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text(loc.commonSort),
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
            child: Text(loc.commonCancel),
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