// 各々の場
class IndividualField {
  static const int none = 0;
  static const int toxicSpikes = 1;       // どくびし
  static const int spikes = 2;            // まきびし
  static const int stealthRock = 3;       // ステルスロック
  static const int stickyWeb = 4;         // ねばねばネット
  static const int healingWish = 5;       // いやしのねがい
  static const int lunarDance = 6;        // みかづきのまい
  static const int sandStormDamage = 7;   // すなあらしによるダメージ
  static const int futureAttack = 8;      // みらいにこうげき
  static const int futureAttackSteel = 9; // はめつのねがい
  static const int wish = 10;             // ねがいごと
  static const int grassFieldRecovery = 11;   // グラスフィールドによる回復
  static const int reflector = 12;        // リフレクター
  static const int lightScreen = 13;      // ひかりのかべ
  static const int safeGuard = 14;        // しんぴのまもり
  static const int mist = 15;             // しろいきり
  static const int tailwind = 16;         // おいかぜ
  static const int luckyChant = 17;       // おまじない
  static const int auroraVeil = 18;       // オーロラベール
  static const int gravity = 19;          // じゅうりょく
  static const int trickRoom = 20;        // トリックルーム
  static const int waterSport = 21;       // みずあそび
  static const int mudSport = 22;         // どろあそび
  static const int wonderRoom = 23;       // ワンダールーム
  static const int magicRoom = 24;        // マジックルーム
  static const int ionDeluge = 25;        // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLock = 26;        // フェアリーロック

  static const _displayNameMap = {
    0: '',
    1: 'どくびし',
    2: 'まきびし',
    3: 'ステルスロック',
    4: 'ねばねばネット',
    5: 'いやしのねがい',
    6: 'みかづきのまい',
    7: 'すなあらしによるダメージ',
    8: 'みらいにこうげき',
    9: 'はめつのねがい',
    10: 'ねがいごと',
    11: 'グラスフィールドによる回復',
    12: 'ねをはる',
    13: 'ひかりのかべ',
    14: 'しんぴのまもり',
    15: 'しろいきり',
    16: 'おいかぜ',
    17: 'おまじない',
    18: 'オーロラベール',
    19: 'じゅうりょく',
    20: 'トリックルーム',
    21: 'みずあそび',
    22: 'どろあそび',
    23: 'ワンダールーム',
    24: 'マジックルーム',
    25: 'プラズマシャワー',
    26: 'フェアリーロック',
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  IndividualField(this.id);

  IndividualField copyWith() =>
    IndividualField(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _displayNameMap[id]!;
  
  // SQLに保存された文字列からIndividualFieldをパース
  static IndividualField deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return IndividualField(elements[0])
      ..turns = elements[1]
      ..extraArg1 = elements[2];
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}