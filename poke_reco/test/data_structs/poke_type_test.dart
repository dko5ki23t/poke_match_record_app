import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:test/test.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:tuple/tuple.dart';

const attackTypes = [
  PokeType.normal, PokeType.fire, PokeType.water, PokeType.electric, PokeType.grass,
  PokeType.ice, PokeType.fight, PokeType.poison, PokeType.ground, PokeType.fly,
  PokeType.psychic, PokeType.bug, PokeType.rock, PokeType.ghost, PokeType.dragon,
  PokeType.evil, PokeType.steel, PokeType.fairy,
];

const defenderTypes = [
  Tuple2(PokeType.normal, null), Tuple2(PokeType.fire, null), Tuple2(PokeType.water, null), Tuple2(PokeType.electric, null), Tuple2(PokeType.grass, null),
  Tuple2(PokeType.ice, null), Tuple2(PokeType.fight, null), Tuple2(PokeType.poison, null), Tuple2(PokeType.ground, null), Tuple2(PokeType.fly, null),
  Tuple2(PokeType.psychic, null), Tuple2(PokeType.bug, null), Tuple2(PokeType.rock, null), Tuple2(PokeType.ghost, null), Tuple2(PokeType.dragon, null),
  Tuple2(PokeType.evil, null), Tuple2(PokeType.steel, null), Tuple2(PokeType.fairy, null),
];

// https://www.pokemon.co.jp/ex/sun_moon/fight/161215_01.html
const answers = [
  ['　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '△', '✕', '　', '　', '△', '　',],
  ['　', '△', '△', '　', '〇', '〇', '　', '　', '　', '　', '　', '〇', '△', '　', '△', '　', '〇', '　',],
  ['　', '〇', '△', '　', '△', '　', '　', '　', '〇', '　', '　', '　', '〇', '　', '△', '　', '　', '　',],
  ['　', '　', '〇', '△', '△', '　', '　', '　', '✕', '〇', '　', '　', '　', '　', '△', '　', '　', '　',],
  ['　', '△', '〇', '　', '△', '　', '　', '△', '〇', '△', '　', '△', '〇', '　', '△', '　', '△', '　',],
  ['　', '△', '△', '　', '〇', '△', '　', '　', '〇', '〇', '　', '　', '　', '　', '〇', '　', '△', '　',],
  ['〇', '　', '　', '　', '　', '〇', '　', '△', '　', '△', '△', '△', '〇', '✕', '　', '〇', '〇', '△',],
  ['　', '　', '　', '　', '〇', '　', '　', '△', '△', '　', '　', '　', '△', '△', '　', '　', '✕', '〇',],
  ['　', '〇', '　', '〇', '△', '　', '　', '〇', '　', '✕', '　', '△', '〇', '　', '　', '　', '〇', '　',],
  ['　', '　', '　', '△', '〇', '　', '〇', '　', '　', '　', '　', '〇', '△', '　', '　', '　', '△', '　',],
  ['　', '　', '　', '　', '　', '　', '〇', '〇', '　', '　', '△', '　', '　', '　', '　', '✕', '△', '　',],
  ['　', '△', '　', '　', '〇', '　', '△', '△', '　', '△', '〇', '　', '　', '△', '　', '〇', '△', '△',],
  ['　', '〇', '　', '　', '　', '〇', '△', '　', '△', '〇', '　', '〇', '　', '　', '　', '　', '△', '　',],
  ['✕', '　', '　', '　', '　', '　', '　', '　', '　', '　', '〇', '　', '　', '〇', '　', '△', '　', '　',],
  ['　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '〇', '　', '△', '✕',],
  ['　', '　', '　', '　', '　', '　', '△', '　', '　', '　', '〇', '　', '　', '〇', '　', '△', '　', '△',],
  ['　', '△', '△', '△', '　', '〇', '　', '　', '　', '　', '　', '　', '　', '　', '　', '　', '△', '　',],
  ['　', '△', '　', '　', '　', '　', '〇', '△', '　', '　', '　', '　', '　', '　', '〇', '〇', '△', '　',],
];

void main() {
  group('PokeType の単体テスト', () {
    PokemonState defenderState = PokemonState();
    for (int i = 0; i < attackTypes.length; i++) {
      for (int j = 0; j < defenderTypes.length; j++) {
        defenderState.type1 = defenderTypes[j].item1;
        defenderState.type2 = defenderTypes[j].item2;
        double result = PokeTypeEffectiveness.effectivenessRate(false, false, false, attackTypes[i], defenderState);
        test('タイプ相性 No[$i][$j]', () {
          double answer = 1.0;
          if (answers[i][j] == '〇') answer = 2.0;
          if (answers[i][j] == '△') answer = 0.5;
          if (answers[i][j] == '✕') answer = 0.0;
          expect(answer - result < 0.01, true);
        });
      }
    }
  });
}