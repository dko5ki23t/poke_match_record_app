import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/main.dart';

Widget createHomeScreen() => ChangeNotifierProvider(
      create: (context) => MyAppState(context, null),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );

void main() {
  group('BattleTile Widgetの単体テスト', () {
    testWidgets('TODO', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.text('表示できる対戦がありません。'), findsOneWidget);
    });
  });
}