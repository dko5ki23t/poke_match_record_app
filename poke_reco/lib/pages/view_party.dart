import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/custom_widgets/pokemon_item_view_row.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewPartyPage extends StatefulWidget {
  ViewPartyPage({
    Key? key,
    required this.onEdit,
    required this.onViewPokemon,
    required this.partyIDList,
    required this.listIndex,
  }) : super(key: key);

  final void Function(Party) onEdit;
  final void Function(List<Pokemon>, int) onViewPokemon;
  final List<int> partyIDList; // IDで受け取ることで、編集画面でパーティ内容を変更してもbuildで更新できる
  final int listIndex;

  @override
  ViewPartyPageState createState() => ViewPartyPageState();
}

class ViewPartyPageState extends State<ViewPartyPage> {
  final partyNameController = TextEditingController();
  final pokemonController = List.generate(6, (i) => TextEditingController());
  final itemController = List.generate(6, (i) => TextEditingController());

  bool firstBuild = true;
  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    var party = PokeDB().parties[widget.partyIDList[widget.listIndex]]!;

    if (firstBuild) {
      for (final controller in pokemonController) {
        controller.text = loc.partiesTabSelectPokemon;
      }
      listIndex = widget.listIndex;
      firstBuild = false;
    } else {
      party = PokeDB().parties[widget.partyIDList[listIndex]]!;
    }

    //appState.onBackKeyPushed = () {};
    //appState.onTabChange = (func) => func();

    partyNameController.text = party.name;

    for (int i = 0; i < 6; i++) {
      final pokemon = party.pokemons[i];
      if (pokemon != null && pokemon.id != 0) {
        pokemonController[i].text = pokemon.nickname == ''
            ? '${pokemon.name}/${pokemon.name}'
            : '${pokemon.nickname}/${pokemon.name}';
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
            onPressed: listIndex != 0
                ? () => setState(() {
                      listIndex--;
                    })
                : null,
            theme: theme,
            icon: Icon(Icons.arrow_upward),
            tooltip: loc.viewToolTipPrev,
          ),
          MyIconButton(
            onPressed: listIndex + 1 < widget.partyIDList.length
                ? () => setState(() {
                      listIndex++;
                    })
                : null,
            theme: theme,
            icon: Icon(Icons.arrow_downward),
            tooltip: loc.viewToolTipNext,
          ),
          MyIconButton(
            onPressed: () => widget.onEdit(party.copy()),
            theme: theme,
            icon: Icon(Icons.edit),
            tooltip: loc.viewToolTipEdit,
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
                Row(
                  // パーティ名
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.partiesTabPartyName,
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
                      '${loc.commonPokemon}${i + 1}',
                      '${loc.commonItem}${i + 1}',
                      pokemonController[i],
                      itemController[i],
                      party.pokemons[i]!,
                      party.items[i],
                      theme, () {
                    widget.onViewPokemon(
                      [
                        for (int j = 0; j < party.pokemonNum; j++)
                          party.pokemons[j]!
                      ],
                      i,
                    );
                  }, showNetworkImage: PokeDB().getPokeAPI),
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
