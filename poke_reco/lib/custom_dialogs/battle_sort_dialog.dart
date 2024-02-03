import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

enum BattleSort {
  registerUp(1, '登録(昇)', 'Register(asc)'),
  registerDown(2, '登録(降)', 'Register(desc)'),
  dateUp(3, '対戦日時(昇)', 'Battle datetime(asc)'),
  dateDown(4, '対戦日時(降)', 'Battle datetime(desc)');

  final int id;
  final String ja;
  final String en;
  const BattleSort(this.id, this.ja, this.en);

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

class BattleSortDialog extends StatefulWidget {
  final Future<void> Function(BattleSort? battleSort) onOK;
  final BattleSort? currentSort;

  const BattleSortDialog(this.onOK, this.currentSort, {Key? key})
      : super(key: key);

  @override
  BattleSortDialogState createState() => BattleSortDialogState();
}

class BattleSortDialogState extends State<BattleSortDialog> {
  BattleSort? _battleSort;

  @override
  void initState() {
    super.initState();
    _battleSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.commonSort),
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
                    }),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            Navigator.pop(context);
            await widget.onOK(_battleSort);
          },
        ),
      ],
    );
  }
}
