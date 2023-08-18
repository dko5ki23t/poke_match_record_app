import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_spinbox/material.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/pokemon_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class RegisterPartyPage extends StatefulWidget {
  RegisterPartyPage({
    Key? key,
    required this.onFinish,
    required this.party,
    required this.isNew,
  }) : super(key: key);

  final void Function() onFinish;
  final Party party;
  final bool isNew;

  @override
  RegisterPartyPageState createState() => RegisterPartyPageState();
}

class RegisterPartyPageState extends State<RegisterPartyPage> {
  // 引用：https://417.run/pg/flutter-dart/hiragana-to-katakana/
  static toKatakana(String str) {
    return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
  }

  static pingpongTextEditingController(TextEditingController controller) {
    if (controller.text == 'ping') {
      controller.text = 'pong';
    }
    else {
      controller.text = 'ping';
    }
  }

  final partyNameController = TextEditingController();
  final item1Controller = TextEditingController();
  final item2Controller = TextEditingController();
  final item3Controller = TextEditingController();
  final item4Controller = TextEditingController();
  final item5Controller = TextEditingController();
  final item6Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    var pokemons = appState.pokemons;
    final theme = Theme.of(context);

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        parties.add(widget.party);
      }
      pokeData.addParty(widget.party, parties.length);
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
                Row(  // ポケモン1, もちもの1
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン1'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon1 = pokemons[value - 1];
                          widget.party.updateIsValid();
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item1Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの1'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item1Controller.text = suggestion.displayName;
                          widget.party.item1 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ポケモン2, もちもの2
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン2'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon2 = pokemons[value - 1];
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item2Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの2'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item2Controller.text = suggestion.displayName;
                          widget.party.item2 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ポケモン3, もちもの3
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン3'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon3 = pokemons[value - 1];
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item3Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの3'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item3Controller.text = suggestion.displayName;
                          widget.party.item3 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ポケモン4, もちもの4
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン4'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon4 = pokemons[value - 1];
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item4Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの4'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item4Controller.text = suggestion.displayName;
                          widget.party.item4 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ポケモン5, もちもの5
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン5'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon5 = pokemons[value - 1];
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item5Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの5'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item5Controller.text = suggestion.displayName;
                          widget.party.item5 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ポケモン6, もちもの6
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン6'
                        ),
                        items: <DropdownMenuItem>[
                          for (final e in pokemons)
                            DropdownMenuItem(
                              value: e.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                              child: PokemonTile(e, theme, pokeData,),
                            ),
                        ],
                        onChanged: (value) {
                          widget.party.pokemon6 = pokemons[value - 1];
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: item6Controller,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'もちもの6'
                          ),
                        ),
                        autoFlipDirection: true,
                        suggestionsCallback: (pattern) async {
                          List<Item> matches = [];
                          matches.addAll(pokeData.items.values);
                          matches.retainWhere((s){
                            return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                          });
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          item6Controller.text = suggestion.displayName;
                          widget.party.item6 = suggestion;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}