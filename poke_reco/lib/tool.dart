import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:collection/collection.dart';

Future<Database> openAssetDatabase(String dbFileName) async {
  if (kIsWeb) {
    // 動作環境がWebの場合
    databaseFactory = databaseFactoryFfiWeb;
  }
  final path = join(await getDatabasesPath(), dbFileName);
  // TODO:アップデート時とかのみ消せばいい。設定から消せるとか、そういうのにしたい。
  await deleteDatabase(path);
  var exists = await databaseExists(path);

  if (!exists) {
    // アプリケーションを最初に起動したときのみ発生？
    print('Creating new copy from asset');

    if (!kIsWeb) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
    }

    // アセットからコピー
    ByteData data = await rootBundle.load(join('assets', dbFileName));
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // 書き込まれたバイトを書き込み、フラッシュする
    if (kIsWeb) {
      await databaseFactoryFfiWeb.writeDatabaseBytes(path, bytes);
    } else {
      await File(path).writeAsBytes(bytes, flush: true);
    }
  } else {
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

void selectAllMap(Map<int, bool> checkList) {
  bool existFalse = false;
  for (final e in checkList.values) {
    if (!e) existFalse = true;
  }

  for (final e in checkList.keys) {
    checkList[e] = existFalse;
  }
}

int getSelectedNum(List<bool> checkList) {
  return checkList.where((bool val) => val).length;
}

int getSelectedNumMap(Map<int, bool> checkList) {
  return checkList.values.where((bool val) => val).length;
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

// カタカナの50音に変換(小文字や濁点半濁点を消す)
String toKatakana50(String str) {
  String ret = toKatakana(str);
  return ret.replaceAllMapped(
      RegExp("[ァ-ヴ]"),
      (Match m) =>
          String.fromCharCode(toKatakana50Code(m.group(0)!.codeUnitAt(0))));
}

int toKatakana50Code(int code) {
  int ret = code;
  if (code < 'ァ'.codeUnitAt(0) || code > 'ヴ'.codeUnitAt(0)) return 0; // invalid
  if (code <= 'オ'.codeUnitAt(0)) {
    if (code % 2 == 1) ret += 1;
  } else if (code <= 'ヂ'.codeUnitAt(0)) {
    if (code % 2 == 0) ret -= 1;
  } else if (code <= 'ヅ'.codeUnitAt(0)) {
    ret = 'ツ'.codeUnitAt(0);
  } else if (code <= 'ド'.codeUnitAt(0)) {
    if (code % 2 == 1) ret -= 1;
  } else if (code <= 'ノ'.codeUnitAt(0)) {
    // nop
  } else if (code <= 'ポ'.codeUnitAt(0)) {
    ret = 'ハ'.codeUnitAt(0) + ((code - 'ハ'.codeUnitAt(0)) ~/ 3) * 3;
  } else if (code <= 'モ'.codeUnitAt(0)) {
    // nop
  } else if (code <= 'ヨ'.codeUnitAt(0)) {
    if (code % 2 == 1) ret += 1;
  } else if (code <= 'ロ'.codeUnitAt(0)) {
    // nop
  } else if (code <= 'ワ'.codeUnitAt(0)) {
    if (code % 2 == 0) ret += 1;
  } else {
    // nop
  }
  return ret;
}

// 五捨五超入
int roundOff5(double a) {
  int ret = a.floor();
  double b = a - ret;
  if (b > 0.5) return ret + 1;
  return ret;
}

/// コピー関数を必須にする
abstract class Copyable<T> {
  /// ディープコピー
  T copy();
}

/// ==演算子を有効にする
abstract class Equatable {
  const Equatable();

  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equatable &&
          runtimeType == other.runtimeType &&
          equals(props, other.props);

  @override
  int get hashCode => Object.hashAll(props);
}

bool equals(List? list1, List? list2) {
  if (identical(list1, list2)) return true;
  if (list1 == null || list2 == null) return false;
  final length = list1.length;
  if (length != list2.length) return false;

  for (var i = 0; i < length; i++) {
    final dynamic unit1 = list1[i];
    final dynamic unit2 = list2[i];

    if (unit1 is Equatable && unit2 is Equatable) {
      if (unit1 != unit2) return false;
    } else if (unit1 is Iterable || unit1 is Map) {
      if (!DeepCollectionEquality().equals(unit1, unit2)) return false;
    } else if (unit1?.runtimeType != unit2?.runtimeType) {
      return false;
    } else if (unit1 != unit2) {
      return false;
    }
  }
  return true;
}
