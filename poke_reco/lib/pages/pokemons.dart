import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
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
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    final double deviceHeight = MediaQuery.of(context).size.height;

    // ポケモンデータ取得で待つ
    if (!pokeData.isLoaded) {
      EasyLoading.instance.userInteractions = false;  // 操作禁止にする
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.5);
      EasyLoading.show(status: 'ポケモンの情報取得中です。しばらくお待ちください...');
    }
    else {
      EasyLoading.dismiss();
    }

    Widget lists;
    checkList ??= List.generate(pokemons.length, (i) => false);
    List<int?> partyPokemonsNo = [
      widget.party?.pokemon1.no,
      widget.party?.pokemon2?.no,
      widget.party?.pokemon3?.no,
      widget.party?.pokemon4?.no,
      widget.party?.pokemon5?.no,
      widget.party?.pokemon6?.no,
    ];

    if (pokemons.isEmpty) {
      lists = Center(
        child: Text('ポケモンが登録されていません。'),
      );
    }
    else {
      if (isEditMode) {
        lists = ListView(
          children: [
            for (int i = 0; i < pokemons.length; i++)
              PokemonTile(
                pokemons[i], theme, pokeData,
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
            for (var pokemon in pokemons)
              PokemonTile(
                pokemon,
                theme,
                pokeData,
                enabled: !partyPokemonsNo.contains(pokemon.no),
                leading: Icon(Icons.catching_pokemon),
                onLongPress: !widget.selectMode ? () => widget.onAdd(pokemon, false) : null,
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
