import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
import 'package:poke_reco/custom_widgets/pokemon_sex_input_row.dart';
import 'package:poke_reco/poke_db.dart';

class BattleBasicListView extends ListView {
  BattleBasicListView(
    void Function() setState,
    Battle battle,
    List<Party> parties,
    ThemeData theme,
    PokeDB pokeData,
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
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'バトル名'
                    ),
                    onChanged: (value) {
                      battle.name = value;
                      battle.updateIsValid();
                      setState();
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
                      battle.datatime = DateTime.parse(value);
//                            widget.battle.updateIsValid();
//                            setState(() {});
                    },
                    initialValue: battle.datatime.toIso8601String(),
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
                    onChanged: (value) {battle.type = value;},
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
                      battle.ownParty = parties[value - 1];
                      battle.updateIsValid();
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
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'あいての名前'
                    ),
                    onChanged: (value) {
                      battle.opponentName = value;
                      battle.updateIsValid();
                      setState();
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
                'ポケモン${i+1}', pokeData,
                [for (int j = 0; j < 6; j++)
                  i != j ? pokeData.pokeBase[battle.opponentParty.pokemons[j]?.no]
                  : null
                ],
                opponentPokemonController[i],
                (suggestion) {
                  battle.opponentParty.pokemons[i] ??= Pokemon();
                  battle.opponentParty.pokemons[i]!
                  ..name = suggestion.name
                  ..no = suggestion.no
                  ..type1 = suggestion.type1
                  ..type2 = suggestion.type2
                  ..h.race = suggestion.h
                  ..a.race = suggestion.a
                  ..b.race = suggestion.b
                  ..c.race = suggestion.c
                  ..d.race = suggestion.d
                  ..s.race = suggestion.s;
                  opponentPokemonController[i].text = suggestion.name;
                  battle.updateIsValid();
                  setState();
                },
                'せいべつ${i+1}',
                battle.opponentParty.pokemons[i] != null ?
                  (value) {battle.opponentParty.pokemons[i]!.sex = value;}
                  : null,
                enabledPokemon: i != 0 ? battle.opponentParty.pokemons[i-1] != null && battle.opponentParty.pokemons[i-1]!.no >= pokemonMinNo : true,
              ),
              SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
      ),
    ],
  );
}