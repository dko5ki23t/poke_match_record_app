import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_delete_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/pokemon_filter_dialog.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PokemonsPage extends StatefulWidget {
  const PokemonsPage({
    Key? key,
    required this.onAdd,
    required this.selectMode,
    required this.onSelect,
    this.party,
  }) : super(key: key);
  final void Function(Pokemon myPokemon, bool isNew) onAdd;
  final void Function(Pokemon selectedPokemon)? onSelect;
  final bool selectMode;
  final Party? party;

  @override
  PokemonsPageState createState() => PokemonsPageState();
}

class PokemonsPageState extends State<PokemonsPage> {
  bool isEditMode = false;
  List<bool>? checkList;
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
    var typeFilter = pokeData.pokemonsTypeFilter;
    var teraTypeFilter = pokeData.pokemonsTeraTypeFilter;
    var moveFilter = pokeData.pokemonsMoveFilter;
    var sexFilter = pokeData.pokemonsSexFilter;
    var abilityFilter = pokeData.pokemonsAbilityFilter;
    var temperFilter = pokeData.pokemonsTemperFilter;
    var pokemons = appState.pokemons;
    var filteredPokemons = pokemons.where((element) => ownerFilter.contains(element.owner)).toList();
    filteredPokemons = filteredPokemons.where((element) => typeFilter.contains(element.type1.id) || typeFilter.contains(element.type2?.id)).toList();
    filteredPokemons = filteredPokemons.where((element) => teraTypeFilter.contains(element.teraType.id)).toList();
    if (moveFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) =>
        moveFilter.contains(element.move1.id) || moveFilter.contains(element.move2?.id) ||
        moveFilter.contains(element.move3?.id) || moveFilter.contains(element.move4?.id)).toList();
    }
    filteredPokemons = filteredPokemons.where((element) => sexFilter.contains(element.sex)).toList();
    if (abilityFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) => abilityFilter.contains(element.ability.id)).toList();
    }
    if (temperFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) => temperFilter.contains(element.temper.id)).toList();
    }
    appState.onBackKeyPushed = (){};
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
    checkList ??= List.generate(filteredPokemons.length, (i) => false);
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != filteredPokemons.length) {
      checkList = List.generate(filteredPokemons.length, (i) => false);
    }
    List<int?> partyPokemonsNo = [
      widget.party?.pokemon1.no,
      widget.party?.pokemon2?.no,
      widget.party?.pokemon3?.no,
      widget.party?.pokemon4?.no,
      widget.party?.pokemon5?.no,
      widget.party?.pokemon6?.no,
    ];

    if (filteredPokemons.isEmpty) {
      lists = Center(
        child: Text('表示できるポケモンのデータがありません。'),
      );
    }
    else {
      if (isEditMode) {
        lists = ListView(
          children: [
            for (int i = 0; i < filteredPokemons.length; i++)
              PokemonTile(
                filteredPokemons[i], theme,
                leading: Icon(Icons.drag_handle),
                trailing: Checkbox(
                  value: checkList![i],
                  onChanged: (isCheck) {
                    setState(() {
                      checkList![i] = isCheck ?? false;
                    });
                  },
                ),
                showWarning: true,
              ),
          ],
        );
      }
      else {
        lists = ListView(
          children: [
            for (var pokemon in filteredPokemons)
              PokemonTile(
                pokemon,
                theme,
                enabled: !partyPokemonsNo.contains(pokemon.no),
                leading: Icon(Icons.catching_pokemon),
                onLongPress: !widget.selectMode ? () => widget.onAdd(pokemon.copyWith(), false) : null,
                onTap: widget.selectMode ? () {
                  selectedPokemon = pokemon;
                  widget.onSelect!(pokemon);} : null,
              ),
            SizedBox(height: deviceHeight / 4),
          ],
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
                onPressed: () => setState(() => isEditMode = false),
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
                              typeFilter,
                              teraTypeFilter,
                              moveFilter,
                              sexFilter,
                              abilityFilter,
                              temperFilter,
                              (f1, f2, f3, f4, f5, f6, f7) async {
                                ownerFilter.clear();
                                typeFilter.clear();
                                teraTypeFilter.clear();
                                moveFilter.clear();
                                sexFilter.clear();
                                abilityFilter.clear();
                                temperFilter.clear();
                                ownerFilter.addAll(f1);
                                typeFilter.addAll(f2);
                                teraTypeFilter.addAll(f3);
                                moveFilter.addAll(f4);
                                sexFilter.addAll(f5);
                                abilityFilter.addAll(f6);
                                temperFilter.addAll(f7);
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
                      onPressed: null,
                      child: Icon(Icons.sort),
                    ),
                    TextButton(
                      onPressed: (filteredPokemons.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
              )
            : Container(),
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
                              bool isContainedParty = false;
                              for (int i = checkList!.length - 1; i >= 0; i--) {
                                if (checkList![i]) {
                                  if (filteredPokemons[i].refCount > 0) {
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
                                      for (int i = 0; i < checkList!.length; i++) {
                                        if (checkList![i]) {
                                          deleteIDs.add(filteredPokemons[i].id);
                                        }
                                      }
                                      //pokeData.recreateMyPokemon(pokemons);
                                      await pokeData.deleteMyPokemon(deleteIDs, false);
                                      setState(() {
                                        filteredPokemons = pokemons.where((element) => element.owner == Owner.mine).toList();
                                        checkList = List.generate(filteredPokemons.length, (i) => false);
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
                          onPressed: (getSelectedNum(checkList!) > 0) ?
                            () async {
                              for (int i = 0; i < checkList!.length; i++) {
                                if (checkList![i]) {
                                  Pokemon copiedPokemon = pokemons[i].copyWith();
                                  copiedPokemon.id = pokeData.getUniqueMyPokemonID();
                                  copiedPokemon.refCount = 0;
                                  pokemons.add(copiedPokemon);
                                  await pokeData.addMyPokemon(copiedPokemon);
                                }
                              }
                              setState(() {
                                checkList = List.generate(pokemons.length, (i) => false);
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
