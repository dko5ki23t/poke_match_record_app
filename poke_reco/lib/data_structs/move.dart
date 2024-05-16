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

  /// 直接攻撃かどうか
  final bool isDirect;

  /// 音技かどうか
  final bool isSound;

  /// HP吸収わざかどうか
  final bool isDrain;

  /// パンチわざかどうか
  final bool isPunch;

  /// はどうわざかどうか
  final bool isWave;

  /// おどりわざかどうか
  final bool isDance;

  /// 反動わざかどうか(とくせい「すてみ」の対象)
  final bool isRecoil;

  /// 追加効果があるこうげきわざかどうか(とくせい「ちからずく」の対象)
  /// 追加効果＋追加効果とみなされない効果(自身のこおりを溶かしつつ相手をやけどにする等)の場合はfalse
  final bool isAdditionalEffect;

  /// 追加効果があるこうげきわざかどうか(とくせい「ちからずく」の対象)
  /// 追加効果＋追加効果とみなされない効果(自身のこおりを溶かしつつ相手をやけどにする等)の場合はtrue
  final bool isAdditionalEffect2;

  /// かみつきわざかどうか
  final bool isBite;

  /// 切るわざかどうか
  final bool isCut;

  /// 風わざかどうか
  final bool isWind;

  /// こなやほうしのわざかどうか
  final bool isPowder;

  /// 弾のわざかどうか
  final bool isBullet;

  /// 相手がまもる状態でも成功するか
  final bool successWithProtect;

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
        isDirect,
        isSound,
        isDrain,
        isPunch,
        isWave,
        isDance,
        isRecoil,
        isAdditionalEffect,
        isAdditionalEffect2,
        isBite,
        isCut,
        isWind,
        isPowder,
        isBullet,
        successWithProtect,
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
    this.isDirect,
    this.isSound,
    this.isDrain,
    this.isPunch,
    this.isWave,
    this.isDance,
    this.isRecoil,
    this.isAdditionalEffect,
    this.isAdditionalEffect2,
    this.isBite,
    this.isCut,
    this.isWind,
    this.isPowder,
    this.isBullet,
    this.successWithProtect,
  ) {
    _displayName = displayName;
    _displayNameEn = displayNameEn;
  }

  /// 無効なわざを生成
  factory Move.none() => Move(
        0,
        '',
        '',
        PokeType.unknown,
        0,
        0,
        0,
        Target.none,
        DamageClass(0),
        MoveEffect(0),
        0,
        0,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      );

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

  /// 相手がまもる状態だと失敗するか
  bool get failWithProtect {
    switch (target) {
      case Target.entireField:
      case Target.allAllies:
      case Target.ally:
      case Target.faintingPokemon:
      case Target.opponentsField:
      case Target.user:
      case Target.userAndAllies:
      case Target.userOrAlly:
      case Target.usersField:
        return false;
      default:
        return !successWithProtect;
    }
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
        isDirect,
        isSound,
        isDrain,
        isPunch,
        isWave,
        isDance,
        isRecoil,
        isAdditionalEffect,
        isAdditionalEffect2,
        isBite,
        isCut,
        isWind,
        isPowder,
        isBullet,
        successWithProtect,
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
        if (effectChance < 100) {
          return false;
        }
        return true;
      default:
        return true;
    }
  }
}
