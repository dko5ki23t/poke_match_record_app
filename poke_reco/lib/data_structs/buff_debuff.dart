import 'package:flutter/material.dart';

// その他の補正(フォルムとか)
class BuffDebuff {
  static const int none = 0;
  static const int attack1_3 = 1;         // こうげき1.3倍
  static const int defense1_3 = 2;        // ぼうぎょ1.3倍
  static const int specialAttack1_3 = 3;  // とくこう1.3倍
  static const int specialDefense1_3 = 4; // とくぼう1.3倍
  static const int speed1_5 = 5;          // すばやさ1.5倍
  static const int yourAccuracy0_8 = 6;   // 相手わざ命中率0.8倍
  static const int accuracy1_3 = 7;       // 命中率1.3倍
  static const int flashFired = 8;        // もらいび状態（ほのおわざ1.5倍）、重複不可
  static const int additionalEffect2 = 9; // わざ追加効果発動確率2倍
  static const int speed2 = 10;           // すばやさ2倍
  static const int attack2 = 11;          // こうげき2倍
  static const int attack1_5 = 12;        // こうげき1.5倍
  static const int physicalAccuracy0_8 = 13;      // 物理技命中率0.8倍
  static const int powalenNormal = 14;    // ポワルンのすがた
  static const int powalenSun = 15;       // たいようのすがた
  static const int powalenRain = 16;      // あまみずのすがた
  static const int powalenSnow = 17;      // ゆきぐものすがた
  static const int attack1_5WithIgnBurn = 18;   // こうげき1.5倍(やけど無視)
  static const int defense1_5 = 19;       // ぼうぎょ1.5倍
  static const int overgrow = 20;         // くさわざ威力1.5倍(しんりょくによる)、重複不可
  static const int blaze = 21;            // ほのおわざ威力1.5倍(もうかによる)、重複不可
  static const int torrent = 22;          // みずわざ威力1.5倍(げきりゅうによる)、重複不可
  static const int swarm = 23;            // むしわざ威力1.5倍(むしのしらせによる)、重複不可
  static const int yourAccuracy0_5 = 24;  // 相手わざ命中率0.5倍(ちどりあしによる)、重複不可
  static const int unburden = 25;         // すばやさ2倍(かるわざによる)、重複不可
  static const int opponentSex1_5 = 26;   // 同性への威力1.25倍/異性への威力0.75倍
  static const int heatproof = 27;        // ほのおわざ被ダメ半減計算・やけどダメ半減(たいねつ)
  static const int drySkin = 28;          // ほのおわざ受ける威力1.25倍
  static const int punch1_2 = 29;         // パンチわざ威力1.2倍
  static const int typeBonus2 = 30;       // タイプ一致ボーナス2倍
  static const int speed1_5IgnPara = 31;  // すばやさ1.5倍(まひ無視)
  static const int normalize = 32;        // すべてのわざタイプ→ノーマル
  static const int sniper = 33;           // 急所時ダメージ1.5倍
  static const int magicGuard = 34;       // 相手こうげき以外ダメージ無効
  static const int noGuard = 35;          // 出すわざ/受けるわざ必中
  static const int stall = 36;            // 同優先度行動で最後に行動
  static const int technician = 37;       // 60以下威力わざの威力1.5倍
  static const int noItemEffect= 38;      // もちものの効果なし
  static const int noAbilityEffect= 39;   // 相手とくせい無視
  static const int vital1 = 40;           // 急所率+1
  static const int vital2 = 41;           // 急所率+2
  static const int vital3 = 42;           // 急所率+3
  static const int ignoreRank = 43;       // 相手のランク補正無視
  static const int notGoodType2 = 44;     // タイプ相性いまひとつ時ダメージ2倍
  static const int greatDamaged0_75 = 45; // こうかばつぐん被ダメージ0.75倍
  static const int attackSpeed0_5 = 46;   // こうげき・すばやさ0.5倍
  static const int recoil1_2 = 47;        // 反動わざ威力1.2倍
  static const int negaForm = 48;         // チェリムのネガフォルム
  static const int posiForm = 49;         // チェリムのポジフォルム
  static const int sheerForce = 50;       // わざの追加効果なし・威力1.3倍
  static const int defeatist = 51;        // こうげき・とくこう半減(よわきによる)、重複不可
  static const int heavy2 = 52;           // おもさ2倍
  static const int heavy0_5 = 53;         // おもさ0.5倍
  static const int damaged0_5 = 54;       // 受けるダメージ0.5倍
  static const int physical1_5 = 55;      // ぶつりわざ威力1.5倍
  static const int special1_5 = 56;       // とくしゅわざ威力1.5倍
  static const int overcoat = 57;         // こな・ほうし・すなあらしダメージ無効
  static const int yourStatusAccuracy50 = 58;   // 相手のへんかわざ命中率50
  static const int analytic = 59;         // 最後行動時わざ威力1.3倍
  static const int ignoreWall = 60;       // かべ・みがわり無視
  static const int prankster = 61;        // へんかわざ優先度+1(あくタイプには無効)
  static const int rockGroundSteel1_3 = 62; // いわ・じめん・はがねわざ威力1.3倍
  static const int zenMode = 63;          // ダルマモード
  static const int accuracy1_1 = 64;      // 命中率1.1倍
  static const int guard2 = 65;           // ぼうぎょ2倍
  static const int bulletProof = 66;      // 弾のわざ無効
  static const int bite1_5 = 67;          // かみつきわざ威力1.5倍
  static const int freezeSkin = 68;       // ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍
  static const int bladeForm = 69;        // ブレードフォルム
  static const int shieldForm = 70;       // シールドフォルム
  static const int galeWings = 71;        // ひこうわざ優先度+1
  static const int wave1_5 = 72;          // はどうわざ威力1.5倍
  static const int guard1_5 = 73;         // ぼうぎょ1.5倍
  static const int directAttack1_3 = 74;  // 直接攻撃威力1.3倍
  static const int fairySkin = 75;        // ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍
  static const int airSkin = 76;          // ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍
  static const int darkAura = 77;         // あくわざ威力1.33倍
  static const int fairyAura = 78;        // フェアリーわざ威力1.33倍
  static const int antiDarkAura = 79;     // あくわざ威力0.75倍
  static const int antiFairyAura = 80;    // フェアリーわざ威力0.75倍
  static const int merciless = 81;        // どく・もうどく状態へのこうげき急所率100%
  static const int change2 = 82;          // こうたい後ポケモンへのこうげき・とくこう2倍
  static const int waterBubble1 = 83;     // 相手ほのおわざこうげき・とくこう0.5倍
  static const int waterBubble2 = 84;     // みずわざこうげき・とくこう2倍
  static const int steelWorker = 85;      // はがねわざこうげき・とくこう1.5倍
  static const int liquidVoice = 86;      // 音わざタイプ→みず
  static const int healingShift = 87;     // かいふくわざ優先度+3
  static const int electricSkin = 88;     // ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍
  static const int singleForm = 89;       // たんどくのすがた
  static const int multipleForm = 90;     // むれたすがた
  static const int transedForm = 91;      // ばけたすがた
  static const int revealedForm = 92;     // ばれたすがた
  static const int satoshiGekkoga = 93;   // サトシゲッコウガ
  static const int tenPercentForm = 94;   // 10%フォルム
  static const int fiftyPercentForm = 95; // 50%フォルム
  static const int perfectForm = 96;      // パーフェクトフォルム
  static const int priorityCut = 97;      // 相手の優先度1以上わざ無効
  static const int directAttackedDamage0_5 = 98;  // 直接攻撃被ダメージ半減
  static const int fireAttackedDamage2 = 99;  // ほのおわざ被ダメージ2倍
  static const int greatDamage1_25 = 100; // こうかばつぐんわざダメージ1.25倍
  static const int targetRock = 101;      // わざの対象相手が変更されない
  static const int unomiForm = 102;       // うのみのすがた
  static const int marunomiForm = 103;    // まるのみのすがた
  static const int sound1_3 = 104;        // 音わざ威力1.3倍
  static const int soundedDamage0_5 = 105;  // 音わざ被ダメージ半減
  static const int specialDamaged0_5 = 106; // とくしゅわざ被ダメージ半減
  static const int nuts2 = 107;           // きのみ効果2倍
  static const int iceFace = 108;         // アイスフェイス
  static const int niceFace = 109;        // ナイスフェイス
  static const int attackMove1_3 = 110;   // こうげきわざ威力1.3倍
  static const int steel1_5 = 111;        // はがねわざ威力1.5倍
  static const int gorimuchu = 112;       // わざこだわり・こうげき1.5倍
  static const int manpukuForm = 113;     // まんぷくもよう
  static const int harapekoForm = 114;    // はらぺこもよう
  static const int directAttackIgnoreGurad = 115;   // まもり不可の直接こうげき
  static const int electric1_3 = 116;     // でんきわざ時こうげき・とくこう1.3倍
  static const int dragon1_5 = 117;       // ドラゴンわざ時こうげき・とくこう1.5倍
  static const int ghosted0_5 = 118;      // ゴーストわざ被ダメ計算時こうげき・とくこう半減
  static const int rock1_5 = 119;         // いわわざ時こうげき・とくこう1.5倍
  static const int naiveForm = 120;       // ナイーブフォルム
  static const int mightyForm = 121;      // マイティフォルム
  static const int specialAttack0_75 = 122;   // とくこう0.75倍
  static const int defense0_75 = 123;     // ぼうぎょ0.75倍
  static const int attack0_75 = 124;      // こうげき0.75倍
  static const int specialDefense0_75 = 125;  // とくぼう0.75倍
  static const int attack1_33 = 126;      // こうげき1.33倍
  static const int specialAttack1_33 = 127;   // とくこう1.33倍
  static const int cut1_5 = 128;          // 切るわざ威力1.5倍
  static const int power10 = 129;         // わざ威力10%アップ
  static const int power20 = 130;         // わざ威力20%アップ
  static const int power30 = 131;         // わざ威力30%アップ
  static const int power40 = 132;         // わざ威力40%アップ
  static const int power50 = 133;         // わざ威力50%アップ
  static const int myceliumMight = 134;   // へんかわざ最後に行動＆相手のとくせい無視
  static const int specialDefense1_5 = 135;   // とくぼう1.5倍
  static const int choiceSpecs = 136;     // わざこだわり・とくこう1.5倍
  static const int specialAttack2 = 137;  // とくこう2倍
  static const int onlyAttackSpecialDefense1_5 = 138;   // こうげきわざのみ選択可・とくぼう1.5倍
  static const int specialDefense2 = 139; // とくぼう2倍
  static const int choiceScarf = 140;     // わざこだわり・すばやさ1.5倍
  static const int onceAccuracy1_2 = 141;      // 次に使うわざ命中率1.2倍
  static const int movedAccuracy1_2 = 142;     // 当ターン行動済み相手へのわざ命中率1.2倍
  static const int attackMove2 = 143;        // こうげきわざ時こうげき・とくこう2倍
  static const int speed0_5 = 144;           // すばやさ0.5倍
  static const int yourAccuracy0_9 = 145; // 相手わざ命中率0.9倍
  static const int physical1_1 = 146;     // ぶつりわざ威力1.1倍
  static const int special1_1 = 147;      // とくしゅわざ威力1.1倍
  static const int onceNormalAttack1_3 = 148;   // ノーマルわざ威力1.3倍
  static const int normalAttack1_2 = 149; // ノーマルわざ威力1.2倍
  static const int fireAttack1_2 = 150;   // ほのおわざ威力1.2倍
  static const int waterAttack1_2 = 151;  // みずわざ威力1.2倍
  static const int electricAttack1_2 = 152;   // でんきわざ威力1.2倍
  static const int grassAttack1_2 = 153;  // くさわざ威力1.2倍
  static const int iceAttack1_2 = 154;    // こおりわざ威力1.2倍
  static const int fightAttack1_2 = 155;  // かくとうわざ威力1.2倍
  static const int poisonAttack1_2 = 156; // どくわざ威力1.2倍
  static const int groundAttack1_2 = 157; // じめんわざ威力1.2倍
  static const int airAttack1_2 = 158;    // ひこうわざ威力1.2倍
  static const int psycoAttack1_2 = 159;  // エスパーわざ威力1.2倍
  static const int bugAttack1_2 = 160;    // むしわざ威力1.2倍
  static const int rockAttack1_2 = 161;   // いわわざ威力1.2倍
  static const int ghostAttack1_2 = 162;  // ゴーストわざ威力1.2倍
  static const int dragonAttack1_2 = 163; // ドラゴンわざ威力1.2倍
  static const int evilAttack1_2 = 164;   // あくわざ威力1.2倍
  static const int steelAttack1_2 = 165;  // はがねわざ威力1.2倍
  static const int fairyAttack1_2 = 166;  // フェアリーわざ威力1.2倍
  static const int moveAttack1_2 = 167;   // わざ威力1.2倍
  static const int lifeOrb = 168;         // こうげきわざダメージ1.3倍・自身HP1/10ダメージ
  static const int greatDamage1_2 = 169;  // こうかばつぐん時ダメージ1.2倍
  static const int continuousMoveDamageInc0_2 = 170;  // 同じわざ連続使用ごとにダメージ+20%(MAX 200%)
  static const int bindDamage1_6 = 171;   // バインド与ダメージ→最大HP1/6
  static const int ignorePowder = 172;    // すなあらしダメージ・こな・ほうし無効
  static const int ignoreDirectAtackEffect = 173; // 直接こうげきに対して発動する効果無効
  static const int ignoreInstallingEffect = 174;  // 設置わざ効果無効
  static const int attackWithFlinch10 = 175;      // こうげき時10%ひるみ
  static const int substitute = 176;      // みがわり
  static const int rage = 177;            // わざによるダメージでこうげき1段階上昇
  static const int punchNotDirect1_1 = 178;   // パンチわざ非接触化・威力1.1倍
  static const int voiceForm = 179;       // ボイスフォルム
  static const int stepForm = 180;        // ステップフォルム

  static const _displayNameMap = {
    0:  '',
    1:  'こうげき1.3倍',
    2:  'ぼうぎょ1.3倍',
    3:  'とくこう1.3倍',
    4:  'とくぼう1.3倍',
    5:  'すばやさ1.5倍',
    6:  '相手わざ命中率0.8倍',
    7:  '命中率1.3倍',
    8:  'ほのおわざ威力1.5倍',
    9:  'わざ追加効果発動確率2倍',
    10: 'すばやさ2倍',
    11: 'こうげき2倍',
    12: 'こうげき1.5倍',
    13: '物理技命中率0.8倍',
    14: 'ポワルンのすがた',
    15: 'たいようのすがた',
    16: 'あまみずのすがた',
    17: 'ゆきぐものすがた',
    18: 'こうげき1.5倍(やけど無視)',
    19: 'ぼうぎょ1.5倍',
    20: 'くさわざ威力1.5倍',
    21: 'ほのおわざ威力1.5倍',
    22: 'みずわざ威力1.5倍',
    23: 'むしわざ威力1.5倍',
    24: '相手わざ命中率0.5倍',
    25: 'すばやさ2倍',
    26: '同性への威力1.25倍/異性への威力0.75倍',
    27: 'ほのおわざ被ダメ半減計算・やけどダメ半減',
    28: 'ほのおわざ受ける威力1.25倍',
    29: 'パンチわざ威力1.2倍',
    30: 'タイプ一致ボーナス2倍',
    31: 'すばやさ1.5倍(まひ無視)',
    32: 'すべてのわざタイプ→ノーマル',
    33: '急所時ダメージ1.5倍',
    34: '相手こうげき以外ダメージ無効',
    35: '出すわざ/受けるわざ必中',
    36: '同優先度行動で最後に行動',
    37: '60以下威力わざの威力1.5倍',
    38: 'もちものの効果なし',
    39: '相手とくせい無視',
    40: '急所率アップ+1',
    41: '急所率アップ+2',
    42: '急所率アップ+3',
    43: '相手のランク補正無視',
    44: 'タイプ相性いまひとつ時ダメージ2倍',
    45: 'こうかばつぐん被ダメージ0.75倍',
    46: 'こうげき・すばやさ0.5倍',
    47: '反動わざ威力1.2倍',
    48: 'ネガフォルム',
    49: 'ポジフォルム',
    50: 'わざの追加効果なし・威力1.3倍',
    51: 'こうげき・とくこう半減',
    52: 'おもさ2倍',
    53: 'おもさ0.5倍',
    54: '受けるダメージ0.5倍',
    55: 'ぶつりわざ威力1.5倍',
    56: 'とくしゅわざ威力1.5倍',
    57: 'こな・ほうし・すなあらしダメージ無効',
    58: '相手のへんかわざ命中率50',
    59: '最後行動時わざ威力1.3倍',
    60: 'かべ・みがわり無視',
    61: 'へんかわざ優先度+1(あくタイプには無効)',
    62: 'いわ・じめん・はがねわざ威力1.3倍',
    63: 'ダルマモード',
    64: '命中率1.1倍',
    65: 'ぼうぎょ2倍',
    66: '弾のわざ無効',
    67: 'かみつきわざ威力1.5倍',
    68: 'ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍',
    69: 'ブレードフォルム',
    70: 'シールドフォルム',
    71: 'ひこうわざ優先度+1',
    72: ' はどうわざ威力1.5倍',
    73: 'ぼうぎょ1.5倍',
    74: '直接攻撃威力1.3倍',
    75: 'ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍',
    76: 'ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍',
    77: 'あくわざ威力1.33倍',
    78: 'フェアリーわざ威力1.33倍',
    79: 'あくわざ威力0.75倍',
    80: 'フェアリーわざ威力0.75倍',
    81: 'どく・もうどく状態へのこうげき急所率100%',
    82: 'こうたい後ポケモンへのこうげき・とくこう2倍',
    83: '相手ほのおわざこうげき・とくこう0.5倍',
    84: 'みずわざこうげき・とくこう2倍',
    85: 'はがねわざこうげき・とくこう1.5倍',
    86: '音わざタイプ→みず',
    87: 'かいふくわざ優先度+3',
    88: 'ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍',
    89: 'たんどくのすがた',
    90: 'むれたすがた',
    91: 'ばけたすがた',
    92: 'ばれたすがた',
    93: 'サトシゲッコウガ',
    94: '10%フォルム',
    95: '50%フォルム',
    96: 'パーフェクトフォルム',
    97: '相手の優先度1以上わざ無効',
    98: '直接攻撃被ダメージ半減',
    99: 'ほのおわざ被ダメージ2倍',
    100: 'こうかばつぐんわざダメージ1.25倍',
    101: 'わざの対象相手が変更されない',
    102: 'うのみのすがた',
    103: 'まるのみのすがた',
    104: '音わざ威力1.3倍',
    105: '音わざ被ダメージ半減',
    106: 'とくしゅわざ被ダメージ半減',
    107: 'きのみ効果2倍',
    108: 'アイスフェイス',
    109: 'ナイスフェイス',
    110: 'こうげきわざ威力1.3倍',
    111: 'はがねわざ威力1.5倍',
    112: 'わざこだわり・こうげき1.5倍',
    113: 'まんぷくもよう',
    114: 'はらぺこもよう',
    115: '直接こうげきのまもり不可',
    116: 'でんきわざ時こうげき・とくこう1.3倍',
    117: 'ドラゴンわざ時こうげき・とくこう1.5倍',
    118: 'ゴーストわざ被ダメ計算時こうげき・とくこう半減',
    119: 'いわわざ時こうげき・とくこう1.5倍',
    120: 'ナイーブフォルム',
    121: 'マイティフォルム',
    122: 'とくこう0.75倍',
    123: 'ぼうぎょ0.75倍',
    124: 'こうげき0.75倍',
    125: 'とくぼう0.75倍',
    126: 'こうげき1.33倍',
    127: 'とくこう1.33倍',
    128: '切るわざ威力1.5倍',
    129: 'わざ威力10%アップ',
    130: 'わざ威力20%アップ',
    131: 'わざ威力30%アップ',
    132: 'わざ威力40%アップ',
    133: 'わざ威力50%アップ',
    134: 'へんかわざ最後に行動＆相手のとくせい無視',
    135: 'とくぼう1.5倍',
    136: 'わざこだわり・とくこう1.5倍',
    137: 'とくこう2倍',
    138: 'こうげきわざのみ選択可・とくぼう1.5倍',
    139: 'とくぼう2倍',
    140: 'わざこだわり・すばやさ1.5倍',
    141: '次に使うわざ命中率1.2倍',
    142: '当ターン行動済み相手へのわざ命中率1.2倍',
    143: 'こうげきわざ時こうげき・とくこう2倍',
    144: 'すばやさ0.5倍',
    145: '相手わざ命中率0.9倍',
    146: 'ぶつりわざ威力1.1倍',
    147: 'とくしゅわざ威力1.1倍',
    148: 'ノーマルわざ威力1.3倍',
    149: 'ノーマルわざ威力1.2倍',
    150: 'ほのおわざ威力1.2倍',
    151: 'みずわざ威力1.2倍',
    152: 'でんきわざ威力1.2倍',
    153: 'くさわざ威力1.2倍',
    154: 'こおりわざ威力1.2倍',
    155: 'かくとうわざ威力1.2倍',
    156: 'どくわざ威力1.2倍',
    157: 'じめんわざ威力1.2倍',
    158: 'ひこうわざ威力1.2倍',
    159: 'エスパーわざ威力1.2倍',
    160: 'むしわざ威力1.2倍',
    161: 'いわわざ威力1.2倍',
    162: 'ゴーストわざ威力1.2倍',
    163: 'ドラゴンわざ威力1.2倍',
    164: 'あくわざ威力1.2倍',
    165: 'はがねわざ威力1.2倍',
    166: 'フェアリーわざ威力1.2倍',
    167: 'わざ威力1.2倍',
    168: 'こうげきわざダメージ1.3倍・自身HP1/10ダメージ',
    169: 'こうかばつぐん時ダメージ1.2倍',
    170: '同じわざ連続使用ごとにダメージ+20%(MAX 200%)',
    171: 'バインド与ダメージ→最大HP1/6',
    172: 'すなあらしダメージ・こな・ほうし無効',
    173: '直接こうげきに対して発動する効果無効',
    174: '設置わざ効果無効',
    175: 'こうげき時10%ひるみ',
    176: 'みがわり',
    177: 'わざによるダメージでこうげき1段階上昇',
    178: 'パンチわざ非接触化・威力1.1倍',
    179: 'ボイスフォルム',
    180: 'ステップフォルム',
  };

  static const _bgColorMap = {
    0:  Colors.black,
    1:  Colors.red,
    2:  Colors.red,
    3:  Colors.red,
    4:  Colors.red,
    5:  Colors.red,
    6:  Colors.red,
    7:  Colors.red,
    8:  Colors.red,
    9:  Colors.red,
    10: Colors.red,
    11: Colors.red,
    12: Colors.red,
    13: Colors.blue,
    14: Colors.orange,
    15: Colors.orange,
    16: Colors.orange,
    17: Colors.orange,
    18: Colors.red,
    19: Colors.red,
    20: Colors.red,
    21: Colors.red,
    22: Colors.red,
    23: Colors.red,
    24: Colors.red,
    25: Colors.red,
    26: Colors.red,
    27: Colors.red,
    28: Colors.blue,
    29: Colors.red,
    30: Colors.red,
    31: Colors.red,
    32: Color(0xffaeaeae),
    33: Colors.red,
    34: Colors.red,
    35: Colors.red,
    36: Colors.red,
    37: Colors.red,
    38: Colors.red,
    39: Colors.red,
    40: Colors.red,
    41: Colors.red,
    42: Colors.red,
    43: Colors.red,
    44: Colors.red,
    45: Colors.red,
    46: Colors.blue,
    47: Colors.red,
    48: Colors.orange,
    49: Colors.orange,
    50: Colors.red,
    51: Colors.blue,
    52: Colors.orange,
    53: Colors.orange,
    54: Colors.red,
    55: Colors.red,
    56: Colors.red,
    57: Colors.red,
    58: Colors.red,
    59: Colors.red,
    60: Colors.red,
    61: Colors.red,
    62: Colors.red,
    63: Colors.orange,
    64: Colors.red,
    65: Colors.red,
    66: Colors.red,
    67: Colors.red,
    68: Colors.orange,
    69: Colors.orange,
    70: Colors.orange,
    71: Colors.red,
    72: Colors.red,
    73: Colors.red,
    74: Colors.red,
    75: Colors.red,
    76: Colors.red,
    77: Colors.red,
    78: Colors.red,
    79: Colors.blue,
    80: Colors.blue,
    81: Colors.red,
    82: Colors.red,
    83: Colors.red,
    84: Colors.red,
    85: Colors.red,
    86: Colors.orange,
    87: Colors.red,
    88: Colors.red,
    89: Colors.orange,
    90: Colors.orange,
    91: Colors.orange,
    92: Colors.orange,
    93: Colors.orange,
    94: Colors.orange,
    95: Colors.orange,
    96: Colors.orange,
    97: Colors.red,
    98: Colors.red,
    99: Colors.blue,
    100: Colors.red,
    101: Colors.red,
    102: Colors.orange,
    103: Colors.orange,
    104: Colors.red,
    105: Colors.red,
    106: Colors.red,
    107: Colors.red,
    108: Colors.orange,
    109: Colors.orange,
    110: Colors.red,
    111: Colors.red,
    112: Colors.red,
    113: Colors.orange,
    114: Colors.orange,
    115: Colors.red,
    116: Colors.red,
    117: Colors.red,
    118: Colors.red,
    119: Colors.red,
    120: Colors.orange,
    121: Colors.orange,
    122: Colors.blue,
    123: Colors.blue,
    124: Colors.blue,
    125: Colors.blue,
    126: Colors.red,
    127: Colors.red,
    128: Colors.red,
    129: Colors.red,
    130: Colors.red,
    131: Colors.red,
    132: Colors.red,
    133: Colors.red,
    134: Colors.red,
    135: Colors.red,
    136: Colors.red,
    137: Colors.red,
    138: Colors.red,
    139: Colors.red,
    140: Colors.red,
    141: Colors.red,
    142: Colors.red,
    143: Colors.red,
    144: Colors.blue,
    145: Colors.red,
    146: Colors.red,
    147: Colors.red,
    148: Colors.red,
    150: Colors.red,
    151: Colors.red,
    152: Colors.red,
    153: Colors.red,
    154: Colors.red,
    155: Colors.red,
    156: Colors.red,
    157: Colors.red,
    158: Colors.red,
    159: Colors.red,
    160: Colors.red,
    161: Colors.red,
    162: Colors.red,
    163: Colors.red,
    164: Colors.red,
    165: Colors.red,
    166: Colors.red,
    167: Colors.red,
    168: Colors.red,
    169: Colors.red,
    170: Colors.red,
    171: Colors.red,
    172: Colors.red,
    173: Colors.red,
    174: Colors.red,
    175: Colors.red,
    176: Colors.green,
    177: Colors.red,
    178: Colors.red,
    179: Colors.orange,
    180: Colors.orange,
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  BuffDebuff(this.id);

  BuffDebuff copyWith() =>
    BuffDebuff(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _displayNameMap[id]!;
  Color get bgColor => _bgColorMap[id]!;
  
  // SQLに保存された文字列からBuffDebuffをパース
  static BuffDebuff deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return BuffDebuff(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}
