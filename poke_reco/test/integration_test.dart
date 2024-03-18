import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'integration_test_core/integration_test_1_5.dart';
import 'integration_test_core/integration_test_6_10.dart';
import 'integration_test_core/integration_test_11_15.dart';
import 'integration_test_core/integration_test_16_20.dart';
import 'integration_test_core/integration_test_21_25.dart';
import 'integration_test_core/integration_test_26_30.dart';
import 'integration_test_core/integration_test_31_35.dart';
import 'integration_test_core/integration_test_36_40.dart';

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

    test('ハルクジラ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test21_1(driver!);
      }
    });
    test('ハルクジラ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test21_2(driver!);
      }
    });
    test('ハルクジラ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test21_3(driver!);
      }
    });

    test('ハルクジラ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test21_4(driver!);
      }
    });
    test('モトトカゲ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_1(driver!);
      }
    });
    test('モトトカゲ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_2(driver!);
      }
    });
    test('モトトカゲ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_3(driver!);
      }
    });
    test('モトトカゲ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_4(driver!);
      }
    });
    test('モトトカゲ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_5(driver!);
      }
    });
    test('モトトカゲ戦6', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test22_6(driver!);
      }
    });
    test('エクスレッグ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test23_1(driver!);
      }
    });
    test('エクスレッグ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test23_2(driver!);
      }
    });
    test('エクスレッグ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test23_3(driver!);
      }
    });
    test('エクスレッグ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test23_4(driver!);
      }
    });
    test('エクスレッグ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test23_5(driver!);
      }
    });
    test('ムクホーク戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test24_1(driver!);
      }
    });
    test('ムクホーク戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test24_2(driver!);
      }
    });
    test('ムクホーク戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test24_3(driver!);
      }
    });
    test('ムクホーク戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test24_4(driver!);
      }
    });
    test('アノホラグサ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test25_1(driver!);
      }
    });
    test('アノホラグサ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test25_2(driver!);
      }
    });
    test('アノホラグサ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test25_3(driver!);
      }
    });
    test('ハラバリー戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test26_1(driver!);
      }
    });
    test('ハラバリー戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test26_2(driver!);
      }
    });
    test('ハラバリー戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test26_3(driver!);
      }
    });
    test('ハラバリー戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test26_4(driver!);
      }
    });
    test('リングマ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test27_1(driver!);
      }
    });
    test('リングマ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test27_2(driver!);
      }
    });
    test('リングマ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test27_3(driver!);
      }
    });
    test('リングマ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test27_4(driver!);
      }
    });
    test('ハカドッグ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test28_1(driver!);
      }
    });
    test('ハカドッグ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test28_2(driver!);
      }
    });
    test('ハカドッグ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test28_3(driver!);
      }
    });
    test('ハカドッグ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test28_4(driver!);
      }
    });
    test('イキリンコ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test29_1(driver!);
      }
    });
    test('イキリンコ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test29_2(driver!);
      }
    });
    test('イキリンコ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test29_3(driver!);
      }
    });
    test('イキリンコ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test29_4(driver!);
      }
    });
    test('イキリンコ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test29_5(driver!);
      }
    });
    test('オドリドリ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test30_1(driver!);
      }
    });
    test('オドリドリ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test30_2(driver!);
      }
    });
    test('オドリドリ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test30_3(driver!);
      }
    });
    test('オドリドリ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test30_4(driver!);
      }
    });
    test('オノノクス戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test31_1(driver!);
      }
    });
    test('オノノクス戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test31_2(driver!);
      }
    });
    test('オノノクス戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test31_3(driver!);
      }
    });
    test('オノノクス戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test31_4(driver!);
      }
    });
    test('スコヴィラン戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test32_1(driver!);
      }
    });
    test('スコヴィラン戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test32_2(driver!);
      }
    });
    test('スコヴィラン戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test32_3(driver!);
      }
    });
    test('スコヴィラン戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test32_4(driver!);
      }
    });
    test('スコヴィラン戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test32_5(driver!);
      }
    });
    test('オトシドリ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test33_1(driver!);
      }
    });
    test('オトシドリ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test33_2(driver!);
      }
    });
    test('オトシドリ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test33_3(driver!);
      }
    });
    test('エーフィ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test34_1(driver!);
      }
    });
    test('エーフィ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test34_2(driver!);
      }
    });
    test('エーフィ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test34_3(driver!);
      }
    });
    test('エーフィ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test34_4(driver!);
      }
    });
    test('フローゼル戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test35_1(driver!);
      }
    });
    test('フローゼル戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test35_2(driver!);
      }
    });
    test('フローゼル戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test35_3(driver!);
      }
    });
    test('ガケガニ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test36_1(driver!);
      }
    });
    test('ガケガニ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test36_2(driver!);
      }
    });
    test('ガケガニ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test36_3(driver!);
      }
    });
    test('ガケガニ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test36_4(driver!);
      }
    });
    test('ソウブレイズ戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test37_1(driver!);
      }
    });
    test('ソウブレイズ戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test37_2(driver!);
      }
    });
    test('ソウブレイズ戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test37_3(driver!);
      }
    });
    test('ソウブレイズ戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test37_4(driver!);
      }
    });
    test('ソウブレイズ戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test37_4(driver!);
      }
    });
    test('キラフロル戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test38_1(driver!);
      }
    });
    test('キラフロル戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test38_2(driver!);
      }
    });
    test('キラフロル戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test38_3(driver!);
      }
    });
    test('キラフロル戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test38_4(driver!);
      }
    });
    test('ポットデス戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test39_1(driver!);
      }
    });
    test('ポットデス戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test39_2(driver!);
      }
    });
    test('ポットデス戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test39_3(driver!);
      }
    });
    test('ポットデス戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test39_4(driver!);
      }
    });
    test('ポットデス戦5', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test39_4(driver!);
      }
    });
    test('ゴーゴート戦1', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test40_1(driver!);
      }
    });
    test('ゴーゴート戦2', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test40_2(driver!);
      }
    });
    test('ゴーゴート戦3', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test40_3(driver!);
      }
    });
    test('ゴーゴート戦4', timeout: Timeout(Duration(minutes: minutesPerTest)),
        () async {
      if (doTest) {
        await test40_4(driver!);
      }
    });
  });
}
