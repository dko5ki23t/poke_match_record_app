import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ability.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_after_move.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_ailment.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_individual_field.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_item.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_weather.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/tool.dart';

// ある時点(ターン内のフェーズ)での状態
// これ単体ではSQLに保存しない
class PhaseState extends Equatable implements Copyable {
  List<int> _pokemonIndexes = [-1, -1]; // 0始まりのインデックス。-1は無効値
  List<List<PokemonState>> _pokemonStates = [[], []];
  List<List<PokemonState>> lastExitedStates = [[], []]; // 最後に退場したときの状態
  List<List<IndividualField>> _indiFields = [[], []]; // 場(天気やフィールドを含まない、かべ等)
  Weather _weather = Weather(0);
  Field _field = Field(0);
  List<TurnEffect> phases = [];
  int phaseIndex = 0;
  bool hasOwnTerastal = false; // これまでのフェーズでテラスタルをしたことがあるか
  bool hasOpponentTerastal = false;
  bool canZorua = false; // 正体を明かしていないゾロアがいるかどうか
  bool canZoroark = false;
  bool canZoruaHisui = false;
  bool canZoroarkHisui = false;
  List<int> _faintingCount = [0, 0]; // ひんしになった回数
  TurnEffectAction? firstAction; // 行動2が行動1を参照するために使う(TODO:不要？)

  @override
  List<Object?> get props => [
        _pokemonIndexes,
        _pokemonStates,
        lastExitedStates,
        _indiFields,
        _weather,
        _field,
        phases,
        phaseIndex,
        hasOwnTerastal,
        hasOpponentTerastal,
        canZorua,
        canZoroark,
        canZoruaHisui,
        canZoroarkHisui,
        _faintingCount,
        firstAction,
      ];

  Weather get weather => _weather;
  Field get field => _field;
  bool get canAnyZoroark =>
      canZorua || canZoroark || canZoruaHisui || canZoroarkHisui;

  set weather(Weather w) {
    Weather.processWeatherEffect(
        _weather,
        w,
        getPokemonState(PlayerType.me, null),
        getPokemonState(PlayerType.opponent, null));

    _weather = w;
  }

  set field(Field f) {
    Field.processFieldEffect(_field, f, getPokemonState(PlayerType.me, null),
        getPokemonState(PlayerType.opponent, null));

    _field = f;
  }

  int getPokemonIndex(PlayerType player, TurnEffect? prevAction) {
    if (prevAction?.getPrevPokemonIndex(player) != null) {
      int ret = prevAction!.getPrevPokemonIndex(player)!;
      if (ret != 0) return ret;
    }
    if (player == PlayerType.me) {
      return _pokemonIndexes[0];
    } else {
      return _pokemonIndexes[1];
    }
  }

  void setPokemonIndex(PlayerType player, int index) {
    if (player == PlayerType.me) {
      _pokemonIndexes[0] = index;
    } else if (player == PlayerType.opponent) {
      _pokemonIndexes[1] = index;
    }
  }

  List<PokemonState> getPokemonStates(PlayerType player) {
    if (player == PlayerType.me) {
      return _pokemonStates[0];
    } else {
      return _pokemonStates[1];
    }
  }

  PokemonState getPokemonState(PlayerType player, TurnEffect? prevAction) {
    int? idx = prevAction?.getPrevPokemonIndex(player);
    if (idx != null) {
      if (player == PlayerType.me) {
        return _pokemonStates[0][idx - 1];
      } else {
        return _pokemonStates[1][idx - 1];
      }
    }
    if (player == PlayerType.me) {
      return _pokemonStates[0][_pokemonIndexes[0] - 1];
    } else {
      return _pokemonStates[1][_pokemonIndexes[1] - 1];
    }
  }

  List<IndividualField> getIndiFields(PlayerType player) {
    if (player == PlayerType.me) {
      return _indiFields[0];
    } else {
      return _indiFields[1];
    }
  }

  int getFaintingCount(PlayerType player) {
    if (player == PlayerType.me) {
      return _faintingCount[0];
    } else {
      return _faintingCount[1];
    }
  }

  void incFaintingCount(PlayerType player, int delta) {
    if (player == PlayerType.me) {
      _faintingCount[0] += delta;
    } else {
      _faintingCount[1] += delta;
    }
  }

  void forceSetWeather(Weather w) {
    _weather = w;
  }

  void forceSetField(Field f) {
    _field = f;
  }

  @override
  PhaseState copy() => PhaseState()
    .._pokemonIndexes = [..._pokemonIndexes]
    .._pokemonStates[0] = [for (final state in _pokemonStates[0]) state.copy()]
    .._pokemonStates[1] = [for (final state in _pokemonStates[1]) state.copy()]
    ..lastExitedStates[0] = [
      for (final state in lastExitedStates[0]) state.copy()
    ]
    ..lastExitedStates[1] = [
      for (final state in lastExitedStates[1]) state.copy()
    ]
    .._indiFields[0] = [for (final e in _indiFields[0]) e.copy()]
    .._indiFields[1] = [for (final e in _indiFields[1]) e.copy()]
    ..weather = weather.copy()
    ..field = field.copy()
    ..phases = [for (final phase in phases) phase.copy()]
    ..phaseIndex = phaseIndex
    ..hasOwnTerastal = hasOwnTerastal
    ..hasOpponentTerastal = hasOpponentTerastal
    ..canZorua = canZorua
    ..canZoroark = canZoroark
    ..canZoruaHisui = canZoruaHisui
    ..canZoroarkHisui = canZoroarkHisui
    .._faintingCount = [..._faintingCount]
    ..firstAction = firstAction?.copy();

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
    if (getPokemonStates(player)
            .where((element) => element.battlingNum > 0)
            .length <
        3) {
      return true;
    }
    return getPokemonStates(player)[i].battlingNum > 0;
  }

  // ターン終了時処理
  void processTurnEnd(Turn currentTurn) {
    // 行動1削除
    firstAction = null;
    // 各々の場のターン経過
    for (int i = 0; i < _indiFields.length; i++) {
      for (var e in _indiFields[i]) {
        e.turns++;
      }
      _indiFields[i].removeWhere(
          (element) => element.id == IndividualField.ionDeluge); // プラズマシャワー消失
    }
    // 各々のポケモンの状態のターン経過
    int initialIndex = currentTurn.getInitialPokemonIndex(PlayerType.me);
    bool isFaintingChange =
        getPokemonIndex(PlayerType.me, null) != initialIndex &&
            getPokemonStates(PlayerType.me)[initialIndex - 1]
                .isFainting; // 死に出しかどうか
    getPokemonState(PlayerType.me, null).processTurnEnd(this, isFaintingChange);
    initialIndex = currentTurn.getInitialPokemonIndex(PlayerType.opponent);
    isFaintingChange =
        getPokemonIndex(PlayerType.opponent, null) != initialIndex &&
            getPokemonStates(PlayerType.opponent)[initialIndex - 1]
                .isFainting; // 死に出しかどうか
    getPokemonState(PlayerType.opponent, null)
        .processTurnEnd(this, isFaintingChange);
    // 天気のターン経過
    _weather.turns++;
    // フィールドのターン経過
    _field.turns++;
  }

  // 現在の状態で、指定されたタイミングで起こるべき効果のリストを返す
  List<TurnEffect> getDefaultEffectList(
    Turn currentTurn,
    Timing timing,
    bool changedOwn,
    bool changedOpponent,
    PhaseState state,
    TurnEffectAction? prevAction,
  ) {
    List<TurnEffect> ret = [];
    var players = [PlayerType.me, PlayerType.opponent];

    switch (timing) {
      case Timing.pokemonAppear: // ポケモン登場時
        {
          // ポケモン登場時には無条件で発動する効果
          var timingIDs = [Timing.pokemonAppear];
          // ポケモン登場時&天気がxxでない
          if (weather.id != Weather.rainy) {
            timingIDs.add(Timing.pokemonAppearNotRained);
          }
          if (weather.id != Weather.sandStorm) {
            timingIDs.add(Timing.pokemonAppearNotSandStormed);
          }
          if (weather.id != Weather.sunny) {
            timingIDs.add(Timing.pokemonAppearNotSunny);
          }
          if (weather.id != Weather.snowy) {
            timingIDs.add(Timing.pokemonAppearNotSnowed);
          }
          // ポケモン登場時&フィールドがxxではない
          if (field.id != Field.electricTerrain) {
            // ポケモン登場時(エレキフィールドでない)
            timingIDs.add(Timing.pokemonAppearNotEreciField);
          }
          if (field.id != Field.psychicTerrain) {
            // ポケモン登場時(サイコフィールドでない)
            timingIDs.add(Timing.pokemonAppearNotPsycoField);
          }
          if (field.id != Field.mistyTerrain) {
            // ポケモン登場時(ミストフィールドでない)
            timingIDs.add(Timing.pokemonAppearNotMistField);
          }
          if (field.id != Field.grassyTerrain) {
            // ポケモン登場時(グラスフィールドでない)
            timingIDs.add(Timing.pokemonAppearNotGrassField);
          }
          for (final player in players) {
            bool changed =
                player == PlayerType.me ? changedOwn : changedOpponent;
            if (changed) {
              var myState = getPokemonState(player, null);
              var yourState = getPokemonState(player.opposite, null);
              var myTimingIDs = [...timingIDs];
              // とくせい
              if (myTimingIDs.contains(myState.currentAbility.timing)) {
                final adding = TurnEffectAbility(
                    player: player,
                    timing: timing,
                    abilityID: myState.currentAbility.id);
                adding.setAutoArgs(myState, yourState, state, prevAction);
                ret.add(adding);
              }
              // 各ポケモンの場
              var indiField = getIndiFields(player);
              for (final f in indiField) {
                if (f.isActive(timing, myState, state)) {
                  var adding = TurnEffectIndividualField(
                      player: player,
                      timing: timing,
                      indiFieldEffectID: IndiFieldEffect.getIdFromIndiField(f));
                  adding.setAutoArgs(myState, yourState, state, prevAction);
                  ret.add(adding);
                }
              }
            }
          }
        }
        break;
      case Timing.beforeMove: // わざ使用前
        var attackerState = prevAction != null
            ? getPokemonState(prevAction.playerType, prevAction)
            : getPokemonState(PlayerType.me, prevAction);
        var defenderState = prevAction != null
            ? getPokemonState(prevAction.playerType.opposite, prevAction)
            : getPokemonState(PlayerType.opponent, prevAction);
        var attackerPlayerType =
            prevAction != null ? prevAction.playerType : PlayerType.me;
        var defenderPlayerType = prevAction != null
            ? prevAction.playerType.opposite
            : PlayerType.opponent;
        var defenderTimingIDList = [];
        bool isDefenderFull = defenderPlayerType == PlayerType.me
            ? defenderState.remainHP >= defenderState.pokemon.h.real
            : defenderState.remainHPPercent >= 100;

        // 状態変化
        for (final ailment in attackerState.ailmentsIterable) {
          if (ailment.isActive(attackerPlayerType == PlayerType.me, timing,
              attackerState, state)) {
            var adding = TurnEffectAilment(
                player: attackerPlayerType,
                timing: timing,
                ailmentEffectID: AilmentEffect.getIdFromAilment(ailment))
              ..turns = ailment.turns;
            adding.setAutoArgs(attackerState, defenderState, state, prevAction);
            ret.add(adding);
          }
        }

        if (prevAction != null &&
            prevAction.isNormallyHit() &&
            prevAction.moveEffectivenesses != MoveEffectiveness.noEffect) {
          // わざ成功時
          var replacedMoveType = prevAction.getReplacedMoveType(
              prevAction.move, attackerState, state);
          // とくせい「へんげんじざい」「リベロ」
          if (!attackerState.isTerastaling &&
              !attackerState.hiddenBuffs.containsByID(BuffDebuff.protean) &&
              (attackerState.currentAbility.id == 168 ||
                  attackerState.currentAbility.id == 236)) {
            ret.add(TurnEffectAbility(
                player: attackerPlayerType,
                timing: Timing.beforeMove,
                abilityID: attackerState.currentAbility.id)
              ..extraArg1 = replacedMoveType.index);
          }
          // ノーマルタイプのこうげきをうけたとき
          if (replacedMoveType == PokeType.normal) {
            defenderTimingIDList.add(148);
          }
          var effectiveness = PokeTypeEffectiveness.effectiveness(
              attackerState.currentAbility.id == 113 ||
                  attackerState.currentAbility.id == 299,
              defenderState.holdingItem?.id == 586,
              defenderState
                  .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                  .isNotEmpty,
              replacedMoveType,
              defenderState);
          if (isDefenderFull &&
              (effectiveness == MoveEffectiveness.normal ||
                  effectiveness == MoveEffectiveness.great)) {
            // HPが満タンで等倍以上のタイプ相性わざを受ける前
            defenderTimingIDList.add(168);
          }
          if (effectiveness == MoveEffectiveness.great) {
            final moveType = replacedMoveType;
            switch (moveType) {
              case PokeType.fire:
                defenderTimingIDList.add(131);
                break;
              case PokeType.water:
                defenderTimingIDList.add(132);
                break;
              case PokeType.electric:
                defenderTimingIDList.add(133);
                break;
              case PokeType.grass:
                defenderTimingIDList.add(134);
                break;
              case PokeType.ice:
                defenderTimingIDList.add(135);
                break;
              case PokeType.fight:
                defenderTimingIDList.add(136);
                break;
              case PokeType.poison:
                defenderTimingIDList.add(137);
                break;
              case PokeType.ground:
                defenderTimingIDList.add(138);
                break;
              case PokeType.fly:
                defenderTimingIDList.add(139);
                break;
              case PokeType.psychic:
                defenderTimingIDList.add(140);
                break;
              case PokeType.bug:
                defenderTimingIDList.add(141);
                break;
              case PokeType.rock:
                defenderTimingIDList.add(142);
                break;
              case PokeType.ghost:
                defenderTimingIDList.add(143);
                break;
              case PokeType.dragon:
                defenderTimingIDList.add(144);
                break;
              case PokeType.evil:
                defenderTimingIDList.add(145);
                break;
              case PokeType.steel:
                defenderTimingIDList.add(146);
                break;
              case PokeType.fairy:
                defenderTimingIDList.add(147);
                break;
              default:
                break;
            }
          }
          if (defenderState.holdingItem != null &&
              defenderTimingIDList
                  .contains(defenderState.holdingItem!.timing)) {
            var addingItem = TurnEffectItem(
                player: defenderPlayerType,
                timing: Timing.afterMove,
                itemID: defenderState.holdingItem!.id);
            addingItem.setAutoArgs(
                defenderState, attackerState, state, prevAction);
            ret.add(addingItem);
          }
        }
        break;
      case Timing.afterMove: // わざ使用後
        {
          var attackerState = prevAction != null
              ? getPokemonState(prevAction.playerType, prevAction)
              : getPokemonState(PlayerType.me, prevAction);
          var defenderState = prevAction != null
              ? getPokemonState(prevAction.playerType.opposite, prevAction)
              : getPokemonState(PlayerType.opponent, prevAction);
          var attackerPlayerType =
              prevAction != null ? prevAction.playerType : PlayerType.me;
          var defenderPlayerType = prevAction != null
              ? prevAction.playerType.opposite
              : PlayerType.opponent;
          var defenderTimingIDList = [];
          var attackerTimingIDList = [];
          var replacedMove =
              prevAction?.getReplacedMove(prevAction.move, attackerState);
          var replacedMoveType = prevAction?.getReplacedMoveType(
              prevAction.move, attackerState, state);
          // 直接こうげきをまもる系統のわざで防がれたとき
          if (prevAction != null &&
                  replacedMove!.isDirect &&
                  !(replacedMove.isPunch &&
                      attackerState.holdingItem?.id ==
                          1700) && // パンチグローブをつけたパンチわざでない
                  attackerState.currentAbility.id != 203 // とくせいがえんかくでない
              ) {
            var findIdx = defenderState
                .ailmentsIndexWhere((e) => e.id == Ailment.protect);
            if (findIdx >= 0 &&
                defenderState.ailments(findIdx).extraArg1 != 0) {
              var id = defenderState.ailments(findIdx).extraArg1;
              int extraArg1 = 0;
              if (id == 596) {
                if (attackerPlayerType == PlayerType.me) {
                  extraArg1 = (attackerState.pokemon.h.real / 8).floor();
                } else {
                  extraArg1 = 12;
                }
              }
              ret.add(
                  TurnEffectAfterMove(player: attackerPlayerType, effectID: id)
                    ..extraArg1 = extraArg1);
            }
          }
          // みちづれ状態の相手をひんしにしたとき
          if (prevAction != null &&
              defenderState.isFainting &&
              defenderState
                  .ailmentsWhere((e) => e.id == Ailment.destinyBond)
                  .isNotEmpty) {
            ret.add(
                TurnEffectAfterMove(player: attackerPlayerType, effectID: 194));
          }
          if (prevAction != null &&
              prevAction.isNormallyHit() &&
              prevAction.moveEffectivenesses != MoveEffectiveness.noEffect) {
            // わざ成功時
            if (replacedMove!.damageClass.id == 1 && replacedMove.isTargetYou) {
              // へんかわざを受けた後
              defenderTimingIDList.add(Timing.statused);
            }
            if (replacedMove.damageClass.id >= 2) {
              // こうげきわざヒット後
              attackerTimingIDList.add(Timing.attackHitted);
              // うのみ状態/まるのみ状態で相手にこうげきされた後
              final unomis = defenderState.buffDebuffs.whereByAnyID(
                  [BuffDebuff.unomiForm, BuffDebuff.marunomiForm]);
              if (unomis.isNotEmpty) {
                ret.add(TurnEffectAbility(
                    player: defenderPlayerType,
                    timing: Timing.afterMove,
                    abilityID: (10000 + unomis.first.id)));
              }
              // こうげきわざでひんしにした後
              if (defenderState.isFainting) {
                attackerTimingIDList.add(Timing.defeatOpponentWithAttack);
              }
              // ぶつりこうげきを受けた時
              if (replacedMove.damageClass.id == DamageClass.physical) {
                defenderTimingIDList.add(Timing.phisycalAttackedHitted);
              }
              // こうげきわざを受けた後
              defenderTimingIDList.addAll(
                  [Timing.attackedHitted, Timing.pokemonAppearAttacked]);
              // ゾロアーク系がばれていないときにこうげきわざを受けた後
              if (!defenderState.hiddenBuffs
                  .containsByID(BuffDebuff.zoroappear)) {
                defenderTimingIDList.add(Timing.attackedNotZoroappeared);
              }
              // ばけたすがたでこうげきを受けた後
              if (defenderState.buffDebuffs
                  .containsByID(BuffDebuff.transedForm)) {
                defenderTimingIDList.add(Timing.attackedHittedWithBake);
              }
              // こうげきわざを受けてひんしになったとき
              if (defenderState.isFainting) {
                defenderTimingIDList.add(Timing.attackedFainting);
              }
              // ノーマルタイプのこうげきをうけたとき
              if (replacedMoveType! == PokeType.normal) {
                defenderTimingIDList.add(148);
              }
              // あくタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.evil) {
                defenderTimingIDList.addAll([86, 87]);
              }
              // みずタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.water) {
                defenderTimingIDList.addAll([92, 104]);
              }
              // ほのおタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.fire) {
                defenderTimingIDList.addAll([104, 107]);
              }
              // でんきタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.electric) {
                defenderTimingIDList.addAll([118]);
              }
              // こおりタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.ice) {
                defenderTimingIDList.addAll([119]);
              }
              // ゴーストタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.ghost) {
                defenderTimingIDList.addAll([87]);
              }
              // むしタイプのこうげきをうけたとき
              if (replacedMoveType == PokeType.bug) {
                defenderTimingIDList.addAll([92]);
              }
              // 直接こうげきを受けた後
              if (replacedMove.isDirect &&
                      !(replacedMove.isPunch &&
                          attackerState.holdingItem?.id ==
                              1700) && // パンチグローブをつけたパンチわざでない
                      attackerState.currentAbility.id != 203 // とくせいがえんかくでない
                  ) {
                // ぼうごパットで防がれないなら
                if (attackerState.holdingItem?.id != 897) {
                  defenderTimingIDList.addAll([Timing.directAttacked]);
                  // 直接攻撃によってひんしになった場合
                  if (defenderState.isFainting) {
                    defenderTimingIDList
                        .addAll([Timing.directAttackedFainting]);
                  }
                }
              }
            }
            // 優先度1以上のわざを受けた後
            if (replacedMove.priority >= 1) {
              defenderTimingIDList.add(Timing.priorityMoved);
            }
            // 音技を使った後/受けた後
            if (replacedMove.isSound) {
              attackerTimingIDList.add(Timing.soundAttack);
              defenderTimingIDList.add(Timing.soundAttacked);
            }
            // 風の技を受けた後
            if (replacedMove.isWind) {
              defenderTimingIDList.add(Timing.winded);
            }
            if (replacedMove.isPowder) {
              // こな系のこうげきを受けた時
              defenderTimingIDList.add(Timing.powdered);
            }
            if (replacedMove.isBullet) {
              // 弾のこうげきを受けた時
              defenderTimingIDList.add(Timing.bulleted);
            }
            // HP吸収わざを受けた後
            if (replacedMove.isDrain) {
              defenderTimingIDList.add(Timing.drained);
            }
            if (replacedMoveType! == PokeType.electric) {
              // でんきタイプのわざをうけた時
              defenderTimingIDList
                  .addAll([Timing.electriced, Timing.electricUse]);
            }
            if (replacedMoveType == PokeType.water) {
              // みずタイプのわざをうけた時
              defenderTimingIDList.addAll([
                Timing.watered,
                Timing.fireWaterAttackedSunnyRained,
                Timing.waterUse
              ]);
            }
            if (replacedMoveType == PokeType.fire) {
              // ほのおタイプのわざをうけた時
              defenderTimingIDList
                  .addAll([Timing.fired, Timing.fireWaterAttackedSunnyRained]);
            }
            if (replacedMoveType == PokeType.grass) {
              // くさタイプのわざをうけた時
              defenderTimingIDList.addAll([Timing.grassed]);
            }
            if (replacedMoveType == PokeType.ground) {
              // じめんタイプのわざをうけた時
              defenderTimingIDList.addAll([Timing.grounded]);
              if (replacedMove.id != 28 && replacedMove.id != 614) {
                // すなかけ/サウザンアローではない
                defenderTimingIDList.addAll([Timing.groundFieldEffected]);
              }
            }
            if (PokeTypeEffectiveness.effectiveness(
                    attackerState.currentAbility.id == 113 ||
                        attackerState.currentAbility.id == 299,
                    defenderState.holdingItem?.id == 586,
                    defenderState
                        .ailmentsWhere((e) => e.id == Ailment.miracleEye)
                        .isNotEmpty,
                    replacedMoveType,
                    defenderState) ==
                MoveEffectiveness.great) {
              // 効果ばつぐんのわざを受けた後
              defenderTimingIDList.addAll([Timing.greatAttacked]);
              final moveType = replacedMoveType;
              switch (moveType) {
                case PokeType.fire:
                  defenderTimingIDList.add(131);
                  break;
                case PokeType.water:
                  defenderTimingIDList.add(132);
                  break;
                case PokeType.electric:
                  defenderTimingIDList.add(133);
                  break;
                case PokeType.grass:
                  defenderTimingIDList.add(134);
                  break;
                case PokeType.ice:
                  defenderTimingIDList.add(135);
                  break;
                case PokeType.fight:
                  defenderTimingIDList.add(136);
                  break;
                case PokeType.poison:
                  defenderTimingIDList.add(137);
                  break;
                case PokeType.ground:
                  defenderTimingIDList.add(138);
                  break;
                case PokeType.fly:
                  defenderTimingIDList.add(139);
                  break;
                case PokeType.psychic:
                  defenderTimingIDList.add(140);
                  break;
                case PokeType.bug:
                  defenderTimingIDList.add(141);
                  break;
                case PokeType.rock:
                  defenderTimingIDList.add(142);
                  break;
                case PokeType.ghost:
                  defenderTimingIDList.add(143);
                  break;
                case PokeType.dragon:
                  defenderTimingIDList.add(144);
                  break;
                case PokeType.evil:
                  defenderTimingIDList.add(145);
                  break;
                case PokeType.steel:
                  defenderTimingIDList.add(146);
                  break;
                case PokeType.fairy:
                  defenderTimingIDList.add(147);
                  break;
                default:
                  break;
              }
            } else {
              // 効果ばつぐん以外のわざを受けたとき
              defenderTimingIDList.addAll([Timing.notGreatAttacked]);
            }
          }

          // 対応するタイミングに該当するとくせい
          if (attackerTimingIDList
              .contains(attackerState.currentAbility.timing)) {
            ret.add(TurnEffectAbility(
                player: attackerPlayerType,
                timing: Timing.afterMove,
                abilityID: attackerState.currentAbility.id));
          }
          // こうげきを受ける側のとくせいは、かたやぶり等によって発動しない場合あり
          if (defenderTimingIDList
                  .contains(defenderState.currentAbility.timing) &&
              (!defenderState.currentAbility.canIgnored ||
                  !attackerState.buffDebuffs.containsByAnyID([
                    BuffDebuff.noAbilityEffect,
                    BuffDebuff.myceliumMight
                  ]))) {
            var addingAbility = TurnEffectAbility(
                player: defenderPlayerType,
                timing: Timing.afterMove,
                abilityID: defenderState.currentAbility.id);
            addingAbility.setAutoArgs(
                defenderState, attackerState, state, prevAction);
            ret.add(addingAbility);
          }
          // 対応するタイミングに該当するもちもの
          if (attackerState.holdingItem != null &&
              attackerTimingIDList
                  .contains(attackerState.holdingItem!.timing)) {
            var addingItem = TurnEffectItem(
                player: attackerPlayerType,
                timing: Timing.afterMove,
                itemID: attackerState.holdingItem!.id);
            addingItem.setAutoArgs(
                attackerState, defenderState, state, prevAction);
            ret.add(addingItem);
          }
          if (defenderState.holdingItem != null &&
              defenderTimingIDList
                  .contains(defenderState.holdingItem!.timing)) {
            var addingItem = TurnEffectItem(
                player: defenderPlayerType,
                timing: Timing.afterMove,
                itemID: defenderState.holdingItem!.id);
            addingItem.setAutoArgs(
                defenderState, attackerState, state, prevAction);
            ret.add(addingItem);
          }
        }
        break;
      case Timing.everyTurnEnd: // 毎ターン終了時
        {
          // 自分/相手ごとにforループ
          for (int i = 0; i < 2; i++) {
            List<Timing> playerTimingIDs = [];
            var player = players[i];
            var myState = getPokemonState(player, null);
            var yourState = getPokemonState(player.opposite, null);
            bool isMe = player == PlayerType.me;

            // 死に出しなら発動する効果はない
            if (getPokemonStates(
                    player)[currentTurn.getInitialPokemonIndex(player) - 1]
                .isFainting) continue;

            // 毎ターン終了時には無条件で発動する効果
            playerTimingIDs = [Timing.everyTurnEnd];
            // 1度でも行動した後毎ターン終了時
            if (currentTurn.getInitialPokemonIndex(player) ==
                getPokemonIndex(player, null)) {
              playerTimingIDs.add(Timing.afterActedEveryTurnEnd);
            }
            if (weather.id == Weather.rainy) {
              playerTimingIDs.addAll([
                Timing.everyTurnEndRained,
                Timing.fireWaterAttackedSunnyRained
              ]); // 天気があめのとき、毎ターン終了時
              if (myState
                  .ailmentsWhere((element) => element.id <= Ailment.sleep)
                  .isNotEmpty) {
                // かつ状態異常のとき
                playerTimingIDs.add(Timing.everyTurnEndRainedWithAbnormal);
              }
            }
            if (weather.id == Weather.sunny) {
              // 天気が晴れのとき、毎ターン終了時
              playerTimingIDs.addAll([
                Timing.fireWaterAttackedSunnyRained,
                Timing.everyTurnEndSunny
              ]);
            }
            if (weather.id == Weather.sunny) {
              // 天気がゆきのとき、毎ターン終了時
              playerTimingIDs.addAll([Timing.everyTurnEndSnowy]);
            }
            if (myState
                .ailmentsWhere(
                    (e) => e.id == Ailment.poison || e.id == Ailment.badPoison)
                .isNotEmpty) {
              // どく/もうどく状態
              playerTimingIDs.add(Timing.poisonDamage);
            }
            if (!myState.isTerastaling) {
              // テラスタルしていない
              playerTimingIDs.add(Timing.everyTurnEndNotTerastaled);
            }
            if (myState.ailmentsWhere((e) => e.id <= Ailment.sleep).isEmpty) {
              // 状態異常でない毎ターン終了時
              playerTimingIDs.add(Timing.everyTurnEndNotAbnormal);
            }
            if ((isMe &&
                    myState.remainHP < myState.pokemon.h.real &&
                    myState.remainHP > 0) ||
                (!isMe &&
                    myState.remainHPPercent < 100 &&
                    myState.remainHPPercent > 0)) {
              // HPが満タンでない毎ターン終了時
              playerTimingIDs.add(Timing.everyTurnEndHPNotFull);
              // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
              if (myState.isTypeContain(PokeType.poison)) {
                playerTimingIDs.add(Timing.everyTurnEndHPNotFull2);
              }
            }
            // 持っているポケモンがどくタイプ→HPが満タンでない毎ターン終了時、どくタイプ以外→毎ターン終了時
            if (!myState.isTypeContain(PokeType.poison)) {
              playerTimingIDs.add(Timing.everyTurnEndHPNotFull2);
            }
            // こだいかっせい発動中に天気が晴れでなくなった/なくなる場合
            if (myState.buffDebuffs.list
                .where((e) =>
                    e.id >= BuffDebuff.attack1_3 &&
                    e.id <= BuffDebuff.speed1_5 &&
                    e.extraArg1 == 0)
                .isNotEmpty) {
              if (weather.id != Weather.sunny ||
                  weather.turns >= weather.maxTurns - 1) {
                playerTimingIDs.add(Timing.sunnyBoostEnergy);
              }
              if (field.id != Field.electricTerrain ||
                  field.turns >= field.maxTurns - 1) {
                playerTimingIDs.add(Timing.elecFieldBoostEnergy);
              }
            }

            // とくせい
            if (playerTimingIDs.contains(myState.currentAbility.timing)) {
              var addingAbility = TurnEffectAbility(
                  player: player,
                  timing: timing,
                  abilityID: myState.currentAbility.id);
              addingAbility.setAutoArgs(myState, yourState, state, prevAction);
              ret.add(addingAbility);
            }

            // もちもの
            if (myState.holdingItem != null &&
                playerTimingIDs.contains(myState.holdingItem!.timing)) {
              var addingItem = TurnEffectItem(
                  player: player,
                  timing: timing,
                  itemID: myState.holdingItem!.id);
              addingItem.setAutoArgs(myState, yourState, state, prevAction);
              ret.add(addingItem);
            }

            // 状態異常
            for (final ailment in myState.ailmentsIterable) {
              if (ailment.isActive(
                  player == PlayerType.me, timing, myState, state)) {
                // ターン経過で効果が現れる状態変化の判定
                var adding = TurnEffectAilment(
                    player: player,
                    timing: timing,
                    ailmentEffectID: AilmentEffect.getIdFromAilment(ailment))
                  ..turns = ailment.turns
                  ..extraArg1 = ailment.id == Ailment.partiallyTrapped
                      ? ailment.extraArg1
                      : ailment.turns;
                adding.setAutoArgs(myState, yourState, state, prevAction);
                ret.add(adding);
              }
            }

            // 各ポケモンの場の効果
            var fields = getIndiFields(player);
            for (final field in fields) {
              if (field.isActive(timing, myState, state)) {
                // ターン経過で終了する場の判定
                var adding = TurnEffectIndividualField(
                    player:
                        field.isEntireField ? PlayerType.entireField : player,
                    timing: timing,
                    indiFieldEffectID:
                        IndiFieldEffect.getIdFromIndiField(field));
                adding.setAutoArgs(myState, yourState, state, prevAction);
                if (ret
                    .where((element) =>
                        element is TurnEffectIndividualField &&
                        element.nearEqual(adding))
                    .isEmpty) {
                  // 両者の場の場合に重複がないようにする
                  ret.add(adding);
                }
              }
            }
          }

          // 両者に効果があるもの
          var weatherEffectIDs = [];
          if (weather.turns >= weather.maxTurns - 1) {
            // 天気終了
            int effectId = WeatherEffect.getIdFromWeather(weather);
            if (effectId > 0) weatherEffectIDs.add(effectId);
          } else if (weather.id == Weather.sandStorm) {
            // すなあらしによるダメージ
            bool occurSandStromDamage = false;
            for (final player in [PlayerType.me, PlayerType.opponent]) {
              occurSandStromDamage = occurSandStromDamage ||
                  (
                      // ポケモンがすなあらしダメージを受ける対象か
                      getPokemonState(player, null).isSandstormDamaged() &&
                          // 死に出しによる登場でないか
                          !getPokemonStates(player)[
                                  currentTurn.getInitialPokemonIndex(player) -
                                      1]
                              .isFainting);
            }
            if (occurSandStromDamage) {
              weatherEffectIDs.add(WeatherEffect.sandStormDamage);
            }
          }
          var fieldEffectIDs = [];
          if (field.id == Field.grassyTerrain) {
            // グラスフィールドによる回復
            final ownState = getPokemonState(PlayerType.me, null);
            final opponentState = getPokemonState(PlayerType.opponent, null);
            if ((ownState.isGround(state.getIndiFields(PlayerType.me)) &&
                    !ownState.isFainting &&
                    ownState.remainHP < ownState.pokemon.h.real) ||
                (opponentState
                        .isGround(state.getIndiFields(PlayerType.opponent)) &&
                    !opponentState.isFainting &&
                    opponentState.remainHPPercent < 100)) {
              fieldEffectIDs.add(FieldEffect.grassHeal);
            }
          }
          if (field.turns >= field.maxTurns - 1) {
            // フィールド終了
            int effectId = FieldEffect.getIdFromField(field);
            if (effectId > 0) fieldEffectIDs.add(effectId);
          }

          // 天気
          for (var e in weatherEffectIDs) {
            int extraArg1 = 0;
            int extraArg2 = 0;
            if (e == WeatherEffect.sandStormDamage) {
              if (getPokemonState(PlayerType.me, null).isSandstormDamaged()) {
                // すなあらしによるダメージ
                extraArg1 =
                    (getPokemonState(PlayerType.me, null).pokemon.h.real / 16)
                        .floor();
              }
              if (getPokemonState(PlayerType.opponent, null)
                  .isSandstormDamaged()) {
                extraArg2 = 6;
              }
            }
            ret.add(TurnEffectWeather(
                timing: Timing.everyTurnEnd, weatherEffectID: e)
              ..extraArg1 = extraArg1
              ..extraArg2 = extraArg2);
          }
          // フィールド
          for (var e in fieldEffectIDs) {
            int extraArg1 = 0;
            int extraArg2 = 0;
            if (e == FieldEffect.grassHeal) {
              if (getPokemonState(PlayerType.me, null)
                  .isGround(state.getIndiFields(PlayerType.me))) {
                // グラスフィールドによる回復
                extraArg1 =
                    -(getPokemonState(PlayerType.me, null).pokemon.h.real / 16)
                        .floor();
              }
              if (getPokemonState(PlayerType.opponent, null)
                  .isGround(state.getIndiFields(PlayerType.opponent))) {
                extraArg2 = -6;
              }
            }
            ret.add(
                TurnEffectField(timing: Timing.everyTurnEnd, fieldEffectID: e)
                  ..extraArg1 = extraArg1
                  ..extraArg2 = extraArg2);
          }
        }
        break;
      case Timing.afterTerastal: // テラスタル後
        {
          // 自分/相手ごとにforループ
          for (int i = 0; i < 2; i++) {
            var player = players[i];
            var myState = getPokemonState(player, null);
            bool isMe = player == PlayerType.me;
            bool isTerastal = myState.isTerastaling &&
                (isMe
                    ? !currentTurn.initialOwnHasTerastal
                    : !currentTurn.initialOpponentHasTerastal);

            if (isTerastal &&
                (myState.currentAbility.id == 303 ||
                    myState.currentAbility.id == 306)) {
              // おもかげやどし/ゼロフォーミング
              ret.add(TurnEffectAbility(
                  player: player,
                  timing: Timing.afterTerastal,
                  abilityID: myState.currentAbility.id));
            }
          }
        }
        break;
      default:
        break;
    }

    // 各タイミング共通
    // 自分/相手ごとにforループ
    for (int i = 0; i < 2; i++) {
      List<Timing> playerTimings = [];
      var player = players[i];
      var myState = getPokemonState(
          player, timing == Timing.afterMove ? prevAction : null);
      var yourState = getPokemonState(
          player.opposite, timing == Timing.afterMove ? prevAction : null);
      bool isMe = player == PlayerType.me;

      if ((isMe &&
              myState.remainHP <= myState.pokemon.h.real / 4 &&
              myState.remainHP > 0) ||
          (!isMe &&
              myState.remainHPPercent <= 25 &&
              myState.remainHPPercent > 0)) {
        playerTimings.add(Timing.hp025);
      }
      if ((isMe &&
              myState.remainHP <= myState.pokemon.h.real / 2 &&
              myState.remainHP > 0) ||
          (!isMe &&
              myState.remainHPPercent <= 50 &&
              myState.remainHPPercent > 0)) {
        playerTimings.add(Timing.hp050);
      }

      // こだいかっせい/ブーストエナジー発動の余地がある場合
      if (myState.buffDebuffs.list
                  .where((e) =>
                      e.id >= BuffDebuff.attack1_3 &&
                      e.id <= BuffDebuff.speed1_5)
                  .isEmpty &&
              ((isMe && (timing == Timing.pokemonAppear || !changedOwn)) ||
                  (!isMe &&
                      (timing == Timing.pokemonAppear ||
                          !changedOpponent))) // 交代で手持ちに戻るときでないなら
          ) {
        if (weather.id == Weather.sunny) {
          playerTimings.add(Timing.sunnyBoostEnergy);
        }
        if (field.id == Field.electricTerrain) {
          playerTimings.add(Timing.elecFieldBoostEnergy);
        }
        if (myState.holdingItem?.id == 1696) {
          playerTimings
              .addAll([Timing.sunnyBoostEnergy, Timing.elecFieldBoostEnergy]);
        }
      }

      // 能力ランクが下がった
      if (myState.hiddenBuffs.containsByID(BuffDebuff.thisTurnDownStatChange)) {
        playerTimings.add(Timing.statDowned);
      }

      // とくせい
      if (playerTimings.contains(myState.currentAbility.timing)) {
        var addingAbility = TurnEffectAbility(
            player: player,
            timing: timing,
            abilityID: myState.currentAbility.id);
        addingAbility.setAutoArgs(myState, yourState, state, prevAction);
        ret.add(addingAbility);
      }

      // もちもの
      if (playerTimings.contains(Timing.hp050) &&
          myState.currentAbility.id == 82) {
        // とくせいがくいしんぼうの場合はHP50%以下ならHP25%以下タイミングも併発
        playerTimings.add(Timing.hp025);
      }
      if (myState.holdingItem != null &&
          playerTimings.contains(myState.holdingItem!.timing)) {
        var addingItem = TurnEffectItem(
            player: player, timing: timing, itemID: myState.holdingItem!.id);
        addingItem.setAutoArgs(myState, yourState, state, prevAction);
        ret.add(addingItem);
      }
    }

/*
    for (var effect in ret) {
      effect.isAutoSet = true;
    }
*/

    return ret;
  }

  // 現在場に出ているポケモン(A)のNoを変える
  void makePokemonOther(
    PlayerType player,
    int no, {
    Party? ownParty,
    Party? opponentParty,
  }) {
    if (no == 0) return;
    if (getPokemonState(player, null).pokemon.no == no) return;
    // 変更先ポケモン(B)がパーティにいるかどうか
    int index = -1;
    for (int i = 0; i < getPokemonStates(player).length; i++) {
      if (no == getPokemonStates(player)[i].pokemon.no) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      // 現在のステータスをBにコピー
      var pokemon = getPokemonStates(player)[index].pokemon;
      getPokemonStates(player)[index] = getPokemonState(player, null).copy()
        ..pokemon = pokemon;
      // Aのステータスを、最後に場にいた状態に戻す
      int currentIndex = getPokemonIndex(player, null);
      getPokemonStates(player)[currentIndex - 1] =
          lastExitedStates[player == PlayerType.me ? 0 : 1][currentIndex - 1]
              .copy();
      // 現在のインデックス変更(Bを指すように)
      setPokemonIndex(player, index + 1);
    } else {
      // 現在のポケモンをまんま変えてしまう(TODO: 不具合でるかも？)
      var pokemonState = getPokemonState(player, null);
      var base = PokeDB().pokeBase[no]!;
      var party = player == PlayerType.me ? ownParty : opponentParty;
      if (party == null) {
        print("arienai");
        return;
      }
      party.pokemons[getPokemonIndex(player, null) - 1]!
        //..name = base.name
        ..no = base.no // nameも変わる
        ..type1 = base.type1
        ..type2 = base.type2
        ..sex = pokemonState.sex
        ..h.race = base.h
        ..a.race = base.a
        ..b.race = base.b
        ..c.race = base.c
        ..d.race = base.d
        ..s.race = base.s
        ..teraType = base.fixedTeraType == PokeType.unknown
            ? pokemonState.teraType1
            : base.fixedTeraType;
      Pokemon poke = party.pokemons[getPokemonIndex(player, null) - 1]!;
      if (base.fixedItemID != 0) poke.item = PokeDB().items[base.fixedItemID];
      pokemonState.pokemon = poke;
      pokemonState.possibleAbilities = base.ability;
      pokemonState.type1 = poke.type1;
      pokemonState.type2 = poke.type2;
      if (pokemonState.getHoldingItem()?.id == 0) {
        pokemonState.setHoldingItemNoEffect(PokeDB().items[base.fixedItemID]);
      }
    }
  }

  // SQLに保存された文字列からTurnをパース
  static PhaseState deserialize(
    dynamic str,
    String split1,
    String split2,
    String split3,
    String split4,
    String split5,
    String split6, {
    int version = -1,
  }) // -1は最新バージョン
  {
    PhaseState ret = PhaseState();
    final List stateElements = str.split(split1);
    // _pokemonIndexes
    var indexes = stateElements.removeAt(0).split(split2);
    ret._pokemonIndexes.clear();
    for (final index in indexes) {
      if (index == '') break;
      ret._pokemonIndexes.add(int.parse(index));
    }
    // _pokemonStates
    var pokeStates = stateElements.removeAt(0).split(split2);
    ret._pokemonStates.clear();
    for (final pokeState in pokeStates) {
      if (pokeState == '') break;
      var states = pokeState.split(split3);
      List<PokemonState> adding = [];
      int i = 0;
      for (final state in states) {
        if (state == '') break;
        adding.add(PokemonState.deserialize(state, split4, split5, split6,
            version: version)
          ..playerType = i == 0 ? PlayerType.me : PlayerType.opponent);
        i++;
      }
      ret._pokemonStates.add(adding);
    }
    // lastExitedStates
    pokeStates = stateElements.removeAt(0).split(split2);
    ret.lastExitedStates.clear();
    for (final pokeState in pokeStates) {
      if (pokeState == '') break;
      var states = pokeState.split(split3);
      List<PokemonState> adding = [];
      int i = 0;
      for (final state in states) {
        if (state == '') break;
        adding.add(PokemonState.deserialize(state, split4, split5, split6,
            version: version)
          ..playerType = i == 0 ? PlayerType.me : PlayerType.opponent);
        i++;
      }
      ret.lastExitedStates.add(adding);
    }
    // indiFields
    var fields = stateElements.removeAt(0).split(split2);
    ret._indiFields = [[], []];
    for (int i = 0; i < fields.length; i++) {
      if (fields[i] == '') break;
      var fs = fields[i].split(split3);
      List<IndividualField> adding = [];
      for (final f in fs) {
        if (f == '') break;
        adding.add(IndividualField.deserialize(f, split4));
      }
      ret._indiFields[i] = adding;
    }
    // _weather
    ret._weather = Weather.deserialize(stateElements.removeAt(0), split2);
    // _field
    ret._field = Field.deserialize(stateElements.removeAt(0), split2);
    // phases
    var turnEffects = stateElements.removeAt(0).split(split2);
    for (var turnEffect in turnEffects) {
      if (turnEffect == '') break;
      ret.phases.add(TurnEffect.deserialize(turnEffect, split3, split4, split5,
          version: version));
    }
    // phaseIndex
    ret.phaseIndex = int.parse(stateElements.removeAt(0));
    // hasOwnTerastal
    ret.hasOwnTerastal = stateElements.removeAt(0) == '1';
    // hasOpponentTerastal
    ret.hasOpponentTerastal = stateElements.removeAt(0) == '1';
    // canZorua
    ret.canZorua = stateElements.removeAt(0) == '1';
    // canZoroark
    ret.canZoroark = stateElements.removeAt(0) == '1';
    // canZoruaHisui
    ret.canZoruaHisui = stateElements.removeAt(0) == '1';
    // canZoroarkHisui
    ret.canZoroarkHisui = stateElements.removeAt(0) == '1';
    // _faintingCount
    final counts = stateElements.removeAt(0).split(split2);
    ret._faintingCount.clear();
    for (final count in counts) {
      if (count == '') break;
      ret._faintingCount.add(int.parse(count));
    }
    // firstAction
    final element = stateElements.removeAt(0);
    if (element != '') {
      ret.firstAction = TurnEffectAction.deserialize(
          element, split2, split3, split4,
          version: version);
    }

    return ret;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3, String split4,
      String split5, String split6) {
    String ret = '';
    // _pokemonIndexes
    for (final index in _pokemonIndexes) {
      ret += index.toString();
      ret += split2;
    }
    ret += split1;
    // _pokemonStates
    for (final states in _pokemonStates) {
      for (final state in states) {
        ret += state.serialize(split4, split5, split6);
        ret += split3;
      }
      ret += split2;
    }
    ret += split1;
    // lastExitedStates
    for (final states in lastExitedStates) {
      for (final state in states) {
        ret += state.serialize(split4, split5, split6);
        ret += split3;
      }
      ret += split2;
    }
    ret += split1;
    // indiFields
    for (final fields in _indiFields) {
      for (final field in fields) {
        ret += field.serialize(split4);
        ret += split3;
      }
      ret += split2;
    }
    ret += split1;
    // _weather
    ret += _weather.serialize(split2);
    ret += split1;
    // _field
    ret += _field.serialize(split2);
    ret += split1;
    // phases
    for (final phase in phases) {
      ret += phase.serialize(split3, split4, split5);
      ret += split2;
    }
    ret += split1;
    // phaseIndex
    ret += phaseIndex.toString();
    ret += split1;
    // hasOwnTerastal
    ret += hasOwnTerastal ? '1' : '0';
    ret += split1;
    // hasOpponentTerastal
    ret += hasOpponentTerastal ? '1' : '0';
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
    ret += split1;
    // _faintingCount
    for (final count in _faintingCount) {
      ret += count.toString();
      ret += split2;
    }
    ret += split1;
    // firstAction
    ret += firstAction != null
        ? firstAction!.serialize(split2, split3, split4)
        : '';

    return ret;
  }
}
