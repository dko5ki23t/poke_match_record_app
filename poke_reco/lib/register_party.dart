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
  final pokemon1Controller = TextEditingController(text: 'ポケモン選択');
  final item1Controller = TextEditingController();
  final pokemon2Controller = TextEditingController(text: 'ポケモン選択');
  final item2Controller = TextEditingController();
  final pokemon3Controller = TextEditingController(text: 'ポケモン選択');
  final item3Controller = TextEditingController();
  final pokemon4Controller = TextEditingController(text: 'ポケモン選択');
  final item4Controller = TextEditingController();
  final pokemon5Controller = TextEditingController(text: 'ポケモン選択');
  final item5Controller = TextEditingController();
  final pokemon6Controller = TextEditingController(text: 'ポケモン選択');
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン1',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon1Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon1 = pokemon;
                            widget.party.updateIsValid();
                            pokemon1Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item2);
                          matches.remove(widget.party.item3);
                          matches.remove(widget.party.item4);
                          matches.remove(widget.party.item5);
                          matches.remove(widget.party.item6);
                          return matches;
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン2',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon2Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon2 = pokemon;
                            pokemon2Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item1);
                          matches.remove(widget.party.item3);
                          matches.remove(widget.party.item4);
                          matches.remove(widget.party.item5);
                          matches.remove(widget.party.item6);
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン3',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon3Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon3 = pokemon;
                            pokemon3Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item1);
                          matches.remove(widget.party.item2);
                          matches.remove(widget.party.item4);
                          matches.remove(widget.party.item5);
                          matches.remove(widget.party.item6);
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン4',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon4Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon4 = pokemon;
                            pokemon4Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item1);
                          matches.remove(widget.party.item2);
                          matches.remove(widget.party.item3);
                          matches.remove(widget.party.item5);
                          matches.remove(widget.party.item6);
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン5',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon5Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon5 = pokemon;
                            pokemon5Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item1);
                          matches.remove(widget.party.item2);
                          matches.remove(widget.party.item3);
                          matches.remove(widget.party.item4);
                          matches.remove(widget.party.item6);
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
                      flex: 6,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン6',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: pokemon6Controller,
                        onTap: () async {
                          // キーボードが出ないようにする
                          FocusScope.of(context).requestFocus(FocusNode());
                          var pokemon = await widget.onSelectPokemon(widget.party);
                          if (pokemon != null) {
                            widget.party.pokemon6 = pokemon;
                            pokemon6Controller.text =
                              pokemon.nickname == '' ?
                                '${pokemon.name}/${pokemon.name}' :
                                '${pokemon.nickname}/${pokemon.name}';
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 4,
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
                          matches.remove(widget.party.item1);
                          matches.remove(widget.party.item2);
                          matches.remove(widget.party.item3);
                          matches.remove(widget.party.item4);
                          matches.remove(widget.party.item5);
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