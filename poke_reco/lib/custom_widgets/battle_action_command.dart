import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/tool.dart';

enum CommandState {
  selectCommand,
  extraInput,
}

class BattleActionCommand extends StatefulWidget {
  const BattleActionCommand({
    Key? key,
    required this.playerType,
    required this.turnMove,
    required this.phaseState,
    required this.myParty,
    required this.yourParty,
    required this.parentSetState,
    required this.onConfirm,
    required this.onUnConfirm,
    required this.isFirstAction,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnMove turnMove;
  final PhaseState phaseState;
  final Party myParty;
  final Party yourParty;
  final Function(void Function()) parentSetState;
  final Function() onConfirm;
  final Function() onUnConfirm;
  final bool? isFirstAction;

  @override
  BattleActionCommandState createState() => BattleActionCommandState();
}

class BattleActionCommandState extends BattleCommandState<BattleActionCommand> {
  CommandState state = CommandState.selectCommand;
  TextEditingController moveSearchTextController = TextEditingController();
  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );
    final loc = AppLocalizations.of(context)!;
    final parentSetState = widget.parentSetState;
    final turnMove = widget.turnMove;
    final prevState = widget.phaseState;
    final playerType = widget.playerType;
    final myParty = widget.myParty;
    final yourParty = widget.yourParty;
    final myState = prevState.getPokemonState(playerType, null);
    final yourState = prevState.getPokemonState(playerType.opposite, null);
    List<Move> moves = [];
    List<ListTile> moveTiles = [];
    if (turnMove.type == TurnMoveType.move) {
      var myPokemon = myState.pokemon;
      var yourFields = prevState.getIndiFields(playerType.opposite);
      // 覚えているわざをリストの先頭に
      for (final acquiringMove in myState.moves) {
        moves.add(acquiringMove);
      }
      moves.addAll(PokeDB().pokeBase[myPokemon.no]!.move.where(
            (element) =>
                element.isValid &&
                moves.where((e) => e.id == element.id).isEmpty,
          ));
      moves.add(PokeDB().moves[165]!); // わるあがき
      // 検索窓の入力でフィルタリング
      final pattern = moveSearchTextController.text;
      if (pattern != '') {
        moves.retainWhere((s) {
          return toKatakana50(s.displayName.toLowerCase())
              .contains(toKatakana50(pattern.toLowerCase()));
        });
      }
      for (int i = 0; i < moves.length; i++) {
        final myMove = moves[i];
        DamageGetter getter = DamageGetter();
        TurnMove tmp = turnMove.copy();
        tmp.move = turnMove.getReplacedMove(myMove, 0, myState);
        tmp.moveHits[0] =
            turnMove.getMoveHit(myMove, 0, myState, yourState, yourFields);
        tmp.moveAdditionalEffects[0] = tmp.move.isSurelyEffect()
            ? MoveEffect(tmp.move.effect.id)
            : MoveEffect(0);
        tmp.moveEffectivenesses[0] = PokeTypeEffectiveness.effectiveness(
            myState.currentAbility.id == 113 ||
                myState.currentAbility.id == 299,
            yourState.holdingItem?.id == 586,
            yourState
                .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                .isNotEmpty,
            turnMove.getReplacedMoveType(tmp.move, 0, myState, prevState),
            yourState);
        tmp.processMove(
          myParty.copyWith(),
          yourParty.copyWith(),
          myState.copyWith(),
          yourState.copyWith(),
          prevState.copyWith(),
          0,
          [],
          damageGetter: getter,
          loc: loc,
        );
        moveTiles.add(
          ListTile(
            dense: true,
            leading: turnMove
                .getReplacedMoveType(myMove, 0, myState, prevState)
                .displayIcon,
            title: Text(myMove.displayName),
            tileColor: i < myState.moves.length ? Colors.yellow[200] : null,
            subtitle:
                Text('${getter.rangeString} (${getter.rangePercentString})'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              parentSetState(() {
                turnMove.move = myMove;
                turnMove.moveHits[0] = turnMove.getMoveHit(
                    myMove, 0, myState, yourState, yourFields);
                turnMove.moveAdditionalEffects[0] = myMove.isSurelyEffect()
                    ? MoveEffect(myMove.effect.id)
                    : MoveEffect(0);
                turnMove.moveEffectivenesses[0] =
                    PokeTypeEffectiveness.effectiveness(
                        myState.currentAbility.id == 113 ||
                            myState.currentAbility.id == 299,
                        yourState.holdingItem?.id == 586,
                        yourState
                            .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                            .isNotEmpty,
                        turnMove.getReplacedMoveType(
                            myMove, 0, myState, prevState),
                        yourState);
                state = CommandState.extraInput;
              });
            },
          ),
        );
      }
    }

    Widget commandColumn;
    switch (state) {
      case CommandState.selectCommand:
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
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnMoveType.move;
                      // TODO: typeを変えたら他も変える？class継承とかでどうにか
                      turnMove.setChangePokemonIndex(playerType, null);
                    }),
                    style: turnMove.type == TurnMoveType.move
                        ? pressedStyle
                        : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnMoveType.change;
                    }),
                    style: turnMove.type == TurnMoveType.change
                        ? pressedStyle
                        : null,
                    child: Text(loc.battlePokemonChange),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnMoveType.surrender;
                      turnMove.setChangePokemonIndex(playerType, null);
                    }),
                    style: turnMove.type == TurnMoveType.surrender
                        ? pressedStyle
                        : null,
                    child: Text(loc.battleSurrender),
                  ),
                ],
              ),
            ),
          );

          late List<Widget> typeCommand;
          // 行動の種類ごとに変わる
          switch (turnMove.type) {
            case TurnMoveType.move: // わざ
              typeCommand = [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: moveSearchTextController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() {}),
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
                if (prevState.isPossibleBattling(playerType, i) &&
                    !prevState.getPokemonStates(playerType)[i].isFainting &&
                    i !=
                        myParty.pokemons.indexWhere((element) =>
                            element ==
                            prevState
                                .getPokemonState(playerType, null)
                                .pokemon)) {
                  pokemonTiles.add(
                    PokemonTile(
                      myParty.pokemons[i]!,
                      theme,
                      onTap: () => parentSetState(() {
                        if (turnMove.getChangePokemonIndex(playerType) ==
                            i + 1) {
                          turnMove.setChangePokemonIndex(playerType, null);
                          widget.onUnConfirm();
                        } else {
                          turnMove.setChangePokemonIndex(playerType, i + 1);
                          widget.onConfirm();
                        }
                      }),
                      dense: true,
                      selected:
                          turnMove.getChangePokemonIndex(playerType) == i + 1,
                      selectedTileColor: Colors.black26,
                    ),
                  );
                  addedIndex.add(i);
                }
              }
              for (int i = 0; i < myParty.pokemonNum; i++) {
                if (addedIndex.contains(i)) continue;
                pokemonTiles.add(
                  PokemonTile(
                    myParty.pokemons[i]!,
                    theme,
                    enabled: false,
                    dense: true,
                  ),
                );
              }
              typeCommand = [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: Text(widget.isFirstAction != null
                              ? widget.isFirstAction!
                                  ? loc.battleActFirst
                                  : loc.battleActSecond
                              : ' '))
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ListViewWithViewItemCount(
                    viewItemCount: 4,
                    children: pokemonTiles,
                  ),
                ),
              ];
              break;
            case TurnMoveType.surrender: // こうさん
            default:
              typeCommand = [
                Expanded(
                  flex: 7,
                  child: Container(),
                )
              ];
              break;
          }

          commandColumn = Column(
            key: ValueKey<int>(state.index),
            children: [
              commonCommand,
              ...typeCommand,
            ],
          );
        }
        break;
      case CommandState.extraInput:
        commandColumn = turnMove.extraCommandInputList(
            initialKeyNumber: CommandState.extraInput.index,
            theme: theme,
            onBackPressed: () => parentSetState(() {
                  // いろいろ初期化
                  turnMove.move = Move(0, '', '', PokeType.unknown, 0, 0, 0,
                      Target.none, DamageClass(0), MoveEffect(0), 0, 0);
                  turnMove.moveHits = [MoveHit.hit];
                  turnMove.moveAdditionalEffects = [
                    MoveEffect(MoveEffect.none)
                  ];
                  turnMove.moveEffectivenesses = [MoveEffectiveness.normal];
                  turnMove.percentDamage[0] = 0;
                  turnMove.realDamage[0] = 0;
                  state = CommandState.selectCommand;
                  widget.onUnConfirm();
                }),
            onListIndexChange: (index) {
              listIndex = index;
            },
            onConfirm: () => widget.onConfirm,
            parentSetState: parentSetState,
            isFirstAction: widget.isFirstAction,
            myParty: myParty,
            yourParty: yourParty,
            myState: myState,
            yourState: yourState,
            state: prevState,
            continuousCount: 0,
            loc: loc)[listIndex];
/*        commandColumn = Column(
          key: ValueKey<int>(state.index),
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: 
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(turnMove.move.displayName),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(widget.isFirstAction != null
                          ? widget.isFirstAction!
                              ? loc.battleActFirst
                              : loc.battleActSecond
                          : ' '))
                ],
              ),
            ),
            // ダメージ入力
            Expanded(
              flex: 7,
              child: NumberInputButtons(
                initialNum: 0,
                onConfirm: (remain) => parentSetState(() {
                  int continuousCount = 0;
                  if (playerType == PlayerType.me) {
                    turnMove.percentDamage[continuousCount] =
                        yourState.remainHPPercent - remain;
                  } else {
                    turnMove.realDamage[continuousCount] =
                        yourState.remainHP - remain;
                  }
                  if (turnMove.extraCommand(
                        key: ValueKey<int>(CommandState.extraInput2.index),
                        theme: theme,
                        onBackPressed: () {},
                        parentSetState: (p0) {},
                        isFirstAction: widget.isFirstAction,
                        myParty: myParty,
                        yourParty: yourParty,
                        myState: myState,
                        yourState: yourState,
                        state: prevState,
                        continuousCount: 0,
                        loc: loc,
                      ) !=
                      null) {
                    state = CommandState.extraInput2;
                  }
                  widget.onConfirm();
                }),
              ),
            ),
          ],
        );
*/
        break;
/*      case CommandState.extraInput2:
        commandColumn = turnMove.extraCommand(
          key: ValueKey<int>(CommandState.extraInput2.index),
          theme: theme,
          onBackPressed: () => setState(() {
            state = CommandState.extraInput1;
          }),
          parentSetState: setState,
          isFirstAction: widget.isFirstAction,
          myParty: myParty,
          yourParty: yourParty,
          myState: myState,
          yourState: yourState,
          state: prevState,
          continuousCount: 0,
          loc: loc,
        )!;
        break;*/
      default:
        commandColumn = Container(
          key: ValueKey<int>(state.index),
        );
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

  @override
  void reset() {
    state = CommandState.selectCommand;
    moveSearchTextController.text = '';
  }
}
