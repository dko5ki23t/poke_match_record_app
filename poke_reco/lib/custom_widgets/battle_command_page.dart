import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleCommandPage extends StatefulWidget {
  const BattleCommandPage({
    Key? key,
    required this.ownTurnMove,
    required this.ownMoveListTiles,
  }) : super(key: key);

  final TurnMove ownTurnMove;
  final List<ListTile> ownMoveListTiles;

  @override
  BattleCommandPageState createState() => BattleCommandPageState();
}

class BattleCommandPageState extends State<BattleCommandPage> {
  int mode = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );
    var ownTurnMove = widget.ownTurnMove;
    var ownMoveListTiles = widget.ownMoveListTiles;
    var loc = AppLocalizations.of(context)!;

    List<ListTile> copiedTiles = [];
    for (var tile in ownMoveListTiles) {
      copiedTiles.add(
        // TODO
        ListTile(
          dense: tile.dense,
          title: tile.title,
          subtitle: tile.subtitle,
          trailing: tile.trailing,
          onTap: () {
            tile.onTap ?? 0;
            push();
          }
        ),
      );
    }

    Widget commandColumn;
    switch (mode) {
      case 0:
        commandColumn = Column(
          children: [
            // 行動
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      ownTurnMove.type = TurnMoveType(TurnMoveType.move);
                    }),
                    style: ownTurnMove.type.id == TurnMoveType.move ? pressedStyle : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      ownTurnMove.type = TurnMoveType(TurnMoveType.change);
                    }),
                    style: ownTurnMove.type.id == TurnMoveType.change ? pressedStyle : null,
                    child: Text(loc.battlePokemonChange),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                    onPressed: () => setState(() {
                      ownTurnMove.type = TurnMoveType(TurnMoveType.surrender);
                    }),
                    style: ownTurnMove.type.id == TurnMoveType.surrender ? pressedStyle : null,
                    child: Text(loc.battleSurrender),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            for (final tile in copiedTiles)
            ownTurnMove.type.id == TurnMoveType.move ?
            tile : Container(),
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
      case 1:
        commandColumn = Column(
          children: [
            // ダメージ入力
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back))),
                ],
              ),
            ),
            NumberInputButtons(initialNum: 100,),
          ],
        );
        break;
      default:
        commandColumn = Container();
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

  void push() {
    setState(() {
      mode = 1;
    });
  }
}
