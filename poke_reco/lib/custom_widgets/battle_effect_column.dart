import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/tool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleEffectColumn extends Column {
  BattleEffectColumn(
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    PhaseState prevState, // 直前までの状態
    List<TurnEffectAndStateAndGuide> sameTimingList,
    int firstIdx,
    Timing timing,
    List<TextEditingController> textEditControllerList1,
    List<TextEditingController> textEditControllerList2,
    List<TextEditingController> textEditControllerList3,
    List<TextEditingController> textEditControllerList4,
    PlayerType attacker,
    TurnMove turnMove, {
    required bool isInput,
    required AppLocalizations loc,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < sameTimingList.length; i++)
              !sameTimingList[i].turnEffect.isAdding
                  ? Column(
                      children: [
                        GestureDetector(
                          onTap: focusPhaseIdx != firstIdx + i + 1
                              ? () => onFocus(firstIdx + i + 1)
                              : () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: focusPhaseIdx == firstIdx + i + 1
                                  ? Border.all(width: 3, color: Colors.orange)
                                  : Border.all(color: theme.primaryColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                isInput
                                    ? Stack(
                                        children: [
                                          Center(
                                              child: Text(
                                                  '${loc.battleProcess}${i + 1}')),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // 編集中でなければ並べ替えボタン
                                              !appState.editingPhase[
                                                      firstIdx + i]
                                                  ? IconButton(
                                                      icon: Icon(
                                                          Icons.arrow_upward),
                                                      onPressed: i != 0
                                                          ? () {
                                                              TurnEffect.swap(
                                                                  turn.phases,
                                                                  firstIdx +
                                                                      i -
                                                                      1,
                                                                  firstIdx + i);
                                                              listShallowSwap(
                                                                  appState
                                                                      .editingPhase,
                                                                  firstIdx +
                                                                      i -
                                                                      1,
                                                                  firstIdx + i);
                                                              appState.needAdjustPhases =
                                                                  firstIdx +
                                                                      i -
                                                                      1;
                                                              onFocus(
                                                                  firstIdx + i);
                                                            }
                                                          : null,
                                                    )
                                                  : Container(),
                                              !appState.editingPhase[
                                                      firstIdx + i]
                                                  ? IconButton(
                                                      icon: Icon(
                                                          Icons.arrow_downward),
                                                      onPressed: i <
                                                                  sameTimingList
                                                                          .length -
                                                                      1 &&
                                                              !sameTimingList[
                                                                      i + 1]
                                                                  .turnEffect
                                                                  .isAdding
                                                          ? () {
                                                              TurnEffect.swap(
                                                                  turn.phases,
                                                                  firstIdx + i,
                                                                  firstIdx +
                                                                      i +
                                                                      1);
                                                              listShallowSwap(
                                                                  appState
                                                                      .editingPhase,
                                                                  firstIdx + i,
                                                                  firstIdx +
                                                                      i +
                                                                      1);
                                                              appState.needAdjustPhases =
                                                                  firstIdx + i;
                                                              onFocus(firstIdx +
                                                                  i +
                                                                  2);
                                                            }
                                                          : null,
                                                    )
                                                  : IconButton(
                                                      icon: Icon(Icons.check),
                                                      onPressed: turn.phases[
                                                                  firstIdx + i]
                                                              .isValid()
                                                          ? () {
                                                              turn
                                                                      .phases[
                                                                          firstIdx +
                                                                              i]
                                                                      .isAutoSet =
                                                                  false; // 自動補完されたものでも、編集後はそのフラグを消す
                                                              appState.editingPhase[
                                                                      firstIdx +
                                                                          i] =
                                                                  false;
                                                              onFocus(firstIdx +
                                                                  i +
                                                                  1);
                                                            }
                                                          : null,
                                                    ),
                                              IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  if (turn.phases[firstIdx + i]
                                                      .isAutoSet) {
                                                    turn.noAutoAddEffect.add(
                                                        turn.phases[
                                                                firstIdx + i]
                                                            .copy());
                                                  }
                                                  if (i == 0) {
                                                    var timing = turn
                                                        .phases[firstIdx + i]
                                                        .timing;
                                                    turn.phases[firstIdx + i] =
                                                        TurnEffect()
                                                          ..timing = timing
                                                          ..isAdding = true;
                                                    appState.editingPhase[
                                                        firstIdx + i] = false;
                                                    textEditControllerList1[
                                                            firstIdx + i]
                                                        .text = '';
                                                    textEditControllerList2[
                                                            firstIdx + i]
                                                        .text = '';
                                                    textEditControllerList3[
                                                            firstIdx + i]
                                                        .text = '';
                                                    textEditControllerList4[
                                                            firstIdx + i]
                                                        .text = '';
                                                  } else {
                                                    turn.phases
                                                        .removeAt(firstIdx + i);
                                                    appState.editingPhase
                                                        .removeAt(firstIdx + i);
                                                    textEditControllerList1
                                                        .removeAt(firstIdx + i);
                                                    textEditControllerList2
                                                        .removeAt(firstIdx + i);
                                                    textEditControllerList3
                                                        .removeAt(firstIdx + i);
                                                    textEditControllerList4
                                                        .removeAt(firstIdx + i);
                                                  }
                                                  appState.adjustPhaseByDelete =
                                                      true;
                                                  appState.needAdjustPhases =
                                                      firstIdx + i;
                                                  onFocus(0); // フォーカスリセット
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Text(
                                            '${loc.battleProcess}${i + 1}')),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: isInput
                                          ? DropdownButtonFormField(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText:
                                                    loc.battleEffectPlayer,
                                              ),
                                              items: <DropdownMenuItem>[
                                                _myDropDown(
                                                  sameTimingList
                                                      .first.candidateEffect
                                                      .where((e) =>
                                                          e.playerType ==
                                                          PlayerType.me)
                                                      .isNotEmpty,
                                                  PlayerType.me.number,
                                                  '${sameTimingList[i].phaseState.getPokemonState(PlayerType.me, sameTimingList.first.phaseIdx - 1 >= 0 && timing == Timing.afterMove ? turn.phases[sameTimingList.first.phaseIdx - 1] : null).pokemon.name}/${loc.battleYou}',
                                                ),
                                                _myDropDown(
                                                  sameTimingList
                                                      .first.candidateEffect
                                                      .where((e) =>
                                                          e.playerType ==
                                                          PlayerType.opponent)
                                                      .isNotEmpty,
                                                  PlayerType.opponent.number,
                                                  '${sameTimingList[i].phaseState.getPokemonState(PlayerType.opponent, sameTimingList.first.phaseIdx - 1 >= 0 && timing == Timing.afterMove ? turn.phases[sameTimingList.first.phaseIdx - 1] : null).pokemon.name}/${battle.opponentName}',
                                                ),
                                                _myDropDown(
                                                  sameTimingList
                                                      .first.candidateEffect
                                                      .where((e) =>
                                                          e.playerType ==
                                                          PlayerType
                                                              .entireField)
                                                      .isNotEmpty,
                                                  PlayerType.entireField.number,
                                                  loc.battleWeatherField,
                                                ),
                                              ],
                                              value: turn.phases[firstIdx + i]
                                                          .playerType ==
                                                      PlayerType.none
                                                  ? null
                                                  : turn.phases[firstIdx + i]
                                                      .playerType,
                                              onChanged: (value) {
                                                turn.phases[firstIdx + i]
                                                        .playerType =
                                                    PlayerTypeNum
                                                        .createFromNumber(
                                                            value);
                                                var candidates = sameTimingList
                                                    .first.candidateEffect
                                                    .where((e) =>
                                                        e.playerType == value);
                                                if (candidates.length == 1) {
                                                  // 候補が1つだけなら
                                                  turn.phases[firstIdx + i]
                                                          .effectType =
                                                      candidates
                                                          .first.effectType;
                                                  turn.phases[firstIdx + i]
                                                          .effectId =
                                                      candidates.first.effectId;
                                                  turn.phases[firstIdx + i]
                                                          .extraArg1 =
                                                      candidates
                                                          .first.extraArg1;
                                                  turn.phases[firstIdx + i]
                                                          .extraArg2 =
                                                      candidates
                                                          .first.extraArg2;
                                                } else {
                                                  turn.phases[firstIdx + i]
                                                          .effectType =
                                                      EffectType.none;
                                                  turn.phases[firstIdx + i]
                                                      .effectId = 0;
                                                }
                                                textEditControllerList1[
                                                            firstIdx + i]
                                                        .text =
                                                    turn.phases[firstIdx + i]
                                                        .displayName;
                                                textEditControllerList2[
                                                        firstIdx + i]
                                                    .text = turn.phases[
                                                        firstIdx + i]
                                                    .getEditingControllerText2(
                                                        sameTimingList[i]
                                                            .phaseState,
                                                        sameTimingList.first
                                                                        .phaseIdx -
                                                                    1 >=
                                                                0
                                                            ? turn.phases[
                                                                sameTimingList
                                                                        .first
                                                                        .phaseIdx -
                                                                    1]
                                                            : null);
                                                textEditControllerList3[
                                                        firstIdx + i]
                                                    .text = turn.phases[
                                                        firstIdx + i]
                                                    .getEditingControllerText3(
                                                        sameTimingList[i]
                                                            .phaseState,
                                                        sameTimingList.first
                                                                        .phaseIdx -
                                                                    1 >=
                                                                0
                                                            ? turn.phases[
                                                                sameTimingList
                                                                        .first
                                                                        .phaseIdx -
                                                                    1]
                                                            : null);
                                                appState.editingPhase[
                                                    firstIdx + i] = true;
                                                onFocus(firstIdx + i + 1);
                                              },
                                            )
                                          : TextField(
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText:
                                                    loc.battleEffectPlayer,
                                              ),
                                              controller: TextEditingController(
                                                text: turn.phases[firstIdx + i]
                                                            .playerType ==
                                                        PlayerType.me
                                                    ? '${sameTimingList[i].phaseState.getPokemonState(PlayerType.me, sameTimingList.first.phaseIdx - 1 >= 0 && timing == Timing.afterMove ? turn.phases[sameTimingList.first.phaseIdx - 1] : null).pokemon.name}/${loc.battleYou}'
                                                    : turn.phases[firstIdx + i]
                                                                .playerType ==
                                                            PlayerType.opponent
                                                        ? '${sameTimingList[i].phaseState.getPokemonState(PlayerType.opponent, sameTimingList.first.phaseIdx - 1 >= 0 && timing == Timing.afterMove ? turn.phases[sameTimingList.first.phaseIdx - 1] : null).pokemon.name}/${battle.opponentName}'
                                                        : loc
                                                            .battleWeatherField,
                                              ),
                                              readOnly: true,
                                              onTap: () =>
                                                  onFocus(firstIdx + i + 1),
                                            ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: isInput
                                          ? DropdownButtonFormField<int>(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText: loc.battleEffectType,
                                              ),
                                              items: timing == Timing.afterMove
                                                  ? <DropdownMenuItem<int>>[
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .afterMove)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .afterMove.index,
                                                        EffectType.afterMove
                                                            .displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .ability)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .ability.index,
                                                        EffectType.ability
                                                            .displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .item)
                                                            .isNotEmpty,
                                                        EffectType.item.index,
                                                        EffectType
                                                            .item.displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .individualField)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .individualField
                                                            .index,
                                                        EffectType
                                                            .individualField
                                                            .displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .ailment)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .ailment.index,
                                                        EffectType.ailment
                                                            .displayName,
                                                      ),
                                                    ]
                                                  : <DropdownMenuItem<int>>[
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .ability)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .ability.index,
                                                        EffectType.ability
                                                            .displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .item)
                                                            .isNotEmpty,
                                                        EffectType.item.index,
                                                        EffectType
                                                            .item.displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .individualField)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .individualField
                                                            .index,
                                                        EffectType
                                                            .individualField
                                                            .displayName,
                                                      ),
                                                      _myDropDown(
                                                        sameTimingList.first
                                                            .candidateEffect
                                                            .where((e) =>
                                                                e.playerType ==
                                                                    turn
                                                                        .phases[
                                                                            firstIdx +
                                                                                i]
                                                                        .playerType &&
                                                                e.effectType ==
                                                                    EffectType
                                                                        .ailment)
                                                            .isNotEmpty,
                                                        EffectType
                                                            .ailment.index,
                                                        EffectType.ailment
                                                            .displayName,
                                                      ),
                                                    ],
                                              value: (turn.phases[firstIdx + i]
                                                              .effectType ==
                                                          EffectType.none ||
                                                      turn.phases[firstIdx + i]
                                                              .effectType ==
                                                          EffectType.weather ||
                                                      turn.phases[firstIdx + i]
                                                              .effectType ==
                                                          EffectType.field ||
                                                      turn.phases[firstIdx + i]
                                                              .effectType ==
                                                          EffectType.move)
                                                  ? null
                                                  : turn.phases[firstIdx + i]
                                                      .effectType.index,
                                              onChanged: turn
                                                              .phases[
                                                                  firstIdx + i]
                                                              .playerType !=
                                                          PlayerType
                                                              .entireField &&
                                                      turn.phases[firstIdx + i]
                                                              .playerType !=
                                                          PlayerType.none
                                                  ? (value) {
                                                      turn.phases[firstIdx + i]
                                                              .effectType =
                                                          EffectType
                                                              .values[value!];
                                                      var candidates = sameTimingList
                                                          .first.candidateEffect
                                                          .where((e) =>
                                                              e.playerType ==
                                                                  turn
                                                                      .phases[
                                                                          firstIdx +
                                                                              i]
                                                                      .playerType &&
                                                              e.effectType ==
                                                                  turn
                                                                      .phases[
                                                                          firstIdx +
                                                                              i]
                                                                      .effectType);
                                                      if (candidates.length ==
                                                          1) {
                                                        // 候補が一つしかないならそれに決めてしまう
                                                        turn
                                                                .phases[
                                                                    firstIdx + i]
                                                                .effectId =
                                                            candidates
                                                                .first.effectId;
                                                        turn
                                                                .phases[
                                                                    firstIdx + i]
                                                                .extraArg1 =
                                                            candidates.first
                                                                .extraArg1;
                                                        turn
                                                                .phases[
                                                                    firstIdx + i]
                                                                .extraArg2 =
                                                            candidates.first
                                                                .extraArg2;
                                                      } else {
                                                        turn
                                                            .phases[
                                                                firstIdx + i]
                                                            .effectId = 0;
                                                      }
                                                      textEditControllerList1[
                                                                  firstIdx + i]
                                                              .text =
                                                          turn
                                                              .phases[
                                                                  firstIdx + i]
                                                              .displayName;
                                                      textEditControllerList2[
                                                              firstIdx + i]
                                                          .text = turn.phases[
                                                              firstIdx + i]
                                                          .getEditingControllerText2(
                                                              sameTimingList[i]
                                                                  .phaseState,
                                                              sameTimingList.first
                                                                              .phaseIdx -
                                                                          1 >=
                                                                      0
                                                                  ? turn.phases[
                                                                      sameTimingList
                                                                              .first
                                                                              .phaseIdx -
                                                                          1]
                                                                  : null);
                                                      textEditControllerList3[
                                                              firstIdx + i]
                                                          .text = turn.phases[
                                                              firstIdx + i]
                                                          .getEditingControllerText3(
                                                              sameTimingList[i]
                                                                  .phaseState,
                                                              sameTimingList.first
                                                                              .phaseIdx -
                                                                          1 >=
                                                                      0
                                                                  ? turn.phases[
                                                                      sameTimingList
                                                                              .first
                                                                              .phaseIdx -
                                                                          1]
                                                                  : null);
                                                      appState.editingPhase[
                                                          firstIdx + i] = true;
                                                      onFocus(firstIdx + i + 1);
                                                    }
                                                  : null,
                                            )
                                          : TextField(
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText: loc.battleEffectType,
                                              ),
                                              controller: TextEditingController(
                                                text: turn.phases[firstIdx + i]
                                                    .effectType.displayName,
                                              ),
                                              readOnly: true,
                                              onTap: () =>
                                                  onFocus(firstIdx + i + 1),
                                            ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: isInput
                                          ? TypeAheadField(
                                              textFieldConfiguration:
                                                  TextFieldConfiguration(
                                                controller:
                                                    textEditControllerList1[
                                                        firstIdx + i],
                                                decoration: InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText: loc.battleEffect,
                                                ),
                                              ),
                                              autoFlipDirection: true,
                                              suggestionsCallback:
                                                  (pattern) async {
                                                List<TurnEffect> matches = sameTimingList
                                                    .first.candidateEffect
                                                    .where((e) =>
                                                        e.playerType ==
                                                            turn
                                                                .phases[
                                                                    firstIdx +
                                                                        i]
                                                                .playerType &&
                                                        (e.playerType ==
                                                                PlayerType
                                                                    .entireField ||
                                                            e.effectType ==
                                                                turn
                                                                    .phases[
                                                                        firstIdx +
                                                                            i]
                                                                    .effectType))
                                                    .toList();
                                                matches.retainWhere((s) {
                                                  return toKatakana50(s
                                                          .displayName
                                                          .toLowerCase())
                                                      .contains(toKatakana50(
                                                          pattern
                                                              .toLowerCase()));
                                                });
                                                return matches;
                                              },
                                              itemBuilder:
                                                  (context, suggestion) {
                                                return ListTile(
                                                  title: Text(
                                                    suggestion.displayName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              },
                                              onSuggestionSelected:
                                                  (suggestion) {
                                                textEditControllerList1[
                                                            firstIdx + i]
                                                        .text =
                                                    suggestion.displayName;
                                                // 発動主が天気やフィールドの場合はEffectTypeも決まっていないため、ここで決定する
                                                turn.phases[firstIdx + i]
                                                        .effectType =
                                                    suggestion.effectType;
                                                turn.phases[firstIdx + i]
                                                        .effectId =
                                                    suggestion.effectId;
                                                turn.phases[firstIdx + i]
                                                        .extraArg1 =
                                                    suggestion.extraArg1;
                                                turn.phases[firstIdx + i]
                                                        .extraArg2 =
                                                    suggestion.extraArg2;
                                                appState.needAdjustPhases =
                                                    firstIdx + i;
                                                appState.editingPhase[
                                                    firstIdx + i] = true;
                                                onFocus(firstIdx + i + 1);
                                              },
                                            )
                                          : TextField(
                                              controller:
                                                  textEditControllerList1[
                                                      firstIdx + i],
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText: loc.battleEffect,
                                              ),
                                              readOnly: true,
                                              onTap: () =>
                                                  onFocus(firstIdx + i + 1),
                                            ),
                                    ),
                                  ],
                                ),
                                turn.phases[firstIdx + i].extraWidget(
                                  () {
                                    appState.needAdjustPhases =
                                        firstIdx + i + 1;
                                    onFocus(firstIdx + i + 1);
                                  },
                                  theme,
                                  battle.getParty(PlayerType.me).pokemons[
                                      _getPrevState(prevState, firstIdx, i,
                                                  sameTimingList)
                                              .getPokemonIndex(
                                                  PlayerType.me, null) -
                                          1]!,
                                  battle.getParty(PlayerType.opponent).pokemons[
                                      _getPrevState(prevState, firstIdx, i,
                                                  sameTimingList)
                                              .getPokemonIndex(
                                                  PlayerType.opponent, null) -
                                          1]!,
                                  _getPrevState(prevState, firstIdx, i,
                                          sameTimingList)
                                      .getPokemonState(PlayerType.me, null),
                                  _getPrevState(prevState, firstIdx, i,
                                          sameTimingList)
                                      .getPokemonState(
                                          PlayerType.opponent, null),
                                  battle.getParty(PlayerType.me),
                                  battle.getParty(PlayerType.opponent),
                                  _getPrevState(
                                      prevState, firstIdx, i, sameTimingList),
                                  firstIdx - 1 >= 0
                                      ? turn.phases[firstIdx - 1]
                                      : null,
                                  textEditControllerList2[firstIdx + i],
                                  textEditControllerList3[firstIdx + i],
                                  appState,
                                  firstIdx + i,
                                  isInput: isInput,
                                  loc: loc,
                                ),
                                SizedBox(height: 10),
                                for (final e in sameTimingList[i].guides)
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Icon(
                                        Icons.info,
                                        color: Colors.lightGreen,
                                      )),
                                      Expanded(
                                          flex: 10, child: Text(e.guideStr)),
                                      e.canDelete && isInput
                                          ? Expanded(
                                              child: IconButton(
                                                onPressed: () {
                                                  turn.phases[firstIdx + i]
                                                      .invalidGuideIDs
                                                      .add(e.guideId);
                                                  appState.needAdjustPhases =
                                                      firstIdx + i + 1;
                                                  onFocus(firstIdx + i + 1);
                                                },
                                                icon: Icon(
                                                  Icons.cancel,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  :
                  // 処理追加ボタン
                  sameTimingList.first.candidateEffect.isNotEmpty && isInput
                      ? TextButton(
                          onPressed: getSelectedNum(appState.editingPhase
                                      .sublist(firstIdx,
                                          firstIdx + sameTimingList.length)) ==
                                  0
                              ? () {
                                  turn.phases[firstIdx + i].isAdding = false;
                                  appState.editingPhase[firstIdx + i] = true;
                                  onFocus(firstIdx + i + 1);
                                }
                              : null,
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
                                Text(loc.battleAddProcess(
                                    _getTimingText(timing, loc))),
                              ],
                            ),
                          ),
                        )
                      : Container(),
          ],
        );

  static String _getTimingText(Timing timing, AppLocalizations loc) {
    switch (timing) {
      case Timing.pokemonAppear:
        return loc.battleTimingPokemonAppear;
      case Timing.everyTurnEnd:
        return loc.battleTimingTurnEnd;
      case Timing.afterActionDecision:
        return loc.battleTimingAfterActionDecision;
      case Timing.beforeMove:
        return loc.battleTimingBeforeMove;
      case Timing.afterMove:
        return loc.battleTimingAfterMove;
      case Timing.afterTerastal:
        return loc.battleTimingAfterTerastal;
      default:
        return '';
    }
  }

  static PhaseState _getPrevState(PhaseState prevState, int firstIdx, int i,
      List<TurnEffectAndStateAndGuide> sameTimingList) {
    if (i == 0) return prevState;
    return sameTimingList[i - 1].phaseState;
  }

  static DropdownMenuItem<int> _myDropDown(
      bool enabled, int value, String label) {
    return DropdownMenuItem(
      enabled: enabled,
      value: value,
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
