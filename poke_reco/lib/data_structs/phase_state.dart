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
  bool canZorua = false;    // 正体を明かしていないゾロアがいるかどうか
  bool canZoroark = false;
  bool canZoruaHisui = false;
  bool canZoroarkHisui = false;

  Weather get weather => _weather;
  Field get field => _field;
  int get ownFaintingNum => _pokemonStates[0].where((e) => e.isFainting).length;
  int get opponentFaintingNum => _pokemonStates[1].where((e) => e.isFainting).length;
  bool get canAnyZoroark => canZorua || canZoroark || canZoruaHisui || canZoroarkHisui;

  set weather(Weather w) {
    Weather.processWeatherEffect(_weather, w, getPokemonState(PlayerType(PlayerType.me), null), getPokemonState(PlayerType(PlayerType.opponent), null));

    _weather = w;
  }
  set field(Field f) {
    Field.processFieldEffect(_field, f, getPokemonState(PlayerType(PlayerType.me), null), getPokemonState(PlayerType(PlayerType.opponent), null));

    _field = f;
  }

  int getPokemonIndex(PlayerType player, TurnEffect? prevAction) {
    if (prevAction != null && prevAction.getPrevPokemonIndex(player) != 0) return prevAction.getPrevPokemonIndex(player);
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

  PokemonState getPokemonState(PlayerType player, TurnEffect? prevAction) {
    if (prevAction != null && prevAction.getPrevPokemonIndex(player) != 0) {
      int idx = prevAction.getPrevPokemonIndex(player);
      if (player.id == PlayerType.me) {
        return _pokemonStates[0][idx-1];
      }
      else {
        return _pokemonStates[1][idx-1];
      }
    }
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
    ..hasOpponentTerastal = hasOpponentTerastal
    ..canZorua = canZorua
    ..canZoroark = canZoroark
    ..canZoruaHisui = canZoruaHisui
    ..canZoroarkHisui = canZoroarkHisui;
  
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
    if (getPokemonStates(player).where((element) => element.battlingNum > 0).length < 3) {
      return true;
    }
    return getPokemonStates(player)[i].battlingNum > 0;
  }

  // ターン終了時処理
  void processTurnEnd(Turn currentTurn) {
    // 各々の場のターン経過
    for (var e in ownFields) {
      e.turns++;
    }
    for (var e in opponentFields) {
      e.turns++;
    }
    // 各々のポケモンの状態のターン経過
    int initialIndex = currentTurn.getInitialPokemonIndex(PlayerType(PlayerType.me));
    bool isFaintingChange = getPokemonIndex(PlayerType(PlayerType.me), null) != initialIndex &&
      getPokemonStates(PlayerType(PlayerType.me))[initialIndex-1].isFainting;   // 死に出しかどうか
    getPokemonState(PlayerType(PlayerType.me), null).processTurnEnd(this, isFaintingChange);
    initialIndex = currentTurn.getInitialPokemonIndex(PlayerType(PlayerType.opponent));
    isFaintingChange = getPokemonIndex(PlayerType(PlayerType.opponent), null) != initialIndex &&
      getPokemonStates(PlayerType(PlayerType.opponent))[initialIndex-1].isFainting;   // 死に出しかどうか
    getPokemonState(PlayerType(PlayerType.opponent), null).processTurnEnd(this, isFaintingChange);
    // 天気のターン経過
    _weather.turns++;
    // フィールドのターン経過
    _field.turns++;
  }

  // 現在の状態で、指定されたタイミングで起こるべき効果のリストを返す
  List<TurnEffect> getDefaultEffectList(
    Turn currentTurn, AbilityTiming timing, bool changedOwn, bool changedOpponent,
    PhaseState state, TurnEffect? prevAction, int continuousCount
  ) {
    List<TurnEffect> ret = [];
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
              var myState = getPokemonState(player, null);
              var yourState = getPokemonState(player.opposite, null);
              var myTimingIDs = [...timingIDs];
              // とくせい追加
              if (myTimingIDs.contains(myState.currentAbility.timing.id)) {
                var addingAbility = TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                  ..effect = EffectType(EffectType.ability)
                  ..effectId = myState.currentAbility.id;
                addingAbility.setAutoArgs(myState, yourState, state, prevAction);
                ret.add(addingAbility);
              }
              // 各ポケモンの場
              var indiField = player.id == PlayerType.me ? ownFields : opponentFields;
              // ステルスロック
              if (indiField.where((e) => e.id == IndividualField.stealthRock).isNotEmpty &&
                  myState.currentAbility.id != 98 &&    // マジックガード
                  myState.holdingItem?.id != 1178       // あつぞこブーツ
              ) {
                var rate = PokeType.effectivenessRate(
                  false, false, false, PokeType.createFromId(6), myState) / 8;
                int extraArg1 = player.id == PlayerType.me ?
                  (myState.pokemon.h.real * rate).floor() : (100 * rate).floor();
                ret.add(TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                  ..effect = EffectType(EffectType.individualField)
                  ..effectId = IndiFieldEffect.stealthRock
                  ..extraArg1 = extraArg1
                );
              }
              // どくびし/どくどくびし
              var findIdx = indiField.indexWhere((e) => e.id == IndividualField.toxicSpikes);
              if (findIdx >= 0 && myState.isGround(indiField) && myState.copyWith().ailmentsAdd(Ailment(Ailment.poison), state) &&
                  myState.holdingItem?.id != 1178)
              {
                ret.add(TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                  ..effect = EffectType(EffectType.individualField)
                  ..effectId = indiField[findIdx].extraArg1 <= 1 ? IndiFieldEffect.toxicSpikes : IndiFieldEffect.badToxicSpikes
                );
              }
              // ねばねばネット
              if (indiField.where((e) => e.id == IndividualField.stickyWeb).isNotEmpty &&
                  myState.isGround(indiField) &&
                  myState.holdingItem?.id != 1178       // あつぞこブーツ
              ) {
                ret.add(TurnEffect()
                  ..playerType = player
                  ..timing = AbilityTiming(AbilityTiming.pokemonAppear)
                  ..effect = EffectType(EffectType.individualField)
                  ..effectId = IndiFieldEffect.stickyWeb
                );
              }
            }
          }
        }
        break;
      case AbilityTiming.beforeMove:  // わざ使用前
        var attackerState = prevAction != null ?
          getPokemonState(prevAction.playerType, prevAction) : getPokemonState(PlayerType(PlayerType.me), prevAction);
        var defenderState = prevAction != null ?
          getPokemonState(prevAction.playerType.opposite, prevAction) : getPokemonState(PlayerType(PlayerType.opponent), prevAction);
        var attackerPlayerTypeId = prevAction != null ? prevAction.playerType.id : PlayerType.me;
        var defenderPlayerTypeId = prevAction != null ? prevAction.playerType.opposite.id : PlayerType.opponent;
        var defenderTimingIDList = [];

        if (prevAction != null && prevAction.move != null && prevAction.move!.isNormallyHit(continuousCount) &&
            prevAction.move!.moveEffectivenesses[continuousCount].id != MoveEffectiveness.noEffect
        ) {  // わざ成功時
          var replacedMoveType = prevAction.move!.getReplacedMoveType(prevAction.move!.move, continuousCount, attackerState, state);
          // とくせい「へんげんじざい」「リベロ」
          if (!attackerState.isTerastaling && attackerState.hiddenBuffs.where((e) => e.id == BuffDebuff.protean).isEmpty &&
              (attackerState.currentAbility.id == 168 || attackerState.currentAbility.id == 236)
          ) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.beforeMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = attackerState.currentAbility.id
              ..extraArg1 = replacedMoveType.id
            );
          }
          // ノーマルタイプのこうげきをうけたとき
          if (replacedMoveType.id == 1) {
            defenderTimingIDList.add(148);
          }
          if (PokeType.effectiveness(
              attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
              defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
              replacedMoveType, defenderState
            ).id == MoveEffectiveness.great
          ) {
            // 効果ばつぐんのわざを受けたとき
            defenderTimingIDList.addAll([AbilityTiming.greatAttacked]);
            var moveTypeId = replacedMoveType.id;
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
          if (defenderState.holdingItem != null && defenderTimingIDList.contains(defenderState.holdingItem!.timing.id)) {
            var addingItem = TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = defenderState.holdingItem!.id;
            addingItem.setAutoArgs(defenderState, attackerState, state, prevAction);
            ret.add(addingItem);
          }
        }
        break;
      case AbilityTiming.afterMove:   // わざ使用後
        {
          var attackerState = prevAction != null ?
            getPokemonState(prevAction.playerType, prevAction) : getPokemonState(PlayerType(PlayerType.me), prevAction);
          var defenderState = prevAction != null ?
            getPokemonState(prevAction.playerType.opposite, prevAction) : getPokemonState(PlayerType(PlayerType.opponent), prevAction);
          var attackerPlayerTypeId = prevAction != null ? prevAction.playerType.id : PlayerType.me;
          var defenderPlayerTypeId = prevAction != null ? prevAction.playerType.opposite.id : PlayerType.opponent;
          var defenderTimingIDList = [];
          var attackerTimingIDList = [];
          var replacedMove = prevAction?.move?.getReplacedMove(prevAction.move!.move, continuousCount, attackerState);
          var replacedMoveType = prevAction?.move?.getReplacedMoveType(prevAction.move!.move, continuousCount, attackerState, state);
          // 直接こうげきをまもる系統のわざで防がれたとき
          if (prevAction != null && replacedMove!.isDirect &&
              !(replacedMove.isPunch && attackerState.holdingItem?.id == 1696) &&  // パンチグローブをつけたパンチわざでない
              attackerState.currentAbility.id != 203    // とくせいがえんかくでない
          ) {
            var findIdx = defenderState.ailmentsIndexWhere((e) => e.id == Ailment.protect);
            if (findIdx >= 0 && defenderState.ailments(findIdx).extraArg1 != 0) {
              var id = defenderState.ailments(findIdx).extraArg1;
              int extraArg1 = 0;
              if (id == 596) {
                if (attackerPlayerTypeId == PlayerType.me) {
                  extraArg1 = (attackerState.pokemon.h.real / 8).floor();
                }
                else {
                  extraArg1 = 12;
                }
              }
              ret.add(TurnEffect()
                ..playerType = PlayerType(attackerPlayerTypeId)
                ..timing = AbilityTiming(AbilityTiming.afterMove)
                ..effect = EffectType(EffectType.afterMove)
                ..effectId = id
                ..extraArg1 = extraArg1
              );
            }
          }
          // みちづれ状態の相手をひんしにしたとき
          if (prevAction != null && defenderState.isFainting && defenderState.ailmentsWhere((e) => e.id == Ailment.destinyBond).isNotEmpty) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.afterMove)
              ..effectId = 194
            );
          }
          if (prevAction != null && prevAction.move != null && prevAction.move!.isNormallyHit(continuousCount) &&
              prevAction.move!.moveEffectivenesses[continuousCount].id != MoveEffectiveness.noEffect
          ) {  // わざ成功時
            if (replacedMove!.damageClass.id == 1 && replacedMove.isTargetYou) {
              // へんかわざを受けた後
              defenderTimingIDList.add(AbilityTiming.statused);
            }
            if (replacedMove.damageClass.id >= 2) {
              // こうげきわざヒット後
              attackerTimingIDList.add(AbilityTiming.attackHitted);
              // こうげきわざでひんしにした後
              if (defenderState.isFainting) {
                attackerTimingIDList.add(AbilityTiming.defeatOpponentWithAttack);
              }
              // ぶつりこうげきを受けた時
              if (replacedMove.damageClass.id == DamageClass.physical) {
                defenderTimingIDList.add(AbilityTiming.phisycalAttackedHitted);
              }
              // こうげきわざを受けた後
              defenderTimingIDList.addAll([AbilityTiming.attackedHitted, AbilityTiming.pokemonAppearAttacked]);
              // ばけたすがたでこうげきを受けた後
              if (defenderState.buffDebuffs.where((element) => element.id == BuffDebuff.transedForm).isNotEmpty) {
                defenderTimingIDList.add(AbilityTiming.attackedHittedWithBake);
              }
              // こうげきわざを受けてひんしになったとき
              if (defenderState.isFainting) {
                defenderTimingIDList.add(AbilityTiming.attackedFainting);
              }
              // ノーマルタイプのこうげきをうけたとき
              if (replacedMoveType!.id == 1) {
                defenderTimingIDList.add(148);
              }
              // あくタイプのこうげきをうけたとき
              if (replacedMoveType.id == 17) {
                defenderTimingIDList.addAll([86, 87]);
              }
              // みずタイプのこうげきをうけたとき
              if (replacedMoveType.id == 11) {
                defenderTimingIDList.addAll([92, 104]);
              }
              // ほのおタイプのこうげきをうけたとき
              if (replacedMoveType.id == 10) {
                defenderTimingIDList.addAll([104, 107]);
              }
              // でんきタイプのこうげきをうけたとき
              if (replacedMoveType.id == 13) {
                defenderTimingIDList.addAll([118]);
              }
              // こおりタイプのこうげきをうけたとき
              if (replacedMoveType.id == 15) {
                defenderTimingIDList.addAll([119]);
              }
              // ゴーストタイプのこうげきをうけたとき
              if (replacedMoveType.id == 8) {
                defenderTimingIDList.addAll([87]);
              }
              // むしタイプのこうげきをうけたとき
              if (replacedMoveType.id == 7) {
                defenderTimingIDList.addAll([92]);
              }
              // 直接こうげきを受けた後
              if (replacedMove.isDirect &&
                  !(replacedMove.isPunch && attackerState.holdingItem?.id == 1696) &&  // パンチグローブをつけたパンチわざでない
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
            if (replacedMove.priority >= 1) {
              defenderTimingIDList.add(AbilityTiming.priorityMoved);
            }
            // 音技を受けた後
            if (replacedMove.isSound) {
              defenderTimingIDList.add(AbilityTiming.soundAttacked);
            }
            // 風の技を受けた後
            if (replacedMove.isWind) {
              defenderTimingIDList.add(AbilityTiming.winded);
            }
            // HP吸収わざを受けた後
            if (replacedMove.isDrain) {
              defenderTimingIDList.add(AbilityTiming.drained);
            }
            if (replacedMoveType!.id == 13) {    // でんきタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.electriced, AbilityTiming.electricUse]);
            }
            if (replacedMoveType.id == 11) {    // みずタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.watered, AbilityTiming.fireWaterAttackedSunnyRained, AbilityTiming.waterUse]);
            }
            if (replacedMoveType.id == 10) {    // ほのおタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.fired, AbilityTiming.fireWaterAttackedSunnyRained]);
            }
            if (replacedMoveType.id == 12) {    // くさタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grassed]);
            }
            if (replacedMoveType.id == 5) {    // じめんタイプのわざをうけた時
              defenderTimingIDList.addAll([AbilityTiming.grounded]);
              if (replacedMove.id != 28 && replacedMove.id != 614) {  // すなかけ/サウザンアローではない
                defenderTimingIDList.addAll([AbilityTiming.groundFieldEffected]);
              }
            }
            if (PokeType.effectiveness(
                  attackerState.currentAbility.id == 113, defenderState.holdingItem?.id == 586,
                  defenderState.ailmentsWhere((e) => e.id == Ailment.miracleEye).isNotEmpty,
                  replacedMoveType, defenderState
                ).id == MoveEffectiveness.great
            ) {
              // 効果ばつぐんのわざを受けたとき
              defenderTimingIDList.addAll([AbilityTiming.greatAttacked]);
              var moveTypeId = replacedMoveType.id;
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
          // こうげきを受ける側のとくせいは、かたやぶり等によって発動しない場合あり
          if (defenderTimingIDList.contains(defenderState.currentAbility.timing.id) &&
              (!defenderState.currentAbility.canIgnored ||
               attackerState.buffDebuffs.where((e) => e.id == BuffDebuff.noAbilityEffect || e.id == BuffDebuff.myceliumMight).isEmpty)
          ) {
            var addingAbility = TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.ability)
              ..effectId = defenderState.currentAbility.id;
            addingAbility.setAutoArgs(defenderState, attackerState, state, prevAction);
            ret.add(addingAbility);
          }
          // 対応するタイミングに該当するもちもの
          if (attackerState.holdingItem != null && attackerTimingIDList.contains(attackerState.holdingItem!.timing.id)) {
            var addingItem = TurnEffect()
              ..playerType = PlayerType(attackerPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = attackerState.holdingItem!.id;
            addingItem.setAutoArgs(attackerState, defenderState, state, prevAction);
            ret.add(addingItem);
          }
          if (defenderState.holdingItem != null && defenderTimingIDList.contains(defenderState.holdingItem!.timing.id)) {
            var addingItem = TurnEffect()
              ..playerType = PlayerType(defenderPlayerTypeId)
              ..timing = AbilityTiming(AbilityTiming.afterMove)
              ..effect = EffectType(EffectType.item)
              ..effectId = defenderState.holdingItem!.id;
            addingItem.setAutoArgs(defenderState, attackerState, state, prevAction);
            ret.add(addingItem);
          }
        }
        break;
      case AbilityTiming.everyTurnEnd:   // 毎ターン終了時
        {
          // 自分/相手ごとにforループ
          for (int i = 0; i < 2; i++) {
            var playerTimingIDs = [];
            var player = players[i];
            var myState = getPokemonState(player, null);
            var yourState = getPokemonState(player.opposite, null);
            bool isMe = player.id == PlayerType.me;

            // 死に出しなら発動する効果はない
            if (getPokemonStates(player)[currentTurn.getInitialPokemonIndex(player)-1].isFainting) continue;

            // 毎ターン終了時には無条件で発動する効果
            playerTimingIDs = [AbilityTiming.everyTurnEnd];
            // 1度でも行動した後毎ターン終了時
            if (currentTurn.getInitialPokemonIndex(player) == getPokemonIndex(player, null)) playerTimingIDs.add(AbilityTiming.afterActedEveryTurnEnd);
            if (weather.id == Weather.rainy) {
              playerTimingIDs.addAll([65,50]);   // 天気があめのとき、毎ターン終了時
              if (myState.ailmentsWhere((element) => element.id <= Ailment.sleep).isNotEmpty) playerTimingIDs.add(72);       // かつ状態異常のとき
            }
            if (weather.id == Weather.sunny) playerTimingIDs.addAll([50, 73]);   // 天気が晴れのとき、毎ターン終了時
            if (weather.id == Weather.sunny) playerTimingIDs.addAll([79]);        // 天気がゆきのとき、毎ターン終了時
            if (myState.ailmentsWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison).isNotEmpty) {  // どく/もうどく状態
              playerTimingIDs.add(52);
            }
            if (!myState.isTerastaling) {  // テラスタルしていない
              playerTimingIDs.add(116);
            }
            if (myState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) playerTimingIDs.add(152);             // 状態異常でない毎ターン終了時
            if ((isMe && myState.remainHP < myState.pokemon.h.real && myState.remainHP > 0) ||
                (!isMe && myState.remainHPPercent < 100 && myState.remainHPPercent > 0)
            ) {
              // HPが満タンでない毎ターン終了時
              playerTimingIDs.add(AbilityTiming.everyTurnEndHPNotFull);
              // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
              if (myState.isTypeContain(4)) playerTimingIDs.add(AbilityTiming.everyTurnEndHPNotFull2);
            }
            // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
            if (!myState.isTypeContain(4)) playerTimingIDs.add(AbilityTiming.everyTurnEndHPNotFull2);
            // こだいかっせい発動中に天気が晴れでなくなった場合
            if (myState.buffDebuffs.where((e) => e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5 && e.extraArg1 == 0).isNotEmpty) {
              if (weather.id != Weather.sunny) playerTimingIDs.add(AbilityTiming.sunnyBoostEnergy);
              if (field.id != Field.electricTerrain) playerTimingIDs.add(AbilityTiming.elecFieldBoostEnergy);
            }

            // とくせい
            if (playerTimingIDs.contains(myState.currentAbility.timing.id)) {
              var addingAbility = TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ability)
                ..effectId = myState.currentAbility.id;
              addingAbility.setAutoArgs(myState, yourState, state, prevAction);
              ret.add(addingAbility);
            }

            // もちもの
            if (myState.holdingItem != null && playerTimingIDs.contains(myState.holdingItem!.timing.id)) {
              var addingItem = TurnEffect()
                ..playerType = player
                ..timing = timing
                ..effect = EffectType(EffectType.item)
                ..effectId = myState.holdingItem!.id;
              addingItem.setAutoArgs(myState, yourState, state, prevAction);
              ret.add(addingItem);
            }

            //  状態異常
            if (myState.ailmentsWhere((e) => e.id == Ailment.sleepy && e.turns >= 1).isNotEmpty &&
                myState.copyWith().ailmentsAdd(Ailment(Ailment.sleep), state)
            ) {  // ねむけ状態のとき&ねむりになるとき
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.sleepy
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.burn).isNotEmpty) {    // やけど
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.burn
                ..extraArg1 = isMe ? (myState.pokemon.h.real / 16).floor() : 6
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.poison).isNotEmpty) {    // どく
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.poison
                ..extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.badPoison).isNotEmpty) { // もうどく
              int turns = (myState.ailmentsWhere((e) => e.id == Ailment.badPoison).first.turns + 1).clamp(1, 15);
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.badPoison
                ..extraArg1 = isMe ? (myState.pokemon.h.real * turns / 16).floor() : (100 * turns / 16).floor()
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.saltCure).isNotEmpty) {    // しおづけ
              int bunbo = myState.isTypeContain(9) || myState.isTypeContain(11) ? 4 : 8;
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.saltCure
                ..extraArg1 = isMe ? (myState.pokemon.h.real / bunbo).floor() : (100 / bunbo).floor()
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.curse).isNotEmpty) {     // のろい
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.curse
                ..extraArg1 = isMe ? (myState.pokemon.h.real / 4).floor() : 25
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.leechSeed).isNotEmpty) { // やどりぎのタネ
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.leechSeed
                ..extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.ingrain).isNotEmpty) {   // ねをはる
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.ingrain
                ..extraArg1 = isMe ? -((myState.pokemon.h.real / 16).floor()) : -6
              );
            }
            if (myState.ailmentsWhere((e) => e.id == Ailment.taunt && e.extraArg1 >= 3).isNotEmpty) {   // ちょうはつ終了
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
                ..effect = EffectType(EffectType.ailment)
                ..effectId = AilmentEffect.tauntEnd
              );
            }

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

          // 両者に効果があるもの
          var weatherEffectIDs = [];
          if (weather.id == Weather.sandStorm) {
            if (getPokemonState(PlayerType(PlayerType.me), null).isSandstormDamaged() ||
                getPokemonState(PlayerType(PlayerType.opponent), null).isSandstormDamaged())
            {
              weatherEffectIDs.add(WeatherEffect.sandStormDamage);
            }
          }
          var fieldEffectIDs = [];
          if (field.id == Field.grassyTerrain) {
            if (getPokemonState(PlayerType(PlayerType.me), null).isGround(state.ownFields) ||
                getPokemonState(PlayerType(PlayerType.opponent), null).isGround(state.opponentFields))
            {
              fieldEffectIDs.add(FieldEffect.grassHeal);
            }
          }

          // 天気
          for (var e in weatherEffectIDs) {
            int extraArg1 = 0;
            int extraArg2 = 0;
            if (e == WeatherEffect.sandStormDamage) {
              if (getPokemonState(PlayerType(PlayerType.me), null).isSandstormDamaged()) {    // すなあらしによるダメージ
                extraArg1 = (getPokemonState(PlayerType(PlayerType.me), null).pokemon.h.real / 16).floor();
              }
              if (getPokemonState(PlayerType(PlayerType.opponent), null).isSandstormDamaged()) {
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
          // フィールド
          for (var e in fieldEffectIDs) {
            int extraArg1 = 0;
            int extraArg2 = 0;
            if (e == FieldEffect.grassHeal) {
              if (getPokemonState(PlayerType(PlayerType.me), null).isGround(state.ownFields)) {   // グラスフィールドによる回復
                extraArg1 = -(getPokemonState(PlayerType(PlayerType.me), null).pokemon.h.real / 16).floor();
              }
              if (getPokemonState(PlayerType(PlayerType.opponent), null).isGround(state.opponentFields)) {
                extraArg2 = -6;
              }
            }
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.entireField)
              ..timing = AbilityTiming(AbilityTiming.everyTurnEnd)
              ..effect = EffectType(EffectType.field)
              ..effectId = e
              ..extraArg1 = extraArg1
              ..extraArg2 = extraArg2
            );
          }
        }
        break;
      case AbilityTiming.afterTerastal:   // テラスタル後
        {
          // 自分/相手ごとにforループ
          for (int i = 0; i < 2; i++) {
            var player = players[i];
            var myState = getPokemonState(player, null);
            bool isMe = player.id == PlayerType.me;
            bool isTerastal = myState.isTerastaling && (isMe ? !currentTurn.initialOwnHasTerastal : !currentTurn.initialOpponentHasTerastal);

            if (isTerastal && myState.currentAbility.id == 303) {
              ret.add(TurnEffect()
                ..playerType = player
                ..timing = AbilityTiming(AbilityTiming.afterTerastal)
                ..effect = EffectType(EffectType.ability)
                ..effectId = 303
              );
            }
          }
        }
        break;
    }

    // 各タイミング共通
    // 自分/相手ごとにforループ
    for (int i = 0; i < 2; i++) {
      List<int> playerTimingIDs = [];
      var player = players[i];
      var myState = getPokemonState(player, timing.id == AbilityTiming.afterMove ? prevAction : null);
      var yourState = getPokemonState(player.opposite, timing.id == AbilityTiming.afterMove ? prevAction : null);
      bool isMe = player.id == PlayerType.me;

      if ((isMe && myState.remainHP <= myState.pokemon.h.real / 4 && myState.remainHP > 0)  || (!isMe && myState.remainHPPercent <= 25 && myState.remainHPPercent > 0)) {
        playerTimingIDs.add(AbilityTiming.hp025);
      }
      if ((isMe && myState.remainHP <= myState.pokemon.h.real / 2 && myState.remainHP > 0) || (!isMe && myState.remainHPPercent <= 50 && myState.remainHPPercent > 0)) {
        playerTimingIDs.add(AbilityTiming.hp050);
      }

      // こだいかっせい/ブーストエナジー発動の余地がある場合
      if (myState.buffDebuffs.where((e) => e.id >= BuffDebuff.attack1_3 && e.id <= BuffDebuff.speed1_5).isEmpty &&
          ((isMe && !changedOwn) || (!isMe && !changedOpponent))    // 交代で手持ちに戻るときでないなら
      ) {
        if (weather.id == Weather.sunny) playerTimingIDs.add(AbilityTiming.sunnyBoostEnergy);
        if (field.id == Field.electricTerrain) playerTimingIDs.add(AbilityTiming.elecFieldBoostEnergy);
        if (myState.holdingItem?.id == 1696) playerTimingIDs.addAll([111, 112]);
      }

      // とくせい
      if (playerTimingIDs.contains(myState.currentAbility.timing.id)) {
        var addingAbility = TurnEffect()
          ..playerType = player
          ..timing = timing
          ..effect = EffectType(EffectType.ability)
          ..effectId = myState.currentAbility.id;
        addingAbility.setAutoArgs(myState, yourState, state, prevAction);
        ret.add(addingAbility);
      }
      
      // もちもの
      if (playerTimingIDs.contains(AbilityTiming.hp050) && myState.currentAbility.id == 82) {   // とくせいがくいしんぼうの場合はHP50%以下ならHP25%以下タイミングも併発
        playerTimingIDs.add(AbilityTiming.hp025);
      }
      if (myState.holdingItem != null && playerTimingIDs.contains(myState.holdingItem!.timing.id)) {
        var addingItem = TurnEffect()
          ..playerType = player
          ..timing = timing
          ..effect = EffectType(EffectType.item)
          ..effectId = myState.holdingItem!.id;
        addingItem.setAutoArgs(myState, yourState, state, prevAction);
        ret.add(addingItem);
      }
    }

    for (var effect in ret) {
      effect.isAutoSet = true;
    }

    return ret;
  }
}
