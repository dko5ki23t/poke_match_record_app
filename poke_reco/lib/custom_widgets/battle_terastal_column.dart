import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/tool.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleTerastalColumn extends Column {
  BattleTerastalColumn(
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    PhaseState prevState,       // 直前までの状態
    List<TurnEffectAndStateAndGuide> sameTimingList,
    int firstIdx,
    Timing timing,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < sameTimingList.length; i++)
        !sameTimingList[i].turnEffect.isAdding ?
        Column(
          children: [
            GestureDetector(
              onTap: focusPhaseIdx != firstIdx+i+1 ? () => onFocus(firstIdx+i+1) : (){},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: focusPhaseIdx == firstIdx+i+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    isInput ?
                      Stack(
                        children: [
                        Center(child: Text('${loc.commonTerastal}${i+1}')),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:[
                            // 編集中でなければ並べ替えボタン
                            !appState.editingPhase[firstIdx+i] ?
                            IconButton(
                              icon: Icon(Icons.arrow_upward),
                              onPressed: i != 0 ? () {
                                TurnEffect.swap(turn.phases, firstIdx+i-1, firstIdx+i);
                                listShallowSwap(appState.editingPhase, firstIdx+i-1, firstIdx+i);
                                appState.needAdjustPhases = firstIdx+i-1;
                                onFocus(firstIdx+i);
                              }: null,
                            ) : Container(),
                            !appState.editingPhase[firstIdx+i] ?
                            IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: i < sameTimingList.length-1 && !sameTimingList[i+1].turnEffect.isAdding ? () {
                                TurnEffect.swap(turn.phases, firstIdx+i, firstIdx+i+1);
                                listShallowSwap(appState.editingPhase, firstIdx+i, firstIdx+i+1);
                                appState.needAdjustPhases = firstIdx+i;
                                onFocus(firstIdx+i+2);
                              } : null,
                            ) :
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: turn.phases[firstIdx+i].isValid() ? () {
                                appState.editingPhase[firstIdx+i] = false;
                                appState.needAdjustPhases = firstIdx+i+1;
                                onFocus(firstIdx+i+1);
                              } : null,
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                if (i == 0) {
                                  var timing = turn.phases[firstIdx+i].timing;
                                  turn.phases[firstIdx+i] =
                                    TurnEffect()
                                    ..timing = timing
                                    ..isAdding = true;
                                  appState.editingPhase[firstIdx+i] = false;
                                  textEditControllerList1[firstIdx+i].text = '';
                                  textEditControllerList2[firstIdx+i].text = '';
                                  textEditControllerList3[firstIdx+i].text = '';
                                  textEditControllerList4[firstIdx+i].text = '';
                                }
                                else {
                                  turn.phases.removeAt(firstIdx+i);
                                  appState.editingPhase.removeAt(firstIdx+i);
                                  textEditControllerList1.removeAt(firstIdx+i);
                                  textEditControllerList2.removeAt(firstIdx+i);
                                  textEditControllerList3.removeAt(firstIdx+i);
                                  textEditControllerList4.removeAt(firstIdx+i);
                                }
                                appState.adjustPhaseByDelete = true;
                                appState.needAdjustPhases = firstIdx+i;
                                onFocus(0);   // フォーカスリセット
                              },
                            ),
                          ],
                        ),
                      ],) :
                      Center(child: Text('${loc.commonTerastal}${i+1}')),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: isInput ?
                            DropdownButtonFormField(
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: loc.battleEffectPlayer,
                              ),
                              items: <DropdownMenuItem>[
                                _myDropDown(
                                  !_getPrevState(prevState, i, sameTimingList).hasOwnTerastal,
                                  PlayerType.me.number,
                                  '${_getPrevState(prevState, i, sameTimingList).getPokemonState(PlayerType.me, null).pokemon.name}/${loc.battleYou}',
                                ),
                                _myDropDown(
                                  !_getPrevState(prevState, i, sameTimingList).hasOpponentTerastal,
                                  PlayerType.opponent.number,
                                  '${_getPrevState(prevState, i, sameTimingList).getPokemonState(PlayerType.opponent, null).pokemon.name}/${battle.opponentName}',
                                ),
                              ],
                              value: turn.phases[firstIdx+i].playerType == PlayerType.none ? null : turn.phases[firstIdx+i].playerType,
                              onChanged: (value) {
                                turn.phases[firstIdx+i].playerType = PlayerTypeNum.createFromNumber(value);
                                var teraType = _getPrevState(prevState, i, sameTimingList).getPokemonState(turn.phases[firstIdx+i].playerType, null).pokemon.teraType;
                                if (teraType.id != 0) {
                                  turn.phases[firstIdx+i].effectId = teraType.id;
                                }
                                else {
                                  turn.phases[firstIdx+i].effectId = 1;
                                }
                                appState.editingPhase[firstIdx+i] = true;
                                onFocus(firstIdx+i+1);
                              },
                            ) :
                            TextField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: loc.battleEffectPlayer,
                              ),
                              controller: TextEditingController(
                                text: turn.phases[firstIdx+i].playerType == PlayerType.me ?
                                      '${_getPrevState(prevState, i, sameTimingList).getPokemonState(PlayerType.me, null).pokemon.name}/${loc.battleYou}' :
                                      '${_getPrevState(prevState, i, sameTimingList).getPokemonState(PlayerType.opponent, null).pokemon.name}/${battle.opponentName}',
                              ),
                              readOnly: true,
                              onTap: () => onFocus(firstIdx+i+1),
                            ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: isInput ?
                            TypeDropdownButton(
                              loc.commonType,
                              turn.phases[firstIdx+i].effectId == 0 ||
                              _getPrevState(prevState, i, sameTimingList).getPokemonState(turn.phases[firstIdx+i].playerType, null).pokemon.teraType.id != 0 ?
                                null : (val) {turn.phases[firstIdx+i].effectId = val;},
                              turn.phases[firstIdx+i].effectId == 0 ? null : turn.phases[firstIdx+i].effectId,
                              isTeraType: true,
                            ) :
                            TextField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: loc.commonType,
                                prefixIcon: PokeType.createFromId(turn.phases[firstIdx+i].effectId).displayIcon,
                              ),
                              controller: TextEditingController(
                                text: PokeType.createFromId(turn.phases[firstIdx+i].effectId).displayName,
                              ),
                              readOnly: true,
                              onTap: () => onFocus(firstIdx+i+1),
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ) :
        isInput ?
          // 処理追加ボタン
          TextButton(
            onPressed: getSelectedNum(appState.editingPhase.sublist(firstIdx, firstIdx+sameTimingList.length)) == 0 ?
              () {
                turn.phases[firstIdx+i].isAdding = false;
                appState.editingPhase[firstIdx+i] = true;
//                appState.editingPhase.insert(firstIdx+i+1, false);
//                textEditControllerList1.insert(firstIdx+i+1, TextEditingController());
//                textEditControllerList2.insert(firstIdx+i+1, TextEditingController());
                onFocus(firstIdx+i+1);
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
                  Text(loc.battleAddTerastal),
                ],
              ),
            ),
          ) :
          Container(),
    ],
  );

  static PhaseState _getPrevState(
    PhaseState prevState, int i,
    List<TurnEffectAndStateAndGuide> sameTimingList)
  {
    if (i==0) return prevState;
    return sameTimingList[i-1].phaseState;
  }

  static DropdownMenuItem<int> _myDropDown(bool enabled, int value, String label) {
    return DropdownMenuItem(
      enabled: enabled,
      value: value,
      child: Text(label, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey,),
      ),
    );
  }

}