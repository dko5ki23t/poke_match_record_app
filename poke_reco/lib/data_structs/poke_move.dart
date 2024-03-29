import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/pokemon_dropdown_menu_item.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ダメージ
class DamageClass {
  static const int none = 0;
  static const int status = 1;    // へんか(ダメージなし)
  static const int physical = 2;  // ぶつり
  static const int special = 3;   // とくしゅ

  const DamageClass(this.id);

  final int id;
}

class TurnMoveType {
  static const int none = 0;
  static const int move = 1;
  static const int change = 2;
  static const int surrender = 3;

  const TurnMoveType(this.id);

  final int id;
}

class MoveHit {
  static const int hit = 0;
  static const int critical = 1;
  static const int notHit = 2;
  static const int fail = 3;

  const MoveHit(this.id);

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        switch (id) {
          case hit:
            return '命中';
          case critical:
            return '急所に命中';
          case notHit:
            return '当たらなかった';
          case fail:
            return 'うまく決まらなかった';
          default:
            return '';
        }
      case Language.english:
      default:
        switch (id) {
          case hit:
            return 'Hit';
          case critical:
            return 'Critical Hit';
          case notHit:
            return 'Missed';
          case fail:
            return 'Failed';
          default:
            return '';
        }
    }
  }

  final int id;
}

class MoveEffectiveness {
  static const int normal = 0;
  static const int great = 1;
  static const int notGood = 2;
  static const int noEffect = 3;

  const MoveEffectiveness(this.id);

  final int id;
}

class MoveAdditionalEffect {
  static const int none = 0;
  static const int speedDown = 1;

  const MoveAdditionalEffect(this.id);

  final int id;
}

class ActionFailure {
  static const int none = 0;
  static const int recoil = 1;        // わざの反動
  static const int sleep = 2;         // ねむり(カウント消費)
  static const int freeze = 3;        // こおり(回復判定で失敗)
  static const int flinch = 4;        // ひるみ
  static const int taunt = 5;        // ちょうはつ
  static const int confusion = 6;    // こんらんにより自傷
  static const int paralysis = 7;    // まひ
  static const int infatuation = 8;  // メロメロ
  static const int protected = 9;    // 相手にこうげきを防がれた
  static const int other = 10;        // その他
  static const int size = 11;

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('わざの反動', 'Need recharge of move'),
    2: Tuple2('ねむり', 'Sleep'),
    3: Tuple2('こおり', 'Freeze'),
//    4: Tuple2('PPが残っていない', ''),
//    5: Tuple2('なまけ', ''),
//    6: Tuple2('きあいパンチ中にダメージを受けた', ''),
    4: Tuple2('ひるみ', 'Flinch'),
//    11: Tuple2('じごくづき', ''),
//    12: Tuple2('こだわり中以外のわざを使った', ''),
    5: Tuple2('ちょうはつ', 'Taunt'),
//    14: Tuple2('ふういん', ''),
    6: Tuple2('こんらん', 'Confusion'),
    7: Tuple2('まひ', 'Paralysis'),
    8: Tuple2('メロメロ', 'Attract'),
    9: Tuple2('相手にこうげきを防がれた', 'Prevented'),
    10: Tuple2('その他', 'Others'),
  };

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  const ActionFailure(this.id);

  final int id;
}

class DamageGetter {
  int minDamage = 0;
  int maxDamage = 0;
  int minDamagePercent = 0;
  int maxDamagePercent = 0;

  String get rangeString {
    if (minDamage == maxDamage) {
      return minDamage.toString();
    }
    else {
      return '$minDamage ~ $maxDamage';
    }
  }

  String get rangePercentString {
    if (minDamagePercent == maxDamagePercent) {
      return '$minDamagePercent%';
    }
    else {
      return '$minDamagePercent% ~ $maxDamagePercent%';
    }
  }
}

class TurnMove {
  PlayerType playerType = PlayerType.none;
  TurnMoveType type = TurnMoveType(TurnMoveType.none);
  PokeType teraType = PokeType.createFromId(0);   // テラスタルなし
  Move move = Move(0, '', '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
  bool isSuccess = true;      // 行動の成功/失敗
  ActionFailure actionFailure = ActionFailure(0);    // 行動失敗の理由
  List<MoveHit> moveHits = [MoveHit(MoveHit.hit)];   // 命中した/急所/外した
  List<MoveEffectiveness> moveEffectivenesses = [MoveEffectiveness(MoveEffectiveness.normal)];   // こうかは(テキスト無し)/ばつぐん/いまひとつ/なし
  List<int> realDamage = [0];     // わざによって受けたダメージ（確定値）
  List<int> percentDamage = [0];  // わざによって与えたダメージ（概算値、割合）
  List<MoveEffect> moveAdditionalEffects = [MoveEffect(MoveEffect.none)];
  List<int> extraArg1 = [0];
  List<int> extraArg2 = [0];
  List<int> extraArg3 = [0];
  List<int?> _changePokemonIndexes = [null, null];
  PokeType moveType = PokeType.createFromId(0);
  bool isFirst = false;   // ターン内最初の行動か

  TurnMove copyWith() =>
    TurnMove()
    ..playerType = playerType
    ..type = type
    ..teraType = teraType
    ..move = move.copyWith()
    ..isSuccess = isSuccess
    ..actionFailure = actionFailure
    ..moveHits = [...moveHits]
    ..moveEffectivenesses = [...moveEffectivenesses]
    ..realDamage = [...realDamage]
    ..percentDamage = [...percentDamage]
    ..moveAdditionalEffects = [...moveAdditionalEffects]
    ..extraArg1 = [...extraArg1]
    ..extraArg2 = [...extraArg2]
    ..extraArg3 = [...extraArg3]
    .._changePokemonIndexes = [..._changePokemonIndexes]
    ..moveType = moveType
    ..isFirst = isFirst;

  int? getChangePokemonIndex(PlayerType player) {
    if (player == PlayerType.me) return _changePokemonIndexes[0];
    return _changePokemonIndexes[1];
  }

  void setChangePokemonIndex(PlayerType player, int? val) {
    if (player == PlayerType.me) {
      _changePokemonIndexes[0] = val;
    }
    else {
      _changePokemonIndexes[1] = val;
    }
  }

  // わざが成功＆ヒットしたかどうか
  // へんかわざなら成功したかどうか、こうげきわざならヒットしたかどうか
  bool isNormallyHit(int continousCount) {
    return isSuccess &&
      (move.damageClass.id >= 2 && 
       moveHits[continousCount].id != MoveHit.notHit &&
       moveHits[continousCount].id != MoveHit.fail) ||
      (move.damageClass.id == 1);
  }

  // 追加効果に対応する文字列
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

  List<Guide> processMove(
    Party ownParty,
    Party opponentParty,
    PokemonState ownState,
    PokemonState opponentState,
    PhaseState state,
    int continuousCount,
    List<int> invalidGuideIDs,
    {
      DamageGetter? damageGetter,
      required AppLocalizations loc,
    }
  )
  {
    final pokeData = PokeDB();
    List<Guide> ret = [];
    if (playerType == PlayerType.none) return ret;

    var ownPokemonState = ownState;
    var opponentPokemonState = opponentState;
    var myState = playerType == PlayerType.me ? ownState : opponentState;
    var yourState = playerType == PlayerType.me ? opponentState : ownState;
    var beforeChangeMyState = myState.copyWith();

    // 行動1の場合は登録
    if (isFirst) {
      state.firstAction = this;
    }
    // みちづれ状態解除
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.destinyBond);
    // おんねん状態解除
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.grudge);
    // きょけんとつげき後状態解除
    myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.certainlyHittedDamage2);

    // こうさん
    if (type.id == TurnMoveType.surrender) {
      // パーティ全員ひんし状態にする
      for (var pokeState in state.getPokemonStates(playerType)) {
        pokeState.remainHP = 0;
        pokeState.remainHPPercent = 0;
        pokeState.isFainting = true;
      }
      return ret;
    }

    // テラスタル
    if (teraType.id != 0) {
      myState.isTerastaling = true;
      myState.teraType1 = teraType;
      if (playerType == PlayerType.me) {
        state.hasOwnTerastal = true;
      }
      else {
        state.hasOpponentTerastal = true;
      }
    }

    // ポケモン交代
    if (type.id == TurnMoveType.change) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      myState.processExitEffect(playerType == PlayerType.me, yourState, state);
      state.setPokemonIndex(playerType, getChangePokemonIndex(playerType)!);
      state.getPokemonState(playerType, null).processEnterEffect(true, state, yourState);
      state.getPokemonState(playerType, null).hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
      return ret;
    }

    if (continuousCount == 0) {
      // ねむりカウント加算
      var sleep = myState.ailmentsWhere((e) => e.id == Ailment.sleep);
      if (sleep.isNotEmpty) sleep.first.turns++;
      // アンコールカウント加算
      var encore = myState.ailmentsWhere((e) => e.id == Ailment.encore);
      if (encore.isNotEmpty) encore.first.turns++;
      // ちょうはつのカウントインクリメント
      var taunt = myState.ailmentsWhere((e) => e.id == Ailment.taunt);
      if (taunt.isNotEmpty) taunt.first.extraArg1++;
    }

    // こんらんによる自傷
    if (actionFailure.id == ActionFailure.confusion) {
      myState.remainHP -= extraArg1[continuousCount];
      myState.remainHPPercent -= extraArg2[continuousCount];
      return ret;
    }

    if (move.id == 0) return ret;

    // ゾロアーク判定
    // ゾロアーク判定だけは、有効/無効でこの後の処理が変わるため、
    // TurnEffectのinvalidGuideIDsに含まれるかどうかチェックする必要がある
    if (!invalidGuideIDs.contains(Guide.confZoroark)) {
      int check = 0;
      check += state.canZorua ? PokeBase.zoruaNo : 0;
      check += state.canZoroark ? PokeBase.zoroarkNo : 0;
      check += state.canZoruaHisui ? PokeBase.zoruaHisuiNo : 0;
      check += state.canZoroarkHisui ? PokeBase.zoroarkHisuiNo : 0;
      if (check == PokeBase.zoruaNo || check == PokeBase.zoroarkNo ||
          check == PokeBase.zoruaHisuiNo || check == PokeBase.zoroarkHisuiNo
      ) {
        // へんしん状態でなく、当該ポケモンが使えないわざを選択していたら
        if (pokeData.pokeBase[myState.pokemon.no]!.move.where((e) => e.id == move.id && e.id != 0).isEmpty &&
            myState.buffDebuffs.where((e) => e.id == BuffDebuff.transform).isEmpty
        ) {
          ret.add(Guide()
            ..guideId = Guide.confZoroark
            ..canDelete = true
            ..guideStr = loc.battleGuideConfZoroark(myState.pokemon.name, pokeData.pokeBase[check]!.name)
          );
          state.makePokemonOther(playerType, check);
          myState = state.getPokemonState(playerType, null);
          myState.setCurrentAbility(pokeData.abilities[149]!, yourState, playerType == PlayerType.me, state);
          ownPokemonState = state.getPokemonState(PlayerType.me, null);
          opponentPokemonState = state.getPokemonState(PlayerType.opponent, null);
        }
      }
    }

    // わざ確定(失敗時でも確定はできる)
    var tmp = myState.moves.where(
      (element) => element.id != 0 && element.id == move.id
    );
    if (move.id != 165 &&     // わるあがきは除外
        playerType == PlayerType.opponent &&
        type.id == TurnMoveType.move &&
        opponentPokemonState.moves.length < 4 &&
        tmp.isEmpty
    ) {
      ret.add(Guide()
        ..guideId = Guide.confMove
        ..canDelete = false
        ..guideStr = loc.battleGuideConfMove(move.displayName, myState.pokemon.omittedName)
      );
      opponentPokemonState.moves.add(move);
    }

    // わざPP消費
    if (continuousCount == 0 && isSuccess) {
      int moveIdx = myState.moves.indexWhere((element) => element.id != 0 && element.id == move.id);
      if (moveIdx >= 0) {
        myState.usedPPs[moveIdx]++;
        if (yourState.currentAbility.id == 46) myState.usedPPs[moveIdx]++;
      }
    }

    // メトロノーム用
    if (continuousCount == 0) {
      int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2);
      if (findIdx >= 0) {
        if (!isSuccess) {
          if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.recoiling).isEmpty) {
            myState.hiddenBuffs[findIdx].extraArg1 = 0;
          }
        }
      }
    }

    if (!isSuccess || moveHits[continuousCount].id == MoveHit.fail || moveHits[continuousCount].id == MoveHit.notHit) return ret;

    List<IndividualField> myFields = state.getIndiFields(playerType);
    List<IndividualField> yourFields = state.getIndiFields(playerType.opposite);
    PlayerType myPlayerType = playerType;
    PlayerType yourPlayerType = playerType == PlayerType.me ? PlayerType.opponent : PlayerType.me;

    // ダメージ計算式を表示するかどうか
    bool showDamageCalc = false;
    // わざの威力(わざによっては変動するため)
    int movePower = 0;
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
    bool isCritical = moveHits[continuousCount].id == MoveHit.critical;
    // 相手のとくせいを無視してダメージ計算するか
    bool ignoreAbility = false;
    // こうげきの代わりにぼうぎょの数値とランク補正を使ってダメージ計算するか
    bool defenseAltAttack = false;
    // ダメージ計算をぶつりわざ/とくしゅわざのどちらとして行うか
    int moveDamageClassID = 0;
    // はれによるダメージ補正率が0.5倍→1.5倍
    bool isSunny1_5 = false;
    // ノーマルスキンによって威力が1.2倍になるか
    bool isNormalized1_2 = false;
    // タイプ相性計算時、追加で計算するタイプ
    PokeType? additionalMoveType;
    // 半減きのみを使用したか
    double halvedBerry = 0.0;
    // ダメージ計算時、テラスタルまたはステラの補正がかかったか
    bool isTeraStellarHosei = false;

    {
      Move replacedMove = getReplacedMove(move, continuousCount, myState);   // 必要に応じてわざの内容変更
      moveDamageClassID = replacedMove.damageClass.id;

      // わざの対象決定
      List<PokemonState> targetStates = [yourState];
      List<List<IndividualField>> targetIndiFields = [yourFields];
      List<PlayerType> targetPlayerTypes = [yourPlayerType];
      PhaseState? targetField;
      switch (replacedMove.target.id) {
        case 1:     // TODO:不定、わざによって異なる のろいとかカウンターとか
          break;
        case 2:     // 選択した自分以外の場にいるポケモン
                    // (現状、さきどりとダイマックスわざのみ。SVで使用不可のため考慮しなくて良さそう)
        case 3:     // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
          targetStates = [];
          targetIndiFields = [];
          targetPlayerTypes = [];
          break;
        case 4:     // 使用者の場
        case 7:     // 使用者自身
        case 5:     // 使用者もしくは味方
        case 13:    // 使用者と味方
        case 15:    // すべての味方
          targetStates = [myState];
          targetIndiFields = [myFields];
          targetPlayerTypes = [myPlayerType];
          break;
        case 6:     // 相手の場
        case 8:     // ランダムな相手
        case 9:     // 場にいる使用者以外の全ポケモン
        case 10:    // 選択した自分以外の場にいるポケモン
        case 11:    // 場にいる相手側の全ポケモン
          break;
        case 12:    // 全体の場
          targetStates = [myState, yourState];
          targetIndiFields = [myFields, yourFields];
          targetPlayerTypes = [myPlayerType, yourPlayerType];
          targetField = state;
          break;
        case 14:    // 場にいるすべてのポケモン
          targetStates.add(myState);
          targetIndiFields.add(myFields);
          targetPlayerTypes.add(myPlayerType);
          break;
        case 16:    // ひんしの(味方)ポケモン
          targetStates.clear();
          targetIndiFields.clear();
          targetPlayerTypes.clear();  // 使わない
          for (int i = 0; i < state.getPokemonStates(playerType).length; i++) {
            if (i != state.getPokemonIndex(playerType, null)-1 && state.getPokemonStates(playerType)[i].isFainting) {
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
      if (replacedMove.damageClass.id == 1 && yourState.ailmentsWhere((e) => e.id == Ailment.magicCoat).isNotEmpty) {
        for (int i = 0; i < targetStates.length; i++) {
          if (targetStates[i] == yourState) {
            targetStates[i] = myState;
          }
        }
      }
      // メトロノーム用
      if (continuousCount == 0) {
        int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.sameMoveCount);
        if (findIdx >= 0) {
          if ((myState.hiddenBuffs[findIdx].extraArg1 / 100).floor() == replacedMove.id) {
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.chargingMove).isEmpty || myState.hiddenBuffs[findIdx].extraArg1 == 0) {
              myState.hiddenBuffs[findIdx].extraArg1++;
            }
          }
          else {
            myState.hiddenBuffs[findIdx].extraArg1 = replacedMove.id * 100;
          }
        }
        else {
          myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.sameMoveCount)..extraArg1 = replacedMove.id * 100);
        }
      }
      // ねごと系以外のわざを出しているならねむり解除とみなす
      if (replacedMove.id != 156 && replacedMove.id != 173 && replacedMove.id != 214) {
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
      }
      // 動いているということで、こおり状態解除とみなす
      myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);

      // ダメージ計算式を表示するかどうか
      showDamageCalc = false;
      // ダメージ計算式が特殊か(固定ダメージ等)
      // わざの威力(わざによっては変動するため)
      movePower = replacedMove.power;
      // わざのタイプ(わざによっては変動するため)
      moveType = replacedMove.type;
      // ダメージ計算式文字列
      damageCalc = null;
      // 半減きのみを使用したか
      if (targetStates.isNotEmpty) {
        int findIdx = targetStates[0].buffDebuffs.indexWhere((e) => e.id == BuffDebuff.halvedBerry);
        if (findIdx >= 0) {
          halvedBerry = targetStates[0].buffDebuffs[findIdx].extraArg1 == 1 ? 0.25 : 0.5;
        }
      }

      switch (moveDamageClassID) {
        case 1:     // へんか
          break;
        case 2:     // ぶつり
        case 3:     // とくしゅ
          showDamageCalc = true;
          break;
        default:
          break;
      }

      // 追加効果
      bool effectOnce = false;    // ターゲットが(便宜上)複数(==targetStates.length > 1)でも、処理は一回にしたい場合にtrueにする(さむいギャグなど)
      for (int i = 0; i < targetStates.length; i++) {
        // ちからずくの場合、追加効果なし
        if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.sheerForce).isNotEmpty && replacedMove.isAdditionalEffect) break;

        if (effectOnce) break;
        var targetState = targetStates[i];
        var targetIndiField = targetIndiFields[i];
        var targetPlayerType = targetPlayerTypes[i];
        switch (moveAdditionalEffects[continuousCount].id) {
          case 1:     // 追加効果なし
          case 104:   // 追加効果なし
          case 86:    // なにも起きない
          case 370:   // 効果なし
          case 371:   // 効果なし
          case 379:   // 通常こうげき
          case 383:   // 場に出た最初の行動時のみ成功する
          case 406:   // 通常こうげき
          case 417:   // 通常こうげき
          case 439:   // 通常こうげき
            break;
          case 2:     // 眠らせる
          case 499:   // 眠らせる(確率)
            targetState.ailmentsAdd(Ailment(Ailment.sleep), state);
            break;
          case 3:     // どくにする(確率)
          case 67:    // どくにする
          case 78:    // 2回こうげき、どくにする(確率)
          case 210:   // どくにする(確率)。急所に当たりやすい
            targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            break;
          case 4:     // 与えたダメージの半分だけHP回復
          case 9:     // ねむり状態の対象にのみダメージ、与えたダメージの半分だけHP回復
          case 33:    // 最大HPの半分だけ回復する
          case 49:    // 使用者は相手に与えたダメージの1/4ダメージを受ける
          case 133:   // 使用者のHP回復。回復量は天気による
          case 199:   // 与えたダメージの33%を使用者も受ける
          case 255:   // 使用者は最大HP1/4の反動ダメージを受ける
          case 270:   // 与えたダメージの1/2を使用者も受ける
          case 346:   // 与えたダメージの半分だけHP回復
          case 349:   // 与えたダメージの3/4だけHP回復
          case 382:   // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
          case 387:   // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
          case 420:   // 最大HP1/2(小数点切り上げ)を削ってこうげき
          case 441:   // 最大HP1/4だけ回復
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            break;
          case 5:     // やけどにする(確率)
          case 168:   // やけどにする
          case 201:   // やけどにする(確率)。急所に当たりやすい
          case 472:   // やけどにする(確率)。天気があめの時は必中
            targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            break;
          case 6:     // こおりにする(確率)
          case 261:   // こおりにする(確率)。天気がゆきのときは必中
            targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            break;
          case 7:     // まひにする(確率)
          case 68:    // まひにする
          case 153:   // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
          case 372:   // まひにする(確率)
          case 471:   // まひにする(確率)。天気があめの時は必中
            targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            break;
          case 8:     // 使用者はひんしになる
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 10:    // 対象が最後に使ったわざを使う(SV使用不可のため処理なし)
            break;
          case 11:    // 使用者のこうげきを1段階上げる
          case 140:   // 使用者のこうげきを1段階上げる(確率)
          case 375:   // 使用者のこうげきを1段階上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            break;
          case 12:    // 使用者のぼうぎょを1段階上げる
          case 139:   // 使用者のぼうぎょを1段階上げる(確率)
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            break;
          case 14:    // 使用者のとくこうを1段階上げる
          case 277:   // 使用者のとくこうを1段階上げる(確率)
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            break;
          case 17:    // 使用者のかいひを1段階上げる
            myState.addStatChanges(true, 6, 1, targetState, moveId: replacedMove.id);
            break;
          case 18:    // 必中
          case 79:    // 必中
          case 381:   // 必中
            break;
          case 19:    // こうげきを1段階下げる
          case 69:    // こうげきを1段階下げる(確率)
          case 365:   // こうげきを1段階下げる
          case 396:   // こうげきを1段階下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 20:    // ぼうぎょを1段階下げる
          case 70:    // ぼうぎょを1段階下げる(確率)
          case 397:   // ぼうぎょを1段階下げる
            targetState.addStatChanges(targetState == myState, 1, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 21:    // すばやさを1段階下げる
          case 71:    // すばやさを1段階下げる(確率)
          case 331:   // すばやさを1段階下げる
          case 470:   // すばやさを1段階下げる(確率)。天気があめの時は必中
            targetState.addStatChanges(targetState == myState, 4, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 24:    // めいちゅうを1段階下げる
          case 74:    // めいちゅうを1段階下げる(確率)
            targetState.addStatChanges(targetState == myState, 5, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 25:    // かいひを1段階下げる
            targetState.addStatChanges(targetState == myState, 6, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 26:    // すべての能力ランクを0にリセットする
            targetState.resetStatChanges();
            break;
          case 27:    // 2ターン後の自身の行動までがまん状態になり、その間受けた合計ダメージの2倍を相手に返す(SV使用不可のため処理なし)
            //myState.ailmentsAdd(Ailment(Ailment.bide), state);
            break;
          case 28:    // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
            myState.ailmentsAdd(Ailment(Ailment.thrash)..extraArg1 = replacedMove.id, state);
            if (extraArg1[continuousCount] != 0) {
              // あばれるの解除
              myState.ailmentsRemoveWhere((e) => e.id == Ailment.thrash);
              // こんらんする
              myState.ailmentsAdd(Ailment(Ailment.confusion), state);
            }
            break;
          case 29:    // 相手ポケモンをランダムに交代させる
          case 314:   // 相手ポケモンをランダムに交代させる
            if (getChangePokemonIndex(targetPlayerType) != null) {
              targetState.processExitEffect(targetPlayerType == PlayerType.me, myState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType.opposite, getChangePokemonIndex(targetPlayerType)!);
              newState = state.getPokemonState(playerType.opposite, null);
              newState.processEnterEffect(targetPlayerType == PlayerType.me, state, myState);
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            break;
          case 30:    // 2～5回連続でこうげきする
          case 361:   // 2～5回連続でこうげきする
            break;
          case 31:    // 使用者のタイプを、使用者が覚えているわざの一番上のタイプに変更する
          case 94:    // 使用者のタイプを、相手が直前に使ったわざのタイプを半減/無効にするタイプに変更する
            if (extraArg1[continuousCount] != 0) {
              myState.type1 = PokeType.createFromId(extraArg1[continuousCount]);
              myState.type2 = null;
            }
            break;
          case 32:    // ひるませる(確率)
          case 93:    // ひるませる(確率)。ねむり状態のときのみ成功
          case 159:   // ひるませる。場に出て最初の行動のときのみ成功
            targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            break;
          case 34:    // もうどくにする
          case 203:   // もうどくにする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.badPoison), state);
            break;
          case 35:    // 戦闘後おかねを拾える
            break;
          case 36:    // 場に「ひかりのかべ」を発生させる
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.lightScreen);
            if (findIdx < 0) targetIndiField.add(IndividualField(IndividualField.lightScreen)..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
            break;
          case 37:    // やけど・こおり・まひのいずれかにする(確率)
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(extraArg1[continuousCount]), state);
            }
            break;
          case 38:    // 使用者はHP満タン・状態異常を回復して2ターン眠る
            myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            if (myPlayerType == PlayerType.me) {
              myState.remainHP = myState.pokemon.h.real;
            }
            else {
              myState.remainHPPercent = 100;
            }
            myState.ailmentsAdd(Ailment(Ailment.sleep)..extraArg1 = 3, state);
            break;
          case 39:    // 一撃必殺
            targetState.remainHP = 0;
            targetState.remainHPPercent = 0;
            targetState.isFainting = true;
            break;
          case 40:    // 1ターン目にため、2ターン目でこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 41:    // 残りHPの半分のダメージ(残り1の場合は1)
            {
              int damage = 0;
              if (targetPlayerType == PlayerType.me) {
                damage = (targetState.remainHP / 2).floor();
                if (damage == 0) damage = 1;
                damageCalc = loc.battleDamageFixed1(damage);
              }
              else {
                damage = (targetState.remainHPPercent / 2).floor();
                damageCalc = loc.battleDamageFixed2(damage);
              }
            }
            break;
          case 42:    // 40の固定ダメージ
            damageCalc = loc.battleDamageFixed3;
            break;
          case 43:    // バインド状態にする
            targetState.ailmentsAdd(Ailment(Ailment.partiallyTrapped), state);
            break;
          case 44:    // きゅうしょに当たりやすい
            break;
          case 45:    // 2回こうげき
            break;
          case 46:    // わざを外すと使用者に、使用者の最大HP1/2のダメージ
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            break;
          case 47:    // 場に「しろいきり」を発生させる
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.mist);
            if (findIdx < 0) targetIndiField.add(IndividualField(IndividualField.mist));
            break;
          case 48:    // 使用者の急所ランク+1
            myState.addVitalRank(1);
            break;
          case 50:    // こんらんさせる
          case 77:    // こんらんさせる(確率)
          case 200:   // こんらんさせる
          case 268:   // こんらんさせる(確率)
          case 334:   // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 51:    // 使用者のこうげきを2段階上げる
            myState.addStatChanges(true, 0, 2, targetState, moveId: replacedMove.id);
            break;
          case 52:    // 使用者のぼうぎょを2段階上げる
          case 359:   // 使用者のぼうぎょを2段階上げる(確率)
            myState.addStatChanges(true, 1, 2, targetState, moveId: replacedMove.id);
            break;
          case 53:    // 使用者のすばやさを2段階上げる
            myState.addStatChanges(true, 4, 2, targetState, moveId: replacedMove.id);
            break;
          case 54:    // 使用者のとくこうを2段階上げる
            myState.addStatChanges(true, 2, 2, targetState, moveId: replacedMove.id);
            break;
          case 55:    // 使用者のとくこうを2段階上げる
            myState.addStatChanges(true, 3, 2, targetState, moveId: replacedMove.id);
            break;
          case 58:    // へんしん状態となる
            if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute || e.id == BuffDebuff.transform).isEmpty &&
                myState.buffDebuffs.where((e) => e.id == BuffDebuff.transform).isEmpty
            ) {    // 対象がみがわり状態でない・お互いにへんしん状態でないなら
              myState.type1 = targetState.type1;
              myState.type2 = targetState.type2;
              if (targetState.ailmentsWhere((e) => e.id == Ailment.halloween).isNotEmpty) myState.ailmentsAdd(Ailment(Ailment.halloween), state);
              if (targetState.ailmentsWhere((e) => e.id == Ailment.forestCurse).isNotEmpty) myState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
              myState.setCurrentAbility(targetState.currentAbility, targetState, playerType == PlayerType.me, state);
              for (int i = 0; i < targetState.moves.length; i++) {
                if (i >= myState.moves.length) {
                  myState.moves.add(targetState.moves[i]);
                }
                else {
                  myState.moves[i] = targetState.moves[i];
                }
                myState.usedPPs[i] = 0;
              }
              for (final stat in StatIndexList.listHtoS) {    // HP以外のステータス実数値
                myState.minStats[stat].real = targetState.minStats[stat].real;
                myState.maxStats[stat].real = targetState.maxStats[stat].real;
              }
              for (int i = 0; i < 7; i++) {
                myState.forceSetStatChanges(i, targetState.statChanges(i));
              }
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transform)..extraArg1 = targetState.pokemon.no..turns = targetState.pokemon.sex.id);
            }
            break;
          case 59:    // こうげきを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 60:    // ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 1, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 61:    // すばやさを2段階下げる
            targetState.addStatChanges(targetState == myState, 4, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 62:    // とくこうを2段階下げる
            targetState.addStatChanges(targetState == myState, 2, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 63:    // とくぼうを2段階下げる
          case 272:   // とくぼうを2段階下げる(確率)
          case 297:   // とくぼうを2段階下げる
            targetState.addStatChanges(targetState == myState, 3, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 66:    // 場に「リフレクター」を発生させる
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.reflector);
            if (findIdx < 0) targetIndiField.add(IndividualField(IndividualField.reflector)..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
            break;
          case 72:    // とくこうを1段階下げる(確率)
          case 358:   // とくこうを1段階下げる
            targetState.addStatChanges(targetState == myState, 2, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 73:    // とくぼうを1段階下げる(確率)
          case 440:   // とくぼうを1段階下げる
            targetState.addStatChanges(targetState == myState, 3, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 76:    // 1ターン目は攻撃せず、2ターン目に攻撃。ひるませる(確率)
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
                if (extraArg1[continuousCount] != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
                }
              }
            }
            break;
          case 80:    // 場に「みがわり」を発生させる
            targetState.remainHP -= extraArg1[continuousCount];
            targetState.remainHPPercent -= extraArg2[continuousCount];
            int findIdx = targetState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.substitute);
            if (findIdx < 0) {
              targetState.buffDebuffs.add(BuffDebuff(BuffDebuff.substitute)
                ..extraArg1 = extraArg1[continuousCount] != 0 ? -extraArg1[continuousCount] : 25);
            }
            break;
          case 81:    // 使用者は次のターン動けない
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.recoiling);
              if (findIdx < 0) {    // 反動で動けない状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.recoiling)..extraArg1 = replacedMove.id);
              }
            }
            break;
          case 82:    // 使用者はいかり状態になる
            int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rage);
            if (findIdx < 0) targetState.buffDebuffs.add(BuffDebuff(BuffDebuff.rage));
            break;
          case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
                      // 本来はコピーできるわざに制限があるが、そこはユーザ入力にゆだねる
            if (myState.hiddenBuffs.where((e) => e.id == BuffDebuff.copiedMove).isEmpty) {
              if (extraArg3[continuousCount] != 0) {
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.copiedMove)..extraArg1 = extraArg3[continuousCount]);
              }
            }
            break;
          case 84:    // ほぼすべてのわざから1つをランダムで使う
            // ユーザが、出たわざを選択していればここは通らない。処理なし
            break;
          case 85:    // やどりぎのタネ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.leechSeed), state);
            break;
          case 87:    // かなしばり状態にする
            if (targetState.lastMove != null) {
              targetState.ailmentsAdd(Ailment(Ailment.disable)..extraArg1 = targetState.lastMove!.id, state);
            }
            break;
          case 88:    // 使用者のレベル分の固定ダメージ
            damageCalc = loc.battleDamageFixed4(myState.pokemon.level);
            break;
          case 89:    // ランダムに決まった固定ダメージ
          case 90:    // 低優先度。ターンで最後に受けた物理わざによるダメージの2倍を与える
          case 92:    // 使用者と相手のHPを足して半々に分ける
          case 145:   // 低優先度。ターンで最後に受けた特殊わざによるダメージの2倍を与える
            showDamageCalc = false;
            break;
          case 91:    // アンコール状態にする
            if (targetState.lastMove != null) {
              targetState.ailmentsAdd(Ailment(Ailment.encore)..extraArg1 = targetState.lastMove!.id, state);
            }
            break;
          case 95:    // ロックオン状態にする
            targetState.ailmentsAdd(Ailment(Ailment.lockOn), state);
            break;
          case 96:    // 相手が最後に使用したわざをコピーし、このわざがその代わりとなる(SV使用不可のため処理なし)
            break;
          case 98:    // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
            // ユーザが、出たわざを選択していればここは通らない。処理なし
            break;
          case 99:    // 次の使用者の行動順までみちづれ状態になる。連続で使用すると失敗する
            targetState.ailmentsAdd(Ailment(Ailment.destinyBond), state);
            break;
          case 100:   // 使用者の残りHPが少ないほど威力が大きくなる
            {
              int x = 0;
              if (myPlayerType == PlayerType.me) {
                x = (myState.remainHP * 48 / myState.pokemon.h.real).floor();
              }
              else {
                x = (myState.remainHPPercent * 48 / 100).floor();
              }
              if (33 <= x) {
                movePower = 20;
              }
              else if (17 <= x) {
                movePower = 40;
              }
              else if (10 <= x) {
                movePower = 80;
              }
              else if (5 <= x) {
                movePower = 100;
              }
              else if (2 <= x) {
                movePower = 150;
              }
              else {
                movePower = 200;
              }
            }
            break;
          case 101:   // 相手が最後に消費したわざのPPを4減らす
            if (targetState.lastMove != null) {
              int targetID = targetState.moves.indexWhere((e) => e.id == targetState.lastMove!.id);
              if (targetID >= 0 && targetID < targetState.usedPPs.length) {
                targetState.usedPPs[targetID] += 4;
              }
            }
            break;
          case 102:   // 相手のHPは最低でも1残る
            break;
          case 103:   // 状態異常を治す
            int findIdx = targetState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            if (findIdx >= 0) targetState.ailmentsRemoveAt(findIdx);
            break;
          case 105:   // 3回連続こうげき。2回目以降の威力は最初の100%分大きくなる
            movePower = movePower * (continuousCount+1);
            break;
          case 106:   // もちものを盗む
            if (extraArg1[continuousCount] != 0) {
              // もちもの確定のため、一度持たせる
              if (targetPlayerType == PlayerType.opponent &&
                  opponentPokemonState.getHoldingItem()?.id == 0
              ) {
                targetState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              }
              myState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              targetState.holdingItem = null;
            }
            break;
          case 107:   // にげられない状態にする
          case 374:   // にげられない状態にする
          case 385:   // にげられない状態にする
            if (!targetState.isTypeContain(8)) {
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
            }
            break;
/*
          case 108:   // あくむ状態にする(SVで使用不可のため実装無し)
            targetState.ailmentsAdd(Ailment(Ailment.nightmare), state);
            break;
*/
          case 109:   // 使用者のかいひを2段階上げる。ちいさくなる状態になる
            myState.addStatChanges(true, 6, 2, targetState, moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.minimize), state);
            break;
          case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
            if (myState.isTypeContain(8)) {
              myState.remainHP -= extraArg1[continuousCount];
              myState.remainHPPercent -= extraArg2[continuousCount];
              yourState.ailmentsAdd(Ailment(Ailment.curse), state);
            }
            else {
              myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
              myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
              myState.addStatChanges(true, 4, -1, targetState, moveId: replacedMove.id);
            }
            break;
          case 112:   // まもる状態になる
          case 307:   // まもる状態になる
          case 377:   // まもる状態になる。場に出て最初の行動の場合のみ成功
            myState.ailmentsAdd(Ailment(Ailment.protect), state);
            break;
          case 113:   // 相手の場に「まきびし」を発生させる
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.spikes);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.spikes)..extraArg1 = 1);
            }
            else {
              targetIndiField[findIdx].extraArg1++;
              if (targetIndiField[findIdx].extraArg1 > 3) targetIndiField[findIdx].extraArg1 = 3;
            }
            break;
          case 114:   // みやぶられている状態にする
            targetState.ailmentsAdd(Ailment(Ailment.identify), state);
            break;
          case 115:   // ほろびのうた状態にする
            targetState.ailmentsAdd(Ailment(Ailment.perishSong), state);
            break;
          case 116:   // 天気をすなあらしにする
            targetField!.weather = Weather(Weather.sandStorm)..extraArg1 = myState.holdingItem?.id == 260 ? 8 : 5;
            effectOnce = true;
            break;
          case 117:   // ひんしダメージをHP1で耐える。連続使用で失敗しやすくなる
            break;
          case 118:   // 最高5ターン連続でこうげき、当てるたびに威力が2倍になる(まるくなる状態だと威力2倍)
            if (myState.lastMove?.id == replacedMove.id) {
              movePower *= 2;
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.curl).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 119:   // こうげきを2段階上げ、こんらん状態にする
            targetState.addStatChanges(targetState == myState, 0, 2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 120:   // 当てるたびに威力が2倍ずつ増える。最大160
            if (myState.lastMove?.id == replacedMove.id) {
              movePower *= 2;
            }
            if (movePower > 160) movePower = 160;
            break;
          case 121:   // 性別が異なる場合、メロメロ状態にする
            if (myState.sex != Sex.none && targetState.sex != Sex.none && myState.sex != targetState.sex) {
              targetState.ailmentsAdd(Ailment(Ailment.infatuation), state);
            }
            break;
          case 122:   // なつき度によって威力が変わる
            // なつき度(0~255)×10/25
            showDamageCalc = false;
            break;
          case 123:   // ランダムに威力が変わる/相手を回復する
            showDamageCalc = false;
            break;
          case 124:   // なつき度が低いほど威力があがる
            // (255-なつき度(0~255))×10/25
            showDamageCalc = false;
            break;
          case 125:   // 場に「しんぴのまもり」を発生させる
            if (targetIndiField.where((e) => e.id == IndividualField.safeGuard).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.safeGuard));
            }
            break;
          case 126:   // 使用者のこおり状態を消す。相手をやけど状態にする(確率)
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 127:   // 威力がランダムで10,30,50,70,90,110,150のいずれかになる。あなをほる状態の対象にも当たり、ダメージ2倍。グラスフィールドの影響を受ける相手には威力半減
            showDamageCalc = false;
            break;
          case 128:   // 控えのポケモンと交代する。能力変化・一部の状態変化は交代後に引き継ぐ
            if (getChangePokemonIndex(myPlayerType) != null) {
              List<int> statChanges = List.generate(7, (i) => myState.statChanges(i));
              var takeOverAilments = [...myState.ailmentsWhere((e) => e.id == Ailment.confusion ||
                e.id == Ailment.leechSeed || e.id == Ailment.curse || e.id == Ailment.perishSong ||
                e.id == Ailment.ingrain || e.id == Ailment.healBlock || e.id == Ailment.embargo ||
                e.id == Ailment.magnetRise || e.id == Ailment.telekinesis || e.id == Ailment.abilityNoEffect ||
                e.id == Ailment.aquaRing || e.id == Ailment.powerTrick
              )];
              var takeOverBuffDebuffs = [...myState.buffDebuffs.where((e) => e.id == BuffDebuff.vital1 ||
                e.id == BuffDebuff.vital2 || e.id == BuffDebuff.vital3 || e.id == BuffDebuff.substitute
              )];
              myState.processExitEffect(myPlayerType == PlayerType.me, yourState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(myPlayerType)!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerType == PlayerType.me, state, yourState);
              for (int i = 0; i < 7; i++) {
                newState.forceSetStatChanges(i, statChanges[i]);
              }
              for (var e in takeOverAilments) {
                newState.ailmentsAdd(e, state);
              }
              newState.buffDebuffs.addAll(takeOverBuffDebuffs);
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            break;
          case 129:   // そのターンに相手が交代しようとした場合、威力2倍で交代前のポケモンにこうげき
            showDamageCalc = false;
            break;
          case 130:   // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。使用者のすばやさを1段階上げる
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.partiallyTrapped || e.id == Ailment.leechSeed);
            myFields.removeWhere((e) => e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes ||
              e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb
            );
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 131:   // 20の固定ダメージ
            damageCalc = loc.battleDamageFixed5;
            break;
          case 136:   // 個体値によってわざのタイプが変わる
            if (extraArg1[continuousCount] != 0) {
              moveType = PokeType.createFromId(extraArg1[continuousCount]);
            }
            break;
          case 137:   // 天気を雨にする
            targetField!.weather = Weather(Weather.rainy)..extraArg1 = myState.holdingItem?.id == 262 ? 8 : 5;
            effectOnce = true;
            break;
          case 138:   // 天気をはれにする
            targetField!.weather = Weather(Weather.sunny)..extraArg1 = myState.holdingItem?.id == 261 ? 8 : 5;
            effectOnce = true;
            break;
          case 141:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 143:   // 使用者は最大HPの1/2だけHPが減る。こうげきランクが最大まで上がる
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= (myState.pokemon.h.real / 2).floor();
            }
            else {
              myState.remainHPPercent -= 50;
            }
            myState.forceSetStatChanges(0, 6);
            break;
          case 144:   // 能力変化をすべて相手と同じにする
            {
              List<int> src = List.generate(7, (i) => targetState.statChanges(i));
              for (int i = 0; i< 7; i++) {
                myState.forceSetStatChanges(i, src[i]);
              }
            }
            break;
          case 146:   // 1ターン目にため、2ターン目でこうげきする。1ターン目で使用者のぼうぎょが1段階上がる
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 147:   // ひるませる(確率)。そらをとぶ状態でも命中し、その場合威力が2倍
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            if (targetState.ailmentsWhere((e) => e.id == Ailment.flying).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 148:   // あなをほる状態でも命中し、その場合ダメージが2倍。グラスフィールドの影響を受けている相手には威力が半減
            if (targetState.ailmentsWhere((e) => e.id == Ailment.digging).isNotEmpty) mTwice = true;
            if (targetState.isGround(targetIndiField) && state.field.id == Field.grassyTerrain) {
              movePower = (movePower / 2).floor();
            }
            break;
          case 149:   // 2ターン後の相手にダメージを与える
            targetIndiField.add(IndividualField(IndividualField.futureAttack));
            damageCalc = '';
            break;
          case 150:   // そらをとぶ状態でも命中し、その場合威力が2倍
            if (targetState.ailmentsWhere((e) => e.id == Ailment.flying).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 151:   // ひるませる(確率)。ちいさくなる状態に対して必中、その場合ダメージ2倍
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            if (targetState.ailmentsWhere((e) => e.id == Ailment.minimize).isNotEmpty) mTwice = true;
            break;
          case 152:   // 1ターン目にため、2ターン目でこうげきする。1ターン目の天気がはれ→ためずにこうげき。攻撃時天気が雨、すなあらし、ゆきなら威力半減
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                if (state.weather.id != Weather.sunny) {
                  myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                  showDamageCalc = false;
                }
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
                if (state.weather.id == Weather.rainy || state.weather.id == Weather.sandStorm || state.weather.id == Weather.snowy) {
                  movePower = (movePower / 2).floor();
                }
              }
            }
            break;
          case 154:   // 控えのポケモンと交代する
          case 229:   // 控えのポケモンと交代する
            if (getChangePokemonIndex(myPlayerType) != null) {
              myState.processExitEffect(myPlayerType == PlayerType.me, yourState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(myPlayerType)!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerType == PlayerType.me, state, yourState);
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            break;
          case 155:   // 手持ちポケモン(ひんし、状態異常除く)の数だけ連続でこうげきする
            showDamageCalc = false;
            break;
          case 156:   // 使用者はそらをとぶ状態になり、次のターンにこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {
                myState.ailmentsAdd(Ailment(Ailment.flying), state);
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.flying);
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 157:   // 使用者のぼうぎょを1段階上げる。まるくなる状態になる
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.curl), state);
            break;
          case 160:   // さわぐ状態になる
            myState.ailmentsAdd(Ailment(Ailment.uproar), state);
            // ねむり状態解除
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
            yourState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
            break;
          case 161:   // たくわえた回数を+1する。使用者のぼうぎょ・とくぼうが1段階上がる
            int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.stock3);
            if (findIdx < 0) {
              int plusPoint = 0;
              if (myState.statChanges(1) < 6) {
                myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
                plusPoint++;
              }
              if (myState.statChanges(3) < 6) {
                myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
                plusPoint += 10;
              }
              findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.stock1 || e.id == Ailment.stock2);
              if (findIdx >= 0) {
                var removed = myState.ailmentsRemoveAt(findIdx);
                myState.ailmentsAdd(Ailment(removed.id + 1)..extraArg1 = removed.extraArg1 + plusPoint, state);
              }
              else {
                myState.ailmentsAdd(Ailment(Ailment.stock1)..extraArg1 = plusPoint, state);
              }
            }
            break;
          case 162:   // たくわえた回数が多いほど威力が上がる。たくわえた回数を0にする
            int findIdx = myState.ailmentsIndexWhere((e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
            if (findIdx >= 0) {
              movePower *= myState.ailments(findIdx).id - Ailment.stock1 + 1;
              myState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 163:   // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            int findIdx = myState.ailmentsIndexWhere((e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
            if (findIdx >= 0) {
              myState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 165:   // 天気をあられにする
            //targetField!.weather = Weather(Weather.snowy);
            effectOnce = true;
            break;
          case 166:   // いちゃもん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.torment), state);
            break;
          case 167:   // とくこうを1段階上げ、こんらん状態にする
            targetState.addStatChanges(targetState == myState, 2, 1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 169:   // 使用者はひんしになる。相手のこうげき・とくこうを2段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 170:   // 使用者がどく・もうどく・まひ・やけどのいずれかの場合、威力が2倍になる(＋やけどによるダメージ減少なし)
            if (myState.ailmentsWhere((e) =>
              e.id == Ailment.burn || e.id == Ailment.paralysis ||
              e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty
            ) {
              movePower *= 2;  
            }
            break;
          case 171:   // そのターンでこうげきする前に使用者がこうげきわざによるダメージを受けていると失敗する
            break;
          case 172:   // 相手がまひ状態なら威力2倍。相手のまひを治す
            int findIdx = targetState.ailmentsIndexWhere((e) => e.id == Ailment.paralysis);
            if (findIdx >= 0) {
              movePower *= 2;
              targetState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 173:   // 使用者はちゅうもくのまと状態になる
            myState.ailmentsAdd(Ailment(Ailment.attention), state);
            break;
          case 174:   // 地形やフィールドによって出る技が変わる(SV使用不可のため処理なし)
            break;
          case 175:   // 使用者はじゅうでん状態になる。使用者のとくぼうを1段階上げる
            myState.ailmentsAdd(Ailment(Ailment.charging), state);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            break;
          case 176:   // ちょうはつ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.taunt), state);
            break;
          case 177:   // てだすけ状態にする
            // シングルバトルでは失敗する
            //targetState.ailmentsAdd(Ailment(Ailment.helpHand), state);
            break;
          case 178:   // 使用者ともちものを入れ替える
            var ownItem = ownPokemonState.getHoldingItem();
            if (extraArg1[continuousCount] > 0) {
              // もちもの確定のため、一度持たせる
              if (opponentPokemonState.getHoldingItem()?.id == 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1[continuousCount]]
                  ..guideStr = loc.battleGuideConfItem1(pokeData.items[extraArg1[continuousCount]]!.displayName, opponentPokemonState.pokemon.omittedName)
                );
                opponentPokemonState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              }
              ownPokemonState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
            }
            else {
              ownPokemonState.holdingItem = null;
            }
            opponentPokemonState.holdingItem = ownItem;
            break;
          case 179:   // 相手と同じとくせいになる
            if (extraArg1[continuousCount] != 0) {
              myState.setCurrentAbility(pokeData.abilities[extraArg1[continuousCount]]!, yourState, playerType == PlayerType.me, state);
            }
            break;
          case 180:   // 使用者の場に「ねがいごと」を発生させる
            if (myFields.where((e) => e.id == IndividualField.wish).isEmpty) {
              myFields.add(IndividualField(IndividualField.wish));
            }
            break;
          case 181:   // 使用者の手持ちポケモンの技をランダムに1つ使う(SV使用不可のため処理なし)
            break;
          case 182:   // 使用者はねをはる状態になる。
            myState.ailmentsAdd(Ailment(Ailment.ingrain), state);
            break;
          case 183:   // 使用者はこうげき・ぼうぎょが1段階下がる
            myState.addStatChanges(true, 0, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            break;
          case 184:   // 使用者に使われた変化技を相手に跳ね返す(SV使用不可のため処理なし)
            break;
          case 185:   // 戦闘中自分が最後に使用したもちものを復活させる
            if (extraArg1[continuousCount] != 0) {
              myState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
            }
            break;
          case 186:   // このターンに、対象からダメージを受けていた場合は威力2倍
            showDamageCalc = false;
            break;
          case 187:   // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき
            targetIndiField.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
            break;
          case 188:   // ねむけ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.sleepy), state);
            break;
          case 189:   // もちものを持っていれば失わせ、威力1.5倍
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent && targetState.getHoldingItem()?.id == 0) {
              ret.add(Guide()
                ..guideId = Guide.confItem
                ..args = [extraArg1[continuousCount]]
                ..guideStr = loc.battleGuideConfItem1(pokeData.items[extraArg1[continuousCount]]!.displayName, opponentPokemonState.pokemon.omittedName)
              );
              if (extraArg1[continuousCount] != 0) targetState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
            }
            targetState.holdingItem = null;
            movePower *= 2;
            break;
          case 190:   // 相手の残りHP-使用者の残りHP(負数なら失敗)分の固定ダメージを与える
            showDamageCalc = false;
            break;
          case 191:   // 威力=150×使用者の残りHP/最大HP
            if (myPlayerType == PlayerType.me) {
              movePower = (150 * myState.remainHP / myState.pokemon.h.real).floor();
            }
            else {
              movePower = (150 * myState.remainHPPercent / 100).floor();
            }
            if (movePower == 0) movePower = 1;
            break;
          case 192:   // 使用者ととくせいを入れ替える
            opponentPokemonState.setCurrentAbility(ownPokemonState.getCurrentAbility(), ownPokemonState, false, state);
            if (extraArg1[continuousCount] != 0) {
              ownPokemonState.setCurrentAbility(pokeData.abilities[extraArg1[continuousCount]]!, opponentPokemonState, true, state);
            }
            break;
          case 193:   // 使用者をふういん状態にする
            myState.ailmentsAdd(Ailment(Ailment.imprison), state);
            break;
          case 194:   // 使用者のどく・もうどく・まひ・やけどを治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison ||
              e.id == Ailment.paralysis || e.id == Ailment.burn);
            break;
          case 195:   // 使用者をおんねん状態にする
            myState.ailmentsAdd(Ailment(Ailment.grudge), state);
            break;
          case 196:   // そのターンに使われる、自身を対象にするへんかわざを横取りして代わりに自分に使う(SV使用不可のため処理なし)
            break;
          case 197:   // 相手のおもさによって威力が変わる
            int weight = targetState.weight;
            if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.heavy2).isNotEmpty) weight *= 2;
            if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.heavy0_5).isNotEmpty) weight  = (weight / 2).floor();
            if (targetState.holdingItem?.id == 582) weight  = (weight / 2).floor();
            if (weight <= 99) {
              movePower = 20;
            }
            else if (weight <= 249) {
              movePower = 40;
            }
            else if (weight <= 499) {
              movePower = 60;
            }
            else if (weight <= 999) {
              movePower = 80;
            }
            else if (weight <= 1999) {
              movePower = 100;
            }
            else {
              movePower = 120;
            }
            break;
          case 198:   // 地形に応じた追加効果を与える(SV使用不可のため処理なし)
            break;
          case 202:   // 場をどろあそび状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.mudSport).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.mudSport));
            }
            break;
          case 204:   // 天気が変わっていると威力2倍、タイプも変わる
            switch (state.weather.id) {
              case Weather.sunny:
                movePower *= 2;
                moveType = PokeType.createFromId(10);
                break;
              case Weather.rainy:
                movePower *= 2;
                moveType = PokeType.createFromId(11);
                break;
              case Weather.snowy:
                movePower *= 2;
                moveType = PokeType.createFromId(15);
                break;
              case Weather.sandStorm:
                movePower *= 2;
                moveType = PokeType.createFromId(6);
                break;
              default:
                break;
            }
            break;
          case 205:   // 使用者はとくこうが2段階下がる
            myState.addStatChanges(true, 2, -2, targetState, moveId: replacedMove.id);
            break;
          case 206:   // こうげき・ぼうぎょを1段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 207:   // 使用者はぼうぎょ・とくぼうが1段階ずつ上がる
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            break;
          case 208:   // そらをとぶ状態の相手にも当たる
            break;
          case 209:   // 使用者はこうげき・ぼうぎょが1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            break;
          case 211:   // 場をみずあそび状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.waterSport).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.waterSport));
            }
            break;
          case 212:   // 使用者はとくこう・とくぼうが1段階ずつ上がる
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            break;
          case 213:   // 使用者はこうげき・すばやさが1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 214:   // 使用者のタイプを地形やフィールドに応じて変える(SV使用不可のため処理なし)
            break;
          case 215:   // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            int lostFly = 0;
            if (!myState.isTerastaling && myState.type1.id == PokeTypeId.fly) {
              if (myState.type2 == null) {
                myState.type1 = PokeType.createFromId(PokeTypeId.normal);
                lostFly = 1;
              }
              else {
                myState.type1 = PokeType.createFromId(myState.type2!.id);
                myState.type2 = null;
                lostFly = 3;
              }
            }
            else if (!myState.isTerastaling && myState.type2?.id == PokeTypeId.fly) {
              myState.type2 = null;
              lostFly = 2;
            }
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.magnetRise);   // でんじふゆうは解除
            myState.ailmentsAdd(Ailment(Ailment.roost)..extraArg1 = lostFly, state);
            break;
          case 216:   // 場をじゅうりょく状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.gravity).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.gravity));
            }
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.magnetRise || e.id == Ailment.telekinesis || e.id == Ailment.flying);   // でんじふゆう/テレキネシス/そらをとぶは解除
            break;
          case 217:   // ミラクルアイ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.miracleEye), state);
            break;
          case 218:   // 相手がねむり状態なら威力2倍。相手のねむりを治す
            int findIdx = targetState.ailmentsIndexWhere((e) => e.id == Ailment.sleep);
            if (findIdx >= 0) {
              movePower *= 2;
              targetState.ailmentsRemoveAt(findIdx);
            }
            break;
          case 219:   // 使用者のすばやさを1段階下げる
            myState.addStatChanges(true, 4, -1, targetState, moveId: replacedMove.id);
            break;
          case 220:   // 使用者のすばやさが相手と比べて低いほど威力が大きくなる(25×相手のすばやさ/使用者のすばやさ+1)(max150)
            showDamageCalc = false;
            break;
          case 221:   // 使用者はひんしになる。場にいやしのねがいを発生させる
            myFields.add(IndividualField(IndividualField.healingWish));
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 222:   // 相手のHPが最大HPの1/2以下なら威力2倍
            if (targetPlayerType == PlayerType.me && targetState.remainHP <= (targetState.pokemon.h.real / 2).floor()) {
              movePower *= 2;
            }
            else if (targetPlayerType == PlayerType.opponent && targetState.remainHPPercent <= 50) {
              movePower *= 2;
            }
            break;
          case 223:   // 持っているきのみによってタイプと威力が変わる。きのみはなくなる(SV使用不可のため処理なし)
            break;
          case 224:   // まもる等の状態を解除してこうげきできる
            break;
          case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
            if (extraArg1[continuousCount] != 0) {
              Item usingItem = pokeData.items[extraArg1[continuousCount]]!;
              Item? mySavingItem = myState.holdingItem;
              targetState.holdingItem = null;
              Item.processEffect(
                usingItem.id, myPlayerType,
                myState, targetState, state, extraArg2[continuousCount], 0,
                getChangePokemonIndex(myPlayerType), loc: loc,
              );
              myState.holdingItem = mySavingItem;
            }
            break;
          case 226:   // 使用者の場においかぜを発生させる
            if (myFields.where((e) => e.id == IndividualField.tailwind).isEmpty) {
              myFields.add(IndividualField(IndividualField.tailwind));
            }
            break;
          case 227:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
            myState.addStatChanges(true, extraArg1[continuousCount], 2, targetState, moveId: replacedMove.id);
            break;
          case 228:   // そのターンで最後に相手から受けたこうげきわざのダメージを1.5倍にして返す
            showDamageCalc = false;
            break;
          case 230:   // 使用者のぼうぎょ・とくぼうを1段階ずつ下げる
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState, moveId: replacedMove.id);
            break;
          case 231:   // 相手がそのターン既に行動していると威力2倍
            showDamageCalc = false;
            break;
          case 232:   // 相手がそのターン既にダメージを受けていると威力2倍
            showDamageCalc = false;
            break;
          case 233:   // さしおさえ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.embargo), state);
            break;
          case 234:   // 使用者のもちものによって威力と追加効果が変わる
            if (extraArg1[continuousCount] != 0) {
              var flingItem = pokeData.items[extraArg1[continuousCount]]!;
              movePower = flingItem.flingPower;
              flingItem.processFlingEffect(
                playerType, myState, yourState, state, extraArg2[continuousCount], 0,
                getChangePokemonIndex(myPlayerType), loc: loc,
              );
              myState.holdingItem = null;
            }
            break;
          case 235:   // 使用者の状態異常を相手に移す
            int targetIdx = targetState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            int myIdx = myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            if (targetIdx < 0 && myIdx >= 0) {
              targetState.ailmentsAdd(Ailment(myState.ailments(myIdx).id), state);
            }
            myState.ailmentsRemoveAt(myIdx);
            break;
          case 236:   // わざの残りPPが少ないほどわざの威力が上がる。必中
            showDamageCalc = false;
            break;
          case 237:   // かいふくふうじ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.healBlock)..extraArg1 = 5, state);
            break;
          case 238:   // 相手の残りHPが多いほど威力が高くなる(120×相手の残りHP/相手の最大HP)
            if (targetPlayerType == PlayerType.me) {
              movePower = (120 * targetState.remainHP / targetState.pokemon.h.real).floor();
            }
            else {
              movePower = (120 * targetState.remainHPPercent / 100).floor();
            }
            break;
          case 239:   // 使用者をパワートリック状態にする
            myState.ailmentsAdd(Ailment(Ailment.powerTrick), state);
            break;
          case 240:   // とくせいなし状態にする
            targetState.ailmentsAdd(Ailment(Ailment.abilityNoEffect), state);
            break;
          case 241:   // 場におまじないを発生させる(SV使用不可のため処理なし)
            break;
          case 242:   // 場におまじないを発生させる(SV使用不可のため処理なし)
            break;
          case 243:   // 最後に出されたわざを出す(相手のわざとは限らない)
            break;
          case 244:   // 使用者のこうげき・とくこうランク変化と相手のこうげき・とくこうランク変化を入れ替える
            int myAttackStat = myState.statChanges(0);
            int mySpecialAttackStat = myState.statChanges(2);
            myState.forceSetStatChanges(0, targetState.statChanges(0));
            myState.forceSetStatChanges(2, targetState.statChanges(2));
            targetState.forceSetStatChanges(0, myAttackStat);
            targetState.forceSetStatChanges(2, mySpecialAttackStat);
            break;
          case 245:   // 使用者のぼうぎょ・とくぼうランク変化と相手のぼうぎょ・とくぼうランク変化を入れ替える
            int myDefenseStat = myState.statChanges(1);
            int mySpecialDefenseStat = myState.statChanges(3);
            myState.forceSetStatChanges(1, targetState.statChanges(1));
            myState.forceSetStatChanges(3, targetState.statChanges(3));
            targetState.forceSetStatChanges(1, myDefenseStat);
            targetState.forceSetStatChanges(3, mySpecialDefenseStat);
            break;
          case 246:   // 相手がランク変化で強くなっているほど威力があがる(max200)
            for (int i = 0; i < 7; i++) {
              if (targetState.statChanges(i) > 0) {
                movePower += 20 * targetState.statChanges(i);
              }
            }
            if (movePower > 200) movePower = 200;
            break;
          case 247:   // 他に覚えているわざをそれぞれ1回以上使っていないと失敗
            break;
          case 248:   // とくせいをふみんにする
            targetState.setCurrentAbility(pokeData.abilities[15]!, myState, targetPlayerType == PlayerType.me, state);
            break;
          case 249:   // 相手より先に発動し、相手がこうげきわざを選んでいる場合のみ成功
            break;
          case 250:   // 場にどくびしを設置する
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.toxicSpikes);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.toxicSpikes)..extraArg1 = 1);
            }
            else {
              targetIndiField[findIdx].extraArg1 = 2;
            }
            break;
          case 251:   // 使用者の各能力変化と相手の各能力変化を入れ替える
            List<int> myStatChanges = List.generate(7, (i) => myState.statChanges(i));
            for (int i = 0; i < 7; i++) {
              myState.forceSetStatChanges(i, targetState.statChanges(i));
            }
            for (int i = 0; i < 7; i++) {
              targetState.forceSetStatChanges(i, myStatChanges[i]);
            }
            break;
          case 252:   // 使用者をアクアリング状態にする
            myState.ailmentsAdd(Ailment(Ailment.aquaRing), state);
            break;
          case 253:   // 使用者をでんじふゆう状態にする
            myState.ailmentsAdd(Ailment(Ailment.magnetRise), state);
            break;
          case 254:   // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2[continuousCount];
            }
            else {
              myState.remainHPPercent -= extraArg2[continuousCount];
            }
            break;
          case 256:   // 使用者はダイビング状態になり、次のターンにこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.diving), state);
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.diving);
                myState.hiddenBuffs.removeAt(findIdx);
                if (myState.currentAbility.id == 241) {   // うのミサイル
                  if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.unomiForm || e.id == BuffDebuff.marunomiForm).isEmpty) {
                    if (myPlayerType == PlayerType.me ? myState.remainHP > myState.pokemon.h.real / 2 : myState.remainHPPercent > 50) {                
                      myState.buffDebuffs.add(BuffDebuff(BuffDebuff.unomiForm));
                    }
                    else {
                      myState.buffDebuffs.add(BuffDebuff(BuffDebuff.marunomiForm));
                    }
                  }
                }
              }
            }
            break;
          case 257:   // 使用者はあなをほる状態になり、次のターンにこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.digging), state);
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.digging);
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 258:   // ダイビング状態でも命中し、その場合ダメージ2倍
            if (targetState.ailmentsWhere((e) => e.id == Ailment.diving).isNotEmpty) mTwice = true;
            if (myState.currentAbility.id == 241) {   // うのミサイル
              if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.unomiForm || e.id == BuffDebuff.marunomiForm).isEmpty) {
                if (myPlayerType == PlayerType.me ? myState.remainHP > myState.pokemon.h.real / 2 : myState.remainHPPercent > 50) {                
                  myState.buffDebuffs.add(BuffDebuff(BuffDebuff.unomiForm));
                }
                else {
                  myState.buffDebuffs.add(BuffDebuff(BuffDebuff.marunomiForm));
                }
              }
            }
            break;
          case 259:   // かいひを1段階下げる。相手のひかりのかべ・リフレクター・オーロラベール・しんぴのまもり・しろいきりを消す
                      // 使用者・相手の場にあるまきびし・どくびし・とがった岩・ねばねばネットを取り除く。フィールドを解除する
            targetState.addStatChanges(targetState == myState, 6, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetIndiField.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen ||
              e.id == IndividualField.auroraVeil || e.id == IndividualField.safeGuard || e.id == IndividualField.mist ||
              e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes || e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb);
            myFields.removeWhere((e) => e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes ||
              e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb);
            state.field = Field(0);
            break;
          case 260:   // 場をトリックルームにする/解除する
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.trickRoom);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.trickRoom));
            }
            else {
              targetIndiField.removeAt(findIdx);
            }
            break;
          case 262:   // バインド状態にする。ダイビング中の相手にはダメージ2倍
            targetState.ailmentsAdd(Ailment(Ailment.partiallyTrapped), state);
            if (targetState.ailmentsWhere((e) => e.id == Ailment.diving).isNotEmpty) mTwice = true;
            break;
          case 263:   // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2[continuousCount];
            }
            else {
              myState.remainHPPercent -= extraArg2[continuousCount];
            }
            break;
          case 264:   // 使用者はそらをとぶ状態になり、次のターンにこうげきする。相手をまひ状態にする(確率)
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.flying), state);
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.flying);
                myState.hiddenBuffs.removeAt(findIdx);
                if (extraArg1[continuousCount] != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
                }
              }
            }
            break;
          case 266:   // 性別が異なる場合、相手のとくこうを2段階下げる
            if (myState.sex != Sex.none && targetState.sex != Sex.none && myState.sex != targetState.sex) {
              targetState.addStatChanges(targetState == myState, 2, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            }
            break;
          case 267:   // 場にとがった岩を発生させる
            if (targetIndiField.where((e) => e.id == IndividualField.stealthRock).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.stealthRock));
            }
            break;
          case 269:   // 持っているプレートに応じてわざのタイプが変わる
            if (myState.holdingItem != null) {
              switch (myState.holdingItem!.id) {
                case 275:   // ひのたまプレート
                  moveType = PokeType.createFromId(10);
                  break;
                case 276:   // しずくプレート
                  moveType = PokeType.createFromId(11);
                  break;
                case 277:   // いかずちプレート
                  moveType = PokeType.createFromId(13);
                  break;
                case 278:   // みどりのプレート
                  moveType = PokeType.createFromId(12);
                  break;
                case 279:   // つららのプレート
                  moveType = PokeType.createFromId(15);
                  break;
                case 280:   // こぶしのプレート
                  moveType = PokeType.createFromId(2);
                  break;
                case 281:   // もうどくプレート
                  moveType = PokeType.createFromId(4);
                  break;
                case 282:   // だいちのプレート
                  moveType = PokeType.createFromId(5);
                  break;
                case 283:   // あおぞらプレート
                  moveType = PokeType.createFromId(3);
                  break;
                case 284:   // ふしぎのプレート
                  moveType = PokeType.createFromId(14);
                  break;
                case 285:   // たまむしプレート
                  moveType = PokeType.createFromId(7);
                  break;
                case 286:   // がんせきプレート
                  moveType = PokeType.createFromId(6);
                  break;
                case 287:   // もののけプレート
                  moveType = PokeType.createFromId(8);
                  break;
                case 288:   // りゅうのプレート
                  moveType = PokeType.createFromId(16);
                  break;
                case 289:   // こわもてプレート
                  moveType = PokeType.createFromId(17);
                  break;
                case 290:   // こつてつプレート
                  moveType = PokeType.createFromId(9);
                  break;
                case 684:   // せいれいプレート
                  moveType = PokeType.createFromId(18);
                  break;
                default:
                  break;
              }
            }
            break;
          case 271:   // 使用者はひんしになる。場にみかづきのまいを発生させる
            myFields.add(IndividualField(IndividualField.lunarDance));
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 273:   // 使用者はシャドーダイブ状態になり、次のターンにこうげきする。まもる等の状態を取り除いてこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.ailmentsAdd(Ailment(Ailment.shadowForcing), state);
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.ailmentsRemoveWhere((e) => e.id == Ailment.shadowForcing);
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 274:   // 相手をやけど状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (extraArg2[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 275:   // 相手をこおり状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            }
            if (extraArg2[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 276:   // 相手をまひ状態にする(確率)。相手をひるませる(確率)。
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
            }
            if (extraArg2[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 278:   // 使用者のこうげき・めいちゅうを1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 5, 1, targetState, moveId: replacedMove.id);
            break;
          case 279:   // そのターンの間、複数のポケモンが対象になるわざから守る
            break;
          case 280:   // 相手と使用者のぼうぎょ・とくぼうをそれぞれ平均値にする
            {
              int maxAvg = ((myState.maxStats.b.real + targetState.maxStats.b.real) / 2).floor();
              int minAvg = ((myState.minStats.b.real + targetState.minStats.b.real) / 2).floor();
              myState.maxStats.b.real = maxAvg;
              myState.minStats.b.real = minAvg;
              targetState.maxStats.b.real = maxAvg;
              targetState.minStats.b.real = minAvg;
              maxAvg = ((myState.maxStats.d.real + targetState.maxStats.d.real) / 2).floor();
              minAvg = ((myState.minStats.d.real + targetState.minStats.d.real) / 2).floor();
              myState.maxStats.d.real = maxAvg;
              myState.minStats.d.real = minAvg;
              targetState.maxStats.d.real = maxAvg;
              targetState.minStats.d.real = minAvg;
            }
            break;
          case 281:   // 相手と使用者のこうげき・とくこうをそれぞれ平均値にする
            {
              int maxAvg = ((myState.maxStats.a.real + targetState.maxStats.a.real) / 2).floor();
              int minAvg = ((myState.minStats.a.real + targetState.minStats.a.real) / 2).floor();
              myState.maxStats.a.real = maxAvg;
              myState.minStats.a.real = minAvg;
              targetState.maxStats.a.real = maxAvg;
              targetState.minStats.a.real = minAvg;
              maxAvg = ((myState.maxStats.c.real + targetState.maxStats.c.real) / 2).floor();
              minAvg = ((myState.minStats.c.real + targetState.minStats.c.real) / 2).floor();
              myState.maxStats.c.real = maxAvg;
              myState.minStats.c.real = minAvg;
              targetState.maxStats.c.real = maxAvg;
              targetState.minStats.c.real = minAvg;
            }
            break;
          case 282:   //場をワンダールームにする/解除する
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.wonderRoom);
            if (findIdx < 0) {
              targetIndiField.add(IndividualField(IndividualField.wonderRoom));
            }
            else {
              targetIndiField.removeAt(findIdx);
            }
            break;
          case 283:   // 相手のとくぼうではなくぼうぎょでダメージ計算する
            invDeffense = true;
            break;
          case 284:   // 相手がどく・もうどく状態のとき威力2倍
            if (targetState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 285:   // 使用者のすばやさを2段階上げる。おもさが100kg軽くなる(SV使用不可のため処理なし)
            break;
          case 286:   // 相手をテレキネシス状態にする
            targetState.ailmentsAdd(Ailment(Ailment.telekinesis), state);
            break;
          case 287:   //場をマジックルームにする/解除する
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.magicRoom);
            if (findIdx < 0) {
              targetState.holdingItem?.clearPassiveEffect(targetState, clearForm: false);
              targetIndiField.add(IndividualField(IndividualField.magicRoom));
              targetState.hiddenBuffs.add(BuffDebuff(BuffDebuff.magicRoom));
            }
            else {
              targetIndiField.removeAt(findIdx);
              targetState.holdingItem?.processPassiveEffect(targetState, processForm: false);
              targetState.hiddenBuffs.removeWhere((e) => e.id == BuffDebuff.magicRoom);
            }
            break;
          case 288:   // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
          case 373:   // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
            targetState.ailmentsAdd(Ailment(Ailment.antiAir), state);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.magnetRise || e.id == Ailment.telekinesis || e.id == Ailment.flying);   // でんじふゆう/テレキネシス/そらをとぶは解除
            break;
          case 289:   // かならず急所に当たる
            break;
          case 290:   // 相手の隣にいるポケモンにも最大HP1/16のダメージ
            break;
          case 291:   // 使用者のとくこう・とくぼう・すばやさを1段階ずつ上げる
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 292:   // 使用者のおもさと相手のおもさの比率によって威力がかわる。ちいさくなる状態の相手に必中、その場合ダメージが2倍
            {
              int myWeight = myState.weight;
              if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.heavy2).isNotEmpty) myWeight *= 2;
              if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.heavy0_5).isNotEmpty) myWeight  = (myWeight / 2).floor();
              if (targetState.holdingItem?.id == 582) myWeight  = (myWeight / 2).floor();
              int targetWeight = targetState.weight;
              if (targetWeight <= myWeight / 5) {
                movePower = 120;
              }
              else if (targetWeight <= myWeight / 4) {
                movePower = 100;
              }
              else if (targetWeight <= myWeight / 3) {
                movePower = 80;
              }
              else if (targetWeight <= myWeight / 2) {
                movePower = 60;
              }
              else {
                movePower = 40;
              }
              if (targetState.ailmentsWhere((e) => e.id == Ailment.minimize).isNotEmpty) mTwice = true;
            }
            break;
          case 293:   // 使用者と同じタイプを持つポケモンに対してのみ有効
            break;
          case 294:   // 相手よりすばやさが速いほど威力が大きくなる
            showDamageCalc = false;
            break;
          case 295:   // 相手のタイプをみず単体に変更する
            if (!targetState.isTerastaling) {
              targetState.type1 = PokeType.createFromId(11);
              targetState.type2 = null;
            }
            break;
          case 296:   // 使用者のすばやさを1段階上げる
          case 467:   // 使用者のすばやさを1段階上げる。急所に当たりやすい
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 298:   // 使用者のこうげきとランク補正ではなく相手のこうげきとランク補正でダメージ計算する
            isFoulPlay = true;
            break;
          case 299:   // 相手のとくせいをたんじゅんに変える
            targetState.setCurrentAbility(pokeData.abilities[86]!, myState, targetPlayerType == PlayerType.me, state);
            break;
          case 300:   // 相手のとくせいを使用者のとくせいと同じにする
            if (extraArg1[continuousCount] != 0) {
              targetState.setCurrentAbility(pokeData.abilities[extraArg1[continuousCount]]!, myState, targetPlayerType == PlayerType.me, state);
            }
            break;
          case 301:   // 選択対象の行動順を、このわざの直後に変更する
            break;
          case 302:   // 同じターンにこのわざを複数が使用すると、1体目が使用した直後に2体目がこのわざを使う。後で使った方は威力120
            break;
          case 303:   // 毎ターン場の誰かが使用し続けた場合(当たらなくてもよい)、40ずつ威力が高くなる。max200。
            showDamageCalc = false;
            break;
          case 304:   // 相手のランク補正を無視してダメージを与える
            ignoreTargetRank = true;
            break;
          case 305:   // 相手の能力ランクを0にする
            targetState.resetStatChanges();
            break;
          case 306:   // 使用者の能力ランク+1ごとに威力+20
            int plus = 0;
            for (int i = 0; i < 7; i++) {
              if (myState.statChanges(i) > 0) plus += myState.statChanges(i);
            }
            movePower += plus * 20;
            break;
          case 308:   // 位置を入れ替える(代わりにわざを受けたりできる)
            break;
          case 309:   // 使用者のぼうぎょ・とくぼうをそれぞれ1段階下げ、こうげき・とくこう・すばやさを2段階ずつ上げる
            myState.addStatChanges(true, 0, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState, moveId: replacedMove.id);
            break;
          case 310:   // 相手のHPを最大HP1/2だけ回復する
            bool isMegaLauncher = myState.buffDebuffs.where((e) => e.id == BuffDebuff.wave1_5).isNotEmpty;
            if (myPlayerType == PlayerType.me) {
              targetState.remainHPPercent += isMegaLauncher ? 75 : 50;
            }
            else {
              targetState.remainHPPercent += isMegaLauncher ? (targetState.pokemon.h.real * 3 / 4).floor() : (targetState.pokemon.h.real / 2).floor();
            }
            break;
          case 311:   // 相手が状態異常のとき威力2倍
            if (targetState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 312:   // 1ターン目で相手を空に連れ去り(両者はそらをとぶ状態)、2ターン目にこうげき。連れ去っている間は相手は行動できない。ひこうタイプにはダメージがない(SV使用不可のため処理なし)
            break;
          case 313:   // 使用者のこうげきを1段階、すばやさを2段階上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState, moveId: replacedMove.id);
            break;
          case 315:   // 相手のきのみ・ノーマルジュエルを失わせる
            targetState.holdingItem = null;
            break;
          case 316:   // 相手の行動順をそのターンの1番最後にする
            break;
          case 317:   // 使用者のこうげき・とくこうをそれぞれ1段階上げる。天気がはれの場合はさらに1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            if (state.weather.id == Weather.sunny) {
              myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
              myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            }
            break;
          case 318:   // 使用者がもちものを持っていない場合威力2倍
            if (myState.holdingItem == null) {
              movePower *= 2;
            }
            break;
          case 319:   // 相手と同じタイプになる
            if (targetState.isTerastaling) {
              myState.type1 = targetState.teraType1;
            }
            else {
              myState.type1 = targetState.type1;
              myState.type2 = targetState.type2;
              if (targetState.ailmentsWhere((e) => e.id == Ailment.halloween).isNotEmpty) myState.ailmentsAdd(Ailment(Ailment.halloween), state);
              if (targetState.ailmentsWhere((e) => e.id == Ailment.forestCurse).isNotEmpty) myState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
            }
            break;
          case 320:   // 味方がひんしになった次のターンに使った場合威力2倍
            showDamageCalc = false;
            break;
          case 321:   // 使用者の残りHP分の固定ダメージを与える。使用者はひんしになる
            if (myPlayerType == PlayerType.me) {
              damageCalc = loc.battleDamageFixed6(myState.remainHP);
            }
            else {
              showDamageCalc = false;
            }
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 322:   // 使用者のとくこうを3段階上げる
            myState.addStatChanges(true, 2, 3, targetState, moveId: replacedMove.id);
            break;
          case 323:   // 使用者のこうげき・ぼうぎょ・めいちゅうをそれぞれ1段階上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 5, 1, targetState, moveId: replacedMove.id);
            break;
          case 324:   // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
            if (extraArg1[continuousCount] != 0) {
              targetState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              myState.holdingItem = null;
            }
            break;
          case 325:   // みずのちかい・ほのおのちかい・くさのちかい 同時に使用するとフィールドに変化が起こる
          case 326:
          case 327:
            break;
          case 328:   // 使用者のこうげき・とくこうをそれぞれ1段階上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            break;
          case 329:   // 使用者のぼうぎょを3段階上げる
            myState.addStatChanges(true, 1, 3, targetState, moveId: replacedMove.id);
            break;
          case 330:   // ねむり状態にする(確率)。メロエッタのフォルムが変わる
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.sleep), state);
            }
            int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.voiceForm || e.id == BuffDebuff.stepForm);
            if (findIdx >= 0) {
              if (myState.buffDebuffs[findIdx].id == BuffDebuff.voiceForm) {
                myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.stepForm);
                // TODO この2行csvに移したい
                myState.type2 = PokeType.createFromId(PokeTypeId.fight);
                myState.maxStats.a.race = 128; myState.maxStats.b.race = 90; myState.maxStats.c.race = 77; myState.maxStats.d.race = 77; myState.maxStats.s.race = 128;
                myState.minStats.a.race = 128; myState.minStats.b.race = 90; myState.minStats.c.race = 77; myState.minStats.d.race = 77; myState.minStats.s.race = 128;
                for (final stat in StatIndexList.listAtoS) {
                  var biases = Temper.getTemperBias(myState.pokemon.temper);
                  myState.maxStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level, myState.maxStats[stat].race, myState.maxStats[stat].indi, myState.maxStats[stat].effort, biases[stat.index-1]);
                  myState.minStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level, myState.minStats[stat].race, myState.minStats[stat].indi, myState.minStats[stat].effort, biases[stat.index-1]);
                }
              }
              else {
                myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.voiceForm);
                myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.stepForm);
                // TODO この2行csvに移したい
                myState.type2 = PokeType.createFromId(PokeTypeId.psychic);
                myState.maxStats.a.race = 77; myState.maxStats.b.race = 77; myState.maxStats.c.race = 128; myState.maxStats.d.race = 128; myState.maxStats.s.race = 90;
                myState.minStats.a.race = 77; myState.minStats.b.race = 77; myState.minStats.c.race = 128; myState.minStats.d.race = 128; myState.minStats.s.race = 90;
                for (final stat in StatIndexList.listAtoS) {
                  var biases = Temper.getTemperBias(myState.pokemon.temper);
                  myState.maxStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level, myState.maxStats[stat].race, myState.maxStats[stat].indi, myState.maxStats[stat].effort, biases[stat.index-1]);
                  myState.minStats[stat].real = SixParams.getRealABCDS(
                    myState.pokemon.level, myState.minStats[stat].race, myState.minStats[stat].indi, myState.minStats[stat].effort, biases[stat.index-1]);
                }
              }
            }
            break;
          case 332:   // 1ターン目にため、2ターン目でこうげきする。まひ状態にする(確率)
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
                if (extraArg1[continuousCount] != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.paralysis), state);
                }
              }
            }
            break;
          case 333:   // 1ターン目にため、2ターン目でこうげきする。やけど状態にする(確率)
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
                if (extraArg1[continuousCount] != 0) {
                  targetState.ailmentsAdd(Ailment(Ailment.burn), state);
                }
              }
            }
            break;
          case 335:   // 使用者のぼうぎょ・とくぼう・すばやさがそれぞれ1段階下がる
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, -1, targetState, moveId: replacedMove.id);
            break;
          case 336:   // 直前に成功したわざがクロスサンダーだった場合威力2倍。こおり状態を治す(SV使用不可のため処理なし)
            //myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            break;
          case 337:   // 直前に成功したわざがクロスフレイムだった場合威力2倍(SV使用不可のため処理なし)
            break;
          case 338:   // わざのタイプにひこうタイプの2つの相性を組み合わせてダメージ計算する。ちいさくなる状態の相手に必中し、その場合はダメージ2倍
            additionalMoveType = PokeType.createFromId(PokeTypeId.fly);
            if (targetState.ailmentsWhere((e) => e.id == Ailment.minimize).isNotEmpty) mTwice = true;
            break;
          case 339:   // 戦闘中にきのみを食べた場合のみ使用可能
            break;
          case 340:   // くさタイプのポケモンのこうげき・とくこうを1段階上げる。地面にいるポケモンにのみ有効(SV使用不可のため処理なし)
            break;
          case 341:   // 場にねばねばネットを設置する
            if (targetIndiField.where((e) => e.id == IndividualField.stickyWeb).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.stickyWeb));
            }
            break;
          case 342:   // このわざで相手を倒すと使用者のこうげきが3段階上がる
            if ((targetPlayerType == PlayerType.me && targetState.remainHP - realDamage[continuousCount] <= 0) ||
                (targetPlayerType == PlayerType.opponent && targetState.remainHPPercent - percentDamage[continuousCount] <= 0)) {
              myState.addStatChanges(true, 0, 3, targetState, moveId: replacedMove.id);
            }
            break;
          case 343:   // 相手のタイプにゴーストを追加する
            if (!targetState.isTypeContain(PokeTypeId.ghost)) {
              targetState.ailmentsRemoveWhere((e) => e.id == Ailment.forestCurse);
              targetState.ailmentsAdd(Ailment(Ailment.halloween), state);
            }
            break;
          case 344:   // こうげき・とくこうを1段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 345:   // 場をプラズマシャワー状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.ionDeluge).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.ionDeluge));
            }
            break;
          case 347:   // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            if (getChangePokemonIndex(myPlayerType) != null) {
              myState.processExitEffect(myPlayerType == PlayerType.me, yourState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(myPlayerType)!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerType == PlayerType.me, state, yourState);
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            break;
          case 348:   // 相手の能力変化を逆にする
            for (int i = 0; i < 7; i++) {
              targetState.forceSetStatChanges(i, -targetState.statChanges(i));
            }
            break;
          case 350:   // そのターンに受ける自分・味方対象の変化技をすべて無効化(SV使用不可のため処理なし)
            break;
          case 351:   // 場のすべてのくさタイプポケモンのぼうぎょを1段階上げる(SV使用不可のため処理なし)
            break;
          case 352:   // 場をグラスフィールドにする
            targetField!.field = Field(Field.grassyTerrain)..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 353:   // 場をミストフィールドにする
            targetField!.field = Field(Field.mistyTerrain)..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 354:   // そうでん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.electrify), state);
            break;
          case 355:   // 場をフェアリーロック状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.fairyLock).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.fairyLock));
            }
            break;
          case 356:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手のこうげきを1段階下げる。シールドフォルムにフォルムチェンジする
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bladeForm);
            if (findIdx >= 0) {
              myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.shieldForm);
            }
            break;
          case 357:   // こうげきを1段階下げる。まもる・みがわり状態を無視する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 360:   // 必中。まもる系統の状態を除外してこうげきする。みがわり状態を無視する
            break;
          case 362:   // そのターンに受けるわざを無効化し、直接攻撃を使用した相手のHPを最大HP1/8分減らす
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 363:   // とくぼうを1段階上げる
            targetState.addStatChanges(targetState == myState, 3, 1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 364:   // こうげき・とくこう・すばやさを1段階下げる。相手がどく/もうどく状態でないと失敗する
            if (targetState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {
              targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 2, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 4, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            }
            break;
          case 366:   // 1ターンためて、2ターン目に使用者のとくこう・とくぼう・すばやさをそれぞれ2段階ずつ上げる
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
                myState.addStatChanges(true, 2, 2, targetState, moveId: replacedMove.id);
                myState.addStatChanges(true, 3, 2, targetState, moveId: replacedMove.id);
                myState.addStatChanges(true, 4, 2, targetState, moveId: replacedMove.id);
              }
            }
            break;
          case 367:   // とくせいがプラスかマイナスのポケモンのぼうぎょ・とくぼうを1段階ずつ上げる
            if (targetState.currentAbility.id == 57 || targetState.currentAbility.id == 58) {
              targetState.addStatChanges(targetState == myState, 1, 1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 3, 1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            }
            break;
          case 368:   // トレーナー戦後にもらえる賞金が2倍になる
            break;
          case 369:   // 場をエレキフィールドにする
            targetField!.field = Field(Field.electricTerrain)..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 376:   // 相手のタイプにくさを追加する
            if (!targetState.isTypeContain(PokeTypeId.grass)) {
              targetState.ailmentsRemoveWhere((e) => e.id == Ailment.halloween);
              targetState.ailmentsAdd(Ailment(Ailment.forestCurse), state);
            }
            break;
/*          case 378:   // ふんじん状態にする(SVで使用不可のため処理なし)
            targetState.ailmentsAdd(Ailment(Ailment.powder), state);
            break;*/
          case 380:   // こおりにする(確率)。みずタイプのポケモンに対しても効果ばつぐんとなる
            targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            break;
          case 384:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手をどく状態にする
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 386:   // やけど状態を治す
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.burn);
            break;
          case 388:   // 相手のこうげきを1段階下げ、下げる前のこうげき実数値と同じ値だけ使用者のHPを回復する
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            // 相手こうげき確定
            if (myPlayerType == PlayerType.me) {
              int drain = extraArg1[continuousCount].abs();
              if (myState.remainHP < myState.pokemon.h.real && drain > 0) {
                if (myState.holdingItem?.id == 273) {   // おおきなねっこ
                  int tmp = ((drain.toDouble() + 0.5) / 1.3).round();
                  while (roundOff5(tmp * 1.3) > drain) {tmp--;}
                  drain = tmp;
                }
                int attack = targetState.getNotRankedStat(StatIndex.A, drain);
                // TODO: この時点で努力値等を反映するのかどうかとか
                if (attack != targetState.minStats.a.real || attack != targetState.maxStats.a.real) {
                  ret.add(Guide()
                    ..guideId = Guide.sapConfAttack
                    ..args = [attack, attack]
                    ..guideStr = loc.battleGuideSapConfAttack(attack, targetState.pokemon.omittedName)
                  );
                }
              }
              targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            }
            break;
          case 389:   // 相手をちゅうもくのまと状態にする
            targetState.ailmentsAdd(Ailment(Ailment.attention), state);
            break;
          case 390:   // 相手のすばやさを1段階下げ、どく状態する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            break;
          case 391:   // 次のターンまで、使用者のこうげきが必ず急所に当たるようになる
            break;
          case 392:   // プラスまたはマイナスのとくせいを持つポケモンのこうげきととくこうを1段階上げる(SV使用不可のため処理なし)
            break;
          case 393:   // じごくづき状態にする
            targetState.ailmentsAdd(Ailment(Ailment.throatChop), state);
            break;
          case 394:   // 対象が味方の場合のみ、最大HPの1/2を回復する
            break;
          case 395:   // 場をサイコフィールドにする
          case 415:   // 場をサイコフィールドにする
            targetField!.field = Field(Field.psychicTerrain)..extraArg1 = myState.holdingItem?.id == 896 ? 8 : 5;
            effectOnce = true;
            break;
          case 398:   // 使用者がほのおタイプでないと失敗する。成功するとほのおタイプを失う。こおり状態を治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (!myState.isTerastaling) {
              if (myState.type1.id == 10) {
                if (myState.type2 == null) {
                  myState.type1 = PokeType.createFromId(0); // タイプなし
                }
                else {
                  myState.type1 = myState.type2!;
                  myState.type2 = null;
                }
              }
              else if (myState.type2?.id == 10) {
                myState.type2 = null;
              }
            }
            break;
          case 399:   // 使用者と相手のすばやさ実数値を入れ替える
            int tmpMax = myState.maxStats.s.real;
            int tmpMin = myState.minStats.s.real;
            myState.maxStats.s.real = targetState.maxStats.s.real;
            myState.minStats.s.real = targetState.minStats.s.real;
            targetState.maxStats.s.real = tmpMax;
            targetState.minStats.s.real = tmpMin;
            break;
          case 400:   // 相手の状態異常を治し、使用者のHPを最大HP半分だけ回復する(SV使用不可のため処理なし)
            break;
          case 401:   // わざのタイプが使用者のタイプ1のタイプになる
            moveType = myState.isTerastaling ? myState.teraType1 : myState.type1;
            break;
          case 402:   // そのターンですでに行動を終えた相手をとくせいなし状態にする
            targetState.ailmentsAdd(Ailment(Ailment.abilityNoEffect), state);
            break;
          case 403:   // 対象が直前に使用したわざをもう一度使わせる
            break;
          case 404:   // わざ発動前に直接攻撃を受けると、その相手をやけど状態にする(SV使用不可のため処理なし)
            break;
          case 405:   // 使用者のぼうぎょが1段階下がる
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            break;
          case 407:   // 場にオーロラベールを発生させる。天気がゆきの場合のみ成功する
            if (state.weather.id == Weather.snowy) {
              if (myFields.where((e) => e.id == IndividualField.auroraVeil).isEmpty) {
                myFields.add(IndividualField(IndividualField.auroraVeil)..extraArg1 = targetState.holdingItem?.id == 246 ? 8 : 5);
              }
            }
            break;
          case 408:   // このターンでこのわざを使用する前に物理技を受けた場合のみこうげき可能
            break;
          case 409:   // 使用者が前のターンで動けなかった/使用したわざが失敗したとき威力2倍
            showDamageCalc = false;
            break;
          case 410:   // 相手のランク補正のうち、ランク+1以上をすべて使用者に移し替えてからこうげきする。みがわり状態を無視する
            for (int i = 0; i < 7; i++) {
              if (targetState.statChanges(i) > 0) {
                myState.addStatChanges(true, i, targetState.statChanges(i), targetState, moveId: replacedMove.id);
                targetState.forceSetStatChanges(i, 0);
              }
            }
            break;
          case 411:   // 相手のとくせいを無視してこうげきする
            ignoreAbility = true;
            break;
          case 412:   // 相手のこうげき・とくこう1段階ずつ下げる。相手の回避率、まもるに関係なく必ず当たる
            //TODO
            targetState.addStatChanges(targetState == myState, 0, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          // このへんからZわざ
          case 413:   // 相手の残りHP3/4の固定ダメージ
            showDamageCalc = false;
            break;
          case 414:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ2段階ずつ上がる
            myState.addStatChanges(true, 0, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 2, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 2, targetState, moveId: replacedMove.id);
            break;
          case 416:   // 使用者のランク補正混みのステータスがたかい方に合わせて特殊わざ/物理わざとなる。相手のとくせいを無視する
            break;
          case 418:   // フィールドを解除する
            state.field = Field(0);
            break;
          case 419:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 421:   // 相手がダイマックスしているとダメージ2倍
          case 436:   // 相手がダイマックスしているとダメージ2倍
            break;
          case 422:   // 相手のとくせいに引き寄せられない。ちゅうもくのまとやサイドチェンジの影響を受けない。急所に当たりやすい
            break;
          case 423:   // 使用者と相手をにげられない状態にする
            if (!myState.isTypeContain(8) && !targetState.isTypeContain(8)) {
              myState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
            }
            break;
          case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
            if (extraArg1[continuousCount] != 0) {
              Item.processEffect(
                extraArg1[continuousCount], playerType, myState, yourState, state, extraArg2[continuousCount], 0,
                getChangePokemonIndex(myPlayerType), loc: loc
              );
              myState.holdingItem = null;
              myState.addStatChanges(true, 1, 2, targetState, moveId: replacedMove.id);
            }
            break;
          case 425:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる
                      // 使用者はにげられない状態になる。1度効果が発動したあとに使用しても失敗する
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
            break;
          case 426:   // すばやさを1段階下げる。タールショット状態にする
            targetState.addStatChanges(targetState == myState, 4, -1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.tarShot), state);
            break;
          case 427:   // 相手のタイプをエスパー単タイプにする
            if (!targetState.isTerastaling) {
              targetState.type1 = PokeType.createFromId(14);
              targetState.type2 = null;
            }
            break;
          case 428:   // こうげきできる対象が1体なら2回の連続こうげき、2体いるならそれぞれに1回ずつこうげき
            break;
          case 429:   // 持っているきのみを消費し、その効果を受けさせる
            //TODO
            targetState.holdingItem = null;
            break;
          case 430:   // にげられない状態とたこがため状態にする
            if (!targetState.isTypeContain(8)) {
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
              targetState.ailmentsAdd(Ailment(Ailment.octoLock), state);
            }
            break;
          case 431:   // まだ行動していないポケモンに対して使うと威力2倍
            showDamageCalc = false;
            break;
          case 432:   // 使用者と相手の場の状態を入れ替える
            // いやしのねがい・みかづきのまい・みらいにこうげき・ねがいごとは入れ替えない
            bool isMyH = myFields.where((e) => e.id == IndividualField.healingWish).isNotEmpty;
            bool isMyL = myFields.where((e) => e.id == IndividualField.lunarDance).isNotEmpty;
            bool isMyF = myFields.where((e) => e.id == IndividualField.futureAttack).isNotEmpty;
            bool isMyW = myFields.where((e) => e.id == IndividualField.wish).isNotEmpty;
            bool isTaH = targetIndiField.where((e) => e.id == IndividualField.healingWish).isNotEmpty;
            bool isTaL = targetIndiField.where((e) => e.id == IndividualField.lunarDance).isNotEmpty;
            bool isTaF = targetIndiField.where((e) => e.id == IndividualField.futureAttack).isNotEmpty;
            bool isTaW = targetIndiField.where((e) => e.id == IndividualField.wish).isNotEmpty;
            myFields.removeWhere((e) => e.id == IndividualField.healingWish || e.id == IndividualField.lunarDance || e.id == IndividualField.futureAttack || e.id == IndividualField.wish);
            targetIndiField.removeWhere((e) => e.id == IndividualField.healingWish || e.id == IndividualField.lunarDance || e.id == IndividualField.futureAttack || e.id == IndividualField.wish);
            var tmp = myFields;
            myFields = targetIndiField;
            targetIndiField = tmp;
            if (isMyH) myFields.add(IndividualField(IndividualField.healingWish));
            if (isMyL) myFields.add(IndividualField(IndividualField.lunarDance));
            if (isMyF) myFields.add(IndividualField(IndividualField.futureAttack));
            if (isMyW) myFields.add(IndividualField(IndividualField.wish));
            if (isTaH) targetIndiField.add(IndividualField(IndividualField.healingWish));
            if (isTaL) targetIndiField.add(IndividualField(IndividualField.lunarDance));
            if (isTaF) targetIndiField.add(IndividualField(IndividualField.futureAttack));
            if (isTaW) targetIndiField.add(IndividualField(IndividualField.wish));
            effectOnce = true;
            break;
          case 433:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            break;
          case 434:   // こうげきの代わりにぼうぎょの数値とランク補正を使ってダメージを計算する
            defenseAltAttack = true;
            break;
          case 435:   // こうげき・とくこうを2段階ずつ上げる
            targetState.addStatChanges(targetState == myState, 0, 2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, 2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 437:   // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.harapekoForm).isNotEmpty) {
              moveType = PokeType.createFromId(17);
            }
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 442:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手のぼうぎょを2段階下げる
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 443:   // 2～5回連続でこうげきする。使用者のぼうぎょが1段階下がり、すばやさが1段階上がる
            if (continuousCount == 0) {
              myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
              myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            }
            break;
          case 444:   // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
                      // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
                      // ステラタイプにテラスタルしたときのみ威力が100になり、成功すると自分のこうげき・とくこうが1段階ずつ下がる
            if (myState.isTerastaling) {
              moveType = myState.teraType1;
            }
            if (myState.teraType1.id == PokeTypeId.stellar) {   // ステラタイプの場合
              movePower = 100;
              myState.addStatChanges(true, 0, -1, targetState, moveId: replacedMove.id);
              myState.addStatChanges(true, 2, -1, targetState, moveId: replacedMove.id);
            }
            // ステータスが確定している場合
            if (myState.maxStats.a.real == myState.minStats.a.real &&
                myState.maxStats.c.real == myState.minStats.c.real
            ) {
              if (myState.getRankedStat(myState.maxStats.a.real, StatIndex.A,) >
                  myState.getRankedStat(myState.maxStats.c.real, StatIndex.C,)
            ) {
                moveDamageClassID = 2;  // ぶつりわざに変更
              }
            }
            else {
              showDamageCalc = false;
            }
            break;
          case 445:   // ひんし状態のポケモンを最大HPの1/2を回復して復活させる
            {
              int targetIdx = extraArg1[continuousCount];
              if (targetIdx != 0) {
                var target = state.getPokemonStates(myPlayerType)[targetIdx-1];
                if (myPlayerType == PlayerType.me) {
                  target.remainHP = (target.pokemon.h.real / 2).floor();
                }
                else {
                  target.remainHPPercent = 50;
                }
                target.isFainting = false;
              }
            }
            break;
          case 446:   // サイコフィールドの効果を受けているとき威力1.5倍・相手全体へのこうげきになる
            if (state.field.id == Field.psychicTerrain && myState.isGround(state.getIndiFields(myPlayerType))) {
              movePower = (movePower * 1.5).floor();
            }
            break;
          case 447:   // 場にフィールドが発生しているときのみ成功し、フィールドを解除する
            state.field = Field(Field.none);
            break;
          case 448:   // 1ターン目に使用者のとくこうを1段階上げて(ためて)、2ターン目にこうげきする
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 449:   // ぶつりわざであるときの方がダメージが大きい場合は物理技になる。どく状態にする(確率)
            // ステータスが確定している場合
            if (myState.maxStats.a.real == myState.minStats.a.real &&
                myState.maxStats.c.real == myState.minStats.c.real
            ) {
              if (myState.getRankedStat(myState.maxStats.a.real, StatIndex.A,) >
                  myState.getRankedStat(myState.maxStats.c.real, StatIndex.C,)
              ) {
                moveDamageClassID = 2;  // ぶつりわざに変更
              }
            }
            else {
              showDamageCalc = false;
            }
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 450:   // 使用者はひんしになる。ミストフィールドの効果を受けているとき威力1.5倍
            if (state.field.id == Field.mistyTerrain && myState.isGround(state.getIndiFields(myPlayerType))) {
              movePower = (movePower * 1.5).floor();
            }
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 451:   // グラスフィールドの効果を受けているとき優先度が高くなる
            break;
          case 452:   // 対象がエレキフィールドの効果を受けているとき威力2倍
            if (state.field.id == Field.electricTerrain && targetState.isGround(state.getIndiFields(targetPlayerType))) {
              movePower *= 2;
            }
            break;
          case 453:   // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
            if (myState.isGround(state.getIndiFields(myPlayerType))) {
              switch (state.field.id) {
                case Field.electricTerrain:
                  moveType = PokeType.createFromId(13);
                  movePower *= 2;
                  break;
                case Field.grassyTerrain:
                  moveType = PokeType.createFromId(12);
                  movePower *= 2;
                  break;
                case Field.mistyTerrain:
                  moveType = PokeType.createFromId(18);
                  movePower *= 2;
                  break;
                case Field.psychicTerrain:
                  moveType = PokeType.createFromId(14);
                  movePower *= 2;
                  break;
              }
            }
            break;
          case 454:   // 対象がそのターンに能力が上がっているとやけど状態にする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            break;
          case 455:   // このターンに使用者の能力が下がっていた場合、威力2倍
            if (myState.hiddenBuffs.where((e) => e.id == BuffDebuff.thisTurnDownStatChange).isNotEmpty) {
              movePower *= 2;
            }
            break;
          case 456:   // 対象にもちものがあるときのみ成功
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent && targetState.getHoldingItem()!.id == 0) {
              if (extraArg1[continuousCount] != 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1[continuousCount]]
                  ..guideStr = loc.battleGuideConfItem2(pokeData.items[extraArg1[continuousCount]]!.displayName, opponentPokemonState.pokemon.omittedName)
                );
                targetState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              }
            }
            break;
          case 457:   // 対象のもちものを消失させる
            // もちもの確定のため、一度持たせる
            if (targetPlayerType == PlayerType.opponent && targetState.getHoldingItem()?.id == 0) {
              if (extraArg1[continuousCount] != 0) {
                ret.add(Guide()
                  ..guideId = Guide.confItem
                  ..args = [extraArg1[continuousCount]]
                  ..guideStr = loc.battleGuideConfItem1(pokeData.items[extraArg1[continuousCount]]!.displayName, opponentPokemonState.pokemon.omittedName)
                );
                targetState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              }
            }
            targetState.holdingItem = null;
            break;
          case 458:   // 自分以外の味方全員のこうげきとぼうぎょを1段階ずつ上げる
            break;
          case 459:   // 3回連続でこうげきする。こうげきのたびに威力が20ずつ上がる
            movePower += continuousCount * 20;
            break;
          case 460:   // やけど状態にする(確率)。使用者、対象ともにこおりを治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 461:   // 最大HP1/4回復、状態異常を治す
            targetState.remainHP -= extraArg1[continuousCount];
            targetState.remainHPPercent -= extraArg2[continuousCount];
            targetState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            break;
          case 462:   // 3回連続でこうげきする。かならず急所に当たる
            break;
          case 463:   // 相手が最後に消費したわざのPPを3減らす
            if (targetState.lastMove != null) {
              int targetID = targetState.moves.indexWhere((e) => e.id == targetState.lastMove!.id);
              if (targetID >= 0 && targetID < targetState.usedPPs.length) {
                targetState.usedPPs[targetID] += 3;
              }
            }
            break;
          case 464:   // どく・まひ・ねむりのいずれかにする(確率)
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(extraArg1[continuousCount]), state);
            }
            break;
          case 465:   // 使用者のこうげき・ぼうぎょ・すばやさを1段階ずつ上げる
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 466:   // 対象がどく・もうどく状態なら威力2倍。どくにする(確率)
            if (targetState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {
              movePower *= 2;
            }
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 468:   // 相手のぼうぎょを1段階下げる(確率)。相手をひるませる(確率)。急所に当たりやすい
            if (extraArg1[continuousCount] != 0) {
              targetState.addStatChanges(targetState == myState, 1, 1, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            }
            if (extraArg2[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            }
            break;
          case 469:   // 対象が状態異常の場合威力2倍。やけど状態にする(確率)
            if (targetState.ailmentsWhere((e) => e.id <= Ailment.sleep).isNotEmpty){
              movePower *= 2;
            }
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            break;
          case 473:   // 使用者のとくこう・とくぼうを1段階ずつ上げる。使用者の状態異常を回復する
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.ailmentsRemoveWhere((e) => e.id <= Ailment.sleep);
            break;
          case 474:   // そのターンに受けるわざを無効化し、直接攻撃を使用した相手のすばやさを1段階下げる
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 475:   // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2[continuousCount];
            }
            else {
              myState.remainHPPercent -= extraArg2[continuousCount];
            }
            break;
          case 476:   // その戦闘で味方がひんしになるたび、威力が50ずつ上がる
            int faintingNum = state.getFaintingCount(playerType);
            movePower += (faintingNum) * 50;
            break;
          case 477:   // ヘイラッシャがシャリタツを飲み込んでいた場合、使用者の能力を上げる
            break;
          case 478:   // 対象のこうげきを2段階上げ、ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, 2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -2, myState, myFields: yourFields, yourFields: myFields, moveId: replacedMove.id);
            break;
          case 479:   // 使用者のすばやさを2段階下げる
            myState.addStatChanges(true, 4, -2, targetState, moveId: replacedMove.id);
            break;
          case 480:   // 最大10回連続でこうげきする
            break;
          case 481:   // 次に使用者が行動するまでの間相手から受けるわざ必中・ダメージ2倍
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.certainlyHittedDamage2).isNotEmpty) {
              myState.buffDebuffs.add(BuffDebuff(BuffDebuff.certainlyHittedDamage2));
            }
            break;
          case 482:   // しおづけ状態にする
            if (targetState.holdingItem?.id != 1701 && targetState.currentAbility.id != 19) {
              targetState.ailmentsAdd(Ailment(Ailment.saltCure), state);
            }
            break;
          case 483:   // 3回連続でこうげきする
            break;
          case 484:   // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。対象をどく状態にする(確率)
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.partiallyTrapped || e.id == Ailment.leechSeed);
            myFields.removeWhere((e) => e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes ||
              e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb
            );
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.poison), state);
            }
            break;
          case 485:   // 使用者の最大HP1/2(小数点以下切り捨て)を消費してこうげき・とくこう・すばやさを1段階ずつ上げる
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 486:   // 必中かつ必ず急所に当たる
            break;
          case 487:   // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき。ケンタロスのフォルムによってわざのタイプが変化する
            targetIndiField.removeWhere((e) => e.id == IndividualField.reflector || e.id == IndividualField.lightScreen || e.id == IndividualField.auroraVeil);
            switch (myState.pokemon.no) {
              case 10250:
                moveType = PokeType.createFromId(2);
                break;
              case 10251:
                moveType = PokeType.createFromId(10);
                break;
              case 10252:
                moveType = PokeType.createFromId(11);
                break;
            }
            break;
          case 488:   // 使用者のとくこうを1段階下げる。戦闘後、このわざの使用回数×レベル×5円のお金をもらえる
            myState.addStatChanges(true, 2, -1, targetState, moveId: replacedMove.id);
            break;
          case 489:   // 場がエレキフィールドのとき威力1.5倍
            if (state.field.id == Field.electricTerrain) {
              movePower = (movePower * 1.5).floor();
            }
            break;
          case 490:   // はれによるダメージ補正率が0.5倍→1.5倍。使用者・対象のこおり状態を治す
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.sheerForce).isEmpty) isSunny1_5 = true;
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            break;
          case 491:   // 効果がばつぐんの場合、威力4/3倍
            if (PokeType.effectiveness(
              myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
              yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              moveType, targetState).id == MoveEffectiveness.great
            ) {
              movePower = (movePower / 3 * 4).floor();
            }
            break;
          case 492:   // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            if (getChangePokemonIndex(myPlayerType) != null) {
              myState.processExitEffect(myPlayerType == PlayerType.me, yourState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(myPlayerType)!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerType == PlayerType.me, state, yourState);
              newState.buffDebuffs.add(BuffDebuff(BuffDebuff.substitute));
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            break;
          case 493:   // 天気をゆきにして控えと交代
            state.weather = Weather(Weather.snowy)..extraArg1 = myState.holdingItem?.id == 259 ? 8 : 5;
            if (getChangePokemonIndex(myPlayerType) != null) {
              myState.processExitEffect(myPlayerType == PlayerType.me, yourState, state);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(myPlayerType)!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerType == PlayerType.me, state, yourState);
              newState.hiddenBuffs.add(BuffDebuff(BuffDebuff.changedThisTurn));
            }
            effectOnce = true;
            break;
          case 494:   // 両者のみがわり、設置技を解除。使用者のこうげき・すばやさを1段階ずつ上げる
            myState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.substitute);
            targetState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.substitute);
            myFields.removeWhere((e) => e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes ||
              e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb
            );
            yourFields.removeWhere((e) => e.id == IndividualField.spikes || e.id == IndividualField.toxicSpikes ||
              e.id == IndividualField.stealthRock || e.id == IndividualField.stickyWeb
            );
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 495:   // 天気をゆきにする
            state.weather = Weather(Weather.snowy)..extraArg1 = myState.holdingItem?.id == 259 ? 8 : 5;
            effectOnce = true;
            break;
          case 496:   // その戦闘でこうげき技のダメージを受けるたびに威力+50。(最大350)
            {
              int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.attackedCount);
              if (findIdx >= 0) {
                movePower += myState.hiddenBuffs[findIdx].extraArg1 * 50;
              }
            }
            break;
          case 497:   // 使用者がでんきタイプの場合のみ成功。でんきタイプを失くす
            if (myState.type1.id == 13) {
              if (myState.type2 != null) {
                myState.type1 = myState.type2!;
              }
              else {
                myState.type1 = PokeType.createFromId(0);
              }
            }
            else if (myState.type2?.id == 13) {
              myState.type2 = null;
            }
            break;
          case 498:   // 使用者が最後にPP消費したわざがこのわざだった場合、選択できない
            break;
          case 500:   // 与えたダメージの半分だけ回復する。両者のこおり状態を消す。相手をやけど状態にする(確率)
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.burn), state);
            }
            if (myPlayerType == PlayerType.me) {
              myState.remainHP -= extraArg2[continuousCount];
            }
            else {
              myState.remainHPPercent -= extraArg2[continuousCount];
            }
            break;
          case 501:   // あめまみれ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.candyCandy), state);
            break;
          case 502:   // オーガポンのフォルムによってわざのタイプが変わる
            {
              int no = myState.buffDebuffs.where((e) => e.id == BuffDebuff.transform).isNotEmpty ?
                myState.buffDebuffs.where((e) => e.id == BuffDebuff.transform).first.extraArg1 : myState.pokemon.no;
              switch (no) {
                case 1017:    // オーガポン(みどりのめん)->くさ
                  moveType = PokeType.createFromId(12);
                  break;
                case 10273:   // オーガポン(いどのめん)->みず
                  moveType = PokeType.createFromId(11);
                  break;
                case 10274:   // オーガポン(かまどのめん)->ほのお
                  moveType = PokeType.createFromId(10);
                  break;
                case 10275:   // オーガポン(いしずえのめん)->いわ
                  moveType = PokeType.createFromId(6);
                  break;
              }
            }
            break;
          case 503:   // 1ターン目に使用者のとくこうを1段階上げて(ためて)、2ターン目にこうげきする。1ターン目の天気があめ→ためずにこうげき。
            {
              var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
              if (findIdx < 0) {    // 溜め状態にする
                myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
                if (state.weather.id != Weather.rainy) {
                  myState.hiddenBuffs.add(BuffDebuff(BuffDebuff.chargingMove)..extraArg1 = replacedMove.id);
                  showDamageCalc = false;
                }
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 504:   // ステラフォルムのテラパゴスが使用した場合、ステラタイプの攻撃になり、相手全員が対象になる
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.stellarForm).isNotEmpty) {
              moveType = PokeType.createFromId(PokeTypeId.stellar);
            }
            break;
          case 505:   // 威力が2倍になる(確率)
            movePower *= 2;
            break;
          case 506:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手をやけど状態にする
            myState.ailmentsAdd(Ailment(Ailment.protect)..extraArg1 = replacedMove.id, state);
            break;
          case 507:   // 2回連続こうげき。必中
            break;
          case 508:   // 相手の残りHPが多いほど威力が高くなる(100×相手の残りHP/相手の最大HP)
            if (targetPlayerType == PlayerType.me) {
              movePower = (100 * targetState.remainHP / targetState.pokemon.h.real).floor();
            }
            else {
              movePower = (100 * targetState.remainHPPercent / 100).floor();
            }
            break;
          case 509:   // 使用者以外の味方全員をきゅうしょアップ状態にする(ドラゴンタイプは+2,それ以外は+1)
            break;
          case 510:   // 対象がそのターンに能力が上がっているとこんらん状態にする(確率)
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 511:   // かいふくふうじ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.healBlock)..extraArg1 = 2, state);
            break;
          case 512:   // 対象が先制攻撃技を使おうとしているとき、かつ使用者の方が先に行動する場合のみ成功。ひるませる(確率)。
            targetState.ailmentsAdd(Ailment(Ailment.flinch), state);
            break;
          default:
            break;
        }

        // ノーマルスキンによるわざタイプ変更
        if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.normalize).isNotEmpty) {
          if (moveType.id != PokeTypeId.normal) {
            moveType = PokeType.createFromId(PokeTypeId.normal);
            isNormalized1_2 = true;
          }
        }
        // そうでんによるわざタイプ変更
        if (myState.ailmentsWhere((e) => e.id == Ailment.electrify).isNotEmpty) {
          moveType = PokeType.createFromId(PokeTypeId.electric);
        }

        // わざの相性をここで変えちゃう
        moveEffectivenesses[continuousCount] = PokeType.effectiveness(
          myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
          yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
          moveType, targetState,
        );
      }

      // わざで交代した場合、交代前のstateで計算する。それを元に戻すために仮変数に退避
      var tmpState = myState;

      // ダメージ計算式
      if (showDamageCalc) {
        var damage = calcDamage(
          myState, targetStates[0], state, continuousCount,
          playerType, replacedMove, moveType, movePower,
          moveDamageClassID, beforeChangeMyState, isNormalized1_2,
          isCritical, isFoulPlay, defenseAltAttack, ignoreTargetRank,
          invDeffense, isSunny1_5, ignoreAbility, mTwice,
          additionalMoveType, halvedBerry, loc: loc,
        );
        damageCalc ??= damage.item1;
        damageGetter?.maxDamage = damage.item2;
        damageGetter?.minDamage = damage.item3;
        damageGetter?.maxDamagePercent = (damage.item2 * 100 / targetStates[0].minStats.h.real).floor();
        damageGetter?.minDamagePercent = (damage.item3 * 100 / targetStates[0].maxStats.h.real).floor();
        isTeraStellarHosei = damage.item4;

        ret.add(Guide()
          ..guideId = Guide.damageCalc
          ..guideStr = damageCalc
          ..canDelete = false
        );
      }

      // 交代前stateを参照していた場合向けに、myStateを元に戻す
      myState = tmpState;

      // ミクルのみのこうかが残っていれば消費
      int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceAccuracy1_2);
      if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
      // ノーマルジュエル消費
      if (myState.holdingItem?.id == 669 && moveDamageClassID >= 2 && moveType.id == 1) {
        myState.holdingItem = null;
      }
      // くっつきバリ移動
      if (replacedMove.isDirect && !(replacedMove.isPunch && myState.holdingItem?.id == 1700) &&  // パンチグローブをつけたパンチわざでない
        myState.holdingItem == null && yourState.holdingItem?.id == 265
      ) {
        myState.holdingItem = yourState.holdingItem;
        yourState.holdingItem = null;
      }

      switch (moveDamageClassID) {
        case 1:     // へんか
          break;
        case 2:     // ぶつり
        case 3:     // とくしゅ
          {
            // ダメージを負わせる
            for (var targetState in targetStates) {
              if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty
                  || replacedMove.isSound || myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isNotEmpty
              ) {
                targetState.remainHP -= realDamage[continuousCount];
                targetState.remainHPPercent -= percentDamage[continuousCount];
                // こうげきを受けた数をカウント
                int findIdx = targetState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.attackedCount);
                if (findIdx >= 0) {
                  targetState.hiddenBuffs[findIdx].extraArg1++;
                }
                else {
                  targetState.hiddenBuffs.add(BuffDebuff(BuffDebuff.attackedCount)..extraArg1 = 1);
                }
                // あいてポケモンのステータス確定
                if (playerType == PlayerType.opponent && realDamage[continuousCount] > 0 &&
                    targetState.remainHP > 0
                ) {
                  var reals = calcRealFromDamage(
                    realDamage[continuousCount], myState, targetStates[0],
                    state, continuousCount, playerType, replacedMove,
                    moveType, movePower, moveDamageClassID, beforeChangeMyState,
                    isNormalized1_2, isCritical, isFoulPlay, defenseAltAttack,
                    ignoreTargetRank, invDeffense, isSunny1_5, ignoreAbility,
                    mTwice, additionalMoveType, halvedBerry, isTeraStellarHosei, loc: loc,
                  );
                  if (reals.item1.index > StatIndex.H.index) {
                    // もともとある範囲より狭まるようにのみ上書き
                    int minS = opponentPokemonState.minStats[StatIndexNumber.getStatIndexFromIndex(reals.item1.index)].real;
                    int maxS = opponentPokemonState.maxStats[StatIndexNumber.getStatIndexFromIndex(reals.item1.index)].real;
                    bool addGuide = false;
                    if (minS < reals.item3) {
                      minS = reals.item3;
                      addGuide = true;
                    }
                    if (maxS > reals.item2) {
                      maxS = reals.item2;
                      addGuide = true;
                    }
                    if (addGuide) {
                      ret.add(Guide()
                        ..guideId = Guide.moveDamagedToStatus
                        ..guideStr = loc.battleGuideMoveDamagedToStatus(maxS, minS, opponentPokemonState.pokemon.omittedName, reals.item1.name)
                        ..args = [reals.item1.index, minS, maxS,]
                        ..canDelete = true
                      );
                    }
                  }
                }
              }
              else {
                if (realDamage[continuousCount] > 0) {
                  targetState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.substitute);
                }
              }
            }
          }
          break;
        default:
          break;
      }
    }

    // あいてポケモンのすばやさ確定
    if (!isFirst && state.firstAction != null && state.firstAction!.type.id == TurnMoveType.move) {
      if (move.priority == state.firstAction!.move.priority) {    // わざの優先度が同じ
        // もともとある範囲より狭まるようにのみ上書き
        int minS = opponentPokemonState.minStats.s.real;
        int maxS = opponentPokemonState.maxStats.s.real;
        bool addGuide = false;
        if (playerType == PlayerType.me) {
          if (minS < ownPokemonState.minStats.s.real) {   // TODO: 交代わざ用に、ターンの最初のポケモンステートが良い
            minS = ownPokemonState.minStats.s.real;
            addGuide = true;
          }
        }
        else {
          if (maxS > ownPokemonState.maxStats.s.real) {    // TODO: 交代わざ用に、ターンの最初のポケモンステートが良い
            maxS = ownPokemonState.maxStats.s.real;
            addGuide = true;
          }
        }
        if (addGuide) {
          ret.add(Guide()
            ..guideId = Guide.moveOrderConfSpeed
            ..guideStr = loc.battleGuideMoveOrderConfSpeed(maxS, minS, opponentPokemonState.pokemon.omittedName)
            ..args = [minS, maxS,]
            ..canDelete = true
          );
        }
      }
    }

    // 最後に使用した(PP消費した)わざセット
    myState.lastMove = move;

    return ret;
  }

  Tuple4<String, int, int, bool> calcDamage(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    int continuousCount,
    PlayerType myPlayerType,
    Move move,
    PokeType replacedMoveType,
    int power,
    int damageClassID,
    PokemonState beforeChangeMyState,
    bool isNormalized1_2,
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
    {
      required AppLocalizations loc,
    }
  ) {
    int movePower = power;
    Move replacedMove = move;
    var myFields = state.getIndiFields(myPlayerType);
    var yourFields = state.getIndiFields(myPlayerType.opposite);
    String ret = '';
    bool isTeraStellarHosei = false;

    // じゅうでん補正&消費
    int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.charging);
    if (findIdx >= 0 && replacedMoveType.id == 13) {
      movePower *= 2;
      myState.ailmentsRemoveAt(findIdx);
    }

    if (getChangePokemonIndex(myPlayerType) != null) {
      myState = beforeChangeMyState;
    }

    // とくせい等によるわざタイプの変更
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) replacedMoveType = PokeType.createFromId(15);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) replacedMoveType = PokeType.createFromId(18);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) replacedMoveType = PokeType.createFromId(3);
    if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.liquidVoice) >= 0) replacedMoveType = PokeType.createFromId(11);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) replacedMoveType = PokeType.createFromId(13);
    if (replacedMove.id != 165 && replacedMoveType.id == PokeTypeId.normal && myFields.indexWhere((e) => e.id == IndividualField.ionDeluge) >= 0) replacedMoveType = PokeType.createFromId(PokeTypeId.electric);
    
    // とくせい等による威力変動
    double tmpPow = movePower.toDouble();
    // テクニシャン補正は一番最初
    if (replacedMove.power <= 60 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.technician) >= 0) tmpPow *= 1.5;

    if (isNormalized1_2) tmpPow *= 1.2;
    if (replacedMoveType.id == PokeTypeId.grass && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.overgrow) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.fire && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.blaze) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.water && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.torrent) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.bug && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.swarm) >= 0) tmpPow *= 1.5;
    if (myState.sex.id != 0 && yourState.sex.id != 0 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.opponentSex1_5) >= 0) {
      if (myState.sex.id != yourState.sex.id) {
        tmpPow *= 1.25;
      }
      else {
        tmpPow *= 0.75;
      }
    }
    if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punch1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isRecoil && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.recoil1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isAdditionalEffect2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.sheerForce) >= 0) tmpPow *= 1.3;
    if (replacedMove.isWave && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.wave1_5) >= 0) tmpPow *= 1.5;
    if (replacedMove.isDirect && !(replacedMove.isPunch && myState.holdingItem?.id == 1700) && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.directAttack1_3) >= 0) tmpPow *= 1.3;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.change2) >= 0 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.changedThisTurn) >= 0) tmpPow *= 2;
    if (damageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5) >= 0) tmpPow *= 1.5;
    if (damageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5) >= 0) tmpPow *= 1.5;
    if (!isFirst && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.analytic) >= 0) tmpPow *= 1.3;
    if ((replacedMoveType.id == 5 || replacedMoveType.id == 6 || replacedMoveType.id == 9) && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockGroundSteel1_3) >= 0) tmpPow *= 1.3;
    if (replacedMove.isBite && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bite1_5) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.darkAura) >= 0) tmpPow *= 1.33;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAura) >= 0) tmpPow *= 1.33;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiDarkAura) >= 0) tmpPow *= 0.75;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiFairyAura) >= 0) tmpPow *= 0.75;
    if (replacedMoveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) tmpPow *= 1.2;
    if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.sound1_3) >= 0) tmpPow *= 1.3;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove1_3) >= 0) tmpPow *= 1.3;
    if (replacedMoveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steel1_5) >= 0) tmpPow *= 1.5;
    if (replacedMove.isCut && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.cut1_5) >= 0) tmpPow *= 1.5;
    int pow = myState.buffDebuffs.indexWhere((e) => e.id >= BuffDebuff.power10 && e.id <= BuffDebuff.power50);
    if (pow >= 0) tmpPow = tmpPow * (1.0 + (myState.buffDebuffs[pow].id - BuffDebuff.power10 + 1) * 0.1);
    if (damageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_1) >= 0) tmpPow *= 1.1;
    if (damageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_1) >= 0) tmpPow *= 1.1;
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3) >= 0) tmpPow *= 1.3;
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.normalAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fightAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 4 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.poisonAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 5 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.groundAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 6 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 7 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bugAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 8 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 10 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fireAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 11 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 12 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.grassAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 14 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 16 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.evilAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAttack1_2) >= 0) tmpPow *= 1.2;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.moveAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punchNotDirect1_1) >= 0) tmpPow *= 1.1;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_2) >= 0) tmpPow *= 1.2;

    if (replacedMoveType.id == 13 && myState.isGround(myFields) && state.field.id == Field.electricTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 12 && myState.isGround(myFields) && state.field.id == Field.grassyTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 14 && myState.isGround(myFields) && state.field.id == Field.psychicTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 16 && yourState.isGround(yourFields) && state.field.id == Field.mistyTerrain) tmpPow *= 0.5;
    
    if (replacedMoveType.id == 10 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.drySkin) >= 0) tmpPow *= 1.25;

    if (replacedMoveType.id == PokeTypeId.fire && myFields.indexWhere((e) => e.id == IndividualField.waterSport) >= 0) tmpPow = tmpPow * 1352 / 4096;
    if (replacedMoveType.id == PokeTypeId.electric && myFields.indexWhere((e) => e.id == IndividualField.mudSport) >= 0) tmpPow = tmpPow * 1352 / 4096;

    movePower = tmpPow.floor();
    // テラスタイプ一致補正/ステラ補正が入っていて威力60未満なら60に
    if (movePower < 60 && (myState.canGetStellarHosei(replacedMoveType.id) || myState.canGetTerastalHosei(replacedMoveType.id))) {
      movePower = 60;
    }

    // 範囲補正・おやこあい補正は無視する(https://wiki.xn--rckteqa2e.com/wiki/%E3%83%80%E3%83%A1%E3%83%BC%E3%82%B8#%E7%AC%AC%E4%BA%94%E4%B8%96%E4%BB%A3%E4%BB%A5%E9%99%8D)
    bool plusIgnore = yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    bool minusIgnore = isCritical || yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    int calcMaxAttack =
      myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
        myState.finalizedMaxStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : myState.finalizedMaxStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinAttack =
      myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
        myState.finalizedMinStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : myState.finalizedMinStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    if (isFoulPlay) {
      calcMaxAttack = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          yourState.finalizedMaxStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : yourState.finalizedMaxStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
      calcMinAttack = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          yourState.finalizedMinStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : yourState.finalizedMinStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    }
    else if (defenseAltAttack) {
      calcMaxAttack = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          myState.finalizedMaxStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : myState.finalizedMaxStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
      calcMinAttack = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          myState.finalizedMinStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) : myState.finalizedMinStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    }
    int attackVmax = damageClassID == 2 ? calcMaxAttack : myState.finalizedMaxStat(StatIndex.C, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int attackVmin = damageClassID == 2 ? calcMinAttack : myState.finalizedMinStat(StatIndex.C, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    String attackStr = '';
    if (attackVmax == attackVmin) {
      attackStr = attackVmax.toString();
    }
    else {
      attackStr = '$attackVmin ~ $attackVmax';
    }
    if (isFoulPlay) {
      attackStr += loc.battleDamageAttackerAttack;
    }
    else {
      attackStr += damageClassID == 2 ? loc.battleDamageAttackerAttack : loc.battleDamageAttackerSAttack;
    }
    plusIgnore = isCritical || myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    minusIgnore = myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    int calcMaxDefense = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ? 
          ignoreTargetRank ? yourState.maxStats.b.real : yourState.finalizedMaxStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) :
          ignoreTargetRank ? yourState.maxStats.a.real : yourState.finalizedMaxStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMaxSDefense = ignoreTargetRank ? yourState.maxStats.d.real : yourState.finalizedMaxStat(StatIndex.D, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinDefense = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          ignoreTargetRank ? yourState.minStats.b.real : yourState.finalizedMinStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) :
          ignoreTargetRank ? yourState.minStats.a.real : yourState.finalizedMinStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinSDefense = ignoreTargetRank ? yourState.minStats.d.real : yourState.finalizedMinStat(StatIndex.D, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int defenseVmax = damageClassID == 2 ? 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            calcMaxDefense : calcMaxSDefense :
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            invDeffense ? calcMaxDefense : calcMaxSDefense :
            invDeffense ? calcMaxSDefense : calcMaxDefense;
    int defenseVmin = damageClassID == 2 ? 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            calcMinDefense : calcMinSDefense : 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            invDeffense ? calcMinDefense : calcMinSDefense :
            invDeffense ? calcMinSDefense : calcMinDefense ;
    String defenseStr = '';
    if (defenseVmax == defenseVmin) {
      defenseStr = defenseVmax.toString();
    }
    else {
      defenseStr = '$defenseVmin ~ $defenseVmax';
    }
    if (invDeffense) {
      defenseStr += loc.battleDamageDefenderDefense;
    }
    else {
      defenseStr += damageClassID == 2 ? loc.battleDamageDefenderDefense : loc.battleDamageDefenderSDefense;
    }
    int damageVmax = (((myState.pokemon.level * 2 / 5 + 2).floor() * movePower * (attackVmax / defenseVmin)).floor() / 50 + 2).floor();
    int damageVmin = ((((myState.pokemon.level * 2 / 5 + 2).floor() * movePower * (attackVmin / defenseVmax)).floor() / 50 + 2).floor() * 0.85).floor();
    ret = loc.battleDamageCalcBase(myState.pokemon.level, movePower, attackStr, defenseStr);
    // 天気補正(五捨五超入)
    if (yourState.holdingItem?.id != 1181) {    // 相手がばんのうがさを持っていない
      if (state.weather.id == Weather.sunny) {
        if (replacedMoveType.id == 10) {   // はれ下ほのおわざ
          damageVmax = roundOff5(damageVmax * 1.5);
          damageVmin = roundOff5(damageVmin * 1.5);
          ret += loc.battleDamageWeather1_5;
        }
        else if (replacedMoveType.id == 11) {   // はれ下みずわざ
          if (isSunny1_5) {
            damageVmax = roundOff5(damageVmax * 1.5);
            damageVmin = roundOff5(damageVmin * 1.5);
            ret += loc.battleDamageWeather1_5;
          }
          else {
            damageVmax = roundOff5(damageVmax * 0.5);
            damageVmin = roundOff5(damageVmin * 0.5);
            ret += loc.battleDamageWeather0_5;
          }
        }
      }
      else if (state.weather.id == Weather.rainy) {
        if (replacedMoveType.id == 11) {   // 雨下みずわざ
          damageVmax = roundOff5(damageVmax * 1.5);
          damageVmin = roundOff5(damageVmin * 1.5);
          ret += loc.battleDamageWeather1_5;
        }
        else if (replacedMoveType.id == 10) {   // 雨下ほのおわざ
          damageVmax = roundOff5(damageVmax * 0.5);
          damageVmin = roundOff5(damageVmin * 0.5);
          ret += loc.battleDamageWeather0_5;
        }
      }
    }
    // 急所補正(五捨五超入)
    if (moveHits[continuousCount].id == MoveHit.critical) {
      damageVmax = roundOff5(damageVmax * 1.5);
      damageVmin = roundOff5(damageVmin * 1.5);
      ret += loc.battleDamageCritical1_5;
    }
    // 乱数補正(切り捨て)
    damageVmax = (damageVmax * 100 / 100).floor();
    damageVmin = (damageVmin * 85 / 100).floor();
    ret += loc.battleDamageRandom85_100;
    // タイプ一致補正(五捨五超入)
    if (myState.canGetStellarHosei(replacedMoveType.id)) {
      myState.addStellarUsed(replacedMoveType.id);
      isTeraStellarHosei = true;
    }
    if (myState.canGetTerastalHosei(replacedMoveType.id)) isTeraStellarHosei = true;
    var rate = myState.typeBonusRate(replacedMoveType.id, myState.buffDebuffs.where((e) => e.id == BuffDebuff.typeBonus2).isNotEmpty);
    if (rate > 1.0) {
      damageVmax = roundOff5(damageVmax * rate);
      damageVmin = roundOff5(damageVmin * rate);
      ret += loc.battleDamageTypeBonus(rate);
    }
    // 相性補正(切り捨て)
    double typeRate = PokeType.effectivenessRate(myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
      yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty, replacedMoveType, yourState);
    if (yourState.currentAbility.id == 305 && (yourState.remainHP >= yourState.pokemon.h.real || yourState.remainHPPercent >= 100) && typeRate > 0.5) { // テラスシェル
      typeRate = 0.5;
    }
    if (additionalMoveType != null) {
      typeRate *= PokeType.effectivenessRate(myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty, additionalMoveType, yourState);
    }
    damageVmax = (damageVmax * typeRate).floor();
    damageVmin = (damageVmin * typeRate).floor();
    ret += loc.battleDamageTypeEffectiveness(typeRate);
    // やけど補正(五捨五超入)
    if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty && damageClassID == 2 && move.id != 263) {  // からげんき以外のぶつりわざ
      if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn) < 0) {
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
      if (
        !isCritical && myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isEmpty && (
        (damageClassID == 2 && yourFields.where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.reflector).isNotEmpty) ||
        (damageClassID == 3 && yourFields.where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.lightScreen).isNotEmpty))
      ) {
        tmpMax *= 0.5;
        tmpMin *= 0.5;
        ret += loc.battleDamageWall;
      }
      // ブレインフォース補正
      if (typeRate >= 2.0 &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamage1_25).isNotEmpty
      ) {
        tmpMax *= 1.25;
        tmpMin *= 1.25;
        ret += loc.battleDamageBrainForce;
      }
      // スナイパー補正
      if (moveHits[continuousCount].id == MoveHit.critical &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.sniper).isNotEmpty
      ) {
        tmpMax *= 1.5;
        tmpMin *= 1.5;
        ret += loc.battleDamageSniper;
      }
      // いろめがね補正
      if (typeRate > 0.0 && typeRate < 1.0 &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.notGoodType2).isNotEmpty
      ) {
        tmpMax *= 2;
        tmpMin *= 2;
        ret += loc.battleDamageTintedLens;
      }
      // もふもふほのお補正
      if (!ignoreAbility && (damageClassID == 2 || damageClassID == 3) &&
          replacedMoveType.id == 10 &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.fireAttackedDamage2).isNotEmpty
      ) {
        tmpMax *= 2;
        tmpMin *= 2;
        ret += loc.battleDamageFluffy;
      }
      // Mhalf
      if (!ignoreAbility &&
        // こおりのりんぷん
        (damageClassID == 3 &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.specialDamaged0_5).isNotEmpty) ||
        // パンクロック
        (replacedMove.isSound && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.soundedDamage0_5).isNotEmpty) ||
        // ファントムガード
        // マルチスケイル
        ((yourState.remainHP >= yourState.pokemon.h.real || yourState.remainHPPercent >= 100) &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.damaged0_5).isNotEmpty) ||
        // もふもふ直接こうげき
        (replacedMove.isDirect && !(replacedMove.isPunch && myState.holdingItem?.id == 1700) &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.directAttackedDamage0_5).isNotEmpty) ||
        // たいねつ
        (replacedMoveType.id == PokeTypeId.fire && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.heatproof).isNotEmpty)
      ) {
        tmpMax *= 0.5;
        tmpMin *= 0.5;
        ret += loc.battleDamageAbility0_5;
      }
      // Mfilter
      if (!ignoreAbility &&
        // ハードロック
        // フィルター
        // プリズムアーマー
        typeRate >= 2.0 && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamaged0_75).isNotEmpty
      ) {
        tmpMax *= 0.75;
        tmpMin *= 0.75;
        ret += loc.battleDamageAbility0_75;
      }
      // たつじんのおび補正
      if (typeRate >= 2.0 && myState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamage1_2).isNotEmpty
      ) {
        tmpMax *= 1.2;
        tmpMin *= 1.2;
        ret += loc.battleDamageExpertBelt;
      }
      // メトロノーム補正
      if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2).isNotEmpty) {
        int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.sameMoveCount);
        if (findIdx >= 0) {
          int count = myState.hiddenBuffs[findIdx].extraArg1 % 100;
          if (count > 0) {
            tmpMax *= (1.0 + 0.2 * count);
            tmpMin *= (1.0 + 0.2 * count);
            ret += loc.battleDamageMetronome(1.0 + 0.2 * count);
          }
        }
      }
      // いのちのたま補正
      if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.lifeOrb).isNotEmpty)
      {
        tmpMax *= 1.3;
        tmpMin *= 1.3;
        ret += loc.battleDamageLifeOrb;
      }
      // 半減きのみ補正
      if (halvedBerry > 0) {
        //double mult = yourState.buffDebuffs[findIdx].extraArg1 == 1 ? 0.25 : 0.5;
        tmpMax *= halvedBerry;
        tmpMin *= halvedBerry;
        ret += loc.battleDamageBerry(halvedBerry);
        yourState.buffDebuffs.removeWhere((e) => e.id == BuffDebuff.halvedBerry);
      }
      // Mtwice
      if (mTwice || yourState.buffDebuffs.where((e) => e.id == BuffDebuff.certainlyHittedDamage2).isNotEmpty) {
        tmpMax *= 2;
        tmpMin *= 2;
        ret += loc.battleDamageOthers;
      }
      
      damageVmax = roundOff5(tmpMax);
      damageVmin = roundOff5(tmpMin);
    }
    // Mprotect(五捨五超入)
    // ダイマックスわざに関する計算のため、SVでは不要
    { }
    ret += '= $damageVmin ~ $damageVmax';
    return Tuple4(ret, damageVmax, damageVmin, isTeraStellarHosei);
  }

  Tuple3<StatIndex, int, int> calcRealFromDamage(
    int realDamage,
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    int continuousCount,
    PlayerType myPlayerType,
    Move move,
    PokeType replacedMoveType,
    int power,
    int damageClassID,
    PokemonState beforeChangeMyState,
    bool isNormalized1_2,
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
    bool isTeraStellarHosei,
    {
      required AppLocalizations loc,
    }
  ) {
    // ダメージから逆算
    if (isFoulPlay) return Tuple3(StatIndex.H, 0, 0);
    int movePower = power;
    Move replacedMove = move;
    var myFields = state.getIndiFields(myPlayerType);
    var yourFields = state.getIndiFields(myPlayerType.opposite);

    // タイプ相性を計算
    double typeRate = PokeType.effectivenessRate(myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
      yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty, replacedMoveType, yourState);
    if (yourState.currentAbility.id == 305 && (yourState.remainHP >= yourState.pokemon.h.real || yourState.remainHPPercent >= 100) && typeRate > 0.5) { // テラスシェル
      typeRate = 0.5;
    }
    if (additionalMoveType != null) {
      typeRate *= PokeType.effectivenessRate(myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty, additionalMoveType, yourState);
    }

    double tmp = realDamage.toDouble();
    int tmpInt = realDamage;
    int tmpMax = realDamage;
    int tmpMin = realDamage;
    // Mprotect(五捨五超入)
    // ダイマックスわざに関する計算のため、SVでは不要
    { }
    // M(五捨五超入)
    {
      // Mtwice
      if (mTwice || yourState.buffDebuffs.where((e) => e.id == BuffDebuff.certainlyHittedDamage2).isNotEmpty) {
        tmp /= 2;
      }
      // 半減きのみ補正
      if (halvedBerry > 0) {
        tmp /= halvedBerry;
      }
      // いのちのたま補正
      if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.lifeOrb).isNotEmpty)
      {
        tmp /= 1.3;
      }
      // メトロノーム補正
      if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.continuousMoveDamageInc0_2).isNotEmpty) {
        int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.sameMoveCount);
        if (findIdx >= 0) {
          int count = myState.hiddenBuffs[findIdx].extraArg1 % 100;
          if (count > 0) {
            tmp /= (1.0 + 0.2 * count);
          }
        }
      }
      // たつじんのおび補正
      if (typeRate >= 2.0 && myState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamage1_2).isNotEmpty
      ) {
        tmp /= 1.2;
      }
      // Mfilter
      if (!ignoreAbility &&
        // ハードロック
        // フィルター
        // プリズムアーマー
        typeRate >= 2.0 && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamaged0_75).isNotEmpty
      ) {
        tmp /= 0.75;
      }
      // Mhalf
      if (!ignoreAbility &&
        // こおりのりんぷん
        (damageClassID == 3 &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.specialDamaged0_5).isNotEmpty) ||
        // パンクロック
        (replacedMove.isSound && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.soundedDamage0_5).isNotEmpty) ||
        // ファントムガード
        // マルチスケイル
        ((yourState.remainHP >= yourState.pokemon.h.real || yourState.remainHPPercent >= 100) &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.damaged0_5).isNotEmpty) ||
        // もふもふ直接こうげき
        (replacedMove.isDirect && !(replacedMove.isPunch && myState.holdingItem?.id == 1700) &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.directAttackedDamage0_5).isNotEmpty) ||
        // たいねつ
        (replacedMoveType.id == PokeTypeId.fire && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.heatproof).isNotEmpty)
      ) {
        tmp /= 0.5;
      }
      // もふもふほのお補正
      if (!ignoreAbility && (damageClassID == 2 || damageClassID == 3) &&
          replacedMoveType.id == 10 &&
          yourState.buffDebuffs.where((e) => e.id == BuffDebuff.fireAttackedDamage2).isNotEmpty
      ) {
        tmp /= 2;
      }
      // いろめがね補正
      if (typeRate > 0.0 && typeRate < 1.0 &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.notGoodType2).isNotEmpty
      ) {
        tmp /= 2;
      }
      // スナイパー補正
      if (moveHits[continuousCount].id == MoveHit.critical &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.sniper).isNotEmpty
      ) {
        tmp /= 1.5;
      }
      // ブレインフォース補正
      if (typeRate >= 2.0 &&
          myState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamage1_25).isNotEmpty
      ) {
        tmp /= 1.25;
      }
      // 壁補正
      if (
        !isCritical && myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isEmpty && (
        (damageClassID == 2 && yourFields.where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.reflector).isNotEmpty) ||
        (damageClassID == 3 && yourFields.where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.lightScreen).isNotEmpty))
      ) {
        tmp /= 0.5;
      }

      tmpInt = roundOff5(tmp);
    }
    // やけど補正(五捨五超入)
    if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty && damageClassID == 2 && move.id != 263) {  // からげんき以外のぶつりわざ
      if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn) < 0) {
        tmpInt = roundOff5(tmpInt / 0.5);
      }
    }
    // 相性補正(切り捨て)
    tmpInt = (tmpInt / typeRate).floor();
    // タイプ一致補正(五捨五超入)
    var rate = myState.typeBonusRate(replacedMoveType.id, myState.buffDebuffs.where((e) => e.id == BuffDebuff.typeBonus2).isNotEmpty);
    // ステラタイプ補正を使ってしまったために、再度計算したら値に補正が反映されてない場合
    if (isTeraStellarHosei && myState.teraType1.id == PokeTypeId.stellar) {
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
    if (moveHits[continuousCount].id == MoveHit.critical) {
      tmpMax = roundOff5(tmpMax / 1.5);
      tmpMin = roundOff5(tmpMin / 1.5);
    }
    // 天気補正(五捨五超入)
    if (yourState.holdingItem?.id != 1181) {    // 相手がばんのうがさを持っていない
      if (state.weather.id == Weather.sunny) {
        if (replacedMoveType.id == 10) {   // はれ下ほのおわざ
          tmpMax = roundOff5(tmpMax / 1.5);
          tmpMin = roundOff5(tmpMin / 1.5);
        }
        else if (replacedMoveType.id == 11) {   // はれ下みずわざ
          if (isSunny1_5) {
            tmpMax = roundOff5(tmpMax / 1.5);
            tmpMin = roundOff5(tmpMin / 1.5);
          }
          else {
            tmpMax = roundOff5(tmpMax / 0.5);
            tmpMin = roundOff5(tmpMin / 0.5);
          }
        }
      }
      else if (state.weather.id == Weather.rainy) {
        if (replacedMoveType.id == 11) {   // 雨下みずわざ
          tmpMax = roundOff5(tmpMax / 1.5);
          tmpMin = roundOff5(tmpMin / 1.5);
        }
        else if (replacedMoveType.id == 10) {   // 雨下ほのおわざ
          tmpMax = roundOff5(tmpMax / 0.5);
          tmpMin = roundOff5(tmpMin / 0.5);
        }
      }
    }

    // ここからわざ自体の威力等補正

    // じゅうでん補正&消費
    int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.charging);
    if (findIdx >= 0 && replacedMoveType.id == 13) {
      movePower *= 2;
      myState.ailmentsRemoveAt(findIdx);
    }

    if (getChangePokemonIndex(myPlayerType) != null) {
      myState = beforeChangeMyState;
    }

    // とくせい等によるわざタイプの変更
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) replacedMoveType = PokeType.createFromId(15);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) replacedMoveType = PokeType.createFromId(18);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) replacedMoveType = PokeType.createFromId(3);
    if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.liquidVoice) >= 0) replacedMoveType = PokeType.createFromId(11);
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) replacedMoveType = PokeType.createFromId(13);
    if (replacedMove.id != 165 && replacedMoveType.id == PokeTypeId.normal && myFields.indexWhere((e) => e.id == IndividualField.ionDeluge) >= 0) replacedMoveType = PokeType.createFromId(PokeTypeId.electric);
    
    // とくせい等による威力変動
    double tmpPow = movePower.toDouble();
    // テクニシャン補正は一番最初
    if (replacedMove.power <= 60 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.technician) >= 0) tmpPow *= 1.5;

    if (isNormalized1_2) tmpPow *= 1.2;
    if (replacedMoveType.id == PokeTypeId.grass && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.overgrow) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.fire && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.blaze) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.water && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.torrent) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == PokeTypeId.bug && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.swarm) >= 0) tmpPow *= 1.5;
    if (myState.sex.id != 0 && yourState.sex.id != 0 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.opponentSex1_5) >= 0) {
      if (myState.sex.id != yourState.sex.id) {
        tmpPow *= 1.25;
      }
      else {
        tmpPow *= 0.75;
      }
    }
    if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punch1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isRecoil && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.recoil1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isAdditionalEffect2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.sheerForce) >= 0) tmpPow *= 1.3;
    if (replacedMove.isWave && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.wave1_5) >= 0) tmpPow *= 1.5;
    if (replacedMove.isDirect && !(replacedMove.isPunch && myState.holdingItem?.id == 1700) && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.directAttack1_3) >= 0) tmpPow *= 1.3;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.change2) >= 0 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.changedThisTurn) >= 0) tmpPow *= 2;
    if (damageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5) >= 0) tmpPow *= 1.5;
    if (damageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5) >= 0) tmpPow *= 1.5;
    if (!isFirst && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.analytic) >= 0) tmpPow *= 1.3;
    if ((replacedMoveType.id == 5 || replacedMoveType.id == 6 || replacedMoveType.id == 9) && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockGroundSteel1_3) >= 0) tmpPow *= 1.3;
    if (replacedMove.isBite && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bite1_5) >= 0) tmpPow *= 1.5;
    if (replacedMoveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.darkAura) >= 0) tmpPow *= 1.33;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAura) >= 0) tmpPow *= 1.33;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiDarkAura) >= 0) tmpPow *= 0.75;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiFairyAura) >= 0) tmpPow *= 0.75;
    if (replacedMoveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) tmpPow *= 1.2;
    if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.sound1_3) >= 0) tmpPow *= 1.3;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove1_3) >= 0) tmpPow *= 1.3;
    if (replacedMoveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steel1_5) >= 0) tmpPow *= 1.5;
    if (replacedMove.isCut && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.cut1_5) >= 0) tmpPow *= 1.5;
    int pow = myState.buffDebuffs.indexWhere((e) => e.id >= BuffDebuff.power10 && e.id <= BuffDebuff.power50);
    if (pow >= 0) tmpPow = tmpPow * (1.0 + (myState.buffDebuffs[pow].id - BuffDebuff.power10 + 1) * 0.1);
    if (damageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_1) >= 0) tmpPow *= 1.1;
    if (damageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_1) >= 0) tmpPow *= 1.1;
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3) >= 0) tmpPow *= 1.3;
    if (replacedMoveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.normalAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fightAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 4 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.poisonAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 5 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.groundAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 6 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 7 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bugAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 8 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 10 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fireAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 11 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 12 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.grassAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 14 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 16 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.evilAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMoveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAttack1_2) >= 0) tmpPow *= 1.2;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.moveAttack1_2) >= 0) tmpPow *= 1.2;
    if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punchNotDirect1_1) >= 0) tmpPow *= 1.1;
    if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_2) >= 0) tmpPow *= 1.2;

    if (replacedMoveType.id == 13 && myState.isGround(myFields) && state.field.id == Field.electricTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 12 && myState.isGround(myFields) && state.field.id == Field.grassyTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 14 && myState.isGround(myFields) && state.field.id == Field.psychicTerrain) tmpPow *= 1.3;
    if (replacedMoveType.id == 16 && yourState.isGround(yourFields) && state.field.id == Field.mistyTerrain) tmpPow *= 0.5;
    
    if (replacedMoveType.id == 10 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.drySkin) >= 0) tmpPow *= 1.25;

    if (replacedMoveType.id == PokeTypeId.fire && myFields.indexWhere((e) => e.id == IndividualField.waterSport) >= 0) tmpPow = tmpPow * 1352 / 4096;
    if (replacedMoveType.id == PokeTypeId.electric && myFields.indexWhere((e) => e.id == IndividualField.mudSport) >= 0) tmpPow = tmpPow * 1352 / 4096;

    movePower = tmpPow.floor();
    // テラスタイプ一致補正/ステラ補正が入っていて威力60未満なら60に
    if (movePower < 60 && isTeraStellarHosei) {
      movePower = 60;
    }

    bool plusIgnore = isCritical || myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    bool minusIgnore = myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    int calcMaxDefense = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ? 
          ignoreTargetRank ? yourState.maxStats.b.real : yourState.finalizedMaxStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) :
          ignoreTargetRank ? yourState.maxStats.a.real : yourState.finalizedMaxStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMaxSDefense = ignoreTargetRank ? yourState.maxStats.d.real : yourState.finalizedMaxStat(StatIndex.D, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinDefense = yourState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
          ignoreTargetRank ? yourState.minStats.b.real : yourState.finalizedMinStat(StatIndex.B, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore) :
          ignoreTargetRank ? yourState.minStats.a.real : yourState.finalizedMinStat(StatIndex.A, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int calcMinSDefense = ignoreTargetRank ? yourState.minStats.d.real : yourState.finalizedMinStat(StatIndex.D, replacedMoveType, yourState, state, plusCut: plusIgnore, minusCut: minusIgnore);
    int defenseVmax = damageClassID == 2 ? 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            calcMaxDefense : calcMaxSDefense :
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            invDeffense ? calcMaxDefense : calcMaxSDefense :
            invDeffense ? calcMaxSDefense : calcMaxDefense;
    int defenseVmin = damageClassID == 2 ? 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            calcMinDefense : calcMinSDefense : 
          myFields.where((element) => element.id == IndividualField.wonderRoom).isEmpty ? // ワンダールーム
            invDeffense ? calcMinDefense : calcMinSDefense :
            invDeffense ? calcMinSDefense : calcMinDefense ;

    int attackVmax = ((((tmpMax / 0.85).floor() - 2) * 50 * defenseVmax) / ((myState.pokemon.level * 2 / 5 + 2).floor() * movePower)).floor();
    int attackVmin = (((tmpMin - 2) * 50 * defenseVmin) / ((myState.pokemon.level * 2 / 5 + 2).floor() * movePower)).floor();

    plusIgnore = yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;
    minusIgnore = isCritical || yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreRank).isNotEmpty;

    StatIndex retStat = StatIndex.H;
    int ret2 = 0;
    int ret3 = 0;
    if (damageClassID == 2) {
      if (defenseAltAttack) {
        if (myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty) {
          retStat = StatIndex.B;
        }
        else {
          retStat = StatIndex.A;
        }
      }
      else {
        if (myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty) {
          retStat = StatIndex.A;
        }
        else {
          retStat = StatIndex.B;
        }
      }
    }
    else {
      retStat = StatIndex.C;
    }
    if ((plusIgnore && myState.statChanges(retStat.index-1) > 0) ||
        (minusIgnore && myState.statChanges(retStat.index-1) < 0)
    ) {
      ret2 = attackVmax;
      ret3 = attackVmin;
    }
    else {
      ret2 = myState.getNotRankedStat(retStat, attackVmax);
      ret3 = myState.getNotRankedStat(retStat, attackVmin);
    }
    int count = 0;  // 誤差20までなら修正
    bool loop = true;
    while (count < 20 && loop) {
      loop = false;
      var copiedMyState = myState.copyWith()..minStats[retStat].real = ret3..maxStats[retStat].real = ret3;
      var ret = calcDamage(
        copiedMyState, yourState, state, continuousCount, myPlayerType, move,
        replacedMoveType, power, damageClassID, beforeChangeMyState, isNormalized1_2,
        isCritical, isFoulPlay, defenseAltAttack, ignoreTargetRank, invDeffense,
        isSunny1_5, ignoreAbility, mTwice, additionalMoveType, halvedBerry, loc: loc,
      );
      if (ret.item2 < realDamage) {
        ret3++;
        loop = true;
      }
      copiedMyState.minStats[retStat].real = ret2;
      copiedMyState.maxStats[retStat].real = ret2;
      ret = calcDamage(
        copiedMyState, yourState, state, continuousCount, myPlayerType, move,
        replacedMoveType, power, damageClassID, beforeChangeMyState, isNormalized1_2,
        isCritical, isFoulPlay, defenseAltAttack, ignoreTargetRank, invDeffense,
        isSunny1_5, ignoreAbility, mTwice, additionalMoveType, halvedBerry, loc: loc,
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
      var copiedMyState = myState.copyWith()..minStats[retStat].real = ret3..maxStats[retStat].real = ret3;
      var ret = calcDamage(
        copiedMyState, yourState, state, continuousCount, myPlayerType, move,
        replacedMoveType, power, damageClassID, beforeChangeMyState, isNormalized1_2,
        isCritical, isFoulPlay, defenseAltAttack, ignoreTargetRank, invDeffense,
        isSunny1_5, ignoreAbility, mTwice, additionalMoveType, halvedBerry, loc: loc,
      );
      if (ret.item2 > realDamage) {
        ret3--;
        loop = true;
      }
      copiedMyState.minStats[retStat].real = ret2;
      copiedMyState.maxStats[retStat].real = ret2;
      ret = calcDamage(
        copiedMyState, yourState, state, continuousCount, myPlayerType, move,
        replacedMoveType, power, damageClassID, beforeChangeMyState, isNormalized1_2,
        isCritical, isFoulPlay, defenseAltAttack, ignoreTargetRank, invDeffense,
        isSunny1_5, ignoreAbility, mTwice, additionalMoveType, halvedBerry, loc: loc,
      );
      if (ret.item3 < realDamage) {
        ret2++;
        loop = true;
      }
      count++;
    }
    
    return Tuple3(retStat, ret2, ret3);
  }

  Widget extraWidget1(
    void Function() onFocus,
    void Function() onFocusTextUpdate,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    TextEditingController moveController,
    TextEditingController hpController,
    MyAppState appState,
    int phaseIdx,
    int continuousCount,
    TurnEffectAndStateAndGuide turnEffectAndStateAndGuide,
    ThemeData theme,
    List<int> invalidGuideIDs,
    {
      required AppLocalizations loc,
      required bool isInput,
    }
  )
  {
    final pokeData = PokeDB();
    var myState = playerType == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var yourFields = state.getIndiFields(playerType.opposite);
    ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );

    // 行動失敗時
    if (!isSuccess) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: _myDropdownButtonFormField(
              isExpanded: true,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: loc.battleFailureCause,
              ),
              items: <DropdownMenuItem>[
                for (int i = 1; i < ActionFailure.size; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(ActionFailure(i).displayName, overflow: TextOverflow.ellipsis,),
                ),
              ],
              value: actionFailure.id == 0 ? null : actionFailure.id,
              onChanged: (value) {
                actionFailure = ActionFailure(value);
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
              onFocus: onFocus,
              isInput: isInput,
              textValue: ActionFailure(actionFailure.id).displayName,
              theme: theme,
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 5,
            child: _myTypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: moveController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battleMoveTryToUse,
                ),
              ),
              autoFlipDirection: true,
              suggestionsCallback: (pattern) async {
                List<Move> matches = [];
                if (playerType == PlayerType.me) {
                  matches.add(ownPokemon.move1);
                  if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                  if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                  if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                }
                else {
                  matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                }
                matches.retainWhere((s){
                  return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                });
                return matches;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.displayName),
                );
              },
              onSuggestionSelected: (suggestion) {
                moveController.text = suggestion.displayName;
                move = suggestion;
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
              onFocus: onFocus,
              isInput: isInput,
            ),
          ),
        ],
      );
    }
    // 行動成功時
    else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: isInput ?
                  playerType != PlayerType.none ?
                  () {
                    type = TurnMoveType(TurnMoveType.move);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  } : null :
                  () {},
                style: type.id == TurnMoveType.move ? pressedStyle : null,
                child: Text(loc.commonMove),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: isInput ?
                  playerType != PlayerType.none ?
                  () {
                    type = TurnMoveType(TurnMoveType.change);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  } : null :
                  () {},
                style: type.id == TurnMoveType.change ? pressedStyle : null,
                child: Text(loc.battlePokemonChange),
              ),
              SizedBox(width: 10,),
              TextButton(
                onPressed: isInput ?
                  playerType != PlayerType.none ?
                  () {
                    type = TurnMoveType(TurnMoveType.surrender);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  } : null :
                  () {},
                style: type.id == TurnMoveType.surrender ? pressedStyle : null,
                child: Text(loc.battleSurrender),
              ),
            ],
          ),
          SizedBox(height: 10,),
          type.id == TurnMoveType.move ?     // 行動がわざの場合
          Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: moveController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                    enabled: playerType != PlayerType.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType == PlayerType.me) {
                      matches.add(ownPokemon.move1);
                      if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                      if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                      if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                    }
                    else if (opponentPokemonState.moves.length == 4) {  //　わざがすべて判明している場合
                      matches.addAll(opponentPokemonState.moves);
                    }
                    else {
                      matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                      if (state.canZorua) matches.addAll(pokeData.pokeBase[PokeBase.zoruaNo]!.move.where((e) => matches.where((element) => element.id == e.id).isEmpty));
                      if (state.canZoroark) matches.addAll(pokeData.pokeBase[PokeBase.zoroarkNo]!.move.where((e) => matches.where((element) => element.id == e.id).isEmpty));
                      if (state.canZoruaHisui) matches.addAll(pokeData.pokeBase[PokeBase.zoruaHisuiNo]!.move.where((e) => matches.where((element) => element.id == e.id).isEmpty));
                      if (state.canZoroarkHisui) matches.addAll(pokeData.pokeBase[PokeBase.zoroarkHisuiNo]!.move.where((e) => matches.where((element) => element.id == e.id).isEmpty));
                    }
                    matches.add(pokeData.moves[165]!);    // わるあがき
                    matches.retainWhere((s){
                      return toKatakana50(getReplacedMoveName(s, continuousCount, myState).toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    DamageGetter getter = DamageGetter();
                    TurnMove tmp = copyWith();
                    tmp.move = getReplacedMove(suggestion, continuousCount, myState);
                    tmp.moveHits[continuousCount] = getMoveHit(suggestion, continuousCount, myState, yourState, yourFields);
                    tmp.moveAdditionalEffects[continuousCount] = tmp.move.isSurelyEffect() ? MoveEffect(tmp.move.effect.id) : MoveEffect(0);
                    tmp.moveEffectivenesses[continuousCount] = PokeType.effectiveness(
                        myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
                        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                        getReplacedMoveType(tmp.move, continuousCount, myState, state), yourState);
                    tmp.processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0, invalidGuideIDs,
                      damageGetter: getter, loc: loc,);
                    return ListTile(
                      leading: getReplacedMoveType(suggestion, continuousCount, myState, state).displayIcon,
                      title: Text(getReplacedMoveName(suggestion, continuousCount, myState)),
                      trailing: Text(getter.rangeString),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    move = getReplacedMove(suggestion, continuousCount, myState);
                    moveController.text = move.displayName;
                    moveHits[continuousCount] = getMoveHit(suggestion, continuousCount, myState, yourState, yourFields);
                    moveAdditionalEffects[0] = move.isSurelyEffect() ? MoveEffect(move.effect.id) : MoveEffect(0);
                    moveEffectivenesses[0] = PokeType.effectiveness(
                        myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
                        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                        getReplacedMoveType(move, continuousCount, myState, state), yourState);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0, invalidGuideIDs, loc: loc,);
                    setAutoArgs(state, continuousCount);
                    appState.editingPhase[phaseIdx] = true;
                    onFocusTextUpdate();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          ) :
          type.id == TurnMoveType.change ?     // 行動が交代の場合
          Row(
            children: [
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battlePokemonToChange,
                  ),
                  items: playerType == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon),
                          theme: theme,
                          pokemon: ownParty.pokemons[i]!,
                          showNetworkImage: pokeData.getPokeAPI,
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                          theme: theme,
                          pokemon: opponentParty.pokemons[i]!,
                          showNetworkImage: pokeData.getPokeAPI,
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    appState.needAdjustPhases = phaseIdx+1;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name,
                  prefixIconPokemon: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1] :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1],
                  showNetworkImage: pokeData.getPokeAPI,
                  theme: theme,
                ),
              ),
            ],
          ) :
          // 行動がにげる/こうさんのとき
          Container(),
        ],
      );
    }
  }

  Widget extraWidget2(
    void Function() onFocus,
    ThemeData theme,
    Pokemon ownPokemon,
    Pokemon opponentPokemon,
    Party ownParty,
    Party opponentParty,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    List<PokemonState> ownPokemonStates,
    List<PokemonState> opponentPokemonStates,
    PhaseState state,
    TextEditingController hpController,
    TextEditingController hpController2,
    TextEditingController preMoveController,
    MyAppState appState,
    int phaseIdx,
    int continuousCount,
    TurnEffectAndStateAndGuide turnEffectAndStateAndGuide,
    List<int> invalidGuideIDs,
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  )
  {
    if (!isSuccess && actionFailure.id != ActionFailure.confusion) return Container();

    if (!isSuccess && actionFailure.id == ActionFailure.confusion) {
      return DamageIndicateRow(
        playerType == PlayerType.me ? ownPokemon : opponentPokemon,
        hpController2,
        playerType == PlayerType.me,
        onFocus,
        (value) {
          if (playerType == PlayerType.me) {
            extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
          }
          else {
            extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
          }
          appState.editingPhase[phaseIdx] = true;
          onFocus();
        },
        playerType == PlayerType.me ? extraArg1[continuousCount] : extraArg2[continuousCount],
        isInput, loc: loc,
      );
    }

    var myState = playerType == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType == PlayerType.me ? opponentPokemonState : ownPokemonState;

    if (playerType != PlayerType.none && type.id == TurnMoveType.move && move.id != 0) {
      // 追加効果
      Row effectInputPrevRow = Row();
      bool insertPrevRow = false;
      switch (move.effect.id) {
        case 84:    // ほぼすべてのわざから1つをランダムで使う
        case 243:   // 最後に出されたわざを出す(相手のわざとは限らない)
                    // 含まれないわざもあるが、すべてのわざを入力できるようにしている
          insertPrevRow = true;
          effectInputPrevRow = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: preMoveController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = appState.pokeData.moves.values.toList();
                    matches.removeWhere((e) => e.id == 0);
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    preMoveController.text = suggestion.displayName;
                    extraArg3[continuousCount] = suggestion.id;
                    moveAdditionalEffects[continuousCount] = suggestion.isSurelyEffect() ? MoveEffect(suggestion.effect.id) : MoveEffect(0);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0, invalidGuideIDs, loc: loc,);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 98:    // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
          insertPrevRow = true;
          effectInputPrevRow = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: preMoveController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType == PlayerType.me) {
                      matches.add(ownPokemon.move1);
                      if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                      if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                      if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                    }
                    else if (opponentPokemonState.moves.length == 4) {  //　わざがすべて判明している場合
                      matches.addAll(opponentPokemonState.moves);
                    }
                    else {
                      matches.addAll(appState.pokeData.pokeBase[opponentPokemon.no]!.move);
                    }
                    matches.add(appState.pokeData.moves[165]!);    // わるあがき
                    matches.removeWhere((e) => e.id == 0);
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    preMoveController.text = suggestion.displayName;
                    extraArg3[continuousCount] = suggestion.id;
                    moveAdditionalEffects[continuousCount] = suggestion.isSurelyEffect() ? MoveEffect(suggestion.effect.id) : MoveEffect(0);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0, invalidGuideIDs, loc: loc,);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        default:
          break;
      }
      
      // 必要に応じてわざの内容変更
      Move replacedMove = getReplacedMove(move, continuousCount, playerType == PlayerType.me ? ownPokemonState : opponentPokemonState);

      // 追加効果
      Row effectInputRow = Row();
      Widget effectInputRow2 = Row();
      switch (replacedMove.effect.id) {
        //case 2:     // 眠らせる
        case 3:     // どくにする(確率)
        case 5:     // やけどにする(確率)
        case 6:     // こおりにする(確率)
        case 7:     // まひにする(確率)
        case 32:    // ひるませる(確率)
        case 69:    // こうげきを1段階下げる(確率)
        case 70:    // ぼうぎょを1段階下げる(確率)
        case 71:    // すばやさを1段階下げる(確率)
        case 72:    // とくこうを1段階下げる(確率)
        case 73:    // とくぼうを1段階下げる(確率)
        case 74:    // めいちゅうを1段階下げる(確率)
        case 77:    // こんらんさせる(確率)
        case 78:    // 2回こうげき、どくにする(確率)
        case 93:    // ひるませる(確率)。ねむり状態のときのみ成功
        case 153:   // まひにする(確率)。天気があめなら必中、はれなら命中率が下がる。そらをとぶ状態でも命中する
        case 201:   // やけどにする(確率)。急所に当たりやすい
        case 203:   // もうどくにする(確率)
        case 210:   // どくにする(確率)。急所に当たりやすい
        case 261:   // こおりにする(確率)。天気がゆきのときは必中
        case 268:   // こんらんさせる(確率)
        case 272:   // とくぼうを2段階下げる(確率)
        case 330:   // ねむり状態にする(確率)。メロエッタのフォルムが変わる
        case 334:   // こんらんさせる(確率)。そらをとぶ状態の相手にも当たる。天気があめだと必中、はれだと命中率50になる
        case 372:   // まひにする(確率)
        case 454:   // 対象がそのターンに能力が上がっているとやけど状態にする(確率)
        case 470:   // すばやさを1段階下げる(確率)。天気があめの時は必中
        case 471:   // まひにする(確率)。天気があめの時は必中
        case 472:   // やけどにする(確率)。天気があめの時は必中
        case 499:   // 眠らせる(確率)
        case 510:   // 対象がそのターンに能力が上がっているとこんらん状態にする(確率)
        case 512:   // 対象が先制攻撃技を使おうとしているとき、かつ使用者の方が先に行動する場合のみ成功。ひるませる(確率)。
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(_getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    _getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 4:     // 与えたダメージの半分だけHP回復
        case 9:     // ねむり状態の対象にのみダメージ、与えたダメージの半分だけHP回復
        case 33:    // 最大HPの半分だけ回復する
        case 49:    // 使用者は相手に与えたダメージの1/4ダメージを受ける
        case 80:    // 場に「みがわり」を発生させる
        case 92:    // 自分と相手のHPを足して半々に分ける
        case 133:   // 使用者のHP回復。回復量は天気による
        case 163:   // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
        case 199:   // 与えたダメージの33%を使用者も受ける
        case 215:   // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
        case 255:   // 使用者は最大HP1/4の反動ダメージを受ける
        case 270:   // 与えたダメージの1/2を使用者も受ける
        case 346:   // 与えたダメージの半分だけHP回復
        case 349:   // 与えたダメージの3/4だけHP回復
        case 382:   // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
        case 387:   // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
        case 388:   // 相手のこうげきを1段階下げ、下げる前のこうげき実数値と同じ値だけ使用者のHPを回復する
        case 433:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
        case 441:   // 最大HP1/4だけ回復
        case 461:   // 最大HP1/4回復、状態異常を治す
        case 485:   // 使用者の最大HP1/2(小数点以下切り捨て)を消費してこうげき・とくこう・すばやさを1段階ずつ上げる
          effectInputRow2 = DamageIndicateRow(
            playerType == PlayerType.me ? ownPokemon : opponentPokemon,
            hpController2,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            playerType == PlayerType.me ? extraArg1[continuousCount] : extraArg2[continuousCount],
            isInput, loc: loc,
          );
          break;
        case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
          effectInputRow = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonMove,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType == PlayerType.opponent) {
                      matches.add(ownPokemon.move1);
                      if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                      if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                      if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                    }
                    else if (opponentPokemonState.moves.length == 4) {  //　わざがすべて判明している場合
                      matches.addAll(opponentPokemonState.moves);
                    }
                    else {
                      matches.addAll(appState.pokeData.pokeBase[opponentPokemon.no]!.move);
                    }
                    matches.add(appState.pokeData.moves[165]!);    // わるあがき
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg3[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
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
        case 139:   // 使用者のぼうぎょを1段階上げる(確率)
        case 140:   // 使用者のこうげきを1段階上げる(確率)
        case 141:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
        case 277:   // 使用者のとくこうを1段階上げる(確率)
        case 359:   // 使用者のぼうぎょを2段階上げる(確率)
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(_getMoveEffectText(replacedMove.effect.id, myState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    _getMoveEffectText(replacedMove.effect.id, myState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 28:    // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleExhaustedConfused(myState.pokemon.omittedName)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == replacedMove.effect.id ?
                    loc.battleExhaustedConfused(myState.pokemon.omittedName) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 29:    // 相手ポケモンをランダムに交代させる
        case 314:   // 相手ポケモンをランダムに交代させる
          effectInputRow = Row(
            children: [
              Expanded(
                flex: 5,
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battlePokemonToChange,
                  ),
                  items: playerType == PlayerType.opponent ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType.opposite, i) && !state.getPokemonStates(playerType.opposite)[i].isFainting,
                          theme: theme,
                          pokemon: ownParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType.opposite, i) && !state.getPokemonStates(playerType.opposite)[i].isFainting,
                          theme: theme,
                          pokemon: opponentParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ],
                  value: getChangePokemonIndex(playerType.opposite),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType.opposite, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: isInput ? null : playerType == PlayerType.opponent ?
                    ownParty.pokemons[getChangePokemonIndex(playerType.opposite)??1-1]?.name :
                    opponentParty.pokemons[getChangePokemonIndex(playerType.opposite)??1-1]?.name,
                  prefixIconPokemon: isInput ? null : playerType == PlayerType.opponent ?
                    ownParty.pokemons[getChangePokemonIndex(playerType.opposite)??1-1] :
                    opponentParty.pokemons[getChangePokemonIndex(playerType.opposite)??1-1],
                  showNetworkImage: PokeDB().getPokeAPI,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 31:    // 使用者のタイプを、使用者が覚えているわざの一番上のタイプに変更する
        case 94:    // 使用者のタイプを、相手が直前に使ったわざのタイプを半減/無効にするタイプに変更する
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myTypeDropdownButton(
                    loc.battleTypeToChange,
                    (val) {extraArg1[continuousCount] = val;},
                    onFocus,
                    extraArg1[continuousCount] == 0 ? null : extraArg1[continuousCount],
                    isInput: isInput,
                  ),
              ),
            ],
          );
          break;
        case 37:    // やけど・こおり・まひのいずれかにする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
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
                      child: Text(loc.battleBurned(yourState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: Ailment.freeze,
                      child: Text(loc.battleFrozen(yourState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text(loc.battlePararised(yourState.pokemon.omittedName)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == Ailment.burn ? loc.battleBurned(yourState.pokemon.omittedName) :
                    extraArg1[continuousCount] == Ailment.freeze ? loc.battleFrozen(yourState.pokemon.omittedName) :
                    extraArg1[continuousCount] == Ailment.paralysis ? loc.battlePararised(yourState.pokemon.omittedName) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 46:    // わざを外すと使用者に、使用者の最大HP1/2のダメージ
          if (moveHits[continuousCount].id == MoveHit.notHit || moveHits[continuousCount].id == MoveHit.fail) {
            effectInputRow2 = DamageIndicateRow(
              playerType == PlayerType.me ? ownPokemon : opponentPokemon,
              hpController2,
              playerType == PlayerType.me,
              onFocus,
              (value) {
                if (playerType == PlayerType.me) {
                  extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                }
                else {
                  extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                }
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
              playerType == PlayerType.me ? extraArg1[continuousCount] : extraArg2[continuousCount],
              isInput, loc: loc,
            );
          }
          break;
        case 106:   // もちものを盗む
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleStealItem),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleStealItem : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.me) {
                      if (opponentPokemonState.getHoldingItem() != null && opponentPokemonState.getHoldingItem()!.id != 0) {
                        matches.add(opponentPokemonState.getHoldingItem()!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.getHoldingItem() != null) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
          if ((playerType == PlayerType.me && ownPokemonState.isTypeContain(8)) ||
              (playerType == PlayerType.opponent && opponentPokemonState.isTypeContain(8))
          ) {
            effectInputRow2 = DamageIndicateRow(
              playerType == PlayerType.me ? ownPokemon : opponentPokemon,
              hpController2,
              playerType == PlayerType.me,
              onFocus,
              (value) {
                if (playerType == PlayerType.me) {
                  extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                }
                else {
                  extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                }
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
              playerType == PlayerType.me ? extraArg1[continuousCount] : extraArg2[continuousCount],
              isInput, loc: loc,
            );
          }
          break;
        case 76:    // 1ターン目は攻撃せず、2ターン目に攻撃。ひるませる(確率)
        case 126:   // 使用者のこおり状態を消す。相手をやけど状態にする(確率)
        case 147:   // ひるませる(確率)。そらをとぶ状態でも命中し、その場合威力が2倍
        case 151:   // ひるませる(確率)。ちいさくなる状態に対して必中、その場合威力が2倍
        case 264:   // 使用者はそらをとぶ状態になり、次のターンにこうげきする。相手をまひ状態にする(確率)
        case 332:   // 1ターン目にため、2ターン目でこうげきする。まひ状態にする(確率)
        case 333:   // 1ターン目にため、2ターン目でこうげきする。やけど状態にする(確率)
        case 380:   // こおりにする(確率)。みずタイプのポケモンに対しても効果ばつぐんとなる
        case 449:   // ぶつりわざであるときの方がダメージが大きい場合は物理技になる。どく状態にする(確率)
        case 460:   // やけど状態にする(確率)。使用者、対象ともにこおりを治す
        case 466:   // 対象がどく・もうどく状態なら威力2倍。どくにする(確率)
        case 469:   // 対象が状態異常の場合威力2倍。やけど状態にする(確率)
        case 484:   // バインド・やどりぎのタネ・まきびし・どくびし・とがった岩・ねばねばネット除去。対象をどく状態にする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleAdditionalEffect,
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.commonNone),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(_getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == 1 ?
                    _getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 128:   // 控えのポケモンと交代する。能力変化・一部の状態変化は交代後に引き継ぐ
        case 154:   // 控えのポケモンと交代する
        case 229:   // 控えのポケモンと交代する
        case 347:   // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
        case 493:   // 天気をゆきにして控えと交代
          effectInputRow = Row(
            children: [
              Expanded(
                flex: 5,
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battlePokemonToChange,
                  ),
                  items: playerType == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          theme: theme,
                          pokemon: ownParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          theme: theme,
                          pokemon: opponentParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name,
                  prefixIconPokemon: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1] :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1],
                  showNetworkImage: PokeDB().getPokeAPI,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 136:   // 個体値によってわざのタイプが変わる
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myTypeDropdownButton(
                  loc.battleMoveType,
                  (val) {extraArg1[continuousCount] = val;},
                  onFocus,
                  extraArg1[continuousCount] == 0 ? null : extraArg1[continuousCount],
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 178:   // 使用者ともちものを入れ替える
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleItemYouGet,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (opponentPokemonState.getHoldingItem() != null && opponentPokemonState.getHoldingItem()!.id != 0) {
                      matches.add(opponentPokemonState.getHoldingItem()!);
                    }
                    else {
                      matches = appState.pokeData.items.values.toList();
                      matches.removeWhere((element) => element.id == 0);
                      for (var item in opponentPokemonState.impossibleItems) {
                        matches.removeWhere((element) => element.id == item.id);
                      }
                      matches.add(Item(
                        id: 0, displayName: loc.commonNone, displayNameEn: 'None', flingPower: 0, flingEffectId: 0,
                        timing: Timing.none, isBerry: false, imageUrl: '',
                      ));
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 179:   // 相手と同じとくせいになる
          effectInputRow = Row(
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonAbility,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType == PlayerType.me) {
                      if (opponentPokemonState.currentAbility.id != 0) {
                        matches.add(opponentPokemonState.currentAbility);
                      }
                      else {
                        matches.addAll(opponentPokemonState.possibleAbilities);
                      }
                      if (state.canAnyZoroark) matches.add(PokeDB().abilities[149]!);
                    }
                    else {
                      matches.add(ownPokemonState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 185:   // 戦闘中自分が最後に使用したもちものを復活させる
        case 324:   // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
        case 456:   // 対象にもちものがあるときのみ成功
        case 457:   // 対象のもちものを消失させる
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = appState.pokeData.items.values.toList();
                    matches.removeWhere((element) => element.id == 0);
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 189:   // もちものを持っていれば失わせ、威力1.5倍
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleKnockOffItem),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleKnockOffItem : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.me) {
                      if (opponentPokemonState.getHoldingItem() != null && opponentPokemonState.getHoldingItem()!.id != 0) {
                        matches.add(opponentPokemonState.getHoldingItem()!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.getHoldingItem() != null) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 192:   // 使用者ととくせいを入れ替える
          effectInputRow = Row(
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleAbilityYouGet,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (opponentPokemonState.getCurrentAbility().id != 0) {
                      matches.add(opponentPokemonState.getCurrentAbility());
                    } else {
                      matches.addAll(opponentPokemonState.possibleAbilities);
                    }
                    if (state.canAnyZoroark) matches.add(PokeDB().abilities[149]!);
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
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleConsumeOpponentBerry(yourState.pokemon.omittedName)),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleConsumeOpponentBerry(yourState.pokemon.omittedName) : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.me) {
                      if (opponentPokemonState.getHoldingItem() != null && opponentPokemonState.getHoldingItem()!.id != 0) {
                        matches.add(opponentPokemonState.getHoldingItem()!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.getHoldingItem() != null) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraWidget(
            onFocus, theme, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
            state, preMoveController, extraArg2[continuousCount], 0, getChangePokemonIndex(playerType),
            (value) {
              extraArg2[continuousCount] = value;
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            (value) {},
            (value) {
              setChangePokemonIndex(playerType, value);
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            isInput,
            showNetworkImage: PokeDB().getPokeAPI,
            loc: loc,
          );
          break;
        case 227:     // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleAdditionalEffect,
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.battleAttackUp2(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(loc.battleDefenseUp2(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(loc.battleSAttackUp2(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text(loc.battleSDefenseUp2(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text(loc.battleAccuracyUp2(myState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text(loc.battleEvasivenessUp2(myState.pokemon.omittedName)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == 0 ? loc.battleAttackUp2(myState.pokemon.omittedName) :
                    extraArg1[continuousCount] == 1 ? loc.battleDefenseUp2(myState.pokemon.omittedName) :
                    extraArg1[continuousCount] == 2 ? loc.battleSAttackUp2(myState.pokemon.omittedName) :
                    extraArg1[continuousCount] == 3 ? loc.battleSDefenseUp2(myState.pokemon.omittedName) :
                    extraArg1[continuousCount] == 5 ? loc.battleAccuracyUp2(myState.pokemon.omittedName) :
                    loc.battleEvasivenessUp2(myState.pokemon.omittedName),
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 234:   // 使用者のもちものによって威力と追加効果が変わる
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleFlingItem),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleFlingItem : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType == PlayerType.opponent) {
                      if (opponentPokemonState.getHoldingItem() != null && opponentPokemonState.getHoldingItem()!.id != 0) {
                        matches.add(opponentPokemonState.getHoldingItem()!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.getHoldingItem() != null) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraWidget(
            onFocus, theme, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
            state, preMoveController, extraArg2[continuousCount], 0, getChangePokemonIndex(playerType),
            (value) {
              extraArg2[continuousCount] = value;
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            (value) {},
            (value) {
              setChangePokemonIndex(playerType, value);
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            isInput,
            showNetworkImage: PokeDB().getPokeAPI,
            loc: loc,
          );
          break;
        case 254:   // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
        case 263:   // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
        case 475:   // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
        case 500:   // 与えたダメージの半分だけ回復する。両者のこおり状態を消す。相手をやけど状態にする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleAdditionalEffect,
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.commonNone),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(_getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == 1 ?
                    _getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          effectInputRow2 = DamageIndicateRow(
            playerType == PlayerType.me ? ownPokemon : opponentPokemon,
            hpController2,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg2[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            extraArg2[continuousCount],
            isInput, loc: loc,
          );
          break;
        case 274:   // 相手をやけど状態にする(確率)。相手をひるませる(確率)。
        case 275:   // 相手をこおり状態にする(確率)。相手をひるませる(確率)。
        case 276:   // 相手をまひ状態にする(確率)。相手をひるませる(確率)。
        case 468:   // 相手のぼうぎょを1段階下げる(確率)。相手をひるませる(確率)。急所に当たりやすい
          effectInputRow = Row(
            children: [
              Flexible(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${loc.battleAdditionalEffect}1',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.commonNone),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(_getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == 1 ?
                    _getMoveEffectText(replacedMove.effect.id, yourState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Flexible(
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${loc.battleAdditionalEffect}2',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text(loc.commonNone),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(_getMoveEffectText2(replacedMove.effect.id, yourState.pokemon.omittedName, loc)),
                    ),
                  ],
                  value: extraArg2[continuousCount],
                  onChanged: (value) {
                    extraArg2[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg2[continuousCount] == 1 ?
                    _getMoveEffectText2(replacedMove.effect.id, yourState.pokemon.omittedName, loc) : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 300:   // 相手のとくせいを使用者のとくせいと同じにする
          effectInputRow = Row(
            children: [
              Flexible(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonAbility,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType == PlayerType.opponent) {
                      if (opponentPokemonState.currentAbility.id != 0) {
                        matches.add(opponentPokemonState.currentAbility);
                      }
                      else {
                        matches.addAll(opponentPokemonState.possibleAbilities);
                      }
                      if (state.canAnyZoroark) matches.add(PokeDB().abilities[149]!);
                    }
                    else {
                      matches.add(ownPokemonState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 315:   // 相手のきのみ・ノーマルジュエルを失わせる
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleBurnDownItem),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleBurnDownItem : loc.commonNone,
                  theme: theme,
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.commonItem,
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    Item? holdingItem = playerType == PlayerType.me ? opponentPokemonState.getHoldingItem() : ownPokemonState.getHoldingItem();
                    if (playerType == PlayerType.me) {
                      if (holdingItem != null && holdingItem.id != 0) {
                        if (holdingItem.isBerry || holdingItem.id == 669) {
                          matches.add(holdingItem);
                        }
                      }
                      else {
                        matches = appState.pokeData.items.values.where((e) => e.isBerry || e.id == 669).toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (holdingItem != null && (holdingItem.isBerry || holdingItem.id == 669)) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          break;
        case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
          effectInputRow = Row(
            children: [
              Expanded(
                child: _myTypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: loc.battleConsumedItem,
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    Item? holdingItem = playerType == PlayerType.me ? ownPokemonState.getHoldingItem() : opponentPokemonState.getHoldingItem();
                    if (playerType == PlayerType.opponent) {
                      if (holdingItem != null && holdingItem.id != 0) {
                        if (holdingItem.isBerry) {
                          matches.add(holdingItem);
                        }
                      }
                      else {
                        matches = appState.pokeData.items.values.where((e) => e.isBerry).toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (holdingItem != null && (holdingItem.isBerry)) {
                      matches = [ownPokemonState.getHoldingItem()!];
                    }
                    matches.retainWhere((s){
                      return toKatakana50(s.displayName.toLowerCase()).contains(toKatakana50(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.displayName, overflow: TextOverflow.ellipsis,),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    hpController2.text = suggestion.displayName;
                    extraArg1[continuousCount] = suggestion.id;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraWidget(
            onFocus, theme, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
            state, preMoveController, extraArg2[continuousCount], 0, getChangePokemonIndex(playerType),
            (value) {
              extraArg2[continuousCount] = value;
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            (value) {},
            (value) {
              setChangePokemonIndex(playerType, value);
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            isInput,
            showNetworkImage: PokeDB().getPokeAPI,
            loc: loc,
          );
          break;
        case 464:     // どく・まひ・ねむりのいずれかにする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
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
                      child: Text(loc.battlePoisoned(yourState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text(loc.battlePararised(yourState.pokemon.omittedName)),
                    ),
                    DropdownMenuItem(
                      value: Ailment.sleep,
                      child: Text(loc.battleFellAsleep(yourState.pokemon.omittedName)),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: extraArg1[continuousCount] == Ailment.poison ? loc.battlePoisoned(yourState.pokemon.omittedName) :
                    extraArg1[continuousCount] == Ailment.paralysis ? loc.battlePararised(yourState.pokemon.omittedName) :
                    extraArg1[continuousCount] == Ailment.sleep ? loc.battleFellAsleep(yourState.pokemon.omittedName) :
                    loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        case 492:   // 使用者の最大HP1/2(小数点以下切り捨て)を消費してみがわり作成、みがわりを引き継いで控えと交代
          effectInputRow = Row(
            children: [
              Expanded(
                flex: 5,
                child: _myDropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleRevivePokemon,
                  ),
                  items: playerType == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          theme: theme,
                          pokemon: ownParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        PokemonDropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          theme: theme,
                          pokemon: opponentParty.pokemons[i]!,
                          showNetworkImage: PokeDB().getPokeAPI,
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1]?.name,
                  prefixIconPokemon: isInput ? null : playerType == PlayerType.me ?
                    ownParty.pokemons[getChangePokemonIndex(playerType)??1-1] :
                    opponentParty.pokemons[getChangePokemonIndex(playerType)??1-1],
                  showNetworkImage: PokeDB().getPokeAPI,
                  theme: theme,
                ),
              ),
            ],
          );
          effectInputRow2 = DamageIndicateRow(
            playerType == PlayerType.me ? ownPokemon : opponentPokemon,
            hpController2,
            playerType == PlayerType.me,
            onFocus,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
              }
              else {
                extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
              }
              appState.editingPhase[phaseIdx] = true;
              onFocus();
            },
            playerType == PlayerType.me ? extraArg1[continuousCount] : extraArg2[continuousCount],
            isInput, loc: loc,
          );
          break;
        case 505:   // 威力が2倍になる(確率)
          effectInputRow = Row(
            children: [
              Expanded(
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
                      value: replacedMove.effect.id,
                      child: Text(loc.battleGoAllOut),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                  onFocus: onFocus,
                  isInput: isInput,
                  textValue: moveAdditionalEffects[continuousCount].id == replacedMove.effect.id ?
                    loc.battleGoAllOut : loc.commonNone,
                  theme: theme,
                ),
              ),
            ],
          );
          break;
        default:
          break;
      }
      
      switch (replacedMove.damageClass.id) {
        case 1:   // へんか
          switch(replacedMove.target.id) {
            case 16:    // ひんしになった(味方の)ポケモン
              return Row(
                children: [
                  Expanded(
                    child: _myDropdownButtonFormField(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: loc.battleRevivePokemon,
                      ),
                      items: playerType == PlayerType.me ?
                        <DropdownMenuItem>[
                          for (int i = 0; i < ownParty.pokemonNum; i++)
                            PokemonDropdownMenuItem(
                              value: i+1,
                              enabled: state.isPossibleBattling(playerType, i) && ownPokemonStates[i].isFainting,
                              theme: theme,
                              pokemon: ownParty.pokemons[i]!,
                              showNetworkImage: PokeDB().getPokeAPI,
                            ),
                        ] :
                        <DropdownMenuItem>[
                          for (int i = 0; i < opponentParty.pokemonNum; i++)
                            PokemonDropdownMenuItem(
                              value: i+1,
                              enabled: state.isPossibleBattling(playerType, i) && opponentPokemonStates[i].isFainting,
                              theme: theme,
                              pokemon: opponentParty.pokemons[i]!,
                              showNetworkImage: PokeDB().getPokeAPI,
                            ),
                        ],
                      value: extraArg1[continuousCount] != 0 ? extraArg1[continuousCount] : null,
                      onChanged: (value) {
                        extraArg1[continuousCount] = value;
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
                      onFocus: onFocus,
                      isInput: isInput,
                      textValue: isInput ? null : playerType == PlayerType.me ?
                        ownParty.pokemons[extraArg1[continuousCount]-1]?.name :
                        opponentParty.pokemons[extraArg1[continuousCount]-1]?.name,
                      theme: theme,
                    ),
                  ),
                ],
              );
            default:
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _myDropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.battleSuccessFailure,
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: MoveHit.hit,
                              child: Text(loc.battleSucceeded),
                            ),
                            DropdownMenuItem(
                              value: MoveHit.notHit,
                              child: Text(MoveHit(MoveHit.notHit).displayName),
                            ),
                            DropdownMenuItem(
                              value: MoveHit.fail,
                              child: Text(MoveHit(MoveHit.fail).displayName),
                            ),
                          ],
                          value: moveHits[continuousCount].id,
                          onChanged: (value) {
                            moveHits[continuousCount] = MoveHit(value);
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                          onFocus: onFocus,
                          isInput: isInput,
                          textValue: moveHits[continuousCount].id == MoveHit.hit ? loc.battleSucceeded :
                            moveHits[continuousCount].displayName,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  effectInputPrevRow,
                  insertPrevRow ?
                  SizedBox(height: 10,) : Container(),
                  SizedBox(height: 10,),
                  effectInputRow,
                  SizedBox(height: 10,),
                  effectInputRow2,
                ],
              );
          }
        default:
          switch(replacedMove.target.id) {
            case 3:   // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _myDropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.battleHitFail,
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: false,
                              child: Text(loc.battleFailed),
                            ),
                          ],
                          value: false,
                          onChanged: null,
                          onFocus: onFocus,
                          isInput: isInput,
                          textValue: loc.battleFailed,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            default:
              return Column(
                children: [
                  effectInputPrevRow,
                  insertPrevRow ?
                  SizedBox(height: 10,) : Container(),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _myDropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.battleHitFail,
                          ),
                          items: <DropdownMenuItem>[
                            for (int index = MoveHit.hit; index <= MoveHit.fail; index++)
                            DropdownMenuItem(
                              value: index,
                              child: Text(MoveHit(index).displayName),
                            ),
                          ],
                          value: moveHits[continuousCount].id,
                          onChanged: (value) {
                            moveHits[continuousCount] = MoveHit(value);
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                          onFocus: onFocus,
                          isInput: isInput,
                          textValue: moveHits[continuousCount].displayName,
                          theme: theme,
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        flex: 5,
                        child: _myDropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.battleEffectiveness,
                          ),
                          items: <DropdownMenuItem<int>>[
                            DropdownMenuItem(
                              value: MoveEffectiveness.normal,
                              child: Text(loc.battleEffectivenessNormal, overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.great,
                              child: Text(loc.battleEffectivenessGreat, overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.notGood,
                              child: Text(loc.battleEffectivenessNotGood, overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.noEffect,
                              child: Text(loc.battleEffectivenessNoEffect, overflow: TextOverflow.ellipsis,),
                            ),
                          ],
                          value: moveEffectivenesses[continuousCount].id,
                          onChanged: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail ? (value) {
                            moveEffectivenesses[continuousCount] = MoveEffectiveness(value!);
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          } : null,
                          onFocus: onFocus,
                          isInput: isInput,
                          textValue: moveEffectivenesses[continuousCount].id == MoveEffectiveness.normal ? loc.battleEffectivenessNormal :
                            moveEffectivenesses[continuousCount].id == MoveEffectiveness.great ? loc.battleEffectivenessGreat :
                            moveEffectivenesses[continuousCount].id == MoveEffectiveness.notGood ? loc.battleEffectivenessNotGood :
                            moveEffectivenesses[continuousCount].id == MoveEffectiveness.noEffect ? loc.battleEffectivenessNoEffect : '',
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  effectInputRow,
                  SizedBox(height: 10,),
                  yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ||
                  replacedMove.isSound || myState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isNotEmpty ?
                  DamageIndicateRow(
                    playerType == PlayerType.me ? opponentPokemon : ownPokemon,
                    hpController,
                    playerType != PlayerType.me,
                    onFocus,
                    (value) {
                      if (playerType == PlayerType.me) {
                        percentDamage[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                      }
                      else {
                        realDamage[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                      }
                      appState.editingPhase[phaseIdx] = true;
                      onFocus();
                    },
                    playerType == PlayerType.me ? percentDamage[continuousCount] : realDamage[continuousCount],
                    isInput, loc: loc,
                  ) :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _myDropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: loc.battleSubstitute,
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 0,
                              child: Text(loc.battleSubstituteRemain, overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(loc.battleSubstituteBroke, overflow: TextOverflow.ellipsis,),
                            ),
                          ],
                          value: realDamage[continuousCount],
                          onChanged: (value) {
                            realDamage[continuousCount] = value;
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                          onFocus: onFocus,
                          isInput: isInput,
                          textValue: realDamage[continuousCount] == 0 ? loc.battleSubstituteRemain : loc.battleSubstituteBroke,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  effectInputRow2,
                ],
              );
          }
      }
    }

    return Container();
  }

  Widget _myTypeAheadField<T>({
    required SuggestionsCallback<T> suggestionsCallback,
    required ItemBuilder<T> itemBuilder,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    TextFieldConfiguration textFieldConfiguration = const TextFieldConfiguration(),
    SuggestionsBoxDecoration suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
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
    required void Function() onFocus,
    required bool isInput,
  })
  {
    if (isInput) {
      return TypeAheadField(
        suggestionsCallback: suggestionsCallback, itemBuilder: itemBuilder, onSuggestionSelected: onSuggestionSelected,
        textFieldConfiguration: textFieldConfiguration, suggestionsBoxDecoration: suggestionsBoxDecoration,
        debounceDuration: debounceDuration, suggestionsBoxController: suggestionsBoxController, scrollController: scrollController,
        loadingBuilder: loadingBuilder, noItemsFoundBuilder: noItemsFoundBuilder, errorBuilder: errorBuilder,
        transitionBuilder: transitionBuilder, animationStart: animationStart, animationDuration: animationDuration,
        getImmediateSuggestions: getImmediateSuggestions, suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
        direction: direction, hideOnLoading: hideOnLoading, hideOnEmpty: hideOnEmpty, hideOnError: hideOnError,
        hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide, keepSuggestionsOnLoading: keepSuggestionsOnLoading,
        keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected, autoFlipDirection: autoFlipDirection,
        autoFlipListDirection: autoFlipListDirection, hideKeyboard: hideKeyboard, minCharsForSuggestions: minCharsForSuggestions,
        onSuggestionsBoxToggle: onSuggestionsBoxToggle, hideKeyboardOnDrag: hideKeyboardOnDrag, key: key,
      );
    }
    else {
      return TextField(
        controller: textFieldConfiguration.controller,
        decoration: textFieldConfiguration.decoration,
        readOnly: true,
        onTap: onFocus,
      );
    }
  }

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
    required void Function() onFocus,
    required bool isInput,
    required String? textValue,   // isInput==falseのとき、出力する文字列として必須
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    required ThemeData theme,
  })
  {
    if (isInput) {
      return DropdownButtonFormField(
        key: key, items: items, selectedItemBuilder: selectedItemBuilder, value: value,
        hint: hint, disabledHint: disabledHint, onChanged: onChanged, onTap: onTap,
        elevation: elevation, style: style, icon: icon, iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor, iconSize: iconSize, isDense: isDense,
        isExpanded: isExpanded, itemHeight: itemHeight, focusColor: focusColor,
        focusNode: focusNode, autofocus: autofocus, dropdownColor: dropdownColor,
        decoration: decoration, onSaved: onSaved, validator: validator, autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight, enableFeedback: enableFeedback, alignment: alignment,
        borderRadius: borderRadius, padding: padding,
      );
    }
    else {
      return TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: decoration?.labelText,
          prefixIcon: prefixIconPokemon != null ? showNetworkImage ?
            Image.network(
              PokeDB().pokeBase[prefixIconPokemon.no]!.imageUrl,
              height: theme.buttonTheme.height,
              errorBuilder: (c, o, s) {
                return const Icon(Icons.catching_pokemon);
              },
            ) : const Icon(Icons.catching_pokemon) : null,
        ),
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
        onTap: onFocus,
      );
    }
  }

  Widget _myTypeDropdownButton(
    String? labelText,
    void Function(dynamic)? onChanged,
    void Function() onFocus,
    int? value,
    {
      required bool isInput,
      bool isError = false,
      bool isTeraType = false,
    }
  )
  {
    if (isInput) {
      return TypeDropdownButton(
        labelText, onChanged, value,
        isError: isError, isTeraType: isTeraType,
      );
    }
    else {
      return TextField(
        controller: TextEditingController(text: PokeType.createFromId(value ?? 0).displayName),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: labelText,
          prefixIcon: PokeType.createFromId(value ?? 0).displayIcon,
        ),
        onTap: onFocus,
        readOnly: true,
      );
    } 
  }

  // 行動が確定するなら自動で設定する。自動で設定した場合はtrueを返す
  bool fillAuto(PhaseState state) {
    var myState = state.getPokemonState(playerType, null);
    var yourState = state.getPokemonState(playerType.opposite, null);
    final pokeData = PokeDB();
    bool ret = false;
    bool isMoveChanged = false;

    // ねむり
    if (myState.ailmentsWhere((e) => e.id == Ailment.sleep && e.turns < (e.extraArg1 == 3 ? 2 : 3)).isNotEmpty) {
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
    if (myState.ailmentsWhere((e) => e.id == Ailment.taunt).isNotEmpty && getReplacedMove(move, 0, myState).damageClass.id == 1) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.taunt);
      ret = true;
    }
    // まもる系統のわざを使われた
    if (yourState.ailmentsWhere((e) => e.id == Ailment.protect).isNotEmpty && getReplacedMove(move, 0, myState).damageClass.id >= 2) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.protected);
      ret = true;
    }
    // わざの反動で動けない
    if (myState.hiddenBuffs.where((e) => e.id == BuffDebuff.recoiling).isNotEmpty) {
      isSuccess = false;
      actionFailure = ActionFailure(ActionFailure.recoil);
      ret = true;
    }
    // あばれる
    else if (myState.ailmentsWhere((e) => e.id == Ailment.thrash).isNotEmpty) {
      move = pokeData.moves[myState.ailmentsWhere((e) => e.id == Ailment.thrash).first.extraArg1]!;
      //move = getReplacedMove(suggestion, continuousCount, myState);
      //turnEffectAndStateAndGuide.guides = processMove(
      //  ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
      //  opponentPokemonState.copyWith(), state.copyWith(), 0);
      ret = true;
      isMoveChanged = true;
    }
    // 溜めがあるこうげき
    var findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.chargingMove);
    if (findIdx >= 0) {
      move = pokeData.moves[myState.hiddenBuffs[findIdx].extraArg1]!;
      ret = true;
      isMoveChanged = true;
    }

    if (isMoveChanged) {
      moveAdditionalEffects[0] = move.isSurelyEffect() ? MoveEffect(move.effect.id) : MoveEffect(0);
      moveEffectivenesses[0] = PokeType.effectiveness(
        myState.currentAbility.id == 113 || myState.currentAbility.id == 299, yourState.holdingItem?.id == 586,
        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
        move.type, yourState);
    }

    return ret;
  }

  String getEditingControllerText4(PhaseState state) {
    var pokeData = PokeDB();
    switch (move.effect.id) {
      case 84:    // ほぼすべてのわざから1つをランダムで使う
      case 98:    // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243:   // 最後に出されたわざを出す(相手のわざとは限らない)
        return pokeData.moves[extraArg3[0]]!.displayName;
      default:
        break;
    }
    return '';
  }

  // わざに対応して、args等を自動でセット
  void setAutoArgs(PhaseState state, int continuousCount) {
    var myState = state.getPokemonState(playerType, null);
    var yourState = state.getPokemonState(playerType.opposite, null);
    var opponentState = state.getPokemonState(PlayerType.opponent, null);
    
    switch (moveAdditionalEffects[continuousCount].id) {
      case 33:    // 最大HPの半分だけ回復する
      case 215:   // 使用者の最大HP1/2だけ回復する。ターン終了までひこうタイプを失う
        extraArg1[continuousCount] = -((myState.pokemon.h.real / 2).ceil());
        extraArg2[continuousCount] = -50;
        break;
      case 80:    // 場に「みがわり」を発生させる
        extraArg1[continuousCount] = (myState.pokemon.h.real / 4).floor();
        extraArg2[continuousCount] = 25;
        break;
      case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
        if (myState.isTypeContain(8)) {
          extraArg1[continuousCount] = (myState.pokemon.h.real / 2).floor();
          extraArg2[continuousCount] = 50;
        }
        break;
      case 106:   // もちものを盗む
      case 189:   // もちものを持っていれば失わせ、威力1.5倍
        if (yourState.getHoldingItem() != null && yourState.getHoldingItem()!.id != 0) {
          extraArg1[continuousCount] = yourState.getHoldingItem()!.id;
        }
        break;
      case 133:   // 使用者のHP回復。回復量は天気による
        if (state.weather.id == Weather.sunny) {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2[continuousCount] = -roundOff5(2732 / 4096);
        }
        else if (state.weather.id == Weather.rainy || state.weather.id == Weather.sandStorm ||
          state.weather.id == Weather.snowy)
        {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real / 4));
          extraArg2[continuousCount] = -25;
        }
        else {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2[continuousCount] = -50;
        }
        break;
      case 163:   // たくわえた回数が多いほど回復量が上がる。たくわえた回数を0にする
        int findIdx = myState.ailmentsIndexWhere((e) => e.id >= Ailment.stock1 && e.id <= Ailment.stock3);
        if (findIdx >= 0) {
          int t = myState.ailments(findIdx).id - Ailment.stock1;
          switch (t) {
            case 0:
              extraArg1[continuousCount] = -((myState.pokemon.h.real / 4).floor());
              extraArg2[continuousCount] = -25;
              break;
            case 1:
              extraArg1[continuousCount] = -((myState.pokemon.h.real / 2).floor());
              extraArg2[continuousCount] = -50;
              break;
            case 2:
              extraArg1[continuousCount] = -myState.pokemon.h.real;
              extraArg2[continuousCount] = -100;
              break;
            default:
              break;
          }
        }
        break;
      case 178:   // 使用者ともちものを入れ替える
        if (opponentState.getHoldingItem() != null && opponentState.getHoldingItem()!.id != 0) {
          extraArg1[continuousCount] = opponentState.getHoldingItem()!.id;
        }
        break;
      case 185:   // 戦闘中自分が最後に使用したもちものを復活させる
        // TODO
        break;
      case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
        if (yourState.getHoldingItem() != null && yourState.getHoldingItem()!.id != 0 && yourState.getHoldingItem()!.isBerry) {
          extraArg1[continuousCount] = yourState.getHoldingItem()!.id;
        }
        break;
      case 234:   // 使用者のもちものによって威力と追加効果が変わる
      case 324:   // 相手がもちものを持っていない場合、使用者が持っているもちものを渡す
        if (myState.getHoldingItem() != null && myState.getHoldingItem()!.id != 0) {
          extraArg1[continuousCount] = myState.getHoldingItem()!.id;
        }
        break;
      case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
        if (myState.getHoldingItem() != null && myState.getHoldingItem()!.id != 0 && myState.getHoldingItem()!.isBerry) {
          extraArg1[continuousCount] = myState.getHoldingItem()!.id;
        }
        break;
      case 179:   // 相手と同じとくせいになる
        if (yourState.getCurrentAbility().id != 0) {
          extraArg1[continuousCount] = yourState.getCurrentAbility().id;
        }
        break;
      case 192:   // 使用者ととくせいを入れ替える
        if (opponentState.getCurrentAbility().id != 0) {
          extraArg1[continuousCount] = opponentState.getCurrentAbility().id;
        }
        break;
      case 300:   // 相手のとくせいを使用者のとくせいと同じにする
        if (myState.currentAbility.id != 0) {
          extraArg1[continuousCount] = myState.currentAbility.id;
        }
        break;
      case 382:   // 最大HPの半分だけ回復する。天気がすなあらしの場合は2/3回復する
        if (state.weather.id == Weather.sandStorm) {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2[continuousCount] = -roundOff5(2732 / 4096);
        }
        else {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2[continuousCount] = -50;
        }
        break;
      case 387:   // 最大HPの半分だけ回復する。場がグラスフィールドの場合は2/3回復する
        if (state.field.id == Field.grassyTerrain) {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real * 2732 / 4096));
          extraArg2[continuousCount] = -roundOff5(2732 / 4096);
        }
        else {
          extraArg1[continuousCount] = -(roundOff5(myState.pokemon.h.real / 2));
          extraArg2[continuousCount] = -50;
        }
        break;
      case 441:   // 最大HP1/4だけ回復
        extraArg1[continuousCount] = -((myState.pokemon.h.real / 4).round());
        extraArg2[continuousCount] = -25;
        break;
      case 420:   // 最大HP1/2(小数点切り上げ)を削ってこうげき
        extraArg1[continuousCount] = (myState.pokemon.h.real / 2).ceil();
        extraArg2[continuousCount] = 50;
        break;
      case 433:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさがそれぞれ1段階ずつ上がる。最大HP1/3が削られる
        extraArg1[continuousCount] = (myState.pokemon.h.real / 3).floor();
        extraArg2[continuousCount] = 33;
        break;
      case 461:   // 最大HP1/4回復、状態異常を治す
        extraArg1[continuousCount] = -((myState.pokemon.h.real / 4).floor());
        extraArg2[continuousCount] = -25;
        break;
      case 492:   // 使用者の最大HP1/2(小数点以下切り上げ)を消費してみがわり作成、みがわりを引き継いで控えと交代
        extraArg1[continuousCount] = ((myState.pokemon.h.real / 2).ceil());
        extraArg2[continuousCount] = 50;
        break;
      default:
        break;
    }
  }

  Move getReplacedMove(Move move, int continuousCount, PokemonState myState) {
    var pokeData = PokeDB();
    Move ret = move;
    // わざの内容変更
    switch (move.effect.id) {
      case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
        {
          int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.copiedMove);
          if (findIdx >= 0) {
            ret = pokeData.moves[myState.hiddenBuffs[findIdx].extraArg1]!;
          }
        }
        break;
      case 84:    // ほぼすべてのわざから1つをランダムで使う
      case 98:    // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243:   // 最後に出されたわざを出す(相手のわざとは限らない)
        if (extraArg3[continuousCount] != 0) {
          ret = pokeData.moves[extraArg3[continuousCount]]!;
        }
        break;
      default:
        break;
    }

    return ret;
  }

  String getReplacedMoveName(Move move, int continuousCount, PokemonState myState) {
    var pokeData = PokeDB();
    String ret = move.displayName;
    // わざの内容変更
    switch (move.effect.id) {
      case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
        {
          int findIdx = myState.hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.copiedMove);
          if (findIdx >= 0) {
            ret = '${pokeData.moves[myState.hiddenBuffs[findIdx].extraArg1]!.displayName}(${move.displayName})';
          }
        }
        break;
      case 84:    // ほぼすべてのわざから1つをランダムで使う
      case 98:    // ねむり状態のとき、使用者が覚えているわざをランダムに使用する
      case 243:   // 最後に出されたわざを出す(相手のわざとは限らない)
        if (extraArg3[continuousCount] != 0) {
          ret = '${pokeData.moves[extraArg3[continuousCount]]!.displayName}(${move.displayName}';
        }
        break;
      default:
        break;
    }

    return ret;
  }

  PokeType getReplacedMoveType(Move move, int continuousCount, PokemonState myState, PhaseState state) {
    // わざの内容変更
    var replacedMove = getReplacedMove(move, continuousCount, myState);
    var ret = replacedMove.type;
    switch (replacedMove.effect.id) {
      //case 136:   // 個体値によってわざのタイプが変わる
      case 204:   // 天気が変わっていると威力2倍、タイプも変わる
        switch (state.weather.id) {
          case Weather.sunny:
            ret = PokeType.createFromId(10);
            break;
          case Weather.rainy:
            ret = PokeType.createFromId(11);
            break;
          case Weather.snowy:
            ret = PokeType.createFromId(15);
            break;
          case Weather.sandStorm:
            ret = PokeType.createFromId(6);
            break;
          default:
            break;
        }
        break;
      case 269:   // 持っているプレートに応じてわざのタイプが変わる
        if (myState.holdingItem != null) {
          switch (myState.holdingItem!.id) {
            case 275:   // ひのたまプレート
              ret = PokeType.createFromId(10);
              break;
            case 276:   // しずくプレート
              ret = PokeType.createFromId(11);
              break;
            case 277:   // いかずちプレート
              ret = PokeType.createFromId(13);
              break;
            case 278:   // みどりのプレート
              ret = PokeType.createFromId(12);
              break;
            case 279:   // つららのプレート
              ret = PokeType.createFromId(15);
              break;
            case 280:   // こぶしのプレート
              ret = PokeType.createFromId(2);
              break;
            case 281:   // もうどくプレート
              ret = PokeType.createFromId(4);
              break;
            case 282:   // だいちのプレート
              ret = PokeType.createFromId(5);
              break;
            case 283:   // あおぞらプレート
              ret = PokeType.createFromId(3);
              break;
            case 284:   // ふしぎのプレート
              ret = PokeType.createFromId(14);
              break;
            case 285:   // たまむしプレート
              ret = PokeType.createFromId(7);
              break;
            case 286:   // がんせきプレート
              ret = PokeType.createFromId(6);
              break;
            case 287:   // もののけプレート
              ret = PokeType.createFromId(8);
              break;
            case 288:   // りゅうのプレート
              ret = PokeType.createFromId(16);
              break;
            case 289:   // こわもてプレート
              ret = PokeType.createFromId(17);
              break;
            case 290:   // こつてつプレート
              ret = PokeType.createFromId(9);
              break;
            case 684:   // せいれいプレート
              ret = PokeType.createFromId(18);
              break;
            default:
              break;
          }
        }
        break;
      case 401:   // わざのタイプが使用者のタイプ1のタイプになる
        ret = myState.isTerastaling ? myState.teraType1 : myState.type1;
        break;
      case 437:   // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
        if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.harapekoForm).isNotEmpty) {
          ret = PokeType.createFromId(17);
        }
        break;
      case 444:   // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
                  // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
        if (myState.isTerastaling) {
          ret = myState.teraType1;
        }
        break;
      case 453:   // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
        if (myState.isGround(state.getIndiFields(playerType))) {
          switch (state.field.id) {
            case Field.electricTerrain:
              ret = PokeType.createFromId(13);
              break;
            case Field.grassyTerrain:
              ret = PokeType.createFromId(12);
              break;
            case Field.mistyTerrain:
              ret = PokeType.createFromId(18);
              break;
            case Field.psychicTerrain:
              ret = PokeType.createFromId(14);
              break;
          }
        }
        break;
      case 487:   // 対象の場のリフレクター・ひかりのかべ・オーロラベールを解除してからこうげき。ケンタロスのフォルムによってわざのタイプが変化する
        switch (myState.pokemon.no) {
          case 10250:
            ret = PokeType.createFromId(2);
            break;
          case 10251:
            ret = PokeType.createFromId(10);
            break;
          case 10252:
            ret = PokeType.createFromId(11);
            break;
        }
        break;
      default:
        break;
    }

    return ret;
  }

  // 主に確定急所の判定を行う
  MoveHit getMoveHit(Move move, int continuousCount, PokemonState myState, PokemonState yourState, List<IndividualField> yourFields) {
    MoveHit ret = MoveHit(MoveHit.hit);
    var mA = myState.currentAbility.id;
    var yA = yourState.currentAbility.id;
    // (こうげき側がとくせいを無視できず、)ぼうぎょ側がカブトアーマー/シェルアーマー/おまじない(場)ならば急所に当たらない
    if ((yourState.holdingItem?.id == 1697 || (mA != 104 && mA != 163 && mA != 164)) && (yA == 4 || yA == 75)) return ret;
    switch (move.effect.id) {
      case 289:   // かならず急所に当たる
      case 462:   // 3回連続でこうげきする。かならず急所に当たる
      case 486:   // 必中かつ必ず急所に当たる
        ret = MoveHit(MoveHit.critical);
        break;
      default:
        break;
    }
    if (yourState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty &&
        myState.buffDebuffs.where((e) => e.id == BuffDebuff.merciless).isNotEmpty
    ) {
      ret = MoveHit(MoveHit.critical);
    }

    return ret;
  }

  void clear() {
    playerType = PlayerType.none;
    type = TurnMoveType(TurnMoveType.none);
    teraType = PokeType.createFromId(0);
    move = Move(0, '', '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
    isSuccess = true;
    actionFailure = ActionFailure(0);
    moveHits = [MoveHit(MoveHit.hit)];
    moveEffectivenesses = [MoveEffectiveness(MoveEffectiveness.normal)];
    realDamage = [0];
    percentDamage = [0];
    moveAdditionalEffects = [MoveEffect(MoveEffect.none)];
    extraArg1 = [0];
    extraArg2 = [0];
    extraArg3 = [0];
    _changePokemonIndexes = [null, null];
    moveType = PokeType.createFromId(0);
    isFirst = false;
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnMove deserialize(dynamic str, String split1, String split2, {int version = -1}) {    // -1は最新バージョン
    TurnMove turnMove = TurnMove();
    final turnMoveElements = str.split(split1);
    // playerType
    turnMove.playerType = PlayerTypeNum.createFromNumber(int.parse(turnMoveElements[0]));
    // type
    turnMove.type = TurnMoveType(int.parse(turnMoveElements[1]));
    // teraType
    turnMove.teraType = PokeType.createFromId(int.parse(turnMoveElements[2]));
    // move
    if (version == 1) {
      var moveElements = turnMoveElements[3].split(split2);
      turnMove.move = Move(
        int.parse(moveElements[0]),
        moveElements[1],
        '',
        PokeType.createFromId(int.parse(moveElements[2])),
        int.parse(moveElements[3]),
        int.parse(moveElements[4]),
        int.parse(moveElements[5]),
        Target(int.parse(moveElements[6])),
        DamageClass(int.parse(moveElements[7])),
        MoveEffect(int.parse(moveElements[8])),
        int.parse(moveElements[9]),
        int.parse(moveElements[10]),
      );
    }
    else {
      turnMove.move = PokeDB().moves[int.parse(turnMoveElements[3])]!;
    }
    // isSuccess
    turnMove.isSuccess = int.parse(turnMoveElements[4]) != 0;
    // actionFailure
    turnMove.actionFailure = ActionFailure(int.parse(turnMoveElements[5]));
    // moveHits
    turnMove.moveHits.clear();
    var moveHits = turnMoveElements[6].split(split2);
    for (var moveHitsElement in moveHits) {
      if (moveHitsElement == '') break;
      turnMove.moveHits.add(MoveHit(int.parse(moveHitsElement)));
    }
    // moveEffectiveness
    var moveEffectivenesses = turnMoveElements[7].split(split2);
    turnMove.moveEffectivenesses.clear();
    for (var moveEffectivenessElement in moveEffectivenesses) {
      if (moveEffectivenessElement == '') break;
      turnMove.moveEffectivenesses.add(MoveEffectiveness(int.parse(moveEffectivenessElement)));
    }
    // realDamage
    var realDamages = turnMoveElements[8].split(split2);
    turnMove.realDamage.clear();
    for (var realDamage in realDamages) {
      if (realDamage == '') break;
      turnMove.realDamage.add(int.parse(realDamage));
    }
    // percentDamage
    var percentDamages = turnMoveElements[9].split(split2);
    turnMove.percentDamage.clear();
    for (var percentDamage in percentDamages) {
      if (percentDamage == '') break;
      turnMove.percentDamage.add(int.parse(percentDamage));
    }
    // moveAdditionalEffect
    var moveAdditionalEffects = turnMoveElements[10].split(split2);
    turnMove.moveAdditionalEffects.clear();
    for (var moveAdditionalEffect in moveAdditionalEffects) {
      if (moveAdditionalEffect == '') break;
      turnMove.moveAdditionalEffects.add(MoveEffect(int.parse(moveAdditionalEffect)));
    }
    // extraArg1
    var extraArg1s = turnMoveElements[11].split(split2);
    turnMove.extraArg1.clear();
    for (var e in extraArg1s) {
      if (e == '') break;
      turnMove.extraArg1.add(int.parse(e));
    }
    // extraArg2
    var extraArg2s = turnMoveElements[12].split(split2);
    turnMove.extraArg2.clear();
    for (var e in extraArg2s) {
      if (e == '') break;
      turnMove.extraArg2.add(int.parse(e));
    }
    // extraArg3
    var extraArg3s = turnMoveElements[13].split(split2);
    turnMove.extraArg3.clear();
    for (var e in extraArg3s) {
      if (e == '') break;
      turnMove.extraArg3.add(int.parse(e));
    }
    // _changePokemonIndexes
    var changePokemonIndexes = turnMoveElements[14].split(split2);
    for (int i = 0; i < 2; i++) {
      if (changePokemonIndexes[i] == '') {
        turnMove._changePokemonIndexes[i] = null;
      }
      else {
        turnMove._changePokemonIndexes[i] = int.parse(changePokemonIndexes[i]);
      }
    }
    // moveType
    turnMove.moveType = PokeType.createFromId(int.parse(turnMoveElements[15]));
    // isFirst
    turnMove.isFirst = int.parse(turnMoveElements[16]) != 0;

    return turnMove;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    // playerType
    ret += playerType.number.toString();
    ret += split1;
    // type
    ret += type.id.toString();
    ret += split1;
    // teraType
    ret += teraType.id.toString();
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
    ret += actionFailure.id.toString();
    ret += split1;
    // moveHits
    for (final moveHit in moveHits) {
      ret += moveHit.id.toString();
      ret += split2;
    }
    ret += split1;
    // moveEffectivenesses
    for (final moveEffectiveness in moveEffectivenesses) {
      ret += moveEffectiveness.id.toString();
      ret += split2;
    }
    ret += split1;
    // realDamage
    for (final damage in realDamage) {
      ret += damage.toString();
      ret += split2;
    }
    ret += split1;
    // percentDamage
    for (final damage in percentDamage) {
      ret += damage.toString();
      ret += split2;
    }
    ret += split1;
    // moveAdditionalEffects
    for (final moveAdditionalEffect in moveAdditionalEffects) {
      ret += moveAdditionalEffect.id.toString();
      ret += split2;
    }
    ret += split1;
    // extraArg1
    for (final arg in extraArg1) {
      ret += arg.toString();
      ret += split2;
    }
    ret += split1;
    // extraArg2
    for (final arg in extraArg2) {
      ret += arg.toString();
      ret += split2;
    }
    ret += split1;
    // extraArg3
    for (final arg in extraArg3) {
      ret += arg.toString();
      ret += split2;
    }
    ret += split1;
    // _changePokemonIndex
    for (int i = 0; i < 2; i++) {
      if (_changePokemonIndexes[i] != null) ret += _changePokemonIndexes[i].toString();
      ret += split2;
    }
    ret += split1;
    // moveType
    ret += moveType.id.toString();
    ret += split1;
    // isFirst
    ret += isFirst ? '1' : '0';

    return ret;
  }

  bool isValid() {
    if (!isSuccess) {
      return playerType != PlayerType.none && actionFailure.id != 0;
    }
    switch (type.id) {
      case TurnMoveType.move:
        return
        playerType != PlayerType.none &&
        move.id != 0;
      case TurnMoveType.change:
        return getChangePokemonIndex(playerType) != null;
      case TurnMoveType.surrender:
        return true;
      default:
        return false;
    }
  }
}