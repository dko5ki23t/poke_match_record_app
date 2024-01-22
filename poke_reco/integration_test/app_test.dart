import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/main.dart';

void main() async {
  // assetの準備等完了させるために不可欠
  TestWidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final directory = await getApplicationDocumentsDirectory();
  final localPath = directory.path;
  final saveDataFile = File('$localPath/poke_reco.json');
  String configText;
  dynamic configJson;
  Locale? locale;
  try {
    configText = await saveDataFile.readAsString();
    configJson = jsonDecode(configText);
    switch (configJson[configKeyLanguage] as int) {
      case 1:
        locale = Locale('en');
        break;
      case 0:
      default:
        locale = Locale('ja');
        break;
    }
  } catch (e) {
    locale = null;
  }
  // デバッグ用DBを読み込むように設定
  PokeDB().setTestMode();
  group('統合テスト1(仮)', () {
    testWidgets('統合テスト1(仮)', (tester) async {
      await tester.pumpWidget(MyApp(initialLocale: locale));
      // TODO
      // 対戦タブボタンタップ
      await tester
          .tap(find.widgetWithIcon(BottomNavigationBarItem, Icons.list));
      await tester.pumpAndSettle();
      // 追加ボタン(+)タップ
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle(Duration(seconds: 2));
      expect(find.byType(TextField), findsWidgets);
      // 基本情報を適当に入力
      //await tester.enterText(find.widgetWithText(widgetType, text), text)
      // 適当に選出ポケモン選ぶ
    });
  });
}
