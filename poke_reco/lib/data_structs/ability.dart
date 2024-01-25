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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/tool.dart';

class Ability extends Equatable implements Copyable {
  final int id;
  final String _displayName;
  final String _displayNameEn;
  final Timing timing;
  final Target target;

  @override
  List<Object?> get props => [
        id,
        _displayName,
        _displayNameEn,
        timing,
        target,
      ];

  const Ability(
    this.id,
    this._displayName,
    this._displayNameEn,
    this.timing,
    this.target,
  );

  @override
  Ability copy() => Ability(id, _displayName, _displayNameEn, timing, target);

  String get displayName {
    switch (PokeDB().language) {
      case Language.english:
        return _displayNameEn;
      case Language.japanese:
      default:
        return _displayName;
    }
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      abilityColumnId: id,
      abilityColumnName: _displayName,
      abilityColumnEnglishName: _displayNameEn,
      abilityColumnTiming: timing.index,
      abilityColumnTarget: target.index,
    };
    return map;
  }

  // 交換可能なとくせいかどうか
  bool get canExchange {
    const ids = [
      225,
      248,
      149,
      241,
      256,
      208,
      266,
      211,
      161,
      209,
      176,
      258,
      25,
    ];
    return !ids.contains(id);
  }

  // 上書きできるとくせいかどうか
  bool get canOverWrite {
    const ids = [
      225,
      248,
      241,
      210,
      208,
      282,
      281,
      266,
      211,
      213,
      161,
      209,
      176,
      278,
      121,
      197,
      304,
    ];
    return !ids.contains(id);
  }

  // コピー可能なとくせいかどうか
  bool get canCopy {
    const ids = [
      225,
      248,
      149,
      241,
      303,
      223,
      256,
      150,
      210,
      208,
      282,
      281,
      279,
      266,
      211,
      213,
      161,
      59,
      36,
      209,
      176,
      258,
      122,
      278,
      121,
      197,
      222,
      305,
    ];
    return !ids.contains(id);
  }

  // かたやぶり/きんしのちから/ターボブレイズ/テラボルテージで無視されるとくせいかどうか
  bool get canIgnored {
    const ids = [
      248,
      47,
      126,
      165,
      188,
      283,
      52,
      274,
      4,
      5,
      87,
      272,
      21,
      179,
      29,
      246,
      273,
      75,
      6,
      7,
      214,
      73,
      299,
      175,
      199,
      8,
      51,
      39,
      157,
      186,
      85,
      86,
      10,
      77,
      11,
      296,
      140,
      78,
      109,
      297,
      12,
      270,
      60,
      116,
      209,
      257,
      35,
      145,
      244,
      275,
      219,
      31,
      169,
      111,
      187,
      63,
      25,
      15,
      26,
      122,
      166,
      132,
      134,
      43,
      142,
      171,
      20,
      40,
      156,
      136,
      41,
      240,
      147,
      17,
      218,
      18,
      72,
      81,
      114,
      135,
      102,
      19,
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
    int? changePokemonIndex, {
    required AppLocalizations loc,
  }) {
    final pokeData = PokeDB();
    List<Guide> ret = [];
    var myPlayer = playerType;
    var yourPlayer = playerType.opposite;
    var myFields = state.getIndiFields(playerType);
    var yourFields = state.getIndiFields(playerType.opposite);
    var isOwn = playerType == PlayerType.me;

    switch (abilityID) {
      case 1: // あくしゅう
        yourState.ailmentsAdd(Ailment(Ailment.flinch), state); // ひるませる
        break;
      case 2: // あめふらし
        state.weather = Weather(Weather.rainy)
          ..extraArg1 = myState.holdingItem?.id == 262 ? 8 : 5;
        break;
      case 3: // かそく
      case 78: // でんきエンジン
      case 80: // ふくつのこころ
      case 155: // びびり
        myState.addStatChanges(true, 4, 1, yourState, abilityId: abilityID);
        break;
      case 7: // じゅうなん
        {
          // まひになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.paralysis);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 9: // せいでんき
        yourState.ailmentsAdd(Ailment(Ailment.paralysis), state);
        break;
      case 10: // ちくでん
      case 11: // ちょすい
      case 44: // あめうけざら
      case 87: // かんそうはだ
      case 90: // ポイズンヒール
      case 94: // サンパワー
      case 115: // アイスボディ
      case 297: // どしょく
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case 12: // どんかん
        {
          // メロメロ/ちょうはつになっていれば消す
          int findIdx = myState.ailmentsIndexWhere(
              (element) => element.id == Ailment.infatuation);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.taunt);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 13: // ノーてんき
      case 76: // エアロック
        Weather.processWeatherEffect(
            state.weather, state.weather, myState, null);
        break;
      case 15: // ふみん
      case 72: // やるき
      case 175: // スイートベール
        {
          // ねむりになっていれば消す
          int findIdx = myState.ailmentsIndexWhere((element) =>
              element.id == Ailment.sleep || element.id == Ailment.sleepy);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 16: // へんしょく
        {
          myState.pokemon.type1 = PokeType.values[extraArg1];
          myState.pokemon.type2 = null;
          myState.ailmentsRemoveWhere(
              (e) => e.id == Ailment.halloween || e.id == Ailment.forestCurse);
        }
        break;
      case 17: // めんえき
      case 257: // パステルベール
        {
          // どく/もうどくになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.poison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
          findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.badPoison);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 18: // もらいび
        {
          // ほのおわざ威力1.5倍
          if (myState.buffDebuffs.containsByID(BuffDebuff.flashFired)) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.flashFired));
          }
        }
        break;
      case 20: // マイペース
        {
          // こんらんになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.confusion);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 22: // いかく
        yourState.addStatChanges(false, 0, -1, myState,
            myFields: yourFields, yourFields: myFields, abilityId: abilityID);
        break;
      case 24: // さめはだ
      case 106: // ゆうばく
      case 123: // ナイトメア
      case 160: // てつのトゲ
      case 215: // とびだすなかみ
        if (yourPlayer == PlayerType.me) {
          yourState.remainHP -= extraArg1;
        } else {
          yourState.remainHPPercent -= extraArg1;
        }
        break;
      case 27: // ほうし
        if (extraArg1 != 0) {
          yourState.ailmentsAdd(Ailment(extraArg1), state);
        }
        break;
      case 28: // シンクロ
        {
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.burn);
          if (findIdx < 0) {
            findIdx = myState
                .ailmentsIndexWhere((element) => element.id == Ailment.poison);
          }
          if (findIdx < 0) {
            findIdx = myState.ailmentsIndexWhere(
                (element) => element.id == Ailment.badPoison);
          }
          if (findIdx < 0) {
            findIdx = myState.ailmentsIndexWhere(
                (element) => element.id == Ailment.paralysis);
          }
          if (findIdx >= 0) {
            yourState.ailmentsAdd(myState.ailments(findIdx), state);
          }
        }
        break;
      case 31: // ひらいしん
      case 114: // よびみず
      case 201: // ぎゃくじょう
      case 220: // ソウルハート
      case 265: // くろのいななき
      case 267: // じんばいったい（くろのいななき）
        myState.addStatChanges(true, 2, 1, yourState, abilityId: abilityID);
        break;
      case 36: // トレース
        {
          if (playerType == PlayerType.opponent &&
              myState.getCurrentAbility().id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confAbility
              ..args = [abilityID]
              ..guideStr = loc.battleGuideConfAbility(
                  pokeData.abilities[abilityID]!.displayName,
                  myState.pokemon.omittedName));
          }
          myState.setCurrentAbility(
              pokeData.abilities[extraArg1]!, yourState, isOwn, state);
          if (playerType == PlayerType.me &&
              yourState.getCurrentAbility().id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confAbility
              ..args = [extraArg1]
              ..guideStr = loc.battleGuideConfAbility(
                  pokeData.abilities[extraArg1]!.displayName,
                  yourState.pokemon.omittedName));
            yourState.setCurrentAbility(
                yourState.pokemon.ability, myState, !isOwn, state);
          }
        }
        break;
      case 38: // どくのトゲ
      case 143: // どくしゅ
        yourState.ailmentsAdd(Ailment(Ailment.poison), state);
        break;
      case 40: // マグマのよろい
        {
          // こおりになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.freeze);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 41: // みずのベール
      case 199: // すいほう
        {
          // やけどになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id == Ailment.burn);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 45: // すなおこし
      case 245: // すなはき
        state.weather = Weather(Weather.sandStorm)
          ..extraArg1 = myState.holdingItem?.id == 260 ? 8 : 5;
        break;
      case 49: // ほのおのからだ
        yourState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case 53: // ものひろい
      case 139: // しゅうかく
        myState.holdingItem = pokeData.items[extraArg1];
        break;
      case 56: // メロメロボディ
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state);
        break;
      case 61: // だっぴ
      case 93: // うるおいボディ
        {
          // まひ/こおり/やけど/どく/もうどく/ねむりになっていれば消す
          int findIdx = myState
              .ailmentsIndexWhere((element) => element.id <= Ailment.sleep);
          if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
        }
        break;
      case 70: // ひでり
      case 288: // ひひいろのこどう
        state.weather = Weather(Weather.sunny)
          ..extraArg1 = myState.holdingItem?.id == 261 ? 8 : 5;
        break;
      case 83: // いかりのつぼ
        myState.addStatChanges(true, 0, 6, yourState, abilityId: abilityID);
        break;
      case 88: // ダウンロード
      case 224: // ビーストブースト
        myState.addStatChanges(true, extraArg1, 1, yourState,
            abilityId: abilityID);
        break;
      case 108: // よちむ
        // わざ確定
        {
          var tmp = opponentPokemonState.moves
              .where((element) => element.id != 0 && element.id == extraArg1);
          if (extraArg1 != 165 && // わるあがきは除外
              myPlayer == PlayerType.me &&
              opponentPokemonState.moves.length < 4 &&
              tmp.isEmpty) {
            ret.add(Guide()
              ..guideId = Guide.confMove
              ..canDelete = false
              ..guideStr = loc.battleGuideConfMove(
                  pokeData.moves[extraArg1]!.displayName,
                  opponentPokemonState.pokemon.omittedName));
          }
        }
        break;
      case 112: // スロースタート
        if (extraArg1 == 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackSpeed0_5));
        } else {
          myState.buffDebuffs.removeAllByID(BuffDebuff.attackSpeed0_5);
        }
        break;
      case 117: // ゆきふらし
        state.weather = Weather(Weather.snowy)
          ..extraArg1 = myState.holdingItem?.id == 259 ? 8 : 5;
        break;
      case 119: // おみとおし
        // もちもの確定
        {
          if (extraArg1 != 0 &&
              myPlayer == PlayerType.me &&
              opponentPokemonState.getHoldingItem()?.id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confItem
              ..args = [extraArg1]
              ..guideStr = loc.battleGuideConfItem2(
                  pokeData.items[extraArg1]!.displayName,
                  opponentPokemonState.pokemon.omittedName));
          }
          yourState.holdingItem = pokeData.items[extraArg1]!;
        }
        break;
      case 124: // わるいてぐせ
      case 170: // マジシャン
        myState.holdingItem = pokeData.items[extraArg1]!;
        yourState.holdingItem = null;
        break;
      case 128: // まけんき
        myState.addStatChanges(true, 0, 2, yourState, abilityId: abilityID);
        break;
      case 130: // のろわれボディ
        yourState.ailmentsAdd(
            Ailment(Ailment.disable)..extraArg1 = extraArg1, state);
        break;
      case 133: // くだけるよろい
        myState.addStatChanges(true, 1, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 4, 2, yourState, abilityId: abilityID);
        break;
      case 141: // ムラっけ
        myState.addStatChanges(true, extraArg1, 2, yourState,
            abilityId: abilityID);
        myState.addStatChanges(true, extraArg2, -1, yourState,
            abilityId: abilityID);
        break;
      case 149: // イリュージョン
        if (playerType == PlayerType.opponent && extraArg1 > 0) {
          var pokeNo = state
              .getPokemonStates(PlayerType.opponent)[extraArg1 - 1]
              .pokemon
              .no;
          if (pokeNo == PokeBase.zoruaNo) state.canZorua = false;
          if (pokeNo == PokeBase.zoroarkNo) state.canZoroark = false;
          if (pokeNo == PokeBase.zoruaHisuiNo) state.canZoruaHisui = false;
          if (pokeNo == PokeBase.zoroarkHisuiNo) state.canZoroarkHisui = false;
          state.makePokemonOther(playerType, pokeNo);
          var newState = state.getPokemonState(playerType, null);
          newState.setCurrentAbility(
              pokeData.abilities[149]!, yourState, isOwn, state);
          newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.zoroappear));
          return ret;
        }
        break;
      case 150: // かわりもの
        if (!yourState.buffDebuffs.containsByAnyID(
                [BuffDebuff.substitute, BuffDebuff.transform]) &&
            !myState.buffDebuffs.containsByID(BuffDebuff.transform)) {
          // 対象がみがわり状態でない・お互いにへんしん状態でないなら
          myState.type1 = yourState.type1;
          myState.type2 = yourState.type2;
          myState.setCurrentAbility(
              yourState.currentAbility, yourState, isOwn, state);
          for (int i = 0; i < yourState.moves.length; i++) {
            if (i >= myState.moves.length) {
              myState.moves.add(yourState.moves[i]);
            } else {
              myState.moves[i] = yourState.moves[i];
            }
            myState.usedPPs[i] = 0;
          }
          for (final stat in StatIndexList.listHtoS) {
            // HP以外のステータス実数値
            myState.minStats[stat].real = yourState.minStats[stat].real;
            myState.maxStats[stat].real = yourState.maxStats[stat].real;
          }
          for (int i = 0; i < 7; i++) {
            myState.forceSetStatChanges(i, yourState.statChanges(i));
          }
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transform)
            ..extraArg1 = yourState.pokemon.no
            ..turns = yourState.pokemon.sex.id);
        }
        break;
      case 152: // ミイラ
      case 268: // とれないにおい
        yourState.setCurrentAbility(
            myState.currentAbility, myState, !isOwn, state);
        break;
      case 153: // じしんかじょう
      case 154: // せいぎのこころ
      case 157: // そうしょく
      case 234: // ふとうのけん
      case 264: // しろのいななき
      case 266: // じんばいったい（しろのいななき）
      case 270: // ねつこうかん
      case 274: // かぜのり
        myState.addStatChanges(true, 0, 1, yourState, abilityId: abilityID);
        break;
      case 161: // ダルマモード(現状SVではヒヒダルマ登場してないので実装していない)
        myState.buffDebuffs.removeOrAddByID(BuffDebuff.zenMode);
        break;
      case 165: // アロマベール
        {
          // メロメロ/アンコール/いちゃもん/かなしばり/ちょうはつ/かいふくふうじになっていれば消す
          myState.ailmentsRemoveWhere((e) =>
              e.id == Ailment.infatuation ||
              e.id == Ailment.encore ||
              e.id == Ailment.torment ||
              e.id == Ailment.disable ||
              e.id == Ailment.taunt ||
              e.id == Ailment.healBlock);
        }
        break;
      case 166: // フラワーベール
      case 272: // きよめのしお
        {
          // まひ/こおり/やけど/どく/もうどく/ねむり/ねむけになっていれば消す
          myState.ailmentsRemoveWhere((element) =>
              element.id <= Ailment.sleep || element.id == Ailment.sleepy);
        }
        break;
      case 168: // へんげんじざい
      case 236: // リベロ
        myState.type1 = PokeType.values[extraArg1];
        myState.type2 = null;
        myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.protean));
        myState.ailmentsRemoveWhere(
            (e) => e.id == Ailment.halloween || e.id == Ailment.forestCurse);
        break;
      case 172: // かちき
        myState.addStatChanges(true, 2, 2, yourState, abilityId: abilityID);
        break;
      case 183: // ぬめぬめ
      case 238: // わたげ
        yourState.addStatChanges(false, 4, -1, myState,
            myFields: yourFields, yourFields: myFields, abilityId: abilityID);
        break;
      case 176: // バトルスイッチ(現状SVでギルガルドが登場していないため未実装)
        myState.buffDebuffs
            .switchID(BuffDebuff.bladeForm, BuffDebuff.shieldForm);
        break;
      case 192: // じきゅうりょく
      case 235: // ふくつのたて
        myState.addStatChanges(true, 1, 1, yourState, abilityId: abilityID);
        break;
      case 195: // みずがため
      case 273: // こんがりボディ
        myState.addStatChanges(true, 1, 2, yourState, abilityId: abilityID);
        break;
      case 208: // ぎょぐん(現状SVでは登場していないため未実装)
        myState.buffDebuffs
            .switchID(BuffDebuff.singleForm, BuffDebuff.multipleForm);
        break;
      case 209: // ばけのかわ
        {
          myState.buffDebuffs.removeAllByID(BuffDebuff.transedForm);
          if (playerType == PlayerType.me) {
            myState.remainHP -= extraArg1;
          } else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        break;
      case 210: // きずなへんげ
        myState.addStatChanges(true, 0, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 2, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 4, 1, yourState, abilityId: abilityID);
        break;
      case 211: // スワームチェンジ
        {
          myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.perfectForm);
          if (playerType == PlayerType.me) {
            myState.remainHP -= extraArg1;
          } else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        break;
      case 216: // おどりこ
        switch (extraArg1) {
          case 872: // アクアステップ
          case 10552: // ほのおのまい(とくこう1段階上昇)
            if (yourPlayer == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            } else {
              yourState.remainHPPercent -= extraArg2;
            }
            myState.addStatChanges(true, extraArg1 == 872 ? 4 : 2, 1, yourState,
                moveId: extraArg1);
            break;
          case 80: // はなびらのまい
            if (yourPlayer == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            } else {
              yourState.remainHPPercent -= extraArg2;
            }
            myState.ailmentsAdd(Ailment(Ailment.thrash), state);
            break;
          case 552: // ほのおのまい
          case 686: // めざめるダンス
            if (yourPlayer == PlayerType.me) {
              yourState.remainHP -= extraArg2;
            } else {
              yourState.remainHPPercent -= extraArg2;
            }
            break;
          case 837: // しょうりのまい
            myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 1, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 483: // ちょうのまい
            myState.addStatChanges(true, 2, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 3, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 14: // つるぎのまい
            myState.addStatChanges(true, 0, 2, yourState, moveId: extraArg1);
            break;
          case 297: // フェザーダンス
            yourState.addStatChanges(false, 0, -2, myState,
                myFields: yourFields, yourFields: myFields, moveId: extraArg1);
            break;
          case 298: // フラフラダンス
            yourState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 461: // みかづきのまい
            if (myPlayer == PlayerType.me) {
              myState.remainHP = 0;
            } else {
              myState.remainHPPercent = 0;
            }
            myFields.add(IndividualField(IndividualField.lunarDance));
            break;
          case 349: // りゅうのまい
            myState.addStatChanges(true, 0, 1, yourState, moveId: extraArg1);
            myState.addStatChanges(true, 4, 1, yourState, moveId: extraArg1);
            break;
          case 775: // ソウルビート
            {
              if (myPlayer == PlayerType.me) {
                myState.remainHP -= extraArg2;
              } else {
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
      case 221: // カーリーヘアー
        yourState.addStatChanges(true, 4, -1, myState, abilityId: abilityID);
        break;
      case 226: // エレキメイカー
      case 289: // ハドロンエンジン
        state.field = Field(Field.electricTerrain)
          ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
        break;
      case 227: // サイコメイカー
        state.field = Field(Field.psychicTerrain)
          ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
        break;
      case 228: // ミストメイカー
        state.field = Field(Field.mistyTerrain)
          ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
        break;
      case 229: // グラスメイカー
        state.field = Field(Field.grassyTerrain)
          ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
        break;
      case 243: // じょうききかん
        myState.addStatChanges(true, 4, 6, yourState, abilityId: abilityID);
        break;
      case 248: // アイスフェイス
        {
          if (myState.buffDebuffs.containsByID(BuffDebuff.iceFace)) {
            myState.buffDebuffs
                .changeID(BuffDebuff.iceFace, BuffDebuff.niceFace);
            // TODO この2行csvに移したい
            myState.maxStats[StatIndex.B].race = 70;
            myState.maxStats[StatIndex.D].race = 50;
            myState.maxStats[StatIndex.S].race = 130;
            myState.minStats[StatIndex.B].race = 70;
            myState.minStats[StatIndex.D].race = 50;
            myState.minStats[StatIndex.S].race = 130;
            for (final stat in [StatIndex.B, StatIndex.D, StatIndex.S]) {
              var biases = Temper.getTemperBias(myState.pokemon.temper);
              myState.maxStats[stat].real = SixParams.getRealABCDS(
                  myState.pokemon.level,
                  myState.maxStats[stat].race,
                  myState.maxStats[stat].indi,
                  myState.maxStats[stat].effort,
                  biases[stat.index - 1]);
              myState.minStats[stat].real = SixParams.getRealABCDS(
                  myState.pokemon.level,
                  myState.minStats[stat].race,
                  myState.minStats[stat].indi,
                  myState.minStats[stat].effort,
                  biases[stat.index - 1]);
            }
          } else {
            if (myState.buffDebuffs.containsByID(BuffDebuff.niceFace)) {
              myState.buffDebuffs
                  .changeID(BuffDebuff.niceFace, BuffDebuff.iceFace);
              // TODO この2行csvに移したい
              myState.maxStats[StatIndex.B].race = 110;
              myState.maxStats[StatIndex.D].race = 90;
              myState.maxStats[StatIndex.S].race = 50;
              myState.minStats[StatIndex.B].race = 110;
              myState.minStats[StatIndex.D].race = 90;
              myState.minStats[StatIndex.S].race = 50;
              for (final stat in [StatIndex.B, StatIndex.D, StatIndex.S]) {
                var biases = Temper.getTemperBias(myState.pokemon.temper);
                myState.maxStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level,
                    myState.maxStats[stat].race,
                    myState.maxStats[stat].indi,
                    myState.maxStats[stat].effort,
                    biases[stat.index - 1]);
                myState.minStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level,
                    myState.minStats[stat].race,
                    myState.minStats[stat].indi,
                    myState.minStats[stat].effort,
                    biases[stat.index - 1]);
              }
            }
          }
        }
        break;
      case 251: // バリアフリー
        myFields.removeWhere((e) =>
            e.id == IndividualField.reflector ||
            e.id == IndividualField.lightScreen ||
            e.id == IndividualField.auroraVeil);
        yourFields.removeWhere((e) =>
            e.id == IndividualField.reflector ||
            e.id == IndividualField.lightScreen ||
            e.id == IndividualField.auroraVeil);
        break;
      case 253: // ほろびのボディ
        myState.ailmentsAdd(Ailment(Ailment.perishSong), state);
        yourState.ailmentsAdd(Ailment(Ailment.perishSong), state);
        break;
      case 254: // さまようたましい
        if (yourState.currentAbility.canExchange) {
          var tmp = yourState.currentAbility;
          yourState.setCurrentAbility(
              myState.currentAbility, myState, !isOwn, state);
          myState.setCurrentAbility(tmp, yourState, isOwn, state);
        }
        break;
      case 258: // はらぺこスイッチ
        myState.buffDebuffs
            .switchID(BuffDebuff.manpukuForm, BuffDebuff.harapekoForm);
        break;
      case 269: // こぼれダネ
        state.field = Field(Field.grassyTerrain)
          ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
        break;
      case 271: // いかりのこうら
        myState.addStatChanges(true, 0, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 1, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 2, 1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 3, -1, yourState, abilityId: abilityID);
        myState.addStatChanges(true, 4, 1, yourState, abilityId: abilityID);
        break;
      case 277: // ふうりょくでんき
      case 280: // でんきにかえる
        myState.ailmentsAdd(Ailment(Ailment.charging), state);
        break;
      case 281: // こだいかっせい
        if (extraArg1 >= 0) {
          int arg = 0;
          if (state.weather.id != Weather.sunny) {
            // 晴れではないのに発動したら
            if (playerType == PlayerType.opponent &&
                myState.getHoldingItem()?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [1696]
                ..guideStr = loc.battleGuideConfItem2(
                    pokeData.items[1696]!.displayName,
                    opponentPokemonState.pokemon.omittedName));
            }
            myState.holdingItem = null; // アイテム消費
            arg = 1;
          }
          myState.buffDebuffs.add(
              BuffDebuff(BuffDebuff.attack1_3 + extraArg1)..extraArg1 = arg);
        } else {
          myState.buffDebuffs.list.removeWhere((e) =>
              e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5);
        }
        break;
      case 282: // クォークチャージ
        if (extraArg1 >= 0) {
          int arg = 0;
          if (state.field.id != Field.electricTerrain) {
            // エレキフィールドではないのに発動したら
            if (playerType == PlayerType.opponent &&
                myState.getHoldingItem()?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [1696]
                ..guideStr = loc.battleGuideConfItem2(
                    pokeData.items[1696]!.displayName,
                    opponentPokemonState.pokemon.omittedName));
            }
            myState.holdingItem = null; // アイテム消費
            arg = 1;
          }
          myState.buffDebuffs.add(
              BuffDebuff(BuffDebuff.attack1_3 + extraArg1)..extraArg1 = arg);
        } else {
          myState.buffDebuffs.list.removeWhere((e) =>
              e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5);
        }
        break;
      case 290: // びんじょう
        myState.addStatChanges(true, extraArg1, extraArg2, yourState,
            abilityId: abilityID);
        break;
      case 291: // はんすう
        ret.addAll(Item.processEffect(
          extraArg1,
          playerType,
          myState,
          yourState,
          state,
          extraArg2,
          0,
          changePokemonIndex,
          loc: loc,
        ));
        break;
      case 293: // そうだいしょう
        {
          int faintingNum = state.getFaintingCount(playerType);
          if (faintingNum > 0) {
            myState.buffDebuffs
                .add(BuffDebuff(BuffDebuff.power10 + faintingNum - 1));
          }
        }
        break;
      case 295: // どくげしょう
        int findIdx =
            yourFields.indexWhere((e) => e.id == IndividualField.toxicSpikes);
        if (findIdx < 0) {
          yourFields
              .add(IndividualField(IndividualField.toxicSpikes)..extraArg1 = 1);
        } else {
          yourFields[findIdx].extraArg1 = 2;
        }
        break;
      case 300: // かんろなミツ
        yourState.addStatChanges(false, 6, -1, myState,
            myFields: yourFields, yourFields: myFields, abilityId: abilityID);
        break;
      case 302: // どくのくさり
        yourState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case 303: // おもかげやどし
        int statIdx = 4; // みどりのめん->すばやさ
        switch (myState.pokemon.no) {
          case 10273: // いどのめん->とくぼう
            statIdx = 3;
            break;
          case 10274: // かまどのめん->こうげき
            statIdx = 0;
            break;
          case 10275: // いしずえのめん->ぼうぎょ
            statIdx = 1;
            break;
          default:
            break;
        }
        myState.addStatChanges(true, statIdx, 1, yourState,
            abilityId: abilityID);
        break;
      case 304: // テラスチェンジ
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.terastalForm);
        // TODO この2行csvに移したい
        myState.maxStats.h.race = 95;
        myState.maxStats.a.race = 95;
        myState.maxStats.b.race = 110;
        myState.maxStats.c.race = 105;
        myState.maxStats.d.race = 110;
        myState.maxStats.s.race = 85;
        myState.minStats.h.race = 95;
        myState.minStats.a.race = 95;
        myState.minStats.b.race = 110;
        myState.minStats.c.race = 105;
        myState.minStats.d.race = 110;
        myState.minStats.s.race = 85;
        for (final stat in StatIndexList.listHtoS) {
          var biases = Temper.getTemperBias(myState.pokemon.temper);
          myState.maxStats[stat].real = SixParams.getRealABCDS(
              myState.pokemon.level,
              myState.maxStats[stat].race,
              myState.maxStats[stat].indi,
              myState.maxStats[stat].effort,
              biases[stat.index - 1]);
          myState.minStats[stat].real = SixParams.getRealABCDS(
              myState.pokemon.level,
              myState.minStats[stat].race,
              myState.minStats[stat].indi,
              myState.minStats[stat].effort,
              biases[stat.index - 1]);
        }
        if (playerType == PlayerType.me) {
          myState.remainHP += (5 * 2 * myState.pokemon.level / 100).floor();
        }
        myState.setCurrentAbility(pokeData.abilities[305]!, yourState, isOwn,
            state); // とくせいをテラスシェルに変更
        break;
      case 306: // ゼロフォーミング
        state.weather = Weather(0);
        state.field = Field(0);
        break;
      case 10000 + BuffDebuff.unomiForm: // うのミサイル(うのみのすがた)
        if (isOwn) {
          yourState.remainHPPercent -= 25;
        } else {
          yourState.remainHP -= (yourState.pokemon.h.real / 4).floor();
        }
        yourState.addStatChanges(false, 1, -1, myState);
        myState.buffDebuffs.removeAllByID(BuffDebuff.unomiForm);
        break;
      case 10000 + BuffDebuff.marunomiForm: // うのミサイル(うのみのすがた)
        if (isOwn) {
          yourState.remainHPPercent -= 25;
        } else {
          yourState.remainHP -= (yourState.pokemon.h.real / 4).floor();
        }
        yourState.ailmentsAdd(Ailment(Ailment.paralysis), state);
        myState.buffDebuffs.removeAllByID(BuffDebuff.marunomiForm);
        break;
      default:
        break;
    }
    if (playerType == PlayerType.opponent &&
        myState.getCurrentAbility().id == 0) {
      ret.add(Guide()
        ..guideId = Guide.confAbility
        ..args = [abilityID]
        ..guideStr = loc.battleGuideConfAbility(
            pokeData.abilities[abilityID]!.displayName,
            opponentPokemonState.pokemon.omittedName));
      myState.setCurrentAbility(
          myState.pokemon.ability, yourState, isOwn, state); // とくせい確定
    }

    return ret;
  }

  void processPassiveEffect(
    PokemonState myState,
    PokemonState yourState,
    bool isOwn,
    PhaseState state,
  ) {
    var yourFields = isOwn
        ? state.getIndiFields(PlayerType.opponent)
        : state.getIndiFields(PlayerType.me);
    switch (id) {
      case 14: // ふくがん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_3));
        break;
      case 23: // かげふみ
        if (yourState.currentAbility.id != 23) {
          yourState.ailmentsAdd(
              Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
        }
        break;
      case 32: // てんのめぐみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.additionalEffect2));
        break;
      case 37: // ちからもち
      case 74: // ヨガパワー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        break;
      case 42: // じりょく
        yourState.ailmentsAdd(
            Ailment(Ailment.cannotRunAway)..extraArg1 = 2, state);
        break;
      case 55: // はりきり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physicalAccuracy0_8));
        break;
      case 59: // てんきや
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.powalenNormal));
        break;
      case 62: // こんじょう
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
        }
        break;
      case 63: // ふしぎなうろこ
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
        }
        break;
      case 71: // ありじごく
        yourState.ailmentsAdd(
            Ailment(Ailment.cannotRunAway)..extraArg1 = 3, state);
        break;
      case 77: // ちどりあし
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
        }
        break;
      case 79: // とうそうしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.opponentSex1_5));
        break;
      case 85: // たいねつ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heatproof));
        break;
      case 87: // かんそうはだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.drySkin));
        break;
      case 89: // てつのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punch1_2));
        break;
      case 91: // てきおうりょく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.typeBonus2));
        break;
      case 95: // はやあし
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
        }
        break;
      case 96: // ノーマルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalize));
        break;
      case 97: // スナイパー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sniper));
        break;
      case 98: // マジックガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.magicGuard));
        break;
      case 99: // ノーガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noGuard));
        break;
      case 100: // あとだし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.stall));
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.technician));
        break;
      case 103: // ぶきよう
        myState.holdingItem?.clearPassiveEffect(myState, clearForm: false);
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
        if ((isOwn && myState.remainHP == myState.pokemon.h.real) ||
            (!isOwn && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        break;
      case 137: // どくぼうそう
        if (myState.ailmentsIndexWhere(
                (e) => e.id == Ailment.poison || e.id == Ailment.badPoison) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
        }
        break;
      case 138: // ねつぼうそう
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.burn) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        }
        break;
      case 142: // ぼうじん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 147: // ミラクルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourStatusAccuracy50));
        break;
      case 148: // アナライズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.analytic));
        break;
      case 151: // すりぬけ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreWall));
        break;
      case 156: // マジックミラー
        myState.ailmentsAdd(Ailment(Ailment.magicCoat), state);
        break;
      case 158: // いたずらごころ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.prankster));
        break;
      case 159: // すなのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockGroundSteel1_3));
        break;
      case 162: // しょうりのほし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 169: // ファーコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.guard2));
        break;
      case 171: // ぼうだん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bulletProof));
        break;
      case 173: // がんじょうあご
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bite1_5));
        break;
      case 174: // フリーズスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.freezeSkin));
        break;
      case 176: // バトルスイッチ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.shieldForm));
        break;
      case 177: // はやてのつばさ
        if ((isOwn && myState.remainHP == myState.pokemon.h.real) ||
            (!isOwn && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
        break;
      case 178: // メガランチャー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.wave1_5));
        break;
      case 181: // かたいツメ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttack1_3));
        break;
      case 182: // フェアリースキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairySkin));
        break;
      case 184: // スカイスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airSkin));
        break;
      case 196: // ひとでなし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.merciless));
        break;
      case 198: // はりこみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.change2));
        break;
      case 199: // すいほう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble1));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble2));
        break;
      case 200: // はがねつかい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelWorker));
        break;
      case 204: // うるおいボイス
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.liquidVoice));
        break;
      case 205: // ヒーリングシフト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.healingShift));
        break;
      case 206: // エレキスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricSkin));
        break;
      case 208: // ぎょぐん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.singleForm));
        break;
      case 209: // ばけのかわ
        if (!myState.buffDebuffs.containsByAnyID(
            [BuffDebuff.transedForm, BuffDebuff.revealedForm])) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transedForm));
        }
        break;
      case 217: // バッテリー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        break;
      case 218: // もふもふ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackedDamage0_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttackedDamage2));
        break;
      case 233: // ブレインフォース
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_25));
        break;
      case 239: // スクリューおびれ
      case 242: // すじがねいり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.targetRock));
        break;
      case 244: // パンクロック
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sound1_3));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.soundedDamage0_5));
        break;
      case 246: // こおりのりんぷん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDamaged0_5));
        break;
      case 247: // じゅくせい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.nuts2));
        break;
      case 248: // アイスフェイス
        if (!myState.buffDebuffs
            .containsByAnyID([BuffDebuff.iceFace, BuffDebuff.niceFace])) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceFace));
        }
        break;
      case 249: // パワースポット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove1_3));
        break;
      case 252: // はがねのせいしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steel1_5));
        break;
      case 255: // ごりむちゅう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 258: // はらぺこスイッチ
        if (!myState.isTerastaling) {
          if (!myState.buffDebuffs.containsByAnyID(
              [BuffDebuff.harapekoForm, BuffDebuff.manpukuForm])) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.manpukuForm));
          } else {
            myState.buffDebuffs
                .changeID(BuffDebuff.harapekoForm, BuffDebuff.manpukuForm);
          }
        }
        break;
      case 260: // ふかしのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackIgnoreGurad));
        break;
      case 262: // トランジスタ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electric1_3));
        break;
      case 263: // りゅうのあぎと
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragon1_5));
        break;
      case 272: // きよめのしお
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghosted0_5));
        break;
      case 276: // いわはこび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rock1_5));
        break;
      case 278: // マイティチェンジ
        {
          if (!myState.buffDebuffs
              .containsByAnyID([BuffDebuff.naiveForm, BuffDebuff.mightyForm])) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.naiveForm));
          }
        }
        break;
      case 284: // わざわいのうつわ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack0_75));
        break;
      case 285: // わざわいのつるぎ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense0_75));
        break;
      case 286: // わざわいのおふだ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack0_75));
        break;
      case 287: // わざわいのたま
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense0_75));
        break;
      case 292: // きれあじ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.cut1_5));
        break;
      case 298: // きんしのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.myceliumMight));
        break;
    }

    if (id == 186 || yourState.currentAbility.id == 186) {
      // ダークオーラ
      if (id == 188 || yourState.currentAbility.id == 188) {
        // オーラブレイク
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiDarkAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiDarkAura);
      } else {
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.darkAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.darkAura);
      }
    }
    if (id == 187 || yourState.currentAbility.id == 187) {
      // フェアリーオーラ
      if (id == 188 || yourState.currentAbility.id == 188) {
        // オーラブレイク
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiFairyAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiFairyAura);
      } else {
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.fairyAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.fairyAura);
      }
    }
  }

  void clearPassiveEffect(
    PokemonState myState,
    PokemonState yourState,
    bool isOwn,
    PhaseState state,
  ) {
    var yourFields = isOwn
        ? state.getIndiFields(PlayerType.opponent)
        : state.getIndiFields(PlayerType.me);
    switch (id) {
      case 14: // ふくがん
        myState.buffDebuffs.removeAllByID(BuffDebuff.accuracy1_3);
        break;
      case 32: // てんのめぐみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.additionalEffect2);
        break;
      case 37: // ちからもち
      case 74: // ヨガパワー
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack2);
        break;
      case 55: // はりきり
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_5);
        myState.buffDebuffs.removeAllByID(BuffDebuff.physicalAccuracy0_8);
        break;
      case 59: // てんきや
        myState.buffDebuffs.removeAllByID(BuffDebuff.powalenNormal);
        break;
      case 62: // こんじょう
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_5WithIgnBurn);
        break;
      case 63: // ふしぎなうろこ
        myState.buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
        break;
      case 77: // ちどりあし
        myState.buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_5);
        break;
      case 79: // とうそうしん
        myState.buffDebuffs.removeAllByID(BuffDebuff.opponentSex1_5);
        break;
      case 85: // たいねつ
        myState.buffDebuffs.removeAllByID(BuffDebuff.heatproof);
        break;
      case 87: // かんそうはだ
        myState.buffDebuffs.removeAllByID(BuffDebuff.drySkin);
        break;
      case 89: // てつのこぶし
        myState.buffDebuffs.removeAllByID(BuffDebuff.punch1_2);
        break;
      case 91: // てきおうりょく
        myState.buffDebuffs.removeAllByID(BuffDebuff.typeBonus2);
        break;
      case 95: // はやあし
        myState.buffDebuffs.removeAllByID(BuffDebuff.speed1_5IgnPara);
        break;
      case 96: // ノーマルスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.normalize);
        break;
      case 97: // スナイパー
        myState.buffDebuffs.removeAllByID(BuffDebuff.sniper);
        break;
      case 98: // マジックガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.magicGuard);
        break;
      case 99: // ノーガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.noGuard);
        break;
      case 100: // あとだし
        myState.buffDebuffs.removeAllByID(BuffDebuff.stall);
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.removeAllByID(BuffDebuff.technician);
        break;
      case 103: // ぶきよう
        myState.buffDebuffs.removeAllByID(BuffDebuff.noItemEffect);
        myState.holdingItem?.processPassiveEffect(myState, processForm: false);
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        myState.buffDebuffs.removeAllByID(BuffDebuff.noAbilityEffect);
        break;
      case 105: // きょううん
        myState.addVitalRank(-1);
        break;
      case 109: // てんねん
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreRank);
        break;
      case 110: // いろめがね
        myState.buffDebuffs.removeAllByID(BuffDebuff.notGoodType2);
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        myState.buffDebuffs.removeAllByID(BuffDebuff.greatDamaged0_75);
        break;
      case 120: // すてみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.recoil1_2);
        break;
      case 122: // フラワーギフト
        myState.buffDebuffs.removeAllByID(BuffDebuff.negaForm);
        break;
      case 125: // ちからずく
        myState.buffDebuffs.removeAllByID(BuffDebuff.sheerForce);
        break;
      case 127: // きんちょうかん
        yourFields.removeWhere((e) => e.id == IndividualField.noBerry);
        break;
      case 134: // ヘヴィメタル
        myState.buffDebuffs.removeAllByID(BuffDebuff.heavy2);
        break;
      case 135: // ライトメタル
        myState.buffDebuffs.removeAllByID(BuffDebuff.heavy0_5);
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.damaged0_5);
        break;
      case 137: // どくぼうそう
        myState.buffDebuffs.removeAllByID(BuffDebuff.physical1_5);
        break;
      case 138: // ねつぼうそう
        myState.buffDebuffs.removeAllByID(BuffDebuff.special1_5);
        break;
      case 142: // ぼうじん
        myState.buffDebuffs.removeAllByID(BuffDebuff.overcoat);
        break;
      case 147: // ミラクルスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.yourStatusAccuracy50);
        break;
      case 148: // アナライズ
        myState.buffDebuffs.removeAllByID(BuffDebuff.analytic);
        break;
      case 151: // すりぬけ
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreWall);
        break;
      case 156: // マジックミラー
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.magicCoat);
        break;
      case 158: // いたずらごころ
        myState.buffDebuffs.removeAllByID(BuffDebuff.prankster);
        break;
      case 159: // すなのちから
        myState.buffDebuffs.removeAllByID(BuffDebuff.rockGroundSteel1_3);
        break;
      case 162: // しょうりのほし
        myState.buffDebuffs.removeAllByID(BuffDebuff.accuracy1_1);
        break;
      case 169: // ファーコート
        myState.buffDebuffs.removeAllByID(BuffDebuff.guard2);
        break;
      case 171: // ぼうだん
        myState.buffDebuffs.removeAllByID(BuffDebuff.bulletProof);
        break;
      case 173: // がんじょうあご
        myState.buffDebuffs.removeAllByID(BuffDebuff.bite1_5);
        break;
      case 174: // フリーズスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.freezeSkin);
        break;
      case 176: // バトルスイッチ
        myState.buffDebuffs.removeAllByID(BuffDebuff.shieldForm);
        break;
      case 177: // はやてのつばさ
        myState.buffDebuffs.removeAllByID(BuffDebuff.galeWings);
        break;
      case 178: // メガランチャー
        myState.buffDebuffs.removeAllByID(BuffDebuff.wave1_5);
        break;
      case 181: // かたいツメ
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttack1_3);
        break;
      case 182: // フェアリースキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.fairySkin);
        break;
      case 184: // スカイスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.airSkin);
        break;
      case 196: // ひとでなし
        myState.buffDebuffs.removeAllByID(BuffDebuff.merciless);
        break;
      case 198: // はりこみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.change2);
        break;
      case 199: // すいほう
        myState.buffDebuffs.removeAllByID(BuffDebuff.waterBubble1);
        myState.buffDebuffs.removeAllByID(BuffDebuff.waterBubble2);
        break;
      case 200: // はがねつかい
        myState.buffDebuffs.removeAllByID(BuffDebuff.steelWorker);
        break;
      case 204: // うるおいボイス
        myState.buffDebuffs.removeAllByID(BuffDebuff.liquidVoice);
        break;
      case 205: // ヒーリングシフト
        myState.buffDebuffs.removeAllByID(BuffDebuff.healingShift);
        break;
      case 206: // エレキスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.electricSkin);
        break;
      case 208: // ぎょぐん
        myState.buffDebuffs.removeAllByID(BuffDebuff.singleForm);
        break;
      case 209: // ばけのかわ
        myState.buffDebuffs.removeAllByAllID(
            [BuffDebuff.transedForm, BuffDebuff.revealedForm]);
        break;
      case 217: // バッテリー
        myState.buffDebuffs.removeAllByID(BuffDebuff.special1_5);
        break;
      case 218: // もふもふ
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttackedDamage0_5);
        myState.buffDebuffs.removeAllByID(BuffDebuff.fireAttackedDamage2);
        break;
      case 233: // ブレインフォース
        myState.buffDebuffs.removeAllByID(BuffDebuff.greatDamage1_25);
        break;
      case 239: // スクリューおびれ
      case 242: // すじがねいり
        myState.buffDebuffs.removeAllByID(BuffDebuff.targetRock);
        break;
      case 244: // パンクロック
        myState.buffDebuffs.removeAllByID(BuffDebuff.sound1_3);
        myState.buffDebuffs.removeAllByID(BuffDebuff.soundedDamage0_5);
        break;
      case 246: // こおりのりんぷん
        myState.buffDebuffs.removeAllByID(BuffDebuff.specialDamaged0_5);
        break;
      case 247: // じゅくせい
        myState.buffDebuffs.removeAllByID(BuffDebuff.nuts2);
        break;
      case 248: // アイスフェイス
        myState.buffDebuffs
            .removeAllByAllID([BuffDebuff.iceFace, BuffDebuff.niceFace]);
        break;
      case 249: // パワースポット
        myState.buffDebuffs.removeAllByID(BuffDebuff.attackMove1_3);
        break;
      case 252: // はがねのせいしん
        myState.buffDebuffs.removeAllByID(BuffDebuff.steel1_5);
        break;
      case 255: // ごりむちゅう
        myState.buffDebuffs.removeFirstByID(BuffDebuff.gorimuchu);
        break;
      case 258: // はらぺこスイッチ
        myState.buffDebuffs.removeAllByAllID(
            [BuffDebuff.harapekoForm, BuffDebuff.manpukuForm]);
        break;
      case 260: // ふかしのこぶし
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttackIgnoreGurad);
        break;
      case 262: // トランジスタ
        myState.buffDebuffs.removeAllByID(BuffDebuff.electric1_3);
        break;
      case 263: // りゅうのあぎと
        myState.buffDebuffs.removeAllByID(BuffDebuff.dragon1_5);
        break;
      case 272: // きよめのしお
        myState.buffDebuffs.removeAllByID(BuffDebuff.ghosted0_5);
        break;
      case 276: // いわはこび
        myState.buffDebuffs.removeAllByID(BuffDebuff.rock1_5);
        break;
      case 278: // マイティチェンジ
        myState.buffDebuffs
            .removeAllByAllID([BuffDebuff.naiveForm, BuffDebuff.mightyForm]);
        break;
      case 284: // わざわいのうつわ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.specialAttack0_75);
        break;
      case 285: // わざわいのつるぎ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.defense0_75);
        break;
      case 286: // わざわいのおふだ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.attack0_75);
        break;
      case 287: // わざわいのたま
        yourState.buffDebuffs.removeAllByID(BuffDebuff.specialDefense0_75);
        break;
      case 292: // きれあじ
        myState.buffDebuffs.removeAllByID(BuffDebuff.cut1_5);
        break;
      case 298: // きんしのちから
        myState.buffDebuffs.removeAllByID(BuffDebuff.myceliumMight);
        break;
    }

    if (id == 186 && yourState.currentAbility.id != 186) {
      // ダークオーラ
      myState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiDarkAura, BuffDebuff.darkAura]);
      yourState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiDarkAura, BuffDebuff.darkAura]);
    }
    if (id == 187 && yourState.currentAbility.id != 187) {
      // フェアリーオーラ
      myState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiFairyAura, BuffDebuff.fairyAura]);
      yourState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiFairyAura, BuffDebuff.fairyAura]);
    }
    if (id == 188) {
      // オーラブレイク
      myState.buffDebuffs.removeAllByAllID(
          [BuffDebuff.antiFairyAura, BuffDebuff.antiDarkAura]);
      yourState.buffDebuffs.removeAllByAllID(
          [BuffDebuff.antiFairyAura, BuffDebuff.antiDarkAura]);
      if (yourState.currentAbility.id == 186) {
        // ダークオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
      if (yourState.currentAbility.id == 187) {
        // フェアリーオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  // TurnEffectのarg1が決定できる場合はその値を返す
  static int getAutoArg1(
    int abilityID,
    PlayerType player,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffect? prevAction,
    Timing timing,
  ) {
    bool isMe = player == PlayerType.me;

    switch (abilityID) {
      case 10: // ちくでん
      case 11: // ちょすい
        return isMe ? -((myState.pokemon.h.real / 4).floor()) : -25;
      case 87: // かんそうはだ
        if (prevAction?.move!
                .getReplacedMove(prevAction.move!.move, 0, myState)
                .type ==
            PokeType.water) {
          // みずタイプのわざを受けた時
          return isMe ? -((myState.pokemon.h.real / 4).floor()) : -25;
        } else if (state.weather.id == Weather.sunny) {
          // 晴れの時
          isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        } else if (state.weather.id == Weather.rainy) {
          // 雨の時
          isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
        }
        break;
      case 16: // へんしょく
        return prevAction!.move!.move.type.index;
      case 24: // さめはだ
      case 160: // てつのトゲ
        return !isMe ? (yourState.pokemon.h.real / 8).floor() : 12;
      case 106: // ゆうばく
        return !isMe ? (yourState.pokemon.h.real / 4).floor() : 25;
      case 209: // ばけのかわ
      case 94: // サンパワー
        return isMe ? (myState.pokemon.h.real / 8).floor() : 12;
      case 168: // へんげんじざい
      case 236: // リベロ
        // TODO?
        break;
      case 44: // あめうけざら
      case 115: // アイスボディ
        return isMe ? -((myState.pokemon.h.real / 16).floor()) : -6;
      case 90: // ポイズンヒール
        return isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
      case 281: // こだいかっせい
      case 282: // ブーストエナジー
        if (timing == Timing.everyTurnEnd) {
          return -1;
        } else {
          bool isClear = true;
          int ret = 0;
          int maxReal = 0;
          for (final stat in StatIndexList.listAtoS) {
            if (myState.minStats[stat].real != myState.maxStats[stat].real) {
              isClear = false;
              break;
            }
            if (myState.getRankedStat(myState.minStats[stat].real, stat) >
                maxReal) {
              maxReal =
                  myState.getRankedStat(myState.minStats[stat].real, stat);
              ret = stat.index - 1;
            }
          }
          if (isClear) {
            return ret;
          }
        }
        break;
      case 36: // トレース
        return yourState.getCurrentAbility().id;
      case 139: // しゅうかく
        final lastLostBerry =
            myState.hiddenBuffs.whereByID(BuffDebuff.lastLostBerry);
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
    int abilityID,
    PlayerType player,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffect? prevAction,
    Timing timing,
  ) {
    return 0;
  }

  // SQLに保存された文字列からabilityをパース
  static Ability deserialize(dynamic str, String split1) {
    final List elements = str.split(split1);
    return Ability(
        int.parse(elements.removeAt(0)),
        elements.removeAt(0),
        elements.removeAt(0),
        Timing.values[int.parse(elements.removeAt(0))],
        Target.values[int.parse(elements.removeAt(0))]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$_displayName$split1$_displayNameEn$split1${timing.index}$split1${target.index}$split1';
  }
}
