import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/tool.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

/// その他の補正(フォルム等)
class BuffDebuff extends Equatable implements Copyable {
  // TODO:最終的には消す。CSVに全データが行くように

  /// なし、無効
  //static const int none = 0;

  /// こうげき1.3倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↓)
  static const int attack1_3 = 1;

  /// ぼうぎょ1.3倍
  static const int defense1_3 = 2;

  /// とくこう1.3倍
  static const int specialAttack1_3 = 3;

  /// とくぼう1.3倍
  static const int specialDefense1_3 = 4;

  /// すばやさ1.5倍(extraArg = 1なら、ブーストエナジー消費によって得られた効果↑)
  static const int speed1_5 = 5;

  /// 相手わざ命中率0.8倍
  static const int yourAccuracy0_8 = 6;

  /// 命中率1.3倍
  static const int accuracy1_3 = 7;

  /// もらいび状態（ほのおわざ1.5倍）、重複不可
  static const int flashFired = 8;

  /// わざ追加効果発動確率2倍
  static const int additionalEffect2 = 9;

  /// すばやさ2倍
  static const int speed2 = 10;

  /// こうげき2倍
  static const int attack2 = 11;

  /// こうげき1.5倍
  static const int attack1_5 = 12;

  /// 物理技命中率0.8倍
  static const int physicalAccuracy0_8 = 13;

  /// ポワルンのすがた
  static const int powalenNormal = 14;

  /// たいようのすがた
  static const int powalenSun = 15;

  /// あまみずのすがた
  static const int powalenRain = 16;

  /// ゆきぐものすがた
  static const int powalenSnow = 17;

  /// こうげき1.5倍(やけど無視)
  static const int attack1_5WithIgnBurn = 18;

  /// ぼうぎょ1.5倍
  static const int defense1_5 = 19;

  /// くさわざ威力1.5倍(しんりょくによる)、重複不可
  static const int overgrow = 20;

  /// ほのおわざ威力1.5倍(もうかによる)、重複不可
  static const int blaze = 21;

  /// みずわざ威力1.5倍(げきりゅうによる)、重複不可
  static const int torrent = 22;

  /// むしわざ威力1.5倍(むしのしらせによる)、重複不可
  static const int swarm = 23;

  /// 相手わざ命中率0.5倍(ちどりあしによる)、重複不可
  static const int yourAccuracy0_5 = 24;

  /// すばやさ2倍(かるわざによる)、重複不可
  static const int unburden = 25;

  /// 同性への威力1.25倍/異性への威力0.75倍
  static const int opponentSex1_5 = 26;

  /// ほのおわざ被ダメ半減計算・やけどダメ半減(たいねつ)
  static const int heatproof = 27;

  /// ほのおわざ受ける威力1.25倍
  static const int drySkin = 28;

  /// パンチわざ威力1.2倍
  static const int punch1_2 = 29;

  /// タイプ一致ボーナス2倍
  static const int typeBonus2 = 30;

  /// すばやさ1.5倍(まひ無視)
  static const int speed1_5IgnPara = 31;

  /// すべてのわざタイプ→ノーマル
  static const int normalize = 32;

  /// 急所時ダメージ1.5倍
  static const int sniper = 33;

  /// 相手こうげき以外ダメージ無効
  static const int magicGuard = 34;

  /// 出すわざ/受けるわざ必中
  static const int noGuard = 35;

  /// 同優先度行動で最後に行動
  static const int stall = 36;

  /// 60以下威力わざの威力1.5倍
  static const int technician = 37;

  /// もちものの効果なし
  static const int noItemEffect = 38;

  /// 相手とくせい無視
  static const int noAbilityEffect = 39;

  /// 急所率+1
  static const int vital1 = 40;

  /// 急所率+2
  static const int vital2 = 41;

  /// 急所率+3
  static const int vital3 = 42;

  /// 相手のランク補正無視
  static const int ignoreRank = 43;

  /// タイプ相性いまひとつ時ダメージ2倍
  static const int notGoodType2 = 44;

  /// こうかばつぐん被ダメージ0.75倍
  static const int greatDamaged0_75 = 45;

  /// こうげき・すばやさ0.5倍
  static const int attackSpeed0_5 = 46;

  /// 反動わざ威力1.2倍
  static const int recoil1_2 = 47;

  /// チェリムのネガフォルム
  static const int negaForm = 48;

  /// チェリムのポジフォルム
  static const int posiForm = 49;

  /// わざの追加効果なし・威力1.3倍
  static const int sheerForce = 50;

  /// こうげき・とくこう半減(よわきによる)、重複不可
  static const int defeatist = 51;

  /// おもさ2倍
  static const int heavy2 = 52;

  /// おもさ0.5倍
  static const int heavy0_5 = 53;

  /// 受けるダメージ0.5倍
  static const int damaged0_5 = 54;

  /// ぶつりわざ威力1.5倍
  static const int physical1_5 = 55;

  /// とくしゅわざ威力1.5倍
  static const int special1_5 = 56;

  /// こな・ほうし・すなあらしダメージ無効
  static const int overcoat = 57;

  /// 相手のへんかわざ命中率50
  static const int yourStatusAccuracy50 = 58;

  /// 最後行動時わざ威力1.3倍
  static const int analytic = 59;

  /// かべ・みがわり無視
  static const int ignoreWall = 60;

  /// へんかわざ優先度+1(あくタイプには無効)
  static const int prankster = 61;

  /// いわ・じめん・はがねわざ威力1.3倍
  static const int rockGroundSteel1_3 = 62;

  /// ダルマモード(現状SVではヒヒダルマ登場してないので実装していない)
  static const int zenMode = 63;

  /// 命中率1.1倍
  static const int accuracy1_1 = 64;

  /// ぼうぎょ2倍
  static const int guard2 = 65;

  /// 弾のわざ無効
  static const int bulletProof = 66;

  /// かみつきわざ威力1.5倍
  static const int bite1_5 = 67;

  /// ノーマルわざ→こおりわざ＆こおりわざ威力1.2倍
  static const int freezeSkin = 68;

  /// ブレードフォルム(現状SVでギルガルドが登場していないため未実装)
  static const int bladeForm = 69;

  /// シールドフォルム(現状SVでギルガルドが登場していないため未実装)
  static const int shieldForm = 70;

  /// ひこうわざ優先度+1
  static const int galeWings = 71;

  /// はどうわざ威力1.5倍
  static const int wave1_5 = 72;

  /// ぼうぎょ1.5倍
  static const int guard1_5 = 73;

  /// 直接攻撃威力1.3倍
  static const int directAttack1_3 = 74;

  /// ノーマルわざ→フェアリーわざ＆フェアリーわざ威力1.2倍
  static const int fairySkin = 75;

  /// ノーマルわざ→ひこうわざ＆ひこうわざ威力1.2倍
  static const int airSkin = 76;

  /// あくわざ威力1.33倍
  static const int darkAura = 77;

  /// フェアリーわざ威力1.33倍
  static const int fairyAura = 78;

  /// あくわざ威力0.75倍
  static const int antiDarkAura = 79;

  /// フェアリーわざ威力0.75倍
  static const int antiFairyAura = 80;

  /// どく・もうどく状態へのこうげき急所率100%
  static const int merciless = 81;

  /// こうたい後ポケモンへのこうげき・とくこう2倍
  static const int change2 = 82;

  /// 相手ほのおわざこうげき・とくこう0.5倍
  static const int waterBubble1 = 83;

  /// みずわざこうげき・とくこう2倍
  static const int waterBubble2 = 84;

  /// はがねわざこうげき・とくこう1.5倍
  static const int steelWorker = 85;

  /// 音わざタイプ→みず
  static const int liquidVoice = 86;

  /// かいふくわざ優先度+3
  static const int healingShift = 87;

  /// ノーマルわざ→でんきわざ＆でんきわざ威力1.2倍
  static const int electricSkin = 88;

  /// たんどくのすがた(現状SVでは登場していないため未実装)
  static const int singleForm = 89;

  /// むれたすがた(現状SVでは登場していないため未実装)
  static const int multipleForm = 90;

  /// ばけたすがた
  static const int transedForm = 91;

  /// ばれたすがた
  static const int revealedForm = 92;
//  static const int satoshiGekkoga = 93;   // サトシゲッコウガ
  /// 10%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int tenPercentForm = 94;

  /// 50%フォルム(現状SVでジガルデが登場していないため未実装)
  static const int fiftyPercentForm = 95;

  /// パーフェクトフォルム(現状SVでジガルデが登場していないため未実装)
  static const int perfectForm = 96;

  /// 相手の優先度1以上わざ無効(TODO)
  static const int priorityCut = 97;

  /// 直接攻撃被ダメージ半減
  static const int directAttackedDamage0_5 = 98;

  /// ほのおわざ被ダメージ2倍
  static const int fireAttackedDamage2 = 99;

  /// こうかばつぐんわざダメージ1.25倍
  static const int greatDamage1_25 = 100;

  /// わざの対象相手が変更されない
  static const int targetRock = 101;

  /// うのみのすがた
  static const int unomiForm = 102;

  /// まるのみのすがた
  static const int marunomiForm = 103;

  /// 音わざ威力1.3倍
  static const int sound1_3 = 104;

  /// 音わざ被ダメージ半減
  static const int soundedDamage0_5 = 105;

  /// とくしゅわざ被ダメージ半減
  static const int specialDamaged0_5 = 106;

  /// きのみ効果2倍
  static const int nuts2 = 107;

  /// アイスフェイス
  static const int iceFace = 108;

  /// ナイスフェイス
  static const int niceFace = 109;

  /// こうげきわざ威力1.3倍
  static const int attackMove1_3 = 110;

  /// はがねわざ威力1.5倍
  static const int steel1_5 = 111;

  /// わざこだわり・こうげき1.5倍
  static const int gorimuchu = 112;

  /// まんぷくもよう
  static const int manpukuForm = 113;

  /// はらぺこもよう
  static const int harapekoForm = 114;

  /// まもり不可の直接こうげき
  static const int directAttackIgnoreGurad = 115;

  /// でんきわざ時こうげき・とくこう1.3倍
  static const int electric1_3 = 116;

  /// ドラゴンわざ時こうげき・とくこう1.5倍
  static const int dragon1_5 = 117;

  /// ゴーストわざ被ダメ計算時こうげき・とくこう半減
  static const int ghosted0_5 = 118;

  /// いわわざ時こうげき・とくこう1.5倍
  static const int rock1_5 = 119;

  /// ナイーブフォルム
  static const int naiveForm = 120;

  /// マイティフォルム
  static const int mightyForm = 121;

  /// とくこう0.75倍
  static const int specialAttack0_75 = 122;

  /// ぼうぎょ0.75倍
  static const int defense0_75 = 123;

  /// こうげき0.75倍
  static const int attack0_75 = 124;

  /// とくぼう0.75倍
  static const int specialDefense0_75 = 125;

  /// こうげき1.33倍
  static const int attack1_33 = 126;

  /// とくこう1.33倍
  static const int specialAttack1_33 = 127;

  /// 切るわざ威力1.5倍
  static const int cut1_5 = 128;

  /// わざ威力10%アップ
  static const int power10 = 129;

  /// わざ威力20%アップ
  static const int power20 = 130;

  /// わざ威力30%アップ
  static const int power30 = 131;

  /// わざ威力40%アップ
  static const int power40 = 132;

  /// わざ威力50%アップ
  static const int power50 = 133;

  /// へんかわざ最後に行動＆相手のとくせい無視
  static const int myceliumMight = 134;

  /// とくぼう1.5倍
  static const int specialDefense1_5 = 135;

  /// わざこだわり・とくこう1.5倍
  static const int choiceSpecs = 136;

  /// とくこう2倍
  static const int specialAttack2 = 137;

  /// こうげきわざのみ選択可・とくぼう1.5倍
  static const int onlyAttackSpecialDefense1_5 = 138;

  /// とくぼう2倍
  static const int specialDefense2 = 139;

  /// わざこだわり・すばやさ1.5倍
  static const int choiceScarf = 140;

  /// 次に使うわざ命中率1.2倍
  static const int onceAccuracy1_2 = 141;

  /// 当ターン行動済み相手へのわざ命中率1.2倍
  static const int movedAccuracy1_2 = 142;

  /// こうげきわざ時こうげき・とくこう2倍
  static const int attackMove2 = 143;

  /// すばやさ0.5倍
  static const int speed0_5 = 144;

  /// 相手わざ命中率0.9倍
  static const int yourAccuracy0_9 = 145;

  /// ぶつりわざ威力1.1倍
  static const int physical1_1 = 146;

  /// とくしゅわざ威力1.1倍
  static const int special1_1 = 147;

  /// ノーマルわざ威力1.3倍
  static const int onceNormalAttack1_3 = 148;

  /// ノーマルわざ威力1.2倍
  static const int normalAttack1_2 = 149;

  /// ほのおわざ威力1.2倍
  static const int fireAttack1_2 = 150;

  /// みずわざ威力1.2倍
  static const int waterAttack1_2 = 151;

  /// でんきわざ威力1.2倍
  static const int electricAttack1_2 = 152;

  /// くさわざ威力1.2倍
  static const int grassAttack1_2 = 153;

  /// こおりわざ威力1.2倍
  static const int iceAttack1_2 = 154;

  /// かくとうわざ威力1.2倍
  static const int fightAttack1_2 = 155;

  /// どくわざ威力1.2倍
  static const int poisonAttack1_2 = 156;

  /// じめんわざ威力1.2倍
  static const int groundAttack1_2 = 157;

  /// ひこうわざ威力1.2倍
  static const int airAttack1_2 = 158;

  /// エスパーわざ威力1.2倍
  static const int psycoAttack1_2 = 159;

  /// むしわざ威力1.2倍
  static const int bugAttack1_2 = 160;

  /// いわわざ威力1.2倍
  static const int rockAttack1_2 = 161;

  /// ゴーストわざ威力1.2倍
  static const int ghostAttack1_2 = 162;

  /// ドラゴンわざ威力1.2倍
  static const int dragonAttack1_2 = 163;

  /// あくわざ威力1.2倍
  static const int evilAttack1_2 = 164;

  /// はがねわざ威力1.2倍
  static const int steelAttack1_2 = 165;

  /// フェアリーわざ威力1.2倍
  static const int fairyAttack1_2 = 166;

  /// わざ威力1.2倍
  static const int moveAttack1_2 = 167;

  /// こうげきわざダメージ1.3倍・自身HP1/10ダメージ
  static const int lifeOrb = 168;

  /// こうかばつぐん時ダメージ1.2倍
  static const int greatDamage1_2 = 169;

  /// 同じわざ連続使用ごとにダメージ+20%(MAX 200%)
  static const int continuousMoveDamageInc0_2 = 170;

  /// バインド与ダメージ→最大HP1/6
  static const int bindDamage1_6 = 171;

  /// 直接こうげきに対して発動する効果無効
  static const int ignoreDirectAtackEffect = 173;

  /// 設置わざ効果無効
  static const int ignoreInstallingEffect = 174;

  /// こうげき時10%ひるみ
  static const int attackWithFlinch10 = 175;

  /// みがわり
  static const int substitute = 176;

  /// わざによるダメージでこうげき1段階上昇
  static const int rage = 177;

  /// パンチわざ非接触化・威力1.1倍
  static const int punchNotDirect1_1 = 178;

  /// ボイスフォルム
  static const int voiceForm = 179;

  /// ステップフォルム
  static const int stepForm = 180;

  /// わざ「ものまね」のコピーしたわざ(隠しステータス)
  static const int copiedMove = 181;

  /// 溜める系わざの溜め状態(隠しステータス)
  static const int chargingMove = 182;

  /// わざの反動で動けない状態(隠しステータス)
  static const int recoiling = 183;

  /// 相手わざ必中・ダメージ2倍
  static const int certainlyHittedDamage2 = 184;

  /// へんげんじざい/リベロ発動済み(隠しステータス)
  static const int protean = 185;

  /// こうげきわざ威力1.2倍
  static const int attack1_2 = 186;

  /// 最後に消費したきのみ(隠しステータス)
  static const int lastLostBerry = 187;

  /// 最後に消費したもちもの(隠しステータス)
  static const int lastLostItem = 188;

  /// へんしん(extraArgに、へんしん対象のポケモンNo、turnsに、性別のid)
  static const int transform = 189;

  /// このターンでステータス上昇が起きたことを示す(隠しステータス)
  static const int thisTurnUpStatChange = 190;

  /// このターンでステータス下降が起きたことを示す(隠しステータス)
  static const int thisTurnDownStatChange = 191;

  /// このターン、交代わざやこうたい行動によってでてきたポケモンであることを表す(隠しステータス。はりこみ用)
  static const int changedThisTurn = 192;

  /// わざを受ける前に半減系きのみを食べた(隠しステータス)
  static const int halvedBerry = 193;

  /// 連続で使用しているわざのID*100+カウント(隠しステータス)
  static const int sameMoveCount = 194;

  /// マジックルーム時、もちものが使えないことを示すフラグ(隠しステータス。場の効果にすると使いづらいため、こちらと併用)
  static const int magicRoom = 195;

  /// こうげきわざを受けた回数(隠しステータス。交代・ひんしでも消えない)
  static const int attackedCount = 196;

  /// ゾロア系だとバレたあと(隠しステータス。交代でも消えない)
  static const int zoroappear = 197;

  /// テラスタルフォルム
  static const int terastalForm = 198;

  /// ステラフォルム
  static const int stellarForm = 199;

  /// ステラ補正を使用したタイプのフラグ(隠しステータス。交代でも消えない)
  static const int stellarUsed = 200;

  /// れんぞくぎり連続成功回数(隠しステータス)
  static const int furyCutter = 201;

  /// ID
  final int id;

  /// 日本語表示名
  final String _displayName;

  /// 英語表示名
  final String _displayNameEn;

  /// 表示色名
  final String _displayColorName;

  /// 継続ターン数
  final int maxTurns;

  /// 隠しステータスかどうか
  final bool isHidden;

  /// 効果のID
  final int effectID;

  /// 効果の引数1~7
  final int effectArg1;
  final int effectArg2;
  final int effectArg3;
  final int effectArg4;
  final int effectArg5;
  final int effectArg6;
  final int effectArg7;

  /// 経過ターン
  int turns = 0;

  /// 引数1
  int extraArg1 = 0;

  @override
  List<Object?> get props => [
        id,
        _displayName,
        _displayNameEn,
        _displayColorName,
        maxTurns,
        isHidden,
        effectID,
        effectArg1,
        effectArg2,
        effectArg3,
        effectArg4,
        effectArg5,
        effectArg6,
        effectArg7,
        turns,
        extraArg1,
      ];

  /// その他の補正(フォルム等)
  BuffDebuff(
    this.id,
    this._displayName,
    this._displayNameEn,
    this._displayColorName,
    this.maxTurns,
    this.isHidden,
    this.effectID,
    this.effectArg1,
    this.effectArg2,
    this.effectArg3,
    this.effectArg4,
    this.effectArg5,
    this.effectArg6,
    this.effectArg7,
  );

  /// 無効な補正を生成
  factory BuffDebuff.none() =>
      BuffDebuff(0, '', '', '', 0, false, 0, 0, 0, 0, 0, 0, 0, 0);

  @override
  BuffDebuff copy() => BuffDebuff(
      id,
      _displayName,
      _displayNameEn,
      _displayColorName,
      maxTurns,
      isHidden,
      effectID,
      effectArg1,
      effectArg2,
      effectArg3,
      effectArg4,
      effectArg5,
      effectArg6,
      effectArg7)
    ..turns = turns
    ..extraArg1 = extraArg1;

  /// 表示名
  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return maxTurns > 0
            ? '$_displayName ($turns/$maxTurns})'
            : _displayName;
      case Language.english:
      default:
        return maxTurns > 0
            ? '$_displayNameEn ($turns/$maxTurns)'
            : _displayNameEn;
    }
  }

  /// 表示背景色
  Color get bgColor {
    switch (_displayColorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'PokeTypeColor.normal':
        return PokeTypeColor.normal;
      default:
        return Colors.white;
    }
  }

  /// 効果引数のリスト
  List<int> get effectArgs => [
        effectArg1,
        effectArg2,
        effectArg3,
        effectArg4,
        effectArg5,
        effectArg6,
        effectArg7
      ];

  /// フォルムチェンジを行う(種族値変化等を行う)
  /// ```
  /// pokemonState: ポケモンの状態
  /// ```
  void changeForm(PokemonState pokemonState) {
    if (effectID == 2) {
      // フォルムチェンジによるタイプ2の変更
      pokemonState.type2 = PokeType.values[effectArg7];
    }
    if (effectID == 1 || effectID == 2) {
      // フォルムチェンジによる種族値の変更
      pokemonState.maxStats.h.race = effectArg1;
      pokemonState.minStats.h.race = effectArg1;
      pokemonState.maxStats.a.race = effectArg2;
      pokemonState.minStats.a.race = effectArg2;
      pokemonState.maxStats.b.race = effectArg3;
      pokemonState.minStats.b.race = effectArg3;
      pokemonState.maxStats.c.race = effectArg4;
      pokemonState.minStats.c.race = effectArg4;
      pokemonState.maxStats.d.race = effectArg5;
      pokemonState.minStats.d.race = effectArg5;
      pokemonState.maxStats.s.race = effectArg6;
      pokemonState.minStats.s.race = effectArg6;
      for (final stat in StatIndexList.listHtoS) {
        pokemonState.maxStats[stat].updateReal(
            pokemonState.pokemon.level, pokemonState.pokemon.nature);
        pokemonState.minStats[stat].updateReal(
            pokemonState.pokemon.level, pokemonState.pokemon.nature);
      }
    }
  }

  /// SQLに保存された文字列からBuffDebuffをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// ```
  static BuffDebuff deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return PokeDB().buffDebuffs[int.parse(elements[0])]!.copy()
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  /// SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}

/// BuffDebuff(=その他補正)のリスト
class BuffDebuffList extends Equatable implements Copyable {
  /// BuffDebuff(=その他補正)のリスト
  List<BuffDebuff> list = [];

  @override
  List<Object?> get props => [list];

  @override
  BuffDebuffList copy() =>
      BuffDebuffList()..list = [for (final bd in list) bd.copy()];

  /// 補正によるステータス変更を行う
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// stat: 変更されたステータス値
  /// statIndex: 変更対象のステータスインデックス
  /// moveType: わざのタイプ。これを指定することで、こうげき時であると判定する
  /// damageClassID: わざの分類
  /// move: わざ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double changeStat(PokemonState pokemonState, PokemonState yourState,
      double stat, StatIndex statIndex,
      {PokeType moveType = PokeType.unknown,
      int? damageClassID,
      Move? move,
      Item? holdingItem,
      bool? isFirst}) {
    return stat *
        _changeStatArg(pokemonState, yourState, statIndex,
            moveType: moveType,
            damageClassID: damageClassID,
            move: move,
            holdingItem: holdingItem,
            isFirst: isFirst);
  }

  /// 補正によって変更されたステータスを元に戻す
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// stat: 変更されたステータス値
  /// statIndex: 変更対象のステータスインデックス
  /// moveType: わざのタイプ。これを指定することで、こうげき時であると判定する
  /// damageClassID: わざの分類
  /// move: わざ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double undoStat(PokemonState pokemonState, PokemonState yourState,
      double stat, StatIndex statIndex,
      {PokeType moveType = PokeType.unknown,
      int? damageClassID,
      Move? move,
      Item? holdingItem,
      bool? isFirst}) {
    return stat /
        _changeStatArg(pokemonState, yourState, statIndex,
            moveType: moveType,
            damageClassID: damageClassID,
            move: move,
            holdingItem: holdingItem,
            isFirst: isFirst);
  }

  /// 補正によるステータス変更時に掛ける値を取得する
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// statIndex: 変更対象のステータスインデックス
  /// moveType: わざのタイプ。これを指定することで、こうげき時であると判定する
  /// damageClassID: わざの分類
  /// move: わざ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double _changeStatArg(
      PokemonState pokemonState, PokemonState yourState, StatIndex statIndex,
      {PokeType moveType = PokeType.unknown,
      int? damageClassID,
      Move? move,
      Item? holdingItem,
      bool? isFirst}) {
    double ret = 1.0;
    for (final element in list) {
      if (element.effectID == 3) {
        // 対象ステータスがxxx倍になる
        final args = element.effectArgs;
        for (int i = 0; i + 1 < args.length; i = i + 2) {
          if (args[i] == statIndex.index) {
            ret *= args[i + 1] / 100;
          }
        }
      } else if (element.effectID == 6) {
        // 【条件付き】対象ステータスがxxx倍になる
        final args = element.effectArgs;
        bool meetCondition = false; // 条件を満たすかどうか
        if (1 <= args[0] && args[0] <= 18) {
          // わざのタイプが条件
          meetCondition = moveType.index == args[0];
        } else {
          switch (args[0]) {
            case 19: // こうげき時のみ
              meetCondition = moveType.index != 0;
              break;
            case 20: // ぶつりわざでこうげきする時
              meetCondition = damageClassID == DamageClass.physical;
              break;
            case 21: // とくしゅわざでこうげきする時
              meetCondition = damageClassID == DamageClass.special;
              break;
            case 22: // へんかわざでこうげきする時
              meetCondition = damageClassID == DamageClass.status;
              break;
            case 23: // わざが直接攻撃の時
              meetCondition = move != null &&
                  move.isDirect &&
                  !(move.isPunch && holdingItem?.id == 1700);
              break;
            case 24: // わざが音技の時
              meetCondition = move != null && move.isSound;
              break;
            case 25: // わざがHP吸収技の時
              meetCondition = move != null && move.isDrain;
              break;
            case 26: // わざがパンチ技の時
              meetCondition = move != null && move.isPunch;
              break;
            case 27: // わざが波動技の時
              meetCondition = move != null && move.isWave;
              break;
            case 28: // わざがおどり技の時
              meetCondition = move != null && move.isDance;
              break;
            case 29: // わざが反動技の時
              meetCondition = move != null && move.isRecoil;
              break;
            case 30: // わざが追加効果ありの時
              meetCondition = move != null && move.isAdditionalEffect;
              break;
            case 31: // わざが追加効果あり2の時
              meetCondition = move != null && move.isAdditionalEffect2;
              break;
            case 32: // わざがかみつきわざの時
              meetCondition = move != null && move.isBite;
              break;
            case 33: // わざが切るわざの時
              meetCondition = move != null && move.isCut;
              break;
            case 34: // わざが風技の時
              meetCondition = move != null && move.isWind;
              break;
            case 35: // わざがこな系の技の時
              meetCondition = move != null && move.isPowder;
              break;
            case 36: // わざが弾の技の時
              meetCondition = move != null && move.isBullet;
              break;
            case 38: // 相手の性別が自身と同じ時
              meetCondition = pokemonState.sex.id != 0 &&
                  yourState.sex.id != 0 &&
                  pokemonState.sex.id == yourState.sex.id;
              break;
            case 39: // 相手の性別が自身と異なる時
              meetCondition = pokemonState.sex.id != 0 &&
                  yourState.sex.id != 0 &&
                  pokemonState.sex.id != yourState.sex.id;
              break;
            case 40: // 相手がこのターンにポケモン交代をしていた時
              meetCondition = yourState.hiddenBuffs
                  .containsByID(BuffDebuff.changedThisTurn);
              break;
            case 41: // 最後に行動する時
              meetCondition = isFirst != null && !isFirst;
              break;
            case 42: // わざのタイプがノーマル以外の時
              meetCondition = move?.type != PokeType.normal;
              break;
            default:
              break;
          }
        }
        if (meetCondition) {
          for (int i = 1; i + 1 < args.length; i = i + 2) {
            if (args[i] == statIndex.index) {
              ret *= args[i + 1] / 100;
            }
          }
        }
      }
    }

    // 相手の補正効果も処理する
    for (final element in yourState.buffDebuffs.list) {
      if (element.effectID == 6) {
        // 【条件付き】対象ステータスがxxx倍になる
        final args = element.effectArgs;
        bool meetCondition = false; // 条件を満たすかどうか
        if (101 <= args[0] && args[0] <= 118) {
          // 受けるわざのタイプが条件
          meetCondition = moveType.index == args[0];
        }
        if (meetCondition) {
          for (int i = 1; i + 1 < args.length; i = i + 2) {
            if (args[i] == statIndex.index) {
              ret *= args[i + 1] / 100;
            }
          }
        }
      }
    }
    return ret;
  }

  /// 補正によるわざ威力の変更を行う
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// power: わざの威力
  /// damageClassID: わざの分類ID
  /// move: わざ
  /// moveType: わざのタイプ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double changeMovePower(
      PokemonState pokemonState,
      PokemonState yourState,
      double power,
      int damageClassID,
      Move move,
      PokeType moveType,
      Item? holdingItem,
      {bool? isFirst}) {
    return power *
        _changeMovePowerArg(
            pokemonState, yourState, damageClassID, move, moveType, holdingItem,
            isFirst: isFirst);
  }

  /// 補正によって変更されたわざ威力を元に戻す
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// power: 変更されたわざの威力
  /// damageClassID: わざの分類ID
  /// move: わざ
  /// moveType: わざのタイプ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double undoMovePower(
      PokemonState pokemonState,
      PokemonState yourState,
      double power,
      int damageClassID,
      Move move,
      PokeType moveType,
      Item? holdingItem,
      {bool? isFirst}) {
    return power /
        _changeMovePowerArg(
            pokemonState, yourState, damageClassID, move, moveType, holdingItem,
            isFirst: isFirst);
  }

  /// 補正によるわざ威力の変更時に掛ける値を取得する
  /// ```
  /// pokemonState: ポケモンの状態
  /// yourState: 相手ポケモンの状態
  /// damageClassID: わざの分類ID
  /// move: わざ
  /// moveType: わざのタイプ
  /// holdingItem: もちもの
  /// isFirst: このターン最初の行動か
  /// ```
  double _changeMovePowerArg(PokemonState pokemonState, PokemonState yourState,
      int damageClassID, Move move, PokeType moveType, Item? holdingItem,
      {bool? isFirst}) {
    double ret = 1.0;

    // 他補正より先に行う補正
    final firstHosei = list
        .where((element) => element.effectID == 7 && element.extraArg1 == 37);
    if (firstHosei.isNotEmpty) {
      if (move.power <= 60) {
        ret *= firstHosei.first.effectArg2 / 100;
      }
    }

    for (final element in list) {
      if (element.effectID == 4) {
        // わざの威力がxxx倍になる
        ret *= element.effectArg1 / 100;
      } else if (element.effectID == 7) {
        // 【条件付き】わざの威力がxxx倍になる
        final args = element.effectArgs;
        for (int i = 0; i + 1 < args.length; i = i + 2) {
          bool meetCondition = false; // 条件を満たすかどうか
          if (1 <= args[i] && args[i] <= 18) {
            // わざのタイプが条件
            meetCondition = moveType.index == args[i];
          } else {
            switch (args[i]) {
              case 19: // こうげき時のみ
                meetCondition = moveType.index != 0;
                break;
              case 20: // ぶつりわざでこうげきする時
                meetCondition = damageClassID == DamageClass.physical;
                break;
              case 21: // とくしゅわざでこうげきする時
                meetCondition = damageClassID == DamageClass.special;
                break;
              case 22: // へんかわざでこうげきする時
                meetCondition = damageClassID == DamageClass.status;
                break;
              case 23: // わざが直接攻撃の時
                meetCondition =
                    move.isDirect && !(move.isPunch && holdingItem?.id == 1700);
                break;
              case 24: // わざが音技の時
                meetCondition = move.isSound;
                break;
              case 25: // わざがHP吸収技の時
                meetCondition = move.isDrain;
                break;
              case 26: // わざがパンチ技の時
                meetCondition = move.isPunch;
                break;
              case 27: // わざが波動技の時
                meetCondition = move.isWave;
                break;
              case 28: // わざがおどり技の時
                meetCondition = move.isDance;
                break;
              case 29: // わざが反動技の時
                meetCondition = move.isRecoil;
                break;
              case 30: // わざが追加効果ありの時
                meetCondition = move.isAdditionalEffect;
                break;
              case 31: // わざが追加効果あり2の時
                meetCondition = move.isAdditionalEffect2;
                break;
              case 32: // わざがかみつきわざの時
                meetCondition = move.isBite;
                break;
              case 33: // わざが切るわざの時
                meetCondition = move.isCut;
                break;
              case 34: // わざが風技の時
                meetCondition = move.isWind;
                break;
              case 35: // わざがこな系の技の時
                meetCondition = move.isPowder;
                break;
              case 36: // わざが弾の技の時
                meetCondition = move.isBullet;
                break;
              case 38: // 相手の性別が自身と同じ時
                meetCondition = pokemonState.sex.id != 0 &&
                    yourState.sex.id != 0 &&
                    pokemonState.sex.id == yourState.sex.id;
                break;
              case 39: // 相手の性別が自身と異なる時
                meetCondition = pokemonState.sex.id != 0 &&
                    yourState.sex.id != 0 &&
                    pokemonState.sex.id != yourState.sex.id;
                break;
              case 40: // 相手がこのターンにポケモン交代をしていた時
                meetCondition = yourState.hiddenBuffs
                    .containsByID(BuffDebuff.changedThisTurn);
                break;
              case 41: // 最後に行動する時
                meetCondition = isFirst != null && !isFirst;
                break;
              case 42: // わざのタイプがノーマル以外の時
                meetCondition = move.type != PokeType.normal;
                break;
              default:
                break;
            }
          }
          if (meetCondition) {
            ret *= args[i + 1] / 100;
          }
        }
      } else if (element.effectID == 9) {
        if (move.type.index != element.effectArg2 &&
            moveType.index == element.effectArg2) {
          ret *= element.effectArg3 / 100;
        }
      }
    }

    // 相手の補正効果も処理する
    for (final element in yourState.buffDebuffs.list) {
      if (element.effectID == 6) {
        // 【条件付き】対象ステータスがxxx倍になる
        final args = element.effectArgs;
        for (int i = 0; i + 1 < args.length; i = i + 2) {
          bool meetCondition = false; // 条件を満たすかどうか
          if (101 <= args[i] && args[i] <= 118) {
            // 受けるわざのタイプが条件
            meetCondition = moveType.index == args[i];
          }
          if (meetCondition) {
            ret *= args[i + 1] / 100;
          }
        }
      }
    }
    return ret;
  }

  /// 補正によるわざタイプの変更を行う
  /// ```
  /// pokemonState: ポケモンの状態
  /// moveType: わざのタイプ
  /// ```
  PokeType changeMoveType(PokemonState pokemonState, PokeType moveType) {
    PokeType ret = moveType;
    for (final element in list) {
      if (element.effectID == 5) {
        // わざのタイプがxxxになる
        ret = PokeType.values[element.effectArg1];
      } else if (element.effectID == 8 || element.effectID == 9) {
        // 【条件付き】わざのタイプがxxxになる
        final args = element.effectArgs;
        bool meetCondition = false; // 条件を満たすかどうか
        if (1 <= args[0] && args[0] <= 18) {
          // わざのタイプが条件
          meetCondition = moveType.index == args[0];
        } else {
          switch (args[0]) {
            case 19: // こうげき時のみ
              meetCondition = moveType.index != 0;
              break;
            default:
              break;
          }
        }
        if (meetCondition) {
          ret = PokeType.values[args[1]];
        }
      }
    }
    return ret;
  }

  /// 指定したIDを持つBuffDebuffを含むかどうかを返す
  /// ```
  /// id: ID
  /// ```
  bool containsByID(int id) =>
      (list.indexWhere((element) => element.id == id) >= 0);

  /// 指定したIDリストに含まれるIDを持つBuffDebuffがあるかどうかを返す
  /// ```
  /// ids: IDリスト
  /// ```
  bool containsByAnyID(List<int> ids) =>
      (list.indexWhere((element) => ids.contains(element.id)) >= 0);

  /// 指定したIDを持つBuffDebuffが無ければ追加する
  /// ```
  /// id: ID
  /// ```
  void addIfNotFoundByID(int id) {
    if (!containsByID(id)) {
      add(PokeDB().buffDebuffs[id]!.copy());
    }
  }

  /// 指定したIDを持つ最初のBuffDebuffを削除する
  /// ```
  /// id: ID
  /// ```
  void removeFirstByID(int id) {
    int findIdx = list.indexWhere((element) => element.id == id);
    if (findIdx >= 0) {
      list.removeAt(findIdx);
    }
  }

  /// 指定したIDを持つBuffDebuffをすべて削除する
  /// ```
  /// id: ID
  /// ```
  void removeAllByID(int id) => list.removeWhere((element) => element.id == id);

  /// 指定したIDリストに含まれるIDを持つBuffDebuffをすべて削除する
  /// ```
  /// ids: IDリスト
  /// ```
  void removeAllByAllID(List<int> ids) =>
      list.removeWhere((element) => ids.contains(element.id));

  /// 指定したIDを持つBuffDebuffのIterableを返す
  /// ```
  /// id: ID
  /// ```
  Iterable<BuffDebuff> whereByID(int id) =>
      list.where((element) => element.id == id);

  /// 指定したIDリストに含まれるIDを持つBuffDebuffのIterableを返す
  /// ```
  /// ids: IDリスト
  /// ```
  Iterable<BuffDebuff> whereByAnyID(List<int> ids) =>
      list.where((element) => ids.contains(element.id));

  /// 指定したIDを持つBuffDebuffがあれば削除、なければ追加する
  /// ```
  /// id: ID
  /// ```
  void removeOrAddByID(int id) {
    int findIdx = list.indexWhere((element) => element.id == id);
    if (findIdx >= 0) {
      list.removeAt(findIdx);
    } else {
      list.add(PokeDB().buffDebuffs[id]!.copy());
    }
  }

  /// 指定したIDを持つBuffDebuffがあればもう一方のIDのBuffDebuffに変更する
  /// ```
  /// id1,id2: ID
  /// ```
  void switchID(int id1, int id2) {
    int findIdx = list.indexWhere((element) => element.id == id1);
    if (findIdx >= 0) {
      list[findIdx] = PokeDB().buffDebuffs[id2]!.copy();
    } else {
      findIdx = list.indexWhere((element) => element.id == id2);
      if (findIdx >= 0) {
        list[findIdx] = PokeDB().buffDebuffs[id1]!.copy();
      }
    }
  }

  /// fromのIDを持つBuffDebuffがあればtoのIDのBuffDebuffに変更する
  /// ```
  /// from: 変更前ID
  /// to: 変更後ID
  /// 返り値: 変更したBuffDebuffのインデックス(なければ-1)
  /// ```
  int changeID(int from, int to) {
    int findIdx = list.indexWhere((element) => element.id == from);
    if (findIdx >= 0) {
      list[findIdx] = PokeDB().buffDebuffs[to]!.copy();
    }
    return findIdx;
  }

  /// 要素を追加する
  /// ```
  /// b: 追加要素
  /// ```
  void add(BuffDebuff b) => list.add(b);

  /// 要素をすべて追加する
  /// ```
  /// b: 追加要素
  /// ```
  void addAll(Iterable<BuffDebuff> b) => list.addAll(b);

  /// 要素をすべて削除する
  void clear() => list.clear();

  /// 要素数
  int get length => list.length;
}
