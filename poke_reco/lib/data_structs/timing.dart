// 発動タイミング
class AbilityTiming {
  static const int none = 0;
  static const int pokemonAppear = 1;     // ポケモン登場時
  static const int defeatOpponentWithAttack = 2;    // こうげきわざで相手を倒したとき
  static const int attackSuccessedWithChance = 3;          // こうげきし、相手にあたったとき(確率)
  static const int everyTurnEnd = 4;      // 毎ターン終了時
  static const int hpMaxAndAttacked = 5;  // HPが満タンでこうげきを受けた時
  static const int blasted = 6;           // ばくはつ系のわざ、とくせいが発動したとき
  static const int paralysised = 7;       // まひするわざ、とくせいを受けた時
  static const int sandstormed = 8;       // 天気がすなあらしのとき(永続、効果は明示されない)
  static const int directAttackedWithChance = 9;          // 直接攻撃を受けた時(確率・条件)
  static const int electriced = 10;       // でんきタイプのわざを受けた時
  static const int watered = 11;          // みずタイプのわざを受けた時
  static const int attractedTauntedIntimidated = 12;    // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
//  weather(13),          // 天気があるとき
  static const int movingWithChance = 14; // わざを使うとき(確率・条件)
  static const int sleeped = 15;          // ねむり・ねむけの効果を受けた時
  static const int poisoned = 16;         // どく・もうどくの効果を受けた時
  static const int fired = 17;            // ほのおタイプのわざを受けた時
  static const int confusedIntimidated = 18;  // こんらん/いかくの効果を受けた時
  static const int afterActedEveryTurnEnd = 19;   // 1度でも行動した後毎ターン終了時
  static const int changeForced = 20;     // こうたいわざやレッドカードによるこうたいを強制されたとき
  static const int notGreatAttacked = 21; // 効果ばつぐん以外のタイプのこうげきざわを受けた時
  static const int groundFieldEffected = 22;  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  static const int poisonedParalysisedBurnedByOppositeMove = 23;    // 相手から受けた技でどく/まひ/やけど状態にされたとき
  static const int statChangedByNotMyself = 24;   // 自身以外の効果によって能力変化が起きるとき
  static const int change = 25;           // 当該ポケモンを交代するとき(とくせい発動は明示されない)
  static const int electricUse = 26;      // 自分以外のポケモンがでんきわざを使ったとき
//  attack(27),           // こうげきわざを使うとき
  static const int rained = 28;           // 天気があめのとき(永続、効果は明示されない)
  static const int sunny = 29;            // 天気が晴れのとき(永続、効果は明示されない)
//  pokemonAppearAndChanged(30),     // ポケモン登場時、ポケモン交代時(場にいるときのみの効果)
  static const int passive = 31;          // 常に発動(ただし画面には表示されない)
  static const int flinchedIntimidated = 32;  // ひるみやいかくを受けた時
  static const int frozen = 33;           // こおり状態になったとき
  static const int burned = 34;           // やけど状態になったとき
//  moveUsed(35),         // わざを受けた時
  static const int icedFired = 36;        // こおり/ほのおタイプのこうげき技を受けた時
  static const int accuracyDownedAttack = 37;    // 命中率が下がるとき、こうげきするとき
  static const int itemLostByOpponent = 38;   // もちものを奪われたり失ったりするとき
//  ailment(39),          // 状態異常のとき
  static const int drained = 40;          // HP吸収技を受けた時
//  HP033(41),            // HPが1/3以下のとき
//  recoilAttack(42),     // 反動ダメージを受ける技を使ったとき
//  confusedAttacked(43), // こんらん状態でこうげきを受けた時
  static const int flinched = 44;         // ひるんだとき
  static const int snowed = 45;           // 天気がゆきのとき(永続、効果は明示されない)
  static const int hp050 = 46;                  // HPが1/2以下になったとき
  static const int criticaled = 47;       // こうげきが急所に当たった時
//  static const int itemLost = 48;         // 場に出た後にもちものを失っている状態のとき(効果は明示されない)
//  firedBurned(49),      // ほのお技を受けるとき、やけどダメージを負うとき
  static const int fireWaterAttackedSunnyRained = 50;   // ほのお/みずタイプのこうげきを受けた時、天気が晴れ/あめのとき
//  static const int punchAttack = 51;      // パンチ技を使用するとき
  static const int poisonDamage = 52;           // どく/もうどくでダメージを負うとき
  static const int afterActionDecision = 53;    // 行動決定後、行動実行前
  static const int action = 54;                 // 行動時
  static const int afterMove = 55;              // わざ使用後
  static const int continuousMove = 56;         // 連続こうげき時(1回目除く)
  static const int changeFaintingPokemon = 57;  // ポケモンがひんしになったため交代
  static const int changePokemonMove = 58;      // 交代わざによる交代
  static const int gameSet = 59;                // 対戦終了
  static const int attackHitted = 60;           // こうげきし、相手に当たったとき
  static const int pokemonAppearNotRained = 61; // ポケモン登場時(天気が雨でない)
  static const int attackedHitted = 62;         // こうげきを受けたとき
  static const int directAttacked = 63;         // 直接攻撃を受けた時
  static const int soundAttacked = 64;          // 音技を受けた時
  static const int everyTurnEndRained = 65;     // 天気があめのとき、毎ターン終了時
  static const int pokemonAppearNotSandStormed = 66; // ポケモン登場時(天気がすなあらしでない)
  static const int attackChangedByNotMyself = 67;   // 自身以外の効果によってこうげきランクが下がるとき
  static const int everyTurnEndOpponentItemConsumeed = 68;  // 相手が道具を消費したターン終了時
  static const int directAttackedByOppositeSexWithChance = 69;  // 違う性別の相手から直接攻撃を受けた時（確率）
  static const int everyTurnEndWithChance = 70;  // 毎ターン終了時（確率・条件）
  static const int pokemonAppearNotSunny = 71;  // ポケモン登場時(天気が晴れでない)
  static const int everyTurnEndRainedWithAbnormal = 72;     // 天気があめのとき、毎ターン終了時、かつ状態異常時
  static const int everyTurnEndSunny = 73;      // 天気が晴れのとき、毎ターン終了時
  static const int sunnyAbnormaled = 74;        // 天気が晴れ状態で、状態異常にされるとき
  static const int directAttackedFainting = 75; // 直接攻撃を受けてひんしになったとき
  static const int pokemonAppearWithChance = 76;    // ポケモン登場時(確率/条件)
  static const int intimidated = 77;            // いかくを受けた時
  static const int waterUse = 78;               // 自分以外のポケモンがみずわざを使ったとき
  static const int everyTurnEndSnowy = 79;      // 天気がゆきのとき、毎ターン終了時
  static const int pokemonAppearNotSnowed = 80; // ポケモン登場時(天気がゆきでない)
  static const int everyTurnEndOpponentSleep = 81;  // 毎ターン終了時、相手がねむっているとき
  static const int attackedHittedWithChance = 82;   // こうげきを受けたとき(確率・条件)
  static const int phisycalAttackedHitted = 83;     // ぶつりこうげきを受けたとき
  static const int directAttackHitWithChance = 84;  // 直接攻撃をあてたとき(確率)
  static const int guardChangedByNotMyself = 85;    // 自身以外の効果によってぼうぎょランクが下がるとき
  static const int evilAttacked = 86;               // あくタイプのこうげきを受けた時
  static const int evilGhostBugAttackedIntimidated = 87;  // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  static const int grassed = 88;                    // くさタイプのわざを受けた時
  static const int mentalAilments = 89;         // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  static const int statChangeAbnormal = 90;     // 能力を下げられたり状態異常・ねむけになるとき
  static const int movingMovedWithCondition = 91;   // わざを使うとき(条件)、特定のわざを使ったとき
  static const int waterAttacked = 92;          // みずタイプのこうげきを受けた時
  static const int firedWaterAttackBurned = 93; // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  static const int pokemonAppearWithChanceEveryTurnEndWithChance = 94;  // ポケモン登場時と毎ターン終了時（ともに条件あり）
  static const int priorityMoved = 95;          // 優先度1以上のわざを受けた時
  static const int attackedFainting = 96;       // こうげきを受けてひんしになったとき
  static const int otherDance = 97;             // 自身以外がおどりわざをつかったとき
  static const int otherFainting = 98;          // 場にいるポケモンがひんしになったとき
  static const int pokemonAppearNotEreciField = 99;   // ポケモン登場時(エレキフィールドでない)
  static const int pokemonAppearNotPsycoField = 100;  // ポケモン登場時(サイコフィールドでない)
  static const int pokemonAppearNotMistField = 101;   // ポケモン登場時(ミストフィールドでない)
  static const int pokemonAppearNotGrassField = 102;  // ポケモン登場時(グラスフィールドでない)
  static const int movingAttacked = 103;        // 特定のわざを使ったとき、こうげきわざを受けたとき(条件)
  static const int fireWaterAttacked = 104;     // ほのお/みずタイプのこうげきを受けた時
  static const int phisycalAttackedHittedSnowed = 105;  // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  static const int fieldChanged = 106;          // フィールドが変化したとき
  static const int afterActionDecisionWithChance = 107;    // 行動決定後、行動実行前(確率)
  static const int fireAtaccked = 107;          // ほのおタイプのこうげきを受けた時
  static const int abnormaledSleepy = 108;      // 状態異常・ねむけになるとき
  static const int winded = 109;                // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  static const int changeForcedIntimidated = 110;   // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  static const int sunnyBoostEnergy = 111;      // 天気が晴れかブーストエナジーを持っているとき
  static const int elecFieldBoostEnergy = 112;  // エレキフィールドかブーストエナジーを持っているとき
  static const int statused = 113;              // へんかわざを受けた時
  static const int opponentStatUp = 114;        // 相手の能力ランクが上昇したとき
  static const int grounded = 115;              // じめんタイプのわざを受けるとき
  static const int everyTurnEndNotTerastaled = 116;   // テラスタルしていない毎ターン終了時
  static const int hp025 = 117;                 // HPが1/4以下になったとき
  static const int electricAttacked = 118;      // でんきタイプのこうげきを受けた時
  static const int iceAttacked = 119;           // こおりタイプのこうげきを受けた時
  static const int greatAttacked = 120;         // 効果ばつぐんのタイプのこうげきざわを受けた時
  static const int elecField = 121;             // エレキフィールドのとき
  static const int grassField = 122;            // グラスフィールドのとき
  static const int soundAttack = 123;           // 音技を使ったとき
  static const int specialAttackedHitted = 124; // とくしゅこうげきを受けたとき
  static const int psycoField = 125;            // サイコフィールドのとき
  static const int mistField = 126;             // ミストフィールドのとき
  static const int notHit = 127;                // わざが当たらなかったとき
  static const int statDowned = 128;            // 能力ランクが下がったとき
  static const int trickRoom = 129;             // トリックルームのとき
  static const int normalAttackHit = 130;       // ノーマルタイプのこうげきわざが当たった時
  static const int greatFireAttacked = 131;     // 効果ばつぐんのほのおタイプのこうげきわざを受けた時
  static const int greatWaterAttacked = 132;    // 効果ばつぐんのみずタイプのこうげきわざを受けた時
  static const int greatElectricAttacked = 133; // 効果ばつぐんのでんきタイプのこうげきわざを受けた時
  static const int greatgrassAttacked = 134;    // 効果ばつぐんのくさタイプのこうげきわざを受けた時
  static const int greatIceAttacked = 135;      // 効果ばつぐんのこおりタイプのこうげきわざを受けた時
  static const int greatFightAttacked = 136;    // 効果ばつぐんのかくとうタイプのこうげきわざを受けた時
  static const int greatPoisonAttacked = 137;   // 効果ばつぐんのどくタイプのこうげきわざを受けた時
  static const int greatGroundAttacked = 138;   // 効果ばつぐんのじめんタイプのこうげきわざを受けた時
  static const int greatAirAttacked = 139;      // 効果ばつぐんのひこうタイプのこうげきわざを受けた時
  static const int greatPsycoAttacked = 140;    // 効果ばつぐんのエスパータイプのこうげきわざを受けた時
  static const int greatBugAttacked = 141;      // 効果ばつぐんのむしタイプのこうげきわざを受けた時
  static const int greatRockAttacked = 142;     // 効果ばつぐんのいわタイプのこうげきわざを受けた時
  static const int greatGhostAttacked = 143;    // 効果ばつぐんのゴーストタイプのこうげきわざを受けた時
  static const int greatDragonAttacked = 144;   // 効果ばつぐんのドラゴンタイプのこうげきわざを受けた時
  static const int greatEvilAttacked = 145;     // 効果ばつぐんのあくタイプのこうげきわざを受けた時
  static const int greatSteelAttacked = 146;    // 効果ばつぐんのはがねタイプのこうげきわざを受けた時
  static const int greatFairyAttacked = 147;    // 効果ばつぐんのフェアリータイプのこうげきわざを受けた時
  static const int normalAttacked = 148;        // ノーマルタイプのこうげきわざを受けた時
  static const int runOutPP = 149;              // 1つのわざのPPが0になったとき
  static const int abnormaledConfused = 150;    // 状態異常・こんらんになるとき
  static const int confused = 151;              // こんらんになるとき
  static const int everyTurnEndNotAbnormal = 152;   // 状態異常でない毎ターン終了時
  static const int infatuation = 153;           // メロメロになるとき
  static const int afterActionDecisionHP025 = 154;  // HPが1/4以下で行動決定後
  static const int chargeMoving = 155;          // ためわざを使うとき
  static const int changedIgnoredAbility = 156; // とくせいを変更される、無効化される、無視されるとき
  static const int attackedHittedWithBake = 157;  // ばけたすがたでこうげきを受けたとき

  const AbilityTiming(this.id);

  final int id;
}