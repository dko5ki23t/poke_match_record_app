import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/custom_dialogs/battle_delete_check_dialog.dart';
import 'package:poke_reco/custom_widgets/battle_tile.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/battle.dart';
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
  Map<int, bool>? checkList;

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
    appState.onTabChange = (func) => func();
    final theme = Theme.of(context);
    final double deviceHeight = MediaQuery.of(context).size.height;
    var filteredBattles = battles.entries.where((element) => element.value.id != 0);
    var sortedBattles = filteredBattles.toList();
    sortedBattles.sort((a, b) => a.key.compareTo(b.key),);

    // データ読み込みで待つ
    if (!pokeData.isLoaded) {
      EasyLoading.instance.userInteractions = false;  // 操作禁止にする
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.5);
      EasyLoading.show(status: 'データ読み込み中です。しばらくお待ちください...');
    }
    else {
      EasyLoading.dismiss();
    }

    Widget lists;
    if (checkList == null) {
      checkList = {};
      for (final e in sortedBattles) {
        checkList![e.key] = false;
      }
    }
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != sortedBattles.length) {
      checkList = {};
      for (final e in sortedBattles) {
        checkList![e.key] = false;
      }
    }

    if (sortedBattles.isEmpty) {
      lists = Center(
        child: Text('表示できる対戦がありません。'),
      );
    }
    else {
      if (isEditMode) {
        lists = Scrollbar(
           child: ListView(
            children: [
              for (final e in sortedBattles)
                BattleTile(
                  e.value,
                  theme,
                  leading: Icon(Icons.drag_handle),
                  trailing: Checkbox(
                    value: checkList![e.key],
                    onChanged: (isCheck) {
                      setState(() {
                        checkList![e.key] = isCheck ?? false;
                      });
                    },
                  ),
                ),
            ],
           ),
        );
      }
      else {
        lists = Scrollbar(
          child: ListView(
            children: [
              for (final battle in sortedBattles)
                BattleTile(
                  battle.value,
                  theme,
                  leading: Icon(Icons.list_alt),
                  onLongPress: () => widget.onAdd(battle.value.copyWith(), false),
                ),
              SizedBox(height: deviceHeight / 4),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('対戦一覧'),
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
                  onPressed: (sortedBattles.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
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
                          selectAllMap(checkList!);
                        }),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: (getSelectedNumMap(checkList!) > 0) ?
                          () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return BattleDeleteCheckDialog(
                                  () async {
                                    List<int> deleteIDs = [];
                                    for (final e in checkList!.keys) {
                                      if (checkList![e]!) {
                                        deleteIDs.add(e);
                                      }
                                    }
                                    //pokeData.recreateMyPokemon(pokemons);
                                    await pokeData.deleteBattle(deleteIDs);
                                    setState(() {
                                      checkList = {};
                                      for (final e in sortedBattles) {
                                        checkList![e.key] = false;
                                      }
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
                        onPressed: (getSelectedNumMap(checkList!) > 0) ?
                          () async {
                            for (final e in checkList!.keys) {
                              if (checkList![e]!) {
                                Battle copiedBattle = battles[e]!.copyWith();
                                copiedBattle.id = pokeData.getUniqueBattleID();
                                battles[copiedBattle.id] = copiedBattle;
                                await pokeData.addBattle(copiedBattle);
                              }
                            }
                            setState(() {
                              checkList = {};
                              for (final e in sortedBattles) {
                                checkList![e.key] = false;
                              }
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
