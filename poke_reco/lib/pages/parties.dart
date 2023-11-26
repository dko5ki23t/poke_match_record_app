import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/custom_dialogs/party_delete_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/party_filter_dialog.dart';
import 'package:poke_reco/custom_dialogs/party_sort_dialog.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/party.dart';

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
  Map<int, bool>? checkList;
  Party? selectedParty;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    var winRateMinFilter = pokeData.partiesWinRateMinFilter;
    var winRateMaxFilter = pokeData.partiesWinRateMaxFilter;
    var pokemonNoFilter = pokeData.partiesPokemonNoFilter;
    var filteredParties = parties.entries.where((element) => element.value.id != 0 && element.value.owner == Owner.mine);
    filteredParties = filteredParties.where((element) => element.value.winRate >= winRateMinFilter);
    filteredParties = filteredParties.where((element) => element.value.winRate <= winRateMaxFilter);
    if (pokemonNoFilter.isNotEmpty) {
      filteredParties = filteredParties.where((element) {
        for (var pokemon in element.value.pokemons) {
          if (pokemonNoFilter.contains(pokemon?.no)) return true;
        }
        return false;
      });
    }
    var sort = pokeData.partiesSort;
    var sortedParties = filteredParties.toList();
    sortedParties.sort((a, b) => a.value.viewOrder.compareTo(b.value.viewOrder));

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();
    final theme = Theme.of(context);

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
      for (final e in sortedParties) {
        checkList![e.key] = false;
      }
    }
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != sortedParties.length) {
      checkList = {};
      for (final e in sortedParties) {
        checkList![e.key] = false;
      }
    }

    if (sortedParties.isEmpty) {
      lists = Center(
        child: Text('表示できるパーティがありません。'),
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
                final item = sortedParties.removeAt(oldIndex);
                sortedParties.insert(newIndex, item);
                for (int i = 0; i < sortedParties.length; i++) {
                  var party = parties[sortedParties[i].key]!;
                  party.viewOrder = i+1;
                }
              });
            },
            children: [
              for (final e in sortedParties)
                PartyTile(
                  e.value, theme,
                  leading: Icon(Icons.drag_handle),
                  trailing: Checkbox(
                    value: checkList![e.key],
                    onChanged: (isCheck) {
                      setState(() {
                        checkList![e.key] = isCheck ?? false;
                      });
                    },
                  ),
                )
            ],
          ),
        );
      }
      else {
        lists = Scrollbar(
          child: ListView(
            children: [
              for (final party in sortedParties)
                PartyTile(
                  party.value, theme,
                  leading: Icon(Icons.group),
                  onLongPress: () => widget.onAdd(party.value.copyWith(), false),
                )
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('パーティ一覧'),
        actions: [
          isEditMode ?
          MyIconButton(
            theme: theme,
            onPressed: () {
              setState(() => isEditMode = false);
              pokeData.partiesSort = null;
            },
            icon: Icon(Icons.check),
            tooltip: '完了',
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
                            return PartyFilterDialog(
                              pokeData,
                              winRateMinFilter,
                              winRateMaxFilter,
                              pokemonNoFilter,
                              (f1, f2, f3) async {
                                pokemonNoFilter.clear();
                                pokeData.partiesWinRateMinFilter = f1;
                                pokeData.partiesWinRateMaxFilter = f2;
                                pokemonNoFilter.addAll(f3);
                                await pokeData.saveConfig();
                                setState(() {});
                              },
                            );
                          }
                        );
                      },
                  icon: Icon(Icons.filter_alt),
                  tooltip: 'フィルタ',
                ),
                MyIconButton(
                  theme: theme,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) {
                      return PartySortDialog(
                        (partySort) async {
                          switch (partySort) {
                            case PartySort.registerUp:
                              sortedParties.sort((a, b) => a.value.id.compareTo(b.value.id),);
                              break;
                            case PartySort.registerDown:
                              sortedParties.sort((a, b) => -1 * a.value.id.compareTo(b.value.id),);
                              break;
                            case PartySort.nameUp:
                              sortedParties.sort((a, b) => a.value.name.compareTo(b.value.name),);
                              break;
                            case PartySort.nameDown:
                              sortedParties.sort((a, b) => -1 * a.value.name.compareTo(b.value.name),);
                              break;
                            case PartySort.winRateUp:
                              sortedParties.sort((a, b) => a.value.winRate.compareTo(b.value.winRate),);
                              break;
                            case PartySort.winRateDown:
                              sortedParties.sort((a, b) => -1 * a.value.winRate.compareTo(b.value.winRate),);
                              break;
                            default:
                              break;
                          }
                          if (sort != partySort && partySort != null) {
                            for (int i = 0; i < sortedParties.length; i++) {
                              var party = parties[sortedParties[i].key]!;
                              party.viewOrder = i+1;
                              await pokeData.addParty(party);
                            }
                          }
                          pokeData.partiesSort = partySort;
                          await pokeData.saveConfig();
                          setState(() {});
                        },
                        sort
                      );
                    }
                  ),
                  icon: Icon(Icons.sort),
                  tooltip: '並べ替え',
                ),
                MyIconButton(
                  theme: theme,
                  onPressed: (sortedParties.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                  icon: Icon(Icons.edit),
                  tooltip: '編集',
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
                            bool isContainedBattle = false;
                            showDialog(
                              context: context,
                              builder: (_) {
                                return PartyDeleteCheckDialog(
                                  isContainedBattle,
                                  () async {
                                    List<int> deleteIDs = [];
                                    for (final e in checkList!.keys) {
                                      if (checkList![e]!) {
                                        deleteIDs.add(e);
                                      }
                                    }
                                    //pokeData.recreateParty(parties);
                                    await pokeData.deleteParty(deleteIDs, false);
                                    setState(() {
                                      checkList = {};
                                      for (final e in sortedParties) {
                                        checkList![e.key] = false;
                                      }
                                    });
                                  },
                                  () {},        // TODO
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
                      SizedBox(width: 20,),
                      TextButton(
                        onPressed: (getSelectedNumMap(checkList!) > 0) ?
                          () async {
                            for (final e in checkList!.keys) {
                              if (checkList![e]!) {
                                Party copiedParty = parties[e]!.copyWith();
                                copiedParty.id = pokeData.getUniquePartyID();
                                copiedParty.viewOrder = copiedParty.id;
                                copiedParty.refCount = 0;
                                parties[copiedParty.id] = copiedParty;
                                await pokeData.addParty(copiedParty);
                              }
                            }
                            setState(() {
                              checkList = {};
                              for (final e in sortedParties) {
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
