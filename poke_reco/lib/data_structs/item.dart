import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';

/// なげつけたときの効果
class FlingItemEffect {
  /// もうどくにする
  static const int badPoison = 1;

  /// やけどにする
  static const int burn = 2;

  /// きのみの効果を発動
  static const int berry = 3;

  /// ハーブの効果を発動
  static const int herb = 4;

  /// まひにする
  static const int paralysis = 5;

  /// どくにする
  static const int poison = 6;

  /// ひるませる
  static const int flinch = 7;
}

/// もちものの情報を管理するclass
class Item extends Equatable implements Copyable {
  /// ID
  final int id;

  /// 名前(日本語)
  late final String _displayName;

  /// 名前(英語)
  late final String _displayNameEn;

  /// なげつけたときの威力
  final int flingPower;

  /// なげつけたときの効果ID
  final int flingEffectId;

  /// 発動タイミング
  final Timing timing;

  /// きのみかどうか
  final bool isBerry;

  /// 画像URL
  final String imageUrl;

  /// 変化し得るステータスとその倍率(100=1.0倍)
  final List<Tuple2<StatIndex, int>> possiblyChangeStat;

  @override
  List<Object?> get props => [
        id,
        _displayName,
        _displayNameEn,
        flingPower,
        flingEffectId,
        timing,
        isBerry,
        imageUrl,
        possiblyChangeStat,
      ];

  // 特徴的なもちもののNo
  /// あつぞこブーツ
  static int atsuzoko = 1178;

  /// ばんのうがさ
  static int bannougasa = 1181;

  /// もちものの情報を管理するclass
  Item({
    required this.id,
    required String displayName,
    required String displayNameEn,
    required this.flingPower,
    required this.flingEffectId,
    required this.timing,
    required this.isBerry,
    required this.imageUrl,
    required this.possiblyChangeStat,
  }) {
    _displayName = displayName;
    _displayNameEn = displayNameEn;
  }

  /// 無効なもちもの
  factory Item.none() => Item(
      id: 0,
      displayName: '',
      displayNameEn: '',
      flingPower: 0,
      flingEffectId: 0,
      timing: Timing.none,
      isBerry: false,
      imageUrl: '',
      possiblyChangeStat: []);

  @override
  Item copy() => Item(
        id: id,
        displayName: _displayName,
        displayNameEn: _displayNameEn,
        flingPower: flingPower,
        flingEffectId: flingEffectId,
        timing: timing,
        isBerry: isBerry,
        imageUrl: imageUrl,
        possiblyChangeStat: possiblyChangeStat,
      );

  /// 表示名
  String get displayName {
    switch (PokeDB().language) {
      case Language.english:
        return _displayNameEn;
      case Language.japanese:
      default:
        return _displayName;
    }
  }

  /// 表示名(不明の場合？を返す)
  String get displayNameWithUnknown {
    if (id == 0) {
      return '?';
    }
    return displayName;
  }

  /// なげつけたときの処理を行う
  /// ```
  /// playerType: 行動主
  /// myState: 行動主のポケモンの状態
  /// yourState: 行動主の相手のポケモンの状態
  /// state: フェーズの状態
  /// extraArg1: 引数1
  /// extraArg2: 引数2
  /// changePokemonIndex: ポケモン交代する場合は交代するポケモンのパーティ内インデックス、
  ///                     交代しなければnull
  /// ```
  void processFlingEffect(
    PlayerType playerType,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex, {
    required AppLocalizations loc,
  }) {
    switch (flingEffectId) {
      case FlingItemEffect.badPoison:
        yourState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case FlingItemEffect.burn:
        yourState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case FlingItemEffect.berry:
      case FlingItemEffect.herb:
        final itemEffect =
            TurnEffectItem(player: playerType, timing: timing, itemID: id);
        itemEffect.processEffect(
            Party(), yourState, Party(), myState, state, null,
            loc: loc, autoConsume: false);
        break;
      case FlingItemEffect.paralysis:
        yourState.ailmentsAdd(Ailment(Ailment.paralysis), state);
        break;
      case FlingItemEffect.poison:
        yourState.ailmentsAdd(Ailment(Ailment.poison), state);
        break;
      case FlingItemEffect.flinch:
        yourState.ailmentsAdd(Ailment(Ailment.flinch), state);
        break;
      default:
        break;
    }
  }

  /// 常時発動する効果を処理
  /// ```
  /// myState: もちもの保持者の状態
  /// processForm: フォルムチェンジを行うかどうか
  /// ```
  void processPassiveEffect(PokemonState myState, {bool processForm = true}) {
    final pokeData = PokeDB();
    switch (id) {
      case 112: // こんごうだま
        if (myState.pokemon.no == 483) {
          // ディアルガ
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.dragonAttack1_2]!);
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.steelAttack1_2]!);
        }
        break;
      case 113: // しらたま
        if (myState.pokemon.no == 484) {
          // パルキア
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.dragonAttack1_2]!);
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.waterAttack1_2]!);
        }
        break;
      case 442: // はっきんだま
        if (myState.pokemon.no == 487) {
          // ギラティナ
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.dragonAttack1_2]!);
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.ghostAttack1_2]!);
        }
        break;
      case 202: // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {
          // ラティアス/ラティオス
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.dragonAttack1_2]!);
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.psycoAttack1_2]!);
        }
        break;
      case 190: // ひかりのこな
      case 232: // のんきのおこう
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.yourAccuracy0_9]!);
        break;
      case 197: // こだわりハチマキ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.gorimuchu]!);
        break;
      case 203: // しんかいのキバ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.specialAttack2]!);
        }
        break;
      case 204: // しんかいのウロコ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.specialDefense2]!);
        }
        break;
      case 209: // ピントレンズ
      case 303: // するどいツメ
        myState.addVitalRank(1);
        break;
      case 213: // でんきだま
        if (myState.pokemon.no == 25) {
          // ピカチュウ
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.attackMove2]!);
        }
        break;
      case 235: // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {
          // カラカラ/ガラガラ
          myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.attack2]!);
        }
        break;
      case 233: // ラッキーパンチ
        if (myState.pokemon.no == 113) {
          // ラッキー
          myState.addVitalRank(2);
        }
        break;
      case 236: // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {
          // カモネギ/ネギガナイト
          myState.addVitalRank(2);
        }
        break;
      case 242: // こうかくレンズ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.accuracy1_1]!);
        break;
      case 243: // ちからのハチマキ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.physical1_1]!);
        break;
      case 244: // ものしりメガネ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.special1_1]!);
        break;
      case 245: // たつじんのおび
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.greatDamage1_2]!);
        break;
      case 247: // いのちのたま
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.lifeOrb]!);
        break;
      case 253: // フォーカスレンズ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.movedAccuracy1_2]!);
        break;
      case 254: // メトロノーム
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.continuousMoveDamageInc0_2]!);
        break;
      case 255: // くろいてっきゅう
      case 192: // きょうせいギプス
      case 266: // パワーリスト
      case 267: // パワーベルト
      case 268: // パワーレンズ
      case 269: // パワーバンド
      case 270: // パワーアンクル
      case 271: // パワーウエイト
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.speed0_5]!);
        break;
      case 264: // こだわりスカーフ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.choiceScarf]!);
        break;
      case 274: // こだわりメガネ
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.choiceSpecs]!);
        break;
      case 275: // ひのたまプレート
      case 226: // もくたん
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.fireAttack1_2]!);
        break;
      case 276: // しずくプレート
      case 220: // しんぴのしずく
      case 231: // うしおのおこう
      case 294: // さざなみのおこう
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.waterAttack1_2]!);
        break;
      case 277: // いかずちプレート
      case 219: // じしゃく
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.electricAttack1_2]!);
        break;
      case 278: // みどりのプレート
      case 216: // きせきのタネ
      case 295: // おはなのおこう
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.grassAttack1_2]!);
        break;
      case 279: // つららのプレート
      case 223: // とけないこおり
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.iceAttack1_2]!);
        break;
      case 280: // こぶしのプレート
      case 218: // くろおび
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.fightAttack1_2]!);
        break;
      case 281: // もうどくプレート
      case 222: // どくバリ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.poisonAttack1_2]!);
        break;
      case 282: // だいちのプレート
      case 214: // やわらかいすな
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.groundAttack1_2]!);
        break;
      case 283: // あおぞらプレート
      case 221: // するどいくちばし
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.airAttack1_2]!);
        break;
      case 284: // ふしぎのプレート
      case 225: // まがったスプーン
      case 291: // あやしいおこう
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.psycoAttack1_2]!);
        break;
      case 285: // たまむしプレート
      case 199: // ぎんのこな
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.bugAttack1_2]!);
        break;
      case 286: // がんせきプレート
      case 215: // かたいいし
      case 292: // がんせきおこう
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.rockAttack1_2]!);
        break;
      case 287: // もののけプレート
      case 224: // のろいのおふだ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.ghostAttack1_2]!);
        break;
      case 288: // りゅうのプレート
      case 227: // りゅうのキバ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.dragonAttack1_2]!);
        break;
      case 289: // こわもてプレート
      case 217: // くろいメガネ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.evilAttack1_2]!);
        break;
      case 290: // こうてつプレート
      case 210: // メタルコート
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.steelAttack1_2]!);
        break;
      case 684: // せいれいプレート
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.fairyAttack1_2]!);
        break;
      case 1664: // レジェンドプレート
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.moveAttack1_2]!);
        break;
      case 581: // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.defense1_5]!);
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.specialDefense1_5]!);
        }
        break;
      case 587: // しめつけバンド
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.bindDamage1_6]!);
        break;
      case 669: // ノーマルジュエル
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.onceNormalAttack1_3]!);
        break;
      case 683: // とつげきチョッキ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.onlyAttackSpecialDefense1_5]!);
        break;
      case 690: // ぼうじんゴーグル
        myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.overcoat]!);
        break;
      case 897: // ぼうごパット
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.ignoreDirectAtackEffect]!);
        break;
      case 1178: // あつぞこブーツ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.ignoreInstallingEffect]!);
        break;
      case 1662: // まっさらプレート
      case 228: // シルクのスカーフ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.normalAttack1_2]!);
        break;
      case 1700: // パンチグローブ
        myState.buffDebuffs
            .add(pokeData.buffDebuffs[BuffDebuff.punchNotDirect1_1]!);
        break;
      case 2106: // いどのめん
        if (myState.pokemon.no == 10273) {
          // オーガポン
          myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.attack1_2]!);
        }
        break;
      case 2107: // かまどのめん
        if (myState.pokemon.no == 10274) {
          // オーガポン
          myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.attack1_2]!);
        }
        break;
      case 2108: // いしずえのめん
        if (myState.pokemon.no == 10275) {
          // オーガポン
          myState.buffDebuffs.add(pokeData.buffDebuffs[BuffDebuff.attack1_2]!);
        }
        break;
    }
  }

  /// 常時発動する効果を消す
  /// ```
  /// myState: もちもの保持者の状態
  /// clearForm: フォルムチェンジを消すかどうか
  /// ```
  void clearPassiveEffect(PokemonState myState, {bool clearForm = true}) {
    switch (id) {
      case 112: // こんごうだま
        if (myState.pokemon.no == 483) {
          // ディアルガ
          myState.buffDebuffs.removeAllByID(BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeAllByID(BuffDebuff.steelAttack1_2);
        }
        break;
      case 113: // しらたま
        if (myState.pokemon.no == 484) {
          // パルキア
          myState.buffDebuffs.removeAllByID(BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeAllByID(BuffDebuff.waterAttack1_2);
        }
        break;
      case 442: // はっきんだま
        if (myState.pokemon.no == 487) {
          // ギラティナ
          myState.buffDebuffs.removeAllByID(BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeAllByID(BuffDebuff.ghostAttack1_2);
        }
        break;
      case 202: // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {
          // ラティアス/ラティオス
          myState.buffDebuffs.removeAllByID(BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeAllByID(BuffDebuff.psycoAttack1_2);
        }
        break;
      case 190: // ひかりのこな
      case 232: // のんきのおこう
        myState.buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_9);
        break;
      case 197: // こだわりハチマキ
        myState.buffDebuffs.removeFirstByID(BuffDebuff.gorimuchu);
        break;
      case 213: // でんきだま
        if (myState.pokemon.no == 25) {
          // ピカチュウ
          myState.buffDebuffs.removeAllByID(BuffDebuff.attackMove2);
        }
        break;
      case 235: // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {
          // カラカラ/ガラガラ
          myState.buffDebuffs.removeAllByID(BuffDebuff.attack2);
        }
        break;
      case 233: // ラッキーパンチ
        if (myState.pokemon.no == 113) {
          // ラッキー
          myState.addVitalRank(-2);
        }
        break;
      case 236: // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {
          // カモネギ/ネギガナイト
          myState.addVitalRank(-2);
        }
        break;
      case 203: // しんかいのキバ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs.removeAllByID(BuffDebuff.specialAttack2);
        }
        break;
      case 204: // しんかいのウロコ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs.removeAllByID(BuffDebuff.specialDefense2);
        }
        break;
      case 209: // ピントレンズ
      case 303: // するどいツメ
        myState.addVitalRank(-1);
        break;
      case 242: // こうかくレンズ
        myState.buffDebuffs.removeAllByID(BuffDebuff.accuracy1_1);
        break;
      case 243: // ちからのハチマキ
        myState.buffDebuffs.removeAllByID(BuffDebuff.physical1_1);
        break;
      case 244: // ものしりメガネ
        myState.buffDebuffs.removeAllByID(BuffDebuff.special1_1);
        break;
      case 245: // たつじんのおび
        myState.buffDebuffs.removeAllByID(BuffDebuff.greatDamage1_2);
        break;
      case 247: // いのちのたま
        myState.buffDebuffs.removeAllByID(BuffDebuff.lifeOrb);
        break;
      case 253: // フォーカスレンズ
        myState.buffDebuffs.removeAllByID(BuffDebuff.movedAccuracy1_2);
        break;
      case 254: // メトロノーム
        myState.buffDebuffs
            .removeAllByID(BuffDebuff.continuousMoveDamageInc0_2);
        break;
      case 255: // くろいてっきゅう
      case 192: // きょうせいギプス
      case 266: // パワーリスト
      case 267: // パワーベルト
      case 268: // パワーレンズ
      case 269: // パワーバンド
      case 270: // パワーアンクル
      case 271: // パワーウエイト
        myState.buffDebuffs.removeAllByID(BuffDebuff.speed0_5);
        break;
      case 264: // こだわりスカーフ
        myState.buffDebuffs.removeAllByID(BuffDebuff.choiceScarf);
        break;
      case 274: // こだわりメガネ
        myState.buffDebuffs.removeAllByID(BuffDebuff.choiceSpecs);
        break;
      case 275: // ひのたまプレート
      case 226: // もくたん
        myState.buffDebuffs.removeAllByID(BuffDebuff.fireAttack1_2);
        break;
      case 276: // しずくプレート
      case 220: // しんぴのしずく
      case 231: // うしおのおこう
      case 294: // さざなみのおこう
        myState.buffDebuffs.removeAllByID(BuffDebuff.waterAttack1_2);
        break;
      case 277: // いかずちプレート
      case 219: // じしゃく
        myState.buffDebuffs.removeAllByID(BuffDebuff.electricAttack1_2);
        break;
      case 278: // みどりのプレート
      case 216: // きせきのタネ
      case 295: // おはなのおこう
        myState.buffDebuffs.removeAllByID(BuffDebuff.grassAttack1_2);
        break;
      case 279: // つららのプレート
      case 223: // とけないこおり
        myState.buffDebuffs.removeAllByID(BuffDebuff.iceAttack1_2);
        break;
      case 280: // こぶしのプレート
      case 218: // くろおび
        myState.buffDebuffs.removeAllByID(BuffDebuff.fightAttack1_2);
        break;
      case 281: // もうどくプレート
      case 222: // どくバリ
        myState.buffDebuffs.removeAllByID(BuffDebuff.poisonAttack1_2);
        break;
      case 282: // だいちのプレート
      case 214: // やわらかいすな
        myState.buffDebuffs.removeAllByID(BuffDebuff.groundAttack1_2);
        break;
      case 283: // あおぞらプレート
      case 221: // するどいくちばし
        myState.buffDebuffs.removeAllByID(BuffDebuff.airAttack1_2);
        break;
      case 284: // ふしぎのプレート
      case 225: // まがったスプーン
      case 291: // あやしいおこう
        myState.buffDebuffs.removeAllByID(BuffDebuff.psycoAttack1_2);
        break;
      case 285: // たまむしプレート
      case 199: // ぎんのこな
        myState.buffDebuffs.removeAllByID(BuffDebuff.bugAttack1_2);
        break;
      case 286: // がんせきプレート
      case 215: // かたいいし
      case 292: // がんせきおこう
        myState.buffDebuffs.removeAllByID(BuffDebuff.rockAttack1_2);
        break;
      case 287: // もののけプレート
      case 224: // のろいのおふだ
        myState.buffDebuffs.removeAllByID(BuffDebuff.ghostAttack1_2);
        break;
      case 288: // りゅうのプレート
      case 227: // りゅうのキバ
        myState.buffDebuffs.removeAllByID(BuffDebuff.dragonAttack1_2);
        break;
      case 289: // こわもてプレート
      case 217: // くろいメガネ
        myState.buffDebuffs.removeAllByID(BuffDebuff.evilAttack1_2);
        break;
      case 290: // こうてつプレート
      case 210: // メタルコート
        myState.buffDebuffs.removeAllByID(BuffDebuff.steelAttack1_2);
        break;
      case 684: // せいれいプレート
        myState.buffDebuffs.removeAllByID(BuffDebuff.fairyAttack1_2);
        break;
      case 1664: // レジェンドプレート
        myState.buffDebuffs.removeAllByID(BuffDebuff.moveAttack1_2);
        break;
      case 581: // しんかのきせき
        myState.buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
        myState.buffDebuffs.removeAllByID(BuffDebuff.specialDefense1_5);
        break;
      case 587: // しめつけバンド
        myState.buffDebuffs.removeAllByID(BuffDebuff.bindDamage1_6);
        break;
      case 669: // ノーマルジュエル
        myState.buffDebuffs.removeAllByID(BuffDebuff.onceNormalAttack1_3);
        break;
      case 683: // とつげきチョッキ
        myState.buffDebuffs
            .removeAllByID(BuffDebuff.onlyAttackSpecialDefense1_5);
        break;
      case 690: // ぼうじんゴーグル
        myState.buffDebuffs.removeAllByID(BuffDebuff.overcoat);
        break;
      case 897: // ぼうごパット
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreDirectAtackEffect);
        break;
      case 1178: // あつぞこブーツ
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreInstallingEffect);
        break;
      case 1662: // まっさらプレート
      case 228: // シルクのスカーフ
        myState.buffDebuffs.removeAllByID(BuffDebuff.normalAttack1_2);
        break;
      case 1700: // パンチグローブ
        myState.buffDebuffs.removeAllByID(BuffDebuff.punchNotDirect1_1);
        break;
      case 2106: // いどのめん
        if (myState.pokemon.no == 10273) {
          // オーガポン
          myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_2);
        }
        break;
      case 2107: // かまどのめん
        if (myState.pokemon.no == 10274) {
          // オーガポン
          myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_2);
        }
        break;
      case 2108: // いしずえのめん
        if (myState.pokemon.no == 10275) {
          // オーガポン
          myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_2);
        }
        break;
    }
  }

  /// SQLite保存用Mapを返す
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      itemColumnId: id,
      itemColumnName: displayName,
      itemColumnTiming: timing,
      //itemColumnPossiblyChangeStat: target.index,
    };
    return map;
  }
}
