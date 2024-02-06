import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/tool.dart';

/// 対象(値はpokeAPIから引用)
enum Target {
  /// なし
  none,

  /// (1)特殊
  specificMove,

  /// (2)？？
  selectedPokemonMeFirst,

  /// (3)味方
  ally,

  /// (4)自分の場
  usersField,

  /// (5)自分自身or味方
  userOrAlly,

  /// (6)相手の場
  opponentsField,

  /// (7)自分自身
  user,

  /// (8)ランダムな相手
  randomOpponent,

  /// (9)他のすべてのポケモン
  allOtherPokemon,

  /// (10)選択した相手
  selectedPokemon,

  /// (11)すべての相手ポケモン
  allOpponents,

  /// (12)両者の場
  entireField,

  /// (13)自分自身とすべての味方
  userAndAllies,

  /// (14)すべてのポケモン
  allPokemon,

  /// (15)すべての味方
  allAllies,

  /// (16)ひんしになったポケモン
  faintingPokemon,
}

/// わざの効果(IDはpokeAPIのmove_effect_idに対応)
class MoveEffect extends Equatable {
  /// なし、無効
  static const int none = 0;

  const MoveEffect(this.id);

  @override
  List<Object> get props => [id];

  /// ID
  final int id;
}

/// わざの分類、ダメージ分類
class DamageClass extends Equatable {
  /// なし、無効
  static const int none = 0;

  /// へんか(ダメージなし)
  static const int status = 1;

  /// ぶつり
  static const int physical = 2;

  /// とくしゅ
  static const int special = 3;

  const DamageClass(this.id);

  @override
  List<Object?> get props => [id];

  /// ID
  final int id;
}

/// わざの情報を管理するclass
class Move extends Equatable implements Copyable {
  /// ID
  final int id;

  /// 名前(日本語)
  late final String _displayName;

  /// 名前(英語)
  late final String _displayNameEn;

  /// わざのタイプ
  final PokeType type;

  /// 威力
  int power;

  /// 命中率
  int accuracy;

  /// 優先度
  int priority;

  /// 対象
  Target target;

  /// 分類
  DamageClass damageClass;

  /// 追加効果
  MoveEffect effect;

  /// 追加効果発動率
  int effectChance;

  /// 初期最大PP
  final int pp;

  @override
  List<Object?> get props => [
        id,
        _displayName,
        _displayNameEn,
        type,
        power,
        accuracy,
        priority,
        target,
        damageClass,
        effect,
        effectChance,
        pp,
      ];

  /// わざ
  Move(
    this.id,
    String displayName,
    String displayNameEn,
    this.type,
    this.power,
    this.accuracy,
    this.priority,
    this.target,
    this.damageClass,
    this.effect,
    this.effectChance,
    this.pp,
  ) {
    _displayName = displayName;
    _displayNameEn = displayNameEn;
  }

  /// 無効なわざを生成
  factory Move.none() => Move(0, '', '', PokeType.unknown, 0, 0, 0, Target.none,
      DamageClass(0), MoveEffect(0), 0, 0);

  /// 名前
  String get displayName {
    switch (PokeDB().language) {
      case Language.english:
        return _displayNameEn;
      case Language.japanese:
      default:
        return _displayName;
    }
  }

  /// 有効かどうか
  bool get isValid => id != 0;

  /// 相手を対象に含むかどうか
  bool get isTargetYou {
    const list = [
      Target.opponentsField,
      Target.randomOpponent,
      Target.allOtherPokemon,
      Target.selectedPokemon,
      Target.allOpponents,
      Target.allPokemon
    ];
    return list.contains(target);
  }

  /// 最小の最大PP
  int get minPP => pp;

  /// 最大の最大PP
  int get maxPP {
    if (pp == 1) return 1;
    return pp + (pp / 5).floor() * 3;
  }

  /// 直接攻撃かどうか
  bool get isDirect {
    const physicalButNot = [
      843,
      788,
      895,
      621,
      856,
      88,
      157,
      479,
      783,
      854,
      780,
      662,
      317,
      439,
      616,
      559,
      454,
      420,
      143,
      614,
      615,
      864,
      89,
      363,
      523,
      120,
      708,
      90,
      799,
      794,
      444,
      328,
      221,
      897,
      153,
      833,
      591,
      441,
      402,
      331,
      41,
      121,
      140,
      619,
      556,
      333,
      893,
      851,
      40,
      839,
      131,
      751,
      778,
      870,
      374,
      6,
      896,
      75,
      572,
      290,
      836,
      899,
      364,
      722,
      251,
      553,
      824,
      217,
      198,
      898,
      809,
      125,
      155,
      900,
      222,
      443,
      42,
      594,
      368,
      350,
    ];
    const specialButNot = [
      879,
      376,
      447,
      378,
      577,
      80,
      611,
    ];
    return ((damageClass.id == DamageClass.physical &&
            !physicalButNot.contains(id)) ||
        (damageClass.id == DamageClass.special && specialButNot.contains(id)));
  }

  /// 音技かどうか
  bool get isSound {
    const soundMoveIDs = [
      547,
      173,
      215,
      103,
      47,
      664,
      497,
      786,
      448,
      568,
      319,
      320,
      253,
      691,
      575,
      775,
      10016,
      574,
      48,
      336,
      590,
      45,
      555,
      304,
      586,
      826,
      871,
      728,
      46,
      195,
      405,
      496,
      463,
      914,
    ];
    return soundMoveIDs.contains(id);
  }

  /// HP吸収わざかどうか
  bool get isDrain {
    const drainMoveIDs = [
      202,
      141,
      71,
      72,
      73,
      138,
      409,
      532,
      613,
      577,
      570,
      668,
      891,
    ];
    return drainMoveIDs.contains(id);
  }

  /// パンチわざかどうか
  bool get isPunch {
    const punchMoveIDs = [
      359,
      665,
      817,
      9,
      264,
      612,
      309,
      857,
      325,
      818,
      327,
      742,
      409,
      223,
      418,
      146,
      838,
      721,
      889,
      7,
      183,
      5,
      8,
      4,
    ];
    return punchMoveIDs.contains(id);
  }

  /// はどうわざかどうか
  bool get isWave {
    const waveMoveIDs = [
      399,
      618,
      805,
      396,
      352,
      406,
      505,
    ];
    return waveMoveIDs.contains(id);
  }

  /// おどりわざかどうか
  bool get isDance {
    const danceMoveIDs = [
      872,
      837,
      775,
      483,
      14,
      80,
      297,
      298,
      552,
      461,
      686,
      349,
    ];
    return danceMoveIDs.contains(id);
  }

  /// 反動わざかどうか(とくせい「すてみ」の対象)
  bool get isRecoil {
    const recoilMoveIDs = [
      543,
      834,
      452,
      853,
      66,
      38,
      36,
      26,
      136,
      617,
      394,
      413,
      344,
      457,
      528,
    ];
    return recoilMoveIDs.contains(id);
  }

  /// 追加効果があるこうげきわざかどうか(とくせい「ちからずく」の対象)
  /// 追加効果＋追加効果とみなされない効果(自身のこおりを溶かしつつ相手をやけどにする等)の場合はfalseを返す
  bool get isAdditionalEffect {
    const additionalEffectMoveIDs = [
      677,
      664,
      703,
      662,
      830,
      864,
      675,
      845,
      290,
      826,
      903,
      440,
      143,
      843,
      840,
      394,
      344,
    ];
    const noAdditionalEffectMoveIDs = [
      165,
      720,
      796,
      835,
      276,
      621,
      799,
      691,
      874,
      315,
      354,
      437,
      434,
      705,
      359,
      665,
      859,
      890,
      370,
      838,
      620,
      557,
      130,
      800,
      565,
      499,
      265,
      358,
      479,
      614,
      615,
      746,
      687,
      168,
      343,
      365,
      450,
      282,
      510,
      481,
      99,
      37,
      80,
      200,
      833,
      253,
      682,
      892,
      721,
      727,
      798,
      861,
      364,
      467,
      566,
      593,
      621,
      712,
      280,
      706,
      873,
      6,
      874,
      690,
    ];
    const noAdditionalEffectIDs = [
      // 追加効果とみなされない追加効果
      1, 104, 86, 370, 371, 379, 383, 406, 417, 439, // 追加効果なし
      4, 9, 33, 49, 133, 199, 255, 270, 346, 349, 382, 387, 420, 441,
      388, // HP吸収
      18, 79, 381, // 必中
      43, 262, // バインド状態にする
      44, 289, 422, 462, 486, // 急所に当たりやすい/急所確定
      8, 169, 221, 271, 321, 450, // ひんしになる
      81, // 次のターン動けない
      126, 254, 275, 460, 490, 500, // こおりをかいふくする
      29, 314, 128, 154, 229, 347, 492, 493, // 自分/あいてを交代
    ];
    if (damageClass.id == 1) return true;
    if (additionalEffectMoveIDs.contains(id)) return true;
    if (noAdditionalEffectMoveIDs.contains(id)) return false;
    if (isRecoil) return false;
    return (damageClass.id > 1 && !noAdditionalEffectIDs.contains(effect.id));
  }

  /// 追加効果があるこうげきわざかどうか(とくせい「ちからずく」の対象)
  /// 追加効果＋追加効果とみなされない効果(自身のこおりを溶かしつつ相手をやけどにする等)の場合はtrueを返す
  bool get isAdditionalEffect2 {
    bool ret = isAdditionalEffect;
    const additionalEffectIDs = [
      // 追加効果も含まれている追加効果
      126, 254, 275, 460, 490, 500, // こおりをかいふくする
    ];
    if (additionalEffectIDs.contains(effect.id)) ret = true;
    return ret;
  }

  /// かみつきわざかどうか
  bool get isBite {
    const biteMoveIDs = [
      755,
      242,
      44,
      422,
      746,
      423,
      706,
      305,
      158,
      424,
    ];
    return biteMoveIDs.contains(id);
  }

  /// 切るわざかどうか
  bool get isCut {
    const cutMoveIDs = [
      895,
      15,
      314,
      403,
      830,
      781,
      163,
      440,
      427,
      875,
      534,
      404,
      548,
      533,
      669,
      400,
      332,
      869,
      860,
      75,
      845,
      891,
      348,
      210,
      910,
      911,
    ];
    return cutMoveIDs.contains(id);
  }

  /// 風わざかどうか
  bool get isWind {
    const windMoveIDs = [
      314,
      16,
      847,
      846,
      196,
      239,
      848,
      257,
      572,
      831,
      18,
      59,
      542,
      584,
    ];
    return windMoveIDs.contains(id);
  }

  /// こなやほうしのわざかどうか
  bool get isPowder {
    const powderMoveIDs = [
      476,
      147,
      78,
      77,
      79,
      600,
      750,
      178,
    ];
    return powderMoveIDs.contains(id);
  }

  /// 弾のわざかどうか
  bool get isBullet {
    const bulletMoveIDs = [
      301,
      491,
      311,
      412,
      486,
      190,
      545,
      780,
      676,
      439,
      411,
      690,
      360,
      247,
      331,
      402,
      121,
      140,
      192,
      426,
      396,
      188,
      443,
      296,
      903,
      350,
    ];
    return bulletMoveIDs.contains(id);
  }

  @override
  Move copy() => Move(
        id,
        _displayName,
        _displayNameEn,
        type,
        power,
        accuracy,
        priority,
        target,
        damageClass,
        effect,
        effectChance,
        pp,
      );

  /// 連続こうげきの場合、その最大回数を返す（連続こうげきではない場合は1を返す）
  int maxMoveCount() {
    if (effect.id == 30) return 5;
    if (effect.id == 45) return 2;
    if (effect.id == 78) return 2;
    if (effect.id == 105) return 3;
    if (effect.id == 155) return 6;
    if (effect.id == 361) return 5;
    if (effect.id == 428) return 2;
    if (effect.id == 443) return 5;
    if (effect.id == 459) return 3;
    if (effect.id == 462) return 3;
    if (effect.id == 480) return 10;
    if (effect.id == 483) return 3;
    if (effect.id == 507) return 2;
    return 1;
  }

  /// 必ず追加効果が起こるかどうかを返す
  bool isSurelyEffect() {
    switch (effect.id) {
      case 3: // どくにする(確率)
      case 78: // 2回こうげき、どくにする(確率)
      case 210: // どくにする(確率)。急所に当たりやすい
      case 5: // やけどにする(確率)
      case 201: // やけどにする(確率)。急所に当たりやすい
      case 6: // こおりにする(確率)
      case 261: // こおりにする(確率)。天気がゆきのときは必中
      case 7: // まひにする(確率)
      case 153: // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
      case 372: // まひにする(確率)
      case 140: // 使用者のこうげきを1段階上げる(確率)
      case 139: // 使用者のぼうぎょを1段階上げる(確率)
      case 277: // 使用者のとくこうを1段階上げる(確率)
      case 69: // こうげきを1段階下げる(確率)
      case 70: // ぼうぎょを1段階下げる(確率)
      case 71: // すばやさを1段階下げる(確率)
      case 74: // めいちゅうを1段階下げる(確率)
      case 32: // ひるませる(確率)
      case 93: // ひるませる(確率)。ねむり状態のときのみ成功
      case 203: // もうどくにする(確率)
      case 37: // やけど・こおり・まひのいずれかにする(確率)
      case 77: // こんらんさせる(確率)
      case 268: // こんらんさせる(確率)
      case 334: // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
      case 359: // 使用者のぼうぎょを2段階上げる(確率)
      case 272: // とくぼうを2段階下げる(確率)
      case 72: // とくこうを1段階下げる(確率)
      case 73: // とくぼうを1段階下げる(確率)
      case 141: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
      case 227: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
      case 254: // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
      case 263: // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
        if (effectChance < 100) {
          return false;
        }
        return true;
      default:
        return true;
    }
  }

/*
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      moveColumnId: id,
      moveColumnName: displayName,
      moveColumnPP: pp,
    };
    return map;
  }
*/
}
