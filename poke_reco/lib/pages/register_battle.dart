import 'dart:math';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialog/delete_editing_check_dialog.dart';
//import 'package:intl/intl.dart';
import 'package:poke_reco/custom_widgets/battle_basic_listview.dart';
import 'package:poke_reco/custom_widgets/battle_first_pokemon_listview.dart';
import 'package:poke_reco/custom_widgets/battle_turn_listview.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/poke_move.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/poke_db.dart';

enum RegisterBattlePageType {
  basePage,
  firstPokemonPage,
  turnPage,
}

class CheckedPokemons {
  int own = 0;
  int opponent = 0;
}

class RegisterBattlePage extends StatefulWidget {
  RegisterBattlePage({
    Key? key,
    required this.onFinish,
    required this.battle,
    required this.isNew,
  }) : super(key: key);

  final void Function() onFinish;
  final Battle battle;
  final bool isNew;

  @override
  RegisterBattlePageState createState() => RegisterBattlePageState();
}

class RegisterBattlePageState extends State<RegisterBattlePage> {
  RegisterBattlePageType pageType = RegisterBattlePageType.basePage;
//  final battleDatetimeController = TextEditingController(text: DateFormat('yyyy/MM/dd HH:mm', "ja_JP").format(DateTime.now()));
  final opponentPokemonController = List.generate(6, (i) => TextEditingController());
  final battleNameController = TextEditingController();
  final opponentNameController = TextEditingController();

  List<TextEditingController> textEditingControllerList1 = [];
  List<TextEditingController> textEditingControllerList2 = [];
  List<TextEditingController> textEditingControllerList3 = [];

  final beforeMoveExpandController = ExpandableController(initialExpanded: true);
  final moveExpandController = ExpandableController(initialExpanded: true);
  final afterMoveExpandController = ExpandableController(initialExpanded: true);

  CheckedPokemons checkedPokemons = CheckedPokemons();
  int turnNum = 1;
  int focusPhaseIdx = 0;                        // 0は無効
  List<List<TurnEffectAndStateAndGuide>> sameTimingList = [];

  bool isNewTurn = false;
  bool openStates = false;

  static pingpongTextEditingController(TextEditingController controller) {
    if (controller.text == 'ping') {
      controller.text = 'pong';
    }
    else {
      controller.text = 'ping';
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var battles = appState.battles;
    var parties = appState.parties;
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    const statAlphabets = ['A ', 'B ', 'C ', 'D ', 'S ', 'Ac', 'Ev'];
    PhaseState? focusState;

    // エイリアス
    List<Turn> turns = widget.battle.turns;
    Party ownParty = widget.battle.ownParty;
    Party opponentParty = widget.battle.opponentParty;

    battleNameController.text = widget.battle.name;
    opponentNameController.text = widget.battle.opponentName;
    for (int i = 0; i < opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = opponentParty.pokemons[i]!.name;
    }
    
    if (turns.length >= turnNum &&
        pageType == RegisterBattlePageType.turnPage
    ) {
      // フォーカスしているフェーズの状態を取得
      focusState = turns[turnNum-1].
                    getProcessedStates(focusPhaseIdx-1, ownParty, opponentParty);
      // 各フェーズを確認して、必要なものがあれば足したり消したりする
      if (getSelectedNum(appState.editingPhase) == 0 || appState.needAdjustPhases) {
        sameTimingList = _adjustPhases(appState, isNewTurn);
        isNewTurn = false;
        appState.needAdjustPhases = false;
      }
    }

    // TODO
    void onBack () {
      showDialog(
        context: context,
        builder: (_) {
          return DeleteEditingCheckDialog(
            '対戦記録',
            () {
              Navigator.pop(context);
            },
          );
        }
      );
    }
    appState.onBackKeyPushed = onBack;

    Widget lists;
    Widget title;
    void Function()? nextPressed;
    void Function()? backPressed;

    void onComplete() async {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        // 相手のパーティ、ポケモンも登録
        for (int i = 0; i < opponentParty.pokemonNum; i++) {
          opponentParty.pokemons[i]!.id = pokeData.getUniqueMyPokemonID();
          opponentParty.pokemons[i]!.owner = Owner.fromBattle;
          pokemons.add(opponentParty.pokemons[i]!);
          await pokeData.addMyPokemon(opponentParty.pokemons[i]!);
        }
        opponentParty.id = pokeData.getUniquePartyID();
        opponentParty.owner = Owner.fromBattle;
        parties.add(opponentParty);
        await pokeData.addParty(opponentParty);

        widget.battle.id = pokeData.getUniqueBattleID();
        battles.add(widget.battle);
      }
      else {
        int index = 0;
        for (int i = 0; i < opponentParty.pokemonNum; i++) {
          int pokemonID = opponentParty.pokemons[i]!.id;
          if (pokemonID == 0) {   // 編集時に追加したポケモン
            opponentParty.pokemons[i]!.id = pokeData.getUniqueMyPokemonID();
            opponentParty.pokemons[i]!.owner = Owner.fromBattle;
            pokemons.add(opponentParty.pokemons[i]!);
            await pokeData.addMyPokemon(opponentParty.pokemons[i]!);
          }
          else {
            index = pokemons.indexWhere((element) => element.id == pokemonID);
            pokemons[index] = opponentParty.pokemons[i]!;
            await pokeData.addMyPokemon(opponentParty.pokemons[i]!);
          }
        }
        index = parties.indexWhere((element) => element.id == opponentParty.id);
        parties[index] = opponentParty;
        await pokeData.addParty(opponentParty);

        index = battles.indexWhere((element) => element.id == widget.battle.id);
        battles[index] = widget.battle;
      }
      await pokeData.addBattle(widget.battle);
      widget.onFinish();
    }

    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          pageType = RegisterBattlePageType.firstPokemonPage;
          checkedPokemons.own = 0;
          checkedPokemons.opponent = 0;
          if (turns.isNotEmpty) {
            checkedPokemons.own = turns[0].initialOwnPokemonIndex;
            checkedPokemons.opponent = turns[0].initialOpponentPokemonIndex;
          }
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own != 0);
          assert(checkedPokemons.opponent != 0);
          if (turns.isEmpty) {
            Turn turn = Turn()
            ..initialOwnPokemonIndex = checkedPokemons.own
            ..initialOpponentPokemonIndex = checkedPokemons.opponent;
            // 初期状態設定ここから
            for (int i = 0; i < ownParty.pokemonNum; i++) {
              turn.initialOwnPokemonStates.add(PokemonState()
                ..pokemon = ownParty.pokemons[i]!
                ..remainHP = ownParty.pokemons[i]!.h.real
                ..isBattling = i+1 == turn.initialOwnPokemonIndex
                ..holdingItem = ownParty.items[i]
                ..usedPPs = List.generate(ownParty.pokemons[i]!.moves.length, (i) => 0)
                ..currentAbility = ownParty.pokemons[i]!.ability
                ..minStats = [for (int j = 0; j < StatIndex.size.index; j++) ownParty.pokemons[i]!.stats[j]]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++) ownParty.pokemons[i]!.stats[j]]
                ..moves = [for (int j = 0; j < ownParty.pokemons[i]!.moveNum; j++) ownParty.pokemons[i]!.moves[j]!]
                ..type1 = ownParty.pokemons[i]!.type1
                ..type2 = ownParty.pokemons[i]!.type2
              );
            }
            for (int i = 0; i < opponentParty.pokemonNum; i++) {
              Pokemon poke = opponentParty.pokemons[i]!;
              List<int> races = List.generate(StatIndex.size.index, (index) => poke.stats[index].race);
              List<int> minReals = List.generate(StatIndex.size.index, (index) => index == StatIndex.H.index ?
                SixParams.getRealH(poke.level, races[index], 0, 0) :
                SixParams.getRealABCDS(poke.level, races[index], 0, 0, 0.9));
              List<int> maxReals = List.generate(StatIndex.size.index, (index) => index == StatIndex.H.index ?
                SixParams.getRealH(poke.level, races[index], pokemonMaxIndividual, pokemonMaxEffort) :
                SixParams.getRealABCDS(poke.level, races[index], pokemonMaxIndividual, pokemonMaxEffort, 1.1));
              final state = PokemonState()
                ..pokemon = poke
                ..isBattling = i+1 == turn.initialOpponentPokemonIndex
                ..minStats = [
                  for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, 0, 0, minReals[j])]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, pokemonMaxIndividual, pokemonMaxEffort, maxReals[j])]
                ..possibleAbilities = pokeData.pokeBase[poke.no]!.ability
                ..type1 = poke.type1
                ..type2 = poke.type2;
              if (state.possibleAbilities.length == 1) {    // 対象ポケモンのとくせいが1つしかあり得ないなら確定
                opponentParty.pokemons[i]!.ability = state.possibleAbilities[0];
                state.currentAbility = state.possibleAbilities[0];
              }
              turn.initialOpponentPokemonStates.add(state);
            }
            turn.initialOwnPokemonState.processEnterEffect(true, turn.initialWeather, turn.initialField, turn.initialOpponentPokemonState);
            turn.initialOpponentPokemonState.processEnterEffect(false, turn.initialWeather, turn.initialField, turn.initialOwnPokemonState);
            // 初期状態設定ここまで
            turns.add(turn);
            isNewTurn = true;
          }
          focusPhaseIdx = 0;
          var currentTurn = turns[turnNum-1];
          appState.editingPhase = List.generate(
            currentTurn.phases.length, (index) => false
          );
          // テキストフィールドの初期値設定
          textEditingControllerList1 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
          );
          textEditingControllerList2 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText2(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          Turn prevTurn = turns[turnNum-1];
          turnNum++;
          if (turns.length < turnNum) {
            PhaseState initialState =
              prevTurn.getProcessedStates(
                prevTurn.phases.length-1,
                ownParty, opponentParty);
            // 前ターンの最終状態を初期状態とする
            Turn turn = Turn()
            ..setInitialState(initialState);
            turns.add(turn);
            isNewTurn = true;
          }
          var currentTurn = turns[turnNum-1];
          focusPhaseIdx = 0;
          appState.editingPhase = List.generate(
            currentTurn.phases.length, (index) => false
          );
          // テキストフィールドの初期値設定
          textEditingControllerList1 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
          );
          textEditingControllerList2 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText2(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        default:
          assert(false, 'invalid page move');
          break;
      }
    }

    void onturnBack() {
      switch (pageType) {
        case RegisterBattlePageType.firstPokemonPage:
          pageType = RegisterBattlePageType.basePage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          turnNum--;
          if (turnNum == 0) {
            turnNum = 1;
            pageType = RegisterBattlePageType.firstPokemonPage;
          }
          else {
            var currentTurn = turns[turnNum-1];
            appState.editingPhase = List.generate(
              currentTurn.phases.length, (index) => false
            );
            textEditingControllerList1 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
            );
            textEditingControllerList2 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText2(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  )
                )
              )
            );
            textEditingControllerList3 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText3(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  )
                )
              )
            );
            pageType = RegisterBattlePageType.turnPage;
          }
          focusPhaseIdx = 0;
          setState(() {});
          break;
        case RegisterBattlePageType.basePage:
        default:
          assert(false, 'invalid page move');
          break;
      }
    }

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        title = Text('バトル基本情報');
        lists = BattleBasicListView(
          () {setState(() {});},
          widget.battle, parties,
          theme, battleNameController,
          opponentNameController,
          opponentPokemonController);
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        backPressed = null;
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text('先頭ポケモン');
        lists = BattleFirstPokemonListView(
          () {setState(() {});},
          widget.battle, theme,
          checkedPokemons);
        nextPressed = (checkedPokemons.own != 0 && checkedPokemons.opponent != 0) ? () => onNext() : null;
        backPressed = () => onturnBack();
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('$turnNumターン目');
        lists = Column(
          children: [
            openStates ?
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        Expanded(
                          child: Row(children: [
                            Icon(Icons.catching_pokemon),
                            Text(_focusingOwnPokemon(focusState!).name),
                            _focusingOwnPokemon(focusState).sex.displayIcon,
                          ],),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Row(children: [
                            Icon(Icons.catching_pokemon),
                            Text(_focusingOpponentPokemon(focusState).name),
                            _focusingOpponentPokemon(focusState).sex.displayIcon,
                          ],),
                        ),
                        IconButton(
                          icon: Icon(Icons.keyboard_double_arrow_up),
                          onPressed: () {
                            setState(() {openStates = false;});
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // とくせい
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text(_focusingOwnAbilityName(focusState)),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text(_focusingOpponentAbilityName(focusState)),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // もちもの
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text(_focusingOwnItemName(focusState)),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text(_focusingOpponentItemName(focusState)),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // HP
                    _HPBarRow(focusState.ownPokemonState.remainHP, _focusingOwnPokemon(focusState).h.real, focusState.opponentPokemonState.remainHPPercent),
                    SizedBox(height: 5),
                    // 各ステータス(ABCDSE)の変化
                    for (int i = 0; i < 7; i++)
                      _StatChangeViewRow(
                        statAlphabets[i], focusState.ownPokemonState.statChanges(i),
                        focusState.opponentPokemonState.statChanges(i)
                      ),
                    SizedBox(height: 5),
                    // すばやさ実数値
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text('すばやさ実数値：${_focusingOwnSpeed(focusState)}'),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text(''),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // 状態異常・その他補正・場
                    for (int i = 0; i < max(focusState.ownPokemonState.ailmentsLength, focusState.opponentPokemonState.ailmentsLength); i++)
                    _AilmentsRow(focusState.ownPokemonState, focusState.opponentPokemonState, i),
                    for (int i = 0; i < max(focusState.ownPokemonState.buffDebuffs.length, focusState.opponentPokemonState.buffDebuffs.length); i++)
                    _BuffDebuffsRow(focusState.ownPokemonState, focusState.opponentPokemonState, i),
                    _WeatherFieldRow(focusState)
                  ],
                ),
              ),
            ) :
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Expanded(
                    child: Row(children: [
                      Icon(Icons.catching_pokemon),
                      Text(_focusingOwnPokemon(focusState!).name),
                    ],),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Row(children: [
                      Icon(Icons.catching_pokemon),
                      Text(_focusingOpponentPokemon(focusState).name),
                    ],),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_double_arrow_down),
                    onPressed: () {
                      setState(() {openStates = true;});
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: openStates ? 1 : 10,
              child: BattleTurnListView(
                () {setState(() {});},
                widget.battle, turnNum, theme, 
                ownParty.pokemons[turns[turnNum-1].initialOwnPokemonIndex-1]!,
                opponentParty.pokemons[turns[turnNum-1].initialOpponentPokemonIndex-1]!,
                textEditingControllerList1,
                textEditingControllerList2,
                textEditingControllerList3,
                appState, focusPhaseIdx,
                (phaseIdx) {
                  focusPhaseIdx = phaseIdx;
                  setState(() {});
                },
                //_getSameTimingList(pokeData),
                sameTimingList,
              ),
            ),
          ],
        );
        nextPressed = (widget.battle.turns.isNotEmpty && widget.battle.turns[turnNum-1].isValid() &&
                       getSelectedNum(appState.editingPhase) == 0 && widget.battle.turns[turnNum-1].phases.last.timing.id != AbilityTiming.gameSet) ? () => onNext() : null;
        backPressed = () => onturnBack();
        break;
      default:
        title = Text('バトル登録');
        lists = Center();
        nextPressed = null;
        backPressed = null;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          TextButton(
            onPressed: backPressed,
            child: Text('前へ'),
          ),
          TextButton(
            onPressed: nextPressed,
            child: Text('次へ'),
          ),
          TextButton(
            onPressed: (pageType == RegisterBattlePageType.turnPage && getSelectedNum(appState.editingPhase) == 0) ? () => onComplete() : null,
            child: Text('完了'),
          ),
        ],
      ),
      body: lists,
    );
  }

  void _insertPhase(int index, TurnEffect phase, MyAppState appState) {
    widget.battle.turns[turnNum-1].phases.insert(
      index, phase
    );
    appState.editingPhase.insert(index, false);
    textEditingControllerList1.insert(index, TextEditingController());
    textEditingControllerList2.insert(index, TextEditingController());
    textEditingControllerList3.insert(index, TextEditingController());
  }

  void _removeAtPhase(int index, MyAppState appState) {
    widget.battle.turns[turnNum-1].phases.removeAt(index);
    appState.editingPhase.removeAt(index);
    textEditingControllerList1.removeAt(index);
    textEditingControllerList2.removeAt(index);
    textEditingControllerList3.removeAt(index);
  }

  void _removeRangePhase(int begin, int end, MyAppState appState) {
    widget.battle.turns[turnNum-1].phases.removeRange(begin, end);
    appState.editingPhase.removeRange(begin, end);
    textEditingControllerList1.removeRange(begin, end);
    textEditingControllerList2.removeRange(begin, end);
    textEditingControllerList3.removeRange(begin, end);
  }

  // 追加用のフェーズを削除
  void _clearAddingPhase(MyAppState appState) {
    List<int> removeIdxs = [];
    var phases = widget.battle.turns[turnNum-1].phases;
    for (int i = 0; i < phases.length; i++) {
      if (phases[i].isAdding) {
          removeIdxs.add(i);
      }
    }
    // 削除インデックスリストの重複削除、ソート(念のため)
    removeIdxs = removeIdxs.toSet().toList();
    removeIdxs.sort();
    for (int i = removeIdxs.length-1; i >= 0; i--) {
      _removeAtPhase(removeIdxs[i], appState);
    }
  }

  // 不要なフェーズを削除
  void _clearInvalidPhase(MyAppState appState, int index, bool pokemonAppear, bool afterMove) {
    var phases = widget.battle.turns[turnNum-1].phases;
    int endIdx = index;
    for (; endIdx < phases.length; endIdx++) {
      if (pokemonAppear && phases[endIdx].timing.id == AbilityTiming.pokemonAppear) {
      }
      else if (afterMove && phases[endIdx].timing.id == AbilityTiming.afterMove) {
      }
      else {
        break;
      }
    }
    _removeRangePhase(index, endIdx, appState);
  }

  List<List<TurnEffectAndStateAndGuide>> _adjustPhases(MyAppState appState, bool isNewTurn) {
    _clearAddingPhase(appState);      // 一旦、追加用のフェーズは削除する

    int beginIdx = 0;
    int timingId = 0;
    List<List<TurnEffectAndStateAndGuide>> ret = [];
    List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
    Turn currentTurn = widget.battle.turns[turnNum-1];
    PhaseState currentState = currentTurn.copyInitialState();
    int s1 = turnNum == 1 ? 0 : 1;   // 試合最初のポケモン登場時処理状態
    int s2 = 0;   // どちらもひんしでない状態
    int end = 100;
    int i = 0;
    int actionCount = 0;
    int allowedContinuous = 0;
    int continuousCount = 0;
    bool isOwnFainting = false;
    bool isOpponentFainting = false;
    bool isMyWin = false;
    bool isYourWin = false;
    bool changeOwn = turnNum == 1;
    bool changeOpponent = turnNum == 1;
    const Map<int, int> s1TimingMap = {
      0: AbilityTiming.pokemonAppear,
      1: AbilityTiming.afterActionDecision,
      2: AbilityTiming.action,
      3: AbilityTiming.pokemonAppear,
      4: AbilityTiming.afterMove,
      5: AbilityTiming.continuousMove,
      6: AbilityTiming.afterMove,
      7: AbilityTiming.changePokemonMove,
      8: AbilityTiming.everyTurnEnd,
      9: AbilityTiming.gameSet,
    };
    const Map<int, int> s2TimingMap = {
      1: AbilityTiming.afterMove,
      2: AbilityTiming.changeFaintingPokemon,
      3: AbilityTiming.pokemonAppear,
      4: AbilityTiming.changeFaintingPokemon,
      5: AbilityTiming.pokemonAppear,
      6: AbilityTiming.changeFaintingPokemon,
      7: AbilityTiming.changeFaintingPokemon,
    };
    int timingListIdx = 0;
    int currentTimingID = s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
    List<TurnEffect> assistList = [];
    List<TurnEffect> delAssistList = [];
    TurnEffect? lastAction;
    bool isAssisting = false;
    // 自動入力リスト作成
    if (isNewTurn) {
      assistList = currentState.getDefaultEffectList(
        currentTurn, AbilityTiming(currentTimingID),
        changeOwn, changeOpponent, lastAction, continuousCount,
      );
    }

    var phases = widget.battle.turns[turnNum-1].phases;

    while (s1 != end) {
      // 自動入力効果を作成
      currentTimingID = s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
      if (timingListIdx >= sameTimingList.length ||
          sameTimingList[timingListIdx].first.turnEffect.timing.id != currentTimingID ||
          sameTimingList[timingListIdx].first.needAssist
      ) {
        assistList = currentState.getDefaultEffectList(
          currentTurn, AbilityTiming(currentTimingID),
          changeOwn, changeOpponent, lastAction, continuousCount,
        );
        for (var del in delAssistList) {
          int findIdx = assistList.indexWhere((element) => element.nearEqual(del));
          if (findIdx >= 0) assistList.removeAt(findIdx);
        }
        changeOwn = false;
        changeOpponent = false;
      }
      else {
        assistList.clear();
        delAssistList.clear();
      }
      bool isInserted = false;
      switch (s2) {
        case 1:       // わざでひんし状態
          if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterMove) {
            // 自動追加
            if (assistList.isNotEmpty) {
              _insertPhase(i, assistList.first, appState);
              delAssistList.add(assistList.first);
              assistList.removeAt(0);
              isAssisting = true;
              isInserted = true;
            }
            else {
              _insertPhase(i, TurnEffect()
                ..timing = AbilityTiming(AbilityTiming.afterMove)
                ..isAdding = true,
                appState
              );
              isInserted = true;
              s2++;   // わざでひんし交代状態へ
              timingListIdx++;
              isAssisting = false;
            }
          }
          else {
            // 自動追加リストに載っているものがあればリストから除外
            delAssistList.add(phases[i]);
            isAssisting = true;
          }
          break;
        case 2:       // わざでひんし交代状態
          {
            changeOwn = changeOpponent = false;
            if (i >= phases.length || phases[i].timing.id != AbilityTiming.changeFaintingPokemon) {
              if (isOwnFainting) {
                isOwnFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.me)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                if (!isOpponentFainting) {
                  s2 = 0;
                  s1 = 8;   // ターン終了状態へ
                }
                else {
                  s2 = 6;   // わざでひんし交代状態(2匹目)へ
                }
              }
              else if (isOpponentFainting) {
                isOpponentFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.opponent)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                s2 = 0;
                s1 = 8;   // ターン終了状態へ
              }
            }
            else {
              if (isOwnFainting) {
                phases[i].playerType = PlayerType(PlayerType.me);
                isOwnFainting = false;
              }
              else if (isOpponentFainting) {
                phases[i].playerType = PlayerType(PlayerType.opponent);
                isOpponentFainting = false;
              }
              if (phases[i].isValid()) {
                s2++;   // わざでひんし交代後状態へ
                if (phases[i].playerType.id == PlayerType.me) {
                  changeOwn = true;
                }
                else {
                  changeOpponent = true;
                }
              }
              else {
                if (!isOpponentFainting) {
                  s2 = 0;
                  s1 = 8;   // ターン終了状態へ
                }
                else {
                  s2 = 6;   // わざでひんし交代状態(2匹目)へ
                }
              }
            }
            timingListIdx++;
          }
          break;
        case 3:       // わざでひんし交代後状態
          if (i >= phases.length || phases[i].timing.id != AbilityTiming.pokemonAppear) {
            // 自動追加
            if (assistList.isNotEmpty) {
              _insertPhase(i, assistList.first, appState);
              delAssistList.add(assistList.first);
              assistList.removeAt(0);
              isAssisting = true;
              isInserted = true;
            }
            else {
              _insertPhase(i,TurnEffect()
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..isAdding = true,
                appState
              );
              isInserted = true;
              timingListIdx++;
              isAssisting = false;
              if (!isOpponentFainting) {
                s2 = 0;
                s1 = 8;   // ターン終了状態へ
              }
              else {
                s2 = 2;   // わざでひんし交代状態へ
              }
            }
          }
          else {
            // 自動追加リストに載っているものがあればリストから除外
            delAssistList.add(phases[i]);
            isAssisting = true;
          }
          break;
        case 4:       // わざ以外でひんし状態
          {
            changeOwn = changeOpponent = false;
            if (i >= phases.length || phases[i].timing.id != AbilityTiming.changeFaintingPokemon) {
              if (isOwnFainting) {
                isOwnFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.me)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                if (!isOpponentFainting) {
                  s2 = 0;
                }
                else {
                  s2 = 7;   // わざ以外でひんし状態(2匹目)へ
                }
              }
              else if (isOpponentFainting) {
                isOpponentFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.opponent)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                s2 = 0;
              }
            }
            else if (phases[i].timing.id == AbilityTiming.changeFaintingPokemon) {
              if (isOwnFainting) {
                phases[i].playerType = PlayerType(PlayerType.me);
                isOwnFainting = false;
              }
              else if (isOpponentFainting) {
                phases[i].playerType = PlayerType(PlayerType.opponent);
                isOpponentFainting = false;
              }
              if (phases[i].isValid()) {
                s2++;   // わざ以外でひんし交代後状態へ
                if (phases[i].playerType.id == PlayerType.me) {
                  changeOwn = true;
                }
                else {
                  changeOpponent = true;
                }
              }
              else {
                if (!isOpponentFainting) {
                  s2 = 0;
                }
                else {
                  s2 = 7;   // わざ以外でひんし状態(2匹目)へ
                }
              }
            }
            timingListIdx++;
          }
          break;
        case 5:       // わざ以外でひんし交代後状態
          if (i >= phases.length || phases[i].timing.id != AbilityTiming.pokemonAppear) {
            // 自動追加
            if (assistList.isNotEmpty) {
              _insertPhase(i, assistList.first, appState);
              delAssistList.add(assistList.first);
              assistList.removeAt(0);
              isAssisting = true;
              isInserted = true;
            }
            else {
              _insertPhase(i,TurnEffect()
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..isAdding = true,
                appState
              );
              isInserted = true;
              timingListIdx++;
              isAssisting = false;
              if (!isOpponentFainting) {
                s2 = 0;
              }
              else {
                s2 = 4;   // わざ以外でひんし状態へ
              }
            }
          }
          else {
            // 自動追加リストに載っているものがあればリストから除外
            delAssistList.add(phases[i]);
            isAssisting = true;
          }
          break;
        case 6:       // わざでひんし交代状態(2匹目)
          {
            changeOwn = changeOpponent = false;
            if (i >= phases.length || phases[i].timing.id != AbilityTiming.changeFaintingPokemon ||
                (isOpponentFainting && phases[i].playerType.id == PlayerType.me)
            ) {
              if (isOpponentFainting) {
                isOpponentFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.opponent)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                s2 = 0;
                s1 = 8;   // ターン終了状態へ
              }
            }
            else {
              if (phases[i].playerType.id == PlayerType.me) {
                isOwnFainting = false;
              }
              else {
                isOpponentFainting = false;
              }
              if (phases[i].isValid()) {
                s2 = 3;   // わざでひんし交代後状態へ
                if (phases[i].playerType.id == PlayerType.me) {
                  changeOwn = true;
                }
                else {
                  changeOpponent = true;
                }
              }
              else {
                if (!isOpponentFainting) {
                  s2 = 0;
                  s1 = 8;   // ターン終了状態へ
                }
              }
            }
            timingListIdx++;
          }
          break;
        case 7:       // わざ以外でひんし状態(2匹目)
          {
            changeOwn = changeOpponent = false;
            if (i >= phases.length || phases[i].timing.id != AbilityTiming.changeFaintingPokemon ||
                (isOpponentFainting && phases[i].playerType.id == PlayerType.me)
            ) {
              if (isOpponentFainting) {
                isOpponentFainting = false;
                _insertPhase(i,TurnEffect()
                  ..playerType = PlayerType(PlayerType.opponent)
                  ..effect = EffectType(EffectType.changeFaintingPokemon)
                  ..timing = AbilityTiming(AbilityTiming.changeFaintingPokemon),
                  appState
                );
                isInserted = true;
                s2 = 0;
              }
            }
            else {
              if (phases[i].playerType.id == PlayerType.me) {
                isOwnFainting = false;
              }
              else {
                isOpponentFainting = false;
              }
              if (phases[i].isValid()) {
                s2 = 5;   // わざ以外でひんし交代後状態へ
                if (phases[i].playerType.id == PlayerType.me) {
                  changeOwn = true;
                }
                else {
                  changeOpponent = true;
                }
              }
              else {
                if (!isOpponentFainting) {
                  s2 = 0;
                }
              }
            }
            timingListIdx++;
          }
          break;
        case 0:       // どちらもひんしでない状態
          switch (s1) {
            case 0:         // 試合最初のポケモン登場時処理状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.pokemonAppear) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  s1++;  // 行動決定直後処理状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 1:       // 行動決定直後処理状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterActionDecision) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.afterActionDecision)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  s1++; // 行動選択状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 2:       // 行動選択状態
              {
                _clearInvalidPhase(appState, i, true, true);
                changeOwn = changeOpponent = false;
                actionCount++;
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.action) {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.action)
                    ..effect = EffectType(EffectType.move)
                    ..move = TurnMove(),
                    appState
                  );
                  isInserted = true;
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 2;    // 行動選択状態へ
                  }
                }
                else if (!phases[i].isValid() || phases[i].move!.type.id == TurnMoveType.surrender) {
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 2;    // 行動選択状態へ
                  }
                }
                else if (phases[i].move!.type.id == TurnMoveType.move) {
                  if (phases[i].move!.changePokemonIndex != null) {
                    allowedContinuous = phases[i].move!.move.maxMoveCount()-1;
                    continuousCount = 0;
                    // わざが失敗/命中していなければポケモン交代も発生しない
                    if (!phases[i].move!.isNormallyHit(0)) {
                      allowedContinuous = 0;
                      s1 = 4;   // わざ使用後状態へ
                    }
                    else {
                      s1 = 6;   // 交代わざ使用後状態へ
                    }
                  }
                  else {
                    allowedContinuous = phases[i].move!.move.maxMoveCount()-1;
                    continuousCount = 0;
                    // わざが失敗/命中していなければ次以降の連続こうげきは追加しない
                    if (!phases[i].move!.isNormallyHit(0)) {
                      allowedContinuous = 0;
                    }
                    s1 = 4;   // わざ使用後状態へ
                  }
                }
                else if (phases[i].move!.changePokemonIndex != null) {
                  s1++;   // ポケモン交代後状態へ
                  if (phases[i].playerType.id == PlayerType.me) {
                    changeOwn = true;
                  }
                  else { 
                    changeOpponent = true;
                  }
                }
                lastAction = phases[i];
                timingListIdx++;
              }
              break;
            case 3:       // ポケモン交代後状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.pokemonAppear) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  timingListIdx++;
                  isAssisting = false;
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 2;     // 行動選択状態へ
                  }
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 4:         // わざ使用後状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterMove) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.afterMove)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  timingListIdx++;
                  isAssisting = false;
                  if (continuousCount < allowedContinuous) {
                    s1 = 5;    // 連続わざ状態へ
                  }
                  else if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 2;     // 行動選択状態へ
                  }
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 5:         // 連続わざ状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.continuousMove) {
                _insertPhase(i, TurnEffect()
                  ..timing = AbilityTiming(AbilityTiming.continuousMove)
                  ..effect = EffectType(EffectType.move)
                  ..isAdding = true,
                  appState
                );
                isInserted = true;
                if (actionCount == 2) {
                  s1 = 8;    // ターン終了状態へ
                }
                else {
                  s1 = 2;    // 行動選択状態へ
                }
              }
              else if (!phases[i].isValid()) {
                if (actionCount == 2) {
                  s1 = 8;    // ターン終了状態へ
                }
                else {
                  s1 = 2;    // 行動選択状態へ
                }
              }
              else {
                continuousCount++;
                // わざが失敗/命中していなければ次以降の連続こうげきは追加しない
                if (!phases[i].move!.isNormallyHit(continuousCount)) {
                  allowedContinuous = 0;
                }
                s1 = 4;   // わざ使用後状態へ
              }
              lastAction = phases[i];
              timingListIdx++;
              break;
            case 6:         // 交代わざ使用後状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterMove) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.afterMove)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  timingListIdx++;
                  isAssisting = false;
                  s1++;     // 交代わざ交代状態へ
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 7:         // 交代わざ交代状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.changePokemonMove) {
                _insertPhase(i, TurnEffect()
                  ..timing = AbilityTiming(AbilityTiming.changePokemonMove),
                  appState
                );
                isInserted = true;
              }
              s1 = 3;     // ポケモン交代後状態へ
              timingListIdx++;
              break;
            case 8:       // ターン終了状態
              if (i >= phases.length || phases[i].timing.id != AbilityTiming.everyTurnEnd) {
                // 自動追加
                if (assistList.isNotEmpty) {
                  _insertPhase(i, assistList.first, appState);
                  delAssistList.add(assistList.first);
                  assistList.removeAt(0);
                  isAssisting = true;
                  isInserted = true;
                }
                else {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  isAssisting = false;
                  _removeRangePhase(i+1, phases.length, appState);
                  s1 = end;
                }
              }
              else {
                // 自動追加リストに載っているものがあればリストから除外
                delAssistList.add(phases[i]);
                isAssisting = true;
              }
              break;
            case 9:     // 試合終了状態
               _insertPhase(i, TurnEffect()
                ..timing = AbilityTiming(AbilityTiming.gameSet)
                ..isMyWin = isMyWin
                ..isYourWin = isYourWin,
                appState
              );
              _removeRangePhase(i+1, phases.length, appState);
              s1 = end;
              break;
          }
          break;
      }

      final guide = phases[i].processEffect(
        widget.battle.ownParty,
        currentState.ownPokemonState,
        widget.battle.opponentParty,
        currentState.opponentPokemonState,
        currentState, lastAction, continuousCount);
      turnEffectAndStateAndGuides.add(
        TurnEffectAndStateAndGuide()
        ..phaseIdx = i
        ..turnEffect = phases[i]
        ..phaseState = currentState.copyWith()
        ..guides = guide
      );
      // 追加されたフェーズのフォームの内容を変える
      if (isInserted) {
        textEditingControllerList1[i].text = phases[i].getEditingControllerText1();
        textEditingControllerList2[i].text = phases[i].getEditingControllerText2(currentState);
        textEditingControllerList3[i].text = phases[i].getEditingControllerText3(currentState);
      }

      if (s1 != end &&
          (!isInserted || isAssisting) && i < phases.length &&
          (phases[i].isMyWin || phases[i].isYourWin))     // どちらかが勝利したら
      {
        isMyWin = phases[i].isMyWin;
        isYourWin = phases[i].isYourWin;
        s2 = 0;
        s1 = 9;     // 試合終了状態へ
      }
      else if (s1 != end && (!isInserted || isAssisting) && i < phases.length && (phases[i].isOwnFainting || phases[i].isOpponentFainting)) {    // どちらかがひんしになる場合
        if (phases[i].isOwnFainting) isOwnFainting = true;
        if (phases[i].isOpponentFainting) isOpponentFainting = true;
        if (s2 == 1 || phases[i].timing.id == AbilityTiming.action || phases[i].timing.id == AbilityTiming.continuousMove) {
          actionCount = 2;
          s2 = 1;     // わざでひんし状態へ
        }
        else {
          s2 = 4;   // わざ以外でひんし状態へ
        }
      }

      i++;
    }

    for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
      if (turnEffectAndStateAndGuides[i].turnEffect.timing.id != timingId ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.action ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.changeFaintingPokemon
      ) {
        if (i != 0) {
          ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
        }
        beginIdx = i;
        timingId = turnEffectAndStateAndGuides[i].turnEffect.timing.id;
      }
    }

    if (phases.isNotEmpty) {
      ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, phases.length));
    }
    return ret;
  }

  Pokemon _focusingOwnPokemon(PhaseState focusState) {
    return widget.battle.ownParty.pokemons[focusState.ownPokemonIndex-1]!;
  }

  Pokemon _focusingOpponentPokemon(PhaseState focusState) {
    return widget.battle.opponentParty.pokemons[focusState.opponentPokemonIndex-1]!;
  }

  String _focusingOwnItemName(PhaseState focusState) {
    final item = focusState.ownPokemonState.holdingItem;
    if (item == null) {
      return 'なし';
    }
    else if (item.id == 0) {
      return '？';
    }
    else {
      return item.displayName;
    }
  }

  String _focusingOpponentItemName(PhaseState focusState) {
    final item = focusState.opponentPokemonState.holdingItem;
    if (item == null) {
      return 'なし';
    }
    else if (item.id == 0) {
      return '？';
    }
    else {
      return item.displayName;
    }
  }

  String _focusingOwnAbilityName(PhaseState focusState) {
    final ability = focusState.ownPokemonState.currentAbility;
    if (ability.id == 0) {
      return '？';
    }
    else {
      return ability.displayName;
    }
  }

  String _focusingOpponentAbilityName(PhaseState focusState) {
    final ability = focusState.opponentPokemonState.currentAbility;
    if (ability.id == 0) {
      return '？';
    }
    else {
      return ability.displayName;
    }
  }

  int _focusingOwnSpeed(PhaseState focusState) {
    int ret = widget.battle.ownParty.pokemons[focusState.ownPokemonIndex-1]!.s.real;
    final item = focusState.ownPokemonState.holdingItem;
    final ability = focusState.ownPokemonState.currentAbility;
    final weather = focusState.weather;
    final ownState = focusState.ownPokemonState;
    final fields = focusState.ownPokemonState.fields;
    bool ignoreParalysis = false;
    
    // ステータス変化
    int rank = focusState.ownPokemonState.statChanges(4);
    if (rank >= 0) {
      ret = (ret * (2 + rank) / 2).floor();
    }
    else {
      ret = (ret * 2 / (2 + rank)).floor();
    }
    // もちもの
    if (item?.id == 251) {  // スピードパウダー
      ret *= 2;
    }
    else if (item?.id == 264) {   // こだわりスカーフ
      ret = (ret * 1.5).floor();
    }
    else if (item?.id == 255) {   // くろいてっきゅう
      ret = (ret * 0.5).floor();
    }
    // とくせい
    if (ability.id == 33 && weather.id == Weather.rainy) {      // 雨下のすいすい
      ret *= 2;
    }
    else if (ability.id == 34 && weather.id == Weather.sunny) { // 晴れ下のようりょくそ
      ret *= 2;
    }
    else if (ability.id == 95 && ownState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) {   // 状態異常中のはやあし
      ret *= 2;
      ignoreParalysis = true;
    }
    else if (ability.id == 84 && item == null) {  // もちものを持っていないときのかるわざ
      ret *= 2;
    }
    // スロースタート(未実装)
    // 場・状態異常
    if (fields.where((element) => element.id == IndividualField.tailwind).isNotEmpty) {   // おいかぜ
      ret *= 2;
    }
    if (!ignoreParalysis && ownState.ailmentsWhere((element) => element.id == Ailment.paralysis).isNotEmpty) {  // まひ
      ret = (ret * 0.5).floor();
    }

    return ret;
  }
}

class _StatChangeViewRow extends Row {
  _StatChangeViewRow(
    String label,
    int ownStatChange,
    int opponentStatChange,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          for (int i = 0; i < ownStatChange.abs(); i++)
          ownStatChange > 0 ?
            Icon(Icons.arrow_drop_up, color: Colors.red) :
            Icon(Icons.arrow_drop_down, color: Colors.blue),
          for (int i = ownStatChange.abs(); i < 6; i++)
            Icon(Icons.minimize, color: Colors.grey),
        ],),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          for (int i = 0; i < opponentStatChange.abs(); i++)
          opponentStatChange > 0 ?
            Icon(Icons.arrow_drop_up, color: Colors.red) :
            Icon(Icons.arrow_drop_down, color: Colors.blue),
          for (int i = opponentStatChange.abs(); i < 6; i++)
            Icon(Icons.minimize, color: Colors.grey),
        ],),
      ),
    ],
  );
}

class _HPBarRow extends Row {
  _HPBarRow(
    int ownRemainHP,
    int ownMaxHP,
    int opponentRemainHPPercent,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Container(
                width: 150,
                height: 20,
                color: Colors.grey),
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Container(
                width: (ownRemainHP / ownMaxHP) * 150,
                height: 20,
                color: (ownRemainHP / ownMaxHP) <= 0.25 ? Colors.red : (ownRemainHP / ownMaxHP) <= 0.5 ? Colors.yellow : Colors.lightGreen,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: SizedBox(
                width: 150,
                height: 20,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('$ownRemainHP/$ownMaxHP'),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Container(
                width: 150,
                height: 20,
                color: Colors.grey),
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Container(
                width: (opponentRemainHPPercent / 100) * 150,
                height: 20,
                color: opponentRemainHPPercent <= 25 ? Colors.red : opponentRemainHPPercent <= 50 ? Colors.yellow : Colors.lightGreen,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: SizedBox(
                width: 150,
                height: 20,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('$opponentRemainHPPercent/100%'),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AilmentsRow extends Row {
  _AilmentsRow(
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    int index,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            ownPokemonState.ailmentsLength > index ?
            Container(
              color: ownPokemonState.ailments(index).bgColor,
              child: Text(ownPokemonState.ailments(index).displayName, style: TextStyle(color: Colors.white)),
            ) : Container(),
        ),
      ),
      SizedBox(width: 10,),
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            opponentPokemonState.ailmentsLength > index ?
            Container(
              color: opponentPokemonState.ailments(index).bgColor,
              child: Text(opponentPokemonState.ailments(index).displayName, style: TextStyle(color: Colors.white)),
            ) : Container(),
        ),
      ),
    ],
  );
}

class _BuffDebuffsRow extends Row {
  _BuffDebuffsRow(
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    int index,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            ownPokemonState.buffDebuffs.length > index ?
            Container(
              color: ownPokemonState.buffDebuffs[index].bgColor,
              child: Text(ownPokemonState.buffDebuffs[index].displayName, style: TextStyle(color: Colors.white)),
            ) : Container(),
        ),
      ),
      SizedBox(width: 10,),
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            opponentPokemonState.buffDebuffs.length > index ?
            Container(
              color: opponentPokemonState.buffDebuffs[index].bgColor,
              child: Text(opponentPokemonState.buffDebuffs[index].displayName, style: TextStyle(color: Colors.white)),
            ) : Container(),
        ),
      ),
    ],
  );
}

class _WeatherFieldRow extends Row {
  _WeatherFieldRow(
    PhaseState state,
  ) :
  super(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      state.weather.id != 0 ?
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            Container(
              color: state.weather.bgColor,
              child: Text(state.weather.displayName, style: TextStyle(color: Colors.white)),
            ),
        ),
      ) : Container(),
      SizedBox(width: 10,),
      state.field.id != 0 ?
      Flexible(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            Container(
              color: state.field.bgColor,
              child: Text(state.field.displayName, style: TextStyle(color: Colors.white)),
            ),
        ),
      ) : Container(),
    ],
  );
}
