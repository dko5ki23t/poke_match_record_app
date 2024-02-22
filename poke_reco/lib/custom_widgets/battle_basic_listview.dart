import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/pokemon_sex_row.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleBasicListView extends StatelessWidget {
  BattleBasicListView(
    this.setState,
    this.battle,
    this.parties,
    this.theme,
    this.battleNameController,
    this.opponentNameController,
    this.dateController,
    this.opponentPokemonController,
    this.ownPartyController,
    this.onSelectParty, {
    required this.isInput,
    this.showNetworkImage = false,
    required this.loc,
  });

  final void Function() setState;
  final Battle battle;
  final Map<int, Party> parties;
  final ThemeData theme;
  final TextEditingController battleNameController;
  final TextEditingController opponentNameController;
  final TextEditingController dateController;
  final List<TextEditingController> opponentPokemonController;
  final TextEditingController ownPartyController;
  final Future<Party?> Function() onSelectParty;
  final bool isInput;
  final bool showNetworkImage;
  final AppLocalizations loc;

  @override
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: Key('BattleBasicListView'), // テストでの識別用
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                // バトル名
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: isInput
                        ? TextFormField(
                            key: Key(
                                'BattleBasicListViewBattleName'), // テストでの識別用
                            controller: battleNameController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleName,
                            ),
                            onChanged: (value) {
                              battle.name = value;
                              setState();
                            },
                            maxLength: 20,
                          )
                        : TextField(
                            controller: battleNameController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleName,
                            ),
                            maxLength: 20,
                            readOnly: true,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                // 対戦日時
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: isInput
                        ? TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleDatetime,
                            ),
                            onTap: () {
                              // キーボードが出ないようにする
                              FocusScope.of(context).requestFocus(FocusNode());
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2000, 1, 1),
                                  maxTime: DateTime(2200, 12, 31),
                                  onConfirm: (date) {
                                battle.date = date;
                                DatePicker.showTimePicker(
                                  context,
                                  showTitleActions: true,
                                  showSecondsColumn: false,
                                  onConfirm: (time) {
                                    battle.time = time;
                                    dateController.text =
                                        battle.formattedDateTime;
                                  },
                                  currentTime: battle.datetime,
                                  locale: LocaleType.jp,
                                );
                              },
                                  currentTime: battle.datetime,
                                  locale: LocaleType.jp);
                            },
                          )
                        : TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleDatetime,
                            ),
                            readOnly: true,
                          ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: isInput
                        ? DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleType,
                            ),
                            items: <DropdownMenuItem>[
                              for (var type in BattleType.values)
                                DropdownMenuItem(
                                  value: type.id,
                                  child: Text(type.displayName),
                                ),
                            ],
                            value: battle.type.id,
                            onChanged: (value) {
                              battle.type = BattleType.createFromId(value);
                              setState();
                            },
                          )
                        : TextField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabBattleType,
                            ),
                            controller: TextEditingController(
                                text: battle.type.displayName),
                            readOnly: true,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: isInput
                        ? TextFormField(
                            key:
                                Key('BattleBasicListViewYourParty'), // テストでの識別用
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabYourParty,
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            controller: ownPartyController,
                            onTap: () async {
                              var party = await onSelectParty();
                              if (!context.mounted) {
                                return; // クラッシュ回避用 https://dart.dev/tools/linter-rules/use_build_context_synchronously
                              }
                              if (party != null) {
                                if (battle.getParty(PlayerType.me).id !=
                                        party.id &&
                                    battle.turns.isNotEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return DeleteEditingCheckDialog(
                                          loc.battlesTabQuestionChangeParty,
                                          () {
                                            // 各ポケモンのレベルを50にするためコピー作成
                                            battle.setParty(
                                                PlayerType.me,
                                                parties.values
                                                    .where((element) =>
                                                        element.id == party.id)
                                                    .first
                                                    .copy());
                                            for (int i = 0;
                                                i <
                                                    battle
                                                        .getParty(PlayerType.me)
                                                        .pokemonNum;
                                                i++) {
                                              battle
                                                      .getParty(PlayerType.me)
                                                      .pokemons[i] =
                                                  battle
                                                      .getParty(PlayerType.me)
                                                      .pokemons[i]!
                                                      .copy();
                                              battle
                                                  .getParty(PlayerType.me)
                                                  .pokemons[i]!
                                                  .level = 50;
                                              battle
                                                  .getParty(PlayerType.me)
                                                  .pokemons[i]!
                                                  .updateRealStats();
                                            }
                                            battle.turns.clear();
                                            setState();
                                          },
                                        );
                                      });
                                } else {
                                  // 各ポケモンのレベルを50にするためコピー作成
                                  battle.setParty(
                                      PlayerType.me,
                                      parties.values
                                          .where((element) =>
                                              element.id == party.id)
                                          .first
                                          .copy());
                                  for (int i = 0;
                                      i <
                                          battle
                                              .getParty(PlayerType.me)
                                              .pokemonNum;
                                      i++) {
                                    battle.getParty(PlayerType.me).pokemons[i] =
                                        battle
                                            .getParty(PlayerType.me)
                                            .pokemons[i]!
                                            .copy();
                                    battle
                                        .getParty(PlayerType.me)
                                        .pokemons[i]!
                                        .level = 50;
                                    battle
                                        .getParty(PlayerType.me)
                                        .pokemons[i]!
                                        .updateRealStats();
                                  }
                                  setState();
                                }
                              }
                            })
                        : TextField(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabYourParty,
                            ),
                            controller: ownPartyController,
                            readOnly: true,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                // あいての名前
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: isInput
                        ? TextFormField(
                            key: Key(
                                'BattleBasicListViewOpponentName'), // テストでの識別用
                            controller: opponentNameController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabOpponentName,
                            ),
                            onChanged: (value) {
                              battle.opponentName = value;
                              setState();
                            },
                            maxLength: 20,
                          )
                        : TextField(
                            controller: opponentNameController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: loc.battlesTabOpponentName,
                            ),
                            maxLength: 20,
                            readOnly: true,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(loc.battlesTabOpponentParty),
              SizedBox(height: 10),
              for (int i = 0; i < 6; i++)
                PokemonSexRow(
                  theme,
                  '${loc.commonPokemon}${i + 1}',
                  [
                    for (int j = 0; j < 6; j++)
                      i != j
                          ? PokeDB().pokeBase[battle
                              .getParty(PlayerType.opponent)
                              .pokemons[j]
                              ?.no]
                          : null
                  ],
                  battle.getParty(PlayerType.opponent).pokemons[i] != null
                      ? battle.getParty(PlayerType.opponent).pokemons[i]!.no
                      : 0,
                  opponentPokemonController[i],
                  (suggestion) {
                    if (battle.turns.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteEditingCheckDialog(
                              loc.battlesTabQuestionChangePokemon,
                              () {
                                battle
                                    .getParty(PlayerType.opponent)
                                    .pokemons[i] ??= Pokemon();
                                battle
                                    .getParty(PlayerType.opponent)
                                    .pokemons[i]!
                                  //..name = suggestion.name
                                  ..no = suggestion.no // nameも変わる
                                  ..type1 = suggestion.type1
                                  ..type2 = suggestion.type2
                                  ..sex = suggestion.sex[0]
                                  ..h.race = suggestion.h
                                  ..a.race = suggestion.a
                                  ..b.race = suggestion.b
                                  ..c.race = suggestion.c
                                  ..d.race = suggestion.d
                                  ..s.race = suggestion.s
                                  ..teraType = suggestion.fixedTeraType;
                                battle.turns.clear();
                                opponentPokemonController[i].text =
                                    suggestion.name;
                                setState();
                              },
                            );
                          });
                    } else {
                      battle.getParty(PlayerType.opponent).pokemons[i] ??=
                          Pokemon();
                      battle.getParty(PlayerType.opponent).pokemons[i]!
                        //..name = suggestion.name
                        ..no = suggestion.no // nameも変わる
                        ..type1 = suggestion.type1
                        ..type2 = suggestion.type2
                        ..sex = suggestion.sex[0]
                        ..h.race = suggestion.h
                        ..a.race = suggestion.a
                        ..b.race = suggestion.b
                        ..c.race = suggestion.c
                        ..d.race = suggestion.d
                        ..s.race = suggestion.s
                        ..teraType = suggestion.fixedTeraType;
                      opponentPokemonController[i].text = suggestion.name;
                      setState();
                    }
                  },
                  () {
                    if (battle.turns.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return DeleteEditingCheckDialog(
                            loc.battlesTabQuestionChangePokemon,
                            () {
                              for (int j = i; j < 6; j++) {
                                if (j + 1 < 6 &&
                                    battle
                                            .getParty(PlayerType.opponent)
                                            .pokemons[j + 1] !=
                                        null) {
                                  opponentPokemonController[j].text = battle
                                      .getParty(PlayerType.opponent)
                                      .pokemons[j + 1]!
                                      .name;
                                  battle
                                          .getParty(PlayerType.opponent)
                                          .pokemons[j] =
                                      battle
                                          .getParty(PlayerType.opponent)
                                          .pokemons[j + 1];
                                } else {
                                  opponentPokemonController[j].text = '';
                                  battle
                                      .getParty(PlayerType.opponent)
                                      .pokemons[j] = j == 0 ? Pokemon() : null;
                                  break;
                                }
                              }
                              battle.turns.clear();
                              setState();
                            },
                          );
                        },
                      );
                    } else {
                      for (int j = i; j < 6; j++) {
                        if (j + 1 < 6 &&
                            battle
                                    .getParty(PlayerType.opponent)
                                    .pokemons[j + 1] !=
                                null) {
                          opponentPokemonController[j].text = battle
                              .getParty(PlayerType.opponent)
                              .pokemons[j + 1]!
                              .name;
                          battle.getParty(PlayerType.opponent).pokemons[j] =
                              battle
                                  .getParty(PlayerType.opponent)
                                  .pokemons[j + 1];
                        } else {
                          opponentPokemonController[j].text = '';
                          battle.getParty(PlayerType.opponent).pokemons[j] =
                              j == 0 ? Pokemon() : null;
                          break;
                        }
                      }
                      setState();
                    }
                  },
                  '${loc.commonGender}${i + 1}',
                  battle.getParty(PlayerType.opponent).pokemons[i] != null
                      ? PokeDB()
                          .pokeBase[battle
                              .getParty(PlayerType.opponent)
                              .pokemons[i]
                              ?.no]!
                          .sex
                      : [Sex.none],
                  battle.getParty(PlayerType.opponent).pokemons[i] != null
                      ? battle.getParty(PlayerType.opponent).pokemons[i]!.sex
                      : Sex.none,
                  battle.getParty(PlayerType.opponent).pokemons[i] != null
                      ? (value) {
                          battle
                              .getParty(PlayerType.opponent)
                              .pokemons[i]!
                              .sex = value;
                        }
                      : null,
                  enabledPokemon: i != 0
                      ? battle.getParty(PlayerType.opponent).pokemons[i - 1] !=
                              null &&
                          battle
                                  .getParty(PlayerType.opponent)
                                  .pokemons[i - 1]!
                                  .no >=
                              pokemonMinNo
                      : true,
                  showNetworkImage: showNetworkImage,
                  isInput: isInput,
                ),
              SizedBox(height: 20),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
