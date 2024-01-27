import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/tool.dart';

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
  }) : super(key: key);

  final TurnMove turnMove;
  final void Function() onUpdate;

  @override
  State<HitCriticalInputRow> createState() => _HitCriticalInputRowState();
}

class _HitCriticalInputRowState extends State<HitCriticalInputRow> {
  TurnMove turnMove = TurnMove();

  @override
  void initState() {
    super.initState();
    turnMove = widget.turnMove;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Checkbox(
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
                    }
                  }),
              Text(MoveHit.hit.displayName),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Checkbox(
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
                    }
                  }),
              Text(MoveHit.critical.displayName),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectMoveInput extends StatefulWidget {
  const SelectMoveInput({
    Key? key,
    required this.turnMove,
    required this.pokemonState,
    required this.state,
    required this.onSelect,
    this.onlyAcquiring = false,
  }) : super(key: key);

  final TurnMove turnMove;
  final PokemonState pokemonState;
  final PhaseState state;
  final void Function(Move) onSelect;
  final bool onlyAcquiring;

  @override
  State<SelectMoveInput> createState() => _SelectMoveInputState();
}

class _SelectMoveInputState extends State<SelectMoveInput> {
  TextEditingController moveSearchTextController = TextEditingController();
  late TurnMove turnMove;
  late PokemonState pokemonState;
  late PhaseState state;

  @override
  void initState() {
    super.initState();
    turnMove = widget.turnMove;
    pokemonState = widget.pokemonState;
    state = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    List<Move> moves = [];
    if (widget.onlyAcquiring) {
      // プレイヤーが自身のとき：覚えているわざ限定
      if (turnMove.playerType == PlayerType.me) {
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
      PokeDB().moves.values.toList();
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
          dense: true,
          leading: turnMove
              .getReplacedMoveType(myMove, 0, pokemonState, state)
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
      ],
    );
  }
}
