import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_effect.dart';
import 'package:poke_reco/tool.dart';

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
  int? changePokemonIndex;
  int? targetMyPokemonIndex;   // わざの対象ポケモン

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
    ..changePokemonIndex = changePokemonIndex
    ..targetMyPokemonIndex = targetMyPokemonIndex;

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
    2: 'ねむってしまった',
    3: 'どくにかかった',
    5: 'やけどをおった',
    6: 'こおってしまった',
    7: 'しびれてしまった',
    32: 'ひるんで技がだせない',
    50: 'こんらんした',
    69: 'こうげきが下がった',
    70: 'ぼうぎょが下がった',
    71: 'すばやさが下がった',
    72: 'とくこうが下がった',
    73: 'とくぼうが下がった',
    74: '命中率が下がった',
    77: 'こんらんした',
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
    List<String> ret = [];
    if (playerType.id == PlayerType.none) return ret;

    // こうさん
    if (type.id == TurnMoveType.surrender) {
      if (playerType.id == PlayerType.me) {   // パーティ全員ひんし状態にする
        for (var pokeState in state.ownPokemonStates) {
          pokeState.remainHP = 0;
          pokeState.isFainting = true;
        }
      }
      else if (playerType.id == PlayerType.opponent) {
        for (var pokeState in state.opponentPokemonStates) {
          pokeState.remainHPPercent = 0;
          pokeState.isFainting = true;
        }
      }
      return ret;
    }

    // わざ確定
    var tmp = opponentPokemonState.moves.where(
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

    // テラスタル
    if (teraType.id != 0) {
      if (playerType.id == PlayerType.me) {
        ownPokemonState.teraType ??= teraType;
      }
      else {
        opponentPokemonState.teraType ??= teraType;
      }
    }

    if (!isSuccess) return ret;

    // ポケモン交代
    if (type.id == TurnMoveType.change) {
      // のうりょく変化リセット、現在のポケモンを表すインデックス更新
      if (playerType.id == PlayerType.me) {
        ownPokemonState.processExitEffect(true, state.opponentPokemonState);
        state.ownPokemonIndex = changePokemonIndex!;
        state.ownPokemonState.processEnterEffect(true, state.weather, state.field, state.opponentPokemonState);
      }
      else {
        opponentPokemonState.processExitEffect(false, state.ownPokemonState);
        state.opponentPokemonIndex = changePokemonIndex!;
        state.opponentPokemonState.processEnterEffect(false, state.weather, state.field, state.ownPokemonState);
      }
      return ret;
    }

    if (move.id == 0) return ret;

    PokemonState myState = playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    PokemonState yourState = playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    int myPlayerTypeID = playerType.id;
    int yourPlayerTypeID = playerType.id == PlayerType.me ? PlayerType.opponent : PlayerType.me;

    // ミクルのみのこうかが残っていれば消費
    int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onceAccuracy1_2);
    if (findIdx >= 0) myState.buffDebuffs.removeAt(findIdx);
    // ノーマルジュエル消費
    if (myState.holdingItem?.id == 669 && move.damageClass.id >= 2 && move.type.id == 1) {
      myState.holdingItem = null;
    }
    // くっつきバリ移動
    if (move.isDirect && myState.holdingItem == null && yourState.holdingItem?.id == 265) {
      myState.holdingItem = yourState.holdingItem;
      yourState.holdingItem = null;
    }

    // わざの対象決定
    List<PokemonState> targetStates = [yourState];
    List<int> targetPlayerTypeIDs = [yourPlayerTypeID];
    PhaseState? targetField;
    switch (move.target.id) {
      case 1:     // TODO:わざによって異なる？
        break;
      case 2:     // 選択した自分以外の場にいるポケモン(TODO:10との違い？)
        break;
      case 3:     // 味方(存在する場合)
        break;
      case 4:     // 使用者の場
        targetStates = [myState];
        targetPlayerTypeIDs = [myPlayerTypeID];
        break;
      case 5:     // 使用者もしくは味方
        targetStates = [myState];
        targetPlayerTypeIDs = [myPlayerTypeID];
        break;
      case 6:     // 相手の場
        break;
      case 7:     // 使用者自身
        targetStates = [myState];
        targetPlayerTypeIDs = [myPlayerTypeID];
        break;
      case 8:     // ランダムな相手
        break;
      case 9:     // 場にいる使用者以外の全ポケモン
        break;
      case 10:    // 選択した自分以外の場にいるポケモン
        break;
      case 11:    // 場にいる相手側の全ポケモン
        break;
      case 12:    // 全体の場
        targetStates = [];
        targetField = state;
        break;
      case 13:    // 使用者と味方
        targetStates = [myState];
        targetPlayerTypeIDs = [myPlayerTypeID];
        break;
      case 14:    // 場にいるすべてのポケモン
        targetStates.add(myState);
        targetPlayerTypeIDs.add(myPlayerTypeID);
        break;
      case 15:    // すべての味方
        targetStates.clear();
        targetPlayerTypeIDs.clear();  // 使わない
        for (int i = 0; i < state.ownPokemonStates.length; i++) {
          if (i != state.ownPokemonIndex-1 && !state.ownPokemonStates[i].isFainting) {
            targetStates.add(state.ownPokemonStates[i]);
            targetPlayerTypeIDs.add(myPlayerTypeID);
          }
        }
        break;
      case 16:    // ひんしの(味方)ポケモン
        targetStates.clear();
        targetPlayerTypeIDs.clear();  // 使わない
        for (int i = 0; i < state.ownPokemonStates.length; i++) {
          if (i != state.ownPokemonIndex-1 && state.ownPokemonStates[i].isFainting) {
            targetStates.add(state.ownPokemonStates[i]);
            targetPlayerTypeIDs.add(myPlayerTypeID);
          }
        }
        break;
      default:
        break;
    }

    switch (move.damageClass.id) {
      case 1:     // へんか
        break;
      case 2:     // ぶつり
      case 3:     // とくしゅ
        // ダメージを負わせる
        for (var targetState in targetStates) {
          targetState.remainHP -= realDamage[continuousCount];
          targetState.remainHPPercent -= percentDamage[continuousCount];
        }
        break;
      default:
        break;
    }

    // 追加効果
    for (int i = 0; i < targetStates.length; i++) {
      var targetState = targetStates[i];
      var targetPlayerTypeID = targetPlayerTypeIDs[i];
      switch (moveAdditionalEffects[continuousCount].id) {
        case 1:     // 特殊効果なし
          break;
        case 2:     // 眠らせる
          targetState.ailmentsAdd(Ailment(Ailment.sleep), state.weather, state.field);
          break;
        case 3:     // どくにする(確率)
        case 67:    // どくにする
        case 78:    // 2回こうげき、どくにする(確率)
          targetState.ailmentsAdd(Ailment(Ailment.poison), state.weather, state.field);
          break;
        case 4:     // 与えたダメージの半分だけHP回復
          myState.remainHP -= extraArg1[continuousCount];
          myState.remainHPPercent -= extraArg2[continuousCount];
          break;
        case 5:     // やけどにする(確率)
          targetState.ailmentsAdd(Ailment(Ailment.burn), state.weather, state.field);
          break;
        case 6:     // こおりにする(確率)
          targetState.ailmentsAdd(Ailment(Ailment.freeze), state.weather, state.field);
          break;
        case 7:     // まひにする(確率)
        case 68:    // まひにする
          targetState.ailmentsAdd(Ailment(Ailment.paralysis), state.weather, state.field);
          break;
        case 8:     // 使用者はひんしになる
          myState.remainHP = 0;
          myState.remainHPPercent = 0;
          myState.isFainting = true;
          break;
        case 9:     // ねむり状態の対象にのみダメージ、与えたダメージの半分だけHP回復
          myState.remainHP -= extraArg1[continuousCount];
          myState.remainHPPercent -= extraArg2[continuousCount];
          break;
        case 10:    // 対象が最後に使ったわざを使う
          // TODO
          break;
        case 11:    // 使用者のこうげきを1段階上げる
          myState.addStatChanges(true, 0, 1, targetState, moveId: move.id);
          break;
        case 12:    // 使用者のぼうぎょを1段階上げる
          myState.addStatChanges(true, 1, 1, targetState, moveId: move.id);
          break;
        case 14:    // 使用者のとくこうを1段階上げる
          myState.addStatChanges(true, 2, 1, targetState, moveId: move.id);
          break;
        case 17:    // 使用者のかいひを1段階上げる
          myState.addStatChanges(true, 6, 1, targetState, moveId: move.id);
          break;
        case 18:    // 必中
        case 79:    // 必中
          break;
        case 19:    // こうげきを1段階下げる
        case 69:    // こうげきを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 0, -1, myState, moveId: move.id);
          break;
        case 20:    // ぼうぎょを1段階下げる
        case 70:    // ぼうぎょを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 1, -1, myState, moveId: move.id);
          break;
        case 21:    // すばやさを1段階下げる
        case 71:    // すばやさを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 4, -1, myState, moveId: move.id);
          break;
        case 24:    // めいちゅうを1段階下げる
        case 74:    // めいちゅうを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 5, -1, myState, moveId: move.id);
          break;
        case 25:    // かいひを1段階下げる
          targetState.addStatChanges(targetState == myState, 6, -1, myState, moveId: move.id);
          break;
        case 26:    // すべての能力ランクを0にリセットする
          targetState.resetStatChanges();
          break;
        case 27:    // 2ターン後の自身の行動までがまん状態になり、その間受けた合計ダメージの2倍を相手に返す
          myState.ailmentsAdd(Ailment(Ailment.bide), state.weather, state.field);
          // TODO
          break;
        case 28:    // 2～3ターンの間あばれる状態になり、攻撃し続ける。攻撃終了後、自身がこんらん状態となる
          myState.ailmentsAdd(Ailment(Ailment.thrash), state.weather, state.field);
          // TODO
          break;
        case 29:    // 相手ポケモンをランダムに交代させる
          if (extraArg1[continuousCount] != 0) {
            targetState.processExitEffect(targetPlayerTypeID == PlayerType.me, myState);
            if (playerType.id == PlayerType.me) {
              state.opponentPokemonIndex = extraArg1[continuousCount];
            }
            else {
              state.ownPokemonIndex = extraArg1[continuousCount];
            }
            targetState.processEnterEffect(targetPlayerTypeID == PlayerType.me, state.weather, state.field, myState);
          }
          break;
        case 30:    // 2～5回こうげきする
          break;
        case 31:    // 使用者のタイプを変更する
          if (extraArg1[continuousCount] != 0) {
            myState.type1 = PokeType.createFromId(extraArg1[continuousCount]);
            myState.type2 = null;
          }
          break;
        case 32:    // ひるませる(確率)
          targetState.ailmentsAdd(Ailment(Ailment.flinch), state.weather, state.field);
          break;
        case 33:    // 最大HPの半分まで回復する
          myState.remainHP -= extraArg1[continuousCount];
          myState.remainHPPercent -= extraArg2[continuousCount];
          break;
        case 34:    // もうどくにする
          targetState.ailmentsAdd(Ailment(Ailment.badPoison), state.weather, state.field);
          break;
        case 35:    // 戦闘後おかねを拾える
          break;
        case 36:    // 場に「ひかりのかべ」を発生させる
          int findIdx = targetState.fields.indexWhere((e) => e.id == IndividualField.lightScreen);
          if (findIdx < 0) targetState.fields.add(IndividualField(IndividualField.lightScreen));
          break;
        case 37:    // やけど・こおり・まひのいずれかにする(確率)
          if (extraArg1[continuousCount] != 0) {
            targetState.ailmentsAdd(Ailment(extraArg1[continuousCount]), state.weather, state.field);
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
          targetState.ailmentsAdd(Ailment(Ailment.sleep), state.weather, state.field);
          break;
        case 39:    // 一撃必殺
          targetState.remainHP = 0;
          targetState.remainHPPercent = 0;
          targetState.isFainting = true;
          break;
        case 40:    // 1ターン目にため、2ターン目でこうげきする
          // TODO
          break;
        case 41:    // 残りHPの半分のダメージ(残り1の場合は1)
          break;
        case 42:    // 40の固定ダメージ
          break;
        case 43:    // バインド状態にする
          targetState.ailmentsAdd(Ailment(Ailment.partiallyTrapped), state.weather, state.field);
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
          int findIdx = targetState.fields.indexWhere((e) => e.id == IndividualField.mist);
          if (findIdx < 0) targetState.fields.add(IndividualField(IndividualField.mist));
          break;
        case 48:    // 使用者の急所ランク+1
          myState.addVitalRank(1);
          break;
        case 49:    // 使用者は相手に与えたダメージの1/4ダメージを受ける
          myState.remainHP -= extraArg1[continuousCount];
          myState.remainHPPercent -= extraArg2[continuousCount];
          break;
        case 50:    // こんらんさせる
        case 77:    // こんらんさせる(確率)
          targetState.ailmentsAdd(Ailment(Ailment.confusion), state.weather, state.field);
          break;
        case 51:    // 使用者のこうげきを2段階上げる
          myState.addStatChanges(true, 0, 2, targetState, moveId: move.id);
          break;
        case 52:    // 使用者のぼうぎょを2段階上げる
          myState.addStatChanges(true, 1, 2, targetState, moveId: move.id);
          break;
        case 53:    // 使用者のすばやさを2段階上げる
          myState.addStatChanges(true, 4, 2, targetState, moveId: move.id);
          break;
        case 54:    // 使用者のとくこうを2段階上げる
          myState.addStatChanges(true, 2, 2, targetState, moveId: move.id);
          break;
        case 55:    // 使用者のとくこうを2段階上げる
          myState.addStatChanges(true, 3, 2, targetState, moveId: move.id);
          break;
        case 58:    // へんしん状態となる
          // TODO
          break;
        case 59:    // こうげきを2段階下げる
          targetState.addStatChanges(targetState == myState, 0, -2, myState, moveId: move.id);
          break;
        case 60:    // ぼうぎょを2段階下げる
          targetState.addStatChanges(targetState == myState, 1, -2, myState, moveId: move.id);
          break;
        case 61:    // すばやさを2段階下げる
          targetState.addStatChanges(targetState == myState, 4, -2, myState, moveId: move.id);
          break;
        case 62:    // とくこうを2段階下げる
          targetState.addStatChanges(targetState == myState, 2, -2, myState, moveId: move.id);
          break;
        case 63:    // とくぼうを2段階下げる
          targetState.addStatChanges(targetState == myState, 3, -2, myState, moveId: move.id);
          break;
        case 66:    // 場に「リフレクター」を発生させる
          int findIdx = targetState.fields.indexWhere((e) => e.id == IndividualField.reflector);
          if (findIdx < 0) targetState.fields.add(IndividualField(IndividualField.reflector));
          break;
        case 72:    // とくこうを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 2, -1, myState, moveId: move.id);
          break;
        case 73:    // とくぼうを1段階下げる(確率)
          targetState.addStatChanges(targetState == myState, 3, -1, myState, moveId: move.id);
          break;
        case 76:    // 1ターン目は攻撃せず、2ターン目に攻撃。ひるませる(確率)
          // TODO
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
          // TODO
          break;
        case 82:    // 使用者はいかり状態になる
          int findIdx = myState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rage);
          if (findIdx < 0) targetState.buffDebuffs.add(BuffDebuff(BuffDebuff.rage));
          break;
        default:
          break;
      }
    }
    /*switch (moveAdditionalEffects[continousCount].id) {
      case MoveAdditionalEffect.speedDown:
        additionalEffectTargetState.addStatChanges(false, 4, -1, myState, moveId: move.id);
        break;
      default:
        break;
    }*/

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
    PokeDB pokeData,
    MyAppState appState,
    int phaseIdx,
  )
  {
    // 交代先ポケモンがいるかどうか
    int count = 0;
    if (playerType.id == PlayerType.me) {
      for (int i = 0; i < ownParty.pokemonNum; i++) {
        if (state.isPossibleOwnBattling(i) &&
            !state.ownPokemonStates[i].isFainting &&
            i != ownParty.pokemons.indexWhere((element) => element == ownPokemon)
        ) {
          count++;
        }
      }
    }
    else if (playerType.id == PlayerType.opponent) {
      for (int i = 0; i < opponentParty.pokemonNum; i++) {
        if (state.isPossibleOpponentBattling(i) &&
            !state.opponentPokemonStates[i].isFainting &&
            i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon)
        ) {
          count++;
        }
      }
    }
    // 相手のポケモンのとくせいによって交代可能かどうか
    var myState = playerType.id == PlayerType.me ? ownPokemonState : opponentPokemonState;
    var yourState = playerType.id == PlayerType.me ? opponentPokemonState : ownPokemonState;
    bool isShadowTag = !myState.isTypeContain(8) &&    // ゴーストタイプではない
      (yourState.currentAbility.id == 23 ||                                     // 相手がかげふみ
       (yourState.currentAbility.id == 42 && myState.isTypeContain(9)) ||       // 相手がじりょく＆自身がはがね
       (yourState.currentAbility.id == 71 && myState.isGround)                  // 相手がありじごく＆自身が地面にいる
      );
    bool canChange = count >= 1 && !isShadowTag;

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
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '行動の種類',
              ),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(
                  value: TurnMoveType.move,
                  child: Text('わざ', overflow: TextOverflow.ellipsis,),
                ),
                DropdownMenuItem(
                  enabled: canChange,
                  value: TurnMoveType.change,
                  child: Text('ポケモン交代', overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: canChange ? Colors.black : Colors.grey),),
                ),
                DropdownMenuItem(
                  value: TurnMoveType.surrender,
                  child: Text('こうさん', overflow: TextOverflow.ellipsis,),
                ),
              ],
              value: type.id == TurnMoveType.none ? null : type.id,
              onChanged: playerType.id != PlayerType.none ? (value) {
                type = TurnMoveType(value as int);
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              } : null,
            ),
          ),
          SizedBox(width: 10,),
          type.id == TurnMoveType.move ?     // 行動がわざの場合
          Expanded(
            flex: 5,
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
                moveAdditionalEffects[0] = MoveEffect(move.effect.id);
                moveEffectivenesses[0] = PokeType.effectiveness(
                    myState.currentAbility.id == 113, yourState.holdingItem?.id == 586, move.type, yourState.type1, yourState.type2);
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
            ),
          ) :
          type.id == TurnMoveType.change ?     // 行動が交代の場合
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
                      enabled: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon),
                      child: Text(
                        ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting && i != ownParty.pokemons.indexWhere((element) => element == ownPokemon) ?
                          Colors.black : Colors.grey),
                        ),
                    ),
                ] :
                <DropdownMenuItem>[
                  for (int i = 0; i < opponentParty.pokemonNum; i++)
                    DropdownMenuItem(
                      value: i+1,
                      enabled: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon),
                      child: Text(
                        opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting && i != opponentParty.pokemons.indexWhere((element) => element == opponentPokemon) ?
                          Colors.black : Colors.grey),
                        ),
                    ),
                ],
              value: changePokemonIndex,
              onChanged: (value) {
                changePokemonIndex = value;
                appState.editingPhase[phaseIdx] = true;
                onFocus();
              },
            ),
          ) :
          // 行動がにげる/こうさんのとき
          Container(),
        ],
      );
    }
  }

  Widget terastalInputWidget(
    void Function() onFocus,
    MyAppState appState,
    Pokemon ownPokemon,
    bool alreadyTerastal,
  )
  {
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
                    teraType = appState.pokeData.types[0];  // とりあえずノーマル
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
              appState.pokeData,
              'タイプ',
              teraType.id == 0 || alreadyTerastal || playerType.id == PlayerType.me ?
                null : (val) {teraType = appState.pokeData.types[val - 1];},
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
    MyAppState appState,
    int phaseIdx,
    int continuousCount,
  )
  {
    if (playerType.id != PlayerType.none && type.id == TurnMoveType.move) {
      // 追加効果
      Row effectInputRow = Row();
      Row effectInputRow2 = Row();
      switch (move.effect.id) {
        //case 2:     // 眠らせる
        case 3:     // どくにする(確率)
        case 5:     // やけどにする(確率)
        case 6:     // こおりにする(確率)
        case 7:     // まひにする(確率)
        //case 19:    // こうげきを1段階下げる
        //case 20:    // ぼうぎょを1段階下げる
        //case 21:    // すばやさを1段階下げる
        //case 24:    // めいちゅうを1段階下げる
        //case 25:    // かいひを1段階下げる
        case 32:    // ひるませる(確率)
        //case 34:    // もうどくにする
        //case 50:    // こんらんさせる
        //case 59:    // こうげきを2段階下げる
        //case 60:    // ぼうぎょを2段階下げる
        //case 61:    // すばやさを2段階下げる
        //case 62:    // とくこうを2段階下げる
        //case 63:    // とくぼうを2段階下げる
        //case 67:    // どくにする
        //case 68:    // まひにする
        case 69:    // こうげきを1段階下げる(確率)
        case 70:    // ぼうぎょを1段階下げる(確率)
        case 71:    // すばやさを1段階下げる(確率)
        case 72:    // とくこうを1段階下げる(確率)
        case 73:    // とくぼうを1段階下げる(確率)
        case 74:    // めいちゅうを1段階下げる(確率)
        case 78:    // 2回こうげき、どくにする(確率)
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
                      value: move.effect.id,
                      child: Text('相手は${moveEffectText[move.effect.id]!}'),
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
        case 33:    // 最大HPの半分まで回復する
        case 49:    // 使用者は相手に与えたダメージの1/4ダメージを受ける
        case 80:    // 場に「みがわり」を発生させる
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
        //case 11:    // 使用者のこうげきを1段階上げる
        //case 12:    // 使用者のぼうぎょを1段階上げる
        //case 14:    // 使用者のとくこうを1段階上げる
        //case 17:    // 使用者のかいひを1段階上げる
        //case 51:    // 使用者のこうげきを2段階上げる
        //case 52:    // 使用者のぼうぎょを2段階上げる
        //case 53:    // 使用者のすばやさを2段階上げる
        //case 54:    // 使用者のとくこうを2段階上げる
        //case 55:    // 使用者のとくこうを2段階上げる
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
                      value: move.effect.id,
                      child: Text('自身は${moveEffectText[move.effect.id]!}'),
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
        case 29:    // 相手ポケモンをランダムに交代させる
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
                          enabled: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOwnBattling(i) && !state.ownPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOpponentBattling(i) && !state.opponentPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
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
        case 31:    // 使用者のタイプを変更する
          effectInputRow = Row(
            children: [
              Expanded(
                child: TypeDropdownButton(
                  appState.pokeData,
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
        case 46:    // わざを外すと使用者にダメージ
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
        case 148:   // 相手が「あなをほる」状態でも命中し、ダメージ2倍
        default:
          break;
      }

      switch (move.target.id) {
        case 7:   // 自分自身 -> 成功/失敗
          return Row(
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
          );
        case 8:       // ランダムな相手1体
        case 9:       // 場の他のポケモン全員
        case 10:      // 選択した相手
          return Column(
            children: [
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
                  Flexible(child: Text('/${ownPokemon.h.real}'))
                ],
              ),
              SizedBox(height: 10,),
              effectInputRow2,
            ],
          );
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
                          enabled: state.isPossibleOwnBattling(i) && ownPokemonStates[i].isFainting,
                          child: Text(
                            ownParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOwnBattling(i) && ownPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ] :
                    <DropdownMenuItem>[
                      for (int i = 0; i < opponentParty.pokemonNum; i++)
                        DropdownMenuItem(
                          value: i+1,
                          enabled: state.isPossibleOpponentBattling(i) && opponentPokemonStates[i].isFainting,
                          child: Text(
                            opponentParty.pokemons[i]!.name, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: state.isPossibleOpponentBattling(i) && opponentPokemonStates[i].isFainting ?
                              Colors.black : Colors.grey),
                            ),
                        ),
                    ],
                  value: targetMyPokemonIndex,
                  onChanged: (value) {
                    targetMyPokemonIndex = value;
                    appState.editingPhase[phaseIdx] = true;
                    onFocus();
                  },
                ),
              ),
            ],
          );
        default:
          break;
      }
    }

    return Container();
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
    changePokemonIndex = null;
    targetMyPokemonIndex = null;
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
    // changePokemonIndex
    if (turnMoveElements[13] != '') {
      turnMove.changePokemonIndex = int.parse(turnMoveElements[11]);
    }
    // targetMyPokemonIndex
    if (turnMoveElements[14] != '') {
      turnMove.targetMyPokemonIndex = int.parse(turnMoveElements[12]);
    }

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
    // changePokemonIndex
    if (changePokemonIndex != null) {
      ret += changePokemonIndex.toString();
    }
    ret += split1;
    // targetMyPokemonIndex
    if (targetMyPokemonIndex != null) {
      ret += targetMyPokemonIndex.toString();
    }

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
        return changePokemonIndex != null;
      case TurnMoveType.surrender:
        return true;
      default:
        return false;
    }
  }
}