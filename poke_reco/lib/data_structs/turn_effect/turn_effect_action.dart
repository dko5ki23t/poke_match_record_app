import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/change_pokemon_command_tile.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/number_input_buttons.dart';
import 'package:poke_reco/custom_widgets/stand_alone_checkbox.dart';
import 'package:poke_reco/custom_widgets/stand_alone_switch_list.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 行動の種類
enum TurnActionType {
  /// なし、無効
  none,

  /// わざ
  move,

  /// ポケモン交代
  change,

  /// こうさん
  surrender,
}

/// わざの命中
enum MoveHit {
  /// 命中
  hit,

  /// 急所
  critical,

  /// 当たらなかった
  notHit,

  /// うまく決まらなかった
  fail,
}

/// 表示名に関するextension
extension MoveHitName on MoveHit {
  /// 表示名
  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        switch (this) {
          case MoveHit.hit:
            return '命中';
          case MoveHit.critical:
            return '急所';
          case MoveHit.notHit:
            return '当たらなかった';
          case MoveHit.fail:
            return 'うまく決まらなかった';
          default:
            return '';
        }
      case Language.english:
      default:
        switch (this) {
          case MoveHit.hit:
            return 'Hit';
          case MoveHit.critical:
            return 'Critical';
          case MoveHit.notHit:
            return 'Missed';
          case MoveHit.fail:
            return 'Failed';
          default:
            return '';
        }
    }
  }
}

/// わざのタイプ相性による効果
enum MoveEffectiveness {
  /// 通常
  normal,

  /// こうかはばつぐんだ
  great,

  /// こうかはいまひとつのようだ
  notGood,

  /// こうかはないようだ
  noEffect,
}

/// わざの追加効果
class MoveAdditionalEffect {
  static const int none = 0;

  const MoveAdditionalEffect(this.id);

  /// ID
  final int id;
}

/// 行動失敗の原因
class ActionFailure extends Equatable {
  /// なし、無効
  static const int none = 0;

  /// わざの反動
  static const int recoil = 1;

  /// ねむり(カウント消費)
  static const int sleep = 2;

  /// こおり(回復判定で失敗)
  static const int freeze = 3;

  /// ひるみ
  static const int flinch = 4;

  /// ちょうはつ (実質不要？)
  static const int taunt = 5;

  /// こんらんにより自傷
  static const int confusion = 6;

  /// まひ
  static const int paralysis = 7;

  /// メロメロ
  static const int infatuation = 8;

  /// 相手にこうげきを防がれた
  static const int protected = 9;

  /// その他
  static const int other = 10;

  /// サイズ
  static const int size = 11;

  static const Map<int, Tuple3<String, String, int>> _displayNamePriorityMap = {
    0: Tuple3('うまく決まらなかった', 'Move is failed', 0),
    1: Tuple3('わざの反動', 'Need recharge of move', 2),
    2: Tuple3('ねむり', 'Sleep', 2),
    3: Tuple3('こおり', 'Freeze', 1),
    4: Tuple3('ひるみ', 'Flinch', 2),
    5: Tuple3('ちょうはつ', 'Taunt', 1),
    6: Tuple3('こんらん', 'Confusion', 1),
    7: Tuple3('まひ', 'Paralysis', 1),
    8: Tuple3('メロメロ', 'Attract', 1),
    9: Tuple3('相手にこうげきを防がれた', 'Prevented', 0),
    10: Tuple3('その他', 'Others', 0),
  };

  /// 表示名
  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNamePriorityMap[id]!.item1;
      case Language.english:
      default:
        return _displayNamePriorityMap[id]!.item2;
    }
  }

  /// 優先度(失敗の原因が複数ある場合にどれを原因とするかを決めるための数値)
  int get priority => _displayNamePriorityMap[id]!.item3;

  const ActionFailure(this.id);

  @override
  List<Object?> get props => [id];

  /// ID
  final int id;
}

/// ダメージの情報を管理するclass
class DamageGetter {
  /// ダメージを表示するかどうか
  bool showDamage = true;

  /// 最小ダメージ
  int minDamage = 0;

  /// 最大ダメージ
  int maxDamage = 0;

  /// 相手最大HPに対する最大ダメージの割合
  int minDamagePercent = 0;

  /// 相手最大HPに対する最小ダメージの割合
  int maxDamagePercent = 0;

  /// ダメージ範囲を表す文字列
  /// ```
  /// [例]168 ~ 200
  /// ```
  String get rangeString {
    if (minDamage == maxDamage) {
      return minDamage.toString();
    } else {
      return '$minDamage ~ $maxDamage';
    }
  }

  /// 相手最大HPに対するダメージ割合の範囲を表す文字列
  /// ```
  /// [例]101% ~ 120%
  /// ```
  String get rangePercentString {
    if (minDamagePercent == maxDamagePercent) {
      return '$minDamagePercent%';
    } else {
      return '$minDamagePercent% ~ $maxDamagePercent%';
    }
  }
}

/// ダメージ等入力Widgetの作成時に使う
enum CommandWidgetTemplate {
  /// 成否を選択
  successOrFail,

  /// 自身のポケモンを選択
  selectMyPokemons,

  /// 相手のポケモンを選択
  selectYourPokemons,

  /// 自身のひんしポケモンを選択
  selectMyFaintingPokemons,

  /// 相手の残りHPを入力
  inputYourHP,

  /// 自身の残りHPを入力
  inputMyHP,

  /// 自身の残りHPを入力(HP情報はextraArg2のみに保存)
  inputMyHP2,

  /// 失敗(入力不可)
  fail,

  /// わざを選択
  selectMove,

  /// 覚えているわざを選択
  selectAcquiringMove,

  /// 相手の覚えているわざを選択
  selectYourAcquiringMove,

  /// 1つの追加効果の発動/未発動を選択
  effect1Switch,

  /// 1つの追加効果の発動/未発動を選択
  effect1Switch2,

  /// 2つの追加効果の発動/未発動を選択
  effect2Switch,

  /// わざのタイプを選択
  selectMoveType,

  /// やけど/こおり/まひのいずれかを選択
  selectBurnFreezeParalysis,

  /// どく/まひ/ねむりのいずれかを選択
  selectPoisonParalysisSleep,

  /// 自身のもちものを選択
  selectMyHoldingItem,

  /// 相手のもちものを選択
  selectYourHoldingItem,

  /// 相手のもちものを選択(条件付き)
  selectYourItemWithFilter,

  /// 自身が得たもちものを選択
  selectMyGettingItem,

  /// 自身のもちものを選択(条件付き)
  selectMyItemWithFilter,

  /// もちものを選択
  selectItem,

  /// 自身のとくせいを選択
  selectMyAbility,

  /// 相手のとくせいを選択
  selectYourAbility,

  /// 自身が得たとくせいを選択
  selectMyGettingAbility,

  /// 2段階あがったステータスを選択
  select2UpStat,
}

/// 該当ページが表示される=入力中のわざは有効ということ、かどうか
extension ImmediatelyValid on CommandWidgetTemplate {
  /// 該当ページが表示される=入力中のわざは有効ということ、かどうか
  bool get isImmediatelyValid {
    switch (this) {
      case CommandWidgetTemplate.successOrFail:
      case CommandWidgetTemplate.fail:
      case CommandWidgetTemplate.effect1Switch:
      case CommandWidgetTemplate.effect1Switch2:
      case CommandWidgetTemplate.effect2Switch:
      case CommandWidgetTemplate.selectBurnFreezeParalysis:
      case CommandWidgetTemplate.selectPoisonParalysisSleep:
      case CommandWidgetTemplate.selectMyHoldingItem:
      case CommandWidgetTemplate.selectYourHoldingItem:
      case CommandWidgetTemplate.selectYourItemWithFilter:
      case CommandWidgetTemplate.selectMyGettingItem:
      case CommandWidgetTemplate.selectMyItemWithFilter:
      case CommandWidgetTemplate.selectItem:
      case CommandWidgetTemplate.selectMyAbility:
      case CommandWidgetTemplate.selectYourAbility:
      case CommandWidgetTemplate.selectMyGettingAbility:
      case CommandWidgetTemplate.select2UpStat:
        return true;
      case CommandWidgetTemplate.selectMyPokemons:
      case CommandWidgetTemplate.selectYourPokemons:
      case CommandWidgetTemplate.selectMyFaintingPokemons:
      case CommandWidgetTemplate.inputYourHP:
      case CommandWidgetTemplate.inputMyHP:
      case CommandWidgetTemplate.inputMyHP2:
      case CommandWidgetTemplate.selectMove:
      case CommandWidgetTemplate.selectAcquiringMove:
      case CommandWidgetTemplate.selectYourAcquiringMove:
      case CommandWidgetTemplate.selectMoveType:
        return false;
    }
  }
}

/// ターン内効果のうち、「行動」について管理するclass
class TurnEffectAction extends TurnEffect {
  /// 行動主
  PlayerType _playerType = PlayerType.none;

  /// 行動の種類
  TurnActionType type = TurnActionType.none;

  /// テラスタルしているならそのタイプ、していないなら[PokeType.unknown]
  PokeType teraType = PokeType.unknown;

  /// 使用するわざ
  Move move = Move.none();

  /// 行動の成功/失敗
  bool isSuccess = true;

  /// 行動失敗の原因
  ActionFailure _actionFailure = ActionFailure(ActionFailure.none);

  /// こうげきが命中した回数
  int hitCount = 1;

  /// 急所に当たった回数
  int criticalCount = 0;

  /// わざの(タイプ相性的な)効果
  /// ```
  /// こうかは(テキスト無し)/ばつぐん/いまひとつ/なし
  /// ```
  MoveEffectiveness moveEffectivenesses = MoveEffectiveness.normal;

  /// わざによって受けたダメージ（確定値）
  int realDamage = 0;

  /// わざによって与えたダメージ（概算値、割合）
  int percentDamage = 0;

  /// みがわりを破壊したかどうか
  bool breakSubstitute = false;

  /// 追加効果
  MoveEffect moveAdditionalEffects = MoveEffect(MoveEffect.none);

  /// オプション引数1
  int extraArg1 = 0;

  /// オプション引数2
  int extraArg2 = 0;

  /// オプション引数3
  int extraArg3 = 0;

  /// 自身・相手の(あるなら)交換先ポケモンのパーティ内インデックス(1始まり)
  List<int?> _changePokemonIndexes = [null, null];

  /// 自身・相手の(あるなら)交換前ポケモンのパーティ内インデックス(1始まり)
  List<int?> _prevPokemonIndexes = [null, null];

  /// わざのタイプ
  PokeType moveType = PokeType.unknown;

  /// ターン内最初の行動かどうか
  bool? isFirst;

  /// 有効かどうか
  bool _isValid = false;

  /// ターン内効果のうち、「行動」について管理するclassを生成
  /// ```
  /// player: 行動主
  /// ```
  TurnEffectAction({required player}) : super(EffectType.action) {
    _playerType = player;
  }

  @override
  List<Object?> get props => [
        playerType,
        type,
        teraType,
        move,
        isSuccess,
        _actionFailure,
        hitCount,
        criticalCount,
        moveEffectivenesses,
        realDamage,
        percentDamage,
        breakSubstitute,
        moveAdditionalEffects,
        extraArg1,
        extraArg2,
        extraArg3,
        _changePokemonIndexes,
        _prevPokemonIndexes,
        moveType,
        isFirst,
        _isValid,
      ];

  @override
  TurnEffectAction copy() => TurnEffectAction(player: playerType)
    ..type = type
    ..teraType = teraType
    ..move = move.copy()
    ..isSuccess = isSuccess
    .._actionFailure = _actionFailure
    ..hitCount = hitCount
    ..criticalCount = criticalCount
    ..moveEffectivenesses = moveEffectivenesses
    ..realDamage = realDamage
    ..percentDamage = percentDamage
    ..breakSubstitute = breakSubstitute
    ..moveAdditionalEffects = moveAdditionalEffects
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2
    ..extraArg3 = extraArg3
    .._changePokemonIndexes = [..._changePokemonIndexes]
    .._prevPokemonIndexes = [..._prevPokemonIndexes]
    ..moveType = moveType
    ..isFirst = isFirst
    .._isValid = _isValid;

  /// 行動失敗の原因
  ActionFailure get actionFailure => _actionFailure;
  set actionFailure(af) {
    // 原因の優先度が元より低くないなら更新
    if (af.id == 0 || af.priority >= _actionFailure.priority) {
      _actionFailure = af;
    }
  }

  /// 表示名
  @override
  String displayName({required AppLocalizations loc}) {
    switch (type) {
      case TurnActionType.move:
        if (isSuccess) {
          return move.displayName;
        } else {
          return actionFailure.displayName;
        }
      case TurnActionType.change:
        return loc.battlePokemonChange;
      case TurnActionType.surrender:
        return loc.battleSurrender;
      default:
        return '';
    }
  }

  @override
  PlayerType get playerType => _playerType;
  @override
  set playerType(type) => _playerType = type;

  @override
  Timing get timing => Timing.action;
  @override
  set timing(Timing t) {}

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getChangePokemonIndex(PlayerType player) {
    if (player == PlayerType.me) return _changePokemonIndexes[0];
    return _changePokemonIndexes[1];
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
    if (player == PlayerType.me) {
      _changePokemonIndexes[0] = val;
      _prevPokemonIndexes[0] = prev;
    } else {
      _changePokemonIndexes[1] = val;
      _prevPokemonIndexes[1] = prev;
    }
    if (val != null && type == TurnActionType.change) {
      _isValid = true;
    }
  }

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getPrevPokemonIndex(PlayerType player) {
    if (player == PlayerType.me) return _prevPokemonIndexes[0];
    return _prevPokemonIndexes[1];
  }

  /// わざが成功＆ヒットしたかどうか
  /// へんかわざなら成功したかどうか、こうげきわざならヒットしたかどうか
  bool isNormallyHit() {
    return isSuccess &&
        ((move.damageClass.id >= 2 && hitCount > 0) ||
            (move.damageClass.id == 1));
  }

  /// 追加効果に対応する文字列を返す
  /// ```
  /// id: わざのID
  /// name: 追加効果を受けるポケモン名
  /// ```
  String _getMoveEffectText(int id, String name, AppLocalizations loc) {
    switch (id) {
      //case 2:
      case 330:
      case 499:
        return loc.battleFellAsleep(name);
      case 3:
      case 78:
      case 210:
      case 449:
      case 466:
      case 484:
        return loc.battlePoisoned(name);
      case 5:
      case 126:
      case 201:
      case 254:
      case 274:
      case 333:
      case 454:
      case 460:
      case 469:
      case 472:
      case 500:
        return loc.battleBurned(name);
      case 6:
      case 275:
        return loc.battleFrozen(name);
      case 7:
      case 153:
      case 263:
      case 264:
      case 276:
      case 332:
      case 372:
      case 471:
        return loc.battlePararised(name);
      case 32:
      case 76:
      case 93:
      case 147:
      case 151:
      case 512:
        return loc.battleFlinched(name);
      //case 50:
      case 77:
      case 268:
      case 334:
      case 475:
      case 510:
        return loc.battleConfused(name);
      case 69:
        return loc.battleAttackDown1(name);
      case 70:
      case 468:
        return loc.battleDefenseDown1(name);
      case 71:
      case 470:
        return loc.battleSpeedDown1(name);
      case 72:
        return loc.battleSAttackDown1(name);
      case 73:
        return loc.battleSDefenseDown1(name);
      case 74:
        return loc.battleAccuracyDown1(name);
      case 139:
        return loc.battleDefenseUp1(name);
      case 140:
        return loc.battleAttackUp1(name);
      case 141:
        return loc.battleABCDSUp1(name);
      case 203:
        return loc.battleBadPoisoned(name);
      case 272:
        return loc.battleSDefenseDown2(name);
      case 277:
        return loc.battleSAttackUp1(name);
      case 359:
        return loc.battleDefenseUp2(name);
      default:
        return '';
    }
  }

  /// 追加効果に対応する文字列2を返す
  /// ```
  /// id: わざのID
  /// name: 追加効果を受けるポケモン名
  /// ```
  String _getMoveEffectText2(int id, String name, AppLocalizations loc) {
    switch (id) {
      case 274:
      case 275:
      case 276:
      case 468:
        return loc.battleFlinched(name);
      default:
        return '';
    }
  }

  /// 行動を処理し、表示ガイドのリストを返す
  /// ```
  /// ownParty: 自身(ユーザー)のパーティ
  /// ownState: 自身(ユーザー)のポケモンの状態
  /// opponentParty: 相手のパーティ
  /// opponentState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// prevAction: この行動の直前に起きた行動(わざ使用後の処理等に用いる)
  /// damageGetter: わざのダメージを取得するインスタンス
  /// ```
  @override
  List<Guide> processEffect(
    Party ownParty,
    PokemonState ownState,
    Party opponentParty,
    PokemonState opponentState,
    PhaseState state,
    TurnEffectAction? prevAction, {
    DamageGetter? damageGetter,
    required AppLocalizations loc,
  }) {
    final pokeData = PokeDB();
    List<Guide> ret = [];
    if (playerType == PlayerType.none) return ret;

    var ownPokemonState = ownState;
    var opponentPokemonState = opponentState;
    var myState = playerType == PlayerType.me ? ownState : opponentState;
    var yourState = playerType == PlayerType.me ? opponentState : ownState;
    var beforeChangeMyState = myState.copy();

    super.beforeProcessEffect(ownState, opponentState);

    // テラスタル済みならわざもテラスタル化
    if (myState.isTerastaling) {
      teraType = myState.teraType1;
    }

    // 行動1の場合は登録
    if (isFirst != null && isFirst!) {
      state.firstAction = this;
    }
    // みちづれ状態解除
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.destinyBond);
    // おんねん状態解除
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.grudge);
    // きょけんとつげき後状態解除
    myState.buffDebuffs.removeAllByID(BuffDebuff.certainlyHittedDamage2);

    // こうさん
    if (type == TurnActionType.surrender) {
      // パーティ全員ひんし状態にする
      for (var pokeState in state.getPokemonStates(playerType)) {
        pokeState.remainHP = 0;
        pokeState.remainHPPercent = 0;
        pokeState.isFainting = true;
      }
      super.afterProcessEffect(ownState, opponentState, state);
      return ret;
    }

    // テラスタル
    if (teraType != PokeType.unknown) {
      myState.isTerastaling = true;
      myState.teraType1 = teraType;
      if (playerType == PlayerType.me) {
        state.hasOwnTerastal = true;
      } else {
        state.hasOpponentTerastal = true;
      }
    }

    // ポケモン交代
    if (type == TurnActionType.change &&
        getChangePokemonIndex(playerType) != null) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      myState.processExitEffect(yourState, state);
      state.setPokemonIndex(playerType, getChangePokemonIndex(playerType)!);
      state
          .getPokemonState(playerType, null)
          .processEnterEffect(yourState, state);
      state
          .getPokemonState(playerType, null)
          .hiddenBuffs
          .add(pokeData.buffDebuffs[BuffDebuff.changedThisTurn]!.copy());
      super.afterProcessEffect(ownState, opponentState, state);
      return ret;
    }

    // ねむりカウント加算
    var sleep = myState.ailmentsWhere((e) => e.id == Ailment.sleep);
    if (sleep.isNotEmpty) sleep.first.turns++;
    // アンコールカウント加算(ただし、溜め状態でないことが条件)
    var encore = myState.ailmentsWhere((e) => e.id == Ailment.encore);
    if (encore.isNotEmpty &&
        !myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
      encore.first.turns++;
    }

    // こんらんによる自傷
    if (actionFailure.id == ActionFailure.confusion) {
      myState.remainHP -= extraArg1;
      myState.remainHPPercent -= extraArg2;
      return ret;
    }

    if (move.id == 0) return ret;

    // ゾロアーク判定
    // ゾロアーク判定だけは、有効/無効でこの後の処理が変わるため、
    // TurnEffectのinvalidGuideIDsに含まれるかどうかチェックする必要がある
    // TODO
    //if (!invalidGuideIDs.contains(Guide.confZoroark)) {
    if (playerType == PlayerType.opponent) {
      int check = 0;
      check += state.canZorua ? PokeBase.zoruaNo : 0;
      check += state.canZoroark ? PokeBase.zoroarkNo : 0;
      check += state.canZoruaHisui ? PokeBase.zoruaHisuiNo : 0;
      check += state.canZoroarkHisui ? PokeBase.zoroarkHisuiNo : 0;
      if (check == PokeBase.zoruaNo ||
          check == PokeBase.zoroarkNo ||
          check == PokeBase.zoruaHisuiNo ||
          check == PokeBase.zoroarkHisuiNo) {
        // へんしん状態でなく、当該ポケモンが使えないわざを選択していたら
        if (pokeData.pokeBase[myState.pokemon.no]!.move
                .where((e) => e.id == move.id && e.id != 0)
                .isEmpty &&
            !myState.buffDebuffs.containsByID(BuffDebuff.transform)) {
          ret.add(Guide()
            ..guideId = Guide.confZoroark
            ..canDelete = true
            ..guideStr = loc.battleGuideConfZoroark(
                myState.pokemon.name, pokeData.pokeBase[check]!.name));
          state.makePokemonOther(playerType, check);
          myState = state.getPokemonState(playerType, null);
          myState.setCurrentAbility(pokeData.abilities[149]!, yourState,
              playerType == PlayerType.me, state);
          ownPokemonState = state.getPokemonState(PlayerType.me, null);
          opponentPokemonState =
              state.getPokemonState(PlayerType.opponent, null);
        }
      }
    }
    //}

    // わざ確定(失敗時でも確定はできる)
    var tmp = myState.moves
        .where((element) => element.id != 0 && element.id == move.id);
    if (move.id != 165 && // わるあがきは除外
        playerType == PlayerType.opponent &&
        type == TurnActionType.move &&
        opponentPokemonState.moves.length < 4 &&
        tmp.isEmpty) {
      ret.add(Guide()
        ..guideId = Guide.confMove
        ..canDelete = false
        ..guideStr = loc.battleGuideConfMove(
            move.displayName, myState.pokemon.omittedName));
      opponentPokemonState.moves.add(move);
    }

    // わざPP消費(ただし、溜め状態でないことが条件)
    if (isSuccess) {
      int moveIdx = myState.moves
          .indexWhere((element) => element.id != 0 && element.id == move.id);
      if (moveIdx >= 0 &&
          !myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
        myState.usedPPs[moveIdx]++;
        if (yourState.currentAbility.id == 46) myState.usedPPs[moveIdx]++;
      }
    }

    // メトロノーム用
    {
      final findIdx = myState.hiddenBuffs.list.indexWhere(
          (element) => element.id == BuffDebuff.continuousMoveDamageInc0_2);
      if (findIdx >= 0) {
        if (!isSuccess) {
          if (!myState.buffDebuffs.containsByID(BuffDebuff.recoiling)) {
            myState.hiddenBuffs.list[findIdx].extraArg1 = 0;
          }
        }
      }
    }

    if (!isSuccess || hitCount == 0) {
      return ret;
    }

    List<IndividualField> myFields = state.getIndiFields(playerType);
    List<IndividualField> yourFields = state.getIndiFields(playerType.opposite);
    PlayerType myPlayerType = playerType;
    PlayerType yourPlayerType =
        playerType == PlayerType.me ? PlayerType.opponent : PlayerType.me;

    // ダメージを表示するかどうか
    damageGetter?.showDamage = false;

    /// わざの威力(連続わざの場合はそれぞれの威力)
    Map<int, int> movePower = {0: 0};
    // ダメージ計算式文字列
    String? damageCalc;
    // 最終ダメージが2倍になるか
    bool mTwice = false;
    // 相手のとくぼうでなくぼうぎょでダメージ計算するか
    bool invDeffense = false;
    // 相手のこうげきとランク補正でダメージ計算するか
    bool isFoulPlay = false;
    // 相手の不利ランク補正を無視してダメージ計算するか
    bool ignoreTargetRank = false;
    // 自身にとって不利ランク補正＆壁を無視してダメージ計算するか
    // TODO
    //bool isCritical = moveHits[continuousCount] == MoveHit.critical;
    bool isCritical = criticalCount > 0;
    // 相手のとくせいを無視してダメージ計算するか
    bool ignoreAbility = false;
    // こうげきの代わりにぼうぎょの数値とランク補正を使ってダメージ計算するか
    bool defenseAltAttack = false;
    // ダメージ計算をぶつりわざ/とくしゅわざのどちらとして行うか
    int moveDamageClassID = 0;
    // はれによるダメージ補正率が0.5倍→1.5倍
    bool isSunny1_5 = false;
    // タイプ相性計算時、追加で計算するタイプ
    PokeType? additionalMoveType;
    // 半減きのみを使用したか
    double halvedBerry = 0.0;
    // こうげき/とくこうのうちどちらの値を使うか不明だが、大きい方を使うかどうか
    bool useLargerAC = false;
    // ダメージ計算時、テラスタルまたはステラの補正がかかったか
    bool isTeraStellarHosei = false;
    // まるくなる状態の連続保持回数取得、まるくなる状態(一旦)解除
    final curl = myState.ailmentsWhere((e) => e.id == Ailment.curl);
    int curlCount = curl.isEmpty ? 0 : curl.first.extraArg1;
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.curl);
    // れんぞくぎりの連続成功回数取得、(一旦)解除
    final furyCutter = myState.hiddenBuffs.whereByID(BuffDebuff.furyCutter);
    int furyCutterCount = furyCutter.isEmpty ? 0 : furyCutter.first.extraArg1;
    myState.hiddenBuffs.removeAllByID(BuffDebuff.furyCutter);

    {
      Move replacedMove = getReplacedMove(move, myState); // 必要に応じてわざの内容変更
      moveDamageClassID = replacedMove.damageClass.id;

      // わざの対象決定
      List<PokemonState> targetStates = [yourState];
      List<List<IndividualField>> targetIndiFields = [yourFields];
      List<PlayerType> targetPlayerTypes = [yourPlayerType];
      PhaseState? targetField;
      switch (replacedMove.target) {
        case Target.specificMove: // 不定、わざによって異なる のろいとかカウンターとか
          break;
        case Target.selectedPokemonMeFirst: // 選択した自分以外の場にいるポケモン
        // (現状、さきどりとダイマックスわざのみ。SVで使用不可のため考慮しなくて良さそう)
        case Target.ally: // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
          targetStates = [];
          targetIndiFields = [];
          targetPlayerTypes = [];
          break;
        case Target.usersField: // 使用者の場
        case Target.user: // 使用者自身
        case Target.userOrAlly: // 使用者もしくは味方
        case Target.userAndAllies: // 使用者と味方
        case Target.allAllies: // すべての味方
          targetStates = [myState];
          targetIndiFields = [myFields];
          targetPlayerTypes = [myPlayerType];
          break;
        case Target.opponentsField: // 相手の場
        case Target.randomOpponent: // ランダムな相手
        case Target.allOtherPokemon: // 場にいる使用者以外の全ポケモン
        case Target.selectedPokemon: // 選択した自分以外の場にいるポケモン
        case Target.allOpponents: // 場にいる相手側の全ポケモン
          break;
        case Target.entireField: // 全体の場
          targetStates = [myState, yourState];
          targetIndiFields = [myFields, yourFields];
          targetPlayerTypes = [myPlayerType, yourPlayerType];
          targetField = state;
          break;
        case Target.allPokemon: // 場にいるすべてのポケモン
          targetStates.add(myState);
          targetIndiFields.add(myFields);
          targetPlayerTypes.add(myPlayerType);
          break;
        case Target.faintingPokemon: // ひんしの(味方)ポケモン
          targetStates.clear();
          targetIndiFields.clear();
          targetPlayerTypes.clear(); // 使わない
          for (int i = 0; i < state.getPokemonStates(playerType).length; i++) {
            if (i != state.getPokemonIndex(playerType, null) - 1 &&
                state.getPokemonStates(playerType)[i].isFainting) {
              targetStates.add(state.getPokemonStates(playerType)[i]);
              targetIndiFields.add(myFields);
              targetPlayerTypes.add(myPlayerType);
            }
          }
          break;
        default:
          break;
      }
      // マジックコートによるはねかえし
      if (replacedMove.damageClass.id == 1 &&
          yourState
              .ailmentsWhere((e) => e.id == Ailment.magicCoat)
              .isNotEmpty) {
        for (int i = 0; i < targetStates.length; i++) {
          if (targetStates[i] == yourState) {
            targetStates[i] = myState;
          }
        }
        for (int i = 0; i < targetIndiFields.length; i++) {
          if (targetIndiFields[i] == yourFields) {
            targetIndiFields[i] = myFields;
          }
        }
      }
      // メトロノーム用
      {
        final findIdx = myState.hiddenBuffs.list
            .indexWhere((element) => element.id == BuffDebuff.sameMoveCount);
        if (findIdx >= 0) {
          final found = myState.hiddenBuffs.list[findIdx];
          if ((found.extraArg1 / 100).floor() == replacedMove.id) {
            if (!myState.buffDebuffs.containsByID(BuffDebuff.chargingMove) ||
                found.extraArg1 == 0) {
              myState.hiddenBuffs.list[findIdx].extraArg1++;
            }
          } else {
            myState.hiddenBuffs.list[findIdx].extraArg1 = replacedMove.id * 100;
          }
        } else {
          myState.hiddenBuffs.add(
              pokeData.buffDebuffs[BuffDebuff.sameMoveCount]!.copy()
                ..extraArg1 = replacedMove.id * 100);
        }
      }
      // ねごと系以外のわざを出しているならねむり解除とみなす
      if (replacedMove.id != 156 &&
          replacedMove.id != 173 &&
          replacedMove.id != 214) {
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
      }
      // 動いているということで、こおり状態解除とみなす
      myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);

      // ダメージ計算式を表示するかどうか
      damageGetter?.showDamage = false;
      for (int i = 0; i < replacedMove.maxMoveCount(); i++) {
        movePower[i] = replacedMove.power;
      }
      // わざのタイプ(わざによっては変動するため)
      moveType = replacedMove.type;
      // ダメージ計算式文字列
      damageCalc = null;
      // 半減きのみを使用したか
      if (targetStates.isNotEmpty) {
        final founds =
            targetStates[0].hiddenBuffs.whereByID(BuffDebuff.halvedBerry);
        if (founds.isNotEmpty) {
          halvedBerry = founds.first.extraArg1 == 1 ? 0.25 : 0.5;
        }
      }

      switch (moveDamageClassID) {
        case 1: // へんか
          break;
        case 2: // ぶつり
        case 3: // とくしゅ
          damageGetter?.showDamage = true;
          break;
        default:
          break;
      }

      // 追加効果
      bool effectOnce =
          false; // ターゲットが(便宜上)複数(==targetStates.length > 1)でも、処理は一回にしたい場合にtrueにする(さむいギャグなど)
      for (int i = 0; i < targetStates.length; i++) {
        // ちからずくの場合、追加効果なし
        if (myState.buffDebuffs.containsByID(BuffDebuff.sheerForce) &&
            replacedMove.isAdditionalEffect) break;

        if (effectOnce) break;
        var targetState = targetStates[i];
        var targetIndiField = targetIndiFields[i];
        var targetPlayerType = targetPlayerTypes[i];
        switch (moveAdditionalEffects.id) {
          case 1: // 追加効果なし
          case 104: // 追加効果なし
          case 86: // なにも起きない
          case 370: // 効果なし
          case 371: // 効果なし
          case 379: // 通常こうげき
          case 383: // 場に出た最初の行動時のみ成功する
          case 406: // 通常こうげき
          case 417: // 通常こうげき
          case 439: // 通常こうげき
            break;
          case 2: // 眠らせる
          case 499: // 眠らせる(確率)
            targetState.ailmentsAdd(Ailment(Ailment.sleep), state);
            break;
          case 3: // どくにする(確率)
          case 67: // どくにする
          case 78: // 2回こうげき、どくにする(確率)
          case 210: // どくにする(確率)。急所に当たりやすい
            targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            break;
          case 4: // 与えたダメージの半分だけHP回復
          case 9: // ねむり状態の対象にのみダメージ、与えたダメージの半分だけHP回復
          case 33: // 最大HPの半分だけ回復する
          case 49: // 使用者は相手に与えたダメージの1/4ダメージを受ける
          case 133: // 使用者のHP回復。回復量は天気による
          case 199: // 与えたダメージの33%を使用者も受ける
          case 255: // 使用者は最大HP1/4の反動ダメージを受ける
          case 270: // 与えたダメージの1/2を使用者も受ける
          case 346: // 与えたダメージの半分だけHP回復
          case 349: // 与えたダメージの3/4だけHP回復
          case 382: // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
          case 387: // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
          case 420: // 最大HP1/2(小数点切り上げ)を削ってこうげき
          case 441: // 最大HP1/4だけ回復
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            break;
          case 5: // やけどにする(確率)
          case 168: // やけどにする
          case 201: // やけどにする(確率)。急所に当たりやすい
          case 472: // やけどにする(確率)。天気があめの時は必中
            targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            break;
          case 6: // こおりにする(確率)
          case 261: // こおりにする(確率)。天気がゆきのときは必中
            targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            break;
          case 7: // まひにする(確率)
          case 68: // まひにする
          case 153: // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
          case 372: // まひにする(確率)
          case 471: // まひにする(確率)。天気があめの時は必中
            targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            break;
          case 8: // 使用者はひんしになる
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 10: // 対象が最後に使ったわざを使う(SV使用不可のため処理なし)
            break;
          case 11: // 使用者のこうげきを1段階上げる
          case 140: // 使用者のこうげきを1段階上げる(確率)
          case 375: // 使用者のこうげきを1段階上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 12: // 使用者のぼうぎょを1段階上げる
          case 139: // 使用者のぼうぎょを1段階上げる(確率)
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 14: // 使用者のとくこうを1段階上げる
          case 277: // 使用者のとくこうを1段階上げる(確率)
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 17: // 使用者のかいひを1段階上げる
            myState.addStatChanges(true, 6, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 18: // 必中
          case 79: // 必中
          case 381: // 必中
            break;
          case 19: // こうげきを1段階下げる
          case 69: // こうげきを1段階下げる(確率)
          case 365: // こうげきを1段階下げる
          case 396: // こうげきを1段階下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 20: // ぼうぎょを1段階下げる
          case 70: // ぼうぎょを1段階下げる(確率)
          case 397: // ぼうぎょを1段階下げる
            targetState.addStatChanges(targetState == myState, 1, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 21: // すばやさを1段階下げる
          case 71: // すばやさを1段階下げる(確率)
          case 331: // すばやさを1段階下げる
          case 470: // すばやさを1段階下げる(確率)。天気があめの時は必中
            targetState.addStatChanges(targetState == myState, 4, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 24: // めいちゅうを1段階下げる
          case 74: // めいちゅうを1段階下げる(確率)
            targetState.addStatChanges(targetState == myState, 5, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 25: // かいひを1段階下げる
            targetState.addStatChanges(targetState == myState, 6, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 26: // すべての能力ランクを0にリセットする
            targetState.resetStatChanges();
            break;
          case 27: // 2ターン後の自身の行動までがまん状態になり、その間受けた合計ダメージの2倍を相手に返す(SV使用不可のため処理なし)
            //myState.ailmentsAdd(Ailment(Ailment.bide), state);
            break;
          case 28: // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
            myState.ailmentsAdd(
                Ailment(Ailment.thrash)..extraArg1 = replacedMove.id, state);
            if (extraArg1 != 0) {
              // あばれるの解除
              myState.ailmentsRemoveWhere((e) => e.id == Ailment.thrash);
              // こんらんする
              myState.ailmentsAdd(Ailment(Ailment.confusion), state);
            }
            break;
          case 29: // 相手ポケモンをランダムに交代させる
          case 314: // 相手ポケモンをランダムに交代させる
            if (getChangePokemonIndex(targetPlayerType) != null) {
              // processChangeEffect()で処理
            }
            break;
          case 30: // 2～5回連続でこうげきする
          case 361: // 2～5回連続でこうげきする
            break;
          case 31: // 使用者のタイプを、使用者が覚えているわざの一番上のタイプに変更する
          case 94: // 使用者のタイプを、相手が直前に使ったわざのタイプを半減/無効にするタイプに変更する
            if (extraArg1 != 0) {
              myState.type1 = PokeType.values[extraArg1];
              myState.type2 = null;
            }
            break;
          case 32: // ひるませる(確率)
          case 93: // ひるませる(確率)。ねむり状態のときのみ成功
          case 159: // ひるませる。場に出て最初の行動のときのみ成功
            targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            break;
          case 34: // もうどくにする
          case 203: // もうどくにする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.badPoison), state);
            break;
          case 35: // 戦闘後おかねを拾える
            break;
          case 36: // 場に「ひかりのかべ」を発生させる
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.lightScreen);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.lightScreen)
                ..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
            }
            break;
          case 37: // やけど・こおり・まひのいずれかにする(確率)
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(extraArg1), state);
            }
            break;
          case 38: // 使用者はHP満タン・状態異常を回復して2ターン眠る
            myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            if (myPlayerType == PlayerType.me) {
              myState.remainHP = myState.pokemon.h.real;
            } else {
              myState.remainHPPercent = 100;
            }
            myState.ailmentsAdd(Ailment(Ailment.sleep)..extraArg1 = 3, state);
            break;
          case 39: // 一撃必殺
            targetState.remainHP = 0;
            targetState.remainHPPercent = 0;
            targetState.isFainting = true;
            break;
          case 40: // 1ターン目にため、2ターン目でこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 41: // 残りHPの半分のダメージ(残り1の場合は1)
            {
              int damage = 0;
              if (targetPlayerType == PlayerType.me) {
                damage = (targetState.remainHP / 2).floor();
                if (damage == 0) damage = 1;
                damageCalc = loc.battleDamageFixed1(damage);
              } else {
                damage = (targetState.remainHPPercent / 2).floor();
                damageCalc = loc.battleDamageFixed2(damage);
              }
            }
            break;
          case 42: // 40の固定ダメージ
            damageCalc = loc.battleDamageFixed3;
            break;
          case 43: // バインド状態にする
            targetState.ailmentsAdd(Ailment(Ailment.partiallyTrapped), state);
            break;
          case 44: // きゅうしょに当たりやすい
            break;
          case 45: // 2回こうげき
            break;
          case 46: // わざを外すと使用者に、使用者の最大HP1/2のダメージ
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            break;
          case 47: // 場に「しろいきり」を発生させる
            int findIdx =
                targetIndiField.indexWhere((e) => e.id == IndividualField.mist);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.mist));
            }
            break;
          case 48: // 使用者の急所ランク+1
            myState.addVitalRank(1);
            break;
          case 50: // こんらんさせる
          case 77: // こんらんさせる(確率)
          case 200: // こんらんさせる
          case 268: // こんらんさせる(確率)
          case 334: // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 51: // 使用者のこうげきを2段階上げる
            myState.addStatChanges(true, 0, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 52: // 使用者のぼうぎょを2段階上げる
          case 359: // 使用者のぼうぎょを2段階上げる(確率)
            myState.addStatChanges(true, 1, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 53: // 使用者のすばやさを2段階上げる
            myState.addStatChanges(true, 4, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 54: // 使用者のとくこうを2段階上げる
            myState.addStatChanges(true, 2, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 55: // 使用者のとくこうを2段階上げる
            myState.addStatChanges(true, 3, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 58: // へんしん状態となる
            if (!targetState.buffDebuffs.containsByAnyID(
                    [BuffDebuff.substitute, BuffDebuff.transform]) &&
                !myState.buffDebuffs.containsByID(BuffDebuff.transform)) {
              // 対象がみがわり状態でない・お互いにへんしん状態でないなら
              myState.type1 = targetState.type1;
              myState.type2 = targetState.type2;
              if (targetState
                  .ailmentsWhere((e) => e.id == Ailment.halloween)
                  .isNotEmpty) {
                myState.ailmentsAdd(Ailment(Ailment.halloween), state);
              }
              if (targetState
                  .ailmentsWhere((e) => e.id == Ailment.forestCurse)
                  .isNotEmpty) {
                myState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
              }
              myState.setCurrentAbility(targetState.currentAbility, targetState,
                  playerType == PlayerType.me, state);
              for (int i = 0; i < targetState.moves.length; i++) {
                if (i >= myState.moves.length) {
                  myState.moves.add(targetState.moves[i]);
                } else {
                  myState.moves[i] = targetState.moves[i];
                }
                myState.usedPPs[i] = 0;
              }
              for (final stat in StatIndexList.listHtoS) {
                // HP以外のステータス実数値
                myState.minStats[stat].real = targetState.minStats[stat].real;
                myState.maxStats[stat].real = targetState.maxStats[stat].real;
              }
              for (int i = 0; i < 7; i++) {
                myState.forceSetStatChanges(i, targetState.statChanges(i));
              }
              myState.buffDebuffs
                  .add(pokeData.buffDebuffs[BuffDebuff.transform]!.copy()
                    ..extraArg1 = targetState.pokemon.no
                    ..turns = targetState.pokemon.sex.id);
            }
            break;
          case 59: // こうげきを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 60: // ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 1, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 61: // すばやさを2段階下げる
            targetState.addStatChanges(targetState == myState, 4, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 62: // とくこうを2段階下げる
            targetState.addStatChanges(targetState == myState, 2, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 63: // とくぼうを2段階下げる
          case 272: // とくぼうを2段階下げる(確率)
          case 297: // とくぼうを2段階下げる
            targetState.addStatChanges(targetState == myState, 3, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 66: // 場に「リフレクター」を発生させる
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.reflector);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.reflector)
                ..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
            }
            break;
          case 72: // とくこうを1段階下げる(確率)
          case 358: // とくこうを1段階下げる
            targetState.addStatChanges(targetState == myState, 2, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 73: // とくぼうを1段階下げる(確率)
          case 440: // とくぼうを1段階下げる
            targetState.addStatChanges(targetState == myState, 3, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 76: // 1ターン目は攻撃せず、2ターン目に攻撃。ひるませる(確率)
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (extraArg1 != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
                }
              }
            }
            break;
          case 80: // 場に「みがわり」を発生させる
            targetState.remainHP -= extraArg1;
            targetState.remainHPPercent -= extraArg2;
            if (!targetState.buffDebuffs.containsByID(BuffDebuff.substitute)) {
              targetState.buffDebuffs.add(
                  pokeData.buffDebuffs[BuffDebuff.substitute]!.copy()
                    ..extraArg1 = extraArg1 != 0 ? -extraArg1 : 25);
            }
            break;
          case 81: // 使用者は次のターン動けない
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.recoiling)) {
                // 反動で動けない状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.recoiling]!.copy()
                      ..extraArg1 = replacedMove.id);
              }
            }
            break;
          case 82: // 使用者はいかり状態になる
            if (!myState.buffDebuffs.containsByID(BuffDebuff.rage)) {
              targetState.buffDebuffs
                  .add(pokeData.buffDebuffs[BuffDebuff.rage]!.copy());
            }
            break;
          case 83: // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
            // 本来はコピーできるわざに制限があるが、そこはユーザ入力にゆだねる
            if (!myState.hiddenBuffs.containsByID(BuffDebuff.copiedMove)) {
              if (extraArg3 != 0) {
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.copiedMove]!.copy()
                      ..extraArg1 = extraArg3);
              }
            }
            break;
          case 84: // ほぼすべてのわざから1つをランダムで使う
            // ユーザが、出たわざを選択していればここは通らない。処理なし
            break;
          case 85: // やどりぎのタネ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.leechSeed), state);
            break;
          case 87: // かなしばり状態にする
            if (targetState.lastMove != null) {
              targetState.ailmentsAdd(
                  Ailment(Ailment.disable)
                    ..extraArg1 = targetState.lastMove!.id,
                  state);
            }
            break;
          case 88: // 使用者のレベル分の固定ダメージ
            damageCalc = loc.battleDamageFixed4(myState.pokemon.level);
            break;
          case 89: // ランダムに決まった固定ダメージ
          case 90: // 低優先度。ターンで最後に受けた物理わざによるダメージの2倍を与える
          case 92: // 使用者と相手のHPを足して半々に分ける
          case 145: // 低優先度。ターンで最後に受けた特殊わざによるダメージの2倍を与える
            damageGetter?.showDamage = false;
            break;
          case 91: // アンコール状態にする
            if (targetState.lastMove != null) {
              targetState.ailmentsAdd(
                  Ailment(Ailment.encore)..extraArg1 = targetState.lastMove!.id,
                  state);
            }
            break;
          case 95: // ロックオン状態にする
            targetState.ailmentsAdd(Ailment(Ailment.lockOn), state);
            break;
          case 96: // 相手が最後に使用したわざをコピーし、このわざがその代わりとなる(SV使用不可のため処理なし)
            break;
          case 98: // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
            // ユーザが、出たわざを選択していればここは通らない。処理なし
            break;
          case 99: // 次の使用者の行動順までみちづれ状態になる。連続で使用すると失敗する
            targetState.ailmentsAdd(Ailment(Ailment.destinyBond), state);
            break;
          case 100: // 使用者の残りHPが少ないほど威力が大きくなる
            {
              int x = 0;
              if (myPlayerType == PlayerType.me) {
                x = (myState.remainHP * 48 / myState.pokemon.h.real).floor();
              } else {
                x = (myState.remainHPPercent * 48 / 100).floor();
              }
              if (33 <= x) {
                movePower[0] = 20;
              } else if (17 <= x) {
                movePower[0] = 40;
              } else if (10 <= x) {
                movePower[0] = 80;
              } else if (5 <= x) {
                movePower[0] = 100;
              } else if (2 <= x) {
                movePower[0] = 150;
              } else {
                movePower[0] = 200;
              }
            }
            break;
          case 101: // 相手が最後に消費したわざのPPを4減らす
            if (targetState.lastMove != null) {
              int targetID = targetState.moves
                  .indexWhere((e) => e.id == targetState.lastMove!.id);
              if (targetID >= 0 && targetID < targetState.usedPPs.length) {
                targetState.usedPPs[targetID] += 4;
              }
            }
            break;
          case 102: // 相手のHPは最低でも1残る
            break;
          case 103: // 状態異常を治す
            int findIdx =
                targetState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            if (findIdx >= 0) targetState.ailmentsRemoveAt(findIdx);
            break;
          case 105: // 3回連続こうげき。2回目以降の威力は最初の100%分大きくなる
            movePower[1] = movePower[0]! * 2;
            movePower[2] = movePower[0]! * 3;
            break;
          case 106: // もちものを盗む
            if (extraArg1 != 0) {
              // もちもの確定のため、一度持たせる
              if (targetPlayerType == PlayerType.opponent &&
                  opponentPokemonState.getHoldingItem()?.id == 0) {
                targetState.holdingItem = pokeData.items[extraArg1]!;
              }
              myState.holdingItem = pokeData.items[extraArg1]!;
              targetState.holdingItem = null;
            }
            break;
          case 107: // にげられない状態にする
          case 374: // にげられない状態にする
          case 385: // にげられない状態にする
            if (!targetState.isTypeContain(PokeType.ghost)) {
              targetState.ailmentsAdd(
                  Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
            }
            break;
/*
          case 108:   // あくむ状態にする(SVで使用不可のため実装無し)
            targetState.ailmentsAdd(Ailment(Ailment.nightmare), state);
            break;
*/
          case 109: // 使用者のかいひを2段階上げる。ちいさくなる状態になる
            myState.addStatChanges(true, 6, 2, targetState,
                moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.minimize), state);
            break;
          case 110: // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
            if (myState.isTypeContain(PokeType.ghost)) {
              myState.remainHP -= extraArg1;
              myState.remainHPPercent -= extraArg2;
              yourState.ailmentsAdd(Ailment(Ailment.curse), state);
            } else {
              myState.addStatChanges(true, 0, 1, targetState,
                  moveId: replacedMove.id);
              myState.addStatChanges(true, 1, 1, targetState,
                  moveId: replacedMove.id);
              myState.addStatChanges(true, 4, -1, targetState,
                  moveId: replacedMove.id);
            }
            break;
          case 112: // まもる状態になる
          case 307: // まもる状態になる
          case 377: // まもる状態になる。場に出て最初の行動の場合のみ成功
            myState.ailmentsAdd(Ailment(Ailment.protect), state);
            break;
          case 113: // 相手の場に「まきびし」を発生させる
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.spikes);
            if (findIdx < 0) {
              targetIndiField
                  .add(IndividualField(IndividualField.spikes)..extraArg1 = 1);
            } else {
              targetIndiField[findIdx].extraArg1++;
              if (targetIndiField[findIdx].extraArg1 > 3) {
                targetIndiField[findIdx].extraArg1 = 3;
              }
            }
            break;
          case 114: // みやぶられている状態にする
            targetState.ailmentsAdd(Ailment(Ailment.identify), state);
            break;
          case 115: // ほろびのうた状態にする
            targetState.ailmentsAdd(Ailment(Ailment.perishSong), state);
            break;
          case 116: // 天気をすなあらしにする
            targetField!.weather = Weather(Weather.sandStorm)
              ..extraArg1 = myState.holdingItem?.id == 260 ? 8 : 5;
            effectOnce = true;
            break;
          case 117: // ひんしダメージをHP1で耐える。連続使用で失敗しやすくなる
            break;
          case 118: // 最高5ターン連続でこうげき、当てるたびに威力が2倍になる(まるくなる状態だと威力2倍)
            for (int i = 0; i < curlCount; i++) {
              movePower[0] = movePower[0]! * 2;
            }
            curlCount++;
            myState.ailmentsAdd(
                Ailment(Ailment.curl)..extraArg1 = curlCount, state);
            break;
          case 119: // こうげきを2段階上げ、こんらん状態にする
            targetState.addStatChanges(targetState == myState, 0, 2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 120: // 当てるたびに威力が2倍ずつ増える。最大160
            for (int i = 0; i < furyCutterCount; i++) {
              movePower[0] = movePower[0]! * 2;
            }
            furyCutterCount++;
            myState.hiddenBuffs.add(
                pokeData.buffDebuffs[BuffDebuff.furyCutter]!.copy()
                  ..extraArg1 = furyCutterCount);
            if (movePower[0]! > 160) movePower[0] = 160;
            break;
          case 121: // 性別が異なる場合、メロメロ状態にする
            if (myState.sex != Sex.none &&
                targetState.sex != Sex.none &&
                myState.sex != targetState.sex) {
              targetState.ailmentsAdd(Ailment(Ailment.infatuation), state);
            }
            break;
          case 122: // なつき度によって威力が変わる
            // なつき度(0~255)×10/25
            damageGetter?.showDamage = false;
            break;
          case 123: // ランダムに威力が変わる/相手を回復する
            damageGetter?.showDamage = false;
            break;
          case 124: // なつき度が低いほど威力があがる
            // (255-なつき度(0~255))×10/25
            damageGetter?.showDamage = false;
            break;
          case 125: // 場に「しんぴのまもり」を発生させる
            if (targetIndiField
                .where((e) => e.id == IndividualField.safeGuard)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.safeGuard));
            }
            break;
          case 126: // 使用者のこおり状態を消す。相手をやけど状態にする(確率)
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 127: // 威力がランダムで10,30,50,70,90,110,150のいずれかになる。あなをほる状態の対象にも当たり、ダメージ2倍。グラスフィールドの影響を受ける相手には威力半減
            damageGetter?.showDamage = false;
            break;
          case 128: // 控えのポケモンと交代する。能力変化・一部の状態変化は交代後に引き継ぐ
            if (getChangePokemonIndex(myPlayerType) != null) {
              // processChangeEffect()で処理
            }
            break;
          case 129: // そのターンに相手が交代しようとした場合、威力2倍で交代前のポケモンにこうげき
            damageGetter?.showDamage = false;
            break;
          case 130: // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。使用者のすばやさを1段階上げる
            myState.ailmentsRemoveWhere((e) =>
                e.id == Ailment.partiallyTrapped || e.id == Ailment.leechSeed);
            myFields.removeWhere((e) =>
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 131: // 20の固定ダメージ
            damageCalc = loc.battleDamageFixed5;
            break;
          case 136: // 個体値によってわざのタイプが変わる
            if (extraArg1 != 0) {
              moveType = PokeType.values[extraArg1];
            }
            break;
          case 137: // 天気を雨にする
            targetField!.weather = Weather(Weather.rainy)
              ..extraArg1 = myState.holdingItem?.id == 262 ? 8 : 5;
            effectOnce = true;
            break;
          case 138: // 天気をはれにする
            targetField!.weather = Weather(Weather.sunny)
              ..extraArg1 = myState.holdingItem?.id == 261 ? 8 : 5;
            effectOnce = true;
            break;
          case 141: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 143: // 使用者は最大HPの1/2だけHPが減る。こうげきランクが最大まで上がる
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= (myState.pokemon.h.real / 2).floor();
            } else {
              myState.remainHPPercent -= 50;
            }
            myState.forceSetStatChanges(0, 6);
            break;
          case 144: // 能力変化をすべて相手と同じにする
            {
              List<int> src =
                  List.generate(7, (i) => targetState.statChanges(i));
              for (int i = 0; i < 7; i++) {
                myState.forceSetStatChanges(i, src[i]);
              }
            }
            break;
          case 146: // 1ターン目にため、2ターン目でこうげきする。1ターン目で使用者のぼうぎょが1段階上がる
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                myState.addStatChanges(true, 1, 1, targetState,
                    moveId: replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 147: // ひるませる(確率)。そらをとぶ状態でも命中し、その場合威力が2倍
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.flying)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 148: // あなをほる状態でも命中し、その場合ダメージが2倍。グラスフィールドの影響を受けている相手には威力が半減
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.digging)
                .isNotEmpty) mTwice = true;
            if (targetState.isGround(targetIndiField) &&
                state.field.id == Field.grassyTerrain) {
              movePower[0] = (movePower[0]! / 2).floor();
            }
            break;
          case 149: // 2ターン後の相手にダメージを与える
            targetIndiField.add(IndividualField(IndividualField.futureAttack));
            damageCalc = '';
            break;
          case 150: // そらをとぶ状態でも命中し、その場合威力が2倍
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.flying)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 151: // ひるませる(確率)。ちいさくなる状態に対して必中、その場合ダメージ2倍
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.minimize)
                .isNotEmpty) mTwice = true;
            break;
          case 152: // 1ターン目にため、2ターン目でこうげきする。1ターン目の天気がはれ→ためずにこうげき。攻撃時天気が雨、すなあらし、ゆきなら威力半減
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                if (state.weather.id != Weather.sunny) {
                  myState.hiddenBuffs.add(
                      pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                        ..extraArg1 = replacedMove.id);
                  damageGetter?.showDamage = false;
                }
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (state.weather.id == Weather.rainy ||
                    state.weather.id == Weather.sandStorm ||
                    state.weather.id == Weather.snowy) {
                  movePower[0] = (movePower[0]! / 2).floor();
                }
              }
            }
            break;
          case 154: // 控えのポケモンと交代する
          case 229: // 控えのポケモンと交代する
            if (getChangePokemonIndex(myPlayerType) != null) {
              // processChangeEffect()で処理
            }
            break;
          case 155: // 手持ちポケモン(ひんし、状態異常除く)の数だけ連続でこうげきする
            damageGetter?.showDamage = false;
            break;
          case 156: // 使用者はそらをとぶ状態になり、次のターンにこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                myState.ailmentsAdd(Ailment(Ailment.flying), state);
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.flying);
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 157: // 使用者のぼうぎょを1段階上げる。まるくなる状態になる
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.curl)..extraArg1, state);
            break;
          case 160: // さわぐ状態になる
            myState.ailmentsAdd(Ailment(Ailment.uproar), state);
            // ねむり状態解除
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
            yourState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
            break;
          case 161: // たくわえた回数を+1する。使用者のぼうぎょ・とくぼうが1段階上がる
            int findIdx =
                myState.ailmentsIndexWhere((e) => e.id == Ailment.stock3);
            if (findIdx < 0) {
              int plusPoint = 0;
              if (myState.statChanges(1) < 6) {
                myState.addStatChanges(true, 1, 1, targetState,
                    moveId: replacedMove.id);
                plusPoint++;
              }
              if (myState.statChanges(3) < 6) {
                myState.addStatChanges(true, 3, 1, targetState,
                    moveId: replacedMove.id);
                plusPoint += 10;
              }
              findIdx = myState.ailmentsIndexWhere(
                  (e) => e.id == Ailment.stock1 || e.id == Ailment.stock2);
              if (findIdx >= 0) {
                var removed = myState.ailmentsRemoveAt(findIdx);
                myState.ailmentsAdd(
                    Ailment(removed.id + 1)
                      ..extraArg1 = removed.extraArg1 + plusPoint,
                    state);
              } else {
                myState.ailmentsAdd(
                    Ailment(Ailment.stock1)..extraArg1 = plusPoint, state);
              }
            }
            break;
          case 162: // たくわえた回数が多いほど威力が上がる。たくわえた回数を0にする
            int findIdx = myState.ailmentsIndexWhere(
                (e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
            if (findIdx >= 0) {
              movePower[0] = movePower[0]! * myState.ailments(findIdx).id -
                  Ailment.stock1 +
                  1;
              myState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 163: // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            int findIdx = myState.ailmentsIndexWhere(
                (e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
            if (findIdx >= 0) {
              myState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 165: // 天気をあられにする
            //targetField!.weather = Weather(Weather.snowy);
            effectOnce = true;
            break;
          case 166: // いちゃもん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.torment), state);
            break;
          case 167: // とくこうを1段階上げ、こんらん状態にする
            targetState.addStatChanges(targetState == myState, 2, 1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 169: // 使用者はひんしになる。相手のこうげき・とくこうを2段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 170: // 使用者がどく・もうどく・まひ・やけどのいずれかの場合、威力が2倍になる(＋やけどによるダメージ減少なし)
            if (myState
                .ailmentsWhere((e) =>
                    e.id == Ailment.burn ||
                    e.id == Ailment.paralysis ||
                    e.id == Ailment.poison ||
                    e.id == Ailment.badPoison)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 171: // そのターンでこうげきする前に使用者がこうげきわざによるダメージを受けていると失敗する
            break;
          case 172: // 相手がまひ状態なら威力2倍。相手のまひを治す
            int findIdx = targetState
                .ailmentsIndexWhere((e) => e.id == Ailment.paralysis);
            if (findIdx >= 0) {
              movePower[0] = movePower[0]! * 2;
              targetState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 173: // 使用者はちゅうもくのまと状態になる
            myState.ailmentsAdd(Ailment(Ailment.attention), state);
            break;
          case 174: // 地形やフィールドによって出る技が変わる(SV使用不可のため処理なし)
            break;
          case 175: // 使用者はじゅうでん状態になる。使用者のとくぼうを1段階上げる
            myState.ailmentsAdd(Ailment(Ailment.charging), state);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 176: // ちょうはつ状態にする
            targetState.ailmentsAdd(
                Ailment(Ailment.taunt)
                  ..extraArg1 = (isFirst != null && !isFirst!) ? 1 : 0,
                state);
            break;
          case 177: // てだすけ状態にする
            // シングルバトルでは失敗する
            //targetState.ailmentsAdd(Ailment(Ailment.helpHand), state);
            break;
          case 178: // 使用者ともちものを入れ替える
            var ownItem = ownPokemonState.getHoldingItem();
            if (extraArg1 > 0) {
              // もちもの確定のため、一度持たせる
              if (opponentPokemonState.getHoldingItem()?.id == 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1]
                  ..guideStr = loc.battleGuideConfItem1(
                      pokeData.items[extraArg1]!.displayName,
                      opponentPokemonState.pokemon.omittedName));
                opponentPokemonState.holdingItem = pokeData.items[extraArg1]!;
              }
              ownPokemonState.holdingItem = pokeData.items[extraArg1]!;
            } else {
              ownPokemonState.holdingItem = null;
            }
            opponentPokemonState.holdingItem = ownItem;
            break;
          case 179: // 相手と同じとくせいになる
            if (extraArg1 != 0) {
              myState.setCurrentAbility(pokeData.abilities[extraArg1]!,
                  yourState, playerType == PlayerType.me, state);
            }
            break;
          case 180: // 使用者の場に「ねがいごと」を発生させる
            if (myFields.where((e) => e.id == IndividualField.wish).isEmpty) {
              myFields.add(IndividualField(IndividualField.wish)
                ..extraArg1 = playerType == PlayerType.me
                    ? (myState.pokemon.h.real / 2).floor()
                    : 50);
            }
            break;
          case 181: // 使用者の手持ちポケモンの技をランダムに1つ使う(SV使用不可のため処理なし)
            break;
          case 182: // 使用者はねをはる状態になる。
            myState.ailmentsAdd(Ailment(Ailment.ingrain), state);
            break;
          case 183: // 使用者はこうげき・ぼうぎょが1段階下がる
            myState.addStatChanges(true, 0, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 184: // 使用者に使われた変化技を相手に跳ね返す(SV使用不可のため処理なし)
            break;
          case 185: // 戦闘中自分が最後に使用したもちものを復活させる
            if (extraArg1 != 0) {
              myState.holdingItem = pokeData.items[extraArg1]!;
            }
            break;
          case 186: // このターンに、対象からダメージを受けていた場合は威力2倍
            damageGetter?.showDamage = false;
            break;
          case 187: // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき
            targetIndiField.removeWhere((e) =>
                e.id == IndividualField.reflector ||
                e.id == IndividualField.lightScreen ||
                e.id == IndividualField.auroraVeil);
            break;
          case 188: // ねむけ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.sleepy), state);
            break;
          case 189: // もちものを持っていれば失わせ、威力1.5倍
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent &&
                targetState.getHoldingItem()?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [extraArg1]
                ..guideStr = loc.battleGuideConfItem1(
                    pokeData.items[extraArg1]!.displayName,
                    opponentPokemonState.pokemon.omittedName));
              if (extraArg1 != 0) {
                targetState.holdingItem = pokeData.items[extraArg1]!;
              }
            }
            targetState.holdingItem = null;
            movePower[0] = movePower[0]! * 2;
            break;
          case 190: // 相手の残りHP-使用者の残りHP(負数なら失敗)分の固定ダメージを与える
            damageGetter?.showDamage = false;
            break;
          case 191: // 威力=150×使用者の残りHP/最大HP
            if (myPlayerType == PlayerType.me) {
              movePower[0] =
                  (150 * myState.remainHP / myState.pokemon.h.real).floor();
            } else {
              movePower[0] = (150 * myState.remainHPPercent / 100).floor();
            }
            if (movePower[0] == 0) movePower[0] = 1;
            break;
          case 192: // 使用者ととくせいを入れ替える
            opponentPokemonState.setCurrentAbility(
                ownPokemonState.getCurrentAbility(),
                ownPokemonState,
                false,
                state);
            if (extraArg1 != 0) {
              ownPokemonState.setCurrentAbility(pokeData.abilities[extraArg1]!,
                  opponentPokemonState, true, state);
            }
            break;
          case 193: // 使用者をふういん状態にする
            myState.ailmentsAdd(Ailment(Ailment.imprison), state);
            break;
          case 194: // 使用者のどく・もうどく・まひ・やけどを治す
            myState.ailmentsRemoveWhere((e) =>
                e.id == Ailment.poison ||
                e.id == Ailment.badPoison ||
                e.id == Ailment.paralysis ||
                e.id == Ailment.burn);
            break;
          case 195: // 使用者をおんねん状態にする
            myState.ailmentsAdd(Ailment(Ailment.grudge), state);
            break;
          case 196: // そのターンに使われる、自身を対象にするへんかわざを横取りして代わりに自分に使う(SV使用不可のため処理なし)
            break;
          case 197: // 相手のおもさによって威力が変わる
            int weight = targetState.weight;
            if (!targetState.buffDebuffs.containsByID(BuffDebuff.heavy2)) {
              weight *= 2;
            }
            if (targetState.buffDebuffs.containsByID(BuffDebuff.heavy0_5)) {
              weight = (weight / 2).floor();
            }
            if (targetState.holdingItem?.id == 582) {
              weight = (weight / 2).floor();
            }
            if (weight <= 99) {
              movePower[0] = 20;
            } else if (weight <= 249) {
              movePower[0] = 40;
            } else if (weight <= 499) {
              movePower[0] = 60;
            } else if (weight <= 999) {
              movePower[0] = 80;
            } else if (weight <= 1999) {
              movePower[0] = 100;
            } else {
              movePower[0] = 120;
            }
            break;
          case 198: // 地形に応じた追加効果を与える(SV使用不可のため処理なし)
            break;
          case 202: // 場をどろあそび状態にする
            if (targetIndiField
                .where((e) => e.id == IndividualField.mudSport)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.mudSport));
            }
            break;
          case 204: // 天気が変わっていると威力2倍、タイプも変わる
            switch (state.weather.id) {
              case Weather.sunny:
                movePower[0] = movePower[0]! * 2;
                moveType = PokeType.fire;
                break;
              case Weather.rainy:
                movePower[0] = movePower[0]! * 2;
                moveType = PokeType.water;
                break;
              case Weather.snowy:
                movePower[0] = movePower[0]! * 2;
                moveType = PokeType.ice;
                break;
              case Weather.sandStorm:
                movePower[0] = movePower[0]! * 2;
                moveType = PokeType.rock;
                break;
              default:
                break;
            }
            break;
          case 205: // 使用者はとくこうが2段階下がる
            myState.addStatChanges(true, 2, -2, targetState,
                moveId: replacedMove.id);
            break;
          case 206: // こうげき・ぼうぎょを1段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 207: // 使用者はぼうぎょ・とくぼうが1段階ずつ上がる
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 208: // そらをとぶ状態の相手にも当たる
            break;
          case 209: // 使用者はこうげき・ぼうぎょが1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 211: // 場をみずあそび状態にする
            if (targetIndiField
                .where((e) => e.id == IndividualField.waterSport)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.waterSport));
            }
            break;
          case 212: // 使用者はとくこう・とくぼうが1段階ずつ上がる
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 213: // 使用者はこうげき・すばやさが1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 214: // 使用者のタイプを地形やフィールドに応じて変える(SV使用不可のため処理なし)
            break;
          case 215: // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            int lostFly = 0;
            if (!myState.isTerastaling && myState.type1 == PokeType.fly) {
              if (myState.type2 == null) {
                myState.type1 = PokeType.normal;
                lostFly = 1;
              } else {
                myState.type1 = myState.type2!;
                myState.type2 = null;
                lostFly = 3;
              }
            } else if (!myState.isTerastaling &&
                myState.type2 != null &&
                myState.type2! == PokeType.fly) {
              myState.type2 = null;
              lostFly = 2;
            }
            myState.ailmentsRemoveWhere(
                (e) => e.id == Ailment.magnetRise); // でんじふゆうは解除
            myState.ailmentsAdd(
                Ailment(Ailment.roost)..extraArg1 = lostFly, state);
            break;
          case 216: // 場をじゅうりょく状態にする
            if (targetIndiField
                .where((e) => e.id == IndividualField.gravity)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.gravity));
            }
            targetState.ailmentsRemoveWhere((e) =>
                e.id == Ailment.magnetRise ||
                e.id == Ailment.telekinesis ||
                e.id == Ailment.flying); // でんじふゆう/テレキネシス/そらをとぶは解除
            break;
          case 217: // ミラクルアイ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.miracleEye), state);
            break;
          case 218: // 相手がねむり状態なら威力2倍。相手のねむりを治す
            int findIdx =
                targetState.ailmentsIndexWhere((e) => e.id == Ailment.sleep);
            if (findIdx >= 0) {
              movePower[0] = movePower[0]! * 2;
              targetState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 219: // 使用者のすばやさを1段階下げる
            myState.addStatChanges(true, 4, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 220: // 使用者のすばやさが相手と比べて低いほど威力が大きくなる(25×相手のすばやさ/使用者のすばやさ+1)(max150)
            damageGetter?.showDamage = false;
            break;
          case 221: // 使用者はひんしになる。場にいやしのねがいを発生させる
            myFields.add(IndividualField(IndividualField.healingWish));
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 222: // 相手のHPが最大HPの1/2以下なら威力2倍
            if (targetPlayerType == PlayerType.me &&
                targetState.remainHP <=
                    (targetState.pokemon.h.real / 2).floor()) {
              movePower[0] = movePower[0]! * 2;
            } else if (targetPlayerType == PlayerType.opponent &&
                targetState.remainHPPercent <= 50) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 223: // 持っているきのみによってタイプと威力が変わる。きのみはなくなる(SV使用不可のため処理なし)
            break;
          case 224: // まもる等の状態を解除してこうげきできる
            break;
          case 225: // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            if (extraArg1 != 0) {
              Item usingItem = pokeData.items[extraArg1]!;
              Item? mySavingItem = myState.holdingItem;
              targetState.holdingItem = null;
              final itemEffect = TurnEffectItem(
                  player: playerType,
                  timing: Timing.action,
                  itemID: usingItem.id);
              itemEffect.processEffect(ownParty, ownState, opponentParty,
                  opponentState, state, prevAction,
                  loc: loc, autoConsume: false);
              myState.holdingItem = mySavingItem;
            }
            break;
          case 226: // 使用者の場においかぜを発生させる
            if (myFields
                .where((e) => e.id == IndividualField.tailwind)
                .isEmpty) {
              myFields.add(IndividualField(IndividualField.tailwind));
            }
            break;
          case 227: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
            myState.addStatChanges(true, extraArg1, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 228: // そのターンで最後に相手から受けたこうげきわざのダメージを1.5倍にして返す
            damageGetter?.showDamage = false;
            break;
          case 230: // 使用者のぼうぎょ・とくぼうを1段階ずつ下げる
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 231: // 相手がそのターン既に行動していると威力2倍
            damageGetter?.showDamage = false;
            break;
          case 232: // 相手がそのターン既にダメージを受けていると威力2倍
            damageGetter?.showDamage = false;
            break;
          case 233: // さしおさえ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.embargo), state);
            break;
          case 234: // 使用者のもちものによって威力と追加効果が変わる
            if (extraArg1 != 0) {
              var flingItem = pokeData.items[extraArg1]!;
              movePower[0] = flingItem.flingPower;
              flingItem.processFlingEffect(
                playerType,
                myState,
                yourState,
                state,
                extraArg2,
                0,
                getChangePokemonIndex(myPlayerType),
                loc: loc,
              );
              myState.holdingItem = null;
            }
            break;
          case 235: // 使用者の状態異常を相手に移す
            int targetIdx =
                targetState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            int myIdx =
                myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            if (targetIdx < 0 && myIdx >= 0) {
              targetState.ailmentsAdd(
                  Ailment(myState.ailments(myIdx).id), state);
            }
            myState.ailmentsRemoveAt(myIdx);
            break;
          case 236: // わざの残りPPが少ないほどわざの威力が上がる。必中
            damageGetter?.showDamage = false;
            break;
          case 237: // かいふくふうじ状態にする
            targetState.ailmentsAdd(
                Ailment(Ailment.healBlock)..extraArg1 = 5, state);
            break;
          case 238: // 相手の残りHPが多いほど威力が高くなる(120×相手の残りHP/相手の最大HP)
            if (targetPlayerType == PlayerType.me) {
              movePower[0] =
                  (120 * targetState.remainHP / targetState.pokemon.h.real)
                      .floor();
            } else {
              movePower[0] = (120 * targetState.remainHPPercent / 100).floor();
            }
            break;
          case 239: // 使用者をパワートリック状態にする
            myState.ailmentsAdd(Ailment(Ailment.powerTrick), state);
            break;
          case 240: // とくせいなし状態にする
            targetState.ailmentsAdd(Ailment(Ailment.abilityNoEffect), state);
            break;
          case 241: // 場におまじないを発生させる(SV使用不可のため処理なし)
            break;
          case 242: // 場におまじないを発生させる(SV使用不可のため処理なし)
            break;
          case 243: // 最後に出されたわざを出す(相手のわざとは限らない)
            break;
          case 244: // 使用者のこうげき・とくこうランク変化と相手のこうげき・とくこうランク変化を入れ替える
            int myAttackStat = myState.statChanges(0);
            int mySpecialAttackStat = myState.statChanges(2);
            myState.forceSetStatChanges(0, targetState.statChanges(0));
            myState.forceSetStatChanges(2, targetState.statChanges(2));
            targetState.forceSetStatChanges(0, myAttackStat);
            targetState.forceSetStatChanges(2, mySpecialAttackStat);
            break;
          case 245: // 使用者のぼうぎょ・とくぼうランク変化と相手のぼうぎょ・とくぼうランク変化を入れ替える
            int myDefenseStat = myState.statChanges(1);
            int mySpecialDefenseStat = myState.statChanges(3);
            myState.forceSetStatChanges(1, targetState.statChanges(1));
            myState.forceSetStatChanges(3, targetState.statChanges(3));
            targetState.forceSetStatChanges(1, myDefenseStat);
            targetState.forceSetStatChanges(3, mySpecialDefenseStat);
            break;
          case 246: // 相手がランク変化で強くなっているほど威力があがる(max200)
            for (int i = 0; i < 7; i++) {
              if (targetState.statChanges(i) > 0) {
                movePower[0] = movePower[0]! + 20 * targetState.statChanges(i);
              }
            }
            if (movePower[0]! > 200) movePower[0] = 200;
            break;
          case 247: // 他に覚えているわざをそれぞれ1回以上使っていないと失敗
            break;
          case 248: // とくせいをふみんにする
            targetState.setCurrentAbility(pokeData.abilities[15]!, myState,
                targetPlayerType == PlayerType.me, state);
            break;
          case 249: // 相手より先に発動し、相手がこうげきわざを選んでいる場合のみ成功
            break;
          case 250: // 場にどくびしを設置する
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.toxicSpikes);
            if (findIdx < 0) {
              targetIndiField.add(
                  IndividualField(IndividualField.toxicSpikes)..extraArg1 = 1);
            } else {
              targetIndiField[findIdx].extraArg1 = 2;
            }
            break;
          case 251: // 使用者の各能力変化と相手の各能力変化を入れ替える
            List<int> myStatChanges =
                List.generate(7, (i) => myState.statChanges(i));
            for (int i = 0; i < 7; i++) {
              myState.forceSetStatChanges(i, targetState.statChanges(i));
            }
            for (int i = 0; i < 7; i++) {
              targetState.forceSetStatChanges(i, myStatChanges[i]);
            }
            break;
          case 252: // 使用者をアクアリング状態にする
            myState.ailmentsAdd(Ailment(Ailment.aquaRing), state);
            break;
          case 253: // 使用者をでんじふゆう状態にする
            myState.ailmentsAdd(Ailment(Ailment.magnetRise), state);
            break;
          case 254: // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2;
            } else {
              myState.remainHPPercent -= extraArg2;
            }
            break;
          case 256: // 使用者はダイビング状態になり、次のターンにこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.diving), state);
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.diving);
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (myState.currentAbility.id == 241) {
                  // うのミサイル
                  if (!myState.buffDebuffs.containsByAnyID(
                      [BuffDebuff.unomiForm, BuffDebuff.marunomiForm])) {
                    if (myPlayerType == PlayerType.me
                        ? myState.remainHP > myState.pokemon.h.real / 2
                        : myState.remainHPPercent > 50) {
                      myState.buffDebuffs.add(
                          pokeData.buffDebuffs[BuffDebuff.unomiForm]!.copy());
                    } else {
                      myState.buffDebuffs.add(pokeData
                          .buffDebuffs[BuffDebuff.marunomiForm]!
                          .copy());
                    }
                  }
                }
              }
            }
            break;
          case 257: // 使用者はあなをほる状態になり、次のターンにこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.digging), state);
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.digging);
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 258: // ダイビング状態でも命中し、その場合ダメージ2倍
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.diving)
                .isNotEmpty) mTwice = true;
            if (myState.currentAbility.id == 241) {
              // うのミサイル
              if (!myState.buffDebuffs.containsByAnyID(
                  [BuffDebuff.unomiForm, BuffDebuff.marunomiForm])) {
                if (myPlayerType == PlayerType.me
                    ? myState.remainHP > myState.pokemon.h.real / 2
                    : myState.remainHPPercent > 50) {
                  myState.buffDebuffs
                      .add(pokeData.buffDebuffs[BuffDebuff.unomiForm]!.copy());
                } else {
                  myState.buffDebuffs.add(
                      pokeData.buffDebuffs[BuffDebuff.marunomiForm]!.copy());
                }
              }
            }
            break;
          case 259: // かいひを1段階下げる。相手のひかりのかべ・リフレクター・オーロラベール・しんぴのまもり・しろいきりを消す
            // 使用者・相手の場にあるまきびし・どくびし・とがった岩・ねばねばネットを取り除く。フィールドを解除する
            targetState.addStatChanges(targetState == myState, 6, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetIndiField.removeWhere((e) =>
                e.id == IndividualField.reflector ||
                e.id == IndividualField.lightScreen ||
                e.id == IndividualField.auroraVeil ||
                e.id == IndividualField.safeGuard ||
                e.id == IndividualField.mist ||
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            myFields.removeWhere((e) =>
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            state.field = Field(0);
            break;
          case 260: // 場をトリックルームにする/解除する
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.trickRoom);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.trickRoom));
            } else {
              targetIndiField.removeAt(findIdx);
            }
            break;
          case 262: // バインド状態にする。ダイビング中の相手にはダメージ2倍
            targetState.ailmentsAdd(Ailment(Ailment.partiallyTrapped), state);
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.diving)
                .isNotEmpty) mTwice = true;
            break;
          case 263: // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2;
            } else {
              myState.remainHPPercent -= extraArg2;
            }
            break;
          case 264: // 使用者はそらをとぶ状態になり、次のターンにこうげきする。相手をまひ状態にする(確率)
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.flying), state);
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.flying);
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (extraArg1 != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
                }
              }
            }
            break;
          case 266: // 性別が異なる場合、相手のとくこうを2段階下げる
            if (myState.sex != Sex.none &&
                targetState.sex != Sex.none &&
                myState.sex != targetState.sex) {
              targetState.addStatChanges(targetState == myState, 2, -2, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
            }
            break;
          case 267: // 場にとがった岩を発生させる
            if (targetIndiField
                .where((e) => e.id == IndividualField.stealthRock)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.stealthRock));
            }
            break;
          case 269: // 持っているプレートに応じてわざのタイプが変わる
            if (myState.holdingItem != null) {
              switch (myState.holdingItem!.id) {
                case 275: // ひのたまプレート
                  moveType = PokeType.fire;
                  break;
                case 276: // しずくプレート
                  moveType = PokeType.water;
                  break;
                case 277: // いかずちプレート
                  moveType = PokeType.electric;
                  break;
                case 278: // みどりのプレート
                  moveType = PokeType.grass;
                  break;
                case 279: // つららのプレート
                  moveType = PokeType.ice;
                  break;
                case 280: // こぶしのプレート
                  moveType = PokeType.fight;
                  break;
                case 281: // もうどくプレート
                  moveType = PokeType.poison;
                  break;
                case 282: // だいちのプレート
                  moveType = PokeType.ground;
                  break;
                case 283: // あおぞらプレート
                  moveType = PokeType.fly;
                  break;
                case 284: // ふしぎのプレート
                  moveType = PokeType.psychic;
                  break;
                case 285: // たまむしプレート
                  moveType = PokeType.bug;
                  break;
                case 286: // がんせきプレート
                  moveType = PokeType.rock;
                  break;
                case 287: // もののけプレート
                  moveType = PokeType.ghost;
                  break;
                case 288: // りゅうのプレート
                  moveType = PokeType.dragon;
                  break;
                case 289: // こわもてプレート
                  moveType = PokeType.evil;
                  break;
                case 290: // こつてつプレート
                  moveType = PokeType.steel;
                  break;
                case 684: // せいれいプレート
                  moveType = PokeType.fairy;
                  break;
                default:
                  break;
              }
            }
            break;
          case 271: // 使用者はひんしになる。場にみかづきのまいを発生させる
            myFields.add(IndividualField(IndividualField.lunarDance));
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 273: // 使用者はシャドーダイブ状態になり、次のターンにこうげきする。まもる等の状態を取り除いてこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.shadowForcing), state);
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState
                    .ailmentsRemoveWhere((e) => e.id == Ailment.shadowForcing);
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 274: // 相手をやけど状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (extraArg2 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 275: // 相手をこおり状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            }
            if (extraArg2 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 276: // 相手をまひ状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            }
            if (extraArg2 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 278: // 使用者のこうげき・めいちゅうを1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 5, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 279: // そのターンの間、複数のポケモンが対象になるわざから守る
            break;
          case 280: // 相手と使用者のぼうぎょ・とくぼうをそれぞれ平均値にする
            {
              int maxAvg =
                  ((myState.maxStats.b.real + targetState.maxStats.b.real) / 2)
                      .floor();
              int minAvg =
                  ((myState.minStats.b.real + targetState.minStats.b.real) / 2)
                      .floor();
              myState.maxStats.b.real = maxAvg;
              myState.minStats.b.real = minAvg;
              targetState.maxStats.b.real = maxAvg;
              targetState.minStats.b.real = minAvg;
              maxAvg =
                  ((myState.maxStats.d.real + targetState.maxStats.d.real) / 2)
                      .floor();
              minAvg =
                  ((myState.minStats.d.real + targetState.minStats.d.real) / 2)
                      .floor();
              myState.maxStats.d.real = maxAvg;
              myState.minStats.d.real = minAvg;
              targetState.maxStats.d.real = maxAvg;
              targetState.minStats.d.real = minAvg;
            }
            break;
          case 281: // 相手と使用者のこうげき・とくこうをそれぞれ平均値にする
            {
              int maxAvg =
                  ((myState.maxStats.a.real + targetState.maxStats.a.real) / 2)
                      .floor();
              int minAvg =
                  ((myState.minStats.a.real + targetState.minStats.a.real) / 2)
                      .floor();
              myState.maxStats.a.real = maxAvg;
              myState.minStats.a.real = minAvg;
              targetState.maxStats.a.real = maxAvg;
              targetState.minStats.a.real = minAvg;
              maxAvg =
                  ((myState.maxStats.c.real + targetState.maxStats.c.real) / 2)
                      .floor();
              minAvg =
                  ((myState.minStats.c.real + targetState.minStats.c.real) / 2)
                      .floor();
              myState.maxStats.c.real = maxAvg;
              myState.minStats.c.real = minAvg;
              targetState.maxStats.c.real = maxAvg;
              targetState.minStats.c.real = minAvg;
            }
            break;
          case 282: //場をワンダールームにする/解除する
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.wonderRoom);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.wonderRoom));
            } else {
              targetIndiField.removeAt(findIdx);
            }
            break;
          case 283: // 相手のとくぼうではなくぼうぎょでダメージ計算する
            invDeffense = true;
            break;
          case 284: // 相手がどく・もうどく状態のとき威力2倍
            if (targetState
                .ailmentsWhere(
                    (e) => e.id == Ailment.poison || e.id == Ailment.badPoison)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 285: // 使用者のすばやさを2段階上げる。おもさが100kg軽くなる(SV使用不可のため処理なし)
            break;
          case 286: // 相手をテレキネシス状態にする
            targetState.ailmentsAdd(Ailment(Ailment.telekinesis), state);
            break;
          case 287: //場をマジックルームにする/解除する
            int findIdx = targetIndiField
                .indexWhere((e) => e.id == IndividualField.magicRoom);
            if (findIdx < 0) {
              targetState.holdingItem
                  ?.clearPassiveEffect(targetState, clearForm: false);
              targetIndiField.add(IndividualField(IndividualField.magicRoom));
              targetState.hiddenBuffs
                  .add(pokeData.buffDebuffs[BuffDebuff.magicRoom]!.copy());
            } else {
              targetIndiField.removeAt(findIdx);
              targetState.holdingItem
                  ?.processPassiveEffect(targetState, processForm: false);
              targetState.hiddenBuffs.removeAllByID(BuffDebuff.magicRoom);
            }
            break;
          case 288: // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
          case 373: // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
            targetState.ailmentsAdd(Ailment(Ailment.antiAir), state);
            targetState.ailmentsRemoveWhere((e) =>
                e.id == Ailment.magnetRise ||
                e.id == Ailment.telekinesis ||
                e.id == Ailment.flying); // でんじふゆう/テレキネシス/そらをとぶは解除
            break;
          case 289: // かならず急所に当たる
            break;
          case 290: // 相手の隣にいるポケモンにも最大HP1/16のダメージ
            break;
          case 291: // 使用者のとくこう・とくぼう・すばやさを1段階ずつ上げる
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 292: // 使用者のおもさと相手のおもさの比率によって威力がかわる。ちいさくなる状態の相手に必中、その場合ダメージが2倍
            {
              int myWeight = myState.weight;
              if (targetState.buffDebuffs.containsByID(BuffDebuff.heavy2)) {
                myWeight *= 2;
              }
              if (targetState.buffDebuffs.containsByID(BuffDebuff.heavy0_5)) {
                myWeight = (myWeight / 2).floor();
              }
              if (targetState.holdingItem?.id == 582) {
                myWeight = (myWeight / 2).floor();
              }
              int targetWeight = targetState.weight;
              if (targetWeight <= myWeight / 5) {
                movePower[0] = 120;
              } else if (targetWeight <= myWeight / 4) {
                movePower[0] = 100;
              } else if (targetWeight <= myWeight / 3) {
                movePower[0] = 80;
              } else if (targetWeight <= myWeight / 2) {
                movePower[0] = 60;
              } else {
                movePower[0] = 40;
              }
              if (targetState
                  .ailmentsWhere((e) => e.id == Ailment.minimize)
                  .isNotEmpty) mTwice = true;
            }
            break;
          case 293: // 使用者と同じタイプを持つポケモンに対してのみ有効
            break;
          case 294: // 相手よりすばやさが速いほど威力が大きくなる
            damageGetter?.showDamage = false;
            break;
          case 295: // 相手のタイプをみず単体に変更する
            if (!targetState.isTerastaling) {
              targetState.type1 = PokeType.water;
              targetState.type2 = null;
            }
            break;
          case 296: // 使用者のすばやさを1段階上げる
          case 467: // 使用者のすばやさを1段階上げる。急所に当たりやすい
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 298: // 使用者のこうげきとランク補正ではなく相手のこうげきとランク補正でダメージ計算する
            isFoulPlay = true;
            break;
          case 299: // 相手のとくせいをたんじゅんに変える
            targetState.setCurrentAbility(pokeData.abilities[86]!, myState,
                targetPlayerType == PlayerType.me, state);
            break;
          case 300: // 相手のとくせいを使用者のとくせいと同じにする
            if (extraArg1 != 0) {
              targetState.setCurrentAbility(pokeData.abilities[extraArg1]!,
                  myState, targetPlayerType == PlayerType.me, state);
            }
            break;
          case 301: // 選択対象の行動順を、このわざの直後に変更する
            break;
          case 302: // 同じターンにこのわざを複数が使用すると、1体目が使用した直後に2体目がこのわざを使う。後で使った方は威力120
            break;
          case 303: // 毎ターン場の誰かが使用し続けた場合(当たらなくてもよい)、40ずつ威力が高くなる。max200。
            damageGetter?.showDamage = false;
            break;
          case 304: // 相手のランク補正を無視してダメージを与える
            ignoreTargetRank = true;
            break;
          case 305: // 相手の能力ランクを0にする
            targetState.resetStatChanges();
            break;
          case 306: // 使用者の能力ランク+1ごとに威力+20
            int plus = 0;
            for (int i = 0; i < 7; i++) {
              if (myState.statChanges(i) > 0) plus += myState.statChanges(i);
            }
            movePower[0] = movePower[0]! + plus * 20;
            break;
          case 308: // 位置を入れ替える(代わりにわざを受けたりできる)
            break;
          case 309: // 使用者のぼうぎょ・とくぼうをそれぞれ1段階下げ、こうげき・とくこう・すばやさを2段階ずつ上げる
            myState.addStatChanges(true, 0, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 310: // 相手のHPを最大HP1/2だけ回復する
            bool isMegaLauncher =
                myState.buffDebuffs.containsByID(BuffDebuff.wave1_5);
            if (myPlayerType == PlayerType.me) {
              targetState.remainHPPercent += isMegaLauncher ? 75 : 50;
            } else {
              targetState.remainHPPercent += isMegaLauncher
                  ? (targetState.pokemon.h.real * 3 / 4).floor()
                  : (targetState.pokemon.h.real / 2).floor();
            }
            break;
          case 311: // 相手が状態異常のとき威力2倍
            if (targetState
                .ailmentsWhere((e) => e.id <= Ailment.sleep)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 312: // 1ターン目で相手を空に連れ去り(両者はそらをとぶ状態)、2ターン目にこうげき。連れ去っている間は相手は行動できない。ひこうタイプにはダメージがない(SV使用不可のため処理なし)
            break;
          case 313: // 使用者のこうげきを1段階、すばやさを2段階上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 315: // 相手のきのみ・ノーマルジュエルを失わせる
            targetState.holdingItem = null;
            break;
          case 316: // 相手の行動順をそのターンの1番最後にする
            break;
          case 317: // 使用者のこうげき・とくこうをそれぞれ1段階上げる。天気がはれの場合はさらに1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            if (state.weather.id == Weather.sunny) {
              myState.addStatChanges(true, 0, 1, targetState,
                  moveId: replacedMove.id);
              myState.addStatChanges(true, 2, 1, targetState,
                  moveId: replacedMove.id);
            }
            break;
          case 318: // 使用者がもちものを持っていない場合威力2倍
            if (myState.holdingItem == null) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 319: // 相手と同じタイプになる
            if (targetState.isTerastaling) {
              myState.type1 = targetState.teraType1;
            } else {
              myState.type1 = targetState.type1;
              myState.type2 = targetState.type2;
              if (targetState
                  .ailmentsWhere((e) => e.id == Ailment.halloween)
                  .isNotEmpty) {
                myState.ailmentsAdd(Ailment(Ailment.halloween), state);
              }
              if (targetState
                  .ailmentsWhere((e) => e.id == Ailment.forestCurse)
                  .isNotEmpty) {
                myState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
              }
            }
            break;
          case 320: // 味方がひんしになった次のターンに使った場合威力2倍
            damageGetter?.showDamage = false;
            break;
          case 321: // 使用者の残りHP分の固定ダメージを与える。使用者はひんしになる
            if (myPlayerType == PlayerType.me) {
              damageCalc = loc.battleDamageFixed6(myState.remainHP);
            } else {
              damageGetter?.showDamage = false;
            }
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 322: // 使用者のとくこうを3段階上げる
            myState.addStatChanges(true, 2, 3, targetState,
                moveId: replacedMove.id);
            break;
          case 323: // 使用者のこうげき・ぼうぎょ・めいちゅうをそれぞれ1段階上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 5, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 324: // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
            if (extraArg1 != 0) {
              targetState.holdingItem = pokeData.items[extraArg1]!;
              myState.holdingItem = null;
            }
            break;
          case 325: // みずのちかい・ほのおのちかい・くさのちかい 同時に使用するとフィールドに変化が起こる
          case 326:
          case 327:
            break;
          case 328: // 使用者のこうげき・とくこうをそれぞれ1段階上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 329: // 使用者のぼうぎょを3段階上げる
            myState.addStatChanges(true, 1, 3, targetState,
                moveId: replacedMove.id);
            break;
          case 330: // ねむり状態にする(確率)。メロエッタのフォルムが変わる
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.sleep), state);
            }
            final findIdx = myState.buffDebuffs.list.indexWhere((element) => [
                  BuffDebuff.voiceForm,
                  BuffDebuff.stepForm
                ].contains(element.id));
            if (findIdx >= 0) {
              if (myState.buffDebuffs.list[findIdx].id ==
                  BuffDebuff.voiceForm) {
                myState.buffDebuffs.list[findIdx] =
                    pokeData.buffDebuffs[BuffDebuff.stepForm]!.copy();
                myState.buffDebuffs.list[findIdx].changeForm(myState);
              } else {
                myState.buffDebuffs.list[findIdx] =
                    pokeData.buffDebuffs[BuffDebuff.voiceForm]!.copy();
                myState.buffDebuffs.list[findIdx].changeForm(myState);
              }
            }
            break;
          case 332: // 1ターン目にため、2ターン目でこうげきする。まひ状態にする(確率)
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (extraArg1 != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
                }
              }
            }
            break;
          case 333: // 1ターン目にため、2ターン目でこうげきする。やけど状態にする(確率)
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                if (extraArg1 != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.burn), state);
                }
              }
            }
            break;
          case 335: // 使用者のぼうぎょ・とくぼう・すばやさがそれぞれ1段階下がる
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 336: // 直前に成功したわざがクロスサンダーだった場合威力2倍。こおり状態を治す(SV使用不可のため処理なし)
            //myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            break;
          case 337: // 直前に成功したわざがクロスフレイムだった場合威力2倍(SV使用不可のため処理なし)
            break;
          case 338: // わざのタイプにひこうタイプの2つの相性を組み合わせてダメージ計算する。ちいさくなる状態の相手に必中し、その場合はダメージ2倍
            additionalMoveType = PokeType.fly;
            if (targetState
                .ailmentsWhere((e) => e.id == Ailment.minimize)
                .isNotEmpty) mTwice = true;
            break;
          case 339: // 戦闘中にきのみを食べた場合のみ使用可能
            break;
          case 340: // くさタイプのポケモンのこうげき・とくこうを1段階上げる。地面にいるポケモンにのみ有効(SV使用不可のため処理なし)
            break;
          case 341: // 場にねばねばネットを設置する
            if (targetIndiField
                .where((e) => e.id == IndividualField.stickyWeb)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.stickyWeb));
            }
            break;
          case 342: // このわざで相手を倒すと使用者のこうげきが3段階上がる
            if ((targetPlayerType == PlayerType.me &&
                    targetState.remainHP - realDamage <= 0) ||
                (targetPlayerType == PlayerType.opponent &&
                    targetState.remainHPPercent - percentDamage <= 0)) {
              myState.addStatChanges(true, 0, 3, targetState,
                  moveId: replacedMove.id);
            }
            break;
          case 343: // 相手のタイプにゴーストを追加する
            if (!targetState.isTypeContain(PokeType.ghost)) {
              targetState
                  .ailmentsRemoveWhere((e) => e.id == Ailment.forestCurse);
              targetState.ailmentsAdd(Ailment(Ailment.halloween), state);
            }
            break;
          case 344: // こうげき・とくこうを1段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 345: // 場をプラズマシャワー状態にする
            if (targetIndiField
                .where((e) => e.id == IndividualField.ionDeluge)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.ionDeluge));
            }
            break;
          case 347: // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            if (getChangePokemonIndex(myPlayerType) != null) {
              // processChangeEffect()で処理
            }
            break;
          case 348: // 相手の能力変化を逆にする
            for (int i = 0; i < 7; i++) {
              targetState.forceSetStatChanges(i, -targetState.statChanges(i));
            }
            break;
          case 350: // そのターンに受ける自分・味方対象の変化技をすべて無効化(SV使用不可のため処理なし)
            break;
          case 351: // 場のすべてのくさタイプポケモンのぼうぎょを1段階上げる(SV使用不可のため処理なし)
            break;
          case 352: // 場をグラスフィールドにする
            targetField!.field = Field(Field.grassyTerrain)
              ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 353: // 場をミストフィールドにする
            targetField!.field = Field(Field.mistyTerrain)
              ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 354: // そうでん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.electrify), state);
            break;
          case 355: // 場をフェアリーロック状態にする
            if (targetIndiField
                .where((e) => e.id == IndividualField.fairyLock)
                .isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.fairyLock));
            }
            break;
          case 356: // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手のこうげきを1段階下げる。シールドフォルムにフォルムチェンジする
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            myState.buffDebuffs
                .changeID(BuffDebuff.bladeForm, BuffDebuff.shieldForm);
            break;
          case 357: // こうげきを1段階下げる。まもる・みがわり状態を無視する
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 360: // 必中。まもる系統の状態を除外してこうげきする。みがわり状態を無視する
            break;
          case 362: // そのターンに受けるわざを無効化し、直接攻撃を使用した相手のHPを最大HP1/8分減らす
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 363: // とくぼうを1段階上げる
            targetState.addStatChanges(targetState == myState, 3, 1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 364: // こうげき・とくこう・すばやさを1段階下げる。相手がどく/もうどく状態でないと失敗する
            if (targetState
                .ailmentsWhere(
                    (e) => e.id == Ailment.poison || e.id == Ailment.badPoison)
                .isNotEmpty) {
              targetState.addStatChanges(targetState == myState, 0, -1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 2, -1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 4, -1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
            }
            break;
          case 366: // 1ターンためて、2ターン目に使用者のとくこう・とくぼう・すばやさをそれぞれ2段階ずつ上げる
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
                myState.addStatChanges(true, 2, 2, targetState,
                    moveId: replacedMove.id);
                myState.addStatChanges(true, 3, 2, targetState,
                    moveId: replacedMove.id);
                myState.addStatChanges(true, 4, 2, targetState,
                    moveId: replacedMove.id);
              }
            }
            break;
          case 367: // とくせいがプラスかマイナスのポケモンのぼうぎょ・とくぼうを1段階ずつ上げる
            if (targetState.currentAbility.id == 57 ||
                targetState.currentAbility.id == 58) {
              targetState.addStatChanges(targetState == myState, 1, 1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 3, 1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
            }
            break;
          case 368: // トレーナー戦後にもらえる賞金が2倍になる
            break;
          case 369: // 場をエレキフィールドにする
            targetField!.field = Field(Field.electricTerrain)
              ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 376: // 相手のタイプにくさを追加する
            if (!targetState.isTypeContain(PokeType.grass)) {
              targetState.ailmentsRemoveWhere((e) => e.id == Ailment.halloween);
              targetState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
            }
            break;
/*          case 378:   // ふんじん状態にする(SVで使用不可のため処理なし)
            targetState.ailmentsAdd(Ailment(Ailment.powder), state);
            break;*/
          case 380: // こおりにする(確率)。みずタイプのポケモンに対しても効果ばつぐんとなる
            targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            break;
          case 384: // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手をどく状態にする
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 386: // やけど状態を治す
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.burn);
            break;
          case 388: // 相手のこうげきを1段階下げ、下げる前のこうげき実数値と同じ値だけ使用者のHPを回復する
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            // 相手こうげき確定
            if (myPlayerType == PlayerType.me) {
              int drain = extraArg1.abs();
              if (myState.remainHP < myState.pokemon.h.real && drain > 0) {
                if (myState.holdingItem?.id == 273) {
                  // おおきなねっこ
                  int tmp = ((drain.toDouble() + 0.5) / 1.3).round();
                  while (roundOff5(tmp * 1.3) > drain) {
                    tmp--;
                  }
                  drain = tmp;
                }
                int attack = targetState.getNotRankedStat(StatIndex.A, drain);
                // TODO: この時点で努力値等を反映するのかどうかとか
                if (attack != targetState.minStats.a.real ||
                    attack != targetState.maxStats.a.real) {
                  ret.add(Guide()
                    ..guideId = Guide.sapConfAttack
                    ..args = [attack, attack]
                    ..guideStr = loc.battleGuideSapConfAttack(
                        attack, targetState.pokemon.omittedName));
                }
              }
              targetState.addStatChanges(targetState == myState, 0, -1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
            }
            break;
          case 389: // 相手をちゅうもくのまと状態にする
            targetState.ailmentsAdd(Ailment(Ailment.attention), state);
            break;
          case 390: // 相手のすばやさを1段階下げ、どく状態する
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            break;
          case 391: // 次のターンまで、使用者のこうげきが必ず急所に当たるようになる
            break;
          case 392: // プラスまたはマイナスのとくせいを持つポケモンのこうげきととくこうを1段階上げる(SV使用不可のため処理なし)
            break;
          case 393: // じごくづき状態にする
            targetState.ailmentsAdd(Ailment(Ailment.throatChop), state);
            break;
          case 394: // 対象が味方の場合のみ、最大HPの1/2を回復する
            break;
          case 395: // 場をサイコフィールドにする
          case 415: // 場をサイコフィールドにする
            targetField!.field = Field(Field.psychicTerrain)
              ..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 398: // 使用者がほのおタイプでないと失敗する。成功するとほのおタイプを失う。こおり状態を治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (!myState.isTerastaling) {
              if (myState.type1 == PokeType.fire) {
                if (myState.type2 == null) {
                  myState.type1 = PokeType.unknown; // タイプなし
                } else {
                  myState.type1 = myState.type2!;
                  myState.type2 = null;
                }
              } else if (myState.type2 != null &&
                  myState.type2! == PokeType.fire) {
                myState.type2 = null;
              }
            }
            break;
          case 399: // 使用者と相手のすばやさ実数値を入れ替える
            int tmpMax = myState.maxStats.s.real;
            int tmpMin = myState.minStats.s.real;
            myState.maxStats.s.real = targetState.maxStats.s.real;
            myState.minStats.s.real = targetState.minStats.s.real;
            targetState.maxStats.s.real = tmpMax;
            targetState.minStats.s.real = tmpMin;
            break;
          case 400: // 相手の状態異常を治し、使用者のHPを最大HP半分だけ回復する(SV使用不可のため処理なし)
            break;
          case 401: // わざのタイプが使用者のタイプ1のタイプになる
            moveType =
                myState.isTerastaling ? myState.teraType1 : myState.type1;
            break;
          case 402: // そのターンですでに行動を終えた相手をとくせいなし状態にする
            targetState.ailmentsAdd(Ailment(Ailment.abilityNoEffect), state);
            break;
          case 403: // 対象が直前に使用したわざをもう一度使わせる
            break;
          case 404: // わざ発動前に直接攻撃を受けると、その相手をやけど状態にする(SV使用不可のため処理なし)
            break;
          case 405: // 使用者のぼうぎょが1段階下がる
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 407: // 場にオーロラベールを発生させる。天気がゆきの場合のみ成功する
            if (state.weather.id == Weather.snowy) {
              if (myFields
                  .where((e) => e.id == IndividualField.auroraVeil)
                  .isEmpty) {
                myFields.add(IndividualField(IndividualField.auroraVeil)
                  ..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
              }
            }
            break;
          case 408: // このターンでこのわざを使用する前に物理技を受けた場合のみこうげき可能
            break;
          case 409: // 使用者が前のターンで動けなかった/使用したわざが失敗したとき威力2倍
            damageGetter?.showDamage = false;
            break;
          case 410: // 相手のランク補正のうち、ランク+1以上をすべて使用者に移し替えてからこうげきする。みがわり状態を無視する
            for (int i = 0; i < 7; i++) {
              if (targetState.statChanges(i) > 0) {
                myState.addStatChanges(
                    true, i, targetState.statChanges(i), targetState,
                    moveId: replacedMove.id);
                targetState.forceSetStatChanges(i, 0);
              }
            }
            break;
          case 411: // 相手のとくせいを無視してこうげきする
            ignoreAbility = true;
            break;
          case 412: // 相手のこうげき・とくこう1段階ずつ下げる。相手の回避率、まもるに関係なく必ず当たる
            targetState.addStatChanges(targetState == myState, 0, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          // このへんからZわざ
          case 413: // 相手の残りHP3/4の固定ダメージ
            damageGetter?.showDamage = false;
            break;
          case 414: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ2段階ずつ上がる
            myState.addStatChanges(true, 0, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 2, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState,
                moveId: replacedMove.id);
            break;
          case 416: // 使用者のランク補正混みのステータスがたかい方に合わせて特殊わざ/物理わざとなる。相手のとくせいを無視する
            break;
          case 418: // フィールドを解除する
            state.field = Field(0);
            break;
          case 419: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 421: // 相手がダイマックスしているとダメージ2倍
          case 436: // 相手がダイマックスしているとダメージ2倍
            break;
          case 422: // 相手のとくせいに引き寄せられない。ちゅうもくのまとやサイドチェンジの影響を受けない。急所に当たりやすい
            break;
          case 423: // 使用者と相手をにげられない状態にする
            if (!myState.isTypeContain(PokeType.ghost) &&
                !targetState.isTypeContain(PokeType.ghost)) {
              myState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
              targetState.ailmentsAdd(
                  Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
            }
            break;
          case 424: // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
            if (extraArg1 != 0) {
              final itemEffect = TurnEffectItem(
                  player: playerType, timing: Timing.action, itemID: extraArg1);
              itemEffect.processEffect(ownParty, ownState, opponentParty,
                  opponentState, state, prevAction,
                  loc: loc);
              myState.holdingItem = null;
              myState.addStatChanges(true, 1, 2, targetState,
                  moveId: replacedMove.id);
            }
            break;
          case 425: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる
            // 使用者はにげられない状態になる。1度効果が発動したあとに使用しても失敗する
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
            break;
          case 426: // すばやさを1段階下げる。タールショット状態にする
            targetState.addStatChanges(targetState == myState, 4, -1, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.tarShot), state);
            break;
          case 427: // 相手のタイプをエスパー単タイプにする
            if (!targetState.isTerastaling) {
              targetState.type1 = PokeType.psychic;
              targetState.type2 = null;
            }
            break;
          case 428: // こうげきできる対象が1体なら2回の連続こうげき、2体いるならそれぞれに1回ずつこうげき
            break;
          case 429: // 持っているきのみを消費し、その効果を受けさせる
            //TODO
            targetState.holdingItem = null;
            break;
          case 430: // にげられない状態とたこがため状態にする
            if (!targetState.isTypeContain(PokeType.ghost)) {
              targetState.ailmentsAdd(
                  Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
              targetState.ailmentsAdd(Ailment(Ailment.octoLock), state);
            }
            break;
          case 431: // まだ行動していないポケモンに対して使うと威力2倍
            damageGetter?.showDamage = false;
            break;
          case 432: // 使用者と相手の場の状態を入れ替える
            // いやしのねがい・みかづきのまい・みらいにこうげき・ねがいごとは入れ替えない
            bool isMyH = myFields
                .where((e) => e.id == IndividualField.healingWish)
                .isNotEmpty;
            bool isMyL = myFields
                .where((e) => e.id == IndividualField.lunarDance)
                .isNotEmpty;
            bool isMyF = myFields
                .where((e) => e.id == IndividualField.futureAttack)
                .isNotEmpty;
            bool isMyW =
                myFields.where((e) => e.id == IndividualField.wish).isNotEmpty;
            bool isTaH = targetIndiField
                .where((e) => e.id == IndividualField.healingWish)
                .isNotEmpty;
            bool isTaL = targetIndiField
                .where((e) => e.id == IndividualField.lunarDance)
                .isNotEmpty;
            bool isTaF = targetIndiField
                .where((e) => e.id == IndividualField.futureAttack)
                .isNotEmpty;
            bool isTaW = targetIndiField
                .where((e) => e.id == IndividualField.wish)
                .isNotEmpty;
            myFields.removeWhere((e) =>
                e.id == IndividualField.healingWish ||
                e.id == IndividualField.lunarDance ||
                e.id == IndividualField.futureAttack ||
                e.id == IndividualField.wish);
            targetIndiField.removeWhere((e) =>
                e.id == IndividualField.healingWish ||
                e.id == IndividualField.lunarDance ||
                e.id == IndividualField.futureAttack ||
                e.id == IndividualField.wish);
            var tmp = myFields;
            myFields = targetIndiField;
            targetIndiField = tmp;
            if (isMyH) {
              myFields.add(IndividualField(IndividualField.healingWish));
            }
            if (isMyL) {
              myFields.add(IndividualField(IndividualField.lunarDance));
            }
            if (isMyF) {
              myFields.add(IndividualField(IndividualField.futureAttack));
            }
            if (isMyW) myFields.add(IndividualField(IndividualField.wish));
            if (isTaH) {
              targetIndiField.add(IndividualField(IndividualField.healingWish));
            }
            if (isTaL) {
              targetIndiField.add(IndividualField(IndividualField.lunarDance));
            }
            if (isTaF) {
              targetIndiField
                  .add(IndividualField(IndividualField.futureAttack));
            }
            if (isTaW) {
              targetIndiField.add(IndividualField(IndividualField.wish));
            }
            effectOnce = true;
            break;
          case 433: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            break;
          case 434: // こうげきの代わりにぼうぎょの数値とランク補正を使ってダメージを計算する
            defenseAltAttack = true;
            break;
          case 435: // こうげき・とくこうを2段階ずつ上げる
            targetState.addStatChanges(targetState == myState, 0, 2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, 2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 437: // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
            if (myState.buffDebuffs.containsByID(BuffDebuff.harapekoForm)) {
              moveType = PokeType.evil;
            }
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 442: // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手のぼうぎょを2段階下げる
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 443: // 2～5回連続でこうげきする。使用者のぼうぎょが1段階下がり、すばやさが1段階上がる
            myState.addStatChanges(true, 1, -1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 444: // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
            // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
            // ステラタイプにテラスタルしたときのみ威力が100になり、成功すると自分のこうげき・とくこうが1段階ずつ下がる
            if (myState.isTerastaling) {
              moveType = myState.teraType1;
            }
            if (myState.teraType1 == PokeType.stellar) {
              // ステラタイプの場合
              movePower[0] = 100;
              myState.addStatChanges(true, 0, -1, targetState,
                  moveId: replacedMove.id);
              myState.addStatChanges(true, 2, -1, targetState,
                  moveId: replacedMove.id);
            }
            // ステータスが確定している場合
            if (myState.maxStats.a.real == myState.minStats.a.real &&
                myState.maxStats.c.real == myState.minStats.c.real) {
              if (myState.getRankedStat(
                    myState.maxStats.a.real,
                    StatIndex.A,
                  ) >
                  myState.getRankedStat(
                    myState.maxStats.c.real,
                    StatIndex.C,
                  )) {
                moveDamageClassID = 2; // ぶつりわざに変更
              }
            } else {
              useLargerAC = true;
            }
            break;
          case 445: // ひんし状態のポケモンを最大HPの1/2を回復して復活させる
            {
              int targetIdx = extraArg1;
              if (targetIdx != 0) {
                var target =
                    state.getPokemonStates(myPlayerType)[targetIdx - 1];
                if (myPlayerType == PlayerType.me) {
                  target.remainHP = (target.pokemon.h.real / 2).floor();
                } else {
                  target.remainHPPercent = 50;
                }
                target.isFainting = false;
              }
            }
            break;
          case 446: // サイコフィールドの効果を受けているとき威力1.5倍・相手全体へのこうげきになる
            if (state.field.id == Field.psychicTerrain &&
                myState.isGround(state.getIndiFields(myPlayerType))) {
              movePower[0] = (movePower[0]! * 1.5).floor();
            }
            break;
          case 447: // 場にフィールドが発生しているときのみ成功し、フィールドを解除する
            state.field = Field(Field.none);
            break;
          case 448: // 1ターン目に使用者のとくこうを1段階上げて(ためて)、2ターン目にこうげきする
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                      ..extraArg1 = replacedMove.id);
                myState.addStatChanges(true, 2, 1, targetState,
                    moveId: replacedMove.id);
                damageGetter?.showDamage = false;
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 449: // ぶつりわざであるときの方がダメージが大きい場合は物理技になる。どく状態にする(確率)
            // ステータスが確定している場合
            if (myState.maxStats.a.real == myState.minStats.a.real &&
                myState.maxStats.c.real == myState.minStats.c.real) {
              if (myState.getRankedStat(
                    myState.maxStats.a.real,
                    StatIndex.A,
                  ) >
                  myState.getRankedStat(
                    myState.maxStats.c.real,
                    StatIndex.C,
                  )) {
                moveDamageClassID = 2; // ぶつりわざに変更
              }
            } else {
              damageGetter?.showDamage = false;
            }
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 450: // 使用者はひんしになる。ミストフィールドの効果を受けているとき威力1.5倍
            if (state.field.id == Field.mistyTerrain &&
                myState.isGround(state.getIndiFields(myPlayerType))) {
              movePower[0] = (movePower[0]! * 1.5).floor();
            }
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 451: // グラスフィールドの効果を受けているとき優先度が高くなる
            break;
          case 452: // 対象がエレキフィールドの効果を受けているとき威力2倍
            if (state.field.id == Field.electricTerrain &&
                targetState.isGround(state.getIndiFields(targetPlayerType))) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 453: // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
            if (myState.isGround(state.getIndiFields(myPlayerType))) {
              switch (state.field.id) {
                case Field.electricTerrain:
                  moveType = PokeType.electric;
                  movePower[0] = movePower[0]! * 2;
                  break;
                case Field.grassyTerrain:
                  moveType = PokeType.grass;
                  movePower[0] = movePower[0]! * 2;
                  break;
                case Field.mistyTerrain:
                  moveType = PokeType.fairy;
                  movePower[0] = movePower[0]! * 2;
                  break;
                case Field.psychicTerrain:
                  moveType = PokeType.psychic;
                  movePower[0] = movePower[0]! * 2;
                  break;
              }
            }
            break;
          case 454: // 対象がそのターンに能力が上がっているとやけど状態にする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            break;
          case 455: // このターンに使用者の能力が下がっていた場合、威力2倍
            if (myState.hiddenBuffs
                .containsByID(BuffDebuff.thisTurnDownStatChange)) {
              movePower[0] = movePower[0]! * 2;
            }
            break;
          case 456: // 対象にもちものがあるときのみ成功
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent &&
                targetState.getHoldingItem()?.id == 0) {
              if (extraArg1 != 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1]
                  ..guideStr = loc.battleGuideConfItem2(
                      pokeData.items[extraArg1]!.displayName,
                      opponentPokemonState.pokemon.omittedName));
                targetState.holdingItem = pokeData.items[extraArg1]!;
              }
            }
            break;
          case 457: // 対象のもちものを消失させる
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent &&
                targetState.getHoldingItem()?.id == 0) {
              if (extraArg1 != 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1]
                  ..guideStr = loc.battleGuideConfItem1(
                      pokeData.items[extraArg1]!.displayName,
                      opponentPokemonState.pokemon.omittedName));
                targetState.holdingItem = pokeData.items[extraArg1]!;
              }
            }
            targetState.holdingItem = null;
            break;
          case 458: // 自分以外の味方全員のこうげきとぼうぎょを1段階ずつ上げる
            break;
          case 459: // 3回連続でこうげきする。こうげきのたびに威力が20ずつ上がる
            movePower[1] = movePower[0]! + 20;
            movePower[2] = movePower[0]! + 40;
            break;
          case 460: // やけど状態にする(確率)。使用者、対象ともにこおりを治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 461: // 最大HP1/4回復、状態異常を治す
            targetState.remainHP -= extraArg1;
            targetState.remainHPPercent -= extraArg2;
            targetState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            break;
          case 462: // 3回連続でこうげきする。かならず急所に当たる
            break;
          case 463: // 相手が最後に消費したわざのPPを3減らす
            if (targetState.lastMove != null) {
              int targetID = targetState.moves
                  .indexWhere((e) => e.id == targetState.lastMove!.id);
              if (targetID >= 0 && targetID < targetState.usedPPs.length) {
                targetState.usedPPs[targetID] += 3;
              }
            }
            break;
          case 464: // どく・まひ・ねむりのいずれかにする(確率)
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(extraArg1), state);
            }
            break;
          case 465: // 使用者のこうげき・ぼうぎょ・すばやさを1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 466: // 対象がどく・もうどく状態なら威力2倍。どくにする(確率)
            if (targetState
                .ailmentsWhere(
                    (e) => e.id == Ailment.poison || e.id == Ailment.badPoison)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 468: // 相手のぼうぎょを1段階下げる(確率)。相手をひるませる(確率)。急所に当たりやすい
            if (extraArg1 != 0) {
              targetState.addStatChanges(targetState == myState, 1, 1, myState,
                  myFields: yourFields,
                  yourFields: myFields,
                  moveId: replacedMove.id);
            }
            if (extraArg2 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 469: // 対象が状態異常の場合威力2倍。やけど状態にする(確率)
            if (targetState
                .ailmentsWhere((e) => e.id <= Ailment.sleep)
                .isNotEmpty) {
              movePower[0] = movePower[0]! * 2;
            }
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 473: // 使用者のとくこう・とくぼうを1段階ずつ上げる。使用者の状態異常を回復する
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState,
                moveId: replacedMove.id);
            myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            break;
          case 474: // そのターンに受けるわざを無効化し、直接攻撃を使用した相手のすばやさを1段階下げる
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 475: // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2;
            } else {
              myState.remainHPPercent -= extraArg2;
            }
            break;
          case 476: // その戦闘で味方がひんしになるたび、威力が50ずつ上がる
            int faintingNum = state.getFaintingCount(playerType);
            movePower[0] = movePower[0]! + (faintingNum) * 50;
            break;
          case 477: // ヘイラッシャがシャリタツを飲み込んでいた場合、使用者の能力を上げる
            break;
          case 478: // 対象のこうげきを2段階上げ、ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, 2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -2, myState,
                myFields: yourFields,
                yourFields: myFields,
                moveId: replacedMove.id);
            break;
          case 479: // 使用者のすばやさを2段階下げる
            myState.addStatChanges(true, 4, -2, targetState,
                moveId: replacedMove.id);
            break;
          case 480: // 最大10回連続でこうげきする
            break;
          case 481: // 次に使用者が行動するまでの間相手から受けるわざ必中・ダメージ2倍
            if (myState.buffDebuffs
                .containsByID(BuffDebuff.certainlyHittedDamage2)) {
              myState.buffDebuffs.add(pokeData
                  .buffDebuffs[BuffDebuff.certainlyHittedDamage2]!
                  .copy());
            }
            break;
          case 482: // しおづけ状態にする
            if (targetState.holdingItem?.id != 1701 &&
                targetState.currentAbility.id != 19) {
              targetState.ailmentsAdd(Ailment(Ailment.saltCure), state);
            }
            break;
          case 483: // 3回連続でこうげきする
            break;
          case 484: // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。対象をどく状態にする(確率)
            myState.ailmentsRemoveWhere((e) =>
                e.id == Ailment.partiallyTrapped || e.id == Ailment.leechSeed);
            myFields.removeWhere((e) =>
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 485: // 使用者の最大HP1/2(小数点以下切り捨て)を消費してこうげき・とくこう・すばやさを1段階ずつ上げる
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 486: // 必中かつ必ず急所に当たる
            break;
          case 487: // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき。ケンタロスのフォルムによってわざのタイプが変化する
            targetIndiField.removeWhere((e) =>
                e.id == IndividualField.reflector ||
                e.id == IndividualField.lightScreen ||
                e.id == IndividualField.auroraVeil);
            switch (myState.pokemon.no) {
              case 10250:
                moveType = PokeType.fight;
                break;
              case 10251:
                moveType = PokeType.fire;
                break;
              case 10252:
                moveType = PokeType.water;
                break;
            }
            break;
          case 488: // 使用者のとくこうを1段階下げる。戦闘後、このわざの使用回数×レベル×5円のお金をもらえる
            myState.addStatChanges(true, 2, -1, targetState,
                moveId: replacedMove.id);
            break;
          case 489: // 場がエレキフィールドのとき威力1.5倍
            if (state.field.id == Field.electricTerrain) {
              movePower[0] = (movePower[0]! * 1.5).floor();
            }
            break;
          case 490: // はれによるダメージ補正率が0.5倍→1.5倍。使用者・対象のこおり状態を治す
            if (!myState.buffDebuffs.containsByID(BuffDebuff.sheerForce)) {
              isSunny1_5 = true;
            }
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            break;
          case 491: // 効果がばつぐんの場合、威力4/3倍
            if (PokeTypeEffectiveness.effectiveness(
                    myState.currentAbility.id == 113 ||
                        myState.currentAbility.id == 299,
                    yourState.holdingItem?.id == 586,
                    yourState
                        .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                        .isNotEmpty,
                    moveType,
                    targetState) ==
                MoveEffectiveness.great) {
              movePower[0] = (movePower[0]! / 3 * 4).floor();
            }
            break;
          case 492: // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
            myState.remainHP -= extraArg1;
            myState.remainHPPercent -= extraArg2;
            if (getChangePokemonIndex(myPlayerType) != null) {
              // processChangeEffect()で処理
            }
            break;
          case 493: // 天気をゆきにして控えと交代
            state.weather = Weather(Weather.snowy)
              ..extraArg1 = myState.holdingItem?.id == 259 ? 8 : 5;
            if (getChangePokemonIndex(myPlayerType) != null) {
              // processChangeEffect()で処理
            }
            effectOnce = true;
            break;
          case 494: // 両者のみがわり、設置技を解除。使用者のこうげき・すばやさを1段階ずつ上げる
            myState.buffDebuffs.removeAllByID(BuffDebuff.substitute);
            targetState.buffDebuffs.removeAllByID(BuffDebuff.substitute);
            myFields.removeWhere((e) =>
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            yourFields.removeWhere((e) =>
                e.id == IndividualField.spikes ||
                e.id == IndividualField.toxicSpikes ||
                e.id == IndividualField.stealthRock ||
                e.id == IndividualField.stickyWeb);
            myState.addStatChanges(true, 0, 1, targetState,
                moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState,
                moveId: replacedMove.id);
            break;
          case 495: // 天気をゆきにする
            state.weather = Weather(Weather.snowy)
              ..extraArg1 = myState.holdingItem?.id == 259 ? 8 : 5;
            effectOnce = true;
            break;
          case 496: // その戦闘でこうげき技のダメージを受けるたびに威力+50。(最大350)
            {
              final founds =
                  myState.hiddenBuffs.whereByID(BuffDebuff.attackedCount);
              if (founds.isNotEmpty) {
                movePower[0] = movePower[0]! + founds.first.extraArg1 * 50;
              }
            }
            break;
          case 497: // 使用者がでんきタイプの場合のみ成功。でんきタイプを失くす
            if (myState.type1 == PokeType.electric) {
              if (myState.type2 != null) {
                myState.type1 = myState.type2!;
              } else {
                myState.type1 = PokeType.unknown;
              }
            } else if (myState.type2 != null &&
                myState.type2! == PokeType.electric) {
              myState.type2 = null;
            }
            break;
          case 498: // 使用者が最後にPP消費したわざがこのわざだった場合、選択できない
            break;
          case 500: // 与えたダメージの半分だけ回復する。両者のこおり状態を消す。相手をやけど状態にする(確率)
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1 != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2;
            } else {
              myState.remainHPPercent -= extraArg2;
            }
            break;
          case 501: // あめまみれ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.candyCandy), state);
            break;
          case 502: // オーガポンのフォルムによってわざのタイプが変わる
            {
              int no = myState.buffDebuffs.containsByID(BuffDebuff.transform)
                  ? myState.buffDebuffs
                      .whereByID(BuffDebuff.transform)
                      .first
                      .extraArg1
                  : myState.pokemon.no;
              switch (no) {
                case 1017: // オーガポン(みどりのめん)->くさ
                  moveType = PokeType.grass;
                  break;
                case 10273: // オーガポン(いどのめん)->みず
                  moveType = PokeType.water;
                  break;
                case 10274: // オーガポン(かまどのめん)->ほのお
                  moveType = PokeType.fire;
                  break;
                case 10275: // オーガポン(いしずえのめん)->いわ
                  moveType = PokeType.rock;
                  break;
              }
            }
            break;
          case 503: // 1ターン目に使用者のとくこうを1段階上げて(ためて)、2ターン目にこうげきする。1ターン目の天気があめ→ためずにこうげき。
            {
              if (!myState.hiddenBuffs.containsByID(BuffDebuff.chargingMove)) {
                // 溜め状態にする
                myState.addStatChanges(true, 2, 1, targetState,
                    moveId: replacedMove.id);
                if (state.weather.id != Weather.rainy) {
                  myState.hiddenBuffs.add(
                      pokeData.buffDebuffs[BuffDebuff.chargingMove]!.copy()
                        ..extraArg1 = replacedMove.id);
                  damageGetter?.showDamage = false;
                }
              } else {
                // こうげきする
                myState.hiddenBuffs.removeAllByID(BuffDebuff.chargingMove);
              }
            }
            break;
          case 504: // ステラフォルムのテラパゴスが使用した場合、ステラタイプの攻撃になり、相手全員が対象になる
            if (myState.buffDebuffs.containsByID(BuffDebuff.stellarForm)) {
              moveType = PokeType.stellar;
            }
            break;
          case 505: // 威力が2倍になる(確率)
            movePower[0] = movePower[0]! * 2;
            break;
          case 506: // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手をやけど状態にする
            myState.ailmentsAdd(
                Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 507: // 2回連続こうげき。必中
            break;
          case 508: // 相手の残りHPが多いほど威力が高くなる(100×相手の残りHP/相手の最大HP)
            if (targetPlayerType == PlayerType.me) {
              movePower[0] =
                  (100 * targetState.remainHP / targetState.pokemon.h.real)
                      .floor();
            } else {
              movePower[0] = (100 * targetState.remainHPPercent / 100).floor();
            }
            break;
          case 509: // 使用者以外の味方全員をきゅうしょアップ状態にする(ドラゴンタイプは+2,それ以外は+1)
            break;
          case 510: // 対象がそのターンに能力が上がっているとこんらん状態にする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 511: // かいふくふうじ状態にする
            targetState.ailmentsAdd(
                Ailment(Ailment.healBlock)..extraArg1 = 2, state);
            break;
          case 512: // 対象が先制攻撃技を使おうとしているとき、かつ使用者の方が先に行動する場合のみ成功。ひるませる(確率)。
            targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            break;
          default:
            break;
        }

        // ノーマルスキンによるわざタイプ変更
        if (myState.buffDebuffs.containsByID(BuffDebuff.normalize)) {
          if (moveType != PokeType.normal) {
            moveType = PokeType.normal;
          }
        }
        // そうでんによるわざタイプ変更
        if (myState
            .ailmentsWhere((e) => e.id == Ailment.electrify)
            .isNotEmpty) {
          moveType = PokeType.electric;
        }

        // わざの相性をここで変えちゃう
        moveEffectivenesses = PokeTypeEffectiveness.effectiveness(
          myState.currentAbility.id == 113 || myState.currentAbility.id == 299,
          yourState.holdingItem?.id == 586,
          yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
          moveType,
          targetState,
        );
      }

      // わざで交代した場合、交代前のstateで計算する。それを元に戻すために仮変数に退避
      var tmpState = myState;

      // ダメージ計算式
      if (damageGetter != null && damageGetter.showDamage) {
        var damage = calcDamage(
          myState,
          targetStates[0],
          state,
          playerType,
          replacedMove,
          moveType,
          movePower,
          moveDamageClassID,
          beforeChangeMyState,
          isCritical,
          isFoulPlay,
          defenseAltAttack,
          ignoreTargetRank,
          invDeffense,
          isSunny1_5,
          ignoreAbility,
          mTwice,
          additionalMoveType,
          halvedBerry,
          useLargerAC,
          loc: loc,
        );
        damageCalc ??= damage.item1;
        damageGetter.maxDamage = damage.item2;
        damageGetter.minDamage = damage.item3;
        damageGetter.maxDamagePercent =
            (damage.item2 * 100 / targetStates[0].minStats.h.real).floor();
        damageGetter.minDamagePercent =
            (damage.item3 * 100 / targetStates[0].maxStats.h.real).floor();
        isTeraStellarHosei = damage.item4;

        ret.add(Guide()
          ..guideId = Guide.damageCalc
          ..guideStr = damageCalc
          ..canDelete = false);
      }

      // 交代前stateを参照していた場合向けに、myStateを元に戻す
      myState = tmpState;

      // ミクルのみのこうかが残っていれば消費
      myState.buffDebuffs.removeFirstByID(BuffDebuff.onceAccuracy1_2);
      // ノーマルジュエル消費
      if (myState.holdingItem?.id == 669 &&
          moveDamageClassID >= 2 &&
          moveType == PokeType.normal) {
        myState.holdingItem = null;
      }
      // くっつきバリ移動
      if (replacedMove.isDirect &&
          !(replacedMove.isPunch &&
              myState.holdingItem?.id == 1700) && // パンチグローブをつけたパンチわざでない
          myState.holdingItem == null &&
          yourState.holdingItem?.id == 265) {
        myState.holdingItem = yourState.holdingItem;
        yourState.holdingItem = null;
      }

      switch (moveDamageClassID) {
        case 1: // へんか
          break;
        case 2: // ぶつり
        case 3: // とくしゅ
          {
            // ダメージを負わせる
            for (var targetState in targetStates) {
              // みがわりなし/貫通わざかどうかの判定(現在は不要)
              /*if (!targetState.buffDebuffs
                      .containsByID(BuffDebuff.substitute) ||
                  replacedMove.isSound ||
                  myState.buffDebuffs.containsByID(BuffDebuff.ignoreWall)) {*/
              targetState.remainHP -= realDamage;
              targetState.remainHPPercent -= percentDamage;
              // こうげきを受けた数をカウント
              final findIdx = targetState.hiddenBuffs.list.indexWhere(
                  (element) => element.id == BuffDebuff.attackedCount);
              if (findIdx >= 0) {
                targetState.hiddenBuffs.list[findIdx].extraArg1++;
              } else {
                targetState.hiddenBuffs.add(
                    pokeData.buffDebuffs[BuffDebuff.attackedCount]!.copy()
                      ..extraArg1 = 1);
              }
              // あいてポケモンのステータス確定
              if (playerType == PlayerType.opponent &&
                  realDamage > 0 &&
                  targetState.remainHP > 0) {
                var reals = calcRealFromDamage(
                  realDamage,
                  myState,
                  targetStates[0],
                  state,
                  playerType,
                  replacedMove,
                  moveType,
                  movePower,
                  moveDamageClassID,
                  beforeChangeMyState,
                  isCritical,
                  isFoulPlay,
                  defenseAltAttack,
                  ignoreTargetRank,
                  invDeffense,
                  isSunny1_5,
                  ignoreAbility,
                  mTwice,
                  additionalMoveType,
                  halvedBerry,
                  isTeraStellarHosei,
                  loc: loc,
                );
                if (reals.item1.index > StatIndex.H.index) {
                  // もともとある範囲より狭まるようにのみ上書き
                  int minS = opponentPokemonState
                      .minStats[StatIndex.values[reals.item1.index]].real;
                  int maxS = opponentPokemonState
                      .maxStats[StatIndex.values[reals.item1.index]].real;
                  bool addGuide = false;
                  // もちもの等の影響で、推定した最小値が現在の最大値より大きくなった場合
                  if (maxS < reals.item3) {
                    // TODO: とくせいやもちものの提案
                    // TODO: 判定方法
                    final sugAList = opponentPokemonState.possibleAbilities
                        .where((element) => element.possiblyChangeStat
                            .where((e) =>
                                e.item1 ==
                                    StatIndex.values[reals.item1.index] &&
                                e.item2 > 100)
                            .isNotEmpty);
                    if (sugAList.isNotEmpty) {
                      ret.add(Guide()
                        ..guideId = Guide.suggestAbilities
                        ..guideStr = ''
                        ..args = [for (final sugA in sugAList) sugA.id]);
                    }
                    final sugIList = pokeData.items.values.where((element) =>
                        element.id != 0 &&
                        !opponentPokemonState.impossibleItems
                            .contains(element) &&
                        element.possiblyChangeStat
                            .where((e) =>
                                e.item1 ==
                                    StatIndex.values[reals.item1.index] &&
                                e.item2 > 100)
                            .isNotEmpty);
                    if (sugIList.isNotEmpty) {
                      ret.add(Guide()
                        ..guideId = Guide.suggestItems
                        ..guideStr = ''
                        ..args = [for (final sugI in sugIList) sugI.id]);
                    }
                    minS = maxS;
                    addGuide = true;
                  } else if (minS < reals.item3) {
                    minS = reals.item3;
                    addGuide = true;
                  }
                  // もちもの等の影響で、推定した最大値が現在の最小値より小さくなった場合
                  if (reals.item2 < minS) {
                    // TODO: とくせいやもちものの提案
                    ret.add(Guide()
                      ..guideId = Guide.suggestAbilities
                      ..guideStr = ''
                      ..args = []);
                    maxS = minS;
                    addGuide = true;
                  } else if (maxS > reals.item2) {
                    maxS = reals.item2;
                    addGuide = true;
                  }
                  if (addGuide) {
                    ret.add(Guide()
                      ..guideId = Guide.moveDamagedToStatus
                      ..guideStr = loc.battleGuideMoveDamagedToStatus(
                          maxS,
                          minS,
                          opponentPokemonState.pokemon.omittedName,
                          reals.item1.name)
                      ..args = [
                        reals.item1.index,
                        minS,
                        maxS,
                      ]
                      ..canDelete = true);
                  }
                }
              }
              if (breakSubstitute) {
                targetState.buffDebuffs.removeAllByID(BuffDebuff.substitute);
              }
            }
          }
          break;
        default:
          break;
      }
    }

    // あいてポケモンのすばやさ確定
    if (isFirst != null &&
        !isFirst! &&
        state.firstAction != null &&
        state.firstAction!.type == TurnActionType.move) {
      if (move.priority == state.firstAction!.move.priority) {
        // わざの優先度が同じ
        // もともとある範囲より狭まるようにのみ上書き
        int minS = opponentPokemonState.minStats.s.real;
        int maxS = opponentPokemonState.maxStats.s.real;
        bool addGuide = false;
        if (playerType == PlayerType.me) {
          if (minS < ownPokemonState.minStats.s.real) {
            // TODO: 交代わざ用に、ターンの最初のポケモンステートが良い
            minS = ownPokemonState.minStats.s.real;
            addGuide = true;
          }
        } else {
          if (maxS > ownPokemonState.maxStats.s.real) {
            // TODO: 交代わざ用に、ターンの最初のポケモンステートが良い
            maxS = ownPokemonState.maxStats.s.real;
            addGuide = true;
          }
        }
        if (addGuide) {
          ret.add(Guide()
            ..guideId = Guide.moveOrderConfSpeed
            ..guideStr = loc.battleGuideMoveOrderConfSpeed(
                maxS, minS, opponentPokemonState.pokemon.omittedName)
            ..args = [
              minS,
              maxS,
            ]
            ..canDelete = true);
        }
      }
    }

    // 最後に使用した(PP消費した)わざセット
    myState.lastMove = move;

    super.afterProcessEffect(ownState, opponentState, state);

    return ret;
  }

  void processChangeEffect(
    PokemonState ownState,
    PokemonState opponentState,
    PhaseState state,
  ) {
    final pokeData = PokeDB();
    var myState = playerType == PlayerType.me ? ownState : opponentState;
    var yourState = playerType == PlayerType.me ? opponentState : ownState;
    PlayerType myPlayerType = playerType;
    PlayerType yourPlayerType =
        playerType == PlayerType.me ? PlayerType.opponent : PlayerType.me;
    Move replacedMove = getReplacedMove(move, myState); // 必要に応じてわざの内容変更
    // わざの対象決定
    PokemonState targetState = yourState;
    PlayerType targetPlayerType = yourPlayerType;
    switch (replacedMove.target) {
      case Target.specificMove: // 不定、わざによって異なる のろいとかカウンターとか
        break;
      case Target.selectedPokemonMeFirst: // 選択した自分以外の場にいるポケモン
      // (現状、さきどりとダイマックスわざのみ。SVで使用不可のため考慮しなくて良さそう)
      case Target.ally: // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
        break;
      case Target.usersField: // 使用者の場
      case Target.user: // 使用者自身
      case Target.userOrAlly: // 使用者もしくは味方
      case Target.userAndAllies: // 使用者と味方
      case Target.allAllies: // すべての味方
      case Target.faintingPokemon: // ひんしの(味方)ポケモン
        targetState = myState;
        targetPlayerType = myPlayerType;
        break;
      case Target.opponentsField: // 相手の場
      case Target.randomOpponent: // ランダムな相手
      case Target.allOtherPokemon: // 場にいる使用者以外の全ポケモン
      case Target.selectedPokemon: // 選択した自分以外の場にいるポケモン
      case Target.allOpponents: // 場にいる相手側の全ポケモン
      case Target.entireField: // 全体の場
        break;
      default:
        break;
    }
    switch (moveAdditionalEffects.id) {
      case 29: // 相手ポケモンをランダムに交代させる
      case 314: // 相手ポケモンをランダムに交代させる
        if (getChangePokemonIndex(targetPlayerType) != null) {
          targetState.processExitEffect(myState, state);
          PokemonState newState;
          state.setPokemonIndex(
              playerType.opposite, getChangePokemonIndex(targetPlayerType)!);
          newState = state.getPokemonState(playerType.opposite, null);
          newState.processEnterEffect(myState, state);
          newState.hiddenBuffs
              .add(pokeData.buffDebuffs[BuffDebuff.changedThisTurn]!.copy());
        }
        break;
      case 128: // 控えのポケモンと交代する。能力変化・一部の状態変化は交代後に引き継ぐ
        if (getChangePokemonIndex(myPlayerType) != null) {
          List<int> statChanges =
              List.generate(7, (i) => myState.statChanges(i));
          var takeOverAilments = [
            ...myState.ailmentsWhere((e) =>
                e.id == Ailment.confusion ||
                e.id == Ailment.leechSeed ||
                e.id == Ailment.curse ||
                e.id == Ailment.perishSong ||
                e.id == Ailment.ingrain ||
                e.id == Ailment.healBlock ||
                e.id == Ailment.embargo ||
                e.id == Ailment.magnetRise ||
                e.id == Ailment.telekinesis ||
                e.id == Ailment.abilityNoEffect ||
                e.id == Ailment.aquaRing ||
                e.id == Ailment.powerTrick)
          ];
          var takeOverBuffDebuffs = [
            ...myState.buffDebuffs.whereByAnyID([
              BuffDebuff.vital1,
              BuffDebuff.vital2,
              BuffDebuff.vital3,
              BuffDebuff.substitute
            ])
          ];
          myState.processExitEffect(yourState, state);
          PokemonState newState;
          state.setPokemonIndex(
              playerType, getChangePokemonIndex(myPlayerType)!);
          newState = state.getPokemonState(playerType, null);
          newState.processEnterEffect(yourState, state);
          for (int i = 0; i < 7; i++) {
            newState.forceSetStatChanges(i, statChanges[i]);
          }
          for (var e in takeOverAilments) {
            newState.ailmentsAdd(e, state);
          }
          newState.buffDebuffs.addAll(takeOverBuffDebuffs);
          newState.hiddenBuffs
              .add(pokeData.buffDebuffs[BuffDebuff.changedThisTurn]!.copy());
        }
        break;
      case 347: // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
      case 493: // 天気をゆきにして控えと交代
      case 154: // 控えのポケモンと交代する
      case 229: // 控えのポケモンと交代する
        if (getChangePokemonIndex(myPlayerType) != null) {
          myState.processExitEffect(yourState, state);
          PokemonState newState;
          state.setPokemonIndex(
              playerType, getChangePokemonIndex(myPlayerType)!);
          newState = state.getPokemonState(playerType, null);
          newState.processEnterEffect(yourState, state);
          newState.hiddenBuffs
              .add(pokeData.buffDebuffs[BuffDebuff.changedThisTurn]!.copy());
        }
        break;
      case 492: // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
        if (getChangePokemonIndex(myPlayerType) != null) {
          myState.processExitEffect(yourState, state);
          PokemonState newState;
          state.setPokemonIndex(
              playerType, getChangePokemonIndex(myPlayerType)!);
          newState = state.getPokemonState(playerType, null);
          newState.processEnterEffect(yourState, state);
          newState.buffDebuffs
              .add(pokeData.buffDebuffs[BuffDebuff.substitute]!.copy());
          newState.hiddenBuffs
              .add(pokeData.buffDebuffs[BuffDebuff.changedThisTurn]!.copy());
        }
        break;
      default:
        break;
    }
  }

  /// わざのダメージを計算する
  /// ```
  /// myState: 自身のポケモンの状態
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// myPlayerType: 自身のタイプ(ユーザーか対戦相手か)
  /// move: 使用するわざ(「ものまね」等の、置き換わるわざは置き換え済みのものを渡す)
  /// replacedMoveType: 使用するわざのタイプ(「ものまね」等の、置き換わるわざは置き換え済みのものを渡す)
  /// power: 威力
  /// damageClassID: わざの分類のID
  /// beforeChangeMyState: ポケモンが交代するなら交換前のポケモンの状態
  /// isCritical: 急所かどうか
  /// isFoulPlay: イカサマかどうか
  /// defenseAltAttack: こうげきではなくぼうぎょの値でダメージ計算するかどうか
  /// ignoreTargetRank: 相手の能力ランクを無視するかどうか
  /// invDeffense: 相手のとくぼうではなくぼうぎょでダメージ計算するかどうか
  /// isSunny1_5: 晴れ下でダメージ1.5倍かどうか
  /// ignoreAbility: 相手とくせいを無視するかどうか
  /// mTwice: 2倍補正がかかるかどうか
  /// additionalMoveType: わざの追加タイプ
  /// halvedBerry: 相手が半減きのみを食べたかどうか
  /// useLargerAC: こうげき/とくこうのうちどちらの値を使うか不明だが、大きい方を使うかどうか
  ///
  /// 戻り値item1: ダメージ計算式
  ///       item2: ダメージ最大値
  ///       item3: ダメージ最小値
  ///       item4: テラスステラの補正がかかったかどうか
  /// ```
  Tuple4<String, int, int, bool> calcDamage(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    PlayerType myPlayerType,
    Move move,
    PokeType replacedMoveType,
    Map<int, int> power,
    int damageClassID,
    PokemonState beforeChangeMyState,
    bool isCritical,
    bool isFoulPlay,
    bool defenseAltAttack,
    bool ignoreTargetRank,
    bool invDeffense,
    bool isSunny1_5,
    bool ignoreAbility,
    bool mTwice,
    PokeType? additionalMoveType,
    double halvedBerry,
    bool useLargerAC, {
    required AppLocalizations loc,
  }) {
    Move replacedMove = move;
    var myFields = state.getIndiFields(myPlayerType);
    var yourFields = state.getIndiFields(myPlayerType.opposite);
    String ret = '';
    bool isTeraStellarHosei = false;
    int maxDamage = 0;
    int minDamage = 0;

    // 連続わざのヒット回数分ループ
    for (int i = 0; i < hitCount; i++) {
      int movePower = power[i]!;
      // TODO:CSVに反映？
      // じゅうでん補正&消費
      int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.charging);
      if (findIdx >= 0 && replacedMoveType == PokeType.electric) {
        movePower *= 2;
        myState.ailmentsRemoveAt(findIdx);
      }

      if (getChangePokemonIndex(myPlayerType) != null) {
        myState = beforeChangeMyState;
      }

      // とくせい等によるわざタイプの変更
      {
        replacedMoveType =
            myState.buffDebuffs.changeMoveType(myState, replacedMoveType);
        if (replacedMove.id != 165 &&
            replacedMoveType == PokeType.normal &&
            myFields.indexWhere((e) => e.id == IndividualField.ionDeluge) >=
                0) {
          replacedMoveType = PokeType.electric;
        }
      }

      // とくせい等による威力変動
      {
        double tmpPow = movePower.toDouble();
        tmpPow = myState.buffDebuffs.changeMovePower(myState, yourState, tmpPow,
            damageClassID, replacedMove, replacedMoveType, myState.holdingItem,
            isFirst: isFirst);

        // フィールド効果
        if (replacedMoveType == PokeType.electric &&
            myState.isGround(myFields) &&
            state.field.id == Field.electricTerrain) tmpPow *= 1.3;
        if (replacedMoveType == PokeType.grass &&
            myState.isGround(myFields) &&
            state.field.id == Field.grassyTerrain) tmpPow *= 1.3;
        if (replacedMoveType == PokeType.psychic &&
            myState.isGround(myFields) &&
            state.field.id == Field.psychicTerrain) tmpPow *= 1.3;
        if (replacedMoveType == PokeType.dragon &&
            yourState.isGround(yourFields) &&
            state.field.id == Field.mistyTerrain) tmpPow *= 0.5;
        if (replacedMoveType == PokeType.fire &&
            myFields.indexWhere((e) => e.id == IndividualField.waterSport) >=
                0) {
          tmpPow = tmpPow * 1352 / 4096;
        }
        if (replacedMoveType == PokeType.electric &&
            myFields.indexWhere((e) => e.id == IndividualField.mudSport) >= 0) {
          tmpPow = tmpPow * 1352 / 4096;
        }

        movePower = tmpPow.floor();
        // テラスタイプ一致補正/ステラ補正が入っていて威力60未満なら60に
        if (movePower < 60 &&
            (myState.canGetStellarHosei(replacedMoveType) ||
                myState.canGetTerastalHosei(replacedMoveType))) {
          movePower = 60;
        }
      }

      // 範囲補正・おやこあい補正は無視する(https://wiki.xn--rckteqa2e.com/wiki/%E3%83%80%E3%83%A1%E3%83%BC%E3%82%B8#%E7%AC%AC%E4%BA%94%E4%B8%96%E4%BB%A3%E4%BB%A5%E9%99%8D)
      bool plusIgnore =
          yourState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
      bool minusIgnore = isCritical ||
          yourState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
      int calcMaxAttack =
          myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
              ? myState.finalizedMaxStat(
                  StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : myState.finalizedMaxStat(
                  StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
      int calcMinAttack =
          myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
              ? myState.finalizedMinStat(
                  StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : myState.finalizedMinStat(
                  StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
      if (isFoulPlay) {
        calcMaxAttack =
            yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
                ? yourState.finalizedMaxStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
                : yourState.finalizedMaxStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
        calcMinAttack =
            yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
                ? yourState.finalizedMinStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
                : yourState.finalizedMinStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
      } else if (defenseAltAttack) {
        calcMaxAttack =
            myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
                ? myState.finalizedMaxStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
                : myState.finalizedMaxStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
        calcMinAttack =
            myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
                ? myState.finalizedMinStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
                : myState.finalizedMinStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
      }
      int attackVmax = 0;
      int attackVmin = 0;
      if (useLargerAC) {
        attackVmax = max(
            calcMaxAttack,
            myState.finalizedMaxStat(
                StatIndex.C, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore));
        attackVmin = max(
            calcMinAttack,
            myState.finalizedMinStat(
                StatIndex.C, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore));
      } else {
        attackVmax = damageClassID == 2
            ? calcMaxAttack
            : myState.finalizedMaxStat(
                StatIndex.C, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore);
        attackVmin = damageClassID == 2
            ? calcMinAttack
            : myState.finalizedMinStat(
                StatIndex.C, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore);
      }
      String attackStr = '';
      if (attackVmax == attackVmin) {
        attackStr = attackVmax.toString();
      } else {
        attackStr = '$attackVmin ~ $attackVmax';
      }
      if (isFoulPlay) {
        attackStr += loc.battleDamageAttackerAttack;
      } else {
        attackStr += damageClassID == 2
            ? loc.battleDamageAttackerAttack
            : loc.battleDamageAttackerSAttack;
      }
      plusIgnore =
          isCritical || myState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
      minusIgnore = myState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
      int calcMaxDefense =
          yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
              ? ignoreTargetRank
                  ? yourState.maxStats.b.real
                  : yourState.finalizedMaxStat(
                      StatIndex.B, replacedMoveType, yourState, state,
                      plusCut: plusIgnore, minusCut: minusIgnore)
              : ignoreTargetRank
                  ? yourState.maxStats.a.real
                  : yourState.finalizedMaxStat(
                      StatIndex.A, replacedMoveType, yourState, state,
                      plusCut: plusIgnore, minusCut: minusIgnore);
      int calcMaxSDefense = ignoreTargetRank
          ? yourState.maxStats.d.real
          : yourState.finalizedMaxStat(
              StatIndex.D, replacedMoveType, yourState, state,
              plusCut: plusIgnore, minusCut: minusIgnore);
      int calcMinDefense =
          yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
              ? ignoreTargetRank
                  ? yourState.minStats.b.real
                  : yourState.finalizedMinStat(
                      StatIndex.B, replacedMoveType, yourState, state,
                      plusCut: plusIgnore, minusCut: minusIgnore)
              : ignoreTargetRank
                  ? yourState.minStats.a.real
                  : yourState.finalizedMinStat(
                      StatIndex.A, replacedMoveType, yourState, state,
                      plusCut: plusIgnore, minusCut: minusIgnore);
      int calcMinSDefense = ignoreTargetRank
          ? yourState.minStats.d.real
          : yourState.finalizedMinStat(
              StatIndex.D, replacedMoveType, yourState, state,
              plusCut: plusIgnore, minusCut: minusIgnore);
      int defenseVmax = damageClassID == 2
          ? myFields
                  .where((element) => element.id == IndividualField.wonderRoom)
                  .isEmpty
              ? // ワンダールーム
              calcMaxDefense
              : calcMaxSDefense
          : myFields
                  .where((element) => element.id == IndividualField.wonderRoom)
                  .isEmpty
              ? // ワンダールーム
              invDeffense
                  ? calcMaxDefense
                  : calcMaxSDefense
              : invDeffense
                  ? calcMaxSDefense
                  : calcMaxDefense;
      int defenseVmin = damageClassID == 2
          ? myFields
                  .where((element) => element.id == IndividualField.wonderRoom)
                  .isEmpty
              ? // ワンダールーム
              calcMinDefense
              : calcMinSDefense
          : myFields
                  .where((element) => element.id == IndividualField.wonderRoom)
                  .isEmpty
              ? // ワンダールーム
              invDeffense
                  ? calcMinDefense
                  : calcMinSDefense
              : invDeffense
                  ? calcMinSDefense
                  : calcMinDefense;
      String defenseStr = '';
      if (defenseVmax == defenseVmin) {
        defenseStr = defenseVmax.toString();
      } else {
        defenseStr = '$defenseVmin ~ $defenseVmax';
      }
      if (invDeffense) {
        defenseStr += loc.battleDamageDefenderDefense;
      } else {
        defenseStr += damageClassID == 2
            ? loc.battleDamageDefenderDefense
            : loc.battleDamageDefenderSDefense;
      }
      int damageVmax = (((myState.pokemon.level * 2 / 5 + 2).floor() *
                          movePower *
                          (attackVmax / defenseVmin))
                      .floor() /
                  50 +
              2)
          .floor();
      int damageVmin = (((myState.pokemon.level * 2 / 5 + 2).floor() *
                          movePower *
                          (attackVmin / defenseVmax))
                      .floor() /
                  50 +
              2)
          .floor();
      ret = loc.battleDamageCalcBase(
          myState.pokemon.level, movePower, attackStr, defenseStr);
      // 天気補正(五捨五超入)
      if (yourState.holdingItem?.id != 1181) {
        // 相手がばんのうがさを持っていない
        if (state.weather.id == Weather.sunny) {
          if (replacedMoveType == PokeType.fire) {
            // はれ下ほのおわざ
            damageVmax = roundOff5(damageVmax * 1.5);
            damageVmin = roundOff5(damageVmin * 1.5);
            ret += loc.battleDamageWeather1_5;
          } else if (replacedMoveType == PokeType.water) {
            // はれ下みずわざ
            if (isSunny1_5) {
              damageVmax = roundOff5(damageVmax * 1.5);
              damageVmin = roundOff5(damageVmin * 1.5);
              ret += loc.battleDamageWeather1_5;
            } else {
              damageVmax = roundOff5(damageVmax * 0.5);
              damageVmin = roundOff5(damageVmin * 0.5);
              ret += loc.battleDamageWeather0_5;
            }
          }
        } else if (state.weather.id == Weather.rainy) {
          if (replacedMoveType == PokeType.water) {
            // 雨下みずわざ
            damageVmax = roundOff5(damageVmax * 1.5);
            damageVmin = roundOff5(damageVmin * 1.5);
            ret += loc.battleDamageWeather1_5;
          } else if (replacedMoveType == PokeType.fire) {
            // 雨下ほのおわざ
            damageVmax = roundOff5(damageVmax * 0.5);
            damageVmin = roundOff5(damageVmin * 0.5);
            ret += loc.battleDamageWeather0_5;
          }
        }
      }
      // 急所補正(五捨五超入)
      // TODO
      if (criticalCount > 0) {
        damageVmax = roundOff5(damageVmax * 1.5);
        damageVmin = roundOff5(damageVmin * 1.5);
        ret += loc.battleDamageCritical1_5;
      }
      // 乱数補正(切り捨て)
      damageVmax = (damageVmax * 100 / 100).floor();
      damageVmin = (damageVmin * 85 / 100).floor();
      ret += loc.battleDamageRandom85_100;
      // タイプ一致補正(五捨五超入)
      if (myState.canGetStellarHosei(replacedMoveType)) {
        myState.addStellarUsed(replacedMoveType);
        isTeraStellarHosei = true;
      }
      if (myState.canGetTerastalHosei(replacedMoveType)) {
        isTeraStellarHosei = true;
      }
      var rate = myState.typeBonusRate(replacedMoveType,
          myState.buffDebuffs.containsByID(BuffDebuff.typeBonus2));
      if (rate > 1.0) {
        damageVmax = roundOff5(damageVmax * rate);
        damageVmin = roundOff5(damageVmin * rate);
        ret += loc.battleDamageTypeBonus(rate);
      }
      // 相性補正(切り捨て)
      double typeRate = PokeTypeEffectiveness.effectivenessRate(
        replacedMoveType,
        yourState,
        isScrappyMindEye: myState.currentAbility.id == 113 ||
            myState.currentAbility.id == 299,
        isRingTarget: yourState.holdingItem?.id == 586,
        isMiracleEye: yourState
            .ailmentsWhere((e) => e.id == Ailment.miracleEye)
            .isNotEmpty,
      );
      if (yourState.currentAbility.id == 305 &&
          (yourState.remainHP >= yourState.pokemon.h.real ||
              yourState.remainHPPercent >= 100) &&
          typeRate > 0.5) {
        // テラスシェル
        typeRate = 0.5;
      }
      if (additionalMoveType != null) {
        typeRate *= PokeTypeEffectiveness.effectivenessRate(
          additionalMoveType,
          yourState,
          isScrappyMindEye: myState.currentAbility.id == 113 ||
              myState.currentAbility.id == 299,
          isRingTarget: yourState.holdingItem?.id == 586,
          isMiracleEye: yourState
              .ailmentsWhere((e) => e.id == Ailment.miracleEye)
              .isNotEmpty,
        );
      }
      damageVmax = (damageVmax * typeRate).floor();
      damageVmin = (damageVmin * typeRate).floor();
      ret += loc.battleDamageTypeEffectiveness(typeRate);
      // やけど補正(五捨五超入)
      if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty &&
          damageClassID == 2 &&
          move.id != 263) {
        // からげんき以外のぶつりわざ
        if (!myState.buffDebuffs
            .containsByID(BuffDebuff.attack1_5WithIgnBurn)) {
          damageVmax = roundOff5(damageVmax * 0.5);
          damageVmin = roundOff5(damageVmin * 0.5);
          ret += loc.battleDamageBurned;
        }
      }
      // M(五捨五超入)
      {
        double tmpMax = damageVmax.toDouble();
        double tmpMin = damageVmin.toDouble();
        // 壁補正
        if (!isCritical &&
            !myState.buffDebuffs.containsByID(BuffDebuff.ignoreWall) &&
            ((damageClassID == 2 &&
                    yourFields
                        .where((e) =>
                            e.id == IndividualField.auroraVeil ||
                            e.id == IndividualField.reflector)
                        .isNotEmpty) ||
                (damageClassID == 3 &&
                    yourFields
                        .where((e) =>
                            e.id == IndividualField.auroraVeil ||
                            e.id == IndividualField.lightScreen)
                        .isNotEmpty))) {
          tmpMax *= 0.5;
          tmpMin *= 0.5;
          ret += loc.battleDamageWall;
        }
        // ブレインフォース補正
        if (typeRate >= 2.0 &&
            myState.buffDebuffs.containsByID(BuffDebuff.greatDamage1_25)) {
          tmpMax *= 1.25;
          tmpMin *= 1.25;
          ret += loc.battleDamageBrainForce;
        }
        // スナイパー補正
        // TODO
        //if (moveHits[continuousCount] == MoveHit.critical &&
        if (criticalCount > 0 &&
            myState.buffDebuffs.containsByID(BuffDebuff.sniper)) {
          tmpMax *= 1.5;
          tmpMin *= 1.5;
          ret += loc.battleDamageSniper;
        }
        // いろめがね補正
        if (typeRate > 0.0 &&
            typeRate < 1.0 &&
            myState.buffDebuffs.containsByID(BuffDebuff.notGoodType2)) {
          tmpMax *= 2;
          tmpMin *= 2;
          ret += loc.battleDamageTintedLens;
        }
        // もふもふほのお補正
        if (!ignoreAbility &&
            (damageClassID == 2 || damageClassID == 3) &&
            replacedMoveType == PokeType.fire &&
            yourState.buffDebuffs
                .containsByID(BuffDebuff.fireAttackedDamage2)) {
          tmpMax *= 2;
          tmpMin *= 2;
          ret += loc.battleDamageFluffy;
        }
        // Mhalf
        if (!ignoreAbility &&
                // こおりのりんぷん
                (damageClassID == 3 &&
                    yourState.buffDebuffs
                        .containsByID(BuffDebuff.specialDamaged0_5)) ||
            // パンクロック
            (replacedMove.isSound &&
                yourState.buffDebuffs
                    .containsByID(BuffDebuff.soundedDamage0_5)) ||
            // ファントムガード
            // マルチスケイル
            ((yourState.remainHP >= yourState.pokemon.h.real ||
                    yourState.remainHPPercent >= 100) &&
                yourState.buffDebuffs.containsByID(BuffDebuff.damaged0_5)) ||
            // もふもふ直接こうげき
            (replacedMove.isDirect &&
                !(replacedMove.isPunch && myState.holdingItem?.id == 1700) &&
                yourState.buffDebuffs
                    .containsByID(BuffDebuff.directAttackedDamage0_5)) ||
            // たいねつ
            (replacedMoveType == PokeType.fire &&
                yourState.buffDebuffs.containsByID(BuffDebuff.heatproof))) {
          tmpMax *= 0.5;
          tmpMin *= 0.5;
          ret += loc.battleDamageAbility0_5;
        }
        // Mfilter
        if (!ignoreAbility &&
            // ハードロック
            // フィルター
            // プリズムアーマー
            typeRate >= 2.0 &&
            yourState.buffDebuffs.containsByID(BuffDebuff.greatDamaged0_75)) {
          tmpMax *= 0.75;
          tmpMin *= 0.75;
          ret += loc.battleDamageAbility0_75;
        }
        // たつじんのおび補正
        if (typeRate >= 2.0 &&
            myState.buffDebuffs.containsByID(BuffDebuff.greatDamage1_2)) {
          tmpMax *= 1.2;
          tmpMin *= 1.2;
          ret += loc.battleDamageExpertBelt;
        }
        // メトロノーム補正
        if (myState.buffDebuffs
            .containsByID(BuffDebuff.continuousMoveDamageInc0_2)) {
          final founds =
              myState.hiddenBuffs.whereByID(BuffDebuff.sameMoveCount);
          if (founds.isNotEmpty) {
            int count = founds.first.extraArg1 % 100;
            if (count > 0) {
              tmpMax *= (1.0 + 0.2 * count);
              tmpMin *= (1.0 + 0.2 * count);
              ret += loc.battleDamageMetronome(1.0 + 0.2 * count);
            }
          }
        }
        // いのちのたま補正
        if (myState.buffDebuffs.containsByID(BuffDebuff.lifeOrb)) {
          tmpMax *= 1.3;
          tmpMin *= 1.3;
          ret += loc.battleDamageLifeOrb;
        }
        // 半減きのみ補正
        if (halvedBerry > 0) {
          //double mult = yourState.buffDebuffs[findIdx].ex.copy()traArg1 == 1 ? 0.25 : 0.5;
          tmpMax *= halvedBerry;
          tmpMin *= halvedBerry;
          ret += loc.battleDamageBerry(halvedBerry);
          yourState.hiddenBuffs.removeAllByID(BuffDebuff.halvedBerry);
        }
        // Mtwice
        if (mTwice ||
            yourState.buffDebuffs
                .containsByID(BuffDebuff.certainlyHittedDamage2)) {
          tmpMax *= 2;
          tmpMin *= 2;
          ret += loc.battleDamageOthers;
        }

        damageVmax = roundOff5(tmpMax);
        damageVmin = roundOff5(tmpMin);
        maxDamage += damageVmax;
        minDamage += damageVmin;
      }
      // Mprotect(五捨五超入)
      // ダイマックスわざに関する計算のため、SVでは不要
      {}
      ret += '= $damageVmin ~ $damageVmax';
    }
    return Tuple4(ret, maxDamage, minDamage, isTeraStellarHosei);
  }

  /// わざのダメージから実数値を計算する
  /// ```
  /// realDamage: 受けたダメージ
  /// myState: 自身のポケモンの状態
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// myPlayerType: 自身のタイプ(ユーザーか対戦相手か)
  /// move: 使用するわざ(「ものまね」等の、置き換わるわざは置き換え済みのものを渡す)
  /// replacedMoveType: 使用するわざのタイプ(「ものまね」等の、置き換わるわざは置き換え済みのものを渡す)
  /// power: 威力
  /// damageClassID: わざの分類のID
  /// beforeChangeMyState: ポケモンが交代するなら交換前のポケモンの状態
  /// isCritical: 急所かどうか
  /// isFoulPlay: イカサマかどうか
  /// defenseAltAttack: こうげきではなくぼうぎょの値でダメージ計算するかどうか
  /// ignoreTargetRank: 相手の能力ランクを無視するかどうか
  /// invDeffense: 相手のとくぼうではなくぼうぎょでダメージ計算するかどうか
  /// isSunny1_5: 晴れ下でダメージ1.5倍かどうか
  /// ignoreAbility: 相手とくせいを無視するかどうか
  /// mTwice: 2倍補正がかかるかどうか
  /// additionalMoveType: わざの追加タイプ
  /// halvedBerry: 相手が半減きのみを食べたかどうか
  /// isTeraStellarHosei: テラスステラの補正がかかったかどうか
  ///
  /// 戻り値item1: 計算結果ステータス
  ///       item2: 実数値の最大値
  ///       item3: 実数値の最小値
  /// ```
  Tuple3<StatIndex, int, int> calcRealFromDamage(
    int realDamage,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    PlayerType myPlayerType,
    Move move,
    PokeType replacedMoveType,
    Map<int, int> power,
    int damageClassID,
    PokemonState beforeChangeMyState,
    bool isCritical,
    bool isFoulPlay,
    bool defenseAltAttack,
    bool ignoreTargetRank,
    bool invDeffense,
    bool isSunny1_5,
    bool ignoreAbility,
    bool mTwice,
    PokeType? additionalMoveType,
    double halvedBerry,
    bool isTeraStellarHosei, {
    required AppLocalizations loc,
  }) {
    // ダメージから逆算
    if (isFoulPlay) return Tuple3(StatIndex.H, 0, 0);
    // 連続わざの場合、1回目のこうげきで判断する
    int movePower = power[0]!;
    // 1ヒット目のダメージ
    int firstRealDamage = realDamage;
    if (hitCount > 1) {
      int allPower = 0;
      for (int i = 0; i < hitCount; i++) {
        allPower += power[i]!;
      }
      firstRealDamage = (realDamage * movePower / allPower).ceil();
    }
    Move replacedMove = move;
    var myFields = state.getIndiFields(myPlayerType);
    var yourFields = state.getIndiFields(myPlayerType.opposite);

    // タイプ相性を計算
    double typeRate = PokeTypeEffectiveness.effectivenessRate(
      replacedMoveType,
      yourState,
      isScrappyMindEye:
          myState.currentAbility.id == 113 || myState.currentAbility.id == 299,
      isRingTarget: yourState.holdingItem?.id == 586,
      isMiracleEye:
          yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
    );
    if (yourState.currentAbility.id == 305 &&
        (yourState.remainHP >= yourState.pokemon.h.real ||
            yourState.remainHPPercent >= 100) &&
        typeRate > 0.5) {
      // テラスシェル
      typeRate = 0.5;
    }
    if (additionalMoveType != null) {
      typeRate *= PokeTypeEffectiveness.effectivenessRate(
        additionalMoveType,
        yourState,
        isScrappyMindEye: myState.currentAbility.id == 113 ||
            myState.currentAbility.id == 299,
        isRingTarget: yourState.holdingItem?.id == 586,
        isMiracleEye: yourState
            .ailmentsWhere((e) => e.id == Ailment.miracleEye)
            .isNotEmpty,
      );
    }

    double tmp = firstRealDamage.toDouble();
    int tmpInt = firstRealDamage;
    int tmpMax = firstRealDamage;
    int tmpMin = firstRealDamage;
    // Mprotect(五捨五超入)
    // ダイマックスわざに関する計算のため、SVでは不要
    {}
    // M(五捨五超入)
    {
      // Mtwice
      if (mTwice ||
          yourState.buffDebuffs
              .containsByID(BuffDebuff.certainlyHittedDamage2)) {
        tmp /= 2;
      }
      // 半減きのみ補正
      if (halvedBerry > 0) {
        tmp /= halvedBerry;
      }
      // いのちのたま補正
      if (myState.buffDebuffs.containsByID(BuffDebuff.lifeOrb)) {
        tmp /= 1.3;
      }
      // メトロノーム補正
      if (myState.buffDebuffs
          .containsByID(BuffDebuff.continuousMoveDamageInc0_2)) {
        final founds = myState.hiddenBuffs.whereByID(BuffDebuff.sameMoveCount);
        if (founds.isNotEmpty) {
          int count = founds.first.extraArg1 % 100;
          if (count > 0) {
            tmp /= (1.0 + 0.2 * count);
          }
        }
      }
      // たつじんのおび補正
      if (typeRate >= 2.0 &&
          myState.buffDebuffs.containsByID(BuffDebuff.greatDamage1_2)) {
        tmp /= 1.2;
      }
      // Mfilter
      if (!ignoreAbility &&
          // ハードロック
          // フィルター
          // プリズムアーマー
          typeRate >= 2.0 &&
          yourState.buffDebuffs.containsByID(BuffDebuff.greatDamaged0_75)) {
        tmp /= 0.75;
      }
      // Mhalf
      if (!ignoreAbility &&
              // こおりのりんぷん
              (damageClassID == 3 &&
                  yourState.buffDebuffs
                      .containsByID(BuffDebuff.specialDamaged0_5)) ||
          // パンクロック
          (replacedMove.isSound &&
              yourState.buffDebuffs
                  .containsByID(BuffDebuff.soundedDamage0_5)) ||
          // ファントムガード
          // マルチスケイル
          ((yourState.remainHP >= yourState.pokemon.h.real ||
                  yourState.remainHPPercent >= 100) &&
              yourState.buffDebuffs.containsByID(BuffDebuff.damaged0_5)) ||
          // もふもふ直接こうげき
          (replacedMove.isDirect &&
              !(replacedMove.isPunch && myState.holdingItem?.id == 1700) &&
              yourState.buffDebuffs
                  .containsByID(BuffDebuff.directAttackedDamage0_5)) ||
          // たいねつ
          (replacedMoveType == PokeType.fire &&
              yourState.buffDebuffs.containsByID(BuffDebuff.heatproof))) {
        tmp /= 0.5;
      }
      // もふもふほのお補正
      if (!ignoreAbility &&
          (damageClassID == 2 || damageClassID == 3) &&
          replacedMoveType == PokeType.fire &&
          yourState.buffDebuffs.containsByID(BuffDebuff.fireAttackedDamage2)) {
        tmp /= 2;
      }
      // いろめがね補正
      if (typeRate > 0.0 &&
          typeRate < 1.0 &&
          myState.buffDebuffs.containsByID(BuffDebuff.notGoodType2)) {
        tmp /= 2;
      }
      // スナイパー補正
      // TODO
      //if (moveHits[continuousCount] == MoveHit.critical &&
      if (criticalCount > 0 &&
          myState.buffDebuffs.containsByID(BuffDebuff.sniper)) {
        tmp /= 1.5;
      }
      // ブレインフォース補正
      if (typeRate >= 2.0 &&
          myState.buffDebuffs.containsByID(BuffDebuff.greatDamage1_25)) {
        tmp /= 1.25;
      }
      // 壁補正
      if (!isCritical &&
          !myState.buffDebuffs.containsByID(BuffDebuff.ignoreWall) &&
          ((damageClassID == 2 &&
                  yourFields
                      .where((e) =>
                          e.id == IndividualField.auroraVeil ||
                          e.id == IndividualField.reflector)
                      .isNotEmpty) ||
              (damageClassID == 3 &&
                  yourFields
                      .where((e) =>
                          e.id == IndividualField.auroraVeil ||
                          e.id == IndividualField.lightScreen)
                      .isNotEmpty))) {
        tmp /= 0.5;
      }

      tmpInt = roundOff5(tmp);
    }
    // やけど補正(五捨五超入)
    if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty &&
        damageClassID == 2 &&
        move.id != 263) {
      // からげんき以外のぶつりわざ
      if (!myState.buffDebuffs.containsByID(BuffDebuff.attack1_5WithIgnBurn)) {
        tmpInt = roundOff5(tmpInt / 0.5);
      }
    }
    // 相性補正(切り捨て)
    if (typeRate == 0) {
      tmpInt = 0;
    } else {
      tmpInt = (tmpInt / typeRate).floor();
    }
    // タイプ一致補正(五捨五超入)
    var rate = myState.typeBonusRate(replacedMoveType,
        myState.buffDebuffs.containsByID(BuffDebuff.typeBonus2));
    // ステラタイプ補正を使ってしまったために、再度計算したら値に補正が反映されてない場合
    if (isTeraStellarHosei && myState.teraType1 == PokeType.stellar) {
      if (rate - 1.5 < 0.1) rate = 2.0;
      if (rate - 1.0 < 0.1) rate = 1.2;
    }
    if (rate > 1.0) {
      tmpInt = roundOff5(tmpInt / rate);
    }
    // 乱数補正(切り捨て)
    tmpMin = (tmpInt * 100 / 100).floor();
    tmpMax = (tmpInt * 100 / 85).floor();
    // 急所補正(五捨五超入)
    // TODO
    //if (moveHits[continuousCount] == MoveHit.critical) {
    if (criticalCount > 0) {
      tmpMax = roundOff5(tmpMax / 1.5);
      tmpMin = roundOff5(tmpMin / 1.5);
    }
    // 天気補正(五捨五超入)
    if (yourState.holdingItem?.id != 1181) {
      // 相手がばんのうがさを持っていない
      if (state.weather.id == Weather.sunny) {
        if (replacedMoveType == PokeType.fire) {
          // はれ下ほのおわざ
          tmpMax = roundOff5(tmpMax / 1.5);
          tmpMin = roundOff5(tmpMin / 1.5);
        } else if (replacedMoveType == PokeType.water) {
          // はれ下みずわざ
          if (isSunny1_5) {
            tmpMax = roundOff5(tmpMax / 1.5);
            tmpMin = roundOff5(tmpMin / 1.5);
          } else {
            tmpMax = roundOff5(tmpMax / 0.5);
            tmpMin = roundOff5(tmpMin / 0.5);
          }
        }
      } else if (state.weather.id == Weather.rainy) {
        if (replacedMoveType == PokeType.water) {
          // 雨下みずわざ
          tmpMax = roundOff5(tmpMax / 1.5);
          tmpMin = roundOff5(tmpMin / 1.5);
        } else if (replacedMoveType == PokeType.fire) {
          // 雨下ほのおわざ
          tmpMax = roundOff5(tmpMax / 0.5);
          tmpMin = roundOff5(tmpMin / 0.5);
        }
      }
    }

    // ここからわざ自体の威力等補正

    // じゅうでん補正&消費
    int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.charging);
    if (findIdx >= 0 && replacedMoveType == PokeType.electric) {
      movePower *= 2;
      myState.ailmentsRemoveAt(findIdx);
    }

    if (getChangePokemonIndex(myPlayerType) != null) {
      myState = beforeChangeMyState;
    }

    // とくせい等によるわざタイプの変更
    {
      replacedMoveType =
          myState.buffDebuffs.changeMoveType(myState, replacedMoveType);
      if (replacedMove.id != 165 &&
          replacedMoveType == PokeType.normal &&
          myFields.indexWhere((e) => e.id == IndividualField.ionDeluge) >= 0) {
        replacedMoveType = PokeType.electric;
      }
    }

    // とくせい等による威力変動
    {
      double tmpPow = movePower.toDouble();
      tmpPow = myState.buffDebuffs.changeMovePower(myState, yourState, tmpPow,
          damageClassID, replacedMove, replacedMoveType, myState.holdingItem,
          isFirst: isFirst);

      // フィールド効果
      if (replacedMoveType == PokeType.electric &&
          myState.isGround(myFields) &&
          state.field.id == Field.electricTerrain) tmpPow *= 1.3;
      if (replacedMoveType == PokeType.grass &&
          myState.isGround(myFields) &&
          state.field.id == Field.grassyTerrain) tmpPow *= 1.3;
      if (replacedMoveType == PokeType.psychic &&
          myState.isGround(myFields) &&
          state.field.id == Field.psychicTerrain) tmpPow *= 1.3;
      if (replacedMoveType == PokeType.dragon &&
          yourState.isGround(yourFields) &&
          state.field.id == Field.mistyTerrain) tmpPow *= 0.5;
      if (replacedMoveType == PokeType.fire &&
          myFields.indexWhere((e) => e.id == IndividualField.waterSport) >= 0) {
        tmpPow = tmpPow * 1352 / 4096;
      }
      if (replacedMoveType == PokeType.electric &&
          myFields.indexWhere((e) => e.id == IndividualField.mudSport) >= 0) {
        tmpPow = tmpPow * 1352 / 4096;
      }

      movePower = tmpPow.floor();
      // テラスタイプ一致補正/ステラ補正が入っていて威力60未満なら60に
      if (movePower < 60 && isTeraStellarHosei) {
        movePower = 60;
      }
    }

    bool plusIgnore =
        isCritical || myState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
    bool minusIgnore = myState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
    int calcMaxDefense =
        yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
            ? ignoreTargetRank
                ? yourState.maxStats.b.real
                : yourState.finalizedMaxStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
            : ignoreTargetRank
                ? yourState.maxStats.a.real
                : yourState.finalizedMaxStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMaxSDefense = ignoreTargetRank
        ? yourState.maxStats.d.real
        : yourState.finalizedMaxStat(
            StatIndex.D, replacedMoveType, yourState, state,
            plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinDefense =
        yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
            ? ignoreTargetRank
                ? yourState.minStats.b.real
                : yourState.finalizedMinStat(
                    StatIndex.B, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore)
            : ignoreTargetRank
                ? yourState.minStats.a.real
                : yourState.finalizedMinStat(
                    StatIndex.A, replacedMoveType, yourState, state,
                    plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinSDefense = ignoreTargetRank
        ? yourState.minStats.d.real
        : yourState.finalizedMinStat(
            StatIndex.D, replacedMoveType, yourState, state,
            plusCut: plusIgnore, minusCut: minusIgnore);
    int defenseVmax = damageClassID == 2
        ? myFields
                .where((element) => element.id == IndividualField.wonderRoom)
                .isEmpty
            ? // ワンダールーム
            calcMaxDefense
            : calcMaxSDefense
        : myFields
                .where((element) => element.id == IndividualField.wonderRoom)
                .isEmpty
            ? // ワンダールーム
            invDeffense
                ? calcMaxDefense
                : calcMaxSDefense
            : invDeffense
                ? calcMaxSDefense
                : calcMaxDefense;
    int defenseVmin = damageClassID == 2
        ? myFields
                .where((element) => element.id == IndividualField.wonderRoom)
                .isEmpty
            ? // ワンダールーム
            calcMinDefense
            : calcMinSDefense
        : myFields
                .where((element) => element.id == IndividualField.wonderRoom)
                .isEmpty
            ? // ワンダールーム
            invDeffense
                ? calcMinDefense
                : calcMinSDefense
            : invDeffense
                ? calcMinSDefense
                : calcMinDefense;

    int attackVmax = movePower == 0
        ? 0
        : (((tmpMax - 2) * 50 * defenseVmin) /
                ((myState.pokemon.level * 2 / 5 + 2).floor() * movePower))
            .floor();
    int attackVmin = movePower == 0
        ? 0
        : (((tmpMin - 2) * 50 * defenseVmax) /
                ((myState.pokemon.level * 2 / 5 + 2).floor() * movePower))
            .floor();

    // 範囲補正・おやこあい補正は無視する(https://wiki.xn--rckteqa2e.com/wiki/%E3%83%80%E3%83%A1%E3%83%BC%E3%82%B8#%E7%AC%AC%E4%BA%94%E4%B8%96%E4%BB%A3%E4%BB%A5%E9%99%8D)
    plusIgnore = yourState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
    minusIgnore =
        isCritical || yourState.buffDebuffs.containsByID(BuffDebuff.ignoreRank);
    int ret2 = 0;
    int ret3 = 0;
    // TODO: 一旦放置
    /*if (useLargerAC) {
      attackVmax = max(
          calcMaxAttack,
          myState.finalizedMaxStat(
              StatIndex.C, replacedMoveType, yourState, state,
              plusCut: plusIgnore, minusCut: minusIgnore));
      attackVmin = max(
          calcMinAttack,
          myState.finalizedMinStat(
              StatIndex.C, replacedMoveType, yourState, state,
              plusCut: plusIgnore, minusCut: minusIgnore));
    } else*/
    {
      if (damageClassID != DamageClass.physical) {
        ret2 = myState.unfinalizedStat(
            attackVmax, StatIndex.C, replacedMoveType, yourState, state,
            plusCut: plusIgnore, minusCut: minusIgnore);
        ret3 = myState.unfinalizedStat(
            attackVmin, StatIndex.C, replacedMoveType, yourState, state,
            plusCut: plusIgnore, minusCut: minusIgnore);
      } else {
        ret2 = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
            ? myState.unfinalizedStat(
                attackVmax, StatIndex.A, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore)
            : myState.unfinalizedStat(
                attackVmax, StatIndex.B, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore);
        ret3 = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty
            ? myState.unfinalizedStat(
                attackVmin, StatIndex.A, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore)
            : myState.unfinalizedStat(
                attackVmin, StatIndex.B, replacedMoveType, yourState, state,
                plusCut: plusIgnore, minusCut: minusIgnore);
        // TODO: イカサマって相手のステータス推定に使えないのでは
        if (isFoulPlay) {
          ret2 = yourState
                  .ailmentsWhere((e) => e.id == Ailment.powerTrick)
                  .isEmpty
              ? yourState.unfinalizedStat(
                  attackVmax, StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : yourState.unfinalizedStat(
                  attackVmax, StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
          ret3 = yourState
                  .ailmentsWhere((e) => e.id == Ailment.powerTrick)
                  .isEmpty
              ? yourState.unfinalizedStat(
                  attackVmin, StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : yourState.unfinalizedStat(
                  attackVmin, StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
        } else if (defenseAltAttack) {
          ret2 = myState
                  .ailmentsWhere((e) => e.id == Ailment.powerTrick)
                  .isEmpty
              ? myState.unfinalizedStat(
                  attackVmax, StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : myState.unfinalizedStat(
                  attackVmax, StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
          ret3 = myState
                  .ailmentsWhere((e) => e.id == Ailment.powerTrick)
                  .isEmpty
              ? myState.unfinalizedStat(
                  attackVmin, StatIndex.B, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore)
              : myState.unfinalizedStat(
                  attackVmin, StatIndex.A, replacedMoveType, yourState, state,
                  plusCut: plusIgnore, minusCut: minusIgnore);
        }
      }
    }

    StatIndex retStat = StatIndex.H;
    if (damageClassID == 2) {
      if (defenseAltAttack) {
        if (myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty) {
          retStat = StatIndex.B;
        } else {
          retStat = StatIndex.A;
        }
      } else {
        if (myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty) {
          retStat = StatIndex.A;
        } else {
          retStat = StatIndex.B;
        }
      }
    } else {
      retStat = StatIndex.C;
    }

    int count = 0; // 誤差20までなら修正
    bool loop = true;
    while (count < 20 && loop) {
      loop = false;
      var copiedMyState = myState.copy()
        ..minStats[retStat].real = ret3
        ..maxStats[retStat].real = ret3;
      var ret = calcDamage(
        copiedMyState,
        yourState,
        state,
        myPlayerType,
        move,
        replacedMoveType,
        power,
        damageClassID,
        beforeChangeMyState,
        isCritical,
        isFoulPlay,
        defenseAltAttack,
        ignoreTargetRank,
        invDeffense,
        isSunny1_5,
        ignoreAbility,
        mTwice,
        additionalMoveType,
        halvedBerry,
        // TODO
        false,
        loc: loc,
      );
      if (ret.item2 < realDamage) {
        ret3++;
        loop = true;
      }
      copiedMyState.minStats[retStat].real = ret2;
      copiedMyState.maxStats[retStat].real = ret2;
      ret = calcDamage(
        copiedMyState,
        yourState,
        state,
        myPlayerType,
        move,
        replacedMoveType,
        power,
        damageClassID,
        beforeChangeMyState,
        isCritical,
        isFoulPlay,
        defenseAltAttack,
        ignoreTargetRank,
        invDeffense,
        isSunny1_5,
        ignoreAbility,
        mTwice,
        additionalMoveType,
        halvedBerry,
        // TODO
        false,
        loc: loc,
      );
      if (ret.item3 > realDamage) {
        ret2--;
        loop = true;
      }
      count++;
    }

    count = 0;
    loop = true;
    while (count < 20 && loop) {
      loop = false;
      var copiedMyState = myState.copy()
        ..minStats[retStat].real = ret3
        ..maxStats[retStat].real = ret3;
      var ret = calcDamage(
        copiedMyState,
        yourState,
        state,
        myPlayerType,
        move,
        replacedMoveType,
        power,
        damageClassID,
        beforeChangeMyState,
        isCritical,
        isFoulPlay,
        defenseAltAttack,
        ignoreTargetRank,
        invDeffense,
        isSunny1_5,
        ignoreAbility,
        mTwice,
        additionalMoveType,
        halvedBerry,
        // TODO
        false,
        loc: loc,
      );
      if (ret.item2 > realDamage) {
        ret3--;
        loop = true;
      }
      copiedMyState.minStats[retStat].real = ret2;
      copiedMyState.maxStats[retStat].real = ret2;
      ret = calcDamage(
        copiedMyState,
        yourState,
        state,
        myPlayerType,
        move,
        replacedMoveType,
        power,
        damageClassID,
        beforeChangeMyState,
        isCritical,
        isFoulPlay,
        defenseAltAttack,
        ignoreTargetRank,
        invDeffense,
        isSunny1_5,
        ignoreAbility,
        mTwice,
        additionalMoveType,
        halvedBerry,
        // TODO
        false,
        loc: loc,
      );
      if (ret.item3 < realDamage) {
        ret2++;
        loop = true;
      }
      count++;
    }

    return Tuple3(retStat, ret2, ret3);
  }

  /// 現在のコマンド入力の1画面を返す
  /// ```
  /// initialKeyNumber: 最初の画面のキー
  /// onBackPressed: 入力画面シーケンス最初の画面の「戻る」を押されたときに呼ぶコールバック
  /// onConfirm: 入力画面シーケンス最後の画面でわざの詳細入力が確定したときに呼ぶコールバック
  /// onUpdate: 入力内容によって描画更新が必要な時に呼ぶコールバック
  /// myParty: 自身のパーティ
  /// yourParty: 相手のパーティ
  /// myState: 自身のポケモンの状態
  /// yourParty: 相手のポケモンの状態
  /// state: フェーズの状態
  /// controller: コマンド入力ページ遷移を管理するコントローラ
  /// ```
  Widget extraCommandInputList({
    required int initialKeyNumber,
    required ThemeData theme,
    required void Function() onBackPressed,
    required void Function() onConfirm,
    required void Function() onUpdate,
    required Party myParty,
    required Party yourParty,
    required PokemonState myState,
    required PokemonState yourState,
    required PhaseState state,
    required DamageGetter damageGetter,
    required CommandPagesController controller,
    required AppLocalizations loc,
  }) {
    List<Tuple3<CommandWidgetTemplate, String, dynamic>> templateTitles = [];
    bool fixTemplates = false;

    if (playerType != PlayerType.none &&
        type == TurnActionType.move &&
        move.id != 0) {
      // 追加効果
      switch (move.effect.id) {
        case 84: // ほぼすべてのわざから1つをランダムで使う
        case 243: // 最後に出されたわざを出す(相手のわざとは限らない)
          // 含まれないわざもあるが、すべてのわざを入力できるようにしている
          templateTitles.add(
              Tuple3(CommandWidgetTemplate.selectMove, move.displayName, null));
          break;
        case 98: // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
          templateTitles.add(Tuple3(CommandWidgetTemplate.selectAcquiringMove,
              move.displayName, null));
          break;
        default:
          break;
      }

      // 必要に応じてわざの内容変更
      Move replacedMove = getReplacedMove(move, myState);

      // 1.分類による返却Widgetリストの対応
      switch (replacedMove.damageClass.id) {
        case 1: // へんか
          // 1-a.対象による返却Widgetリストの対応
          switch (replacedMove.target) {
            case Target.faintingPokemon: // ひんしになった(味方の)ポケモン
              templateTitles.add(Tuple3(
                  CommandWidgetTemplate.selectMyFaintingPokemons,
                  loc.battleRevivePokemon,
                  null));
              fixTemplates = true;
              break;
            default: // その他が対象のへんかわざ
              templateTitles.add(Tuple3(CommandWidgetTemplate.successOrFail,
                  loc.battleSuccessFailure, null));
              break;
          }
          break;
        default: // ぶつり・とくしゅ
          switch (replacedMove.target) {
            case Target.ally: // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
              _isValid = true;
              isSuccess = false;
              templateTitles.add(Tuple3(
                  CommandWidgetTemplate.fail, loc.battleSuccessFailure, null));
              fixTemplates = true;
              break;
            default:
              // ダメージ入力のWidgetを追加
              templateTitles.add(Tuple3(CommandWidgetTemplate.inputYourHP,
                  replacedMove.displayName, [replacedMove.maxMoveCount()]));
              break;
          }
          break;
      }

      // 2.追加効果
      if (!fixTemplates) {
        switch (replacedMove.effect.id) {
          //case 2:     // 眠らせる
          case 3: // どくにする(確率)
          case 5: // やけどにする(確率)
          case 6: // こおりにする(確率)
          case 7: // まひにする(確率)
          case 32: // ひるませる(確率)
          case 69: // こうげきを1段階下げる(確率)
          case 70: // ぼうぎょを1段階下げる(確率)
          case 71: // すばやさを1段階下げる(確率)
          case 72: // とくこうを1段階下げる(確率)
          case 73: // とくぼうを1段階下げる(確率)
          case 74: // めいちゅうを1段階下げる(確率)
          case 77: // こんらんさせる(確率)
          case 78: // 2回こうげき、どくにする(確率)
          case 93: // ひるませる(確率)。ねむり状態のときのみ成功
          case 153: // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
          case 201: // やけどにする(確率)。急所に当たりやすい
          case 203: // もうどくにする(確率)
          case 210: // どくにする(確率)。急所に当たりやすい
          case 261: // こおりにする(確率)。天気がゆきのときは必中
          case 268: // こんらんさせる(確率)
          case 272: // とくぼうを2段階下げる(確率)
          case 330: // ねむり状態にする(確率)。メロエッタのフォルムが変わる
          case 334: // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
          case 372: // まひにする(確率)
          case 454: // 対象がそのターンに能力が上がっているとやけど状態にする(確率)
          case 470: // すばやさを1段階下げる(確率)。天気があめの時は必中
          case 471: // まひにする(確率)。天気があめの時は必中
          case 472: // やけどにする(確率)。天気があめの時は必中
          case 499: // 眠らせる(確率)
          case 510: // 対象がそのターンに能力が上がっているとこんらん状態にする(確率)
          case 512: // 対象が先制攻撃技を使おうとしているとき、かつ使用者の方が先に行動する場合のみ成功。ひるませる(確率)。
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch,
                loc.battleAdditionalEffect, [
              _getMoveEffectText(
                  replacedMove.effect.id, yourState.pokemon.omittedName, loc),
              replacedMove,
            ]));
            break;
          case 4: // 与えたダメージの半分だけHP回復
          case 9: // ねむり状態の対象にのみダメージ、与えたダメージの半分だけHP回復
          case 33: // 最大HPの半分だけ回復する
          case 49: // 使用者は相手に与えたダメージの1/4ダメージを受ける
          case 80: // 場に「みがわり」を発生させる
          case 92: // 自分と相手のHPを足して半々に分ける
          case 133: // 使用者のHP回復。回復量は天気による
          case 163: // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
          case 199: // 与えたダメージの33%を使用者も受ける
          case 215: // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
          case 255: // 使用者は最大HP1/4の反動ダメージを受ける
          case 270: // 与えたダメージの1/2を使用者も受ける
          case 346: // 与えたダメージの半分だけHP回復
          case 349: // 与えたダメージの3/4だけHP回復
          case 382: // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
          case 387: // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
          case 388: // 相手のこうげきを1段階下げ、下げる前のこうげき実数値と同じ値だけ使用者のHPを回復する
          case 433: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
          case 441: // 最大HP1/4だけ回復
          case 461: // 最大HP1/4回復、状態異常を治す
          case 485: // 使用者の最大HP1/2(小数点以下切り捨て)を消費してこうげき・とくこう・すばやさを1段階ずつ上げる
            templateTitles.add(Tuple3(
              CommandWidgetTemplate.inputMyHP,
              replacedMove.displayName,
              null,
            ));
            break;
          case 83: // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
            templateTitles.add(Tuple3(
              CommandWidgetTemplate.selectYourAcquiringMove,
              replacedMove.displayName,
              null,
            ));
            break;
          //case 11:    // 使用者のこうげきを1段階上げる
          //case 12:    // 使用者のぼうぎょを1段階上げる
          //case 14:    // 使用者のとくこうを1段階上げる
          //case 17:    // 使用者のかいひを1段階上げる
          //case 51:    // 使用者のこうげきを2段階上げる
          //case 52:    // 使用者のぼうぎょを2段階上げる
          //case 53:    // 使用者のすばやさを2段階上げる
          //case 54:    // 使用者のとくこうを2段階上げる
          //case 55:    // 使用者のとくこうを2段階上げる
          case 139: // 使用者のぼうぎょを1段階上げる(確率)
          case 140: // 使用者のこうげきを1段階上げる(確率)
          case 141: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
          case 277: // 使用者のとくこうを1段階上げる(確率)
          case 359: // 使用者のぼうぎょを2段階上げる(確率)
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch,
                loc.battleAdditionalEffect, [
              _getMoveEffectText(
                  replacedMove.effect.id, myState.pokemon.omittedName, loc),
              replacedMove,
            ]));
            break;
          case 28: // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch2,
                loc.battleAdditionalEffect, [
              loc.battleExhaustedConfused(myState.pokemon.omittedName),
              replacedMove,
            ]));
            break;
          case 29: // 相手ポケモンをランダムに交代させる
          case 314: // 相手ポケモンをランダムに交代させる
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectYourPokemons,
                loc.battlePokemonToChange, null));
            break;
          case 31: // 使用者のタイプを、使用者が覚えているわざの一番上のタイプに変更する
          case 94: // 使用者のタイプを、相手が直前に使ったわざのタイプを半減/無効にするタイプに変更する
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMoveType,
                loc.battleTypeToChange, [loc.battleTypeToChange]));
            break;
          case 37: // やけど・こおり・まひのいずれかにする(確率)
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectBurnFreezeParalysis,
                loc.battleAdditionalEffect,
                null));
            break;
          case 46: // わざを外すと使用者に、使用者の最大HP1/2のダメージ
            if (!isNormallyHit()) {
              templateTitles.add(Tuple3(CommandWidgetTemplate.inputMyHP,
                  replacedMove.displayName, null));
            }
            break;
          case 106: // もちものを盗む
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectYourHoldingItem,
                loc.battleAdditionalEffect,
                [loc.battleStealItem, replacedMove, loc.commonItem]));
            break;
          case 110: // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
            if (myState.isTypeContain(PokeType.ghost)) {
              templateTitles.add(Tuple3(CommandWidgetTemplate.inputMyHP,
                  replacedMove.displayName, null));
            }
            break;
          case 76: // 1ターン目は攻撃せず、2ターン目に攻撃。ひるませる(確率)
          case 126: // 使用者のこおり状態を消す。相手をやけど状態にする(確率)
          case 147: // ひるませる(確率)。そらをとぶ状態でも命中し、その場合威力が2倍
          case 151: // ひるませる(確率)。ちいさくなる状態に対して必中、その場合威力が2倍
          case 264: // 使用者はそらをとぶ状態になり、次のターンにこうげきする。相手をまひ状態にする(確率)
          case 332: // 1ターン目にため、2ターン目でこうげきする。まひ状態にする(確率)
          case 333: // 1ターン目にため、2ターン目でこうげきする。やけど状態にする(確率)
          case 380: // こおりにする(確率)。みずタイプのポケモンに対しても効果ばつぐんとなる
          case 449: // ぶつりわざであるときの方がダメージが大きい場合は物理技になる。どく状態にする(確率)
          case 460: // やけど状態にする(確率)。使用者、対象ともにこおりを治す
          case 466: // 対象がどく・もうどく状態なら威力2倍。どくにする(確率)
          case 469: // 対象が状態異常の場合威力2倍。やけど状態にする(確率)
          case 484: // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。対象をどく状態にする(確率)
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch2,
                loc.battleAdditionalEffect, [
              _getMoveEffectText(
                  replacedMove.effect.id, yourState.pokemon.omittedName, loc),
              replacedMove,
            ]));
            break;
          case 128: // 控えのポケモンと交代する。能力変化・一部の状態変化は交代後に引き継ぐ
          case 154: // 控えのポケモンと交代する
          case 229: // 控えのポケモンと交代する
          case 347: // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
          case 493: // 天気をゆきにして控えと交代
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMyPokemons,
                loc.battlePokemonToChange, null));
            break;
          case 136: // 個体値によってわざのタイプが変わる
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMoveType,
                loc.battleMoveType, [loc.battleMoveType]));
            break;
          case 178: // 使用者ともちものを入れ替える
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMyGettingItem,
                loc.battleAdditionalEffect, [loc.battleItemYouGet]));
            break;
          case 179: // 相手と同じとくせいになる
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectYourAbility,
                loc.battleAdditionalEffect, [loc.commonAbility]));
            break;
          case 185: // 戦闘中自分が最後に使用したもちものを復活させる
          case 324: // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
          case 456: // 対象にもちものがあるときのみ成功
          case 457: // 対象のもちものを消失させる
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectItem,
                loc.battleAdditionalEffect, [loc.commonItem]));
            break;
          case 189: // もちものを持っていれば失わせ、威力1.5倍
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectYourHoldingItem,
                loc.battleAdditionalEffect,
                [loc.battleKnockOffItem, replacedMove, loc.commonItem]));
            break;
          case 192: // 使用者ととくせいを入れ替える
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectMyGettingAbility,
                loc.battleAdditionalEffect,
                [loc.battleAbilityYouGet]));
            break;
          case 225: // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectYourItemWithFilter,
                loc.battleAdditionalEffect, [
              loc.battleConsumeOpponentBerry(yourState.pokemon.omittedName),
              replacedMove,
              loc.commonItem,
              (item) => item.isBerry,
            ]));
            // TODO
//          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraWidget(
//            onFocus, theme, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
//            state, preMoveController, extraArg2[continuousCount], 0, getChangePokemonIndex(playerType),
//            (value) {
//              extraArg2[continuousCount] = value;
//              appState.editingPhase[phaseIdx] = true;
//              onFocus();
//            },
//            (value) {},
//            (value) {
//              setChangePokemonIndex(playerType, value);
//              appState.editingPhase[phaseIdx] = true;
//              onFocus();
//            },
//            isInput,
//            showNetworkImage: PokeDB().getPokeAPI,
//            loc: loc,
//          );
            break;
          case 227: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
            templateTitles.add(Tuple3(CommandWidgetTemplate.select2UpStat,
                loc.battleAdditionalEffect, null));
            break;
          case 234: // 使用者のもちものによって威力と追加効果が変わる
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectMyHoldingItem,
                loc.battleAdditionalEffect,
                [loc.battleFlingItem, replacedMove, loc.commonItem]));
            // TODO
//          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraWidget(
//            onFocus, theme, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
//            state, preMoveController, extraArg2[continuousCount], 0, getChangePokemonIndex(playerType),
//            (value) {
//              extraArg2[continuousCount] = value;
//              appState.editingPhase[phaseIdx] = true;
//              onFocus();
//            },
//            (value) {},
//            (value) {
//              setChangePokemonIndex(playerType, value);
//              appState.editingPhase[phaseIdx] = true;
//              onFocus();
//            },
//            isInput,
//            showNetworkImage: PokeDB().getPokeAPI,
//            loc: loc,
//          );
            break;
          case 254: // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
          case 263: // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
          case 475: // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
          case 500: // 与えたダメージの半分だけ回復する。両者のこおり状態を消す。相手をやけど状態にする(確率)
            templateTitles.add(Tuple3(CommandWidgetTemplate.inputMyHP2,
                replacedMove.displayName, null));
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch2,
                loc.battleAdditionalEffect, [
              _getMoveEffectText(
                  replacedMove.effect.id, yourState.pokemon.omittedName, loc),
              replacedMove,
            ]));
            break;
          case 274: // 相手をやけど状態にする(確率)。相手をひるませる(確率)。
          case 275: // 相手をこおり状態にする(確率)。相手をひるませる(確率)。
          case 276: // 相手をまひ状態にする(確率)。相手をひるませる(確率)。
          case 468: // 相手のぼうぎょを1段階下げる(確率)。相手をひるませる(確率)。急所に当たりやすい
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect2Switch,
                loc.battleAdditionalEffect, [
              _getMoveEffectText(
                  replacedMove.effect.id, yourState.pokemon.omittedName, loc),
              _getMoveEffectText2(
                  replacedMove.effect.id, yourState.pokemon.omittedName, loc),
            ]));
            break;
          case 300: // 相手のとくせいを使用者のとくせいと同じにする
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMyAbility,
                loc.battleAdditionalEffect, [loc.commonAbility]));
            break;
          case 315: // 相手のきのみ・ノーマルジュエルを失わせる
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectYourItemWithFilter,
                loc.battleAdditionalEffect, [
              loc.battleBurnDownItem,
              replacedMove,
              loc.commonItem,
              (item) => item.isBerry || item.id == 669
            ]));
            break;
          case 424: // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectMyItemWithFilter,
                loc.battleAdditionalEffect, [
              loc.commonItem,
              (item) => item.isBerry,
            ]));
            // TODO
//            effectInputRow2 = appState
//                .pokeData.items[extraArg1[continuousCount]]!
//                .extraWidget(
//              onFocus,
//              theme,
//              playerType,
//              ownPokemon,
//              opponentPokemon,
//              ownPokemonState,
//              opponentPokemonState,
//              ownParty,
//              opponentParty,
//              state,
//              preMoveController,
//              extraArg2[continuousCount],
//              0,
//              getChangePokemonIndex(playerType),
//              (value) {
//                extraArg2[continuousCount] = value;
//                appState.editingPhase[phaseIdx] = true;
//                onFocus();
//              },
//              (value) {},
//              (value) {
//                setChangePokemonIndex(playerType, value);
//                appState.editingPhase[phaseIdx] = true;
//                onFocus();
//              },
//              isInput,
//              showNetworkImage: PokeDB().getPokeAPI,
//              loc: loc,
//            );
            break;
          case 464: // どく・まひ・ねむりのいずれかにする(確率)
            templateTitles.add(Tuple3(
                CommandWidgetTemplate.selectPoisonParalysisSleep,
                loc.battleAdditionalEffect,
                null));
            break;
          case 492: // 使用者の最大HP1/2(小数点以下切り捨て)を消費してみがわり作成、みがわりを引き継いで控えと交代
            //_isValid = false;
            templateTitles.add(Tuple3(CommandWidgetTemplate.inputMyHP,
                replacedMove.displayName, null));
            templateTitles.add(Tuple3(CommandWidgetTemplate.selectMyPokemons,
                loc.battlePokemonToChange, null));
            break;
          case 505: // 威力が2倍になる(確率)
            templateTitles.add(Tuple3(CommandWidgetTemplate.effect1Switch,
                loc.battleAdditionalEffect, [
              loc.battleGoAllOut,
              replacedMove,
            ]));
            break;
          default:
            break;
        }
      }

      // へんかわざ＆対象がひんしポケモンでない＆入力内容が成否しかない場合はそのわざを有効に
      if (replacedMove.damageClass.id == 1 &&
          replacedMove.target != Target.faintingPokemon &&
          templateTitles.length <= 1) {
        _isValid = true;
      }
    }

    List<Widget> widgets = [];

    for (int index = 0; index < templateTitles.length; index++) {
      Widget template = _getCommandWidgetTemplate(
        templateTitles[index].item1,
        theme: theme,
        onConfirm: onConfirm,
        onUpdate: onUpdate,
        // 想定している入力の最後、もしくはわざ失敗/外したときならばonNext=>onConfirm
        onNext: (index == templateTitles.length - 1 || !isNormallyHit())
            ? () {
                _isValid = true;
                onConfirm();
              }
            : () {
                controller.pageIndex++;
                if (templateTitles[index + 1].item1.isImmediatelyValid) {
                  _isValid = true;
                  onConfirm();
                  // TODO:戻るボタン押したとき無効に戻す処理
                } else {
                  onUpdate();
                }
              },
        myParty: myParty,
        yourParty: yourParty,
        myState: myState,
        yourState: yourState,
        state: state,
        damageGetter: damageGetter,
        controller: controller,
        loc: loc,
        extra: templateTitles[index].item3,
      );

      // 返却Widget作成
      // 最初のWidgetの場合、戻るボタンタップ時の挙動が違う
      if (index == 0) {
        widgets.add(
          Column(
            key: ValueKey<int>(initialKeyNumber + index),
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => onBackPressed(),
                      icon: Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(templateTitles[index].item2),
                    ),
                    (templateTitles[index].item1 ==
                                    CommandWidgetTemplate.successOrFail ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect1Switch ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect1Switch2 ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect2Switch) &&
                            templateTitles.length > 1 &&
                            isNormallyHit()
                        ? IconButton(
                            key: Key(
                                'StatusMoveNextButton${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                            onPressed: () {
                              controller.pageIndex++;
                              if (templateTitles[index + 1]
                                  .item1
                                  .isImmediatelyValid) {
                                _isValid = true;
                                onConfirm();
                                // TODO:戻るボタン押したとき無効に戻す処理
                              } else {
                                onUpdate();
                              }
                              // 統合テスト作成用
                              print(
                                  "await driver.tap(find.byValueKey('StatusMoveNextButton${playerType == PlayerType.me ? 'Own' : 'Opponent'}'));");
                            },
                            icon: Icon(Icons.arrow_forward),
                          )
                        : Container(),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: template,
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          Column(
            key: ValueKey<int>(initialKeyNumber + index),
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.pageIndex--;
                        onUpdate();
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(templateTitles[index].item2),
                    ),
                    (templateTitles[index].item1 ==
                                    CommandWidgetTemplate.successOrFail ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect1Switch ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect1Switch2 ||
                                templateTitles[index].item1 ==
                                    CommandWidgetTemplate.effect2Switch) &&
                            templateTitles.length - 1 > index &&
                            isNormallyHit()
                        ? IconButton(
                            key: Key(
                                'StatusMoveNextButton${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                            onPressed: () {
                              controller.pageIndex++;
                              if (templateTitles[index + 1]
                                  .item1
                                  .isImmediatelyValid) {
                                _isValid = true;
                                onConfirm();
                                // TODO:戻るボタン押したとき無効に戻す処理
                              } else {
                                onUpdate();
                              }
                              // 統合テスト作成用
                              print(
                                  "await driver.tap(find.byValueKey('StatusMoveNextButton${playerType == PlayerType.me ? 'Own' : 'Opponent'}'));");
                            },
                            icon: Icon(Icons.arrow_forward),
                          )
                        : Container(),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: template,
              ),
            ],
          ),
        );
      }
    }

    if (controller.pageIndex < widgets.length) {
      return widgets[controller.pageIndex];
    } else {
      return Container();
    }
  }

  /// コマンド入力の1画面を返す
  /// ```
  /// template: 作成する画面テンプレート
  /// onConfirm: 入力画面シーケンス最後の画面でわざの詳細入力が確定したときに呼ぶコールバック
  /// onUpdate: 入力内容によって描画更新が必要な時に呼ぶコールバック
  /// onNext: 次の画面に進む時に呼ぶコールバック
  /// myParty: 自身のパーティ
  /// yourParty: 相手のパーティ
  /// myState: 自身のポケモンの状態
  /// yourParty: 相手のポケモンの状態
  /// state: フェーズの状態
  /// controller: コマンド入力ページ遷移を管理するコントローラ
  /// extra: 画面作成に必要なその他引数
  /// ```
  Widget _getCommandWidgetTemplate(
    CommandWidgetTemplate template, {
    required ThemeData theme,
    required void Function() onConfirm,
    required void Function() onUpdate,
    required void Function() onNext,
    required Party myParty,
    required Party yourParty,
    required PokemonState myState,
    required PokemonState yourState,
    required PhaseState state,
    required DamageGetter damageGetter,
    required CommandPagesController controller,
    required AppLocalizations loc,
    required dynamic extra,
  }) {
    switch (template) {
      case CommandWidgetTemplate.successOrFail:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: StandAloneSwitchList(
                key: Key(
                    'SuccessSwitch${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                title: Text(loc.battleSucceeded),
                onChanged: (change) {
                  isSuccess = change;
                  onUpdate();
                  // 統合テスト作成用
                  print(
                      "await tapSuccess(driver, ${playerType == PlayerType.me ? 'me' : 'op'});");
                },
                initialValue: isSuccess,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyPokemons:
        {
          // 交代先選択ListTile作成
          List<ListTile> myPokemonTiles = [];
          List<int> addedIndex = [];
          for (int i = 0; i < myParty.pokemonNum; i++) {
            if (state.isPossibleBattling(playerType, i) &&
                !state.getPokemonStates(playerType)[i].isFainting) {
              myPokemonTiles.add(
                ChangePokemonCommandTile(
                  myParty.pokemons[i]!,
                  theme,
                  onTap: () {
                    setChangePokemonIndex(playerType,
                        state.getPokemonIndex(playerType, null), i + 1);
                    //onUpdate();
                    onNext();
                    // 統合テスト作成用
                    final poke = state.getPokemonStates(playerType)[i].pokemon;
                    print("// ${poke.omittedName}に交代\n"
                        "await changePokemon(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${poke.name}', false);");
                  },
                  selected: getChangePokemonIndex(playerType) == i + 1,
                  showNetworkImage: PokeDB().getPokeAPI,
                ),
              );
              addedIndex.add(i);
            }
          }
          for (int i = 0; i < myParty.pokemonNum; i++) {
            if (addedIndex.contains(i)) continue;
            myPokemonTiles.add(
              ChangePokemonCommandTile(
                myParty.pokemons[i]!,
                theme,
                enabled: false,
                showNetworkImage: PokeDB().getPokeAPI,
              ),
            );
          }
          return ListViewWithViewItemCount(
            key: Key(
                'ChangePokemonListView${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
            viewItemCount: 4,
            children: myPokemonTiles,
          );
        }
      case CommandWidgetTemplate.selectYourPokemons:
        {
          // 交代先選択ListTile作成
          List<ListTile> yourPokemonTiles = [];
          List<int> addedIndex = [];
          for (int i = 0; i < yourParty.pokemonNum; i++) {
            if (state.isPossibleBattling(playerType.opposite, i) &&
                !state.getPokemonStates(playerType.opposite)[i].isFainting) {
              yourPokemonTiles.add(
                ChangePokemonCommandTile(
                  yourParty.pokemons[i]!,
                  theme,
                  onTap: () {
                    setChangePokemonIndex(
                        playerType.opposite,
                        state.getPokemonIndex(playerType.opposite, null),
                        i + 1);
                    //onUpdate();
                    onNext();
                    // 統合テスト作成用
                    final poke =
                        state.getPokemonStates(playerType.opposite)[i].pokemon;
                    print("// ${poke.omittedName}に交代\n"
                        "await changePokemon(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${poke.name}', false);");
                  },
                  selected: getChangePokemonIndex(playerType.opposite) == i + 1,
                  showNetworkImage: PokeDB().getPokeAPI,
                ),
              );
              addedIndex.add(i);
            }
          }
          for (int i = 0; i < yourParty.pokemonNum; i++) {
            if (addedIndex.contains(i)) continue;
            yourPokemonTiles.add(
              ChangePokemonCommandTile(
                yourParty.pokemons[i]!,
                theme,
                enabled: false,
                showNetworkImage: PokeDB().getPokeAPI,
              ),
            );
          }
          return ListViewWithViewItemCount(
            key: Key(
                'ChangePokemonListView${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
            viewItemCount: 4,
            children: yourPokemonTiles,
          );
        }
      case CommandWidgetTemplate.selectMyFaintingPokemons:
        {
          // 交代先選択ListTile作成
          List<ListTile> pokemonTiles = [];
          List<int> addedIndex = [];
          for (int i = 0; i < myParty.pokemonNum; i++) {
            if (state.isPossibleBattling(playerType, i) &&
                state.getPokemonStates(playerType)[i].isFainting) {
              pokemonTiles.add(
                ChangePokemonCommandTile(
                  myParty.pokemons[i]!,
                  theme,
                  onTap: () {
                    extraArg1 = i + 1;
                    //_isValid = true;
                    //onConfirm();
                    onNext();
                    // 統合テスト作成用
                    print("// ${myParty.pokemons[i]!.name}を復活\n"
                        "await changePokemon(driver, me, '${myParty.pokemons[i]!.name}', false);");
                  },
                  selected: extraArg1 == i + 1,
                  showNetworkImage: PokeDB().getPokeAPI,
                ),
              );
              addedIndex.add(i);
            }
          }
          for (int i = 0; i < myParty.pokemonNum; i++) {
            if (addedIndex.contains(i)) continue;
            pokemonTiles.add(
              ChangePokemonCommandTile(
                myParty.pokemons[i]!,
                theme,
                enabled: false,
                showNetworkImage: PokeDB().getPokeAPI,
              ),
            );
          }
          return ListViewWithViewItemCount(
            key: Key(
                'ChangePokemonListView${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
            viewItemCount: 4,
            children: pokemonTiles,
          );
        }
      case CommandWidgetTemplate.inputYourHP:
        int initialNum = playerType == PlayerType.me
            ? yourState.remainHPPercent
            : yourState.remainHP;
        return Column(
          children: [
            // 命中・急所(ON/OFF)。連続わざの場合はそれぞれの回数を入力
            Expanded(
                flex: 1,
                child: HitCriticalInputRow(
                  turnMove: this,
                  onUpdate: onUpdate,
                  maxMoveCount: extra[0] as int,
                )),
            // 推定ダメージ
            Expanded(
              flex: 1,
              child: damageGetter.showDamage
                  ? Text(
                      '${damageGetter.rangeString} (${damageGetter.rangePercentString})')
                  : Text(' - '),
            ),
            failWithProtect(state, onlyValid: false)
                ? Expanded(flex: 1, child: ProtectedInput())
                : yourState.buffDebuffs.containsByID(BuffDebuff.substitute)
                    ? Expanded(
                        flex: 1,
                        child: SubstituteBreakInput(
                          turnMove: this,
                          onUpdate: onUpdate,
                        ))
                    : Container(),
            Expanded(
              flex: 5,
              child: NumberInputButtons(
                key: Key(
                    'NumberInputButtons${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                initialNum: initialNum,
                onConfirm: (remain) {
                  if (playerType == PlayerType.me) {
                    percentDamage = yourState.remainHPPercent - remain;
                  } else {
                    realDamage = yourState.remainHP - remain;
                  }
                  onNext();
                  // 統合テスト作成用
                  print("// ${yourState.pokemon.omittedName}のHP$remain\n"
                      "await inputRemainHP(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${initialNum != remain ? remain : ""}');\n");
                },
                prefixText: loc.battleRemainHP(yourState.pokemon.omittedName),
                suffixText: playerType == PlayerType.me ? '%' : null,
                enabled: isNormallyHit() &&
                    (!yourState.buffDebuffs
                            .containsByID(BuffDebuff.substitute) ||
                        breakSubstitute ||
                        ignoreSubstitute(state)) &&
                    yourState
                        .ailmentsWhere(
                            (element) => element.id == Ailment.protect)
                        .isEmpty,
              ),
            ),
          ],
        );
      case CommandWidgetTemplate.inputMyHP:
        int initialNum = playerType == PlayerType.me
            ? myState.remainHP
            : myState.remainHPPercent;
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 6,
              child: NumberInputButtons(
                key: Key(
                    'NumberInputButtons${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                initialNum: initialNum,
                onConfirm: (remain) {
                  if (playerType == PlayerType.me) {
                    extraArg1 = myState.remainHP - remain;
                  } else {
                    extraArg2 = myState.remainHPPercent - remain;
                  }
                  onNext();
                  // 統合テスト作成用
                  print("// ${myState.pokemon.omittedName}のHP$remain\n"
                      "await inputRemainHP(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${initialNum != remain ? remain : ""}');\n");
                },
                prefixText: loc.battleRemainHP(myState.pokemon.omittedName),
                suffixText: playerType == PlayerType.opponent ? '%' : null,
                enabled: isNormallyHit(),
              ),
            ),
          ],
        );
      case CommandWidgetTemplate.inputMyHP2:
        int initialNum = playerType == PlayerType.me
            ? myState.remainHP
            : myState.remainHPPercent;
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 6,
              child: NumberInputButtons(
                key: Key(
                    'NumberInputButtons${playerType == PlayerType.me ? 'Own' : 'Opponent'}'),
                initialNum: initialNum,
                onConfirm: (remain) {
                  if (playerType == PlayerType.me) {
                    extraArg2 = myState.remainHP - remain;
                  } else {
                    extraArg2 = myState.remainHPPercent - remain;
                  }
                  onNext();
                  // 統合テスト作成用
                  print("// ${myState.pokemon.omittedName}のHP$remain\n"
                      "await inputRemainHP(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${initialNum != remain ? remain : ""}');\n");
                },
                prefixText: loc.battleRemainHP(myState.pokemon.omittedName),
                suffixText: playerType == PlayerType.opponent ? '%' : null,
                enabled: isNormallyHit(),
              ),
            ),
          ],
        );
      case CommandWidgetTemplate.fail:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: SwitchListTile(
                title: Text(loc.battleSucceeded),
                onChanged: null,
                value: false,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMove:
        return SelectMoveInput(
          playerType: playerType,
          turnMove: this,
          pokemonState: myState,
          state: state,
          onSelect: (move) {
            extraArg3 = move.id;
            fillAutoAdditionalEffect(state);
            onNext();
            // 統合テスト作成用
            print("// ${myState.pokemon.omittedName}の${move.displayName}\n"
                "await tapMove(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${move.displayName}', true);");
          },
        );
      case CommandWidgetTemplate.selectAcquiringMove:
        return SelectMoveInput(
          playerType: playerType,
          turnMove: this,
          pokemonState: myState,
          state: state,
          onSelect: (move) {
            extraArg3 = move.id;
            fillAutoAdditionalEffect(state);
            onNext();
            // 統合テスト作成用
            print("// ${myState.pokemon.omittedName}の${move.displayName}\n"
                "await tapMove(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${move.displayName}', false);");
          },
          onlyAcquiring: true,
        );
      case CommandWidgetTemplate.effect1Switch:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: StandAloneSwitchList(
                title: Text(extra[0] as String),
                onChanged: (change) {
                  if (change) {
                    moveAdditionalEffects =
                        MoveEffect((extra[1] as Move).effect.id);
                  } else {
                    moveAdditionalEffects = MoveEffect(0);
                  }
                  onUpdate();
                  // 統合テスト作成用
                  print("// ${extra[0] as String}\n"
                      "await driver.tap(find.text('${extra[0] as String}'));");
                },
                initialValue: moveAdditionalEffects ==
                    MoveEffect((extra[1] as Move).effect.id),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.effect1Switch2:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: StandAloneSwitchList(
                title: Text(extra[0] as String),
                onChanged: (change) {
                  if (change) {
                    extraArg1 = (extra[1] as Move).effect.id;
                  } else {
                    extraArg1 = 0;
                  }
                  onUpdate();
                  // 統合テスト作成用
                  print("// ${extra[0] as String}\n"
                      "await driver.tap(find.text('${extra[0] as String}'));");
                },
                initialValue: extraArg1 == (extra[1] as Move).effect.id,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.effect2Switch:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: StandAloneSwitchList(
                title: Text(extra[0] as String),
                onChanged: (change) {
                  if (change) {
                    extraArg1 = 1;
                  } else {
                    extraArg1 = 0;
                  }
                  onUpdate();
                },
                initialValue: extraArg1 == 1,
              ),
            ),
            Expanded(
              flex: 1,
              child: StandAloneSwitchList(
                title: Text(extra[1] as String),
                onChanged: (change) {
                  if (change) {
                    extraArg2 = 1;
                  } else {
                    extraArg2 = 0;
                  }
                  onUpdate();
                },
                initialValue: extraArg2 == 1,
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectYourAcquiringMove:
        return SelectMoveInput(
          playerType: playerType.opposite,
          turnMove: this,
          pokemonState: yourState,
          state: state,
          onSelect: (move) {
            extraArg3 = move.id;
            onNext();
            // 統合テスト作成用
            print("// ${myState.pokemon.omittedName}の${move.displayName}\n"
                "await tapMove(driver, ${playerType == PlayerType.me ? "me" : "op"}, '${move.displayName}', false);");
          },
          onlyAcquiring: true,
        );
      case CommandWidgetTemplate.selectMoveType:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: _myTypeDropdownButton(
                extra[0] as String,
                (val) {
                  extraArg1 = val;
                  onNext();
                },
                extraArg1 == 0 ? null : extraArg1,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectBurnFreezeParalysis:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battleAdditionalEffect,
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: MoveEffect.none,
                    child: Text(loc.commonNone),
                  ),
                  DropdownMenuItem(
                    value: Ailment.burn,
                    child:
                        Text(loc.battleBurned(yourState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: Ailment.freeze,
                    child:
                        Text(loc.battleFrozen(yourState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: Ailment.paralysis,
                    child: Text(
                        loc.battlePararised(yourState.pokemon.omittedName)),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onNext();
                },
                theme: theme,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectPoisonParalysisSleep:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battleAdditionalEffect,
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: MoveEffect.none,
                    child: Text(loc.commonNone),
                  ),
                  DropdownMenuItem(
                    value: Ailment.poison,
                    child:
                        Text(loc.battlePoisoned(yourState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: Ailment.paralysis,
                    child: Text(
                        loc.battlePararised(yourState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: Ailment.sleep,
                    child: Text(
                        loc.battleFellAsleep(yourState.pokemon.omittedName)),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onNext();
                },
                theme: theme,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyHoldingItem:
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: SwitchSelectItemInput(
                switchText: extra[0] as String,
                initialSwitchValue:
                    moveAdditionalEffects == (extra[1] as Move).effect,
                onSwitchChanged: (value) {
                  if (value) {
                    moveAdditionalEffects = (extra[1] as Move).effect;
                  } else {
                    moveAdditionalEffects = MoveEffect(MoveEffect.none);
                  }
                  onUpdate();
                },
                itemText: extra[2] as String,
                initialItemText: PokeDB().items[extraArg1]!.displayName,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                },
                playerType: playerType,
                pokemonState: myState,
                onlyHolding: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectYourHoldingItem:
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: SwitchSelectItemInput(
                switchText: extra[0] as String,
                initialSwitchValue:
                    moveAdditionalEffects == (extra[1] as Move).effect,
                onSwitchChanged: (value) {
                  if (value) {
                    moveAdditionalEffects = (extra[1] as Move).effect;
                  } else {
                    moveAdditionalEffects = MoveEffect(MoveEffect.none);
                  }
                  onUpdate();
                  // 統合テスト作成用
                  print(
                      "await driver.tap(find.byValueKey('SwitchSelectItemInputSwitch'));");
                },
                itemText: extra[2] as String,
                initialItemText: PokeDB().items[extraArg1]!.displayName,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                  // 統合テスト作成用
                  print(
                      "await driver.tap(find.byValueKey('SwitchSelectItemInputTextField'));\n"
                      "await driver.enterText('${item.displayName}');\n"
                      "await driver.tap(find.descendant(\n"
                      "    of: find.byType('ListTile'), matching: find.text('${item.displayName}')));");
                },
                playerType: playerType.opposite,
                pokemonState: yourState,
                onlyHolding: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectYourItemWithFilter:
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: SwitchSelectItemInput(
                switchText: extra[0] as String,
                initialSwitchValue:
                    moveAdditionalEffects == (extra[1] as Move).effect,
                onSwitchChanged: (value) {
                  if (value) {
                    moveAdditionalEffects = (extra[1] as Move).effect;
                  } else {
                    moveAdditionalEffects = MoveEffect(MoveEffect.none);
                  }
                  onUpdate();
                },
                itemText: extra[2] as String,
                initialItemText: PokeDB().items[extraArg1]!.displayName,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                },
                playerType: playerType.opposite,
                pokemonState: yourState,
                onlyHolding: true,
                filter: extra[3] as bool Function(Item),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyGettingItem:
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: SelectItemInput(
                itemText: extra[0] as String,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                },
                playerType: PlayerType.opponent,
                pokemonState: playerType == PlayerType.me ? yourState : myState,
                onlyHolding: true,
                containNone: true,
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyItemWithFilter:
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: SelectItemInput(
                itemText: extra[0] as String,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                },
                playerType: playerType,
                pokemonState: myState,
                onlyHolding: true,
                filter: extra[1] as bool Function(Item),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectItem:
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: SelectItemInput(
                itemText: extra[0] as String,
                onItemSelected: (item) {
                  extraArg1 = item.id;
                  onNext();
                },
                playerType: playerType,
                pokemonState: myState,
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyAbility:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: SelectAbilityInput(
                abilityText: extra[0] as String,
                onAbilitySelected: (ability) {
                  extraArg1 = ability.id;
                  onNext();
                },
                playerType: playerType,
                pokemonState: myState,
                state: state,
                onlyCurrent: true,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectYourAbility:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: SelectAbilityInput(
                abilityText: extra[0] as String,
                onAbilitySelected: (ability) {
                  extraArg1 = ability.id;
                  onNext();
                },
                playerType: playerType.opposite,
                pokemonState: yourState,
                state: state,
                onlyCurrent: true,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.selectMyGettingAbility:
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: SelectAbilityInput(
                abilityText: extra[0] as String,
                onAbilitySelected: (ability) {
                  extraArg1 = ability.id;
                  onNext();
                },
                playerType: PlayerType.opponent,
                pokemonState: playerType == PlayerType.me ? yourState : myState,
                state: state,
                onlyCurrent: true,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
      case CommandWidgetTemplate.select2UpStat:
        // TODO:Widgetのstate変わんない
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battleAdditionalEffect,
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: 0,
                    child:
                        Text(loc.battleAttackUp2(myState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child:
                        Text(loc.battleDefenseUp2(myState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child:
                        Text(loc.battleSAttackUp2(myState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text(
                        loc.battleSDefenseUp2(myState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text(
                        loc.battleAccuracyUp2(myState.pokemon.omittedName)),
                  ),
                  DropdownMenuItem(
                    value: 6,
                    child: Text(
                        loc.battleEvasivenessUp2(myState.pokemon.omittedName)),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) {
                  extraArg1 = value;
                  onNext();
                },
                theme: theme,
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(),
            ),
          ],
        );
    }
  }

  /// カスタムしたDropdownButtonFormField
  /// ```
  /// prefixIconPokemon: フィールド前に配置するアイコンのポケモン
  /// showNetworkImage: インターネットから取得したポケモンの画像を使うかどうか
  /// ```
  Widget _myDropdownButtonFormField<T>({
    Key? key,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    T? value,
    Widget? hint,
    Widget? disabledHint,
    required ValueChanged<T?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField(
      key: key,
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      value: value,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      decoration: decoration,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
      padding: padding,
    );
  }

  /// タイプのDropdownButton
  /// ```
  /// labelText: ラベル名
  /// onChanged: 変更された際に呼び出すコールバック
  /// value: 選択されているタイプのインデックス
  /// isError: エラー表示にするかどうか
  /// isTeraType: テラスタイプ選択のDropdownButtonかどうか(trueならステラも選択可)
  /// ```
  Widget _myTypeDropdownButton(
    String? labelText,
    void Function(dynamic)? onChanged,
    int? value, {
    bool isError = false,
    bool isTeraType = false,
  }) {
    return TypeDropdownButton(
      labelText,
      onChanged,
      value != null ? PokeType.values[value] : null,
      isError: isError,
      isTeraType: isTeraType,
    );
  }

  /// 行動が確定するなら自動で設定する。自動で設定した場合はtrueを返す
  /// ```
  /// state: フェーズの状態
  /// ```
  bool fillAuto(PhaseState state) {
    var myState = state.getPokemonState(playerType, null);
    var yourState = state.getPokemonState(playerType.opposite, null);
    final pokeData = PokeDB();
    bool ret = false;
    bool isMoveChanged = false;

    // ねむり
    if (myState
        .ailmentsWhere((e) =>
            e.id == Ailment.sleep && e.turns < (e.extraArg1 == 3 ? 2 : 3))
        .isNotEmpty) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.sleep);
      ret = true;
    }
    // ひるみ
    else if (myState.ailmentsWhere((e) => e.id == Ailment.flinch).isNotEmpty) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.flinch);
      ret = true;
    }
    // そのターンに先にちょうはつを使われた
    if (myState.ailmentsWhere((e) => e.id == Ailment.taunt).isNotEmpty &&
        getReplacedMove(move, myState).damageClass.id == 1) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.taunt);
      ret = true;
    }
    // まもる系統のわざを使われた
    if (yourState.ailmentsWhere((e) => e.id == Ailment.protect).isNotEmpty &&
        getReplacedMove(move, myState).damageClass.id >= 2) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.protected);
      ret = true;
    }
    // わざの反動で動けない
    if (myState.hiddenBuffs.containsByID(BuffDebuff.recoiling)) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.recoil);
      ret = true;
    }
    // あばれる
    else if (myState.ailmentsWhere((e) => e.id == Ailment.thrash).isNotEmpty) {
      move = pokeData.moves[myState
          .ailmentsWhere((e) => e.id == Ailment.thrash)
          .first
          .extraArg1]!;
      //move = getReplacedMove(suggestion, continuousCount, myState);
      //turnEffectAndStateAndGuide.guides = processMove(
      //  ownParty.copy(), opponentParty.copy(), ownPokemonState.copy(),
      //  opponentPokemonState.copy(), state.copy(), 0);
      ret = true;
      isMoveChanged = true;
    }
    // 溜めがあるこうげき
    final founds = myState.hiddenBuffs.whereByID(BuffDebuff.chargingMove);
    if (founds.isNotEmpty) {
      move = pokeData.moves[founds.first.extraArg1]!;
      ret = true;
      isMoveChanged = true;
    }

    if (isMoveChanged) {
      fillAutoAdditionalEffect(state);
      moveEffectivenesses = PokeTypeEffectiveness.effectiveness(
          myState.currentAbility.id == 113 || myState.currentAbility.id == 299,
          yourState.holdingItem?.id == 586,
          yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
          move.type,
          yourState);
    }

    return ret;
  }

  /// TODO:削除対象？
  String getEditingControllerText4(PhaseState state) {
    var pokeData = PokeDB();
    switch (move.effect.id) {
      case 84: // ほぼすべてのわざから1つをランダムで使う
      case 98: // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243: // 最後に出されたわざを出す(相手のわざとは限らない)
        return pokeData.moves[extraArg3]!.displayName;
      default:
        break;
    }
    return '';
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
    var myState = state.getPokemonState(playerType, null);
    var yourState = state.getPokemonState(playerType.opposite, null);
    var opponentState = state.getPokemonState(PlayerType.opponent, null);

    switch (moveAdditionalEffects.id) {
      case 33: // 最大HPの半分だけ回復する
      case 215: // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
        extraArg1 = -((myState.pokemon.h.real / 2).ceil());
        extraArg2 = -50;
        break;
      case 80: // 場に「みがわり」を発生させる
        extraArg1 = (myState.pokemon.h.real / 4).floor();
        extraArg2 = 25;
        break;
      case 110: // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
        if (myState.isTypeContain(PokeType.ghost)) {
          extraArg1 = (myState.pokemon.h.real / 2).floor();
          extraArg2 = 50;
        }
        break;
      case 106: // もちものを盗む
      case 189: // もちものを持っていれば失わせ、威力1.5倍
        if (yourState.getHoldingItem() != null &&
            yourState.getHoldingItem()!.id != 0) {
          extraArg1 = yourState.getHoldingItem()!.id;
        }
        break;
      case 133: // 使用者のHP回復。回復量は天気による
        if (state.weather.id == Weather.sunny) {
          extraArg1 = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2 = -roundOff5(2732 / 4096);
        } else if (state.weather.id == Weather.rainy ||
            state.weather.id == Weather.sandStorm ||
            state.weather.id == Weather.snowy) {
          extraArg1 = -(roundOff5(myState.pokemon.h.real / 4));
          extraArg2 = -25;
        } else {
          extraArg1 = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2 = -50;
        }
        break;
      case 163: // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
        int findIdx = myState.ailmentsIndexWhere(
            (e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
        if (findIdx >= 0) {
          int t = myState.ailments(findIdx).id - Ailment.stock1;
          switch (t) {
            case 0:
              extraArg1 = -((myState.pokemon.h.real / 4).floor());
              extraArg2 = -25;
              break;
            case 1:
              extraArg1 = -((myState.pokemon.h.real / 2).floor());
              extraArg2 = -50;
              break;
            case 2:
              extraArg1 = -myState.pokemon.h.real;
              extraArg2 = -100;
              break;
            default:
              break;
          }
        }
        break;
      case 178: // 使用者ともちものを入れ替える
        if (opponentState.getHoldingItem() != null &&
            opponentState.getHoldingItem()!.id != 0) {
          extraArg1 = opponentState.getHoldingItem()!.id;
        }
        break;
      case 185: // 戦闘中自分が最後に使用したもちものを復活させる
        // TODO
        break;
      case 225: // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
        if (yourState.getHoldingItem() != null &&
            yourState.getHoldingItem()!.id != 0 &&
            yourState.getHoldingItem()!.isBerry) {
          extraArg1 = yourState.getHoldingItem()!.id;
        }
        break;
      case 234: // 使用者のもちものによって威力と追加効果が変わる
      case 324: // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
        if (myState.getHoldingItem() != null &&
            myState.getHoldingItem()!.id != 0) {
          extraArg1 = myState.getHoldingItem()!.id;
        }
        break;
      case 424: // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
        if (myState.getHoldingItem() != null &&
            myState.getHoldingItem()!.id != 0 &&
            myState.getHoldingItem()!.isBerry) {
          extraArg1 = myState.getHoldingItem()!.id;
        }
        break;
      case 179: // 相手と同じとくせいになる
        if (yourState.getCurrentAbility().id != 0) {
          extraArg1 = yourState.getCurrentAbility().id;
        }
        break;
      case 192: // 使用者ととくせいを入れ替える
        if (opponentState.getCurrentAbility().id != 0) {
          extraArg1 = opponentState.getCurrentAbility().id;
        }
        break;
      case 300: // 相手のとくせいを使用者のとくせいと同じにする
        if (myState.currentAbility.id != 0) {
          extraArg1 = myState.currentAbility.id;
        }
        break;
      case 382: // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
        if (state.weather.id == Weather.sandStorm) {
          extraArg1 = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2 = -roundOff5(2732 / 4096);
        } else {
          extraArg1 = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2 = -50;
        }
        break;
      case 387: // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
        if (state.field.id == Field.grassyTerrain) {
          extraArg1 = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2 = -roundOff5(2732 / 4096);
        } else {
          extraArg1 = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2 = -50;
        }
        break;
      case 441: // 最大HP1/4だけ回復
        extraArg1 = -((myState.pokemon.h.real / 4).round());
        extraArg2 = -25;
        break;
      case 420: // 最大HP1/2(小数点切り上げ)を削ってこうげき
        extraArg1 = (myState.pokemon.h.real / 2).ceil();
        extraArg2 = 50;
        break;
      case 433: // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
        extraArg1 = (myState.pokemon.h.real / 3).floor();
        extraArg2 = 33;
        break;
      case 461: // 最大HP1/4回復、状態異常を治す
        extraArg1 = -((myState.pokemon.h.real / 4).floor());
        extraArg2 = -25;
        break;
      case 492: // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
        extraArg1 = ((myState.pokemon.h.real / 2).ceil());
        extraArg2 = 50;
        break;
      default:
        break;
    }
  }

  /// 相手がまもる系統の状態にある場合、それによって失敗するかどうかを返す
  /// ```
  /// state: フェーズの状態
  /// onlyValid: 有効な行動の場合のみ失敗を設定する
  /// update: isSuccessとactionFailureを更新するかどうか
  /// ```
  bool failWithProtect(
    PhaseState state, {
    bool onlyValid = true,
    bool update = false,
  }) {
    if (state
            .getPokemonState(playerType.opposite, null)
            .ailmentsWhere((element) => element.id == Ailment.protect)
            .isNotEmpty &&
        (onlyValid && isValid()) &&
        move.failWithProtect &&
        !(state.getPokemonState(playerType, null).currentAbility.id == 260 &&
            move.isDirect)) {
      if (update) {
        isSuccess = false;
        actionFailure = ActionFailure(ActionFailure.protected);
      }
      return true;
    } else if (!isSuccess && actionFailure.id == ActionFailure.protected) {
      if (update) {
        isSuccess = true;
        actionFailure = ActionFailure(ActionFailure.none);
      }
    }
    return false;
  }

  /// ひるみによって失敗するかどうかを返す
  /// ```
  /// state: フェーズの状態
  /// update: isSuccessとactionFailureを更新するかどうか
  /// ```
  bool failWithFlinch(
    PhaseState state, {
    bool update = false,
  }) {
    if (state
        .getPokemonState(playerType, null)
        .ailmentsWhere((element) => element.id == Ailment.flinch)
        .isNotEmpty) {
      if (update) {
        isSuccess = false;
        actionFailure = ActionFailure(ActionFailure.flinch);
      }
      return true;
    } else if (!isSuccess && actionFailure.id == ActionFailure.flinch) {
      if (update) {
        isSuccess = true;
        actionFailure = ActionFailure(ActionFailure.none);
      }
    }
    return false;
  }

  /// 必ず追加効果が起こる場合は自動でそれを設定する
  /// ```
  /// state: フェーズの状態
  /// ```
  void fillAutoAdditionalEffect(PhaseState state) {
    // みがわりに対して使用しても追加効果(的なもの)が発動するIDリスト
    const effectWithSubstituteIDs = [
      8,
      221,
      271,
      321,
      450,
    ];
    final replacedMove =
        getReplacedMove(move, state.getPokemonState(playerType, null));
    if ((!state
                .getPokemonState(playerType.opposite, null)
                .buffDebuffs
                .containsByID(BuffDebuff.substitute) ||
            ignoreSubstitute(state) ||
            effectWithSubstituteIDs.contains(replacedMove.effect.id)) &&
        replacedMove.isSurelyEffect()) {
      moveAdditionalEffects = MoveEffect(replacedMove.effect.id);
    } else {
      moveAdditionalEffects = MoveEffect(0);
    }
  }

  /// こうげきが相手のみがわりを無視するかどうかを返す
  /// ```
  /// state: フェーズの状態
  /// ```
  bool ignoreSubstitute(PhaseState state) {
    final myState = state.getPokemonState(playerType, null);
    final replacedMove = getReplacedMove(move, myState);
    // 対象が相手でない
    if (!replacedMove.isTargetYou) {
      return true;
    }
    // とくしゅなこうげき
    switch (replacedMove.effect.id) {
      case 357:
      case 360:
      case 410:
        return true;
    }
    // 場を対象とする変化技
    switch (replacedMove.target) {
      case Target.entireField:
      case Target.opponentsField:
      case Target.usersField:
        return true;
      default:
        break;
    }
    // 使用者がとくせい「すりぬけ」の場合
    if (myState.currentAbility.id == 151) {
      return true;
    }
    // 音技
    if (replacedMove.isSound) {
      return true;
    }
    return false;
  }

  /// 置き換わるわざは置き換え後のわざを返す。それ以外の場合は元のわざをそのまま返す
  /// ```
  /// move: 対象のわざ
  /// myState: 自身のポケモンの状態
  /// ```
  Move getReplacedMove(Move move, PokemonState myState) {
    var pokeData = PokeDB();
    Move ret = move;
    // わざの内容変更
    switch (move.effect.id) {
      case 83: // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
        {
          final founds = myState.hiddenBuffs.whereByID(BuffDebuff.copiedMove);
          if (founds.isNotEmpty) {
            ret = pokeData.moves[founds.first.extraArg1]!;
          }
        }
        break;
      case 84: // ほぼすべてのわざから1つをランダムで使う
      case 98: // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243: // 最後に出されたわざを出す(相手のわざとは限らない)
        if (extraArg3 != 0) {
          ret = pokeData.moves[extraArg3]!;
        }
        break;
      default:
        break;
    }

    return ret;
  }

  /// わざの名前を返す。置き換わるわざは置き換え後のわざの名前を返す
  /// ```
  /// move: 対象のわざ
  /// myState: 自身のポケモンの状態
  /// ```
  String getReplacedMoveName(Move move, PokemonState myState) {
    var pokeData = PokeDB();
    String ret = move.displayName;
    // わざの内容変更
    switch (move.effect.id) {
      case 83: // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
        {
          final founds = myState.hiddenBuffs.whereByID(BuffDebuff.copiedMove);
          if (founds.isNotEmpty) {
            ret =
                '${pokeData.moves[founds.first.extraArg1]!.displayName}(${move.displayName})';
          }
        }
        break;
      case 84: // ほぼすべてのわざから1つをランダムで使う
      case 98: // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243: // 最後に出されたわざを出す(相手のわざとは限らない)
        if (extraArg3 != 0) {
          ret = '${pokeData.moves[extraArg3]!.displayName}(${move.displayName}';
        }
        break;
      default:
        break;
    }

    return ret;
  }

  /// わざのタイプを返す。置き換わるわざは置き換え後のわざのタイプを返す
  /// ```
  /// move: 対象のわざ
  /// myState: 自身のポケモンの状態
  /// yourState: 相手のポケモンの状態
  /// ```
  PokeType getReplacedMoveType(
      Move move, PokemonState myState, PhaseState state) {
    // わざの内容変更
    var replacedMove = getReplacedMove(move, myState);
    var ret = replacedMove.type;
    switch (replacedMove.effect.id) {
      //case 136:   // 個体値によってわざのタイプが変わる
      case 204: // 天気が変わっていると威力2倍、タイプも変わる
        switch (state.weather.id) {
          case Weather.sunny:
            ret = PokeType.fire;
            break;
          case Weather.rainy:
            ret = PokeType.water;
            break;
          case Weather.snowy:
            ret = PokeType.ice;
            break;
          case Weather.sandStorm:
            ret = PokeType.rock;
            break;
          default:
            break;
        }
        break;
      case 269: // 持っているプレートに応じてわざのタイプが変わる
        if (myState.holdingItem != null) {
          switch (myState.holdingItem!.id) {
            case 275: // ひのたまプレート
              moveType = PokeType.fire;
              break;
            case 276: // しずくプレート
              moveType = PokeType.water;
              break;
            case 277: // いかずちプレート
              moveType = PokeType.electric;
              break;
            case 278: // みどりのプレート
              moveType = PokeType.grass;
              break;
            case 279: // つららのプレート
              moveType = PokeType.ice;
              break;
            case 280: // こぶしのプレート
              moveType = PokeType.fight;
              break;
            case 281: // もうどくプレート
              moveType = PokeType.poison;
              break;
            case 282: // だいちのプレート
              moveType = PokeType.ground;
              break;
            case 283: // あおぞらプレート
              moveType = PokeType.fly;
              break;
            case 284: // ふしぎのプレート
              moveType = PokeType.psychic;
              break;
            case 285: // たまむしプレート
              moveType = PokeType.bug;
              break;
            case 286: // がんせきプレート
              moveType = PokeType.rock;
              break;
            case 287: // もののけプレート
              moveType = PokeType.ghost;
              break;
            case 288: // りゅうのプレート
              moveType = PokeType.dragon;
              break;
            case 289: // こわもてプレート
              moveType = PokeType.evil;
              break;
            case 290: // こつてつプレート
              moveType = PokeType.steel;
              break;
            case 684: // せいれいプレート
              moveType = PokeType.fairy;
              break;
            default:
              break;
          }
        }
        break;
      case 401: // わざのタイプが使用者のタイプ1のタイプになる
        ret = myState.isTerastaling ? myState.teraType1 : myState.type1;
        break;
      case 437: // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
        if (myState.buffDebuffs.containsByID(BuffDebuff.harapekoForm)) {
          ret = PokeType.evil;
        }
        break;
      case 444: // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
        // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
        if (myState.isTerastaling) {
          ret = myState.teraType1;
        }
        break;
      case 453: // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
        if (myState.isGround(state.getIndiFields(playerType))) {
          switch (state.field.id) {
            case Field.electricTerrain:
              ret = PokeType.electric;
              break;
            case Field.grassyTerrain:
              ret = PokeType.grass;
              break;
            case Field.mistyTerrain:
              ret = PokeType.fairy;
              break;
            case Field.psychicTerrain:
              ret = PokeType.psychic;
              break;
          }
        }
        break;
      case 487: // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき。ケンタロスのフォルムによってわざのタイプが変化する
        switch (myState.pokemon.no) {
          case 10250:
            ret = PokeType.fight;
            break;
          case 10251:
            ret = PokeType.fire;
            break;
          case 10252:
            ret = PokeType.water;
            break;
        }
        break;
      default:
        break;
    }

    return ret;
  }

  /// 確定で急所になるかどうかを返す
  /// ```
  /// move: 対象のわざ
  /// myState: 自身のポケモンの状態
  /// yourState: 相手のポケモンの状態
  /// yourFields: 相手の場
  /// ```
  bool isCriticalFromMove(Move move, PokemonState myState,
      PokemonState yourState, List<IndividualField> yourFields) {
    var mA = myState.currentAbility.id;
    var yA = yourState.currentAbility.id;
    // (こうげき側がとくせいを無視できず、)ぼうぎょ側がカブトアーマー/シェルアーマー/おまじない(場)ならば急所に当たらない
    if ((yourState.holdingItem?.id == 1697 ||
            (mA != 104 && mA != 163 && mA != 164)) &&
        (yA == 4 || yA == 75)) return false;
    switch (move.effect.id) {
      case 289: // かならず急所に当たる
      case 462: // 3回連続でこうげきする。かならず急所に当たる
      case 486: // 必中かつ必ず急所に当たる
        return true;
      default:
        break;
    }
    if (yourState
            .ailmentsWhere(
                (e) => e.id == Ailment.poison || e.id == Ailment.badPoison)
            .isNotEmpty &&
        myState.buffDebuffs.containsByID(BuffDebuff.merciless)) {
      return true;
    }
    return false;
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
    return this == t;
  }

  /// 内容をクリアする
  void clear() {
    playerType = PlayerType.none;
    type = TurnActionType.none;
    teraType = PokeType.unknown;
    move = Move.none();
    isSuccess = true;
    _actionFailure = ActionFailure(ActionFailure.none);
    hitCount = 1;
    criticalCount = 0;
    moveEffectivenesses = MoveEffectiveness.normal;
    realDamage = 0;
    percentDamage = 0;
    breakSubstitute = false;
    moveAdditionalEffects = MoveEffect(MoveEffect.none);
    extraArg1 = 0;
    extraArg2 = 0;
    extraArg3 = 0;
    _changePokemonIndexes = [null, null];
    _prevPokemonIndexes = [null, null];
    moveType = PokeType.unknown;
    isFirst = null;
    _isValid = false;
  }

  /// わざに関する情報のみクリアする
  void clearMove() {
    teraType = PokeType.unknown;
    move = Move.none();
    isSuccess = true;
    _actionFailure = ActionFailure(ActionFailure.none);
    hitCount = 1;
    criticalCount = 0;
    moveEffectivenesses = MoveEffectiveness.normal;
    realDamage = 0;
    percentDamage = 0;
    breakSubstitute = false;
    moveAdditionalEffects = MoveEffect(MoveEffect.none);
    extraArg1 = 0;
    extraArg2 = 0;
    extraArg3 = 0;
    _changePokemonIndexes = [null, null];
    _prevPokemonIndexes = [null, null];
    moveType = PokeType.unknown;
    isFirst = null;
    _isValid = false;
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
    required Function() onEdit,
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    return Container();
  }

  /// SQLに保存された文字列からTurnEffectActionをパース
  /// /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字1
  /// split2: 区切り文字2
  /// split3: 区切り文字3
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
  static TurnEffectAction deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    final List turnMoveElements = str.split(split1);
    // effectType
    turnMoveElements.removeAt(0);
    // playerType
    final playerType =
        PlayerTypeNum.createFromNumber(int.parse(turnMoveElements.removeAt(0)));
    TurnEffectAction turnEffectAction = TurnEffectAction(player: playerType);
    // type
    turnEffectAction.type =
        TurnActionType.values[int.parse(turnMoveElements.removeAt(0))];
    // teraType
    turnEffectAction.teraType =
        PokeType.values[int.parse(turnMoveElements.removeAt(0))];
    // move
    if (version == 1) {
      final List moveElements = turnMoveElements.removeAt(0).split(split2);
      int moveID = int.parse(moveElements.removeAt(0));
      final move = PokeDB().moves[moveID]!;
      turnEffectAction.move = Move(
        moveID,
        moveElements.removeAt(0),
        '',
        PokeType.values[int.parse(moveElements.removeAt(0))],
        int.parse(moveElements.removeAt(0)),
        int.parse(moveElements.removeAt(0)),
        int.parse(moveElements.removeAt(0)),
        Target.values[int.parse(moveElements.removeAt(0))],
        DamageClass(int.parse(moveElements.removeAt(0))),
        MoveEffect(int.parse(moveElements.removeAt(0))),
        int.parse(moveElements.removeAt(0)),
        int.parse(moveElements.removeAt(0)),
        move.isDirect,
        move.isSound,
        move.isDrain,
        move.isPunch,
        move.isWave,
        move.isDance,
        move.isRecoil,
        move.isAdditionalEffect,
        move.isAdditionalEffect2,
        move.isBite,
        move.isCut,
        move.isWind,
        move.isPowder,
        move.isBullet,
        move.failWithProtect,
      );
    } else {
      turnEffectAction.move =
          PokeDB().moves[int.parse(turnMoveElements.removeAt(0))]!;
    }
    // isSuccess
    turnEffectAction.isSuccess = int.parse(turnMoveElements.removeAt(0)) != 0;
    // actionFailure
    turnEffectAction._actionFailure =
        ActionFailure(int.parse(turnMoveElements.removeAt(0)));
    // hitCount
    turnEffectAction.hitCount = int.parse(turnMoveElements.removeAt(0));
    // criticalCount
    turnEffectAction.criticalCount = int.parse(turnMoveElements.removeAt(0));
    // moveEffectiveness
    turnEffectAction.moveEffectivenesses =
        MoveEffectiveness.values[int.parse(turnMoveElements.removeAt(0))];
    // realDamage
    turnEffectAction.realDamage = int.parse(turnMoveElements.removeAt(0));
    // percentDamage
    turnEffectAction.percentDamage = int.parse(turnMoveElements.removeAt(0));
    // breakSubstitute
    turnEffectAction.breakSubstitute =
        int.parse(turnMoveElements.removeAt(0)) != 0;
    // moveAdditionalEffect
    turnEffectAction.moveAdditionalEffects =
        MoveEffect(int.parse(turnMoveElements.removeAt(0)));
    // extraArg1
    turnEffectAction.extraArg1 = int.parse(turnMoveElements.removeAt(0));
    // extraArg2
    turnEffectAction.extraArg2 = int.parse(turnMoveElements.removeAt(0));
    // extraArg3
    turnEffectAction.extraArg3 = int.parse(turnMoveElements.removeAt(0));
    // _changePokemonIndexes
    var changePokemonIndexes = turnMoveElements.removeAt(0).split(split2);
    for (int i = 0; i < 2; i++) {
      if (changePokemonIndexes[i] == '') {
        turnEffectAction._changePokemonIndexes[i] = null;
      } else {
        turnEffectAction._changePokemonIndexes[i] =
            int.parse(changePokemonIndexes[i]);
      }
    }
    // _prevPokemonIndexes
    var prevPokemonIndexes = turnMoveElements.removeAt(0).split(split2);
    for (int i = 0; i < 2; i++) {
      if (prevPokemonIndexes[i] == '') {
        turnEffectAction._prevPokemonIndexes[i] = null;
      } else {
        turnEffectAction._prevPokemonIndexes[i] =
            int.parse(prevPokemonIndexes[i]);
      }
    }
    // moveType
    turnEffectAction.moveType =
        PokeType.values[int.parse(turnMoveElements.removeAt(0))];
    // isFirst
    final isFirstStr = turnMoveElements.removeAt(0);
    if (isFirstStr != '') {
      turnEffectAction.isFirst = int.parse(isFirstStr) != 0;
    }

    return turnEffectAction;
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1: 区切り文字1
  /// split2: 区切り文字2
  /// split3: 区切り文字3
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
    // type
    ret += type.index.toString();
    ret += split1;
    // teraType
    ret += teraType.index.toString();
    ret += split1;
    // move
/*    // version==1
      // id
      ret += move.id.toString();
      ret += split2;
      // displayName
      ret += move.displayName;
      ret += split2;
      // type
      ret += move.type.id.toString();
      ret += split2;
      // power
      ret += move.power.toString();
      ret += split2;
      // accuracy
      ret += move.accuracy.toString();
      ret += split2;
      // priority
      ret += move.priority.toString();
      ret += split2;
      // target
      ret += move.target.id.toString();
      ret += split2;
      // damageClass
      ret += move.damageClass.id.toString();
      ret += split2;
      // effect
      ret += move.effect.id.toString();
      ret += split2;
      // effectChance
      ret += move.effectChance.toString();
      ret += split2;
      // pp
      ret += move.pp.toString();
*/
    ret += move.id.toString();
    ret += split1;
    // isSuccess
    ret += isSuccess ? '1' : '0';
    ret += split1;
    // actionFailure
    ret += _actionFailure.id.toString();
    ret += split1;
    // hitCount
    ret += hitCount.toString();
    ret += split1;
    // criticalCount
    ret += criticalCount.toString();
    ret += split1;
    // moveEffectivenesses
    ret += moveEffectivenesses.index.toString();
    ret += split1;
    // realDamage
    ret += realDamage.toString();
    ret += split1;
    // percentDamage
    ret += percentDamage.toString();
    ret += split1;
    // breakSubstitute
    ret += breakSubstitute ? '1' : '0';
    ret += split1;
    // moveAdditionalEffects
    ret += moveAdditionalEffects.id.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();
    ret += split1;
    // extraArg3
    ret += extraArg3.toString();
    ret += split1;
    // _changePokemonIndex
    for (int i = 0; i < 2; i++) {
      if (_changePokemonIndexes[i] != null) {
        ret += _changePokemonIndexes[i].toString();
      }
      ret += split2;
    }
    ret += split1;
    // _prevPokemonIndex
    for (int i = 0; i < 2; i++) {
      if (_prevPokemonIndexes[i] != null) {
        ret += _prevPokemonIndexes[i].toString();
      }
      ret += split2;
    }
    ret += split1;
    // moveType
    ret += moveType.index.toString();
    ret += split1;
    // isFirst
    if (isFirst != null) {
      ret += isFirst! ? '1' : '0';
    }

    return ret;
  }

  /// 有効かどうか
  @override
  bool isValid() {
    if (type == TurnActionType.surrender) {
      return true;
    }
    if (!isSuccess) {
      return playerType != PlayerType.none /* && actionFailure.id != 0*/;
    }
    if (!_isValid) {
      return false;
    }
    switch (type) {
      case TurnActionType.move:
        return playerType != PlayerType.none && move.id != 0;
      case TurnActionType.change:
        return getChangePokemonIndex(playerType) != null;
      default:
        return false;
    }
  }
}

/// コマンド入力ページ遷移を管理するclass
class CommandPagesController {
  /// ページのインデックス
  int pageIndex = 0;
}
