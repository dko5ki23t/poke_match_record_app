import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/battle_command.dart';
import 'package:poke_reco/custom_widgets/change_pokemon_command_tile.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';

class BattleChangeFaintingCommand extends StatefulWidget {
  const BattleChangeFaintingCommand({
    Key? key,
    required this.playerType,
    required this.turnEffect,
    required this.phaseState,
    required this.myParty,
    required this.yourParty,
    required this.parentSetState,
    required this.onConfirm,
    required this.onUnConfirm,
  }) : super(key: key);

  final PlayerType playerType;
  final TurnEffectChangeFaintingPokemon turnEffect;
  final PhaseState phaseState;
  final Party myParty;
  final Party yourParty;
  final Function(void Function()) parentSetState;
  final Function() onConfirm;
  final Function() onUnConfirm;

  @override
  BattleChangeFaintingCommandState createState() =>
      BattleChangeFaintingCommandState();
}

class BattleChangeFaintingCommandState
    extends BattleCommandState<BattleChangeFaintingCommand> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );
    final loc = AppLocalizations.of(context)!;
    final parentSetState = widget.parentSetState;
    final turnEffect = widget.turnEffect;
    final prevState = widget.phaseState;
    final playerType = widget.playerType;
    final myParty = widget.myParty;

    Widget commandColumn;
    final commonCommand = Expanded(
      flex: 1,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: null,
              child: Text(loc.commonMove),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              style: pressedStyle,
              child: Text(loc.battlePokemonChange),
            ),
            SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: null,
              child: Text(loc.battleSurrender),
            ),
          ],
        ),
      ),
    );
    late List<Widget> typeCommand;

    List<ListTile> pokemonTiles = [];
    List<int> addedIndex = [];
    for (int i = 0; i < myParty.pokemonNum; i++) {
      if (prevState.isPossibleBattling(playerType, i) &&
          !prevState.getPokemonStates(playerType)[i].isFainting &&
          i !=
              myParty.pokemons.indexWhere((element) =>
                  element ==
                  prevState.getPokemonState(playerType, null).pokemon)) {
        pokemonTiles.add(
          ChangePokemonCommandTile(
            myParty.pokemons[i]!,
            theme,
            onTap: () {
              parentSetState(() {
                turnEffect.changePokemonIndex = i + 1;
                widget.onConfirm();
              });
              // 統合テスト作成用
              final prePoke =
                  prevState.getPokemonState(playerType, null).pokemon;
              final poke = prevState.getPokemonStates(playerType)[i].pokemon;
              print("// ${prePoke.omittedName}ひんし->${poke.omittedName}に交代\n"
                  "await changePokemon(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${poke.name}', false);");
            },
            selected: turnEffect.changePokemonIndex == i + 1,
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
        child: Text(loc.battlePokemonChange),
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

    commandColumn = Column(
      key: ValueKey<int>(0),
      children: [
        commonCommand,
        ...typeCommand,
      ],
    );

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
  void reset() {}
}
