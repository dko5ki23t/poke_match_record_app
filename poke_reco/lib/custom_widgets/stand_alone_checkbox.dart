import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/tool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StandAloneCheckBox extends StatefulWidget {
  const StandAloneCheckBox({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  final bool initialValue;
  final void Function(bool) onChanged;

  @override
  State<StandAloneCheckBox> createState() => _StandAloneCheckBoxState();
}

class _StandAloneCheckBoxState extends State<StandAloneCheckBox> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: value,
        onChanged: (v) {
          if (v != null) {
            widget.onChanged(v);
            setState(() {
              value = v;
            });
          }
        });
  }
}

class HitCriticalInputRow extends StatefulWidget {
  const HitCriticalInputRow({
    Key? key,
    required this.turnMove,
    required this.onUpdate,
    required this.maxMoveCount,
  }) : super(key: key);

  final TurnEffectAction turnMove;
  final void Function() onUpdate;
  final int maxMoveCount;

  @override
  State<HitCriticalInputRow> createState() => _HitCriticalInputRowState();
}

class _HitCriticalInputRowState extends State<HitCriticalInputRow> {
  late final TurnEffectAction turnMove;
  final TextEditingController hitController = TextEditingController();
  final TextEditingController criticalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    turnMove = widget.turnMove;
    hitController.text = turnMove.hitCount.toString();
    criticalController.text = turnMove.criticalCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: widget.maxMoveCount <= 1
              ? Row(
                  children: [
                    Checkbox(
                        key: Key(
                            'HitInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                        value: turnMove.hitCount > 0,
                        onChanged: (change) {
                          if (change != null) {
                            if (change) {
                              turnMove.hitCount = 1;
                            } else {
                              turnMove.hitCount = 0;
                              turnMove.criticalCount = 0;
                            }
                            widget.onUpdate();
                            setState(() {});
                            // 統合テスト作成用
                            print("// 外れる\n"
                                "await tapHit(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"});");
                          }
                        }),
                    Text(MoveHit.hit.displayName),
                  ],
                )
              : Row(
                  children: [
                    Text(MoveHit.hit.displayName),
                    GestureDetector(
                      onTap: () {
                        turnMove.hitCount = (turnMove.hitCount - 1)
                            .clamp(0, widget.maxMoveCount);
                        hitController.text = turnMove.hitCount.toString();
                        // 統合テスト作成用
                        print("// ${turnMove.hitCount}回命中\n"
                            "await setHitCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, ${turnMove.hitCount});");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.remove_circle,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        key: Key(
                            'HitInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                        textAlign: TextAlign.center,
                        controller: hitController,
                        onChanged: (value) {
                          int count = (int.tryParse(value) ?? 0)
                              .clamp(0, widget.maxMoveCount);
                          turnMove.hitCount = count;
                          // 統合テスト作成用
                          print("// $count回命中\n"
                              "await setHitCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, $count);");
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        turnMove.hitCount = (turnMove.hitCount + 1)
                            .clamp(0, widget.maxMoveCount);
                        hitController.text = turnMove.hitCount.toString();
                        // 統合テスト作成用
                        print("// ${turnMove.hitCount}回命中\n"
                            "await setHitCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, ${turnMove.hitCount});");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_circle,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          flex: 1,
          child: widget.maxMoveCount <= 1
              ? Row(
                  children: [
                    Checkbox(
                        key: Key(
                            'CriticalInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                        value: turnMove.criticalCount > 0,
                        onChanged: (change) {
                          if (change != null) {
                            if (change) {
                              turnMove.hitCount = 1;
                              turnMove.criticalCount = 1;
                            } else {
                              turnMove.criticalCount = 0;
                            }
                            widget.onUpdate();
                            setState(() {});
                            // 統合テスト作成用
                            print("// 急所に命中\n"
                                "await tapCritical(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"});");
                          }
                        }),
                    Text(MoveHit.critical.displayName),
                  ],
                )
              : Row(
                  children: [
                    Text(MoveHit.critical.displayName),
                    GestureDetector(
                      onTap: () {
                        turnMove.criticalCount = (turnMove.criticalCount - 1)
                            .clamp(0, widget.maxMoveCount);
                        criticalController.text =
                            turnMove.criticalCount.toString();
                        // 統合テスト作成用
                        print("// ${turnMove.criticalCount}回急所\n"
                            "await setCriticalCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, ${turnMove.criticalCount});");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.remove_circle,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        key: Key(
                            'CriticalInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                        textAlign: TextAlign.center,
                        controller: criticalController,
                        onChanged: (value) {
                          int count = (int.tryParse(value) ?? 0)
                              .clamp(0, widget.maxMoveCount);
                          turnMove.criticalCount = count;
                          // 統合テスト作成用
                          print("// $count回急所\n"
                              "await setCriticalCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, $count);");
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        turnMove.criticalCount = (turnMove.criticalCount + 1)
                            .clamp(0, widget.maxMoveCount);
                        criticalController.text =
                            turnMove.criticalCount.toString();
                        // 統合テスト作成用
                        print("// ${turnMove.criticalCount}回急所\n"
                            "await setCriticalCount(driver, ${turnMove.playerType == PlayerType.me ? "me" : "op"}, ${turnMove.criticalCount});");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_circle,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class SubstituteBreakInput extends StatefulWidget {
  const SubstituteBreakInput({
    Key? key,
    required this.turnMove,
    required this.onUpdate,
  }) : super(key: key);

  final TurnEffectAction turnMove;
  final void Function() onUpdate;

  @override
  State<SubstituteBreakInput> createState() => _SubstituteBreakInputState();
}

class _SubstituteBreakInputState extends State<SubstituteBreakInput> {
  late final TurnEffectAction turnMove;

  @override
  void initState() {
    super.initState();
    turnMove = widget.turnMove;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Checkbox(
            key: Key(
                'SubstituteInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
            value: turnMove.breakSubstitute,
            onChanged: (change) {
              if (change != null) {
                turnMove.breakSubstitute = change;
                if (!change) {
                  turnMove.realDamage = 0;
                  turnMove.percentDamage = 0;
                }
                widget.onUpdate();
                setState(() {});
                // 統合テスト作成用
                print(
                    "await driver.tap(find.byValueKey('SubstituteInput${turnMove.playerType == PlayerType.me ? 'Own' : 'Opponent'}'));");
              }
            }),
        Text(loc.battleSubstituteBroke),
      ],
    );
  }
}

class ProtectedInput extends StatelessWidget {
  const ProtectedInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: null,
        ),
        Text(ActionFailure(ActionFailure.protected).displayName),
      ],
    );
  }
}

class SelectMoveInput extends StatefulWidget {
  const SelectMoveInput({
    Key? key,
    required this.playerType,
    required this.turnMove,
    required this.pokemonState,
    required this.state,
    required this.onSelect,
    this.onlyAcquiring = false,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnEffectAction turnMove;
  final PokemonState pokemonState;
  final PhaseState state;
  final void Function(Move) onSelect;
  final bool onlyAcquiring;

  @override
  State<SelectMoveInput> createState() => _SelectMoveInputState();
}

class _SelectMoveInputState extends State<SelectMoveInput> {
  TextEditingController moveSearchTextController = TextEditingController();
  late PlayerType playerType;
  late TurnEffectAction turnMove;
  late PokemonState pokemonState;
  late PhaseState state;

  @override
  void initState() {
    super.initState();
    playerType = widget.playerType;
    turnMove = widget.turnMove;
    pokemonState = widget.pokemonState;
    state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    List<Move> moves = [];
    if (widget.onlyAcquiring) {
      // プレイヤーが自身のとき：覚えているわざ限定
      if (playerType == PlayerType.me) {
        moves.addAll(pokemonState.moves);
      }
      // プレイヤーが相手のとき
      else {
        // 覚えているわざがすべて判明しているとき
        if (pokemonState.moves.length == 4) {
          moves.addAll(pokemonState.moves);
        } else {
          // 覚えているわざを最初に追加し、それ以外をあとで追加
          for (final acquiringMove in pokemonState.moves) {
            moves.add(acquiringMove);
          }
          moves.addAll(PokeDB().pokeBase[pokemonState.pokemon.no]!.move.where(
                (element) =>
                    element.isValid &&
                    moves.where((e) => e.id == element.id).isEmpty,
              ));
        }
      }
      moves.add(PokeDB().moves[165]!); // わるあがき
    } else {
      moves = PokeDB().moves.values.toList();
      moves.removeWhere((element) => element.id == 0);
    }
    List<ListTile> moveTiles = [];

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
      moveTiles.add(
        ListTile(
          key: Key(
              'BattleActionCommandMoveListTile${playerType == PlayerType.me ? 'Own' : 'Opponent'}${myMove.displayName}'),
          dense: true,
          leading: turnMove
              .getReplacedMoveType(myMove, pokemonState, state)
              .displayIcon,
          title: Text(myMove.displayName),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => widget.onSelect(myMove),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              key: Key(
                  'StandAloneMoveSearch${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
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
            key: Key('BattleActionCommandMoveListView'),
            viewItemCount: 4,
            children: moveTiles,
          ),
        ),
      ],
    );
  }
}

class SwitchSelectItemInput extends StatefulWidget {
  const SwitchSelectItemInput({
    Key? key,
    required this.switchText,
    required this.initialSwitchValue,
    required this.onSwitchChanged,
    required this.itemText,
    required this.initialItemText,
    required this.onItemSelected,
    required this.playerType,
    required this.pokemonState,
    this.onlyHolding = false,
    this.containNone = false,
    this.filter,
  }) : super(key: key);

  final String switchText;
  final bool initialSwitchValue;
  final void Function(bool) onSwitchChanged;
  final String itemText;
  final String initialItemText;
  final void Function(Item) onItemSelected;
  final PlayerType playerType;
  final PokemonState pokemonState;
  final bool onlyHolding;
  final bool containNone;
  final bool Function(Item)? filter;

  @override
  State<SwitchSelectItemInput> createState() => _SwitchSelectItemInputState();
}

class _SwitchSelectItemInputState extends State<SwitchSelectItemInput> {
  TextEditingController itemSearchTextController = TextEditingController();
  late bool switchOn = false;
  late final PokemonState pokemonState;

  @override
  void initState() {
    super.initState();
    switchOn = widget.initialSwitchValue;
    pokemonState = widget.pokemonState;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SwitchListTile(
            key: Key("SwitchSelectItemInputSwitch"),
            title: Text(widget.switchText),
            onChanged: (value) {
              switchOn = value;
              widget.onSwitchChanged(value);
            },
            value: switchOn,
          ),
        ),
        Expanded(
          flex: 1,
          child: TypeAheadField(
            key: Key("SwitchSelectItemInputTextField"),
            textFieldConfiguration: TextFieldConfiguration(
              controller: itemSearchTextController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: widget.itemText,
              ),
              enabled: switchOn,
            ),
            autoFlipDirection: true,
            suggestionsCallback: (pattern) async {
              List<Item> matches = [];
              if (widget.onlyHolding) {
                if (widget.playerType == PlayerType.opponent) {
                  // 対象が相手
                  // もちものを持っていないことが確定している場合
                  if (pokemonState.getHoldingItem() == null &&
                      widget.containNone) {
                    matches.add(Item(
                      id: 0,
                      displayName: 'なし',
                      displayNameEn: 'None',
                      flingPower: 0,
                      flingEffectId: 0,
                      timing: Timing.none,
                      isBerry: false,
                      imageUrl: '',
                      possiblyChangeStat: [],
                    ));
                    // 持っているもちものが確定している場合
                  } else if (pokemonState.getHoldingItem() != null &&
                      pokemonState.getHoldingItem()!.id != 0) {
                    matches.add(pokemonState.getHoldingItem()!);
                    // 何を持っているか分からない場合
                  } else {
                    matches = PokeDB().items.values.toList();
                    matches.removeWhere((element) => element.id == 0);
                    // もちものなしを含める場合
                    if (widget.containNone) {
                      matches.add(Item(
                        id: 0,
                        displayName: 'なし',
                        displayNameEn: 'None',
                        flingPower: 0,
                        flingEffectId: 0,
                        timing: Timing.none,
                        isBerry: false,
                        imageUrl: '',
                        possiblyChangeStat: [],
                      ));
                    }
                    for (var item in pokemonState.impossibleItems) {
                      matches.removeWhere((element) => element.id == item.id);
                    }
                  }
                  // 対象が自身
                } else if (pokemonState.getHoldingItem() != null) {
                  matches = [pokemonState.getHoldingItem()!];
                  // もちものなしを含める場合
                } else if (widget.containNone) {
                  matches = [
                    Item(
                      id: 0,
                      displayName: 'なし',
                      displayNameEn: 'None',
                      flingPower: 0,
                      flingEffectId: 0,
                      timing: Timing.none,
                      isBerry: false,
                      imageUrl: '',
                      possiblyChangeStat: [],
                    )
                  ];
                }
                // フィルタ適用
                if (widget.filter != null) matches.retainWhere(widget.filter!);
                matches.retainWhere((s) {
                  return toKatakana50(s.displayName.toLowerCase())
                      .contains(toKatakana50(pattern.toLowerCase()));
                });
              } else {
                matches = PokeDB().items.values.toList();
                matches.removeWhere((element) => element.id == 0);
              }
              return matches;
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              itemSearchTextController.text = suggestion.displayName;
              widget.onItemSelected(suggestion);
            },
          ),
        ),
      ],
    );
  }
}

class SelectItemInput extends StatefulWidget {
  const SelectItemInput({
    Key? key,
    required this.itemText,
    required this.onItemSelected,
    required this.playerType,
    required this.pokemonState,
    this.onlyHolding = false,
    this.containNone = false,
    this.filter,
  }) : super(key: key);

  final String itemText;
  final void Function(Item) onItemSelected;
  final PlayerType playerType;
  final PokemonState pokemonState;
  final bool onlyHolding;
  final bool containNone;
  final bool Function(Item)? filter;

  @override
  State<SelectItemInput> createState() => _SelectItemInputState();
}

class _SelectItemInputState extends State<SelectItemInput> {
  TextEditingController itemSearchTextController = TextEditingController();
  late final PokemonState pokemonState;

  @override
  void initState() {
    super.initState();
    pokemonState = widget.pokemonState;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      key: Key(
          'SelectItemTextField${widget.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
      textFieldConfiguration: TextFieldConfiguration(
        controller: itemSearchTextController,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: widget.itemText,
        ),
      ),
      autoFlipDirection: true,
      suggestionsCallback: (pattern) async {
        List<Item> matches = [];
        if (widget.onlyHolding) {
          if (widget.playerType == PlayerType.opponent) {
            // 対象が相手
            // もちものを持っていないことが確定している場合
            if (pokemonState.getHoldingItem() == null && widget.containNone) {
              matches.add(Item(
                id: 0,
                displayName: 'なし',
                displayNameEn: 'None',
                flingPower: 0,
                flingEffectId: 0,
                timing: Timing.none,
                isBerry: false,
                imageUrl: '',
                possiblyChangeStat: [],
              ));
              // 持っているもちものが確定している場合
            } else if (pokemonState.getHoldingItem() != null &&
                pokemonState.getHoldingItem()!.id != 0) {
              matches.add(pokemonState.getHoldingItem()!);
              // 何を持っているか分からない場合
            } else {
              matches = PokeDB().items.values.toList();
              matches.removeWhere((element) => element.id == 0);
              // もちものなしを含める場合
              if (widget.containNone) {
                matches.add(Item(
                  id: 0,
                  displayName: 'なし',
                  displayNameEn: 'None',
                  flingPower: 0,
                  flingEffectId: 0,
                  timing: Timing.none,
                  isBerry: false,
                  imageUrl: '',
                  possiblyChangeStat: [],
                ));
              }
              for (var item in pokemonState.impossibleItems) {
                matches.removeWhere((element) => element.id == item.id);
              }
            }
            // 対象が自身
          } else if (pokemonState.getHoldingItem() != null) {
            matches = [pokemonState.getHoldingItem()!];
            // もちものなしを含める場合
          } else if (widget.containNone) {
            matches = [
              Item(
                id: 0,
                displayName: 'なし',
                displayNameEn: 'None',
                flingPower: 0,
                flingEffectId: 0,
                timing: Timing.none,
                isBerry: false,
                imageUrl: '',
                possiblyChangeStat: [],
              )
            ];
          }
          // フィルタ適用
          if (widget.filter != null) matches.retainWhere(widget.filter!);
          matches.retainWhere((s) {
            return toKatakana50(s.displayName.toLowerCase())
                .contains(toKatakana50(pattern.toLowerCase()));
          });
        } else {
          matches = PokeDB().items.values.toList();
          matches.removeWhere((element) => element.id == 0);
        }
        return matches;
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      onSuggestionSelected: (suggestion) {
        itemSearchTextController.text = suggestion.displayName;
        widget.onItemSelected(suggestion);
        // 統合テスト作成用
        print(
            "await driver.tap(find.byValueKey('SelectItemTextField${widget.playerType == PlayerType.me ? 'Own' : 'Opponent'}'));\n"
            "await driver.enterText('${suggestion.displayName}');\n"
            "await driver.tap(find.descendant(\n"
            "    of: find.byType('ListTile'), matching: find.text('${suggestion.displayName}')));");
      },
    );
  }
}

class SelectAbilityInput extends StatefulWidget {
  const SelectAbilityInput({
    Key? key,
    required this.abilityText,
    required this.onAbilitySelected,
    required this.playerType,
    required this.pokemonState,
    required this.state,
    this.onlyCurrent = false,
  }) : super(key: key);

  final String abilityText;
  final void Function(Ability) onAbilitySelected;
  final PlayerType playerType;
  final PokemonState pokemonState;
  final PhaseState state;
  final bool onlyCurrent;

  @override
  State<SelectAbilityInput> createState() => _SelectAbilityInputState();
}

class _SelectAbilityInputState extends State<SelectAbilityInput> {
  TextEditingController abilitySearchTextController = TextEditingController();
  late final PokemonState pokemonState;
  late final PhaseState state;

  @override
  void initState() {
    super.initState();
    pokemonState = widget.pokemonState;
    state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      key: Key(
          'SelectAbilityInput${widget.playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
      textFieldConfiguration: TextFieldConfiguration(
        controller: abilitySearchTextController,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: widget.abilityText,
        ),
      ),
      autoFlipDirection: true,
      suggestionsCallback: (pattern) async {
        List<Ability> matches = [];
        if (widget.onlyCurrent) {
          if (widget.playerType == PlayerType.opponent) {
            // 対象が相手
            // 現在のとくせいが確定している場合
            if (pokemonState.currentAbility.id != 0) {
              matches.add(pokemonState.currentAbility);
              // 現在のとくせいか分からない場合
            } else {
              matches = pokemonState.possibleAbilities;
              if (state.canAnyZoroark) matches.add(PokeDB().abilities[149]!);
            }
            // 対象が自身
          } else {
            matches = [pokemonState.currentAbility];
          }
          matches.retainWhere((s) {
            return toKatakana50(s.displayName.toLowerCase())
                .contains(toKatakana50(pattern.toLowerCase()));
          });
        } else {
          matches = PokeDB().abilities.values.toList();
          matches.removeWhere((element) => element.id == 0);
        }
        return matches;
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      onSuggestionSelected: (suggestion) {
        abilitySearchTextController.text = suggestion.displayName;
        widget.onAbilitySelected(suggestion);
        // 統合テスト作成用
        print("// ${suggestion.displayName}\n"
            "{\n"
            "  await driver.tap(find.byValueKey('SelectAbilityInput${widget.playerType == PlayerType.me ? 'Own' : 'Opponent'}'));\n"
            "  await driver.enterText('${suggestion.displayName}');\n"
            "  final selectListTile = find.ancestor(\n"
            "    matching: find.byType('ListTile'),\n"
            "      of: find.text('${suggestion.displayName}'),\n"
            "      firstMatchOnly: true,\n"
            "    );\n"
            "    await driver.tap(selectListTile);\n"
            "}");
      },
    );
  }
}
