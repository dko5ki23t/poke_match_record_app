import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'integration_test_core/integration_test_1_5.dart';
import 'integration_test_core/integration_test_6_10.dart';
import 'integration_test_core/integration_test_11_15.dart';
import 'integration_test_core/integration_test_16_20.dart';

/// 量が多いのでVSCodeでは「Ctrl+k」「Ctrl+0」で一度すべて折りたたむこと推奨

void main() {
  FlutterDriver? driver;
  bool doTest = true;

  setUpAll(() async {
    try {
      driver = await FlutterDriver.connect(
              dartVmServiceUrl: 'http://localhost:8888/')
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception();
      });
    } catch (e) {
      print('Flutter driver connection failed');
      doTest = false;
    }
  });

  tearDownAll(() async {
    if (driver != null) {
      await driver!.close();
    }
  });

  group('統合テスト(もこうの実況を記録)', () {
    int minutesPerTest = 5;
    /*
    test('パーモット戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_1(driver!);
      }
    });
    test('パーモット戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_2(driver!);
      }
    });
    test('パーモット戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_3(driver!);
      }
    });
    test('パーモット戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test1_4(driver!);
      }
    });
    test('イルカマン戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_1(driver!);
      }
    });
    test('イルカマン戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_2(driver!);
      }
    });
    test('イルカマン戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_3(driver!);
      }
    });
    test('イルカマン戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test2_4(driver!);
      }
    });
    test('イッカネズミ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_1(driver!);
      }
    });
    test('イッカネズミ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_2(driver!);
      }
    });
    test('イッカネズミ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_3(driver!);
      }
    });
    test('イッカネズミ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test3_4(driver!);
      }
    });
    test('ミミズズ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_1(driver!);
      }
    });
    test('ミミズズ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_2(driver!);
      }
    });
    test('ミミズズ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_3(driver!);
      }
    });
    test('ミミズズ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test4_4(driver!);
      }
    });
    test('グレンアルマ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test5_1(driver!);
      }
    });
    test('グレンアルマ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test5_2(driver!);
      }
    });
    test('グレンアルマ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test5_3(driver!);
      }
    });
    test('グレンアルマ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test5_4(driver!);
      }
    });
    */
    test('ノココッチ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test6_1(driver!);
      }
    });
    test('ノココッチ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test6_2(driver!);
      }
    });
    test('ノココッチ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test6_3(driver!);
      }
    });
    test('ノココッチ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test6_4(driver!);
      }
    });
    test('ウミトリオ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test7_1(driver!);
      }
    });
    test('ウミトリオ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test7_2(driver!);
      }
    });
    test('ウミトリオ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test7_3(driver!);
      }
    });
    test('ウミトリオ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test7_4(driver!);
      }
    });
    test('ウミトリオ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test7_5(driver!);
      }
    });
    test('キョジオーン戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test8_1(driver!);
      }
    });
    test('キョジオーン戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test8_2(driver!);
      }
    });
    test('キョジオーン戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test8_3(driver!);
      }
    });
    test('キョジオーン戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test8_4(driver!);
      }
    });
    test('ミガルーサ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test9_1(driver!);
      }
    });
    test('ミガルーサ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test9_2(driver!);
      }
    });
    test('ミガルーサ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test9_3(driver!);
      }
    });
    test('ミガルーサ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test9_4(driver!);
      }
    });
    test('リククラゲ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test10_1(driver!);
      }
    });
    test('リククラゲ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test10_2(driver!);
      }
    });
    test('リククラゲ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test10_3(driver!);
      }
    });
    test('セグレイブ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test11_1(driver!);
      }
    });
    test('セグレイブ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test11_2(driver!);
      }
    });
    test('セグレイブ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test11_3(driver!);
      }
    });
    test('セグレイブ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test11_4(driver!);
      }
    });
    test('セグレイブ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test11_5(driver!);
      }
    });
    test('ワナイダー戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test12_1(driver!);
      }
    });
    test('ワナイダー戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test12_2(driver!);
      }
    });
    test('ワナイダー戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test12_3(driver!);
      }
    });
    test('ワナイダー戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test12_4(driver!);
      }
    });
    test('トドロクツキ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test13_1(driver!);
      }
    });
    test('トドロクツキ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test13_2(driver!);
      }
    });
    test('トドロクツキ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test13_3(driver!);
      }
    });
    test('トドロクツキ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test13_4(driver!);
      }
    });
    test('シャリタツ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test14_1(driver!);
      }
    });
    test('シャリタツ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test14_2(driver!);
      }
    });
    test('シャリタツ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test14_3(driver!);
      }
    });
    test('シャリタツ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test14_4(driver!);
      }
    });
    test('エルレイド戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test15_1(driver!);
      }
    });
    test('エルレイド戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test15_2(driver!);
      }
    });
    test('エルレイド戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test15_3(driver!);
      }
    });
    test('エルレイド戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test15_4(driver!);
      }
    });
    test('クエスパトラ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test16_1(driver!);
      }
    });
    test('クエスパトラ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test16_2(driver!);
      }
    });
    test('クエスパトラ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test16_3(driver!);
      }
    });
    test('オリーヴァ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test17_1(driver!);
      }
    });
    test('オリーヴァ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test17_2(driver!);
      }
    });
    test('オリーヴァ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test17_3(driver!);
      }
    });
    test('オリーヴァ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test17_4(driver!);
      }
    });
    test('マスカーニャ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test18_1(driver!);
      }
    });
    test('マスカーニャ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test18_2(driver!);
      }
    });
    test('マスカーニャ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test18_3(driver!);
      }
    });
    test('マスカーニャ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test18_4(driver!);
      }
    });
    test('ウェーニバル戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test19_1(driver!);
      }
    });
    test('ウェーニバル戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test19_2(driver!);
      }
    });
    test('ウェーニバル戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test19_3(driver!);
      }
    });
    test('ウェーニバル戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test19_4(driver!);
      }
    });
    test('ウェーニバル戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test19_5(driver!);
      }
    });
    test('カラミンゴ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test20_1(driver!);
      }
    });
    test('カラミンゴ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test20_2(driver!);
      }
    });
    test('カラミンゴ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test20_3(driver!);
      }
    });
    test('カラミンゴ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test20_4(driver!);
      }
    });
  });
}
