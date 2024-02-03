import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver? driver;

  setUpAll(() async {
    driver =
        await FlutterDriver.connect(dartVmServiceUrl: 'http://localhost:8888/')
            .timeout(Duration(seconds: 10));
  });

  tearDownAll(() async {
    if (driver != null) {
      await driver!.close();
    }
  });

//  test('the button changes the text from hogehoge to fugafuga', () async {
//    expect(await driver!.getText(find.byValueKey('text')), equals('hogehoge'));
//    driver!.tap(find.byValueKey('button'));
//    expect(await driver!.getText(find.byValueKey('text')), equals('fugafuga'));
//  });

  group('統合テスト(もこうの実況を記録)', () {
    test('パーモット戦', () async {
      //await tester.pumpWidget(MyApp(initialLocale: locale));
      //await tester.pump(Duration(seconds: 5));
      // TODO
      // ポケモンタブボタンタップ
      //await tester.tap(find.text('ポケモン'));
      //await tester.pumpAndSettle();
      //expect(find.text('もこパモ'), findsWidgets);
      // 追加ボタン(+)タップ
      await driver!.tap(find.byType('FloatingActionButton'));
/*
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
*/
    });
  });
}
