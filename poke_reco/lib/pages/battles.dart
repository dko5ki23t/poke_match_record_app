import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/custom_dialogs/battle_delete_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/battle_filter_dialog.dart';
import 'package:poke_reco/custom_dialogs/battle_sort_dialog.dart';
import 'package:poke_reco/custom_widgets/battle_tile.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class BattlesPage extends StatefulWidget {
  const BattlesPage({
    Key? key,
    required this.onAdd,
    required this.onView,
  }) : super(key: key);
  final void Function(Battle battle, bool isNew) onAdd;
  final void Function(Battle battle) onView;

  @override
  BattlesPageState createState() => BattlesPageState();
}

class BattlesPageState extends State<BattlesPage> {
  bool isEditMode = false;
  Map<int, bool>? checkList;
  List<MapEntry<int, Battle>> sortedBattles = [];

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
    var loc = AppLocalizations.of(context)!;
    var winFilter = pokeData.battlesWinFilter;
    var partyIDFilter = pokeData.battlesPartyIDFilter;

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();
    final theme = Theme.of(context);

    // データ読み込みで待つ
    if (!pokeData.isLoaded) {
      EasyLoading.instance.userInteractions = false;  // 操作禁止にする
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.5);
      EasyLoading.show(status: loc.commonLoading);
    }
    else {
      EasyLoading.dismiss();
    }

    var filteredBattles = battles.entries.where((element) => element.value.id != 0);
    filteredBattles = filteredBattles.where(
      (element) => winFilter.contains(element.value.isMyWin ? 2 : element.value.isYourWin ? 3: 1)
    );
    if (partyIDFilter.isNotEmpty) {
      filteredBattles = filteredBattles.where((element) => partyIDFilter.contains(element.value.getParty(PlayerType.me).id));
    }
    var sort = pokeData.battlesSort;
    sortedBattles = filteredBattles.toList();
    sortedBattles.sort((a, b) => a.value.viewOrder.compareTo(b.value.viewOrder),);

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
        child: Text(loc.battlesTabNoBattle),
      );
    }
    else {
      if (isEditMode) {
        lists = Scrollbar(
           child: ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = sortedBattles.removeAt(oldIndex);
                sortedBattles.insert(newIndex, item);
                for (int i = 0; i < sortedBattles.length; i++) {
                  var battle = battles[sortedBattles[i].key]!;
                  battle.viewOrder = i+1;
                }
              });
            },
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
                  onTap: () => widget.onView(battle.value),
                ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.battlesTabTitleBattleList),
        actions: [
          isEditMode ?
          MyIconButton(
            // TODO awaitで待ち発生しない？終わるまで操作不能とかにしたい
            theme: theme,
            onPressed: () async {
              for (int i = 0; i < sortedBattles.length; i++) {
                var battle = battles[sortedBattles[i].key]!;
                battle.viewOrder = i+1;
                await pokeData.addBattle(battle, false);
              }
              pokeData.battlesSort = null;
              setState(() {
                isEditMode = false;
              });
            },
            icon: Icon(Icons.check),
            tooltip: loc.commonDone,
          ) :
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                MyIconButton(
                  theme: theme,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return BattleFilterDialog(
                          pokeData,
                          winFilter,
                          partyIDFilter,
                          (f1, f2) async {
                            winFilter.clear();
                            partyIDFilter.clear();
                            winFilter.addAll(f1);
                            partyIDFilter.addAll(f2);
                            await pokeData.saveConfig();
                            setState(() {});
                          },
                        );
                      }
                    );
                  },
                  icon: Icon(Icons.filter_alt),
                  tooltip: loc.commonFilter,
                ),
                MyIconButton(
                  theme: theme,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) {
                      return BattleSortDialog(
                        (battleSort) async {
                          switch (battleSort) {
                            case BattleSort.registerUp:
                              sortedBattles.sort((a, b) => a.value.id.compareTo(b.value.id),);
                              break;
                            case BattleSort.registerDown:
                              sortedBattles.sort((a, b) => -1 * a.value.id.compareTo(b.value.id),);
                              break;
                            case BattleSort.dateUp:
                              sortedBattles.sort((a, b) => a.value.datetime.compareTo(b.value.datetime),);
                              break;
                            case BattleSort.dateDown:
                              sortedBattles.sort((a, b) => -1 * a.value.datetime.compareTo(b.value.datetime),);
                              break;
                            default:
                              break;
                          }
                          if (sort != battleSort && battleSort != null) {
                            for (int i = 0; i < sortedBattles.length; i++) {
                              var battle = battles[sortedBattles[i].key]!;
                              battle.viewOrder = i+1;
                            }
                            await pokeData.updateAllBattleViewOrder();
                          }
                          pokeData.battlesSort = battleSort;
                          await pokeData.saveConfig();
                          setState(() {});
                        },
                        sort
                      );
                    }
                  ),
                  icon: Icon(Icons.sort),
                  tooltip: loc.commonSort,
                ),
                MyIconButton(
                  theme: theme,
                  onPressed: (sortedBattles.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                  icon: Icon(Icons.edit),
                  tooltip: loc.commonEdit,
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
                          Text(loc.commonSelectAll)
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
                          Text(loc.commonDelete)
                        ]),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: (getSelectedNumMap(checkList!) > 0) ?
                          () async {
                            for (final e in checkList!.keys) {
                              if (checkList![e]!) {
                                Battle copiedBattle = battles[e]!.copyWith();
                                await pokeData.addBattle(copiedBattle, true);
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
                          Text(loc.commonCopy),
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
                tooltip: loc.battlesTabTitleRegisterBattle,
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
