import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialog/delete_editing_check_dialog.dart';
//import 'package:intl/intl.dart';
import 'package:poke_reco/custom_widgets/battle_basic_listview.dart';
import 'package:poke_reco/custom_widgets/battle_first_pokemon_listview.dart';
import 'package:poke_reco/custom_widgets/battle_turn_listview.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:poke_reco/main.dart';
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

  final move1Controller = TextEditingController();
  final move2Controller = TextEditingController();
  final hp1Controller = TextEditingController();
  final hp2Controller = TextEditingController();

  final beforeMoveExpandController = ExpandableController(initialExpanded: true);
  final moveExpandController = ExpandableController(initialExpanded: true);
  final afterMoveExpandController = ExpandableController(initialExpanded: true);

  CheckedPokemons checkedPokemons = CheckedPokemons();
  int turnNum = 1;

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

    // わざ選択前処理の数と、処理編集中を示す変数の数を同じにする
    if (appState.beforeMoveEditing.length != widget.battle.turns[turnNum-1].beforeMoveEffects.length) {
      appState.beforeMoveEditing = List.generate(widget.battle.turns[turnNum-1].beforeMoveEffects.length, (i) => false);
    }

    battleNameController.text = widget.battle.name;
    opponentNameController.text = widget.battle.opponentName;
    for (int i = 0; i < widget.battle.opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = widget.battle.opponentParty.pokemons[i]!.name;
    }
    if (widget.battle.turns.length >= turnNum) {
      move1Controller.text = widget.battle.turns[turnNum-1].turnMove1.move.displayName;
      move2Controller.text = widget.battle.turns[turnNum-1].turnMove2.move.displayName;
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
          for (final pokemon in widget.battle.ownParty.pokemons) {
            if (pokemon != null) {
              widget.battle.ownPokemonStates.add(
                PokemonState()
                ..no = pokemon.no
              );
            }
          }
          for (final pokemon in widget.battle.opponentParty.pokemons) {
            if (pokemon != null) {
              widget.battle.opponentPokemonStates.add(
                PokemonState()
                ..no = pokemon.no
              );
            }
          }
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own != 0);
          assert(checkedPokemons.opponent != 0);
          if (widget.battle.turns.isEmpty) {
            Turn turn = Turn()
            ..initialOwnPokemonIndex = checkedPokemons.own
            ..initialOpponentPokemonIndex = checkedPokemons.opponent
            ..currentOwnPokemonIndex = checkedPokemons.own
            ..currentOpponentPokemonIndex = checkedPokemons.opponent
            ..changedOwnPokemon = true
            ..changedOpponentPokemon = true;
            // 初期HP設定
            for (int i = 0; i < widget.battle.ownPokemonStates.length; i++) {
              widget.battle.ownPokemonStates[i].hp = 
                widget.battle.ownParty.pokemons[i]!.h.real;
            }
            for (int i = 0; i < widget.battle.opponentPokemonStates.length; i++) {
              widget.battle.opponentPokemonStates[i].hpPercent = 100;
            }
            // 可能性あるとくせい設定
            for (int i = 0; i < widget.battle.opponentPokemonStates.length; i++) {
              widget.battle.opponentPokemonStates[i].possibleAbilities =
                pokeData.pokeBase[widget.battle.opponentParty.pokemons[i]!.no]!.ability;
            }
            turn.ownPokemonInitialStates = [];
            for (final e in widget.battle.ownPokemonStates) {
              turn.ownPokemonInitialStates.add(e.copyWith());
            }
            turn.opponentPokemonInitialStates = [];
            for (final e in widget.battle.opponentPokemonStates) {
              turn.opponentPokemonInitialStates.add(e.copyWith());
            }
            turn.updateCurrentStates(widget.battle.ownParty, widget.battle.opponentParty);

            widget.battle.turns.add(turn);
          }
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          Turn prevTurn = widget.battle.turns[turnNum-1];
          int prevOwnIndex = prevTurn.currentOwnPokemonIndex;
          int prevOpponentIndex = prevTurn.currentOpponentPokemonIndex;
          turnNum++;
          if (widget.battle.turns.length < turnNum) {
            Turn turn = Turn()
            ..initialOwnPokemonIndex = prevOwnIndex
            ..initialOpponentPokemonIndex = prevOpponentIndex
            ..currentOwnPokemonIndex = prevOwnIndex
            ..currentOpponentPokemonIndex = prevOpponentIndex
            ..changedOwnPokemon = false
            ..changedOpponentPokemon = false;
            // 前ターンの最終状態をコピー
            for (final e in prevTurn.ownPokemonCurrentStates) {
              turn.ownPokemonInitialStates.add(e.copyWith());
            }
            for (final e in prevTurn.opponentPokemonCurrentStates) {
              turn.opponentPokemonInitialStates.add(e.copyWith());
            }
            turn.updateCurrentStates(widget.battle.ownParty, widget.battle.opponentParty);

            widget.battle.turns.add(turn);
          }
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
              //flex: 10,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Expanded(
                        child: Row(children: [
                          Icon(Icons.catching_pokemon),
                          Text(widget.battle.ownParty.pokemons[widget.battle.turns[turnNum-1].currentOwnPokemonIndex-1]!.name),
                        ],),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Row(children: [
                          Icon(Icons.catching_pokemon),
                          Text(widget.battle.opponentParty.pokemons[widget.battle.turns[turnNum-1].currentOpponentPokemonIndex-1]!.name),
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
                  // 各ステータス(ABCDSE)の変化
                  for (int i = 0; i < 6; i++)
                    _StatChangeViewRow(
                      statAlphabets[i], widget.battle.turns[turnNum-1].ownPokemonCurrentStates[widget.battle.turns[turnNum-1].currentOwnPokemonIndex-1].statChanges[i],
                      widget.battle.turns[turnNum-1].opponentPokemonCurrentStates[widget.battle.turns[turnNum-1].currentOpponentPokemonIndex-1].statChanges[i]
                    ),
                ],
              ),
            ) :
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Expanded(
                    child: Row(children: [
                      Icon(Icons.catching_pokemon),
                      Text(widget.battle.ownParty.pokemons[widget.battle.turns[turnNum-1].currentOwnPokemonIndex-1]!.name),
                    ],),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Row(children: [
                      Icon(Icons.catching_pokemon),
                      Text(widget.battle.opponentParty.pokemons[widget.battle.turns[turnNum-1].currentOpponentPokemonIndex-1]!.name),
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
                widget.battle.ownParty.pokemons[widget.battle.turns[turnNum-1].currentOwnPokemonIndex-1]!,
                widget.battle.opponentParty.pokemons[widget.battle.turns[turnNum-1].currentOpponentPokemonIndex-1]!,
                move1Controller, move2Controller,
                hp1Controller, hp2Controller, beforeMoveExpandController,
                moveExpandController, afterMoveExpandController,
                appState,
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
