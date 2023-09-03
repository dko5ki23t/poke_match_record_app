import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialog/battle_delete_check_dialog.dart';
import 'package:poke_reco/custom_widgets/battle_tile.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';
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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var battles = appState.battles;
    var pokeData = appState.pokeData;
    appState.onBackKeyPushed = (){};
    final theme = Theme.of(context);
    final double deviceHeight = MediaQuery.of(context).size.height;

    Widget lists;
    checkList ??= List.generate(battles.length, (i) => false);
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != battles.length) {
      checkList = List.generate(battles.length, (i) => false);
    }

    if (battles.isEmpty) {
      lists = Center(
        child: Text('バトルが登録されていません。'),
      );
    }
    else {
      if (isEditMode) {
        lists = ListView(
          children: [
            for (int i = 0; i < battles.length; i++)
              BattleTile(
                battles[i],
                theme,
                pokeData,
                leading: Icon(Icons.drag_handle),
                trailing: Checkbox(
                  value: checkList![i],
                  onChanged: (isCheck) {
                    setState(() {
                      checkList![i] = isCheck ?? false;
                    });
                  },
                ),
              ),
          ],
        );
      }
      else {
        lists = ListView(
          children: [
            for (var battle in battles)
              BattleTile(
                battle,
                theme,
                pokeData,
                leading: Icon(Icons.list_alt),
                onLongPress: () => widget.onAdd(battle.copyWith(), false),
              ),
            SizedBox(height: deviceHeight / 4),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('バトル一覧'),
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
                  onPressed: (battles.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
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
                          () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return BattleDeleteCheckDialog(
                                  () async {
                                    List<int> deleteIDs = [];
                                    for (int i = 0; i < checkList!.length; i++) {
                                      if (checkList![i]) {
                                        deleteIDs.add(battles[i].id);
                                      }
                                    }
                                    //pokeData.recreateMyPokemon(pokemons);
                                    await pokeData.deleteBattle(deleteIDs);
                                    setState(() {
                                      checkList = List.generate(battles.length, (i) => false);
                                    });
                                  },
                                );
                              }
                            );
                          }
                          :
                          null,
                        child: Row(children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text('削除')
                        ]),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: (getSelectedNum(checkList!) > 0) ?
                          () async {
                            for (int i = 0; i < checkList!.length; i++) {
                              if (checkList![i]) {
                                Battle copiedBattle = battles[i].copyWith();
                                copiedBattle.id = pokeData.getUniqueBattleID();
                                battles.add(copiedBattle);
                                pokeData.addBattle(copiedBattle);
                              }
                            }
                            setState(() {
                              checkList = List.generate(battles.length, (i) => false);
                            });
                          } : null,
                        child: Row(children: [
                          Icon(Icons.copy),
                          SizedBox(width: 10),
                          Text('コピー作成'),
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
                tooltip: 'バトル登録',
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
