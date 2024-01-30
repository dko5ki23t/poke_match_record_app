import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/turn_effect_action.dart';
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
  final TurnEffectAction turnMove;
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
  List<Widget> moveCommandWidgetList = [];
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
        TurnEffectAction tmp = turnMove.copy();
        tmp.move = turnMove.getReplacedMove(myMove, 0, myState);
        if (turnMove.isCriticalFromMove(
            myMove, myState, yourState, yourFields)) {
          tmp.criticalCount = 1;
        }
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
        tmp.processEffect(
          playerType == PlayerType.me ? myParty.copy() : yourParty.copy(),
          playerType == PlayerType.me ? myState.copy() : yourState.copy(),
          playerType == PlayerType.me ? yourParty.copy() : myParty.copy(),
          playerType == PlayerType.me ? yourState.copy() : myState.copy(),
          prevState.copy(),
          null,
          0,
          damageGetter: getter,
          loc: loc,
        );
        moveTiles.add(
          ListTile(
            dense: true,
            leading: turnMove
                .getReplacedMoveType(myMove, 0, myState, prevState)
                .displayIcon,
            title: i < myState.moves.length
                ? RichText(
                    text: TextSpan(children: [
                    TextSpan(
                        text: myMove.displayName,
                        style: theme.textTheme.bodyMedium),
                    WidgetSpan(
                      child: Icon(
                        Icons.push_pin,
                        size: theme.textTheme.bodyMedium!.fontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ]))
                : Text(myMove.displayName),
            subtitle:
                Text('${getter.rangeString} (${getter.rangePercentString})'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              parentSetState(() {
                turnMove.move = myMove;
                if (turnMove.isCriticalFromMove(
                    myMove, myState, yourState, yourFields)) {
                  turnMove.criticalCount = 1;
                }
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
                // 表示Widgetのリスト作成
                moveCommandWidgetList = turnMove.extraCommandInputList(
                    initialKeyNumber: CommandState.extraInput.index,
                    theme: theme,
                    onBackPressed: () => parentSetState(() {
                          // いろいろ初期化
                          turnMove.clearMove();
                          state = CommandState.selectCommand;
                          widget.onUnConfirm();
                        }),
                    onListIndexChange: (index) => setState(() {
                          listIndex = index;
                        }),
                    onConfirm: () => parentSetState(() => widget.onConfirm),
                    onUpdate: () => parentSetState(() {}),
                    isFirstAction: widget.isFirstAction,
                    myParty: myParty,
                    yourParty: yourParty,
                    myState: myState,
                    yourState: yourState,
                    state: prevState,
                    continuousCount: 0,
                    loc: loc);
                listIndex = 0;
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
                        contentPadding: EdgeInsets.all(1),
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
        commandColumn = moveCommandWidgetList[listIndex];
        break;
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
