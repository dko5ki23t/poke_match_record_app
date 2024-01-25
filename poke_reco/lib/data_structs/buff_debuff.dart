// 補正

import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

// その他の補正(フォルムとか)
class BuffDebuff extends Equatable implements Copyable {
  static const int none = 0;
  static const int attack1_3 =
      1; // こうげき1.3倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↓)
  static const int defense1_3 = 2; // ぼうぎょ1.3倍
  static const int specialAttack1_3 = 3; // とくこう1.3倍
  static const int specialDefense1_3 = 4; // とくぼう1.3倍
  static const int speed1_5 =
      5; // すばやさ1.5倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↑)
  static const int yourAccuracy0_8 = 6; // 相手わざ命中率0.8倍
  static const int accuracy1_3 = 7; // 命中率1.3倍
  static const int flashFired = 8; // もらいび状態（ほのおわざ1.5倍）、重複不可
  static const int additionalEffect2 = 9; // わざ追加効果発動確率2倍
  static const int speed2 = 10; // すばやさ2倍
  static const int attack2 = 11; // こうげき2倍
  static const int attack1_5 = 12; // こうげき1.5倍
  static const int physicalAccuracy0_8 = 13; // 物理技命中率0.8倍
  static const int powalenNormal = 14; // ポワルンのすがた
  static const int powalenSun = 15; // たいようのすがた
  static const int powalenRain = 16; // あまみずのすがた
  static const int powalenSnow = 17; // ゆきぐものすがた
  static const int attack1_5WithIgnBurn = 18; // こうげき1.5倍(やけど無視)
  static const int defense1_5 = 19; // ぼうぎょ1.5倍
  static const int overgrow = 20; // くさわざ威力1.5倍(しんりょくによる)、重複不可
  static const int blaze = 21; // ほのおわざ威力1.5倍(もうかによる)、重複不可
  static const int torrent = 22; // みずわざ威力1.5倍(げきりゅうによる)、重複不可
  static const int swarm = 23; // むしわざ威力1.5倍(むしのしらせによる)、重複不可
  static const int yourAccuracy0_5 = 24; // 相手わざ命中率0.5倍(ちどりあしによる)、重複不可
  static const int unburden = 25; // すばやさ2倍(かるわざによる)、重複不可
  static const int opponentSex1_5 = 26; // 同性への威力1.25倍/異性への威力0.75倍
  static const int heatproof = 27; // ほのおわざ被ダメ半減計算・やけどダメ半減(たいねつ)
  static const int drySkin = 28; // ほのおわざ受ける威力1.25倍
  static const int punch1_2 = 29; // パンチわざ威力1.2倍
  static const int typeBonus2 = 30; // タイプ一致ボーナス2倍
  static const int speed1_5IgnPara = 31; // すばやさ1.5倍(まひ無視)
  static const int normalize = 32; // すべてのわざタイプ→ノーマル
  static const int sniper = 33; // 急所時ダメージ1.5倍
  static const int magicGuard = 34; // 相手こうげき以外ダメージ無効
  static const int noGuard = 35; // 出すわざ/受けるわざ必中
  static const int stall = 36; // 同優先度行動で最後に行動
  static const int technician = 37; // 60以下威力わざの威力1.5倍
  static const int noItemEffect = 38; // もちものの効果なし
  static const int noAbilityEffect = 39; // 相手とくせい無視
  static const int vital1 = 40; // 急所率+1
  static const int vital2 = 41; // 急所率+2
  static const int vital3 = 42; // 急所率+3
  static const int ignoreRank = 43; // 相手のランク補正無視
  static const int notGoodType2 = 44; // タイプ相性いまひとつ時ダメージ2倍
  static const int greatDamaged0_75 = 45; // こうかばつぐん被ダメージ0.75倍
  static const int attackSpeed0_5 = 46; // こうげき・すばやさ0.5倍
  static const int recoil1_2 = 47; // 反動わざ威力1.2倍
  static const int negaForm = 48; // チェリムのネガフォルム
  static const int posiForm = 49; // チェリムのポジフォルム
  static const int sheerForce = 50; // わざの追加効果なし・威力1.3倍
  static const int defeatist = 51; // こうげき・とくこう半減(よわきによる)、重複不可
  static const int heavy2 = 52; // おもさ2倍
  static const int heavy0_5 = 53; // おもさ0.5倍
  static const int damaged0_5 = 54; // 受けるダメージ0.5倍
  static const int physical1_5 = 55; // ぶつりわざ威力1.5倍
  static const int special1_5 = 56; // とくしゅわざ威力1.5倍
  static const int overcoat = 57; // こな・ほうし・すなあらしダメージ無効
  static const int yourStatusAccuracy50 = 58; // 相手のへんかわざ命中率50
  static const int analytic = 59; // 最後行動時わざ威力1.3倍
  static const int ignoreWall = 60; // かべ・みがわり無視
  static const int prankster = 61; // へんかわざ優先度+1(あくタイプには無効)
  static const int rockGroundSteel1_3 = 62; // いわ・じめん・はがねわざ威力1.3倍
  static const int zenMode = 63; // ダルマモード(現状SVではヒヒダルマ登場してないので実装していない)
  static const int accuracy1_1 = 64; // 命中率1.1倍
  static const int guard2 = 65; // ぼうぎょ2倍
  static const int bulletProof = 66; // 弾のわざ無効
  static const int bite1_5 = 67; // かみつきわざ威力1.5倍
  static const int freezeSkin = 68; // ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍
  static const int bladeForm = 69; // ブレードフォルム(現状SVでギルガルドが登場していないため未実装)
  static const int shieldForm = 70; // シールドフォルム(現状SVでギルガルドが登場していないため未実装)
  static const int galeWings = 71; // ひこうわざ優先度+1
  static const int wave1_5 = 72; // はどうわざ威力1.5倍
  static const int guard1_5 = 73; // ぼうぎょ1.5倍
  static const int directAttack1_3 = 74; // 直接攻撃威力1.3倍
  static const int fairySkin = 75; // ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍
  static const int airSkin = 76; // ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍
  static const int darkAura = 77; // あくわざ威力1.33倍
  static const int fairyAura = 78; // フェアリーわざ威力1.33倍
  static const int antiDarkAura = 79; // あくわざ威力0.75倍
  static const int antiFairyAura = 80; // フェアリーわざ威力0.75倍
  static const int merciless = 81; // どく・もうどく状態へのこうげき急所率100%
  static const int change2 = 82; // こうたい後ポケモンへのこうげき・とくこう2倍
  static const int waterBubble1 = 83; // 相手ほのおわざこうげき・とくこう0.5倍
  static const int waterBubble2 = 84; // みずわざこうげき・とくこう2倍
  static const int steelWorker = 85; // はがねわざこうげき・とくこう1.5倍
  static const int liquidVoice = 86; // 音わざタイプ→みず
  static const int healingShift = 87; // かいふくわざ優先度+3
  static const int electricSkin = 88; // ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍
  static const int singleForm = 89; // たんどくのすがた(現状SVでは登場していないため未実装)
  static const int multipleForm = 90; // むれたすがた(現状SVでは登場していないため未実装)
  static const int transedForm = 91; // ばけたすがた
  static const int revealedForm = 92; // ばれたすがた
//  static const int satoshiGekkoga = 93;   // サトシゲッコウガ
  static const int tenPercentForm = 94; // 10%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int fiftyPercentForm = 95; // 50%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int perfectForm = 96; // パーフェクトフォルム(現状SVでジガルデが登場していないため未実装)
  static const int priorityCut = 97; // 相手の優先度1以上わざ無効    // TODO
  static const int directAttackedDamage0_5 = 98; // 直接攻撃被ダメージ半減
  static const int fireAttackedDamage2 = 99; // ほのおわざ被ダメージ2倍
  static const int greatDamage1_25 = 100; // こうかばつぐんわざダメージ1.25倍
  static const int targetRock = 101; // わざの対象相手が変更されない
  static const int unomiForm = 102; // うのみのすがた
  static const int marunomiForm = 103; // まるのみのすがた
  static const int sound1_3 = 104; // 音わざ威力1.3倍
  static const int soundedDamage0_5 = 105; // 音わざ被ダメージ半減
  static const int specialDamaged0_5 = 106; // とくしゅわざ被ダメージ半減
  static const int nuts2 = 107; // きのみ効果2倍
  static const int iceFace = 108; // アイスフェイス
  static const int niceFace = 109; // ナイスフェイス
  static const int attackMove1_3 = 110; // こうげきわざ威力1.3倍
  static const int steel1_5 = 111; // はがねわざ威力1.5倍
  static const int gorimuchu = 112; // わざこだわり・こうげき1.5倍
  static const int manpukuForm = 113; // まんぷくもよう
  static const int harapekoForm = 114; // はらぺこもよう
  static const int directAttackIgnoreGurad = 115; // まもり不可の直接こうげき
  static const int electric1_3 = 116; // でんきわざ時こうげき・とくこう1.3倍
  static const int dragon1_5 = 117; // ドラゴンわざ時こうげき・とくこう1.5倍
  static const int ghosted0_5 = 118; // ゴーストわざ被ダメ計算時こうげき・とくこう半減
  static const int rock1_5 = 119; // いわわざ時こうげき・とくこう1.5倍
  static const int naiveForm = 120; // ナイーブフォルム
  static const int mightyForm = 121; // マイティフォルム
  static const int specialAttack0_75 = 122; // とくこう0.75倍
  static const int defense0_75 = 123; // ぼうぎょ0.75倍
  static const int attack0_75 = 124; // こうげき0.75倍
  static const int specialDefense0_75 = 125; // とくぼう0.75倍
  static const int attack1_33 = 126; // こうげき1.33倍
  static const int specialAttack1_33 = 127; // とくこう1.33倍
  static const int cut1_5 = 128; // 切るわざ威力1.5倍
  static const int power10 = 129; // わざ威力10%アップ
  static const int power20 = 130; // わざ威力20%アップ
  static const int power30 = 131; // わざ威力30%アップ
  static const int power40 = 132; // わざ威力40%アップ
  static const int power50 = 133; // わざ威力50%アップ
  static const int myceliumMight = 134; // へんかわざ最後に行動＆相手のとくせい無視
  static const int specialDefense1_5 = 135; // とくぼう1.5倍
  static const int choiceSpecs = 136; // わざこだわり・とくこう1.5倍
  static const int specialAttack2 = 137; // とくこう2倍
  static const int onlyAttackSpecialDefense1_5 = 138; // こうげきわざのみ選択可・とくぼう1.5倍
  static const int specialDefense2 = 139; // とくぼう2倍
  static const int choiceScarf = 140; // わざこだわり・すばやさ1.5倍
  static const int onceAccuracy1_2 = 141; // 次に使うわざ命中率1.2倍
  static const int movedAccuracy1_2 = 142; // 当ターン行動済み相手へのわざ命中率1.2倍
  static const int attackMove2 = 143; // こうげきわざ時こうげき・とくこう2倍
  static const int speed0_5 = 144; // すばやさ0.5倍
  static const int yourAccuracy0_9 = 145; // 相手わざ命中率0.9倍
  static const int physical1_1 = 146; // ぶつりわざ威力1.1倍
  static const int special1_1 = 147; // とくしゅわざ威力1.1倍
  static const int onceNormalAttack1_3 = 148; // ノーマルわざ威力1.3倍
  static const int normalAttack1_2 = 149; // ノーマルわざ威力1.2倍
  static const int fireAttack1_2 = 150; // ほのおわざ威力1.2倍
  static const int waterAttack1_2 = 151; // みずわざ威力1.2倍
  static const int electricAttack1_2 = 152; // でんきわざ威力1.2倍
  static const int grassAttack1_2 = 153; // くさわざ威力1.2倍
  static const int iceAttack1_2 = 154; // こおりわざ威力1.2倍
  static const int fightAttack1_2 = 155; // かくとうわざ威力1.2倍
  static const int poisonAttack1_2 = 156; // どくわざ威力1.2倍
  static const int groundAttack1_2 = 157; // じめんわざ威力1.2倍
  static const int airAttack1_2 = 158; // ひこうわざ威力1.2倍
  static const int psycoAttack1_2 = 159; // エスパーわざ威力1.2倍
  static const int bugAttack1_2 = 160; // むしわざ威力1.2倍
  static const int rockAttack1_2 = 161; // いわわざ威力1.2倍
  static const int ghostAttack1_2 = 162; // ゴーストわざ威力1.2倍
  static const int dragonAttack1_2 = 163; // ドラゴンわざ威力1.2倍
  static const int evilAttack1_2 = 164; // あくわざ威力1.2倍
  static const int steelAttack1_2 = 165; // はがねわざ威力1.2倍
  static const int fairyAttack1_2 = 166; // フェアリーわざ威力1.2倍
  static const int moveAttack1_2 = 167; // わざ威力1.2倍
  static const int lifeOrb = 168; // こうげきわざダメージ1.3倍・自身HP1/10ダメージ
  static const int greatDamage1_2 = 169; // こうかばつぐん時ダメージ1.2倍
  static const int continuousMoveDamageInc0_2 =
      170; // 同じわざ連続使用ごとにダメージ+20%(MAX 200%)
  static const int bindDamage1_6 = 171; // バインド与ダメージ→最大HP1/6
  static const int ignoreDirectAtackEffect = 173; // 直接こうげきに対して発動する効果無効
  static const int ignoreInstallingEffect = 174; // 設置わざ効果無効
  static const int attackWithFlinch10 = 175; // こうげき時10%ひるみ
  static const int substitute = 176; // みがわり
  static const int rage = 177; // わざによるダメージでこうげき1段階上昇
  static const int punchNotDirect1_1 = 178; // パンチわざ非接触化・威力1.1倍
  static const int voiceForm = 179; // ボイスフォルム
  static const int stepForm = 180; // ステップフォルム
  static const int copiedMove = 181; // わざ「ものまね」のコピーしたわざ(隠しステータス)
  static const int chargingMove = 182; // 溜める系わざの溜め状態(隠しステータス)
  static const int recoiling = 183; // わざの反動で動けない状態(隠しステータス)
  static const int certainlyHittedDamage2 = 184; // 相手わざ必中・ダメージ2倍
  static const int protean = 185; // へんげんじざい/リベロ発動済み(隠しステータス)
  static const int attack1_2 = 186; // こうげきわざ威力1.2倍
  static const int lastLostBerry = 187; // 最後に消費したきのみ(隠しステータス)
  static const int lastLostItem = 188; // 最後に消費したもちもの(隠しステータス)
  static const int transform =
      189; // へんしん(extraArgに、へんしん対象のポケモンNo、turnsに、性別のid)
  static const int thisTurnUpStatChange =
      190; // このターンでステータス上昇が起きたことを示す(隠しステータス)
  static const int thisTurnDownStatChange =
      191; // このターンでステータス下降が起きたことを示す(隠しステータス)
  static const int changedThisTurn =
      192; // このターン、交代わざやこうたい行動によってでてきたポケモンであることを表す(隠しステータス。はりこみ用)
  static const int halvedBerry = 193; // わざを受ける前に半減系きのみを食べた(隠しステータス)
  static const int sameMoveCount = 194; // 連続で使用しているわざのID*100+カウント(隠しステータス)
  static const int magicRoom =
      195; // マジックルーム時、もちものが使えないことを示すフラグ(隠しステータス。場の効果にすると使いづらいため、こちらと併用)
  static const int attackedCount = 196; // こうげきわざを受けた回数(隠しステータス。交代・ひんしでも消えない)
  static const int zoroappear = 197; // ゾロア系だとバレたあと(隠しステータス。交代でも消えない)
  static const int terastalForm = 198; // テラスタルフォルム
  static const int stellarForm = 199; // ステラフォルム
  static const int stellarUsed = 200; // ステラ補正を使用したタイプのフラグ(隠しステータス。交代でも消えない)

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap =
      {
    0: Tuple4('', '', Colors.black, 0),
    1: Tuple4('こうげき1.3倍', 'Attack 1.3x', Colors.red, 0),
    2: Tuple4('ぼうぎょ1.3倍', 'Defense 1.3x', Colors.red, 0),
    3: Tuple4('とくこう1.3倍', 'Special Attack 1.3x', Colors.red, 0),
    4: Tuple4('とくぼう1.3倍', 'Special Defense 1.3x', Colors.red, 0),
    5: Tuple4('すばやさ1.5倍', 'Speed 1.5x', Colors.red, 0),
    6: Tuple4('相手わざ命中率0.8倍', 'Opponent\'s Accuracy 0.8x', Colors.red, 0),
    7: Tuple4('命中率1.3倍', 'Accuracy 1.3x', Colors.red, 0),
    8: Tuple4('ほのおわざ威力1.5倍', 'Fire Move Power 1.5x', Colors.red, 0),
    9: Tuple4(
        'わざ追加効果発動確率2倍', 'Additional effect chance of Move 2x', Colors.red, 0),
    10: Tuple4('すばやさ2倍', 'Speed 2x', Colors.red, 0),
    11: Tuple4('こうげき2倍', 'Attack 2x', Colors.red, 0),
    12: Tuple4('こうげき1.5倍', 'Attack 1.5x', Colors.red, 0),
    13: Tuple4('物理技命中率0.8倍', 'Accuracy of Physical Move 0.8x', Colors.blue, 0),
    14: Tuple4('ポワルンのすがた', 'Normal Form', Colors.orange, 0),
    15: Tuple4('たいようのすがた', 'Sunny Form', Colors.orange, 0),
    16: Tuple4('あまみずのすがた', 'Rainy Form', Colors.orange, 0),
    17: Tuple4('ゆきぐものすがた', 'Snowy Form', Colors.orange, 0),
    18: Tuple4('こうげき1.5倍(やけど無視)', 'Attack 1.5x(ignore Burn)', Colors.red, 0),
    19: Tuple4('ぼうぎょ1.5倍', 'Defense 1.5x', Colors.red, 0),
    20: Tuple4('くさわざ威力1.5倍', 'Grass Move Power 1.5x', Colors.red, 0),
    21: Tuple4('ほのおわざ威力1.5倍', 'Fire Move Power 1.5x', Colors.red, 0),
    22: Tuple4('みずわざ威力1.5倍', 'Water Move Power 1.5x', Colors.red, 0),
    23: Tuple4('むしわざ威力1.5倍', 'Bug Move Power 1.5x', Colors.red, 0),
    24: Tuple4('相手わざ命中率0.5倍', 'Opponent\'s Accuracy 0.5x', Colors.red, 0),
    25: Tuple4('すばやさ2倍', 'Speed 2x', Colors.red, 0),
    26: Tuple4(
        '同性への威力1.25倍/異性への威力0.75倍',
        '1.25x power against same sex / 0.75x power against opposite sex',
        Colors.red,
        0),
    27: Tuple4(
        'ほのおわざ被ダメ半減計算・やけどダメ半減',
        'Fire Move\'s damage damage calculation/Burn damage halved',
        Colors.red,
        0),
    28: Tuple4('ほのおわざ受ける威力1.25倍', 'Receiving Fire Move\'s power 1.25x',
        Colors.blue, 0),
    29: Tuple4('パンチわざ威力1.2倍', 'Punch Move power 1.2x', Colors.red, 0),
    30: Tuple4('タイプ一致ボーナス2倍', 'Type match bonus 2x', Colors.red, 0),
    31: Tuple4('すばやさ1.5倍(まひ無視)', 'Speed 1.5x(ignore Paralysis)', Colors.red, 0),
    32: Tuple4(
        'すべてのわざタイプ→ノーマル', 'All Move types -> Normal', PokeTypeColor.normal, 0),
    33: Tuple4('急所時ダメージ1.5倍', 'Critical damage 1.5x', Colors.red, 0),
    34: Tuple4('相手こうげき以外ダメージ無効',
        'Immunity to damage other than opponent\'s attacks', Colors.red, 0),
    35: Tuple4('出すわざ/受けるわざ必中', 'Moves to send/Moves to receive are sure to hit',
        Colors.red, 0),
    36: Tuple4(
        '同優先度行動で最後に行動', 'Act last with same priority action', Colors.red, 0),
    37: Tuple4('60以下威力わざの威力1.5倍',
        '1.5x the power of Moves with a power of 60 or less', Colors.red, 0),
    38: Tuple4('もちものの効果なし', 'Item no effect', Colors.red, 0),
    39: Tuple4('相手とくせい無視', 'Ignore opponent\'s Ability', Colors.red, 0),
    40: Tuple4('急所率アップ+1', 'Critical rate +1', Colors.red, 0),
    41: Tuple4('急所率アップ+2', 'Critical rate +2', Colors.red, 0),
    42: Tuple4('急所率アップ+3', 'Critical rate +3', Colors.red, 0),
    43: Tuple4(
        '相手のランク補正無視', 'Ignore opponent\'s Stat modifications', Colors.red, 0),
    44: Tuple4('タイプ相性いまひとつ時ダメージ2倍', '2x damage when type compatibility is poor',
        Colors.red, 0),
    45: Tuple4(
        'こうかばつぐん被ダメージ0.75倍',
        '0.75x damage when Move whose type compatibility is great received',
        Colors.red,
        0),
    46: Tuple4('こうげき・すばやさ0.5倍', 'Attack and Speed 0.5x', Colors.blue, 5),
    47: Tuple4('反動わざ威力1.2倍', '1.2x power of Move with recoil', Colors.red, 0),
    48: Tuple4('ネガフォルム', 'Overcast Form', Colors.orange, 0),
    49: Tuple4('ポジフォルム', 'Sunshine Form', Colors.orange, 0),
    50: Tuple4(
        'わざの追加効果なし・威力1.3倍',
        'No additional effect occurs when use Move and 1.3x power',
        Colors.red,
        0),
    51: Tuple4('こうげき・とくこう半減', 'Attack and Special Attack 0.5x', Colors.blue, 0),
    52: Tuple4('おもさ2倍', 'Weight 2x', Colors.orange, 0),
    53: Tuple4('おもさ0.5倍', 'Weight 0.5x', Colors.orange, 0),
    54: Tuple4('受けるダメージ0.5倍', 'Damage received 0.5x', Colors.red, 0),
    55: Tuple4('ぶつりわざ威力1.5倍', 'Physical Move power 1.5x', Colors.red, 0),
    56: Tuple4('とくしゅわざ威力1.5倍', 'Special Move power 1.5x', Colors.red, 0),
    57: Tuple4('こな・ほうし・すなあらしダメージ無効',
        'Nullifies damage from powders/Effect Spore/sandstorm', Colors.red, 0),
    58: Tuple4('相手のへんかわざ命中率50',
        'Accuracy of opponent\'s Status Move becomes 50', Colors.red, 0),
    59: Tuple4('最後行動時わざ威力1.3倍', 'Move power 1.3x when you act at last in turns',
        Colors.red, 0),
    60: Tuple4('かべ・みがわり無視', 'Ignore Walls and SUBSTITUTE', Colors.red, 0),
    61: Tuple4(
        'へんかわざ優先度+1(あくタイプには無効)',
        'Status Move\'s priority +1(Except for Dark type Pokémon)',
        Colors.red,
        0),
    62: Tuple4('いわ・じめん・はがねわざ威力1.3倍', 'Rock/Ground/Steel Move power 1.5x',
        Colors.red, 0),
    63: Tuple4('ダルマモード', 'Zen Mode', Colors.orange, 0),
    64: Tuple4('命中率1.1倍', 'Accuracy 1.1x', Colors.red, 0),
    65: Tuple4('ぼうぎょ2倍', 'Defense 2x', Colors.red, 0),
    66: Tuple4('弾のわざ無効', 'Disable bullet Moves', Colors.red, 0),
    67: Tuple4('かみつきわざ威力1.5倍', 'Bite Move\'s power 1.5x', Colors.red, 0),
    68: Tuple4('ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍',
        'Normal Move types -> Ice and Ice Move power 1.2x', Colors.orange, 0),
    69: Tuple4('ブレードフォルム', 'Blade Forme', Colors.orange, 0),
    70: Tuple4('シールドフォルム', 'Shield Forme', Colors.orange, 0),
    71: Tuple4('ひこうわざ優先度+1', 'Flying Move priority +1', Colors.red, 0),
    72: Tuple4('はどうわざ威力1.5倍', 'Wave Move power 1.5x', Colors.red, 0),
    73: Tuple4('ぼうぎょ1.5倍', 'Defense 1.5x', Colors.red, 0),
    74: Tuple4('直接攻撃威力1.3倍', 'Direct attack power 1.3x', Colors.red, 0),
    75: Tuple4('ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍',
        'Normal Move types -> Fairy and Fairy Move power 1.2x', Colors.red, 0),
    76: Tuple4(
        'ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍',
        'Normal Move types -> Flying and Flying Move power 1.2x',
        Colors.red,
        0),
    77: Tuple4('あくわざ威力1.33倍', 'Dark Move power 1.33x', Colors.red, 0),
    78: Tuple4('フェアリーわざ威力1.33倍', 'Fairy Move power 1.33x', Colors.red, 0),
    79: Tuple4('あくわざ威力0.75倍', 'Dark Move power 0.75x', Colors.blue, 0),
    80: Tuple4('フェアリーわざ威力0.75倍', 'Fairy Move power 0.75x', Colors.blue, 0),
    81: Tuple4(
        'どく・もうどく状態へのこうげき急所率100%',
        '100% rate of Critical for Poisoning and badly Poisoning',
        Colors.red,
        0),
    82: Tuple4('こうたい後ポケモンへのこうげき・とくこう2倍',
        'Attack/Special Attack 2x to Pokémon after change', Colors.red, 0),
    83: Tuple4(
        '相手ほのおわざこうげき・とくこう0.5倍',
        'Opponent\'s Attack/Special Attack 0.5x when receive Fire Move',
        Colors.red,
        0),
    84: Tuple4('みずわざこうげき・とくこう2倍',
        'Attack/Special Attack 2x when using Water Move', Colors.red, 0),
    85: Tuple4('はがねわざこうげき・とくこう1.5倍',
        'Attack/Special Attack 2x when using Steel Move', Colors.red, 0),
    86: Tuple4('音わざタイプ→みず', 'Sound Move types -> Water', Colors.orange, 0),
    87: Tuple4('かいふくわざ優先度+3', 'Recovery Moves priority +3', Colors.red, 0),
    88: Tuple4(
        'ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍',
        'Normal Move types -> Electric and Electric Move power 1.2x',
        Colors.red,
        0),
    89: Tuple4('たんどくのすがた', 'Single Form', Colors.orange, 0),
    90: Tuple4('むれたすがた', 'Multiple Form', Colors.orange, 0),
    91: Tuple4('ばけたすがた', 'Disguised Form', Colors.orange, 0),
    92: Tuple4('ばれたすがた', 'Busted Form', Colors.orange, 0),
    93: Tuple4('サトシゲッコウガ', 'Ash-Greninja', Colors.orange, 0),
    94: Tuple4('10%フォルム', '10% Form', Colors.orange, 0),
    95: Tuple4('50%フォルム', '50% Form', Colors.orange, 0),
    96: Tuple4('パーフェクトフォルム', 'Perfect Form', Colors.orange, 0),
    97: Tuple4('相手の優先度1以上わざ無効',
        'Disables opponent\'s Moves with priority 1 or above', Colors.red, 0),
    98: Tuple4(
        '直接攻撃被ダメージ半減', 'Direct attack with halved damage', Colors.red, 0),
    99: Tuple4(
        'ほのおわざ被ダメージ2倍', 'Fire Move received with damage 2x', Colors.blue, 0),
    100: Tuple4(
        'こうかばつぐんわざダメージ1.25倍',
        '1.25x damage when using Move whose type compatibility is great',
        Colors.red,
        0),
    101: Tuple4(
        'わざの対象相手が変更されない', 'Target of Moves does not change', Colors.red, 0),
    102: Tuple4('うのみのすがた', 'Gulping Form', Colors.orange, 0),
    103: Tuple4('まるのみのすがた', 'Gorging Form', Colors.orange, 0),
    104: Tuple4('音わざ威力1.3倍', 'Sound Move Power 1.3x', Colors.red, 0),
    105: Tuple4(
        '音わざ被ダメージ半減', 'Sound Move received with halved damage', Colors.red, 0),
    106: Tuple4('とくしゅわざ被ダメージ半減', 'Special Move received with halved damage',
        Colors.red, 0),
    107: Tuple4('きのみ効果2倍', '2x Berry effect', Colors.red, 0),
    108: Tuple4('アイスフェイス', 'Ice Face', Colors.orange, 0),
    109: Tuple4('ナイスフェイス', 'Noice Face', Colors.orange, 0),
    110: Tuple4('こうげきわざ威力1.3倍', 'Attack Move Power 1.3x', Colors.red, 0),
    111: Tuple4('はがねわざ威力1.5倍', 'Steel Move Power 1.3x', Colors.red, 0),
    112: Tuple4(
        'わざこだわり・こうげき1.5倍', 'Lock one Move and Attack 1.5x', Colors.red, 0),
    113: Tuple4('まんぷくもよう', 'Full Belly Mode', Colors.orange, 0),
    114: Tuple4('はらぺこもよう', 'Hangry Mode', Colors.orange, 0),
    115: Tuple4('直接こうげきのまもり不可', 'Direct attack passes through protection',
        Colors.red, 0),
    116: Tuple4('でんきわざ時こうげき・とくこう1.3倍',
        'Attack/Special Attack 1.3x when using Electric Move', Colors.red, 0),
    117: Tuple4('ドラゴンわざ時こうげき・とくこう1.5倍',
        'Attack/Special Attack 1.5x when using Dragon Move', Colors.red, 0),
    118: Tuple4(
        'ゴーストわざ被ダメ計算時こうげき・とくこう半減',
        'Opponent\'s Attack/Special Attack 0.5x when receive Ghost Move',
        Colors.red,
        0),
    119: Tuple4('いわわざ時こうげき・とくこう1.5倍',
        'Attack/Special Attack 1.5x when using Rock Move', Colors.red, 0),
    120: Tuple4('ナイーブフォルム', 'Zero Form', Colors.orange, 0),
    121: Tuple4('マイティフォルム', 'Zero Form', Colors.orange, 0),
    122: Tuple4('とくこう0.75倍', 'Special Attack 0.75x', Colors.blue, 0),
    123: Tuple4('ぼうぎょ0.75倍', 'Defense 0.75x', Colors.blue, 0),
    124: Tuple4('こうげき0.75倍', 'Attack 0.75x', Colors.blue, 0),
    125: Tuple4('とくぼう0.75倍', 'Special Defense 0.75x', Colors.blue, 0),
    126: Tuple4('こうげき1.33倍', 'Attack 1.33x', Colors.red, 0),
    127: Tuple4('とくこう1.33倍', 'Special Attack 1.33x', Colors.red, 0),
    128: Tuple4('切るわざ威力1.5倍', 'Cutting Move Power 1.5x', Colors.red, 0),
    129: Tuple4('わざ威力10%アップ', 'Move Power +10%', Colors.red, 0),
    130: Tuple4('わざ威力20%アップ', 'Move Power +20%', Colors.red, 0),
    131: Tuple4('わざ威力30%アップ', 'Move Power +30%', Colors.red, 0),
    132: Tuple4('わざ威力40%アップ', 'Move Power +40%', Colors.red, 0),
    133: Tuple4('わざ威力50%アップ', 'Move Power +50%', Colors.red, 0),
    134: Tuple4(
        'へんかわざ最後に行動＆相手のとくせい無視',
        'Act at last in turns when using Status Move and ignore opponent\'s Ability',
        Colors.red,
        0),
    135: Tuple4('とくぼう1.5倍', 'Special Defense 1.5x', Colors.red, 0),
    136: Tuple4('わざこだわり・とくこう1.5倍', 'Lock one Move and Special Attack 1.5x',
        Colors.red, 0),
    137: Tuple4('とくこう2倍', 'Special Attack 2x', Colors.red, 0),
    138: Tuple4('こうげきわざのみ選択可・とくぼう1.5倍',
        'Special Defense 1.5x but cannot Status Moves', Colors.red, 0),
    139: Tuple4('とくぼう2倍', 'Special Defense 2x', Colors.red, 0),
    140: Tuple4(
        'わざこだわり・すばやさ1.5倍', 'Lock one Move and Speed 1.5x', Colors.red, 0),
    141: Tuple4(
        '次に使うわざ命中率1.2倍', 'Accuracy 1.2x of Move use next', Colors.red, 0),
    142: Tuple4('当ターン行動済み相手へのわざ命中率1.2倍',
        'Accuracy 1.2x to opponent acted in this turn', Colors.red, 0),
    143: Tuple4('こうげきわざ時こうげき・とくこう2倍',
        'Attack/Special Attack 2x when using Move', Colors.red, 0),
    144: Tuple4('すばやさ0.5倍', 'Speed 0.5x', Colors.blue, 0),
    145: Tuple4(
        '相手わざ命中率0.9倍', 'Accuracy 0.9x of opponent\'s Move', Colors.red, 0),
    146: Tuple4('ぶつりわざ威力1.1倍', 'Physical Move Power 1.1x', Colors.red, 0),
    147: Tuple4('とくしゅわざ威力1.1倍', 'Special Move Power 1.1x', Colors.red, 0),
    148: Tuple4('ノーマルわざ威力1.3倍', 'Normal Move Power 1.3x', Colors.red, 0),
    149: Tuple4('ノーマルわざ威力1.2倍', 'Normal Move Power 1.2x', Colors.red, 0),
    150: Tuple4('ほのおわざ威力1.2倍', 'Fire Move Power 1.2x', Colors.red, 0),
    151: Tuple4('みずわざ威力1.2倍', 'Water Move Power 1.2x', Colors.red, 0),
    152: Tuple4('でんきわざ威力1.2倍', 'Electric Move Power 1.2x', Colors.red, 0),
    153: Tuple4('くさわざ威力1.2倍', 'Grass Move Power 1.2x', Colors.red, 0),
    154: Tuple4('こおりわざ威力1.2倍', 'Ice Move Power 1.2x', Colors.red, 0),
    155: Tuple4('かくとうわざ威力1.2倍', 'Fighting Move Power 1.2x', Colors.red, 0),
    156: Tuple4('どくわざ威力1.2倍', 'Poison Move Power 1.2x', Colors.red, 0),
    157: Tuple4('じめんわざ威力1.2倍', 'Ground Move Power 1.2x', Colors.red, 0),
    158: Tuple4('ひこうわざ威力1.2倍', 'Flying Move Power 1.2x', Colors.red, 0),
    159: Tuple4('エスパーわざ威力1.2倍', 'Psychic Move Power 1.2x', Colors.red, 0),
    160: Tuple4('むしわざ威力1.2倍', 'Bug Move Power 1.2x', Colors.red, 0),
    161: Tuple4('いわわざ威力1.2倍', 'Rock Move Power 1.2x', Colors.red, 0),
    162: Tuple4('ゴーストわざ威力1.2倍', 'Ghost Move Power 1.2x', Colors.red, 0),
    163: Tuple4('ドラゴンわざ威力1.2倍', 'Dragon Move Power 1.2x', Colors.red, 0),
    164: Tuple4('あくわざ威力1.2倍', 'Dark Move Power 1.2x', Colors.red, 0),
    165: Tuple4('はがねわざ威力1.2倍', 'Steel Move Power 1.2x', Colors.red, 0),
    166: Tuple4('フェアリーわざ威力1.2倍', 'Fairy Move Power 1.2x', Colors.red, 0),
    167: Tuple4('わざ威力1.2倍', 'Move Power 1.2x', Colors.red, 0),
    168: Tuple4(
        'こうげきわざダメージ1.3倍・自身HP1/10ダメージ',
        'Damage 1.3x of using attack Move and 1/10 of max HP is reduced',
        Colors.red,
        0),
    169: Tuple4(
        'こうかばつぐん時ダメージ1.2倍',
        '1.2x damage when using Move whose type compatibility is great',
        Colors.red,
        0),
    170: Tuple4(
        '同じわざ連続使用ごとにダメージ+20%(MAX 200%)',
        'Damage +20%(MAX 200%) for each consecutive use of the same Move',
        Colors.red,
        0),
    171: Tuple4('バインド与ダメージ→最大HP1/6',
        'Damage dealt by Partially Trapped -> Max HP 1/6', Colors.red, 0),
    173: Tuple4('直接こうげきに対して発動する効果無効',
        'Effects activated direct attack are disabled', Colors.red, 0),
    174: Tuple4('設置わざ効果無効', 'Ignore Setting Move effect', Colors.red, 0),
    175: Tuple4('こうげき時10%ひるみ', '10% Flinch when attack', Colors.red, 0),
    176: Tuple4('みがわり', 'SUBSTITUTE', Colors.green, 0),
    177: Tuple4('わざによるダメージでこうげき1段階上昇',
        'Attack rise 1 level due to damage caused by Moves', Colors.red, 0),
    178: Tuple4('パンチわざ非接触化・威力1.1倍', 'Punch Moves are non-contact/power 1.1x',
        Colors.red, 0),
    179: Tuple4('ボイスフォルム', 'Aria Forme', Colors.orange, 0),
    180: Tuple4('ステップフォルム', 'Pirouette Forme', Colors.orange, 0),
    181: Tuple4('', '', Colors.white, 0),
    182: Tuple4('', '', Colors.white, 0),
    183: Tuple4('', '', Colors.white, 0),
    184: Tuple4('相手わざ必中・ダメージ2倍', 'Opponent Move guaranteed to hit/damage 2x',
        Colors.blue, 0),
    186: Tuple4('こうげきわざ威力1.2倍', 'Attack Move Power 1.2x', Colors.red, 0),
    189: Tuple4('へんしん', 'Transform', Colors.orange, 0),
    198: Tuple4('テラスタルフォルム', 'Terastal Form', Colors.orange, 0),
    199: Tuple4('ステラフォルム', 'Stellar Form', Colors.orange, 0),
  };

  final int id;
  int turns = 0; // 経過ターン
  int extraArg1 = 0; //

  @override
  List<Object?> get props => [
        id,
        turns,
        extraArg1,
      ];

  BuffDebuff(this.id);

  @override
  BuffDebuff copy() => BuffDebuff(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _nameColorTurnMap[id]!.item4 > 0
            ? '${_nameColorTurnMap[id]!.item1} ($turns/${_nameColorTurnMap[id]!.item4})'
            : _nameColorTurnMap[id]!.item1;
      case Language.english:
      default:
        return _nameColorTurnMap[id]!.item4 > 0
            ? '${_nameColorTurnMap[id]!.item2} ($turns/${_nameColorTurnMap[id]!.item4})'
            : _nameColorTurnMap[id]!.item2;
    }
  }

  Color get bgColor => _nameColorTurnMap[id]!.item3;

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

class BuffDebuffList extends Equatable implements Copyable {
  List<BuffDebuff> list = [];

  @override
  List<Object?> get props => [list];

  @override
  BuffDebuffList copy() => BuffDebuffList()..list = [...list];

  bool containsByID(int id) =>
      (list.indexWhere((element) => element.id == id) >= 0);

  bool containsByAnyID(List<int> ids) =>
      (list.indexWhere((element) => ids.contains(element.id)) >= 0);

  void addIfNotFoundByID(int id) {
    if (!containsByID(id)) {
      add(BuffDebuff(id));
    }
  }

  void removeFirstByID(int id) {
    int findIdx = list.indexWhere((element) => element.id == id);
    if (findIdx >= 0) {
      list.removeAt(findIdx);
    }
  }

  void removeAllByID(int id) => list.removeWhere((element) => element.id == id);

  void removeAllByAllID(List<int> ids) =>
      list.removeWhere((element) => ids.contains(element.id));

  Iterable<BuffDebuff> whereByID(int id) =>
      list.where((element) => element.id == id);

  Iterable<BuffDebuff> whereByAnyID(List<int> ids) =>
      list.where((element) => ids.contains(element.id));

  // 対象IDを持つ要素があれば削除、なければ追加
  void removeOrAddByID(int id) {
    int findIdx = list.indexWhere((element) => element.id == id);
    if (findIdx >= 0) {
      list.removeAt(findIdx);
    } else {
      list.add(BuffDebuff(id));
    }
  }

  // 対象IDを持つ要素があればもう一方のIDの要素に変更
  void switchID(int id1, int id2) {
    int findIdx = list.indexWhere((element) => element.id == id1);
    if (findIdx >= 0) {
      list[findIdx] = BuffDebuff(id2);
    } else {
      findIdx = list.indexWhere((element) => element.id == id2);
      if (findIdx >= 0) {
        list[findIdx] = BuffDebuff(id1);
      }
    }
  }

  // 対象IDを持つ要素があればもう一方のIDの要素に変更
  void changeID(int from, int to) {
    int findIdx = list.indexWhere((element) => element.id == from);
    if (findIdx >= 0) {
      list[findIdx] = BuffDebuff(to);
    }
  }

  // 以下、単にリスト操作するだけ
  void add(BuffDebuff b) => list.add(b);
  void addAll(Iterable<BuffDebuff> b) => list.addAll(b);
  void clear() => list.clear();
  int get length => list.length;
}
