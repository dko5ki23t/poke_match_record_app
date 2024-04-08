import 'dart:collection';

import 'package:poke_reco/custom_widgets/battle_pokemon_state_info.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_change_fainting_pokemon.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_gameset.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_terastal.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_user_edit.dart';
import 'package:poke_reco/pages/register_battle.dart';
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
  /// onlyValids: 有効なフェーズに限定して探すか
  /// ```
  int getLatestActionIndex(
    PlayerType playerType, {
    bool onlyValids = false,
  }) {
    if (onlyValids) {
      return l
          .where(
            (element) => element.isValid(),
          )
          .toList()
          .lastIndexWhere((e) =>
              (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
              e.playerType == playerType);
    } else {
      return l.lastIndexWhere((e) =>
          (e is TurnEffectAction || e is TurnEffectChangeFaintingPokemon) &&
          e.playerType == playerType);
    }
  }

  /// 指定したインデックスの効果タイミングがわざ使用後の場合、
  /// その直前の行動を返す。
  /// そうでない場合はnullを返す
  /// ```
  /// phaseIdx: 対象効果のインデックス
  /// ```
  TurnEffectAction? getPrevAction(int phaseIdx) {
    if (l[phaseIdx].timing == Timing.afterMove) {
      for (int i = phaseIdx - 1; i >= 0; i--) {
        if (l[i] is TurnEffectAction) return l[i] as TurnEffectAction;
      }
    }
    return null;
  }

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
      if (opponentPlayerActions.isNotEmpty) {
        (opponentPlayerActions.first as TurnEffectAction).isFirst = false;
      }
      setActionOrderFirst(PlayerType.me);
      return;
    }
    if (opponentPlayerActions.isNotEmpty &&
        opponentPlayerActions.first.isValid() &&
        (ownPlayerActions.isEmpty || !ownPlayerActions.first.isValid())) {
      if (ownPlayerActions.isNotEmpty) {
        (ownPlayerActions.first as TurnEffectAction).isFirst = false;
      }
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
  /// turnNum: 現在のターン数
  /// currrentTurn: 現在のターン
  /// ```
  void turnOnOffTerastal(
      PlayerType playerType, PokeType type, int turnNum, Turn currentTurn) {
    final terastal = l.where((element) =>
        element is TurnEffectTerastal && element.playerType == playerType);
    if (terastal.isEmpty) {
      int insertIndex = l.lastIndexWhere((element) =>
          element is TurnEffectTerastal ||
          element.timing == Timing.afterTerastal);
      if (insertIndex < 0) {
        insertIndex =
            insertIndexByTiming(Timing.terastaling, turnNum, currentTurn);
      } else {
        insertIndex++;
      }
      l.insert(insertIndex,
          TurnEffectTerastal(playerType: playerType, teraType: type));
    } else {
      l.remove(terastal.first);
    }
  }

  /// 指定したタイミングを挿入可能な最初のインデックスを返す
  /// ```
  /// index: 挿入するタイミング
  /// turnNum: 現在のターン数
  /// currentTurn: 現在のターン
  /// ```
  int insertIndexByTiming(Timing timing, int turnNum, Turn currentTurn) {
    /// 現在のステート
    int state = turnNum == 1 ? 0 : 1; // 試合最初のポケモン登場時処理状態
    int end = 100;

    /// 現在着目しているフェーズインデックス
    int i = 0;

    /// 各プレイヤーの行動が残っているかどうか(行動より先にひんしになる場合もあるためこの変数で判断する)
    List<bool> remainAction = [true, true];

    /// 各プレイヤーの行動が有効かどうか
    List<bool> isValidAction = [false, false];

    /// ひんしになったかどうか
    /// TODO:同じターンに何体かひんしになることある？
    List<bool> isFainting = [false, false];

    // TODO: いらなそう
    /// 試合終了処理を終えたかどうか(これがtrueでない間は、s1がendでもs2が0じゃなくならない限りループは続ける)
    bool alreadyGameset = false;

    /// 各プレイヤーのポケモン交代したかどうか
    List<bool> isChanged = [turnNum == 1, turnNum == 1];

    /// ステートと対応するタイミングのマップ
    const Map<int, Timing> stateTimingMap = {
      0: Timing.pokemonAppear, // 試合最初のポケモン登場時処理状態
      1: Timing.afterActionDecision, // 行動決定直後処理状態
      2: Timing.action, // こうさん処理状態
      3: Timing.action, // (行動としての)ポケモン交代処理状態
      4: Timing.pokemonAppear, // (行動としての)ポケモン交代後処理状態
      5: Timing.terastaling, // テラスタル処理状態
      6: Timing.afterTerastal, // テラスタル後処理状態
      7: Timing.beforeMove, // わざ使用前処理状態
      8: Timing.action, // わざ処理状態
      9: Timing.afterMove, // わざ使用後処理状態
      10: Timing.pokemonAppear, // 交代わざ使用後状態
      11: Timing.everyTurnEnd, // ターン終了時処理状態
      12: Timing.changeFaintingPokemon, // ひんし交代処理状態
      13: Timing.pokemonAppear, // ひんし交代後処理状態
      14: Timing.gameSet, // 試合終了状態
    };
    Timing currentTiming = stateTimingMap[state]!;

    /// 効果によってポケモン交代した状態
    bool changingState = false;

    while (!alreadyGameset && state != end) {
      currentTiming =
          changingState ? Timing.pokemonAppear : stateTimingMap[state]!;
      if (currentTiming == timing) {
        return i;
      }
      bool toNext = false;
      if (i < l.length && l[i] is TurnEffectUserEdit) {
        // パラメータ編集は無視して次へ
        toNext = true;
      } else if (changingState) {
        // ポケモン交代後状態
        if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
          changingState = false;
        } else {
          toNext = true;
        }
      } else {
        switch (state) {
          case 0: // 試合最初のポケモン登場時処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state++; // 行動決定直後処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 1: // 行動決定直後処理状態
            if (i >= l.length || l[i].timing != Timing.afterActionDecision) {
              state++; // こうさん処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 2: // こうさん処理状態
            if (i >= l.length ||
                !(l[i] is TurnEffectAction &&
                    (l[i] as TurnEffectAction).type ==
                        TurnActionType.surrender)) {
              state++; // (行動としての)ポケモン交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 3: // (行動としての)ポケモン交代処理状態
            if (i >= l.length ||
                !(l[i] is TurnEffectAction &&
                    (l[i] as TurnEffectAction).type == TurnActionType.change)) {
              state = 5; // テラスタル処理状態へ
            } else {
              toNext = true;
              state++; // (行動としての)ポケモン交代処理後状態へ
            }
            break;
          case 4: // (行動としての)ポケモン交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state = 3; // (行動としての)ポケモン交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 5: // テラスタル処理状態
            if (i >= l.length || l[i].timing != Timing.terastaling) {
              state = 7; // わざ使用前処理状態へ
            } else {
              toNext = true;
              state++; // テラスタル後処理状態へ
            }
            break;
          case 6: // テラスタル後処理状態
            if (i >= l.length || l[i].timing != Timing.afterTerastal) {
              state = 5; // テラスタル処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 7: // わざ使用前処理状態
            if (i >= l.length || l[i].timing != Timing.beforeMove) {
              state++; // わざ処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 8: // わざ処理状態
            {
              isChanged = [false, false];
              if (i >= l.length || l[i].runtimeType != TurnEffectAction) {
                state = 11; // ターン終了時処理状態へ
              } else {
                toNext = true;
                final action = l[i] as TurnEffectAction;
                remainAction[action.playerType.number] = false;
                if (action.isValid()) {
                  isValidAction[action.playerType.number] = true;
                  assert(action.type == TurnActionType.move);
                  // 交代が発生するか
                  if (action.getChangePokemonIndex(PlayerType.me) != null ||
                      action.getChangePokemonIndex(PlayerType.opponent) !=
                          null) {
                    // わざが失敗/命中していなければポケモン交代も発生しない
                    if (!action.isNormallyHit()) {
                    } else {
                      isChanged[PlayerType.me.number] =
                          action.getChangePokemonIndex(PlayerType.me) != null;
                      isChanged[PlayerType.opponent.number] =
                          action.getChangePokemonIndex(PlayerType.opponent) !=
                              null;
                    }
                  }
                  state = 9; // わざ使用後処理状態へ
                } else {
                  if (!remainAction[PlayerType.me.number] &&
                      !remainAction[PlayerType.opponent.number]) {
                    state = 11; // ターン終了時処理へ
                  } else {
                    state = 7; // わざ使用前処理状態へ
                  }
                }
              }
            }
            break;
          case 9: // わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.afterMove) {
              if (isChanged[PlayerType.me.number] ||
                  isChanged[PlayerType.opponent.number]) {
                state = 10; // 交代わざ使用後処理状態へ
              } else {
                if (!remainAction[PlayerType.me.number] &&
                    !remainAction[PlayerType.opponent.number]) {
                  state = 11; // ターン終了時処理へ
                } else {
                  state = 7; // わざ使用前処理状態へ
                }
              }
            } else {
              toNext = true;
              if (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                  l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
                // 効果によりポケモン交代が生じた場合
                changingState = true;
                state = 7; // わざ使用前処理状態へ
              }
            }
            break;
          case 10: // 交代わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              isChanged = [false, false];
              if (!remainAction[PlayerType.me.number] &&
                  !remainAction[PlayerType.opponent.number]) {
                state = 11; // ターン終了時処理へ
              } else {
                state = 7; // わざ使用前処理状態へ
              }
            } else {
              toNext = true;
            }
            break;
          case 11: // ターン終了状態
            if (i >= l.length || l[i].timing != Timing.everyTurnEnd) {
              state++; // ひんし交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 12: // ひんし交代処理状態
            {
              isChanged = [false, false];
              if (i >= l.length ||
                  l[i].runtimeType != TurnEffectChangeFaintingPokemon) {
                state = end;
              } else {
                if (isFainting[PlayerType.me.number] &&
                    l[i].playerType == PlayerType.me) {
                  isFainting[PlayerType.me.number] = false;
                } else if (isFainting[PlayerType.opponent.number] &&
                    l[i].playerType == PlayerType.opponent) {
                  isFainting[PlayerType.opponent.number] = false;
                }
                toNext = true;
                state++; // ひんし交代後処理状態へ
              }
            }
            break;
          case 13: // ひんし交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state = 12; // ひんし交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 14: // 試合終了状態
            toNext = true;
            alreadyGameset = true;
            state = end;
            break;
        }
      }
      if (toNext) {
        i++;
      }
    }

    return i;
  }

  /// 指定したインデックスに挿入可能なタイミングのリストを返す
  /// ```
  /// index: 挿入するインデックス
  /// turnNum: 現在のターン数
  /// currentTurn: 現在のターン
  /// ```
  List<Timing> insertableTimings(int index, int turnNum, Turn currentTurn) {
    Set<Timing> ret = {};

    /// 現在のステート
    int state = turnNum == 1 ? 0 : 1; // 試合最初のポケモン登場時処理状態
    int end = 100;

    /// 現在着目しているフェーズインデックス
    int i = 0;

    /// 各プレイヤーの行動が残っているかどうか(行動より先にひんしになる場合もあるためこの変数で判断する)
    List<bool> remainAction = [true, true];

    /// 各プレイヤーの行動が有効かどうか
    List<bool> isValidAction = [false, false];

    /// ひんしになったかどうか
    /// TODO:同じターンに何体かひんしになることある？
    List<bool> isFainting = [false, false];

    /// 試合の勝者(このターンで勝敗決まらない場合はnull)
    /// 先にwinnerに代入したら、他プレイヤーの代入禁止
    PlayerType? winner;

    // TODO: いらなそう
    /// 試合終了処理を終えたかどうか(これがtrueでない間は、s1がendでもs2が0じゃなくならない限りループは続ける)
    bool alreadyGameset = false;

    /// 試合終了処理を行うことが決定されているが、わざ使用後処理のみ残っている場合
    bool isReservedGameset = false;

    /// 各プレイヤーのポケモン交代したかどうか
    List<bool> isChanged = [turnNum == 1, turnNum == 1];

    /// ステートと対応するタイミングのマップ
    const Map<int, Timing> stateTimingMap = {
      0: Timing.pokemonAppear, // 試合最初のポケモン登場時処理状態
      1: Timing.afterActionDecision, // 行動決定直後処理状態
      2: Timing.action, // こうさん処理状態
      3: Timing.action, // (行動としての)ポケモン交代処理状態
      4: Timing.pokemonAppear, // (行動としての)ポケモン交代後処理状態
      5: Timing.terastaling, // テラスタル処理状態
      6: Timing.afterTerastal, // テラスタル後処理状態
      7: Timing.beforeMove, // わざ使用前処理状態
      8: Timing.action, // わざ処理状態
      9: Timing.afterMove, // わざ使用後処理状態
      10: Timing.pokemonAppear, // 交代わざ使用後状態
      11: Timing.everyTurnEnd, // ターン終了時処理状態
      12: Timing.changeFaintingPokemon, // ひんし交代処理状態
      13: Timing.pokemonAppear, // ひんし交代後処理状態
      14: Timing.gameSet, // 試合終了状態
    };
    Timing currentTiming = stateTimingMap[state]!;

    /// 効果によってポケモン交代した状態
    bool changingState = false;

    while (!alreadyGameset && state != end) {
      currentTiming =
          changingState ? Timing.pokemonAppear : stateTimingMap[state]!;
      ret.add(currentTiming);
      bool toNext = false;
      if (i < l.length && l[i] is TurnEffectUserEdit) {
        // パラメータ編集は無視して次へ
        toNext = true;
      } else if (changingState) {
        // ポケモン交代後状態
        if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
          changingState = false;
        } else {
          toNext = true;
        }
      } else {
        switch (state) {
          case 0: // 試合最初のポケモン登場時処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state++; // 行動決定直後処理状態へ
              //timingListIdx++;
            } else {
              toNext = true;
            }
            break;
          case 1: // 行動決定直後処理状態
            if (i >= l.length || l[i].timing != Timing.afterActionDecision) {
              state++; // こうさん処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 2: // こうさん処理状態
            if (i >= l.length ||
                !(l[i] is TurnEffectAction &&
                    (l[i] as TurnEffectAction).type ==
                        TurnActionType.surrender)) {
              state++; // (行動としての)ポケモン交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 3: // (行動としての)ポケモン交代処理状態
            if (i >= l.length ||
                !(l[i] is TurnEffectAction &&
                    (l[i] as TurnEffectAction).type == TurnActionType.change)) {
              state = 5; // テラスタル処理状態へ
            } else {
              toNext = true;
              state++; // (行動としての)ポケモン交代処理後状態へ
            }
            break;
          case 4: // (行動としての)ポケモン交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state = 3; // (行動としての)ポケモン交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 5: // テラスタル処理状態
            if (i >= l.length || l[i].timing != Timing.terastaling) {
              state = 7; // わざ使用前処理状態へ
            } else {
              toNext = true;
              state++; // テラスタル後処理状態へ
            }
            break;
          case 6: // テラスタル後処理状態
            if (i >= l.length || l[i].timing != Timing.afterTerastal) {
              state = 5; // テラスタル処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 7: // わざ使用前処理状態
            if (i >= l.length || l[i].timing != Timing.beforeMove) {
              state++; // わざ処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 8: // わざ処理状態
            {
              isChanged = [false, false];
              if (i >= l.length || l[i].runtimeType != TurnEffectAction) {
                state = 11; // ターン終了時処理状態へ
              } else {
                toNext = true;
                final action = l[i] as TurnEffectAction;
                remainAction[action.playerType.number] = false;
                if (action.isValid()) {
                  isValidAction[action.playerType.number] = true;
                  assert(action.type == TurnActionType.move);
                  // 交代が発生するか
                  if (action.getChangePokemonIndex(PlayerType.me) != null ||
                      action.getChangePokemonIndex(PlayerType.opponent) !=
                          null) {
                    // わざが失敗/命中していなければポケモン交代も発生しない
                    if (!action.isNormallyHit()) {
                    } else {
                      isChanged[PlayerType.me.number] =
                          action.getChangePokemonIndex(PlayerType.me) != null;
                      isChanged[PlayerType.opponent.number] =
                          action.getChangePokemonIndex(PlayerType.opponent) !=
                              null;
                    }
                  }
                  state = 9; // わざ使用後処理状態へ
                } else {
                  if (!remainAction[PlayerType.me.number] &&
                      !remainAction[PlayerType.opponent.number]) {
                    state = 11; // ターン終了時処理へ
                  } else {
                    state = 7; // わざ使用前処理状態へ
                  }
                }
              }
            }
            break;
          case 9: // わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.afterMove) {
              if (isChanged[PlayerType.me.number] ||
                  isChanged[PlayerType.opponent.number]) {
                state = 10; // 交代わざ使用後処理状態へ
              } else {
                if (!remainAction[PlayerType.me.number] &&
                    !remainAction[PlayerType.opponent.number]) {
                  state = 11; // ターン終了時処理へ
                } else {
                  state = 7; // わざ使用前処理状態へ
                }
              }
            } else {
              toNext = true;
              if (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                  l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
                // 効果によりポケモン交代が生じた場合
                changingState = true;
                state = 7; // わざ使用前処理状態へ
              }
            }
            break;
          case 10: // 交代わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              isChanged = [false, false];
              if (!remainAction[PlayerType.me.number] &&
                  !remainAction[PlayerType.opponent.number]) {
                state = 11; // ターン終了時処理へ
              } else {
                state = 7; // わざ使用前処理状態へ
              }
            } else {
              toNext = true;
            }
            break;
          case 11: // ターン終了状態
            if (i >= l.length || l[i].timing != Timing.everyTurnEnd) {
              state++; // ひんし交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 12: // ひんし交代処理状態
            {
              isChanged = [false, false];
              if (i >= l.length ||
                  l[i].runtimeType != TurnEffectChangeFaintingPokemon) {
                state = end;
              } else {
                if (isFainting[PlayerType.me.number] &&
                    l[i].playerType == PlayerType.me) {
                  isFainting[PlayerType.me.number] = false;
                } else if (isFainting[PlayerType.opponent.number] &&
                    l[i].playerType == PlayerType.opponent) {
                  isFainting[PlayerType.opponent.number] = false;
                }
                toNext = true;
                state++; // ひんし交代後処理状態へ
              }
            }
            break;
          case 13: // ひんし交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              state = 12; // ひんし交代処理状態へ
            } else {
              toNext = true;
            }
            break;
          case 14: // 試合終了状態
            toNext = true;
            alreadyGameset = true;
            state = end;
            break;
        }
      }

      if (i < l.length &&
          winner == null &&
          toNext &&
          l[i].isValid() &&
          l[i] is! TurnEffectAction &&
          (l[i].getChangePokemonIndex(PlayerType.me) != null ||
              l[i].getChangePokemonIndex(PlayerType.opponent) != null)) {
        // 効果によりポケモン交代が生じた場合
        changingState = true;
        if (l[i].getChangePokemonIndex(PlayerType.me) != null) {
          isChanged[PlayerType.me.number] = true;
          // 行動も消費
          remainAction[PlayerType.me.number] = false;
          isValidAction[PlayerType.me.number] = true;
        }
        if (l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
          isChanged[PlayerType.opponent.number] = true;
          // 行動も消費
          remainAction[PlayerType.opponent.number] = false;
          isValidAction[PlayerType.opponent.number] = true;
        }
      }

      if (state != end &&
          winner == null &&
          toNext &&
          i < l.length &&
          (l[i].isMyWin || l[i].isYourWin)) // どちらかが勝利したら
      {
        winner = l[i].isMyWin ? PlayerType.me : PlayerType.opponent;
        if (stateTimingMap[state]! == Timing.afterMove) {
          // わざ使用後の場合は、その処理が終わるまで試合終了処理をスタック
          isReservedGameset = true;
        } else {
          state = 14; // 試合終了状態へ
        }
      } else {
        // どちらかがひんしになる場合
        if (state != end && toNext && i < l.length) {
          if (l[i].isOwnFainting) {
            isFainting[PlayerType.me.number] = true;
            remainAction[PlayerType.me.number] = false;
          }
          if (l[i].isOpponentFainting) {
            isFainting[PlayerType.opponent.number] = true;
            remainAction[PlayerType.opponent.number] = false;
          }
        }
      }

      if (state != end &&
          isReservedGameset &&
          stateTimingMap[state]! != Timing.afterMove) {
        state = 14; // 試合終了状態へ
      }

      if (toNext) {
        if (i == index) {
          return ret.toList();
        }
        ret.clear();
        i++;
      }
    }

    return ret.toList();
  }

  /// TODO:フェーズを最適化する
  ///
  //List<List<TurnEffectAndStateAndGuide>> _adjustPhases(MyAppState appState, bool isNewTurn, AppLocalizations loc,) {
  StatusInfoPageIndex adjust(
    bool isNewTurn,
    int turnNum,
    Turn currentTurn,
    Party ownParty,
    Party opponentParty,
    String opponentName,
    AppLocalizations loc,
  ) {
    var ret = StatusInfoPageIndex.none;
    // 試合終了フェーズは一旦削除する
    l.removeWhere(
      (element) => element is TurnEffectGameset,
    );
    //_clearAddingPhase(appState);      // 一旦、追加用のフェーズは削除する
    //int beginIdx = 0;
    //Timing timing = Timing.none;
    //List<List<TurnEffectAndStateAndGuide>> ret = [];
    //List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
    //Turn currentTurn = widget.battle.turns[turnNum - 1];
    // 行動順をアップデート
    updateActionOrder();
    PhaseState currentState = currentTurn.copyInitialState();

    /// 現在のステート
    int state = turnNum == 1 ? 0 : 1; // 試合最初のポケモン登場時処理状態
    int end = 100;

    /// 現在着目しているフェーズインデックス
    int i = 0;

    /// 各プレイヤーの行動が残っているかどうか(行動より先にひんしになる場合もあるためこの変数で判断する)
    List<bool> remainAction = [true, true];

    /// 各プレイヤーの行動が有効かどうか
    List<bool> isValidAction = [false, false];

    /// ひんしになったかどうか
    /// TODO:同じターンに何体かひんしになることある？
    List<bool> isFainting = [false, false];

    /// 試合の勝者(このターンで勝敗決まらない場合はnull)
    /// 先にwinnerに代入したら、他プレイヤーの代入禁止
    PlayerType? winner;

    // TODO: いらなそう
    /// 試合終了処理を終えたかどうか(これがtrueでない間は、s1がendでもs2が0じゃなくならない限りループは続ける)
    bool alreadyGameset = false;

    /// 試合終了処理を行うことが決定されているが、わざ使用後処理のみ残っている場合
    bool isReservedGameset = false;

    /// 各プレイヤーのポケモン交代したかどうか
    List<bool> isChanged = [turnNum == 1, turnNum == 1];

    /// ステートと対応するタイミングのマップ
    const Map<int, Timing> stateTimingMap = {
      0: Timing.pokemonAppear, // 試合最初のポケモン登場時処理状態
      1: Timing.afterActionDecision, // 行動決定直後処理状態
      2: Timing.action, // こうさん処理状態
      3: Timing.action, // (行動としての)ポケモン交代処理状態
      4: Timing.pokemonAppear, // (行動としての)ポケモン交代後処理状態
      5: Timing.terastaling, // テラスタル処理状態
      6: Timing.afterTerastal, // テラスタル後処理状態
      7: Timing.beforeMove, // わざ使用前処理状態
      8: Timing.action, // わざ処理状態
      9: Timing.afterMove, // わざ使用後処理状態
      10: Timing.pokemonAppear, // 交代わざ使用後状態
      11: Timing.everyTurnEnd, // ターン終了時処理状態
      12: Timing.changeFaintingPokemon, // ひんし交代処理状態
      13: Timing.pokemonAppear, // ひんし交代後処理状態
      14: Timing.gameSet, // 試合終了状態
    };
    Timing currentTiming = stateTimingMap[state]!;
    Timing prevTiming = Timing.none;
    List<TurnEffect> assistList = [];
    //List<TurnEffect> delAssistList = [];
    //PlayerType? firstActionPlayer;
    TurnEffectAction? lastAction;

    /// 効果によってポケモン交代した状態
    bool changingState = false;

    /// TODO: 必要？
    bool isAssisting = false;
    // 自動入力リスト作成
    if (isNewTurn) {
      assistList = currentState.getDefaultEffectList(
        currentTurn,
        currentTiming,
        isChanged[PlayerType.me.number],
        isChanged[PlayerType.opponent.number],
        currentState,
        lastAction,
      );
      // TODO
/*
      for (final effect in currentTurn.noAutoAddEffect) {
        assistList.removeWhere((e) => effect.nearEqual(e));
      }
*/
    }

    while (!alreadyGameset && state != end) {
      currentTiming =
          changingState ? Timing.pokemonAppear : stateTimingMap[state]!;

      /// TODO: 必要？
      bool isInserted = false;
      bool skipInc = false;
      if (i < l.length && l[i] is TurnEffectUserEdit) {
        // 何も変化させず、processEffect()
        // currentTimingを無効にすることで自動入力を再作成させる
        currentTiming = Timing.none;
      } else if (changingState) {
        // ポケモン交代後状態
        if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
          // 自動追加
          if (assistList.isNotEmpty) {
            l.insert(i, assistList.removeAt(0));
            isAssisting = true;
            isInserted = true;
          } else {
            //isInserted = true;
            //timingListIdx++;
            isAssisting = false;
            changingState = false;
            skipInc = true;
          }
        } else {
          isAssisting = true;
        }
      } else {
        switch (state) {
          case 0: // 試合最初のポケモン登場時処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                skipInc = true;
                state++; // 行動決定直後処理状態へ
                //timingListIdx++;
                isAssisting = false;
              }
            } else {
              isAssisting = true;
            }
            break;
          case 1: // 行動決定直後処理状態
            if (i >= l.length || l[i].timing != Timing.afterActionDecision) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                state++; // こうさん処理状態へ
                //timingListIdx++;
                isAssisting = false;
                skipInc = true;
              }
            } else {
              isAssisting = true;
            }
            break;
          case 2: // こうさん処理状態
            // iより先こうさん行動があれば前に移動する
            // こうさん行動がなければ次のステートへ
            bool isExistSurrender = false;
            for (int idx = i; idx < l.length; idx++) {
              if (l[idx] is TurnEffectAction) {
                final action = l[idx] as TurnEffectAction;
                if (action.type == TurnActionType.surrender) {
                  final removed = l.removeAt(idx);
                  l.insert(i, removed);
                  isExistSurrender = true;
                  break;
                }
              }
            }
            if (isExistSurrender) {
              isAssisting = true;
            } else {
              state++; // (行動としての)ポケモン交代処理状態へ
              isAssisting = false;
              skipInc = true;
            }
            break;
          case 3: // (行動としての)ポケモン交代処理状態
            // iより先ポケモン交代行動があれば前に移動する
            // ポケモン交代行動がなければ次のステートへ
            bool isExistChange = false;
            isChanged = [false, false];
            for (int idx = i; idx < l.length; idx++) {
              if (l[idx] is TurnEffectAction) {
                final action = l[idx] as TurnEffectAction;
                if (action.type == TurnActionType.change) {
                  remainAction[action.playerType.number] = false;
                  if (action.isValid()) {
                    isChanged[action.playerType.number] = true;
                    isValidAction[action.playerType.number] = true;
                  }
                  // 交代後のポケモン登場時処理を含めて移動させる
                  int endIdx = idx;
                  final removed = [l[idx]];
                  for (int idx2 = idx + 1; idx2 < l.length; idx2++) {
                    if (l[idx2].timing == Timing.pokemonAppear) {
                      removed.add(l[idx2]);
                      endIdx++;
                    } else {
                      break;
                    }
                  }
                  l.removeRange(idx, endIdx + 1);
                  l.insertAll(i, removed);
                  isExistChange = true;
                  break;
                }
              }
            }
            if (isExistChange) {
              isAssisting = true;
              state++; // (行動としての)ポケモン交代処理後状態へ
            } else {
              state = 5; // テラスタル処理状態へ
              isAssisting = false;
              skipInc = true;
            }
            break;
          case 4: // (行動としての)ポケモン交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                //timingListIdx++;
                isAssisting = false;
                isChanged = [false, false];
                skipInc = true;
                state = 3; // (行動としての)ポケモン交代処理状態へ
              }
            } else {
              isAssisting = true;
            }
            break;
          case 5: // テラスタル処理状態
            if (i >= l.length || l[i].timing != Timing.terastaling) {
              state = 7; // わざ使用前処理状態へ
              skipInc = true;
              isAssisting = true;
            } else {
              //isInserted = true;
              state++; // テラスタル後処理状態へ
              //timingListIdx++;
              isAssisting = false;
            }
            break;
          case 6: // テラスタル後処理状態
            if (i >= l.length || l[i].timing != Timing.afterTerastal) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                state = 5; // テラスタル処理状態へ
                //timingListIdx++;
                isAssisting = false;
                skipInc = true;
              }
            } else {
              isAssisting = true;
            }
            break;
          case 7: // わざ使用前処理状態
            if (i >= l.length || l[i].timing != Timing.beforeMove) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                state++; // わざ処理状態へ
                //timingListIdx++;
                isAssisting = false;
                skipInc = true;
              }
            } else {
              isAssisting = true;
            }
            break;
          case 8: // わざ処理状態
            {
              // TODO?
              //_clearInvalidPhase(appState, i, true, true);
              isChanged = [false, false];
              //actionCount++;
              if (i >= l.length || l[i].runtimeType != TurnEffectAction) {
                // TODO:ありえない？
                /*_insertPhase(
                        i,
                        TurnEffect()
                          ..timing = Timing.action
                          ..effectType = EffectType.move
                          ..move = TurnMove(),
                        appState);
                    if (actionCount == 1) l[i].move!.isFirst = true;
                    isInserted = true;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }*/
                state = 11; // ターン終了時処理状態へ
                isAssisting = false;
                skipInc = true;
              } else {
                final action = l[i] as TurnEffectAction;
                remainAction[action.playerType.number] = false;
                if (action.isValid()) {
                  isValidAction[action.playerType.number] = true;
                  assert(action.type == TurnActionType.move);
                  // 交代が発生するか
                  if (action.getChangePokemonIndex(PlayerType.me) != null ||
                      action.getChangePokemonIndex(PlayerType.opponent) !=
                          null) {
                    // わざが失敗/命中していなければポケモン交代も発生しない
                    if (!action.isNormallyHit()) {
                    } else {
                      isChanged[PlayerType.me.number] =
                          action.getChangePokemonIndex(PlayerType.me) != null;
                      isChanged[PlayerType.opponent.number] =
                          action.getChangePokemonIndex(PlayerType.opponent) !=
                              null;
                    }
                  }
                  state = 9; // わざ使用後処理状態へ
                } else {
                  if (!remainAction[PlayerType.me.number] &&
                      !remainAction[PlayerType.opponent.number]) {
                    state = 11; // ターン終了時処理へ
                  } else {
                    state = 7; // わざ使用前処理状態へ
                  }
                }
                lastAction = l[i] as TurnEffectAction;
              }
              //timingListIdx++;
            }
            break;
          case 9: // わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.afterMove) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                //timingListIdx++;
                isAssisting = false;
                skipInc = true;
                if (isChanged[PlayerType.me.number] ||
                    isChanged[PlayerType.opponent.number]) {
                  // 交代わざ処理実施
                  lastAction!.processChangeEffect(
                      currentState.getPokemonState(PlayerType.me, null),
                      currentState.getPokemonState(PlayerType.opponent, null),
                      currentState);
                  state = 10; // 交代わざ使用後処理状態へ
                } else {
                  if (!remainAction[PlayerType.me.number] &&
                      !remainAction[PlayerType.opponent.number]) {
                    state = 11; // ターン終了時処理へ
                  } else {
                    state = 7; // わざ使用前処理状態へ
                  }
                }
              }
            } else {
              isAssisting = true;
              if (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                  l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
                // 効果によりポケモン交代が生じた場合
                state = 7; // わざ使用前処理状態へ
              }
            }
            break;
          case 10: // 交代わざ使用後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                //timingListIdx++;
                isAssisting = false;
                isChanged = [false, false];
                skipInc = true;
                if (!remainAction[PlayerType.me.number] &&
                    !remainAction[PlayerType.opponent.number]) {
                  state = 11; // ターン終了時処理へ
                } else {
                  state = 7; // わざ使用前処理状態へ
                }
              }
            } else {
              isAssisting = true;
            }
            break;
          case 11: // ターン終了状態
            if (i >= l.length || l[i].timing != Timing.everyTurnEnd) {
              // 自動追加
              if (assistList.isNotEmpty /* && !alreadyTurnEnd*/) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                isAssisting = false;
                skipInc = true;
                state++; // ひんし交代処理状態へ
              }
            } else {}
            break;
          case 12: // ひんし交代処理状態
            {
              isChanged = [false, false];
              if (i >= l.length ||
                  l[i].runtimeType != TurnEffectChangeFaintingPokemon) {
                if (isFainting[PlayerType.me.number]) {
                  isFainting[PlayerType.me.number] = false;
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                        player: PlayerType.me,
                      ));
                  isInserted = true;
                  // TODO: 不要になった？
                  // ひんしになったポケモンがまだ行動していなかった場合
                  if (getLatestActionIndex(PlayerType.me) > i) {
                    // その行動を削除
                    // TODO:追加も必要
                    l.removeAt(getLatestActionIndex(PlayerType.me));
                  }
                  state++; // ひんし交代後処理状態へ
                } else if (isFainting[PlayerType.opponent.number]) {
                  isFainting[PlayerType.opponent.number] = false;
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                        player: PlayerType.opponent,
                      ));
                  isInserted = true;
                  // TODO: 不要になった？
                  // ひんしになったポケモンがまだ行動していなかった場合
                  if (getLatestActionIndex(PlayerType.opponent) > i) {
                    // その行動を削除
                    l.removeAt(getLatestActionIndex(PlayerType.opponent));
                  }
                  state++; // ひんし交代後処理状態へ
                } else {
                  skipInc = true;
                  state = end;
                }
              } else {
                if (isFainting[PlayerType.me.number] &&
                    l[i].playerType == PlayerType.me) {
                  isFainting[PlayerType.me.number] = false;
                  if (l[i].isValid()) {
                    isChanged[PlayerType.me.number] = true;
                  }
                } else if (isFainting[PlayerType.opponent.number] &&
                    l[i].playerType == PlayerType.opponent) {
                  isFainting[PlayerType.opponent.number] = false;
                  if (l[i].isValid()) {
                    isChanged[PlayerType.opponent.number] = true;
                  }
                }
                state++; // ひんし交代後処理状態へ
              }
              //timingListIdx++;
            }
            break;
          case 13: // ひんし交代後処理状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                //timingListIdx++;
                isAssisting = false;
                skipInc = true;
                isChanged = [false, false];
                if (!isFainting[PlayerType.me.number] &&
                    !isFainting[PlayerType.opponent.number]) {
                  state = end; // 終了
                } else {
                  state = 12; // ひんし交代処理状態へ
                }
              }
            } else {
              isAssisting = true;
            }
            break;
          case 14: // 試合終了状態
            l.insert(i,
                TurnEffectGameset(winner: winner!, opponentName: opponentName));
            l.removeRange(i + 1, l.length);
            // 行動がなくなった場合は不都合が出るので無効な行動を追加
            if (getLatestActionIndex(PlayerType.me) < 0) {
              l.add(TurnEffectAction(player: PlayerType.me));
            } else if (getLatestActionIndex(PlayerType.opponent) < 0) {
              l.add(TurnEffectAction(player: PlayerType.opponent));
            }
            alreadyGameset = true;
            state = end;
            break;
        }
      }

      if (i < l.length && !skipInc) {
        // 効果を処理する
        if (l[i].isValid()) {
          final guides = l[i].processEffect(
            ownParty,
            currentState.getPokemonState(PlayerType.me, null),
            opponentParty,
            currentState.getPokemonState(PlayerType.opponent, null),
            currentState,
            lastAction,
            loc: loc,
          );
          // 効果により確定する事項を反映させる
          for (final guide in guides) {
            var tmp = guide.processEffect(
                currentState.getPokemonState(PlayerType.me, null),
                currentState.getPokemonState(PlayerType.opponent, null),
                currentState);
            if (tmp != StatusInfoPageIndex.none) {
              ret = tmp;
            }
          }
          if (l[i] is! TurnEffectAction &&
              (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                  l[i].getChangePokemonIndex(PlayerType.opponent) != null)) {
            // 効果によりポケモン交代が生じた場合
            changingState = true;
            if (l[i].getChangePokemonIndex(PlayerType.me) != null) {
              isChanged[PlayerType.me.number] = true;
              // 行動も消費
              remainAction[PlayerType.me.number] = false;
              isValidAction[PlayerType.me.number] = true;
            }
            if (l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
              isChanged[PlayerType.opponent.number] = true;
              // 行動も消費
              remainAction[PlayerType.opponent.number] = false;
              isValidAction[PlayerType.opponent.number] = true;
            }
          }
        }

        // ターン終了時処理(共通)を実施
        if (prevTiming == Timing.everyTurnEnd &&
            currentTiming != Timing.none &&
            currentTiming != Timing.everyTurnEnd &&
            isValidAction[0] != remainAction[0] &&
            isValidAction[1] != remainAction[1]) {
          currentState.processTurnEnd(currentTurn);
        }

        if (state != end &&
            winner == null &&
            (!isInserted || isAssisting) &&
            i < l.length &&
            (l[i].isMyWin || l[i].isYourWin)) // どちらかが勝利したら
        {
          winner = l[i].isMyWin ? PlayerType.me : PlayerType.opponent;
          //isYourWin = l[i].isYourWin;
          if (stateTimingMap[state]! == Timing.afterMove) {
            // わざ使用後の場合は、その処理が終わるまで試合終了処理をスタック
            isReservedGameset = true;
          } else {
            state = 14; // 試合終了状態へ
          }
        } else {
          // どちらかがひんしになる場合
          if (state != end && (!isInserted || isAssisting) && i < l.length) {
            if (l[i].isOwnFainting) {
              isFainting[PlayerType.me.number] = true;
              remainAction[PlayerType.me.number] = false;
              isValidAction[PlayerType.me.number] = true;
            }
            if (l[i].isOpponentFainting) {
              isFainting[PlayerType.opponent.number] = true;
              remainAction[PlayerType.opponent.number] = false;
              isValidAction[PlayerType.opponent.number] = true;
            }
            // TODO?
            /*
            if (s2 == 1 || l[i].timing == Timing.action) {
              if ((isOwnFainting &&
                      !isOpponentFainting &&
                      l[i].playerType == PlayerType.me) ||
                  (isOpponentFainting &&
                      !isOwnFainting &&
                      l[i].playerType == PlayerType.opponent)) {
              } else {
                // わざ使用者のみがひんしになったのでなければ、このターンの行動はもう無い
                actionCount = 2;
              }
            }
            */
          }
        }

        if (i < l.length) i++;
      } else {
        // ターン終了時処理(共通)を実施
        if (prevTiming == Timing.everyTurnEnd &&
            currentTiming != Timing.none &&
            currentTiming != Timing.everyTurnEnd &&
            isValidAction[0] != remainAction[0] &&
            isValidAction[1] != remainAction[1]) {
          currentState.processTurnEnd(currentTurn);
        }
      }

      if (state != end &&
          isReservedGameset &&
          stateTimingMap[state]! != Timing.afterMove) {
        state = 14; // 試合終了状態へ
      }

      // 自動入力効果を作成
      // 前回までと違うタイミング、かつ更新要求インデックス以降のとき作成
      if (state != end) {
        var nextTiming =
            changingState ? Timing.pokemonAppear : stateTimingMap[state]!;
        prevTiming = currentTiming;
        if (/*(timingListIdx >= sameTimingList.length ||
            sameTimingList[timingListIdx].first.turnEffect.timing != nextTiming ||*/
            ((currentTiming !=
                nextTiming) /*||
            sameTimingList[timingListIdx].first.needAssist*/
            ) /*&&
                appState.needAdjustPhases <= i &&
                !appState.adjustPhaseByDelete*/
            ) {
          var tmpAction = lastAction;
          if (nextTiming == Timing.beforeMove) {
            // わざの先読みをする
            for (int j = i; j < l.length; j++) {
              if (l[j] is TurnEffectAction) {
                // へんげんじざい等のわざは、ダメージ予測のためには例え有効な入力になっていなくても
                // 渡してあげるべき
                tmpAction = (l[j] as TurnEffectAction);
                if (tmpAction.type != TurnActionType.move ||
                    tmpAction.move.id == 0) {
                  tmpAction = null;
                }
                break;
              }
            }
          }
          // ターン終了時処理は、両者の行動が確定している場合のみ自動挿入を行う
          if (nextTiming != Timing.everyTurnEnd ||
              (isValidAction[0] != remainAction[0] &&
                  isValidAction[1] != remainAction[1])) {
            assistList = currentState.getDefaultEffectList(
              currentTurn,
              nextTiming,
              isChanged[PlayerType.me.number],
              isChanged[PlayerType.opponent.number],
              currentState,
              tmpAction,
            );
          }
          for (final effect in currentTurn.noAutoAddEffect) {
            assistList.removeWhere((e) => effect.nearEqual(e));
          }
          // 同じタイミングの先読みをし、既に入力済みで自動入力に含まれるものは除外する
          // それ以外で入力済みの自動入力は削除
          //List<int> removeIdxs = [];
          for (int j = i; j < l.length; j++) {
            if (l[j].timing != nextTiming) break;
            // TODO
            int findIdx =
                assistList.indexWhere((element) => element.nearEqual(l[j]));
            if (findIdx >= 0) {
              assistList.removeAt(findIdx);
              // TODO
              /*} else if (l[j].isAutoSet) {
              removeIdxs.add(j);*/
            }
          }
/*          
          // 削除インデックスリストの重複削除、ソート(念のため)
          removeIdxs = removeIdxs.toSet().toList();
          removeIdxs.sort();
          for (int i = removeIdxs.length - 1; i >= 0; i--) {
            l.removeAt(removeIdxs[i]);
          }
          if (timingListIdx < sameTimingList.length) {
            for (var e in sameTimingList[timingListIdx]) {
              e.needAssist = false;
            }
          }
*/
          if (currentTiming == Timing.pokemonAppear) {
            isChanged[PlayerType.me.number] = false;
            isChanged[PlayerType.opponent.number] = false;
          }
        } else if (currentTiming != nextTiming) {
          assistList.clear();
          //delAssistList.clear();
        }
      }
    }

/*
    for (int i = 0; i < turnEffectAndStateAndGuides.length; i++) {
      turnEffectAndStateAndGuides[i].phaseIdx = i;
      if (turnEffectAndStateAndGuides[i].turnEffect.timing != timing ||
          turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.action ||
          turnEffectAndStateAndGuides[i].turnEffect.timing == Timing.changeFaintingPokemon
      ) {
        if (i != 0) {
          turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
            currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
          ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, i));
        }
        beginIdx = i;
        timing = turnEffectAndStateAndGuides[i].turnEffect.timing;
      }
    }

    if (phases.isNotEmpty) {
      turnEffectAndStateAndGuides[beginIdx].updateEffectCandidates(
        currentTurn, turnEffectAndStateAndGuides[beginIdx == 0 ? beginIdx : beginIdx-1].phaseState);
      ret.add(turnEffectAndStateAndGuides.sublist(beginIdx, phases.length));
    }
    return ret;*/
    return ret;
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

  /// 正体がばれていないゾロアがいる可能性があるかどうか
  bool canZorua = false;

  /// 正体がばれていないゾロアークがいる可能性があるかどうか
  bool canZoroark = false;

  /// 正体がばれていないゾロア(ヒスイ)がいる可能性があるかどうか
  bool canZoruaHisui = false;

  /// 正体がばれていないゾロアーク(ヒスイ)がいる可能性があるかどうか
  bool canZoroarkHisui = false;

  @override
  List<Object?> get props => [
        _initialState,
        phases,
        _endingState,
        noAutoAddEffect,
        canZorua,
        canZoroark,
        canZoruaHisui,
        canZoroarkHisui,
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
    ..noAutoAddEffect = [for (final effect in noAutoAddEffect) effect.copy()]
    ..canZorua = canZorua
    ..canZoroark = canZoroark
    ..canZoruaHisui = canZoruaHisui
    ..canZoroarkHisui = canZoroarkHisui;

  /// ターン開始時の状態のコピーを返す
  PhaseState copyInitialState() {
    return _initialState.copy();
  }

  /// 有効かどうか
  bool isValid() {
    Map<PlayerType, bool> actioned = {
      PlayerType.me: false,
      PlayerType.opponent: false
    };
    Map<PlayerType, bool> isValid = {
      PlayerType.me: false,
      PlayerType.opponent: false
    };
    for (final phase in phases) {
      if (phase is TurnEffectAction ||
          phase is TurnEffectChangeFaintingPokemon) {
        actioned[phase.playerType] = true;
        isValid[phase.playerType] = phase.isValid();
      } else if (phase.getChangePokemonIndex(PlayerType.me) != null) {
        actioned[PlayerType.me] = true;
        isValid[PlayerType.me] = phase.isValid();
      } else if (phase.getChangePokemonIndex(PlayerType.opponent) != null) {
        actioned[PlayerType.opponent] = true;
        isValid[PlayerType.opponent] = phase.isValid();
      }
    }
    return actioned.values.where((element) => !element).isEmpty &&
        isValid.values.where((element) => !element).isEmpty;
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

  /// パーティと選出ポケモンからターンの情報を初期化する
  /// ```
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 相手のパーティ
  /// checkedPokemons: 選出ポケモン情報
  /// ```
  void initializeFromPartyInfo(
    Party ownParty,
    Party opponentParty,
    CheckedPokemons checkedPokemons,
  ) {
    final pokeData = PokeDB();

    setInitialPokemonIndex(PlayerType.me, checkedPokemons.own[0]);
    setInitialPokemonIndex(PlayerType.opponent, checkedPokemons.opponent);
    canZorua = opponentParty.pokemons
        .where((e) => e?.no == PokeBase.zoruaNo)
        .isNotEmpty;
    canZoroark = opponentParty.pokemons
        .where((e) => e?.no == PokeBase.zoroarkNo)
        .isNotEmpty;
    canZoruaHisui = opponentParty.pokemons
        .where((e) => e?.no == PokeBase.zoruaHisuiNo)
        .isNotEmpty;
    canZoroarkHisui = opponentParty.pokemons
        .where((e) => e?.no == PokeBase.zoroarkHisuiNo)
        .isNotEmpty;
    // 自身のポケモンの状態の初期設定
    for (int i = 0; i < ownParty.pokemonNum; i++) {
      final poke = ownParty.pokemons[i]!;
      final pokeState = PokemonState()
        ..playerType = PlayerType.me
        ..pokemon = poke
        ..remainHP = poke.h.real
        ..battlingNum = checkedPokemons.own.indexWhere((e) => e == i + 1) + 1
        ..setHoldingItemNoEffect(ownParty.items[i])
        ..usedPPs = List.generate(poke.moves.length, (i) => 0)
        ..setCurrentAbilityNoEffect(poke.ability)
        ..minStats = SixStats.generate((j) => poke.stats.sixParams[j])
        ..maxStats = SixStats.generate((j) => poke.stats.sixParams[j])
        ..moves = [for (int j = 0; j < poke.moveNum; j++) poke.moves[j]!]
        ..type1 = poke.type1
        ..type2 = poke.type2;
      getInitialPokemonStates(PlayerType.me).add(pokeState);
      getInitialLastExitedStates(PlayerType.me).add(pokeState.copy());
    }
    // 相手ポケモン状態の初期設定
    for (int i = 0; i < opponentParty.pokemonNum; i++) {
      final poke = opponentParty.pokemons[i]!;
      final state = PokemonState()
        ..playerType = PlayerType.opponent
        ..pokemon = poke
        ..battlingNum = i + 1 == checkedPokemons.opponent ? 1 : 0
        ..setHoldingItemNoEffect(
            pokeData.items[pokeData.pokeBase[poke.no]!.fixedItemID])
        ..minStats = SixStats.generate((j) => FourParams.createFromValues(
            statIndex: StatIndex.values[j],
            level: poke.level,
            race: poke.stats.sixParams[j].race,
            indi: 0,
            effort: 0,
            temper: Temper(0, '', '', StatIndex.values[j], StatIndex.none)))
        ..maxStats = SixStats.generate((j) => FourParams.createFromValues(
            statIndex: StatIndex.values[j],
            level: poke.level,
            race: poke.stats.sixParams[j].race,
            indi: pokemonMaxIndividual,
            effort: pokemonMaxEffort,
            temper: Temper(0, '', '', StatIndex.none, StatIndex.values[j])))
        ..possibleAbilities = pokeData.pokeBase[poke.no]!.ability
        ..type1 = poke.type1
        ..type2 = poke.type2;
      if (pokeData.pokeBase[poke.no]!.fixedItemID != 0) {
        // もちもの確定
        poke.item = pokeData.items[pokeData.pokeBase[poke.no]!.fixedItemID];
      }
      if (state.possibleAbilities.length == 1) {
        // 対象ポケモンのとくせいが1つしかあり得ないなら確定
        opponentParty.pokemons[i]!.ability = state.possibleAbilities[0];
        state.setCurrentAbilityNoEffect(state.possibleAbilities[0]);
      }
      getInitialPokemonStates(PlayerType.opponent).add(state);
      getInitialLastExitedStates(PlayerType.opponent).add(state.copy());
    }
    // ゾロア関連の情報をphaseStateにコピー
    _initialState.canZorua = canZorua;
    _initialState.canZoroark = canZoroark;
    _initialState.canZoruaHisui = canZoruaHisui;
    _initialState.canZoroarkHisui = canZoroarkHisui;
    // 登場時処理を行う
    initialOwnPokemonState.processEnterEffect(
        initialOpponentPokemonState, copyInitialState());
    initialOpponentPokemonState.processEnterEffect(
        initialOwnPokemonState, copyInitialState());
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
    TurnEffectAction? lastAction;
    Map<PlayerType, bool> alreadyActioned = {
      PlayerType.me: false,
      PlayerType.opponent: false,
    };
    bool doneProcessTurnEnd = false;
    bool needChangeActionProcess = false;

    for (int i = 0; i < phaseIdx + 1; i++) {
      final phase = phases[i];
      //if (phase.isAdding) continue;
      //if (phase.timing == Timing.continuousMove) {
      //  lastAction = phase;
      //  continousCount++;
      //} else if (phase.timing == Timing.action) {
      //  lastAction = phase;
      //  continousCount = 0;
      //}
      // 交代を伴うわざ後処理が終わったなら交代処理を行う
      // ※lastActionを代入する前に処理する
      if (needChangeActionProcess && phase.timing != Timing.afterMove) {
        lastAction!.processChangeEffect(
            ret.getPokemonState(PlayerType.me, null),
            ret.getPokemonState(PlayerType.opponent, null),
            ret);
        needChangeActionProcess = false;
      }
      if (phase is TurnEffectAction) lastAction = phase;
      // 両者の行動が完了している＆ひんし交代の効果が初めて出現したなら
      // ターン終了時処理(共通)を実施する
      if (alreadyActioned[PlayerType.me]! &&
          alreadyActioned[PlayerType.opponent]! &&
          phase is TurnEffectChangeFaintingPokemon &&
          !doneProcessTurnEnd) {
        ret.processTurnEnd(this);
        doneProcessTurnEnd = true;
      }
      // 効果を処理する
      phase.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me,
            phase.timing == Timing.afterMove ? lastAction : null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent,
            phase.timing == Timing.afterMove ? lastAction : null),
        ret,
        lastAction,
        loc: loc,
      );

      if (phase is TurnEffectAction) {
        alreadyActioned[phase.playerType] = true;
        if (phase.type == TurnActionType.move &&
            (phase.getChangePokemonIndex(PlayerType.me) != null ||
                phase.getChangePokemonIndex(PlayerType.opponent) != null)) {
          needChangeActionProcess = true;
        }
      }
      if (phase.isOwnFainting) {
        alreadyActioned[PlayerType.me] = true;
      }
      if (phase.isOpponentFainting) {
        alreadyActioned[PlayerType.opponent] = true;
      }
    }

    // 両者の行動が完了している＆ひんし交代の効果が無かった場合
    // ターン終了時処理(共通)を実施する
    if (alreadyActioned[PlayerType.me]! &&
        alreadyActioned[PlayerType.opponent]! &&
        !doneProcessTurnEnd) {
      ret.processTurnEnd(this);
    }
    // 交代を伴うわざ後処理が終わったなら交代処理を行う
    if (needChangeActionProcess) {
      lastAction!.processChangeEffect(ret.getPokemonState(PlayerType.me, null),
          ret.getPokemonState(PlayerType.opponent, null), ret);
      needChangeActionProcess = false;
    }

    return ret;
  }

  /// 対象プレイヤーの行動直前のフェーズの状態を返す。
  /// phasesに入っている各処理のうち有効な値が入っているphaseのみ処理を適用する。
  /// ※他のphaseState取得系処理とは異なり、交代わざのあとにわざ使用後の効果が無かったとしても交代処理は行う
  /// （行動「直前」の状態を返す＝交代処理は終わっている）
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
    TurnEffectAction? lastAction;
    int endIndex = phases.getLatestActionIndex(playerType);
    bool needChangeActionProcess = false;

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
      // 交代を伴うわざ後処理が終わったなら交代処理を行う
      // ※lastActionを代入する前に処理する
      if (needChangeActionProcess && phase.timing != Timing.afterMove) {
        lastAction!.processChangeEffect(
            ret.getPokemonState(PlayerType.me, null),
            ret.getPokemonState(PlayerType.opponent, null),
            ret);
        needChangeActionProcess = false;
      }
      if (phase is TurnEffectAction) lastAction = phase;
      /*
      ※どちらかの行動直前のstateを取得するので、これは不要
      // 両者の行動が完了している＆ひんし交代の効果が初めて出現したなら
      // ターン終了時処理(共通)を実施する
      if (alreadyActioned[PlayerType.me]! &&
          alreadyActioned[PlayerType.opponent]! &&
          phase is TurnEffectChangeFaintingPokemon &&
          !doneProcessTurnEnd) {
        ret.processTurnEnd(this);
        doneProcessTurnEnd = true;
      }
      */
      // 効果を処理する
      phase.processEffect(
        ownParty,
        ret.getPokemonState(PlayerType.me,
            phase.timing == Timing.afterMove ? lastAction : null),
        opponentParty,
        ret.getPokemonState(PlayerType.opponent,
            phase.timing == Timing.afterMove ? lastAction : null),
        ret,
        lastAction,
        loc: loc,
      );

      if (phase is TurnEffectAction &&
          phase.type == TurnActionType.move &&
          (phase.getChangePokemonIndex(PlayerType.me) != null ||
              phase.getChangePokemonIndex(PlayerType.opponent) != null)) {
        needChangeActionProcess = true;
      }
    }
    // 交代を伴うわざ後処理が終わったなら交代処理を行う
    if (needChangeActionProcess) {
      lastAction!.processChangeEffect(ret.getPokemonState(PlayerType.me, null),
          ret.getPokemonState(PlayerType.opponent, null), ret);
      needChangeActionProcess = false;
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
    TurnEffectAction? lastAction;
    Map<PlayerType, bool> alreadyActioned = {
      PlayerType.me: false,
      PlayerType.opponent: false,
    };

    int i = 0;
    bool doneProcessTurnEnd = false;
    bool needChangeActionProcess = false;
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
      // 交代を伴うわざ後処理が終わったなら交代処理を行う
      // ※lastActionを代入する前に処理する
      if (needChangeActionProcess && phase.timing != Timing.afterMove) {
        lastAction!.processChangeEffect(
            _endingState.getPokemonState(PlayerType.me, null),
            _endingState.getPokemonState(PlayerType.opponent, null),
            _endingState);
        needChangeActionProcess = false;
      }
      if (phase is TurnEffectAction) lastAction = phase;
      // 両者の行動が完了している＆ひんし交代の効果が初めて出現したなら
      // ターン終了時処理(共通)を実施する
      if (alreadyActioned[PlayerType.me]! &&
          alreadyActioned[PlayerType.opponent]! &&
          phase is TurnEffectChangeFaintingPokemon &&
          !doneProcessTurnEnd) {
        _endingState.processTurnEnd(this);
        doneProcessTurnEnd = true;
      }
      // 効果を処理する
      final guides = phase.processEffect(
        ownParty,
        _endingState.getPokemonState(PlayerType.me,
            phase.timing == Timing.afterMove ? lastAction : null),
        opponentParty,
        _endingState.getPokemonState(PlayerType.opponent,
            phase.timing == Timing.afterMove ? lastAction : null),
        _endingState,
        lastAction,
        loc: loc,
      );
      // 効果によって確定できる事項をstate等に反映する
      for (final guide in guides) {
        guide.processEffect(
            _endingState.getPokemonState(PlayerType.me, null),
            _endingState.getPokemonState(PlayerType.opponent, null),
            _endingState);
      }

      if (phase is TurnEffectAction) {
        alreadyActioned[phase.playerType] = true;
        if (phase.type == TurnActionType.move &&
            (phase.getChangePokemonIndex(PlayerType.me) != null ||
                phase.getChangePokemonIndex(PlayerType.opponent) != null)) {
          needChangeActionProcess = true;
        }
      }
      if (phase.isOwnFainting) {
        alreadyActioned[PlayerType.me] = true;
      }
      if (phase.isOpponentFainting) {
        alreadyActioned[PlayerType.opponent] = true;
      }
      i++;
    }
    // 両者の行動が完了している＆ひんし交代の効果が無かった場合
    // ターン終了時処理(共通)を実施する
    if (alreadyActioned[PlayerType.me]! &&
        alreadyActioned[PlayerType.opponent]! &&
        !doneProcessTurnEnd) {
      _endingState.processTurnEnd(this);
    }
    // 交代を伴うわざ後処理が終わったなら交代処理を行う
    if (needChangeActionProcess) {
      lastAction!.processChangeEffect(
          _endingState.getPokemonState(PlayerType.me, null),
          _endingState.getPokemonState(PlayerType.opponent, null),
          _endingState);
      needChangeActionProcess = false;
    }
    return _endingState.copy();
  }

  /// TODO:関数コメント
  /// 現在のフェーズの状態で起こる効果の候補を返す
  /// 効果->挿入可能インデックスのMapを返す
  /// ```
  /// ```
  Map<TurnEffect, Set<int>> getEffectCandidates(
    PlayerType? playerType,
    EffectType? effectType,
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
    int turnNum,
  ) {
    Map<TurnEffect, Set<int>> ret = {};
    PhaseState state = copyInitialState();
    TurnEffectAction? lastAction;

    for (int i = 0; i <= phases.length; i++) {
      List<TurnEffect> effectList = [];
      final timingList = phases.insertableTimings(i, turnNum, this);
      if (i != 0) {
        final currentEffect = phases[i - 1];
        //if (effect.isAdding) continue;
        //if (effect.timing == Timing.continuousMove) {
        //  lastAction = effect;
        //  continousCount++;
        //} else if (effect.timing == Timing.action) {
        //  lastAction = effect;
        //  continousCount = 0;
        //}
        if (currentEffect is TurnEffectAction) lastAction = currentEffect;
        currentEffect.processEffect(
          ownParty,
          state.getPokemonState(PlayerType.me,
              /*effect.timing == Timing.afterMove ? lastAction :*/ null),
          opponentParty,
          state.getPokemonState(PlayerType.opponent,
              /*effect.timing == Timing.afterMove ? lastAction :*/ null),
          state,
          lastAction,
          loc: loc,
        );
      }
      for (final timing in timingList) {
        if (playerType != null) {
          effectList.addAll(_getEffectCandidates(
            timing,
            i,
            playerType,
            effectType,
            state,
          ));
        } else {
          effectList.addAll(_getEffectCandidates(
            timing,
            i,
            PlayerType.me,
            effectType,
            state,
          ));
          effectList.addAll(_getEffectCandidates(
            timing,
            i,
            PlayerType.opponent,
            effectType,
            state,
          ));
          effectList.addAll(_getEffectCandidates(
            timing,
            i,
            PlayerType.entireField,
            effectType,
            state,
          ));
        }
      }
      for (final effect in effectList) {
        if (ret.containsKey(effect)) {
          ret[effect]!.add(i);
        } else {
          ret[effect] = {i};
        }
      }
    }
    return ret;
  }

  /// TODO:関数コメント
  /// 現在のフェーズの状態で起こる効果の候補を返す
  /// 効果->挿入可能インデックスのMapを返す
  /// ```
  /// ```
  List<TurnEffect> getEffectCandidatesWithPhaseIdx(
    PlayerType? playerType,
    EffectType? effectType,
    Party ownParty,
    Party opponentParty,
    PhaseState phaseState,
    AppLocalizations loc,
    int turnNum,
    int phaseIdx,
  ) {
    List<TurnEffect> effectList = [];

    /// 対象プレイヤーのポケモンが登場したときかどうか
    /// (Timing.pokemonAppearであってもどちらのポケモン登場時かわからないため、判定する)
    bool isAppearingPokemon(PlayerType player, PhaseState state, int num) {
      // 1ターン目の最初ならtrue
      if (num == 1) {
        bool isAppear = true;
        for (int i = 0; i < phaseIdx && i < phases.length; i++) {
          if (phases[i].timing != Timing.pokemonAppear) {
            isAppear = false;
            break;
          }
        }
        if (isAppear) return true;
      }
      // ターン最初と違うポケモンならtrue
      if (state.getPokemonIndex(player, null) !=
          getInitialPokemonIndex(player)) {
        return true;
      }
      return false;
    }

    final timingList = phases.insertableTimings(phaseIdx, turnNum, this);
    for (final timing in timingList) {
      if (playerType != null) {
        effectList.addAll(_getEffectCandidates(
          timing,
          phaseIdx,
          playerType,
          effectType,
          phaseState,
        ));
        // プレイヤーの指定がない場合は、すべてのプレイヤーを対象に効果を追加する
      } else {
        if (timing != Timing.pokemonAppear ||
            isAppearingPokemon(PlayerType.me, phaseState, turnNum)) {
          effectList.addAll(_getEffectCandidates(
            timing,
            phaseIdx,
            PlayerType.me,
            effectType,
            phaseState,
          ));
        }
        if (timing != Timing.pokemonAppear ||
            isAppearingPokemon(PlayerType.opponent, phaseState, turnNum)) {
          effectList.addAll(_getEffectCandidates(
            timing,
            phaseIdx,
            PlayerType.opponent,
            effectType,
            phaseState,
          ));
        }
        effectList.addAll(_getEffectCandidates(
          timing,
          phaseIdx,
          PlayerType.entireField,
          effectType,
          phaseState,
        ));
      }
    }

    return effectList.toSet().toList();
  }

  List<TurnEffect> _getEffectCandidates(
    Timing timing,
    int phaseIdx,
    PlayerType playerType,
    EffectType? effectType,
    PhaseState phaseState,
  ) {
    if (playerType == PlayerType.none) return [];

    // prevActionを設定
    TurnEffectAction? prevAction;
    if (timing == Timing.afterMove) {
      for (int i = phaseIdx - 1; i >= 0; i--) {
        if (phases[i] is TurnEffectAction) {
          prevAction = phases[i] as TurnEffectAction;
          break;
        } else if (phases[i].timing != timing) {
          break;
        }
      }
    } else if (timing == Timing.beforeMove) {
      for (int i = phaseIdx; i < phases.length; i++) {
        if (phases[i] is TurnEffectAction) {
          prevAction = phases[i] as TurnEffectAction;
          break;
        } else if (phases[i].timing != timing) {
          break;
        }
      }
    }
    List<PlayerType> attackers = prevAction != null && prevAction.isValid()
        ? [prevAction.playerType]
        : [PlayerType.me, PlayerType.opponent];
    // TODO?
    //TurnMove turnMove =
    //    prevAction?.move != null ? prevAction!.move : TurnMove();
    final turnMove = prevAction ?? TurnEffectAction(player: playerType);

    if (playerType == PlayerType.entireField) {
      return _getEffectCandidatesWithEffectType(timing, playerType,
          EffectType.ability, attackers[0], turnMove, prevAction, phaseState);
    }
    List<TurnEffect> ret = [];
    for (final attacker in attackers) {
      if (effectType == null) {
        ret.addAll(_getEffectCandidatesWithEffectType(timing, playerType,
            EffectType.ability, attacker, turnMove, prevAction, phaseState));
        ret.addAll(_getEffectCandidatesWithEffectType(timing, playerType,
            EffectType.item, attacker, turnMove, prevAction, phaseState));
        ret.addAll(_getEffectCandidatesWithEffectType(
            timing,
            playerType,
            EffectType.individualField,
            attacker,
            turnMove,
            prevAction,
            phaseState));
        ret.addAll(_getEffectCandidatesWithEffectType(timing, playerType,
            EffectType.ailment, attacker, turnMove, prevAction, phaseState));
      } else {
        ret.addAll(_getEffectCandidatesWithEffectType(timing, playerType,
            effectType, attacker, turnMove, prevAction, phaseState));
      }
    }
    return ret;
  }

  List<TurnEffect> _getEffectCandidatesWithEffectType(
    Timing timing,
    PlayerType playerType,
    EffectType effectType,
    PlayerType attacker,
    TurnEffectAction turnMove,
    TurnEffectAction? prevAction,
    PhaseState phaseState,
  ) {
    return TurnEffect.getPossibleEffects(
        timing,
        playerType,
        effectType,
        playerType == PlayerType.me || playerType == PlayerType.opponent
            ? phaseState.getPokemonState(playerType, prevAction).pokemon
            : null,
        playerType == PlayerType.me || playerType == PlayerType.opponent
            ? phaseState.getPokemonState(playerType, prevAction)
            : null,
        phaseState,
        attacker,
        turnMove,
        this,
        prevAction);
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
    // canZorua
    ret.canZorua = turnElements.removeAt(0) == '1';
    // canZoroark
    ret.canZoroark = turnElements.removeAt(0) == '1';
    // canZoruaHisui
    ret.canZoruaHisui = turnElements.removeAt(0) == '1';
    // canZoroarkHisui
    ret.canZoroarkHisui = turnElements.removeAt(0) == '1';

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
    ret += split1;
    // canZorua
    ret += canZorua ? '1' : '0';
    ret += split1;
    // canZoroark
    ret += canZoroark ? '1' : '0';
    ret += split1;
    // canZoruaHisui
    ret += canZoruaHisui ? '1' : '0';
    ret += split1;
    // canZoroarkHisui
    ret += canZoroarkHisui ? '1' : '0';

    return ret;
  }
}
