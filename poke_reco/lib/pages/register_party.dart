import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/pokemon_item_input_row.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';

class RegisterPartyPage extends StatefulWidget {
  RegisterPartyPage({
    Key? key,
    required this.onFinish,
    required this.onSelectPokemon,
    required this.party,
    required this.isNew,
  }) : super(key: key);

  final void Function() onFinish;
  final Future<Pokemon?> Function(Party party) onSelectPokemon;
  final Party party;
  final bool isNew;

  @override
  RegisterPartyPageState createState() => RegisterPartyPageState();
}

class RegisterPartyPageState extends State<RegisterPartyPage> {
  final partyNameController = TextEditingController();
  final pokemonController = List.generate(6, (i) => TextEditingController(text: 'ポケモン選択'));
  final itemController = List.generate(6, (i) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        parties.add(widget.party);
        widget.party.id = parties.length;
      }
      pokeData.addParty(widget.party);
      widget.onFinish();
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? Text('パーティ登録') : Text('パーティ編集'),
        actions: [
          TextButton(
            onPressed: (widget.party.isValid) ? () => onComplete() : null,
            child: Text('完了'),
          ),
        ],
      ),
      body: ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
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
                      child:TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'パーティ名'
                        ),
                        onChanged: (value) {
                          widget.party.name = value;
                          widget.party.updateIsValid();
                          setState(() {});
                        },
                        maxLength: 5,
                        controller: partyNameController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                for (int i = 0; i < 6; i++)
                  PokemonItemInputRow(
                    'ポケモン${i+1}',
                    pokemonController[i],
                    () async {
                      // キーボードが出ないようにする
                      FocusScope.of(context).requestFocus(FocusNode());
                      var pokemon = await widget.onSelectPokemon(widget.party);
                      if (pokemon != null) {
                        widget.party.pokemons[i] = pokemon;
                        widget.party.updateIsValid();
                        pokemonController[i].text =
                          pokemon.nickname == '' ?
                            '${pokemon.name}/${pokemon.name}' :
                            '${pokemon.nickname}/${pokemon.name}';
                      }
                    },
                    'もちもの${i+1}',
                    itemController[i],
                    pokeData,
                    [for (int j = 0; j < 6; j++) i != j ? widget.party.items[j] : null],
                    (suggestion) {
                      itemController[i].text = suggestion.displayName;
                      widget.party.items[i] = suggestion;
                    },
                    enabledPokemon: i != 0 ? widget.party.pokemons[i-1] != null && widget.party.pokemons[i-1]!.isValid : true,
                    enabledItem: widget.party.pokemons[i] != null,
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