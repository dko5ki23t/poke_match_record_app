import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum CommandState {
  home,
  inputNum,
}

class BattleCommand extends StatefulWidget {
  const BattleCommand({
    Key? key,
    required this.turnMove,
    required this.moveListTiles,
  }) : super(key: key);

  final TurnMove turnMove;
  final List<ListTile> moveListTiles;

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
    var turnMove = widget.turnMove;
    var moveListTiles = widget.moveListTiles;
    var loc = AppLocalizations.of(context)!;

    List<ListTile> copiedTiles = [];
    for (var tile in moveListTiles) {
      copiedTiles.add(
        // TODO
        ListTile(
          dense: tile.dense,
          title: tile.title,
          subtitle: tile.subtitle,
          leading: tile.leading,
          trailing: tile.trailing,
          onTap: () {
            tile.onTap ?? 0;
            setState(() {
              state = CommandState.inputNum;
            });
          }
        ),
      );
    }

    Widget commandColumn;
    switch (state) {
      case CommandState.home:
        commandColumn = Column(
          key: ValueKey<int>(state.index),
          children: [
            // 行動
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType(TurnMoveType.move);
                    }),
                    style: turnMove.type.id == TurnMoveType.move ? pressedStyle : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType(TurnMoveType.change);
                    }),
                    style: turnMove.type.id == TurnMoveType.change ? pressedStyle : null,
                    child: Text(loc.battlePokemonChange),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                    onPressed: () => setState(() {
                      turnMove.type = TurnMoveType(TurnMoveType.surrender);
                    }),
                    style: turnMove.type.id == TurnMoveType.surrender ? pressedStyle : null,
                    child: Text(loc.battleSurrender),
                  ),
                ],
              ),),
            ),
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
                children: turnMove.type.id == TurnMoveType.move ? copiedTiles : [],
              ),
            ),
    /*
            type.id == TurnMoveType.change ?     // 行動が交代の場合
            Row(
              children: [
                Expanded(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battlePokemonToChange,
                    ),
                    items: playerType.id == PlayerType.me ?
                      <DropdownMenuItem>[
                        for (int i = 0; i < ownParty.pokemonNum; i++)
                          PokemonDropdownMenuItem(
                            value: i+1,
                            enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon),
                            theme: theme,
                            pokemon: ownParty.pokemons[i]!,
                            showNetworkImage: pokeData.getPokeAPI,
                          ),
                      ] :
                      <DropdownMenuItem>[
                        for (int i = 0; i < opponentParty.pokemonNum; i++)
                          PokemonDropdownMenuItem(
                            value: i+1,
                            enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                            theme: theme,
                            pokemon: opponentParty.pokemons[i]!,
                            showNetworkImage: pokeData.getPokeAPI,
                          ),
                      ],
                    value: getChangePokemonIndex(playerType),
                    onChanged: (value) {
                      setChangePokemonIndex(playerType, value);
                      appState.editingPhase[phaseIdx] = true;
                      appState.needAdjustPhases = phaseIdx+1;
                      onFocus();
                    },
                    onFocus: onFocus,
                    isInput: isInput,
                    textValue: isInput ? null : playerType.id == PlayerType.me ?
                      ownParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name :
                      opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name,
                    prefixIconPokemon: isInput ? null : playerType.id == PlayerType.me ?
                      ownParty.pokemons[getChangePokemonIndex(playerType)??1-1] :
                      opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1],
                    showNetworkImage: pokeData.getPokeAPI,
                    theme: theme,
                  ),
                ),
              ],
            ),
    */
          ],
        );
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
                    child: Text('ああ'),
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
