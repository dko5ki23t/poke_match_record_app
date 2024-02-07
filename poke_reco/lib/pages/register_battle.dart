import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/select_type_dialog.dart';
import 'package:poke_reco/custom_widgets/battle_basic_listview.dart';
import 'package:poke_reco/custom_widgets/battle_action_command.dart';
import 'package:poke_reco/custom_widgets/battle_change_fainting_command.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/battle_first_pokemon_listview.dart';
import 'package:poke_reco/custom_widgets/battle_pokemon_state_info.dart';
import 'package:poke_reco/custom_widgets/bubble_border.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_user_edit.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum RegisterBattlePageType {
  basePage,
  firstPokemonPage,
  turnPage,
}

/// 選出ポケモン
/// * own: 選出ポケモンのパーティ内インデックス(3匹分)
/// * opponent: 最初に選出されたポケモンのパーティ内インデックス(1匹分)
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
  final Future<void> Function(Party party, PhaseState state)
      onSaveOpponentParty;
  final Battle battle;
  final bool isNew;
  final RegisterBattlePageType firstPageType;
  final int firstTurnNum;

  @override
  RegisterBattlePageState createState() => RegisterBattlePageState();
}

class RegisterBattlePageState extends State<RegisterBattlePage> {
  RegisterBattlePageType pageType = RegisterBattlePageType.basePage;
  final opponentPokemonController =
      List.generate(6, (i) => TextEditingController());
  final battleNameController = TextEditingController();
  final opponentNameController = TextEditingController();
  final dateController = TextEditingController();
  final ownPartyController = TextEditingController();
  final ownCommandNavigatorKey = GlobalKey<NavigatorState>();

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
  List<TextEditingController> ownStatusMinControllers =
      List.generate(6, (index) => TextEditingController());
  List<TextEditingController> ownStatusMaxControllers =
      List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMinControllers =
      List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMaxControllers =
      List.generate(6, (index) => TextEditingController());

//  final turnScrollController = ScrollController();

  CheckedPokemons checkedPokemons = CheckedPokemons();
  List<Color> opponentFilters = [];
  int turnNum = 1;
  int focusPhaseIdx = 0; // 0は無効
  //List<List<TurnEffectAndStateAndGuide>> sameTimingList = [];
  int viewMode = 0; // 0:ランク 1:種族値 2:ステータス(補正前) 3:ステータス(補正後)
  bool isEditMode = false;

  bool isNewTurn = false;
  bool openStates = false;
  bool firstBuild = true;
  // 能力ランク編集に使う
  List<int> ownStatChanges = [0, 0, 0, 0, 0, 0, 0];
  List<int> opponentStatChanges = [0, 0, 0, 0, 0, 0, 0];

  final ownBattleCommandKey = GlobalKey<BattleCommandState>();
  final opponentBattleCommandKey = GlobalKey<BattleCommandState>();
  //PlayerType? firstActionPlayer;

/*
  TurnEffect? _getPrevTimingEffect(int index) {
    TurnEffect? ret;
    var currentTurn = widget.battle.turns[turnNum - 1];
    Timing nowTiming = currentTurn.phases[index].timing;
    for (int i = index - 1; i >= 0; i--) {
      if (currentTurn.phases[i].timing != nowTiming) {
        ret = currentTurn.phases[i];
        break;
      }
    }
    return ret;
  }
*/

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    PhaseState? focusState;

    // エイリアス
    List<Turn> turns = widget.battle.turns;
    Party ownParty = widget.battle.getParty(PlayerType.me);
    Party opponentParty = widget.battle.getParty(PlayerType.opponent);

    for (int i = 0; i < opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = opponentParty.pokemons[i]!.name;
    }
    dateController.text = widget.battle.formattedDateTime;
    ownPartyController.text = widget.battle.getParty(PlayerType.me).id != 0
        ? pokeData.parties[widget.battle.getParty(PlayerType.me).id]!.name
        : loc.battlesTabSelectParty;

    Future<bool?> showBackDialog() async {
      if (widget.battle != pokeData.battles[widget.battle.id]) {
        return showDialog<bool?>(
            context: context,
            builder: (_) {
              return DeleteEditingCheckDialog(
                null,
                () {
                  //Navigator.pop(context);
                  //appState.onTabChange = (func) => func();
                },
              );
            });
      } else {
        return true;
      }
    }

    if (firstBuild) {
      if (widget.battle.name == '') {
        widget.battle.name =
            loc.tabBattles + pokeData.battles.length.toString();
      }
      battleNameController.text = widget.battle.name;
      opponentNameController.text = widget.battle.opponentName;
      if (!widget.isNew) {
        pageType = widget.firstPageType;
        if (pageType == RegisterBattlePageType.turnPage &&
            turnNum <= turns.length) {
          turnNum = widget.firstTurnNum;
        }
      }
      firstBuild = false;
    }

    if (turns.length >= turnNum &&
        pageType == RegisterBattlePageType.turnPage) {
      // フォーカスしているフェーズの状態を取得
//      focusState = turns[turnNum-1].
//                    getProcessedStates(focusPhaseIdx-1, ownParty, opponentParty, loc);
      focusState =
          turns[turnNum - 1].updateEndingState(ownParty, opponentParty, loc);
      // 各フェーズを確認して、必要なものがあれば足したり消したりする
      /*if (appState.requestActionSwap) {
        _onlySwapActionPhases(loc);
        appState.requestActionSwap = false;
      }
      if (getSelectedNum(appState.editingPhase) == 0 || appState.needAdjustPhases >= 0) {
        sameTimingList = _adjustPhases(appState, isNewTurn, loc);
        isNewTurn = false;
        appState.needAdjustPhases = -1;
        appState.adjustPhaseByDelete = false;
      }*/
    }

    final ownLastAction = turns.isNotEmpty
        ? turns[turnNum - 1].phases.getLatestAction(PlayerType.me)
        : null;
    final opponentLastAction = turns.isNotEmpty
        ? turns[turnNum - 1].phases.getLatestAction(PlayerType.opponent)
        : null;
//    final prevState =
//        turns.isNotEmpty ? turns[turnNum - 1].copyInitialState() : null;

    Widget lists;
    Widget title;
    void Function()? nextPressed;
    void Function()? backPressed;

    void onComplete() async {
      // TODO?: 入力された値が正しいかチェック
      var battle = widget.battle;
      if (turns.isNotEmpty) {
        if (turns.last.isMyWin) {
          battle.isMyWin = true;
        }
        if (turns.last.isYourWin) {
          battle.isYourWin = true;
        }
/*
        for (var phase in turns[turnNum - 1].phases) {
          phase.isAutoSet = false;
        }
*/
        // TODO:このやり方だと5ターン入力してて3ターン目で勝利確定させるような編集されると破綻する
      }

      showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialogWithCancel(
              question: loc.battlesTabQuestionSavePartyPokemon,
              onYesPressed: () async {
                var lastState = turns.last.phases.isNotEmpty
                    ? turns.last.getProcessedStates(
                        turns.last.phases.length - 1,
                        ownParty,
                        opponentParty,
                        loc)
                    : turns.last.copyInitialState();
                var oppPokemonStates =
                    lastState.getPokemonStates(PlayerType.opponent);
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
                  for (final stat in StatIndexList.listHtoS) {
                    poke.stats.sixParams[stat.index].real =
                        pokemonState.minStats[stat].real;
                    poke.updateStatsRefReal(stat);
                  }
                  // TODO
                  for (int j = 0; j < pokemonState.moves.length; j++) {
                    if (j < poke.moves.length) {
                      poke.moves[j] = pokemonState.moves[j];
                    } else {
                      poke.moves.add(pokemonState.moves[j]);
                    }
                    if (j < poke.pps.length) {
                      poke.pps[j] = pokeData.moves[poke.moves[j]!.id]!.pp;
                    } else {
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
          });
    }

    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          pageType = RegisterBattlePageType.firstPokemonPage;
          checkedPokemons.own = [];
          checkedPokemons.opponent = 0;
          if (turns.isNotEmpty) {
            checkedPokemons.own = [0, 0, 0];
            var states = turns.first.getInitialPokemonStates(PlayerType.me);
            for (int i = 0; i < states.length; i++) {
              if (states[i].battlingNum != 0) {
                checkedPokemons.own[states[i].battlingNum - 1] = i + 1;
              }
            }
            checkedPokemons.own.removeWhere((element) => element == 0);
            checkedPokemons.opponent =
                turns[0].getInitialPokemonIndex(PlayerType.opponent);
          }
          opponentFilters = List.generate(
              opponentParty.pokemonNum, (index) => Color(0x00ffffff));
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own.isNotEmpty && checkedPokemons.own[0] != 0);
          assert(checkedPokemons.opponent != 0);
          bool battlingCheck = true;
          if (turns.isNotEmpty) {
            var states = turns.first.getInitialPokemonStates(PlayerType.me);
            for (int i = 0; i < states.length; i++) {
              if (states[i].battlingNum !=
                  checkedPokemons.own.indexWhere((e) => e == i + 1) + 1) {
                battlingCheck = false;
                break;
              }
            }
            states = turns.first.getInitialPokemonStates(PlayerType.opponent);
          }
          if (turns.isEmpty ||
              turns.first.getInitialPokemonIndex(PlayerType.me) !=
                  checkedPokemons.own[0] ||
              !battlingCheck ||
              turns.first.getInitialPokemonIndex(PlayerType.opponent) !=
                  checkedPokemons.opponent) {
            turns.clear();
            // パーティを基に初期設定したターンを作成
            Turn turn = Turn()
              ..initializeFromPartyInfo(
                  ownParty, opponentParty, checkedPokemons);
            turns.add(turn);
            isNewTurn = true;
          }
          focusPhaseIdx = 0;
          var currentTurn = turns[turnNum - 1];
          appState.editingPhase =
              List.generate(currentTurn.phases.length, (index) => false);
          // テキストフィールドの初期値設定
/*
          textEditingControllerList1 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                  text: currentTurn.phases[index].getEditingControllerText1()));
          textEditingControllerList2 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                      text: currentTurn.phases[index].getEditingControllerText2(
                    currentTurn.getProcessedStates(
                        index, ownParty, opponentParty, loc),
                    _getPrevTimingEffect(index),
                  )));
          textEditingControllerList3 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                      text: currentTurn.phases[index].getEditingControllerText3(
                    currentTurn.getProcessedStates(
                        index, ownParty, opponentParty, loc),
                    _getPrevTimingEffect(index),
                  )));
          textEditingControllerList4 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                  text: currentTurn.phases[index].getEditingControllerText4(
                      currentTurn.getProcessedStates(
                          index, ownParty, opponentParty, loc))));
*/
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          Turn prevTurn = turns[turnNum - 1];
/*
          for (var phase in prevTurn.phases) {
            phase.isAutoSet = false;
          }
*/
          turnNum++;
          if (turns.length < turnNum) {
            turns.add(Turn());
            isNewTurn = true;
          }
          var currentTurn = turns[turnNum - 1];
          /*
          PhaseState initialState = prevTurn.getProcessedStates(
              prevTurn.phases.length - 1, ownParty, opponentParty, loc);*/
          // 前ターンの最終状態を初期状態とする
          PhaseState initialState =
              prevTurn.updateEndingState(ownParty, opponentParty, loc);
          initialState.processTurnEnd(prevTurn);
          currentTurn.setInitialState(initialState);
          focusPhaseIdx = 0;
          appState.editingPhase =
              List.generate(currentTurn.phases.length, (index) => false);
          // テキストフィールドの初期値設定
          /*
          textEditingControllerList1 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                  text: currentTurn.phases[index].getEditingControllerText1()));
          textEditingControllerList2 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                      text: currentTurn.phases[index].getEditingControllerText2(
                    currentTurn.getProcessedStates(
                        index, ownParty, opponentParty, loc),
                    _getPrevTimingEffect(index),
                  )));
          textEditingControllerList3 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                      text: currentTurn.phases[index].getEditingControllerText3(
                    currentTurn.getProcessedStates(
                        index, ownParty, opponentParty, loc),
                    _getPrevTimingEffect(index),
                  )));
          textEditingControllerList4 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(
                  text: currentTurn.phases[index].getEditingControllerText4(
                      currentTurn.getProcessedStates(
                          index, ownParty, opponentParty, loc))));
                          */
          pageType = RegisterBattlePageType.turnPage;
          // 行動入力画面を初期化
          ownBattleCommandKey.currentState?.reset();
          opponentBattleCommandKey.currentState?.reset();
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
          //turnScrollController.jumpTo(0);
/*
          for (var phase in turns[turnNum - 1].phases) {
            phase.isAutoSet = false;
          }
*/
          turnNum--;
          if (turnNum == 0) {
            turnNum = 1;
            pageType = RegisterBattlePageType.firstPokemonPage;
          } else {
            var currentTurn = turns[turnNum - 1];
            appState.editingPhase =
                List.generate(currentTurn.phases.length, (index) => false);
/*
            textEditingControllerList1 = List.generate(
                currentTurn.phases.length,
                (index) => TextEditingController(
                    text:
                        currentTurn.phases[index].getEditingControllerText1()));
            textEditingControllerList2 = List.generate(
                currentTurn.phases.length,
                (index) => TextEditingController(
                        text:
                            currentTurn.phases[index].getEditingControllerText2(
                      currentTurn.getProcessedStates(
                          index, ownParty, opponentParty, loc),
                      _getPrevTimingEffect(index),
                    )));
            textEditingControllerList3 = List.generate(
                currentTurn.phases.length,
                (index) => TextEditingController(
                        text:
                            currentTurn.phases[index].getEditingControllerText3(
                      currentTurn.getProcessedStates(
                          index, ownParty, opponentParty, loc),
                      _getPrevTimingEffect(index),
                    )));
            textEditingControllerList4 = List.generate(
                currentTurn.phases.length,
                (index) => TextEditingController(
                      text: currentTurn.phases[index].getEditingControllerText4(
                        currentTurn.getProcessedStates(
                            index, ownParty, opponentParty, loc),
                      ),
                    ));
*/
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

/*
    void userForceAdd(int focusPhaseIdx, UserForce force) {
      if (focusPhaseIdx > 0) {
        turns[turnNum-1].phases[focusPhaseIdx-1].userForces.add(force);
      }
      else {
        var state = turns[turnNum-1].copyInitialState(ownParty, opponentParty);
        state.userForces.add(force);
        turns[turnNum-1].setInitialState(state, ownParty, opponentParty);
      }
    }
*/

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        title = Text(loc.battlesTabTitleBattleBase);
        lists = BattleBasicListView(
          () {
            setState(() {});
          },
          widget.battle,
          parties,
          theme,
          battleNameController,
          opponentNameController,
          dateController,
          opponentPokemonController,
          ownPartyController,
          widget.onSelectParty,
          showNetworkImage: pokeData.getPokeAPI,
          isInput: true,
          loc: loc,
        );
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        backPressed = null;
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text(loc.battlesTabTitleSelectingPokemon);
        lists = BattleFirstPokemonListView(
          () {
            setState(() {});
          },
          widget.battle,
          theme,
          checkedPokemons,
          opponentFilters,
          onTapOwnPokemon: (index) {
            opponentFilters =
                opponentParty.getCompatibilities(ownParty.pokemons[index]!);
          },
          showNetworkImage: pokeData.getPokeAPI,
          isInput: true,
          loc: loc,
        );
        nextPressed = (checkedPokemons.own.isNotEmpty &&
                checkedPokemons.own[0] != 0 &&
                checkedPokemons.opponent != 0)
            ? () => onNext()
            : null;
        backPressed = () => onturnBack();
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('${loc.battlesTabTitleTurn}$turnNum');
        if (widget.battle.turns.isNotEmpty &&
            widget.battle.turns[turnNum - 1].isValid() &&
            !widget.battle.turns[turnNum - 1].isGameSet) {
          nextPressed = () => onNext();
        } else {
          nextPressed = null;
        }
        lists = Column(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: BattlePokemonStateInfo(
                      playerType: PlayerType.me,
                      focusState: focusState!,
                      playerName: loc.battleYou,
                      onStatusEdit: (abilityChanged, ability, itemChanged, item,
                          hpChanged, remainHP) {
                        final TurnEffectUserEdit userEdit =
                            TurnEffectUserEdit();
                        if (abilityChanged) {
                          userEdit.add(UserEdit(
                              PlayerType.me, UserEdit.ability, ability.id));
                        }
                        if (itemChanged) {
                          userEdit.add(UserEdit(PlayerType.me, UserEdit.item,
                              item != null ? item.id : -1));
                        }
                        if (hpChanged) {
                          userEdit.add(
                              UserEdit(PlayerType.me, UserEdit.hp, remainHP));
                        }
                        turns[turnNum - 1].phases.addNextToLastValid(userEdit);
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 6,
                    child: ownLastAction is TurnEffectAction
                        ? BattleActionCommand(
                            key: ownBattleCommandKey,
                            playerType: PlayerType.me,
                            turnMove: ownLastAction,
                            phaseState: turns[turnNum - 1].getBeforeActionState(
                                PlayerType.me, ownParty, opponentParty, loc),
                            myParty: ownParty,
                            yourParty: opponentParty,
                            parentSetState: setState,
                            onConfirm: () => setState(() =>
                                turns[turnNum - 1].phases.updateActionOrder()),
                            onUnConfirm: () => setState(() =>
                                turns[turnNum - 1].phases.updateActionOrder()),
                            updateActionOrder: () =>
                                turns[turnNum - 1].phases.updateActionOrder(),
                            playerCanTerastal:
                                !turns[turnNum - 1].initialOwnHasTerastal,
                            onRequestTerastal: () => setState(() =>
                                turns[turnNum - 1].phases.turnOnOffTerastal(
                                    PlayerType.me,
                                    focusState!
                                        .getPokemonState(PlayerType.me, null)
                                        .pokemon
                                        .teraType)),
                          )
                        : ownLastAction is TurnEffectChangeFaintingPokemon
                            ? BattleChangeFaintingCommand(
                                playerType: PlayerType.me,
                                turnEffect: ownLastAction,
                                phaseState: turns[turnNum - 1]
                                    .getBeforeActionState(PlayerType.me,
                                        ownParty, opponentParty, loc),
                                myParty: ownParty,
                                yourParty: opponentParty,
                                parentSetState: setState,
                                onConfirm: () {
                                  //TODO
                                },
                                onUnConfirm: () {})
                            : Container(),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                const Divider(
                  height: 5,
                  thickness: 1,
                ),
                FittedBox(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    //height: theme.textTheme.bodyMedium!.fontSize! *
                    //    theme.textTheme.bodyMedium!.height!,
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final effect in turns[turnNum - 1]
                            .phases
                            .where((element) => element.isValid()))
                          Container(
                            decoration: ShapeDecoration(
                              color: Colors.green[200],
                              shape: BubbleBorder(
                                  nipInBottom:
                                      effect.playerType == PlayerType.opponent
                                          ? true
                                          : effect.playerType == PlayerType.me
                                              ? false
                                              : null),
                            ),
                            child: Text(effect.displayName(loc: loc)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 4,
                    child: BattlePokemonStateInfo(
                      playerType: PlayerType.opponent,
                      focusState: focusState,
                      playerName: widget.battle.opponentName,
                      onStatusEdit: (abilityChanged, ability, itemChanged, item,
                          hpChanged, remainHP) {
                        final TurnEffectUserEdit userEdit =
                            TurnEffectUserEdit();
                        if (abilityChanged) {
                          userEdit.add(UserEdit(PlayerType.opponent,
                              UserEdit.ability, ability.id));
                        }
                        if (itemChanged) {
                          userEdit.add(UserEdit(PlayerType.opponent,
                              UserEdit.item, item != null ? item.id : -1));
                        }
                        if (hpChanged) {
                          userEdit.add(UserEdit(
                              PlayerType.opponent, UserEdit.hp, remainHP));
                        }
                        turns[turnNum - 1].phases.addNextToLastValid(userEdit);
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 6,
                    child: opponentLastAction is TurnEffectAction
                        ? BattleActionCommand(
                            key: opponentBattleCommandKey,
                            playerType: PlayerType.opponent,
                            turnMove: opponentLastAction,
                            phaseState: turns[turnNum - 1].getBeforeActionState(
                                PlayerType.opponent,
                                ownParty,
                                opponentParty,
                                loc),
                            myParty: opponentParty,
                            yourParty: ownParty,
                            parentSetState: setState,
                            onConfirm: () => setState(() =>
                                turns[turnNum - 1].phases.updateActionOrder()),
                            onUnConfirm: () => setState(() =>
                                turns[turnNum - 1].phases.updateActionOrder()),
                            updateActionOrder: () =>
                                turns[turnNum - 1].phases.updateActionOrder(),
                            playerCanTerastal:
                                !turns[turnNum - 1].initialOpponentHasTerastal,
                            // 相手のテラスタイプ選択ダイアログ表示
                            onRequestTerastal: () {
                              if (turns[turnNum - 1]
                                  .getBeforeActionState(PlayerType.opponent,
                                      ownParty, opponentParty, loc)
                                  .getPokemonState(PlayerType.opponent, null)
                                  .isTerastaling) {
                                setState(() {
                                  turns[turnNum - 1].phases.turnOnOffTerastal(
                                      PlayerType.opponent, PokeType.unknown);
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SelectTypeDialog(
                                          (type) => setState(() =>
                                              turns[turnNum - 1]
                                                  .phases
                                                  .turnOnOffTerastal(
                                                      PlayerType.opponent,
                                                      type)),
                                          loc.commonTeraType);
                                    });
                              }
                            },
                          )
                        : opponentLastAction is TurnEffectChangeFaintingPokemon
                            ? BattleChangeFaintingCommand(
                                playerType: PlayerType.opponent,
                                turnEffect: opponentLastAction,
                                phaseState: turns[turnNum - 1]
                                    .getBeforeActionState(PlayerType.opponent,
                                        ownParty, opponentParty, loc),
                                myParty: opponentParty,
                                yourParty: ownParty,
                                parentSetState: setState,
                                onConfirm: () {
                                  //TODO
                                },
                                onUnConfirm: () {})
                            : Container(),
                  ),
                ],
              ),
            ),
          ],
        );
        backPressed = () => onturnBack();
        break;
      default:
        title = Text(loc.battlesTabTitleRegisterBattle);
        lists = Center();
        nextPressed = null;
        backPressed = null;
        break;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool? shouldPop = await showBackDialog();
        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
          actions: [
            MyIconButton(
              theme: theme,
              onPressed: backPressed,
              tooltip: loc.battlesTabToolTipPrev,
              icon: Icon(Icons.navigate_before),
            ),
            MyIconButton(
              theme: theme,
              onPressed: nextPressed,
              tooltip: loc.battlesTabToolTipNext,
              icon: Icon(Icons.navigate_next),
            ),
            SizedBox(
              height: 20,
              child: VerticalDivider(
                thickness: 1,
              ),
            ),
            MyIconButton(
              theme: theme,
              onPressed: (pageType == RegisterBattlePageType.turnPage &&
                      getSelectedNum(appState.editingPhase) == 0 &&
                      widget.battle != pokeData.battles[widget.battle.id])
                  ? () => onComplete()
                  : null,
              tooltip: loc.registerSave,
              icon: Icon(Icons.save),
            ),
          ],
        ),
        body: lists,
      ),
    );
  }

/*
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
*/

/*
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
*/

/*
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
*/

/*
  // 不要なフェーズを削除
  void _clearInvalidPhase(MyAppState appState, int index, bool pokemonAppear, bool afterMove) {
    var phases = widget.battle.turns[turnNum-1].phases;
    int endIdx = index;
    for (; endIdx < phases.length; endIdx++) {
      if (pokemonAppear && phases[endIdx].timing == Timing.pokemonAppear) {
      }
      else if (afterMove && phases[endIdx].timing == Timing.afterMove) {
      }
      else {
        break;
      }
    }
    _removeRangePhase(index, endIdx, appState);
  }
*/

/*
  List<List<TurnEffectAndStateAndGuide>> _adjustPhases(MyAppState appState, bool isNewTurn, AppLocalizations loc,) {
    _clearAddingPhase(appState);      // 一旦、追加用のフェーズは削除する

    int beginIdx = 0;
    Timing timing = Timing.none;
    List<List<TurnEffectAndStateAndGuide>> ret = [];
    List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
    Turn currentTurn = widget.battle.turns[turnNum-1];
    PhaseState currentState = currentTurn.copyInitialState(
      widget.battle.getParty(PlayerType.me),
      widget.battle.getParty(PlayerType.opponent),
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
    const Map<int, Timing> s1TimingMap = {
      0: Timing.pokemonAppear,
      1: Timing.afterActionDecision,
      2: Timing.action,
      3: Timing.pokemonAppear,
      4: Timing.afterMove,
      5: Timing.continuousMove,
      6: Timing.afterMove,
      7: Timing.changePokemonMove,
      8: Timing.everyTurnEnd,
      9: Timing.gameSet,
      10: Timing.terastaling,
      11: Timing.afterTerastal,
      12: Timing.beforeMove,
    };
    const Map<int, Timing> s2TimingMap = {
      1: Timing.afterMove,
      2: Timing.changeFaintingPokemon,
      3: Timing.pokemonAppear,
      4: Timing.changeFaintingPokemon,
      5: Timing.pokemonAppear,
      6: Timing.changeFaintingPokemon,
      7: Timing.changeFaintingPokemon,
    };
    int timingListIdx = 0;
    Timing currentTiming = s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
    List<TurnEffect> assistList = [];
    //List<TurnEffect> delAssistList = [];
    PlayerType? firstActionPlayer;
    TurnEffect? lastAction;
    bool changingState = false;   // 効果によってポケモン交代した状態
    bool isAssisting = false;
    // 自動入力リスト作成
    if (isNewTurn) {
      assistList = currentState.getDefaultEffectList(
        currentTurn, currentTiming,
        changeOwn, changeOpponent, currentState, lastAction, continuousCount,
      );
      for (final effect in currentTurn.noAutoAddEffect) {
        assistList.removeWhere((e) => effect.nearEqual(e));
      }
    }

    var phases = widget.battle.turns[turnNum-1].phases;

    while (s1 != end) {
      currentTiming = changingState ? Timing.pokemonAppear : s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
      bool isInserted = false;
      if (changingState) {    // ポケモン交代後状態
        if (i >= phases.length || phases[i].timing != Timing.pokemonAppear) {
          // 自動追加
          if (assistList.isNotEmpty) {
            _insertPhase(i, assistList.first, appState);
            assistList.removeAt(0);
            isAssisting = true;
            isInserted = true;
          }
          else {
            _insertPhase(i, TurnEffect()
              ..timing = Timing.pokemonAppear
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
            if (i >= phases.length || phases[i].timing != Timing.afterMove) {
              // 自動追加
              if (assistList.isNotEmpty) {
                _insertPhase(i, assistList.first, appState);
                assistList.removeAt(0);
                isAssisting = true;
                isInserted = true;
              }
              else {
                _insertPhase(i, TurnEffect()
                  ..timing = Timing.afterMove
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
              if (i >= phases.length || phases[i].timing != Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  isOwnFainting = false;
                  _insertPhase(i,TurnEffect()
                    ..playerType = PlayerType.me
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
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
                    ..playerType = PlayerType.opponent
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
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
                  phases[i].playerType = PlayerType.me;
                  isOwnFainting = false;
                }
                else if (isOpponentFainting) {
                  phases[i].playerType = PlayerType.opponent;
                  isOpponentFainting = false;
                }
                if (phases[i].isValid()) {
                  s2++;   // わざでひんし交代後状態へ
                  if (phases[i].playerType == PlayerType.me) {
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
            if (i >= phases.length || phases[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                _insertPhase(i, assistList.first, appState);
                assistList.removeAt(0);
                isAssisting = true;
                isInserted = true;
              }
              else {
                _insertPhase(i,TurnEffect()
                  ..timing = Timing.pokemonAppear
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
              if (i >= phases.length || phases[i].timing != Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  isOwnFainting = false;
                  _insertPhase(i,TurnEffect()
                    ..playerType = PlayerType.me
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
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
                    ..playerType = PlayerType.opponent
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
                    appState
                  );
                  isInserted = true;
                  s2 = 0;
                }
              }
              else if (phases[i].timing == Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  phases[i].playerType = PlayerType.me;
                  isOwnFainting = false;
                }
                else if (isOpponentFainting) {
                  phases[i].playerType = PlayerType.opponent;
                  isOpponentFainting = false;
                }
                if (phases[i].isValid()) {
                  s2++;   // わざ以外でひんし交代後状態へ
                  if (phases[i].playerType == PlayerType.me) {
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
            if (i >= phases.length || phases[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                _insertPhase(i, assistList.first, appState);
                assistList.removeAt(0);
                isAssisting = true;
                isInserted = true;
              }
              else {
                _insertPhase(i,TurnEffect()
                  ..timing = Timing.pokemonAppear
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
              if (i >= phases.length || phases[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && phases[i].playerType == PlayerType.me)
              ) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  _insertPhase(i,TurnEffect()
                    ..playerType = PlayerType.opponent
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
                    appState
                  );
                  isInserted = true;
                  s2 = 0;
                  s1 = 8;   // ターン終了状態へ
                }
              }
              else {
                if (phases[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                }
                else {
                  isOpponentFainting = false;
                }
                if (phases[i].isValid()) {
                  s2 = 3;   // わざでひんし交代後状態へ
                  if (phases[i].playerType == PlayerType.me) {
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
              if (i >= phases.length || phases[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && phases[i].playerType == PlayerType.me)
              ) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  _insertPhase(i,TurnEffect()
                    ..playerType = PlayerType.opponent
                    ..effectType = EffectType.changeFaintingPokemon
                    ..timing = Timing.changeFaintingPokemon,
                    appState
                  );
                  isInserted = true;
                  s2 = 0;
                }
              }
              else {
                if (phases[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                }
                else {
                  isOpponentFainting = false;
                }
                if (phases[i].isValid()) {
                  s2 = 5;   // わざ以外でひんし交代後状態へ
                  if (phases[i].playerType == PlayerType.me) {
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
                if (i >= phases.length || phases[i].timing != Timing.pokemonAppear) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.pokemonAppear
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
                if (i >= phases.length || phases[i].timing != Timing.afterActionDecision) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.afterActionDecision
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
                if (i >= phases.length || phases[i].timing != Timing.terastaling) {
                  _insertPhase(i, TurnEffect()
                    ..timing = Timing.terastaling
                    ..effectType = EffectType.terastal
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
                if (i >= phases.length || phases[i].timing != Timing.afterTerastal) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.afterTerastal
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
                if (i >= phases.length || phases[i].timing != Timing.beforeMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.beforeMove
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
                  if (i >= phases.length || phases[i].timing != Timing.action) {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.action
                      ..effectType = EffectType.move
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
                      if (phases[i].move!.getChangePokemonIndex(PlayerType.me) != null ||
                          phases[i].move!.getChangePokemonIndex(PlayerType.opponent) != null
                      ) {
                        // わざが失敗/命中していなければポケモン交代も発生しない
                        if (!phases[i].move!.isNormallyHit(0)) {
                          allowedContinuous = 0;
                          s1 = 4;   // わざ使用後状態へ
                        }
                        else {
                          changeOwn = phases[i].move!.getChangePokemonIndex(PlayerType.me) != null;
                          changeOpponent = phases[i].move!.getChangePokemonIndex(PlayerType.opponent) != null;
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
                      if (phases[i].playerType == PlayerType.me) {
                        changeOwn = true;
                      }
                      else { 
                        changeOpponent = true;
                      }
                    }
                  }
                  // 行動主の自動選択
                  if (firstActionPlayer == null) {  // 1つ目の行動
                    if (phases[i].playerType != PlayerType.none) {   // 1つ目の行動主が入力されているなら
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
                      TurnMove tmp = TurnMove()..playerType = PlayerType.me..type = TurnMoveType(TurnMoveType.move);
                      if (tmp.fillAuto(currentState)) {
                        phases[i].playerType = PlayerType.me;
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
                        tmp = TurnMove()..playerType = PlayerType.opponent..type = TurnMoveType(TurnMoveType.move);
                        if (tmp.fillAuto(currentState)) {
                          phases[i].playerType = PlayerType.opponent;
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
                  else if (phases[i].playerType == PlayerType.none) {    // 2つ目の行動主が未入力の場合
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
                if (i >= phases.length || phases[i].timing != Timing.pokemonAppear) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.pokemonAppear
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
                if (i >= phases.length || phases[i].timing != Timing.afterMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.afterMove
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

                  if (phases[i].getChangePokemonIndex(PlayerType.me) != null ||
                      phases[i].getChangePokemonIndex(PlayerType.opponent) != null
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
                if (i >= phases.length || phases[i].timing != Timing.continuousMove) {
                  _insertPhase(i, TurnEffect()
                    ..timing = Timing.continuousMove
                    ..effectType = EffectType.move
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
                if (i >= phases.length || phases[i].timing != Timing.afterMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    _insertPhase(i, assistList.first, appState);
                    assistList.removeAt(0);
                    isAssisting = true;
                    isInserted = true;
                  }
                  else {
                    _insertPhase(i, TurnEffect()
                      ..timing = Timing.afterMove
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
                if (i >= phases.length || phases[i].timing != Timing.everyTurnEnd) {
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
                      ..timing = Timing.everyTurnEnd
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
                  ..timing = Timing.gameSet
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
        widget.battle.getParty(PlayerType.me),
        currentState.getPokemonState(PlayerType.me, null),
        widget.battle.getParty(PlayerType.opponent),
        currentState.getPokemonState(PlayerType.opponent, null),
        currentState, lastAction, continuousCount, loc: loc,
      );
      turnEffectAndStateAndGuides.add(
        TurnEffectAndStateAndGuide()
        ..phaseIdx = i
        ..turnEffect = phases[i]
        ..phaseState = currentState.copy()
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
          if (s2 == 1 || phases[i].timing == Timing.action || phases[i].timing == Timing.continuousMove) {
            if ((isOwnFainting && !isOpponentFainting && phases[i].playerType == PlayerType.me) ||
                (isOpponentFainting && !isOwnFainting && phases[i].playerType == PlayerType.opponent)
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
        var nextTiming = changingState ? Timing.pokemonAppear : s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
        if (/*(timingListIdx >= sameTimingList.length ||
            sameTimingList[timingListIdx].first.turnEffect.timing != nextTiming ||*/
            ((currentTiming != nextTiming)/*||
            sameTimingList[timingListIdx].first.needAssist*/) &&
            appState.needAdjustPhases <= i &&
            !appState.adjustPhaseByDelete
        ) {
          var tmpAction = lastAction;
          if (nextTiming == Timing.beforeMove) {   // わざの先読みをする
            for (int j = i; j < phases.length; j++) {
              if (phases[j].timing == Timing.action) {
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
            currentTurn, nextTiming, changeOwn, changeOpponent, currentState, tmpAction, continuousCount,
          );
          for (final effect in currentTurn.noAutoAddEffect) {
            assistList.removeWhere((e) => effect.nearEqual(e));
          }
          // 同じタイミングの先読みをし、既に入力済みで自動入力に含まれるものは除外する
          // それ以外で入力済みの自動入力は削除
          List<int> removeIdxs = [];
          for (int j = i; j < phases.length; j++) {
            if (phases[j].timing != nextTiming) break;
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
        else if (currentTiming != nextTiming) {
          assistList.clear();
          //delAssistList.clear();
        }
      }
    }

    for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
      turnEffectAndStateAndGuides[i].phaseIdx = i;
      if (turnEffectAndStateAndGuides[i].turnEffect.timing != timing ||
          turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.action ||
          turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.changeFaintingPokemon
      ) {
        if (i != 0) {
          turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
            currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
          ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
        }
        beginIdx = i;
        timing = turnEffectAndStateAndGuides[i].turnEffect.timing;
      }
    }

    if (phases.isNotEmpty) {
      turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
        currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
      ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, phases.length));
    }
    return ret;
  }
*/

/*
  void _onlySwapActionPhases(AppLocalizations loc,) {
    int action1BeginIdx = -1;
    int action1EndIdx = -1;
    int action2BeginIdx = -1;
    int action2EndIdx = -1;
    var phases = widget.battle.turns[turnNum-1].phases;
    bool actioned = false;
    for (int i = 0; i < phases.length; i++) {
      if (phases[i].timing == Timing.beforeMove || phases[i].timing == Timing.action) {
        if (phases[i].timing == Timing.action) {
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
      else if (phases[i].timing == Timing.everyTurnEnd) {
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
        widget.battle.getParty(PlayerType.me),
        widget.battle.getParty(PlayerType.opponent),
      );
      int continuousCount = 0;
      TurnEffect? lastAction;

      for (int i = 0; i < phases.length; i++) {
        if (phases[i].timing == Timing.action) {
          lastAction = phases[i];
          continuousCount = 0;
        }
        else if (phases[i].timing == Timing.continuousMove) {
          lastAction = phases[i];
          continuousCount++;
        }

        final guides = phases[i].processEffect(
          widget.battle.getParty(PlayerType.me),
          currentState.getPokemonState(PlayerType.me, null),
          widget.battle.getParty(PlayerType.opponent),
          currentState.getPokemonState(PlayerType.opponent, null),
          currentState, lastAction, continuousCount, loc: loc,
        );
        turnEffectAndStateAndGuides.add(
          TurnEffectAndStateAndGuide()
          ..phaseIdx = i
          ..turnEffect = phases[i]
          ..phaseState = currentState.copy()
          ..guides = guides
        );
        // フォームの内容を変える
        textEditingControllerList1[i].text = phases[i].getEditingControllerText1();
        textEditingControllerList2[i].text = phases[i].getEditingControllerText2(currentState, lastAction);
        textEditingControllerList3[i].text = phases[i].getEditingControllerText3(currentState, lastAction);
        textEditingControllerList4[i].text = phases[i].getEditingControllerText4(currentState);
      }

      sameTimingList.clear();
      Timing timing = turnEffectAndStateAndGuides.first.turnEffect.timing;
      int beginIdx = 0;
      for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
        if (turnEffectAndStateAndGuides[i].turnEffect.timing != timing ||
            turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.action ||
            turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.changeFaintingPokemon
        ) {
          sameTimingList.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
          beginIdx = i;
          timing = turnEffectAndStateAndGuides[i].turnEffect.timing;
        }
      }

      sameTimingList.add(turnEffectAndStateAndGuides.sublist(beginIdx, turnEffectAndStateAndGuides.length));
    }
  }
*/

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

/*
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
*/

/*
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
                addFunc(UserForce(PlayerType.me, statMinTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
          Text(' ~ '),
          Expanded(
            child: TextFormField(
              controller: ownStatusMaxController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType.me, statMaxTypeID, (int.tryParse(value)??0)));
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
                addFunc(UserForce(PlayerType.opponent, statMinTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
          Text(' ~ '),
          Expanded(
            child: TextFormField(
              controller: opponentStatusMaxController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                addFunc(UserForce(PlayerType.opponent, statMaxTypeID, (int.tryParse(value)??0)));
              },
            ),
          ),
        ],),
      ),
    ],
  );
}
*/

/*
class _MoveViewRow extends Row {
  _MoveViewRow(PokemonState ownState, PokemonState opponentState, int idx, {required AppLocalizations loc,}) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          ownState.moves.length > idx ?
          MoveText(ownState.moves[idx], loc: loc,) : Text(''),
        ],),
      ),
      ownState.moves.length > idx && ownState.usedPPs.length > idx ?
      Text(ownState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          opponentState.moves.length > idx ?
          MoveText(opponentState.moves[idx], loc: loc,) : Text(''),
        ],),
      ),
      opponentState.moves.length > idx && opponentState.usedPPs.length > idx ?
      Text(opponentState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
    ],
  );
}
*/

/*
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
*/

/*
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
            addFunc(UserForce(PlayerType.me, UserForce.hp, (int.tryParse(value)??0)));
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
            addFunc(UserForce(PlayerType.opponent, UserForce.hp, (int.tryParse(value)??0)));
          },
        ),
      ),
    ],
  );
}
*/

/*
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
*/

/*
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
*/

/*
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
                state.getIndiFields(PlayerType.me).length > index ?
                Container(
                  color: state.getIndiFields(PlayerType.me)[index].bgColor,
                  child: Text(state.getIndiFields(PlayerType.me)[index].displayName, style: TextStyle(color: Colors.white)),
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
                state.getIndiFields(PlayerType.opponent).length > index ?
                Container(
                  color: state.getIndiFields(PlayerType.opponent)[index].bgColor,
                  child: Text(state.getIndiFields(PlayerType.opponent)[index].displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
          ],
        ),
      ),
    ],
  );
}
*/

/*
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
*/
