import 'package:flutter/material.dart';
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

  final move1Controller = TextEditingController();
  final move2Controller = TextEditingController();

  final hp1Controller = TextEditingController();

  CheckedPokemons checkedPokemons = CheckedPokemons();
  late Pokemon currentOwnPokemon;
  late Pokemon currentOpponentPokemon;
  int turn = 1;
  int turnPlayer1 = 0;    // ターン内で先に行動する者のID
  Move turnMove1 = Move(0, '', 0);  // ターン内で先に実行されたわざ
  int turnPlayer2 = 0;    // ターン内で先に行動する者のID
  Move turnMove2 = Move(0, '', 0);  // ターン内で先に実行されたわざ

  // 引用：https://417.run/pg/flutter-dart/hiragana-to-katakana/
  static toKatakana(String str) {
    return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
  }

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
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);

    Widget lists;
    Widget title;
    void Function()? nextPressed;

    void onComplete() {
      // TODO?: 入力された値が正しいかチェック
      if (widget.isNew) {
        battles.add(widget.battle);
      }
//      pokeData.addParty(widget.party, parties.length);
      widget.onFinish();
    }

    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.basePage:
          pageType = RegisterBattlePageType.firstPokemonPage;
          checkedPokemons.own = 0;
          checkedPokemons.opponent = 0;
          setState(() {});
          break;
        case RegisterBattlePageType.firstPokemonPage:
          assert(checkedPokemons.own != 0);
          assert(checkedPokemons.opponent != 0);
          currentOwnPokemon = widget.battle.ownParty.pokemons[checkedPokemons.own - 1]!;
          currentOpponentPokemon = widget.battle.ownParty.pokemons[checkedPokemons.opponent - 1]!;
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          turn++;
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
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
          theme, pokeData, opponentPokemonController);
        nextPressed = (widget.battle.isValid) ? () => onNext() : null;
        break;
      case RegisterBattlePageType.firstPokemonPage:
        title = Text('先頭ポケモン');
        lists = BattleFirstPokemonListView(
          () {setState(() {});},
          widget.battle, theme, pokeData,
          checkedPokemons);
        nextPressed = (checkedPokemons.own != 0 && checkedPokemons.opponent != 0) ? () => onNext() : null;
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('$turnターン目');
        lists = BattleTurnListView(
          () {setState(() {});},
          widget.battle, theme, pokeData,
          currentOwnPokemon, currentOpponentPokemon,
          turnPlayer1, turnPlayer2,
          move1Controller, move2Controller,
          hp1Controller);
        nextPressed = () => onNext();
        break;
      default:
        title = Text('バトル登録');
        lists = Center();
        nextPressed = null;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? title : Text('バトル編集'),
        actions: [
          TextButton(
            onPressed: nextPressed,
            child: Text('次へ'),
          ),
        ],
      ),
      body: lists,
    );
  }
}