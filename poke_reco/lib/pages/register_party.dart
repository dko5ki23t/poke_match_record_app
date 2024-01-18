import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_widgets/pokemon_item_input_row.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPartyPage extends StatefulWidget {
  RegisterPartyPage({
    Key? key,
    required this.onFinish,
    required this.onSelectPokemon,
    required this.party,
    required this.isNew,
    required this.isEditPokemon,
    required this.onEditPokemon,
    this.phaseState,
  }) : super(key: key);

  final void Function() onFinish;
  final Future<Pokemon?> Function(Party party, int selectingPokemonIdx) onSelectPokemon;
  final Party party;
  final bool isNew;
  final bool isEditPokemon;
  final void Function(Pokemon pokemon, PokemonState pokemonState) onEditPokemon;
  final PhaseState? phaseState;

  @override
  RegisterPartyPageState createState() => RegisterPartyPageState();
}

class RegisterPartyPageState extends State<RegisterPartyPage> {
  final partyNameController = TextEditingController();
  final pokemonController = List.generate(6, (i) => TextEditingController());
  final itemController = List.generate(6, (i) => TextEditingController());

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    void onBack () {
      bool showAlert = false;
      if (widget.party.pokemons[0]!.no != 0) {
        if (widget.party.id == 0) {
          showAlert = true;
        }
        else if (widget.party.isDiff(pokeData.parties[widget.party.id]!)) {
          showAlert = true;
        }
      }
      if (showAlert) {
        showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialog(
              null,
              () {
                Navigator.pop(context);
                appState.onTabChange = (func) => func();
              },
            );
          }
        );
      }
      else {
        Navigator.pop(context);
        appState.onTabChange = (func) => func();
      }
    }

    void onTabChange (void Function() func) {
      if (widget.party.pokemons[0]!.no != 0) {
        showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialog(
              null,
              () => func(),
            );
          }
        );
      }
      else {
        func();
      }
    }

    if (firstBuild) {
      appState.onBackKeyPushed = onBack;
      appState.onTabChange = onTabChange;
      partyNameController.text = widget.party.name;
      for (final controller in pokemonController) {
        controller.text = loc.partiesTabSelectPokemon;
      }
      firstBuild = false;
    }

    for (int i = 0; i < 6; i++) {
      final pokemon = widget.party.pokemons[i];
      if (pokemon != null && pokemon.id != 0) {
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
      await pokeData.addParty(widget.party, widget.isNew);
      widget.onFinish();
    }

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          onBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.isNew ? Text(loc.partiesTabRegisterParty) : Text(loc.partiesTabEditParty),
          actions: [
            TextButton(
              onPressed: ((widget.isEditPokemon && widget.party.name != '') || widget.party.isValid) ? () => onComplete() : null,
              child: Text(loc.registerSave),
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
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.partiesTabPartyName,
                          ),
                          onChanged: (value) {
                            setState(() {
                              widget.party.name = value;
                            });
                          },
                          maxLength: 20,
                          controller: partyNameController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  for (int i = 0; i < 6; i++)
                    PokemonItemInputRow(
                      '${loc.commonPokemon}${i+1}',
                      pokemonController[i],
                      () async {
                        // キーボードが出ないようにする
                        FocusScope.of(context).requestFocus(FocusNode());
                        var pokemon = await widget.onSelectPokemon(widget.party, i+1);
                        if (pokemon != null) {
                          widget.party.pokemons[i] = pokemon;
                          pokemonController[i].text =
                            pokemon.nickname == '' ?
                              pokemon.name :
                              '${pokemon.nickname}/${pokemon.name}';
                          if (pokeData.pokeBase[pokemon.no]!.fixedItemID != 0) {
                            widget.party.items[i] = pokeData.items[pokeData.pokeBase[pokemon.no]!.fixedItemID]!;
                            itemController[i].text = widget.party.items[i]!.displayName;
                          }
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
                            pokemonController[j].text = loc.partiesTabSelectPokemon;
                            widget.party.pokemons[j] = j == 0 ?
                              Pokemon() : null;
                            itemController[j].text = '';
                            widget.party.items[j] = null;
                            break;
                          }
                        }
                        setState(() {});
                      },
                      '${loc.commonItem}${i+1}',
                      itemController[i],
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
                      widget.party.pokemons[i] != null ? widget.party.pokemons[i]!.no : 0,
                      widget.party.items[i]?.id,
                      theme,
                      widget.isEditPokemon,
                      () {
                        if (widget.isEditPokemon && widget.party.pokemons[i] != null && widget.phaseState != null) {
                          widget.onEditPokemon(widget.party.pokemons[i]!, widget.phaseState!.getPokemonStates(PlayerType.opponent)[i]);
                        }
                      },
                      enabledPokemon: i == 0 || (widget.party.pokemons[i-1] != null && (widget.isEditPokemon || widget.party.pokemons[i-1]!.isValid)),
                      enabledItem: widget.party.pokemons[i] != null && pokeData.pokeBase[widget.party.pokemons[i]!.no]!.fixedItemID == 0,
                      showNetworkImage: pokeData.getPokeAPI
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