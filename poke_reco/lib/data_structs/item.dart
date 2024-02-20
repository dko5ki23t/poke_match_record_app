import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/pokemon_dropdown_menu_item.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/tool.dart';

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
      imageUrl: '');

  @override
  Item copy() => Item(
      id: id,
      displayName: _displayName,
      displayNameEn: _displayNameEn,
      flingPower: flingPower,
      flingEffectId: flingEffectId,
      timing: timing,
      isBerry: isBerry,
      imageUrl: imageUrl);

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
    switch (id) {
      case 112: // こんごうだま
        if (myState.pokemon.no == 483) {
          // ディアルガ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        }
        break;
      case 113: // しらたま
        if (myState.pokemon.no == 484) {
          // パルキア
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        }
        break;
      case 442: // はっきんだま
        if (myState.pokemon.no == 487) {
          // ギラティナ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        }
        break;
      case 202: // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {
          // ラティアス/ラティオス
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        }
        break;
      case 190: // ひかりのこな
      case 232: // のんきのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_9));
        break;
      case 197: // こだわりハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 203: // しんかいのキバ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack2));
        }
        break;
      case 204: // しんかいのウロコ
        if (myState.pokemon.no == 366) {
          // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense2));
        }
        break;
      case 209: // ピントレンズ
      case 303: // するどいツメ
        myState.addVitalRank(1);
        break;
      case 213: // でんきだま
        if (myState.pokemon.no == 25) {
          // ピカチュウ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove2));
        }
        break;
      case 235: // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {
          // カラカラ/ガラガラ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
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
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 243: // ちからのハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_1));
        break;
      case 244: // ものしりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_1));
        break;
      case 245: // たつじんのおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_2));
        break;
      case 247: // いのちのたま
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.lifeOrb));
        break;
      case 253: // フォーカスレンズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.movedAccuracy1_2));
        break;
      case 254: // メトロノーム
        myState.buffDebuffs
            .add(BuffDebuff(BuffDebuff.continuousMoveDamageInc0_2));
        break;
      case 255: // くろいてっきゅう
      case 192: // きょうせいギプス
      case 266: // パワーリスト
      case 267: // パワーベルト
      case 268: // パワーレンズ
      case 269: // パワーバンド
      case 270: // パワーアンクル
      case 271: // パワーウエイト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed0_5));
        break;
      case 264: // こだわりスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceScarf));
        break;
      case 274: // こだわりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceSpecs));
        break;
      case 275: // ひのたまプレート
      case 226: // もくたん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttack1_2));
        break;
      case 276: // しずくプレート
      case 220: // しんぴのしずく
      case 231: // うしおのおこう
      case 294: // さざなみのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        break;
      case 277: // いかずちプレート
      case 219: // じしゃく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricAttack1_2));
        break;
      case 278: // みどりのプレート
      case 216: // きせきのタネ
      case 295: // おはなのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.grassAttack1_2));
        break;
      case 279: // つららのプレート
      case 223: // とけないこおり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceAttack1_2));
        break;
      case 280: // こぶしのプレート
      case 218: // くろおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fightAttack1_2));
        break;
      case 281: // もうどくプレート
      case 222: // どくバリ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.poisonAttack1_2));
        break;
      case 282: // だいちのプレート
      case 214: // やわらかいすな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.groundAttack1_2));
        break;
      case 283: // あおぞらプレート
      case 221: // するどいくちばし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airAttack1_2));
        break;
      case 284: // ふしぎのプレート
      case 225: // まがったスプーン
      case 291: // あやしいおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        break;
      case 285: // たまむしプレート
      case 199: // ぎんのこな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bugAttack1_2));
        break;
      case 286: // がんせきプレート
      case 215: // かたいいし
      case 292: // がんせきおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockAttack1_2));
        break;
      case 287: // もののけプレート
      case 224: // のろいのおふだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        break;
      case 288: // りゅうのプレート
      case 227: // りゅうのキバ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
        break;
      case 289: // こわもてプレート
      case 217: // くろいメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.evilAttack1_2));
        break;
      case 290: // こうてつプレート
      case 210: // メタルコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        break;
      case 684: // せいれいプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAttack1_2));
        break;
      case 1664: // レジェンドプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.moveAttack1_2));
        break;
      case 581: // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense1_5));
        }
        break;
      case 587: // しめつけバンド
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bindDamage1_6));
        break;
      case 669: // ノーマルジュエル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceNormalAttack1_3));
        break;
      case 683: // とつげきチョッキ
        myState.buffDebuffs
            .add(BuffDebuff(BuffDebuff.onlyAttackSpecialDefense1_5));
        break;
      case 690: // ぼうじんゴーグル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 897: // ぼうごパット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreDirectAtackEffect));
        break;
      case 1178: // あつぞこブーツ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreInstallingEffect));
        break;
      case 1662: // まっさらプレート
      case 228: // シルクのスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalAttack1_2));
        break;
      case 1700: // パンチグローブ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punchNotDirect1_1));
        break;
      case 2106: // いどのめん
        if (myState.pokemon.no == 10273) {
          // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
        }
        break;
      case 2107: // かまどのめん
        if (myState.pokemon.no == 10274) {
          // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
        }
        break;
      case 2108: // いしずえのめん
        if (myState.pokemon.no == 10275) {
          // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
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

  /// TODO:削除対象？
  String getEditingControllerText2(
      PlayerType playerType, PokemonState myState, PokemonState yourState) {
    switch (id) {
      case 247: // いのちのたま
      case 265: // くっつきバリ
      case 258: // くろいヘドロ
      case 211: // たべのこし
      case 132: // オレンのみ
      case 135: // オボンのみ
      case 136: // フィラのみ
      case 137: // ウイのみ
      case 138: // マゴのみ
      case 139: // バンジのみ
      case 140: // イアのみ
      case 185: // ナゾのみ
      case 230: // かいがらのすず
      case 43: // きのみジュース
        if (playerType == PlayerType.me) {
          return myState.remainHP.toString();
        } else {
          return myState.remainHPPercent.toString();
        }
      case 583: // ゴツゴツメット
      case 188: // ジャポのみ
      case 189: // レンブのみ
        if (playerType == PlayerType.me) {
          return yourState.remainHPPercent.toString();
        } else {
          return yourState.remainHP.toString();
        }
    }
    return '';
  }

  Widget extraWidget(
    ThemeData theme,
    PlayerType playerType,
    Pokemon myPokemon,
    Pokemon yourPokemon,
    PokemonState myState,
    PokemonState yourState,
    Party myParty,
    Party yourParty,
    PhaseState state,
    TextEditingController controller,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex,
    void Function(int) extraArg1ChangeFunc,
    void Function(int) extraArg2ChangeFunc,
    void Function(int?) changePokemonIndexChangeFunc,
    bool isInput, {
    bool showNetworkImage = false,
    required AppLocalizations loc,
  }) {
    switch (id) {
      case 184: // スターのみ
        return Row(
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                items: <DropdownMenuItem>[
                  for (final statIndex in StatIndexList.listAtoS)
                    DropdownMenuItem(
                      value: statIndex.index - 1,
                      child: Text(statIndex.name),
                    ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1ChangeFunc(value),
                textValue: StatIndex.values[extraArg1 + 1].name,
                isInput: isInput,
              ),
            ),
            Text(loc.battleRankUp1),
          ],
        );
      case 247: // いのちのたま
      case 265: // くっつきバリ
      case 258: // くろいヘドロ
      case 211: // たべのこし
      case 132: // オレンのみ
      case 135: // オボンのみ
      case 185: // ナゾのみ
      case 230: // かいがらのすず
      case 43: // きのみジュース
        return DamageIndicateRow(
          myState.pokemon,
          controller,
          playerType == PlayerType.me,
          (value) {
            int val = myState.remainHP - (int.tryParse(value) ?? 0);
            if (playerType == PlayerType.opponent) {
              val = myState.remainHPPercent - (int.tryParse(value) ?? 0);
            }
            extraArg1ChangeFunc(val);
          },
          extraArg1,
          isInput,
          loc: loc,
        );
      case 136: // フィラのみ
      case 137: // ウイのみ
      case 138: // マゴのみ
      case 139: // バンジのみ
      case 140: // イアのみ
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.battleHPRecovery),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(loc.battleConfused2),
                    ),
                  ],
                  value: extraArg2,
                  onChanged: (value) => extraArg2ChangeFunc(value),
                  textValue: extraArg2 == 0
                      ? loc.battleHPRecovery
                      : extraArg1 == 1
                          ? loc.battleConfused2
                          : '',
                  isInput: isInput,
                ),
              ),
            ]),
            extraArg2 == 0
                ? SizedBox(
                    height: 10,
                  )
                : Container(),
            extraArg2 == 0
                ? DamageIndicateRow(
                    myPokemon,
                    controller,
                    playerType == PlayerType.me,
                    (value) {
                      int val = myState.remainHP - (int.tryParse(value) ?? 0);
                      if (playerType == PlayerType.opponent) {
                        val = myState.remainHPPercent -
                            (int.tryParse(value) ?? 0);
                      }
                      extraArg1ChangeFunc(val);
                    },
                    extraArg1,
                    isInput,
                    loc: loc,
                  )
                : Container(),
          ],
        );
      case 583: // ゴツゴツメット
      case 188: // ジャポのみ
      case 189: // レンブのみ
        return DamageIndicateRow(
          yourPokemon,
          controller,
          playerType != PlayerType.me,
          (value) {
            int val = yourState.remainHPPercent - (int.tryParse(value) ?? 0);
            if (playerType == PlayerType.opponent) {
              val = yourState.remainHP - (int.tryParse(value) ?? 0);
            }
            extraArg1ChangeFunc(val);
          },
          extraArg1,
          isInput,
          loc: loc,
        );
      case 584: // ふうせん
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: 0,
                    child: Text(loc.battleBalloonFloat),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(loc.battleBalloonBurst),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1ChangeFunc(value),
                textValue: extraArg1 == 0
                    ? loc.battleBalloonFloat
                    : extraArg1 == 1
                        ? loc.battleBalloonBurst
                        : '',
                isInput: isInput,
              ),
            ),
          ],
        );
      case 585: // レッドカード
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battlePokemonToChange,
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < yourParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i + 1,
                      enabled:
                          state.isPossibleBattling(playerType.opposite, i) &&
                              !state
                                  .getPokemonStates(playerType.opposite)[i]
                                  .isFainting,
                      theme: theme,
                      pokemon: yourParty.pokemons[i]!,
                      showNetworkImage: showNetworkImage,
                    ),
                ],
                value: changePokemonIndex,
                onChanged: (value) => changePokemonIndexChangeFunc(value),
                textValue: isInput
                    ? null
                    : yourParty.pokemons[changePokemonIndex ?? 1 - 1]!.name,
                isInput: isInput,
                prefixIconPokemon: isInput
                    ? null
                    : yourParty.pokemons[changePokemonIndex ?? 1 - 1]!,
                showNetworkImage: showNetworkImage,
                theme: theme,
              ),
            ),
          ],
        );
      case 1699: // ものまねハーブ
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonAttack}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[0] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[0],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[0] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[0] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[0])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
                Text('${loc.commonDefense}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[1] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[1],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[1] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[1] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[1])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
                Text('${loc.commonSAttack}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[2] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[2],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[2] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[2] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[2])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonSDefense}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[3] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[3],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[3] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[3] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[3])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text('${loc.commonSpeed}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[4] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[4],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[4] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[4] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[4])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonAccuracy}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[5] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[5],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[5] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[5] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[5])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text('${loc.commonEvasiveness}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[6] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[6],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[6] = value;
                      extraArg1ChangeFunc(
                          PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[6] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[6])
                        .toString(),
                    isInput: isInput,
                  ),
                ),
              ],
            ),
          ],
        );
      case 1177: // だっしゅつパック
      case 590: // だっしゅつボタン
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battlePokemonToChange,
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < myParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i + 1,
                      enabled: state.isPossibleBattling(playerType, i) &&
                          !state.getPokemonStates(playerType)[i].isFainting,
                      theme: theme,
                      pokemon: myParty.pokemons[i]!,
                      showNetworkImage: showNetworkImage,
                    ),
                ],
                value: changePokemonIndex,
                onChanged: (value) => changePokemonIndexChangeFunc(value),
                textValue: isInput
                    ? null
                    : myParty.pokemons[changePokemonIndex ?? 1 - 1]!.name,
                isInput: isInput,
                prefixIconPokemon: isInput
                    ? null
                    : myParty.pokemons[changePokemonIndex ?? 1 - 1]!,
                showNetworkImage: showNetworkImage,
                theme: theme,
              ),
            ),
          ],
        );
    }
    return Container();
  }

  /// カスタムしたDropdownButtonFormField
  /// ```
  /// onFocus: フォーカスされたとき(タップされたとき)に呼ぶコールバック
  /// isInput: 入力モードかどうか
  /// textValue: 出力文字列(isInput==falseのとき必須)
  /// prefixIconPokemon: フィールド前に配置するアイコンのポケモン
  /// showNetworkImage: インターネットから取得したポケモンの画像を使うかどうか
  /// ```
  Widget _myDropdownButtonFormField<T>({
    Key? key,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    T? value,
    Widget? hint,
    Widget? disabledHint,
    required ValueChanged<T?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    required bool isInput,
    required String? textValue,
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    ThemeData? theme,
  }) {
    if (isInput) {
      return DropdownButtonFormField(
        key: key,
        items: items,
        selectedItemBuilder: selectedItemBuilder,
        value: value,
        hint: hint,
        disabledHint: disabledHint,
        onChanged: onChanged,
        onTap: onTap,
        elevation: elevation,
        style: style,
        icon: icon,
        iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor,
        iconSize: iconSize,
        isDense: isDense,
        isExpanded: isExpanded,
        itemHeight: itemHeight,
        focusColor: focusColor,
        focusNode: focusNode,
        autofocus: autofocus,
        dropdownColor: dropdownColor,
        decoration: decoration,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight,
        enableFeedback: enableFeedback,
        alignment: alignment,
        borderRadius: borderRadius,
        padding: padding,
      );
    } else {
      return TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: decoration?.labelText,
          prefixIcon: prefixIconPokemon != null
              ? showNetworkImage
                  ? Image.network(
                      PokeDB().pokeBase[prefixIconPokemon.no]!.imageUrl,
                      height: theme?.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    )
                  : const Icon(Icons.catching_pokemon)
              : null,
        ),
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
      );
    }
  }

  /// SQLite保存用Mapを返す
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      itemColumnId: id,
      itemColumnName: displayName,
      itemColumnTiming: timing,
    };
    return map;
  }
}
