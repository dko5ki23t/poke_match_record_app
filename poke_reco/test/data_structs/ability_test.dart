import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:test/test.dart';
import 'package:poke_reco/data_structs/ability.dart';

void main() {
  group('Ability class の単体テスト', () {
    final Ability ability = Ability(
      100, '日本語名', 'EnglishName',
      Timing.action, Target(7), AbilityEffect(10),
    );
    final String sqlStr = '100,日本語名,EnglishName,${ability.timing.index},7,10';
    bool compareAbility(Ability a, Ability b) {
      return a.id == b.id && /*a._displayName == b._displayname && a._displayNameEn == b._displaynameEn &&*/
        a.timing == b.timing && a.target.id == b.target.id && a.effect.id == b.effect.id;
    }

    test('SQL文字列から変換', () {
      final parsed = Ability.deserialize(sqlStr, ',');
      expect(compareAbility(parsed, ability), true);
    });

    test('SQL文字列に変換', () {
      final str = ability.serialize(',');
      expect(str, sqlStr);
    });
  });
}