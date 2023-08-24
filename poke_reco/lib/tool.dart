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

// 引用：https://417.run/pg/flutter-dart/hiragana-to-katakana/
String toKatakana(String str) {
  return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
    (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
}