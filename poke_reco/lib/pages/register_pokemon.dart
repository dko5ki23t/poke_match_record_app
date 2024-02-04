import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_widgets/move_input_row.dart';
import 'package:poke_reco/custom_widgets/stat_input_row.dart';
import 'package:poke_reco/custom_widgets/stat_total_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPokemonPage extends StatefulWidget {
  RegisterPokemonPage({
    Key? key,
    required this.onFinish,
    required this.myPokemon,
//    required this.isNew,
    this.pokemonState,
  }) : super(key: key);

  final void Function() onFinish;
  final Pokemon myPokemon;
//  final bool isNew;     // この変数の代わりに、ポケモンのIDが0(まだ無効)かどうかで新規登録かを判定する
  final PokemonState? pokemonState;

  @override
  RegisterPokemonPageState createState() => RegisterPokemonPageState();
}

class RegisterPokemonPageState extends State<RegisterPokemonPage> {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );
  final pokeNameController = TextEditingController();
  final pokeNickNameController = TextEditingController();
  final pokeNoController = TextEditingController();
  final pokeLevelController = TextEditingController();
  final pokeTemperController = TextEditingController();
  final pokeStatRaceController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatIndiController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatEffortController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatRealController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeMoveController = List.generate(4, (i) => TextEditingController());
  final pokePPController = List.generate(4, (i) => TextEditingController());

  bool canChangeTeraType = true;

  // TODO:変更したステータスのみ計算する(全部計算する機能も残す)
  void updateRealStat() {
    widget.myPokemon.updateRealStats();

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatRealController[i].text =
          widget.myPokemon.stats[i].real.toString();
    }
    // notify
    setState(() {});
  }

  void updateStatsRefReal(int statIndex) {
    widget.myPokemon.updateStatsRefReal(statIndex);

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatEffortController[i].text =
          widget.myPokemon.stats[i].effort.toString();
      pokeStatIndiController[i].text =
          widget.myPokemon.stats[i].indi.toString();
    }
    // notify
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
    var pokemonState = widget.pokemonState;
    var myPokemon = widget.myPokemon;
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;

    pokeNameController.text = myPokemon.name;
    pokeNickNameController.text = myPokemon.nickname;
    pokeNoController.text = myPokemon.no.toString();
    pokeLevelController.text = myPokemon.level.toString();
    pokeTemperController.text = myPokemon.temper.displayName;
    pokeStatRaceController[0].text =
        myPokemon.name == '' ? 'H -' : 'H ${myPokemon.h.race}';
    pokeStatRaceController[1].text =
        myPokemon.name == '' ? 'A -' : 'A ${myPokemon.a.race}';
    pokeStatRaceController[2].text =
        myPokemon.name == '' ? 'B -' : 'B ${myPokemon.b.race}';
    pokeStatRaceController[3].text =
        myPokemon.name == '' ? 'C -' : 'C ${myPokemon.c.race}';
    pokeStatRaceController[4].text =
        myPokemon.name == '' ? 'D -' : 'D ${myPokemon.d.race}';
    pokeStatRaceController[5].text =
        myPokemon.name == '' ? 'S -' : 'S ${myPokemon.s.race}';
    pokeMoveController[0].text = myPokemon.move1.displayName;
    pokeMoveController[1].text =
        myPokemon.move2 == null ? '' : myPokemon.move2!.displayName;
    pokeMoveController[2].text =
        myPokemon.move3 == null ? '' : myPokemon.move3!.displayName;
    pokeMoveController[3].text =
        myPokemon.move4 == null ? '' : myPokemon.move4!.displayName;

    Future<bool?> showBackDialog() async {
      if (myPokemon != pokeData.pokemons[myPokemon.id]) {
        return showDialog<bool?>(
            context: context,
            builder: (_) {
              return DeleteEditingCheckDialog(
                null,
                () {},
              );
            });
      } else {
        return true;
      }
    }

    void onComplete() async {
      if (myPokemon.id != 0) {
        pokemons[myPokemon.id] = myPokemon;
        // 登録されているパーティのポケモン情報更新
        var parties = appState.parties;
        for (final party in parties.values) {
          var target = party.pokemons
              .indexWhere((element) => element?.id == myPokemon.id);
          if (target >= 0) {
            party.pokemons[target] = myPokemon;
          }
        }
      }
      await pokeData.addMyPokemon(myPokemon, myPokemon.id == 0);
      widget.onFinish();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool? shouldPop = await showBackDialog();
        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: myPokemon.id == 0
                ? Text(loc.pokemonsTabRegisterPokemon)
                : Text(loc.pokemonsTabEditPokemon),
            actions: [
              TextButton(
                onPressed: (myPokemon.isValid &&
                        myPokemon != pokeData.pokemons[myPokemon.id])
                    ? () => onComplete()
                    : null,
                child: Text(loc.registerSave),
              ),
            ]),
        body: ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    // ポケモン名, 図鑑No
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 7,
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: pokeNameController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.pokemonsTabPokemonName,
                            ),
                          ),
                          autoFlipDirection: true,
                          suggestionsCallback: (pattern) async {
                            List<PokeBase> matches = [];
                            matches.addAll(pokeData.pokeBase.values);
                            matches.remove(pokeData.pokeBase[0]);
                            matches.retainWhere((s) {
                              return toKatakana50(s.name.toLowerCase())
                                  .contains(
                                      toKatakana50(pattern.toLowerCase()));
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
                            myPokemon
                              //..name = suggestion.name
                              ..no = suggestion.no // nameも変わる
                              ..type1 = suggestion.type1
                              ..type2 = suggestion.type2
                              ..ability = suggestion.ability[0]
                              ..sex = suggestion.sex[0]
                              ..h.race = suggestion.h
                              ..a.race = suggestion.a
                              ..b.race = suggestion.b
                              ..c.race = suggestion.c
                              ..d.race = suggestion.d
                              ..s.race = suggestion.s
                              ..teraType = suggestion.fixedTeraType;
                            canChangeTeraType =
                                suggestion.fixedTeraType == PokeType.unknown;
                            pokeStatRaceController[0].text =
                                'H ${myPokemon.h.race}';
                            pokeStatRaceController[1].text =
                                'A ${myPokemon.a.race}';
                            pokeStatRaceController[2].text =
                                'B ${myPokemon.b.race}';
                            pokeStatRaceController[3].text =
                                'C ${myPokemon.c.race}';
                            pokeStatRaceController[4].text =
                                'D ${myPokemon.d.race}';
                            pokeStatRaceController[5].text =
                                'S ${myPokemon.s.race}';
                            updateRealStat();
                            myPokemon.move1 = Move(
                                0,
                                '',
                                '',
                                PokeType.unknown,
                                0,
                                0,
                                0,
                                Target.none,
                                DamageClass(0),
                                MoveEffect(0),
                                0,
                                0); // 無効なわざ
                            myPokemon.move2 = null;
                            myPokemon.move3 = null;
                            myPokemon.move4 = null;
                            for (int i = 0; i < 4; i++) {
                              pokeMoveController[i].text = '';
                              myPokemon.pps[i] = 0;
                              pokePPController[i].text = '0';
                            }
                            pokeNameController.text = suggestion.name;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: pokeData.getPokeAPI
                            ? Image.network(
                                pokeData.pokeBase[myPokemon.no]!.imageUrl,
                                errorBuilder: (c, o, s) {
                                  return const Icon(Icons.catching_pokemon);
                                },
                              )
                            : const Icon(Icons.catching_pokemon),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    // ニックネーム
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.pokemonsTabNickName,
                          ),
                          onChanged: (value) {
                            myPokemon.nickname = value;
                          },
                          maxLength: 20,
                          controller: pokeNickNameController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    // タイプ1, タイプ2, テラスタイプ
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TypeDropdownButton(
                          loc.commonType1,
                          null,
                          myPokemon.type1 == PokeType.unknown
                              ? null
                              : myPokemon.type1,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: TypeDropdownButton(
                          loc.commonType2,
                          null,
                          myPokemon.type2 == PokeType.unknown
                              ? null
                              : myPokemon.type2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: TypeDropdownButton(
                          loc.commonTeraType,
                          canChangeTeraType
                              ? (value) {
                                  setState(() {
                                    myPokemon.teraType = value;
                                  });
                                }
                              : null,
                          myPokemon.teraType == PokeType.unknown
                              ? null
                              : myPokemon.teraType,
                          isError: myPokemon.no != 0 &&
                              myPokemon.teraType == PokeType.unknown,
                          isTeraType: true,
                        ),
                      ),
                    ],
                  ),
                  pokemonState != null
                      ? Row(
                          // テラスタイプ
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${loc.pokemonsTabConfTeraType} : ${pokemonState.teraType1 != PokeType.unknown ? pokemonState.teraType1.displayName : loc.commonNone}',
                                  style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize:
                                          theme.textTheme.bodyMedium?.fontSize),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(height: 10),
                  Row(
                    // レベル, せいべつ
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: NumberInputWithIncrementDecrement(
                          controller: pokeLevelController,
                          numberFieldDecoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.commonLevel,
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
                          }, // TODO: いい方法ありそう
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.commonGender,
                          ),
                          items: <DropdownMenuItem<Sex>>[
                            for (var type
                                in pokeData.pokeBase[myPokemon.no]!.sex)
                              DropdownMenuItem(
                                value: type,
                                child: type.displayIcon,
                              ),
                          ],
                          value: myPokemon.sex,
                          onChanged: myPokemon.no != 0
                              ? (value) {
                                  myPokemon.sex = value as Sex;
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    // せいかく, とくせい
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: pokeTemperController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.commonNature,
                              labelStyle:
                                  myPokemon.no != 0 && myPokemon.temper.id == 0
                                      ? notAllowedStyle
                                      : null,
                            ),
                          ),
                          autoFlipDirection: true,
                          suggestionsCallback: (pattern) async {
                            List<Temper> matches = [];
                            matches.addAll(pokeData.tempers.values);
                            matches.remove(pokeData.tempers[0]);
                            matches.retainWhere((s) {
                              return toKatakana50(s.displayName.toLowerCase())
                                  .contains(
                                      toKatakana50(pattern.toLowerCase()));
                            });
                            return matches;
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium,
                                  children: [
                                    TextSpan(text: suggestion.displayName),
                                    suggestion.increasedStat.alphabet != ''
                                        ? TextSpan(
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                            text:
                                                ' ${suggestion.increasedStat.alphabet}')
                                        : TextSpan(),
                                    suggestion.decreasedStat.alphabet != ''
                                        ? TextSpan(
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                            text:
                                                ' ${suggestion.decreasedStat.alphabet}')
                                        : TextSpan(),
                                  ],
                                ),
                              ),
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
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.commonAbility,
                          ),
                          items: <DropdownMenuItem>[
                            for (var ab
                                in pokeData.pokeBase[myPokemon.no]!.ability)
                              DropdownMenuItem(
                                value: ab,
                                child: Text(ab.displayName),
                              )
                          ],
                          value: pokeData.abilities[myPokemon.ability.id],
                          onChanged: (myPokemon.name == '')
                              ? null
                              : (dynamic value) {
                                  myPokemon.ability = value;
                                  setState(() {});
                                },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ の数値入力
                  for (int i = 0; i < StatIndex.size.index; i++)
                    Column(children: [
                      StatInputRow(
                        StatIndexNumber.getStatIndexFromIndex(i).name,
                        myPokemon,
                        pokeStatRaceController[i],
                        pokeStatIndiController[i],
                        pokemonMinIndividual,
                        pokemonMaxIndividual,
                        myPokemon.stats[i].indi,
                        (value) {
                          myPokemon.stats[i].indi = value.toInt();
                          updateRealStat();
                        },
                        pokeStatEffortController[i],
                        pokemonMinEffort,
                        pokemonMaxEffort,
                        myPokemon.stats[i].effort,
                        (value) {
                          myPokemon.stats[i].effort = value.toInt();
                          updateRealStat();
                        },
                        pokeStatRealController[i],
                        myPokemon.stats[i].real,
                        (value) {
                          myPokemon.stats[i].real = value.toInt();
                          updateStatsRefReal(i);
                        },
                        effectTemper: i != 0,
                        statIndex: StatIndexNumber.getStatIndexFromIndex(i),
                        loc: loc,
                      ),
                      pokemonState != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${loc.pokemonsTabConfValueRange} : ${pokemonState.minStats[StatIndexNumber.getStatIndexFromIndex(i)].real} ~ ${pokemonState.maxStats[StatIndexNumber.getStatIndexFromIndex(i)].real}',
                                      style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: theme
                                              .textTheme.bodyMedium?.fontSize),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ]),
                  // ステータスの合計値
                  StatTotalRow(
                    myPokemon.totalRace(),
                    myPokemon.totalEffort(),
                    loc: loc,
                  ),

                  // わざ1, PP1, わざ2, PP2, わざ3, PP3, わざ4, PP4
                  for (int i = 0; i < 4; i++)
                    Column(
                      children: [
                        MoveInputRow(
                          myPokemon,
                          '${loc.commonMove}${i + 1}',
                          'PP',
                          pokeMoveController[i],
                          [
                            for (int j = 0; j < 4; j++)
                              i != j ? myPokemon.moves[j] : null
                          ],
                          (suggestion) {
                            pokeMoveController[i].text = suggestion.displayName;
                            myPokemon.moves[i] = suggestion;
                            pokePPController[i].text = suggestion.pp.toString();
                            myPokemon.pps[i] = suggestion.pp;
                            setState(() {});
                          },
                          () {
                            for (int j = i; j < 4; j++) {
                              if (j + 1 < 4 && myPokemon.moves[j + 1] != null) {
                                pokeMoveController[j].text =
                                    myPokemon.moves[j + 1]!.displayName;
                                myPokemon.moves[j] = myPokemon.moves[j + 1];
                                pokePPController[j].text =
                                    '${myPokemon.pps[j + 1]}';
                                myPokemon.pps[j] = myPokemon.pps[j + 1];
                              } else {
                                pokeMoveController[j].text = '';
                                myPokemon.moves[j] = j == 0
                                    ? Move(
                                        0,
                                        '',
                                        '',
                                        PokeType.unknown,
                                        0,
                                        0,
                                        0,
                                        Target.none,
                                        DamageClass(0),
                                        MoveEffect(0),
                                        0,
                                        0)
                                    : null;
                                pokePPController[j].text = '0';
                                myPokemon.pps[j] = 0;
                                break;
                              }
                            }
                            setState(() {});
                          },
                          pokePPController[i],
                          (value) {
                            myPokemon.pps[i] = value.toInt();
                          },
                          minPP: myPokemon.moves[i] != null
                              ? myPokemon.moves[i]!.minPP
                              : 0,
                          maxPP: myPokemon.moves[i] != null
                              ? myPokemon.moves[i]!.maxPP
                              : 0,
                          moveEnabled: i == 0
                              ? myPokemon.name != ''
                              : myPokemon.moves[i - 1] != null &&
                                  myPokemon.moves[i - 1]!.id != 0,
                          ppEnabled: myPokemon.moves[i] != null &&
                              myPokemon.moves[i]!.id != 0,
                          initialPPValue: myPokemon.pps[i] ?? 0,
                          isError: i == 0 &&
                              myPokemon.no != 0 &&
                              myPokemon.move1.id == 0,
                        ),
                        pokemonState != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        i < pokemonState.moves.length
                                            ? '${loc.pokemonsTabConfMove}${i + 1} : ${pokeData.moves[pokemonState.moves[i].id]!.displayName}'
                                            : '',
                                        style: TextStyle(
                                            color: theme.primaryColor,
                                            fontSize: theme.textTheme.bodyMedium
                                                ?.fontSize),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
