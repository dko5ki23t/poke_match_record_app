import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';

class PartiesPage extends StatefulWidget {
  const PartiesPage({
    Key? key,
    required this.onAdd,
  }) : super(key: key);
  final void Function(Party party, bool isNew) onAdd;

  @override
  PartiesPageState createState() => PartiesPageState();
}

class PartiesPageState extends State<PartiesPage> {
  bool isEditMode = false;
  List<bool>? checkList;
  Party? selectedParty;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);

    Widget lists;
    checkList ??= List.generate(parties.length, (i) => false);

    if (parties.isEmpty) {
      lists = Center(
        child: Text('パーティが登録されていません。'),
      );
    }
    else {
      if (isEditMode) {
        lists = ListView(
          children: [
            for (int i = 0; i < parties.length; i++)
              PartyTile(
                parties[i], theme, pokeData,
                leading: Icon(Icons.drag_handle),
                trailing: Checkbox(
                  value: checkList![i],
                  onChanged: (isCheck) {
                    setState(() {
                      checkList![i] = isCheck ?? false;
                    });
                  },
                ),
              )
          ],
        );
      }
      else {
        lists = ListView(
          children: [
            for (var party in parties)
              PartyTile(
                party, theme, pokeData,
                leading: Icon(Icons.group),
                onLongPress: () => widget.onAdd(party, false),
              )
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('パーティ一覧'),
        actions: [
          isEditMode ?
          TextButton(
            onPressed: () => setState(() => isEditMode = false),
            child: Text('完了'),
          ) :
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                TextButton(
                  onPressed: null,
                  child: Icon(Icons.filter_alt),
                ),
                TextButton(
                  onPressed: null,
                  child: Icon(Icons.sort),
                ),
                TextButton(
                  onPressed: (parties.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                  child: Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children:
              isEditMode ?
                [
                  Expanded(flex: 10, child: lists),
                  Expanded(child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      TextButton(
                        child: Row(children: [
                          Icon(Icons.select_all),
                          SizedBox(width: 10),
                          Text('すべて選択')
                        ]),
                        onPressed: () => setState(() {
                          selectAll(checkList!);
                        }),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: (getSelectedNum(checkList!) > 0) ?
                          () => setState(() {
                            //List<int> deleteIDs = [];
                            for (int i = checkList!.length - 1; i >= 0; i--) {
                              if (checkList![i]) {
                                //deleteIDs.add(pokemons[i].id);
                                checkList!.removeAt(i);
                                parties.removeAt(i);
                              }
                            }
                            pokeData.recreateParty(parties);
                            //pokeData.deleteMyPokemon(deleteIDs);
                          })
                          :
                          null,
                        child: Row(children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text('削除')
                        ]),
                      ),
                    ],
                  ),),),
                ]
                :
                [
                  Expanded(child: lists),
                ],
          ),
          !isEditMode ?
          Container(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                tooltip: 'パーティ登録',
                shape: CircleBorder(),
                onPressed: (){
                  checkList = null;
                  widget.onAdd(Party(), true);
                },
                child: Icon(Icons.add),
              ),
            ),
          )
          : Container(),
        ],
      ),
    );
  }
}
