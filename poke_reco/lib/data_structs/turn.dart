import 'dart:collection';

import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_terastal.dart';
import 'package:poke_reco/tool.dart';

/// 自身・相手の行動(timing==Timing.action)1つずつを含むTurnEffectのリスト
class PhaseList extends ListBase<TurnEffect> implements Copyable, Equatable {
  // https://stackoverflow.com/questions/16247045/how-do-i-extend-a-list-in-dart
  final List<TurnEffect> l = [];

  @override
  List<Object?> get props => [l];

  /// 自身・相手の行動(timing==Timing.action)1つずつをTurnEffectの含むリスト
  PhaseList() {
    l.addAll([
      TurnEffectAction(
        player: PlayerType.me,
      )..type = TurnActionType.move,
      TurnEffectAction(
        player: PlayerType.opponent,
      )..type = TurnActionType.move,
    ]);
  }

  @override
  set length(int newLength) {
    l.length = newLength;
  }

  @override
  int get length => l.length;
  @override
  TurnEffect operator [](int index) => l[index];
  @override
  void operator []=(int index, TurnEffect value) {
    l[index] = value;
  }

  @override
  PhaseList copy() => PhaseList()..l.addAll(l);

  /// 追加(許容を超えた行動の追加は例外発生)
  /// ```
  /// element: 追加要素
  /// ```
  void checkAdd(TurnEffect element) {
    if (element is TurnEffectAction ||
        element is TurnEffectChangeFaintingPokemon) {
      assert(
        element.playerType == PlayerType.me ||
            element.playerType == PlayerType.opponent,
        'action effect\'s player must be me or opponent',
      );
      // 自身・相手の行動は1つずつまで
      assert(
        l
            .where((e) =>
                (e.runtimeType == element.runtimeType) &&
                e.playerType == element.playerType)
            .isEmpty,
        'only 1 action effect for each player is allowed in 1 turn',
      );
    }
  }

  @override
  void add(TurnEffect element) {
    checkAdd(element);
    l.add(element);
  }

  @override
  void insert(int index, TurnEffect element) {
    checkAdd(element);
    l.insert(index, element);
  }

  /// 最後の有効なTurnEffectの次に追加する
  /// ```
  /// element: 追加要素
  /// ```
  void addNextToLastValid(TurnEffect element) {
    checkAdd(element);
    int insertIdx = l.lastIndexWhere((element) => element.isValid()) + 1;
    l.insert(insertIdx, element);
  }

  /// 対象行動主の行動が存在するかどうか
  /// ```
  /// playerType: 行動主
  /// ```
  bool isExistAction(PlayerType playerType) => l
      .where((e) =>
          (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
          e.playerType == playerType)
      .isNotEmpty;

  /// 対象行動主の最後の行動を返す
  /// ```
  /// playerType: 行動主
  /// ```
  TurnEffect getLatestAction(PlayerType playerType) => l
      .where((e) =>
          (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
          e.playerType == playerType)
      .last;

  /// 対象行動主の最後の行動のインデックスを返す
  /// ```
  /// playerType: 行動主
  /// ```
  int getLatestActionIndex(PlayerType playerType) => l.lastIndexWhere((e) =>
      (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
      e.playerType == playerType);

  /// 最後に有効な行動をした行動主
  PlayerType? get firstActionPlayer {
    int ownPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == PlayerType.me);
    int opponentPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == PlayerType.opponent);
    //どちらも(存在しない/無効)
    if ((ownPlayerActionIndex < 0 || !l[ownPlayerActionIndex].isValid()) &&
        (opponentPlayerActionIndex < 0 ||
            !l[opponentPlayerActionIndex].isValid())) return null;
    // 片方の行動のみ(存在かつ有効)
    if (ownPlayerActionIndex >= 0 &&
        l[ownPlayerActionIndex].isValid() &&
        (opponentPlayerActionIndex < 0 ||
            !l[opponentPlayerActionIndex].isValid())) return PlayerType.me;
    if (opponentPlayerActionIndex >= 0 &&
        l[opponentPlayerActionIndex].isValid() &&
        (ownPlayerActionIndex < 0 || !l[ownPlayerActionIndex].isValid())) {
      return PlayerType.opponent;
    }
    // 両行動ともに(存在かつ有効)
    if (ownPlayerActionIndex > opponentPlayerActionIndex) {
      return PlayerType.me;
    } else {
      return PlayerType.opponent;
    }
  }

  /// 各プレイヤーのTurnEffectActionのisFirstを更新する
  void updateActionOrder() {
    // 有効なactionで先に行動しているプレイヤーを探す
    final ownPlayerActions =
        l.where((e) => e is TurnEffectAction && e.playerType == PlayerType.me);
    final opponentPlayerActions = l.where(
        (e) => e is TurnEffectAction && e.playerType == PlayerType.opponent);
    //どちらも(存在しない/無効)
    if ((ownPlayerActions.isEmpty || !ownPlayerActions.first.isValid()) &&
        (opponentPlayerActions.isEmpty ||
            !opponentPlayerActions.first.isValid())) {
      if (ownPlayerActions.isNotEmpty) {
        (ownPlayerActions.first as TurnEffectAction).isFirst = null;
      }
      if (opponentPlayerActions.isNotEmpty) {
        (opponentPlayerActions.first as TurnEffectAction).isFirst = null;
      }
      return;
    }
    // 片方の行動のみ(存在かつ有効)
    if (ownPlayerActions.isNotEmpty &&
        ownPlayerActions.first.isValid() &&
        (opponentPlayerActions.isEmpty ||
            !opponentPlayerActions.first.isValid())) {
      (ownPlayerActions.first as TurnEffectAction).isFirst = true;
      (opponentPlayerActions.first as TurnEffectAction).isFirst = false;
      setActionOrderFirst(PlayerType.me);
      return;
    }
    if (opponentPlayerActions.isNotEmpty &&
        opponentPlayerActions.first.isValid() &&
        (ownPlayerActions.isEmpty || !ownPlayerActions.first.isValid())) {
      (ownPlayerActions.first as TurnEffectAction).isFirst = false;
      (opponentPlayerActions.first as TurnEffectAction).isFirst = true;
      setActionOrderFirst(PlayerType.opponent);
      return;
    }
    // 両行動ともに(存在かつ有効)
    if (l.indexOf(ownPlayerActions.first) >
        l.indexOf(opponentPlayerActions.first)) {
      (ownPlayerActions.first as TurnEffectAction).isFirst = false;
      (opponentPlayerActions.first as TurnEffectAction).isFirst = true;
    } else {
      (ownPlayerActions.first as TurnEffectAction).isFirst = true;
      (opponentPlayerActions.first as TurnEffectAction).isFirst = false;
    }
  }

  /// 指定したプレイヤーの行動順を先にする
  /// ```
  /// playerType: プレイヤー
  /// ```
  void setActionOrderFirst(PlayerType playerType) {
    // 行動がない
    assert(
      isExistAction(PlayerType.me) && isExistAction(PlayerType.opponent),
      'there are no own action or opponent action',
    );
    int myPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == playerType);
    int yourPlayerActionIndex = l.indexWhere((e) =>
        (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
        e.playerType == playerType.opposite);
    // 対象の行動が後にあるなら
    if (myPlayerActionIndex > yourPlayerActionIndex) {
      // TODO:今後もっと複雑になる
      final removed = l.removeAt(yourPlayerActionIndex);
      l.add(removed);
    }
  }

  /// 対象プレイヤーのテラスタルのON/OFF切り替え
  /// ```
  /// playerType: プレイヤー
  /// type: テラスタイプ
  /// ```
  void turnOnOffTerastal(PlayerType playerType, PokeType type) {
    final terastal = l.where((element) =>
        element is TurnEffectTerastal && element.playerType == playerType);
    if (terastal.isEmpty) {
      int insertIndex =
          l.lastIndexWhere((element) => element is TurnEffectTerastal);
      if (insertIndex < 0) {
        insertIndex = 0;
      } else {
        insertIndex++;
      }
      l.insert(
          insertIndex, TurnEffectTerastal(player: playerType, teraType: type));
    } else {
      l.remove(terastal.first);
    }
  }
}

/// 個々のターンを管理するclass
class Turn extends Equatable implements Copyable {
  /// ターン開始時の状態
  PhaseState _initialState = PhaseState();

  /// フェーズ
  PhaseList phases = PhaseList();

  /// ターン終了時の状態(updateEndingState()で更新する必要あり)
  PhaseState _endingState = PhaseState();

  /// 自動追加オフの効果リスト
  List<TurnEffect> noAutoAddEffect = [];

  @override
  List<Object?> get props => [
        _initialState,
        phases,
        _endingState,
        noAutoAddEffect,
      ];

  /// ターン開始時の自身(ユーザー)のポケモンの状態
  PokemonState get initialOwnPokemonState =>
      _initialState.getPokemonState(PlayerType.me, null);

  /// ターン開始時の相手のポケモンの状態
  PokemonState get initialOpponentPokemonState =>
      _initialState.getPokemonState(PlayerType.opponent, null);

  /// ターン開始時の自身(ユーザー)の場
  List<IndividualField> get initialOwnIndiField =>
      _initialState.getIndiFields(PlayerType.me);

  /// ターン終了時の相手の場
  List<IndividualField> get initialOpponentIndiField =>
      _initialState.getIndiFields(PlayerType.opponent);

  /// ターン開始時に自身(ユーザー)がテラスタルしているかどうか
  bool get initialOwnHasTerastal => _initialState.hasOwnTerastal;

  /// ターン開始時に相手がテラスタルしているかどうか
  bool get initialOpponentHasTerastal => _initialState.hasOpponentTerastal;

  /// ターン開始時ポケモンのパーティ内インデックスを返す
  /// ```
  /// player: 対象のプレイヤー
  /// ```
  int getInitialPokemonIndex(PlayerType player) {
    return _initialState.getPokemonIndex(player, null);
  }

  /// ターン開始時ポケモンのパーティ内インデックスを設定する
  /// ```
  /// player: 対象のプレイヤー
  /// index: ポケモンのパーティ内インデックス
  /// ```
  void setInitialPokemonIndex(PlayerType player, int index) {
    _initialState.setPokemonIndex(player, index);
  }

  /// ターン開始時パーティ内ポケモンの状態リストを返す
  /// ```
  /// player: 対象のプレイヤー
  /// ```
  List<PokemonState> getInitialPokemonStates(PlayerType player) {
    return _initialState.getPokemonStates(player);
  }

  /// ターン開始時点での、パーティ内各ポケモンの最後に退出したときの状態リストを返す
  /// ```
  /// player: 対象のプレイヤー
  /// ```
  List<PokemonState> getInitialLastExitedStates(PlayerType player) {
    return player == PlayerType.me
        ? _initialState.lastExitedStates[0]
        : _initialState.lastExitedStates[1];
  }

  @override
  Turn copy() => Turn()
    .._initialState = _initialState.copy()
    ..phases = phases.copy()
    .._endingState = _endingState.copy()
    ..noAutoAddEffect = [for (final effect in noAutoAddEffect) effect.copy()];

  /// ターン開始時の状態のコピーを返す
  PhaseState copyInitialState() {
    return _initialState.copy();
  }

  /// 有効かどうか
  bool isValid() {
    int actionCount = 0;
    int validCount = 0;
    for (final phase in phases) {
      if (phase is TurnEffectAction ||
          phase is TurnEffectChangeFaintingPokemon) {
        actionCount++;
        if (phase.isValid()) validCount++;
      }
    }
    return actionCount == validCount && actionCount >= 2;
  }

  /// ターン終了時、自身(ユーザー)が勝利しているかどうか
  bool get isMyWin => _endingState.isMyWin;

  /// ターン終了時、対戦相手が勝利しているかどうか
  bool get isYourWin => _endingState.isYourWin;

  /// ターン終了時、対戦が終了しているかどうか
  bool get isGameSet => isMyWin || isYourWin;

  /// ターン開始時の状態を設定する
  /// ```
  /// state: フェーズの状態
  /// ```
  void setInitialState(PhaseState state) {
    _initialState = state.copy();
  }

  /// とある時点(フェーズ)での状態を返す
  /// ```
  /// phaseIdx: フェーズのインデックス
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 相手のパーティ
  /// ```
  PhaseState getProcessedStates(
    int phaseIdx,
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    PhaseState ret = copyInitialState();
    int continousCount = 0;
    TurnEffect? lastAction;

    for (int i = 0; i < phaseIdx + 1; i++) {
      final effect = phases[i];
      //if (effect.isAdding) continue;
      //if (effect.timing == Timing.continuousMove) {
      //  lastAction = effect;
      //  continousCount++;
      //} else if (effect.timing == Timing.action) {
      //  lastAction = effect;
      //  continousCount = 0;
      //}
      if (effect is TurnEffectAction) lastAction = effect;
      effect.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me,
            /*effect.timing == Timing.afterMove ? lastAction :*/ null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent,
            /*effect.timing == Timing.afterMove ? lastAction :*/ null),
        ret,
        lastAction,
        continousCount,
        loc: loc,
      );
    }
    return ret;
  }

  /// 対象プレイヤーの行動直前のフェーズの状態を返す。
  /// phasesに入っている各処理のうち有効な値が入っているphaseのみ処理を適用する。
  /// ```
  /// playerType: プレイヤー
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 相手のパーティ
  /// ```
  PhaseState getBeforeActionState(
    PlayerType playerType,
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    PhaseState ret = _initialState.copy();
    int continousCount = 0;
    TurnEffect? lastAction;
    int endIndex = phases.getLatestActionIndex(playerType);

    for (int i = 0; i < endIndex; i++) {
      final phase = phases[i];
//      if (phase.isAdding) {
//        i++;
//        continue; // TODO
//      }
      if (!phase.isValid()) {
        continue;
      }
      //if (phase.timing == Timing.continuousMove) {
      //  lastAction = phase;
      //  continousCount++;
      //} else if (phase.timing == Timing.action) {
      //  lastAction = phase;
      //  continousCount = 0;
      //}
      if (phase is TurnEffectAction) lastAction = phase;
      phase.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        ret,
        lastAction,
        continousCount,
        loc: loc,
      );
    }
    return ret;
  }

  /// ターンの最終状態(_endingState)を更新する。
  /// phasesに入っている各処理のうち有効な値が入っているphaseのみ処理を適用する。
  /// また、_endingStateのコピーを返す。
  /// ```
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 相手のパーティ
  /// ```
  PhaseState updateEndingState(
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    _endingState = _initialState.copy();
    int continousCount = 0;
    TurnEffect? lastAction;
    PlayerType? needChangeFaintingPlayer;
    Map<PlayerType, bool> alreadyActioned = {
      PlayerType.me: false,
      PlayerType.opponent: false,
    };

    int i = 0;
    while (i < phases.length) {
      final phase = phases[i];
//      if (phase.isAdding) {
//        i++;
//        continue; // TODO
//      }
      if (!phase.isValid()) {
        i++;
        continue;
      }
      //if (phase.timing == Timing.continuousMove) {
      //  lastAction = phase;
      //  continousCount++;
      //} else if (phase.timing == Timing.action) {
      //  lastAction = phase;
      //  continousCount = 0;
      //}
      if (phase is TurnEffectAction) lastAction = phase;
      phase.processEffect(
        ownParty,
        _endingState.getPokemonState(PlayerType.me,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        opponentParty,
        _endingState.getPokemonState(PlayerType.opponent,
            /*phase.timing == Timing.afterMove ? lastAction :*/ null),
        _endingState,
        lastAction,
        continousCount,
        loc: loc,
      );
      if (phase is TurnEffectAction) {
        alreadyActioned[phase.playerType] = true;
      }
      // ポケモンがひんしになっている場合、無ければひんし交代phaseを追加
      final ownState = _endingState.getPokemonState(PlayerType.me, null);
      final opponentState =
          _endingState.getPokemonState(PlayerType.opponent, null);
      if (ownState.remainHP <= 0) {
        ownState.remainHP = 0;
        ownState.isFainting = true;
        _endingState.incFaintingCount(PlayerType.me, 1);
        needChangeFaintingPlayer = PlayerType.me;
      } else {
        ownState.isFainting = false;
      }
      if (opponentState.remainHPPercent <= 0) {
        opponentState.remainHPPercent = 0;
        opponentState.isFainting = true;
        _endingState.incFaintingCount(PlayerType.opponent, 1);
        needChangeFaintingPlayer = PlayerType.opponent;
      } else {
        opponentState.isFainting = false;
      }
      if (needChangeFaintingPlayer != null) {
        if (phase is! TurnEffectChangeFaintingPokemon) {
          // ひんし対象がまだ行動していないとき
          if (!alreadyActioned[needChangeFaintingPlayer]!) {
            final target =
                phases.getLatestActionIndex(needChangeFaintingPlayer);
            if (phases[target] is! TurnEffectChangeFaintingPokemon) {
              phases[target] = TurnEffectChangeFaintingPokemon(
                  player: needChangeFaintingPlayer, timing: Timing.afterMove);
            }
          }
          // ひんし対象が行動済みのとき
          else {
            if (i == phases.length - 1 ||
                phases[i + 1] is! TurnEffectChangeFaintingPokemon) {
              phases.insert(
                  i + 1,
                  // TODO
                  TurnEffectChangeFaintingPokemon(
                      player: needChangeFaintingPlayer,
                      timing: Timing.afterMove));
            }
          }
          needChangeFaintingPlayer = null;
        }
      }
      i++;
    }
    return _endingState.copy();
  }

  /// 初期状態のみ残してクリア
  void clearExceptInitialState() {
    phases = PhaseList();
    _endingState = PhaseState();
    noAutoAddEffect = [];
  }

  /// SQLに保存された文字列からTurnをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1 ~ split7: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
  static Turn deserialize(dynamic str, String split1, String split2,
      String split3, String split4, String split5, String split6, String split7,
      {int version = -1}) {
    Turn ret = Turn();
    final List turnElements = str.split(split1);
    // _initialState
    ret._initialState = PhaseState.deserialize(turnElements.removeAt(0), split2,
        split3, split4, split5, split6, split7);
    // phases
    ret.phases.clear();
    var turnEffects = turnElements.removeAt(0).split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5,
          version: version));
    }
    // _endingState
    ret._endingState = PhaseState.deserialize(turnElements.removeAt(0), split2,
        split3, split4, split5, split6, split7);
    // noAutoAddEffect
    var effects = turnElements.removeAt(0).split(split2);
    ret.noAutoAddEffect.clear();
    for (final effect in effects) {
      if (effect == '') break;
      ret.noAutoAddEffect.add(TurnEffect.deserialize(
          effect, split3, split4, split5,
          version: version));
    }

    return ret;
  }

  /// SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3, String split4,
      String split5, String split6, String split7) {
    String ret = '';
    // _initialState
    ret +=
        _initialState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // phases
    for (final turnEffect in phases) {
      ret += turnEffect.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // _endingState
    ret +=
        _endingState.serialize(split2, split3, split4, split5, split6, split7);
    ret += split1;
    // noAutoAddEffect
    for (final effect in noAutoAddEffect) {
      ret += effect.serialize(split3, split4, split5);
      ret += split2;
    }

    return ret;
  }
}
