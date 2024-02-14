import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/pages/register_battle.dart';
import 'package:test/test.dart';

import '../test_poke_db.dart';

const String testDataFile = 'test_data/move_damage.csv';

class DamageTestData {
  int attackerNo = 0;
  int defenderNo = 0;
  String attackerName = '';
  String defenderName = '';
  int moveID = 0;
  String moveName = '';
  int minDamage = 0;
  int maxDamage = 0;
  int minDamagePercent = 0;
  int maxDamagePercent = 0;
}

void main() async {
  // assetフォルダを直接開いて初期化するテスト用のDB
  TestPokeDB testPokeData = TestPokeDB();
  await testPokeData.initialize();
  PokeDB pokeData = testPokeData.data;
  // CSVからデータ読み込み
  List<List> rawData = [];
  List<DamageTestData> damageTestData = [];
  Stream fread = File(testDataFile).openRead();
  await fread
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((String line) {
    rawData.add(line.split(','));
  }).asFuture();
  for (final lineItem in rawData) {
    DamageTestData add = DamageTestData()
      ..attackerNo = int.parse(lineItem[0])
      ..attackerName = lineItem[1]
      ..moveID = int.parse(lineItem[2])
      ..moveName = lineItem[3]
      ..defenderNo = int.parse(lineItem[4])
      ..defenderName = lineItem[5]
      ..minDamage = int.parse(lineItem[6])
      ..maxDamage = int.parse(lineItem[7])
      ..minDamagePercent = int.parse(lineItem[8])
      ..maxDamagePercent = int.parse(lineItem[9]);
    damageTestData.add(add);
  }
  group('TurnEffectAction class の単体テスト', () {
    final TurnEffectAction turnMove = TurnEffectAction(player: PlayerType.me)
      ..type = TurnActionType.move
      ..teraType = PokeType.fire
      ..move = pokeData.moves[1]!
      ..isSuccess = false
      ..actionFailure = ActionFailure(1)
      ..hitCount = 2
      ..criticalCount = 1
      ..moveEffectivenesses = MoveEffectiveness.great
      ..realDamage = 50
      ..percentDamage = 25
      ..moveAdditionalEffects = MoveEffect(1)
      ..extraArg1 = 1
      ..extraArg2 = 2
      ..extraArg3 = 3
      ..moveType = PokeType.water
      ..isFirst = true;
    turnMove.setChangePokemonIndex(PlayerType.me, 1);
    turnMove.setChangePokemonIndex(PlayerType.opponent, 2);
    final String sqlStr =
        '7:0:1:${PokeType.fire.index}:1:0:1:2:1:${MoveEffectiveness.great.index}:50:25:1:1:2:3:1;2;:${PokeType.water.index}:1';

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

    for (final testData in damageTestData) {
      // こうげき側のポケモン
      final attackerBase = pokeData.pokeBase[testData.attackerNo]!;
      Pokemon attacker = Pokemon()
        ..setBasicInfoFromNo(testData.attackerNo, setDefaultAbility: false);
      attacker.a.set(attackerBase.a, 31, 252, 0);
      attacker.c.set(attackerBase.c, 31, 252, 0);
      attacker.updateRealStats();
      // ぼうぎょ側のポケモン
      final defenderBase = pokeData.pokeBase[testData.defenderNo]!;
      Pokemon defender = Pokemon()
        ..setBasicInfoFromNo(testData.defenderNo, setDefaultAbility: false);
      defender.h.set(defenderBase.h, 31, 0, 0);
      defender.b.set(defenderBase.b, 31, 0, 0);
      defender.d.set(defenderBase.d, 31, 0, 0);
      defender.updateRealStats();
      // パーティ作成
      // ダメージ→ステータス計算をする状況を作るため、対戦相手から攻撃された場合を想定してテストする
      Party ownParty = Party()..pokemons[0] = defender;
      Party opponentParty = Party()..pokemons[0] = attacker;
      Turn turn = Turn()
        ..initializeFromPartyInfo(
            ownParty,
            opponentParty,
            CheckedPokemons()
              ..own = [1, 0, 0]
              ..opponent = 1);
      final attackerState =
          turn.getInitialPokemonStates(PlayerType.opponent)[0];
      final defenderState = turn.getInitialPokemonStates(PlayerType.me)[0];
      attackerState.minStats =
          SixStats.generate((j) => FourParams.createFromValues(
                statIndex: StatIndex.values[j],
                level: attacker.level,
                race: attacker.stats[StatIndex.values[j]].race,
                indi: 31, // ダメージ計算時個体値は固定で
                effort: 252, // ダメージ計算時努力値は固定で
              )); // ダメージ計算時せいかく補正はなし固定で
      attackerState.maxStats =
          SixStats.generate((j) => FourParams.createFromValues(
                statIndex: StatIndex.values[j],
                level: attacker.level,
                race: attacker.stats[StatIndex.values[j]].race,
                indi: 31, // ダメージ計算時個体値は固定で
                effort: 252, // ダメージ計算時努力値は固定で
              )); // ダメージ計算時せいかく補正はなし固定で

      final action = TurnEffectAction(player: PlayerType.opponent)
        ..type = TurnActionType.move;
      final myMove = pokeData.moves[testData.moveID]!; // わざ
      final phaseState = turn.copyInitialState();
      final yourFields = phaseState.getIndiFields(PlayerType.me);
      final getter = DamageGetter();
      action.move = turnMove.getReplacedMove(myMove, attackerState);
      if (turnMove.isCriticalFromMove(
          myMove, attackerState, defenderState, yourFields)) {
        action.criticalCount = 1;
      }
      action.moveAdditionalEffects = action.move.isSurelyEffect()
          ? MoveEffect(action.move.effect.id)
          : MoveEffect(0);
      action.moveEffectivenesses = PokeTypeEffectiveness.effectiveness(
          attackerState.currentAbility.id == 113 ||
              attackerState.currentAbility.id == 299,
          defenderState.holdingItem?.id == 586,
          defenderState
              .ailmentsWhere((e) => e.id == Ailment.miracleEye)
              .isNotEmpty,
          turnMove.getReplacedMoveType(action.move, attackerState, phaseState),
          defenderState);
      action.processEffect(
        ownParty,
        defenderState.copy(),
        opponentParty,
        attackerState.copy(),
        phaseState.copy(),
        null,
        damageGetter: getter,
        loc: lookupAppLocalizations(Locale('ja')),
      );
      test(
          'ダメージ計算（${attacker.name} -> ${defender.name} : ${testData.moveName}）',
          () {
        expect(getter.maxDamage, testData.maxDamage);
        expect(getter.minDamage, testData.minDamage);
        expect(getter.maxDamagePercent, testData.maxDamagePercent);
        expect(getter.minDamagePercent, testData.minDamagePercent);
      });

      action.realDamage = testData.maxDamage;
      // ステータス予想のために、相手のステータスを確定状態からぼかす
      attackerState.minStats = SixStats.generate((j) =>
          FourParams.createFromValues(
              statIndex: StatIndex.values[j],
              level: attacker.level,
              race: attacker.stats.sixParams[j].race,
              indi: 0,
              effort: 0,
              temper: Temper(0, '', '', StatIndex.values[j], StatIndex.none)));
      attackerState.maxStats = SixStats.generate((j) =>
          FourParams.createFromValues(
              statIndex: StatIndex.values[j],
              level: attacker.level,
              race: attacker.stats.sixParams[j].race,
              indi: pokemonMaxIndividual,
              effort: pokemonMaxEffort,
              temper: Temper(0, '', '', StatIndex.none, StatIndex.values[j])));
      final guides = action.processEffect(
        ownParty,
        defenderState.copy(),
        opponentParty,
        attackerState.copy(),
        phaseState.copy(),
        null,
        loc: lookupAppLocalizations(Locale('ja')),
      );
      final correct =
          attacker.stats[StatIndex.values[guides.last.args[0]]].real;

      test('ステータス逆算（${attacker.name}）', () {
        expect(guides.last.args[1] <= correct && correct <= guides.last.args[2],
            true);
      });
    }

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
