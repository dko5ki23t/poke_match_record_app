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

  final beforeMoveExpandController = ExpandableController(initialExpanded: true);
  final moveExpandController = ExpandableController(initialExpanded: true);
  final afterMoveExpandController = ExpandableController(initialExpanded: true);

  CheckedPokemons checkedPokemons = CheckedPokemons();
  int turnNum = 1;
  int focusPhaseIdx = 0;                        // 0は無効

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
    const statAlphabets = ['A', 'B', 'C', 'D', 'S', 'E'];
    PhaseState? focusState;

    battleNameController.text = widget.battle.name;
    opponentNameController.text = widget.battle.opponentName;
    for (int i = 0; i < widget.battle.opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = widget.battle.opponentParty.pokemons[i]!.name;
    }
    
    if (widget.battle.turns.length >= turnNum &&
        pageType == RegisterBattlePageType.turnPage
    ) {
      // フォーカスしているフェーズの状態を取得
      focusState = widget.battle.turns[turnNum-1].
                    getProcessedStates(focusPhaseIdx-1, widget.battle.ownParty, widget.battle.opponentParty, pokeData);
      // 各フェーズを確認して、必要なものがあれば足したり消したりする
      _adjustPhases(appState);
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
        for (int i = 0; i < widget.battle.opponentParty.pokemonNum; i++) {
          widget.battle.opponentParty.pokemons[i]!.id = pokeData.getUniqueMyPokemonID();
          widget.battle.opponentParty.pokemons[i]!.owner = Owner.fromBattle;
          pokemons.add(widget.battle.opponentParty.pokemons[i]!);
          await pokeData.addMyPokemon(widget.battle.opponentParty.pokemons[i]!);
        }
        widget.battle.opponentParty.id = pokeData.getUniquePartyID();
        widget.battle.opponentParty.owner = Owner.fromBattle;
        parties.add(widget.battle.opponentParty);
        await pokeData.addParty(widget.battle.opponentParty);

        widget.battle.id = pokeData.getUniqueBattleID();
        battles.add(widget.battle);
      }
      else {
        int index = 0;
        for (int i = 0; i < widget.battle.opponentParty.pokemonNum; i++) {
          int pokemonID = widget.battle.opponentParty.pokemons[i]!.id;
          if (pokemonID == 0) {   // 編集時に追加したポケモン
            widget.battle.opponentParty.pokemons[i]!.id = pokeData.getUniqueMyPokemonID();
            widget.battle.opponentParty.pokemons[i]!.owner = Owner.fromBattle;
            pokemons.add(widget.battle.opponentParty.pokemons[i]!);
            await pokeData.addMyPokemon(widget.battle.opponentParty.pokemons[i]!);
          }
          else {
            index = pokemons.indexWhere((element) => element.id == pokemonID);
            pokemons[index] = widget.battle.opponentParty.pokemons[i]!;
            await pokeData.addMyPokemon(widget.battle.opponentParty.pokemons[i]!);
          }
        }
        index = parties.indexWhere((element) => element.id == widget.battle.opponentParty.id);
        parties[index] = widget.battle.opponentParty;
        await pokeData.addParty(widget.battle.opponentParty);

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
          if (widget.battle.turns.isNotEmpty) {
            checkedPokemons.own = widget.battle.turns[0].initialOwnPokemonIndex;
            checkedPokemons.opponent = widget.battle.turns[0].initialOpponentPokemonIndex;
          }
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own != 0);
          assert(checkedPokemons.opponent != 0);
          if (widget.battle.turns.isEmpty) {
            Turn turn = Turn()
            ..initialOwnPokemonIndex = checkedPokemons.own
            ..initialOpponentPokemonIndex = checkedPokemons.opponent;
            // 初期状態設定ここから
            for (int i = 0; i < widget.battle.ownParty.pokemonNum; i++) {
              turn.initialOwnPokemonStates.add(PokemonState()
                ..pokemon = widget.battle.ownParty.pokemons[i]!
                ..remainHP = widget.battle.ownParty.pokemons[i]!.h.real
                ..isBattling = i+1 == turn.initialOwnPokemonIndex
                ..holdingItem = widget.battle.ownParty.items[i]
                ..usedPPs = List.generate(widget.battle.ownParty.pokemons[i]!.moves.length, (i) => 0)
                ..currentAbility = widget.battle.ownParty.pokemons[i]!.ability
                ..minStats = [for (int j = 0; j < StatIndex.size.index; j++) widget.battle.ownParty.pokemons[i]!.stats[j]]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++) widget.battle.ownParty.pokemons[i]!.stats[j]]
              );
            }
            for (int i = 0; i < widget.battle.opponentParty.pokemonNum; i++) {
              Pokemon poke = widget.battle.opponentParty.pokemons[i]!;
              List<int> races = List.generate(StatIndex.size.index, (index) => poke.stats[index].race);
              List<int> minReals = List.generate(StatIndex.size.index, (index) => index == StatIndex.H.index ?
                SixParams.getRealH(poke.level, races[index], 0, 0) :
                SixParams.getRealABCDS(poke.level, races[index], 0, 0, 0.9));
              List<int> maxReals = List.generate(StatIndex.size.index, (index) => index == StatIndex.H.index ?
                SixParams.getRealH(poke.level, races[index], pokemonMaxIndividual, pokemonMaxEffort) :
                SixParams.getRealABCDS(poke.level, races[index], pokemonMaxIndividual, pokemonMaxEffort, 1.1));
              turn.initialOpponentPokemonStates.add(PokemonState()
                ..pokemon = poke
                ..isBattling = i+1 == turn.initialOpponentPokemonIndex
                ..minStats = [
                  for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, 0, 0, minReals[j])]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, pokemonMaxIndividual, pokemonMaxEffort, maxReals[j])]
                ..possibleAbilities = pokeData.pokeBase[poke.no]!.ability
              );
            }
            turn.phases.addAll(
              [
                TurnEffect()
                ..effect = EffectType(EffectType.move)
                ..timing = AbilityTiming(AbilityTiming.action)
                ..move = TurnMove(),
                TurnEffect()
                ..effect = EffectType(EffectType.move)
                ..timing = AbilityTiming(AbilityTiming.action)
                ..move = TurnMove(),
              ]
            );
            // 初期状態設定ここまで
            widget.battle.turns.add(turn);
          }
          focusPhaseIdx = 0;
          appState.editingPhase = List.generate(
            widget.battle.turns[turnNum-1].phases.length, (index) => false
          );
          textEditingControllerList1 = List.generate(
            widget.battle.turns[turnNum-1].phases.length,
            (index) => TextEditingController(text: widget.battle.turns[turnNum-1].phases[index].getEditingControllerText1())
          );
          textEditingControllerList2 = List.generate(
            widget.battle.turns[turnNum-1].phases.length,
            (index) => TextEditingController(text: widget.battle.turns[turnNum-1].phases[index].getEditingControllerText2())
          );
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          Turn prevTurn = widget.battle.turns[turnNum-1];
          turnNum++;
          if (widget.battle.turns.length < turnNum) {
            PhaseState initialState =
              prevTurn.getProcessedStates(
                prevTurn.phases.length-1,
                widget.battle.ownParty, widget.battle.opponentParty, pokeData);
            // 前ターンの最終状態を初期状態とする
            Turn turn = Turn()
            ..setInitialState(initialState);
            turn.phases.addAll(
              [
                TurnEffect()
                ..effect = EffectType(EffectType.move)
                ..timing = AbilityTiming(AbilityTiming.action)
                ..move = TurnMove(),
                TurnEffect()
                ..effect = EffectType(EffectType.move)
                ..timing = AbilityTiming(AbilityTiming.action)
                ..move = TurnMove(),
              ]
            );

            widget.battle.turns.add(turn);
          }
          focusPhaseIdx = 0;
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
          theme, pokeData, battleNameController,
          opponentNameController,
          opponentPokemonController);
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        backPressed = null;
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text('先頭ポケモン');
        lists = BattleFirstPokemonListView(
          () {setState(() {});},
          widget.battle, theme, pokeData,
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
                    _HPBarRow(_focusingOwnPokemonState(focusState).remainHP, _focusingOwnPokemon(focusState).h.real, _focusingOpponentPokemonState(focusState).remainHPPercent),
                    SizedBox(height: 5),
                    // 各ステータス(ABCDSE)の変化
                    for (int i = 0; i < 6; i++)
                      _StatChangeViewRow(
                        statAlphabets[i], _focusingOwnPokemonState(focusState).statChanges[i],
                        _focusingOpponentPokemonState(focusState).statChanges[i]
                      ),
                    SizedBox(height: 5),
                    // 状態異常・その他補正・場
                    for (int i = 0; i < max(_focusingOwnPokemonState(focusState).buffDebuffs.length, _focusingOpponentPokemonState(focusState).buffDebuffs.length); i++)
                    _BuffDebuffsRow(_focusingOwnPokemonState(focusState), _focusingOpponentPokemonState(focusState), i)
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
                widget.battle, turnNum, theme, pokeData,
                widget.battle.ownParty.pokemons[widget.battle.turns[turnNum-1].initialOwnPokemonIndex-1]!,
                widget.battle.opponentParty.pokemons[widget.battle.turns[turnNum-1].initialOpponentPokemonIndex-1]!,
                textEditingControllerList1,
                textEditingControllerList2,
                appState, focusPhaseIdx,
                (phaseIdx) {
                  focusPhaseIdx = phaseIdx;
                  setState(() {});
                },
                _getSameTimingList(pokeData),
              ),
            ),
          ],
        );
        nextPressed = () => onNext();
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
            onPressed: pageType == RegisterBattlePageType.turnPage ? () => onComplete() : null,
            child: Text('完了'),
          ),
        ],
      ),
      body: lists,
    );
  }

  void _clearContinuousMove(MyAppState appState) {
    int allowedContinuous = 0;
    int continuousCount = 0;
    bool clearAfterMove = false;    // 連続こうげき削除に伴い、そのこうげき後の効果を消すかどうかのフラグ
    List<int> removeIdxs = [];
    for (int i = 0; i < widget.battle.turns[turnNum-1].phases.length; i++) {
      var process = widget.battle.turns[turnNum-1].phases[i];
      if (process.timing.id == AbilityTiming.action &&
          process.move!.type.id == TurnMoveType.move
      ) {
        allowedContinuous = process.move!.move.maxMoveCount()-1;
        continuousCount = 0;
        // わざが失敗/命中してない場合は、連続こうげきは問答無用で削除対象
        if (!process.move!.isSuccess ||
            process.move!.moveHits[0].id == MoveHit.notHit ||
            process.move!.moveHits[0].id == MoveHit.fail
        ) {
          allowedContinuous = 0;
        }
      }
      else if (process.timing.id == AbilityTiming.continuousMove) {
        continuousCount++;
        if (continuousCount > allowedContinuous) {
          removeIdxs.add(i);
          clearAfterMove = true;
        }
        // わざが失敗/命中してない場合は、次以降の連続こうげきは問答無用で削除対象
        if (!process.isAdding &&
            (!process.move!.isSuccess ||
             process.move!.moveHits[continuousCount].id == MoveHit.notHit ||
             process.move!.moveHits[continuousCount].id == MoveHit.fail)
        ) {
          continuousCount = allowedContinuous;
        }
      }
      else if (clearAfterMove) {
        if (process.timing.id == AbilityTiming.afterMove) {
          removeIdxs.add(i);
        }
        else {
          clearAfterMove = false;
        }
      }
    }
    for (int i = removeIdxs.length-1; i >= 0; i--) {
      int idx = removeIdxs[i];
      widget.battle.turns[turnNum-1].phases.removeAt(idx);
      appState.editingPhase.removeAt(idx);
      textEditingControllerList1.removeAt(idx);
      textEditingControllerList2.removeAt(idx);
    }
  }

  void _clearPokemonApeer(MyAppState appState) {
    List<int> removeIdxs = [];
    var processList = widget.battle.turns[turnNum-1].phases;
    for (int i = 0; i < processList.length; i++) {
      var process = processList[i];
      if (process.timing.id == AbilityTiming.action &&
          process.move!.type.id != TurnMoveType.change
      ) {
        for (int j = i+1; j < processList.length; j++) {
          if (processList[j].timing.id == AbilityTiming.pokemonAppear) {
            removeIdxs.add(j);
          }
          else {
            break;
          }
        }
      }
    }
    for (int i = removeIdxs.length-1; i >= 0; i--) {
      int idx = removeIdxs[i];
      processList.removeAt(idx);
      appState.editingPhase.removeAt(idx);
      textEditingControllerList1.removeAt(idx);
      textEditingControllerList2.removeAt(idx);
    }
  }

  void _adjustPhases(MyAppState appState) {
    _clearContinuousMove(appState);
    _clearPokemonApeer(appState);

    int allowedContinuous = 0;
    int continuousCount = 0;
    int i = 0;
    var processList = widget.battle.turns[turnNum-1].phases;
    while (true) {
      if (i >= processList.length) break;
      var process = processList[i];
      if (process.timing.id == AbilityTiming.afterMove &&
          continuousCount < allowedContinuous &&
          (i+1 >= processList.length ||
           processList[i+1].timing.id != AbilityTiming.afterMove &&
           processList[i+1].timing.id != AbilityTiming.continuousMove 
          )
      ) {
        // 可能な連続こうげきが残っている場合、「連続こうげき」タイミングを追加
        processList.insert(i+1,
          TurnEffect()
          ..effect = EffectType(EffectType.move)
          ..timing = AbilityTiming(AbilityTiming.continuousMove)
          ..isAdding = true
        );
        appState.editingPhase.insert(i+1, false);
        textEditingControllerList1.insert(i+1, TextEditingController());
        textEditingControllerList2.insert(i+1, TextEditingController());
      }
      else if (process.timing.id == AbilityTiming.action &&
          process.move!.type.id == TurnMoveType.change &&
          (i+1 >= processList.length ||
           processList[i+1].timing.id != AbilityTiming.pokemonAppear)
           // ポケモン交換の場合、次は「ポケモン登場時」タイミングにする
      ) {
        processList.insert(i+1,
          TurnEffect()
          ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
          ..isAdding = true
        );
        appState.editingPhase.insert(i+1, false);
        textEditingControllerList1.insert(i+1, TextEditingController());
        textEditingControllerList2.insert(i+1, TextEditingController());
      }
      else if (
        process.timing.id == AbilityTiming.action &&
        process.move!.type.id == TurnMoveType.move           // わざの場合
      ) {
        allowedContinuous = process.move!.move.maxMoveCount()-1;
        continuousCount = 0;
        // わざが失敗/命中していなければ次以降の連続こうげきは追加しない
        if (!process.move!.isSuccess ||
            process.move!.moveHits[0].id == MoveHit.notHit ||
            process.move!.moveHits[0].id == MoveHit.fail
        ) {
          allowedContinuous = 0;
        }
        if (i+1 >= processList.length ||
            processList[i+1].timing.id != AbilityTiming.afterMove
        ) {
        // 次が「わざ使用後」タイミングでない場合は「わざ使用後」タイミングにする
          processList.insert(i+1,
            TurnEffect()
            ..timing = AbilityTiming(AbilityTiming.afterMove)
            ..isAdding = true
          );
          appState.editingPhase.insert(i+1, false);
          textEditingControllerList1.insert(i+1, TextEditingController());
          textEditingControllerList2.insert(i+1, TextEditingController());
          // さらに、連続こうげきの場合は「連続こうげき」タイミングを追加(ただし、ちゃんと命中した場合のみ)
          if (continuousCount < allowedContinuous &&
              (i+1 >= processList.length ||
              processList[i+1].timing.id != AbilityTiming.continuousMove &&
              processList[i].move!.isSuccess &&
              processList[i].move!.moveHits[0].id != MoveHit.notHit &&
              processList[i].move!.moveHits[0].id != MoveHit.fail)
          ) {
            processList.insert(i+1,
              TurnEffect()
              ..effect = EffectType(EffectType.move)
              ..timing = AbilityTiming(AbilityTiming.continuousMove)
              ..isAdding = true
            );
            appState.editingPhase.insert(i+1, false);
            textEditingControllerList1.insert(i+1, TextEditingController());
            textEditingControllerList2.insert(i+1, TextEditingController());
          }
        }
      }
      else if (process.timing.id == AbilityTiming.continuousMove && !process.isAdding) {   // 連続こうげきの場合
        continuousCount++;
        // 次が「わざ使用後」タイミングでない場合は「わざ使用後」タイミングにする
        if (i+1 >= processList.length ||
            processList[i+1].timing.id != AbilityTiming.afterMove)
        {
          processList.insert(i+1,
            TurnEffect()
            ..timing = AbilityTiming(AbilityTiming.afterMove)
            ..isAdding = true
          );
          appState.editingPhase.insert(i+1, false);
          textEditingControllerList1.insert(i+1, TextEditingController());
          textEditingControllerList2.insert(i+1, TextEditingController());
        }
        // わざが命中してない場合は、これ以上連続こうげきさせない
        if (!processList[i].isAdding &&
            (!processList[i].move!.isSuccess ||
             processList[i].move!.moveHits[continuousCount].id == MoveHit.notHit ||
             processList[i].move!.moveHits[continuousCount].id == MoveHit.fail)
        ) {
          continuousCount = allowedContinuous;
        }
      }

      i++;
    }

    // 最初のターンなら、初めにポケモン登場時処理を追加
    if (turnNum == 1 && (processList.isEmpty || processList[0].timing.id != AbilityTiming.pokemonAppear)) {
      processList.insert(0, TurnEffect()
        ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
        ..isAdding = true
      );
      appState.editingPhase.insert(0, false);
      textEditingControllerList1.insert(0, TextEditingController());
      textEditingControllerList2.insert(0, TextEditingController());
    }
    int firstPokemonAppearEndIdx = -1;
    if (turnNum == 1) {
      for (int i = 0; i < processList.length; i++) {
        if (processList[i].timing.id != AbilityTiming.pokemonAppear) break;
        firstPokemonAppearEndIdx++;
      }
    }
    // 行動決定直後処理を追加
    if (processList.isEmpty ||
        (turnNum == 1 && processList.length <= 1) ||
        processList[firstPokemonAppearEndIdx+1].timing.id != AbilityTiming.afterActionDecision
      )
    {
      processList.insert(firstPokemonAppearEndIdx+1, TurnEffect()
        ..timing = AbilityTiming(AbilityTiming.afterActionDecision)
        ..isAdding = true
      );
      appState.editingPhase.insert(firstPokemonAppearEndIdx+1, false);
      textEditingControllerList1.insert(firstPokemonAppearEndIdx+1, TextEditingController());
      textEditingControllerList2.insert(firstPokemonAppearEndIdx+1, TextEditingController());
    }
    // ポケモン交換
    // 毎ターン終了時処理を追加
    if (processList.last.timing.id != AbilityTiming.everyTurnEnd) {
      processList.add(TurnEffect()
        ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
        ..isAdding = true
      );
      appState.editingPhase.add(false);
      textEditingControllerList1.add(TextEditingController());
      textEditingControllerList2.add(TextEditingController());
    }
  }

  List<List<TurnEffectAndState>> _getSameTimingList(PokeDB pokeData) {
    int beginIdx = 0;
    int timingId = 0;
    List<List<TurnEffectAndState>> ret = [];
    var phases = widget.battle.turns[turnNum-1].phases;
    final turnEffectAndStates = [
      for (int i = 0; i < phases.length; i++)
      TurnEffectAndState()
      ..turnEffect = phases[i]
      ..phaseState = widget.battle.turns[turnNum-1].getProcessedStates(i, widget.battle.ownParty, widget.battle.opponentParty, pokeData)
    ];
    for (int i = 0; i < turnEffectAndStates.length; i++) {
      if (turnEffectAndStates[i].turnEffect.timing.id != timingId ||
          turnEffectAndStates[i].turnEffect.timing.id == AbilityTiming.action
      ) {
        if (i != 0) {
          ret.add(turnEffectAndStates.sublist(beginIdx, i));
        }
        beginIdx = i;
        timingId = turnEffectAndStates[i].turnEffect.timing.id;
      }
    }
    if (phases.isNotEmpty) {
      ret.add(turnEffectAndStates.sublist(beginIdx, phases.length));
    }

    return ret;
  }

  Pokemon _focusingOwnPokemon(PhaseState focusState) {
    return widget.battle.ownParty.pokemons[focusState.ownPokemonIndex-1]!;
  }

  Pokemon _focusingOpponentPokemon(PhaseState focusState) {
    return widget.battle.opponentParty.pokemons[focusState.opponentPokemonIndex-1]!;
  }

  PokemonState _focusingOwnPokemonState(PhaseState focusState) {
    return focusState.ownPokemonStates[focusState.ownPokemonIndex-1];
  }

  PokemonState _focusingOpponentPokemonState(PhaseState focusState) {
    return focusState.opponentPokemonStates[focusState.opponentPokemonIndex-1];
  }

  String _focusingOwnItemName(PhaseState focusState) {
    final item = focusState.ownPokemonStates[focusState.ownPokemonIndex-1].holdingItem;
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
    final item = focusState.opponentPokemonStates[focusState.opponentPokemonIndex-1].holdingItem;
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
    final ability = focusState.ownPokemonStates[focusState.ownPokemonIndex-1].currentAbility;
    if (ability.id == 0) {
      return '？';
    }
    else {
      return ability.displayName;
    }
  }

  String _focusingOpponentAbilityName(PhaseState focusState) {
    final ability = focusState.opponentPokemonStates[focusState.opponentPokemonIndex-1].currentAbility;
    if (ability.id == 0) {
      return '？';
    }
    else {
      return ability.displayName;
    }
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
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            ownPokemonState.ailments.length > index ?
            Container(
              color: ownPokemonState.ailments[index].bgColor,
              child: Text(ownPokemonState.ailments[index].displayName, style: TextStyle(color: Colors.white)),
            ) : Container(),
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child:
            opponentPokemonState.ailments.length > index ?
            Container(
              color: opponentPokemonState.ailments[index].bgColor,
              child: Text(opponentPokemonState.ailments[index].displayName, style: TextStyle(color: Colors.white)),
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
