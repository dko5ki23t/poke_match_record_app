import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';

class RegisterPokemonPage extends StatelessWidget {
  RegisterPokemonPage({
    Key? key,
    required this.onFinish,
  }) : super(key: key);
  final void Function() onFinish;
  final Pokemon myPokemon = Pokemon();
  final TextEditingController pokeNameController = TextEditingController();     // TODO:デストラクタ？で解放しなくていいのか https://codewithandrea.com/articles/flutter-text-field-form-validation/
  final TextEditingController pokeNoController = TextEditingController();
  final TextEditingController pokeTemperController = TextEditingController();
  final TextEditingController pokeAbilityController = TextEditingController();
  final TextEditingController pokeItemController = TextEditingController();
  final TextEditingController pokeStatHRaceController = TextEditingController(text: 'H -');
  final TextEditingController pokeStatARaceController = TextEditingController(text: 'A -');
  final TextEditingController pokeStatBRaceController = TextEditingController(text: 'B -');
  final TextEditingController pokeStatCRaceController = TextEditingController(text: 'C -');
  final TextEditingController pokeStatDRaceController = TextEditingController(text: 'D -');
  final TextEditingController pokeStatSRaceController = TextEditingController(text: 'S -');
  final TextEditingController pokeMove1Controller = TextEditingController();
  final TextEditingController pokeMove2Controller = TextEditingController();
  final TextEditingController pokeMove3Controller = TextEditingController();
  final TextEditingController pokeMove4Controller = TextEditingController();
  final GlobalKey pokeStatHRealKey = GlobalKey();

  // 引用：https://417.run/pg/flutter-dart/hiragana-to-katakana/
  static toKatakana(String str) {
    return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
//    final theme = Theme.of(context);

    void onComplete() {
      // TODO: 入力された値が正しいかチェック
      pokemons.add(myPokemon);
      onFinish();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ポケモン登録'),
        actions: [
          TextButton(
            child: Text('完了'),
            onPressed:() => onComplete(),
          ),
        ]
      ),
      body: ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(  // ポケモン名, 図鑑No
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 7,
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: pokeNameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'ポケモン名'
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
                    pokeNameController.text = suggestion.name;
                    pokeNoController.text = suggestion.no.toString();
                    myPokemon.name = suggestion.name;
                    myPokemon.no = suggestion.no;
                    myPokemon.type1 = suggestion.type1;
                    myPokemon.type2 = suggestion.type2;
                    myPokemon.h.race = suggestion.h;
                    myPokemon.a.race = suggestion.a;
                    myPokemon.b.race = suggestion.b;
                    myPokemon.c.race = suggestion.c;
                    myPokemon.d.race = suggestion.d;
                    myPokemon.s.race = suggestion.s;
                    pokeStatHRaceController.text = 'H ${myPokemon.h.race}';
                    pokeStatARaceController.text = 'A ${myPokemon.a.race}';
                    pokeStatBRaceController.text = 'B ${myPokemon.b.race}';
                    pokeStatCRaceController.text = 'C ${myPokemon.c.race}';
                    pokeStatDRaceController.text = 'D ${myPokemon.d.race}';
                    pokeStatSRaceController.text = 'S ${myPokemon.s.race}';
                    final pokeStatARealControoler = (pokeStatHRealKey.currentState as dynamic).controller as TextEditingController;
                    pokeStatARealControoler.text = ((myPokemon.h.race * 2 + myPokemon.h.indi + (myPokemon.h.effort ~/ 4)) * myPokemon.level ~/ 100 + myPokemon.level + 10).toString();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 3,
                child:TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '図鑑No.',
                    counterText: '',        // 下に出る文字数制限の表示を消す
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {myPokemon.no = int.parse(value);},
                  maxLength: 5,
                  controller: pokeNoController,
                ),
              ),            
            ],
          ),
          SizedBox(height: 10),
          Row(  // ニックネーム
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child:TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ニックネーム'
                  ),
                  onChanged: (value) {myPokemon.nickname = value;},
                  maxLength: 6,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // タイプ1, タイプ2, テラスタイプ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'タイプ1'
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: myPokemon.type1,
                          child: Icon(myPokemon.type1.displayIcon),
                        )
                      ],
                      onChanged: null,
                      value: myPokemon.type1,
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'タイプ2'
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: myPokemon.type2,
                          child: Icon(myPokemon.type2?.displayIcon),
                        )
                      ],
                      onChanged: null,
                      value: myPokemon.type2,
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'テラスタイプ'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in pokeData.types)
                      DropdownMenuItem(
                        value: type,
                        child: Icon(type.displayIcon),
                    ),
                  ],
                  onChanged: (value) {myPokemon.teraType = value;},
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // レベル, せいべつ, せいかく
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'レベル'
                  ),
                  min: 1,
                  max: 100,
                  value: 50,
                  onChanged: (value) {myPokemon.level = value.toInt();},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'せいべつ'
                  ),
                  items: <DropdownMenuItem>[
                    for (var type in Sex.values)
                      DropdownMenuItem(
                        value: type,
                        child: Icon(type.displayIcon),
                    ),
                  ],
                  value: Sex.none,
                  onChanged: (value) {myPokemon.sex = value;},
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: pokeTemperController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'せいかく'
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Temper> matches = [];
                    matches.addAll(pokeData.tempers);
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
                    pokeTemperController.text = suggestion.displayName;
                    myPokemon.temper = suggestion;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくせい, もちもの
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'とくせい'
                      ),
                      items: <DropdownMenuItem>[
                        for (var ab in pokeData.pokeBase[myPokemon.no]!.ability)
                          DropdownMenuItem(
                            value: ab,
                            child: Text(ab.displayName),
                          )
                      ],
                      onChanged:(value) {myPokemon.ability = value;},
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: pokeItemController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの'
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    matches.addAll(pokeData.items);
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
                    pokeItemController.text = suggestion.displayName;
                    myPokemon.item = suggestion;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // HP
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  enabled: false,
                  controller: pokeStatHRaceController,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値',
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'HP'
                  ),
                  key: pokeStatHRealKey,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // こうげき
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  controller: pokeStatARaceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'こうげき'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // ぼうぎょ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  controller: pokeStatBRaceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ぼうぎょ'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくこう
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  controller: pokeStatCRaceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくこう'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // とくぼう
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  controller: pokeStatDRaceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'とくぼう'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // すばやさ
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '種族値'
                  ),
                  controller: pokeStatSRaceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '個体値'
                  ),
                  min: 0,
                  max: 31,
                  value: 31,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '努力値'
                  ),
                  min: 0,
                  max: 252,
                  value: 0,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'すばやさ'
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ1, PP1
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 7,
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokeMove1Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'わざ1'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Move> matches = [];
                        matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
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
                        pokeMove1Controller.text = suggestion.displayName;
                        myPokemon.move1 = suggestion;
                      },
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ2, PP2
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 7,
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokeMove2Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'わざ2'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Move> matches = [];
                        matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
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
                        pokeMove2Controller.text = suggestion.displayName;
                        myPokemon.move2 = suggestion;
                      },
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ3, PP3
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 7,
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokeMove3Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'わざ3'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Move> matches = [];
                        matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
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
                        pokeMove3Controller.text = suggestion.displayName;
                        myPokemon.move3 = suggestion;
                      },
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(  // わざ4, PP4
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 7,
                child: ValueListenableBuilder(
                  valueListenable: pokeNameController,
                  builder: (context, TextEditingValue value, __) {
                    return TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: pokeMove4Controller,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'わざ4'
                        ),
                      ),
                      autoFlipDirection: true,
                      suggestionsCallback: (pattern) async {
                        List<Move> matches = [];
                        matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
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
                        pokeMove4Controller.text = suggestion.displayName;
                        myPokemon.move4 = suggestion;
                      },
                    );
                  }
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SpinBox(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'PP'
                  ),
                  value: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}