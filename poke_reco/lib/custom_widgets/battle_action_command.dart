import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/change_pokemon_command_tile.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ailment.dart';
import 'package:poke_reco/tool.dart';

/// わざの並び替えで先頭に来させるための値
const int topOrderVal = 0xffffff00;

enum CommandState {
  selectCommand,
  confusedDamageInput,
  extraInput,
}

/// わざのリストタイル＋並び替え用の値
class MoveTileWithVal {
  /// わざのリストタイル等Widget
  final Widget moveTile;

  /// わざの最大ダメージ
  final int maxDamage;

  /// わざの採用数
  final int adoptedCount;

  MoveTileWithVal(
      {required this.moveTile,
      required this.maxDamage,
      required this.adoptedCount});
}

class BattleActionCommand extends StatefulWidget {
  const BattleActionCommand({
    Key? key,
    required this.playerType,
    required this.turnMove,
    required this.phaseState,
    required this.myParty,
    required this.yourParty,
    required this.opponentName,
    required this.parentSetState,
    required this.onConfirm,
    required this.onUnConfirm,
    required this.updateActionOrder,
    required this.playerCanTerastal,
    required this.onRequestTerastal,
    required this.moveListOrder,
    required this.onMoveListOrderChange,
    required this.onConfusionEnd,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnEffectAction turnMove;
  final PhaseState phaseState;
  final Party myParty;
  final Party yourParty;
  final String opponentName;
  final void Function(void Function()) parentSetState;
  final void Function() onConfirm;
  final void Function() onUnConfirm;
  final void Function() updateActionOrder;
  final bool playerCanTerastal;
  final void Function() onRequestTerastal;
  final int moveListOrder;
  final void Function(int) onMoveListOrderChange;
  final void Function() onConfusionEnd;

  @override
  BattleActionCommandState createState() => BattleActionCommandState();
}

class BattleActionCommandState extends BattleCommandState<BattleActionCommand> {
  CommandState state = CommandState.selectCommand;
  TextEditingController moveSearchTextController = TextEditingController();
  CommandPagesController commandPagesController = CommandPagesController();
  int currentMoveListOrder = 0;

  @override
  void initState() {
    currentMoveListOrder = widget.moveListOrder;
    super.initState();
  }

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
    final selectingMoveDamageGetter = DamageGetter();
    turnMove.copy().processEffect(
          playerType == PlayerType.me ? myParty.copy() : yourParty.copy(),
          playerType == PlayerType.me ? myState.copy() : yourState.copy(),
          playerType == PlayerType.me ? yourParty.copy() : myParty.copy(),
          playerType == PlayerType.me ? yourState.copy() : myState.copy(),
          prevState.copy(),
          null,
          damageGetter: selectingMoveDamageGetter,
          loc: loc,
        );
    bool canSelect = turnMove.isSuccess;
    List<Move> moves = [];
    List<MoveTileWithVal> moveTileVals = [];
    if (turnMove.type == TurnActionType.move &&
        state == CommandState.selectCommand) {
      //
      // わざリスト作成
      //
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
      // ゾロア系かもしれない場合
      if (prevState.canZorua) {
        moves.addAll(PokeDB().pokeBase[PokeBase.zoruaNo]!.move.where(
              (element) =>
                  element.isValid &&
                  moves.where((e) => e.id == element.id).isEmpty,
            ));
      }
      if (prevState.canZoroark) {
        moves.addAll(PokeDB().pokeBase[PokeBase.zoroarkNo]!.move.where(
              (element) =>
                  element.isValid &&
                  moves.where((e) => e.id == element.id).isEmpty,
            ));
      }
      if (prevState.canZoruaHisui) {
        moves.addAll(PokeDB().pokeBase[PokeBase.zoruaHisuiNo]!.move.where(
              (element) =>
                  element.isValid &&
                  moves.where((e) => e.id == element.id).isEmpty,
            ));
      }
      if (prevState.canZoroarkHisui) {
        moves.addAll(PokeDB().pokeBase[PokeBase.zoroarkHisuiNo]!.move.where(
              (element) =>
                  element.isValid &&
                  moves.where((e) => e.id == element.id).isEmpty,
            ));
      }
      moves.add(PokeDB().moves[165]!); // わるあがき
      // 検索窓の入力でフィルタリング
      final pattern = moveSearchTextController.text;
      if (pattern != '') {
        moves.retainWhere((s) {
          return toKatakana50(s.displayName.toLowerCase())
              .contains(toKatakana50(pattern.toLowerCase()));
        });
      }
      // ねむり状態の場合
      if (myState
          .ailmentsWhere((element) => element.id == Ailment.sleep)
          .isNotEmpty) {
        moveTileVals.add(MoveTileWithVal(
          moveTile: SwitchListTile(
            title: Text(ActionFailure(ActionFailure.sleep).displayName),
            onChanged: (value) {
              if (value) {
                parentSetState(() {
                  turnMove.isSuccess = false;
                  turnMove.actionFailure = ActionFailure(ActionFailure.sleep);
                });
              } else {
                parentSetState(() {
                  turnMove.isSuccess = true;
                  turnMove.actionFailure = ActionFailure(ActionFailure.none);
                });
              }
              // 統合テスト作成用
              print("await driver.tap(\n"
                  "      find.ancestor(of: find.text('ねむり'), matching: find.byType('ListTile')));\n");
            },
            value: !turnMove.isSuccess &&
                turnMove.actionFailure.id == ActionFailure.sleep,
          ),
          maxDamage: topOrderVal + 100,
          adoptedCount: topOrderVal + 100,
        ));
      }
      // まひ状態の場合
      else if (myState
          .ailmentsWhere((element) => element.id == Ailment.paralysis)
          .isNotEmpty) {
        moveTileVals.add(MoveTileWithVal(
          moveTile: SwitchListTile(
            title: Text(ActionFailure(ActionFailure.paralysis).displayName),
            onChanged: (value) {
              if (value) {
                parentSetState(() {
                  turnMove.isSuccess = false;
                  turnMove.actionFailure =
                      ActionFailure(ActionFailure.paralysis);
                });
              } else {
                parentSetState(() {
                  turnMove.isSuccess = true;
                  turnMove.actionFailure = ActionFailure(ActionFailure.none);
                });
              }
              // 統合テスト作成用
              print("await driver.tap(\n"
                  "      find.ancestor(of: find.text('まひ'), matching: find.byType('ListTile')));\n");
            },
            value: !turnMove.isSuccess &&
                turnMove.actionFailure.id == ActionFailure.paralysis,
          ),
          maxDamage: topOrderVal + 100,
          adoptedCount: topOrderVal + 100,
        ));
      }
      // こんらん状態の場合
      else if (myState
          .ailmentsWhere((element) => element.id == Ailment.confusion)
          .isNotEmpty) {
        moveTileVals.add(MoveTileWithVal(
          moveTile: SwitchListTile(
            title: Text(AilmentEffect(AilmentEffect.confusionEnd).displayName),
            onChanged: (value) {
              if (value) {
                parentSetState(() {
                  widget.onConfusionEnd();
                });
              }
              // 統合テスト作成用
              print("await driver.tap(\n"
                  "      find.ancestor(of: find.text('こんらんが解けた'), matching: find.byType('ListTile')));\n");
            },
            value: myState
                .ailmentsWhere((element) => element.id == Ailment.confusion)
                .isEmpty,
          ),
          maxDamage: topOrderVal + 101,
          adoptedCount: topOrderVal + 101,
        ));
        moveTileVals.add(MoveTileWithVal(
          moveTile: ListTile(
            key: Key(
                'BattleActionCommandMoveListTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}ConfusionDamage'),
            horizontalTitleGap: 8.0,
            dense: true,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            title: Text(loc.battleConfusedAttack),
            onTap: () {
              parentSetState(() {
                turnMove.isSuccess = false;
                turnMove.actionFailure = ActionFailure(ActionFailure.confusion);
                // 表示Widgetのコントローラリセット
                commandPagesController = CommandPagesController();
                state = CommandState.confusedDamageInput;
              });
              // 統合テスト作成用
              print("// ${myState.pokemon.omittedName}は自分をこうげきした\n"
                  "await tapMove(driver, ${playerType == PlayerType.me ? "me" : "op"}, 'ConfusionDamage', false);");
            },
          ),
          maxDamage: topOrderVal + 100,
          adoptedCount: topOrderVal + 100,
        ));
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
        tmp.fillAutoAdditionalEffect(prevState);
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
        var listTile = ListTile(
          key: Key(
              'BattleActionCommandMoveListTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}${myMove.displayName}'),
          horizontalTitleGap: 8.0,
          dense: true,
          enabled: canSelect,
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
                  TextSpan(
                      text:
                          '(${myState.usedPPs[myState.moves.indexOf(myMove)]})',
                      style: theme.textTheme.bodyMedium),
                ]))
              : Text(myMove.displayName),
          subtitle: getter.showDamage
              ? Text('${getter.rangeString} (${getter.rangePercentString})')
              : Text(' - '),
          onTap: () {
            parentSetState(() {
              turnMove.move = myMove;
              turnMove.hitCount = myMove.maxMoveCount();
              if (turnMove.isCriticalFromMove(
                  myMove, myState, yourState, yourFields)) {
                turnMove.criticalCount = turnMove.hitCount;
              }
              turnMove.fillAutoAdditionalEffect(prevState);
              turnMove.moveEffectivenesses =
                  PokeTypeEffectiveness.effectiveness(
                      myState.currentAbility.id == 113 ||
                          myState.currentAbility.id == 299,
                      yourState.holdingItem?.id == 586,
                      yourState
                          .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                          .isNotEmpty,
                      turnMove.getReplacedMoveType(myMove, myState, prevState),
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
                  opponentName: widget.opponentName,
                  state: prevState,
                  damageGetter: getter,
                  controller: commandPagesController,
                  loc: loc);
              // 表示Widgetのコントローラリセット
              commandPagesController = CommandPagesController();
              state = CommandState.extraInput;
            });
            // 統合テスト作成用
            print("// ${myState.pokemon.omittedName}の${myMove.displayName}\n"
                "await tapMove(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${myMove.displayName}', ${myState.moves.contains(myMove) ? "false" : "true"});");
          },
        );
        if (myState.moves.contains(myMove)) {
          moveTileVals.add(MoveTileWithVal(
              moveTile: listTile,
              maxDamage: topOrderVal + 3 - i,
              adoptedCount: topOrderVal + 3 - i));
        } else {
          moveTileVals.add(MoveTileWithVal(
            moveTile: listTile,
            maxDamage: getter.maxDamage,
            adoptedCount: PokeDB().getAdoptedMoveCount(myPokemon.no, myMove.id),
          ));
        }
      }

      if (currentMoveListOrder == 0) {
        // ダメージ多い順にソート(同順位の場合は採用率大きい方が上)
        moveTileVals.sort(((a, b) => b.adoptedCount.compareTo(a.adoptedCount)));
        moveTileVals.sort(((a, b) => b.maxDamage.compareTo(a.maxDamage)));
      } else {
        // 採用率高い順にソート(同順位の場合はダメージ大きい方が上)
        moveTileVals.sort(((a, b) => b.maxDamage.compareTo(a.maxDamage)));
        moveTileVals.sort(((a, b) => b.adoptedCount.compareTo(a.adoptedCount)));
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
                    key: Key(
                        'BattleActionCommandMove${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                    onPressed: () => parentSetState(() {
                      turnMove.type = TurnActionType.move;
                      // TODO: typeを変えたら他も変える？class継承とかでどうにか
                      turnMove.setChangePokemonIndex(playerType, null, null);
                    }),
                    style: turnMove.type == TurnActionType.move
                        ? pressedStyle
                        : null,
                    child: Text(loc.commonMove),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    key: Key(
                        'BattleActionCommandChange${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
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
                    key: Key(
                        'BattleActionCommandSurrender${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                    onPressed: () {
                      parentSetState(() {
                        turnMove.type = TurnActionType.surrender;
                        turnMove.setChangePokemonIndex(playerType, null, null);
                      });
                      // 統合テスト作成用
                      print(
                          "// ${turnMove.playerType == PlayerType.me ? 'あなた' : 'あいて'}降参\n"
                          "await driver.tap(find.byValueKey('BattleActionCommandSurrender${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'));");
                    },
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
                                key: Key(
                                    'BattleActionCommandTerastal${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                                icon: myState.isTerastaling
                                    ? myState.teraType1.displayIcon
                                    : Icon(
                                        Icons.diamond,
                                        color: Color(0x80000000),
                                      ),
                                onPressed: () {
                                  widget.onRequestTerastal();
                                  // 統合テスト作成用
                                  print(
                                      "// ${myState.pokemon.omittedName}のテラスタル");
                                  if (playerType == PlayerType.me) {
                                    print(
                                        "await inputTerastal(driver, me, '');");
                                  }
                                },
                                isSelected: myState.isTerastaling,
                              ),
                            )
                          : Container(),
                      Expanded(
                        flex: 6,
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
                      playerType == PlayerType.opponent
                          ? Expanded(
                              flex: 2,
                              child: PopupMenuButton(
                                initialValue: currentMoveListOrder,
                                child: Icon(
                                  Icons.reorder,
                                ),
                                onSelected: (value) => setState(() {
                                  currentMoveListOrder = value;
                                  widget.onMoveListOrderChange(value);
                                }),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 0,
                                    child: Text('ダメージ大きい順'),
                                  ),
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text('採用率高い順'),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(children: [
                    Expanded(
                      flex: 10,
                      child: ListViewWithViewItemCount(
                        key: Key(
                            'BattleActionCommandMoveListView${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                        viewItemCount: 4,
                        children: [
                          for (final moveTileVal in moveTileVals)
                            moveTileVal.moveTile
                        ],
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
                      key: Key(
                          'ChangePokemonTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                      myParty.pokemons[i]!,
                      theme,
                      onTap: () {
                        parentSetState(() {
                          if (turnMove.getChangePokemonIndex(playerType) ==
                              i + 1) {
                            turnMove.setChangePokemonIndex(
                                playerType, null, null);
                            widget.onUnConfirm();
                          } else {
                            turnMove.setChangePokemonIndex(
                                playerType,
                                prevState.getPokemonIndex(playerType, null),
                                i + 1);
                            widget.onConfirm();
                          }
                        });
                        // 統合テスト作成用
                        final prePoke =
                            prevState.getPokemonState(playerType, null).pokemon;
                        final poke =
                            prevState.getPokemonStates(playerType)[i].pokemon;
                        print(
                            "// ${prePoke.omittedName}->${poke.omittedName}に交代\n"
                            "await changePokemon(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${poke.name}', true);");
                      },
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
                    key: Key(
                        'ChangePokemonTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
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
                    key: Key(
                        'ChangePokemonListView${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
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
      case CommandState.confusedDamageInput:
        // 入力中に試合終了になった場合は以下の条件に入る
        if (turnMove.actionFailure != ActionFailure(ActionFailure.confusion)) {
          commandColumn = Container();
          break;
        }
        // こんらんによる自傷ダメージ入力
        int initialNum = playerType == PlayerType.me
            ? myState.remainHP
            : myState.remainHPPercent;
        commandColumn = Column(
          key: ValueKey<int>(state.index),
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      parentSetState(() {
                        turnMove.isSuccess = true;
                        turnMove.actionFailure =
                            ActionFailure(ActionFailure.none);
                        state = CommandState.selectCommand;
                      });
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(loc.battleConfusedAttack),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 6,
                    child: NumberInputButtons(
                      key: Key(
                          'NumberInputButtons${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                      initialNum: initialNum,
                      onConfirm: (remain) {
                        if (playerType == PlayerType.me) {
                          turnMove.extraArg1 = myState.remainHP - remain;
                        } else {
                          turnMove.extraArg2 = myState.remainHPPercent - remain;
                        }
                        parentSetState(() {
                          widget.onConfirm();
                        });
                        // 統合テスト作成用
                        print("// ${myState.pokemon.omittedName}のHP$remain\n"
                            "await inputRemainHP(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${initialNum != remain ? remain : ""}');\n");
                      },
                      prefixText:
                          loc.battleRemainHP(myState.pokemon.omittedName),
                      suffixText:
                          playerType == PlayerType.opponent ? '%' : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case CommandState.extraInput:
        // 入力中に試合終了になった場合は以下の条件に入る
        if (turnMove.move.id == 0) {
          commandColumn = Container();
          break;
        }
        commandColumn = turnMove.extraCommandInputList(
            initialKeyNumber: CommandState.extraInput.index,
            theme: theme,
            onBackPressed: () => parentSetState(() {
                  // いろいろ初期化
                  turnMove.clearMove();
                  state = CommandState.selectCommand;
                  widget.onUnConfirm();
                }),
            onConfirm: () => parentSetState(() {
                  widget.onConfirm();
                }),
            onUpdate: () => parentSetState(() {}),
            myParty: myParty,
            yourParty: yourParty,
            myState: myState,
            yourState: yourState,
            opponentName: widget.opponentName,
            state: prevState,
            damageGetter: selectingMoveDamageGetter,
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
