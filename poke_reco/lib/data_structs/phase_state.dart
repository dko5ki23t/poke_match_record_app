import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/poke_move.dart';

// ある時点(ターン内のフェーズ)での状態
class PhaseState {
  int ownPokemonIndex = 0;          // 0は無効値
  int opponentPokemonIndex = 0;     // 0は無効値
  List<PokemonState> ownPokemonStates = [];
  List<PokemonState> opponentPokemonStates = [];
  Weather _weather = Weather(0);
  Field _field = Field(0);

  Weather get weather => _weather;
  Field get field => _field;
  int get ownFaintingNum => ownPokemonStates.where((e) => e.isFainting).length;
  int get opponentFaintingNum => opponentPokemonStates.where((e) => e.isFainting).length;

  set weather(Weather w) {
    Weather.processWeatherEffect(_weather, w, ownPokemonState, opponentPokemonState);

    _weather = w;
  }
  set field(Field f) {
    Field.processFieldEffect(_field, f, ownPokemonState, opponentPokemonState);

    _field = f;
  }

  void forceSetWeather(Weather w) {
    _weather = w;
  }
  void forceSetField(Field f) {
    _field = f;
  }

  PhaseState copyWith() =>
    PhaseState()
    ..ownPokemonIndex = ownPokemonIndex
    ..opponentPokemonIndex = opponentPokemonIndex
    ..ownPokemonStates = [
      for (final state in ownPokemonStates)
      state.copyWith()
    ]
    ..opponentPokemonStates = [
      for (final state in opponentPokemonStates)
      state.copyWith()
    ]
    ..weather = weather.copyWith()
    ..field = field.copyWith();
  
  PokemonState get ownPokemonState => ownPokemonStates[ownPokemonIndex-1];
  PokemonState get opponentPokemonState => opponentPokemonStates[opponentPokemonIndex-1];
  bool get hasOwnTerastal => ownPokemonStates.where((element) => element.teraType != null).isNotEmpty;
  bool get hasOpponentTerastal => opponentPokemonStates.where((element) => element.teraType != null).isNotEmpty;
  bool get isMyWin {
    var n = opponentPokemonStates.where((element) => element.isFainting).length;
    return n >= 3 || n >= opponentPokemonStates.length;
  }
  bool get isYourWin {
    var n = ownPokemonStates.where((element) => element.isFainting).length;
    return n >= 3 || n >= ownPokemonStates.length;
  }
  
  // 対戦に登場する3匹が確定していた場合、対象のポケモンが登場しているかどうか
  // 3匹が確定していない場合は常にtrue
  bool isPossibleOwnBattling(int i) {
    if (ownPokemonStates.where((element) => element.isBattling).length < 3) {
      return true;
    }
    return ownPokemonStates[i].isBattling;
  }
  bool isPossibleOpponentBattling(int i) {
    if (opponentPokemonStates.where((element) => element.isBattling).length < 3) {
      return true;
    }
    return opponentPokemonStates[i].isBattling;
  }

  // 現在の状態で、指定されたタイミングで起こるべき効果のリストを返す
  List<TurnEffect> getDefaultEffectList(
    Turn currentTurn, AbilityTiming timing, bool changedOwn, bool changedOpponent,
    TurnEffect? prevAction, int continuousCount
  ) {
    List<TurnEffect> ret = [];
    var attackerState = ownPokemonState;
    var defenderState = opponentPokemonState;
    var attackerPlayerTypeId = PlayerType.me;
    var defenderPlayerTypeId = PlayerType.opponent;
    if (prevAction != null && prevAction.playerType.id == PlayerType.opponent) {
      attackerState = opponentPokemonState;
      defenderState = ownPokemonState;
      attackerPlayerTypeId = PlayerType.opponent;
      defenderPlayerTypeId = PlayerType.me;
    }
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:   // ポケモン登場時
        {
          // ポケモン登場時には無条件で発動する効果
          var timingIDs = [AbilityTiming.pokemonAppear];
          // ポケモン登場時&天気がxxでない
          if (weather.id != Weather.rainy) timingIDs.add(AbilityTiming.pokemonAppearNotRained);
          if (weather.id != Weather.sandStorm) timingIDs.add(AbilityTiming.pokemonAppearNotSandStormed);
          if (weather.id != Weather.sunny) timingIDs.add(AbilityTiming.pokemonAppearNotSunny);
          if (weather.id != Weather.snowy) timingIDs.add(AbilityTiming.pokemonAppearNotSnowed);
          // TODO アイテムとかも
          // TODO 追加順はすばやさを考慮したい
          if (changedOwn) {
            if (timingIDs.contains(ownPokemonState.currentAbility.timing.id)) {
              int extraArg1 = 0;
              if (ownPokemonState.currentAbility.id == 36) {    // トレース
                extraArg1 = opponentPokemonState.currentAbility.id; 
              }
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.me)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = ownPokemonState.currentAbility.id
                ..extraArg1 = extraArg1
              );
            }
          }
          if (changedOpponent) {
            if (timingIDs.contains(opponentPokemonState.currentAbility.timing.id)) {
              int extraArg1 = 0;
              if (ownPokemonState.currentAbility.id == 36) {    // トレース
                extraArg1 = ownPokemonState.currentAbility.id;
              }
              ret.add(TurnEffect()
                ..playerType = PlayerType(PlayerType.opponent)
                ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                ..effect = EffectType(EffectType.ability)
                ..effectId = opponentPokemonState.currentAbility.id
                ..extraArg1 = extraArg1
              );
            }
          }
        }
        break;
      case AbilityTiming.afterMove:   // わざ使用後
        {
          var defenderTimingIDList = [];
          var attackerTimingIDList = [];
          int variedExtraArg1 = 0;
          if (prevAction != null && prevAction.move != null && prevAction.move!.isNormallyHit(continuousCount)) {  // わざ成功時
            if (prevAction.move!.move.damageClass.id == 1) {
              // へんかわざを受けた後
              defenderTimingIDList.add(AbilityTiming.statused);
            }
            if (prevAction.move!.move.damageClass.id >= 2) {
              // こうげきわざヒット後
              attackerTimingIDList.add(AbilityTiming.attackHitted);
              // ぶつりこうげきを受けた時
              if (prevAction.move!.move.damageClass.id == DamageClass.physical) {
                defenderTimingIDList.add(AbilityTiming.phisycalAttackedHitted);
              }
              // こうげきわざを受けた後
              defenderTimingIDList.add(AbilityTiming.attackedHitted);
              // こうげきわざを受けてひんしになったとき
              if (defenderState.isFainting) {
                defenderTimingIDList.add(AbilityTiming.attackedFainting);
              }
              // ノーマルタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 1) {
                defenderTimingIDList.add(148);
              }
              // あくタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 17) {
                defenderTimingIDList.addAll([86, 87]);
              }
              // みずタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 11) {
                defenderTimingIDList.addAll([92, 104]);
              }
              // ほのおタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 10) {
                defenderTimingIDList.addAll([104, 107]);
              }
              // でんきタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 13) {
                defenderTimingIDList.addAll([118]);
              }
              // こおりタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 15) {
                defenderTimingIDList.addAll([119]);
              }
              // ゴーストタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 8) {
                defenderTimingIDList.addAll([87]);
              }
              // むしタイプのこうげきをうけたとき
              if (prevAction.move!.move.type.id == 7) {
                defenderTimingIDList.addAll([92]);
              }
              // 直接こうげきを受けた後
              if (prevAction.move!.move.isDirect &&
                  !(prevAction.move!.move.isPunch && attackerState.holdingItem?.id == 1696) &&  // パンチグローブをつけたパンチわざでない
                  attackerState.currentAbility.id != 203    // とくせいがえんかくでない
              ) {
                // ぼうごパットで防がれないなら
                if (attackerState.holdingItem?.id != 897) {
                  defenderTimingIDList.addAll([AbilityTiming.directAttacked]);
                  // 直接攻撃によってひんしになった場合
                  if (defenderState.isFainting) {
                    defenderTimingIDList.addAll([AbilityTiming.directAttackedFainting]);
                  }
                }
              }
            }
            // 優先度1以上のわざを受けた後
            if (prevAction.move!.move.priority >= 1) {
              defenderTimingIDList.add(AbilityTiming.priorityMoved);
            }
            // 音技を受けた後
            if (prevAction.move!.move.isSound) {
              defenderTimingIDList.add(AbilityTiming.soundAttacked);
            }
            // HP吸収わざを受けた後
            if (prevAction.move!.move.isDrain) {
              defenderTimingIDList.add(AbilityTiming.drained);
            }
            if (prevAction.move!.move.type.id == 13) {    // でんきタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.electriced, AbilityTiming.electricUse]);
            }
            if (prevAction.move!.move.type.id == 11) {    // みずタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.watered, AbilityTiming.fireWaterAttackedSunnyRained, AbilityTiming.waterUse]);
              if (defenderState.currentAbility.id == 87) {   // かんそうはだ
                variedExtraArg1 = defenderPlayerTypeId == PlayerType.me ? -((ownPokemonState.pokemon.h.real / 4).floor()) : -25;
              }
            }
            if (prevAction.move!.move.type.id == 10) {    // ほのおタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.fired, AbilityTiming.fireWaterAttackedSunnyRained]);
            }
            if (prevAction.move!.move.type.id == 12) {    // くさタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grassed]);
            }
            if (prevAction.move!.move.type.id == 5) {    // じめんタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grounded]);
              if (prevAction.move!.move.id != 28 && prevAction.move!.move.id != 614) {  // すなかけ/サウザンアローではない
                defenderTimingIDList.addAll([AbilityTiming.groundFieldEffected]);
              }
            }
            if (PokeType.effectiveness(
                  attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
                  defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                  prevAction.move!.move.type, defenderState
                ).id == MoveEffectiveness.great
            ) {
              // 効果ばつぐんのわざを受けたとき
              defenderTimingIDList.addAll([AbilityTiming.greatAttacked]);
              var moveTypeId = prevAction.move!.move.type.id;
              if (moveTypeId == 10) defenderTimingIDList.add(131);
              if (moveTypeId == 11) defenderTimingIDList.add(132);
              if (moveTypeId == 13) defenderTimingIDList.add(133);
              if (moveTypeId == 12) defenderTimingIDList.add(134);
              if (moveTypeId == 15) defenderTimingIDList.add(135);
              if (moveTypeId == 2) defenderTimingIDList.add(136);
              if (moveTypeId == 4) defenderTimingIDList.add(137);
              if (moveTypeId == 5) defenderTimingIDList.add(138);
              if (moveTypeId == 3) defenderTimingIDList.add(139);
              if (moveTypeId == 14) defenderTimingIDList.add(140);
              if (moveTypeId == 7) defenderTimingIDList.add(141);
              if (moveTypeId == 6) defenderTimingIDList.add(142);
              if (moveTypeId == 8) defenderTimingIDList.add(143);
              if (moveTypeId == 16) defenderTimingIDList.add(144);
              if (moveTypeId == 17) defenderTimingIDList.add(145);
              if (moveTypeId == 9) defenderTimingIDList.add(146);
              if (moveTypeId == 18) defenderTimingIDList.add(147);
            }
            else {
              // 効果ばつぐん以外のわざを受けたとき
              defenderTimingIDList.addAll([AbilityTiming.notGreatAttacked]);
            }
          }

          // 対応するタイミングに該当するとくせい
          // TODO 追加順はすばやさを考慮したい
          if (attackerTimingIDList.contains(attackerState.currentAbility.timing.id)) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = attackerState.currentAbility.id
            );
          }
          if (defenderTimingIDList.contains(defenderState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (defenderState.currentAbility.id == 10 ||  // ちくでん
                defenderState.currentAbility.id == 11     // ちょすい
            ) {
              extraArg1 = defenderPlayerTypeId == PlayerType.me ? -((ownPokemonState.pokemon.h.real / 4).floor()) : -25;
            }
            if (defenderState.currentAbility.id == 16) {   // へんしょく
              extraArg1 = prevAction!.move!.move.type.id;
            }
            if (defenderState.currentAbility.id == 24 || defenderState.currentAbility.id == 160) {   // さめはだ/てつのトゲ
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 8).floor() : 12;
            }
            if (defenderState.currentAbility.id == 87) {    // かんそうはだ
              extraArg1 = variedExtraArg1;
            }
            if (defenderState.currentAbility.id == 106) {   // ゆうばく
                extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 4).floor() : 25;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = defenderState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }
          // 対応するタイミングに該当するもちもの
          if (attackerState.holdingItem != null && attackerTimingIDList.contains(attackerState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            if (attackerState.holdingItem!.id == 247) {   // いのちのたま
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 10).floor() : 10;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = attackerState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
          if (defenderState.holdingItem != null && defenderTimingIDList.contains(defenderState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            if (defenderState.holdingItem!.id == 583) {   // ゴツゴツメット
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 6).floor() : 16;
            }
            if (defenderState.holdingItem!.id == 188 || defenderState.holdingItem!.id == 189) {   // ジャポのみ/レンブのみ
              extraArg1 = attackerPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 8).floor() : 12;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = defenderState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
        }
        break;
      case AbilityTiming.everyTurnEnd:   // 毎ターン終了時
        {
          // 毎ターン終了時には無条件で発動する効果
          var timingIDs = [AbilityTiming.everyTurnEnd];
          var ownTimingIDs = [];
          var opponentTimingIDs = [];
          // 1度でも行動した後毎ターン終了時
          if (currentTurn.initialOwnPokemonIndex == ownPokemonIndex) ownTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
          if (currentTurn.initialOpponentPokemonIndex == opponentPokemonIndex) opponentTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
          if (weather.id == Weather.rainy) {
            timingIDs.addAll([65,50]);   // 天気があめのとき、毎ターン終了時
            if (ownPokemonState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) ownTimingIDs.add(72);       // かつ状態異常のとき
            if (opponentPokemonState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) opponentTimingIDs.add(72);
          }
          if (weather.id == Weather.sunny) timingIDs.addAll([50, 73]);   // 天気が晴れのとき、毎ターン終了時
          if (weather.id == Weather.sunny) timingIDs.addAll([79]);        // 天気がゆきのとき、毎ターン終了時
          if (ownPokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
            ownTimingIDs.add(52);
          }
          if (opponentPokemonState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
            opponentTimingIDs.add(52);
          }
          if (ownPokemonState.teraType == null || ownPokemonState.teraType!.id == 0) {  // テラスタルしていない
            ownTimingIDs.add(116);
          }
          if (opponentPokemonState.teraType == null || opponentPokemonState.teraType!.id == 0) {  // テラスタルしていない
            opponentTimingIDs.add(116);
          }
          if (ownPokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) ownTimingIDs.add(152);             // 状態異常でない毎ターン終了時
          if (opponentPokemonState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) opponentTimingIDs.add(152);   // 状態異常でない毎ターン終了時
          ownTimingIDs.addAll(timingIDs);
          opponentTimingIDs.addAll(timingIDs);

          if (ownTimingIDs.contains(ownPokemonState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (ownPokemonState.currentAbility.id == 44 || ownPokemonState.currentAbility.id == 115) {   // あめうけざら/アイスボディ
              extraArg1 = -((ownPokemonState.pokemon.h.real / 16).floor());
            }
            if (ownPokemonState.currentAbility.id == 94) {   // サンパワー
              extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
            }
            if (ownPokemonState.currentAbility.id == 87 && weather.id == Weather.sunny) {   // かんそうはだ＆晴れ
              extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
            }
            if ((ownPokemonState.currentAbility.id == 87 && weather.id == Weather.rainy) ||   // かんそうはだ＆雨
                ownPokemonState.currentAbility.id == 90   // ポイズンヒール
            ) {
              extraArg1 = -((ownPokemonState.pokemon.h.real / 8).floor());
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.me)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.ability)
              ..effectId = ownPokemonState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }
          if (opponentTimingIDs.contains(opponentPokemonState.currentAbility.timing.id)) {
            int extraArg1 = 0;
            if (opponentPokemonState.currentAbility.id == 44 || opponentPokemonState.currentAbility.id == 115) {   // あめうけざら/アイスボディ
              extraArg1 = -6;
            }
            if (opponentPokemonState.currentAbility.id == 94) {   // サンパワー
              extraArg1 = 12;
            }
            if (opponentPokemonState.currentAbility.id == 87 && weather.id == Weather.sunny) {   // かんそうはだ＆晴れ
              extraArg1 = 12;
            }
            if ((opponentPokemonState.currentAbility.id == 87 && weather.id == Weather.rainy) ||   // かんそうはだ＆雨
                opponentPokemonState.currentAbility.id == 90    // ポイズンヒール
            ) {
              extraArg1 = -12;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.ability)
              ..effectId = opponentPokemonState.currentAbility.id
              ..extraArg1 = extraArg1
            );
          }

          if (ownPokemonState.holdingItem != null && ownTimingIDs.contains(ownPokemonState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            switch (ownPokemonState.holdingItem!.id) {
              case 265:     // くっつきバリ
                extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
                break;
              case 132:     // オレンのみ
                extraArg1 = -10;
                break;
              case 43:      // きのみジュース
                extraArg1 = -20;
                break;
              case 135:     // オボンのみ
              case 185:     // ナゾのみ
                extraArg1 = -(ownPokemonState.pokemon.h.real / 4).floor();
                break;
              case 136:     // フィラのみ
              case 137:     // ウイのみ
              case 138:     // マゴのみ
              case 139:     // バンジのみ
              case 140:     // イアのみ
                extraArg1 = -(ownPokemonState.pokemon.h.real / 3).floor();
                break;
              case 258:     // くろいヘドロ
                if (ownPokemonState.isTypeContain(4)) {   // どくタイプか
                  extraArg1 = -(ownPokemonState.pokemon.h.real / 16).floor();
                }
                else {
                  extraArg1 = (ownPokemonState.pokemon.h.real / 8).floor();
                }
                break;
              case 211:     // たべのこし
                extraArg1 = -(ownPokemonState.pokemon.h.real / 16).floor();
                break;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.me)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.item)
              ..effectId = ownPokemonState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
          if (opponentPokemonState.holdingItem != null && opponentTimingIDs.contains(opponentPokemonState.holdingItem!.timing.id)) {
            int extraArg1 = 0;
            switch (ownPokemonState.holdingItem!.id) {
              case 265:     // くっつきバリ
                extraArg1 = 12;
                break;
              case 135:     // オボンのみ
              case 185:     // ナゾのみ
                extraArg1 = -25;
                break;
              case 136:     // フィラのみ
              case 137:     // ウイのみ
              case 138:     // マゴのみ
              case 139:     // バンジのみ
              case 140:     // イアのみ
                extraArg1 = -33;
                break;
              case 258:     // くろいヘドロ
                if (ownPokemonState.isTypeContain(4)) {   // どくタイプか
                  extraArg1 = -6;
                }
                else {
                  extraArg1 = 12;
                }
                break;
              case 211:     // たべのこし
                extraArg1 = -6;
                break;
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.item)
              ..effectId = opponentPokemonState.holdingItem!.id
              ..extraArg1 = extraArg1
            );
          }
        }
        break;
    }
    return ret;
  }
}
