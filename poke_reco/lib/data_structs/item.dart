import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/ailment.dart';

class Item {
  final int id;
  final String displayName;
  final AbilityTiming timing;
  final bool isBerry;

  const Item(this.id, this.displayName, this.timing, this.isBerry);

  Item copyWith() =>
    Item(id, displayName, timing, isBerry);

  static List<String> processEffect(
    int itemID,
    PlayerType playerType,
    Party myParty,
    int myPokemonIndex,
    PokemonState myState,
    Party yourParty,
    int yourPokemonIndex,
    PokemonState yourState,
    PhaseState state,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex,
    TurnEffect? prevAction,
  ) {
    final pokeData = PokeDB();
    List<String> ret = [];
    if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
      myParty.items[myPokemonIndex-1] = pokeData.items[itemID];   // もちもの確定
      ret.add('もちものを${pokeData.items[itemID]!.displayName}で確定しました。');
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
      case 590:     // だっしゅつボタン
      case 1177:    // だっしゅつパック
        // ダメージ軽減効果はユーザ入力に任せる
        myState.holdingItem = null;   // アイテム消費
        break;
      case 194:     // せんせいのツメ
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 178:     // チイラのみ
      case 589:     // じゅうでんち
      case 689:     // ゆきだま
        myState.addStatChanges(true, 0, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 179:     // リュガのみ
      case 724:     // アッキのみ
      case 898:     // エレキシード
      case 901:     // グラスシード
        myState.addStatChanges(true, 1, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 181:     // ヤタピのみ
      case 588:     // きゅうこん
      case 1176:    // のどスプレー
        myState.addStatChanges(true, 2, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 182:     // ズアのみ
      case 725:     // タラプのみ
      case 688:     // ひかりごけ
      case 899:     // サイコシード
      case 900:     // ミストシード
        myState.addStatChanges(true, 3, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 180:     // カムラのみ
      case 883:     // ビビリだま
        myState.addStatChanges(true, 4, 1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 183:     // サンのみ
        myState.addVitalRank(1);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 184:     // スターのみ
        myState.addStatChanges(true, extraArg1, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 186:     // ミクルのみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceAccuracy1_2));
        myState.holdingItem = null;   // アイテム消費
        break;
      case 188:   // ジャポのみ
      case 189:   // レンブのみ
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 191:     // しろいハーブ
        myState.resetDownedStatChanges();
        myState.holdingItem = null;   // アイテム消費
        break;
      case 682:     // じゃくてんほけん
        myState.addStatChanges(true, 0, 2, yourState, itemId: itemID);
        myState.addStatChanges(true, 2, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
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
        myState.holdingItem = pokeData.items[itemID];
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
        myState.holdingItem = null;   // アイテム消費
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
          myState.ailmentsAdd(Ailment(Ailment.confusion), state.weather, state.field);
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 126:   // クラボのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.paralysis);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 127:   // カゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.sleep);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 128:   // モモンのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 129:   // チーゴのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.burn);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 130:   // ナナシのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.freeze);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 133:   // キーのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 134:   // ラムのみ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => e.id <= Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 196:   // メンタルハーブ
        {
          int findIdx = myState.ailmentsIndexWhere((e) => 
            e.id == Ailment.infatuation || e.id == Ailment.encore ||
            e.id == Ailment.torment || e.id == Ailment.disable ||
            e.id == Ailment.taunt || e.id == Ailment.healBlock);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          myState.holdingItem = null;   // アイテム消費
        }
        break;
      case 249:   // どくどくだま
        myState.ailmentsAdd(Ailment(Ailment.badPoison), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 250:   // かえんだま
        myState.ailmentsAdd(Ailment(Ailment.burn), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 257:   // あかいいと
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state.weather, state.field);
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 207:   // きあいのハチマキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 252:   // きあいのタスキ
        if (playerType.id == PlayerType.me) {
          myState.remainHP == 1;
        }
        else {
          myState.remainHPPercent == 1;
        }
        myState.holdingItem = null;   // アイテム消費
        break;
      case 583:   // ゴツゴツメット
        if (playerType.id == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        }
        else {
          yourState.remainHP -= extraArg1;
        }
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 585:     // レッドカード
        if (changePokemonIndex != null) {
          yourState.processExitEffect(playerType.opposite.id == PlayerType.me, myState);
          state.setPokemonIndex(playerType.opposite, changePokemonIndex!);
          PokemonState newState;
          newState = state.getPokemonState(playerType.opposite);
          newState.processEnterEffect(playerType.opposite.id == PlayerType.me, state.weather, state.field, myState);
        }
        break;
      case 1179:  // からぶりほけん
        myState.addStatChanges(true, 4, 2, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      case 1180:  // ルームサービス
        myState.addStatChanges(true, 4, -1, yourState, itemId: itemID);
        myState.holdingItem = null;   // アイテム消費
        break;
      default:
        break;
    }
    return ret;
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
    }
  }

  void clearPassiveEffect(/*bool isOwn, Weather weather, Field field,*/ PokemonState myState, /*PokemonState yourState*/) {
    switch (id) {
      case 112:     // こんごうだま
        if (myState.pokemon.no == 483) {    // ディアルガ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 113:     // しらたま
        if (myState.pokemon.no == 484) {    // パルキア
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 442:     // はっきんだま
        if (myState.pokemon.no == 487) {    // ギラティナ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 202:     // こころのしずく
        if (myState.pokemon.no == 380 || myState.pokemon.no == 381) {   // ラティアス/ラティオス
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 190:   // ひかりのこな
      case 232:   // のんきのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_9);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 197:   // こだわりハチマキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.gorimuchu);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 213:   // でんきだま
        if (myState.pokemon.no == 25) {     // ピカチュウ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 235:   // ふといホネ
        if (myState.pokemon.no == 104 || myState.pokemon.no == 105) {   // カラカラ/ガラガラ
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
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
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 204:   // しんかいのウロコ
        if (myState.pokemon.no == 366) {    // パールル
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 209:   // ピントレンズ
      case 303:   // するどいツメ
        myState.addVitalRank(-1);
        break;
      case 242:   // こうかくレンズ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.accuracy1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 243:   // ちからのハチマキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 244:   // ものしりメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 245:   // たつじんのおび
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.greatDamage1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 247:   // いのちのたま
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.lifeOrb);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 253:   // フォーカスレンズ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.movedAccuracy1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 254:   // メトロノーム
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 255:   // くろいてっきゅう
      case 192:   // きょうせいギプス
      case 266:   // パワーリスト
      case 267:   // パワーベルト
      case 268:   // パワーレンズ
      case 269:   // パワーバンド
      case 270:   // パワーアンクル
      case 271:   // パワーウエイト
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed0_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 264:   // こだわりスカーフ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceScarf);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 274:   // こだわりメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceSpecs);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 275:   // ひのたまプレート
      case 226:   // もくたん
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fireAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 276:   // しずくプレート
      case 220:   // しんぴのしずく
      case 231:   // うしおのおこう
      case 294:   // さざなみのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 277:   // いかずちプレート
      case 219:   // じしゃく
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 278:   // みどりのプレート
      case 216:   // きせきのタネ
      case 295:   // おはなのおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.grassAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 279:   // つららのプレート
      case 223:   // とけないこおり
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 280:   // こぶしのプレート
      case 218:   // くろおび
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fightAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 281:   // もうどくプレート
      case 222:   // どくバリ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.poisonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 282:   // だいちのプレート
      case 214:   // やわらかいすな
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.groundAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 283:   // あおぞらプレート
      case 221:   // するどいくちばし
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 284:   // ふしぎのプレート
      case 225:   // まがったスプーン
      case 291:   // あやしいおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 285:   // たまむしプレート
      case 199:   // ぎんのこな
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bugAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 286:   // がんせきプレート
      case 215:   // かたいいし
      case 292:   // がんせきおこう
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 287:   // もののけプレート
      case 224:   // のろいのおふだ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 288:   // りゅうのプレート
      case 227:   // りゅうのキバ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 289:   // こわもてプレート
      case 217:   // くろいメガネ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.evilAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 290:   // こうてつプレート
      case 210:   // メタルコート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 684:   // せいれいプレート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1664:  // レジェンドプレート
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.moveAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 581:   // しんかのきせき
        if (myState.pokemon.isEvolvable) {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
          findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 587:   // しめつけバンド
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bindDamage1_6);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 669:   // ノーマルジュエル
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 683:   // とつげきチョッキ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onlyAttackSpecialDefense1_5);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 690:   // ぼうじんゴーグル
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignorePowder);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 897:   // ぼうごパット
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignoreDirectAtackEffect);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1178:  // あつぞこブーツ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ignoreInstallingEffect);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1662:  // まっさらプレート
      case 228:   // シルクのスカーフ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.normalAttack1_2);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
      case 1696:  // パンチグローブ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punchNotDirect1_1);
          if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
        }
        break;
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
