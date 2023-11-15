import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

enum PokemonSort {
  registerUp(1, '登録(昇)'),
  registerDown(2, '登録(降)'),
  nickNameUp(3, 'ニックネーム(昇)'),
  nickNameDown(4, 'ニックネーム(降)'),
  nameUp(5, 'ポケモン(昇)'),
  nameDown(6, 'ポケモン(降)');

  final int id;
  final String displayName;
  const PokemonSort(this.id, this.displayName);

  factory PokemonSort.createFromId(int id) {
    switch (id) {
      case 1:
        return registerUp;
      case 2:
        return registerDown;
      case 3:
        return nickNameUp;
      case 4:
        return nickNameDown;
      case 5:
        return nameUp;
      case 6:
        return nameDown;
      default:
        return registerUp;
    }
  }
}

class PokemonSortDialog extends StatefulWidget {
  final Future<void> Function (
    PokemonSort? pokemonSort) onOK;
  final PokemonSort? currentSort;

  const PokemonSortDialog(
    this.onOK,
    this.currentSort,
    {Key? key}) : super(key: key);

  @override
  PokemonSortDialogState createState() => PokemonSortDialogState();
}

class PokemonSortDialogState extends State<PokemonSortDialog> {
  bool isFirstBuild = true;
  PokemonSort? _pokemonSort;

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      _pokemonSort = widget.currentSort;
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('並べ替え'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (var e in PokemonSort.values)
            ListTile(
              title: Text(e.displayName),
              leading: Radio<PokemonSort>(
                value: e,
                groupValue: _pokemonSort,
                onChanged: (PokemonSort? value) {
                  setState(() {
                    _pokemonSort = value;
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
              await widget.onOK(_pokemonSort);
            },
          ),
        ],
    );
  }
}