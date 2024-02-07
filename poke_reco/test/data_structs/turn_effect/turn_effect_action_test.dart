import 'package:flutter/cupertino.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:test/test.dart';

import '../test_poke_db.dart';

void main() async {
  // assetフォルダを直接開いて初期化するテスト用のDB
  TestPokeDB testPokeData = TestPokeDB();
  await testPokeData.initialize();
  PokeDB pokeData = testPokeData.data;
  group('TurnEffectAction class の単体テスト', () {
    final TurnEffectAction turnMove = TurnEffectAction(player: PlayerType.me)
      ..type = TurnActionType.move
      ..teraType = PokeType.fire
      ..move = pokeData.moves[1]!
      ..isSuccess = false
      ..actionFailure = ActionFailure(1)
      ..hitCount = 2
      ..criticalCount = 1
      ..moveEffectivenesses = [MoveEffectiveness.great]
      ..realDamage = [50]
      ..percentDamage = [25]
      ..moveAdditionalEffects = [MoveEffect(1)]
      ..extraArg1 = [1]
      ..extraArg2 = [2]
      ..extraArg3 = [3]
      ..moveType = PokeType.water
      ..isFirst = true;
    turnMove.setChangePokemonIndex(PlayerType.me, 1);
    turnMove.setChangePokemonIndex(PlayerType.opponent, 2);
    final String sqlStr =
        '7:0:1:${PokeType.fire.index}:1:0:1:2:1:${MoveEffectiveness.great.index};:50;:25;:1;:1;:2;:3;:1;2;:${PokeType.water.index}:1';

    test('clear()', () {
      TurnEffectAction testingTurnMove = turnMove.copy();
      testingTurnMove.clear();
      expect(
          testingTurnMove == TurnEffectAction(player: PlayerType.none), true);
    });

    test('clearMove()', () {
      TurnEffectAction testingTurnMove = turnMove.copy();
      testingTurnMove.clearMove();
      TurnEffectAction expectTurnMove =
          TurnEffectAction(player: turnMove.playerType)..type = turnMove.type;
      expect(testingTurnMove == expectTurnMove, true);
    });

    // ハバタクカミ
    final attackerBase = pokeData.pokeBase[987]!;
    Pokemon attacker = Pokemon()
      ..setBasicInfoFromNo(987, setDefaultAbility: false);
    attacker.c.set(attackerBase.c, 31, 252, 0);
    attacker.updateRealStats();
    // カイリュー
    final defenderBase = pokeData.pokeBase[149]!;
    Pokemon defender = Pokemon()
      ..setBasicInfoFromNo(149, setDefaultAbility: false);
    defender.h.set(defenderBase.h, 31, 0, 0);
    defender.b.set(defenderBase.b, 31, 0, 0);
    defender.d.set(defenderBase.d, 31, 0, 0);
    defender.updateRealStats();
    // パーティ作成
    Party ownParty = Party()..pokemons[0] = attacker;
    Party opponentParty = Party()..pokemons[0] = defender;
    Turn turn = Turn()
      ..setInitialPokemonIndex(PlayerType.me, 1)
      ..setInitialPokemonIndex(PlayerType.opponent, 1);
    PokemonState attackerState = PokemonState()
      ..playerType = PlayerType.me
      ..pokemon = ownParty.pokemons[0]!
      ..remainHP = ownParty.pokemons[0]!.h.real
      ..battlingNum = 1
      ..setHoldingItemNoEffect(ownParty.items[0])
      ..usedPPs = List.generate(ownParty.pokemons[0]!.moves.length, (i) => 0)
      ..setCurrentAbilityNoEffect(ownParty.pokemons[0]!.ability)
      ..minStats = SixStats.generate(
          (j) => ownParty.pokemons[0]!.stats[StatIndex.values[j]])
      ..maxStats = SixStats.generate(
          (j) => ownParty.pokemons[0]!.stats[StatIndex.values[j]])
      ..moves = [
        for (int j = 0; j < ownParty.pokemons[0]!.moveNum; j++)
          ownParty.pokemons[0]!.moves[j]!
      ]
      ..type1 = ownParty.pokemons[0]!.type1
      ..type2 = ownParty.pokemons[0]!.type2;
    turn.getInitialPokemonStates(PlayerType.me).add(attackerState);
    turn.getInitialLastExitedStates(PlayerType.me).add(attackerState.copy());
    PokemonState defenderState = PokemonState()
      ..playerType = PlayerType.opponent
      ..pokemon = defender
      ..battlingNum = 1
      ..setHoldingItemNoEffect(
          pokeData.items[pokeData.pokeBase[defender.no]!.fixedItemID])
      ..minStats = SixStats.generate((j) => FourParams.createFromValues(
            statIndex: StatIndex.values[j],
            level: defender.level,
            race: defender.stats[StatIndex.values[j]].race,
            indi: 31, // 今回個体値は固定で
            effort: 0, // 今回努力値は固定で
          )) // 今回せいかく補正はなし固定で
      ..maxStats = SixStats.generate((j) => FourParams.createFromValues(
            statIndex: StatIndex.values[j],
            level: defender.level,
            race: defender.stats[StatIndex.values[j]].race,
            indi: 31, // 今回個体値は固定で
            effort: 0, // 今回努力値は固定で
          )) // 今回せいかく補正はなし固定で
      ..possibleAbilities = pokeData.pokeBase[defender.no]!.ability
      ..type1 = defender.type1
      ..type2 = defender.type2;
    turn.getInitialPokemonStates(PlayerType.opponent).add(defenderState);
    turn
        .getInitialLastExitedStates(PlayerType.opponent)
        .add(defenderState.copy());
    turn.initialOwnPokemonState.processEnterEffect(
        turn.initialOpponentPokemonState, turn.copyInitialState());
    turn.initialOpponentPokemonState.processEnterEffect(
        turn.initialOwnPokemonState, turn.copyInitialState());
    final action = TurnEffectAction(player: PlayerType.me)
      ..type = TurnActionType.move;
    final myMove = pokeData.moves[585]!; // ムーンフォース
    final phaseState = turn.copyInitialState();
    final yourFields = phaseState.getIndiFields(PlayerType.opponent);
    final getter = DamageGetter();
    action.move = turnMove.getReplacedMove(myMove, 0, attackerState);
    if (turnMove.isCriticalFromMove(
        myMove, attackerState, defenderState, yourFields)) {
      action.criticalCount = 1;
    }
    action.moveAdditionalEffects[0] = action.move.isSurelyEffect()
        ? MoveEffect(action.move.effect.id)
        : MoveEffect(0);
    action.moveEffectivenesses[0] = PokeTypeEffectiveness.effectiveness(
        attackerState.currentAbility.id == 113 ||
            attackerState.currentAbility.id == 299,
        defenderState.holdingItem?.id == 586,
        defenderState
            .ailmentsWhere((e) => e.id == Ailment.miracleEye)
            .isNotEmpty,
        turnMove.getReplacedMoveType(action.move, 0, attackerState, phaseState),
        defenderState);
    action.processEffect(
      ownParty,
      attackerState.copy(),
      opponentParty,
      defenderState.copy(),
      phaseState.copy(),
      null,
      0,
      damageGetter: getter,
      loc: lookupAppLocalizations(Locale('ja')),
    );

    test('ダメージ計算（${attacker.name} -> ${defender.name}）', () {
      expect(getter.maxDamage, 200.0);
      expect(getter.minDamage, 168.0);
      expect(getter.maxDamagePercent, 120);
      expect(getter.minDamagePercent, 101);
    });

    test('SQL文字列から変換', () {
      final parsed = TurnEffectAction.deserialize(sqlStr, ':', ';', '_');
      expect(parsed, turnMove);
    });

    test('SQL文字列に変換', () {
      final str = turnMove.serialize(':', ';', '_');
      expect(str, sqlStr);
    });
  });
}
