import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/pokemon_dropdown_menu_item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/ailment.dart';

// なげつけたときの効果
class FlingItemEffect {
  static const int badPoison = 1;       // もうどくにする
  static const int burn = 2;            // やけどにする
  static const int berry = 3;           // きのみの効果を発動
  static const int herb = 4;            // ハーブの効果を発動
  static const int paralysis = 5;       // まひにする
  static const int poison = 6;          // どくにする
  static const int flinch = 7;          // ひるませる
}

class Item {
  final int id;
  final String displayName;
  final int flingPower;
  final int flingEffectId;
  final AbilityTiming timing;
  final bool isBerry;
  final String imageUrl;

  // 特徴的なもちもののNo
  static int atsuzoko = 1178;       // あつぞこブーツ
  static int bannougasa = 1181;     // ばんのうがさ

  const Item({
    required this.id,
    required this.displayName,
    required this.flingPower,
    required this.flingEffectId,
    required this.timing,
    required this.isBerry,
    required this.imageUrl,
  });

  Item copyWith() =>
    Item(
      id: id, displayName: displayName, flingPower: flingPower,
      flingEffectId: flingEffectId, timing: timing,
      isBerry: isBerry, imageUrl: imageUrl
    );

  static List<String> processEffect(
    int itemID,
    PlayerType playerType,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex,
    {
      bool autoConsume = true,
    }
//    TurnEffect? prevAction,
  ) {
    final pokeData = PokeDB();
    List<String> ret = [];
    /*
    if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
      myParty.items[myPokemonIndex-1] = pokeData.items[itemID];   // もちもの確定
      ret.add('もちものを${pokeData.items[itemID]!.displayName}で確定しました。');
    }
    */
    // 既にもちものがわかっている場合は代入しない(代入によってbuffを追加してしまうから)
    if (myState.holdingItem == null || myState.holdingItem?.id != itemID) {
      myState.holdingItem = pokeData.items[itemID];
    }

    switch (itemID) {
      case 161:     // オッカのみ
      case 162:     // イトケのみ
      case 163:     // ソクノのみ
      case 164:     // リンドのみ
      case 165:     // ヤチェのみ
      case 166:     // ヨプのみ
      case 167:     // ビアーのみ
      case 168:     // シュカのみ
      case 169:     // バコウのみ
      case 170:     // ウタンのみ
      case 171:     // タンガのみ
      case 172:     // ヨロギのみ
      case 173:     // カシブのみ
      case 174:     // ハバンのみ
      case 175:     // ナモのみ
      case 176:     // リリバのみ
      case 723:     // ロゼルのみ
      case 177:     // ホズのみ
      case 187:     // イバンのみ
      case 248:     // パワフルハーブ
        // ダメージ軽減効果はユーザ入力に任せる
      case 669:     // ノーマルジュエル
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 194:     // せんせいのツメ
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 178:     // チイラのみ
      case 589:     // じゅうでんち
      case 689:     // ゆきだま
        myState.addStatChanges(true, 0, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 179:     // リュガのみ
      case 724:     // アッキのみ
      case 898:     // エレキシード
      case 901:     // グラスシード
        myState.addStatChanges(true, 1, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 181:     // ヤタピのみ
      case 588:     // きゅうこん
      case 1176:    // のどスプレー
        myState.addStatChanges(true, 2, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 182:     // ズアのみ
      case 725:     // タラプのみ
      case 688:     // ひかりごけ
      case 899:     // サイコシード
      case 900:     // ミストシード
        myState.addStatChanges(true, 3, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 180:     // カムラのみ
      case 883:     // ビビリだま
        myState.addStatChanges(true, 4, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 183:     // サンのみ
        myState.addVitalRank(1);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 184:     // スターのみ
        myState.addStatChanges(true, extraArg1, 2, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 186:     // ミクルのみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceAccuracy1_2));
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 188:   // ジャポのみ
      case 189:   // レンブのみ
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 191:     // しろいハーブ
        myState.resetDownedStatChanges();
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 682:     // じゃくてんほけん
        myState.addStatChanges(true, 0, 2, yourState, itemId: itemID);
        myState.addStatChanges(true, 2, 2, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 247:     // いのちのたま
      case 265:     // くっつきバリ
      case 258:     // くろいヘドロ
      case 211:     // たべのこし
      case 230:     // かいがらのすず
        if (playerType.id == PlayerType.me) {
          myState.remainHP -= extraArg1;
        }
        else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case 132:     // オレンのみ
      case 43:      // きのみジュース
      case 135:     // オボンのみ
      case 185:     // ナゾのみ
        if (playerType.id == PlayerType.me) {
          myState.remainHP -= extraArg1;
        }
        else {
          myState.remainHPPercent -= extraArg1;
        }
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 136:     // フィラのみ
      case 137:     // ウイのみ
      case 138:     // マゴのみ
      case 139:     // バンジのみ
      case 140:     // イアのみ
        if (extraArg2 == 0) {
          if (playerType.id == PlayerType.me) {
            myState.remainHP -= extraArg1;
          }
          else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        else {
          myState.ailmentsAdd(Ailment(Ailment.confusion), state);
        }
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 126:   // クラボのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.paralysis);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 127:   // カゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.sleep);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 128:   // モモンのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 129:   // チーゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.burn);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 130:   // ナナシのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.freeze);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 133:   // キーのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 134:   // ラムのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id <= Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 196:   // メンタルハーブ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => 
            e.id == Ailment.infatuation || e.id == Ailment.encore ||
            e.id == Ailment.torment || e.id == Ailment.disable ||
            e.id == Ailment.taunt || e.id == Ailment.healBlock);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 249:   // どくどくだま
        myState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case 250:   // かえんだま
        myState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case 257:   // あかいいと
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state);
        break;
      case 207:   // きあいのハチマキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        break;
      case 252:   // きあいのタスキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 583:   // ゴツゴツメット
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        break;
      case 584:     // ふうせん
        if (extraArg1 != 0) {   // ふうせんが割れたとき
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 585:     // レッドカード
        if (changePokemonIndex != null) {
          yourState.processExitEffect(playerType.opposite.id == PlayerType.me, myState);
          state.setPokemonIndex(playerType.opposite, changePokemonIndex);
          PokemonState newState;
          newState = state.getPokemonState(playerType.opposite, null);
          newState.processEnterEffect(playerType.opposite.id == PlayerType.me, state, myState);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 1177:    // だっしゅつパック
      case 590:     // だっしゅつボタン
        if (changePokemonIndex != null) {
          myState.processExitEffect(playerType.id == PlayerType.me, yourState);
          state.setPokemonIndex(playerType, changePokemonIndex);
          PokemonState newState;
          newState = state.getPokemonState(playerType, null);
          newState.processEnterEffect(playerType.id == PlayerType.me, state, yourState);
          if (autoConsume) myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 1179:  // からぶりほけん
        myState.addStatChanges(true, 4, 2, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 1180:  // ルームサービス
        myState.addStatChanges(true, 4, -1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      case 1699:      // ものまねハーブ
        var statChanges = PokemonState.unpackStatChanges(extraArg1);
        for (int i = 0; i < 7; i++) {
          myState.addStatChanges(true, i, statChanges[i], yourState, itemId: itemID);
        }
        if (autoConsume) myState.holdingItem = null;   // アイテム消費
        break;
      default:
        break;
    }
    return ret;
  }

  void processFlingEffect(
    PlayerType playerType,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex,
  ) {
    switch (flingEffectId) {
      case FlingItemEffect.badPoison:
        yourState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case FlingItemEffect.burn:
        yourState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case FlingItemEffect.berry:
      case FlingItemEffect.herb:
        processEffect(id, playerType, yourState, myState, state, extraArg1, extraArg2, changePokemonIndex, autoConsume: false);
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

  void processPassiveEffect(/*bool isOwn, Weather weather, Field field,*/ PokemonState myState, /*PokemonState yourState*/) {
    switch (id) {
      case 112:   // こんごうだま
        if (myState.pokemon.no == 483) {    // ディアルガ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        }
        break;
      case 113:   // しらたま
        if (myState.pokemon.no == 484) {    // パルキア
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        }
        break;
      case 442:   // はっきんだま
        if (myState.pokemon.no == 487) {    // ギラティナ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        }
        break;
      case 202:   // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {   // ラティアス/ラティオス
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        }
        break;
      case 190:   // ひかりのこな
      case 232:   // のんきのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_9));
        break;
      case 197:   // こだわりハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 203:   // しんかいのキバ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack2));
        }
        break;
      case 204:   // しんかいのウロコ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense2));
        }
        break;
      case 209:   // ピントレンズ
      case 303:   // するどいツメ
        myState.addVitalRank(1);
        break;
      case 213:   // でんきだま
        if (myState.pokemon.no == 25) {     // ピカチュウ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove2));
        }
        break;
      case 235:   // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {   // カラカラ/ガラガラ
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        }
        break;
      case 233:   // ラッキーパンチ
        if (myState.pokemon.no == 113) {   // ラッキー
          myState.addVitalRank(2);
        }
        break;
      case 236:   // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {   // カモネギ/ネギガナイト
          myState.addVitalRank(2);
        }
        break;
      case 242:   // こうかくレンズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 243:   // ちからのハチマキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_1));
        break;
      case 244:   // ものしりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_1));
        break;
      case 245:   // たつじんのおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_2));
        break;
      case 247:   // いのちのたま
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.lifeOrb));
        break;
      case 253:   // フォーカスレンズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.movedAccuracy1_2));
        break;
      case 254:   // メトロノーム
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.continuousMoveDamageInc0_2));
        break;
      case 255:   // くろいてっきゅう
      case 192:   // きょうせいギプス
      case 266:   // パワーリスト
      case 267:   // パワーベルト
      case 268:   // パワーレンズ
      case 269:   // パワーバンド
      case 270:   // パワーアンクル
      case 271:   // パワーウエイト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed0_5));
        break;
      case 264:   // こだわりスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceScarf));
        break;
      case 274:   // こだわりメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.choiceSpecs));
        break;
      case 275:   // ひのたまプレート
      case 226:   // もくたん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttack1_2));
        break;
      case 276:   // しずくプレート
      case 220:   // しんぴのしずく
      case 231:   // うしおのおこう
      case 294:   // さざなみのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterAttack1_2));
        break;
      case 277:   // いかずちプレート
      case 219:   // じしゃく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricAttack1_2));
        break;
      case 278:   // みどりのプレート
      case 216:   // きせきのタネ
      case 295:   // おはなのおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.grassAttack1_2));
        break;
      case 279:   // つららのプレート
      case 223:   // とけないこおり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceAttack1_2));
        break;
      case 280:   // こぶしのプレート
      case 218:   // くろおび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fightAttack1_2));
        break;
      case 281:   // もうどくプレート
      case 222:   // どくバリ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.poisonAttack1_2));
        break;
      case 282:   // だいちのプレート
      case 214:   // やわらかいすな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.groundAttack1_2));
        break;
      case 283:   // あおぞらプレート
      case 221:   // するどいくちばし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airAttack1_2));
        break;
      case 284:   // ふしぎのプレート
      case 225:   // まがったスプーン
      case 291:   // あやしいおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.psycoAttack1_2));
        break;
      case 285:   // たまむしプレート
      case 199:   // ぎんのこな
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bugAttack1_2));
        break;
      case 286:   // がんせきプレート
      case 215:   // かたいいし
      case 292:   // がんせきおこう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockAttack1_2));
        break;
      case 287:   // もののけプレート
      case 224:   // のろいのおふだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghostAttack1_2));
        break;
      case 288:   // りゅうのプレート
      case 227:   // りゅうのキバ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragonAttack1_2));
        break;
      case 289:   // こわもてプレート
      case 217:   // くろいメガネ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.evilAttack1_2));
        break;
      case 290:   // こうてつプレート
      case 210:   // メタルコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelAttack1_2));
        break;
      case 684:   // せいれいプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAttack1_2));
        break;
      case 1664:  // レジェンドプレート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.moveAttack1_2));
        break;
      case 581:   // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense1_5));
        }
        break;
      case 587:   // しめつけバンド
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bindDamage1_6));
        break;
      case 669:   // ノーマルジュエル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceNormalAttack1_3));
        break;
      case 683:   // とつげきチョッキ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onlyAttackSpecialDefense1_5));
        break;
      case 690:   // ぼうじんゴーグル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignorePowder));
        break;
      case 897:   // ぼうごパット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreDirectAtackEffect));
        break;
      case 1178:  // あつぞこブーツ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreInstallingEffect));
        break;
      case 1662:  // まっさらプレート
      case 228:   // シルクのスカーフ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalAttack1_2));
        break;
      case 1696:  // パンチグローブ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punchNotDirect1_1));
        break;
      case 2106:  // いどのめん
        if (myState.pokemon.no == 10273) {    // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
        }
        break;
      case 2107:  // かまどのめん
        if (myState.pokemon.no == 10274) {    // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
        }
        break;
      case 2108:  // いしずえのめん
        if (myState.pokemon.no == 10275) {    // オーガポン
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_2));
        }
        break;
    }
  }

  void clearPassiveEffect(/*bool isOwn, Weather weather, Field field,*/ PokemonState myState, /*PokemonState yourState*/) {
    switch (id) {
      case 112:     // こんごうだま
        if (myState.pokemon.no == 483) {    // ディアルガ
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.steelAttack1_2);
        }
        break;
      case 113:     // しらたま
        if (myState.pokemon.no == 484) {    // パルキア
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.waterAttack1_2);
        }
        break;
      case 442:     // はっきんだま
        if (myState.pokemon.no == 487) {    // ギラティナ
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
        }
        break;
      case 202:     // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {   // ラティアス/ラティオス
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
        }
        break;
      case 190:   // ひかりのこな
      case 232:   // のんきのおこう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourAccuracy0_9);
        break;
      case 197:   // こだわりハチマキ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.gorimuchu);
        break;
      case 213:   // でんきだま
        if (myState.pokemon.no == 25) {     // ピカチュウ
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attackMove2);
        }
        break;
      case 235:   // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {   // カラカラ/ガラガラ
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack2);
        }
        break;
      case 233:   // ラッキーパンチ
        if (myState.pokemon.no == 113) {   // ラッキー
          myState.addVitalRank(-2);
        }
        break;
      case 236:   // ながねぎ
        if (myState.pokemon.no == 83 || myState.pokemon.no == 865) {   // カモネギ/ネギガナイト
          myState.addVitalRank(-2);
        }
        break;
      case 203:   // しんかいのキバ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialAttack2);
        }
        break;
      case 204:   // しんかいのウロコ
        if (myState.pokemon.no == 366) {    // パールル
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialDefense2);
        }
        break;
      case 209:   // ピントレンズ
      case 303:   // するどいツメ
        myState.addVitalRank(-1);
        break;
      case 242:   // こうかくレンズ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.accuracy1_1);
        break;
      case 243:   // ちからのハチマキ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physical1_1);
        break;
      case 244:   // ものしりメガネ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_1);
        break;
      case 245:   // たつじんのおび
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.greatDamage1_2);
        break;
      case 247:   // いのちのたま
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.lifeOrb);
        break;
      case 253:   // フォーカスレンズ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.movedAccuracy1_2);
        break;
      case 254:   // メトロノーム
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2);
        break;
      case 255:   // くろいてっきゅう
      case 192:   // きょうせいギプス
      case 266:   // パワーリスト
      case 267:   // パワーベルト
      case 268:   // パワーレンズ
      case 269:   // パワーバンド
      case 270:   // パワーアンクル
      case 271:   // パワーウエイト
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.speed0_5);
        break;
      case 264:   // こだわりスカーフ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.choiceScarf);
        break;
      case 274:   // こだわりメガネ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.choiceSpecs);
        break;
      case 275:   // ひのたまプレート
      case 226:   // もくたん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.fireAttack1_2);
        break;
      case 276:   // しずくプレート
      case 220:   // しんぴのしずく
      case 231:   // うしおのおこう
      case 294:   // さざなみのおこう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.waterAttack1_2);
        break;
      case 277:   // いかずちプレート
      case 219:   // じしゃく
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.electricAttack1_2);
        break;
      case 278:   // みどりのプレート
      case 216:   // きせきのタネ
      case 295:   // おはなのおこう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.grassAttack1_2);
        break;
      case 279:   // つららのプレート
      case 223:   // とけないこおり
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.iceAttack1_2);
        break;
      case 280:   // こぶしのプレート
      case 218:   // くろおび
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.fightAttack1_2);
        break;
      case 281:   // もうどくプレート
      case 222:   // どくバリ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.poisonAttack1_2);
        break;
      case 282:   // だいちのプレート
      case 214:   // やわらかいすな
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.groundAttack1_2);
        break;
      case 283:   // あおぞらプレート
      case 221:   // するどいくちばし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.airAttack1_2);
        break;
      case 284:   // ふしぎのプレート
      case 225:   // まがったスプーン
      case 291:   // あやしいおこう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
        break;
      case 285:   // たまむしプレート
      case 199:   // ぎんのこな
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.bugAttack1_2);
        break;
      case 286:   // がんせきプレート
      case 215:   // かたいいし
      case 292:   // がんせきおこう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.rockAttack1_2);
        break;
      case 287:   // もののけプレート
      case 224:   // のろいのおふだ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
        break;
      case 288:   // りゅうのプレート
      case 227:   // りゅうのキバ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
        break;
      case 289:   // こわもてプレート
      case 217:   // くろいメガネ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.evilAttack1_2);
        break;
      case 290:   // こうてつプレート
      case 210:   // メタルコート
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.steelAttack1_2);
        break;
      case 684:   // せいれいプレート
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.fairyAttack1_2);
        break;
      case 1664:  // レジェンドプレート
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.moveAttack1_2);
        break;
      case 581:   // しんかのきせき
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense1_5);
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialDefense1_5);
        break;
      case 587:   // しめつけバンド
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.bindDamage1_6);
        break;
      case 669:   // ノーマルジュエル
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3);
        break;
      case 683:   // とつげきチョッキ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.onlyAttackSpecialDefense1_5);
        break;
      case 690:   // ぼうじんゴーグル
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ignorePowder);
        break;
      case 897:   // ぼうごパット
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ignoreDirectAtackEffect);
        break;
      case 1178:  // あつぞこブーツ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ignoreInstallingEffect);
        break;
      case 1662:  // まっさらプレート
      case 228:   // シルクのスカーフ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.normalAttack1_2);
        break;
      case 1696:  // パンチグローブ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.punchNotDirect1_1);
        break;
      case 2106:  // いどのめん
        if (myState.pokemon.no == 10273) {    // オーガポン
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_2);
        }
        break;
      case 2107:  // かまどのめん
        if (myState.pokemon.no == 10274) {    // オーガポン
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_2);
        }
        break;
      case 2108:  // いしずえのめん
        if (myState.pokemon.no == 10275) {    // オーガポン
          myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_2);
        }
        break;
    }
  }

  // TurnEffectのarg1が決定できる場合はその値を返す
  static int getAutoArg1(
    int itemID, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    bool isMe = player.id == PlayerType.me;

    switch (itemID) {
      case 247:       // いのちのたま
        return isMe ? (myState.pokemon.h.real / 10).floor() : 10;
      case 583:       // ゴツゴツメット
        return !isMe ? (yourState.pokemon.h.real / 6).floor() : 16;
      case 188:       // ジャポのみ
      case 189:       // レンブのみ
        return !isMe ? (yourState.pokemon.h.real / 8).floor() : 12;
      case 584:       // ふうせん
        if (timing.id != AbilityTiming.pokemonAppear) {
          return 1;
        }
        break;
      case 265:     // くっつきバリ
        return isMe ? (myState.pokemon.h.real / 8).floor() : 12;
      case 132:     // オレンのみ
        if (isMe) return -10;
        break;
      case 43:      // きのみジュース
        if (isMe) return -20;
        break;
      case 135:     // オボンのみ
      case 185:     // ナゾのみ
        return isMe ? -(myState.pokemon.h.real / 4).floor() : -25;
      case 136:     // フィラのみ
      case 137:     // ウイのみ
      case 138:     // マゴのみ
      case 139:     // バンジのみ
      case 140:     // イアのみ
        return isMe ? -(myState.pokemon.h.real / 3).floor() : -33;
      case 258:     // くろいヘドロ
        if (myState.isTypeContain(4)) {   // どくタイプか
          return isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
        }
        else {
          return isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        }
      case 211:     // たべのこし
        return isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
      case 1699:    // ものまねハーブ
        return 0x06666666;
      default:
        break;
    }

    return 0;
  }

  // TurnEffectのarg2が決定できる場合はその値を返す
  static int getAutoArg2(
    int itemID, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    return 0;
  }

  String getEditingControllerText2(PlayerType playerType, PokemonState myState, PokemonState yourState) {
    switch (id) {
      case 247:     // いのちのたま
      case 265:     // くっつきバリ
      case 258:     // くろいヘドロ
      case 211:     // たべのこし
      case 132:     // オレンのみ
      case 135:     // オボンのみ
      case 136:     // フィラのみ
      case 137:     // ウイのみ
      case 138:     // マゴのみ
      case 139:     // バンジのみ
      case 140:     // イアのみ
      case 185:     // ナゾのみ
      case 230:     // かいがらのすず
      case 43:      // きのみジュース
        if (playerType.id == PlayerType.me) {
          return myState.remainHP.toString();
        }
        else {
          return myState.remainHPPercent.toString();
        }
      case 583:     // ゴツゴツメット
      case 188:     // ジャポのみ
      case 189:     // レンブのみ
        if (playerType.id == PlayerType.me) {
          return yourState.remainHPPercent.toString();
        }
        else {
          return yourState.remainHP.toString();
        }
    }
    return '';
  }

  Widget extraWidget(
    void Function() onFocus,
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
    int extraArg1, int extraArg2, int? changePokemonIndex,
    void Function(int) extraArg1ChangeFunc,
    void Function(int) extraArg2ChangeFunc,
    void Function(int?) changePokemonIndexChangeFunc,
    bool isInput,
    {
      bool showNetworkImage = false,
    }
  ) {
    switch (id) {
      case 184:     // スターのみ
        return Row(
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
                    child: Text('こうげき'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('ぼうぎょ'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('とくこう'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('とくぼう'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('すばやさ'),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1ChangeFunc(value),
                textValue: extraArg1 == 0 ? 'こうげき' : extraArg1 == 1 ? 'ぼうぎょ' :
                  extraArg1 == 2 ? 'とくこう' : extraArg1 == 3 ? 'とくぼう' : extraArg1 == 4 ? 'すばやさ' : '',
                isInput: isInput,
                onFocus: onFocus,
              ),
            ),
            Text('があがった'),
          ],
        );
      case 247:     // いのちのたま
      case 265:     // くっつきバリ
      case 258:     // くろいヘドロ
      case 211:     // たべのこし
      case 132:     // オレンのみ
      case 135:     // オボンのみ
      case 185:     // ナゾのみ
      case 230:     // かいがらのすず
      case 43:      // きのみジュース
        return DamageIndicateRow(
          myState.pokemon, controller,
          playerType.id == PlayerType.me,
          onFocus,
          (value) {
            int val = myState.remainHP - (int.tryParse(value)??0);
            if (playerType.id == PlayerType.opponent) {
              val = myState.remainHPPercent - (int.tryParse(value)??0);
            }
            extraArg1ChangeFunc(val);
          },
          extraArg1, isInput,);
      case 136:     // フィラのみ
      case 137:     // ウイのみ
      case 138:     // マゴのみ
      case 139:     // バンジのみ
      case 140:     // イアのみ
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
                      child: Text('HPが回復した'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('こんらんした'),
                    ),
                  ],
                  value: extraArg2,
                  onChanged: (value) => extraArg2ChangeFunc(value),
                  textValue: extraArg2 == 0 ? 'HPが回復した' : extraArg1 == 1 ? 'こんらんした' : '',
                  isInput: isInput,
                  onFocus: onFocus,
                ),
              ),
            ]),
            extraArg2 == 0 ? SizedBox(height: 10,) : Container(),
            extraArg2 == 0 ?
            DamageIndicateRow(
              myPokemon, controller,
              playerType.id == PlayerType.me,
              onFocus,
              (value) {
                int val = myState.remainHP - (int.tryParse(value)??0);
                if (playerType.id == PlayerType.opponent) {
                  val = myState.remainHPPercent - (int.tryParse(value)??0);
                }
                extraArg1ChangeFunc(val);
              },
              extraArg1, isInput,
            ) : Container(),
          ],
        );
      case 583:     // ゴツゴツメット
      case 188:     // ジャポのみ
      case 189:     // レンブのみ
        return DamageIndicateRow(
          yourPokemon, controller,
          playerType.id != PlayerType.me,
          onFocus,
          (value) {
            int val = yourState.remainHPPercent - (int.tryParse(value)??0);
            if (playerType.id == PlayerType.opponent) {
              val = yourState.remainHP - (int.tryParse(value)??0);
            }
            extraArg1ChangeFunc(val);
          },
          extraArg1, isInput,
        );
      case 584:     // ふうせん
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
                    child: Text('ふうせんで浮いている'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('ふうせんが割れた'),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1ChangeFunc(value),
                textValue: extraArg1 == 0 ? 'ふうせんで浮いている' : extraArg1 == 1 ? 'ふうせんが割れた' : '',
                isInput: isInput,
                onFocus: onFocus,
              ),
            ),
          ],
        );
      case 585:     // レッドカード
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '交代先ポケモン',
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < yourParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i+1,
                      enabled: state.isPossibleBattling(playerType.opposite, i) && !state.getPokemonStates(playerType.opposite)[i].isFainting,
                      theme: theme,
                      pokemon: yourParty.pokemons[i]!,
                      showNetworkImage: showNetworkImage,
                    ),
                ],
                value: changePokemonIndex,
                onChanged: (value) => changePokemonIndexChangeFunc(value),
                textValue: isInput ? null : yourParty.pokemons[changePokemonIndex??1-1]!.name,
                isInput: isInput,
                onFocus: onFocus,
                prefixIconPokemon: isInput ? null : yourParty.pokemons[changePokemonIndex??1-1]!,
                showNetworkImage: showNetworkImage,
                theme: theme,
              ),
            ),
          ],
        );
      case 1699:      // ものまねハーブ
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('こうげき:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[0] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[0],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[0] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[0] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[0]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
                Text('ぼうぎょ:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[1] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[1],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[1] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[1] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[1]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
                Text('とくこう:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[2] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[2],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[2] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[2] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[2]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('とくぼう:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[3] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[3],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[3] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[3] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[3]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
                SizedBox(width: 10,),
                Text('すばやさ:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[4] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[4],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[4] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[4] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[4]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('めいちゅう:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[5] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[5],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[5] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[5] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[5]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
                SizedBox(width: 10,),
                Text('かいひ:'),
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
                    value: PokemonState.unpackStatChanges(extraArg1)[6] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[6],
                    onChanged: (value) {
                      var statChanges = PokemonState.unpackStatChanges(extraArg1);
                      statChanges[6] = value;
                      extraArg1ChangeFunc(PokemonState.packStatChanges(statChanges));
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[6] < 0 ? 0 : PokemonState.unpackStatChanges(extraArg1)[6]).toString(),
                    isInput: isInput,
                    onFocus: onFocus,
                  ),
                ),
              ],
            ),
          ],
        );
      case 1177:    // だっしゅつパック
      case 590:     // だっしゅつボタン
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '交代先ポケモン',
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < myParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i+1,
                      enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                      theme: theme,
                      pokemon: myParty.pokemons[i]!,
                      showNetworkImage: showNetworkImage,
                    ),
                ],
                value: changePokemonIndex,
                onChanged: (value) => changePokemonIndexChangeFunc(value),
                textValue: isInput ? null : myParty.pokemons[changePokemonIndex??1-1]!.name,
                isInput: isInput,
                onFocus: onFocus,
                prefixIconPokemon: isInput ? null : myParty.pokemons[changePokemonIndex??1-1]!,
                showNetworkImage: showNetworkImage,
                theme: theme,
              ),
            ),
          ],
        );
    }
    return Container();
  }

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
    required void Function() onFocus,
    required bool isInput,
    required String? textValue,   // isInput==falseのとき、出力する文字列として必須
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    ThemeData? theme,
  })
  {
    if (isInput) {
      return DropdownButtonFormField(
        key: key, items: items, selectedItemBuilder: selectedItemBuilder, value: value,
        hint: hint, disabledHint: disabledHint, onChanged: onChanged, onTap: onTap,
        elevation: elevation, style: style, icon: icon, iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor, iconSize: iconSize, isDense: isDense,
        isExpanded: isExpanded, itemHeight: itemHeight, focusColor: focusColor,
        focusNode: focusNode, autofocus: autofocus, dropdownColor: dropdownColor,
        decoration: decoration, onSaved: onSaved, validator: validator, autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight, enableFeedback: enableFeedback, alignment: alignment,
        borderRadius: borderRadius, padding: padding,
      );
    }
    else {
      return TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: decoration?.labelText,
          prefixIcon: prefixIconPokemon != null ? showNetworkImage ?
            Image.network(
              PokeDB().pokeBase[prefixIconPokemon.no]!.imageUrl,
              height: theme?.buttonTheme.height,
              errorBuilder: (c, o, s) {
                return const Icon(Icons.catching_pokemon);
              },
            ) : const Icon(Icons.catching_pokemon) : null,
        ),
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
        onTap: onFocus,
      );
    }
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      itemColumnId: id,
      itemColumnName: displayName,
      itemColumnTiming: timing.id,
    };
    return map;
  }
}
