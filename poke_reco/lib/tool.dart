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