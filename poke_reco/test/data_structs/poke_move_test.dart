import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:test/test.dart';

import 'test_poke_db.dart';

void main() {
  TestPokeDB pokeData = TestPokeDB();
  group('TurnMove class の単体テスト', () {
    final TurnMove turnMove = TurnMove()
      ..playerType = PlayerType.me
      ..type = TurnMoveType.move
      ..teraType = PokeType.fire
      ..move = pokeData.moves[1]!
      ..isSuccess = false
      ..actionFailure = ActionFailure(1)
      ..moveHits = [MoveHit.critical]
      ..moveEffectivenesses = [MoveEffectiveness.great]
      ..realDamage = [50]
      ..percentDamage = [50]
      ..moveAdditionalEffects = [MoveEffect(1)]
      ..extraArg1 = [1]
      ..extraArg2 = [2]
      ..extraArg3 = [3]
      //.._changePokemonIndexes = [null, null];
      ..moveType = PokeType.water
      ..isFirst = true;
    //.._isValid = false;
    turnMove.setChangePokemonIndex(PlayerType.me, 1);
    turnMove.setChangePokemonIndex(PlayerType.opponent, 2);
    //final String sqlStr = '100,日本語名,EnglishName,${ability.timing.index},7,10';

    /*test('SQL文字列から変換', () {
      final parsed = TurnMove.deserialize(sqlStr, ',');
      expect(parsed == turnMove, true);
    });

    test('SQL文字列に変換', () {
      final str = ability.serialize(',');
      expect(str, sqlStr);
    });*/
  });
}
