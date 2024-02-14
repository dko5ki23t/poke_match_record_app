import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';

class TurnEffectAfterMove extends TurnEffect {
  TurnEffectAfterMove({required player, required this.effectID})
      : super(EffectType.afterMove) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  int effectID;
  int extraArg1 = 0;

  @override
  List<Object?> get props => [
        _playerType,
        effectID,
        extraArg1,
      ];

  @override
  TurnEffectAfterMove copy() =>
      TurnEffectAfterMove(player: playerType, effectID: effectID);

  @override
  String displayName({required AppLocalizations loc}) =>
      PokeDB().moves[effectID]!.displayName;

  @override
  PlayerType get playerType => _playerType;
  @override
  set playerType(type) => _playerType = type;

  @override
  Timing get timing => Timing.afterMove;
  @override
  set timing(Timing t) {}

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

    super.beforeProcessEffect(ownState, opponentState);

    switch (effectID) {
      case 194: // みちづれ
        myState.remainHP = 0;
        myState.remainHPPercent = 0;
        myState.isFainting = true;
        break;
      case 588: // キングシールド
        myState.addStatChanges(false, 0, -1, yourState,
            myFields: myFields, yourFields: yourFields, moveId: effectID);
        break;
      case 596: // ニードルガード
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case 661: // トーチカ
        myState.ailmentsAdd(Ailment(Ailment.poison), state);
        break;
      case 792: // ブロッキング
        myState.addStatChanges(false, 1, -2, yourState,
            myFields: myFields, yourFields: yourFields, moveId: effectID);
        break;
      case 852: // スレッドトラップ
        myState.addStatChanges(false, 4, -1, yourState,
            myFields: myFields, yourFields: yourFields, moveId: effectID);
        break;
      case 508: // かえんのまもり
        myState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none && timing != Timing.none && effectID != 0;

  /// 引数を自動で設定(TurnEffectAfterMoveでは何も処理しない)
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
  ) {}

  /// extraArg等以外同じ、ほぼ同じかどうか
  @override
  bool nearEqual(TurnEffect t) {
    return t.runtimeType == TurnEffectAfterMove &&
        playerType == t.playerType &&
        timing == t.timing &&
        effectID == (t as TurnEffectAfterMove).effectID;
  }

  // SQLに保存された文字列からTurnEffectAfterMoveをパース
  static TurnEffectAfterMove deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // playerType
    final playerType = PlayerTypeNum.createFromNumber(
        int.parse(turnEffectElements.removeAt(0)));
    // effectID
    final effectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectAfterMove turnEffect =
        TurnEffectAfterMove(player: playerType, effectID: effectID);
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
    // effectID
    ret += effectID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();

    return ret;
  }
}
