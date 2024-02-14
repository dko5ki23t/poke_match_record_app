import 'dart:collection';

import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
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
import 'package:poke_reco/data_structs/turn_effect/turn_effect_terastal.dart';
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
      l.insert(insertIndex,
          TurnEffectTerastal(playerType: playerType, teraType: type));
    } else {
      l.remove(terastal.first);
    }
  }

  /// 指定したインデックスに挿入可能なタイミングのリストを返す
  /// ```
  /// index: 挿入するインデックス
  /// turnNum: 現在のターン数
  /// currentTurn: 現在のターン
  /// ```
  List<Timing> insertableTimings(int index, int turnNum, Turn currentTurn) {
    Set<Timing> ret = {};
    int s1 = turnNum == 1 ? 0 : 1; // 試合最初のポケモン登場時処理状態
    int s2 = 0; // どちらもひんしでない状態
    int end = 100;
    int i = 0;
    int actionCount = 0;
    int terastalCount = 0;
    int maxTerastal = 0;
    if (!currentTurn.initialOwnHasTerastal) maxTerastal++;
    if (!currentTurn.initialOpponentHasTerastal) maxTerastal++;
    const Map<int, Timing> s1TimingMap = {
      0: Timing.pokemonAppear,
      1: Timing.afterActionDecision,
      2: Timing.action,
      3: Timing.pokemonAppear,
      4: Timing.afterMove,
      6: Timing.afterMove,
      7: Timing.changePokemonMove,
      8: Timing.everyTurnEnd,
      9: Timing.gameSet,
      10: Timing.terastaling,
      11: Timing.afterTerastal,
      12: Timing.beforeMove,
    };
    const Map<int, Timing> s2TimingMap = {
      1: Timing.afterMove,
      2: Timing.changeFaintingPokemon,
      3: Timing.pokemonAppear,
      4: Timing.changeFaintingPokemon,
      5: Timing.pokemonAppear,
      6: Timing.changeFaintingPokemon,
      7: Timing.changeFaintingPokemon,
    };
    Timing currentTiming = s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
    bool changingState = false; // 効果によってポケモン交代した状態
    bool isOwnFainting = false;
    bool isOpponentFainting = false;

    while (s1 != end) {
      currentTiming = changingState
          ? Timing.pokemonAppear
          : s2 == 0
              ? s1TimingMap[s1]!
              : s2TimingMap[s2]!;
      ret.add(currentTiming);
      bool toNext = false;
      if (changingState) {
        // ポケモン交代後状態
        if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
          changingState = false;
        } else {
          // TODO?
          toNext = true;
        }
      } else {
        switch (s2) {
          case 1: // わざでひんし状態
            if (i >= l.length || l[i].timing != Timing.afterMove) {
              s2++; // わざでひんし交代状態へ
            } else {
              toNext = true;
            }
            break;
          case 2: // わざでひんし交代状態
            {
              if (i >= l.length ||
                  l[i].runtimeType != TurnEffectChangeFaintingPokemon) {
                // ありえない？
                if (isOwnFainting) {
                  isOwnFainting = false;
                  if (!isOpponentFainting) {
                    s2 = 0;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  } else {
                    s2 = 6; // わざでひんし交代状態(2匹目)へ
                  }
                } else if (isOpponentFainting) {
                  s2 = 0;
                  if (actionCount == 2) {
                    s1 = 8; // ターン終了状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                }
              } else {
                toNext = true;
                if (isOwnFainting) {
                  isOwnFainting = false;
                } else if (isOpponentFainting) {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2++; // わざでひんし交代後状態へ
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  } else {
                    s2 = 6; // わざでひんし交代状態(2匹目)へ
                  }
                }
              }
            }
            break;
          case 3: // わざでひんし交代後状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              if (!isOpponentFainting) {
                s2 = 0;
                if (actionCount == 2) {
                  s1 = 8; // ターン終了状態へ
                } else {
                  s1 = 12; // 行動選択前状態へ
                }
              } else {
                s2 = 2; // わざでひんし交代状態へ
              }
            } else {
              toNext = true;
            }
            break;
          case 4: // わざ以外でひんし状態
            {
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon) {
                // ありえない？
                if (isOwnFainting) {
                  isOwnFainting = false;
                  if (!isOpponentFainting) {
                    s2 = 0;
                  } else {
                    s2 = 7; // わざ以外でひんし状態(2匹目)へ
                  }
                } else if (isOpponentFainting) {
                  isOpponentFainting = false;
                  s2 = 0;
                }
              } else if (l[i].timing == Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  isOwnFainting = false;
                } else if (isOpponentFainting) {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  toNext = true;
                  s2++; // わざ以外でひんし交代後状態へ
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                  } else {
                    s2 = 7; // わざ以外でひんし状態(2匹目)へ
                  }
                }
              }
            }
            break;
          case 5: // わざ以外でひんし交代後状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              if (!isOpponentFainting) {
                s2 = 0;
              } else {
                s2 = 4; // わざ以外でひんし状態へ
              }
            } else {
              toNext = true;
            }
            break;
          case 6: // わざでひんし交代状態(2匹目)
            {
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && l[i].playerType == PlayerType.me)) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  s2 = 0;
                  s1 = 8; // ターン終了状態へ
                }
              } else {
                toNext = true;
                if (l[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                } else {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2 = 3; // わざでひんし交代後状態へ
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                    s1 = 8; // ターン終了状態へ
                  }
                }
              }
            }
            break;
          case 7: // わざ以外でひんし状態(2匹目)
            {
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && l[i].playerType == PlayerType.me)) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  s2 = 0;
                }
              } else {
                toNext = true;
                if (l[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                } else {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2 = 5; // わざ以外でひんし交代後状態へ
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                  }
                }
              }
            }
            break;
          case 0: // どちらもひんしでない状態
            switch (s1) {
              case 0: // 試合最初のポケモン登場時処理状態
                if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
                  s1++; // 行動決定直後処理状態へ
                  //timingListIdx++;
                } else {
                  toNext = true;
                }
                break;
              case 1: // 行動決定直後処理状態
                if (i >= l.length ||
                    l[i].timing != Timing.afterActionDecision) {
                  if (maxTerastal > 0) {
                    s1 = 10; // テラスタル処理状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                } else {
                  toNext = true;
                }
                break;
              case 10: // テラスタル処理状態
                if (i >= l.length || l[i].timing != Timing.terastaling) {
                  s1 = 11; // テラスタル後状態へ
                } else {
                  toNext = true;
                }
                terastalCount++;
                if (terastalCount >= maxTerastal) {
                  s1 = 11; // テラスタル後状態へ
                }
                break;
              case 11: // テラスタル後状態
                if (i >= l.length || l[i].timing != Timing.afterTerastal) {
                  s1 = 12; // 行動選択前状態へ
                } else {
                  toNext = true;
                }
                break;
              case 12: // 行動選択前状態
                if (i >= l.length || l[i].timing != Timing.beforeMove) {
                  s1 = 2; // 行動選択状態へ
                } else {
                  toNext = true;
                }
                break;
              case 2: // 行動選択状態
                {
                  actionCount++;
                  if (i >= l.length || l[i].runtimeType != TurnEffectAction) {
                    // TODO:ありえない？
                  } else {
                    // TODO?
                    toNext = true;
                    final action = l[i] as TurnEffectAction;
                    if (!action.isValid() ||
                        action.type == TurnActionType.surrender) {
                      if (actionCount == 2) {
                        s1 = 8; // ターン終了状態へ
                      } else {
                        s1 = 12; // 行動選択前状態へ
                      }
                    } else if (action.type == TurnActionType.move) {
                      if (action.getChangePokemonIndex(PlayerType.me) != null ||
                          action.getChangePokemonIndex(PlayerType.opponent) !=
                              null) {
                        // わざが失敗/命中していなければポケモン交代も発生しない
                        if (!action.isNormallyHit()) {
                          s1 = 4; // わざ使用後状態へ
                        } else {
                          s1 = 6; // 交代わざ使用後状態へ
                        }
                      } else {
                        s1 = 4; // わざ使用後状態へ
                      }
                    } else if (action
                            .getChangePokemonIndex(action.playerType) !=
                        null) {
                      s1++; // ポケモン交代後状態へ
                    }
                  }
                }
                break;
              case 3: // ポケモン交代後状態
                if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
                  if (actionCount == 2) {
                    s1 = 8; // ターン終了状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                } else {
                  toNext = true;
                }
                break;
              case 4: // わざ使用後状態
                if (i >= l.length || l[i].timing != Timing.afterMove) {
                  if (actionCount == 2) {
                    s1 = 8; // ターン終了状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                } else {
                  toNext = true;
                  if (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                      l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
                    // 効果によりポケモン交代が生じた場合
                    changingState = true;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  }
                }
                break;
              case 6: // 交代わざ使用後状態
                if (i >= l.length || l[i].timing != Timing.afterMove) {
                  s1 = 3; // ポケモン交代後状態へ
                } else {
                  toNext = true;
                }
                break;
              case 8: // ターン終了状態
                if (i >= l.length || l[i].timing != Timing.everyTurnEnd) {
                  s1 = end;
                } else {
                  toNext = true;
                }
                break;
              case 9: // 試合終了状態
                s1 = end;
                break;
            }
            break;
        }
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
  void adjust(
    bool isNewTurn,
    int turnNum,
    Turn currentTurn,
    Party ownParty,
    Party opponentParty,
    AppLocalizations loc,
  ) {
    //_clearAddingPhase(appState);      // 一旦、追加用のフェーズは削除する
    int beginIdx = 0;
    Timing timing = Timing.none;
    //List<List<TurnEffectAndStateAndGuide>> ret = [];
    //List<TurnEffectAndStateAndGuide> turnEffectAndStateAndGuides = [];
    //Turn currentTurn = widget.battle.turns[turnNum - 1];
    PhaseState currentState = currentTurn.copyInitialState();
    int s1 = turnNum == 1 ? 0 : 1; // 試合最初のポケモン登場時処理状態
    int s2 = 0; // どちらもひんしでない状態
    int end = 100;
    int i = 0;
    int actionCount = 0;
    int terastalCount = 0;
    int maxTerastal = 0;
    if (!currentTurn.initialOwnHasTerastal) maxTerastal++;
    if (!currentTurn.initialOpponentHasTerastal) maxTerastal++;
    bool isOwnFainting = false;
    bool isOpponentFainting = false;
    bool isMyWin = false;
    bool isYourWin = false;
    bool changeOwn = turnNum == 1;
    bool changeOpponent = turnNum == 1;
    const Map<int, Timing> s1TimingMap = {
      0: Timing.pokemonAppear,
      1: Timing.afterActionDecision,
      2: Timing.action,
      3: Timing.pokemonAppear,
      4: Timing.afterMove,
      6: Timing.afterMove,
      7: Timing.changePokemonMove,
      8: Timing.everyTurnEnd,
      9: Timing.gameSet,
      10: Timing.terastaling,
      11: Timing.afterTerastal,
      12: Timing.beforeMove,
    };
    const Map<int, Timing> s2TimingMap = {
      1: Timing.afterMove,
      2: Timing.changeFaintingPokemon,
      3: Timing.pokemonAppear,
      4: Timing.changeFaintingPokemon,
      5: Timing.pokemonAppear,
      6: Timing.changeFaintingPokemon,
      7: Timing.changeFaintingPokemon,
    };
    int timingListIdx = 0;
    Timing currentTiming = s2 == 0 ? s1TimingMap[s1]! : s2TimingMap[s2]!;
    List<TurnEffect> assistList = [];
    //List<TurnEffect> delAssistList = [];
    PlayerType? firstActionPlayer;
    TurnEffectAction? lastAction;
    bool changingState = false; // 効果によってポケモン交代した状態
    bool isAssisting = false;
    // 自動入力リスト作成
    if (isNewTurn) {
      assistList = currentState.getDefaultEffectList(
        currentTurn,
        currentTiming,
        changeOwn,
        changeOpponent,
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

    while (s1 != end) {
      currentTiming = changingState
          ? Timing.pokemonAppear
          : s2 == 0
              ? s1TimingMap[s1]!
              : s2TimingMap[s2]!;
      bool isInserted = false;
      if (changingState) {
        // ポケモン交代後状態
        if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
          // 自動追加
          if (assistList.isNotEmpty) {
            l.insert(i, assistList.removeAt(0));
            isAssisting = true;
            isInserted = true;
          } else {
            //isInserted = true;
            timingListIdx++;
            isAssisting = false;
            changingState = false;
          }
        } else {
          isAssisting = true;
        }
      } else {
        switch (s2) {
          case 1: // わざでひんし状態
            if (i >= l.length || l[i].timing != Timing.afterMove) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                s2++; // わざでひんし交代状態へ
                timingListIdx++;
                isAssisting = false;
              }
            } else {
              isAssisting = true;
            }
            break;
          case 2: // わざでひんし交代状態
            {
              changeOwn = changeOpponent = false;
              if (i >= l.length ||
                  l[i].runtimeType != TurnEffectChangeFaintingPokemon) {
                if (isOwnFainting) {
                  isOwnFainting = false;
                  /*_insertPhase(
                      i,
                      TurnEffect()
                        ..playerType = PlayerType.me
                        ..effectType = EffectType.changeFaintingPokemon
                        ..timing = Timing.changeFaintingPokemon,
                      appState);*/
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.me,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  if (!isOpponentFainting) {
                    s2 = 0;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  } else {
                    s2 = 6; // わざでひんし交代状態(2匹目)へ
                  }
                } else if (isOpponentFainting) {
                  isOpponentFainting = false;
                  /*_insertPhase(
                      i,
                      TurnEffect()
                        ..playerType = PlayerType.opponent
                        ..effectType = EffectType.changeFaintingPokemon
                        ..timing = Timing.changeFaintingPokemon,
                      appState);*/
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.opponent,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  s2 = 0;
                  if (actionCount == 2) {
                    s1 = 8; // ターン終了状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                }
              } else {
                if (isOwnFainting) {
                  l[i].playerType = PlayerType.me;
                  isOwnFainting = false;
                } else if (isOpponentFainting) {
                  l[i].playerType = PlayerType.opponent;
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2++; // わざでひんし交代後状態へ
                  if (l[i].playerType == PlayerType.me) {
                    changeOwn = true;
                  } else {
                    changeOpponent = true;
                  }
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  } else {
                    s2 = 6; // わざでひんし交代状態(2匹目)へ
                  }
                }
              }
              timingListIdx++;
            }
            break;
          case 3: // わざでひんし交代後状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                timingListIdx++;
                isAssisting = false;
                if (!isOpponentFainting) {
                  changeOwn = false;
                  changeOpponent = false;
                  s2 = 0;
                  if (actionCount == 2) {
                    s1 = 8; // ターン終了状態へ
                  } else {
                    s1 = 12; // 行動選択前状態へ
                  }
                } else {
                  s2 = 2; // わざでひんし交代状態へ
                }
              }
            } else {
              isAssisting = true;
            }
            break;
          case 4: // わざ以外でひんし状態
            {
              changeOwn = changeOpponent = false;
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  isOwnFainting = false;
                  /*_insertPhase(
                      i,
                      TurnEffect()
                        ..playerType = PlayerType.me
                        ..effectType = EffectType.changeFaintingPokemon
                        ..timing = Timing.changeFaintingPokemon,
                      appState);*/
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.me,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  if (!isOpponentFainting) {
                    s2 = 0;
                  } else {
                    s2 = 7; // わざ以外でひんし状態(2匹目)へ
                  }
                } else if (isOpponentFainting) {
                  isOpponentFainting = false;
                  /*_insertPhase(
                      i,
                      TurnEffect()
                        ..playerType = PlayerType.opponent
                        ..effectType = EffectType.changeFaintingPokemon
                        ..timing = Timing.changeFaintingPokemon,
                      appState);*/
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.opponent,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  s2 = 0;
                }
              } else if (l[i].timing == Timing.changeFaintingPokemon) {
                if (isOwnFainting) {
                  l[i].playerType = PlayerType.me;
                  isOwnFainting = false;
                } else if (isOpponentFainting) {
                  l[i].playerType = PlayerType.opponent;
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2++; // わざ以外でひんし交代後状態へ
                  if (l[i].playerType == PlayerType.me) {
                    changeOwn = true;
                  } else {
                    changeOpponent = true;
                  }
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                  } else {
                    s2 = 7; // わざ以外でひんし状態(2匹目)へ
                  }
                }
              }
              timingListIdx++;
            }
            break;
          case 5: // わざ以外でひんし交代後状態
            if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
              // 自動追加
              if (assistList.isNotEmpty) {
                l.insert(i, assistList.removeAt(0));
                isAssisting = true;
                isInserted = true;
              } else {
                //isInserted = true;
                timingListIdx++;
                isAssisting = false;
                if (!isOpponentFainting) {
                  changeOwn = false;
                  changeOpponent = false;
                  s2 = 0;
                } else {
                  s2 = 4; // わざ以外でひんし状態へ
                }
              }
            } else {
              isAssisting = true;
            }
            break;
          case 6: // わざでひんし交代状態(2匹目)
            {
              changeOwn = changeOpponent = false;
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && l[i].playerType == PlayerType.me)) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.opponent,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  s2 = 0;
                  s1 = 8; // ターン終了状態へ
                }
              } else {
                if (l[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                } else {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2 = 3; // わざでひんし交代後状態へ
                  if (l[i].playerType == PlayerType.me) {
                    changeOwn = true;
                  } else {
                    changeOpponent = true;
                  }
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                    s1 = 8; // ターン終了状態へ
                  }
                }
              }
              timingListIdx++;
            }
            break;
          case 7: // わざ以外でひんし状態(2匹目)
            {
              changeOwn = changeOpponent = false;
              if (i >= l.length ||
                  l[i].timing != Timing.changeFaintingPokemon ||
                  (isOpponentFainting && l[i].playerType == PlayerType.me)) {
                if (isOpponentFainting) {
                  isOpponentFainting = false;
                  // TODO:タイミングの設定必要？
                  l.insert(
                      i,
                      TurnEffectChangeFaintingPokemon(
                          player: PlayerType.opponent,
                          timing: Timing.changeFaintingPokemon));
                  isInserted = true;
                  s2 = 0;
                }
              } else {
                if (l[i].playerType == PlayerType.me) {
                  isOwnFainting = false;
                } else {
                  isOpponentFainting = false;
                }
                if (l[i].isValid()) {
                  s2 = 5; // わざ以外でひんし交代後状態へ
                  if (l[i].playerType == PlayerType.me) {
                    changeOwn = true;
                  } else {
                    changeOpponent = true;
                  }
                } else {
                  if (!isOpponentFainting) {
                    s2 = 0;
                  }
                }
              }
              timingListIdx++;
            }
            break;
          case 0: // どちらもひんしでない状態
            switch (s1) {
              case 0: // 試合最初のポケモン登場時処理状態
                if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    s1++; // 行動決定直後処理状態へ
                    timingListIdx++;
                    isAssisting = false;
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 1: // 行動決定直後処理状態
                if (i >= l.length ||
                    l[i].timing != Timing.afterActionDecision) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    if (maxTerastal > 0) {
                      s1 = 10; // テラスタル処理状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                    timingListIdx++;
                    isAssisting = false;
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 10: // テラスタル処理状態
                if (i >= l.length || l[i].timing != Timing.terastaling) {
                  //isInserted = true;
                  s1 = 11; // テラスタル後状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
                terastalCount++;
                if (terastalCount >= maxTerastal) {
                  s1 = 11; // テラスタル後状態へ
                  timingListIdx++;
                  isAssisting = false;
                }
                break;
              case 11: // テラスタル後状態
                if (i >= l.length || l[i].timing != Timing.afterTerastal) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    s1 = 12; // 行動選択前状態へ
                    timingListIdx++;
                    isAssisting = false;
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 12: // 行動選択前状態
                if (i >= l.length || l[i].timing != Timing.beforeMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    s1 = 2; // 行動選択状態へ
                    timingListIdx++;
                    isAssisting = false;
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 2: // 行動選択状態
                {
                  // TODO
                  //_clearInvalidPhase(appState, i, true, true);
                  changeOwn = changeOpponent = false;
                  actionCount++;
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
                  } else {
                    // TODO?
                    isInserted = true;
                    final action = l[i] as TurnEffectAction;
                    if (!action.isValid() ||
                        action.type == TurnActionType.surrender) {
                      if (actionCount == 2) {
                        s1 = 8; // ターン終了状態へ
                      } else {
                        s1 = 12; // 行動選択前状態へ
                      }
                    } else if (action.type == TurnActionType.move) {
                      if (action.getChangePokemonIndex(PlayerType.me) != null ||
                          action.getChangePokemonIndex(PlayerType.opponent) !=
                              null) {
                        // わざが失敗/命中していなければポケモン交代も発生しない
                        if (!action.isNormallyHit()) {
                          s1 = 4; // わざ使用後状態へ
                        } else {
                          changeOwn =
                              action.getChangePokemonIndex(PlayerType.me) !=
                                  null;
                          changeOpponent = action
                                  .getChangePokemonIndex(PlayerType.opponent) !=
                              null;
                          s1 = 6; // 交代わざ使用後状態へ
                        }
                      } else {
                        s1 = 4; // わざ使用後状態へ
                      }
                    } else if (action
                            .getChangePokemonIndex(action.playerType) !=
                        null) {
                      s1++; // ポケモン交代後状態へ
                      if (action.playerType == PlayerType.me) {
                        changeOwn = true;
                      } else {
                        changeOpponent = true;
                      }
                    }
                  }
                  // 行動主の自動選択
                  /*if (firstActionPlayer == null) {
                    // 1つ目の行動
                    if (l[i].playerType != PlayerType.none) {
                      // 1つ目の行動主が入力されているなら
                      firstActionPlayer = l[i].playerType;
                      if (!l[i].isValid()) {
                        // 行動主が入力されているが、入力された行動がまだ有効でないとき
                        // 自動補完
                        l[i].move!.fillAuto(currentState);
                        textEditingControllerList1[i].text =
                            l[i].getEditingControllerText1();
                        textEditingControllerList2[i].text = l[i]
                            .getEditingControllerText2(
                                currentState, lastAction);
                        textEditingControllerList3[i].text = l[i]
                            .getEditingControllerText3(
                                currentState, lastAction);
                        textEditingControllerList4[i].text =
                            l[i].getEditingControllerText4(currentState);
                      }
                    } else {
                      TurnMove tmp = TurnMove()
                        ..playerType = PlayerType.me
                        ..type = TurnMoveType(TurnMoveType.move);
                      if (tmp.fillAuto(currentState)) {
                        l[i].playerType = PlayerType.me;
                        firstActionPlayer = l[i].playerType;
                        l[i].move = tmp;
                        textEditingControllerList1[i].text =
                            l[i].getEditingControllerText1();
                        textEditingControllerList2[i].text = l[i]
                            .getEditingControllerText2(
                                currentState, lastAction);
                        textEditingControllerList3[i].text = l[i]
                            .getEditingControllerText3(
                                currentState, lastAction);
                        textEditingControllerList4[i].text =
                            l[i].getEditingControllerText4(currentState);
                      } else {
                        tmp = TurnMove()
                          ..playerType = PlayerType.opponent
                          ..type = TurnMoveType(TurnMoveType.move);
                        if (tmp.fillAuto(currentState)) {
                          l[i].playerType = PlayerType.opponent;
                          firstActionPlayer = l[i].playerType;
                          l[i].move = tmp;
                          textEditingControllerList1[i].text =
                              l[i].getEditingControllerText1();
                          textEditingControllerList2[i].text = l[i]
                              .getEditingControllerText2(
                                  currentState, lastAction);
                          textEditingControllerList3[i].text = l[i]
                              .getEditingControllerText3(
                                  currentState, lastAction);
                          textEditingControllerList4[i].text =
                              l[i].getEditingControllerText4(currentState);
                        }
                      }
                    }
                  } else if (l[i].playerType == PlayerType.none) {
                    // 2つ目の行動主が未入力の場合
                    l[i].playerType = firstActionPlayer.opposite;
                    if (l[i].move != null) {
                      l[i].move!.clear();
                      l[i].move!.playerType = firstActionPlayer.opposite;
                      l[i].move!.type = TurnMoveType(TurnMoveType.move);
                      l[i].move!.fillAuto(currentState);
                      textEditingControllerList1[i].text =
                          l[i].getEditingControllerText1();
                      textEditingControllerList2[i].text = l[i]
                          .getEditingControllerText2(currentState, lastAction);
                      textEditingControllerList3[i].text = l[i]
                          .getEditingControllerText3(currentState, lastAction);
                      textEditingControllerList4[i].text =
                          l[i].getEditingControllerText4(currentState);
                    }
                  } else {
                    if (!l[i].isValid()) {
                      // 2つ目の行動主が入力されているが、入力された行動がまだ有効でないとき
                      // 自動補完
                      l[i].move!.fillAuto(currentState);
                      textEditingControllerList1[i].text =
                          l[i].getEditingControllerText1();
                      textEditingControllerList2[i].text = l[i]
                          .getEditingControllerText2(currentState, lastAction);
                      textEditingControllerList3[i].text = l[i]
                          .getEditingControllerText3(currentState, lastAction);
                      textEditingControllerList4[i].text =
                          l[i].getEditingControllerText4(currentState);
                    }
                  }*/
                  lastAction = l[i] as TurnEffectAction;
                  timingListIdx++;
                }
                break;
              case 3: // ポケモン交代後状態
                if (i >= l.length || l[i].timing != Timing.pokemonAppear) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    timingListIdx++;
                    isAssisting = false;
                    changeOwn = false;
                    changeOpponent = false;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 4: // わざ使用後状態
                if (i >= l.length || l[i].timing != Timing.afterMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    timingListIdx++;
                    isAssisting = false;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  }
                } else {
                  isAssisting = true;
                  if (l[i].getChangePokemonIndex(PlayerType.me) != null ||
                      l[i].getChangePokemonIndex(PlayerType.opponent) != null) {
                    // 効果によりポケモン交代が生じた場合
                    changingState = true;
                    if (actionCount == 2) {
                      s1 = 8; // ターン終了状態へ
                    } else {
                      s1 = 12; // 行動選択前状態へ
                    }
                  }
                }
                break;
              case 6: // 交代わざ使用後状態
                if (i >= l.length || l[i].timing != Timing.afterMove) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    timingListIdx++;
                    isAssisting = false;
                    s1 = 3; // ポケモン交代後状態へ
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 8: // ターン終了状態
                if (i >= l.length || l[i].timing != Timing.everyTurnEnd) {
                  // 自動追加
                  if (assistList.isNotEmpty) {
                    l.insert(i, assistList.removeAt(0));
                    isAssisting = true;
                    isInserted = true;
                  } else {
                    //isInserted = true;
                    isAssisting = false;
                    // TODO?
                    //l.removeRange(i + 1, l.length);
                    s1 = end;
                  }
                } else {
                  isAssisting = true;
                }
                break;
              case 9: // 試合終了状態
                // TODO
                /*_insertPhase(
                    i,
                    TurnEffect()
                      ..timing = Timing.gameSet
                      ..isMyWin = isMyWin
                      ..isYourWin = isYourWin,
                    appState);*/
                l.removeRange(i + 1, l.length);
                s1 = end;
                break;
            }
            break;
        }
      }

      if (i >= l.length) break;

      final guides = l[i].processEffect(
        ownParty,
        currentState.getPokemonState(PlayerType.me, null),
        opponentParty,
        currentState.getPokemonState(PlayerType.opponent, null),
        currentState,
        lastAction,
        loc: loc,
      );
      /*
      turnEffectAndStateAndGuides.add(TurnEffectAndStateAndGuide()
        ..phaseIdx = i
        ..turnEffect = l[i]
        ..phaseState = currentState.copy()
        ..guides = guides);
      // 更新要求インデックス以降はフォームの内容を変える
      // 追加されたフェーズのフォームの内容を変える
      if (isInserted ||
          (appState.needAdjustPhases >= 0 && appState.needAdjustPhases <= i)) {
        if (!l[i].isAdding) {
          textEditingControllerList1[i].text = l[i].getEditingControllerText1();
          textEditingControllerList2[i].text =
              l[i].getEditingControllerText2(currentState, lastAction);
          textEditingControllerList3[i].text =
              l[i].getEditingControllerText3(currentState, lastAction);
          textEditingControllerList4[i].text =
              l[i].getEditingControllerText4(currentState);
        }
      }
      */

      if (s1 != end &&
          (!isInserted || isAssisting) &&
          i < l.length &&
          (l[i].isMyWin || l[i].isYourWin)) // どちらかが勝利したら
      {
        isMyWin = l[i].isMyWin;
        isYourWin = l[i].isYourWin;
        s2 = 0;
        s1 = 9; // 試合終了状態へ
      } else {
        if (s1 != end &&
            (!isInserted || isAssisting) &&
            i < l.length &&
            (l[i].isOwnFainting || l[i].isOpponentFainting)) {
          // どちらかがひんしになる場合
          if (l[i].isOwnFainting) isOwnFainting = true;
          if (l[i].isOpponentFainting) isOpponentFainting = true;
          if (s2 == 1 ||
              l[i].timing == Timing.action ||
              l[i].timing == Timing.continuousMove) {
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
            s2 = 1; // わざでひんし状態へ
          } else {
            s2 = 4; // わざ以外でひんし状態へ
          }
        }
      }

      if (i < l.length) i++;

      // 自動入力効果を作成
      // 前回までと違うタイミング、かつ更新要求インデックス以降のとき作成
      if (s1 != end) {
        var nextTiming = changingState
            ? Timing.pokemonAppear
            : s2 == 0
                ? s1TimingMap[s1]!
                : s2TimingMap[s2]!;
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
              if (l[j].timing == Timing.action) {
                if (l[j].isValid() && l[j].runtimeType == TurnEffectAction) {
                  tmpAction = l[j] as TurnEffectAction;
                  break;
                } else {
                  break;
                }
              }
            }
          }
          assistList = currentState.getDefaultEffectList(
            currentTurn,
            nextTiming,
            changeOwn,
            changeOpponent,
            currentState,
            tmpAction,
          );
          for (final effect in currentTurn.noAutoAddEffect) {
            // TODO
            //assistList.removeWhere((e) => effect.nearEqual(e));
            assistList.removeWhere((e) => effect == e);
          }
          // 同じタイミングの先読みをし、既に入力済みで自動入力に含まれるものは除外する
          // それ以外で入力済みの自動入力は削除
          List<int> removeIdxs = [];
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
          changeOwn = false;
          changeOpponent = false;
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
    // TODO:ゾロア系の設定
    //canZorua = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoruaNo).isNotEmpty
    //canZoroark = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoroarkNo).isNotEmpty
    //canZoruaHisui = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoruaHisuiNo).isNotEmpty
    //canZoroarkHisui = opponentParty.pokemons.where((e) => e?.no == PokeBase.zoroarkHisuiNo).isNotEmpty;
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
    TurnEffectAction? lastAction;
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
    TurnEffectAction? lastAction;
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
        if (phases[i].runtimeType == TurnEffectAction) {
          prevAction = phases[i] as TurnEffectAction;
          break;
        } else if (phases[i].timing != timing) {
          break;
        }
      }
    } else if (timing == Timing.beforeMove) {
      for (int i = phaseIdx + 1; i < phases.length; i++) {
        if (phases[i].runtimeType == TurnEffectAction) {
          prevAction = phases[i] as TurnEffectAction;
          break;
        } else if (phases[i].timing != timing) {
          break;
        }
      }
    }
    PlayerType attacker =
        prevAction != null ? prevAction.playerType : PlayerType.none;
    // TODO?
    //TurnMove turnMove =
    //    prevAction?.move != null ? prevAction!.move : TurnMove();
    final turnMove = prevAction ?? TurnEffectAction(player: playerType);

    if (playerType == PlayerType.entireField) {
      return _getEffectCandidatesWithEffectType(timing, playerType,
          EffectType.ability, attacker, turnMove, prevAction, phaseState);
    }
    if (effectType == null) {
      List<TurnEffect> ret = [];
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
      return ret;
    } else {
      return _getEffectCandidatesWithEffectType(timing, playerType, effectType,
          attacker, turnMove, prevAction, phaseState);
    }
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
