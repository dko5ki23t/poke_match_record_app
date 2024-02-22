import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:tuple/tuple.dart';

// 各々の場による効果(TurnEffectのeffectIdに使用する定数を提供)
class IndiFieldEffect {
  static const int none = 0;
  static const int toxicSpikes = 1; // どくびし
  static const int spikes1 = 2; // まきびし(重ね掛けなし)
  static const int stealthRock = 3; // ステルスロック
  static const int stickyWeb = 4; // ねばねばネット
  static const int healingWish = 5; // いやしのねがい
  static const int lunarDance = 6; // みかづきのまい
  static const int badToxicSpikes = 7; // どくどくびし
  static const int futureAttack = 8; // みらいにこうげき
  static const int wish = 10; // ねがいごと
  static const int reflectorEnd = 12; // リフレクター終了
  static const int lightScreenEnd = 13; // ひかりのかべ終了
  static const int safeGuardEnd = 14; // しんぴのまもり終了
  static const int mistEnd = 15; // しろいきり
  static const int tailwindEnd = 16; // おいかぜ終了
  //static const int luckyChant = 17;       // おまじない
  static const int auroraVeilEnd = 18; // オーロラベール終了
  static const int gravityEnd = 19; // じゅうりょく終了
  static const int trickRoomEnd = 20; // トリックルーム終了
  static const int waterSportEnd = 21; // みずあそび終了
  static const int mudSportEnd = 22; // どろあそび終了
  static const int wonderRoomEnd = 23; // ワンダールーム
  static const int magicRoomEnd = 24; // マジックルーム
  static const int ionDeluge = 25; // プラズマシャワー(わざタイプ：ノーマル→でんき)
  static const int fairyLockEnd = 26; // フェアリーロック終了
  static const int spikes2 = 27; // まきびし(重ね掛け2回)
  static const int spikes3 = 28; // まきびし(重ね掛け3回)

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('どくをあびた', 'Poisoned'),
    2: Tuple2('まきびし', 'Spikes'),
    3: Tuple2('ステルスロック', 'Stealth Rock'),
    4: Tuple2('ねばねばネット', 'Sticky Web'),
    5: Tuple2('いやしのねがい', 'Healing Wish'),
    6: Tuple2('みかづきのまい', 'Lunar Dance'),
    7: Tuple2('もうどくをあびた', 'Badly poisoned'),
    8: Tuple2('みらいにこうげき', 'Future Sight'),
    10: Tuple2('ねがいごと', 'Wish'),
    12: Tuple2('リフレクターがなくなった', 'Reflector is gone'),
    13: Tuple2('ひかりのかべがなくなった', 'Light Screen is gone'),
    14: Tuple2('しんぴのまもり終了', 'Safe Guard ends'),
    15: Tuple2('しろいきりが消えた', 'Mist is gone'),
    16: Tuple2('おいかぜがやんだ', 'Tailwind is gone'),
    18: Tuple2('オーロラベールがなくなった', 'Aurora Veil is gone'),
    19: Tuple2('じゅうりょく終了', 'Gravity ends'),
    20: Tuple2('トリックルーム終了', 'Trick Room ends'), // ゆがんだ時空がもとにもどった
    21: Tuple2('みずあそび終了', 'Water Sport ends'),
    22: Tuple2('どろあそび終了', 'Mud Sport ends'),
    23: Tuple2('ワンダールーム終了', 'Wonder Room ends'),
    24: Tuple2('マジックルーム終了', 'Magic Room ends'),
    26: Tuple2('フェアリーロック終了', 'Fairy Lock ends'),
    27: Tuple2('まきびし', 'Spikes'),
    28: Tuple2('まきびし', 'Spikes'),
  };

  const IndiFieldEffect(this.id);

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  static int getIdFromIndiField(IndividualField field) {
    switch (field.id) {
      case IndividualField.toxicSpikes:
        if (field.extraArg1 >= 2) {
          return badToxicSpikes;
        }
        break;
      case IndividualField.spikes:
        if (field.extraArg1 >= 3) {
          return spikes3;
        }
        if (field.extraArg1 >= 2) {
          return spikes2;
        }
        break;
      default:
        break;
    }
    return field.id;
  }

  // ただ場を終了させるだけの処理を行う
  static void processRemove(
    int effectId,
    List<IndividualField> myFields,
    List<IndividualField> yourFields,
  ) {
    switch (effectId) {
      case IndiFieldEffect.reflectorEnd: // リフレクター終了
      case IndiFieldEffect.lightScreenEnd: // ひかりのかべ終了
      case IndiFieldEffect.safeGuardEnd: // しんぴのまもり終了
      case IndiFieldEffect.mistEnd: // しろいきり終了
      case IndiFieldEffect.tailwindEnd: // おいかぜ終了
      case IndiFieldEffect.auroraVeilEnd: // オーロラベール終了
      case IndiFieldEffect.gravityEnd: // じゅうりょく終了
        myFields.removeWhere((e) => e.id == effectId);
        break;
      case IndiFieldEffect.trickRoomEnd: // トリックルーム終了
      case IndiFieldEffect.waterSportEnd: // みずあそび終了
      case IndiFieldEffect.mudSportEnd: // どろあそび終了
      case IndiFieldEffect.wonderRoomEnd: // ワンダールーム終了
      case IndiFieldEffect.magicRoomEnd: // マジックルーム終了
      case IndiFieldEffect.fairyLockEnd: // フェアリーロック終了
        myFields.removeWhere((e) => e.id == effectId);
        yourFields.removeWhere((e) => e.id == effectId);
        break;
      default:
        break;
    }
  }

  final int id;
}

class TurnEffectIndividualField extends TurnEffect {
  TurnEffectIndividualField(
      {required player, required this.timing, required this.indiFieldEffectID})
      : super(EffectType.individualField);

  PlayerType _playerType = PlayerType.none;
  @override
  Timing timing = Timing.none;
  int indiFieldEffectID = 0;
  int extraArg1 = 0;

  @override
  List<Object?> get props => [playerType, timing, indiFieldEffectID, extraArg1];

  @override
  TurnEffectIndividualField copy() => TurnEffectIndividualField(
      player: playerType, timing: timing, indiFieldEffectID: indiFieldEffectID)
    ..extraArg1 = extraArg1;

  @override
  String displayName({required AppLocalizations loc}) =>
      IndiFieldEffect(indiFieldEffectID).displayName;

  @override
  PlayerType get playerType => _playerType;

  @override
  set playerType(type) => _playerType = type;

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
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  @override
  void setChangePokemonIndex(PlayerType player, int? val) {}

  /// 効果のextraArg等を編集するWidgetを返す
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 対戦相手のパーティ
  /// state: フェーズの状態
  /// controller: テキスト入力コントローラ
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
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    switch (indiFieldEffectID) {
      case IndiFieldEffect.spikes1: // まきびし
      case IndiFieldEffect.spikes2:
      case IndiFieldEffect.spikes3:
      case IndiFieldEffect.futureAttack: // みらいにこうげき
      case IndiFieldEffect.stealthRock: // ステルスロック
      case IndiFieldEffect.wish: // ねがいごと
        return DamageIndicateRow(
          myState.pokemon,
          controller,
          playerType == PlayerType.me,
          (value) {
            if (playerType == PlayerType.me) {
              extraArg1 = myState.remainHP - (int.tryParse(value) ?? 0);
            } else {
              extraArg1 = myState.remainHPPercent - (int.tryParse(value) ?? 0);
            }
          },
          extraArg1,
          true,
          loc: loc,
        );
    }
    return Container();
  }

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffectAction? prevAction,
      {required AppLocalizations loc}) {
    final myState = timing == Timing.afterMove && prevAction != null
        ? state.getPokemonState(playerType, prevAction)
        : playerType == PlayerType.me
            ? ownState
            : opponentState;
    final yourState = timing == Timing.afterMove && prevAction != null
        ? state.getPokemonState(playerType.opposite, prevAction)
        : playerType == PlayerType.me
            ? opponentState
            : ownState;
    final myFields = state.getIndiFields(playerType);
    final yourFields = state.getIndiFields(playerType.opposite);
    final bool isMe = playerType == PlayerType.me;

    super.beforeProcessEffect(ownState, opponentState);

    switch (indiFieldEffectID) {
      case IndiFieldEffect.toxicSpikes: // どくびし
        myState.ailmentsAdd(Ailment(Ailment.poison), state);
        break;
      case IndiFieldEffect.badToxicSpikes: // どくどくびし
        myState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case IndiFieldEffect.spikes1: // まきびし
      case IndiFieldEffect.spikes2:
      case IndiFieldEffect.spikes3:
      case IndiFieldEffect.futureAttack: // みらいにこうげき
      case IndiFieldEffect.stealthRock: // ステルスロック
      case IndiFieldEffect.wish: // ねがいごと
        if (isMe) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case IndiFieldEffect.healingWish: // いやしのねがい
        if (isMe) {
          myState.remainHP = myState.pokemon.h.real;
        } else {
          myState.remainHPPercent = 100;
        }
        myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
        myFields.removeWhere((e) => e.id == IndividualField.healingWish);
        break;
      case IndiFieldEffect.lunarDance: // みかづきのまい
        if (isMe) {
          myState.remainHP = myState.pokemon.h.real;
        } else {
          myState.remainHPPercent = 100;
        }
        myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
        for (int i = 0; i < myState.usedPPs.length; i++) {
          myState.usedPPs[i] = 0;
        }
        myFields.removeWhere((e) => e.id == IndividualField.lunarDance);
        break;
      case IndiFieldEffect.stickyWeb: // ねばねばネット
        myState.addStatChanges(false, 4, -1, yourState,
            myFields: myFields, yourFields: yourFields);
        break;
      default:
        IndiFieldEffect.processRemove(indiFieldEffectID, myFields, yourFields);
        break;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      indiFieldEffectID != 0;

  /// extraArg等以外同じ、ほぼ同じかどうか
  /// ```
  /// allowTimingDiff: タイミングが異なっていても同じとみなすかどうか
  /// ```
  @override
  bool nearEqual(
    TurnEffect t, {
    bool allowTimingDiff = false,
  }) {
    return t.runtimeType == TurnEffectIndividualField &&
        playerType == t.playerType &&
        (allowTimingDiff || timing == t.timing) &&
        indiFieldEffectID == (t as TurnEffectIndividualField).indiFieldEffectID;
  }

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
    bool isMe = playerType == PlayerType.me;

    switch (indiFieldEffectID) {
      case IndiFieldEffect.spikes1: // まきびし(重ね掛けなし)
        extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        return;
      case IndiFieldEffect.spikes2: // まきびし(2回重ね掛け)
        extraArg1 = isMe ? (myState.pokemon.h.real / 6).floor() : 16;
        return;
      case IndiFieldEffect.spikes3: // まきびし(3回重ね掛け)
        extraArg1 = isMe ? (myState.pokemon.h.real / 4).floor() : 25;
        return;
      case IndiFieldEffect.stealthRock: // ステルスロック
        {
          var rate =
              PokeTypeEffectiveness.effectivenessRate(PokeType.rock, myState) /
                  8;
          extraArg1 = isMe
              ? (myState.pokemon.h.real * rate).floor()
              : (100 * rate).floor();
          return;
        }
      default:
        return;
    }
  }

  // SQLに保存された文字列からTurnEffectIndividualFieldをパース
  static TurnEffectIndividualField deserialize(
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
    // indiFieldEffectID
    final indiFieldEffectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectIndividualField turnEffect = TurnEffectIndividualField(
        player: playerType,
        timing: timing,
        indiFieldEffectID: indiFieldEffectID);
    // extraArg1
    turnEffect.extraArg1 = int.parse(turnEffectElements.removeAt(0));

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
    // indiFieldEffectID
    ret += indiFieldEffectID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();

    return ret;
  }
}
