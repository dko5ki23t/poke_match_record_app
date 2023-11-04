import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
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
  // TODO:多い(まだ他にもある)から、何か情報が得られるものに限定したい
  static const int none = 0;
  static const int recoil = 1;        // わざの反動
  static const int sleep = 2;         // ねむり(カウント消費)
  static const int freeze = 3;        // こおり(回復判定で失敗)
  static const int pp = 4;            // PPが残っていない
  static const int lazy = 5;          // なまけ(カウント消費(反動で動けなくても消費はする))
  static const int focusPunch = 6;    // きあいパンチ使用時、そのターンにダメージを受けていて動けない
  static const int flinch = 7;        // ひるみ
  static const int disable = 8;       // かなしばり
  static const int gravity = 9;       // じゅうりょく
  static const int healBlock = 10;    // かいふくふうじ
  static const int throatChop = 11;   // じごくづき
  static const int choice = 12;       // こだわり
  static const int taunt = 13;        // ちょうはつ
  static const int imprison = 14;     // ふういん
  static const int confusion = 15;    // こんらんにより自傷
  static const int paralysis = 16;    // まひ
  static const int infatuation = 17;  // メロメロ
  static const int other = 18;        // その他
  static const int size = 19;

  static const _displayNameMap = {
    0: '',
    1: 'わざの反動',
    2: 'ねむり',
    3: 'こおり',
    4: 'PPが残っていない',
    5: 'なまけ',
    6: 'きあいパンチ中にダメージを受けた',
    7: 'ひるみ',
    8: 'かなしばり',
    9: 'じゅうりょく',
    10: 'かいふくふうじ',
    11: 'じごくづき',
    12: 'こだわり中以外のわざを使った',
    13: 'ちょうはつ',
    14: 'ふういん',
    15: 'こんらん',
    16: 'まひ',
    17: 'メロメロ',
    18: 'その他',
  };

  String get displayName => _displayNameMap[id]!;

  const ActionFailure(this.id);

  final int id;
}

class TurnMove {
  PlayerType playerType = PlayerType(PlayerType.none);
  TurnMoveType type = TurnMoveType(TurnMoveType.none);
  PokeType teraType = PokeType.createFromId(0);   // テラスタルなし
  Move move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
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
    ..moveType = moveType;

  int? getChangePokemonIndex(PlayerType player) {
    if (player.id == PlayerType.me) return _changePokemonIndexes[0];
    return _changePokemonIndexes[1];
  }

  void setChangePokemonIndex(PlayerType player, int? val) {
    if (player.id == PlayerType.me) {
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
  static const Map<int, String> moveEffectText = {
    //2: 'ねむってしまった',
    3: 'どくにかかった',
    5: 'やけどをおった',
    6: 'こおってしまった',
    7: 'しびれてしまった',
    32: 'ひるんで技がだせない',
    //50: 'こんらんした',
    69: 'こうげきが下がった',
    70: 'ぼうぎょが下がった',
    71: 'すばやさが下がった',
    72: 'とくこうが下がった',
    73: 'とくぼうが下がった',
    74: '命中率が下がった',
    76: 'ひるんで技がだせない',
    77: 'こんらんした',
    78: 'どくにかかった',
    93: 'ひるんで技がだせない',
    126: 'やけどをおった',
    139: 'ぼうぎょが上がった',
    140: 'こうげきが上がった',
    141: 'こうげき・ぼうぎょ・とくこう・とくぼう・すばやさがあがった',
    147: 'ひるんで技がだせない',
    151: 'ひるんで技がだせない',
    153: 'しびれてしまった',
    201: 'やけどをおった',
    203: 'もうどくにかかった',
    210: 'どくにかかった',
    254: 'やけどをおった',
    261: 'こおってしまった',
    263: 'しびれてしまった',
    264: 'しびれてしまった',
    268: 'こんらんした',
    272: 'とくぼうががくっと下がった',
    274: 'やけどをおった',
    275: 'こおってしまった',
    276: 'しびれてしまった',
    277: 'とくこうが上がった',
    330: 'ねむってしまった',
    332: 'しびれてしまった',
    333: 'やけどをおった',
    334: 'こんらんした',
    359: 'ぼうぎょがぐーんと上がった',
    372: 'しびれてしまった',
    380: 'こおってしまった',
    449: 'どくにかかった',
    460: 'やけどをおった',
    466: 'どくにかかった',
    468: 'ぼうぎょが下がった',
    469: 'やけどをおった',
    470: 'すばやさが下がった',
    471: 'しびれてしまった',
    472: 'やけどをおった',
    475: 'こんらんした',
    484: 'どくにかかった',
    499: 'ねむってしまった',
    500: 'やけどをおった',
  };

  static const Map<int, String> moveEffectText2 = {
    274: 'ひるんで技がだせない',
    275: 'ひるんで技がだせない',
    276: 'ひるんで技がだせない',
    468: 'ひるんで技がだせない',
  };

  List<String> processMove(
    Party ownParty,
    Party opponentParty,
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    PhaseState state,
    int continuousCount,
  )
  {
    final pokeData = PokeDB();
    List<String> ret = [];
    if (playerType.id == PlayerType.none) return ret;

    var myState = playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;

    // みちづれ状態解除
    myState.ailmentsRemoveWhere((e) => e.id == Ailment.destinyBond);

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
      myState.teraType ??= teraType;
      if (playerType.id == PlayerType.me) {
        state.hasOwnTerastal = true;
      }
      else {
        state.hasOpponentTerastal = true;
      }
    }

    // ポケモン交代
    if (type.id == TurnMoveType.change) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      myState.processExitEffect(true, yourState);
      state.setPokemonIndex(playerType, getChangePokemonIndex(playerType)!);
      state.getPokemonState(playerType, null).processEnterEffect(true, state, yourState);
      return ret;
    }

    if (move.id == 0) return ret;
    if (!isSuccess) return ret;

    List<IndividualField> myFields = playerType.id == PlayerType.me ? state.ownFields : state.opponentFields;
    List<IndividualField> yourFields = playerType.id == PlayerType.me ? state.opponentFields : state.ownFields;
    int myPlayerTypeID = playerType.id;
    int yourPlayerTypeID = playerType.id == PlayerType.me ? PlayerType.opponent : PlayerType.me;

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
    // 相手のランク補正を無視してダメージ計算するか
    bool ignoreTargetRank = false;
    // 相手のとくせいを無視してダメージ計算するか
    bool ignoreAbility = false;
    // こうげきの代わりにぼうぎょの数値とランク補正を使ってダメージ計算するか
    bool defenseAltAttack = false;
    // ダメージ計算をぶつりわざ/とくしゅわざのどちらとして行うか
    int moveDamageClassID = 0;
    // はれによるダメージ補正率が0.5倍→1.5倍
    bool isSunny1_5 = false;

    {
      Move replacedMove = getReplacedMove(move, continuousCount, myState);   // 必要に応じてわざの内容変更
      moveDamageClassID = replacedMove.damageClass.id;

      // わざの対象決定
      List<PokemonState> targetStates = [yourState];
      List<List<IndividualField>> targetIndiFields = [yourFields];
      List<int> targetPlayerTypeIDs = [yourPlayerTypeID];
      PhaseState? targetField;
      switch (replacedMove.target.id) {
        case 1:     // TODO:不定、わざによって異なる のろいとかカウンターとか
          // TODO
          break;
        case 2:     // 選択した自分以外の場にいるポケモン
                    // (現状、さきどりとダイマックスわざのみ。SVで使用不可のため考慮しなくて良さそう)
        case 3:     // 味方(現状のわざはすべて、シングルバトルでは対象がいないため失敗する)
          targetStates = [];
          targetIndiFields = [];
          targetPlayerTypeIDs = [];
          break;
        case 4:     // 使用者の場
        case 7:     // 使用者自身
        case 5:     // 使用者もしくは味方
        case 13:    // 使用者と味方
        case 15:    // すべての味方
          targetStates = [myState];
          targetIndiFields = [myFields];
          targetPlayerTypeIDs = [myPlayerTypeID];
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
          targetPlayerTypeIDs = [myPlayerTypeID, yourPlayerTypeID];
          targetField = state;
          break;
        case 14:    // 場にいるすべてのポケモン
          targetStates.add(myState);
          targetIndiFields.add(myFields);
          targetPlayerTypeIDs.add(myPlayerTypeID);
          break;
        case 16:    // ひんしの(味方)ポケモン
          targetStates.clear();
          targetIndiFields.clear();
          targetPlayerTypeIDs.clear();  // 使わない
          for (int i = 0; i < state.getPokemonStates(playerType).length; i++) {
            if (i != state.getPokemonIndex(playerType, null)-1 && state.getPokemonStates(playerType)[i].isFainting) {
              targetStates.add(state.getPokemonStates(playerType)[i]);
              targetIndiFields.add(myFields);
              targetPlayerTypeIDs.add(myPlayerTypeID);
            }
          }
          break;
        default:
          break;
      }

      // ダメージ計算式を表示するかどうか
      showDamageCalc = false;
      // ダメージ計算式が特殊か(固定ダメージ等)
      // わざの威力(わざによっては変動するため)
      movePower = replacedMove.power;
      // わざのタイプ(わざによっては変動するため)
      moveType = replacedMove.type;
      // ダメージ計算式文字列
      damageCalc = null;

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
      for (int i = 0; i < targetStates.length; i++) {
        var targetState = targetStates[i];
        var targetIndiField = targetIndiFields[i];
        var targetPlayerTypeID = targetPlayerTypeIDs[i];
        bool isSubstitute = targetState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isNotEmpty;
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
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            break;
          case 20:    // ぼうぎょを1段階下げる
          case 70:    // ぼうぎょを1段階下げる(確率)
          case 397:   // ぼうぎょを1段階下げる
            targetState.addStatChanges(targetState == myState, 1, -1, myState, moveId: replacedMove.id);
            break;
          case 21:    // すばやさを1段階下げる
          case 71:    // すばやさを1段階下げる(確率)
          case 331:   // すばやさを1段階下げる
          case 470:   // すばやさを1段階下げる(確率)。天気があめの時は必中
            targetState.addStatChanges(targetState == myState, 4, -1, myState, moveId: replacedMove.id);
            break;
          case 24:    // めいちゅうを1段階下げる
          case 74:    // めいちゅうを1段階下げる(確率)
            targetState.addStatChanges(targetState == myState, 5, -1, myState, moveId: replacedMove.id);
            break;
          case 25:    // かいひを1段階下げる
            targetState.addStatChanges(targetState == myState, 6, -1, myState, moveId: replacedMove.id);
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
            if (getChangePokemonIndex(PlayerType(targetPlayerTypeID)) != null) {
              targetState.processExitEffect(targetPlayerTypeID == PlayerType.me, myState);
              PokemonState newState;
              state.setPokemonIndex(playerType.opposite, getChangePokemonIndex(PlayerType(targetPlayerTypeID))!);
              newState = state.getPokemonState(playerType.opposite, null);
              newState.processEnterEffect(targetPlayerTypeID == PlayerType.me, state, myState);
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
            if (findIdx < 0) targetIndiField.add(IndividualField(IndividualField.lightScreen));
            break;
          case 37:    // やけど・こおり・まひのいずれかにする(確率)
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(extraArg1[continuousCount]), state);
            }
            break;
          case 38:    // 使用者はHP満タン・状態異常を回復して2ターン眠る
            int findIdx = myState.ailmentsIndexWhere((e) => e.id <= Ailment.sleep);
            if (findIdx >= 0) myState.ailmentsRemoveAt(findIdx);
            if (myPlayerTypeID == PlayerType.me) {
              myState.remainHP = myState.pokemon.h.real;
            }
            else {
              myState.remainHPPercent = 100;
            }
            targetState.ailmentsAdd(Ailment(Ailment.sleep), state);
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
              if (targetPlayerTypeID == PlayerType.me) {
                damage = (targetState.remainHP / 2).floor();
                if (damage == 0) damage = 1;
                damageCalc = 'ダメージ計算：$damage(固定ダメージ) = $damage';
              }
              else {
                damage = (targetState.remainHPPercent / 2).floor();
                damageCalc = 'ダメージ計算：$damage%(固定ダメージ) = $damage%';
              }
            }
            break;
          case 42:    // 40の固定ダメージ
            damageCalc = 'ダメージ計算：40(固定ダメージ) = 40';
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
            // TODO
            break;
          case 59:    // こうげきを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState, moveId: replacedMove.id);
            break;
          case 60:    // ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 1, -2, myState, moveId: replacedMove.id);
            break;
          case 61:    // すばやさを2段階下げる
            targetState.addStatChanges(targetState == myState, 4, -2, myState, moveId: replacedMove.id);
            break;
          case 62:    // とくこうを2段階下げる
            targetState.addStatChanges(targetState == myState, 2, -2, myState, moveId: replacedMove.id);
            break;
          case 63:    // とくぼうを2段階下げる
          case 272:   // とくぼうを2段階下げる(確率)
          case 297:   // とくぼうを2段階下げる
            targetState.addStatChanges(targetState == myState, 3, -2, myState, moveId: replacedMove.id);
            break;
          case 66:    // 場に「リフレクター」を発生させる
            int findIdx = targetIndiField.indexWhere((e) => e.id == IndividualField.reflector);
            if (findIdx < 0) targetIndiField.add(IndividualField(IndividualField.reflector));
            break;
          case 72:    // とくこうを1段階下げる(確率)
          case 358:   // とくこうを1段階下げる
            targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: replacedMove.id);
            break;
          case 73:    // とくぼうを1段階下げる(確率)
          case 440:   // とくぼうを1段階下げる
            targetState.addStatChanges(targetState == myState, 3, -1, myState, moveId: replacedMove.id);
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
            damageCalc = 'ダメージ計算：${myState.pokemon.level}(わざ使用者レベル) = ${myState.pokemon.level}';
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
              if (myPlayerTypeID == PlayerType.me) {
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
              // もちもの確定
              if (myPlayerTypeID == PlayerType.me &&
                  opponentPokemonState.holdingItem?.id == 0
              ) {
                ret.add('もちものを${pokeData.items[extraArg1[continuousCount]]!.displayName}で確定しました。');
              }
              myState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
              targetState.holdingItem = null;
            }
            break;
          case 107:   // にげられない状態にする
          case 374:   // にげられない状態にする
          case 385:   // にげられない状態にする
            if (!targetState.isTypeContain(8)) {
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
            }
            break;
          case 108:   // あくむ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.nightmare), state);
            break;
          case 109:   // 使用者のかいひを2段階上げる。ちいさくなる状態になる
            myState.addStatChanges(true, 6, 2, targetState, moveId: replacedMove.id);
            myState.ailmentsAdd(Ailment(Ailment.minimize), state);
            break;
          case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
            if (myState.isTypeContain(8)) {
              myState.remainHP -= extraArg1[continuousCount];
              myState.remainHPPercent -= extraArg2[continuousCount];
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
            targetField!.weather = Weather(Weather.sandStorm);
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
            targetState.addStatChanges(targetState == myState, 0, 2, myState, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 120:   // 当てるたびに威力が2倍ずつ増える。最大160
            if (myState.lastMove?.id == replacedMove.id) {
              movePower *= 2;
            }
            if (movePower > 160) movePower = 160;
            break;
          case 121:   // 性別が異なる場合、メロメロ状態にする
            if (myState.pokemon.sex != Sex.none && targetState.pokemon.sex != Sex.none && myState.pokemon.sex != targetState.pokemon.sex) {
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
            if (getChangePokemonIndex(PlayerType(myPlayerTypeID)) != null) {
              List<int> statChanges = List.generate(7, (i) => myState.statChanges(i));
              var takeOverAilments = myState.ailmentsWhere((e) => e.id == Ailment.confusion ||
                e.id == Ailment.leechSeed || e.id == Ailment.curse || e.id == Ailment.perishSong ||
                e.id == Ailment.ingrain || e.id == Ailment.healBlock || e.id == Ailment.embargo ||
                e.id == Ailment.magnetRise || e.id == Ailment.telekinesis || e.id == Ailment.abilityNoEffect ||
                e.id == Ailment.aquaRing || e.id == Ailment.powerTrick
              );
              var takeOverBuffDebuffs = myState.buffDebuffs.where((e) => e.id == BuffDebuff.vital1 ||
                e.id == BuffDebuff.vital2 || e.id == BuffDebuff.vital3 || e.id == BuffDebuff.substitute
              );
              myState.processExitEffect(myPlayerTypeID == PlayerType.me, yourState);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(PlayerType(myPlayerTypeID))!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerTypeID == PlayerType.me, state, yourState);
              for (int i = 0; i < 7; i++) {
                newState.forceSetStatChanges(i, statChanges[i]);
              }
              for (var e in takeOverAilments) {
                newState.ailmentsAdd(e, state);
              }
              newState.buffDebuffs.addAll(takeOverBuffDebuffs);
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
            damageCalc = 'ダメージ計算：20(固定ダメージ) = 20';
            break;
          case 136:   // 個体値によってわざのタイプが変わる
            if (extraArg1[continuousCount] != 0) {
              moveType = PokeType.createFromId(extraArg1[continuousCount]);
            }
            break;
          case 137:   // 天気を雨にする
            targetField!.weather = Weather(Weather.rainy);
            break;
          case 138:   // 天気をはれにする
            targetField!.weather = Weather(Weather.sunny);
            break;
          case 141:   // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・すばやさを1段階上げる(確率)
            myState.addStatChanges(true, 0, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 1, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 2, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, 1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 143:   // 使用者は最大HPの1/2だけHPが減る。こうげきランクが最大まで上がる
            if (myPlayerTypeID == PlayerType.me) {
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
            if (getChangePokemonIndex(PlayerType(myPlayerTypeID)) != null) {
              myState.processExitEffect(myPlayerTypeID == PlayerType.me, yourState);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(PlayerType(myPlayerTypeID))!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerTypeID == PlayerType.me, state, yourState);
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
            break;
          case 166:   // いちゃもん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.torment), state);
            break;
          case 167:   // とくこうを1段階上げ、こんらん状態にする
            targetState.addStatChanges(targetState == myState, 2, 1, myState, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            break;
          case 169:   // 使用者はひんしになる。相手のこうげき・とくこうを2段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -2, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -2, myState, moveId: replacedMove.id);
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
            targetState.ailmentsAdd(Ailment(Ailment.helpHand), state);
            break;
          case 178:   // 使用者ともちものを入れ替える
            opponentPokemonState.holdingItem = ownPokemonState.holdingItem;
            if (extraArg1[continuousCount] > 0) {
              ownPokemonState.holdingItem = pokeData.items[extraArg1[continuousCount]]!;
            }
            else {
              ownPokemonState.holdingItem = null;
            }
            break;
          case 179:   // 相手と同じとくせいになる
            if (extraArg1[continuousCount] != 0) {
              myState.currentAbility = pokeData.abilities[extraArg1[continuousCount]]!;
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
            // TODOもちもの確定
            targetState.holdingItem = null;
            movePower *= 2;
            break;
          case 190:   // 相手の残りHP-使用者の残りHP(負数なら失敗)分の固定ダメージを与える
            showDamageCalc = false;
            break;
          case 191:   // 威力=150×使用者の残りHP/最大HP
            if (myPlayerTypeID == PlayerType.me) {
              movePower = (150 * myState.remainHP / myState.pokemon.h.real).floor();
            }
            else {
              movePower = (150 * myState.remainHPPercent / 100).floor();
            }
            if (movePower == 0) movePower = 1;
            break;
          case 192:   // 使用者ととくせいを入れ替える
            opponentPokemonState.currentAbility = ownPokemonState.currentAbility;
            if (extraArg1[continuousCount] != 0) {
              ownPokemonState.currentAbility = pokeData.abilities[extraArg1[continuousCount]]!;
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
            int weight = pokeData.pokeBase[targetState.pokemon.no]!.weight;
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
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -1, myState, moveId: replacedMove.id);
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
            if (myState.teraType == null && myState.type1.id == 3) {
              myState.type1 = PokeType.createFromId(0);
              lostFly = 1;
            }
            else if (myState.teraType == null && myState.type2?.id == 3) {
              myState.type2 = null;
              lostFly = 2;
            }
            myState.ailmentsAdd(Ailment(Ailment.roost)..extraArg1 = lostFly, state);
            break;
          case 216:   // 場をじゅうりょく状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.gravity).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.gravity));
            }
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
            if (targetPlayerTypeID == PlayerType.me && targetState.remainHP <= (targetState.pokemon.h.real / 2).floor()) {
              movePower *= 2;
            }
            else if (targetPlayerTypeID == PlayerType.opponent && targetState.remainHPPercent <= 50) {
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
                usingItem.id, PlayerType(myPlayerTypeID),
                myState, targetState,
                state, extraArg2[continuousCount], 0, getChangePokemonIndex(PlayerType(myPlayerTypeID)));
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
            //TODO
            showDamageCalc = false;
            break;
          case 230:   // 使用者のぼうぎょ・とくぼうを1段階ずつ下げる
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 3, -1, targetState, moveId: replacedMove.id);
            break;
          case 231:   // 相手がそのターン既に行動していると威力2倍
            //TODO
            showDamageCalc = false;
            break;
          case 232:   // 相手がそのターン既にダメージを受けていると威力2倍
            //TODO
            showDamageCalc = false;
            break;
          case 233:   // さしおさえ状態にする
            targetState.ailmentsAdd(Ailment(Ailment.embargo), state);
            break;
          case 234:   // 使用者のもちものによって威力と追加効果が変わる
            if (extraArg1[continuousCount] != 0) {
              var flingItem = pokeData.items[extraArg1[continuousCount]]!;
              movePower = flingItem.flingPower;
              flingItem.processFlingEffect(playerType, myState, yourState, state, extraArg2[continuousCount], 0, getChangePokemonIndex(PlayerType(myPlayerTypeID)));
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
            targetState.ailmentsAdd(Ailment(Ailment.healBlock), state);
            break;
          case 238:   // 相手の残りHPが多いほど威力が高くなる(120×相手の残りHP/相手の最大HP)
            if (targetPlayerTypeID == PlayerType.me) {
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
            // TODO 入力するわざのデフォルトサジェストを変更したい
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
            targetState.currentAbility = pokeData.abilities[15]!;
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
            if (myPlayerTypeID == PlayerType.me) {
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
            break;
          case 259:   // かいひを1段階下げる。相手のひかりのかべ・リフレクター・オーロラベール・しんぴのまもり・しろいきりを消す
                      // 使用者・相手の場にあるまきびし・どくびし・とがった岩・ねばねばネットを取り除く。フィールドを解除する
            targetState.addStatChanges(targetState == myState, 6, -1, myState, moveId: replacedMove.id);
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
            if (myPlayerTypeID == PlayerType.me) {
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
            if (myState.pokemon.sex != Sex.none && targetState.pokemon.sex != Sex.none && myState.pokemon.sex != targetState.pokemon.sex) {
              targetState.addStatChanges(targetState == myState, 2, -2, myState, moveId: replacedMove.id);
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
            // TODOこうかばつぐんとかの情報から、相手のもちものわからない？
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
              int maxAvg = ((myState.maxStats[StatIndex.B.index].real + targetState.maxStats[StatIndex.B.index].real) / 2).floor();
              int minAvg = ((myState.minStats[StatIndex.B.index].real + targetState.minStats[StatIndex.B.index].real) / 2).floor();
              myState.maxStats[StatIndex.B.index].real = maxAvg;
              myState.minStats[StatIndex.B.index].real = minAvg;
              targetState.maxStats[StatIndex.B.index].real = maxAvg;
              targetState.minStats[StatIndex.B.index].real = minAvg;
              maxAvg = ((myState.maxStats[StatIndex.D.index].real + targetState.maxStats[StatIndex.D.index].real) / 2).floor();
              minAvg = ((myState.minStats[StatIndex.D.index].real + targetState.minStats[StatIndex.D.index].real) / 2).floor();
              myState.maxStats[StatIndex.D.index].real = maxAvg;
              myState.minStats[StatIndex.D.index].real = minAvg;
              targetState.maxStats[StatIndex.D.index].real = maxAvg;
              targetState.minStats[StatIndex.D.index].real = minAvg;
            }
            break;
          case 281:   // 相手と使用者のこうげき・とくこうをそれぞれ平均値にする
            {
              int maxAvg = ((myState.maxStats[StatIndex.A.index].real + targetState.maxStats[StatIndex.A.index].real) / 2).floor();
              int minAvg = ((myState.minStats[StatIndex.A.index].real + targetState.minStats[StatIndex.A.index].real) / 2).floor();
              myState.maxStats[StatIndex.A.index].real = maxAvg;
              myState.minStats[StatIndex.A.index].real = minAvg;
              targetState.maxStats[StatIndex.A.index].real = maxAvg;
              targetState.minStats[StatIndex.A.index].real = minAvg;
              maxAvg = ((myState.maxStats[StatIndex.C.index].real + targetState.maxStats[StatIndex.C.index].real) / 2).floor();
              minAvg = ((myState.minStats[StatIndex.C.index].real + targetState.minStats[StatIndex.C.index].real) / 2).floor();
              myState.maxStats[StatIndex.C.index].real = maxAvg;
              myState.minStats[StatIndex.C.index].real = minAvg;
              targetState.maxStats[StatIndex.C.index].real = maxAvg;
              targetState.minStats[StatIndex.C.index].real = minAvg;
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
              targetIndiField.add(IndividualField(IndividualField.magicRoom));
            }
            else {
              targetIndiField.removeAt(findIdx);
            }
            break;
          case 288:   // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
          case 373:   // 相手をうちおとす状態にして地面に落とす。そらをとぶ状態の相手にも当たる
            targetState.ailmentsAdd(Ailment(Ailment.antiAir), state);
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
              int myWeight = pokeData.pokeBase[myState.pokemon.no]!.weight;
              int targetWeight = pokeData.pokeBase[targetState.pokemon.no]!.weight;
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
            if (targetState.teraType == null) {
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
            targetState.currentAbility = pokeData.abilities[86]!;
            break;
          case 300:   // 相手のとくせいを使用者のとくせいと同じにする
            if (extraArg1[continuousCount] != 0) {
              targetState.currentAbility = pokeData.abilities[extraArg1[continuousCount]]!;
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
            if (targetState.teraType != null) {
              myState.type1 = targetState.teraType!;
            }
            else {
              myState.type1 = targetState.type1;
              myState.type2 = targetState.type2;
            }
            break;
          case 320:   // 味方がひんしになった次のターンに使った場合威力2倍
            showDamageCalc = false;
            break;
          case 321:   // 使用者の残りHP分の固定ダメージを与える。使用者はひんしになる
            if (myPlayerTypeID == PlayerType.me) {
              damageCalc = 'ダメージ計算：${myState.remainHP}(固定ダメージ) = ${myState.remainHP}';
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
              }
              else {
                myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.voiceForm);
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
            //TODO
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
            if ((targetPlayerTypeID == PlayerType.me && targetState.remainHP - realDamage[continuousCount] <= 0) ||
                (targetPlayerTypeID == PlayerType.opponent && targetState.remainHPPercent - percentDamage[continuousCount] <= 0)) {
              myState.addStatChanges(true, 0, 3, targetState, moveId: replacedMove.id);
            }
            break;
          case 343:   // 相手のタイプにゴーストを追加する
            //TODO
            break;
          case 344:   // こうげき・とくこうを1段階ずつ下げる
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: replacedMove.id);
            break;
          case 345:   // 場をプラズマシャワー状態にする
            if (targetIndiField.where((e) => e.id == IndividualField.ionDeluge).isEmpty) {
              targetIndiField.add(IndividualField(IndividualField.ionDeluge));
            }
            break;
          case 347:   // こうげき・とくこうを1段階ずつ下げる。控えのポケモンと交代する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: replacedMove.id);
            if (getChangePokemonIndex(PlayerType(myPlayerTypeID)) != null) {
              myState.processExitEffect(myPlayerTypeID == PlayerType.me, yourState);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(PlayerType(myPlayerTypeID))!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerTypeID == PlayerType.me, state, yourState);
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
            targetField!.field = Field(Field.grassyTerrain);
            break;
          case 353:   // 場をミストフィールドにする
            targetField!.field = Field(Field.mistyTerrain);
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
            //TODO
            int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bladeForm);
            if (findIdx >= 0) {
              myState.buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.shieldForm);
            }
            break;
          case 357:   // こうげきを1段階下げる。まもる・みがわり状態を無視する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            break;
          case 360:   // 必中。まもる系統の状態を除外してこうげきする。みがわり状態を無視する
            break;
          case 362:   // そのターンに受けるわざを無効化し、直接攻撃を使用した相手のHPを最大HP1/8分減らす
            //TODO
            break;
          case 363:   // とくぼうを1段階上げる
            targetState.addStatChanges(targetState == myState, 3, 1, myState, moveId: replacedMove.id);
            break;
          case 364:   // こうげき・とくこう・すばやさを1段階下げる。相手がどく/もうどく状態でないと失敗する
            if (targetState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {
              targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 4, -1, myState, moveId: replacedMove.id);
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
              targetState.addStatChanges(targetState == myState, 1, 1, myState, moveId: replacedMove.id);
              targetState.addStatChanges(targetState == myState, 3, 1, myState, moveId: replacedMove.id);
            }
            break;
          case 368:   // トレーナー戦後にもらえる賞金が2倍になる
            break;
          case 369:   // 場をエレキフィールドにする
            targetField!.field = Field(Field.electricTerrain);
            break;
          case 376:   // 相手のタイプにくさを追加する
            //TODO
            break;
          case 378:   // ふんじん状態にする
            targetState.ailmentsAdd(Ailment(Ailment.powder), state);
            break;
          case 380:   // こおりにする(確率)。みずタイプのポケモンに対しても効果ばつぐんとなる
            targetState.ailmentsAdd(Ailment(Ailment.freeze), state);
            break;
          case 384:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手をどく状態にする
            //TODO
            break;
          case 386:   // やけど状態を治す
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.burn);
            break;
          case 388:   // 相手のこうげきを1段階下げ、下げる前のこうげき実数値と同じ値だけ使用者のHPを回復する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            // TODO 相手のこうげき実数値が確定する場合あり
            break;
          case 389:   // 相手をちゅうもくのまと状態にする
            targetState.ailmentsAdd(Ailment(Ailment.attention), state);
            break;
          case 390:   // 相手のすばやさを1段階下げ、どく状態する
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
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
            targetField!.field = Field(Field.psychicTerrain);
            break;
          case 398:   // 使用者がほのおタイプでないと失敗する。成功するとほのおタイプを失う。こおり状態を治す
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            if (myState.teraType == null) {
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
            int tmpMax = myState.maxStats[StatIndex.S.index].real;
            int tmpMin = myState.minStats[StatIndex.S.index].real;
            myState.maxStats[StatIndex.S.index].real = targetState.maxStats[StatIndex.S.index].real;
            myState.minStats[StatIndex.S.index].real = targetState.minStats[StatIndex.S.index].real;
            targetState.maxStats[StatIndex.S.index].real = tmpMax;
            targetState.minStats[StatIndex.S.index].real = tmpMin;
            break;
          case 400:   // 相手の状態異常を治し、使用者のHPを最大HP半分だけ回復する(SV使用不可のため処理なし)
            break;
          case 401:   // わざのタイプが使用者のタイプ1のタイプになる
            moveType = myState.teraType != null ? myState.teraType! : myState.type1;
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
                myFields.add(IndividualField(IndividualField.auroraVeil));
              }
            }
            break;
          case 408:   // このターンでこのわざを使用する前に物理技を受けた場合のみこうげき可能
            break;
          case 409:   // 使用者が前のターンで動けなかった/使用したわざが失敗したとき威力2倍
            showDamageCalc = false;
            // TODO?
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
            targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: replacedMove.id);
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
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
            }
            break;
          case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
            if (extraArg1[continuousCount] != 0) {
              Item.processEffect(
                extraArg1[continuousCount], playerType, myState, yourState, state, extraArg2[continuousCount], 0, getChangePokemonIndex(PlayerType(myPlayerTypeID)));
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
            targetState.addStatChanges(targetState == myState, 4, -1, myState, moveId: replacedMove.id);
            targetState.ailmentsAdd(Ailment(Ailment.tarShot), state);
            break;
          case 427:   // 相手のタイプをエスパー単タイプにする
            if (targetState.teraType == null) {
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
              targetState.ailmentsAdd(Ailment(Ailment.cannotRunAway), state);
              targetState.ailmentsAdd(Ailment(Ailment.octoLock), state);
            }
            break;
          case 431:   // まだ行動していないポケモンに対して使うと威力2倍
            //TODO
            showDamageCalc = false;
            break;
          case 432:   // 使用者と相手の場の状態を入れ替える
            var tmp = myFields;
            myFields = targetIndiField;
            targetIndiField = tmp;
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
            targetState.addStatChanges(targetState == myState, 0, 2, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 2, 2, myState, moveId: replacedMove.id);
            break;
          case 437:   // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
            if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.harapekoForm).isNotEmpty) {
              moveType = PokeType.createFromId(17);
            }
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 442:   // そのターンに受けるこうげきわざを無効化し、直接攻撃わざを使用した相手のぼうぎょを2段階下げる
            // TODO
            break;
          case 443:   // 2～5回連続でこうげきする。使用者のぼうぎょが1段階下がり、すばやさが1段階上がる
            myState.addStatChanges(true, 1, -1, targetState, moveId: replacedMove.id);
            myState.addStatChanges(true, 4, 1, targetState, moveId: replacedMove.id);
            break;
          case 444:   // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
                      // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
            if (myState.teraType != null) {
              moveType = myState.teraType!;
            }
            // ステータスが確定している場合
            if (myState.maxStats[StatIndex.A.index].real == myState.minStats[StatIndex.A.index].real &&
                myState.maxStats[StatIndex.C.index].real == myState.minStats[StatIndex.C.index].real
            ) {
              if (myState.finalizedMaxStat(StatIndex.A, moveType, targetState, state) >
                    myState.finalizedMaxStat(StatIndex.C, moveType, targetState, state)
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
                var target = state.getPokemonStates(PlayerType(myPlayerTypeID))[targetIdx-1];
                if (myPlayerTypeID == PlayerType.me) {
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
            if (state.field.id == Field.psychicTerrain && myState.isGround(myPlayerTypeID == PlayerType.me ? state.ownFields : state.opponentFields)) {
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
                myState.addStatChanges(true, 2, 2, targetState, moveId: replacedMove.id);
                showDamageCalc = false;
              }
              else {  // こうげきする
                myState.hiddenBuffs.removeAt(findIdx);
              }
            }
            break;
          case 449:   // ぶつりわざであるときの方がダメージが大きい場合は物理技になる。どく状態にする(確率)
            // ステータスが確定している場合
            if (myState.maxStats[StatIndex.A.index].real == myState.minStats[StatIndex.A.index].real &&
                myState.maxStats[StatIndex.C.index].real == myState.minStats[StatIndex.C.index].real
            ) {
              if (myState.finalizedMaxStat(StatIndex.A, moveType, targetState, state) >
                    myState.finalizedMaxStat(StatIndex.C, moveType, targetState, state)
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
            if (state.field.id == Field.mistyTerrain && myState.isGround(myPlayerTypeID == PlayerType.me ? state.ownFields : state.opponentFields)) {
              movePower = (movePower * 1.5).floor();
            }
            myState.remainHP = 0;
            myState.remainHPPercent = 0;
            myState.isFainting = true;
            break;
          case 451:   // グラスフィールドの効果を受けているとき優先度が高くなる
            break;
          case 452:   // 対象がエレキフィールドの効果を受けているとき威力2倍
            if (state.field.id == Field.electricTerrain && targetState.isGround(targetPlayerTypeID == PlayerType.me ? state.ownFields : state.opponentFields)) {
              movePower *= 2;
            }
            break;
          case 453:   // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
            if (myState.isGround(myPlayerTypeID == PlayerType.me ? state.ownFields : state.opponentFields)) {
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
            // TODO
            break;
          case 455:   // このターンに使用者の能力が下がっていた場合、威力2倍
            // TODO
            break;
          case 456:   // 対象にもちものがあるときのみ成功
            // TODO もちもの確定
            break;
          case 457:   // 対象のもちものを消失させる
            // TODO もちもの確定
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
              targetState.addStatChanges(targetState == myState, 1, 1, myState, moveId: replacedMove.id);
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
            //TODO
            break;
          case 475:   // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
            if (extraArg1[continuousCount] != 0) {
              targetState.ailmentsAdd(Ailment(Ailment.confusion), state);
            }
            if (myPlayerTypeID == PlayerType.me) {
              myState.remainHP -= extraArg2[continuousCount];
            }
            else {
              myState.remainHPPercent -= extraArg2[continuousCount];
            }
            break;
          case 476:   // その戦闘で味方がひんしになるたび、威力が50ずつ上がる
            // TODO
            break;
          case 477:   // ヘイラッシャがシャリタツを飲み込んでいた場合、使用者の能力を上げる
            break;
          case 478:   // 対象のこうげきを2段階上げ、ぼうぎょを2段階下げる
            targetState.addStatChanges(targetState == myState, 0, 2, myState, moveId: replacedMove.id);
            targetState.addStatChanges(targetState == myState, 1, -2, myState, moveId: replacedMove.id);
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
            targetState.ailmentsAdd(Ailment(Ailment.saltCure), state);
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
            isSunny1_5 = true;
            myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            targetState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
            break;
          case 491:   // 効果がばつぐんの場合、威力4/3倍
            if (PokeType.effectiveness(
              myState.currentAbility.id == 113, yourState.holdingItem?.id == 586,
              yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              moveType, targetState).id == MoveEffectiveness.great
            ) {
              movePower = (movePower / 3 * 4).floor();
            }
            break;
          case 492:   // 使用者の最大HP1/2(小数点以下切り捨て)を消費してみがわり作成、みがわりを引き継いで控えと交代
            myState.remainHP -= extraArg1[continuousCount];
            myState.remainHPPercent -= extraArg2[continuousCount];
            if (getChangePokemonIndex(PlayerType(myPlayerTypeID)) != null) {
              myState.processExitEffect(myPlayerTypeID == PlayerType.me, yourState);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(PlayerType(myPlayerTypeID))!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerTypeID == PlayerType.me, state, yourState);
              newState.buffDebuffs.add(BuffDebuff(BuffDebuff.substitute));
            }
            break;
          case 493:   // 天気をゆきにして控えと交代
            state.weather = Weather(Weather.snowy);
            if (getChangePokemonIndex(PlayerType(myPlayerTypeID)) != null) {
              myState.processExitEffect(myPlayerTypeID == PlayerType.me, yourState);
              PokemonState newState;
              state.setPokemonIndex(playerType, getChangePokemonIndex(PlayerType(myPlayerTypeID))!);
              newState = state.getPokemonState(playerType, null);
              newState.processEnterEffect(myPlayerTypeID == PlayerType.me, state, yourState);
              newState.buffDebuffs.add(BuffDebuff(BuffDebuff.substitute));
            }
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
            state.weather = Weather(Weather.snowy);
            break;
          case 496:   // その戦闘でこうげき技のダメージを受けるたびに威力+50。(最大350)
            // TODO
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
            if (myPlayerTypeID == PlayerType.me) {
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
            // TODO
            break;
          default:
            break;
        }
      }

      // ダメージ計算式
      if (showDamageCalc) {
        if (damageCalc == null) {
          // じゅうでん補正&消費
          int findIdx = myState.ailmentsIndexWhere((e) => e.id == Ailment.charging);
          if (findIdx >= 0 && moveType.id == 13) {
            movePower *= 2;
            myState.ailmentsRemoveAt(findIdx);
          }

          // とくせい等によるわざタイプの変更
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) moveType = PokeType.createFromId(15);
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) moveType = PokeType.createFromId(18);
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) moveType = PokeType.createFromId(3);
          if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.liquidVoice) >= 0) moveType = PokeType.createFromId(11);
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) moveType = PokeType.createFromId(13);
          
          // とくせい等による威力変動
          double tmpPow = movePower.toDouble();
          // テクニシャン補正は一番最初
          if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.technician) >= 0) tmpPow *= 1.5;

          if (moveType.id == 12 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.overgrow) >= 0) tmpPow *= 1.5;
          if (moveType.id == 10 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.blaze) >= 0) tmpPow *= 1.5;
          if (moveType.id == 11 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.torrent) >= 0) tmpPow *= 1.5;
          if (moveType.id == 7 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.swarm) >= 0) tmpPow *= 1.5;
          if (myState.pokemon.sex.id != 0 && targetStates[0].pokemon.sex.id != 0 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.opponentSex1_5) >= 0) {
            if (myState.pokemon.sex.id != targetStates[0].pokemon.sex.id) {
              tmpPow *= 1.25;
            }
            else {
              tmpPow *= 0.75;
            }
          }
          if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punch1_2) >= 0) tmpPow *= 1.2;
          if (replacedMove.power <= 60 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.technician) >= 0) tmpPow *= 1.5;
          if (replacedMove.isRecoil && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.recoil1_2) >= 0) tmpPow *= 1.2;
          if (moveDamageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5) >= 0) tmpPow *= 1.5;
          if (moveDamageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5) >= 0) tmpPow *= 1.5;
          // TODO : 最後の行動なら威力1.3倍 if (?? && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.analytic) >= 0) tmpPow *= 1.3;
          if ((moveType.id == 5 || moveType.id == 6 || moveType.id == 9) && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockGroundSteel1_3) >= 0) tmpPow *= 1.3;
          if (replacedMove.isBite && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bite1_5) >= 0) tmpPow *= 1.5;
          if (moveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.freezeSkin) >= 0) tmpPow *= 1.2;
          if (moveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairySkin) >= 0) tmpPow *= 1.2;
          if (moveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airSkin) >= 0) tmpPow *= 1.2;
          if (moveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.darkAura) >= 0) tmpPow *= 1.33;
          if (moveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAura) >= 0) tmpPow *= 1.33;
          if (moveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiDarkAura) >= 0) tmpPow *= 0.75;
          if (moveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.antiFairyAura) >= 0) tmpPow *= 0.75;
          if (moveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricSkin) >= 0) tmpPow *= 1.2;
          if (replacedMove.isSound && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.sound1_3) >= 0) tmpPow *= 1.3;
          if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove1_3) >= 0) tmpPow *= 1.3;
          if (moveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steel1_5) >= 0) tmpPow *= 1.5;
          if (replacedMove.isCut && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.cut1_5) >= 0) tmpPow *= 1.5;
          int pow = myState.buffDebuffs.indexWhere((e) => e.id >= BuffDebuff.power10 && e.id <= BuffDebuff.power50);
          if (myState.buffDebuffs.indexWhere((e) => e.id >= BuffDebuff.power10 && e.id <= BuffDebuff.power50) >= 0) {
            tmpPow = tmpPow * (1.0 + (myState.buffDebuffs[pow].id - BuffDebuff.power10 + 1) * 0.1);
          }
          if (moveDamageClassID == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_1) >= 0) tmpPow *= 1.1;
          if (moveDamageClassID == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_1) >= 0) tmpPow *= 1.1;
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceNormalAttack1_3) >= 0) tmpPow *= 1.3;
          if (moveType.id == 1 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.normalAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 2 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fightAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 3 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.airAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 4 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.poisonAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 5 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.groundAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 6 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rockAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 7 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.bugAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 8 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghostAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 9 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 10 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fireAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 11 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 12 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.grassAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 13 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electricAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 14 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.psycoAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 15 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 16 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragonAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 17 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.evilAttack1_2) >= 0) tmpPow *= 1.2;
          if (moveType.id == 18 && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.fairyAttack1_2) >= 0) tmpPow *= 1.2;
          if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.moveAttack1_2) >= 0) tmpPow *= 1.2;
          if (replacedMove.isPunch && myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.punchNotDirect1_1) >= 0) tmpPow *= 1.1;

          if (moveType.id == 13 && myState.isGround(myFields) && state.field.id == Field.electricTerrain) tmpPow *= 1.3;
          if (moveType.id == 12 && myState.isGround(myFields) && state.field.id == Field.grassyTerrain) tmpPow *= 1.3;
          if (moveType.id == 14 && myState.isGround(myFields) && state.field.id == Field.psychicTerrain) tmpPow *= 1.3;
          if (moveType.id == 16 && targetStates[0].isGround(targetIndiFields[0]) && state.field.id == Field.mistyTerrain) tmpPow *= 0.5;
          
          if (moveType.id == 10 && targetStates[0].buffDebuffs.indexWhere((e) => e.id == BuffDebuff.drySkin) >= 0) tmpPow *= 1.25;

          movePower = tmpPow.floor();

          // TODO: targetStates(リスト)
          // 範囲補正・おやこあい補正は無視する(https://wiki.xn--rckteqa2e.com/wiki/%E3%83%80%E3%83%A1%E3%83%BC%E3%82%B8#%E7%AC%AC%E4%BA%94%E4%B8%96%E4%BB%A3%E4%BB%A5%E9%99%8D)
          // TODO パワートリック等で、実際にmaxStatsとかの値を入れ替えたほうが良さそう
          int calcMaxAttack =
            myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
              myState.finalizedMaxStat(StatIndex.A, moveType, targetStates[0], state) : myState.finalizedMaxStat(StatIndex.B, moveType, targetStates[0], state);
          int calcMinAttack =
            myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
              myState.finalizedMinStat(StatIndex.A, moveType, targetStates[0], state) : myState.finalizedMinStat(StatIndex.B, moveType, targetStates[0], state);
          if (isFoulPlay) {
            calcMaxAttack = targetStates[0].ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
                targetStates[0].finalizedMaxStat(StatIndex.A, moveType, targetStates[0], state) : targetStates[0].finalizedMaxStat(StatIndex.B, moveType, targetStates[0], state);
            calcMinAttack = targetStates[0].ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
                targetStates[0].finalizedMinStat(StatIndex.A, moveType, targetStates[0], state) : targetStates[0].finalizedMinStat(StatIndex.B, moveType, targetStates[0], state);
          }
          else if (defenseAltAttack) {
            calcMaxAttack = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
                myState.finalizedMaxStat(StatIndex.B, moveType, targetStates[0], state) : myState.finalizedMaxStat(StatIndex.A, moveType, targetStates[0], state);
            calcMinAttack = myState.ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
                myState.finalizedMinStat(StatIndex.B, moveType, targetStates[0], state) : myState.finalizedMinStat(StatIndex.A, moveType, targetStates[0], state);
          }
          int attackVmax = moveDamageClassID == 2 ? calcMaxAttack : myState.finalizedMaxStat(StatIndex.C, moveType, targetStates[0], state);
          int attackVmin = moveDamageClassID == 2 ? calcMinAttack : myState.finalizedMinStat(StatIndex.C, moveType, targetStates[0], state);
          String attackStr = '';
          if (attackVmax == attackVmin) {
            attackStr = attackVmax.toString();
          }
          else {
            attackStr = '$attackVmin～$attackVmax';
          }
          if (isFoulPlay) {
            attackStr += '(対象者のこうげき)';
          }
          else {
            attackStr += moveDamageClassID == 2 ? '(使用者のこうげき)' : '(使用者のとくこう)';
          }
          int calcMaxDefense = targetStates[0].ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ? 
                ignoreTargetRank ? targetStates[0].maxStats[2].real : targetStates[0].finalizedMaxStat(StatIndex.B, moveType, targetStates[0], state) :
                ignoreTargetRank ? targetStates[0].maxStats[1].real : targetStates[0].finalizedMaxStat(StatIndex.A, moveType, targetStates[0], state);
          int calcMinDefense = targetStates[0].ailmentsWhere((e) => e.id == Ailment.powerTrick).isEmpty ?
                ignoreTargetRank ? targetStates[0].minStats[2].real : targetStates[0].finalizedMinStat(StatIndex.B, moveType, targetStates[0], state) :
                ignoreTargetRank ? targetStates[0].minStats[1].real : targetStates[0].finalizedMinStat(StatIndex.A, moveType, targetStates[0], state);
          int defenseVmax = moveDamageClassID == 2 ? calcMaxDefense : invDeffense ? calcMaxDefense :
                ignoreTargetRank ? targetStates[0].maxStats[4].real : targetStates[0].finalizedMaxStat(StatIndex.D, moveType, targetStates[0], state);
          int defenseVmin = moveDamageClassID == 2 ? calcMinDefense : invDeffense ? calcMinDefense :
                ignoreTargetRank ? targetStates[0].minStats[4].real : targetStates[0].finalizedMinStat(StatIndex.D, moveType, targetStates[0], state);
          String defenseStr = '';
          if (defenseVmax == defenseVmin) {
            defenseStr = defenseVmax.toString();
          }
          else {
            defenseStr = '$defenseVmin～$defenseVmax';
          }
          if (invDeffense) {
            defenseStr += '(対象者のぼうぎょ)';
          }
          else {
            defenseStr += moveDamageClassID == 2 ? '(対象者のぼうぎょ)' : '(対象者のとくぼう)';
          }
          int damageVmax = (((myState.pokemon.level * 2 / 5 + 2).floor() * movePower * (attackVmax / defenseVmin)).floor() / 50 + 2).floor();
          int damageVmin = ((((myState.pokemon.level * 2 / 5 + 2).floor() * movePower * (attackVmin / defenseVmax)).floor() / 50 + 2).floor() * 0.85).floor();
          damageCalc = 'ダメージ計算：${myState.pokemon.level}(わざ使用者レベル)×2÷5+2 ×$movePower(威力)×$attackStr÷$defenseStr ÷50+2 ×0.85～1.00(乱数) ';
          // 天気補正(五捨五超入)
          if (targetStates[0].holdingItem?.id != 1181) {    // 相手がばんのうがさを持っていない
            if (state.weather.id == Weather.sunny) {
              if (moveType.id == 10) {   // はれ下ほのおわざ
                damageVmax = roundOff5(damageVmax * 1.5);
                damageVmin = roundOff5(damageVmin * 1.5);
                damageCalc += '×1.5(天気) ';
              }
              else if (moveType.id == 11) {   // はれ下みずわざ
                if (isSunny1_5) {
                  damageVmax = roundOff5(damageVmax * 1.5);
                  damageVmin = roundOff5(damageVmin * 1.5);
                  damageCalc += '×1.5(天気) ';
                }
                else {
                  damageVmax = roundOff5(damageVmax * 0.5);
                  damageVmin = roundOff5(damageVmin * 0.5);
                  damageCalc += '×0.5(天気) ';
                }
              }
            }
            else if (state.weather.id == Weather.rainy) {
              if (moveType.id == 11) {   // 雨下みずわざ
                damageVmax = roundOff5(damageVmax * 1.5);
                damageVmin = roundOff5(damageVmin * 1.5);
                damageCalc += '×1.5(天気) ';
              }
              else if (moveType.id == 10) {   // 雨下ほのおわざ
                damageVmax = roundOff5(damageVmax * 0.5);
                damageVmin = roundOff5(damageVmin * 0.5);
                damageCalc += '×0.5(天気) ';
              }
            }
          }
          // 急所補正(五捨五超入)
          if (moveHits[continuousCount].id == MoveHit.critical) {
            damageVmax = roundOff5(damageVmax * 1.5);
            damageVmin = roundOff5(damageVmin * 1.5);
            damageCalc += '×1.5(急所) ';
          }
          // 乱数補正(切り捨て)
          damageVmax = (damageVmax * 100 / 100).floor();
          damageVmin = (damageVmin * 85 / 100).floor();
          damageCalc += '×85～100÷100(乱数) ';
          // タイプ一致補正(五捨五超入)
          var rate = myState.typeBonusRate(moveType.id, myState.currentAbility.id == 91);
          if (rate > 1.0) {
            damageVmax = roundOff5(damageVmax * rate);
            damageVmin = roundOff5(damageVmin * rate);
            damageCalc += '×$rate(タイプ一致) ';
          }
          // 相性補正(切り捨て)
          rate = PokeType.effectivenessRate(myState.currentAbility.id == 113, targetStates[0].holdingItem?.id == 586,
            targetStates[0].ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty, moveType, targetStates[0]);
          damageVmax = (damageVmax * rate).floor();
          damageVmin = (damageVmin * rate).floor();
          damageCalc += '×$rate(相性) ';
          // やけど補正(五捨五超入)
          if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty && moveDamageClassID == 2 && move.id != 263) {  // からげんき以外のぶつりわざ
            if (myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn) < 0) {
              damageVmax = roundOff5(damageVmax * 0.5);
              damageVmin = roundOff5(damageVmin * 0.5);
              damageCalc += '×0.5(やけど) ';
            }
          }
          // M(五捨五超入)
          {
            double tmpMax = damageVmax.toDouble();
            double tmpMin = damageVmin.toDouble();
            // 壁補正
            if (
              (moveDamageClassID == 2 && targetIndiFields[0].where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.reflector).isNotEmpty) ||
              (moveDamageClassID == 3 && targetIndiFields[0].where((e) => e.id == IndividualField.auroraVeil || e.id == IndividualField.lightScreen).isNotEmpty)
            ) {
              tmpMax *= 0.5;
              tmpMin *= 0.5;
              damageCalc += '×0.5(壁) ';
            }
            // ブレインフォース補正
            if (moveEffectivenesses[continuousCount].id == MoveEffectiveness.great &&
                myState.buffDebuffs.where((e) => e.id == BuffDebuff.greatDamage1_25).isNotEmpty
            ) {
              tmpMax *= 1.25;
              tmpMin *= 1.25;
              damageCalc += '×1.25(ブレインフォース) ';
            }
            // スナイパー補正
            if (moveHits[continuousCount].id == MoveHit.critical &&
                myState.buffDebuffs.where((e) => e.id == BuffDebuff.sniper).isNotEmpty
            ) {
              tmpMax *= 1.5;
              tmpMin *= 1.5;
              damageCalc += '×1.5(スナイパー) ';
            }
            // いろめがね補正
            if (moveEffectivenesses[continuousCount].id == MoveEffectiveness.notGood &&
                myState.buffDebuffs.where((e) => e.id == BuffDebuff.notGoodType2).isNotEmpty
            ) {
              tmpMax *= 2;
              tmpMin *= 2;
              damageCalc += '×2(いろめがね) ';
            }
            // もふもふほのお補正
            if (!ignoreAbility && (moveDamageClassID == 2 || moveDamageClassID == 3) &&
                moveType.id == 10 &&
                targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.fireAttackedDamage2).isNotEmpty
            ) {
              tmpMax *= 2;
              tmpMin *= 2;
              damageCalc += '×2(もふもふ) ';
            }
            // Mhalf
            if (!ignoreAbility &&
              // こおりのりんぷん
              (moveDamageClassID == 3 &&
               targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.specialDamaged0_5).isNotEmpty) ||
              // パンクロック
              (replacedMove.isSound && targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.soundedDamage0_5).isNotEmpty) ||
              // ファントムガード
              // マルチスケイル
              ((targetStates[0].remainHP >= targetStates[0].pokemon.h.real || targetStates[0].remainHPPercent >= 100) &&
                targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.damaged0_5).isNotEmpty ||
              // もふもふ直接こうげき
               replacedMove.isDirect && targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.directAttackedDamage0_5).isNotEmpty)
            ) {
              tmpMax *= 0.5;
              tmpMin *= 0.5;
              damageCalc += '×0.5(とくせい) ';
            }
            // Mfilter
            if (!ignoreAbility &&
              // ハードロック
              // フィルター
              // プリズムアーマー
              moveEffectivenesses[continuousCount].id == MoveEffectiveness.great &&
              targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.greatDamaged0_75).isNotEmpty
            ) {
              tmpMax *= 0.75;
              tmpMin *= 0.75;
              damageCalc += '×0.75(とくせい) ';
            }
            // Mtwice
            if (mTwice || targetStates[0].buffDebuffs.where((e) => e.id == BuffDebuff.certainlyHittedDamage2).isNotEmpty) {
              tmpMax *= 2;
              tmpMin *= 2;
              damageCalc += '×2(その他補正) ';
            }
            
            damageVmax = roundOff5(tmpMax);
            damageVmin = roundOff5(tmpMin);
          }
          // Mprotect(五捨五超入)
          // ダイマックスわざに関する計算のため、SVでは不要
          { }
          damageCalc += '= $damageVmin～$damageVmax';
        }

        ret.add(damageCalc);
      }

      // ねごと系以外のわざを出しているならねむり解除とみなす
      if (replacedMove.id != 173 && replacedMove.id != 214) {
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
      }
      // ミクルのみのこうかが残っていれば消費
      int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceAccuracy1_2);
      if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
      // ノーマルジュエル消費
      if (myState.holdingItem?.id == 669 && moveDamageClassID >= 2 && moveType.id == 1) {
        myState.holdingItem = null;
      }
      // くっつきバリ移動
      if (replacedMove.isDirect && myState.holdingItem == null && yourState.holdingItem?.id == 265) {
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
              if (targetState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty) {
                targetState.remainHP -= realDamage[continuousCount];
                targetState.remainHPPercent -= percentDamage[continuousCount];
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

    // わざ確定
    var tmp = myState.moves.where(
          (element) => element.id != 0 && element.id == move.id
        );
    if (move.id != 165 &&     // わるあがきは除外
        playerType.id == PlayerType.opponent &&
        type.id == TurnMoveType.move &&
        opponentPokemonState.moves.length < 4 &&
        tmp.isEmpty
    ) {
      opponentPokemonState.moves.add(move);
      ret.add('わざの1つを${move.displayName}で確定しました。');
    }

    // わざPP消費
    if (continuousCount == 0) {
      int moveIdx = myState.moves.indexWhere((element) => element.id != 0 && element.id == move.id);
      if (moveIdx >= 0) {
        myState.usedPPs[moveIdx]++;
        if (yourState.currentAbility.id == 46) myState.usedPPs[moveIdx]++;
      }
    }

    // 最後に使用した(PP消費した)わざセット
    // TODO:replacedMove?
    myState.lastMove = move;

    return ret;
  }

  Widget extraInputWidget1(
    void Function() onFocus,
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
  )
  {
    final pokeData = PokeDB();
    // 交代先ポケモンがいるかどうか
    int count = 0;
    if (playerType.id == PlayerType.me) {
      for (int i = 0; i < ownParty.pokemonNum; i++) {
        if (state.isPossibleBattling(playerType, i) &&
            !state.getPokemonStates(playerType)[i].isFainting &&
            i != ownParty.pokemons.indexWhere((element) => element == ownPokemon)
        ) {
          count++;
        }
      }
    }
    else if (playerType.id == PlayerType.opponent) {
      for (int i = 0; i < opponentParty.pokemonNum; i++) {
        if (state.isPossibleBattling(playerType, i) &&
            !state.getPokemonStates(playerType)[i].isFainting &&
            i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon)
        ) {
          count++;
        }
      }
    }
    // 相手のポケモンのとくせいによって交代可能かどうか
    var myState = playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var myFields = playerType.id == PlayerType.me ? state.ownFields : state.opponentFields;
    bool isShadowTag = !myState.isTypeContain(8) &&    // ゴーストタイプではない
      (yourState.currentAbility.id == 23 ||                                     // 相手がかげふみ
       (yourState.currentAbility.id == 42 && myState.isTypeContain(9)) ||       // 相手がじりょく＆自身がはがね
       (yourState.currentAbility.id == 71 && myState.isGround(myFields))                  // 相手がありじごく＆自身が地面にいる
      );
    bool canChange = count >= 1 && !isShadowTag;
    ButtonStyle pressedStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(theme.secondaryHeaderColor),
    );

    // 行動失敗時
    if (!isSuccess) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '失敗の原因',
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
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 5,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: moveController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '使用しようとしたわざ',
                ),
              ),
              autoFlipDirection: true,
              suggestionsCallback: (pattern) async {
                List<Move> matches = [];
                if (playerType.id == PlayerType.me) {
                  matches.add(ownPokemon.move1);
                  if (ownPokemon.move2 != null) matches.add(ownPokemon.move2!);
                  if (ownPokemon.move3 != null) matches.add(ownPokemon.move3!);
                  if (ownPokemon.move4 != null) matches.add(ownPokemon.move4!);
                }
                else {
                  matches.addAll(pokeData.pokeBase[opponentPokemon.no]!.move);
                }
                matches.retainWhere((s){
                  return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                onPressed: playerType.id != PlayerType.none ?
                () {
                  type = TurnMoveType(TurnMoveType.move);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                } : null,
                style: type.id == TurnMoveType.move ? pressedStyle : null,
                child: Text('わざ'),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: playerType.id != PlayerType.none ?
                () {
                  type = TurnMoveType(TurnMoveType.change);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                } : null,
                style: type.id == TurnMoveType.change ? pressedStyle : null,
                child: Text('ポケモン交代'),
              ),
              SizedBox(width: 10,),
              TextButton(
                onPressed: playerType.id != PlayerType.none ?
                () {
                  type = TurnMoveType(TurnMoveType.surrender);
                  appState.editingPhase[phaseIdx] = true;
                  onFocus();
                } : null,
                style: type.id == TurnMoveType.surrender ? pressedStyle : null,
                child: Text('こうさん'),
              ),
            ],
          ),
          SizedBox(height: 10,),
          type.id == TurnMoveType.move ?     // 行動がわざの場合
          Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: moveController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'わざ',
                    ),
                    enabled: playerType.id != PlayerType.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType.id == PlayerType.me) {
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
                    }
                    matches.add(pokeData.moves[165]!);    // わるあがき
                    matches.retainWhere((s){
                      return toKatakana(getReplacedMoveName(s, continuousCount, myState).toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
                    });
                    return matches;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(getReplacedMoveName(suggestion, continuousCount, myState)),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    moveController.text = getReplacedMoveName(suggestion, continuousCount, myState);
                    move = getReplacedMove(suggestion, continuousCount, myState);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0);
                    moveAdditionalEffects[0] = move.isSurelyEffect() && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ? MoveEffect(move.effect.id) : MoveEffect(0);
                    moveEffectivenesses[0] = PokeType.effectiveness(
                        myState.currentAbility.id == 113, yourState.holdingItem?.id == 586,
                        yourState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                        getReplacedMoveType(move, continuousCount, myState, state), yourState);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          ) :
          type.id == TurnMoveType.change ?     // 行動が交代の場合
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '交代先ポケモン',
                  ),
                  items: playerType.id == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon),
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon) ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon) ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    appState.needAdjustPhases = phaseIdx+1;
                    onFocus();
                  },
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

  Widget terastalInputWidget(
    void Function() onFocus,
    Pokemon ownPokemon,
    bool alreadyTerastal,
  )
  {
    final pokeData = PokeDB();
    if (playerType.id != PlayerType.none && type.id == TurnMoveType.move) {
      // テラスタル有無
      return Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              title: Text('テラスタル'),
              value: teraType.id != 0,
              enabled: !alreadyTerastal,
              onChanged: (value) {
                if (value != null && value) {
                  if (playerType.id == PlayerType.me) {
                    teraType = ownPokemon.teraType;
                  }
                  else {
                    teraType = pokeData.types[0];  // とりあえずノーマル
                  }
                }
                else {
                  teraType = PokeType.createFromId(0);
                }
                onFocus();
              },
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: TypeDropdownButton(
              'タイプ',
              teraType.id == 0 || alreadyTerastal || playerType.id == PlayerType.me ?
                null : (val) {teraType = pokeData.types[val - 1];},
              teraType.id == 0 ? null : teraType.id,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget extraInputWidget2(
    void Function() onFocus,
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
  )
  {
    var myState = playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    var myFields = playerType.id == PlayerType.me ? state.ownFields : state.opponentFields;

    if (playerType.id != PlayerType.none && type.id == TurnMoveType.move && move.id != 0) {
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
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: preMoveController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'わざ',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = appState.pokeData.moves.values.toList();
                    matches.removeWhere((e) => e.id == 0);
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                    moveAdditionalEffects[continuousCount] = suggestion.isSurelyEffect() && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ? MoveEffect(suggestion.effect.id) : MoveEffect(0);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: preMoveController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'わざ',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType.id == PlayerType.me) {
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
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                    moveAdditionalEffects[continuousCount] = suggestion.isSurelyEffect() && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ? MoveEffect(suggestion.effect.id) : MoveEffect(0);
                    turnEffectAndStateAndGuide.guides = processMove(
                      ownParty.copyWith(), opponentParty.copyWith(), ownPokemonState.copyWith(),
                      opponentPokemonState.copyWith(), state.copyWith(), 0);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        default:
          break;
      }
      
      // 必要に応じてわざの内容変更
      Move replacedMove = getReplacedMove(move, continuousCount, playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState);

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
        case 470:   // すばやさを1段階下げる(確率)。天気があめの時は必中
        case 471:   // まひにする(確率)。天気があめの時は必中
        case 472:   // やけどにする(確率)。天気があめの時は必中
        case 499:   // 眠らせる(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('相手は${moveEffectText[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
          effectInputRow2 = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: hpController2,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                  ),
                  enabled: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${ownPokemon.h.real}')) :
              Flexible(child: Text('% /100%'))
            ],
          );
          break;
        case 83:    // 相手が最後にPP消費したわざになる。交代するとわざは元に戻る
          effectInputRow = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'わざ',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Move> matches = [];
                    if (playerType.id == PlayerType.opponent) {
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
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('自身は${moveEffectText[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        case 28:    // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('疲れ果ててこんらんした'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '交代先ポケモン',
                  ),
                  items: playerType.id == PlayerType.opponent ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: getChangePokemonIndex(playerType.opposite),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType.opposite, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
                child: TypeDropdownButton(
                  '変更先タイプ',
                  (val) {extraArg1[continuousCount] = val;},
                  extraArg1[continuousCount] == 0 ? null : extraArg1[continuousCount],
                ),
              ),
            ],
          );
          break;
        case 37:    // やけど・こおり・まひのいずれかにする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.burn,
                      child: Text('相手はやけどをおった'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.freeze,
                      child: Text('相手はこおってしまった'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text('相手はしびれてしまった'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        case 46:    // わざを外すと使用者に、使用者の最大HP1/2のダメージ
          if (moveHits[continuousCount].id == MoveHit.notHit || moveHits[continuousCount].id == MoveHit.fail) {
            effectInputRow2 = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: hpController2,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: playerType.id == PlayerType.me ? 
                        '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                    ),
                    enabled: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onTap: () => onFocus(),
                    onChanged: (value) {
                      if (playerType.id == PlayerType.me) {
                        extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                      }
                      else {
                        extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                      }
                      appState.editingPhase[phaseIdx] = true;
                      onFocus();
                    },
                  ),
                ),
                playerType.id == PlayerType.me ?
                Flexible(child: Text('/${ownPokemon.h.real}')) :
                Flexible(child: Text('% /100%'))
              ],
            );
          }
          break;
        case 106:   // もちものを盗む
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('もちものをぬすんだ'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                        matches.add(opponentPokemonState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.holdingItem != null) {
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          break;
        case 110:   // 使用者がゴーストタイプ：使用者のHPを最大HPの半分だけ減らし、相手をのろいにする。ゴースト以外：使用者のこうげき・ぼうぎょ1段階UP、すばやさ1段階DOWN
          if ((playerType.id == PlayerType.me && ownPokemonState.isTypeContain(8)) ||
              (playerType.id == PlayerType.opponent && opponentPokemonState.isTypeContain(8))
          ) {
            effectInputRow2 = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: hpController2,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: playerType.id == PlayerType.me ? 
                        '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                    ),
                    enabled: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onTap: () => onFocus(),
                    onChanged: (value) {
                      if (playerType.id == PlayerType.me) {
                        extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                      }
                      else {
                        extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                      }
                      appState.editingPhase[phaseIdx] = true;
                      onFocus();
                    },
                  ),
                ),
                playerType.id == PlayerType.me ?
                Flexible(child: Text('/${ownPokemon.h.real}')) :
                Flexible(child: Text('% /100%'))
              ],
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
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('相手は${moveEffectText[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '交代先ポケモン',
                  ),
                  items: playerType.id == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        case 136:   // 個体値によってわざのタイプが変わる
          effectInputRow = Row(
            children: [
              Expanded(
                child: TypeDropdownButton(
                  'わざのタイプ',
                  (val) {extraArg1[continuousCount] = val;},
                  extraArg1[continuousCount] == 0 ? null : extraArg1[continuousCount],
                ),
              ),
            ],
          );
          break;
        case 178:   // 使用者ともちものを入れ替える
          effectInputRow = Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'あなたが手に入れたもちもの',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                      matches.add(opponentPokemonState.holdingItem!);
                    }
                    else {
                      matches = appState.pokeData.items.values.toList();
                      matches.removeWhere((element) => element.id == 0);
                      for (var item in opponentPokemonState.impossibleItems) {
                        matches.removeWhere((element) => element.id == item.id);
                      }
                      matches.add(Item(0, 'なし', 0, 0, AbilityTiming(0), false));
                    }
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
                ),
              ),
            ],
          );
          break;
        case 179:   // 相手と同じとくせいになる
          effectInputRow = Row(
            children: [
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'とくせい',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.currentAbility.id != 0) {
                        matches.add(opponentPokemonState.currentAbility);
                      }
                      else {
                        matches.addAll(opponentPokemonState.possibleAbilities);
                      }
                    }
                    else {
                      matches.add(ownPokemonState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
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
                ),
              ),
            ],
          );
          break;
        case 189:   // もちものを持っていれば失わせ、威力1.5倍
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('もちものをはたきおとした'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                        matches.add(opponentPokemonState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.holdingItem != null) {
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          break;
        case 192:   // 使用者ととくせいを入れ替える
          effectInputRow = Row(
            children: [
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'あなたが得たとくせい',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (opponentPokemonState.currentAbility.id != 0) {
                      matches.add(opponentPokemonState.currentAbility);
                    }
                    else {
                      matches.addAll(opponentPokemonState.possibleAbilities);
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          break;
        case 225:   // 相手がきのみを持っている場合はその効果を使用者が受ける(きのみを消費)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('相手のきのみを消費した'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType.id == PlayerType.me) {
                      if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                        matches.add(opponentPokemonState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.holdingItem != null) {
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraInputWidget(
            onFocus, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
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
          );
          break;
        case 227:     // 使用者のこうげき・ぼうぎょ・とくこう・とくぼう・めいちゅう・かいひのうちランダムにいずれかを2段階上げる(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('自身はこうげきがぐーんと上がった'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('自身はぼうぎょがぐーんと上がった'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('自身はとくこうがぐーんと上がった'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('自身はとくぼうがぐーんと上がった'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('自身はめいちゅうがぐーんと上がった'),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text('自身はかいひがぐーんと上がった'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        case 234:   // 使用者のもちものによって威力と追加効果が変わる
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('もちものを投げつけた'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    if (playerType.id == PlayerType.opponent) {
                      if (opponentPokemonState.holdingItem != null && opponentPokemonState.holdingItem!.id != 0) {
                        matches.add(opponentPokemonState.holdingItem!);
                      }
                      else {
                        matches = appState.pokeData.items.values.toList();
                        matches.removeWhere((element) => element.id == 0);
                        for (var item in opponentPokemonState.impossibleItems) {
                          matches.removeWhere((element) => element.id == item.id);
                        }
                      }
                    }
                    else if (ownPokemonState.holdingItem != null) {
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraInputWidget(
            onFocus, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
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
          );
          break;
        case 254:   // 与えたダメージの33%を使用者も受ける。使用者のこおり状態を消す。相手をやけど状態にする(確率)
        case 263:   // 与えたダメージの33%を使用者も受ける。相手をまひ状態にする(確率)
        case 475:   // こんらんさせる(確率)。わざを外すと使用者に、使用者の最大HP1/2のダメージ
        case 500:   // 与えたダメージの半分だけ回復する。両者のこおり状態を消す。相手をやけど状態にする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('相手は${moveEffectText[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          effectInputRow2 = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: hpController2,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                  ),
                  enabled: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg2[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${ownPokemon.h.real}')) :
              Flexible(child: Text('% /100%'))
            ],
          );
          break;
        case 274:   // 相手をやけど状態にする(確率)。相手をひるませる(確率)。
        case 275:   // 相手をこおり状態にする(確率)。相手をひるませる(確率)。
        case 276:   // 相手をまひ状態にする(確率)。相手をひるませる(確率)。
        case 468:   // 相手のぼうぎょを1段階下げる(確率)。相手をひるませる(確率)。急所に当たりやすい
          effectInputRow = Row(
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果1',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('相手は${moveEffectText[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Flexible(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果2',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('相手は${moveEffectText2[replacedMove.effect.id]!}'),
                    ),
                  ],
                  value: extraArg2[continuousCount],
                  onChanged: (value) {
                    extraArg2[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          break;
        case 300:   // 相手のとくせいを使用者のとくせいと同じにする
          effectInputRow = Row(
            children: [
              Flexible(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'とくせい',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Ability> matches = [];
                    if (playerType.id == PlayerType.opponent) {
                      if (opponentPokemonState.currentAbility.id != 0) {
                        matches.add(opponentPokemonState.currentAbility);
                      }
                      else {
                        matches.addAll(opponentPokemonState.possibleAbilities);
                      }
                    }
                    else {
                      matches.add(ownPokemonState.currentAbility);
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          break;
        case 315:   // 相手のきのみ・ノーマルジュエルを失わせる
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: replacedMove.effect.id,
                      child: Text('もちものをやきつくした'),
                    ),
                  ],
                  value: moveAdditionalEffects[continuousCount].id,
                  onChanged: (value) {
                    moveAdditionalEffects[continuousCount] = MoveEffect(value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'もちもの',
                    ),
                    enabled: moveAdditionalEffects[continuousCount].id != MoveEffect.none,
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    Item? holdingItem = playerType.id == PlayerType.me ? opponentPokemonState.holdingItem : ownPokemonState.holdingItem;
                    if (playerType.id == PlayerType.me) {
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
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          break;
        case 424:   // 持っているきのみを消費して効果を受ける。その場合、追加で使用者のぼうぎょを2段階上げる
          effectInputRow = Row(
            children: [
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hpController2,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '消費したもちもの',
                    ),
                  ),
                  autoFlipDirection: true,
                  suggestionsCallback: (pattern) async {
                    List<Item> matches = [];
                    Item? holdingItem = playerType.id == PlayerType.me ? ownPokemonState.holdingItem : opponentPokemonState.holdingItem;
                    if (playerType.id == PlayerType.opponent) {
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
                      matches = [ownPokemonState.holdingItem!];
                    }
                    matches.retainWhere((s){
                      return toKatakana(s.displayName.toLowerCase()).contains(toKatakana(pattern.toLowerCase()));
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
                ),
              ),
            ],
          );
          // TODO controllerの数足りてない
          effectInputRow2 = appState.pokeData.items[extraArg1[continuousCount]]!.extraInputWidget(
            onFocus, playerType, ownPokemon, opponentPokemon, ownPokemonState, opponentPokemonState, ownParty, opponentParty,
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
          );
          break;
        case 464:     // どく・まひ・ねむりのいずれかにする(確率)
          effectInputRow = Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '追加効果',
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: MoveEffect.none,
                      child: Text('なし'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.poison,
                      child: Text('相手はどくにかかった'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.paralysis,
                      child: Text('相手はしびれてしまった'),
                    ),
                    DropdownMenuItem(
                      value: Ailment.sleep,
                      child: Text('相手はねむってしまった'),
                    ),
                  ],
                  value: extraArg1[continuousCount],
                  onChanged: (value) {
                    extraArg1[continuousCount] = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
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
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '交代先ポケモン',
                  ),
                  items: playerType.id == PlayerType.me ?
                    <DropdownMenuItem>[
                      for (int i = 0; i < ownParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleBattling(playerType, i) && !state.getPokemonStates(playerType)[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: getChangePokemonIndex(playerType),
                  onChanged: (value) {
                    setChangePokemonIndex(playerType, value);
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
          effectInputRow2 = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  controller: hpController2,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: playerType.id == PlayerType.me ? 
                      '${ownPokemon.name}の残りHP' : '${opponentPokemon.name}の残りHP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTap: () => onFocus(),
                  onChanged: (value) {
                    if (playerType.id == PlayerType.me) {
                      extraArg1[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                    }
                    else {
                      extraArg2[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                    }
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
              playerType.id == PlayerType.me ?
              Flexible(child: Text('/${ownPokemon.h.real}')) :
              Flexible(child: Text('% /100%'))
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
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: '復活させるポケモン',
                      ),
                      items: playerType.id == PlayerType.me ?
                        <DropdownMenuItem>[
                          for (int i = 0; i < ownParty.pokemonNum; i++)
                            DropdownMenuItem(
                              value: i+1,
                              enabled: state.isPossibleBattling(playerType, i) && ownPokemonStates[i].isFainting,
                              child: Text(
                                ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: state.isPossibleBattling(playerType, i) && ownPokemonStates[i].isFainting ?
                                  Colors.black : Colors.grey),
                                ),
                            ),
                        ] :
                        <DropdownMenuItem>[
                          for (int i = 0; i < opponentParty.pokemonNum; i++)
                            DropdownMenuItem(
                              value: i+1,
                              enabled: state.isPossibleBattling(playerType, i) && opponentPokemonStates[i].isFainting,
                              child: Text(
                                opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: state.isPossibleBattling(playerType, i) && opponentPokemonStates[i].isFainting ?
                                  Colors.black : Colors.grey),
                                ),
                            ),
                        ],
                      value: extraArg1[continuousCount] != 0 ? extraArg1[continuousCount] : null,
                      onChanged: (value) {
                        extraArg1[continuousCount] = value;
                        appState.editingPhase[phaseIdx] = true;
                        onFocus();
                      },
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
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: '成否',
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: true,
                              child: Text('成功'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('うまくきまらなかった！'),
                            ),
                          ],
                          value: isSuccess,
                          onChanged: (value) {
                            isSuccess = value;
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
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
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: '成否',
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: false,
                              child: Text('うまくきまらなかった！'),
                            ),
                          ],
                          value: false,
                          onChanged: null,
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
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: '命中/失敗',
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: MoveHit.hit,
                              child: Text('命中'),
                            ),
                            DropdownMenuItem(
                              value: MoveHit.critical,
                              child: Text('急所に命中'),
                            ),
                            DropdownMenuItem(
                              value: MoveHit.notHit,
                              child: Text('当たらなかった'),
                            ),
                            DropdownMenuItem(
                              value: MoveHit.fail,
                              child: Text('うまく決まらなかった'),
                            ),
                          ],
                          value: moveHits[continuousCount].id,
                          onChanged: (value) {
                            moveHits[continuousCount] = MoveHit(value);
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: '効果',
                          ),
                          items: <DropdownMenuItem<int>>[
                            DropdownMenuItem(
                              value: MoveEffectiveness.normal,
                              child: Text('（テキストなし）', overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.great,
                              child: Text('ばつぐんだ', overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.notGood,
                              child: Text('いまひとつのようだ', overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: MoveEffectiveness.noEffect,
                              child: Text('ないようだ', overflow: TextOverflow.ellipsis,),
                            ),
                          ],
                          value: moveEffectivenesses[continuousCount].id,
                          onChanged: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail ? (value) {
                            moveEffectivenesses[continuousCount] = MoveEffectiveness(value!);
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          } : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  effectInputRow,
                  SizedBox(height: 10,),
                  yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: hpController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: playerType.id == PlayerType.me ? 
                              '${opponentPokemon.name}の残りHP' : '${ownPokemon.name}の残りHP',
                          ),
                          enabled: moveHits[continuousCount].id != MoveHit.notHit && moveHits[continuousCount].id != MoveHit.fail,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onTap: () => onFocus(),
                          onChanged: (value) {
                            if (playerType.id == PlayerType.me) {
                              percentDamage[continuousCount] = opponentPokemonState.remainHPPercent - (int.tryParse(value)??0);
                            }
                            else {
                              realDamage[continuousCount] = ownPokemonState.remainHP - (int.tryParse(value)??0);
                            }
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
                        ),
                      ),
                      playerType.id == PlayerType.me ?
                      Flexible(child: Text('% /100%')) :
                      Flexible(child: Text('/${ownPokemon.h.real}')),
                      SizedBox(width: 10,),
                      playerType.id == PlayerType.me ?
                        percentDamage[continuousCount] >= 0 ?
                        Flexible(child: Text('= ダメージ ${percentDamage[continuousCount]}%')) :
                        Flexible(child: Text('= 回復 ${-percentDamage[continuousCount]}%')) :
                        realDamage[continuousCount] >= 0 ?
                        Flexible(child: Text('= ダメージ ${realDamage[continuousCount]}')) :
                        Flexible(child: Text('= 回復 ${-realDamage[continuousCount]}')),
                    ],
                  ) :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'みがわり',
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 0,
                              child: Text('みがわりはのこった', overflow: TextOverflow.ellipsis,),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('みがわりはこわれてしまった', overflow: TextOverflow.ellipsis,),
                            ),
                          ],
                          value: realDamage[continuousCount],
                          onChanged: (value) {
                            realDamage[continuousCount] = value;
                            appState.editingPhase[phaseIdx] = true;
                            onFocus();
                          },
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

  // 行動が確定するなら自動で設定する。自動で設定した場合はtrueを返す
  bool fillAuto(PhaseState state) {
    var myState = state.getPokemonState(playerType, null);
    var yourState = state.getPokemonState(playerType.opposite, null);
    final pokeData = PokeDB();
    bool ret = false;
    bool isMoveChanged = false;

    // ねむり
    if (myState.ailmentsWhere((e) => e.id == Ailment.sleep).isNotEmpty) {
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
      moveAdditionalEffects[0] = move.isSurelyEffect() && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isEmpty ? MoveEffect(move.effect.id) : MoveEffect(0);
      moveEffectivenesses[0] = PokeType.effectiveness(
        myState.currentAbility.id == 113, yourState.holdingItem?.id == 586,
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
        ret = myState.teraType != null ? myState.teraType! : myState.type1;
        break;
      case 437:   // 使用者のフォルムがはらぺこもようのときはタイプがあくになる。使用者のすばやさを1段階上げる
        if (myState.buffDebuffs.where((e) => e.id == BuffDebuff.harapekoForm).isNotEmpty) {
          ret = PokeType.createFromId(17);
        }
        break;
      case 444:   // テラスタルしている場合はわざのタイプがテラスタイプに変わる。
                  // ランク補正込みのステータスがこうげき>とくこうなら物理技になる
        if (myState.teraType != null) {
          ret = myState.teraType!;
        }
        break;
      case 453:   // フィールドの効果を受けているとき威力2倍・わざのタイプが変わる
        if (myState.isGround(playerType.id == PlayerType.me ? state.ownFields : state.opponentFields)) {
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

  void clear() {
    playerType = PlayerType(PlayerType.none);
    type = TurnMoveType(TurnMoveType.none);
    teraType = PokeType.createFromId(0);
    move = Move(0, '', PokeType.createFromId(0), 0, 0, 0, Target(0), DamageClass(0), MoveEffect(0), 0, 0);
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
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnMove deserialize(dynamic str, String split1, String split2) {
    TurnMove turnMove = TurnMove();
    final turnMoveElements = str.split(split1);
    // playerType
    turnMove.playerType = PlayerType(int.parse(turnMoveElements[0]));
    // type
    turnMove.type = TurnMoveType(int.parse(turnMoveElements[1]));
    // teraType
    turnMove.teraType = PokeType.createFromId(int.parse(turnMoveElements[2]));
    // move
    var moveElements = turnMoveElements[3].split(split2);
    turnMove.move = Move(
      int.parse(moveElements[0]),
      moveElements[1],
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

    return turnMove;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    // playerType
    ret += playerType.id.toString();
    ret += split1;
    // type
    ret += type.id.toString();
    ret += split1;
    // teraType
    ret += teraType.id.toString();
    ret += split1;
    // move
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

    return ret;
  }

  bool isValid() {
    if (!isSuccess) {
      return playerType.id != PlayerType.none && actionFailure.id != 0;
    }
    switch (type.id) {
      case TurnMoveType.move:
        return
        playerType.id != PlayerType.none &&
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