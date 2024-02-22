import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/change_pokemon_command_tile.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
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
    required this.updateActionOrder,
    required this.playerCanTerastal,
    required this.onRequestTerastal,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnEffectAction turnMove;
  final PhaseState phaseState;
  final Party myParty;
  final Party yourParty;
  final Function(void Function()) parentSetState;
  final Function() onConfirm;
  final Function() onUnConfirm;
  final Function() updateActionOrder;
  final bool playerCanTerastal;
  final Function() onRequestTerastal;

  @override
  BattleActionCommandState createState() => BattleActionCommandState();
}

class BattleActionCommandState extends BattleCommandState<BattleActionCommand> {
  CommandState state = CommandState.selectCommand;
  TextEditingController moveSearchTextController = TextEditingController();
  CommandPagesController commandPagesController = CommandPagesController();

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
    if (turnMove.type == TurnActionType.move &&
        state == CommandState.selectCommand) {
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
        tmp.move = turnMove.getReplacedMove(myMove, myState);
        if (turnMove.isCriticalFromMove(
            myMove, myState, yourState, yourFields)) {
          tmp.criticalCount = 1;
        }
        tmp.moveAdditionalEffects = tmp.move.isSurelyEffect()
            ? MoveEffect(tmp.move.effect.id)
            : MoveEffect(0);
        tmp.moveEffectivenesses = PokeTypeEffectiveness.effectiveness(
            myState.currentAbility.id == 113 ||
                myState.currentAbility.id == 299,
            yourState.holdingItem?.id == 586,
            yourState
                .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                .isNotEmpty,
            turnMove.getReplacedMoveType(tmp.move, myState, prevState),
            yourState);
        tmp.processEffect(
          playerType == PlayerType.me ? myParty.copy() : yourParty.copy(),
          playerType == PlayerType.me ? myState.copy() : yourState.copy(),
          playerType == PlayerType.me ? yourParty.copy() : myParty.copy(),
          playerType == PlayerType.me ? yourState.copy() : myState.copy(),
          prevState.copy(),
          null,
          damageGetter: getter,
          loc: loc,
        );
        moveTiles.add(
          ListTile(
            key: Key(
                'BattleActionCommandMoveListTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}${myMove.displayName}'),
            horizontalTitleGap: 8.0,
            dense: true,
            leading: turnMove
                .getReplacedMoveType(myMove, myState, prevState)
                .displayIcon,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            title: myState.moves.contains(myMove)
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
            onTap: () {
              parentSetState(() {
                turnMove.move = myMove;
                turnMove.hitCount = myMove.maxMoveCount();
                if (turnMove.isCriticalFromMove(
                    myMove, myState, yourState, yourFields)) {
                  turnMove.criticalCount = turnMove.hitCount;
                }
                turnMove.moveAdditionalEffects = myMove.isSurelyEffect()
                    ? MoveEffect(myMove.effect.id)
                    : MoveEffect(0);
                turnMove.moveEffectivenesses =
                    PokeTypeEffectiveness.effectiveness(
                        myState.currentAbility.id == 113 ||
                            myState.currentAbility.id == 299,
                        yourState.holdingItem?.id == 586,
                        yourState
                            .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                            .isNotEmpty,
                        turnMove.getReplacedMoveType(
                            myMove, myState, prevState),
                        yourState);
                // わざ選択で即isValid()==trueになるわざのために呼び出す
                turnMove.extraCommandInputList(
                    initialKeyNumber: 0,
                    theme: theme,
                    onBackPressed: () {},
                    onConfirm: () {},
                    onUpdate: () {},
                    myParty: myParty,
                    yourParty: yourParty,
                    myState: myState,
                    yourState: yourState,
                    state: prevState,
                    controller: commandPagesController,
                    loc: loc);
                // 表示Widgetのコントローラリセット
                commandPagesController = CommandPagesController();
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
                      turnMove.type = TurnActionType.move;
                      // TODO: typeを変えたら他も変える？class継承とかでどうにか
                      turnMove.setChangePokemonIndex(playerType, null);
                    }),
                    style: turnMove.type == TurnActionType.move
                        ? pressedStyle
                        : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnActionType.change;
                    }),
                    style: turnMove.type == TurnActionType.change
                        ? pressedStyle
                        : null,
                    child: Text(loc.battlePokemonChange),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnActionType.surrender;
                      turnMove.setChangePokemonIndex(playerType, null);
                    }),
                    style: turnMove.type == TurnActionType.surrender
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
            case TurnActionType.move: // わざ
              typeCommand = [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      // テラスタル可能ならテラスタルボタン表示
                      widget.playerCanTerastal
                          ? Expanded(
                              flex: 2,
                              child: IconButton(
                                icon: myState.isTerastaling
                                    ? myState.teraType1.displayIcon
                                    : Icon(
                                        Icons.diamond,
                                        color: Color(0x80000000),
                                      ),
                                onPressed: () => widget.onRequestTerastal(),
                                isSelected: myState.isTerastaling,
                              ),
                            )
                          : Container(),
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            key: Key(
                                'BattleActionCommandMoveSearch${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
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
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(children: [
                    Expanded(
                      flex: 10,
                      child: ListViewWithViewItemCount(
                        viewItemCount: 4,
                        children: moveTiles,
                      ),
                    ),
                  ]),
                ),
              ];
              break;
            case TurnActionType.change: // ポケモン交代
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
                    ChangePokemonCommandTile(
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
                      selected:
                          turnMove.getChangePokemonIndex(playerType) == i + 1,
                      showNetworkImage: PokeDB().getPokeAPI,
                    ),
                  );
                  addedIndex.add(i);
                }
              }
              for (int i = 0; i < myParty.pokemonNum; i++) {
                if (addedIndex.contains(i)) continue;
                pokemonTiles.add(
                  ChangePokemonCommandTile(
                    myParty.pokemons[i]!,
                    theme,
                    onTap: null,
                    enabled: false,
                    showNetworkImage: PokeDB().getPokeAPI,
                  ),
                );
              }
              typeCommand = [
                Expanded(
                  flex: 1,
                  child: Container(),
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
            case TurnActionType.surrender: // こうさん
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
                  turnMove.clearMove();
                  state = CommandState.selectCommand;
                  widget.onUnConfirm();
                }),
            onConfirm: () => parentSetState(() => widget.onConfirm),
            onUpdate: () => parentSetState(() {}),
            myParty: myParty,
            yourParty: yourParty,
            myState: myState,
            yourState: yourState,
            state: prevState,
            controller: commandPagesController,
            loc: loc);
        // 選択するだけでvalidになるmoveがあるため、行動順をupdate
        // TODO:この位置じゃないほうがいい？
        widget.updateActionOrder();
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
    // 表示Widgetのコントローラリセット
    commandPagesController = CommandPagesController();
  }
}
