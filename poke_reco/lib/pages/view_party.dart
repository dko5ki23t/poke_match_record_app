import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/custom_widgets/pokemon_item_view_row.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/party.dart';

class ViewPartyPage extends StatefulWidget {
  ViewPartyPage({
    Key? key,
    required this.onEdit,
    required this.onViewPokemon,
    required this.partyList,
    required this.listIndex,
  }) : super(key: key);

  final void Function(Party) onEdit;
  final void Function(List<Pokemon>, int) onViewPokemon;
  final List<Party> partyList;
  final int listIndex;

  @override
  ViewPartyPageState createState() => ViewPartyPageState();
}

class ViewPartyPageState extends State<ViewPartyPage> {
  final partyNameController = TextEditingController();
  final pokemonController = List.generate(6, (i) => TextEditingController(text: 'ポケモン選択'));
  final itemController = List.generate(6, (i) => TextEditingController());

  bool firstBuild = true;
  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    var party = widget.partyList[widget.listIndex];

    if (firstBuild) {
      listIndex = widget.listIndex;
      firstBuild = false;
    }
    else {
      party = widget.partyList[listIndex];
    }

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    partyNameController.text = party.name;

    for (int i = 0; i < 6; i++) {
      final pokemon = party.pokemons[i];
      if (pokemon != null && pokemon.id != 0) {
        pokemonController[i].text =
          pokemon.nickname == '' ?
            '${pokemon.name}/${pokemon.name}' :
            '${pokemon.nickname}/${pokemon.name}';
      }

      final item = party.items[i];
      if (item != null) {
        itemController[i].text = item.displayName;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        actions: [
          MyIconButton(
            onPressed: listIndex != 0 ? () => setState(() {
              listIndex--;
            }) : null,
            theme: theme,
            icon: Icon(Icons.arrow_upward),
            tooltip: '前へ',
          ),
          MyIconButton(
            onPressed: listIndex + 1 < widget.partyList.length ? () => setState(() {
              listIndex++;
            }) : null,
            theme: theme,
            icon: Icon(Icons.arrow_downward),
            tooltip: '次へ',
          ),
          MyIconButton(
            onPressed: () => widget.onEdit(party),
            theme: theme,
            icon: Icon(Icons.edit),
            tooltip: '編集',
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(  // パーティ名
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'パーティ名'
                        ),
                        maxLength: 20,
                        controller: partyNameController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                for (int i = 0; i < party.pokemonNum; i++)
                  PokemonItemViewRow(
                    'ポケモン${i+1}',
                    'もちもの${i+1}',
                    pokemonController[i],
                    itemController[i],
                    party.pokemons[i]!,
                    party.items[i],
                    theme,
                    () {
                      widget.onViewPokemon(
                        [for (int j = 0; j < party.pokemonNum; j++) party.pokemons[j]!],
                        i,
                      );
                    },
                    showNetworkImage: appState.getPokeAPI
                  ),
                  SizedBox(height: 10),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}