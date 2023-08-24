import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/custom_widgets/move_input_row.dart';
import 'package:poke_reco/custom_widgets/stat_input_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class RegisterPokemonPage extends StatefulWidget {
  RegisterPokemonPage({
    Key? key,
    required this.onFinish,
    required this.myPokemon,
    required this.isNew,
  }) : super(key: key);

  final void Function() onFinish;
  final Pokemon myPokemon;
  final bool isNew;

  @override
  RegisterPokemonPageState createState() => RegisterPokemonPageState();
}

class RegisterPokemonPageState extends State<RegisterPokemonPage> {
  final pokeNameController = TextEditingController();     // TODO:デストラクタ？で解放しなくていいのか https://codewithandrea.com/articles/flutter-text-field-form-validation/
  final pokeNickNameController = TextEditingController();
  final pokeNoController = TextEditingController();
  final pokeLevelController = TextEditingController();
  final pokeTemperController = TextEditingController();
  final pokeStatRaceController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatIndiController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatEffortController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatRealController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeMoveController = List.generate(4, (i) => TextEditingController());
  final pokePPController = List.generate(4, (i) => TextEditingController());
  final statsLabelTexts = ['HP', 'こうげき', 'ぼうぎょ', 'とくこう', 'とくぼう', 'すばやさ'];
  final statNames = ['', 'attack', 'defense', 'special-attack', 'special-defense', 'speed'];

  // TODO:変更したステータスのみ計算する(全部計算する機能も残す)
  void updateRealStat() {
    widget.myPokemon.updateRealStats();

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatRealController[i].text = widget.myPokemon.stats[i].real.toString();
    }
    // notify
    setState(() {});
  }

  void updateStatsRefReal() {
    widget.myPokemon.updateStatsRefReal();

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatEffortController[i].text = widget.myPokemon.stats[i].effort.toString();
      pokeStatIndiController[i].text = widget.myPokemon.stats[i].indi.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;

    pokeNameController.text = widget.myPokemon.name;
    pokeNickNameController.text = widget.myPokemon.nickname;
    pokeNoController.text = widget.myPokemon.no.toString();
    pokeLevelController.text = widget.myPokemon.level.toString();
    pokeTemperController.text = widget.myPokemon.temper.displayName;
    pokeStatRaceController[0].text = widget.isNew ? 'H -' : 'H ${widget.myPokemon.h.race}';
    pokeStatRaceController[1].text = widget.isNew ? 'A -' : 'A ${widget.myPokemon.a.race}';
    pokeStatRaceController[2].text = widget.isNew ? 'B -' : 'B ${widget.myPokemon.b.race}';
    pokeStatRaceController[3].text = widget.isNew ? 'C -' : 'C ${widget.myPokemon.c.race}';
    pokeStatRaceController[4].text = widget.isNew ? 'D -' : 'D ${widget.myPokemon.d.race}';
    pokeStatRaceController[5].text = widget.isNew ? 'S -' : 'S ${widget.myPokemon.s.race}';
    pokeMoveController[0].text = widget.isNew ? '' : widget.myPokemon.move1.displayName;
    pokeMoveController[1].text = (widget.isNew || widget.myPokemon.move2 == null) ? '' : widget.myPokemon.move2!.displayName;
    pokeMoveController[2].text = (widget.isNew || widget.myPokemon.move3 == null) ? '' : widget.myPokemon.move3!.displayName;
    pokeMoveController[3].text = (widget.isNew || widget.myPokemon.move4 == null) ? '' : widget.myPokemon.move4!.displayName;

    void onComplete() {
      if (widget.isNew) {
        pokemons.add(widget.myPokemon);
        widget.myPokemon.id = pokemons.length;
      }
      pokeData.addMyPokemon(widget.myPokemon);
      widget.onFinish();
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? Text('ポケモン登録') : Text('ポケモン編集'),
        actions: [
          TextButton(
            onPressed: (widget.myPokemon.isValid) ? () => onComplete() : null,
            child: Text('完了'),
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
                          widget.myPokemon
                          ..name = suggestion.name
                          ..no = suggestion.no
                          ..type1 = suggestion.type1
                          ..type2 = suggestion.type2
                          ..ability = suggestion.ability[0]
                          ..h.race = suggestion.h
                          ..a.race = suggestion.a
                          ..b.race = suggestion.b
                          ..c.race = suggestion.c
                          ..d.race = suggestion.d
                          ..s.race = suggestion.s;
                          pokeStatRaceController[0].text = 'H ${widget.myPokemon.h.race}';
                          pokeStatRaceController[1].text = 'A ${widget.myPokemon.a.race}';
                          pokeStatRaceController[2].text = 'B ${widget.myPokemon.b.race}';
                          pokeStatRaceController[3].text = 'C ${widget.myPokemon.c.race}';
                          pokeStatRaceController[4].text = 'D ${widget.myPokemon.d.race}';
                          pokeStatRaceController[5].text = 'S ${widget.myPokemon.s.race}';
                          updateRealStat();
                          //pokeStatHRealController.text = widget.myPokemon.h.real.toString();
                          widget.myPokemon.move1 = pokeData.pokeBase[widget.myPokemon.no]!.move[0];   // TODO:無効なわざ用意しとくべき(今、formの有効/無効切り替え条件がtextの''になってる)
                          widget.myPokemon.move2 = null;
                          widget.myPokemon.move3 = null;
                          widget.myPokemon.move4 = null;
                          for (int i = 0; i < 4; i++) {
                            pokeMoveController[i].text = '';
                            widget.myPokemon.pps[i] = 0;
                            pokePPController[i].text = '0';
                          }
                          // TODO:Listnerのために最後に更新した方がいい？
                          pokeNameController.text = suggestion.name;
                          setState(() {});
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
                        onChanged: (value) {widget.myPokemon.no = int.parse(value);},
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
                          labelText: 'ニックネーム(任意)'
                        ),
                        onChanged: (value) {widget.myPokemon.nickname = value;},
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
                      child: TypeDropdownButton(
                        pokeData,
                        'タイプ1',
                        null,
                        widget.myPokemon.type1.id,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeDropdownButton(
                        pokeData,
                        'タイプ2',
                        null,
                        widget.myPokemon.type2?.id,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TypeDropdownButton(
                        pokeData,
                        'テラスタイプ',
                        (value) {widget.myPokemon.teraType = pokeData.types[value - 1];},
                        widget.myPokemon.teraType.id,
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
                        initialValue: widget.myPokemon.level,
                        onIncrement: (value) {
                          widget.myPokemon.level = value.toInt();
                          updateRealStat();
                        },
                        onDecrement: (value) {
                          widget.myPokemon.level = value.toInt();
                          updateRealStat();
                        },
                        onChanged: (value) {
                          widget.myPokemon.level = value.toInt();
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
                        value: widget.myPokemon.sex,
                        onChanged: (value) {widget.myPokemon.sex = value;},
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
                          widget.myPokemon.temper = suggestion;
                          updateRealStat();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'とくせい'
                        ),
                        items: <DropdownMenuItem>[
                          for (var ab in pokeData.pokeBase[widget.myPokemon.no]!.ability)
                            DropdownMenuItem(
                              value: ab,
                              child: Text(ab.displayName),
                            )
                        ],
                        value: pokeData.abilities[widget.myPokemon.ability.id],
                        onChanged: (widget.myPokemon.name == '') ? null : (dynamic value) {widget.myPokemon.ability = value;},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ の数値入力
                for (int i = 0; i < StatIndex.size.index; i++)
                  StatInputRow(
                    statsLabelTexts[i],
                    widget.myPokemon,
                    pokeStatRaceController[i],
                    pokeStatIndiController[i],
                    pokemonMinIndividual,
                    pokemonMaxIndividual,
                    widget.myPokemon.stats[i].indi,
                    (value) {
                      widget.myPokemon.stats[i].indi = value.toInt();
                      updateRealStat();
                    },
                    pokeStatEffortController[i],
                    pokemonMinEffort,
                    pokemonMaxEffort,
                    widget.myPokemon.stats[i].effort,
                    (value) {
                      widget.myPokemon.stats[i].effort = value.toInt();
                      updateRealStat();
                    },
                    pokeStatRealController[i],
                    widget.myPokemon.stats[i].real,
                    (value) {
                      widget.myPokemon.stats[i].real = value.toInt();
                      updateStatsRefReal();
                    },
                    effectTemper: i != 0,
                    statName: statNames[i],
                  ),
                  SizedBox(height: 10),

                // わざ1, PP1, わざ2, PP2, わざ3, PP3, わざ4, PP4
                for (int i = 0; i < 4; i++)
                  MoveInputRow(
                    pokeData, widget.myPokemon,
                    'わざ${i+1}', 'PP',
                    pokeMoveController[i],
                    [for (int j = 0; j < 4; j++) i != j ? widget.myPokemon.moves[j] : null],
                    (suggestion) {
                      pokeMoveController[i].text = suggestion.displayName;
                      widget.myPokemon.moves[i] = suggestion;
                      pokePPController[i].text = suggestion.pp.toString();
                      widget.myPokemon.pps[i] = suggestion.pp;
                    },
                    pokePPController[i],
                    (value) {widget.myPokemon.pps[i] = value.toInt();},
                    moveEnabled: widget.myPokemon.name != '',
                    ppEnabled: widget.myPokemon.name != '',
                    initialPPValue: widget.myPokemon.pps[i] ?? 0,
                  ),
                  SizedBox(height: 10),

                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}