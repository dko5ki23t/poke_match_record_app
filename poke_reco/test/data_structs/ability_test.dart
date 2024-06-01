import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:test/test.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Ability class の単体テスト', () {
    final Ability ability = Ability(100, '日本語名', 'EnglishName', Timing.action,
        Target.user, [Tuple2(StatIndex.S, 50)]);
    final String sqlStr =
        '100,日本語名,EnglishName,${ability.timing.index},7,5}50{';

    test('SQL文字列から変換', () {
      final parsed = Ability.deserialize(sqlStr, ',', '{', '}');
      expect(parsed == ability, true);
    });

    test('SQL文字列に変換', () {
      final str = ability.serialize(',', '{', '}');
      expect(str, sqlStr);
    });

    // TODO? processPassiveEffect()やclearPassiveEffect()
  });
}
