import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/poke_move.dart';
import 'package:poke_reco/tool.dart';

class BattleMoveInputColumn extends Column {
  BattleMoveInputColumn(
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    PokeDB pokeData,
    Pokemon initialOwnPokemon,
    Pokemon initialOpponentPokemon,
    Pokemon currentOwnPokemon,
    Pokemon currentOpponentPokemon,
    TurnMove turnMove1,
    TextEditingController move1Controller,
    TurnMove turnMove2,
    TextEditingController move2Controller,
    TextEditingController hpController1,
    TextEditingController hpController2,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _BattleMoveInputColumn(
        1, setState, theme, battle, turn, pokeData,
        initialOwnPokemon, initialOpponentPokemon,
        currentOwnPokemon, currentOpponentPokemon,
        turnMove1, move1Controller, hpController1,
//        null
      ),
      SizedBox(height: 10,),
      _BattleMoveInputColumn(
        2, setState, theme, battle, turn, pokeData,
        initialOwnPokemon, initialOpponentPokemon,
        currentOwnPokemon, currentOpponentPokemon,
        turnMove2, move2Controller, hpController2,
/*
        turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1].hp == 0 ?
          battle.ownParty :
          turn.opponentPokemonCurrentStates[turn.initialOpponentPokemonIndex-1].hpPercent == 0 ?
            battle.opponentParty : null
*/
      ),
    ],
  );
}

class _BattleMoveInputColumn extends Container {
  _BattleMoveInputColumn(
    int no,
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    PokeDB pokeData,
    Pokemon initialOwnPokemon,
    Pokemon initialOpponentPokemon,
    Pokemon currentOwnPokemon,
    Pokemon currentOpponentPokemon,
    TurnMove turnMove,
    TextEditingController moveController,
    TextEditingController hpController,
  ) :
  super(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: theme.primaryColor),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Stack(
          children: [
          Center(child: Text('行動$no')),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: turnMove.isValid() ? () {
                  turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                  setState();
                } : null,
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  turnMove.clear();
                  turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                  setState();
                },
              ),
            ],
          ),
        ],),
        SizedBox(height: 10,),
        Row(
          children: [
            //ひんしポケモンがいる場合はポケモン交換
            Expanded(
              flex: 5,
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '行動主',
                ),
                items: <DropdownMenuItem<PlayerType>>[
                  DropdownMenuItem<PlayerType>(
                    value: PlayerType.me,
                    child: Text('${initialOwnPokemon.name}/あなた', overflow: TextOverflow.ellipsis,),
                  ),
                  DropdownMenuItem(
                    value: PlayerType.opponent,
                    child: Text('${initialOpponentPokemon.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                  ),
                ],
                value: turnMove.playerType == PlayerType.none ? null : turnMove.playerType,
                onChanged: (value) {turnMove.playerType = value as PlayerType; setState();},
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 5,
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '行動の種類',
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: TurnMoveType.move,
                    child: Text('わざ', overflow: TextOverflow.ellipsis,),
                  ),
                  DropdownMenuItem(
                    value: TurnMoveType.change,
                    child: Text('ポケモン交換', overflow: TextOverflow.ellipsis,),
                  ),
                  DropdownMenuItem(
                    value: TurnMoveType.surrender,
                    child: Text('こうさん', overflow: TextOverflow.ellipsis,),
                  ),
                ],
                value: turnMove.type == TurnMoveType.none ? null : turnMove.type,
                onChanged: (value) {
                  turnMove.type = value;
                  setState();
                },
              ),
             )
            
          ],
        ),
        SizedBox(height: 10,),
        turnMove.type == TurnMoveType.move ?
        // TODO:わざの場合はテラスタルも
        Row(
          children: [
            Expanded(
//            flex: 5,
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: moveController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'わざ',
                  ),
                  enabled: turnMove.playerType != PlayerType.none,
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<Move> matches = [];
                  if (turnMove.playerType == PlayerType.me) {
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
                  moveController.text = suggestion.displayName;
                  turnMove.move = suggestion;
                  turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                  setState();
                },
              ),
            ),
          ],
        ) :
        turnMove.type == TurnMoveType.change ?
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '交換先ポケモン',
                ),
                items: turnMove.playerType == PlayerType.me ?
                  <DropdownMenuItem>[
                    for (int i = 0; i < battle.ownParty.pokemonNum; i++)
                      DropdownMenuItem(
                        value: i+1,
                        enabled: i+1 != turn.currentOwnPokemonIndex,
                        child: Text(battle.ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,),
                      ),
                  ] :
                  <DropdownMenuItem>[
                    for (int i = 0; i < battle.opponentParty.pokemonNum; i++)
                      DropdownMenuItem(
                        value: i+1,
                        enabled: i+1 != turn.currentOpponentPokemonIndex,
                        child: Text(battle.opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,),
                      ),
                  ],
                value: turnMove.changePokemonIndex,
                onChanged: (value) {
//              turnMove.playerType =
//                turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1].hp == 0 ? PlayerType.me : PlayerType.opponent;
                  turnMove.changePokemonIndex = value;
                  setState();
                },
              ),
            ),
          ],
        ) :
        // こうさん時は何もなし
        Row(),
        SizedBox(height: 10,),
        turnMove.extraInputWidget(
          setState, currentOwnPokemon, currentOpponentPokemon,
          turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1],
          turn.opponentPokemonCurrentStates[turn.initialOpponentPokemonIndex-1],
          hpController,
        ),
      ],
    ),
  );
}
