import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

class PartyFilterDialog extends StatefulWidget {
  final Future<void> Function (
    int winRateMinFilter,
    int winRateMaxFilter,
    List<int> pokemonIDFilter) onOK;
  final PokeDB pokeData;
  final int winRateMinFilter;
  final int winRateMaxFilter;
  final List<int> pokemonNoFilter;

  const PartyFilterDialog(
    this.pokeData,
    this.winRateMinFilter,
    this.winRateMaxFilter,
    this.pokemonNoFilter,
    this.onOK,
    {Key? key}) : super(key: key);

  @override
  PartyFilterDialogState createState() => PartyFilterDialogState();
}

class PartyFilterDialogState extends State<PartyFilterDialog> {
  bool isFirstBuild = true;
  bool winRateExpanded = true;
  bool pokemonNoExpanded = true;
  int winRateMinFilter = 0;
  int winRateMaxFilter = 100;
  List<int> pokemonNoFilter = [];
  TextEditingController winRateMinController = TextEditingController();
  TextEditingController winRateMaxController = TextEditingController();
  TextEditingController pokemonNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      winRateMinFilter = widget.winRateMinFilter;
      winRateMaxFilter = widget.winRateMaxFilter;
      pokemonNoFilter = [...widget.pokemonNoFilter];
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('フィルタ'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                winRateExpanded = !winRateExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('勝率'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: winRateExpanded ?
                      Icon(Icons.keyboard_arrow_up) :
                      Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            winRateExpanded ?
            ListTile(
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
                  Text('%～'),
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
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                pokemonNoExpanded = !pokemonNoExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('ポケモン'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: pokemonNoExpanded ?
                      Icon(Icons.keyboard_arrow_up) :
                      Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            for (var pokemonNo in pokemonNoFilter)
              pokemonNoExpanded ?
              ListTile(
                title: Text(widget.pokeData.pokeBase[pokemonNo]!.name),
                leading: Checkbox(
                  value: pokemonNoFilter.contains(pokemonNo),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        pokemonNoFilter.add(pokemonNo);
                      }
                      else {
                        pokemonNoFilter.remove(pokemonNo);
                      }
                    });
                  },
                ),
              ) : Container(),
            pokemonNoExpanded ?
            ListTile(
              title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: pokemonNoController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ポケモン追加',
                  ),
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<PokeBase> matches = [];
                  matches.addAll(widget.pokeData.pokeBase.values);
                  matches.removeWhere((element) => element.no == 0);
                  matches.retainWhere((s){
                    return toKatakana50(s.name.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
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
            ) : Container(),
          ],
        ),
      ),
      actions:
        <Widget>[
          GestureDetector(
            child: Text('キャンセル'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: Text('OK'),
            onTap: () async {
              Navigator.pop(context);
              await widget.onOK(winRateMinFilter, winRateMaxFilter, pokemonNoFilter,);
            },
          ),
        ],
    );
  }
}