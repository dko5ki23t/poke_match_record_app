import 'package:flutter_driver/driver_extension.dart';
import 'package:poke_reco/main.dart' as app;

void main() {
  // app_test.dart の方とやりとりしたい場合はこの引数にhandlerを追加
  enableFlutterDriverExtension();

  // runAppに好きなWidgetを渡しても良い
  app.main(usePrepared: true, testMode: true);
}
