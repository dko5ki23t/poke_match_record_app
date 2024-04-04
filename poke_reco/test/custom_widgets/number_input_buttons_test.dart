import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
//import 'package:provider/provider.dart';

int confirmedNumber = 0;

Widget createHomeScreen(int initialNum) => MaterialApp(
      home: Scaffold(
        body: NumberInputButtons(
          initialNum: initialNum,
          onConfirm: (number) {
            confirmedNumber = number;
          },
        ),
      ),
    );

void main() {
  group('NumberInputButtons Widget の単体テスト', () {
    testWidgets('数字ボタン入力テスト1', (tester) async {
      await tester.pumpWidget(createHomeScreen(0));
      // 0～9のボタンが1つずつあることの確認
      for (int i = 0; i < 10; i++) {
        expect(
            find.widgetWithText(OutlinedButton, i.toString()), findsOneWidget);
      }
      // 1個のテキストフィールドがあることの確認
      expect(find.byType(TextField), findsOneWidget);
      // 各ボタンタップで値がテキストフィールドに反映されること＆max4桁入力であることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '1'));
      await tester.tap(find.widgetWithText(OutlinedButton, '2'));
      await tester.tap(find.widgetWithText(OutlinedButton, '3'));
      await tester.tap(find.widgetWithText(OutlinedButton, '4'));
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '1234'), findsOneWidget);
    });

    testWidgets('数字ボタン入力テスト2', (tester) async {
      await tester.pumpWidget(createHomeScreen(0));
      // 各ボタンタップで値がテキストフィールドに反映されること＆max4桁入力であることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.tap(find.widgetWithText(OutlinedButton, '6'));
      await tester.tap(find.widgetWithText(OutlinedButton, '7'));
      await tester.tap(find.widgetWithText(OutlinedButton, '8'));
      await tester.tap(find.widgetWithText(OutlinedButton, '9'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '5678'), findsOneWidget);
    });

    testWidgets('数字ボタン入力テスト3', (tester) async {
      await tester.pumpWidget(createHomeScreen(0));
      // 各ボタンタップで値がテキストフィールドに反映されること＆max4桁入力であることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.tap(find.widgetWithText(OutlinedButton, '9'));
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '90'), findsOneWidget);
    });

    testWidgets('削除ボタン入力テスト', (tester) async {
      await tester.pumpWidget(createHomeScreen(0));
      // 削除ボタンタップで1桁目の値が削除されてテキストフィールドに反映されることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '1'));
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.backspace));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '0'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, '1'));
      await tester.tap(find.widgetWithText(OutlinedButton, '2'));
      await tester.tap(find.widgetWithText(OutlinedButton, '3'));
      await tester.tap(find.widgetWithText(OutlinedButton, '4'));
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.backspace));
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '1235'), findsOneWidget);
    });

    testWidgets('確定ボタン入力テスト', (tester) async {
      await tester.pumpWidget(createHomeScreen(0));
      confirmedNumber = 0;
      // 確定ボタンタップでコールバック関数が呼ばれることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '1'));
      await tester.tap(find.widgetWithText(OutlinedButton, '2'));
      await tester.tap(find.widgetWithText(OutlinedButton, '3'));
      await tester.tap(find.widgetWithText(OutlinedButton, '4'));
      await tester.tap(
          find.widgetWithIcon(OutlinedButton, Icons.subdirectory_arrow_left));
      await tester.pumpAndSettle();
      expect(confirmedNumber == 1234, true);
      // 確定後新たな入力が始まることの確認
      await tester.tap(find.widgetWithText(OutlinedButton, '5'));
      await tester.tap(find.widgetWithText(OutlinedButton, '6'));
      await tester.tap(find.widgetWithText(OutlinedButton, '7'));
      await tester.tap(find.widgetWithText(OutlinedButton, '8'));
      await tester.tap(
          find.widgetWithIcon(OutlinedButton, Icons.subdirectory_arrow_left));
      await tester.pumpAndSettle();
      expect(confirmedNumber == 5678, true);
    });

    testWidgets('エッジケーステスト', (tester) async {
      await tester.pumpWidget(createHomeScreen(7890));
      confirmedNumber = 0;
      // 一度も数字入力せずに確定した場合
      await tester.tap(
          find.widgetWithIcon(OutlinedButton, Icons.subdirectory_arrow_left));
      await tester.pumpAndSettle();
      expect(confirmedNumber == 7890, true);
      // 0入力後に削除ボタンを押した場合
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.backspace));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '0'), findsOneWidget);
    });
  });
}
