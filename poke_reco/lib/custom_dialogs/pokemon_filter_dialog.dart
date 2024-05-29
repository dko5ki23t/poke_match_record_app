import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/tool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PokemonFilterDialog extends StatefulWidget {
  final Future<void> Function(
      List<Owner> ownerFilter,
      List<int> noFilter,
      List<PokeType> typeFilter,
      List<PokeType> teraTypeFilter,
      List<int> moveFilter,
      List<int> sexFilter,
      List<int> abilityFilter,
      List<int> natureFilter) onOK;
  final PokeDB pokeData;
  final List<Owner> ownerFilter;
  final List<int> noFilter;
  final List<PokeType> typeFilter;
  final List<PokeType> teraTypeFilter;
  final List<int> moveFilter;
  final List<int> sexFilter;
  final List<int> abilityFilter;
  final List<int> natureFilter;

  const PokemonFilterDialog(
      this.pokeData,
      this.ownerFilter,
      this.noFilter,
      this.typeFilter,
      this.teraTypeFilter,
      this.moveFilter,
      this.sexFilter,
      this.abilityFilter,
      this.natureFilter,
      this.onOK,
      {Key? key})
      : super(key: key);

  @override
  PokemonFilterDialogState createState() => PokemonFilterDialogState();
}

class PokemonFilterDialogState extends State<PokemonFilterDialog> {
  bool ownerExpanded = true;
  bool pokemonExpanded = true;
  bool typeExpanded = true;
  bool teraTypeExpanded = true;
  bool moveExpanded = true;
  bool sexExpanded = true;
  bool abilityExpanded = true;
  bool natureExpanded = true;
  List<Owner> ownerFilter = [];
  List<int> noFilter = [];
  List<PokeType> typeFilter = [];
  List<PokeType> teraTypeFilter = [];
  List<int> moveFilter = [];
  List<int> sexFilter = [];
  List<int> abilityFilter = [];
  List<int> natureFilter = [];
  TextEditingController pokemonController = TextEditingController();
  TextEditingController moveController = TextEditingController();
  TextEditingController abilityController = TextEditingController();
  TextEditingController natureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ownerFilter = [...widget.ownerFilter];
    noFilter = [...widget.noFilter];
    typeFilter = [...widget.typeFilter];
    teraTypeFilter = [...widget.teraTypeFilter];
    moveFilter = [...widget.moveFilter];
    sexFilter = [...widget.sexFilter];
    abilityFilter = [...widget.abilityFilter];
    natureFilter = [...widget.natureFilter];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                    title: Text(loc.filterDialogOwnPokemon),
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
                    title: Text(loc.filterDialogOpponentPokemon),
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
                pokemonExpanded = !pokemonExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.filterDialogPokemonName),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: pokemonExpanded
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
            for (var no in noFilter)
              pokemonExpanded
                  ? ListTile(
                      title: Text(widget.pokeData.pokeBase[no]!.name),
                      leading: Checkbox(
                        value: noFilter.contains(no),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              noFilter.add(no);
                            } else {
                              noFilter.remove(no);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            pokemonExpanded
                ? ListTile(
                    title: AppBaseTypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokemonController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.filterDialogAddPokemon,
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          borderRadius: BorderRadius.circular(8)),
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
                        pokemonController.text = '';
                        noFilter.add(suggestion.no);
                        setState(() {});
                      },
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () => setState(() {
                typeExpanded = !typeExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonType),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: typeExpanded
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
            for (final type in widget.pokeData.types)
              typeExpanded
                  ? ListTile(
                      title: Row(
                        children: [type.displayIcon, Text(type.displayName)],
                      ),
                      leading: Checkbox(
                        value: typeFilter.contains(type),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              typeFilter.add(type);
                            } else {
                              typeFilter.remove(type);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            GestureDetector(
              onTap: () => setState(() {
                teraTypeExpanded = !teraTypeExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonTeraType),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: teraTypeExpanded
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
            for (final type in widget.pokeData.teraTypes)
              teraTypeExpanded
                  ? ListTile(
                      title: Row(
                        children: [type.displayIcon, Text(type.displayName)],
                      ),
                      leading: Checkbox(
                        value: teraTypeFilter.contains(type),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              teraTypeFilter.add(type);
                            } else {
                              teraTypeFilter.remove(type);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            GestureDetector(
              onTap: () => setState(() {
                moveExpanded = !moveExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonMove),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: moveExpanded
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
            for (var moveID in moveFilter)
              moveExpanded
                  ? ListTile(
                      title: Text(widget.pokeData.moves[moveID]!.displayName),
                      leading: Checkbox(
                        value: moveFilter.contains(moveID),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              moveFilter.add(moveID);
                            } else {
                              moveFilter.remove(moveID);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            moveExpanded
                ? ListTile(
                    title: AppBaseTypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: moveController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.filterDialogAddMove,
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Move> matches = [];
                        matches.addAll(widget.pokeData.moves.values);
                        matches.removeWhere((element) => element.id == 0);
                        matches.retainWhere((s) {
                          return toKatakana50(s.displayName.toLowerCase())
                              .contains(toKatakana50(pattern.toLowerCase()));
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
                  )
                : Container(),
            GestureDetector(
              onTap: () => setState(() {
                sexExpanded = !sexExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonGender),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: sexExpanded
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
            for (var type in Sex.values)
              sexExpanded
                  ? ListTile(
                      title: type.displayIcon,
                      leading: Checkbox(
                        value: sexFilter.contains(type.id),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              sexFilter.add(type.id);
                            } else {
                              sexFilter.remove(type.id);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            GestureDetector(
              onTap: () => setState(() {
                abilityExpanded = !abilityExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonAbility),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: abilityExpanded
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
            for (var abilityID in abilityFilter)
              abilityExpanded
                  ? ListTile(
                      title: Text(
                          widget.pokeData.abilities[abilityID]!.displayName),
                      leading: Checkbox(
                        value: abilityFilter.contains(abilityID),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              abilityFilter.add(abilityID);
                            } else {
                              abilityFilter.remove(abilityID);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            abilityExpanded
                ? ListTile(
                    title: AppBaseTypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: abilityController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.filterDialogAddAbility,
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Ability> matches = [];
                        matches.addAll(widget.pokeData.abilities.values);
                        matches.removeWhere((element) => element.id == 0);
                        matches.retainWhere((s) {
                          return toKatakana50(s.displayName.toLowerCase())
                              .contains(toKatakana50(pattern.toLowerCase()));
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
                  )
                : Container(),
            GestureDetector(
              onTap: () => setState(() {
                natureExpanded = !natureExpanded;
              }),
              child: Stack(
                children: [
                  Center(
                    child: Text(loc.commonNature),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: natureExpanded
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
            for (var natureID in natureFilter)
              natureExpanded
                  ? ListTile(
                      title:
                          Text(widget.pokeData.natures[natureID]!.displayName),
                      leading: Checkbox(
                        value: natureFilter.contains(natureID),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            if (value == true) {
                              natureFilter.add(natureID);
                            } else {
                              natureFilter.remove(natureID);
                            }
                          });
                        },
                      ),
                    )
                  : Container(),
            natureExpanded
                ? ListTile(
                    title: AppBaseTypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: natureController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.filterDialogAddNature,
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Nature> matches = [];
                        matches.addAll(widget.pokeData.natures.values);
                        matches.removeWhere((element) => element.id == 0);
                        matches.retainWhere((s) {
                          return toKatakana50(s.displayName.toLowerCase())
                              .contains(toKatakana50(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.displayName),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        natureController.text = '';
                        natureFilter.add(suggestion.id);
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
            setState(() {
              ownerFilter = [Owner.mine];
              noFilter = [];
              typeFilter = PokeType.values;
              typeFilter.remove(PokeType.stellar);
              teraTypeFilter = PokeType.values;
              moveFilter = [];
              sexFilter = [for (var sex in Sex.values) sex.id];
              abilityFilter = [];
              natureFilter = [];
            });
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            Navigator.pop(context);
            await widget.onOK(
              ownerFilter,
              noFilter,
              typeFilter,
              teraTypeFilter,
              moveFilter,
              sexFilter,
              abilityFilter,
              natureFilter,
            );
          },
        ),
      ],
    );
  }
}
