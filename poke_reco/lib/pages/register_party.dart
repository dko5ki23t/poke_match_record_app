import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialog/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_widgets/pokemon_item_input_row.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
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
    void onBack () {
      if (widget.party.pokemon1.no != 0) {
        showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialog(
              'パーティ',
              () {
                Navigator.pop(context);
              },
            );
          }
        );
      }
      else {
        Navigator.pop(context);
      }
    }
    appState.onBackKeyPushed = onBack;

    partyNameController.text = widget.party.name;
    for (int i = 0; i < 6; i++) {
      final pokemon = widget.party.pokemons[i];
      if (pokemon != null && pokemon.isValid) {
        pokemonController[i].text =
          pokemon.nickname == '' ?
            '${pokemon.name}/${pokemon.name}' :
            '${pokemon.nickname}/${pokemon.name}';
      }

      final item = widget.party.items[i];
      if (item != null) {
        itemController[i].text = item.displayName;
      }
    }

    void onComplete() async {
      if (widget.isNew) {
        parties.add(widget.party);
        widget.party.id = pokeData.getUniquePartyID();
      }
      else {
        final index = parties.indexWhere((element) => element.id == widget.party.id);
        parties[index] = widget.party;
      }
      await pokeData.addParty(widget.party);
      widget.onFinish();
    }

    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
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
                            //setState(() {});
                          },
                          onTapOutside: (event) {
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
                          pokemonController[i].text =
                            pokemon.nickname == '' ?
                              pokemon.name :
                              '${pokemon.nickname}/${pokemon.name}';
                        }
                      },
                      widget.party.pokemons[i] != null && widget.party.pokemons[i]!.no != 0,
                      () {
                        for (int j = i; j < 6; j++) {
                          if (j+1 < 6 && widget.party.pokemons[j+1] != null) {
                            pokemonController[j].text = widget.party.pokemons[j+1]!.nickname == '' ?
                              widget.party.pokemons[j+1]!.name :
                              '${widget.party.pokemons[j+1]!.nickname}/${widget.party.pokemons[j+1]!.name}';
                            widget.party.pokemons[j] = widget.party.pokemons[j+1];
                            itemController[j].text = widget.party.items[j+1] != null ?
                              widget.party.items[j+1]!.displayName : '';
                            widget.party.items[j] = widget.party.items[j+1];
                          }
                          else {
                            pokemonController[j].text = 'ポケモン選択';
                            widget.party.pokemons[j] = j == 0 ?
                              Pokemon() : null;
                            itemController[j].text = '';
                            widget.party.items[j] = null;
                            break; 
                          }
                        }
                        setState(() {});
                      },
                      'もちもの${i+1}',
                      itemController[i],
                      pokeData,
                      [for (int j = 0; j < 6; j++) i != j ? widget.party.items[j] : null, pokeData.items[0]],
                      (suggestion) {
                        itemController[i].text = suggestion.displayName;
                        widget.party.items[i] = suggestion;
                      },
                      () {
                        itemController[i].text = '';
                        widget.party.items[i] = null;
                        setState(() {});
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
      ),
    );
  }
}