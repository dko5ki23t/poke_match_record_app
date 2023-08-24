import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/tool.dart';

class BattleTurnListView extends ListView {
  BattleTurnListView(
    void Function() setState,
    Battle battle,
    ThemeData theme,
    PokeDB pokeData,
    Pokemon currentOwnPokemon,
    Pokemon currentOpponentPokemon,
    int turnPlayer1,
    int turnPlayer2,
    TextEditingController move1Controller,
    TextEditingController move2Controller,
    TextEditingController hp1Controller,
  ) : 
  super(
    children: [
      Container(
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
                                    child: Text('${currentOpponentPokemon.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                                  ),
                                ],
                                value: turnPlayer1,
                                onChanged: (value) {turnPlayer1 = value; setState();},
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
                                controller: hp1Controller,
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
      ),
    ],
  );
}