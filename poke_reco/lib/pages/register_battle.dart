import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_widgets/battle_basic_listview.dart';
import 'package:poke_reco/custom_widgets/battle_first_pokemon_listview.dart';
import 'package:poke_reco/custom_widgets/battle_turn_listview.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/user_force.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

enum RegisterBattlePageType {
  basePage,
  firstPokemonPage,
  turnPage,
}

class CheckedPokemons {
  List<int> own = [];
  int opponent = 0;
}

class RegisterBattlePage extends StatefulWidget {
  RegisterBattlePage({
    Key? key,
    required this.onFinish,
    required this.onSelectParty,
    required this.battle,
    required this.isNew,
    required this.onSaveOpponentParty,
    required this.firstPageType,
    required this.firstTurnNum,
  }) : super(key: key);

  final void Function() onFinish;
  final Future<Party?> Function() onSelectParty;
  final Future<void> Function(Party party, PhaseState state) onSaveOpponentParty;
  final Battle battle;
  final bool isNew;
  final RegisterBattlePageType firstPageType;
  final int firstTurnNum;

  @override
  RegisterBattlePageState createState() => RegisterBattlePageState();
}

class RegisterBattlePageState extends State<RegisterBattlePage> {
  RegisterBattlePageType pageType = RegisterBattlePageType.basePage;
  final opponentPokemonController = List.generate(6, (i) => TextEditingController());
  final battleNameController = TextEditingController();
  final opponentNameController = TextEditingController();
  final dateController = TextEditingController();
  final ownPartyController = TextEditingController();

  List<TextEditingController> textEditingControllerList1 = [];
  List<TextEditingController> textEditingControllerList2 = [];
  List<TextEditingController> textEditingControllerList3 = [];
  List<TextEditingController> textEditingControllerList4 = [];
  TextEditingController opponentPokeController = TextEditingController();
  TextEditingController ownAbilityController = TextEditingController();
  TextEditingController opponentAbilityController = TextEditingController();
  TextEditingController ownItemController = TextEditingController();
  TextEditingController opponentItemController = TextEditingController();
  TextEditingController ownHPController = TextEditingController();
  TextEditingController opponentHPController = TextEditingController();
  List<TextEditingController> ownStatusMinControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> ownStatusMaxControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMinControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMaxControllers = List.generate(6, (index) => TextEditingController());

  final turnScrollController = ScrollController();

  CheckedPokemons checkedPokemons = CheckedPokemons();
  int turnNum = 1;
  int focusPhaseIdx = 0;                        // 0は無効
  List<List<TurnEffectAndStateAndGuide>> sameTimingList = [];
  int viewMode = 0;     // 0:ランク 1:種族値 2:ステータス(補正前) 3:ステータス(補正後)
  bool isEditMode = false;

  bool isNewTurn = false;
  bool openStates = false;
  bool firstBuild = true;
  // 能力ランク編集に使う
  List<int> ownStatChanges = [0, 0, 0, 0, 0, 0, 0];
  List<int> opponentStatChanges = [0, 0, 0, 0, 0, 0, 0];

  TurnEffect? _getPrevTimingEffect(int index) {
    TurnEffect? ret;
    var currentTurn = widget.battle.turns[turnNum-1];
    AbilityTiming nowTiming = currentTurn.phases[index].timing;
    for (int i = index-1; i >= 0; i--) {
      if (currentTurn.phases[i].timing.id != nowTiming.id) {
        ret = currentTurn.phases[i];
        break;
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    const statAlphabets = ['A ', 'B ', 'C ', 'D ', 'S ', 'Ac', 'Ev'];
    const statusAlphabets = ['H ', 'A ', 'B ', 'C ', 'D ', 'S '];
    PhaseState? focusState;

    // エイリアス
    List<Turn> turns = widget.battle.turns;
    Party ownParty = widget.battle.getParty(PlayerType(PlayerType.me));
    Party opponentParty = widget.battle.getParty(PlayerType(PlayerType.opponent));

    for (int i = 0; i < opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = opponentParty.pokemons[i]!.name;
    }
    dateController.text = widget.battle.formattedDateTime;
    ownPartyController.text = widget.battle.getParty(PlayerType(PlayerType.me)).id != 0 ?
      pokeData.parties[widget.battle.getParty(PlayerType(PlayerType.me)).id]!.name : 'パーティ選択';

    void onBack () {
      bool showAlert = false;
      if (widget.battle.id == 0) {
        showAlert = true;
      }
      else if (widget.battle.isDiff(pokeData.battles[widget.battle.id]!)) {
        showAlert = true;
      }
      if (showAlert) {
        showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialog(
              null,
              () {
                Navigator.pop(context);
                appState.onTabChange = (func) => func();
              },
            );
          }
        );
      }
    }

    void onTabChange(void Function() func) {
      showDialog(
        context: context,
        builder: (_) {
          return DeleteEditingCheckDialog(
            null,
            () => func(),
          );
        }
      );
    }

    if (firstBuild) {
      appState.onBackKeyPushed = onBack;
      appState.onTabChange = onTabChange;
      battleNameController.text = widget.battle.name;
      opponentNameController.text = widget.battle.opponentName;
      if (!widget.isNew) {
        pageType = widget.firstPageType;
        if (pageType == RegisterBattlePageType.turnPage && turnNum <= turns.length) {
          turnNum = widget.firstTurnNum;
        }
      }
      firstBuild = false;
    }
    
    if (turns.length >= turnNum &&
        pageType == RegisterBattlePageType.turnPage
    ) {
      // フォーカスしているフェーズの状態を取得
      focusState = turns[turnNum-1].
                    getProcessedStates(focusPhaseIdx-1, ownParty, opponentParty);
      // 各フェーズを確認して、必要なものがあれば足したり消したりする
      if (appState.requestActionSwap) {
        _onlySwapActionPhases();
        appState.requestActionSwap = false;
      }
      if (getSelectedNum(appState.editingPhase) == 0 || appState.needAdjustPhases >= 0) {
        sameTimingList = _adjustPhases(appState, isNewTurn);
        isNewTurn = false;
        appState.needAdjustPhases = -1;
        appState.adjustPhaseByDelete = false;
      }
    }

    Widget lists;
    Widget title;
    void Function()? nextPressed;
    void Function()? backPressed;
    void Function()? deletePressed;

    void onComplete() async {
      // TODO?: 入力された値が正しいかチェック
      var battle = widget.battle;
      if (turns.isNotEmpty) {
        if (turns.last.phases.where((e) => e.isMyWin).isNotEmpty) battle.isMyWin = true;
        if (turns.last.phases.where((e) => e.isYourWin).isNotEmpty) battle.isYourWin = true;
        for (var phase in turns[turnNum-1].phases) {
          phase.isAutoSet = false;
        }
        // TODO:このやり方だと5ターン入力してて3ターン目で勝利確定させるような編集されると破綻する
      }

      showDialog(
        context: context,
        builder: (_) {
          return DeleteEditingCheckDialogWithCancel(
            question: '相手パーティ・ポケモンを保存しますか？',
            onYesPressed: () async {
              var lastState = turns.last.phases.isNotEmpty ?
                turns.last.getProcessedStates(turns.last.phases.length-1, ownParty, opponentParty) :
                turns.last.copyInitialState(ownParty, opponentParty);
              var oppPokemonStates = lastState.getPokemonStates(PlayerType(PlayerType.opponent));
              // 現在無効のポケモンを有効化し、DBに保存
              for (int i = 0; i < opponentParty.pokemonNum; i++) {
                var poke = opponentParty.pokemons[i]!;
                var pokemonState = oppPokemonStates[i];
                poke.owner = Owner.fromBattle;
                // もちもの
                opponentParty.items[i] = poke.item;
                // 対戦で確定できなかったものを穴埋めする
                if (poke.ability.id == 0) {
                  poke.ability = pokeData.pokeBase[poke.no]!.ability.first;
                }
                /*if (poke.temper.id == 0) {
                  poke.temper = pokeData.tempers[1]!;
                }*/
                // TODO
                for (int j = 0; j < StatIndex.size.index; j++) {
                  poke.stats[j].real = pokemonState.minStats[j].real;
                  poke.updateStatsRefReal(j);
                }
                // TODO
                for (int j = 0; j < pokemonState.moves.length; j++) {
                  if (j < poke.moves.length) {
                    poke.moves[j] = pokemonState.moves[j];
                  }
                  else {
                    poke.moves.add(pokemonState.moves[j]);
                  }
                  if (j < poke.pps.length) {
                    poke.pps[j] = pokeData.moves[poke.moves[j]!.id]!.pp;
                  }
                  else {
                    poke.pps.add(pokeData.moves[poke.moves[j]!.id]!.pp);
                  }
                }
                poke.teraType = pokemonState.teraType1;
                /*if (poke.move1.id == 0) {
                  poke.move1 = pokeData.pokeBase[poke.no]!.move.first;
                }
                if (poke.teraType.id == 0) {
                  poke.teraType = PokeType.createFromId(1);
                }*/
                await pokeData.addMyPokemon(poke, poke.id == 0);
              }
              opponentParty.owner = Owner.fromBattle;

              await widget.onSaveOpponentParty(
                opponentParty,
                lastState,
              );

              // TODO パーティを保存されなかった場合は、hiddenとして残す必要あり（battleを正しく保存できないため）
              // TODO refCount
              await pokeData.addBattle(battle, widget.isNew);
              widget.onFinish();
            },
            onNoPressed: () async {
              // ポケモンとパーティを(ID決まってないやつは)hiddenとして保存する必要あり(battleを正しく保存できないため)
              for (int i = 0; i < opponentParty.pokemonNum; i++) {
                var poke = opponentParty.pokemons[i]!;
                if (poke.id == 0) {
                  poke.owner = Owner.hidden;
                }
                await pokeData.addMyPokemon(poke, poke.id == 0);
              }
              if (opponentParty.id == 0) {
                opponentParty.owner = Owner.hidden;
              }
              await pokeData.addParty(opponentParty, opponentParty.id == 0);
              await pokeData.addBattle(battle, widget.isNew);
              widget.onFinish();
            },
          );
        }
      );
    }

    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          pageType = RegisterBattlePageType.firstPokemonPage;
          checkedPokemons.own = [];
          checkedPokemons.opponent = 0;
          if (turns.isNotEmpty) {
            checkedPokemons.own = [0, 0, 0];
            var states = turns.first.getInitialPokemonStates(PlayerType(PlayerType.me));
            for (int i = 0; i < states.length; i++) {
              if (states[i].battlingNum != 0) {
                checkedPokemons.own[states[i].battlingNum-1] = i+1;
              }
            }
            checkedPokemons.own.removeWhere((element) => element == 0);
            checkedPokemons.opponent = turns[0].getInitialPokemonIndex(PlayerType(PlayerType.opponent));
          }
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own.isNotEmpty && checkedPokemons.own[0] != 0);
          assert(checkedPokemons.opponent != 0);
          bool battlingCheck = true;
          if (turns.isNotEmpty) {
            var states = turns.first.getInitialPokemonStates(PlayerType(PlayerType.me));
            for (int i = 0; i < states.length; i++) {
              if (states[i].battlingNum != checkedPokemons.own.indexWhere((e) => e == i+1)+1) {
                battlingCheck = false;
                break;
              }
            }
            states = turns.first.getInitialPokemonStates(PlayerType(PlayerType.opponent));
          }
          if (turns.isEmpty ||
              turns.first.getInitialPokemonIndex(PlayerType(PlayerType.me)) != checkedPokemons.own[0] ||
              !battlingCheck ||
              turns.first.getInitialPokemonIndex(PlayerType(PlayerType.opponent)) != checkedPokemons.opponent
          ) {
            turns.clear();
            Turn turn = Turn()
            ..setInitialPokemonIndex(PlayerType(PlayerType.me), checkedPokemons.own[0]) 
            ..setInitialPokemonIndex(PlayerType(PlayerType.opponent), checkedPokemons.opponent)
            ..canZorua = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoruaNo).isNotEmpty
            ..canZoroark = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoroarkNo).isNotEmpty
            ..canZoruaHisui = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoruaHisuiNo).isNotEmpty
            ..canZoroarkHisui = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoroarkHisuiNo).isNotEmpty;
            // 初期状態設定ここから
            for (int i = 0; i < ownParty.pokemonNum; i++) {
              var pokeState = PokemonState()
                ..playerType = PlayerType(PlayerType.me)
                ..pokemon = ownParty.pokemons[i]!
                ..remainHP = ownParty.pokemons[i]!.h.real
                ..battlingNum = checkedPokemons.own.indexWhere((e) => e == i+1) + 1
                ..setHoldingItemNoEffect(ownParty.items[i])
                ..usedPPs = List.generate(ownParty.pokemons[i]!.moves.length, (i) => 0)
                ..setCurrentAbilityNoEffect(ownParty.pokemons[i]!.ability)
                ..minStats = [for (int j = 0; j < StatIndex.size.index; j++) ownParty.pokemons[i]!.stats[j]]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++) ownParty.pokemons[i]!.stats[j]]
                ..moves = [for (int j = 0; j < ownParty.pokemons[i]!.moveNum; j++) ownParty.pokemons[i]!.moves[j]!]
                ..type1 = ownParty.pokemons[i]!.type1
                ..type2 = ownParty.pokemons[i]!.type2;
              turn.getInitialPokemonStates(PlayerType(PlayerType.me)).add(pokeState);
              turn.getInitialLastExitedStates(PlayerType(PlayerType.me)).add(pokeState.copyWith());
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
                ..playerType = PlayerType(PlayerType.opponent)
                ..pokemon = poke
                ..battlingNum = i+1 == turn.getInitialPokemonIndex(PlayerType(PlayerType.opponent)) ? 1 : 0
                ..setHoldingItemNoEffect(pokeData.items[pokeData.pokeBase[poke.no]!.fixedItemID])
                ..minStats = [
                  for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, 0, 0, minReals[j])]
                ..maxStats = [for (int j = 0; j < StatIndex.size.index; j++)
                  SixParams(poke.stats[j].race, pokemonMaxIndividual, pokemonMaxEffort, maxReals[j])]
                ..possibleAbilities = pokeData.pokeBase[poke.no]!.ability
                ..type1 = poke.type1
                ..type2 = poke.type2;
              if (pokeData.pokeBase[poke.no]!.fixedItemID != 0) {
                // もちもの確定
                poke.item = pokeData.items[pokeData.pokeBase[poke.no]!.fixedItemID];
              }
              if (state.possibleAbilities.length == 1) {    // 対象ポケモンのとくせいが1つしかあり得ないなら確定
                opponentParty.pokemons[i]!.ability = state.possibleAbilities[0];
                state.setCurrentAbilityNoEffect(state.possibleAbilities[0]);
              }
              turn.getInitialPokemonStates(PlayerType(PlayerType.opponent)).add(state);
              turn.getInitialLastExitedStates(PlayerType(PlayerType.opponent)).add(state.copyWith());
            }
            turn.initialOwnPokemonState.processEnterEffect(
              true, turn.copyInitialState(ownParty, opponentParty),
              turn.initialOpponentPokemonState
            );
            turn.initialOpponentPokemonState.processEnterEffect(
              false, turn.copyInitialState(ownParty, opponentParty),
              turn.initialOwnPokemonState
            );
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
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList4 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText4(
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
          // 表示のスクロール位置をトップに
          turnScrollController.jumpTo(0);
          Turn prevTurn = turns[turnNum-1];
          for (var phase in prevTurn.phases) {
            phase.isAutoSet = false;
          }
          turnNum++;
          if (turns.length < turnNum) {
            turns.add(Turn());
            isNewTurn = true;
          }
          var currentTurn = turns[turnNum-1];
          PhaseState initialState =
            prevTurn.getProcessedStates(
              prevTurn.phases.length-1,
              ownParty, opponentParty);
          initialState.processTurnEnd(prevTurn);
          // 前ターンの最終状態を初期状態とする
          currentTurn.setInitialState(initialState, ownParty, opponentParty);
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
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList4 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText4(
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
          // 表示のスクロール位置をトップに
          turnScrollController.jumpTo(0);
          for (var phase in turns[turnNum-1].phases) {
            phase.isAutoSet = false;
          }
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
                  ),
                  _getPrevTimingEffect(index),
                )
              )
            );
            textEditingControllerList3 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText3(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  ),
                  _getPrevTimingEffect(index),
                )
              )
            );
            textEditingControllerList4 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText4(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  ),
                ),
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

    void onTurnDelete() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          showDialog(
            context: context,
            builder: (_) {
              return DeleteEditingCheckDialog(
                '入力中の対戦記録の内容をすべて削除してもいいですか？\n（※現在の画面以降の入力もすべて削除されます。）',
                () {
                  widget.battle.clear();
                  setState(() {});
                },
              );
            }
          );
          break;
        case RegisterBattlePageType.turnPage:
          showDialog(
            context: context,
            builder: (_) {
              return DeleteEditingCheckDialog(
                '入力中のターンの記録を削除してもいいですか？\n（※現在のターン以降の入力もすべて削除されます。）',
                () {
                  if (turnNum < turns.length) {
                    widget.battle.turns.removeRange(turnNum, widget.battle.turns.length);
                  }
                  widget.battle.turns[turnNum-1].clearWithInitialState();
                  focusPhaseIdx = 0;
                  setState(() {});
                },
              );
            }
          );
          break;
        case RegisterBattlePageType.firstPokemonPage:
        default:
          assert(false, 'invalid page move');
          break;
      }
    }

    void userForceAdd(int focusPhaseIdx, UserForce force) {
      if (focusPhaseIdx > 0) {
        turns[turnNum-1].phases[focusPhaseIdx-1].userForces.add(force);
      }
      else {
        var state = turns[turnNum-1].copyInitialState(ownParty, opponentParty);
        turns[turnNum-1].initialUserForces.add(force);
        turns[turnNum-1].setInitialState(state, ownParty, opponentParty);
      }
    }

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        title = Text('バトル基本情報');
        lists = BattleBasicListView(
          context,
          () {setState(() {});},
          widget.battle, parties,
          theme, battleNameController,
          opponentNameController,
          dateController,
          opponentPokemonController,
          ownPartyController,
          widget.onSelectParty,
          showNetworkImage: pokeData.getPokeAPI,
          isInput: true,
        );
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        backPressed = null;
        deletePressed = () => onTurnDelete();
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text('選出ポケモン');
        lists = BattleFirstPokemonListView(
          () {setState(() {});},
          widget.battle, theme,
          checkedPokemons,
          showNetworkImage: pokeData.getPokeAPI,
          isInput: true,
        );
        nextPressed = (checkedPokemons.own.isNotEmpty && checkedPokemons.own[0] != 0 && checkedPokemons.opponent != 0) ? () => onNext() : null;
        backPressed = () => onturnBack();
        deletePressed = null;
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('$turnNumターン目');
        lists = Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Row(children: [
                    pokeData.getPokeAPI ?
                    Image.network(
                      pokeData.pokeBase[focusState!.getPokemonState(PlayerType(PlayerType.me), null).pokemon.no]!.imageUrl,
                      height: theme.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    ) : const Icon(Icons.catching_pokemon),
                    Flexible(child: Text(_focusingPokemon(PlayerType(PlayerType.me), focusState!).name, overflow: TextOverflow.ellipsis,)),
                    focusState.getPokemonState(PlayerType(PlayerType.me), null).sex.displayIcon,
                  ],),
                ),
                SizedBox(width: 10,),
                isEditMode ?
                  Expanded(
                    child: Row(children: [
                      pokeData.getPokeAPI ?
                      Image.network(
                        pokeData.pokeBase[focusState.getPokemonState(PlayerType(PlayerType.opponent), null).pokemon.no]!.imageUrl,
                        height: theme.buttonTheme.height,
                        errorBuilder: (c, o, s) {
                          return const Icon(Icons.catching_pokemon);
                        },
                      ) : const Icon(Icons.catching_pokemon),
                      Flexible(
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: opponentPokeController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          autoFlipDirection: true,
                          suggestionsCallback: (pattern) async {
                            List<PokeBase> matches = pokeData.pokeBase.values.where((e) => e.no != 0).toList();
                            matches.retainWhere((s){
                              return toKatakana50(s.name.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                            });
                            return matches;
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.name, overflow: TextOverflow.ellipsis,),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              opponentPokeController.text = suggestion.name;
                              userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.opponent), UserForce.pokemon, suggestion.no));
                            });
                          },
                        ),
                      ),
                      focusState.getPokemonState(PlayerType(PlayerType.opponent), null).sex.displayIcon,
                    ],),
                  ) :
                  Expanded(
                    child: Row(children: [
                      pokeData.getPokeAPI ?
                      Image.network(
                        pokeData.pokeBase[focusState.getPokemonState(PlayerType(PlayerType.opponent), null).pokemon.no]!.imageUrl,
                        height: theme.buttonTheme.height,
                        errorBuilder: (c, o, s) {
                          return const Icon(Icons.catching_pokemon);
                        },
                      ) : const Icon(Icons.catching_pokemon),
                      Flexible(child: Text(_focusingPokemon(PlayerType(PlayerType.opponent), focusState).name, overflow: TextOverflow.ellipsis,)),
                      focusState.getPokemonState(PlayerType(PlayerType.opponent), null).sex.displayIcon,
                    ],),
                  ),
                IconButton(
                  icon: Icon(openStates ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down),
                  onPressed: () {
                    setState(() {openStates = !openStates;});
                  },
                ),
              ],
            ),
            openStates ?
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                viewMode++;
                                viewMode %= 4;
                              });
                            },
                            child: Row(children: [
                              viewMode == 0 ?
                              Text('ランク') :
                              viewMode == 1 ?
                              Text('種族値') :
                              viewMode == 2 ?
                              Text('ステータス(補正前)') : Text('ステータス(補正後)'),
                              SizedBox(width: 10),
                              Icon(Icons.sync),
                            ]),
                          ),
                          SizedBox(width: 10,),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isEditMode = !isEditMode;
                                var own = focusState!.getPokemonState(PlayerType(PlayerType.me), null);
                                var opp = focusState.getPokemonState(PlayerType(PlayerType.opponent), null);
                                if (isEditMode) {
                                  opponentPokeController.text = opp.pokemon.name;
                                  ownAbilityController.text = _abilityNameWithNull(own.currentAbility);
                                  opponentAbilityController.text = _abilityNameWithNull(opp.currentAbility);
                                  ownItemController.text = _itemNameWithNull(own.holdingItem);
                                  opponentItemController.text = _itemNameWithNull(opp.holdingItem);
                                  ownHPController.text = own.remainHP.toString();
                                  opponentHPController.text = opp.remainHPPercent.toString();
                                  for (int i = 0; i < 7; i++) {
                                    ownStatChanges[i] = own.statChanges(i);
                                    opponentStatChanges[i] = opp.statChanges(i);
                                  }
                                  for (int i = 0; i < 6; i++) {
                                    ownStatusMinControllers[i].text = own.minStats[i].real.toString();
                                    ownStatusMaxControllers[i].text = own.maxStats[i].real.toString();
                                    opponentStatusMinControllers[i].text = opp.minStats[i].real.toString();
                                    opponentStatusMaxControllers[i].text = opp.maxStats[i].real.toString();
                                  }
                                }
                                else {
                                  for (int i = 0; i < 7; i++) {
                                    if (ownStatChanges[i] != own.statChanges(i)) {
                                      userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.me), UserForce.rankA+i, ownStatChanges[i]));
                                    }
                                    if (opponentStatChanges[i] != opp.statChanges(i)) {
                                      userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.opponent), UserForce.rankA+i, opponentStatChanges[i]));
                                    }
                                  }
                                }
                              });
                            },
                            child: isEditMode ?
                              Row(children: [
                                Icon(Icons.check),
                                SizedBox(width: 10),
                                Text('完了'),
                              ]) :
                              Row(children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text('編集'),
                              ]),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // タイプ
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child:
                              focusState.getPokemonState(PlayerType(PlayerType.me), null).isTerastaling ?
                              Row(children: [
                                Text('テラスタル'),
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).teraType1.displayIcon,
                              ],) :
                              Row(children: [
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type1.displayIcon,
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type2 != null ?
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type2!.displayIcon : Container(),
                              ],),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child:
                              focusState.getPokemonState(PlayerType(PlayerType.opponent), null).isTerastaling ?
                              Row(children: [
                                Text('テラスタル'),
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).teraType1.displayIcon,
                              ],) :
                              Row(children: [
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type1.displayIcon,
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type2 != null ?
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type2!.displayIcon : Container(),
                              ],),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      // とくせい
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: isEditMode ?
                              TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: ownAbilityController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'とくせい',
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Ability> matches = pokeData.abilities.values.toList();
                                  matches.retainWhere((s){
                                    return toKatakana50(s.id == 0 ? '？' : s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.id == 0 ? '？' : suggestion.displayName, overflow: TextOverflow.ellipsis,),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    ownAbilityController.text = suggestion.id == 0 ? '？' : suggestion.displayName;
                                    userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.me), UserForce.ability, suggestion.id));
                                  });
                                },
                              ) :
                              AbilityText(focusState.getPokemonState(PlayerType(PlayerType.me), null).currentAbility, showHatena: true,),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: isEditMode ?
                              TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: opponentAbilityController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'とくせい',
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Ability> matches = pokeData.abilities.values.toList();
                                  matches.retainWhere((s){
                                    return toKatakana50(s.id == 0 ? '？' : s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.id == 0 ? '？' : suggestion.displayName, overflow: TextOverflow.ellipsis,),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    opponentAbilityController.text = suggestion.id == 0 ? '？' : suggestion.displayName;
                                    userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.opponent), UserForce.ability, suggestion.id));
                                  });
                                },
                              ) :
                              AbilityText(focusState.getPokemonState(PlayerType(PlayerType.opponent), null).currentAbility, showHatena: true,),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // もちもの
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: isEditMode ?
                              TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: ownItemController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'もちもの',
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Item> matches = pokeData.items.values.toList();
                                  matches.add(Item(
                                    id: -1, displayName: 'なし', displayNameEn: 'None', flingPower: 0, flingEffectId: 0,
                                    timing: AbilityTiming(0), isBerry: false, imageUrl: ''));
                                  matches.retainWhere((s){
                                    return toKatakana50(s.id == 0 ? '？' : s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.id == 0 ? '？' : suggestion.displayName, overflow: TextOverflow.ellipsis,),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    ownItemController.text = suggestion.id == 0 ? '？' : suggestion.displayName;
                                    userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.me), UserForce.item, suggestion.id));
                                  });
                                },
                              ) :
                              ItemText(focusState.getPokemonState(PlayerType(PlayerType.me), null).holdingItem, showHatena: true, showNone: true,),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: isEditMode ?
                              TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: opponentItemController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'もちもの',
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Item> matches = pokeData.items.values.toList();
                                  matches.add(Item(
                                    id: -1, displayName: 'なし', displayNameEn: 'None', flingPower: 0, flingEffectId: 0,
                                    timing: AbilityTiming(0), isBerry: false, imageUrl: ''));
                                  matches.retainWhere((s){
                                    return toKatakana50(s.id == 0 ? '？' : s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.id == 0 ? '？' : suggestion.displayName, overflow: TextOverflow.ellipsis,),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    opponentItemController.text = suggestion.id == 0 ? '？' : suggestion.displayName;
                                    userForceAdd(focusPhaseIdx, UserForce(PlayerType(PlayerType.opponent), UserForce.item, suggestion.id));
                                  });
                                },
                              ) :
                              ItemText(focusState.getPokemonState(PlayerType(PlayerType.opponent), null).holdingItem, showHatena: true, showNone: true,),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // HP
                      isEditMode ?
                      _HPInputRow(
                        ownHPController, opponentHPController,
                        (userForce) => userForceAdd(focusPhaseIdx, userForce)) :
                      _HPBarRow(
                        focusState.getPokemonState(PlayerType(PlayerType.me), null).remainHP, _focusingPokemon(PlayerType(PlayerType.me), focusState).h.real,
                        focusState.getPokemonState(PlayerType(PlayerType.opponent), null).remainHPPercent),
                      SizedBox(height: 5),
                      // 各ステータス(ABCDSAcEv)の変化/各ステータス(HABCDS)の実数値/
                      // TODO
                      for (int i = 0; i < 7; i++)
                        viewMode == 0 ?   // ランク表示
                        _StatChangeViewRow(
                          statAlphabets[i], isEditMode ? ownStatChanges[i] : focusState.getPokemonState(PlayerType(PlayerType.me), null).statChanges(i),
                          isEditMode ? opponentStatChanges[i] : focusState.getPokemonState(PlayerType(PlayerType.opponent), null).statChanges(i),
                          isEditMode ? (idx) => setState(() {
                            if (ownStatChanges[i].abs() == idx+1) {
                              if (ownStatChanges[i] > 0) {
                                ownStatChanges[i] = -ownStatChanges[i];
                              }
                              else {
                                ownStatChanges[i] = 0;
                              }
                            }
                            else {
                              ownStatChanges[i] = idx+1;
                            }
                          }) : (idx) {},
                          isEditMode ? (idx) => setState(() {
                            if (opponentStatChanges[i].abs() == idx+1) {
                              if (opponentStatChanges[i] > 0) {
                                opponentStatChanges[i] = -opponentStatChanges[i];
                              }
                              else {
                                opponentStatChanges[i] = 0;
                              }
                            }
                            else {
                              opponentStatChanges[i] = idx+1;
                            }
                          }) : (idx) {},
                        ) :
                        viewMode == 1 ?   // 種族値表示
                          i < 6 ?
                          _StatStatusViewRow(
                            statusAlphabets[i],
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).minStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).maxStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).minStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).maxStats[i].race,
                          ) : Container() :
                          // ステータス(補正前/補正後)
                          i < 6 ?
                          isEditMode ?
                          _StatStatusInputRow(
                            statusAlphabets[i],
                            ownStatusMinControllers[i], ownStatusMaxControllers[i],
                            opponentStatusMinControllers[i], opponentStatusMaxControllers[i],
                            UserForce.statMinH+i, UserForce.statMaxH+i,
                            (userForce) => userForceAdd(focusPhaseIdx, userForce),
                          ) :
                          _StatStatusViewRow(
                            statusAlphabets[i],
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).minStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).maxStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).minStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).maxStats[i].real,
                          ) : Container(),
                      SizedBox(height: 5),
                      // わざ
                      for (int i = 0; i < 4; i++)
                      _MoveViewRow(
                        focusState.getPokemonState(PlayerType(PlayerType.me), null),
                        focusState.getPokemonState(PlayerType(PlayerType.opponent), null),
                        i,
                      ),
                      SizedBox(height: 5),
                      // 状態異常・その他補正・場
                      for (int i = 0; i < max(focusState.getPokemonState(PlayerType(PlayerType.me), null).ailmentsLength, focusState.getPokemonState(PlayerType(PlayerType.opponent), null).ailmentsLength); i++)
                      _AilmentsRow(focusState.getPokemonState(PlayerType(PlayerType.me), null), focusState.getPokemonState(PlayerType(PlayerType.opponent), null), i),
                      for (int i = 0; i < max(focusState.getPokemonState(PlayerType(PlayerType.me), null).buffDebuffs.length, focusState.getPokemonState(PlayerType(PlayerType.opponent), null).buffDebuffs.length); i++)
                      _BuffDebuffsRow(focusState.getPokemonState(PlayerType(PlayerType.me), null), focusState.getPokemonState(PlayerType(PlayerType.opponent), null), i),
                      for (int i = 0; i < max(focusState.ownFields.length, focusState.opponentFields.length); i++)
                      _IndiFieldRow(focusState, i),
                      _WeatherFieldRow(focusState)
                    ],
                  ),
                ),
              ),
            ) : Container(),
            Expanded(
              flex: openStates ? 1 : 10,
              child: BattleTurnListView(
                turnScrollController,
                () {setState(() {});},
                widget.battle, turnNum, theme, 
                ownParty.pokemons[turns[turnNum-1].getInitialPokemonIndex(PlayerType(PlayerType.me))-1]!,
                opponentParty.pokemons[turns[turnNum-1].getInitialPokemonIndex(PlayerType(PlayerType.opponent))-1]!,
                textEditingControllerList1,
                textEditingControllerList2,
                textEditingControllerList3,
                textEditingControllerList4,
                appState, focusPhaseIdx,
                (phaseIdx) {
                  focusPhaseIdx = phaseIdx;
                  setState(() {});
                },
                //_getSameTimingList(pokeData),
                sameTimingList,
                isInput: true,
              ),
            ),
          ],
        );
        nextPressed = (widget.battle.turns.isNotEmpty && widget.battle.turns[turnNum-1].isValid() &&
                       getSelectedNum(appState.editingPhase) == 0 && widget.battle.turns[turnNum-1].phases.last.timing.id != AbilityTiming.gameSet) ? () => onNext() : null;
        backPressed = () => onturnBack();
        deletePressed = () => onTurnDelete();
        break;
      default:
        title = Text('バトル登録');
        lists = Center();
        nextPressed = null;
        backPressed = null;
        deletePressed = null;
        break;
    }

    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
          actions: [
            MyIconButton(
              theme: theme,
              onPressed: backPressed,
              tooltip: '前へ',
              icon: Icon(Icons.navigate_before),
            ),
            MyIconButton(
              theme: theme,
              onPressed: nextPressed,
              tooltip: '次へ',
              icon: Icon(Icons.navigate_next),
            ),
            MyIconButton(
              theme: theme,
              onPressed: deletePressed,
              tooltip: '削除',
              icon: Icon(Icons.delete),
            ),
            SizedBox(
              height: 20,
              child: VerticalDivider(
                thickness: 1,
              ),
            ),
            MyIconButton(
              theme: theme,
              onPressed: (pageType == RegisterBattlePageType.turnPage && getSelectedNum(appState.editingPhase) == 0) ? () => onComplete() : null,
              tooltip: '保存',
              icon: Icon(Icons.save),
            ),
          ],
        ),
        body: lists,
      ),
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
    textEditingControllerList4.insert(index, TextEditingController());
  }

  void _removeAtPhase(int index, MyAppState appState) {
    widget.battle.turns[turnNum-1].phases.removeAt(index);
    appState.editingPhase.removeAt(index);
    textEditingControllerList1.removeAt(index);
    textEditingControllerList2.removeAt(index);
    textEditingControllerList3.removeAt(index);
    textEditingControllerList4.removeAt(index);
  }

  void _removeRangePhase(int begin, int end, MyAppState appState) {
    widget.battle.turns[turnNum-1].phases.removeRange(begin, end);
    appState.editingPhase.removeRange(begin, end);
    textEditingControllerList1.removeRange(begin, end);
    textEditingControllerList2.removeRange(begin, end);
    textEditingControllerList3.removeRange(begin, end);
    textEditingControllerList4.removeRange(begin, end);
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
    PhaseState currentState = currentTurn.copyInitialState(
      widget.battle.getParty(PlayerType(PlayerType.me)),
      widget.battle.getParty(PlayerType(PlayerType.opponent)),
    );
    int s1 = turnNum == 1 ? 0 : 1;   // 試合最初のポケモン登場時処理状態
    int s2 = 0;   // どちらもひんしでない状態
    int end = 100;
    int i = 0;
    int actionCount = 0;
    int terastalCount = 0;
    int maxTerastal = 0;
    if (!widget.battle.turns[turnNum-1].initialOwnHasTerastal) maxTerastal++;
    if (!widget.battle.turns[turnNum-1].initialOpponentHasTerastal) maxTerastal++;
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
      10: AbilityTiming.terastaling,
      11: AbilityTiming.afterTerastal,
      12: AbilityTiming.beforeMove,
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
    //List<TurnEffect> delAssistList = [];
    PlayerType? firstActionPlayer;
    TurnEffect? lastAction;
    bool changingState = false;   // 効果によってポケモン交代した状態
    bool isAssisting = false;
    // 自動入力リスト作成
    if (isNewTurn) {
      assistList = currentState.getDefaultEffectList(
        currentTurn, AbilityTiming(currentTimingID),
        changeOwn, changeOpponent, currentState, lastAction, continuousCount,
      );
      for (final effect in currentTurn.noAutoAddEffect) {
        assistList.removeWhere((e) => effect.nearEqual(e));
      }
    }

    var phases = widget.battle.turns[turnNum-1].phases;

    while (s1 != end) {
      currentTimingID = changingState ? AbilityTiming.pokemonAppear : s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
      bool isInserted = false;
      if (changingState) {    // ポケモン交代後状態
        if (i >= phases.length || phases[i].timing.id != AbilityTiming.pokemonAppear) {
          // 自動追加
          if (assistList.isNotEmpty) {
            _insertPhase(i, assistList.first, appState);
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
            changingState = false;
          }
        }
        else {
          isAssisting = true;
        }
      }
      else {
        switch (s2) {
          case 1:       // わざでひんし状態
            if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterMove) {
              // 自動追加
              if (assistList.isNotEmpty) {
                _insertPhase(i, assistList.first, appState);
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
                    if (actionCount == 2) {
                      s1 = 8;    // ターン終了状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
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
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 12;    // 行動選択前状態へ
                  }
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
                    if (actionCount == 2) {
                      s1 = 8;    // ターン終了状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
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
                  changeOwn = false;
                  changeOpponent = false;
                  s2 = 0;
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 12;    // 行動選択前状態へ
                  }
                }
                else {
                  s2 = 2;   // わざでひんし交代状態へ
                }
              }
            }
            else {
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
                  changeOwn = false;
                  changeOpponent = false;
                  s2 = 0;
                }
                else {
                  s2 = 4;   // わざ以外でひんし状態へ
                }
              }
            }
            else {
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
                  isAssisting = true;
                }
                break;
              case 1:       // 行動決定直後処理状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterActionDecision) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
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
                    if (maxTerastal > 0) {
                      s1 = 10;    // テラスタル処理状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
                    timingListIdx++;
                    isAssisting = false;
                  }
                }
                else {
                  isAssisting = true;
                }
                break;
              case 10:      // テラスタル処理状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.terastaling) {
                  _insertPhase(i, TurnEffect()
                    ..timing = AbilityTiming(AbilityTiming.terastaling)
                    ..effect = EffectType(EffectType.terastal)
                    ..isAdding = true,
                    appState
                  );
                  isInserted = true;
                  s1 = 11;  // テラスタル後状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
                terastalCount++;
                if (terastalCount >= maxTerastal) {
                  s1 = 11;  // テラスタル後状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
                break;
              case 11:      // テラスタル後状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterTerastal) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = AbilityTiming(AbilityTiming.afterTerastal)
                      ..isAdding = true,
                      appState
                    );
                    isInserted = true;
                    s1 = 12; // 行動選択前状態へ
                    timingListIdx++;
                    isAssisting = false;
                  }
                }
                else {
                  isAssisting = true;
                }
                break;
              case 12:      // 行動選択前状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.beforeMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = AbilityTiming(AbilityTiming.beforeMove)
                      ..isAdding = true,
                      appState
                    );
                    isInserted = true;
                    s1 = 2; // 行動選択状態へ
                    timingListIdx++;
                    isAssisting = false;
                  }
                }
                else {
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
                    if (actionCount == 1) phases[i].move!.isFirst = true;
                    isInserted = true;
                    if (actionCount == 2) {
                      s1 = 8;    // ターン終了状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
                  }
                  else {
                    if (!phases[i].isValid() || phases[i].move!.type.id == TurnMoveType.surrender) {
                      if (actionCount == 2) {
                        s1 = 8;    // ターン終了状態へ
                      }
                      else {
                        s1 = 12;    // 行動選択前状態へ
                      }
                    }
                    else if (phases[i].move!.type.id == TurnMoveType.move) {
                      allowedContinuous = phases[i].move!.move.maxMoveCount()-1;
                      continuousCount = 0;
                      if (phases[i].move!.getChangePokemonIndex(PlayerType(PlayerType.me)) != null ||
                          phases[i].move!.getChangePokemonIndex(PlayerType(PlayerType.opponent)) != null
                      ) {
                        // わざが失敗/命中していなければポケモン交代も発生しない
                        if (!phases[i].move!.isNormallyHit(0)) {
                          allowedContinuous = 0;
                          s1 = 4;   // わざ使用後状態へ
                        }
                        else {
                          changeOwn = phases[i].move!.getChangePokemonIndex(PlayerType(PlayerType.me)) != null;
                          changeOpponent = phases[i].move!.getChangePokemonIndex(PlayerType(PlayerType.opponent)) != null;
                          s1 = 6;   // 交代わざ使用後状態へ
                        }
                      }
                      else {
                        // わざが失敗/命中していなければ次以降の連続こうげきは追加しない
                        if (!phases[i].move!.isNormallyHit(0)) {
                          allowedContinuous = 0;
                        }
                        s1 = 4;   // わざ使用後状態へ
                      }
                    }
                    else if (phases[i].move!.getChangePokemonIndex(phases[i].playerType) != null) {
                      s1++;   // ポケモン交代後状態へ
                      if (phases[i].playerType.id == PlayerType.me) {
                        changeOwn = true;
                      }
                      else { 
                        changeOpponent = true;
                      }
                    }
                  }
                  // 行動主の自動選択
                  if (firstActionPlayer == null) {  // 1つ目の行動
                    if (phases[i].playerType.id != PlayerType.none) {   // 1つ目の行動主が入力されているなら
                      firstActionPlayer = phases[i].playerType;
                      if (!phases[i].isValid()) {     // 行動主が入力されているが、入力された行動がまだ有効でないとき
                        // 自動補完
                        phases[i].move!.fillAuto(currentState);
                        textEditingControllerList1[i].text =
                          phases[i].getEditingControllerText1();
                        textEditingControllerList2[i].text =
                          phases[i].getEditingControllerText2(currentState, lastAction);
                        textEditingControllerList3[i].text =
                          phases[i].getEditingControllerText3(currentState, lastAction);
                        textEditingControllerList4[i].text =
                          phases[i].getEditingControllerText4(currentState);
                      }
                    }
                    else {
                      TurnMove tmp = TurnMove()..playerType = PlayerType(PlayerType.me)..type = TurnMoveType(TurnMoveType.move);
                      if (tmp.fillAuto(currentState)) {
                        phases[i].playerType = PlayerType(PlayerType.me);
                        firstActionPlayer = phases[i].playerType;
                        phases[i].move = tmp;
                        textEditingControllerList1[i].text =
                          phases[i].getEditingControllerText1();
                        textEditingControllerList2[i].text =
                          phases[i].getEditingControllerText2(currentState, lastAction);
                        textEditingControllerList3[i].text =
                          phases[i].getEditingControllerText3(currentState, lastAction);
                        textEditingControllerList4[i].text =
                          phases[i].getEditingControllerText4(currentState);
                      }
                      else {
                        tmp = TurnMove()..playerType = PlayerType(PlayerType.opponent)..type = TurnMoveType(TurnMoveType.move);
                        if (tmp.fillAuto(currentState)) {
                          phases[i].playerType = PlayerType(PlayerType.opponent);
                          firstActionPlayer = phases[i].playerType;
                          phases[i].move = tmp;
                          textEditingControllerList1[i].text =
                            phases[i].getEditingControllerText1();
                          textEditingControllerList2[i].text =
                            phases[i].getEditingControllerText2(currentState, lastAction);
                          textEditingControllerList3[i].text =
                            phases[i].getEditingControllerText3(currentState, lastAction);
                          textEditingControllerList4[i].text =
                            phases[i].getEditingControllerText4(currentState);
                        }
                      }
                    }
                  }
                  else if (phases[i].playerType.id == PlayerType.none) {    // 2つ目の行動主が未入力の場合
                    phases[i].playerType = firstActionPlayer.opposite;
                    if (phases[i].move != null) {
                      phases[i].move!.clear();
                      phases[i].move!.playerType = firstActionPlayer.opposite;
                      phases[i].move!.type = TurnMoveType(TurnMoveType.move);
                      phases[i].move!.fillAuto(currentState);
                      textEditingControllerList1[i].text =
                        phases[i].getEditingControllerText1();
                      textEditingControllerList2[i].text =
                        phases[i].getEditingControllerText2(currentState, lastAction);
                      textEditingControllerList3[i].text =
                        phases[i].getEditingControllerText3(currentState, lastAction);
                      textEditingControllerList4[i].text =
                        phases[i].getEditingControllerText4(currentState);
                    }
                  }
                  else {
                    if (!phases[i].isValid()) {     // 2つ目の行動主が入力されているが、入力された行動がまだ有効でないとき
                      // 自動補完
                      phases[i].move!.fillAuto(currentState);
                      textEditingControllerList1[i].text =
                        phases[i].getEditingControllerText1();
                      textEditingControllerList2[i].text =
                        phases[i].getEditingControllerText2(currentState, lastAction);
                      textEditingControllerList3[i].text =
                        phases[i].getEditingControllerText3(currentState, lastAction);
                      textEditingControllerList4[i].text =
                        phases[i].getEditingControllerText4(currentState);
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
                    changeOwn = false;
                    changeOpponent = false;
                    if (actionCount == 2) {
                      s1 = 8;    // ターン終了状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
                  }
                }
                else {
                  isAssisting = true;
                }
                break;
              case 4:         // わざ使用後状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.afterMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
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
                      s1 = 12;    // 行動選択前状態へ
                    }
                  }
                }
                else {
                  isAssisting = true;

                  if (phases[i].getChangePokemonIndex(PlayerType(PlayerType.me)) != null ||
                      phases[i].getChangePokemonIndex(PlayerType(PlayerType.opponent)) != null
                  ) {       // 効果によりポケモン交代が生じた場合
                    changingState = true;
                    if (continuousCount < allowedContinuous) {
                      s1 = 5;    // 連続わざ状態へ
                    }
                    else if (actionCount == 2) {
                      s1 = 8;    // ターン終了状態へ
                    }
                    else {
                      s1 = 12;    // 行動選択前状態へ
                    }
                  }
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
                    s1 = 12;    // 行動選択前状態へ
                  }
                }
                else if (!phases[i].isValid()) {
                  if (actionCount == 2) {
                    s1 = 8;    // ターン終了状態へ
                  }
                  else {
                    s1 = 12;    // 行動選択前状態へ
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
                    s1 = 3;     // ポケモン交代後状態へ
                  }
                }
                else {
                  isAssisting = true;
                }
                break;
              case 8:       // ターン終了状態
                if (i >= phases.length || phases[i].timing.id != AbilityTiming.everyTurnEnd) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    //delAssistList.add(assistList.first);
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
      }

      final guides = phases[i].processEffect(
        widget.battle.getParty(PlayerType(PlayerType.me)),
        currentState.getPokemonState(PlayerType(PlayerType.me), null),
        widget.battle.getParty(PlayerType(PlayerType.opponent)),
        currentState.getPokemonState(PlayerType(PlayerType.opponent), null),
        currentState, lastAction, continuousCount,
      );
      turnEffectAndStateAndGuides.add(
        TurnEffectAndStateAndGuide()
        ..phaseIdx = i
        ..turnEffect = phases[i]
        ..phaseState = currentState.copyWith()
        ..guides = guides
      );
      // 更新要求インデックス以降はフォームの内容を変える
      // 追加されたフェーズのフォームの内容を変える
      if (isInserted || (appState.needAdjustPhases >= 0 && appState.needAdjustPhases <= i)) {
        if (!phases[i].isAdding) {
          textEditingControllerList1[i].text = phases[i].getEditingControllerText1();
          textEditingControllerList2[i].text = phases[i].getEditingControllerText2(currentState, lastAction);
          textEditingControllerList3[i].text = phases[i].getEditingControllerText3(currentState, lastAction);
          textEditingControllerList4[i].text = phases[i].getEditingControllerText4(currentState);
        }
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
      else {
        if (s1 != end && (!isInserted || isAssisting) && i < phases.length && (phases[i].isOwnFainting || phases[i].isOpponentFainting)) {    // どちらかがひんしになる場合
          if (phases[i].isOwnFainting) isOwnFainting = true;
          if (phases[i].isOpponentFainting) isOpponentFainting = true;
          if (s2 == 1 || phases[i].timing.id == AbilityTiming.action || phases[i].timing.id == AbilityTiming.continuousMove) {
            if ((isOwnFainting && !isOpponentFainting && phases[i].playerType.id == PlayerType.me) ||
                (isOpponentFainting && !isOwnFainting && phases[i].playerType.id == PlayerType.opponent)
            ) {}
            else {      // わざ使用者のみがひんしになったのでなければ、このターンの行動はもう無い
              actionCount = 2;
            }
            s2 = 1;     // わざでひんし状態へ
          }
          else {
            s2 = 4;   // わざ以外でひんし状態へ
          }
        }
      }

      i++;

      // 自動入力効果を作成
      // 前回までと違うタイミング、かつ更新要求インデックス以降のとき作成
      if (s1 != end) {
        var nextTimingID = changingState ? AbilityTiming.pokemonAppear : s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
        if (/*(timingListIdx >= sameTimingList.length ||
            sameTimingList[timingListIdx].first.turnEffect.timing.id != nextTimingID ||*/
            ((currentTimingID != nextTimingID)/*||
            sameTimingList[timingListIdx].first.needAssist*/) &&
            appState.needAdjustPhases <= i &&
            !appState.adjustPhaseByDelete
        ) {
          var tmpAction = lastAction;
          if (nextTimingID == AbilityTiming.beforeMove) {   // わざの先読みをする
            for (int j = i; j < phases.length; j++) {
              if (phases[j].timing.id == AbilityTiming.action) {
                if (phases[j].isValid() && phases[j].move != null) {
                  tmpAction = phases[j];
                  break;
                }
                else {
                  break;
                }
              }
            }
          }
          assistList = currentState.getDefaultEffectList(
            currentTurn, AbilityTiming(nextTimingID),
            changeOwn, changeOpponent, currentState, tmpAction, continuousCount,
          );
          for (final effect in currentTurn.noAutoAddEffect) {
            assistList.removeWhere((e) => effect.nearEqual(e));
          }
          // 同じタイミングの先読みをし、既に入力済みで自動入力に含まれるものは除外する
          // それ以外で入力済みの自動入力は削除
          List<int> removeIdxs = [];
          for (int j = i; j < phases.length; j++) {
            if (phases[j].timing.id != nextTimingID) break;
            int findIdx = assistList.indexWhere((element) => element.nearEqual(phases[j]));
            if (findIdx >= 0) {
              assistList.removeAt(findIdx);
            }
            else if (phases[j].isAutoSet) {
              removeIdxs.add(j);
            }
          }
          // 削除インデックスリストの重複削除、ソート(念のため)
          removeIdxs = removeIdxs.toSet().toList();
          removeIdxs.sort();
          for (int i = removeIdxs.length-1; i >= 0; i--) {
            _removeAtPhase(removeIdxs[i], appState);
          }
          if (timingListIdx < sameTimingList.length) {
            for (var e in sameTimingList[timingListIdx]) {
              e.needAssist = false;
            }
          }
          //changeOwn = false;
          //changeOpponent = false;
        }
        else if (currentTimingID != nextTimingID) {
          assistList.clear();
          //delAssistList.clear();
        }
      }
    }

    for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
      turnEffectAndStateAndGuides[i].phaseIdx = i;
      if (turnEffectAndStateAndGuides[i].turnEffect.timing.id != timingId ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.action ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.changeFaintingPokemon
      ) {
        if (i != 0) {
          turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
            currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
          ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
        }
        beginIdx = i;
        timingId = turnEffectAndStateAndGuides[i].turnEffect.timing.id;
      }
    }

    if (phases.isNotEmpty) {
      turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
        currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
      ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, phases.length));
    }
    return ret;
  }

  void _onlySwapActionPhases() {
    int action1BeginIdx = -1;
    int action1EndIdx = -1;
    int action2BeginIdx = -1;
    int action2EndIdx = -1;
    var phases = widget.battle.turns[turnNum-1].phases;
    bool actioned = false;
    for (int i = 0; i < phases.length; i++) {
      if (phases[i].timing.id == AbilityTiming.beforeMove || phases[i].timing.id == AbilityTiming.action) {
        if (phases[i].timing.id == AbilityTiming.action) {
          if (!actioned) {
            phases[i].move!.isFirst = true;
            actioned = true;
          }
          else {
            phases[i].move!.isFirst = false;
          }
        }
        if (action1BeginIdx < 0) {
          action1BeginIdx = i;
        }
        else if (actioned) {
          assert(i >= 1);
          action1EndIdx = i-1;
          action2BeginIdx = i;
        }
      }
      else if (phases[i].timing.id == AbilityTiming.everyTurnEnd) {
        assert(i >= 1);
        action2EndIdx = i-1;
        break;
      }
    }
    // 行動を交換
    if (action1BeginIdx >= 0 && action1EndIdx >= 0 &&
        action2BeginIdx >= 0 && action2EndIdx >= 0
    ) {
      List<TurnEffect> removedPhases1 = [];
      for (int i = 0; i < action1EndIdx-action1BeginIdx+1; i++) {
        removedPhases1.add(phases.removeAt(action1BeginIdx));
      }
      List<TurnEffect> removedPhases2 = [];
      int id = action2BeginIdx - (action1EndIdx-action1BeginIdx+1);
      for (int i = 0; i < action2EndIdx-action2BeginIdx+1; i++) {
        removedPhases2.add(phases.removeAt(id));
      }
      phases.insertAll(action1BeginIdx, removedPhases2);
      id = action1BeginIdx + action2EndIdx - action1EndIdx;
      phases.insertAll(id, removedPhases1);

      List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
      PhaseState currentState = widget.battle.turns[turnNum-1].copyInitialState(
        widget.battle.getParty(PlayerType(PlayerType.me)),
        widget.battle.getParty(PlayerType(PlayerType.opponent)),
      );
      int continuousCount = 0;
      TurnEffect? lastAction;

      for (int i = 0; i < phases.length; i++) {
        if (phases[i].timing.id == AbilityTiming.action) {
          lastAction = phases[i];
          continuousCount = 0;
        }
        else if (phases[i].timing.id == AbilityTiming.continuousMove) {
          lastAction = phases[i];
          continuousCount++;
        }

        final guides = phases[i].processEffect(
          widget.battle.getParty(PlayerType(PlayerType.me)),
          currentState.getPokemonState(PlayerType(PlayerType.me), null),
          widget.battle.getParty(PlayerType(PlayerType.opponent)),
          currentState.getPokemonState(PlayerType(PlayerType.opponent), null),
          currentState, lastAction, continuousCount
        );
        turnEffectAndStateAndGuides.add(
          TurnEffectAndStateAndGuide()
          ..phaseIdx = i
          ..turnEffect = phases[i]
          ..phaseState = currentState.copyWith()
          ..guides = guides
        );
        // フォームの内容を変える
        textEditingControllerList1[i].text = phases[i].getEditingControllerText1();
        textEditingControllerList2[i].text = phases[i].getEditingControllerText2(currentState, lastAction);
        textEditingControllerList3[i].text = phases[i].getEditingControllerText3(currentState, lastAction);
        textEditingControllerList4[i].text = phases[i].getEditingControllerText4(currentState);
      }

      sameTimingList.clear();
      int timingId = turnEffectAndStateAndGuides.first.turnEffect.timing.id;
      int beginIdx = 0;
      for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
        if (turnEffectAndStateAndGuides[i].turnEffect.timing.id != timingId ||
            turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.action ||
            turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.changeFaintingPokemon
        ) {
          sameTimingList.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
          beginIdx = i;
          timingId = turnEffectAndStateAndGuides[i].turnEffect.timing.id;
        }
      }

      sameTimingList.add(turnEffectAndStateAndGuides.sublist(beginIdx, turnEffectAndStateAndGuides.length));
    }
  }

  Pokemon _focusingPokemon(PlayerType player, PhaseState focusState) {
    return widget.battle.getParty(player).pokemons[focusState.getPokemonIndex(player, null)-1]!;
  }

  String _itemNameWithNull(Item? item) {
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

  String _abilityNameWithNull(Ability ability) {
    if (ability.id == 0) {
      return '？';
    }
    else {
      return ability.displayName;
    }
  }

/*
  int _correctedSpeed(PlayerType player, PhaseState focusState) {
    int ret = widget.battle.getParty(player).pokemons[focusState.getPokemonIndex(player, null)-1]!.s.real;
    final item = focusState.getPokemonState(player, null).holdingItem;
    final ability = focusState.getPokemonState(player, null).currentAbility;
    final weather = focusState.weather;
    final ownState = focusState.getPokemonState(player, null);
    final fields = focusState.ownFields;
    bool ignoreParalysis = false;
    
    // ステータス変化
    int rank = focusState.getPokemonState(player, null).statChanges(4);
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
*/
}

class _StatChangeViewRow extends Row {
  _StatChangeViewRow(
    String label,
    int ownStatChange,
    int opponentStatChange,
    void Function(int idx) onOwnPressed,
    void Function(int idx) onOpponentPressed,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          for (int i = 0; i < ownStatChange.abs(); i++)
          ownStatChange > 0 ?
            GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.arrow_drop_up, color: Colors.red)) :
            GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.arrow_drop_down, color: Colors.blue)),
          for (int i = ownStatChange.abs(); i < 6; i++)
            GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.remove, color: Colors.grey)),
        ],),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          for (int i = 0; i < opponentStatChange.abs(); i++)
          opponentStatChange > 0 ?
            GestureDetector(onTap: () => onOpponentPressed(i), child: Icon(Icons.arrow_drop_up, color: Colors.red)) :
            GestureDetector(onTap: () => onOpponentPressed(i), child: Icon(Icons.arrow_drop_down, color: Colors.blue)),
          for (int i = opponentStatChange.abs(); i < 6; i++)
            GestureDetector(onTap: () => onOpponentPressed(i), child: Icon(Icons.remove, color: Colors.grey)),
        ],),
      ),
    ],
  );
}

class _StatStatusViewRow extends Row {
  _StatStatusViewRow(
    String label,
    int ownStatusMin,
    int ownStatusMax,
    int opponentStatusMin,
    int opponentStatusMax,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          ownStatusMin == ownStatusMax ?
          Text(ownStatusMin.toString()) :
          Text('$ownStatusMin～$ownStatusMax'),
        ],),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          opponentStatusMin == opponentStatusMax ?
          Text(opponentStatusMin.toString()) :
          Text('$opponentStatusMin～$opponentStatusMax'),
        ],),
      ),
    ],
  );
}

class _StatStatusInputRow extends Row {
  _StatStatusInputRow(
    String label,
    TextEditingController ownStatusMinController,
    TextEditingController ownStatusMaxController,
    TextEditingController opponentStatusMinController,
    TextEditingController opponentStatusMaxController,
    int statMinTypeID,
    int statMaxTypeID,
    void Function(UserForce) addFunc,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          Expanded(
            child: TextFormField(
              controller: ownStatusMinController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType(PlayerType.me), statMinTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
          Text('～'),
          Expanded(
            child: TextFormField(
              controller: ownStatusMaxController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType(PlayerType.me), statMaxTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
        ],),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          Expanded(
            child: TextFormField(
              controller: opponentStatusMinController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType(PlayerType.opponent), statMinTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
          Text('～'),
          Expanded(
            child: TextFormField(
              controller: opponentStatusMaxController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType(PlayerType.opponent), statMaxTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
        ],),
      ),
    ],
  );
}

class _MoveViewRow extends Row {
  _MoveViewRow(PokemonState ownState, PokemonState opponentState, int idx) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          ownState.moves.length > idx ?
          MoveText(ownState.moves[idx]) : Text(''),
        ],),
      ),
      ownState.moves.length > idx && ownState.usedPPs.length > idx ?
      Text(ownState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          opponentState.moves.length > idx ?
          MoveText(opponentState.moves[idx]) : Text(''),
        ],),
      ),
      opponentState.moves.length > idx && opponentState.usedPPs.length > idx ?
      Text(opponentState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
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

class _HPInputRow extends Row {
  _HPInputRow(
    TextEditingController ownHPController,
    TextEditingController opponentHPController,
    void Function(UserForce) addFunc,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: TextFormField(
          controller: ownHPController,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'HP',
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            addFunc(UserForce(PlayerType(PlayerType.me), UserForce.hp, (int.tryParse(value)??0)));
          },
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: TextFormField(
          controller: opponentHPController,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'HP',
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            addFunc(UserForce(PlayerType(PlayerType.opponent), UserForce.hp, (int.tryParse(value)??0)));
          },
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child:
                ownPokemonState.ailmentsLength > index ?
                Container(
                  color: ownPokemonState.ailments(index).bgColor,
                  child: Text(ownPokemonState.ailments(index).displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child:
                opponentPokemonState.ailmentsLength > index ?
                Container(
                  color: opponentPokemonState.ailments(index).bgColor,
                  child: Text(opponentPokemonState.ailments(index).displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
            Expanded(child: Container())
          ],
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
      Expanded(
        child: Row(
          children: [
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
          ],
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(
          children: [
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
        ),
      ),
    ],
  );
}

class _IndiFieldRow extends Row {
  _IndiFieldRow(
    PhaseState state,
    int index,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child:
                state.ownFields.length > index ?
                Container(
                  color: state.ownFields[index].bgColor,
                  child: Text(state.ownFields[index].displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
            Expanded(child: Container(),),
          ],
        ),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child:
                state.opponentFields.length > index ?
                Container(
                  color: state.opponentFields[index].bgColor,
                  child: Text(state.opponentFields[index].displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
          ],
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
