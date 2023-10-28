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
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';

// ある時点(ターン内のフェーズ)での状態
class PhaseState {
  List<int> _pokemonIndexes = [0, 0];   // 0は無効値
  List<List<PokemonState>> _pokemonStates = [[], []];
  List<IndividualField> ownFields = [];        // 場(天気やフィールドを含まない、かべ等)
  List<IndividualField> opponentFields = [];        // 場(天気やフィールドを含まない、かべ等)
  Weather _weather = Weather(0);
  Field _field = Field(0);
  bool hasOwnTerastal = false;        // これまでのフェーズでテラスタルをしたことがあるか
  bool hasOpponentTerastal = false;

  Weather get weather => _weather;
  Field get field => _field;
  int get ownFaintingNum => _pokemonStates[0].where((e) => e.isFainting).length;
  int get opponentFaintingNum => _pokemonStates[1].where((e) => e.isFainting).length;

  set weather(Weather w) {
    Weather.processWeatherEffect(_weather, w, getPokemonState(PlayerType(PlayerType.me)), getPokemonState(PlayerType(PlayerType.opponent)));

    _weather = w;
  }
  set field(Field f) {
    Field.processFieldEffect(_field, f, getPokemonState(PlayerType(PlayerType.me)), getPokemonState(PlayerType(PlayerType.opponent)));

    _field = f;
  }

  int getPokemonIndex(PlayerType player) {
    if (player.id == PlayerType.me) {
      return _pokemonIndexes[0];
    }
    else {
      return _pokemonIndexes[1];
    }
  }

  void setPokemonIndex(PlayerType player, int index) {
    if (player.id == PlayerType.me) {
      _pokemonIndexes[0] = index;
    }
    else if (player.id == PlayerType.opponent) {
      _pokemonIndexes[1] = index;
    }
    assert(true);
  }

  List<PokemonState> getPokemonStates(PlayerType player) {
    if (player.id == PlayerType.me) {
      return _pokemonStates[0];
    }
    else {
      return _pokemonStates[1];
    }
  }

  PokemonState getPokemonState(PlayerType player) {
    if (player.id == PlayerType.me) {
      return _pokemonStates[0][_pokemonIndexes[0]-1];
    }
    else {
      return _pokemonStates[1][_pokemonIndexes[1]-1];
    }
  }

  void forceSetWeather(Weather w) {
    _weather = w;
  }
  void forceSetField(Field f) {
    _field = f;
  }

  PhaseState copyWith() =>
    PhaseState()
    .._pokemonIndexes = [..._pokemonIndexes]
    .._pokemonStates[0] = [
      for (final state in _pokemonStates[0])
      state.copyWith()
    ]
    .._pokemonStates[1] = [
      for (final state in _pokemonStates[1])
      state.copyWith()
    ]
    ..ownFields = [for (final e in ownFields) e.copyWith()]
    ..opponentFields = [for (final e in opponentFields) e.copyWith()]
    ..weather = weather.copyWith()
    ..field = field.copyWith()
    ..hasOwnTerastal = hasOwnTerastal
    ..hasOpponentTerastal = hasOpponentTerastal;
  
  //PokemonState get ownPokemonState => _pokemonStates[0][_pokemonIndexes[0]-1];
  //PokemonState get opponentPokemonState => _pokemonStates[1][_pokemonIndexes[1]-1];
  //bool get hasOwnTerastal => _pokemonStates[0].where((element) => element.teraType != null).isNotEmpty;
  //bool get hasOpponentTerastal => _pokemonStates[1].where((element) => element.teraType != null).isNotEmpty;
  bool get isMyWin {
    var n = _pokemonStates[1].where((element) => element.isFainting).length;
    return n >= 3 || n >= _pokemonStates[1].length;
  }
  bool get isYourWin {
    var n = _pokemonStates[0].where((element) => element.isFainting).length;
    return n >= 3 || n >= _pokemonStates[0].length;
  }
  
  // 対戦に登場する3匹が確定していた場合、対象のポケモンが登場しているかどうか
  // 3匹が確定していない場合は常にtrue
  bool isPossibleBattling(PlayerType player, int i) {
    if (getPokemonStates(player).where((element) => element.isBattling).length < 3) {
      return true;
    }
    return getPokemonStates(player)[i].isBattling;
  }

  // ターン終了時処理
  void processTurnEnd() {
    // 各々の場のターン経過
    for (var e in ownFields) {
      e.turns++;
    }
    for (var e in opponentFields) {
      e.turns++;
    }
    // 各々のポケモンの状態のターン経過
    getPokemonState(PlayerType(PlayerType.me)).processTurnEnd();
    getPokemonState(PlayerType(PlayerType.opponent)).processTurnEnd();
    // 天気のターン経過
    _weather.turns++;
    // フィールドのターン経過
    _field.turns++;
  }

  // 現在の状態で、指定されたタイミングで起こるべき効果のリストを返す
  List<TurnEffect> getDefaultEffectList(
    Turn currentTurn, AbilityTiming timing, bool changedOwn, bool changedOpponent,
    TurnEffect? prevAction, int continuousCount
  ) {
    List<TurnEffect> ret = [];
    var attackerState = prevAction != null ? getPokemonState(prevAction.playerType) : getPokemonState(PlayerType(PlayerType.me));
    var defenderState = prevAction != null ? getPokemonState(prevAction.playerType.opposite) : getPokemonState(PlayerType(PlayerType.opponent));
    var attackerPlayerTypeId = prevAction != null ? prevAction.playerType.id : PlayerType.me;
    var defenderPlayerTypeId = prevAction != null ? prevAction.playerType.opposite.id : PlayerType.opponent;
    var players = [PlayerType(PlayerType.me), PlayerType(PlayerType.opponent)];

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
          // TODO 追加順はすばやさを考慮したい
          for (final player in players) {
            bool changed = player.id == PlayerType.me ? changedOwn : changedOpponent;
            if (changed) {
              if (timingIDs.contains(getPokemonState(player).currentAbility.timing.id)) {
                int extraArg1 = 0;
                if (getPokemonState(player).currentAbility.id == 36) {    // トレース
                  extraArg1 = getPokemonState(player.opposite).currentAbility.id; 
                }
                ret.add(TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                  ..effect = EffectType(EffectType.ability)
                  ..effectId = getPokemonState(player).currentAbility.id
                  ..extraArg1 = extraArg1
                );
              }
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
              // ばけたすがたでこうげきを受けた後
              if (defenderState.buffDebuffs.where((element) => element.id == BuffDebuff.transedForm).isNotEmpty) {
                defenderTimingIDList.add(AbilityTiming.attackedHittedWithBake);
              }
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
                variedExtraArg1 = defenderPlayerTypeId == PlayerType.me ? -((getPokemonState(PlayerType(PlayerType.me)).pokemon.h.real / 4).floor()) : -25;
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
              extraArg1 = defenderPlayerTypeId == PlayerType.me ? -((getPokemonState(PlayerType(PlayerType.me)).pokemon.h.real / 4).floor()) : -25;
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
            if (defenderState.currentAbility.id == 209) {   // ばけのかわ
                extraArg1 = defenderPlayerTypeId == PlayerType.me ? (attackerState.pokemon.h.real / 8).floor() : 12;
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
          // 自分/相手ごとにforループ
          for (int i = 0; i < 2; i++) {
            var playerTimingIDs = [];
            var player = players[i];

            // 毎ターン終了時には無条件で発動する効果
            playerTimingIDs = [AbilityTiming.everyTurnEnd];
            // 1度でも行動した後毎ターン終了時
            if (currentTurn.getInitialPokemonIndex(player) == getPokemonIndex(player)) playerTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
            if (weather.id == Weather.rainy) {
              playerTimingIDs.addAll([65,50]);   // 天気があめのとき、毎ターン終了時
              if (getPokemonState(player).ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) playerTimingIDs.add(72);       // かつ状態異常のとき
            }
            if (weather.id == Weather.sunny) playerTimingIDs.addAll([50, 73]);   // 天気が晴れのとき、毎ターン終了時
            if (weather.id == Weather.sunny) playerTimingIDs.addAll([79]);        // 天気がゆきのとき、毎ターン終了時
            if (getPokemonState(player).ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
              playerTimingIDs.add(52);
            }
            if (getPokemonState(player).teraType == null || getPokemonState(player).teraType!.id == 0) {  // テラスタルしていない
              playerTimingIDs.add(116);
            }
            if (getPokemonState(player).ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) playerTimingIDs.add(152);             // 状態異常でない毎ターン終了時

            // とくせい
            if (playerTimingIDs.contains(getPokemonState(player).currentAbility.timing.id)) {
              int extraArg1 = 0;
              int currentAbilityID = getPokemonState(player).currentAbility.id;
              bool isMe = player.id == PlayerType.me;
              if (currentAbilityID == 44 || currentAbilityID == 115) {   // あめうけざら/アイスボディ
                extraArg1 = isMe ? -((getPokemonState(player).pokemon.h.real / 16).floor()) : -6;
              }
              if (currentAbilityID == 94) {   // サンパワー
                extraArg1 = isMe ? (getPokemonState(player).pokemon.h.real / 8).floor() : 12;
              }
              if (currentAbilityID == 87 && weather.id == Weather.sunny) {   // かんそうはだ＆晴れ
                extraArg1 = isMe ? (getPokemonState(player).pokemon.h.real / 8).floor() : 12;
              }
              if ((currentAbilityID == 87 && weather.id == Weather.rainy) ||   // かんそうはだ＆雨
                  currentAbilityID == 90   // ポイズンヒール
              ) {
                extraArg1 = isMe ? -((getPokemonState(player).pokemon.h.real / 8).floor()) : -12;
              }
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ability)
                ..effectId = currentAbilityID
                ..extraArg1 = extraArg1
              );
            }

            // もちもの
            if (getPokemonState(player).holdingItem != null && playerTimingIDs.contains(getPokemonState(player).holdingItem!.timing.id)) {
              int extraArg1 = 0;
              bool isMe = player.id == PlayerType.me;
              switch (getPokemonState(player).holdingItem!.id) {
                case 265:     // くっつきバリ
                  extraArg1 = isMe ? (getPokemonState(player).pokemon.h.real / 8).floor() : 12;
                  break;
                case 132:     // オレンのみ
                  if (isMe) extraArg1 = -10;
                  break;
                case 43:      // きのみジュース
                  if (isMe) extraArg1 = -20;
                  break;
                case 135:     // オボンのみ
                case 185:     // ナゾのみ
                  extraArg1 = isMe ? -(getPokemonState(player).pokemon.h.real / 4).floor() : -25;
                  break;
                case 136:     // フィラのみ
                case 137:     // ウイのみ
                case 138:     // マゴのみ
                case 139:     // バンジのみ
                case 140:     // イアのみ
                  extraArg1 = isMe ? -(getPokemonState(player).pokemon.h.real / 3).floor() : -33;
                  break;
                case 258:     // くろいヘドロ
                  if (getPokemonState(player).isTypeContain(4)) {   // どくタイプか
                    extraArg1 = isMe ? -(getPokemonState(player).pokemon.h.real / 16).floor() : -6;
                  }
                  else {
                    extraArg1 = isMe ? (getPokemonState(player).pokemon.h.real / 8).floor() : 12;
                  }
                  break;
                case 211:     // たべのこし
                  extraArg1 = isMe ? -(getPokemonState(player).pokemon.h.real / 16).floor() : -6;
                  break;
              }
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.item)
                ..effectId = getPokemonState(player).holdingItem!.id
                ..extraArg1 = extraArg1
              );

              // 各ポケモンの場の効果
              var fields = player.id == PlayerType.me ? ownFields : opponentFields;
              var findIdx = fields.indexWhere((e) => e.id == IndividualField.futureAttack && e.turns == 2);
              if (findIdx >= 0) {
                ret.add(TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                  ..effect = EffectType(EffectType.individualField)
                  ..effectId = IndividualField.futureAttack
                );
              }
            }
          }

          // 両者に効果があるもの
          var weatherEffectIDs = [];
          if (weather.id == Weather.sandStorm) {
            if (getPokemonState(PlayerType(PlayerType.me)).isSandstormDamaged() ||
                getPokemonState(PlayerType(PlayerType.opponent)).isSandstormDamaged())
            {
              weatherEffectIDs.add(WeatherEffect.sandStormDamage);
            }
          }

          // 天気
          for (var e in weatherEffectIDs) {
            int extraArg1 = 0;
            int extraArg2 = 0;
            if (e == WeatherEffect.sandStormDamage) {
              if (getPokemonState(PlayerType(PlayerType.me)).isSandstormDamaged()) {    // すなあらしによるダメージ
                extraArg1 = (getPokemonState(PlayerType(PlayerType.me)).pokemon.h.real / 16).floor();
              }
              if (getPokemonState(PlayerType(PlayerType.opponent)).isSandstormDamaged()) {
                extraArg2 = 6;
              }
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.entireField)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.weather)
              ..effectId = e
              ..extraArg1 = extraArg1
              ..extraArg2 = extraArg2
            );
          }          
        }
        break;
    }
    return ret;
  }
}
