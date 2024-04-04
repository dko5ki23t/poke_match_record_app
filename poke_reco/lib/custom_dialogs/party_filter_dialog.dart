import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PartyFilterDialog extends StatefulWidget {
  final Future<void> Function(List<Owner> ownerFilter, int winRateMinFilter,
      int winRateMaxFilter, List<int> pokemonIDFilter) onOK;
  final PokeDB pokeData;
  final List<Owner> ownerFilter;
  final int winRateMinFilter;
  final int winRateMaxFilter;
  final List<int> pokemonNoFilter;

  const PartyFilterDialog(
      this.pokeData,
      this.ownerFilter,
      this.winRateMinFilter,
      this.winRateMaxFilter,
      this.pokemonNoFilter,
      this.onOK,
      {Key? key})
      : super(key: key);

  @override
  PartyFilterDialogState createState() => PartyFilterDialogState();
}

class PartyFilterDialogState extends State<PartyFilterDialog> {
  bool ownerExpanded = true;
  bool winRateExpanded = true;
  bool pokemonNoExpanded = true;
  List<Owner> ownerFilter = [];
  int winRateMinFilter = 0;
  int winRateMaxFilter = 100;
  List<int> pokemonNoFilter = [];
  TextEditingController winRateMinController = TextEditingController();
  TextEditingController winRateMaxController = TextEditingController();
  TextEditingController pokemonNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ownerFilter = [...widget.ownerFilter];
    winRateMinFilter = widget.winRateMinFilter;
    winRateMaxFilter = widget.winRateMaxFilter;
    pokemonNoFilter = [...widget.pokemonNoFilter];
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.commonFilter),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                ownerExpanded = !ownerExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.filterDialogProducer),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ownerExpanded
                        ? Icon(Icons.keyboard_arrow_up)
                        : Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            ownerExpanded
                ? ListTile(
                    title: Text(loc.filterDialogOwnParty),
                    leading: Checkbox(
                      value: ownerFilter.contains(Owner.mine),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == true) {
                            ownerFilter.add(Owner.mine);
                          } else {
                            ownerFilter.remove(Owner.mine);
                          }
                        });
                      },
                    ),
                  )
                : Container(),
            ownerExpanded
                ? ListTile(
                    title: Text(loc.filterDialogOpponentParty),
                    leading: Checkbox(
                      value: ownerFilter.contains(Owner.fromBattle),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          if (value == true) {
                            ownerFilter.add(Owner.fromBattle);
                          } else {
                            ownerFilter.remove(Owner.fromBattle);
                          }
                        });
                      },
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () => setState(() {
                winRateExpanded = !winRateExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.filterDialogWinningRate),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: winRateExpanded
                        ? Icon(Icons.keyboard_arrow_up)
                        : Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            winRateExpanded
                ? ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: NumberInputWithIncrementDecrement(
                            controller: winRateMinController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            min: 0,
                            max: 100,
                            initialValue: winRateMinFilter,
                            onIncrement: (val) => winRateMinFilter = val as int,
                            onDecrement: (val) => winRateMinFilter = val as int,
                            onChanged: (val) => winRateMinFilter = val as int,
                          ),
                        ),
                        Text('% ~ '),
                        Expanded(
                          child: NumberInputWithIncrementDecrement(
                            controller: winRateMaxController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            min: 0,
                            max: 100,
                            initialValue: winRateMaxFilter,
                            onIncrement: (val) => winRateMaxFilter = val as int,
                            onDecrement: (val) => winRateMaxFilter = val as int,
                            onChanged: (val) => winRateMaxFilter = val as int,
                          ),
                        ),
                        Text('%'),
                      ],
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () => setState(() {
                pokemonNoExpanded = !pokemonNoExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonPokemon),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: pokemonNoExpanded
                        ? Icon(Icons.keyboard_arrow_up)
                        : Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            for (var pokemonNo in pokemonNoFilter)
              pokemonNoExpanded
                  ? ListTile(
                      title: Text(widget.pokeData.pokeBase[pokemonNo]!.name),
                      leading: Checkbox(
                        value: pokemonNoFilter.contains(pokemonNo),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              pokemonNoFilter.add(pokemonNo);
                            } else {
                              pokemonNoFilter.remove(pokemonNo);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            pokemonNoExpanded
                ? ListTile(
                    title: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokemonNoController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.filterDialogAddPokemon,
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(widget.pokeData.pokeBase.values);
                        matches.removeWhere((element) => element.no == 0);
                        matches.retainWhere((s) {
                          return toKatakana50(s.name.toLowerCase())
                              .contains(toKatakana50(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        pokemonNoController.text = '';
                        pokemonNoFilter.add(suggestion.no);
                        setState(() {});
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(loc.commonReset),
          onPressed: () {
            ownerFilter = [Owner.mine];
            winRateMinFilter = 0;
            winRateMaxFilter = 100;
            pokemonNoFilter = [];
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            Navigator.pop(context);
            await widget.onOK(
              ownerFilter,
              winRateMinFilter,
              winRateMaxFilter,
              pokemonNoFilter,
            );
          },
        ),
      ],
    );
  }
}
