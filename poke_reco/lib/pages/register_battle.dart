import 'package:poke_reco/data_structs/timing.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/add_effect_dialog.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/edit_effect_dialog.dart';
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
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum RegisterBattlePageType {
  basePage,
  firstPokemonPage,
  turnPage,
}

final GlobalKey<RegisterBattlePageState> battleNameInputKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleNameInputKey');
final GlobalKey<RegisterBattlePageState> battleSelectPartyKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleSelectPartyKey');
final GlobalKey<RegisterBattlePageState> battleOpponentNameInputKey =
    GlobalKey<RegisterBattlePageState>(
        debugLabel: 'BattleOpponentNameInputKey');
final GlobalKey<RegisterBattlePageState> _battleNextButtonKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleNextButtonKey');
final GlobalKey<RegisterBattlePageState> battleSelectFirstPokemonKey =
    GlobalKey<RegisterBattlePageState>(
        debugLabel: 'BattleSelectFirstPokemonKey');
final GlobalKey<RegisterBattlePageState> _battleOwnStateInfoKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleOwnStateInfoKey');
final GlobalKey<RegisterBattlePageState> _battleOwnCommandKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleOwnCommandKey');
final GlobalKey<RegisterBattlePageState> _battleOpponentStateInfoKey =
    GlobalKey<RegisterBattlePageState>(
        debugLabel: 'BattleOpponentStateInfoKey');
final GlobalKey<RegisterBattlePageState> _battleOpponentCommandKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleOpponentCommandKey');
final GlobalKey<RegisterBattlePageState> _battleEffectListKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleEffectListKey');
final GlobalKey<RegisterBattlePageState> _battleSaveButtonKey =
    GlobalKey<RegisterBattlePageState>(debugLabel: 'BattleSaveButtonKey');

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

class RegisterBattlePageState extends State<RegisterBattlePage>
    with SingleTickerProviderStateMixin {
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
  PageController ownStatusPageController = PageController();
  PageController opponentStatusPageController = PageController();
  late AnimationController animeController;
  late SequenceAnimation colorAnimation;

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
  // 処理ビュー(画面真ん中)のスクロールコントローラ
  final effectViewScrollController = AutoScrollController();

  List<TargetFocus> tutorialTargets = [];
  List<TargetFocus> tutorialTargets2 = [];
  List<TargetFocus> tutorialTargets3 = [];

  @override
  void initState() {
    super.initState();
    animeController = AnimationController(vsync: this);
    animeController.addListener(() {
      setState(() {});
    });
    colorAnimation = SequenceAnimationBuilder()
        .addAnimatable(
            animatable: ColorTween(begin: Colors.black, end: Colors.red),
            from: Duration.zero,
            to: const Duration(milliseconds: 500),
            tag: 'color')
        .addAnimatable(
            animatable: ColorTween(begin: Colors.red, end: Colors.black),
            from: const Duration(milliseconds: 500),
            to: const Duration(milliseconds: 1000),
            tag: 'color')
        .addAnimatable(
            animatable: ColorTween(begin: Colors.black, end: Colors.red),
            from: const Duration(milliseconds: 1000),
            to: const Duration(milliseconds: 1500),
            tag: 'color')
        .addAnimatable(
            animatable: ColorTween(begin: Colors.red, end: Colors.black),
            from: const Duration(milliseconds: 1600),
            to: const Duration(milliseconds: 2000),
            tag: 'color')
        .animate(animeController);
  }

  @override
  void dispose() {
    super.dispose();
    animeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var parties = appState.parties;
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    PhaseState? focusState;
    var pageInfoIndex = StatusInfoPageIndex.none;

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
      // 各フェーズを確認して、必要なものがあれば足したり消したりする
      pageInfoIndex = turns[turnNum - 1].phases.adjust(
          isNewTurn,
          turnNum,
          turns[turnNum - 1],
          ownParty,
          opponentParty,
          widget.battle.opponentName,
          loc);
      isNewTurn = false;
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
    final ownBeforeLastActionState = turns.isNotEmpty
        ? turns[turnNum - 1]
            .getBeforeActionState(PlayerType.me, ownParty, opponentParty, loc)
        : PhaseState();
    final opponentBeforeLastActionState = turns.isNotEmpty
        ? turns[turnNum - 1].getBeforeActionState(
            PlayerType.opponent, ownParty, opponentParty, loc)
        : PhaseState();
    if (ownLastAction is TurnEffectAction) {
      // ひるみによる失敗判定
      ownLastAction.failWithFlinch(ownBeforeLastActionState, update: true);
      // まもるによる失敗判定
      ownLastAction.failWithProtect(ownBeforeLastActionState, update: true);
    }
    if (opponentLastAction is TurnEffectAction) {
      // ひるみによる失敗判定
      opponentLastAction.failWithFlinch(opponentBeforeLastActionState,
          update: true);
      // まもるによる失敗判定
      opponentLastAction.failWithProtect(opponentBeforeLastActionState,
          update: true);
    }
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

      /*showDialog(
          context: context,
          builder: (_) {
            return DeleteEditingCheckDialogWithCancel(
              question: loc.battlesTabQuestionSavePartyPokemon,
              onYesPressed: () async */
      {
        var lastState = turns.last.phases.isNotEmpty
            ? turns.last.updateEndingState(ownParty, opponentParty, loc)
            : turns.last.copyInitialState();
        var oppPokemonStates = lastState.getPokemonStates(PlayerType.opponent);
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
          await pokeData.addMyPokemon(poke, poke.id == 0, appState.notify);
        }
        opponentParty.owner = Owner.fromBattle;

        // TODO
        /*await widget.onSaveOpponentParty(
                  opponentParty,
                  lastState,
                );*/

        // TODO パーティを保存されなかった場合は、hiddenとして残す必要あり（battleを正しく保存できないため）
        // TODO refCount
        await pokeData.addBattle(battle, widget.isNew, appState.notify);
        widget.onFinish();
      } /*,
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
          });*/
    }

    void showTutorial() {
      TutorialCoachMark(
        targets: tutorialTargets,
        alignSkip: Alignment.topRight,
        textSkip: loc.tutorialSkip,
        onClickTarget: (target) {},
      ).show(context: context);
    }

    void showTutorial2() {
      TutorialCoachMark(
        targets: tutorialTargets2,
        alignSkip: Alignment.topRight,
        textSkip: loc.tutorialSkip,
        onClickTarget: (target) {},
      ).show(context: context);
    }

    void showTutorial3() {
      TutorialCoachMark(
        targets: tutorialTargets3,
        alignSkip: Alignment.topRight,
        textSkip: loc.tutorialSkip,
        onClickTarget: (target) {},
        onFinish: () => appState.inclementTutorialStep(),
        onSkip: () {
          appState.inclementTutorialStep();
          return true;
        },
      ).show(context: context);
    }

    if (appState.tutorialStep == 7) {
      appState.inclementTutorialStep();
      tutorialTargets.add(TargetFocus(
        keyTarget: battleNameInputKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleBasic,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputBattleName,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: battleSelectPartyKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleBasic2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputYourParty,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: battleOpponentNameInputKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleBasic3,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputOpponentName,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: _battleNextButtonKey,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleBasic4,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleNext,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      showTutorial();
    } else if (appState.tutorialStep == 8 &&
        pageType == RegisterBattlePageType.firstPokemonPage) {
      appState.inclementTutorialStep();
      tutorialTargets2.add(TargetFocus(
        keyTarget: battleSelectFirstPokemonKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleSelectFirstPokemon,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleSelectFirstPokemon,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets2.add(TargetFocus(
        keyTarget: _battleNextButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleSelectFirstPokemon2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleNext2,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      showTutorial2();
    } else if (appState.tutorialStep == 9 &&
        pageType == RegisterBattlePageType.turnPage) {
      appState.inclementTutorialStep();
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleOwnStateInfoKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleOwnCommandKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn2,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleOpponentStateInfoKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn3,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn3,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleOpponentCommandKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn4,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn4,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleEffectListKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn5,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn5,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleNextButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn6,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn6,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleSaveButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn7,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn7,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets3.add(TargetFocus(
        keyTarget: _battleSaveButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterBattleTurn8,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterBattleTurn8,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      showTutorial3();
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
          // 統合テスト作成用
          print("// 基本情報を入力\n"
              "await inputBattleBasicInfo(\n"
              "  driver,\n"
              "  battleName: '${widget.battle.name}',\n"
              "  ownPartyname: '${widget.battle.getParty(PlayerType.me).name}',\n"
              "  opponentName: '${widget.battle.opponentName}',\n"
              "  pokemon1: '${widget.battle.getParty(PlayerType.opponent).pokemons[0]!.name}',\n"
              "  pokemon2: '${widget.battle.getParty(PlayerType.opponent).pokemons[1]?.name}',\n"
              "  pokemon3: '${widget.battle.getParty(PlayerType.opponent).pokemons[2]?.name}',\n"
              "  pokemon4: '${widget.battle.getParty(PlayerType.opponent).pokemons[3]?.name}',\n"
              "  pokemon5: '${widget.battle.getParty(PlayerType.opponent).pokemons[4]?.name}',\n"
              "  pokemon6: '${widget.battle.getParty(PlayerType.opponent).pokemons[5]?.name}',\n"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[0]?.sex == Sex.female ? "  sex1: Sex.female,\n" : ""}"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[1]?.sex == Sex.female ? "  sex2: Sex.female,\n" : ""}"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[2]?.sex == Sex.female ? "  sex3: Sex.female,\n" : ""}"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[3]?.sex == Sex.female ? "  sex4: Sex.female,\n" : ""}"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[4]?.sex == Sex.female ? "  sex5: Sex.female,\n" : ""}"
              "${widget.battle.getParty(PlayerType.opponent).pokemons[5]?.sex == Sex.female ? "  sex6: Sex.female,\n" : ""}"
              ");\n");
          print("// 選出ポケモン選択ページへ\n"
              "  await goSelectPokemonPage(driver);\n");
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
          // 統合テスト作成用
          print("// 選出ポケモンを選ぶ\n"
              "  await selectPokemons(driver,\n"
              "      ownPokemon1: '${ownParty.pokemons[checkedPokemons.own[0] - 1]?.nickname}/',\n"
              "      ownPokemon2: '${checkedPokemons.own.length > 1 ? ownParty.pokemons[checkedPokemons.own[1] - 1]?.nickname : ''}/',\n"
              "      ownPokemon3: '${checkedPokemons.own.length > 2 ? ownParty.pokemons[checkedPokemons.own[2] - 1]?.nickname : ''}/',\n"
              "      opponentPokemon: '${opponentParty.pokemons[checkedPokemons.opponent - 1]?.name}');\n");
          print("// 各ターン入力画面へ\n"
              "  await goTurnPage(driver, turnNum++);\n\n");
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
          // 統合テスト作成用
          print("\n// ターン$turnNumへ\n"
              "await goTurnPage(driver, turnNum++);\n\n");
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

    int keyNum = 0;
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
// TODO
//            opponentFilters =
//                opponentParty.getCompatibilities(ownParty.pokemons[index]!);
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
        // 画面中央の処理リスト
        List<Widget> effectWidgetList = [];
        final currentTurn = turns[turnNum - 1];
        int addButtonCount = 0;
        int widgetIdx = 0;
        effectWidgetList.add(
            // スクロール位置を指定しやすくする
            AutoScrollTag(
                key: Key('AddIcon$addButtonCount'),
                controller: effectViewScrollController,
                index: widgetIdx++,
                child: GestureDetector(
                  onLongPress: () {}, // 移動禁止
                  child: IconButton(
                    key: Key(
                        'RegisterBattleEffectAddIconButton${addButtonCount++}'),
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      final effectList =
                          currentTurn.getEffectCandidatesWithPhaseIdx(
                        null,
                        null,
                        ownParty,
                        opponentParty,
                        currentTurn.copyInitialState(),
                        loc,
                        turnNum,
                        0,
                      );
                      // 自身の効果->相手の効果->全体の効果の順に並べ替え
                      effectList.sort((e1, e2) =>
                          e1.playerType.number.compareTo(e2.playerType.number));
                      // タイミングのみ違う効果は最後を除いて削除
                      int i = effectList.length - 1;
                      while (i >= 0) {
                        if (i >= effectList.length) {
                          i = effectList.length - 1;
                        }
                        List<int> deleteIdx = [];
                        for (int j = i - 1; j >= 0; j--) {
                          if (effectList[j].nearEqual(effectList[i],
                              allowTimingDiff: true)) {
                            deleteIdx.add(j);
                          }
                        }
                        for (final idx in deleteIdx) {
                          effectList.removeAt(idx);
                        }
                        i--;
                      }
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AddEffectDialog(
                              (effect) {
                                currentTurn.phases.insert(0, effect);
                                // 続けて効果の編集ダイアログ表示
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return EditEffectDialog(
                                      () => setState(() {
                                        currentTurn.phases.remove(effect);
                                      }),
                                      (newEffect) {
                                        setState(() {
                                          int findIdx = currentTurn.phases
                                              .indexOf(effect);
                                          currentTurn.phases[findIdx] =
                                              newEffect;
                                          // スクロール位置変更
                                          effectViewScrollController
                                              .scrollToIndex(widgetIdx + 1);
                                        });
                                      },
                                      effect.displayName(
                                        loc: loc,
                                      ),
                                      effect,
                                      currentTurn
                                          .copyInitialState()
                                          .getPokemonState(
                                              effect.playerType, null),
                                      currentTurn
                                          .copyInitialState()
                                          .getPokemonState(
                                              effect.playerType.opposite, null),
                                      ownParty,
                                      opponentParty,
                                      currentTurn.copyInitialState(),
                                    );
                                  },
                                );
                                // 統合テスト作成用
                                final playerName = effect.playerType !=
                                        PlayerType.entireField
                                    ? '${currentTurn.copyInitialState().getPokemonState(effect.playerType, null).pokemon.omittedName}の'
                                    : '';
                                final effectName = effect.displayName(loc: loc);
                                print("// $playerName$effectName\n"
                                    "await addEffect(driver, ${addButtonCount - 1}, ${effect.playerType == PlayerType.me ? 'me' : effect.playerType == PlayerType.opponent ? 'op' : 'PlayerType.entireField'}, '$effectName');\n"
                                    "await driver.tap(find.text('OK'));");
                              },
                              loc.battleAddProcess,
                              effectList,
                              '${currentTurn.copyInitialState().getPokemonState(PlayerType.me, null).pokemon.omittedName}/${loc.battleYou}',
                              null, // わざ使用後のタイミングは必ず無いのでここはnull
                              '${currentTurn.copyInitialState().getPokemonState(PlayerType.opponent, null).pokemon.omittedName}/${widget.battle.opponentName}',
                              null,
                            );
                          });
                    },
                  ),
                )));
        for (final effect
            in currentTurn.phases.where((element) => element.isValid())) {
          final phaseIdx = currentTurn.phases.indexOf(effect);
          TurnEffectAction? prevAction =
              currentTurn.phases.getPrevAction(phaseIdx);
          final phaseState = currentTurn.getProcessedStates(
              phaseIdx - 1, ownParty, opponentParty, loc);
          final myState =
              phaseState.getPokemonState(effect.playerType, prevAction);
          final yourState = phaseState.getPokemonState(
              effect.playerType.opposite, prevAction);
          final phaseStateForAdd = currentTurn.getProcessedStates(
              phaseIdx, ownParty, opponentParty, loc);

          effectWidgetList.add(AutoScrollTag(
              key: Key('TurnEffect${effect.hashCode}${keyNum++}'),
              controller: effectViewScrollController,
              index: widgetIdx++,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return EditEffectDialog(
                        () => setState(() {
                          currentTurn.phases.remove(effect);
                        }),
                        (newEffect) {
                          setState(() {
                            int findIdx = currentTurn.phases.indexOf(effect);
                            currentTurn.phases[findIdx] = newEffect;
                            // スクロール位置変更
                            effectViewScrollController
                                .scrollToIndex(widgetIdx + 1);
                          });
                        },
                        effect.displayName(
                          loc: loc,
                        ),
                        effect,
                        myState,
                        yourState,
                        ownParty,
                        opponentParty,
                        phaseState,
                      );
                    },
                  );
                  // 統合テスト作成用
                  print("// ${effect.displayName(loc: loc)}編集\n"
                      "await tapEffect(driver, '${effect.displayName(loc: loc)}');");
                },
                child: Container(
                  key: Key('EffectContainer'),
                  decoration: ShapeDecoration(
                    color: Colors.green[200],
                    shape: BubbleBorder(
                        nipInBottom: effect.playerType == PlayerType.opponent
                            ? true
                            : effect.playerType == PlayerType.me
                                ? false
                                : null),
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Text(effect.displayName(loc: loc)),
                ),
              )));
          // 処理追加ボタン
          effectWidgetList.add(AutoScrollTag(
              key: Key('AddIcon$addButtonCount'),
              controller: effectViewScrollController,
              index: widgetIdx++,
              child: GestureDetector(
                onLongPress: () {}, // 移動禁止
                child: IconButton(
                  key: Key(
                      'RegisterBattleEffectAddIconButton${addButtonCount++}'),
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    final effectList =
                        currentTurn.getEffectCandidatesWithPhaseIdx(
                      null,
                      null,
                      ownParty,
                      opponentParty,
                      phaseStateForAdd,
                      loc,
                      turnNum,
                      phaseIdx + 1,
                    );
                    // 自身の効果->相手の効果->全体の効果(その次にタイミング)の順に並べ替え
                    effectList.sort(
                        (e1, e2) => e1.timing.index.compareTo(e2.timing.index));
                    effectList.sort((e1, e2) =>
                        e1.playerType.number.compareTo(e2.playerType.number));
                    // タイミングにわざ使用後が含まれる＋交代わざの場合、
                    // 交代前の効果も候補に加える(効果の対象が交代前と交代後の2種類できる)ため、
                    // 最後に使用されたわざを取得する
                    TurnEffectAction? prevChangeMove;
                    bool isChangeMe = false;
                    bool isChangeOpponent = false;
                    if (effectList
                        .where((element) => element.timing == Timing.afterMove)
                        .isNotEmpty) {
                      for (int t = phaseIdx; t >= 0; t--) {
                        if (currentTurn.phases[t] is TurnEffectAction &&
                            (currentTurn.phases[t] as TurnEffectAction).type ==
                                TurnActionType.move) {
                          if (currentTurn.phases[t]
                                  .getChangePokemonIndex(PlayerType.me) !=
                              null) {
                            isChangeMe = true;
                          }
                          if (currentTurn.phases[t]
                                  .getChangePokemonIndex(PlayerType.opponent) !=
                              null) {
                            isChangeOpponent = true;
                          }
                          prevChangeMove =
                              currentTurn.phases[t] as TurnEffectAction;
                          break;
                        }
                      }
                    }
                    // タイミングのみ違う効果は最後を除いて削除
                    // (交代わざの使用後タイミングは別物としてカウントする(削除しない))
                    int i = effectList.length - 1;
                    while (i >= 0) {
                      if (i >= effectList.length) {
                        i = effectList.length - 1;
                      }
                      List<int> deleteIdx = [];
                      for (int j = i - 1; j >= 0; j--) {
                        if (effectList[j].nearEqual(effectList[i],
                            allowTimingDiff: true,
                            isChangeMe: isChangeMe,
                            isChangeOpponent: isChangeOpponent)) {
                          deleteIdx.add(j);
                        }
                      }
                      for (final idx in deleteIdx) {
                        effectList.removeAt(idx);
                      }
                      i--;
                    }
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AddEffectDialog(
                            (eff) {
                              currentTurn.phases.insert(phaseIdx + 1, eff);
                              // スクロール位置変更
                              effectViewScrollController
                                  .scrollToIndex(widgetIdx + 1);
                              // 続けて効果の編集ダイアログ表示
                              TurnEffectAction? prevA = currentTurn.phases
                                  .getPrevAction(phaseIdx + 1);
                              final phaseS = currentTurn.getProcessedStates(
                                  phaseIdx, ownParty, opponentParty, loc);
                              final myS =
                                  phaseS.getPokemonState(eff.playerType, prevA);
                              final yourS = phaseS.getPokemonState(
                                  eff.playerType.opposite, prevA);
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return EditEffectDialog(
                                    () => setState(() {
                                      currentTurn.phases.remove(eff);
                                    }),
                                    (newEffect) {
                                      setState(() {
                                        int findIdx =
                                            currentTurn.phases.indexOf(eff);
                                        currentTurn.phases[findIdx] = newEffect;
                                        // スクロール位置変更
                                        effectViewScrollController
                                            .scrollToIndex(widgetIdx + 1);
                                      });
                                      // 統合テスト作成用
                                      final playerName = newEffect.playerType !=
                                              PlayerType.entireField
                                          ? '${currentTurn.copyInitialState().getPokemonState(newEffect.playerType, null).pokemon.omittedName}の'
                                          : '';
                                      final effectName =
                                          newEffect.displayName(loc: loc);
                                      print("// $playerName$effectName\n"
                                          "await addEffect(driver, ${addButtonCount - 1}, ${newEffect.playerType == PlayerType.me ? 'me' : newEffect.playerType == PlayerType.opponent ? 'op' : 'PlayerType.entireField'}, '$effectName');\n");
                                    },
                                    eff.displayName(
                                      loc: loc,
                                    ),
                                    eff,
                                    myS,
                                    yourS,
                                    ownParty,
                                    opponentParty,
                                    phaseS,
                                  );
                                },
                              );
                            },
                            loc.battleAddProcess,
                            effectList,
                            '${phaseStateForAdd.getPokemonState(PlayerType.me, null).pokemon.omittedName}/${loc.battleYou}',
                            isChangeMe
                                ? '${phaseStateForAdd.getPokemonState(PlayerType.me, prevChangeMove).pokemon.omittedName}/${loc.battleYou}'
                                : null,
                            '${phaseStateForAdd.getPokemonState(PlayerType.opponent, null).pokemon.omittedName}/${widget.battle.opponentName}',
                            isChangeOpponent
                                ? '${phaseStateForAdd.getPokemonState(PlayerType.opponent, prevChangeMove).pokemon.omittedName}/${widget.battle.opponentName}'
                                : null,
                          );
                        });
                  },
                ),
              )));
        }
        lists = Column(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    key: _battleOwnStateInfoKey,
                    flex: 4,
                    child: BattlePokemonStateInfo(
                      playerType: PlayerType.me,
                      focusState: focusState!,
                      pageController: ownStatusPageController,
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
                        currentTurn.phases.addNextToLastValid(userEdit);
                        effectViewScrollController.scrollToIndex((currentTurn
                                        .phases
                                        .where((element) => element.isValid())
                                        .length -
                                    1) *
                                2 +
                            1);
                        setState(() {});
                      },
                      animeController: animeController,
                      colorAnimation: colorAnimation,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    key: _battleOwnCommandKey,
                    flex: 6,
                    child: ownLastAction is TurnEffectAction
                        ? BattleActionCommand(
                            key: ownBattleCommandKey,
                            playerType: PlayerType.me,
                            turnMove: ownLastAction,
                            phaseState: ownBeforeLastActionState,
                            myParty: ownParty,
                            yourParty: opponentParty,
                            parentSetState: setState,
                            onConfirm: () => setState(() {
                              currentTurn.phases.updateActionOrder();
                              ownLastAction.failWithProtect(
                                  currentTurn.getBeforeActionState(
                                      PlayerType.me,
                                      ownParty,
                                      opponentParty,
                                      loc),
                                  update: true);
                              effectViewScrollController.scrollToIndex(
                                  currentTurn.phases.getLatestActionIndex(
                                              PlayerType.me,
                                              onlyValids: true) *
                                          2 +
                                      1);
                            }),
                            onUnConfirm: () => setState(
                                () => currentTurn.phases.updateActionOrder()),
                            updateActionOrder: () =>
                                currentTurn.phases.updateActionOrder(),
                            playerCanTerastal:
                                !currentTurn.initialOwnHasTerastal,
                            onRequestTerastal: () => setState(() =>
                                currentTurn.phases.turnOnOffTerastal(
                                    PlayerType.me,
                                    focusState!
                                        .getPokemonState(PlayerType.me, null)
                                        .pokemon
                                        .teraType,
                                    turnNum,
                                    currentTurn)),
                          )
                        : ownLastAction is TurnEffectChangeFaintingPokemon
                            ? BattleChangeFaintingCommand(
                                playerType: PlayerType.me,
                                turnEffect: ownLastAction,
                                phaseState: ownBeforeLastActionState,
                                myParty: ownParty,
                                yourParty: opponentParty,
                                parentSetState: setState,
                                onConfirm: () {
                                  effectViewScrollController.scrollToIndex(
                                      currentTurn.phases.getLatestActionIndex(
                                                  PlayerType.me,
                                                  onlyValids: true) *
                                              2 +
                                          1);
                                },
                                onUnConfirm: () {})
                            : Container(),
                  ),
                ],
              ),
            ),
            Stack(
              key: _battleEffectListKey,
              alignment: Alignment.center,
              children: [
                const Divider(
                  height: 5,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                ),
                FittedBox(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    //height: theme.textTheme.bodyMedium!.fontSize! *
                    //    theme.textTheme.bodyMedium!.height!,
                    height: 50,
                    child: ReorderableListView(
                      key: Key('EffectListView'),
                      scrollDirection: Axis.horizontal,
                      scrollController: effectViewScrollController,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex == currentTurn.phases.length ||
                            newIndex == currentTurn.phases.length) {
                          // 処理追加ボタンの入れ替えや処理追加ボタンの後ろへの移動は無効
                          return;
                        }
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = currentTurn.phases.removeAt(oldIndex);
                          if (currentTurn.phases
                              .insertableTimings(newIndex, turnNum, currentTurn)
                              .contains(item.timing)) {
                            currentTurn.phases.insert(newIndex, item);
                          } else {
                            // 入れ替えない
                            currentTurn.phases.insert(oldIndex, item);
                          }
                        });
                      },
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      children: effectWidgetList,
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
                    key: _battleOpponentStateInfoKey,
                    flex: 4,
                    child: BattlePokemonStateInfo(
                      playerType: PlayerType.opponent,
                      focusState: focusState,
                      pageController: opponentStatusPageController,
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
                        currentTurn.phases.addNextToLastValid(userEdit);
                        effectViewScrollController.scrollToIndex((currentTurn
                                        .phases
                                        .where((element) => element.isValid())
                                        .length -
                                    1) *
                                2 +
                            1);
                        setState(() {});
                      },
                      animeController: animeController,
                      colorAnimation: colorAnimation,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    key: _battleOpponentCommandKey,
                    flex: 6,
                    child: opponentLastAction is TurnEffectAction
                        ? BattleActionCommand(
                            key: opponentBattleCommandKey,
                            playerType: PlayerType.opponent,
                            turnMove: opponentLastAction,
                            phaseState: opponentBeforeLastActionState,
                            myParty: opponentParty,
                            yourParty: ownParty,
                            parentSetState: setState,
                            onConfirm: () => setState(() {
                              currentTurn.phases.updateActionOrder();
                              opponentLastAction.failWithProtect(
                                  currentTurn.getBeforeActionState(
                                      PlayerType.opponent,
                                      ownParty,
                                      opponentParty,
                                      loc),
                                  update: true);
                              effectViewScrollController.scrollToIndex(
                                  currentTurn.phases.getLatestActionIndex(
                                              PlayerType.opponent,
                                              onlyValids: true) *
                                          2 +
                                      1);
                            }),
                            onUnConfirm: () => setState(
                                () => currentTurn.phases.updateActionOrder()),
                            updateActionOrder: () =>
                                currentTurn.phases.updateActionOrder(),
                            playerCanTerastal:
                                !currentTurn.initialOpponentHasTerastal,
                            // 相手のテラスタイプ選択ダイアログ表示
                            onRequestTerastal: () {
                              if (currentTurn
                                  .getBeforeActionState(PlayerType.opponent,
                                      ownParty, opponentParty, loc)
                                  .getPokemonState(PlayerType.opponent, null)
                                  .isTerastaling) {
                                setState(() {
                                  currentTurn.phases.turnOnOffTerastal(
                                      PlayerType.opponent,
                                      PokeType.unknown,
                                      turnNum,
                                      currentTurn);
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SelectTypeDialog(
                                          (type) => setState(() => currentTurn
                                              .phases
                                              .turnOnOffTerastal(
                                                  PlayerType.opponent,
                                                  type,
                                                  turnNum,
                                                  currentTurn)),
                                          loc.commonTeraType);
                                    });
                              }
                            },
                          )
                        : opponentLastAction is TurnEffectChangeFaintingPokemon
                            ? BattleChangeFaintingCommand(
                                playerType: PlayerType.opponent,
                                turnEffect: opponentLastAction,
                                phaseState: opponentBeforeLastActionState,
                                myParty: opponentParty,
                                yourParty: ownParty,
                                parentSetState: setState,
                                onConfirm: () {
                                  effectViewScrollController.scrollToIndex(
                                      currentTurn.phases.getLatestActionIndex(
                                                  PlayerType.opponent,
                                                  onlyValids: true) *
                                              2 +
                                          1);
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
        // ステータス画面下部のページ移動
        if (pageInfoIndex != StatusInfoPageIndex.none &&
            opponentStatusPageController.hasClients) {
          int currentPage = opponentStatusPageController.page!.toInt();
          opponentStatusPageController
              .animateToPage(pageInfoIndex.index - 1,
                  duration: Duration(milliseconds: 500), curve: Curves.ease)
              .then((value) async {
            await Future.delayed(Duration(seconds: 1));
            // TODO:保存時？にここでバグる
            // この条件を付けておかないと、対戦保存時にページが遷移したときに例外が起きてしまう
            if (opponentStatusPageController.hasClients) {
              opponentStatusPageController.animateToPage(currentPage,
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
            }
          });
          animeController.forward();
        }
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
              key: Key('RegisterBattleNext'), // テストでの識別用
              theme: theme,
              onPressed: nextPressed,
              tooltip: loc.battlesTabToolTipNext,
              icon: Icon(key: _battleNextButtonKey, Icons.navigate_next),
            ),
            SizedBox(
              height: 20,
              child: VerticalDivider(
                thickness: 1,
              ),
            ),
            MyIconButton(
              key: Key('RegisterBattleSave'), // テストでの識別用
              theme: theme,
              onPressed: (pageType == RegisterBattlePageType.turnPage &&
                      getSelectedNum(appState.editingPhase) == 0 &&
                      widget.battle != pokeData.battles[widget.battle.id])
                  ? () => onComplete()
                  : null,
              tooltip: loc.registerSave,
              icon: Icon(key: _battleSaveButtonKey, Icons.save),
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
