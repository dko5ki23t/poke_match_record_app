import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_move.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:test/test.dart';

import 'test_poke_db.dart';

void main() async {
  // assetフォルダを直接開いて初期化するテスト用のDB
  TestPokeDB testPokeData = TestPokeDB();
  await testPokeData.initialize();
  PokeDB pokeData = testPokeData.data;
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
      ..percentDamage = [25]
      ..moveAdditionalEffects = [MoveEffect(1)]
      ..extraArg1 = [1]
      ..extraArg2 = [2]
      ..extraArg3 = [3]
      ..moveType = PokeType.water
      ..isFirst = true;
    turnMove.setChangePokemonIndex(PlayerType.me, 1);
    turnMove.setChangePokemonIndex(PlayerType.opponent, 2);
    final String sqlStr =
        '0:1:${PokeType.fire.index}:1:0:1:${MoveHit.critical.index};:${MoveEffectiveness.great.index};:50;:25;:1;:1;:2;:3;:1;2;:${PokeType.water.index}:1';

    test('clear()', () {
      TurnMove testingTurnMove = turnMove.copy();
      testingTurnMove.clear();
      expect(testingTurnMove == TurnMove(), true);
    });

    test('clearMove()', () {
      TurnMove testingTurnMove = turnMove.copy();
      testingTurnMove.clearMove();
      TurnMove expectTurnMove = TurnMove()
        ..playerType = turnMove.playerType
        ..type = turnMove.type;
      expect(testingTurnMove == expectTurnMove, true);
    });

    test('SQL文字列から変換', () {
      final parsed = TurnMove.deserialize(sqlStr, ':', ';');
      expect(parsed == turnMove, true);
    });

    test('SQL文字列に変換', () {
      final str = turnMove.serialize(':', ';');
      expect(str, sqlStr);
    });
  });
}
