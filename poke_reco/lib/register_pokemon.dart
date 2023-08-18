import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_spinbox/material.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class RegisterPokemonPage extends StatelessWidget {
  RegisterPokemonPage({
    Key? key,
    required this.onFinish,
    required this.myPokemon,
    required this.isNew,
  }) : super(key: key) {
    pokeNameController = TextEditingController(text: myPokemon.name);
    pokeNickNameController = TextEditingController(text: myPokemon.nickname);
    pokeNoController = TextEditingController(text: myPokemon.no.toString());
    pokeLevelController = TextEditingController(text: myPokemon.level.toString());
    pokeTemperController = TextEditingController(text: myPokemon.temper.displayName);
    pokeStatHRaceController = TextEditingController(text: isNew ? 'H -' : 'H ${myPokemon.h.race}');
    pokeStatHController = TextEditingController();
    pokeStatHIndiController = TextEditingController();
    pokeStatHEffortController = TextEditingController();
    pokeStatHRealController = TextEditingController();
    //pokeStatHRealController = TextEditingController(text: isNew ? '' : '${myPokemon.h.real}');
    pokeStatARaceController = TextEditingController(text: isNew ? 'A -' : 'A ${myPokemon.a.race}');
    pokeStatAController = TextEditingController();
    pokeStatAIndiController = TextEditingController();
    pokeStatAEffortController = TextEditingController();
    pokeStatARealController = TextEditingController();
    //pokeStatARealController = TextEditingController(text: isNew ? '' : '${myPokemon.a.real}');
    pokeStatBRaceController = TextEditingController(text: isNew ? 'B -' : 'B ${myPokemon.b.race}');
    pokeStatBController = TextEditingController();
    pokeStatBIndiController = TextEditingController();
    pokeStatBEffortController = TextEditingController();
    pokeStatBRealController = TextEditingController();
    //pokeStatBRealController = TextEditingController(text: isNew ? '' : '${myPokemon.b.real}');
    pokeStatCRaceController = TextEditingController(text: isNew ? 'C -' : 'C ${myPokemon.c.race}');
    pokeStatCController = TextEditingController();
    pokeStatCIndiController = TextEditingController();
    pokeStatCEffortController = TextEditingController();
    pokeStatCRealController = TextEditingController();
    //pokeStatCRealController = TextEditingController(text: isNew ? '' : '${myPokemon.c.real}');
    pokeStatDRaceController = TextEditingController(text: isNew ? 'D -' : 'D ${myPokemon.d.race}');
    pokeStatDController = TextEditingController();
    pokeStatDIndiController = TextEditingController();
    pokeStatDEffortController = TextEditingController();
    pokeStatDRealController = TextEditingController();
    //pokeStatDRealController = TextEditingController(text: isNew ? '' : '${myPokemon.d.real}');
    pokeStatSRaceController = TextEditingController(text: isNew ? 'S -' : 'S ${myPokemon.s.race}');
    pokeStatSController = TextEditingController();
    pokeStatSIndiController = TextEditingController();
    pokeStatSEffortController = TextEditingController();
    pokeStatSRealController = TextEditingController();
    //pokeStatSRealController = TextEditingController(text: isNew ? '' : '${myPokemon.s.real}');
    pokeMove1Controller = TextEditingController(text: isNew ? '' : myPokemon.move1.displayName);
    pokePP1Controller = TextEditingController();
    pokeMove2Controller = TextEditingController(text: (isNew || myPokemon.move2 == null) ? '' : myPokemon.move2!.displayName);
    pokePP2Controller = TextEditingController();
    pokeMove3Controller = TextEditingController(text: (isNew || myPokemon.move3 == null) ? '' : myPokemon.move3!.displayName);
    pokePP3Controller = TextEditingController();
    pokeMove4Controller = TextEditingController(text: (isNew || myPokemon.move4 == null) ? '' : myPokemon.move4!.displayName);
    pokePP4Controller = TextEditingController();
  }

  final void Function() onFinish;
  final Pokemon myPokemon;
  final bool isNew;
  late final TextEditingController pokeNameController;     // TODO:デストラクタ？で解放しなくていいのか https://codewithandrea.com/articles/flutter-text-field-form-validation/
  late final TextEditingController pokeNickNameController;
  late final TextEditingController pokeNoController;
  late final TextEditingController pokeLevelController;
  late final TextEditingController pokeTemperController;
  //final pokeAbilityController = TextEditingController();
  final pokeItemController = TextEditingController();
  late final TextEditingController pokeStatHRaceController;
  late final TextEditingController pokeStatHController;
  late final TextEditingController pokeStatHIndiController;
  late final TextEditingController pokeStatHEffortController;
  late final TextEditingController pokeStatHRealController;
  late final TextEditingController pokeStatARaceController;
  late final TextEditingController pokeStatAController;          // 計算によりAの実数値が変更されるときに変更。（Formには紐づけないcontroller）
  late final TextEditingController pokeStatAIndiController;
  late final TextEditingController pokeStatAEffortController;
  late final TextEditingController pokeStatARealController;
  late final TextEditingController pokeStatBRaceController;
  late final TextEditingController pokeStatBController;
  late final TextEditingController pokeStatBIndiController;
  late final TextEditingController pokeStatBEffortController;
  late final TextEditingController pokeStatBRealController;
  late final TextEditingController pokeStatCRaceController;
  late final TextEditingController pokeStatCController;
  late final TextEditingController pokeStatCIndiController;
  late final TextEditingController pokeStatCEffortController;
  late final TextEditingController pokeStatCRealController;
  late final TextEditingController pokeStatDRaceController;
  late final TextEditingController pokeStatDController;
  late final TextEditingController pokeStatDIndiController;
  late final TextEditingController pokeStatDEffortController;
  late final TextEditingController pokeStatDRealController;
  late final TextEditingController pokeStatSRaceController;
  late final TextEditingController pokeStatSController;
  late final TextEditingController pokeStatSIndiController;
  late final TextEditingController pokeStatSEffortController;
  late final TextEditingController pokeStatSRealController;
  late final TextEditingController pokeMove1Controller;
  late final TextEditingController pokePP1Controller;
  late final TextEditingController pokeMove2Controller;
  late final TextEditingController pokePP2Controller;
  late final TextEditingController pokeMove3Controller;
  late final TextEditingController pokePP3Controller;
  late final TextEditingController pokeMove4Controller;
  late final TextEditingController pokePP4Controller;

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

  // TODO:変更したステータスのみ計算する(全部計算する機能も残す)
  void updateRealStat() {
    myPokemon.updateRealStats();

    pokeStatHRealController.text = myPokemon.h.real.toString();
    pokeStatARealController.text = myPokemon.a.real.toString();
    pokeStatBRealController.text = myPokemon.b.real.toString();
    pokeStatCRealController.text = myPokemon.c.real.toString();
    pokeStatDRealController.text = myPokemon.d.real.toString();
    pokeStatSRealController.text = myPokemon.s.real.toString();
    // notify
    pingpongTextEditingController(pokeStatHController);
    pingpongTextEditingController(pokeStatAController);
    pingpongTextEditingController(pokeStatBController);
    pingpongTextEditingController(pokeStatCController);
    pingpongTextEditingController(pokeStatDController);
    pingpongTextEditingController(pokeStatSController);
  }

  void updateStatsRefReal() {
    myPokemon.updateStatsRefReal();

    pokeStatHEffortController.text = myPokemon.h.effort.toString();
    pokeStatHIndiController.text = myPokemon.h.indi.toString();
    pokeStatAEffortController.text = myPokemon.a.effort.toString();
    pokeStatAIndiController.text = myPokemon.a.indi.toString();
    pokeStatBEffortController.text = myPokemon.b.effort.toString();
    pokeStatBIndiController.text = myPokemon.b.indi.toString();
    pokeStatCEffortController.text = myPokemon.c.effort.toString();
    pokeStatCIndiController.text = myPokemon.c.indi.toString();
    pokeStatDEffortController.text = myPokemon.d.effort.toString();
    pokeStatDIndiController.text = myPokemon.d.indi.toString();
    pokeStatSEffortController.text = myPokemon.s.effort.toString();
    pokeStatSIndiController.text = myPokemon.s.indi.toString();
    // notify
    //pingpongTextEditingController(pokeStatHController);
    //pingpongTextEditingController(pokeStatAController);
    //pingpongTextEditingController(pokeStatBController);
    //pingpongTextEditingController(pokeStatCController);
    //pingpongTextEditingController(pokeStatDController);
    //pingpongTextEditingController(pokeStatSController);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
//    final theme = Theme.of(context);

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (isNew) {
        pokemons.add(myPokemon);
      }
      pokeData.addMyPokemon(myPokemon, pokemons.length);
      onFinish();
    }

    return Scaffold(
      appBar: AppBar(
        title: isNew ? Text('ポケモン登録') : Text('ポケモン編集'),
        actions: [
          ValueListenableBuilder(
            valueListenable: pokeMove1Controller,
            builder: (context, TextEditingValue value, __) {
              return TextButton(
                onPressed: (myPokemon.isValid) ? () => onComplete() : null,
                //onPressed: (pokeMove1Controller.text == '') ? null : () => onComplete(),
                child: Text('完了'),
              );
            },
          ),
        ]
      ),
      body: ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
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
                          pokeNoController.text = suggestion.no.toString();
                          myPokemon.name = suggestion.name;
                          myPokemon.no = suggestion.no;
                          myPokemon.type1 = suggestion.type1;
                          myPokemon.type2 = suggestion.type2;
                          myPokemon.ability = suggestion.ability[0];
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
                          updateRealStat();
                          pokeStatHRealController.text = myPokemon.h.real.toString();
                          myPokemon.move1 = pokeData.pokeBase[myPokemon.no]!.move[0];   // TODO:無効なわざ用意しとくべき(今、formの有効/無効切り替え条件がtextの''になってる)
                          myPokemon.move2 = null;
                          myPokemon.move3 = null;
                          myPokemon.move4 = null;
                          pokeMove1Controller.text = '';
                          pokeMove2Controller.text = '';
                          pokeMove3Controller.text = '';
                          pokeMove4Controller.text = '';
                          myPokemon.pp1 = 0;
                          myPokemon.pp2 = 0;
                          myPokemon.pp3 = 0;
                          myPokemon.pp4 = 0;
                          pokePP1Controller.text = '0';
                          pokePP2Controller.text = '0';
                          pokePP3Controller.text = '0';
                          pokePP4Controller.text = '0';
                          // TODO:Listnerのために最後に更新した方がいい？
                          pokeNameController.text = suggestion.name;
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
                        enabled: false,   // TODO:余裕があれば図鑑No変更→ポケモン名変更
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
                        controller: pokeNickNameController,
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
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'タイプ1'
                            ),
                            items: <DropdownMenuItem>[
                              DropdownMenuItem(
                                value: myPokemon.type1,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Row(
                                    children: [
                                      myPokemon.type1.displayIcon,
                                      Text(myPokemon.type1.displayName),
                                    ],
                                  ),
                                ),
                              ),
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
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'タイプ2'
                            ),
                            items: <DropdownMenuItem>[
                              DropdownMenuItem(
                                value: myPokemon.type2,
                                child:
                                  (myPokemon.type2 != null) ?
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Row(
                                      children: 
                                        [
                                          myPokemon.type2!.displayIcon,
                                          Text(myPokemon.type2!.displayName),
                                        ],
                                    ),
                                  ) :
                                  Text(''),
                              ),
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
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'テラスタイプ'
                        ),
                        items: <DropdownMenuItem>[
                          for (var type in pokeData.types)
                            DropdownMenuItem(
                              value: type,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Row(
                                  children: [
                                    type.displayIcon,
                                    Text(type.displayName)
                                  ],
                                ),
                              ),
                          ),
                        ],
                        value: pokeData.types[myPokemon.teraType.id - 1],
                        //value: myPokemon.teraType,
                        onChanged: (value) {myPokemon.teraType = value;},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // レベル, せいべつ
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeLevelController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'レベル'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinLevel,
                        max: pokemonMaxLevel,
                        initialValue: myPokemon.level,
                        onIncrement: (value) {
                          myPokemon.level = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.level = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.level = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
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
                              child: type.displayIcon,
                          ),
                        ],
                        value: myPokemon.sex,
                        onChanged: (value) {myPokemon.sex = value;},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // せいかく, とくせい
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          matches.addAll(pokeData.tempers.values);
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
                          updateRealStat();
                        },
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
                              labelText: 'とくせい'
                            ),
                            items: <DropdownMenuItem>[
                              for (var ab in pokeData.pokeBase[myPokemon.no]!.ability)
                                DropdownMenuItem(
                                  value: ab,
                                  child: Text(ab.displayName),
                                )
                            ],
                            value: pokeData.abilities[myPokemon.ability.id],
                            onChanged: (myPokemon.name == '') ? null : (dynamic value) {myPokemon.ability = value;},
                          );
                        }
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
                        controller: pokeStatHRaceController,
                        enabled: false,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatHIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値',
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.h.indi,
                        onIncrement: (value) {
                          myPokemon.h.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.h.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.h.indi = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatHEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.h.effort,
                        onIncrement: (value) {
                          myPokemon.h.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.h.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.h.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatHController,
                        builder: (context, TextEditingValue value, __) {    // TODO: 2つの値をlistenするためのワークアラウンド。このネストを解消して新たにクラス作るのもあり https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatHRealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'HP'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.h.real,
                            onIncrement: (value) {
                              myPokemon.h.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.h.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.h.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // こうげき
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeTemperController,
                        builder: (context, TextEditingValue value, __) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '種族値',
                            ),
                            controller: pokeStatARaceController,
                            style: (myPokemon.temper.increasedStat == 'attack') ? 
                              TextStyle(color: Colors.red,) :
                                (myPokemon.temper.decreasedStat == 'attack') ?
                                  TextStyle(color: Colors.blue,) : null,
                            enabled: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatAIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.a.indi,
                        onIncrement: (value) {
                          myPokemon.a.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.a.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.a.indi = value.toInt();
                          updateRealStat();
                        },                     // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatAEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.a.effort,
                        onIncrement: (value) {
                          myPokemon.a.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.a.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.a.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatAController,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatARealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'こうげき'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.a.real,
                            onIncrement: (value) {
                              myPokemon.a.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.a.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.a.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ぼうぎょ
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeTemperController,
                        builder: (context, TextEditingValue value, __) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '種族値'
                            ),
                            controller: pokeStatBRaceController,
                            style: (myPokemon.temper.increasedStat == 'defense') ? 
                                  TextStyle(color: Colors.red,) :
                                    (myPokemon.temper.decreasedStat == 'defense') ?
                                      TextStyle(color: Colors.blue,) : null,
                            enabled: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatBIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.b.indi,
                        onIncrement: (value) {
                          myPokemon.b.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.b.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.b.indi = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatBEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.b.effort,
                        onIncrement: (value) {
                          myPokemon.b.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.b.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.b.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatBController,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatBRealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'ぼうぎょ'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.b.real,
                            onIncrement: (value) {
                              myPokemon.b.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.b.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.b.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // とくこう
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeTemperController,
                        builder: (context, TextEditingValue value, __) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '種族値'
                            ),
                            controller: pokeStatCRaceController,
                            style: (myPokemon.temper.increasedStat == 'special-attack') ? 
                                  TextStyle(color: Colors.red,) :
                                    (myPokemon.temper.decreasedStat == 'special-attack') ?
                                      TextStyle(color: Colors.blue,) : null,
                            enabled: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatCIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.c.indi,
                        onIncrement: (value) {
                          myPokemon.c.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.c.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.c.indi = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatCEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.c.effort,
                        onIncrement: (value) {
                          myPokemon.c.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.c.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.c.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatCController,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatCRealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'とくこう'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.c.real,
                            onIncrement: (value) {
                              myPokemon.c.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.c.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.c.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // とくぼう
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeTemperController,
                        builder: (context, TextEditingValue value, __) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '種族値'
                            ),
                            controller: pokeStatDRaceController,
                            style: (myPokemon.temper.increasedStat == 'special-defense') ? 
                                  TextStyle(color: Colors.red,) :
                                    (myPokemon.temper.decreasedStat == 'special-defense') ?
                                      TextStyle(color: Colors.blue,) : null,
                            enabled: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatDIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.d.indi,
                        onIncrement: (value) {
                          myPokemon.d.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.d.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.d.indi = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatDEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.d.effort,
                        onIncrement: (value) {
                          myPokemon.d.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.d.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.d.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatDController,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatDRealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'とくぼう'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.d.real,
                            onIncrement: (value) {
                              myPokemon.d.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.d.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.d.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // すばやさ
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeTemperController,
                        builder: (context, TextEditingValue value, __) {
                          return TextFormField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: '種族値'
                            ),
                            controller: pokeStatSRaceController,
                            style: (myPokemon.temper.increasedStat == 'speed') ? 
                                  TextStyle(color: Colors.red,) :
                                    (myPokemon.temper.decreasedStat == 'speed') ?
                                      TextStyle(color: Colors.blue,) : null,
                            enabled: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatSIndiController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '個体値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinIndividual,
                        max: pokemonMaxIndividual,
                        initialValue: myPokemon.s.indi,
                        onIncrement: (value) {
                          myPokemon.s.indi = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.s.indi = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.s.indi = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: NumberInputWithIncrementDecrement(
                        controller: pokeStatSEffortController,
                        numberFieldDecoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: '努力値'
                        ),
                        widgetContainerDecoration: const BoxDecoration(
                          border: null,
                        ),
                        min: pokemonMinEffort,
                        max: pokemonMaxEffort,
                        initialValue: myPokemon.s.effort,
                        onIncrement: (value) {
                          myPokemon.s.effort = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          myPokemon.s.effort = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          myPokemon.s.effort = value.toInt();
                          updateRealStat();
                        },                      // TODO: いい方法ありそう
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: pokeStatSController,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokeStatSRealController,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'すばやさ'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            initialValue: myPokemon.s.real,
                            onIncrement: (value) {
                              myPokemon.s.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onDecrement: (value) {
                              myPokemon.s.real = value.toInt();
                              updateStatsRefReal();
                            },
                            onChanged: (value) {
                              myPokemon.s.real = value.toInt();
                              updateStatsRefReal();
                            },
                          );
                        },
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
                              enabled: (myPokemon.name != ''),
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
                              pokePP1Controller.text = suggestion.pp.toString();
                              myPokemon.pp1 = suggestion.pp;
                            },
                          );
                        }
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ValueListenableBuilder(
                        valueListenable: pokeNameController,
                        builder: (context, TextEditingValue value, __) {
                          return ValueListenableBuilder(
                            valueListenable: pokeMove1Controller,
                            builder: (context, TextEditingValue value, __) {
                              return NumberInputWithIncrementDecrement(
                                controller: pokePP1Controller,
                                numberFieldDecoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'PP'
                                ),
                                widgetContainerDecoration: const BoxDecoration(
                                  border: null,
                                ),
                                onIncrement: (value) {
                                  myPokemon.pp1 = value.toInt();
                                },
                                onDecrement: (value) {
                                  myPokemon.pp1 = value.toInt();
                                },
                                onChanged: (value) {
                                  myPokemon.pp1 = value.toInt();
                                },                      // TODO: いい方法ありそう
                                initialValue: myPokemon.pp1,
                                enabled: (myPokemon.name != ''),
                              );
                            },
                          );
                        },
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
                          return ValueListenableBuilder(                      // TODO: https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
                            valueListenable: pokeMove1Controller,
                            builder: (context, TextEditingValue value, __) {
                              return TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: pokeMove2Controller,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'わざ2',
                                  ),
                                  enabled: (pokeMove1Controller.text != ''),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Move> matches = [];
                                  matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
                                  matches.retainWhere((s){
                                    return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                                  });
                                  matches.remove(myPokemon.move1);    // わざ1で選択したわざは除外
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
                                  pokePP2Controller.text = suggestion.pp.toString();
                                  myPokemon.pp2 = suggestion.pp;
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ValueListenableBuilder(
                        valueListenable: pokeMove1Controller,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokePP2Controller,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'PP'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            onIncrement: (value) {
                              myPokemon.pp2 = value.toInt();
                            },
                            onDecrement: (value) {
                              myPokemon.pp2 = value.toInt();
                            },
                            onChanged: (value) {
                              myPokemon.pp2 = value.toInt();
                            },                      // TODO: いい方法ありそう
                            initialValue: myPokemon.pp2 == null ? 0 : myPokemon.pp2!,
                            enabled: (pokeMove1Controller.text != ''),
                          );
                        },
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
                          return ValueListenableBuilder(                      // TODO: https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
                            valueListenable: pokeMove2Controller,
                            builder: (context, TextEditingValue value, __) {
                              return TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: pokeMove3Controller,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'わざ3',
                                  ),
                                  enabled: (pokeMove2Controller.text != ''),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Move> matches = [];
                                  matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
                                  matches.retainWhere((s){
                                    return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                                  });
                                  matches.remove(myPokemon.move1);
                                  matches.remove(myPokemon.move2);    // わざ1,2で選択したわざは除外
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
                                  pokePP3Controller.text = suggestion.pp.toString();
                                  myPokemon.pp3 = suggestion.pp;
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ValueListenableBuilder(
                        valueListenable: pokeMove2Controller,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokePP3Controller,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'PP'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            onIncrement: (value) {
                              myPokemon.pp3 = value.toInt();
                            },
                            onDecrement: (value) {
                              myPokemon.pp3 = value.toInt();
                            },
                            onChanged: (value) {
                              myPokemon.pp3 = value.toInt();
                            },                      // TODO: いい方法ありそう
                            initialValue: myPokemon.pp3 == null ? 0 : myPokemon.pp3!,
                            enabled: (pokeMove2Controller.text != ''),
                          );
                        },
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
                          return ValueListenableBuilder(                      // TODO: https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
                            valueListenable: pokeMove3Controller,
                            builder: (context, TextEditingValue value, __) {
                              return TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: pokeMove4Controller,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'わざ4'
                                  ),
                                  enabled: (pokeMove3Controller.text != ''),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Move> matches = [];
                                  matches.addAll(pokeData.pokeBase[myPokemon.no]!.move);
                                  matches.retainWhere((s){
                                    return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                                  });
                                  matches.remove(myPokemon.move1);
                                  matches.remove(myPokemon.move2);
                                  matches.remove(myPokemon.move3);    // わざ1,2,3で選択したわざは除外
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
                                  pokePP4Controller.text = suggestion.pp.toString();
                                  myPokemon.pp4 = suggestion.pp;
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ValueListenableBuilder(
                        valueListenable: pokeMove3Controller,
                        builder: (context, TextEditingValue value, __) {
                          return NumberInputWithIncrementDecrement(
                            controller: pokePP4Controller,
                            numberFieldDecoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'PP'
                            ),
                            widgetContainerDecoration: const BoxDecoration(
                              border: null,
                            ),
                            onIncrement: (value) {
                              myPokemon.pp4 = value.toInt();
                            },
                            onDecrement: (value) {
                              myPokemon.pp4 = value.toInt();
                            },
                            onChanged: (value) {
                              myPokemon.pp4 = value.toInt();
                            },                      // TODO: いい方法ありそう
                            initialValue: myPokemon.pp4 == null ? 0 : myPokemon.pp4!,
                            enabled: (pokeMove3Controller.text != ''),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}