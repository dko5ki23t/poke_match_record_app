import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
import 'package:poke_reco/custom_widgets/pokemon_sex_input_row.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class BattleBasicListView extends ListView {
  BattleBasicListView(
    BuildContext context,
    void Function() setState,
    Battle battle,
    List<Party> parties,
    ThemeData theme,
    TextEditingController battleNameController,
    TextEditingController opponentNameController,
    TextEditingController dateController,
    List<TextEditingController> opponentPokemonController,
  ) : 
  super(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(  // バトル名
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: battleNameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'バトル名'
                    ),
                    onChanged: (value) {
                      battle.name = value;
                      //setState();
                    },
                    maxLength: 10,
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
                    controller: dateController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '対戦日'
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
                          DatePicker.showTimePicker(context,
                            showTitleActions: true,
                            showSecondsColumn: false,
                            onConfirm: (time) {
                              battle.time = time;
                              dateController.text = battle.formattedDateTime;
                            },
                            currentTime: battle.datetime,
                            locale: LocaleType.jp,
                          );
                        },
                        currentTime: battle.datetime,
                        locale: LocaleType.jp
                      );
                    },
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
                          value: type.id,
                          child: Text(type.displayName),
                      ),
                    ],
                    value: battle.type.id,
                    onChanged: (value) {battle.type = BattleType.createFromId(value); setState();},
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
                        for (final party in parties.where((element) => element.owner == Owner.mine).toList())
                          Text(party.name),
                      ];
                    },
                    items: <DropdownMenuItem>[
                      for (final party in parties.where((element) => element.owner == Owner.mine).toList())
                        DropdownMenuItem(
                          value: party.id,
                          child: PartyTile(party, theme,),
                        ),
                    ],
                    value: battle.getParty(PlayerType(PlayerType.me)).id == 0 ? null : battle.getParty(PlayerType(PlayerType.me)).id,
                    onChanged: (value) {
                      // 各ポケモンのレベルを50にするためコピー作成
                      battle.setParty(PlayerType(PlayerType.me), parties.where((element) => element.id == value).first.copyWith());
                      for (int i = 0; i < battle.getParty(PlayerType(PlayerType.me)).pokemonNum; i++) {
                        battle.getParty(PlayerType(PlayerType.me)).pokemons[i] = battle.getParty(PlayerType(PlayerType.me)).pokemons[i]!.copyWith();
                        battle.getParty(PlayerType(PlayerType.me)).pokemons[i]!.level = 50;
                      }
                      setState();
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
                    controller: opponentNameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'あいての名前'
                    ),
                    onChanged: (value) {
                      battle.opponentName = value;
                      //setState();
                    },
                    maxLength: 10,
//                          controller: partyNameController,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            for (int i = 0; i < 6; i++)
              PokemonSexInputRow(
                'ポケモン${i+1}',
                [for (int j = 0; j < 6; j++)
                  i != j ? PokeDB().pokeBase[battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j]?.no]
                  : null
                ],
                opponentPokemonController[i],
                (suggestion) {
                  battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] ??= Pokemon();
                  battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!
                  ..name = suggestion.name
                  ..no = suggestion.no
                  ..type1 = suggestion.type1
                  ..type2 = suggestion.type2
                  ..sex = suggestion.sex[0]
                  ..h.race = suggestion.h
                  ..a.race = suggestion.a
                  ..b.race = suggestion.b
                  ..c.race = suggestion.c
                  ..d.race = suggestion.d
                  ..s.race = suggestion.s;
                  opponentPokemonController[i].text = suggestion.name;
                  setState();
                },
                () {
                  for (int j = i; j < 6; j++) {
                    if (j+1 < 6 && battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j+1] != null) {
                      opponentPokemonController[j].text = battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j+1]!.name;
                      battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j] = battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j+1];
                    }
                    else {
                      opponentPokemonController[j].text = '';
                      battle.getParty(PlayerType(PlayerType.opponent)).pokemons[j] = j == 0 ?
                        Pokemon() : null;
                      break; 
                    }
                  }
                  setState();
                },
                'せいべつ${i+1}',
                battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] != null ?
                  PokeDB().pokeBase[battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]?.no]!.sex : [Sex.none],
                battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] != null ?
                  battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!.sex : Sex.none,
                battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i] != null ?
                  (value) {battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i]!.sex = value;}
                  : null,
                enabledPokemon: i != 0 ? battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i-1] != null && battle.getParty(PlayerType(PlayerType.opponent)).pokemons[i-1]!.no >= pokemonMinNo : true,
              ),
              SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
      ),
    ],
  );
}