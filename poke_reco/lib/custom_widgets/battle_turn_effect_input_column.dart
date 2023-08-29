import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

class BattleTurnEffectInputColumn extends Column {
  // TODO:これでいける？
  static int editingIndex = 0;
  static bool lockEditTargetChange = false;
  
  BattleTurnEffectInputColumn(
    void Function() setState,
    ThemeData theme,
    Battle battle,
    Turn turn,
    List<TurnEffect> turnEffects,
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < turnEffects.length; i++)
        i+1 == editingIndex ?
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                Center(child: Text('処理${i+1}')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: turnEffects[i].isValid() ? () {
                        lockEditTargetChange = false;
                        editingIndex = 0;
                        turn.updateCurrentStates(battle.ownParty, battle.opponentParty);
                        setState();
                      } : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        turnEffects.removeAt(i);
                        lockEditTargetChange = false;
                        editingIndex = 0;
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
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '発動主',
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: PlayerType.me,
                          child: Text('${battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.name}/あなた', overflow: TextOverflow.ellipsis,),
                        ),
                        DropdownMenuItem(
                          value: PlayerType.opponent,
                          child: Text('${battle.opponentParty.pokemons[turn.currentOpponentPokemonIndex-1]!.name}/${battle.opponentName}', overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                      value: turnEffects[i].playerType == PlayerType.none ? null : turnEffects[i].playerType,
                      onChanged: (value) {turnEffects[i].playerType = value; setState();},
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '発動効果',
                      ),
                      items: turnEffects[i].playerType == PlayerType.me ?
                        battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.ability.timing.id == 1 && turn.changedOwnPokemon ?
                          <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.ability.effect.id,
                              child: Text(battle.ownParty.pokemons[turn.currentOwnPokemonIndex-1]!.ability.displayName, overflow: TextOverflow.ellipsis,),
                            ),
                          ] :
                        [] :
                      [],
                      value: turnEffects[i].effectId == 0 ? null : turnEffects[i].effectId,
                      onChanged: (value) {turnEffects[i].effectId = value! as int; setState();},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) :
        TextButton(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('処理${i+1}')),
          ),
          onPressed: () {
            if (!lockEditTargetChange) editingIndex = i+1;
            setState();
          },
        ),
      // 処理追加ボタン
      TextButton(
        onPressed: turn.canAddBeforemoveEffects() && !lockEditTargetChange ?
          () {
            lockEditTargetChange = true;
            turnEffects.add(TurnEffect()..effect = EffectType.ability);
            editingIndex = turnEffects.length;
            setState();
          } : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle),
              Text('わざ選択前処理を追加'),
            ],
          ),
        ),
      ),
    ],
  );
}