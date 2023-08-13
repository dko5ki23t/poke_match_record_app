import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PokemonsPage extends StatefulWidget {
  const PokemonsPage({
    Key? key,
    required this.onAdd,
  }) : super(key: key);
  final void Function(Pokemon myPokemon, bool isNew) onAdd;

  @override
  PokemonsPageState createState() => PokemonsPageState();
}

class PokemonsPageState extends State<PokemonsPage> {
  bool isEditMode = false;
  List<bool>? checkList;

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
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;

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
              ListTile(
                leading: Checkbox(
                  value: checkList![i],
                  onChanged: (isCheck) {
                    setState(() {
                      checkList![i] = isCheck ?? false;
                    });
                  },
                ),
                title: Text(
                  pokemons[i].nickname == '' ?
                  pokemons[i].name :
                  pokemons[i].nickname
                ),
                subtitle: Text(pokemons[i].name),
                trailing: TextButton(
                  onPressed: () => widget.onAdd(pokemons[i], false),
                  child: Icon(Icons.edit),
                ),
              ),
          ],
        );
      }
      else {
        lists = ListView(
          children: [
            for (var pokemon in pokemons)
              ListTile(
                leading: Icon(Icons.catching_pokemon),
                title: Text(
                  pokemon.nickname == '' ?
                  pokemon.name :
                  pokemon.nickname
                ),
                subtitle: Text(pokemon.name),
                onLongPress: () => widget.onAdd(pokemon, false),
              ),
          ],
        );
      }
    }

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.outline,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ポケモン一覧'),
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
                  onPressed: (pokemons.isNotEmpty) ? () => setState(() => isEditMode = true) : null,
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
    );
  }
}
