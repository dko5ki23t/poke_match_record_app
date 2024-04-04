/// info: 現在使用していない

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
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
  PokeDB().getPokeAPI = false;
  group('統合テスト(もこうの実況を記録)', () {
    testWidgets('パーモット戦', (tester) async {
      await tester.pumpWidget(MyApp(initialLocale: locale));
      //await tester.pump(Duration(seconds: 5));
      // ポケモンタブボタンタップ
      //await tester.tap(find.text('ポケモン'));
      //await tester.pumpAndSettle();
      //expect(find.text('もこパモ'), findsWidgets);
      // 追加ボタン(+)タップ
      await wrapedTap(
          tester, find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
      // 基本情報を入力
      await wrapedEnterText(
          tester, find.widgetWithText(TextField, '対戦名'), 'もこうパーモット戦');
      await wrapedTap(tester, find.widgetWithText(TextFormField, 'あなたのパーティ'));
      await tester.pumpAndSettle();
      expect(find.byType(PartyTile), findsWidgets);
      await wrapedTap(tester, find.widgetWithText(PartyTile, '1もこパーモット'));
      await wrapedEnterText(
          tester, find.widgetWithText(TextFormField, 'あいての名前'), 'メリタマ');
      expect(find.bySemanticsLabel('ポケモン1'), findsWidgets);
      // ポケモン1
      await tester.enterText(find.bySemanticsLabel('ポケモン1'), 'きやら');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'ギャラドス'), findsOneWidget);
      await wrapedTap(tester, find.widgetWithText(ListTile, 'ギャラドス'));
      //await wrapedTap(tester, find.bySemanticsLabel('せいべつ1'));
      //await tester
      //    .ensureVisible(find.widgetWithIcon(DropdownMenuItem, Icons.male));
      //await tester.pumpAndSettle();
      //expect(find.widgetWithIcon(DropdownMenuItem, Icons.male), findsWidgets);
      //await wrapedTap(
      //    tester, find.widgetWithIcon(DropdownMenuItem, Icons.male));
      // ポケモン2
      await wrapedEnterText(tester, find.bySemanticsLabel('ポケモン2'), 'せくれ');
      await wrapedTap(tester, find.widgetWithText(ListTile, 'セグレイブ'));
      //await wrapedTap(tester, find.bySemanticsLabel('せいべつ2'));
      //await wrapedTap(
      //    tester, find.widgetWithIcon(DropdownMenuItem, Icons.female));
      // ポケモン3
      await wrapedEnterText(tester, find.bySemanticsLabel('ポケモン3'), 'てつのつ');
      await wrapedTap(tester, find.widgetWithText(ListTile, 'テツノツツミ'));
      // ポケモン4
      await wrapedEnterText(tester, find.bySemanticsLabel('ポケモン4'), 'てかぬ');
      await wrapedTap(tester, find.widgetWithText(ListTile, 'デカヌチャン'));
      // ポケモン5
      await wrapedEnterText(tester, find.bySemanticsLabel('ポケモン5'), 'てつのこ');
      await wrapedTap(tester, find.widgetWithText(ListTile, 'テツノコウベ'));
      // ポケモン6
      await wrapedEnterText(tester, find.bySemanticsLabel('ポケモン6'), 'かはる');
      await wrapedTap(tester, find.widgetWithText(ListTile, 'カバルドン'));
      //await wrapedTap(tester, find.bySemanticsLabel('せいべつ6'));
      //await wrapedTap(
      //    tester, find.widgetWithIcon(DropdownMenuItem, Icons.female));
      // 次へボタンタップ
      await wrapedTap(tester, find.byIcon(Icons.navigate_next));
      //await tester.ensureVisible(
      //    find.textContaining('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'));
      //expect(
      //    find.textContaining('あなたの選出ポケモン3匹と相手の先頭ポケモンを選んでください。'), findsWidgets);
      // 選出ポケモンを選ぶ
      //await tester.ensureVisible(find.byIcon(Icons.air));
      await tester.pumpAndSettle();
      await wrapedTap(tester, find.textContaining('もこいかくマンダ/'));
      await wrapedTap(tester, find.textContaining('もこパモ/'));
      await wrapedTap(tester, find.textContaining('もこロローム/'));
      await wrapedTap(tester, find.textContaining('デカヌチャン/'));
      // 次へボタンタップ
      await wrapedTap(tester, find.byIcon(Icons.navigate_next));
      await tester.pumpAndSettle();
      await wrapedTap(tester, find.text('りゅうのまい'));
      await tester.pumpAndSettle();
      expect(find.textContaining('成否'), findsOneWidget);
    });
  });
}

Future<void> wrapedTap(
  WidgetTester tester,
  FinderBase<Element> finder,
) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
  await tester.tap(finder);
}

Future<void> wrapedEnterText(
  WidgetTester tester,
  FinderBase<Element> finder,
  String text,
) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
  await tester.enterText(finder, text);
}
