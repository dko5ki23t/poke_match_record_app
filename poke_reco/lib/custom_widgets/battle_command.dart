import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

enum CommandState {
  home,
  inputNum,
}

class BattleCommand extends StatefulWidget {
  const BattleCommand({
    Key? key,
    required this.playerType,
    required this.turnMove,
    required this.phaseState,
    required this.myParty,
    required this.yourParty,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnMove turnMove;
  final PhaseState phaseState;
  final Party myParty;
  final Party yourParty;

  @override
  BattleCommandState createState() => BattleCommandState();
}

class BattleCommandState extends State<BattleCommand> {
  CommandState state = CommandState.home;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );
    final loc = AppLocalizations.of(context)!;
    final turnMove = widget.turnMove;
    final prevState = widget.phaseState;
    final playerType = widget.playerType;
    final myParty = widget.myParty;
    final yourParty = widget.yourParty;
    List<Move> moves = [];
    List<ListTile> moveTiles = [];
    if (turnMove.type == TurnMoveType.move){
      var myState = prevState.getPokemonState(playerType, null);
      var myPokemon = myState.pokemon;
      var yourState = prevState.getPokemonState(playerType.opposite, null);
      var yourFields = prevState.getIndiFields(playerType.opposite);
      // 覚えているわざをリストの先頭に
      if (myPokemon.move1.isValid) moves.add(myPokemon.move1);
      if (myPokemon.move2 != null) moves.add(myPokemon.move2!);
      if (myPokemon.move3 != null) moves.add(myPokemon.move3!);
      if (myPokemon.move4 != null) moves.add(myPokemon.move4!);
      moves.addAll(PokeDB().pokeBase[myPokemon.no]!.move.where((element) => element.isValid && moves.where((e) => e.id == element.id).isEmpty,));
      moves.add(PokeDB().moves[165]!);  // わるあがき
      for (final myMove in moves) {
        DamageGetter getter = DamageGetter();
        TurnMove tmp = turnMove.copyWith();
        tmp.move = turnMove.getReplacedMove(myMove, 0, myState);
        tmp.moveHits[0] = turnMove.getMoveHit(myMove, 0, myState, yourState, yourFields);
        tmp.moveAdditionalEffects[0] = tmp.move.isSurelyEffect() ? MoveEffect(tmp.move.effect.id) : MoveEffect(0);
        tmp.moveEffectivenesses[0] = PokeType.effectiveness(
            myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
            yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
            turnMove.getReplacedMoveType(tmp.move, 0, myState, prevState), yourState);
        tmp.processMove(
          myParty.copyWith(), yourParty.copyWith(), myState.copyWith(),
          yourState.copyWith(), prevState.copyWith(), 0, [],
          damageGetter: getter, loc: loc,);
        moveTiles.add(
          ListTile(
            dense: true,
            leading: turnMove.getReplacedMoveType(myMove, 0, myState, prevState).displayIcon,
            title: Text(myMove.displayName),
            subtitle: Text('${getter.rangeString} (${getter.rangePercentString})'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              turnMove.move = myMove;
              turnMove.moveHits[0] = turnMove.getMoveHit(myMove, 0, myState, yourState, yourFields);
              turnMove.moveAdditionalEffects[0] = myMove.isSurelyEffect() ? MoveEffect(myMove.effect.id) : MoveEffect(0);
              turnMove.moveEffectivenesses[0] = PokeType.effectiveness(
                myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
                yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                turnMove.getReplacedMoveType(myMove, 0, myState, prevState), yourState
              );
              setState(() {
                state = CommandState.inputNum;
              });
            },
          ),
        );
      }
    }

    Widget commandColumn;
    switch (state) {
      case CommandState.home:
        {
          // 行動の種類選択ボタン
          final commonCommand = Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType.move;
                    }),
                    style: turnMove.type == TurnMoveType.move ? pressedStyle : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType.change;
                    }),
                    style: turnMove.type == TurnMoveType.change ? pressedStyle : null,
                    child: Text(loc.battlePokemonChange),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType.surrender;
                    }),
                    style: turnMove.type == TurnMoveType.surrender ? pressedStyle : null,
                    child: Text(loc.battleSurrender),
                  ),
                ],
              ),
            ),
          );

          late List<Widget> typeCommand;
          // 行動の種類ごとに変わる
          switch (turnMove.type) {
            case TurnMoveType.move:   // わざ
              typeCommand = [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ListViewWithViewItemCount(
                    viewItemCount: 4,
                    children: moveTiles,
                  ),
                ),
              ];
              break;
            case TurnMoveType.change: // ポケモン交代
              List<ListTile> pokemonTiles = [];
              List<int> addedIndex = [];
              for (int i = 0; i < myParty.pokemonNum; i++) {
                if (
                  prevState.isPossibleBattling(playerType, i) &&
                  !prevState.getPokemonStates(playerType)[i].isFainting &&
                  i != myParty.pokemons.indexWhere((element) => element == prevState.getPokemonState(playerType, null).pokemon)
                ) {
                  pokemonTiles.add(PokemonTile(myParty.pokemons[i]!, theme));
                  addedIndex.add(i);
                }
              }
              typeCommand = [
                Expanded(
                  flex: 7,
                  child: ListViewWithViewItemCount(
                    viewItemCount: 3,
                    children: pokemonTiles,
                  ),
                ),
              ];
              break;
            case TurnMoveType.surrender:    // こうさん
            default:
              typeCommand = [Expanded(flex: 7, child: Container(),)];
              break;
          }

          commandColumn = Column(
          key: ValueKey<int>(state.index),
          children: [
            commonCommand, ...typeCommand,
          ],
        );
        }
        break;
      case CommandState.inputNum:
        commandColumn = Column(
          key: ValueKey<int>(state.index),
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      state = CommandState.home;
                    }),
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(turnMove.move.displayName),
                  )
                ],
              ),
            ),
            // ダメージ入力
            Expanded(
              flex: 5,
              child: NumberInputButtons(initialNum: 100,),
            ),
          ],
        );
        break;
      default:
        commandColumn = Container(key: ValueKey<int>(state.index),);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Offset begin = Offset(1.0, 0.0);
        const Offset end = Offset.zero;
        final Animatable<Offset> tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        final Animation<Offset> offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      child: commandColumn,
    );
  }
}
