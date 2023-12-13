// 補正

import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

// その他の補正(フォルムとか)
class BuffDebuff {
  static const int none = 0;
  static const int attack1_3 = 1;         // こうげき1.3倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↓)
  static const int defense1_3 = 2;        // ぼうぎょ1.3倍
  static const int specialAttack1_3 = 3;  // とくこう1.3倍
  static const int specialDefense1_3 = 4; // とくぼう1.3倍
  static const int speed1_5 = 5;          // すばやさ1.5倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↑)
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
  static const int noItemEffect= 38;      // もちものの効果なし   // TODO
  static const int noAbilityEffect= 39;   // 相手とくせい無視     // TODO
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
  static const int zenMode = 63;          // ダルマモード(現状SVではヒヒダルマ登場してないので実装していない)
  static const int accuracy1_1 = 64;      // 命中率1.1倍
  static const int guard2 = 65;           // ぼうぎょ2倍
  static const int bulletProof = 66;      // 弾のわざ無効
  static const int bite1_5 = 67;          // かみつきわざ威力1.5倍
  static const int freezeSkin = 68;       // ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍
  static const int bladeForm = 69;        // ブレードフォルム(現状SVでギルガルドが登場していないため未実装)
  static const int shieldForm = 70;       // シールドフォルム(現状SVでギルガルドが登場していないため未実装)
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
  static const int singleForm = 89;       // たんどくのすがた(現状SVでは登場していないため未実装)
  static const int multipleForm = 90;     // むれたすがた(現状SVでは登場していないため未実装)
  static const int transedForm = 91;      // ばけたすがた
  static const int revealedForm = 92;     // ばれたすがた
//  static const int satoshiGekkoga = 93;   // サトシゲッコウガ
  static const int tenPercentForm = 94;   // 10%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int fiftyPercentForm = 95; // 50%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int perfectForm = 96;      // パーフェクトフォルム(現状SVでジガルデが登場していないため未実装)
  static const int priorityCut = 97;      // 相手の優先度1以上わざ無効    // TODO
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
  static const int ignoreDirectAtackEffect = 173; // 直接こうげきに対して発動する効果無効
  static const int ignoreInstallingEffect = 174;  // 設置わざ効果無効
  static const int attackWithFlinch10 = 175;      // こうげき時10%ひるみ
  static const int substitute = 176;      // みがわり
  static const int rage = 177;            // わざによるダメージでこうげき1段階上昇
  static const int punchNotDirect1_1 = 178;   // パンチわざ非接触化・威力1.1倍
  static const int voiceForm = 179;       // ボイスフォルム
  static const int stepForm = 180;        // ステップフォルム
  static const int copiedMove = 181;      // わざ「ものまね」のコピーしたわざ(隠しステータス)
  static const int chargingMove = 182;    // 溜める系わざの溜め状態(隠しステータス)
  static const int recoiling = 183;       // わざの反動で動けない状態(隠しステータス)
  static const int certainlyHittedDamage2 = 184;    // 相手わざ必中・ダメージ2倍
  static const int protean = 185;         // へんげんじざい/リベロ発動済み(隠しステータス)
  static const int attack1_2 = 186;       // こうげきわざ威力1.2倍
  static const int lastLostBerry = 187;   // 最後に消費したきのみ(隠しステータス)
  static const int lastLostItem = 188;    // 最後に消費したもちもの(隠しステータス)
  static const int transform = 189;       // へんしん(extraArgに、へんしん対象のポケモンNo、turnsに、性別のid)
  static const int lastUpStatChange = 190;    // 最後に上昇したステータス変化(隠しステータス。extraArg1に、int化されたステータス変化)
  static const int lastDownStatChange = 191;  // 最後に下降したステータス変化(隠しステータス。extraArg1に、int化されたステータス変化)
  static const int changedThisTurn = 192; // このターン、交代わざやこうたい行動によってでてきたポケモンであることを表す(隠しステータス。はりこみ用)
  static const int halvedBerry = 193;     // わざを受ける前に半減系きのみを食べた(隠しステータス)
  static const int sameMoveCount = 194;   // 連続で使用しているわざのID*100+カウント(隠しステータス)

  static const Map<int, Tuple3<String, Color, int>> _nameColorTurnMap = {
    0:  Tuple3('', Colors.black, 0),
    1:  Tuple3('こうげき1.3倍', Colors.red, 0),
    2:  Tuple3('ぼうぎょ1.3倍', Colors.red, 0),
    3:  Tuple3('とくこう1.3倍', Colors.red, 0),
    4:  Tuple3('とくぼう1.3倍', Colors.red, 0),
    5:  Tuple3('すばやさ1.5倍', Colors.red, 0),
    6:  Tuple3('相手わざ命中率0.8倍', Colors.red, 0),
    7:  Tuple3('命中率1.3倍', Colors.red, 0),
    8:  Tuple3('ほのおわざ威力1.5倍', Colors.red, 0),
    9:  Tuple3('わざ追加効果発動確率2倍', Colors.red, 0),
    10: Tuple3('すばやさ2倍', Colors.red, 0),
    11: Tuple3('こうげき2倍', Colors.red, 0),
    12: Tuple3('こうげき1.5倍', Colors.red, 0),
    13: Tuple3('物理技命中率0.8倍', Colors.blue, 0),
    14: Tuple3('ポワルンのすがた', Colors.orange, 0),
    15: Tuple3('たいようのすがた', Colors.orange, 0),
    16: Tuple3('あまみずのすがた', Colors.orange, 0),
    17: Tuple3('ゆきぐものすがた', Colors.orange, 0),
    18: Tuple3('こうげき1.5倍(やけど無視)', Colors.red, 0),
    19: Tuple3('ぼうぎょ1.5倍', Colors.red, 0),
    20: Tuple3('くさわざ威力1.5倍', Colors.red, 0),
    21: Tuple3('ほのおわざ威力1.5倍', Colors.red, 0),
    22: Tuple3('みずわざ威力1.5倍', Colors.red, 0),
    23: Tuple3('むしわざ威力1.5倍', Colors.red, 0),
    24: Tuple3('相手わざ命中率0.5倍', Colors.red, 0),
    25: Tuple3('すばやさ2倍', Colors.red, 0),
    26: Tuple3('同性への威力1.25倍/異性への威力0.75倍', Colors.red, 0),
    27: Tuple3('ほのおわざ被ダメ半減計算・やけどダメ半減', Colors.red, 0),
    28: Tuple3('ほのおわざ受ける威力1.25倍', Colors.blue, 0),
    29: Tuple3('パンチわざ威力1.2倍', Colors.red, 0),
    30: Tuple3('タイプ一致ボーナス2倍', Colors.red, 0),
    31: Tuple3('すばやさ1.5倍(まひ無視)', Colors.red, 0),
    32: Tuple3('すべてのわざタイプ→ノーマル', PokeTypeColor.normal, 0),
    33: Tuple3('急所時ダメージ1.5倍', Colors.red, 0),
    34: Tuple3('相手こうげき以外ダメージ無効', Colors.red, 0),
    35: Tuple3('出すわざ/受けるわざ必中', Colors.red, 0),
    36: Tuple3('同優先度行動で最後に行動', Colors.red, 0),
    37: Tuple3('60以下威力わざの威力1.5倍', Colors.red, 0),
    38: Tuple3('もちものの効果なし', Colors.red, 0),
    39: Tuple3('相手とくせい無視', Colors.red, 0),
    40: Tuple3('急所率アップ+1', Colors.red, 0),
    41: Tuple3('急所率アップ+2', Colors.red, 0),
    42: Tuple3('急所率アップ+3', Colors.red, 0),
    43: Tuple3('相手のランク補正無視', Colors.red, 0),
    44: Tuple3('タイプ相性いまひとつ時ダメージ2倍', Colors.red, 0),
    45: Tuple3('こうかばつぐん被ダメージ0.75倍', Colors.red, 0),
    46: Tuple3('こうげき・すばやさ0.5倍', Colors.blue, 5),
    47: Tuple3('反動わざ威力1.2倍', Colors.red, 0),
    48: Tuple3('ネガフォルム', Colors.orange, 0),
    49: Tuple3('ポジフォルム', Colors.orange, 0),
    50: Tuple3('わざの追加効果なし・威力1.3倍', Colors.red, 0),
    51: Tuple3('こうげき・とくこう半減', Colors.blue, 0),
    52: Tuple3('おもさ2倍', Colors.orange, 0),
    53: Tuple3('おもさ0.5倍', Colors.orange, 0),
    54: Tuple3('受けるダメージ0.5倍', Colors.red, 0),
    55: Tuple3('ぶつりわざ威力1.5倍', Colors.red, 0),
    56: Tuple3('とくしゅわざ威力1.5倍', Colors.red, 0),
    57: Tuple3('こな・ほうし・すなあらしダメージ無効', Colors.red, 0),
    58: Tuple3('相手のへんかわざ命中率50', Colors.red, 0),
    59: Tuple3('最後行動時わざ威力1.3倍', Colors.red, 0),
    60: Tuple3('かべ・みがわり無視', Colors.red, 0),
    61: Tuple3('へんかわざ優先度+1(あくタイプには無効)', Colors.red, 0),
    62: Tuple3('いわ・じめん・はがねわざ威力1.3倍', Colors.red, 0),
    63: Tuple3('ダルマモード', Colors.orange, 0),
    64: Tuple3('命中率1.1倍', Colors.red, 0),
    65: Tuple3('ぼうぎょ2倍', Colors.red, 0),
    66: Tuple3('弾のわざ無効', Colors.red, 0),
    67: Tuple3('かみつきわざ威力1.5倍', Colors.red, 0),
    68: Tuple3('ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍', Colors.orange, 0),
    69: Tuple3('ブレードフォルム', Colors.orange, 0),
    70: Tuple3('シールドフォルム', Colors.orange, 0),
    71: Tuple3('ひこうわざ優先度+1', Colors.red, 0),
    72: Tuple3(' はどうわざ威力1.5倍', Colors.red, 0),
    73: Tuple3('ぼうぎょ1.5倍', Colors.red, 0),
    74: Tuple3('直接攻撃威力1.3倍', Colors.red, 0),
    75: Tuple3('ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍', Colors.red, 0),
    76: Tuple3('ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍', Colors.red, 0),
    77: Tuple3('あくわざ威力1.33倍', Colors.red, 0),
    78: Tuple3('フェアリーわざ威力1.33倍', Colors.red, 0),
    79: Tuple3('あくわざ威力0.75倍', Colors.blue, 0),
    80: Tuple3('フェアリーわざ威力0.75倍', Colors.blue, 0),
    81: Tuple3('どく・もうどく状態へのこうげき急所率100%', Colors.red, 0),
    82: Tuple3('こうたい後ポケモンへのこうげき・とくこう2倍', Colors.red, 0),
    83: Tuple3('相手ほのおわざこうげき・とくこう0.5倍', Colors.red, 0),
    84: Tuple3('みずわざこうげき・とくこう2倍', Colors.red, 0),
    85: Tuple3('はがねわざこうげき・とくこう1.5倍', Colors.red, 0),
    86: Tuple3('音わざタイプ→みず', Colors.orange, 0),
    87: Tuple3('かいふくわざ優先度+3', Colors.red, 0),
    88: Tuple3('ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍', Colors.red, 0),
    89: Tuple3('たんどくのすがた', Colors.orange, 0),
    90: Tuple3('むれたすがた', Colors.orange, 0),
    91: Tuple3('ばけたすがた', Colors.orange, 0),
    92: Tuple3('ばれたすがた', Colors.orange, 0),
    93: Tuple3('サトシゲッコウガ', Colors.orange, 0),
    94: Tuple3('10%フォルム', Colors.orange, 0),
    95: Tuple3('50%フォルム', Colors.orange, 0),
    96: Tuple3('パーフェクトフォルム', Colors.orange, 0),
    97: Tuple3('相手の優先度1以上わざ無効', Colors.red, 0),
    98: Tuple3('直接攻撃被ダメージ半減', Colors.red, 0),
    99: Tuple3('ほのおわざ被ダメージ2倍', Colors.blue, 0),
    100: Tuple3('こうかばつぐんわざダメージ1.25倍 ', Colors.red, 0),
    101: Tuple3('わざの対象相手が変更されない', Colors.red, 0),
    102: Tuple3('うのみのすがた', Colors.orange, 0),
    103: Tuple3('まるのみのすがた', Colors.orange, 0),
    104: Tuple3('音わざ威力1.3倍 ',Colors.red, 0),
    105: Tuple3('音わざ被ダメージ半減', Colors.red, 0),
    106: Tuple3('とくしゅわざ被ダメージ半減', Colors.red, 0),
    107: Tuple3('きのみ効果2倍', Colors.red, 0),
    108: Tuple3('アイスフェイス', Colors.orange, 0),
    109: Tuple3('ナイスフェイス', Colors.orange, 0),
    110: Tuple3('こうげきわざ威力1.3倍 ',Colors.red, 0),
    111: Tuple3('はがねわざ威力1.5倍 ',Colors.red, 0),
    112: Tuple3('わざこだわり・こうげき1.5倍 ',Colors.red, 0),
    113: Tuple3('まんぷくもよう', Colors.orange, 0),
    114: Tuple3('はらぺこもよう', Colors.orange, 0),
    115: Tuple3('直接こうげきのまもり不可', Colors.red, 0),
    116: Tuple3('でんきわざ時こうげき・とくこう1.3倍 ',Colors.red, 0),
    117: Tuple3('ドラゴンわざ時こうげき・とくこう1.5倍 ',Colors.red, 0),
    118: Tuple3('ゴーストわざ被ダメ計算時こうげき・とくこう半減', Colors.red, 0),
    119: Tuple3('いわわざ時こうげき・とくこう1.5倍 ',Colors.red, 0),
    120: Tuple3('ナイーブフォルム', Colors.orange, 0),
    121: Tuple3('マイティフォルム', Colors.orange, 0),
    122: Tuple3('とくこう0.75倍 ', Colors.blue, 0),
    123: Tuple3('ぼうぎょ0.75倍 ', Colors.blue, 0),
    124: Tuple3('こうげき0.75倍 ', Colors.blue, 0),
    125: Tuple3('とくぼう0.75倍 ', Colors.blue, 0),
    126: Tuple3('こうげき1.33倍 ', Colors.red, 0),
    127: Tuple3('とくこう1.33倍 ', Colors.red, 0),
    128: Tuple3('切るわざ威力1.5倍 ', Colors.red, 0),
    129: Tuple3('わざ威力10%アップ ', Colors.red, 0),
    130: Tuple3('わざ威力20%アップ ', Colors.red, 0),
    131: Tuple3('わざ威力30%アップ ', Colors.red, 0),
    132: Tuple3('わざ威力40%アップ ', Colors.red, 0),
    133: Tuple3('わざ威力50%アップ ', Colors.red, 0),
    134: Tuple3('へんかわざ最後に行動＆相手のとくせい無視', Colors.red, 0),
    135: Tuple3('とくぼう1.5倍 ', Colors.red, 0),
    136: Tuple3('わざこだわり・とくこう1.5倍 ', Colors.red, 0),
    137: Tuple3('とくこう2倍', Colors.red, 0),
    138: Tuple3('こうげきわざのみ選択可・とくぼう1.5倍 ', Colors.red, 0),
    139: Tuple3('とくぼう2倍', Colors.red, 0),
    140: Tuple3('わざこだわり・すばやさ1.5倍 ', Colors.red, 0),
    141: Tuple3('次に使うわざ命中率1.2倍 ', Colors.red, 0),
    142: Tuple3('当ターン行動済み相手へのわざ命中率1.2倍 ', Colors.red, 0),
    143: Tuple3('こうげきわざ時こうげき・とくこう2倍', Colors.red, 0),
    144: Tuple3('すばやさ0.5倍 ', Colors.blue, 0),
    145: Tuple3('相手わざ命中率0.9倍 ', Colors.red, 0),
    146: Tuple3('ぶつりわざ威力1.1倍 ', Colors.red, 0),
    147: Tuple3('とくしゅわざ威力1.1倍 ', Colors.red, 0),
    148: Tuple3('ノーマルわざ威力1.3倍 ', Colors.red, 0),
    149: Tuple3('ノーマルわざ威力1.2倍 ', Colors.red, 0),
    150: Tuple3('ほのおわざ威力1.2倍 ', Colors.red, 0),
    151: Tuple3('みずわざ威力1.2倍', Colors.red, 0),
    152: Tuple3('でんきわざ威力1.2倍', Colors.red, 0),
    153: Tuple3('くさわざ威力1.2倍', Colors.red, 0),
    154: Tuple3('こおりわざ威力1.2倍', Colors.red, 0),
    155: Tuple3('かくとうわざ威力1.2倍', Colors.red, 0),
    156: Tuple3('どくわざ威力1.2倍', Colors.red, 0),
    157: Tuple3('じめんわざ威力1.2倍', Colors.red, 0),
    158: Tuple3('ひこうわざ威力1.2倍', Colors.red, 0),
    159: Tuple3('エスパーわざ威力1.2倍', Colors.red, 0),
    160: Tuple3('むしわざ威力1.2倍', Colors.red, 0),
    161: Tuple3('いわわざ威力1.2倍', Colors.red, 0),
    162: Tuple3('ゴーストわざ威力1.2倍', Colors.red, 0),
    163: Tuple3('ドラゴンわざ威力1.2倍', Colors.red, 0),
    164: Tuple3('あくわざ威力1.2倍', Colors.red, 0),
    165: Tuple3('はがねわざ威力1.2倍', Colors.red, 0),
    166: Tuple3('フェアリーわざ威力1.2倍', Colors.red, 0),
    167: Tuple3('わざ威力1.2倍', Colors.red, 0),
    168: Tuple3('こうげきわざダメージ1.3倍・自身HP1/10ダメージ', Colors.red, 0),
    169: Tuple3('こうかばつぐん時ダメージ1.2倍', Colors.red, 0),
    170: Tuple3('同じわざ連続使用ごとにダメージ+20%(MAX 200%)', Colors.red, 0),
    171: Tuple3('バインド与ダメージ→最大HP1/6', Colors.red, 0),
    172: Tuple3('すなあらしダメージ・こな・ほうし無効', Colors.red, 0),
    173: Tuple3('直接こうげきに対して発動する効果無効', Colors.red, 0),
    174: Tuple3('設置わざ効果無効', Colors.red, 0),
    175: Tuple3('こうげき時10%ひるみ', Colors.red, 0),
    176: Tuple3('みがわり', Colors.green, 0),
    177: Tuple3('わざによるダメージでこうげき1段階上昇', Colors.red, 0),
    178: Tuple3('パンチわざ非接触化・威力1.1倍', Colors.red, 0),
    179: Tuple3('ボイスフォルム', Colors.orange, 0),
    180: Tuple3('ステップフォルム', Colors.orange, 0),
    181: Tuple3('', Colors.white, 0),
    182: Tuple3('', Colors.white, 0),
    183: Tuple3('', Colors.white, 0),
    184: Tuple3('相手わざ必中・ダメージ2倍', Colors.blue, 0),
    186: Tuple3('こうげきわざ威力1.2倍', Colors.red, 0),
    189: Tuple3('へんしん', Colors.orange, 0),
  };

  final int id;
  int turns = 0;        // 経過ターン
  int extraArg1 = 0;    // 

  BuffDebuff(this.id);

  BuffDebuff copyWith() =>
    BuffDebuff(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName => _nameColorTurnMap[id]!.item3 > 0 ? '${_nameColorTurnMap[id]!.item1} ($turns/?)' : _nameColorTurnMap[id]!.item1;
  Color get bgColor => _nameColorTurnMap[id]!.item2;
  
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
