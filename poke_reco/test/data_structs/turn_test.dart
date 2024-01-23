import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:test/test.dart';

import 'test_poke_db.dart';

void main() async {
  TestPokeDB pokeData = TestPokeDB();
  group('Turn class の単体テスト', () {
    //final ownParty = pokeData.parties[1]!;
    Turn turn = Turn()
      ..setInitialPokemonIndex(PlayerType.me, 1)
      ..setInitialPokemonIndex(PlayerType.opponent, 1);
    {
      final pokeState = PokemonState()
        ..playerType = PlayerType.me
        ..remainHP = 200
        ..battlingNum = 1
        //      ..setHoldingItemNoEffect(ownParty.items[i])
        //      ..usedPPs = List.generate(ownParty.pokemons[i]!.moves.length, (i) => 0)
        //      ..setCurrentAbilityNoEffect(ownParty.pokemons[i]!.ability)
        //      ..minStats = SixStats.generate((j) => ownParty.pokemons[i]!.stats[j])
        //      ..maxStats = SixStats.generate((j) => ownParty.pokemons[i]!.stats[j])
        ..moves = [
          Move(
              1,
              'ダミー',
              'Dummy',
              PokeType.normal,
              50,
              100,
              0,
              Target.selectedPokemon,
              DamageClass(DamageClass.physical),
              MoveEffect(0),
              100,
              10),
        ]
        ..type1 = PokeType.normal
        ..type2 = null;
      turn.getInitialPokemonStates(PlayerType.me).add(pokeState);
      turn.getInitialLastExitedStates(PlayerType.me).add(pokeState.copyWith());
    }
    {
      /*Pokemon poke = opponentParty.pokemons[i]!;
      List<int> races = List.generate(
          StatIndex.size.index, (index) => poke.stats[index].race);
      List<int> minReals = List.generate(
          StatIndex.size.index,
          (index) => index == StatIndex.H.index
              ? SixParams.getRealH(poke.level, races[index], 0, 0)
              : SixParams.getRealABCDS(
                  poke.level, races[index], 0, 0, 0.9));
      List<int> maxReals = List.generate(
          StatIndex.size.index,
          (index) => index == StatIndex.H.index
              ? SixParams.getRealH(poke.level, races[index],
                  pokemonMaxIndividual, pokemonMaxEffort)
              : SixParams.getRealABCDS(poke.level, races[index],
                  pokemonMaxIndividual, pokemonMaxEffort, 1.1));*/
      final pokeState = PokemonState()
        ..playerType = PlayerType.opponent
        //..pokemon = poke
        ..battlingNum = 1
//        ..setHoldingItemNoEffect(
//            pokeData.items[pokeData.pokeBase[poke.no]!.fixedItemID])
//        ..minStats = SixStats.generate(
//            (j) => SixParams(poke.stats[j].race, 0, 0, minReals[j]))
//        ..maxStats = SixStats.generate((j) => SixParams(
//            poke.stats[j].race,
//            pokemonMaxIndividual,
//            pokemonMaxEffort,
//            maxReals[j]))
//        ..possibleAbilities = pokeData.pokeBase[poke.no]!.ability
        ..moves = [
          Move(
              1,
              'ダミー',
              'Dummy',
              PokeType.normal,
              50,
              100,
              0,
              Target.selectedPokemon,
              DamageClass(DamageClass.physical),
              MoveEffect(0),
              100,
              10),
        ]
        ..type1 = PokeType.normal
        ..type2 = null;
      turn.getInitialPokemonStates(PlayerType.opponent).add(pokeState);
      turn
          .getInitialLastExitedStates(PlayerType.opponent)
          .add(pokeState.copyWith());
    }

    test('わざによりポケモンひんしになる状況のテスト', () {
      expect(turn.phases.length == 2, true);
    });
  });
}
