import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/weather.dart';

class TurnEffectAbility extends TurnEffect {
  TurnEffectAbility(
      {required player, required this.timing, required this.abilityID})
      : super(EffectType.ability) {
    playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  Timing timing = Timing.none;
  int abilityID = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        playerType,
        timing,
        abilityID,
        extraArg1,
        extraArg2,
      ];

  @override
  TurnEffectAbility copy() => TurnEffectAbility(
      player: playerType, timing: timing, abilityID: abilityID)
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2;

  @override
  String displayName({required AppLocalizations loc}) =>
      PokeDB().abilities[abilityID]!.displayName;

  @override
  PlayerType get playerType => _playerType;

  @override
  set playerType(type) => _playerType = type;

  /*static List<Guide> processEffect(
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
  })*/
  @override
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownState,
    Party opponentParty,
    PokemonState opponentState,
    PhaseState state,
    TurnEffect? prevAction,
    int continuousCount, {
    int? changePokemonIndex,
    required AppLocalizations loc,
  }) {
    final pokeData = PokeDB();
    List<Guide> ret = [];
    final myPlayer = playerType;
    final yourPlayer = playerType.opposite;
    final myFields = state.getIndiFields(playerType);
    final yourFields = state.getIndiFields(playerType.opposite);
    final isMe = playerType == PlayerType.me;
    final myState = isMe ? ownState : opponentState;
    final yourState = isMe ? opponentState : ownState;

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
              pokeData.abilities[extraArg1]!, yourState, isMe, state);
          if (playerType == PlayerType.me &&
              yourState.getCurrentAbility().id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confAbility
              ..args = [extraArg1]
              ..guideStr = loc.battleGuideConfAbility(
                  pokeData.abilities[extraArg1]!.displayName,
                  yourState.pokemon.omittedName));
            yourState.setCurrentAbility(
                yourState.pokemon.ability, myState, !isMe, state);
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
          var tmp = opponentState.moves
              .where((element) => element.id != 0 && element.id == extraArg1);
          if (extraArg1 != 165 && // わるあがきは除外
              myPlayer == PlayerType.me &&
              opponentState.moves.length < 4 &&
              tmp.isEmpty) {
            ret.add(Guide()
              ..guideId = Guide.confMove
              ..canDelete = false
              ..guideStr = loc.battleGuideConfMove(
                  pokeData.moves[extraArg1]!.displayName,
                  opponentState.pokemon.omittedName));
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
              opponentState.getHoldingItem()?.id == 0) {
            ret.add(Guide()
              ..guideId = Guide.confItem
              ..args = [extraArg1]
              ..guideStr = loc.battleGuideConfItem2(
                  pokeData.items[extraArg1]!.displayName,
                  opponentState.pokemon.omittedName));
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
              pokeData.abilities[149]!, yourState, isMe, state);
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
              yourState.currentAbility, yourState, isMe, state);
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
            myState.currentAbility, myState, !isMe, state);
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
              myState.maxStats[stat]
                  .updateReal(myState.pokemon.level, myState.pokemon.temper);
              myState.minStats[stat]
                  .updateReal(myState.pokemon.level, myState.pokemon.temper);
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
                myState.maxStats[stat]
                    .updateReal(myState.pokemon.level, myState.pokemon.temper);
                myState.minStats[stat]
                    .updateReal(myState.pokemon.level, myState.pokemon.temper);
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
              myState.currentAbility, myState, !isMe, state);
          myState.setCurrentAbility(tmp, yourState, isMe, state);
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
                    opponentState.pokemon.omittedName));
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
                    opponentState.pokemon.omittedName));
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
        final itemEffecct = TurnEffectItem(
            player: playerType, timing: timing, itemID: extraArg1);
        ret.addAll(itemEffecct.processEffect(ownParty, ownState, opponentParty,
            opponentState, state, prevAction, continuousCount,
            loc: loc));
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
          myState.maxStats[stat]
              .updateReal(myState.pokemon.level, myState.pokemon.temper);
          myState.minStats[stat]
              .updateReal(myState.pokemon.level, myState.pokemon.temper);
        }
        if (playerType == PlayerType.me) {
          myState.remainHP += (5 * 2 * myState.pokemon.level / 100).floor();
        }
        myState.setCurrentAbility(
            pokeData.abilities[305]!, yourState, isMe, state); // とくせいをテラスシェルに変更
        break;
      case 306: // ゼロフォーミング
        state.weather = Weather(0);
        state.field = Field(0);
        break;
      case 10000 + BuffDebuff.unomiForm: // うのミサイル(うのみのすがた)
        if (isMe) {
          yourState.remainHPPercent -= 25;
        } else {
          yourState.remainHP -= (yourState.pokemon.h.real / 4).floor();
        }
        yourState.addStatChanges(false, 1, -1, myState);
        myState.buffDebuffs.removeAllByID(BuffDebuff.unomiForm);
        break;
      case 10000 + BuffDebuff.marunomiForm: // うのミサイル(うのみのすがた)
        if (isMe) {
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
            opponentState.pokemon.omittedName));
      myState.setCurrentAbility(
          myState.pokemon.ability, yourState, isMe, state); // とくせい確定
    }

    return ret;
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none && timing != Timing.none && abilityID != 0;

  void setAutoArgs(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffectAction? prevAction,
  ) {
    extraArg1 = 0;
    extraArg2 = 0;
    bool isMe = playerType == PlayerType.me;

    switch (abilityID) {
      case 10: // ちくでん
      case 11: // ちょすい
        extraArg1 = isMe ? -((myState.pokemon.h.real / 4).floor()) : -25;
        return;
      case 87: // かんそうはだ
        if (prevAction!.getReplacedMove(prevAction.move, 0, myState).type ==
            PokeType.water) {
          // みずタイプのわざを受けた時
          extraArg1 = isMe ? -((myState.pokemon.h.real / 4).floor()) : -25;
        } else if (state.weather.id == Weather.sunny) {
          // 晴れの時
          extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        } else if (state.weather.id == Weather.rainy) {
          // 雨の時
          extraArg1 = isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
        }
        return;
      case 16: // へんしょく
        extraArg1 = prevAction!.move.type.index;
        return;
      case 24: // さめはだ
      case 160: // てつのトゲ
        extraArg1 = !isMe ? (yourState.pokemon.h.real / 8).floor() : 12;
        return;
      case 106: // ゆうばく
        extraArg1 = !isMe ? (yourState.pokemon.h.real / 4).floor() : 25;
        return;
      case 209: // ばけのかわ
      case 94: // サンパワー
        extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        return;
      case 168: // へんげんじざい
      case 236: // リベロ
        // TODO?
        return;
      case 44: // あめうけざら
      case 115: // アイスボディ
        extraArg1 = isMe ? -((myState.pokemon.h.real / 16).floor()) : -6;
        return;
      case 90: // ポイズンヒール
        extraArg1 = isMe ? -((myState.pokemon.h.real / 8).floor()) : -12;
        return;
      case 281: // こだいかっせい
      case 282: // ブーストエナジー
        if (timing == Timing.everyTurnEnd) {
          extraArg1 = -1;
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
            extraArg1 = ret;
          }
        }
        return;
      case 36: // トレース
        extraArg1 = yourState.getCurrentAbility().id;
        return;
      case 139: // しゅうかく
        final lastLostBerry =
            myState.hiddenBuffs.whereByID(BuffDebuff.lastLostBerry);
        if (lastLostBerry.isNotEmpty) {
          extraArg1 = lastLostBerry.first.extraArg1;
        }
        return;
      default:
        return;
    }
  }

  // SQLに保存された文字列からTurnEffectAbilityをパース
  static TurnEffectAbility deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // playerType
    final playerType = PlayerTypeNum.createFromNumber(
        int.parse(turnEffectElements.removeAt(0)));
    // timing
    final timing = Timing.values[int.parse(turnEffectElements.removeAt(0))];
    // abilityID
    final abilityID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectAbility turnEffect = TurnEffectAbility(
        player: playerType, timing: timing, abilityID: abilityID);
    // extraArg1
    turnEffect.extraArg1 = int.parse(turnEffectElements.removeAt(0));
    // extraArg2
    turnEffect.extraArg2 = int.parse(turnEffectElements.removeAt(0));

    return turnEffect;
  }

  // SQL保存用の文字列に変換
  @override
  String serialize(
    String split1,
    String split2,
    String split3,
  ) {
    String ret = '';
    // effectType
    ret += effectType.index.toString();
    ret += split1;
    // playerType
    ret += playerType.number.toString();
    ret += split1;
    // timing
    ret += timing.index.toString();
    ret += split1;
    // abilityID
    ret += abilityID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }
}
