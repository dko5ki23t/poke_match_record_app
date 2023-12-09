import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_basic_listview.dart';
import 'package:poke_reco/custom_widgets/battle_first_pokemon_listview.dart';
import 'package:poke_reco/custom_widgets/battle_turn_listview.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/pages/register_battle.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

class ViewBattlePage extends StatefulWidget {
  ViewBattlePage({
    Key? key,
    required this.battle,
    required this.onEdit,
  }) : super(key: key);

  final Battle battle;
  final void Function(Battle, RegisterBattlePageType, int) onEdit;

  @override
  ViewBattlePageState createState() => ViewBattlePageState();
}

class ViewBattlePageState extends State<ViewBattlePage> {
  RegisterBattlePageType pageType = RegisterBattlePageType.basePage;
  final opponentPokemonController = List.generate(6, (i) => TextEditingController());
  final battleNameController = TextEditingController();
  final opponentNameController = TextEditingController();
  final dateController = TextEditingController();
  final ownPartyController = TextEditingController();

  List<TextEditingController> textEditingControllerList1 = [];
  List<TextEditingController> textEditingControllerList2 = [];
  List<TextEditingController> textEditingControllerList3 = [];
  List<TextEditingController> textEditingControllerList4 = [];
  TextEditingController ownAbilityController = TextEditingController();
  TextEditingController opponentAbilityController = TextEditingController();
  TextEditingController ownItemController = TextEditingController();
  TextEditingController opponentItemController = TextEditingController();
  TextEditingController ownHPController = TextEditingController();
  TextEditingController opponentHPController = TextEditingController();
  List<TextEditingController> ownStatusMinControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> ownStatusMaxControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMinControllers = List.generate(6, (index) => TextEditingController());
  List<TextEditingController> opponentStatusMaxControllers = List.generate(6, (index) => TextEditingController());

  final turnScrollController = ScrollController();

  int turnNum = 1;
  int focusPhaseIdx = 0;                        // 0は無効
  List<List<TurnEffectAndStateAndGuide>> sameTimingList = [];
  int viewMode = 0;     // 0:ランク 1:種族値 2:ステータス(補正前) 3:ステータス(補正後)

  bool openStates = false;
  // 能力ランク編集に使う
  List<int> ownStatChanges = [0, 0, 0, 0, 0, 0, 0];
  List<int> opponentStatChanges = [0, 0, 0, 0, 0, 0, 0];

  TurnEffect? _getPrevTimingEffect(int index) {
    TurnEffect? ret;
    var currentTurn = widget.battle.turns[turnNum-1];
    AbilityTiming nowTiming = currentTurn.phases[index].timing;
    for (int i = index-1; i >= 0; i--) {
      if (currentTurn.phases[i].timing.id != nowTiming.id) {
        ret = currentTurn.phases[i];
        break;
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;
    final theme = Theme.of(context);
    const statAlphabets = ['A ', 'B ', 'C ', 'D ', 'S ', 'Ac', 'Ev'];
    const statusAlphabets = ['H ', 'A ', 'B ', 'C ', 'D ', 'S '];
    PhaseState? focusState;

    // エイリアス
    List<Turn> turns = widget.battle.turns;
    Party ownParty = widget.battle.getParty(PlayerType(PlayerType.me));
    Party opponentParty = widget.battle.getParty(PlayerType(PlayerType.opponent));

    for (int i = 0; i < opponentParty.pokemonNum; i++) {
      opponentPokemonController[i].text = opponentParty.pokemons[i]!.name;
    }
    dateController.text = widget.battle.formattedDateTime;
    ownPartyController.text = widget.battle.getParty(PlayerType(PlayerType.me)).id != 0 ?
      pokeData.parties[widget.battle.getParty(PlayerType(PlayerType.me)).id]!.name : 'パーティ選択';
    
    if (turns.length >= turnNum &&
        pageType == RegisterBattlePageType.turnPage
    ) {
      // フォーカスしているフェーズの状態を取得
      focusState = turns[turnNum-1].getProcessedStates(focusPhaseIdx-1, ownParty, opponentParty);
      sameTimingList = _createSameTimingList(appState);
      //appState.needAdjustPhases = -1;
      //appState.adjustPhaseByDelete = false;
    }

    battleNameController.text = widget.battle.name;
    opponentNameController.text = widget.battle.opponentName;

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    Widget lists;
    Widget title;
    void Function()? nextPressed;
    void Function()? backPressed;


    void onNext() {
      switch (pageType) {
        case RegisterBattlePageType.firstPokemonPage:
          focusPhaseIdx = 0;
          var currentTurn = turns[turnNum-1];
          appState.editingPhase = List.generate(
            currentTurn.phases.length, (index) => false
          );
          // テキストフィールドの初期値設定
          textEditingControllerList1 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
          );
          textEditingControllerList2 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText2(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList4 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText4(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
          pageType = RegisterBattlePageType.turnPage;
          setState(() {});
          break;
        case RegisterBattlePageType.turnPage:
          // 表示のスクロール位置をトップに
          turnScrollController.jumpTo(0);
          turnNum++;
          var currentTurn = turns[turnNum-1];
          focusPhaseIdx = 0;
          appState.editingPhase = List.generate(
            currentTurn.phases.length, (index) => false
          );
          // テキストフィールドの初期値設定
          textEditingControllerList1 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
          );
          textEditingControllerList2 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText2(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList3 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText3(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                ),
                _getPrevTimingEffect(index),
              )
            )
          );
          textEditingControllerList4 = List.generate(
            currentTurn.phases.length,
            (index) => TextEditingController(text:
              currentTurn.phases[index].getEditingControllerText4(
                currentTurn.getProcessedStates(
                  index, ownParty, opponentParty
                )
              )
            )
          );
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
        case RegisterBattlePageType.turnPage:
          // 表示のスクロール位置をトップに
          turnScrollController.jumpTo(0);
          turnNum--;
          if (turnNum == 0) {
            turnNum = 1;
            pageType = RegisterBattlePageType.firstPokemonPage;
          }
          else {
            var currentTurn = turns[turnNum-1];
            appState.editingPhase = List.generate(
              currentTurn.phases.length, (index) => false
            );
            textEditingControllerList1 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text: currentTurn.phases[index].getEditingControllerText1())
            );
            textEditingControllerList2 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText2(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  ),
                  _getPrevTimingEffect(index),
                )
              )
            );
            textEditingControllerList3 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText3(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  ),
                  _getPrevTimingEffect(index),
                )
              )
            );
            textEditingControllerList4 = List.generate(
              currentTurn.phases.length,
              (index) => TextEditingController(text:
                currentTurn.phases[index].getEditingControllerText4(
                  currentTurn.getProcessedStates(
                    index, ownParty, opponentParty
                  ),
                ),
              )
            );
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

    switch (pageType) {
      case RegisterBattlePageType.basePage:
        title = Text('バトル基本情報 - ${widget.battle.name}');
        lists = BattleBasicListView(
          context, () {},
          widget.battle, 
          pokeData.parties,
          theme,
          battleNameController,
          opponentNameController,
          dateController,
          opponentPokemonController,
          ownPartyController, () {return Future<Party?>.value(null);},
          showNetworkImage: pokeData.getPokeAPI,
          isInput: false,
        );
        nextPressed = turns.isNotEmpty ?
          () {
            setState(() {
              pageType = RegisterBattlePageType.firstPokemonPage;
            });
          } : null;
        backPressed = null;
        break;

      case RegisterBattlePageType.firstPokemonPage:
        title = Text('選出ポケモン - ${widget.battle.name}');
        assert(turns.isNotEmpty);
        lists = BattleFirstPokemonListView(
          () {}, widget.battle, theme, CheckedPokemons(),
          ownPokemonStates: turns.first.getInitialPokemonStates(PlayerType(PlayerType.me)),
          opponentPokemonIndex: turns.first.getInitialPokemonIndex(PlayerType(PlayerType.opponent)),
          showNetworkImage: pokeData.getPokeAPI,
          isInput: false,
        );
        nextPressed = () => onNext();
        backPressed = () {
          setState(() {
            pageType = RegisterBattlePageType.basePage;
          });
        };
        break;
      case RegisterBattlePageType.turnPage:
        title = Text('$turnNumターン目 - ${widget.battle.name}');
        lists = Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Row(children: [
                    pokeData.getPokeAPI ?
                    Image.network(
                      pokeData.pokeBase[focusState!.getPokemonState(PlayerType(PlayerType.me), null).pokemon.no]!.imageUrl,
                      height: theme.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    ) : const Icon(Icons.catching_pokemon),
                    Flexible(child: Text(_focusingPokemon(PlayerType(PlayerType.me), focusState!).name, overflow: TextOverflow.ellipsis,)),
                    focusState.getPokemonState(PlayerType(PlayerType.me), null).sex.displayIcon,
                  ],),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Row(children: [
                    pokeData.getPokeAPI ?
                    Image.network(
                      pokeData.pokeBase[focusState.getPokemonState(PlayerType(PlayerType.opponent), null).pokemon.no]!.imageUrl,
                      height: theme.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    ) : const Icon(Icons.catching_pokemon),
                    Flexible(child: Text(_focusingPokemon(PlayerType(PlayerType.opponent), focusState).name, overflow: TextOverflow.ellipsis,)),
                    focusState.getPokemonState(PlayerType(PlayerType.opponent), null).sex.displayIcon,
                  ],),
                ),
                IconButton(
                  icon: Icon(openStates ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down),
                  onPressed: () {
                    setState(() {openStates = !openStates;});
                  },
                ),
              ],
            ),
            openStates ?
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                viewMode++;
                                viewMode %= 4;
                              });
                            },
                            child: Row(children: [
                              viewMode == 0 ?
                              Text('ランク') :
                              viewMode == 1 ?
                              Text('種族値') :
                              viewMode == 2 ?
                              Text('ステータス(補正前)') : Text('ステータス(補正後)'),
                              SizedBox(width: 10),
                              Icon(Icons.sync),
                            ]),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // タイプ
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child:
                              focusState.getPokemonState(PlayerType(PlayerType.me), null).isTerastaling ?
                              Row(children: [
                                Text('テラスタル'),
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).teraType1.displayIcon,
                              ],) :
                              Row(children: [
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type1.displayIcon,
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type2 != null ?
                                focusState.getPokemonState(PlayerType(PlayerType.me), null).type2!.displayIcon : Container(),
                              ],),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child:
                              focusState.getPokemonState(PlayerType(PlayerType.opponent), null).isTerastaling ?
                              Row(children: [
                                Text('テラスタル'),
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).teraType1.displayIcon,
                              ],) :
                              Row(children: [
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type1.displayIcon,
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type2 != null ?
                                focusState.getPokemonState(PlayerType(PlayerType.opponent), null).type2!.displayIcon : Container(),
                              ],),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      // とくせい
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: AbilityText(focusState.getPokemonState(PlayerType(PlayerType.me), null).currentAbility, showHatena: true,),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: AbilityText(focusState.getPokemonState(PlayerType(PlayerType.opponent), null).currentAbility, showHatena: true,),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // もちもの
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: ItemText(focusState.getPokemonState(PlayerType(PlayerType.me), null).holdingItem, showHatena: true, showNone: true,),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: ItemText(focusState.getPokemonState(PlayerType(PlayerType.opponent), null).holdingItem, showHatena: true, showNone: true,),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // HP
                      _HPBarRow(
                        focusState.getPokemonState(PlayerType(PlayerType.me), null).remainHP, _focusingPokemon(PlayerType(PlayerType.me), focusState).h.real,
                        focusState.getPokemonState(PlayerType(PlayerType.opponent), null).remainHPPercent),
                      SizedBox(height: 5),
                      // 各ステータス(ABCDSAcEv)の変化/各ステータス(HABCDS)の実数値/
                      // TODO
                      for (int i = 0; i < 7; i++)
                        viewMode == 0 ?   // ランク表示
                        _StatChangeViewRow(
                          statAlphabets[i], focusState.getPokemonState(PlayerType(PlayerType.me), null).statChanges(i),
                          focusState.getPokemonState(PlayerType(PlayerType.opponent), null).statChanges(i),
                          (idx) {},
                          (idx) {},
                        ) :
                        viewMode == 1 ?   // 種族値表示
                          i < 6 ?
                          _StatStatusViewRow(
                            statusAlphabets[i],
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).minStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).maxStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).minStats[i].race,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).maxStats[i].race,
                          ) : Container() :
                          // ステータス(補正前/補正後)
                          i < 6 ?
                          _StatStatusViewRow(
                            statusAlphabets[i],
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).minStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.me), null).maxStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).minStats[i].real,
                            focusState.getPokemonState(PlayerType(PlayerType.opponent), null).maxStats[i].real,
                          ) : Container(),
                      SizedBox(height: 5),
                      // わざ
                      for (int i = 0; i < 4; i++)
                      _MoveViewRow(
                        focusState.getPokemonState(PlayerType(PlayerType.me), null),
                        focusState.getPokemonState(PlayerType(PlayerType.opponent), null),
                        i,
                      ),
                      SizedBox(height: 5),
                      // 状態異常・その他補正・場
                      for (int i = 0; i < max(focusState.getPokemonState(PlayerType(PlayerType.me), null).ailmentsLength, focusState.getPokemonState(PlayerType(PlayerType.opponent), null).ailmentsLength); i++)
                      _AilmentsRow(focusState.getPokemonState(PlayerType(PlayerType.me), null), focusState.getPokemonState(PlayerType(PlayerType.opponent), null), i),
                      for (int i = 0; i < max(focusState.getPokemonState(PlayerType(PlayerType.me), null).buffDebuffs.length, focusState.getPokemonState(PlayerType(PlayerType.opponent), null).buffDebuffs.length); i++)
                      _BuffDebuffsRow(focusState.getPokemonState(PlayerType(PlayerType.me), null), focusState.getPokemonState(PlayerType(PlayerType.opponent), null), i),
                      for (int i = 0; i < max(focusState.ownFields.length, focusState.opponentFields.length); i++)
                      _IndiFieldRow(focusState, i),
                      _WeatherFieldRow(focusState)
                    ],
                  ),
                ),
              ),
            ) : Container(),
            Expanded(
              flex: openStates ? 1 : 10,
              child: BattleTurnListView(
                turnScrollController,
                () {setState(() {});},
                widget.battle, turnNum, theme, 
                ownParty.pokemons[turns[turnNum-1].getInitialPokemonIndex(PlayerType(PlayerType.me))-1]!,
                opponentParty.pokemons[turns[turnNum-1].getInitialPokemonIndex(PlayerType(PlayerType.opponent))-1]!,
                textEditingControllerList1,
                textEditingControllerList2,
                textEditingControllerList3,
                textEditingControllerList4,
                appState, focusPhaseIdx,
                (phaseIdx) {
                  focusPhaseIdx = phaseIdx;
                  setState(() {});
                },
                //_getSameTimingList(pokeData),
                sameTimingList,
                isInput: false,
              ),
            ),
          ],
        );
        nextPressed = turnNum < turns.length ? () => onNext() : null;
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
          MyIconButton(
            theme: theme,
            onPressed: backPressed,
            tooltip: '前へ',
            icon: Icon(Icons.navigate_before),
          ),
          MyIconButton(
            theme: theme,
            onPressed: nextPressed,
            tooltip: '次へ',
            icon: Icon(Icons.navigate_next),
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              thickness: 1,
            ),
          ),
          MyIconButton(
            theme: theme,
            // TODO
            // onPressed: () => widget.onEdit(widget.battle, pageType, turnNum),
            onPressed: () => widget.onEdit(widget.battle, RegisterBattlePageType.basePage, 1),
            tooltip: '編集',
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: lists,
    );
  }

  Pokemon _focusingPokemon(PlayerType player, PhaseState focusState) {
    return widget.battle.getParty(player).pokemons[focusState.getPokemonIndex(player, null)-1]!;
  }

  List<List<TurnEffectAndStateAndGuide>> _createSameTimingList(MyAppState appState) {
    List<List<TurnEffectAndStateAndGuide>> ret = [];
    List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
    Turn currentTurn = widget.battle.turns[turnNum-1];
    PhaseState currentState = currentTurn.copyInitialState();
    int continuousCount = 0;
    TurnEffect? lastAction;
    int beginIdx = 0;
    int timingId = 0;
    var phases = widget.battle.turns[turnNum-1].phases;

    for (int i = 0; i < phases.length; i++) {
      if (phases[i].timing.id == AbilityTiming.action){
        lastAction = phases[i];
        if (phases[i].move!.type.id == TurnMoveType.move) {
          continuousCount = 0;
        }       
      }
      else if (phases[i].timing.id == AbilityTiming.continuousMove && phases[i].isValid()) {
        lastAction = phases[i];
        continuousCount++;
      }
      final guide = phases[i].processEffect(
        widget.battle.getParty(PlayerType(PlayerType.me)),
        currentState.getPokemonState(PlayerType(PlayerType.me), null),
        widget.battle.getParty(PlayerType(PlayerType.opponent)),
        currentState.getPokemonState(PlayerType(PlayerType.opponent), null),
        currentState, lastAction, continuousCount);
      turnEffectAndStateAndGuides.add(
        TurnEffectAndStateAndGuide()
        ..phaseIdx = i
        ..turnEffect = phases[i]
        ..phaseState = currentState.copyWith()
        ..guides = guide
      );
      if (!phases[i].isAdding) {
        textEditingControllerList1[i].text = phases[i].getEditingControllerText1();
        textEditingControllerList2[i].text = phases[i].getEditingControllerText2(currentState, lastAction);
        textEditingControllerList3[i].text = phases[i].getEditingControllerText3(currentState, lastAction);
        textEditingControllerList4[i].text = phases[i].getEditingControllerText4(currentState);
      }
    }

    for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
      turnEffectAndStateAndGuides[i].phaseIdx = i;
      if (turnEffectAndStateAndGuides[i].turnEffect.timing.id != timingId ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.action ||
          turnEffectAndStateAndGuides[i].turnEffect.timing.id == AbilityTiming.changeFaintingPokemon
      ) {
        if (i != 0) {
          turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
            currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
          ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
        }
        beginIdx = i;
        timingId = turnEffectAndStateAndGuides[i].turnEffect.timing.id;
      }
    }

    if (phases.isNotEmpty) {
      turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
        currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
      ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, phases.length));
    }
    return ret;
  }

}

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
            GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.minimize, color: Colors.grey)),
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
            GestureDetector(onTap: () => onOpponentPressed(i), child: Icon(Icons.minimize, color: Colors.grey)),
        ],),
      ),
    ],
  );
}

class _StatStatusViewRow extends Row {
  _StatStatusViewRow(
    String label,
    int ownStatusMin,
    int ownStatusMax,
    int opponentStatusMin,
    int opponentStatusMax,
  ) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          ownStatusMin == ownStatusMax ?
          Text(ownStatusMin.toString()) :
          Text('$ownStatusMin～$ownStatusMax'),
        ],),
      ),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          Text(label),
          opponentStatusMin == opponentStatusMax ?
          Text(opponentStatusMin.toString()) :
          Text('$opponentStatusMin～$opponentStatusMax'),
        ],),
      ),
    ],
  );
}

class _MoveViewRow extends Row {
  _MoveViewRow(PokemonState ownState, PokemonState opponentState, int idx) :
  super(
    children: [
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          ownState.moves.length > idx ?
          MoveText(ownState.moves[idx]) : Text(''),
        ],),
      ),
      ownState.moves.length > idx && ownState.usedPPs.length > idx ?
      Text(ownState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
      SizedBox(width: 10,),
      Expanded(
        child: Row(children: [
          opponentState.moves.length > idx ?
          MoveText(opponentState.moves[idx]) : Text(''),
        ],),
      ),
      opponentState.moves.length > idx && opponentState.usedPPs.length > idx ?
      Text(opponentState.usedPPs[idx].toString()) : Text(''),
      SizedBox(width: 10,),
    ],
  );
}

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
                state.ownFields.length > index ?
                Container(
                  color: state.ownFields[index].bgColor,
                  child: Text(state.ownFields[index].displayName, style: TextStyle(color: Colors.white)),
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
                state.opponentFields.length > index ?
                Container(
                  color: state.opponentFields[index].bgColor,
                  child: Text(state.opponentFields[index].displayName, style: TextStyle(color: Colors.white)),
                ) : Container(),
            ),
          ],
        ),
      ),
    ],
  );
}

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
