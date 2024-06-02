import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_dropdown_button_form_field.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/tool.dart';

/// ターン内効果のうち、「とくせい」によるものについて管理するclass
class TurnEffectAbility extends TurnEffect {
  TurnEffectAbility(
      {required player, required this.timing, required this.abilityID})
      : super(EffectType.ability) {
    playerType = player;
  }

  @override
  PlayerType playerType = PlayerType.none;
  @override
  Timing timing = Timing.none;

  /// とくせいID
  int abilityID = 0;

  /// 引数1
  int extraArg1 = 0;

  /// 引数2
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        ...super.props,
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
    ..extraArg2 = extraArg2
    ..baseCopyWith(this);

  @override
  String displayName({required AppLocalizations loc}) =>
      PokeDB().abilities[abilityID]!.displayName;

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getChangePokemonIndex(PlayerType player) {
    return null;
  }

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を設定する
  /// nullを設定すると交換していないことを表す
  /// ```
  /// player: 行動主
  /// prev: 交換前ポケモンのパーティ内インデックス(1始まり)
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  @override
  void setChangePokemonIndex(PlayerType player, int? prev, int? val) {}

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getPrevPokemonIndex(PlayerType player) {
    return null;
  }

  /// とくせいの効果を処理し、表示ガイドのリストを返す
  /// ```
  /// ownParty: 自身(ユーザー)のパーティ
  /// ownState: 自身(ユーザー)のポケモンの状態
  /// opponentParty: 相手のパーティ
  /// opponentState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// prevAction: この行動の直前に起きた行動(わざ使用後の処理等に用いる)
  /// ```
  @override
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownState,
    Party opponentParty,
    PokemonState opponentState,
    PhaseState state,
    TurnEffectAction? prevAction, {
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

    super.beforeProcessEffect(ownState, opponentState);

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
          if (myState.buffDebuffs.containsByID(8)) {
            myState.buffDebuffs
                .add(pokeData.buffDebuffs[BuffDebuff.flashFired]!.copy());
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
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.attackSpeed0_5]!.copy());
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
          newState.hiddenBuffs
              .add(pokeData.buffDebuffs[BuffDebuff.zoroappear]!.copy());
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
          myState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.transform]!.copy()
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
        myState.hiddenBuffs
            .add(pokeData.buffDebuffs[BuffDebuff.protean]!.copy());
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
      case 197: // リミットシールド
        myState.buffDebuffs
            .switchID(BuffDebuff.meteorForm, BuffDebuff.coloredCore);
        break;
      case 208: // ぎょぐん(現状SVでは登場していないため未実装)
        myState.buffDebuffs
            .switchID(BuffDebuff.singleForm, BuffDebuff.multipleForm);
        break;
      case 209: // ばけのかわ
        {
          myState.buffDebuffs.removeAllByID(BuffDebuff.transedForm);
          myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.revealedForm);
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
            int findIdx = myState.buffDebuffs
                .changeID(BuffDebuff.iceFace, BuffDebuff.niceFace);
            myState.buffDebuffs.list[findIdx].changeForm(myState);
          } else {
            if (myState.buffDebuffs.containsByID(BuffDebuff.niceFace)) {
              int findIdx = myState.buffDebuffs
                  .changeID(BuffDebuff.niceFace, BuffDebuff.iceFace);
              myState.buffDebuffs.list[findIdx].changeForm(myState);
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
              pokeData.buffDebuffs[BuffDebuff.attack1_3 + extraArg1]!.copy()
                ..extraArg1 = arg);
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
              pokeData.buffDebuffs[BuffDebuff.attack1_3 + extraArg1]!.copy()
                ..extraArg1 = arg);
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
        ret.addAll(itemEffecct.processEffect(
            ownParty, ownState, opponentParty, opponentState, state, prevAction,
            loc: loc));
        break;
      case 293: // そうだいしょう
        {
          int faintingNum = state.getFaintingCount(playerType);
          if (faintingNum > 0) {
            myState.buffDebuffs.add(pokeData
                .buffDebuffs[BuffDebuff.power10 + faintingNum - 1]!
                .copy());
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
        myState.buffDebuffs.list
            .firstWhere((element) => element.id == BuffDebuff.terastalForm)
            .changeForm(myState);
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

    super.afterProcessEffect(ownState, opponentState, state);

    return ret;
  }

  /// 効果のextraArg等を編集するWidgetを返す
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 対戦相手のパーティ
  /// state: フェーズの状態
  /// controller: テキスト入力コントローラ
  /// onEdit: 編集したときに呼び出すコールバック
  /// (ダイアログで、効果が有効かどうかでOKボタンの有効無効を切り替えるために使う)
  /// ```
  @override
  Widget editArgWidget(
    PokemonState myState,
    PokemonState yourState,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    TextEditingController controller,
    TextEditingController controller2, {
    required void Function() onEdit,
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    final dropdownMenuKey = Key('AbilityEffectDropDownMenu');
    final pokeData = PokeDB();
    switch (abilityID) {
      case 10: // ちくでん
      case 11: // ちょすい
      case 44: // あめうけざら
      case 87: // かんそうはだ
      case 90: // ポイズンヒール
      case 94: // サンパワー
      case 115: // アイスボディ
      case 209: // ばけのかわ
      case 211: // スワームチェンジ
      case 297: // どしょく
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
          }
          return DamageIndicateRow(
            myState.pokemon,
            controller,
            playerType == PlayerType.me,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - value;
              } else {
                extraArg1 = myState.remainHPPercent - value;
              }
              onEdit();
              return extraArg1;
            },
            extraArg1,
            true,
            loc: loc,
          );
        }
      case 16: // へんしょく
      case 168: // へんげんじざい
      case 236: // リベロ
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TypeDropdownButton(
                loc.battleTypeToChange,
                (value) {
                  extraArg1 = value.index;
                  onEdit();
                  // 統合テスト作成用
                  print(
                      "await driver.tap(find.byValueKey('TypeDropdownButton'));\n"
                      "await driver.tap(find.text('${value.displayName}'));");
                },
                extraArg1 == 0 ? null : PokeType.values[extraArg1],
              ),
            ),
          ],
        );
      case 24: // さめはだ
      case 106: // ゆうばく
      case 123: // ナイトメア
      case 160: // てつのトゲ
      case 215: // とびだすなかみ
        {
          if (playerType == PlayerType.me) {
            controller.text =
                (yourState.remainHPPercent - extraArg1).toString();
          } else {
            controller.text = (yourState.remainHP - extraArg1).toString();
          }
          return DamageIndicateRow(
            yourState.pokemon,
            controller,
            playerType != PlayerType.me,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = yourState.remainHPPercent - value;
              } else {
                extraArg1 = yourState.remainHP - value;
              }
              onEdit();
              return extraArg1;
            },
            extraArg1,
            true,
            loc: loc,
          );
        }
      case 27: // ほうし
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                decoration: InputDecoration(
                  label: Text(loc.battleOpponentAilments),
                ),
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: Ailment.poison,
                    child: Text(Ailment(Ailment.poison).displayName),
                  ),
                  ColoredPopupMenuItem(
                    value: Ailment.paralysis,
                    child: Text(Ailment(Ailment.paralysis).displayName),
                  ),
                  ColoredPopupMenuItem(
                    value: Ailment.sleep,
                    child: Text(Ailment(Ailment.sleep).displayName),
                  ),
                ],
                value: extraArg1 == 0 ? null : extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onEdit();
                },
                isInput: true,
                textValue: Ailment(extraArg1).displayName,
              ),
            ),
          ],
        );
      case 36: // トレース
        {
          if (playerType == PlayerType.me) {
            if (yourState.getCurrentAbility().id != 0) {
              extraArg1 = yourState.getCurrentAbility().id;
              controller.text = yourState.getCurrentAbility().displayName;
            } else {
              controller.text = '';
            }
          } else {
            extraArg1 = yourState.getCurrentAbility().id;
            controller.text = yourState.getCurrentAbility().displayName;
          }
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleAbilityTraced,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType == PlayerType.me) {
                      if (yourState.getCurrentAbility().id != 0) {
                        matches.add(yourState.getCurrentAbility());
                      } else {
                        matches.addAll(yourState.possibleAbilities);
                      }
                      if (state.canAnyZoroark) {
                        matches.add(PokeDB().abilities[149]!);
                      }
                    } else {
                      matches.add(yourState.getCurrentAbility());
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    onEdit();
                  },
                  isInput: true,
                ),
              ),
            ],
          );
        }
      case 53: // ものひろい
      case 139: // しゅうかく
        {
          controller.text = pokeData.items[extraArg1]!.displayName;
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = PokeDB().items.values.toList();
                    matches.removeWhere((e) => e.id == 0);
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    onEdit();
                  },
                  isInput: true,
                ),
              ),
            ],
          );
        }
      case 88: // ダウンロード
        return Row(
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: 0,
                    child: Text(loc.commonAttack),
                  ),
                  ColoredPopupMenuItem(
                    value: 2,
                    child: Text(loc.commonSAttack),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onEdit();
                },
                isInput: true,
                textValue:
                    extraArg1 == 0 ? loc.commonAttack : loc.commonSAttack,
              ),
            ),
            Text(loc.battleRankUp1),
          ],
        );
      case 108: // よちむ
      case 130: // のろわれボディ
        {
          controller.text = pokeData.moves[extraArg1]!.displayName;
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  key: Key('EffectMoveField'),
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType == PlayerType.me) {
                      matches.addAll(yourState.moves);
                    } else {
                      matches.add(yourState.pokemon.move1);
                      if (yourState.pokemon.move2 != null) {
                        matches.add(yourState.pokemon.move2!);
                      }
                      if (yourState.pokemon.move3 != null) {
                        matches.add(yourState.pokemon.move3!);
                      }
                      if (yourState.pokemon.move4 != null) {
                        matches.add(yourState.pokemon.move4!);
                      }
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    onEdit();
                    // 統合テスト作成用
                    print(
                        "await driver.tap(find.byValueKey('EffectMoveField'));\n"
                        "await driver.enterText('${suggestion.displayName}');\n"
                        "await driver.tap(\n"
                        "find.ancestor(of: find.text('${suggestion.displayName}'), matching: find.byType('ListTile')));");
                  },
                  isInput: true,
                ),
              ),
            ],
          );
        }
      case 119: // おみとおし
      case 124: // わるいてぐせ
      case 170: // マジシャン
        {
          controller.text = pokeData.items[extraArg1]!.displayName;
          return Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.me) {
                      if (yourState.holdingItem != null &&
                          yourState.holdingItem!.id != 0) {
                        matches.add(yourState.holdingItem!);
                      } else {
                        matches = PokeDB().items.values.toList();
                        for (var item in yourState.impossibleItems) {
                          matches
                              .removeWhere((element) => element.id == item.id);
                        }
                      }
                    } else if (yourState.holdingItem != null) {
                      matches = [yourState.holdingItem!];
                    }
                    matches.retainWhere((s) {
                      return toKatakana50(s.displayName.toLowerCase())
                          .contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller.text = suggestion.displayName;
                    extraArg1 = suggestion.id;
                    onEdit();
                  },
                  isInput: true,
                ),
              ),
            ],
          );
        }
      case 141: // ムラっけ
        return Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: _myDropdownButtonFormField(
                    items: <ColoredPopupMenuItem>[
                      for (final statIndex in StatIndexList.listAtoS)
                        ColoredPopupMenuItem(
                          value: statIndex.index - 1,
                          child: Text(statIndex.name),
                        ),
                    ],
                    value: extraArg1,
                    onChanged: (value) {
                      extraArg1 = value;
                      onEdit();
                    },
                    isInput: true,
                    textValue: StatIndex.values[extraArg1 + 1].name,
                  ),
                ),
                Text(loc.battleRankUp2),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Flexible(
                  child: _myDropdownButtonFormField(
                    items: <ColoredPopupMenuItem>[
                      for (final statIndex in StatIndexList.listAtoS)
                        ColoredPopupMenuItem(
                          value: statIndex.index - 1,
                          child: Text(statIndex.name),
                        ),
                    ],
                    value: extraArg2,
                    onChanged: (value) {
                      extraArg2 = value;
                      onEdit();
                    },
                    isInput: true,
                    textValue: StatIndex.values[extraArg2 + 1].name,
                  ),
                ),
                Text(loc.battleRankDown1),
              ],
            ),
          ],
        );
      case 149: // イリュージョン
        if (playerType == PlayerType.opponent) {
          final zoruaNos = [
            PokeBase.zoruaNo,
            PokeBase.zoroarkNo,
            PokeBase.zoruaHisuiNo,
            PokeBase.zoroarkHisuiNo
          ];
          return Row(
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
                  key: Key('PokemonSelectDropdown'),
                  decoration: InputDecoration(
                    labelText: loc.battleIllusionedPokemon,
                  ),
                  items: <ColoredPopupMenuItem>[
                    for (int i = 0; i < opponentParty.pokemonNum; i++)
                      ColoredPopupMenuItem(
                        value: i + 1,
                        enabled: zoruaNos.contains(
                            state.getPokemonStates(playerType)[i].pokemon.no),
                        child: Text(
                          opponentParty.pokemons[i]!.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: zoruaNos.contains(state
                                      .getPokemonStates(playerType)[i]
                                      .pokemon
                                      .no)
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                  ],
                  value: extraArg1 <= 0 ? null : extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    onEdit();
                    // 統合テスト作成用
                    print(
                        "await driver.tap(find.byValueKey('PokemonSelectDropdown'));\n"
                        "await driver.tap(find.text('${state.getPokemonStates(playerType)[value - 1].pokemon.name}'));");
                  },
                  isInput: true,
                  textValue: extraArg1 > 0
                      ? opponentParty.pokemons[extraArg1 - 1]?.name
                      : '',
                ),
              ),
            ],
          );
        }
        break;
      case 281: // こだいかっせい
      case 282: // クォークチャージ
      case 224: // ビーストブースト
        return Row(
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                key: dropdownMenuKey,
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: -1,
                    child: Text(loc.battleEffectExpired),
                  ),
                  for (final statIndex in StatIndexList.listAtoS)
                    ColoredPopupMenuItem(
                      value: statIndex.index - 1,
                      child: Text(statIndex.name),
                    ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onEdit();
                  // 統合テスト作成用
                  final text = value == -1
                      ? loc.battleEffectExpired
                      : (StatIndex.values[value + 1].name +
                          loc.battleStatIncrease);
                  final text2 = value == -1
                      ? loc.battleEffectExpired
                      : StatIndex.values[value + 1].name;
                  print("// $text\n"
                      "await driver.tap(find.byValueKey('AbilityEffectDropDownMenu'));\n"
                      "await driver.tap(find.text('$text2'));");
                },
                isInput: true,
                textValue: extraArg1 == -1
                    ? loc.battleEffectExpired
                    : StatIndex.values[extraArg1 + 1].name,
              ),
            ),
            extraArg1 >= 0 ? Text(loc.battleStatIncrease) : Text(''),
          ],
        );
      case 290: // びんじょう
        return Row(
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                items: <ColoredPopupMenuItem>[
                  for (final statIndex in StatIndexList.listAtoS)
                    ColoredPopupMenuItem(
                      value: statIndex.index - 1,
                      child: Text(statIndex.name),
                    ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  onEdit();
                  extraArg1 = value;
                },
                isInput: true,
                textValue: StatIndex.values[extraArg1 + 1].name,
              ),
            ),
            Text(loc.battleOpportunist1),
            Flexible(
              child: _myDropdownButtonFormField(
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: 1,
                    child: Text('1'),
                  ),
                  ColoredPopupMenuItem(
                    value: 2,
                    child: Text('2'),
                  ),
                  ColoredPopupMenuItem(
                    value: 3,
                    child: Text('3'),
                  ),
                  ColoredPopupMenuItem(
                    value: 4,
                    child: Text('4'),
                  ),
                  ColoredPopupMenuItem(
                    value: 5,
                    child: Text('5'),
                  ),
                  ColoredPopupMenuItem(
                    value: 6,
                    child: Text('6'),
                  ),
                ],
                value: extraArg2 == 0 ? null : extraArg2,
                onChanged: (value) {
                  extraArg2 = value;
                  onEdit();
                },
                isInput: true,
                textValue: extraArg2.toString(),
              ),
            ),
            Text(loc.battleOpportunist2),
          ],
        );
      case 216: // おどりこ
        {
          controller.text = pokeData.moves[extraArg1 % 10000]!.displayName;
          if (playerType == PlayerType.me) {
            if (extraArg1 == 775) {
              controller2.text = (myState.remainHP - extraArg2).toString();
            } else {
              controller2.text =
                  (yourState.remainHPPercent - extraArg2).toString();
            }
          } else {
            if (extraArg1 == 775) {
              controller2.text =
                  (myState.remainHPPercent - extraArg2).toString();
            } else {
              controller2.text = (yourState.remainHP - extraArg2).toString();
            }
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _myTypeAheadField(
                key: Key('DanceTypeAheadField'),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.commonMove,
                  ),
                ),
                autoFlipDirection: true,
                suggestionsCallback: (pattern) async {
                  List<int> ids = [
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
                  List<Move> matches = [];
                  for (var i in ids) {
                    matches.add(PokeDB().moves[i]!);
                  }
                  matches.retainWhere((s) {
                    return toKatakana50(s.displayName.toLowerCase())
                        .contains(toKatakana50(pattern.toLowerCase()));
                  });
                  return matches;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(
                      suggestion.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  controller.text = suggestion.displayName;
                  extraArg1 = suggestion.id;
                  onEdit();
                  // 統合テスト作成用
                  print(
                      "await driver.tap(find.byValueKey('DanceTypeAheadField'));\n"
                      "await driver.enterText('${suggestion.displayName}');"
                      "await driver.tap(find.descendant(\n"
                      "    of: find.byType('ListTile'), matching: find.text('${suggestion.displayName}')));");
                },
                isInput: true,
              ),
              SizedBox(
                height: 10,
              ),
              extraArg1 == 872 ||
                      extraArg1 == 80 ||
                      extraArg1 == 552 ||
                      extraArg1 == 10552 ||
                      extraArg1 == 686
                  ? DamageIndicateRow(
                      yourState.pokemon,
                      controller2,
                      playerType != PlayerType.me,
                      (value) {
                        if (playerType == PlayerType.me) {
                          extraArg2 = yourState.remainHPPercent - value;
                        } else {
                          extraArg2 = yourState.remainHP - value;
                        }
                        onEdit();
                        return extraArg2;
                      },
                      extraArg2,
                      true,
                      loc: loc,
                    )
                  : extraArg1 == 775
                      ? DamageIndicateRow(
                          myState.pokemon,
                          controller2,
                          playerType == PlayerType.me,
                          (value) {
                            if (playerType == PlayerType.me) {
                              extraArg2 = myState.remainHP - value;
                            } else {
                              extraArg2 = myState.remainHPPercent - value;
                            }
                            onEdit();
                            return extraArg2;
                          },
                          extraArg2,
                          true,
                          loc: loc,
                        )
                      : Container(),
              extraArg1 == 552 || extraArg1 == 10552
                  ? SizedBox(
                      height: 10,
                    )
                  : Container(),
              extraArg1 == 552 || extraArg1 == 10552
                  ? _myDropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: loc.battleAdditionalEffect,
                      ),
                      items: <ColoredPopupMenuItem>[
                        ColoredPopupMenuItem(
                          value: 552,
                          child: Text(loc.commonNone),
                        ),
                        ColoredPopupMenuItem(
                          value: 10552,
                          child: Text(loc
                              .battleSAttackUp1(myState.pokemon.omittedName)),
                        ),
                      ],
                      value: extraArg1,
                      onChanged: (value) {
                        extraArg1 = value;
                        onEdit();
                      },
                      isInput: true,
                      textValue: extraArg1 == 552
                          ? loc.commonNone
                          : loc.battleSAttackUp1(myState.pokemon.omittedName),
                    )
                  : Container(),
            ],
          );
        }
      default:
        break;
    }
    return Container();
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none && timing != Timing.none && abilityID != 0;

  /// 現在のポケモンの状態等から決定できる引数を自動で設定
  /// ```
  /// myState: 効果発動主のポケモンの状態
  /// yourState: 効果発動主の相手のポケモンの状態
  /// state: フェーズの状態
  /// prevAction: 直前の行動
  /// ```
  @override
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
      case 297: // どしょく
        extraArg1 = isMe ? -((myState.pokemon.h.real / 4).floor()) : -25;
        return;
      case 87: // かんそうはだ
        if (prevAction!.getReplacedMove(prevAction.move, myState).type ==
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
        // getDefaultEffectList()にてセットされる
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

  /// extraArg等以外同じ、ほぼ同じかどうか
  /// ```
  /// allowTimingDiff: タイミングが異なっていても同じとみなすかどうか
  /// ```
  @override
  bool nearEqual(
    TurnEffect t, {
    bool allowTimingDiff = false,
    bool isChangeMe = false,
    bool isChangeOpponent = false,
  }) {
    return t.runtimeType == TurnEffectAbility &&
        playerType == t.playerType &&
        (timing == t.timing ||
            (allowTimingDiff &&
                !(isChangeMe &&
                    playerType == PlayerType.me &&
                    (timing == Timing.afterMove ||
                        t.timing == Timing.afterMove)) &&
                !(isChangeOpponent &&
                    playerType == PlayerType.opponent &&
                    (timing == Timing.afterMove ||
                        t.timing == Timing.afterMove)))) &&
        abilityID == (t as TurnEffectAbility).abilityID;
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
    required List<ColoredPopupMenuItem<T>> items,
    T? value,
    required ValueChanged<T?>? onChanged,
    double elevation = 8,
    Widget? icon,
    double iconSize = 24.0,
    InputDecoration? decoration,
    bool? enableFeedback,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    required bool isInput,
    required String? textValue,
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    ThemeData? theme,
  }) {
    if (isInput) {
      return AppBaseDropdownButtonFormField(
        key: key,
        items: items,
        value: value,
        onChanged: onChanged,
        elevation: elevation,
        icon: icon,
        iconSize: iconSize,
        decoration: decoration,
        enableFeedback: enableFeedback,
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

  Widget _myTypeAheadField<T>({
    required SuggestionsCallback<T> suggestionsCallback,
    required ItemBuilder<T> itemBuilder,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    TextFieldConfiguration textFieldConfiguration =
        const TextFieldConfiguration(),
    SuggestionsBoxDecoration suggestionsBoxDecoration =
        const SuggestionsBoxDecoration(),
    Duration debounceDuration = const Duration(milliseconds: 300),
    SuggestionsBoxController? suggestionsBoxController,
    ScrollController? scrollController,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? noItemsFoundBuilder,
    ErrorBuilder? errorBuilder,
    AnimationTransitionBuilder? transitionBuilder,
    double animationStart = 0.25,
    Duration animationDuration = const Duration(milliseconds: 500),
    bool getImmediateSuggestions = false,
    double suggestionsBoxVerticalOffset = 5.0,
    AxisDirection direction = AxisDirection.down,
    bool hideOnLoading = false,
    bool hideOnEmpty = false,
    bool hideOnError = false,
    bool hideSuggestionsOnKeyboardHide = true,
    bool keepSuggestionsOnLoading = true,
    bool keepSuggestionsOnSuggestionSelected = false,
    bool autoFlipDirection = false,
    bool autoFlipListDirection = true,
    bool hideKeyboard = false,
    int minCharsForSuggestions = 0,
    void Function(bool)? onSuggestionsBoxToggle,
    bool hideKeyboardOnDrag = false,
    Key? key,
    required bool isInput,
  }) {
    if (isInput) {
      return AppBaseTypeAheadField(
        suggestionsCallback: suggestionsCallback,
        itemBuilder: itemBuilder,
        onSuggestionSelected: onSuggestionSelected,
        textFieldConfiguration: textFieldConfiguration,
        suggestionsBoxDecoration: suggestionsBoxDecoration,
        debounceDuration: debounceDuration,
        suggestionsBoxController: suggestionsBoxController,
        scrollController: scrollController,
        loadingBuilder: loadingBuilder,
        noItemsFoundBuilder: noItemsFoundBuilder,
        errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder,
        animationStart: animationStart,
        animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions,
        suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction,
        hideOnLoading: hideOnLoading,
        hideOnEmpty: hideOnEmpty,
        hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
        keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected:
            keepSuggestionsOnSuggestionSelected,
        autoFlipDirection: autoFlipDirection,
        autoFlipListDirection: autoFlipListDirection,
        hideKeyboard: hideKeyboard,
        minCharsForSuggestions: minCharsForSuggestions,
        onSuggestionsBoxToggle: onSuggestionsBoxToggle,
        hideKeyboardOnDrag: hideKeyboardOnDrag,
        key: key,
      );
    } else {
      return TextField(
        controller: textFieldConfiguration.controller,
        decoration: textFieldConfiguration.decoration,
        readOnly: true,
      );
    }
  }

  /// SQLに保存された文字列からTurnEffectAbilityをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1~split3: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
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

  /// SQL保存用の文字列に変換
  /// ```
  /// split1~split3: 区切り文字
  /// ```
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
