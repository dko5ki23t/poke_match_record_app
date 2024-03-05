import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'integration_test_core/integration_test_1_5.dart';
import 'integration_test_core/integration_test_6_10.dart';

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
    int minutesPerTest = 10;
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
  });
}
