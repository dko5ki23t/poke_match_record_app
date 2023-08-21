import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/party_tile.dart';
import 'package:poke_reco/pokemon_mini_tile.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/poke_db.dart';

enum RegisterBattlePageType {
  basePage,
  firstPokemonPage,
  turnPage,
}

/*
enum RegisterBattleDialogType {
  selectOwnPokemonDialog,
  selectOppositePokemonDialog,
}
*/

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
//  final battleDatetimeController = TextEditingController(text: DateFormat('yyyy/MM/dd HH:mm', "ja_JP").format(DateTime.now()));
  final opponentPokemon1Controller = TextEditingController();
  final opponentPokemon2Controller = TextEditingController();
  final opponentPokemon3Controller = TextEditingController();
  final opponentPokemon4Controller = TextEditingController();
  final opponentPokemon5Controller = TextEditingController();
  final opponentPokemon6Controller = TextEditingController();

  final move1Controller = TextEditingController();
  final move2Controller = TextEditingController();

  final HP1Controller = TextEditingController();

  int checkedOwnPokemon = 0;
  int checkedOpponentPokemon = 0;
  late Pokemon currentOwnPokemon;
  late Pokemon currentOpponentPokemon;
  int turn = 1;
  int turnPlayer1 = 0;    // ターン内で先に行動する者のID
  Move turnMove1 = Move(0, '', 0);  // ターン内で先に実行されたわざ
  int turnPlayer2 = 0;    // ターン内で先に行動する者のID
  Move turnMove2 = Move(0, '', 0);  // ターン内で先に実行されたわざ

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
    Widget title;
    void Function()? nextPressed;

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        battles.add(widget.battle);
      }
//      pokeData.addParty(widget.party, parties.length);
      widget.onFinish();
    }

    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          pageType = RegisterBattlePageType.firstPokemonPage;
          checkedOwnPokemon = 0;
          checkedOpponentPokemon = 0;
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          // TODO:やっぱポケモンの配列にしないと
          switch (checkedOwnPokemon) {
            case 1:
              currentOwnPokemon = widget.battle.ownParty.pokemon1;
              break;
            case 2:
              currentOwnPokemon = widget.battle.ownParty.pokemon2!;
              break;
            case 3:
              currentOwnPokemon = widget.battle.ownParty.pokemon3!;
              break;
            case 4:
              currentOwnPokemon = widget.battle.ownParty.pokemon4!;
              break;
            case 5:
              currentOwnPokemon = widget.battle.ownParty.pokemon5!;
              break;
            case 6:
              currentOwnPokemon = widget.battle.ownParty.pokemon6!;
              break;
          }
          switch (checkedOpponentPokemon) {
            case 1:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon1;
              break;
            case 2:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon2!;
              break;
            case 3:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon3!;
              break;
            case 4:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon4!;
              break;
            case 5:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon5!;
              break;
            case 6:
              currentOpponentPokemon = widget.battle.opponentParty.pokemon6!;
              break;
          }
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          turn++;
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        default:
          assert(false, 'invalid page move');
          break;
      }
    }

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        title = Text('バトル基本情報');
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
                        widget.battle.updateIsValid();
                        setState(() {});
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
                      initialValue: widget.battle.datatime.toIso8601String(),
//                      controller: battleDatetimeController,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'バトルの種類'
                      ),
                      items: <DropdownMenuItem>[
                        for (var type in BattleType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                        ),
                      ],
                      value: BattleType.rankmatch,
                      onChanged: (value) {widget.battle.type = value;},
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
                      selectedItemBuilder: (context) {
                        return [
                          for (final party in parties)
                            Text(party.name),
                        ];
                      },
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
                        widget.battle.updateIsValid();
                        setState(() {});
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
                        widget.battle.updateIsValid();
                        setState(() {});
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
                        widget.battle.updateIsValid();
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
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text('先頭ポケモン');
        lists = Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('あなた', style: theme.textTheme.bodyLarge,),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(widget.battle.opponentName, style: theme.textTheme.bodyLarge,),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PokemonMiniTile(
                      widget.battle.ownParty.pokemon1,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 1; setState(() {});},
                      selected: checkedOwnPokemon == 1,
                      selectedTileColor: Colors.black26,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: PokemonMiniTile(
                      widget.battle.opponentParty.pokemon1,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 1; setState(() {});},
                      selected: checkedOpponentPokemon == 1,
                      selectedTileColor: Colors.black26,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.battle.ownParty.pokemon2 != null ?
                    PokemonMiniTile(
                      widget.battle.ownParty.pokemon2!,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 2; setState(() {});},
                      selected: checkedOwnPokemon == 2,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: widget.battle.opponentParty.pokemon2 != null ?
                    PokemonMiniTile(
                      widget.battle.opponentParty.pokemon2!,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 2; setState(() {});},
                      selected: checkedOpponentPokemon == 2,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.battle.ownParty.pokemon3 != null ?
                    PokemonMiniTile(
                      widget.battle.ownParty.pokemon3!,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 3; setState(() {});},
                      selected: checkedOwnPokemon == 3,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: widget.battle.opponentParty.pokemon3 != null ?
                    PokemonMiniTile(
                      widget.battle.opponentParty.pokemon3!,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 3; setState(() {});},
                      selected: checkedOpponentPokemon == 3,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.battle.ownParty.pokemon4 != null ?
                    PokemonMiniTile(
                      widget.battle.ownParty.pokemon4!,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 4; setState(() {});},
                      selected: checkedOwnPokemon == 4,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: widget.battle.opponentParty.pokemon4 != null ?
                    PokemonMiniTile(
                      widget.battle.opponentParty.pokemon4!,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 4; setState(() {});},
                      selected: checkedOpponentPokemon == 4,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.battle.ownParty.pokemon5 != null ?
                    PokemonMiniTile(
                      widget.battle.ownParty.pokemon5!,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 5; setState(() {});},
                      selected: checkedOwnPokemon == 5,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: widget.battle.opponentParty.pokemon5 != null ?
                    PokemonMiniTile(
                      widget.battle.opponentParty.pokemon5!,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 5; setState(() {});},
                      selected: checkedOpponentPokemon == 5,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.battle.ownParty.pokemon6 != null ?
                    PokemonMiniTile(
                      widget.battle.ownParty.pokemon6!,
                      theme, pokeData,
                      onTap: () {checkedOwnPokemon = 6; setState(() {});},
                      selected: checkedOwnPokemon == 6,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: widget.battle.opponentParty.pokemon6 != null ?
                    PokemonMiniTile(
                      widget.battle.opponentParty.pokemon6!,
                      theme, pokeData,
                      onTap: () {checkedOpponentPokemon = 6; setState(() {});},
                      selected: checkedOpponentPokemon == 6,
                      selectedTileColor: Colors.black26,
                    ) : Text(''),
                  ),
                ],
              ),
            ],
          ),
        );
        nextPressed = (checkedOwnPokemon != 0 && checkedOpponentPokemon != 0) ? () => onNext() : null;
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('$turnターン目');
        lists = Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),
              ExpandablePanel(
                header: Text('わざ選択前'),
                collapsed: Text('タップで詳細を設定'),
                expanded: Text('hoge'),
              ),
              SizedBox(height: 20,),
              ExpandablePanel(
                header: Text('わざ選択'),
                collapsed: Text('タップで詳細を設定'),
                expanded: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('行動1'),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: '行動主',
                                  ),
                                  items: <DropdownMenuItem>[
                                    DropdownMenuItem(
                                      value: 0,
                                      child: Text('選択してください'),
                                    ),
                                    DropdownMenuItem(
                                      value: PlayerType.me.id,
                                      child: Text('${currentOwnPokemon.name}/あなた', overflow: TextOverflow.ellipsis,),
                                    ),
                                    DropdownMenuItem(
                                      value: PlayerType.opponent.id,
                                      child: Text('${currentOpponentPokemon.name}/${widget.battle.opponentName}', overflow: TextOverflow.ellipsis,),
                                    ),
                                  ],
                                  value: turnPlayer1,
                                  onChanged: (value) {turnPlayer1 = value; setState(() {});},
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                flex: 5,
                                child: TypeAheadField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: move1Controller,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'わざ'
                                    ),
                                    enabled: turnPlayer1 != 0,
                                  ),
                                  autoFlipDirection: true,
                                  suggestionsCallback: (pattern) async {
                                    List<Move> matches = [];
                                    if (turnPlayer1 == PlayerType.me.id) {
                                      matches.add(currentOwnPokemon.move1);
                                      if (currentOwnPokemon.move2 != null) matches.add(currentOwnPokemon.move2!);
                                      if (currentOwnPokemon.move3 != null) matches.add(currentOwnPokemon.move3!);
                                      if (currentOwnPokemon.move4 != null) matches.add(currentOwnPokemon.move4!);
                                    }
                                    else {
                                      matches.addAll(pokeData.pokeBase[currentOpponentPokemon.no]!.move);
                                    }
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
                                    move1Controller.text = suggestion.displayName;
                                    /*myPokemon.move1 = suggestion;
                                    pokePP1Controller.text = suggestion.pp.toString();
                                    myPokemon.pp1 = suggestion.pp;*/
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: '命中',
                                  ),
                                  items: <DropdownMenuItem>[
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('命中'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('急所に命中'),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('当たらなかった'),
                                    ),
                                  ],
                                  onChanged: (value) {},
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: '効果',
                                  ),
                                  items: <DropdownMenuItem>[
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('（テキストなし）', overflow: TextOverflow.ellipsis,),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('ばつぐんだ', overflow: TextOverflow.ellipsis,),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('いまひとつのようだ', overflow: TextOverflow.ellipsis,),
                                    ),
                                    DropdownMenuItem(
                                      value: 4,
                                      child: Text('ないようだ', overflow: TextOverflow.ellipsis,),
                                    ),
                                  ],
                                  onChanged: (value) {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: NumberInputWithIncrementDecrement(
                                  controller: HP1Controller,
                                  numberFieldDecoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'HP'
                                  ),
                                  widgetContainerDecoration: const BoxDecoration(
                                    border: null,
                                  ),
                                  initialValue: currentOwnPokemon.h.real,
                                  min: 0,
                                  max: currentOwnPokemon.h.real,
                                  onIncrement: (value) {
/*
                                    myPokemon.b.real = value.toInt();
                                    updateStatsRefReal();
*/
                                  },
                                  onDecrement: (value) {
/*
                                    myPokemon.b.real = value.toInt();
                                    updateStatsRefReal();
*/
                                  },
                                  onChanged: (value) {
/*
                                    myPokemon.b.real = value.toInt();
                                    updateStatsRefReal();
*/
                                  },
                                ),
                              ),
                              Text('/${currentOwnPokemon.h.real}')
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              ExpandablePanel(
                header: Text('わざ選択後'),
                collapsed: Text('タップで詳細を設定'),
                expanded: Text('hoge'),
              ),
              SizedBox(height: 10,),
            ],
          ),
        );
        nextPressed = () => onNext();
        break;
      default:
        title = Text('バトル登録');
        lists = Center();
        nextPressed = null;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? title : Text('バトル編集'),
        actions: [
          TextButton(
            onPressed: nextPressed,
            child: Text('次へ'),
          ),
        ],
      ),
      body: ListView(
        children: [lists],
      ),
    );
  }
}