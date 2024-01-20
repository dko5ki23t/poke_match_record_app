import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

enum PokemonSort {
  registerUp(1, '登録(昇)', 'Register(asc)'),
  registerDown(2, '登録(降)', 'Register(desc)'),
  nickNameUp(3, 'ニックネーム(昇)', 'NickName(asc)'),
  nickNameDown(4, 'ニックネーム(降)', 'NickName(desc)'),
  nameUp(5, 'ポケモン名(昇)', 'Pokémon\'s name(asc)'),
  nameDown(6, 'ポケモン名(降)', 'Pokémon\'s name(desc)');

  final int id;
  final String ja;
  final String en;
  const PokemonSort(this.id, this.ja, this.en);

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
  PokemonSort? _pokemonSort;

  @override
  void initState() {
    super.initState();
    _pokemonSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.commonSort),
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
            child: Text(loc.commonCancel),
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