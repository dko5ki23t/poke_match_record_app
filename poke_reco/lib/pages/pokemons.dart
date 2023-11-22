import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_delete_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/pokemon_filter_dialog.dart';
import 'package:poke_reco/custom_dialogs/pokemon_sort_dialog.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/party.dart';

class PokemonsPage extends StatefulWidget {
  const PokemonsPage({
    Key? key,
    required this.onAdd,
    required this.selectMode,
    required this.onSelect,
    this.party,
    this.selectingPokemonIdx,
  }) : super(key: key);
  final void Function(Pokemon myPokemon, bool isNew) onAdd;
  final void Function(Pokemon selectedPokemon)? onSelect;
  final bool selectMode;
  final Party? party;
  final int? selectingPokemonIdx;

  @override
  PokemonsPageState createState() => PokemonsPageState();
}

class PokemonsPageState extends State<PokemonsPage> {
  bool isEditMode = false;
  Map<int, bool>? checkList;
  Pokemon? selectedPokemon;

  final increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  final decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;
    var ownerFilter = pokeData.pokemonsOwnerFilter;
    var noFilter = pokeData.pokemonsNoFilter;
    var typeFilter = pokeData.pokemonsTypeFilter;
    var teraTypeFilter = pokeData.pokemonsTeraTypeFilter;
    var moveFilter = pokeData.pokemonsMoveFilter;
    var sexFilter = pokeData.pokemonsSexFilter;
    var abilityFilter = pokeData.pokemonsAbilityFilter;
    var temperFilter = pokeData.pokemonsTemperFilter;
    var pokemons = appState.pokemons;
    var filteredPokemons = pokemons.entries.where((element) => element.value.id != 0 && ownerFilter.contains(element.value.owner));
    if (noFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) => noFilter.contains(element.value.no));
    }
    filteredPokemons = filteredPokemons.where((element) => typeFilter.contains(element.value.type1.id) || typeFilter.contains(element.value.type2?.id));
    filteredPokemons = filteredPokemons.where((element) => teraTypeFilter.contains(element.value.teraType.id));
    if (moveFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) =>
        moveFilter.contains(element.value.move1.id) || moveFilter.contains(element.value.move2?.id) ||
        moveFilter.contains(element.value.move3?.id) || moveFilter.contains(element.value.move4?.id));
    }
    filteredPokemons = filteredPokemons.where((element) => sexFilter.contains(element.value.sex.id));
    if (abilityFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) => abilityFilter.contains(element.value.ability.id));
    }
    if (temperFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) => temperFilter.contains(element.value.temper.id));
    }
    var sort = pokeData.pokemonsSort;
    var sortedPokemons = filteredPokemons.toList();
    sortedPokemons.sort((a, b) => a.value.viewOrder.compareTo(b.value.viewOrder));

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();
    final theme = Theme.of(context);
    final double deviceHeight = MediaQuery.of(context).size.height;

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
      for (final e in sortedPokemons) {
        checkList![e.key] = false;
      }
    }
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != sortedPokemons.length) {
      checkList = {};
      for (final e in sortedPokemons) {
        checkList![e.key] = false;
      }
    }
    List<int?> partyPokemonsNo = [
      for (int i = 0; i < 6; i++)
      widget.selectingPokemonIdx != null && i != widget.selectingPokemonIdx!-1 ?
        widget.party?.pokemons[i]?.no : null,
    ];

    if (sortedPokemons.isEmpty) {
      lists = Center(
        child: Text('表示できるポケモンのデータがありません。'),
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
                final item = sortedPokemons.removeAt(oldIndex);
                sortedPokemons.insert(newIndex, item);
                for (int i = 0; i < sortedPokemons.length; i++) {
                  var pokemon = pokemons[sortedPokemons[i].key]!;
                  pokemon.viewOrder = i+1;
                }
              });
            },
            children: [
              for (final e in sortedPokemons)
                PokemonTile(
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
                  showWarning: true,
                ),
            ],
          ),
        );
      }
      else {
        lists = Scrollbar(
          child: ListView(
            children: [
              for (final e in sortedPokemons)
                PokemonTile(
                  e.value,
                  theme,
                  enabled: !partyPokemonsNo.contains(e.value.no),
                  leading: Icon(Icons.catching_pokemon),
                  onLongPress: !widget.selectMode ? () => widget.onAdd(e.value.copyWith(), false) : null,
                  onTap: widget.selectMode ? () {
                    selectedPokemon = e.value;
                    widget.onSelect!(e.value);} : null,
                ),
              SizedBox(height: deviceHeight / 4),
            ],
          ),
        );
      }
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(selectedPokemon);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.selectMode ? Text('ポケモン選択') : Text('ポケモン一覧'),
          actions: [
            !widget.selectMode ?
              isEditMode ?
              TextButton(
                onPressed: () {
                  setState(() => isEditMode = false);
                  pokeData.pokemonsSort = null;
                },
                child: Text('完了'),
              ) :
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return PokemonFilterDialog(
                              pokeData,
                              ownerFilter,
                              noFilter,
                              typeFilter,
                              teraTypeFilter,
                              moveFilter,
                              sexFilter,
                              abilityFilter,
                              temperFilter,
                              (f1, f2, f3, f4, f5, f6, f7, f8) async {
                                ownerFilter.clear();
                                noFilter.clear();
                                typeFilter.clear();
                                teraTypeFilter.clear();
                                moveFilter.clear();
                                sexFilter.clear();
                                abilityFilter.clear();
                                temperFilter.clear();
                                ownerFilter.addAll(f1);
                                noFilter.addAll(f2);
                                typeFilter.addAll(f3);
                                teraTypeFilter.addAll(f4);
                                moveFilter.addAll(f5);
                                sexFilter.addAll(f6);
                                abilityFilter.addAll(f7);
                                temperFilter.addAll(f8);
                                await pokeData.saveConfig();
                                setState(() {});
                              },
                            );
                          }
                        );
                      },
                      child: Icon(Icons.filter_alt),
                    ),
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) {
                          return PokemonSortDialog(
                            (pokemonSort) async {
                              switch (pokemonSort) {
                                case PokemonSort.registerUp:
                                  sortedPokemons.sort((a, b) => a.value.id.compareTo(b.value.id),);
                                  break;
                                case PokemonSort.registerDown:
                                  sortedPokemons.sort((a, b) => -1 * a.value.id.compareTo(b.value.id),);
                                  break;
                                case PokemonSort.nickNameUp:
                                  sortedPokemons.sort((a, b) => a.value.nickname.compareTo(b.value.nickname),);
                                  break;
                                case PokemonSort.nickNameDown:
                                  sortedPokemons.sort((a, b) => -1 * a.value.nickname.compareTo(b.value.nickname),);
                                  break;
                                case PokemonSort.nameUp:
                                  sortedPokemons.sort((a, b) => a.value.name.compareTo(b.value.name),);
                                  break;
                                case PokemonSort.nameDown:
                                  sortedPokemons.sort((a, b) => -1 * a.value.name.compareTo(b.value.name),);
                                  break;
                                default:
                                  break;
                              }
                              if (sort != pokemonSort && pokemonSort != null) {
                                for (int i = 0; i < sortedPokemons.length; i++) {
                                  var pokemon = pokemons[sortedPokemons[i].key]!;
                                  pokemon.viewOrder = i+1;
                                  await pokeData.addMyPokemon(pokemon);
                                }
                              }
                              pokeData.pokemonsSort = pokemonSort;
                              await pokeData.saveConfig();
                              setState(() {});
                            },
                            sort
                          );
                        }
                      ),
                      child: Icon(Icons.sort),
                    ),
                    TextButton(
                      onPressed: (sortedPokemons.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
              )
            :
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return PokemonFilterDialog(
                            pokeData,
                            ownerFilter,
                            noFilter,
                            typeFilter,
                            teraTypeFilter,
                            moveFilter,
                            sexFilter,
                            abilityFilter,
                            temperFilter,
                            (f1, f2, f3, f4, f5, f6, f7, f8) async {
                              ownerFilter.clear();
                              noFilter.clear();
                              typeFilter.clear();
                              teraTypeFilter.clear();
                              moveFilter.clear();
                              sexFilter.clear();
                              abilityFilter.clear();
                              temperFilter.clear();
                              ownerFilter.addAll(f1);
                              noFilter.addAll(f2);
                              typeFilter.addAll(f3);
                              teraTypeFilter.addAll(f4);
                              moveFilter.addAll(f5);
                              sexFilter.addAll(f6);
                              abilityFilter.addAll(f7);
                              temperFilter.addAll(f8);
                              await pokeData.saveConfig();
                              setState(() {});
                            },
                          );
                        }
                      );
                    },
                    child: Icon(Icons.filter_alt),
                  ),
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) {
                        return PokemonSortDialog(
                          (pokemonSort) async {
                            switch (pokemonSort) {
                              case PokemonSort.registerUp:
                                sortedPokemons.sort((a, b) => a.value.id.compareTo(b.value.id),);
                                break;
                              case PokemonSort.registerDown:
                                sortedPokemons.sort((a, b) => -1 * a.value.id.compareTo(b.value.id),);
                                break;
                              case PokemonSort.nickNameUp:
                                sortedPokemons.sort((a, b) => a.value.nickname.compareTo(b.value.nickname),);
                                break;
                              case PokemonSort.nickNameDown:
                                sortedPokemons.sort((a, b) => -1 * a.value.nickname.compareTo(b.value.nickname),);
                                break;
                              case PokemonSort.nameUp:
                                sortedPokemons.sort((a, b) => a.value.name.compareTo(b.value.name),);
                                break;
                              case PokemonSort.nameDown:
                                sortedPokemons.sort((a, b) => -1 * a.value.name.compareTo(b.value.name),);
                                break;
                              default:
                                break;
                            }
                            if (sort != pokemonSort && pokemonSort != null) {
                              for (int i = 0; i < sortedPokemons.length; i++) {
                                var pokemon = pokemons[sortedPokemons[i].key]!;
                                pokemon.viewOrder = i+1;
                                await pokeData.addMyPokemon(pokemon);
                              }
                            }
                            pokeData.pokemonsSort = pokemonSort;
                            await pokeData.saveConfig();
                            setState(() {});
                          },
                          sort
                        );
                      }
                    ),
                    child: Icon(Icons.sort),
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
                              bool isContainedParty = false;
                              for (final e in checkList!.keys) {
                                if (checkList![e]!) {
                                  if (sortedPokemons.where((element) => element.value.id == e).first.value.refCount > 0) {
                                    isContainedParty = true;
                                    break;
                                  }
                                }
                              }
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return PokemonDeleteCheckDialog(
                                    isContainedParty,
                                    () async {
                                      List<int> deleteIDs = [];
                                      for (final e in checkList!.keys) {
                                        if (checkList![e]!) {
                                          deleteIDs.add(e);
                                        }
                                      }
                                      //pokeData.recreateMyPokemon(pokemons);
                                      await pokeData.deleteMyPokemon(deleteIDs, false);
                                      setState(() {
                                        /*
                                        filteredPokemons = pokemons.entries.where((element) => element.value.id != 0 && ownerFilter.contains(element.value.owner));
                                        filteredPokemons = filteredPokemons.where((element) => typeFilter.contains(element.value.type1.id) || typeFilter.contains(element.value.type2?.id));
                                        filteredPokemons = filteredPokemons.where((element) => teraTypeFilter.contains(element.value.teraType.id));
                                        if (moveFilter.isNotEmpty) {
                                          filteredPokemons = filteredPokemons.where((element) =>
                                            moveFilter.contains(element.value.move1.id) || moveFilter.contains(element.value.move2?.id) ||
                                            moveFilter.contains(element.value.move3?.id) || moveFilter.contains(element.value.move4?.id));
                                        }
                                        filteredPokemons = filteredPokemons.where((element) => sexFilter.contains(element.value.sex));
                                        if (abilityFilter.isNotEmpty) {
                                          filteredPokemons = filteredPokemons.where((element) => abilityFilter.contains(element.value.ability.id));
                                        }
                                        if (temperFilter.isNotEmpty) {
                                          filteredPokemons = filteredPokemons.where((element) => temperFilter.contains(element.value.temper.id));
                                        }
                                        checkList = {};
                                        for (final e in filteredPokemons) {
                                          checkList![e.key] = false;
                                        }*/
                                      });
                                    },
                                    () {},    // TODO
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
                                  Pokemon copiedPokemon = pokemons[e]!.copyWith();
                                  copiedPokemon.id = pokeData.getUniqueMyPokemonID();
                                  copiedPokemon.viewOrder = copiedPokemon.id;
                                  copiedPokemon.refCount = 0;
                                  pokemons[copiedPokemon.id] = copiedPokemon;
                                  await pokeData.addMyPokemon(copiedPokemon);
                                }
                              }
                              setState(() {
                                checkList = {};
                                for (final e in sortedPokemons) {
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
            !isEditMode && !widget.selectMode ?
            Container(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  tooltip: 'ポケモン登録',
                  shape: CircleBorder(),
                  onPressed: (){
                    checkList = null;
                    widget.onAdd(Pokemon(), true);
                  },
                  child: Icon(Icons.add),
                ),
              ),
            )
            : Container(),
          ],
        ),
      )
    );
  }
}
