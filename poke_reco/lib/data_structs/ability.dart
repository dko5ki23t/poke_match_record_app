import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/weather.dart';

class Ability {
  final int id;
  final String displayName;
  final AbilityTiming timing;
  final Target target;
  final AbilityEffect effect;
//  final int chance;               // 発動確率

  const Ability(
    this.id, this.displayName, this.timing, this.target, this.effect
  );

  Ability copyWith() =>
    Ability(id, displayName, timing, target, effect);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      abilityColumnId: id,
      abilityColumnName: displayName,
      abilityColumnTiming: timing.id,
      abilityColumnTarget: target.id,
      abilityColumnEffect: effect.id,
    };
    return map;
  }

  // 交換可能なとくせいかどうか
  bool get canExchange {
    const ids = [
      225, 248, 149, 241, 256, 208, 266, 211, 161, 209,
      176, 258, 25,
    ];
    return !ids.contains(id);
  }

  // 上書きできるとくせいかどうか
  bool get canOverWrite {
    const ids = [
      225, 248, 241, 210, 208, 282, 281, 266, 211, 213,
      161, 209, 176, 278, 121, 197,
    ];
    return !ids.contains(id);
  }

  // コピー可能なとくせいかどうか
  bool get canCopy {
    const ids = [
      225, 248, 149, 241, 303, 223, 256, 150, 210, 208, 282,
      281, 279, 266, 211, 213, 161, 59, 36, 209, 176, 258,
      122, 278, 121, 197, 222,
    ];
    return !ids.contains(id);
  }

  // かたやぶり/きんしのちから/ターボブレイズ/テラボルテージで無視されるとくせいかどうか
  bool get canIgnored {
    const ids = [
      248, 47, 126, 165, 188, 283, 52, 274, 4, 5, 87, 272,
      21, 179, 29, 246, 273, 75, 6, 7, 214, 73, 299, 175,
      199, 8, 51, 39, 157, 186, 85, 86, 10, 77, 11, 296,
      140, 78, 109, 297, 12, 270, 60, 116, 209, 257, 35,
      145, 244, 275, 219, 31, 169, 111, 187, 63, 25, 15,
      26, 122, 166, 132, 134, 43, 142, 171, 20, 40, 156,
      136, 41, 240, 147, 17, 218, 18, 72, 81, 114, 135,
      102, 19,
    ];
    return ids.contains(id);
  }

  static List<Guide> processEffect(
    int abilityID,
    PlayerType playerType,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    Party myParty,
    int myPokemonIndex,
    PokemonState opponentPokemonState,
    int extraArg1,
    int extraArg2,
    int? changePokemonIndex,
  ) {
    final pokeData = PokeDB();
    List<Guide> ret = [];
    var myPlayerID = playerType.id;
    var yourPlayerID = playerType.opposite.id;
    var myFields = playerType.id == PlayerType.me ? state.ownFields : state.opponentFields;
    var yourFields = playerType.id == PlayerType.me ? state.opponentFields : state.ownFields;
    var isOwn = playerType.id == PlayerType.me;

    switch (abilityID) {
      case 1:     // あくしゅう
        yourState.ailmentsAdd(Ailment(Ailment.flinch), state);  // ひるませる
        break;
      case 2:     // あめふらし
        state.weather = Weather(Weather.rainy);
        break;
      case 3:     // かそく
      case 78:    // でんきエンジン
      case 80:    // ふくつのこころ
      case 155:   // びびり
        myState.addStatChanges(true, 4, 1, yourState, abilityId: abilityID);
        break;
      case 7:     // じゅうなん
        {   // まひになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 9:     // せいでんき
        yourState.ailmentsAdd(Ailment(Ailment.paralysis), state);
        break;
      case 10:    // ちくでん
      case 11:    // ちょすい
      case 44:    // あめうけざら
      case 87:    // かんそうはだ
      case 90:    // ポイズンヒール
      case 94:    // サンパワー
      case 115:   // アイスボディ
      case 297:   // どしょく
        if (playerType.id == PlayerType.me) {
          myState.remainHP -= extraArg1;
        }
        else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case 12:    // どんかん
        {
          // メロメロ/ちょうはつになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.infatuation);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.taunt);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 13:    // ノーてんき
      case 76:    // エアロック
        Weather.processWeatherEffect(state.weather, state.weather, myState, null);
        break;
      case 15:    // ふみん
      case 72:    // やるき
      case 175:   // スイートベール
        {   // ねむりになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.sleep || element.id == Ailment.sleepy);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 16:    // へんしょく
        {
          myState.pokemon.type1 = PokeType.createFromId(extraArg1);
          myState.pokemon.type2 = null;
        }
        break;
      case 17:    // めんえき
      case 257:   // パステルベール
        {   // どく/もうどくになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.poison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 18:    // もらいび
        {   // ほのおわざ威力1.5倍
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.flashFired);
          if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.flashFired));
        }
        break;
      case 20:    // マイペース
        {   // こんらんになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 22:    // いかく
        yourState.addStatChanges(false, 0, -1, myState, myFields: yourFields, yourFields: myFields, abilityId: abilityID);
        break;
      case 24:    // さめはだ
      case 106:   // ゆうばく
      case 123:   // ナイトメア
      case 160:   // てつのトゲ
      case 215:   // とびだすなかみ
        if (yourPlayerID == PlayerType.me) {
          yourState.remainHP -= extraArg1;
        }
        else {
          yourState.remainHPPercent -= extraArg1;
        }
        break;
      case 27:    // ほうし
        if (extraArg1 != 0) {
          yourState.ailmentsAdd(Ailment(extraArg1), state);
        }
        break;
      case 28:    // シンクロ
        {
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
          if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.poison);
          if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
          if (findIdx < 0) findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
          if (findIdx >= 0) yourState.ailmentsAdd(myState.ailments(findIdx), state);
        }
        break;
      case 31:    // ひらいしん
      case 114:   // よびみず
      case 201:   // ぎゃくじょう
      case 220:   // ソウルハート
      case 265:   // くろのいななき
      case 267:   // じんばいったい（くろのいななき）
        myState.addStatChanges(true, 2, 1, yourState, abilityId: abilityID);
        break;
      case 36:    // トレース
        {
          if (playerType.id == PlayerType.opponent && myState.currentAbility.id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confAbility
              ..args = [abilityID]
              ..guideStr = 'あいての${myState.pokemon.name}のとくせいを${pokeData.abilities[abilityID]!.displayName}で確定しました。'
            );
          }
          myState.setCurrentAbility(pokeData.abilities[extraArg1]!, yourState, isOwn, state);
          if (playerType.id == PlayerType.me && yourState.currentAbility.id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confAbility
              ..args = [extraArg1]
              ..guideStr = 'あいての${yourState.pokemon.name}のとくせいを${pokeData.abilities[extraArg1]!.displayName}で確定しました。'
            );
            yourState.setCurrentAbility(yourState.pokemon.ability, myState, !isOwn, state);
          }
        }
        break;
      case 38:    // どくのトゲ
      case 143:   // どくしゅ
        yourState.ailmentsAdd(Ailment(Ailment.poison), state);
        break;
      case 40:    // マグマのよろい
        {   // こおりになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.freeze);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 41:    // みずのベール
      case 199:   // すいほう
        {   // やけどになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id == Ailment.burn);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 45:    // すなおこし
      case 245:   // すなはき
        state.weather = Weather(Weather.sandStorm);
        break;
      case 49:    // ほのおのからだ
        yourState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case 53:    // ものひろい
      case 139:   // しゅうかく
        myState.holdingItem = pokeData.items[extraArg1];
        break;
      case 56:    // メロメロボディ
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state);
        break;
      case 61:    // だっぴ
      case 93:    // うるおいボディ
        {   // まひ/こおり/やけど/どく/もうどく/ねむりになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) => element.id <= Ailment.sleep);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 70:      // ひでり
      case 288:     // ひひいろのこどう
        state.weather = Weather(Weather.sunny);
        break;
      case 83:    // いかりのつぼ
        myState.addStatChanges(true, 0, 6, yourState, abilityId: abilityID);
        break;
      case 88:    // ダウンロード
      case 224:   // ビーストブースト
        myState.addStatChanges(true, extraArg1, 1, yourState, abilityId: abilityID);
        break;
      case 108:   // よちむ
        // わざ確定
        {
          var tmp = opponentPokemonState.moves.where(
                (element) => element.id != 0 && element.id == extraArg1
              );
          if (extraArg1 != 165 &&     // わるあがきは除外
              myPlayerID == PlayerType.me &&
              opponentPokemonState.moves.length < 4 &&
              tmp.isEmpty
          ) {
            ret.add(Guide()
              ..guideId = Guide.confMove
              ..canDelete = false
              ..guideStr = 'あいての${opponentPokemonState.pokemon.name}のわざの1つを${pokeData.moves[extraArg1]!.displayName}で確定しました。'
            );
          }
        }
        break;
      case 112:   // スロースタート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackSpeed0_5));
        break;
      case 117:     // ゆきふらし
        state.weather = Weather(Weather.snowy);
        break;
      case 119:     // おみとおし
        // もちもの確定
        {
          if (extraArg1 != 0 &&
              myPlayerID == PlayerType.me &&
              opponentPokemonState.holdingItem?.id == 0
          ) {
            ret.add(Guide()
              ..guideId = Guide.confItem
              ..args = [extraArg1]
              ..guideStr = 'あいての${opponentPokemonState.pokemon.name}のもちものを${pokeData.items[extraArg1]!.displayName}で確定しました。'
            );
          }
          yourState.holdingItem = pokeData.items[extraArg1]!;
        }
        break;
      case 124:     // わるいてぐせ
      case 170:     // マジシャン
        myState.holdingItem = pokeData.items[extraArg1]!;
        yourState.holdingItem = null;
        break;
      case 130:     // のろわれボディ
        yourState.ailmentsAdd(Ailment(Ailment.disable)..extraArg1 = extraArg1, state);
        break;
      case 133:     // くだけるよろい
        myState.addStatChanges(true, 1, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 4, 2, yourState, abilityId: abilityID);
        break;
      case 141:     // ムラっけ
        myState.addStatChanges(true, extraArg1, 2, yourState, abilityId: abilityID);
        myState.addStatChanges(true, extraArg2, -1, yourState, abilityId: abilityID);
        break;
      case 149:     // イリュージョン
        if (playerType.id == PlayerType.opponent) {
          var pokeNo = state.getPokemonStates(PlayerType(PlayerType.opponent))[extraArg1-1].pokemon.no;
          if (pokeNo == PokeBase.zoruaNo) state.canZorua = false;
          if (pokeNo == PokeBase.zoroarkNo) state.canZoroark = false;
          if (pokeNo == PokeBase.zoruaHisuiNo) state.canZoruaHisui = false;
          if (pokeNo == PokeBase.zoroarkHisuiNo) state.canZoroarkHisui = false;
          // TODO インデックス等を変える
        }
        break;
      case 150:     // かわりもの
        if (yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute || e.id == BuffDebuff.transform).isEmpty &&
            myState.buffDebuffs.where((e) => e.id == BuffDebuff.transform).isEmpty
        ) {    // 対象がみがわり状態でない・お互いにへんしん状態でないなら
          myState.type1 = yourState.type1;
          myState.type2 = yourState.type2;
          myState.setCurrentAbility(yourState.currentAbility, yourState, isOwn, state);
          for (int i = 0; i < yourState.moves.length; i++) {
            if (i >= myState.moves.length) {
              myState.moves.add(yourState.moves[i]);
            }
            else {
              myState.moves[i] = yourState.moves[i];
            }
            myState.usedPPs[i] = 0;
          }
          for (int i = 0; i < StatIndex.size.index; i++) {    // HP以外のステータス実数値
            myState.minStats[i].real = yourState.minStats[i].real;
            myState.maxStats[i].real = yourState.maxStats[i].real;
          }
          for (int i = 0; i < 7; i++) {
            myState.forceSetStatChanges(i, yourState.statChanges(i));
          }
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transform)..extraArg1 = yourState.pokemon.no..turns = yourState.pokemon.sex.id);
        }
        break;
      case 152:   // ミイラ
      case 268:   // とれないにおい
        yourState.setCurrentAbility(myState.currentAbility, myState, !isOwn, state);
        break;
      case 153:     // じしんかじょう
      case 154:     // せいぎのこころ
      case 157:     // そうしょく
      case 234:     // ふとうのけん
      case 264:     // しろのいななき
      case 266:     // じんばいったい（しろのいななき）
      case 270:     // ねつこうかん
      case 274:     // かぜのり
        myState.addStatChanges(true, 0, 1, yourState, abilityId: abilityID);
        break;
      case 161:     // ダルマモード
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.zenMode);
          if (findIdx >= 0) {
            myState.buffDebuffs.removeAt(findIdx);
          }
          else {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.zenMode));
          }
        }
        break;
      case 165:     // アロマベール
        {
          // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじになっていれば消す
          myState.ailmentsRemoveWhere((e) =>
            e.id == Ailment.infatuation || e.id == Ailment.encore || e.id == Ailment.torment ||
            e.id == Ailment.disable || e.id == Ailment.taunt || e.id == Ailment.healBlock);
        }
        break;
      case 166:     // フラワーベール
      case 272:     // きよめのしお
        {   // まひ/こおり/やけど/どく/もうどく/ねむり/ねむけになっていれば消す
          myState.ailmentsRemoveWhere((element) => element.id <= Ailment.sleep || element.id == Ailment.sleepy);
        }
        break;
      case 168:   // へんげんじざい
      case 236:   // リベロ
        myState.type1 = PokeType.createFromId(extraArg1);
        myState.type2 = null;
        myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.protean));
        break;
      case 172:   // かちき
        myState.addStatChanges(true, 2, 2, yourState, abilityId: abilityID);
        break;
      case 183:   // ぬめぬめ
      case 238:   // わたげ
        yourState.addStatChanges(false, 4, -1, myState, myFields: yourFields, yourFields: myFields, abilityId: abilityID);
        break;
      case 176:   // バトルスイッチ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bladeForm);
          if (findIdx >= 0) {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.shieldForm);
          }
          else {
            findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.shieldForm);
            if (findIdx >= 0) myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.bladeForm);
          }
        }
        break;
      case 192:   // じきゅうりょく
      case 235:   // ふくつのたて
        myState.addStatChanges(true, 1, 1, yourState, abilityId: abilityID);
        break;
      case 195:   // みずがため
      case 273:   // こんがりボディ
        myState.addStatChanges(true, 1, 2, yourState, abilityId: abilityID);
        break;
      case 208:     // ぎょぐん
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.singleForm);
          if (findIdx >= 0) {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.multipleForm);
          }
          else {
            findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.multipleForm);
            if (findIdx >= 0) {
              myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.singleForm);
            }
          }
        }
        break;
      case 209:   // ばけのかわ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.transedForm);
          if (findIdx >= 0) {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.revealedForm);
          }
          if (playerType.id == PlayerType.me) {
            myState.remainHP -= extraArg1;
          }
          else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        break;
      case 210:   // きずなへんげ
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.satoshiGekkoga);
          if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.satoshiGekkoga));
        }
        break;
      case 211:   // スワームチェンジ
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.perfectForm);
          if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.perfectForm));
          if (playerType.id == PlayerType.me) {
            myState.remainHP -= extraArg1;
          }
          else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        break;
      case 216:   // おどりこ
        switch (extraArg1) {
          case 872:   // アクアステップ
          case 10552: // ほのおのまい(とくこう1段階上昇)
            if (yourPlayerID == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            }
            else {
              yourState.remainHPPercent -= extraArg2;
            }
            myState.addStatChanges(true, extraArg1 == 872 ? 4 : 2, 1, yourState, moveId: extraArg1);
            break;
          case 80:    // はなびらのまい
            if (yourPlayerID == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            }
            else {
              yourState.remainHPPercent -= extraArg2;
            }
            myState.ailmentsAdd(Ailment(Ailment.thrash), state);
            break;
          case 552:   // ほのおのまい
          case 686:   // めざめるダンス
            if (yourPlayerID == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            }
            else {
              yourState.remainHPPercent -= extraArg2;
            }
            break;
          case 837:   // しょうりのまい
            myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 1, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 483:   // ちょうのまい
            myState.addStatChanges(true, 2, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 3, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 14:    // つるぎのまい
            myState.addStatChanges(true, 0, 2, yourState, moveId: extraArg1);
            break;
          case 297:   // フェザーダンス
            yourState.addStatChanges(false, 0, -2, myState, myFields: yourFields, yourFields: myFields, moveId: extraArg1);
            break;
          case 298:   // フラフラダンス
            yourState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 461:   // みかづきのまい
            if (myPlayerID == PlayerType.me) {
              myState.remainHP = 0;
            }
            else {
              myState.remainHPPercent = 0;
            }
            myFields.add(IndividualField(IndividualField.lunarDance));
            break;
          case 349:   // りゅうのまい
            myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 775:   // ソウルビート
            {
              if (myPlayerID == PlayerType.me) {
                myState.remainHP -= extraArg2;
              }
              else {
                myState.remainHPPercent -= extraArg2;
              }
              myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
              myState.addStatChanges(true, 1, 1, yourState, moveId: extraArg1);
              myState.addStatChanges(true, 2, 1, yourState, moveId: extraArg1);
              myState.addStatChanges(true, 3, 1, yourState, moveId: extraArg1);
              myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            }
            break;
          default:
            break;
        }
        break;
      case 221:   // カーリーヘアー
        yourState.addStatChanges(true, 4, -1, myState, abilityId: abilityID);
        break;
      case 226:   // エレキメイカー
      case 289:   // ハドロンエンジン
        state.field = Field(Field.electricTerrain);
        break;
      case 227:   // サイコメイカー
        state.field = Field(Field.psychicTerrain);
        break;
      case 228:   // ミストメイカー
        state.field = Field(Field.mistyTerrain);
        break;
      case 229:   // グラスメイカー
        state.field = Field(Field.grassyTerrain);
        break;
      case 243:   // じょうききかん
        myState.addStatChanges(true, 4, 6, yourState, abilityId: abilityID);
        break;
      case 248:   // アイスフェイス
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.iceFace);
          if (findIdx >= 0) {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.niceFace);
          }
          else {
            findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.niceFace);
            if (findIdx >= 0) {
              myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.iceFace);
            }
          }
        }
        break;
      case 251:   // バリアフリー
        myFields.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
        yourFields.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
        break;
      case 253:   // ほろびのボディ
        myState.ailmentsAdd(Ailment(Ailment.perishSong), state);
        yourState.ailmentsAdd(Ailment(Ailment.perishSong), state);
        break;
      case 254:   // さまようたましい
        if (yourState.currentAbility.canExchange) {
          var tmp = yourState.currentAbility;
          yourState.setCurrentAbility(myState.currentAbility, myState, !isOwn, state);
          myState.setCurrentAbility(tmp, yourState, isOwn, state);
        }
        break;
      case 258:   // はらぺこスイッチ
        {
          int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.manpukuForm);
          if (findIdx >= 0) {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.harapekoForm);
          }
          else {
            findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.harapekoForm);
            if (findIdx >= 0) {
              myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.manpukuForm);
            }
          }
        }
        break;
      case 269:   // こぼれダネ
        state.field = Field(Field.grassyTerrain);
        break;
      case 271:   // いかりのこうら
        myState.addStatChanges(true, 0, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 1, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 2, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 3, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 4, 1, yourState, abilityId: abilityID);
        break;
      case 277:   // ふうりょくでんき
      case 280:   // でんきにかえる
        myState.ailmentsAdd(Ailment(Ailment.charging), state);
        break;
      case 281:   // こだいかっせい
        if (extraArg1 >= 0) {
          int arg = 0;
          if (state.weather.id != Weather.sunny) {  // 晴れではないのに発動したら
            if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [1696]
                ..guideStr = 'あいての${opponentPokemonState.pokemon.name}のもちものを${pokeData.items[1696]!.displayName}で確定しました。'
              );
            }
            myState.holdingItem = null;   // アイテム消費
            arg = 1;
          }
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1)..extraArg1 = arg);
        }
        else {
          myState.buffDebuffs.removeWhere((e) => e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5);
        }
        break;
      case 282:   // クォークチャージ
        if (extraArg1 >= 0) {
          int arg = 0;
          if (state.field.id != Field.electricTerrain) {  // エレキフィールドではないのに発動したら
            if (playerType.id == PlayerType.opponent && myState.holdingItem?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [1696]
                ..guideStr = 'あいての${opponentPokemonState.pokemon.name}のもちものを${pokeData.items[1696]!.displayName}で確定しました。'
              );
            }
            myState.holdingItem = null;   // アイテム消費
            arg = 1;
          }
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_3+extraArg1)..extraArg1 = arg);
        }
        else {
          myState.buffDebuffs.removeWhere((e) => e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5);
        }
        break;
      case 290:   // びんじょう
        myState.addStatChanges(true, extraArg1, extraArg2, yourState, abilityId: abilityID);
        break;
      case 291:   // はんすう
        ret.addAll(Item.processEffect(
          extraArg1, playerType, myState,
          yourState, state,
          extraArg2, 0, changePokemonIndex,
        ));
        break;
      case 293:   // そうだいしょう
        {
          int faintingNum = state.getFaintingCount(playerType);
          if (faintingNum > 0) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.power10 + faintingNum - 1));
          }
        }
        break;
      case 295:   // どくげしょう
        int findIdx = yourFields.indexWhere((e) => e.id == IndividualField.toxicSpikes);
        if (findIdx < 0) {
          yourFields.add(IndividualField(IndividualField.toxicSpikes)..extraArg1 = 1);
        }
        else {
          yourFields[findIdx].extraArg1 = 2;
        }
        break;
      case 303:     // おもかげやどし
        int statIdx = 4;    // みどりのめん->すばやさ
        switch (myState.pokemon.no) {
          case 10273:   // いどのめん->とくぼう
            statIdx = 3;
            break;
          case 10274:   // かまどのめん->こうげき
            statIdx = 0;
            break;
          case 10275:   // いしずえのめん->ぼうぎょ
            statIdx = 1;
            break;
          default:
            break;
        }
        myState.addStatChanges(true, statIdx, 1, yourState, abilityId: abilityID);
        break;
      default:
        break;
    }
    if (playerType.id == PlayerType.opponent && myState.currentAbility.id == 0) {
      ret.add(Guide()
        ..guideId = Guide.confAbility
        ..args = [abilityID]
        ..guideStr = 'あいての${opponentPokemonState.pokemon.name}のとくせいを${pokeData.abilities[abilityID]!.displayName}で確定しました。'
      );
      myState.setCurrentAbility(myState.pokemon.ability, yourState, isOwn, state);   // とくせい確定
    }

    return ret;
  }

  void processPassiveEffect(PokemonState myState, PokemonState yourState, bool isOwn, PhaseState state,) {
    var myFields = isOwn ? state.ownFields : state.opponentFields;
    var yourFields = isOwn ? state.opponentFields : state.ownFields;
    switch (id) {
      case 14:  // ふくがん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_3));
        break;
      case 23:  // かげふみ
        if (yourState.currentAbility.id != 23) {
          yourState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
        }
        break;
      case 32:  // てんのめぐみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.additionalEffect2));
        break;
      case 37:  // ちからもち
      case 74:  // ヨガパワー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        break;
      case 42:  // じりょく
        yourState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 2, state);
        break;
      case 55:  // はりきり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physicalAccuracy0_8));
        break;
      case 59:  // てんきや
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.powalenNormal));
        break;
      case 62:  // こんじょう
        if (myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
        }
        break;
      case 63:  // ふしぎなうろこ
        if (myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
        }
        break;
      case 71:  // ありじごく
        yourState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 3, state);
        break;
      case 77:  // ちどりあし
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
        }
        break;
      case 79:  // とうそうしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.opponentSex1_5));
        break;
      case 85:  // たいねつ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heatproof));
        break;
      case 87:  // かんそうはだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.drySkin));
        break;
      case 89:  // てつのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punch1_2));
        break;
      case 91:  // てきおうりょく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.typeBonus2));
        break;
      case 95:  // はやあし
        if (myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
        }
        break;
      case 96:  // ノーマルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalize));
        break;
      case 97:  // スナイパー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sniper));
        break;
      case 98:  // マジックガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.magicGuard));
        break;
      case 99:  // ノーガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noGuard));
        break;
      case 100: // あとだし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.stall));
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.technician));
        break;
      case 103: // ぶきよう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noItemEffect));
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noAbilityEffect));
        break;
      case 105: // きょううん
        myState.addVitalRank(1);
        break;
      case 109: // てんねん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreRank));
        break;
      case 110: // いろめがね
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.notGoodType2));
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamaged0_75));
        break;
      case 120: // すてみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.recoil1_2));
        break;
      case 122: // フラワーギフト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.negaForm));
        break;
      case 125: // ちからずく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sheerForce));
        break;
      case 127: // きんちょうかん
        yourFields.add(IndividualField(IndividualField.noBerry));
        break;
      case 134: // ヘヴィメタル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heavy2));
        break;
      case 135: // ライトメタル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heavy0_5));
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        if ((isOwn && myState.remainHP == myState.pokemon.h.real) || (!isOwn && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        break;
      case 137:  // どくぼうそう
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
        }
        break;
      case 138:  // ねつぼうそう
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.burn) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        }
        break;
      case 142:  // ぼうじん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 147:  // ミラクルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourStatusAccuracy50));
        break;
      case 148:  // アナライズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.analytic));
        break;
      case 151:  // すりぬけ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreWall));
        break;
      case 156:  // マジックミラー
        myState.ailmentsAdd(Ailment(Ailment.magicCoat), state);
        break;
      case 158:  // いたずらごころ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.prankster));
        break;
      case 159:   // すなのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockGroundSteel1_3));
        break;
      case 162:   // しょうりのほし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 169:   // ファーコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.guard2));
        break;
      case 171:   // ぼうだん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bulletProof));
        break;
      case 173:   // がんじょうあご
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bite1_5));
        break;
      case 174:   // フリーズスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.freezeSkin));
        break;
      case 176:   // バトルスイッチ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.shieldForm));
        break;
      case 177: // はやてのつばさ
        if ((isOwn && myState.remainHP == myState.pokemon.h.real) || (!isOwn && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
        break;
      case 178:   // メガランチャー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.wave1_5));
        break;
      case 181:   // かたいツメ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttack1_3));
        break;
      case 182:   // フェアリースキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairySkin));
        break;
      case 184:   // スカイスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airSkin));
        break;
      case 196:   // ひとでなし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.merciless));
        break;
      case 198:   // はりこみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.change2));
        break;
      case 199:   // すいほう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble1));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble2));
        break;
      case 200:   // はがねつかい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelWorker));
        break;
      case 204:   // うるおいボイス
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.liquidVoice));
        break;
      case 205:   // ヒーリングシフト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.healingShift));
        break;
      case 206:   // エレキスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricSkin));
        break;
      case 208:   // ぎょぐん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.singleForm));
        break;
      case 209:   // ばけのかわ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.transedForm || e.id == BuffDebuff.revealedForm);
          if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transedForm));
        }
        break;
      case 217:   // バッテリー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        break;
      case 218:   // もふもふ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackedDamage0_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttackedDamage2));
        break;
      case 233:   // ブレインフォース
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_25));
        break;
      case 239:   // スクリューおびれ
      case 242:   // すじがねいり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.targetRock));
        break;
      case 244:   // パンクロック
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sound1_3));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.soundedDamage0_5));
        break;
      case 246:   // こおりのりんぷん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDamaged0_5));
        break;
      case 247:   // じゅくせい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.nuts2));
        break;
      case 248:   // アイスフェイス
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace);
          if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceFace));
        }
        break;
      case 249:   // パワースポット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove1_3));
        break;
      case 252:   // はがねのせいしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steel1_5));
        break;
      case 255:   // ごりむちゅう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 258:   // はらぺこスイッチ
        if (!myState.isTerastaling) {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.harapekoForm || e.id == BuffDebuff.manpukuForm);
          if (findIdx < 0) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.manpukuForm));
          }
          else {
            myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.manpukuForm);
          }
        }
        break;
      case 260:   // ふかしのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackIgnoreGurad));
        break;
      case 262:   // トランジスタ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electric1_3));
        break;
      case 263:   // りゅうのあぎと
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragon1_5));
        break;
      case 272:   // きよめのしお
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghosted0_5));
        break;
      case 276:   // いわはこび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rock1_5));
        break;
      case 278:   // マイティチェンジ
        {
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm);
          if (findIdx < 0) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.naiveForm));
          }
        }
        break;
      case 284:   // わざわいのうつわ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack0_75));
        break;
      case 285:   // わざわいのつるぎ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense0_75));
        break;
      case 286:   // わざわいのおふだ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack0_75));
        break;
      case 287:   // わざわいのたま
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense0_75));
        break;
      case 292:   // きれあじ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.cut1_5));
        break;
      case 298:   // きんしのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.myceliumMight));
        break;
    }

    if (id == 186 || yourState.currentAbility.id == 186) { // ダークオーラ
      if (id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
      }
      else {
        int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
    }
    if (id == 187 || yourState.currentAbility.id == 187) { // フェアリーオーラ
      if (id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
      }
      else {
        int findIdx = myState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  void clearPassiveEffect(PokemonState myState, PokemonState yourState, bool isOwn, PhaseState state,) {
    var myFields = isOwn ? state.ownFields : state.opponentFields;
    var yourFields = isOwn ? state.opponentFields : state.ownFields;
    switch (id) {
      case 14:  // ふくがん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.accuracy1_3);
        break;
      case 32:  // てんのめぐみ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.additionalEffect2);
        break;
      case 37:  // ちからもち
      case 74:  // ヨガパワー
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack2);
        break;
      case 55:  // はりきり
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_5);
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physicalAccuracy0_8);
        break;
      case 59:  // てんきや
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.powalenNormal);
        break;
      case 62:  // こんじょう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        break;
      case 63:  // ふしぎなうろこ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense1_5);
        break;
      case 77:  // ちどりあし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        break;
      case 79:  // とうそうしん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.opponentSex1_5);
        break;
      case 85:  // たいねつ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.heatproof);
        break;
      case 87:  // かんそうはだ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.drySkin);
        break;
      case 89:  // てつのこぶし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.punch1_2);
        break;
      case 91:  // てきおうりょく
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.typeBonus2);
        break;
      case 95:  // はやあし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        break;
      case 96:  // ノーマルスキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.normalize);
        break;
      case 97:  // スナイパー
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.sniper);
        break;
      case 98:  // マジックガード
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.magicGuard);
        break;
      case 99:  // ノーガード
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.noGuard);
        break;
      case 100: // あとだし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.stall);
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.technician);
        break;
      case 103: // ぶきよう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.noItemEffect);
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.noAbilityEffect);
        break;
      case 105: // きょううん
        myState.addVitalRank(-1);
        break;
      case 109: // てんねん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ignoreRank);
        break;
      case 110: // いろめがね
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.notGoodType2);
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.greatDamaged0_75);
        break;
      case 120: // すてみ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.recoil1_2);
        break;
      case 122: // フラワーギフト
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.negaForm);
        break;
      case 125: // ちからずく
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.sheerForce);
        break;
      case 127: // きんちょうかん
        yourFields.removeWhere((e) => e.id == IndividualField.noBerry);
        break;
      case 134: // ヘヴィメタル
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.heavy2);
        break;
      case 135: // ライトメタル
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.heavy0_5);
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.damaged0_5);
        break;
      case 137:  // どくぼうそう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physical1_5);
        break;
      case 138:  // ねつぼうそう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_5);
        break;
      case 142:  // ぼうじん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.overcoat);
        break;
      case 147:  // ミラクルスキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourStatusAccuracy50);
        break;
      case 148:  // アナライズ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.analytic);
        break;
      case 151:  // すりぬけ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ignoreWall);
        break;
      case 156:  // マジックミラー
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.magicCoat);
        break;
      case 158:  // いたずらごころ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.prankster);
        break;
      case 159:   // すなのちから
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.rockGroundSteel1_3);
        break;
      case 162:   // しょうりのほし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.accuracy1_1);
        break;
      case 169:   // ファーコート
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.guard2);
        break;
      case 171:   // ぼうだん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.bulletProof);
        break;
      case 173:   // がんじょうあご
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.bite1_5);
        break;
      case 174:   // フリーズスキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.freezeSkin);
        break;
      case 176:   // バトルスイッチ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.shieldForm);
        break;
      case 177: // はやてのつばさ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.galeWings);
        break;
      case 178:   // メガランチャー
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.wave1_5);
        break;
      case 181:   // かたいツメ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.directAttack1_3);
        break;
      case 182:   // フェアリースキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.fairySkin);
        break;
      case 184:   // スカイスキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.airSkin);
        break;
      case 196:   // ひとでなし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.merciless);
        break;
      case 198:   // はりこみ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.change2);
        break;
      case 199:   // すいほう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.waterBubble1);
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.waterBubble2);
        break;
      case 200:   // はがねつかい
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.steelWorker);
        break;
      case 204:   // うるおいボイス
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.liquidVoice);
        break;
      case 205:   // ヒーリングシフト
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.healingShift);
        break;
      case 206:   // エレキスキン
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.electricSkin);
        break;
      case 208:   // ぎょぐん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.singleForm);
        break;
      case 209:   // ばけのかわ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.transedForm || e.id == BuffDebuff.revealedForm);
        break;
      case 217:   // バッテリー
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_5);
        break;
      case 218:   // もふもふ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.directAttackedDamage0_5);
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.fireAttackedDamage2);
        break;
      case 233:   // ブレインフォース
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.greatDamage1_25);
        break;
      case 239:   // スクリューおびれ
      case 242:   // すじがねいり
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.targetRock);
        break;
      case 244:   // パンクロック
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.sound1_3);
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.soundedDamage0_5);
        break;
      case 246:   // こおりのりんぷん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialDamaged0_5);
        break;
      case 247:   // じゅくせい
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.nuts2);
        break;
      case 248:   // アイスフェイス
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace);
        break;
      case 249:   // パワースポット
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attackMove1_3);
        break;
      case 252:   // はがねのせいしん
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.steel1_5);
        break;
      case 255:   // ごりむちゅう
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.gorimuchu);
        break;
      case 258:   // はらぺこスイッチ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.harapekoForm || e.id == BuffDebuff.manpukuForm);
        break;
      case 260:   // ふかしのこぶし
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.directAttackIgnoreGurad);
        break;
      case 262:   // トランジスタ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.electric1_3);
        break;
      case 263:   // りゅうのあぎと
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.dragon1_5);
        break;
      case 272:   // きよめのしお
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.ghosted0_5);
        break;
      case 276:   // いわはこび
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.rock1_5);
        break;
      case 278:   // マイティチェンジ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm);
        break;
      case 284:   // わざわいのうつわ
        yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialAttack0_75);
        break;
      case 285:   // わざわいのつるぎ
        yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense0_75);
        break;
      case 286:   // わざわいのおふだ
        yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack0_75);
        break;
      case 287:   // わざわいのたま
        yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.specialDefense0_75);
        break;
      case 292:   // きれあじ
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.cut1_5);
        break;
      case 298:   // きんしのちから
        myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.myceliumMight);
        break;
    }

    if (id == 186 && yourState.currentAbility.id != 186) { // ダークオーラ
      myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiDarkAura || e.id == BuffDebuff.darkAura);
      yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiDarkAura || e.id == BuffDebuff.darkAura);
    }
    if (id == 187 && yourState.currentAbility.id != 187) { // フェアリーオーラ
      myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiFairyAura || e.id == BuffDebuff.fairyAura);
      yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiFairyAura || e.id == BuffDebuff.fairyAura);
    }
    if (id == 188) { // オーラブレイク
      myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiFairyAura || e.id == BuffDebuff.antiDarkAura);
      yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.antiFairyAura || e.id == BuffDebuff.antiDarkAura);
      if (yourState.currentAbility.id == 186) { // ダークオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
      if (yourState.currentAbility.id == 187) { // フェアリーオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  // TurnEffectのarg1が決定できる場合はその値を返す
  static int getAutoArg1(
    int abilityID, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    bool isMe = player.id == PlayerType.me;

    switch (abilityID) {
      case 10:        // ちくでん
      case 11:        // ちょすい
        return isMe? -((myState.pokemon.h.real / 4).floor()) : -25;
      case 87:        // かんそうはだ
        if (prevAction?.move!.getReplacedMove(prevAction.move!.move, 0, myState).type.id == 11) {   // みずタイプのわざを受けた時
          return isMe? -((myState.pokemon.h.real / 4).floor()) : -25;
        }
        else if (state.weather.id == Weather.sunny) { // 晴れの時
          isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        }
        else if (state.weather.id == Weather.rainy) { // 雨の時
          isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
        }
        break;
      case 16:        // へんしょく
        return prevAction!.move!.move.type.id;
      case 24:        // さめはだ
      case 160:       // てつのトゲ
        return !isMe ? (yourState.pokemon.h.real / 8).floor() : 12;
      case 106:       // ゆうばく
        return !isMe ? (yourState.pokemon.h.real / 4).floor() : 25;
      case 209:       // ばけのかわ
      case 94:        // サンパワー
        return isMe ? (myState.pokemon.h.real / 8).floor() : 12;
      case 168:       // へんげんじざい
      case 236:       // リベロ
        // TODO?
        break;
      case 44:        // あめうけざら
      case 115:       // アイスボディ
        return isMe ? -((myState.pokemon.h.real / 16).floor()) : -6;
      case 90:        // ポイズンヒール
        return isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
      case 281:       // こだいかっせい
      case 282:       // ブーストエナジー
        if (timing.id == AbilityTiming.everyTurnEnd) {
          return -1;
        }
        break;
      case 36:        // トレース
        return yourState.currentAbility.id;
      case 139:   // しゅうかく
        var lastLostBerry = myState.hiddenBuffs.where((e) => e.id == BuffDebuff.lastLostBerry);
        if (lastLostBerry.isNotEmpty) {
          return lastLostBerry.first.extraArg1;
        }
        break;
      default:
        break;
    }

    return 0;
  }

  // TurnEffectのarg2が決定できる場合はその値を返す
  static int getAutoArg2(
    int abilityID, PlayerType player, PokemonState myState, PokemonState yourState, PhaseState state,
    TurnEffect? prevAction, AbilityTiming timing,
  ) {
    return 0;
  }

  // SQLに保存された文字列からabilityをパース
  static Ability deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Ability(
      int.parse(elements[0]),
      elements[1],
      AbilityTiming(int.parse(elements[2])),
      Target(int.parse(elements[3])),
      AbilityEffect(int.parse(elements[4]))
    );
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$displayName$split1${timing.id}$split1${target.id}$split1${effect.id}';
  }
}
