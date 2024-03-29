// 発動タイミング
enum Timing {
  none,
  pokemonAppear,     // ポケモン登場時
  defeatOpponentWithAttack,    // こうげきわざで相手を倒したとき
  attackSuccessedWithChance,          // こうげきし、相手にあたったとき(確率)
  everyTurnEnd,      // 毎ターン終了時
  hpMaxAndAttacked,  // HPが満タンでこうげきを受けた時
  blasted,           // ばくはつ系のわざ、とくせいが発動したとき
  paralysised,       // まひするわざ、とくせいを受けた時
  sandstormed,       // 天気がすなあらしのとき(永続、効果は明示されない)
  directAttackedWithChance,          // 直接攻撃を受けた時(確率・条件)
  electriced,       // でんきタイプのわざを受けた時
  watered,          // みずタイプのわざを受けた時
  attractedTauntedIntimidated,    // メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
/* 未使用 */  weather,          // 天気があるとき
  movingWithChance, // わざを使うとき(確率・条件)
  sleeped,          // ねむり・ねむけの効果を受けた時
  poisoned,         // どく・もうどくの効果を受けた時
  fired,            // ほのおタイプのわざを受けた時
  confusedIntimidated,  // こんらん/いかくの効果を受けた時
  afterActedEveryTurnEnd,   // 1度でも行動した後毎ターン終了時
  changeForced,     // こうたいわざやレッドカードによるこうたいを強制されたとき
  notGreatAttacked, // 効果ばつぐん以外のタイプのこうげきざわを受けた時
  groundFieldEffected,  // じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  poisonedParalysisedBurnedByOppositeMove,    // 相手から受けた技でどく/まひ/やけど状態にされたとき
  statChangedByNotMyself,   // 自身以外の効果によって能力変化が起きるとき
  change,           // 当該ポケモンを交代するとき(とくせい発動は明示されない)
  electricUse,      // 自分以外のポケモンがでんきわざを使ったとき
/* 未使用 */  attack,           // こうげきわざを使うとき
  rained,           // 天気があめのとき(永続、効果は明示されない)
  sunny,            // 天気が晴れのとき(永続、効果は明示されない)
/* 未使用 */  pokemonAppearAndChanged,     // ポケモン登場時、ポケモン交代時(場にいるときのみの効果)
  passive,          // 常に発動(ただし画面には表示されない)
  flinchedIntimidated,  // ひるみやいかくを受けた時
  frozen,           // こおり状態になったとき
  burned,           // やけど状態になったとき
/* 未使用 */  moveUsed,         // わざを受けた時
  icedFired,        // こおり/ほのおタイプのこうげき技を受けた時
  accuracyDownedAttack,    // 命中率が下がるとき、こうげきするとき
  itemLostByOpponent,   // もちものを奪われたり失ったりするとき
/* 未使用 */  ailment,          // 状態異常のとき
  drained,          // HP吸収技を受けた時
/* 未使用 */  hp033,            // HPが1/3以下のとき
/* 未使用 */  recoilAttack,     // 反動ダメージを受ける技を使ったとき
/* 未使用 */  confusedAttacked, // こんらん状態でこうげきを受けた時
  flinched,         // ひるんだとき
  snowed,           // 天気がゆきのとき(永続、効果は明示されない)
  hp050,                  // HPが1/2以下になったとき
  criticaled,       // こうげきが急所に当たった時
/* 未使用 */  itemLost,         // 場に出た後にもちものを失っている状態のとき(効果は明示されない)
/* 未使用 */  firedBurned,      // ほのお技を受けるとき、やけどダメージを負うとき
  fireWaterAttackedSunnyRained,   // ほのお/みずタイプのこうげきを受けた時、天気が晴れ/あめのとき
/* 未使用 */  punchAttack,      // パンチ技を使用するとき
  poisonDamage,           // どく/もうどくでダメージを負うとき
  afterActionDecision,    // 行動決定後、行動実行前
  action,                 // 行動時
  afterMove,              // わざ使用後
  continuousMove,         // 連続こうげき時(1回目除く)
  changeFaintingPokemon,  // ポケモンがひんしになったため交代
  changePokemonMove,      // 交代わざによる交代
  gameSet,                // 対戦終了
  attackHitted,           // こうげきし、相手に当たったとき
  pokemonAppearNotRained, // ポケモン登場時(天気が雨でない)
  attackedHitted,         // こうげきを受けたとき
  directAttacked,         // 直接攻撃を受けた時
  soundAttacked,          // 音技を受けた時
  everyTurnEndRained,     // 天気があめのとき、毎ターン終了時
  pokemonAppearNotSandStormed, // ポケモン登場時(天気がすなあらしでない)
  attackChangedByNotMyself,   // 自身以外の効果によってこうげきランクが下がるとき
  everyTurnEndOpponentItemConsumeed,  // 相手が道具を消費したターン終了時
  directAttackedByOppositeSexWithChance,  // 違う性別の相手から直接攻撃を受けた時（確率）
  everyTurnEndWithChance,  // 毎ターン終了時（確率・条件）
  pokemonAppearNotSunny,  // ポケモン登場時(天気が晴れでない)
  everyTurnEndRainedWithAbnormal,     // 天気があめのとき、毎ターン終了時、かつ状態異常時
  everyTurnEndSunny,      // 天気が晴れのとき、毎ターン終了時
  sunnyAbnormaled,        // 天気が晴れ状態で、状態異常にされるとき
  directAttackedFainting, // 直接攻撃を受けてひんしになったとき
  pokemonAppearWithChance,    // ポケモン登場時(確率/条件)
  intimidated,            // いかくを受けた時
  waterUse,               // 自分以外のポケモンがみずわざを使ったとき
  everyTurnEndSnowy,      // 天気がゆきのとき、毎ターン終了時
  pokemonAppearNotSnowed, // ポケモン登場時(天気がゆきでない)
  everyTurnEndOpponentSleep,  // 毎ターン終了時、相手がねむっているとき
  attackedHittedWithChance,   // こうげきを受けたとき(確率・条件)
  phisycalAttackedHitted,     // ぶつりこうげきを受けたとき
  directAttackHitWithChance,  // 直接攻撃をあてたとき(確率)
  guardChangedByNotMyself,    // 自身以外の効果によってぼうぎょランクが下がるとき
  evilAttacked,               // あくタイプのこうげきを受けた時
  evilGhostBugAttackedIntimidated,  // あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  grassed,                    // くさタイプのわざを受けた時
  mentalAilments,         // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  statChangeAbnormal,     // 能力を下げられたり状態異常・ねむけになるとき
  movingMovedWithCondition,   // わざを使うとき(条件)、特定のわざを使ったとき
  waterAttacked,          // みずタイプのこうげきを受けた時
  firedWaterAttackBurned, // ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  pokemonAppearWithChanceEveryTurnEndWithChance,  // ポケモン登場時と毎ターン終了時（ともに条件あり）
  priorityMoved,          // 優先度1以上のわざを受けた時
  attackedFainting,       // こうげきを受けてひんしになったとき
  otherDance,             // 自身以外がおどりわざをつかったとき
  otherFainting,          // 場にいるポケモンがひんしになったとき
  pokemonAppearNotEreciField,   // ポケモン登場時(エレキフィールドでない)
  pokemonAppearNotPsycoField,  // ポケモン登場時(サイコフィールドでない)
  pokemonAppearNotMistField,   // ポケモン登場時(ミストフィールドでない)
  pokemonAppearNotGrassField,  // ポケモン登場時(グラスフィールドでない)
  movingAttacked,         // 特定のわざを使ったとき、こうげきわざを受けたとき(条件)
  fireWaterAttacked,      // ほのお/みずタイプのこうげきを受けた時
  phisycalAttackedHittedSnowed,  // ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  fieldChanged,           // フィールドが変化したとき
  afterActionDecisionWithChance,    // 行動決定後、行動実行前(確率)
  fireAtaccked,           // ほのおタイプのこうげきを受けた時
  abnormaledSleepy,       // 状態異常・ねむけになるとき
  winded,                 // おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  changeForcedIntimidated,  // こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  sunnyBoostEnergy,       // 天気が晴れかブーストエナジーを持っているとき
  elecFieldBoostEnergy,   // エレキフィールドかブーストエナジーを持っているとき
  statused,               // へんかわざを受けた時
  opponentStatUp,         // 相手の能力ランクが上昇したとき
  grounded,               // じめんタイプのわざを受けるとき
  everyTurnEndNotTerastaled,   // テラスタルしていない毎ターン終了時
  hp025,                  // HPが1/4以下になったとき
  electricAttacked,       // でんきタイプのこうげきを受けた時
  iceAttacked,            // こおりタイプのこうげきを受けた時
  greatAttacked,          // 効果ばつぐんのタイプのこうげきざわを受けた時
  elecField,              // エレキフィールドのとき
  grassField,             // グラスフィールドのとき
  soundAttack,            // 音技を使ったとき
  specialAttackedHitted,  // とくしゅこうげきを受けたとき
  psycoField,             // サイコフィールドのとき
  mistField,              // ミストフィールドのとき
  notHit,                 // わざが当たらなかったとき
  statDowned,             // 能力ランクが下がったとき
  trickRoom,              // トリックルームのとき
  normalAttackHit,        // ノーマルタイプのこうげきわざが当たった時
  greatFireAttacked,      // 効果ばつぐんのほのおタイプのこうげきわざを受けた時
  greatWaterAttacked,     // 効果ばつぐんのみずタイプのこうげきわざを受けた時
  greatElectricAttacked,  // 効果ばつぐんのでんきタイプのこうげきわざを受けた時
  greatgrassAttacked,     // 効果ばつぐんのくさタイプのこうげきわざを受けた時
  greatIceAttacked,       // 効果ばつぐんのこおりタイプのこうげきわざを受けた時
  greatFightAttacked,     // 効果ばつぐんのかくとうタイプのこうげきわざを受けた時
  greatPoisonAttacked,    // 効果ばつぐんのどくタイプのこうげきわざを受けた時
  greatGroundAttacked,    // 効果ばつぐんのじめんタイプのこうげきわざを受けた時
  greatFlyAttacked,       // 効果ばつぐんのひこうタイプのこうげきわざを受けた時
  greatPsycoAttacked,     // 効果ばつぐんのエスパータイプのこうげきわざを受けた時
  greatBugAttacked,       // 効果ばつぐんのむしタイプのこうげきわざを受けた時
  greatRockAttacked,      // 効果ばつぐんのいわタイプのこうげきわざを受けた時
  greatGhostAttacked,     // 効果ばつぐんのゴーストタイプのこうげきわざを受けた時
  greatDragonAttacked,    // 効果ばつぐんのドラゴンタイプのこうげきわざを受けた時
  greatEvilAttacked,      // 効果ばつぐんのあくタイプのこうげきわざを受けた時
  greatSteelAttacked,     // 効果ばつぐんのはがねタイプのこうげきわざを受けた時
  greatFairyAttacked,     // 効果ばつぐんのフェアリータイプのこうげきわざを受けた時
  normalAttacked,         // ノーマルタイプのこうげきわざを受けた時
  runOutPP,               // 1つのわざのPPが0になったとき
  abnormaledConfused,     // 状態異常・こんらんになるとき
  confused,               // こんらんになるとき
  everyTurnEndNotAbnormal,   // 状態異常でない毎ターン終了時
  infatuation,            // メロメロになるとき
  afterActionDecisionHP025,  // HPが1/4以下で行動決定後
  chargeMoving,           // ためわざを使うとき
  changedIgnoredAbility,  // とくせいを変更される、無効化される、無視されるとき
  attackedHittedWithBake, // ばけたすがたでこうげきを受けたとき
  terastaling,            // テラスタル選択時
  everyTurnEndHPNotFull,  // HPが満タンでない毎ターン終了時
  everyTurnEndHPNotFull2, // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
  pokemonAppearAttacked,  // ポケモン登場時・こうげきを受けたとき
  afterTerastal,          // テラスタル後
  beforeMove,             // わざ使用前
  beforeMoveWithChance,   // わざ使用前(確率・条件)
  powdered,               // こなやほうしわざを受けた時
  bulleted,               // 弾のわざを受けた時
  attackedNotZoroappeared,   // ゾロアーク系がばれていない状態でこうげきを受けたとき
  beforeTypeNormalOrGreatAttackedWithFullHP,   // HPが満タンで等倍以上のタイプ相性わざを受ける前
}
