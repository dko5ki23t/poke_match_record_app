import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/party_tile.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/poke_db.dart';

enum RegisterBattlePageType {
  basePage,
}

enum RegisterBattleDialogType {
  selectOwnPokemonDialog,
  selectOppositePokemonDialog,
}

class RegisterBattlePage extends StatefulWidget {
  RegisterBattlePage({
    Key? key,
    required this.onFinish,
    required this.battle,
    required this.isNew,
  }) : super(key: key);

  final void Function() onFinish;
  final Battle battle;
  final bool isNew;

  @override
  RegisterBattlePageState createState() => RegisterBattlePageState();
}

class RegisterBattlePageState extends State<RegisterBattlePage> {
  RegisterBattlePageType pageType = RegisterBattlePageType.basePage;
  final opponentPokemon1Controller = TextEditingController();
  final opponentPokemon2Controller = TextEditingController();
  final opponentPokemon3Controller = TextEditingController();
  final opponentPokemon4Controller = TextEditingController();
  final opponentPokemon5Controller = TextEditingController();
  final opponentPokemon6Controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var battles = appState.battles;
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);

    Widget lists;

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        lists = Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(  // バトル名
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'バトル名'
                      ),
                      onChanged: (value) {
                        widget.battle.name = value;
//                            widget.battle.updateIsValid();
//                            setState(() {});
                      },
                      maxLength: 10,
//                          controller: partyNameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(  // 対戦日時
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '対戦日'
                      ),
/*
                      onTap: () {
                        // キーボードが出ないようにする
                        FocusScope.of(context).requestFocus(FocusNode());
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(2000, 1, 1),
                          maxTime: DateTime(2200, 12, 31),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            print('confirm $date');
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.jp,
                        );
                      },
*/
                      onChanged: (value) {
                        widget.battle.datatime = DateTime.parse(value);
//                            widget.battle.updateIsValid();
//                            setState(() {});
                      },
//                          controller: partyNameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'あなたのパーティ'
                      ),
                      items: <DropdownMenuItem>[
                        for (final party in parties)
                          DropdownMenuItem(
                            value: party.id,
//                              child: FittedBox(
//                                fit: BoxFit.fitWidth,
//                                child: PokemonTile(e, theme, pokeData,),
//                              ),
                            child: PartyTile(party, theme, pokeData,),
                          ),
                      ],
                      onChanged: (value) {
                        widget.battle.ownParty = parties[value - 1];
//                      widget.party.updateIsValid();
//                      setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(  // あいての名前
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'あいての名前'
                      ),
                      onChanged: (value) {
                        widget.battle.opponentName = value;
//                            widget.battle.updateIsValid();
//                            setState(() {});
                      },
                      maxLength: 10,
//                          controller: partyNameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon1Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン1'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon1.name = suggestion.name;
                        widget.battle.opponentParty.pokemon1.no = suggestion.no;
                        widget.battle.opponentParty.pokemon1.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon1.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon1.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon1.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon1.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon1.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon1.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon1.s.race = suggestion.s;
                        opponentPokemon1Controller.text = suggestion.name;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ1'
                      ),
                      items: <DropdownMenuItem>[
                        for (var type in Sex.values)
                          DropdownMenuItem(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: (value) {widget.battle.opponentParty.pokemon1.sex = value;},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon2Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン2'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon2 ??= Pokemon();
                        widget.battle.opponentParty.pokemon2!.name = suggestion.name;
                        widget.battle.opponentParty.pokemon2!.no = suggestion.no;
                        widget.battle.opponentParty.pokemon2!.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon2!.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon2!.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon2!.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon2!.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon2!.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon2!.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon2!.s.race = suggestion.s;
                        opponentPokemon2Controller.text = suggestion.name;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ2'
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in Sex.values)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: widget.battle.opponentParty.pokemon2 != null ?
                        (Sex? value) {widget.battle.opponentParty.pokemon2!.sex = value!;} : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon3Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン3'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon3 ??= Pokemon();
                        widget.battle.opponentParty.pokemon3!.name = suggestion.name;
                        widget.battle.opponentParty.pokemon3!.no = suggestion.no;
                        widget.battle.opponentParty.pokemon3!.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon3!.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon3!.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon3!.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon3!.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon3!.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon3!.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon3!.s.race = suggestion.s;
                        opponentPokemon3Controller.text = suggestion.name;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ3'
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in Sex.values)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: widget.battle.opponentParty.pokemon3 != null ?
                        (Sex? value) {widget.battle.opponentParty.pokemon3!.sex = value!;} : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon4Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン4'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon4 ??= Pokemon();
                        widget.battle.opponentParty.pokemon4!.name = suggestion.name;
                        widget.battle.opponentParty.pokemon4!.no = suggestion.no;
                        widget.battle.opponentParty.pokemon4!.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon4!.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon4!.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon4!.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon4!.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon4!.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon4!.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon4!.s.race = suggestion.s;
                        opponentPokemon4Controller.text = suggestion.name;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ4'
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in Sex.values)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: widget.battle.opponentParty.pokemon4 != null ?
                        (Sex? value) {widget.battle.opponentParty.pokemon4!.sex = value!;} : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon5Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン5'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon5 ??= Pokemon();
                        widget.battle.opponentParty.pokemon5!.name = suggestion.name;
                        widget.battle.opponentParty.pokemon5!.no = suggestion.no;
                        widget.battle.opponentParty.pokemon5!.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon5!.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon5!.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon5!.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon5!.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon5!.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon5!.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon5!.s.race = suggestion.s;
                        opponentPokemon5Controller.text = suggestion.name;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ5'
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in Sex.values)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: widget.battle.opponentParty.pokemon5 != null ?
                        (Sex? value) {widget.battle.opponentParty.pokemon5!.sex = value!;} : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 8,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: opponentPokemon6Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'ポケモン6'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<PokeBase> matches = [];
                        matches.addAll(pokeData.pokeBase.values);
                        matches.retainWhere((s){
                          return toKatakana(s.name.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                        });
                        return matches;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          autofocus: true,
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        widget.battle.opponentParty.pokemon6 ??= Pokemon();
                        widget.battle.opponentParty.pokemon6!.name = suggestion.name;
                        widget.battle.opponentParty.pokemon6!.no = suggestion.no;
                        widget.battle.opponentParty.pokemon6!.type1 = suggestion.type1;
                        widget.battle.opponentParty.pokemon6!.type2 = suggestion.type2;
                        widget.battle.opponentParty.pokemon6!.h.race = suggestion.h;
                        widget.battle.opponentParty.pokemon6!.a.race = suggestion.a;
                        widget.battle.opponentParty.pokemon6!.b.race = suggestion.b;
                        widget.battle.opponentParty.pokemon6!.c.race = suggestion.c;
                        widget.battle.opponentParty.pokemon6!.d.race = suggestion.d;
                        widget.battle.opponentParty.pokemon6!.s.race = suggestion.s;
                        opponentPokemon6Controller.text = suggestion.name;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'せいべつ6'
                      ),
                      items: <DropdownMenuItem<Sex>>[
                        for (var type in Sex.values)
                          DropdownMenuItem<Sex>(
                            value: type,
                            child: type.displayIcon,
                        ),
                      ],
                      value: Sex.none,
                      onChanged: widget.battle.opponentParty.pokemon6 != null ?
                        (Sex? value) {widget.battle.opponentParty.pokemon6!.sex = value!;} : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
        break;
      default:
        lists = Center();
        break;
    }
    

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        battles.add(widget.battle);
      }
//      pokeData.addParty(widget.party, parties.length);
      widget.onFinish();
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? Text('バトル記録') : Text('バトル編集'),
        actions: [
          TextButton(
            onPressed: (widget.battle.isValid) ? () => onComplete() : null,
            child: Text('完了'),
          ),
        ],
      ),
      body: ListView(
        children: [lists],
      ),
    );
  }
}