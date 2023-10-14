import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> openAssetDatabase(String dbFileName) async {
  if (kIsWeb) {
    // 動作環境がWebの場合
    databaseFactory = databaseFactoryFfiWeb;
  }
  final path = join(await getDatabasesPath(), dbFileName);
  // TODO:アップデート時とかのみ消せばいい。設定から消せるとか、そういうのにしたい。
  await deleteDatabase(path);
  var exists = await databaseExists(path);

  if (!exists) {    // アプリケーションを最初に起動したときのみ発生？
    print('Creating new copy from asset');

    if (!kIsWeb) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
    }

    // アセットからコピー
    ByteData data = await rootBundle.load(join('assets', dbFileName));
    var bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // 書き込まれたバイトを書き込み、フラッシュする
    if (kIsWeb) {
      await databaseFactoryFfiWeb.writeDatabaseBytes(path, bytes);
    }
    else {
      await File(path).writeAsBytes(bytes, flush: true);
    }
  }
  else {
    print("Opening existing database");
  }

  // SQLiteのDB読み込み
  return await openDatabase(path);
}

void selectAll(List<bool> checkList) {
  bool existFalse = false;
  for (final e in checkList) {
    if (!e) existFalse = true;
  }

  for (int i = 0; i < checkList.length; i++) {
    checkList[i] = existFalse;
  }
}

int getSelectedNum(List<bool> checkList) {
  return checkList.where((bool val) => val).length;
}

void listShallowSwap(List list, int idx1, int idx2) {
  var tmp = list[idx1];
  list[idx1] = list[idx2];
  list[idx2] = tmp;
}

// 引用：https://417.run/pg/flutter-dart/hiragana-to-katakana/
String toKatakana(String str) {
  return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
    (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
}

// 五捨五超入
int roundOff5(double a) {
  int ret = a.floor();
  double b = a - ret;
  if (b > 0.5) return ret+1;
  return ret;
}
