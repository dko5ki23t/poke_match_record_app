import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';

class TurnEffectChangeFaintingPokemon extends TurnEffect {
  TurnEffectChangeFaintingPokemon({required player})
      : super(EffectType.changeFaintingPokemon) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  @override
  Timing timing = Timing.changeFaintingPokemon;
  int changePokemonIndex = 0; // 0は無効値

  @override
  List<Object?> get props =>
      [...super.props, playerType, timing, changePokemonIndex];

  @override
  TurnEffectChangeFaintingPokemon copy() =>
      TurnEffectChangeFaintingPokemon(player: playerType)
        ..changePokemonIndex = changePokemonIndex
        ..baseCopyWith(this);

  @override
  String displayName({required AppLocalizations loc}) =>
      loc.battleChangeFainting;

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
    if (player == playerType) {
      return changePokemonIndex;
    }
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
  void setChangePokemonIndex(PlayerType player, int? prev, int? val) {
    if (player == playerType) {
      changePokemonIndex = val!;
    }
  }

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getPrevPokemonIndex(PlayerType player) {
    return null;
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

    super.beforeProcessEffect(ownState, opponentState);

    // のうりょく変化リセット、現在のポケモンを表すインデックス更新
    myState.processExitEffect(yourState, state);
    if (changePokemonIndex != 0) {
      state.setPokemonIndex(playerType, changePokemonIndex);
      state
          .getPokemonState(playerType, null)
          .processEnterEffect(yourState, state);
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      changePokemonIndex != 0;

  /// 引数を自動で設定(TurnEffectChangeFaintingPokemonでは何も処理しない)
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
    return t.runtimeType == TurnEffectChangeFaintingPokemon &&
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
        changePokemonIndex ==
            (t as TurnEffectChangeFaintingPokemon).changePokemonIndex;
  }

  // SQLに保存された文字列からTurnEffectChangeFaintingPokemonをパース
  static TurnEffectChangeFaintingPokemon deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // playerType
    final playerType = PlayerTypeNum.createFromNumber(
        int.parse(turnEffectElements.removeAt(0)));
    TurnEffectChangeFaintingPokemon turnEffect =
        TurnEffectChangeFaintingPokemon(player: playerType);
    // changePokemonIndex
    turnEffect.changePokemonIndex = int.parse(turnEffectElements.removeAt(0));

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
    // changePokemonIndex
    ret += changePokemonIndex.toString();

    return ret;
  }
}
