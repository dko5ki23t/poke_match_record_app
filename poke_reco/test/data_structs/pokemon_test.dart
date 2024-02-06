import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:test/test.dart';

import 'test_poke_db.dart';

void main() async {
  // assetフォルダを直接開いて初期化するテスト用のDB
  TestPokeDB testPokeData = TestPokeDB();
  await testPokeData.initialize();
  //PokeDB pokeData = testPokeData.data;
  group('Pokemon class の単体テスト', () {
    // https://pokecosmos.github.io/calc_stats_sv/
    // ゼニガメのステータスでテスト
    // ステータスに関する基本的なテストはFourParamsの単体テストで実施
    const hpStatLowList = [44, 14, 0, 111]; // 努力値0
    const hpStatLowestList = [
      44,
      0,
      0,
      104,
      100
    ]; // 努力値・個体値0での実数値よりも低い実数値が設定された場合->努力値・個体値0での実数値に変更される
    const hpStatHighList = [44, 15, 252, 143]; // 努力値max
    const hpStatHighestList = [
      44,
      31,
      252,
      151,
      160
    ]; // 努力値・個体値MAXでの実数値よりも高い実数値が設定された場合->努力値・個体値MAXでの実数値に変更される

    test('実数値が極端に低い/高い場合のテスト', () {
      final pokemon = Pokemon()..setBasicInfoFromNo(7);
      pokemon.h.set(hpStatLowList[0], hpStatLowList[1], 10, hpStatLowList[3]);
      pokemon.updateStatsRefReal(StatIndex.H);
      expect(pokemon.h.indi, hpStatLowList[1]);
      expect(pokemon.h.effort, hpStatLowList[2]);
      expect(pokemon.h.real, hpStatLowList[3]);
      pokemon.h.set(hpStatLowestList[0], 10, 10, hpStatLowestList[4]);
      pokemon.updateStatsRefReal(StatIndex.H);
      expect(pokemon.h.indi, hpStatLowestList[1]);
      expect(pokemon.h.effort, hpStatLowestList[2]);
      expect(pokemon.h.real, hpStatLowestList[3]);
      pokemon.h
          .set(hpStatHighList[0], hpStatHighList[1], 10, hpStatHighList[3]);
      pokemon.updateStatsRefReal(StatIndex.H);
      expect(pokemon.h.indi, hpStatHighList[1]);
      expect(pokemon.h.effort, hpStatHighList[2]);
      expect(pokemon.h.real, hpStatHighList[3]);
      pokemon.h.set(hpStatHighestList[0], 10, 10, hpStatHighestList[4]);
      pokemon.updateStatsRefReal(StatIndex.H);
      expect(pokemon.h.indi, hpStatHighestList[1]);
      expect(pokemon.h.effort, hpStatHighestList[2]);
      expect(pokemon.h.real, hpStatHighestList[3]);
    });
  });
}
