import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/poke_db.dart';
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
    TextEditingController hpController,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      _BattleMoveInputColumn(
        1, setState, theme, battle, turn, pokeData,
        initialOwnPokemon, initialOpponentPokemon,
        currentOwnPokemon, currentOpponentPokemon,
        turnMove1, move1Controller, hpController,
        null
      ),
      SizedBox(height: 10,),
      _BattleMoveInputColumn(
        2, setState, theme, battle, turn, pokeData,
        initialOwnPokemon, initialOpponentPokemon,
        currentOwnPokemon, currentOpponentPokemon,
        turnMove2, move2Controller, hpController,
        turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1].hp == 0 ?
          battle.ownParty :
          turn.opponentPokemonCurrentStates[turn.initialOpponentPokemonIndex-1].hpPercent == 0 ?
            battle.opponentParty : null
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
    Party? faintingParty,
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
            faintingParty != null ?
            Expanded(
              flex: 5,
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '行動主',
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: PlayerType.me,
                    child: Text('あなた', overflow: TextOverflow.ellipsis,),
                  ),
                  DropdownMenuItem(
                    value: PlayerType.opponent,
                    child: Text(battle.opponentName, overflow: TextOverflow.ellipsis,),
                  ),
                ],
                value: turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1].hp == 0 ? PlayerType.me : PlayerType.opponent,
                onChanged: null,
              ),
            ) :
            Expanded(
              flex: 5,
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '行動主',
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: PlayerType.me,
                    child: Text('${initialOwnPokemon.name}/あなた', overflow: TextOverflow.ellipsis,),
                  ),
                  DropdownMenuItem(
                    value: PlayerType.opponent,
                    child: Text('${initialOpponentPokemon.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                  ),
                ],
                value: turnMove.playerType == PlayerType.none ? null : turnMove.playerType,
                onChanged: (value) {turnMove.playerType = value; setState();},
              ),
            ),
            SizedBox(width: 10,),
            faintingParty != null ?
            Expanded(
              flex: 5,
              child: DropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'ポケモン交換',
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < faintingParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(faintingParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,),
                    ),
                ],
                onChanged: (value) {
                  turnMove.playerType =
                    turn.ownPokemonCurrentStates[turn.initialOwnPokemonIndex-1].hp == 0 ? PlayerType.me : PlayerType.opponent;
                  turnMove.changePokemonIndex = value+1;
                  setState();
                },
              ),
             ) :
            Expanded(
              flex: 5,
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
        ),
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
