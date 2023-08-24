import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_tile.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:provider/provider.dart';

class BattlesPage extends StatefulWidget {
  const BattlesPage({
    Key? key,
    required this.onAdd,
  }) : super(key: key);
  final void Function(Battle myPokemon, bool isNew) onAdd;

  @override
  BattlesPageState createState() => BattlesPageState();
}

class BattlesPageState extends State<BattlesPage> {
  bool isEditMode = false;
  List<bool>? checkList;

  final increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  final decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  void selectAll() {
    bool existFalse = false;
    for (final e in checkList!) {
      if (!e) existFalse = true;
    }

    for (int i = 0; i < checkList!.length; i++) {
      checkList![i] = existFalse;
    }
  }

  int getSelectedNum() {
    return checkList!.where((bool val) => val).length;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var battles = appState.battles;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);

    Widget lists;
//    checkList ??= List.generate(battles.length, (i) => false);

    if (battles.isEmpty) {
      lists = Center(
        child: Text('バトルが登録されていません。'),
      );
    }
    else {
/*
      if (isEditMode) {
        lists = ListView(
          children: [
            for (int i = 0; i < pokemons.length; i++)
              PokemonTile(
                pokemons[i],
                theme,
                pokeData,
                leading: Checkbox(
                  value: checkList![i],
                  onChanged: (isCheck) {
                    setState(() {
                      checkList![i] = isCheck ?? false;
                    });
                  },
                ),
                trailing: TextButton(
                  onPressed: () => widget.onAdd(pokemons[i], false),
                  child: Icon(Icons.edit),
                ),
              ),
          ],
        );
      }
      else {
*/
        lists = ListView(
          children: [
            for (var battle in battles)
            BattleTile(
              battle,
              theme,
              pokeData,
              leading: Icon(Icons.list_alt),
//              onLongPress: () => widget.onAdd(pokemon, false),
            ),
          ],
        );
//      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('バトル一覧'),
        actions: [
/*
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
                  onPressed: (pokemons.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                  child: Icon(Icons.edit),
                ),
              ],
            ),
          ),
*/
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children:
/*
              isEditMode ?
                [
                  Expanded(child: lists),
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
                          selectAll();
                        }),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: (getSelectedNum() > 0) ?
                          () => setState(() {
                            //List<int> deleteIDs = [];
                            for (int i = checkList!.length - 1; i >= 0; i--) {
                              if (checkList![i]) {
                                //deleteIDs.add(pokemons[i].id);
                                checkList!.removeAt(i);
                                pokemons.removeAt(i);
                              }
                            }
                            pokeData.recreateMyPokemon(pokemons);
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
*/
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
                tooltip: '新規作成',
                shape: CircleBorder(),
                onPressed: (){
                  checkList = null;
                  widget.onAdd(Battle(), true);
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
