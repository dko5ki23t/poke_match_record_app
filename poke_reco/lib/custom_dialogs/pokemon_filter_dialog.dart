import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';

class PokemonFilterDialog extends StatefulWidget {
  final Future<void> Function (
    List<Owner> ownerFilter,
    List<int> noFilter,
    List<int> typeFilter,
    List<int> teraTypeFilter,
    List<int> moveFilter,
    List<int> sexFilter,
    List<int> abilityFilter,
    List<int> temperFilter) onOK;
  final PokeDB pokeData;
  final List<Owner> ownerFilter;
  final List<int> noFilter;
  final List<int> typeFilter;
  final List<int> teraTypeFilter;
  final List<int> moveFilter;
  final List<int> sexFilter;
  final List<int> abilityFilter;
  final List<int> temperFilter;

  const PokemonFilterDialog(
    this.pokeData,
    this.ownerFilter,
    this.noFilter,
    this.typeFilter,
    this.teraTypeFilter,
    this.moveFilter,
    this.sexFilter,
    this.abilityFilter,
    this.temperFilter,
    this.onOK,
    {Key? key}) : super(key: key);

  @override
  PokemonFilterDialogState createState() => PokemonFilterDialogState();
}

class PokemonFilterDialogState extends State<PokemonFilterDialog> {
  bool isFirstBuild = true;
  bool ownerExpanded = true;
  bool pokemonExpanded = true;
  bool typeExpanded = true;
  bool teraTypeExpanded = true;
  bool moveExpanded = true;
  bool sexExpanded = true;
  bool abilityExpanded = true;
  bool temperExpanded = true;
  List<Owner> ownerFilter = [];
  List<int> noFilter = [];
  List<int> typeFilter = [];
  List<int> teraTypeFilter = [];
  List<int> moveFilter = [];
  List<int> sexFilter = [];
  List<int> abilityFilter = [];
  List<int> temperFilter = [];
  TextEditingController pokemonController = TextEditingController();
  TextEditingController moveController = TextEditingController();
  TextEditingController abilityController = TextEditingController();
  TextEditingController temperController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      ownerFilter = [...widget.ownerFilter];
      noFilter = [...widget.noFilter];
      typeFilter = [...widget.typeFilter];
      teraTypeFilter = [...widget.teraTypeFilter];
      moveFilter = [...widget.moveFilter];
      sexFilter = [...widget.sexFilter];
      abilityFilter = [...widget.abilityFilter];
      temperFilter = [...widget.temperFilter];
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text('フィルタ'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                ownerExpanded = !ownerExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('作成者'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ownerExpanded ?
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
            ownerExpanded ?
            ListTile(
              title: Text('自分のポケモン'),
              leading: Checkbox(
                value: ownerFilter.contains(Owner.mine),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      ownerFilter.add(Owner.mine);
                    }
                    else {
                      ownerFilter.remove(Owner.mine);
                    }
                  });
                },
              ),
            ) : Container(),
            ownerExpanded ?
            ListTile(
              title: Text('対戦相手のポケモン'),
              leading: Checkbox(
                value: ownerFilter.contains(Owner.fromBattle),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      ownerFilter.add(Owner.fromBattle);
                    }
                    else {
                      ownerFilter.remove(Owner.fromBattle);
                    }
                  });
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                pokemonExpanded = !pokemonExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('名前'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: pokemonExpanded ?
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
            for (var no in noFilter)
              pokemonExpanded ?
              ListTile(
                title: Text(widget.pokeData.pokeBase[no]!.name),
                leading: Checkbox(
                  value: noFilter.contains(no),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        noFilter.add(no);
                      }
                      else {
                        noFilter.remove(no);
                      }
                    });
                  },
                ),
              ) : Container(),
            pokemonExpanded ?
            ListTile(
              title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: pokemonController,
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
                  pokemonController.text = '';
                  noFilter.add(suggestion.no);
                  setState(() {});
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                typeExpanded = !typeExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('タイプ'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: typeExpanded ?
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
            for (final type in widget.pokeData.types)
            typeExpanded ?
            ListTile(
              title: Row(
                children: [
                  type.displayIcon,
                  Text(type.displayName)
                ],
              ),
              leading: Checkbox(
                value: typeFilter.contains(type.id),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      typeFilter.add(type.id);
                    }
                    else {
                      typeFilter.remove(type.id);
                    }
                  });
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                teraTypeExpanded = !teraTypeExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('テラスタイプ'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: teraTypeExpanded ?
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
            for (final type in widget.pokeData.types)
            teraTypeExpanded ?
            ListTile(
              title: Row(
                children: [
                  type.displayIcon,
                  Text(type.displayName)
                ],
              ),
              leading: Checkbox(
                value: teraTypeFilter.contains(type.id),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      teraTypeFilter.add(type.id);
                    }
                    else {
                      teraTypeFilter.remove(type.id);
                    }
                  });
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                moveExpanded = !moveExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('わざ'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: moveExpanded ?
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
            for (var moveID in moveFilter)
              moveExpanded ?
              ListTile(
                title: Text(widget.pokeData.moves[moveID]!.displayName),
                leading: Checkbox(
                  value: moveFilter.contains(moveID),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        moveFilter.add(moveID);
                      }
                      else {
                        moveFilter.remove(moveID);
                      }
                    });
                  },
                ),
              ) : Container(),
            moveExpanded ?
            ListTile(
              title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: moveController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ追加',
                  ),
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<Move> matches = [];
                  matches.addAll(widget.pokeData.moves.values);
                  matches.removeWhere((element) => element.id == 0);
                  matches.retainWhere((s){
                    return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                  });
                  return matches;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.displayName),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  moveController.text = '';
                  moveFilter.add(suggestion.id);
                  setState(() {});
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                sexExpanded = !sexExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('せいべつ'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: sexExpanded ?
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
            for (var type in Sex.values)
              sexExpanded ?
              ListTile(
                title: type.displayIcon,
                leading: Checkbox(
                  value: sexFilter.contains(type.id),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        sexFilter.add(type.id);
                      }
                      else {
                        sexFilter.remove(type.id);
                      }
                    });
                  },
                ),
              ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                abilityExpanded = !abilityExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('とくせい'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: abilityExpanded ?
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
            for (var abilityID in abilityFilter)
              abilityExpanded ?
              ListTile(
                title: Text(widget.pokeData.abilities[abilityID]!.displayName),
                leading: Checkbox(
                  value: abilityFilter.contains(abilityID),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        abilityFilter.add(abilityID);
                      }
                      else {
                        abilityFilter.remove(abilityID);
                      }
                    });
                  },
                ),
              ) : Container(),
            abilityExpanded ?
            ListTile(
              title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: abilityController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくせい追加',
                  ),
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<Ability> matches = [];
                  matches.addAll(widget.pokeData.abilities.values);
                  matches.removeWhere((element) => element.id == 0);
                  matches.retainWhere((s){
                    return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                  });
                  return matches;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.displayName),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  abilityController.text = '';
                  abilityFilter.add(suggestion.id);
                  setState(() {});
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                temperExpanded = !temperExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text('せいかく'),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: temperExpanded ?
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
            for (var temperID in temperFilter)
              temperExpanded ?
              ListTile(
                title: Text(widget.pokeData.tempers[temperID]!.displayName),
                leading: Checkbox(
                  value: temperFilter.contains(temperID),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        temperFilter.add(temperID);
                      }
                      else {
                        temperFilter.remove(temperID);
                      }
                    });
                  },
                ),
              ) : Container(),
            temperExpanded ?
            ListTile(
              title: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: temperController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'せいかく追加',
                  ),
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<Temper> matches = [];
                  matches.addAll(widget.pokeData.tempers.values);
                  matches.removeWhere((element) => element.id == 0);
                  matches.retainWhere((s){
                    return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                  });
                  return matches;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.displayName),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  temperController.text = '';
                  temperFilter.add(suggestion.id);
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
              await widget.onOK(
                ownerFilter, noFilter, typeFilter, teraTypeFilter,
                moveFilter, sexFilter, abilityFilter,
                temperFilter,
              );
            },
          ),
        ],
    );
  }
}