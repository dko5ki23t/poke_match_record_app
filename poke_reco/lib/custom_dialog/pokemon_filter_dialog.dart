import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

class PokemonFilterDialog extends StatefulWidget {
  final void Function(
    List<Owner> ownerFilter,
    List<int> typeFilter,
    List<int> teraTypeFilter) onOK;
  final PokeDB pokeData;
  final List<Owner> ownerFilter;
  final List<int> typeFilter;
  final List<int> teraTypeFilter;

  const PokemonFilterDialog(
    this.pokeData,
    this.ownerFilter,
    this.typeFilter,
    this.teraTypeFilter,
    this.onOK,
    {Key? key}) : super(key: key);

  @override
  PokemonFilterDialogState createState() => PokemonFilterDialogState();
}

class PokemonFilterDialogState extends State<PokemonFilterDialog> {
  bool isFirstBuild = true;
  List<Owner> ownerFilter = [];
  List<int> typeFilter = [];
  List<int> teraTypeFilter = [];

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      ownerFilter = [...widget.ownerFilter];
      typeFilter = [...widget.typeFilter];
      teraTypeFilter = [...widget.teraTypeFilter];
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('フィルタ'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text('作成者'),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            ListTile(
              title: Text('自分のポケモン'),
              leading: Checkbox(
                value: ownerFilter.contains(Owner.mine),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      ownerFilter.add(Owner.mine);
                    }
                    else {
                      ownerFilter.remove(Owner.mine);
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: Text('対戦相手のポケモン'),
              leading: Checkbox(
                value: ownerFilter.contains(Owner.fromBattle),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      ownerFilter.add(Owner.fromBattle);
                    }
                    else {
                      ownerFilter.remove(Owner.fromBattle);
                    }
                  });
                },
              ),
            ),
            Text('タイプ'),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            for (final type in widget.pokeData.types)
            ListTile(
              title: Row(
                children: [
                  type.displayIcon,
                  Text(type.displayName)
                ],
              ),
              leading: Checkbox(
                value: typeFilter.contains(type.id),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      typeFilter.add(type.id);
                    }
                    else {
                      typeFilter.remove(type.id);
                    }
                  });
                },
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
            onTap: () {
              Navigator.pop(context);
              widget.onOK(ownerFilter, typeFilter, teraTypeFilter);
            },
          ),
        ],
    );
  }
}