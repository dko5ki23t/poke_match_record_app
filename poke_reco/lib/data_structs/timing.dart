/// 発動タイミング
enum Timing {
  /// なし、無効
  none,

  /// ポケモン登場時
  pokemonAppear,

  /// こうげきわざで相手を倒したとき
  defeatOpponentWithAttack,

  /// こうげきし、相手にあたったとき(確率)
  attackSuccessedWithChance,

  /// 毎ターン終了時
  everyTurnEnd,

  /// HPが満タンでこうげきを受けた時
  hpMaxAndAttacked,

  /// ばくはつ系のわざ、とくせいが発動したとき
  blasted,

  /// まひするわざ、とくせいを受けた時
  paralysised,

  /// 天気がすなあらしのとき(永続、効果は明示されない)
  sandstormed,

  /// 直接攻撃を受けた時(確率・条件)
  directAttackedWithChance,

  /// でんきタイプのわざを受けた時
  electriced,

  /// みずタイプのわざを受けた時
  watered,

  /// メロメロ/ゆうわく/ちょうはつ/いかくの効果を受けたとき
  attractedTauntedIntimidated,

  /// 天気があるとき(未使用)
  weather,

  /// わざを使うとき(確率・条件)
  movingWithChance,

  /// ねむり・ねむけの効果を受けた時
  sleeped,

  /// どく・もうどくの効果を受けた時
  poisoned,

  /// ほのおタイプのわざを受けた時
  fired,

  /// こんらん/いかくの効果を受けた時
  confusedIntimidated,

  /// 1度でも行動した後毎ターン終了時
  afterActedEveryTurnEnd,

  /// こうたいわざやレッドカードによるこうたいを強制されたとき
  changeForced,

  /// 効果ばつぐん以外のタイプのこうげきざわを受けた時
  notGreatAttacked,

  /// じめんタイプのわざ/まきびし/どくびし/ねばねばネット/ありじごく/たがやす/フィールドの効果を受けるとき
  groundFieldEffected,

  /// 相手から受けた技でどく/まひ/やけど状態にされたとき
  poisonedParalysisedBurnedByOppositeMove,

  /// 自身以外の効果によって能力変化が起きるとき
  statChangedByNotMyself,

  /// 当該ポケモンを交代するとき(とくせい発動は明示されない)
  change,

  /// 自分以外のポケモンがでんきわざを使ったとき
  electricUse,

  /// こうげきわざを使うとき(未使用)
  attack,

  /// 天気があめのとき(永続、効果は明示されない)
  rained,

  /// 天気が晴れのとき(永続、効果は明示されない)
  sunny,

  /// ポケモン登場時、ポケモン交代時(場にいるときのみの効果)(未使用)
  pokemonAppearAndChanged,

  /// 常に発動(ただし画面には表示されない)
  passive,

  /// ひるみやいかくを受けた時
  flinchedIntimidated,

  /// こおり状態になったとき
  frozen,

  /// やけど状態になったとき
  burned,

  /// わざを受けた時(未使用)
  moveUsed,

  /// こおり/ほのおタイプのこうげき技を受けた時
  icedFired,

  /// 命中率が下がるとき、こうげきするとき
  accuracyDownedAttack,

  /// もちものを奪われたり失ったりするとき
  itemLostByOpponent,

  /// 状態異常のとき(未使用)
  ailment,

  /// HP吸収技を受けた時
  drained,

  /// HPが1/3以下のとき(未使用)
  hp033,

  /// 反動ダメージを受ける技を使ったとき(未使用)
  recoilAttack,

  /// こんらん状態でこうげきを受けた時(未使用)
  confusedAttacked,

  /// ひるんだとき
  flinched,

  /// 天気がゆきのとき(永続、効果は明示されない)
  snowed,

  /// HPが1/2以下になったとき
  hp050,

  /// こうげきが急所に当たった時
  criticaled,

  /// 場に出た後にもちものを失っている状態のとき(効果は明示されない)(未使用)
  itemLost,

  /// ほのお技を受けるとき、やけどダメージを負うとき(未使用)
  firedBurned,

  /// ほのお/みずタイプのこうげきを受けた時、天気が晴れ/あめのとき
  fireWaterAttackedSunnyRained,

  /// パンチ技を使用するとき(未使用)
  punchAttack,

  /// どく/もうどくでダメージを負うとき
  poisonDamage,

  /// 行動決定後、行動実行前
  afterActionDecision,

  /// 行動時
  action,

  /// わざ使用後
  afterMove,

  /// 連続こうげき時(1回目除く)
  continuousMove,

  /// ポケモンがひんしになったため交代
  changeFaintingPokemon,

  /// 交代わざによる交代
  changePokemonMove,

  /// 対戦終了
  gameSet,

  /// こうげきし、相手に当たったとき
  attackHitted,

  /// ポケモン登場時(天気が雨でない)
  pokemonAppearNotRained,

  /// こうげきを受けたとき
  attackedHitted,

  /// 直接攻撃を受けた時
  directAttacked,

  /// 音技を受けた時
  soundAttacked,

  /// 天気があめのとき、毎ターン終了時
  everyTurnEndRained,

  /// ポケモン登場時(天気がすなあらしでない)
  pokemonAppearNotSandStormed,

  /// 自身以外の効果によってこうげきランクが下がるとき
  attackChangedByNotMyself,

  /// 相手が道具を消費したターン終了時
  everyTurnEndOpponentItemConsumeed,

  /// 違う性別の相手から直接攻撃を受けた時（確率）
  directAttackedByOppositeSexWithChance,

  /// 毎ターン終了時（確率・条件）
  everyTurnEndWithChance,

  /// ポケモン登場時(天気が晴れでない)
  pokemonAppearNotSunny,

  /// 天気があめのとき、毎ターン終了時、かつ状態異常時
  everyTurnEndRainedWithAbnormal,

  /// 天気が晴れのとき、毎ターン終了時
  everyTurnEndSunny,

  /// 天気が晴れ状態で、状態異常にされるとき
  sunnyAbnormaled,

  /// 直接攻撃を受けてひんしになったとき
  directAttackedFainting,

  /// ポケモン登場時(確率/条件)
  pokemonAppearWithChance,

  /// いかくを受けた時
  intimidated,

  /// 自分以外のポケモンがみずわざを使ったとき
  waterUse,

  /// 天気がゆきのとき、毎ターン終了時
  everyTurnEndSnowy,

  /// ポケモン登場時(天気がゆきでない)
  pokemonAppearNotSnowed,

  /// 毎ターン終了時、相手がねむっているとき
  everyTurnEndOpponentSleep,

  /// こうげきを受けたとき(確率・条件)
  attackedHittedWithChance,

  /// ぶつりこうげきを受けたとき
  phisycalAttackedHitted,

  /// 直接攻撃をあてたとき(確率)
  directAttackHitWithChance,

  /// 自身以外の効果によってぼうぎょランクが下がるとき
  guardChangedByNotMyself,

  /// あくタイプのこうげきを受けた時
  evilAttacked,

  /// あく/ゴースト/むしタイプのこうげきを受けた時、いかくを受けた時
  evilGhostBugAttackedIntimidated,

  /// くさタイプのわざを受けた時
  grassed,

  /// メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじの効果を受けたとき
  mentalAilments,

  /// 能力を下げられたり状態異常・ねむけになるとき
  statChangeAbnormal,

  /// わざを使うとき(条件)、特定のわざを使ったとき
  movingMovedWithCondition,

  /// みずタイプのこうげきを受けた時
  waterAttacked,

  /// ほのおわざを受けるとき/みずタイプでこうげきする時/やけどを負うとき
  firedWaterAttackBurned,

  /// ポケモン登場時と毎ターン終了時（ともに条件あり）
  pokemonAppearWithChanceEveryTurnEndWithChance,

  /// 優先度1以上のわざを受けた時
  priorityMoved,

  /// こうげきを受けてひんしになったとき
  attackedFainting,

  /// 自身以外がおどりわざをつかったとき
  otherDance,

  /// 場にいるポケモンがひんしになったとき
  otherFainting,

  /// ポケモン登場時(エレキフィールドでない)
  pokemonAppearNotEreciField,

  /// ポケモン登場時(サイコフィールドでない)
  pokemonAppearNotPsycoField,

  /// ポケモン登場時(ミストフィールドでない)
  pokemonAppearNotMistField,

  /// ポケモン登場時(グラスフィールドでない)
  pokemonAppearNotGrassField,

  /// 特定のわざを使ったとき、こうげきわざを受けたとき(条件)
  movingAttacked,

  /// ほのお/みずタイプのこうげきを受けた時
  fireWaterAttacked,

  /// ぶつりこうげきを受けた時、天気がゆきに変化したとき(条件)
  phisycalAttackedHittedSnowed,

  /// フィールドが変化したとき
  fieldChanged,

  /// 行動決定後、行動実行前(確率)
  afterActionDecisionWithChance,

  /// ほのおタイプのこうげきを受けた時
  fireAtaccked,

  /// 状態異常・ねむけになるとき
  abnormaledSleepy,

  /// おいかぜ発生時、おいかぜ中にポケモン登場時、かぜ技を受けた時
  winded,

  /// こうたいわざやレッドカードによるこうたいを強制されたとき、いかくを受けた時
  changeForcedIntimidated,

  /// 天気が晴れかブーストエナジーを持っているとき
  sunnyBoostEnergy,

  /// エレキフィールドかブーストエナジーを持っているとき
  elecFieldBoostEnergy,

  /// へんかわざを受けた時
  statused,

  /// 相手の能力ランクが上昇したとき
  opponentStatUp,

  /// じめんタイプのわざを受けるとき
  grounded,

  /// テラスタルしていない毎ターン終了時
  everyTurnEndNotTerastaled,

  /// HPが1/4以下になったとき
  hp025,

  /// でんきタイプのこうげきを受けた時
  electricAttacked,

  /// こおりタイプのこうげきを受けた時
  iceAttacked,

  /// 効果ばつぐんのタイプのこうげきざわを受けた後
  greatAttacked,

  /// エレキフィールドのとき
  elecField,

  /// グラスフィールドのとき
  grassField,

  /// 音技を使ったとき
  soundAttack,

  /// とくしゅこうげきを受けたとき
  specialAttackedHitted,

  /// サイコフィールドのとき
  psycoField,

  /// ミストフィールドのとき
  mistField,

  /// わざが当たらなかったとき
  notHit,

  /// 能力ランクが下がったとき
  statDowned,

  /// トリックルームのとき
  trickRoom,

  /// ノーマルタイプのこうげきわざを使用する前
  beforeNormalAttack,

  /// 効果ばつぐんのほのおタイプのこうげきわざを受けた時
  greatFireAttacked,

  /// 効果ばつぐんのみずタイプのこうげきわざを受けた時
  greatWaterAttacked,

  /// 効果ばつぐんのでんきタイプのこうげきわざを受けた時
  greatElectricAttacked,

  /// 効果ばつぐんのくさタイプのこうげきわざを受けた時
  greatGrassAttacked,

  /// 効果ばつぐんのこおりタイプのこうげきわざを受けた時
  greatIceAttacked,

  /// 効果ばつぐんのかくとうタイプのこうげきわざを受けた時
  greatFightAttacked,

  /// 効果ばつぐんのどくタイプのこうげきわざを受けた時
  greatPoisonAttacked,

  /// 効果ばつぐんのじめんタイプのこうげきわざを受けた時
  greatGroundAttacked,

  /// 効果ばつぐんのひこうタイプのこうげきわざを受けた時
  greatFlyAttacked,

  /// 効果ばつぐんのエスパータイプのこうげきわざを受けた時
  greatPsycoAttacked,

  /// 効果ばつぐんのむしタイプのこうげきわざを受けた時
  greatBugAttacked,

  /// 効果ばつぐんのいわタイプのこうげきわざを受けた時
  greatRockAttacked,

  /// 効果ばつぐんのゴーストタイプのこうげきわざを受けた時
  greatGhostAttacked,

  /// 効果ばつぐんのドラゴンタイプのこうげきわざを受けた時
  greatDragonAttacked,

  /// 効果ばつぐんのあくタイプのこうげきわざを受けた時
  greatEvilAttacked,

  /// 効果ばつぐんのはがねタイプのこうげきわざを受けた時
  greatSteelAttacked,

  /// 効果ばつぐんのフェアリータイプのこうげきわざを受けた時
  greatFairyAttacked,

  /// ノーマルタイプのこうげきわざを受けた時
  normalAttacked,

  /// 1つのわざのPPが0になったとき
  runOutPP,

  /// 状態異常・こんらんになるとき
  abnormaledConfused,

  /// こんらんになるとき
  confused,

  /// 状態異常でない毎ターン終了時
  everyTurnEndNotAbnormal,

  /// メロメロになるとき
  infatuation,

  /// HPが1/4以下で行動決定後
  afterActionDecisionHP025,

  /// ためわざを使うとき
  chargeMoving,

  /// とくせいを変更される、無効化される、無視されるとき
  changedIgnoredAbility,

  /// ばけたすがたでこうげきを受けたとき
  attackedHittedWithBake,

  /// テラスタル選択時
  terastaling,

  /// HPが満タンでない毎ターン終了時
  everyTurnEndHPNotFull,

  /// 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
  everyTurnEndHPNotFull2,

  /// ポケモン登場時・こうげきを受けたとき
  pokemonAppearAttacked,

  /// テラスタル後
  afterTerastal,

  /// わざ使用前
  beforeMove,

  /// わざ使用前(確率・条件)
  beforeMoveWithChance,

  /// こなやほうしわざを受けた時
  powdered,

  /// 弾のわざを受けた時
  bulleted,

  /// ゾロアーク系がばれていない状態でこうげきを受けたとき
  attackedNotZoroappeared,

  /// HPが満タンで等倍以上のタイプ相性わざを受ける前
  beforeTypeNormalOrGreatAttackedWithFullHP,
}
