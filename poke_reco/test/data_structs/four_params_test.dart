import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:test/test.dart';

void main() {
  group('FourParams class の単体テスト', () {
    final FourParams fourParams = FourParams(StatIndex.C)
      ..race = 50
      ..indi = 128
      ..effort = 100
      ..real = 200;
    const String sqlStr = '3,50,128,100,200';

    // https://pokecosmos.github.io/calc_stats_sv/
    // ゼニガメのステータスでテスト(ランダムに生成したデータでテストできるとなお良い)
    const hpStatList = [44, 25, 84, 127];
    const hpStatListLv100 = [44, 3, 252, 264];
    const aStatList = [48, 31, 20, 71];
    const aStatListPlus = [48, 18, 88, 80];
    const aStatListMinus = [48, 31, 148, 78];
    final plusNature = Nature(0, '', '', StatIndex.none, StatIndex.A);
    final minusNature = Nature(0, '', '', StatIndex.A, StatIndex.none);

    test('努力値を算出', () {
      FourParams testParam = FourParams(StatIndex.H)
        ..set(hpStatList[0], hpStatList[1], 0, hpStatList[3]);
      expect(testParam.updateEffort(50, null), hpStatList[2]);
      testParam = FourParams(StatIndex.H)
        ..set(hpStatListLv100[0], hpStatListLv100[1], 0, hpStatListLv100[3]);
      expect(testParam.updateEffort(100, null), hpStatListLv100[2]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatList[0], aStatList[1], 0, aStatList[3]);
      expect(testParam.updateEffort(50, null), aStatList[2]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatListPlus[0], aStatListPlus[1], 0, aStatListPlus[3]);
      expect(testParam.updateEffort(50, plusNature), aStatListPlus[2]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatListMinus[0], aStatListMinus[1], 0, aStatListMinus[3]);
      expect(testParam.updateEffort(50, minusNature), aStatListMinus[2]);
    });

    test('個体値を算出', () {
      FourParams testParam = FourParams(StatIndex.H)
        ..set(hpStatList[0], 0, hpStatList[2], hpStatList[3]);
      expect(testParam.updateIndi(50, null), hpStatList[1]);
      testParam = FourParams(StatIndex.H)
        ..set(hpStatListLv100[0], 0, hpStatListLv100[2], hpStatListLv100[3]);
      expect(testParam.updateIndi(100, null), hpStatListLv100[1]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatList[0], 0, aStatList[2], aStatList[3]);
      expect(testParam.updateIndi(50, null), aStatList[1]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatListPlus[0], 0, aStatListPlus[2], aStatListPlus[3]);
      expect(testParam.updateIndi(50, plusNature), aStatListPlus[1]);
      testParam = FourParams(StatIndex.A)
        ..set(aStatListMinus[0], 0, aStatListMinus[2], aStatListMinus[3]);
      expect(testParam.updateIndi(50, minusNature), aStatListMinus[1]);
    });

    test('実数値以外の値から生成', () {
      FourParams testParam = FourParams.createFromValues(
          statIndex: StatIndex.H,
          race: hpStatList[0],
          indi: hpStatList[1],
          effort: hpStatList[2]);
      expect(testParam.real, hpStatList[3]);
      testParam = FourParams.createFromValues(
          statIndex: StatIndex.H,
          level: 100,
          race: hpStatListLv100[0],
          indi: hpStatListLv100[1],
          effort: hpStatListLv100[2]);
      expect(testParam.real, hpStatListLv100[3]);
      testParam = FourParams.createFromValues(
          statIndex: StatIndex.A,
          race: aStatList[0],
          indi: aStatList[1],
          effort: aStatList[2]);
      expect(testParam.real, aStatList[3]);
      testParam = FourParams.createFromValues(
          statIndex: StatIndex.A,
          race: aStatListPlus[0],
          indi: aStatListPlus[1],
          effort: aStatListPlus[2],
          nature: plusNature);
      expect(testParam.real, aStatListPlus[3]);
      testParam = FourParams.createFromValues(
          statIndex: StatIndex.A,
          race: aStatListMinus[0],
          indi: aStatListMinus[1],
          effort: aStatListMinus[2],
          nature: minusNature);
      expect(testParam.real, aStatListMinus[3]);
    });

    test('SQL文字列から変換', () {
      final parsed = FourParams.deserialize(sqlStr, ',');
      expect(parsed, fourParams);
    });

    test('SQL文字列に変換', () {
      final str = fourParams.serialize(',');
      expect(str, sqlStr);
    });
  });
}
