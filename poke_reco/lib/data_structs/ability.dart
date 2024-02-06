import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/tool.dart';

/// とくせいの情報を管理するclass
class Ability extends Equatable implements Copyable {
  /// ID
  final int id;

  /// 名前(日本語)
  final String _displayName;

  /// 名前(英語)
  final String _displayNameEn;

  /// 発動タイミング
  final Timing timing;

  /// 対象
  final Target target;

  @override
  List<Object?> get props => [
        id,
        _displayName,
        _displayNameEn,
        timing,
        target,
      ];

  /// とくせい
  const Ability(
    this.id,
    this._displayName,
    this._displayNameEn,
    this.timing,
    this.target,
  );

  /// 無効なとくせいを生成
  factory Ability.none() => Ability(0, '', '', Timing.none, Target.none);

  @override
  Ability copy() => Ability(id, _displayName, _displayNameEn, timing, target);

  /// 名前
  String get displayName {
    switch (PokeDB().language) {
      case Language.english:
        return _displayNameEn;
      case Language.japanese:
      default:
        return _displayName;
    }
  }

  /// SQLite保存用Mapを返す
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      abilityColumnId: id,
      abilityColumnName: _displayName,
      abilityColumnEnglishName: _displayNameEn,
      abilityColumnTiming: timing.index,
      abilityColumnTarget: target.index,
    };
    return map;
  }

  /// 交換可能なとくせいかどうか
  bool get canExchange {
    const ids = [
      225,
      248,
      149,
      241,
      256,
      208,
      266,
      211,
      161,
      209,
      176,
      258,
      25,
    ];
    return !ids.contains(id);
  }

  /// 上書きできるとくせいかどうか
  bool get canOverWrite {
    const ids = [
      225,
      248,
      241,
      210,
      208,
      282,
      281,
      266,
      211,
      213,
      161,
      209,
      176,
      278,
      121,
      197,
      304,
    ];
    return !ids.contains(id);
  }

  /// コピー可能なとくせいかどうか
  bool get canCopy {
    const ids = [
      225,
      248,
      149,
      241,
      303,
      223,
      256,
      150,
      210,
      208,
      282,
      281,
      279,
      266,
      211,
      213,
      161,
      59,
      36,
      209,
      176,
      258,
      122,
      278,
      121,
      197,
      222,
      305,
    ];
    return !ids.contains(id);
  }

  /// かたやぶり/きんしのちから/ターボブレイズ/テラボルテージで無視されるとくせいかどうか
  bool get canIgnored {
    const ids = [
      248,
      47,
      126,
      165,
      188,
      283,
      52,
      274,
      4,
      5,
      87,
      272,
      21,
      179,
      29,
      246,
      273,
      75,
      6,
      7,
      214,
      73,
      299,
      175,
      199,
      8,
      51,
      39,
      157,
      186,
      85,
      86,
      10,
      77,
      11,
      296,
      140,
      78,
      109,
      297,
      12,
      270,
      60,
      116,
      209,
      257,
      35,
      145,
      244,
      275,
      219,
      31,
      169,
      111,
      187,
      63,
      25,
      15,
      26,
      122,
      166,
      132,
      134,
      43,
      142,
      171,
      20,
      40,
      156,
      136,
      41,
      240,
      147,
      17,
      218,
      18,
      72,
      81,
      114,
      135,
      102,
      19,
    ];
    return ids.contains(id);
  }

  /// 常時発動する効果を処理(該当ポケモン登場時等に呼び出す)
  /// ```
  /// myState: とくせい保持者の状態
  /// yourState: とくせい保持者の相手の状態
  /// isMe: とくせい保持者が自身(ユーザ・me)かどうか
  /// state: フェーズの状態
  /// ```
  void processPassiveEffect(
    PokemonState myState,
    PokemonState yourState,
    bool isMe,
    PhaseState state,
  ) {
    var yourFields = isMe
        ? state.getIndiFields(PlayerType.opponent)
        : state.getIndiFields(PlayerType.me);
    switch (id) {
      case 14: // ふくがん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_3));
        break;
      case 23: // かげふみ
        if (yourState.currentAbility.id != 23) {
          yourState.ailmentsAdd(
              Ailment(Ailment.cannotRunAway)..extraArg1 = 1, state);
        }
        break;
      case 32: // てんのめぐみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.additionalEffect2));
        break;
      case 37: // ちからもち
      case 74: // ヨガパワー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        break;
      case 42: // じりょく
        yourState.ailmentsAdd(
            Ailment(Ailment.cannotRunAway)..extraArg1 = 2, state);
        break;
      case 55: // はりきり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physicalAccuracy0_8));
        break;
      case 59: // てんきや
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.powalenNormal));
        break;
      case 62: // こんじょう
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
        }
        break;
      case 63: // ふしぎなうろこ
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
        }
        break;
      case 71: // ありじごく
        yourState.ailmentsAdd(
            Ailment(Ailment.cannotRunAway)..extraArg1 = 3, state);
        break;
      case 77: // ちどりあし
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.confusion) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
        }
        break;
      case 79: // とうそうしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.opponentSex1_5));
        break;
      case 85: // たいねつ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heatproof));
        break;
      case 87: // かんそうはだ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.drySkin));
        break;
      case 89: // てつのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.punch1_2));
        break;
      case 91: // てきおうりょく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.typeBonus2));
        break;
      case 95: // はやあし
        if (myState.ailmentsIndexWhere(
                (e) => e.id <= Ailment.sleep && e.id != 0) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
        }
        break;
      case 96: // ノーマルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.normalize));
        break;
      case 97: // スナイパー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sniper));
        break;
      case 98: // マジックガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.magicGuard));
        break;
      case 99: // ノーガード
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noGuard));
        break;
      case 100: // あとだし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.stall));
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.technician));
        break;
      case 103: // ぶきよう
        myState.holdingItem?.clearPassiveEffect(myState, clearForm: false);
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noItemEffect));
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.noAbilityEffect));
        break;
      case 105: // きょううん
        myState.addVitalRank(1);
        break;
      case 109: // てんねん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreRank));
        break;
      case 110: // いろめがね
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.notGoodType2));
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamaged0_75));
        break;
      case 120: // すてみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.recoil1_2));
        break;
      case 122: // フラワーギフト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.negaForm));
        break;
      case 125: // ちからずく
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sheerForce));
        break;
      case 127: // きんちょうかん
        yourFields.add(IndividualField(IndividualField.noBerry));
        break;
      case 134: // ヘヴィメタル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heavy2));
        break;
      case 135: // ライトメタル
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.heavy0_5));
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        if ((isMe && myState.remainHP == myState.pokemon.h.real) ||
            (!isMe && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        break;
      case 137: // どくぼうそう
        if (myState.ailmentsIndexWhere(
                (e) => e.id == Ailment.poison || e.id == Ailment.badPoison) >=
            0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
        }
        break;
      case 138: // ねつぼうそう
        if (myState.ailmentsIndexWhere((e) => e.id == Ailment.burn) >= 0) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        }
        break;
      case 142: // ぼうじん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 147: // ミラクルスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.yourStatusAccuracy50));
        break;
      case 148: // アナライズ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.analytic));
        break;
      case 151: // すりぬけ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreWall));
        break;
      case 156: // マジックミラー
        myState.ailmentsAdd(Ailment(Ailment.magicCoat), state);
        break;
      case 158: // いたずらごころ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.prankster));
        break;
      case 159: // すなのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rockGroundSteel1_3));
        break;
      case 162: // しょうりのほし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 169: // ファーコート
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.guard2));
        break;
      case 171: // ぼうだん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bulletProof));
        break;
      case 173: // がんじょうあご
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.bite1_5));
        break;
      case 174: // フリーズスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.freezeSkin));
        break;
      case 176: // バトルスイッチ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.shieldForm));
        break;
      case 177: // はやてのつばさ
        if ((isMe && myState.remainHP == myState.pokemon.h.real) ||
            (!isMe && myState.remainHPPercent == 100)) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
        break;
      case 178: // メガランチャー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.wave1_5));
        break;
      case 181: // かたいツメ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttack1_3));
        break;
      case 182: // フェアリースキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairySkin));
        break;
      case 184: // スカイスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.airSkin));
        break;
      case 196: // ひとでなし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.merciless));
        break;
      case 198: // はりこみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.change2));
        break;
      case 199: // すいほう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble1));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble2));
        break;
      case 200: // はがねつかい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steelWorker));
        break;
      case 204: // うるおいボイス
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.liquidVoice));
        break;
      case 205: // ヒーリングシフト
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.healingShift));
        break;
      case 206: // エレキスキン
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electricSkin));
        break;
      case 208: // ぎょぐん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.singleForm));
        break;
      case 209: // ばけのかわ
        if (!myState.buffDebuffs.containsByAnyID(
            [BuffDebuff.transedForm, BuffDebuff.revealedForm])) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.transedForm));
        }
        break;
      case 217: // バッテリー
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        break;
      case 218: // もふもふ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackedDamage0_5));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttackedDamage2));
        break;
      case 233: // ブレインフォース
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_25));
        break;
      case 239: // スクリューおびれ
      case 242: // すじがねいり
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.targetRock));
        break;
      case 244: // パンクロック
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.sound1_3));
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.soundedDamage0_5));
        break;
      case 246: // こおりのりんぷん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDamaged0_5));
        break;
      case 247: // じゅくせい
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.nuts2));
        break;
      case 248: // アイスフェイス
        if (!myState.buffDebuffs
            .containsByAnyID([BuffDebuff.iceFace, BuffDebuff.niceFace])) {
          myState.buffDebuffs.add(BuffDebuff(BuffDebuff.iceFace));
        }
        break;
      case 249: // パワースポット
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove1_3));
        break;
      case 252: // はがねのせいしん
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.steel1_5));
        break;
      case 255: // ごりむちゅう
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 258: // はらぺこスイッチ
        if (!myState.isTerastaling) {
          if (!myState.buffDebuffs.containsByAnyID(
              [BuffDebuff.harapekoForm, BuffDebuff.manpukuForm])) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.manpukuForm));
          } else {
            myState.buffDebuffs
                .changeID(BuffDebuff.harapekoForm, BuffDebuff.manpukuForm);
          }
        }
        break;
      case 260: // ふかしのこぶし
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackIgnoreGurad));
        break;
      case 262: // トランジスタ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.electric1_3));
        break;
      case 263: // りゅうのあぎと
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.dragon1_5));
        break;
      case 272: // きよめのしお
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.ghosted0_5));
        break;
      case 276: // いわはこび
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.rock1_5));
        break;
      case 278: // マイティチェンジ
        {
          if (!myState.buffDebuffs
              .containsByAnyID([BuffDebuff.naiveForm, BuffDebuff.mightyForm])) {
            myState.buffDebuffs.add(BuffDebuff(BuffDebuff.naiveForm));
          }
        }
        break;
      case 284: // わざわいのうつわ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack0_75));
        break;
      case 285: // わざわいのつるぎ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense0_75));
        break;
      case 286: // わざわいのおふだ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack0_75));
        break;
      case 287: // わざわいのたま
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense0_75));
        break;
      case 292: // きれあじ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.cut1_5));
        break;
      case 298: // きんしのちから
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.myceliumMight));
        break;
    }

    if (id == 186 || yourState.currentAbility.id == 186) {
      // ダークオーラ
      if (id == 188 || yourState.currentAbility.id == 188) {
        // オーラブレイク
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiDarkAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiDarkAura);
      } else {
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.darkAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.darkAura);
      }
    }
    if (id == 187 || yourState.currentAbility.id == 187) {
      // フェアリーオーラ
      if (id == 188 || yourState.currentAbility.id == 188) {
        // オーラブレイク
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiFairyAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.antiFairyAura);
      } else {
        myState.buffDebuffs.addIfNotFoundByID(BuffDebuff.fairyAura);
        yourState.buffDebuffs.addIfNotFoundByID(BuffDebuff.fairyAura);
      }
    }
  }

  /// 常時発動する効果を消す(該当ポケモン退出時等に呼び出す)
  /// ```
  /// myState: とくせい保持者の状態
  /// yourState: とくせい保持者の相手の状態
  /// isMe: とくせい保持者が自身(ユーザ・me)かどうか
  /// state: フェーズの状態
  /// ```
  void clearPassiveEffect(
    PokemonState myState,
    PokemonState yourState,
    bool isMe,
    PhaseState state,
  ) {
    var yourFields = isMe
        ? state.getIndiFields(PlayerType.opponent)
        : state.getIndiFields(PlayerType.me);
    switch (id) {
      case 14: // ふくがん
        myState.buffDebuffs.removeAllByID(BuffDebuff.accuracy1_3);
        break;
      case 32: // てんのめぐみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.additionalEffect2);
        break;
      case 37: // ちからもち
      case 74: // ヨガパワー
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack2);
        break;
      case 55: // はりきり
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_5);
        myState.buffDebuffs.removeAllByID(BuffDebuff.physicalAccuracy0_8);
        break;
      case 59: // てんきや
        myState.buffDebuffs.removeAllByID(BuffDebuff.powalenNormal);
        break;
      case 62: // こんじょう
        myState.buffDebuffs.removeAllByID(BuffDebuff.attack1_5WithIgnBurn);
        break;
      case 63: // ふしぎなうろこ
        myState.buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
        break;
      case 77: // ちどりあし
        myState.buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_5);
        break;
      case 79: // とうそうしん
        myState.buffDebuffs.removeAllByID(BuffDebuff.opponentSex1_5);
        break;
      case 85: // たいねつ
        myState.buffDebuffs.removeAllByID(BuffDebuff.heatproof);
        break;
      case 87: // かんそうはだ
        myState.buffDebuffs.removeAllByID(BuffDebuff.drySkin);
        break;
      case 89: // てつのこぶし
        myState.buffDebuffs.removeAllByID(BuffDebuff.punch1_2);
        break;
      case 91: // てきおうりょく
        myState.buffDebuffs.removeAllByID(BuffDebuff.typeBonus2);
        break;
      case 95: // はやあし
        myState.buffDebuffs.removeAllByID(BuffDebuff.speed1_5IgnPara);
        break;
      case 96: // ノーマルスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.normalize);
        break;
      case 97: // スナイパー
        myState.buffDebuffs.removeAllByID(BuffDebuff.sniper);
        break;
      case 98: // マジックガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.magicGuard);
        break;
      case 99: // ノーガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.noGuard);
        break;
      case 100: // あとだし
        myState.buffDebuffs.removeAllByID(BuffDebuff.stall);
        break;
      case 101: // テクニシャン
        myState.buffDebuffs.removeAllByID(BuffDebuff.technician);
        break;
      case 103: // ぶきよう
        myState.buffDebuffs.removeAllByID(BuffDebuff.noItemEffect);
        myState.holdingItem?.processPassiveEffect(myState, processForm: false);
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        myState.buffDebuffs.removeAllByID(BuffDebuff.noAbilityEffect);
        break;
      case 105: // きょううん
        myState.addVitalRank(-1);
        break;
      case 109: // てんねん
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreRank);
        break;
      case 110: // いろめがね
        myState.buffDebuffs.removeAllByID(BuffDebuff.notGoodType2);
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        myState.buffDebuffs.removeAllByID(BuffDebuff.greatDamaged0_75);
        break;
      case 120: // すてみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.recoil1_2);
        break;
      case 122: // フラワーギフト
        myState.buffDebuffs.removeAllByID(BuffDebuff.negaForm);
        break;
      case 125: // ちからずく
        myState.buffDebuffs.removeAllByID(BuffDebuff.sheerForce);
        break;
      case 127: // きんちょうかん
        yourFields.removeWhere((e) => e.id == IndividualField.noBerry);
        break;
      case 134: // ヘヴィメタル
        myState.buffDebuffs.removeAllByID(BuffDebuff.heavy2);
        break;
      case 135: // ライトメタル
        myState.buffDebuffs.removeAllByID(BuffDebuff.heavy0_5);
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        myState.buffDebuffs.removeAllByID(BuffDebuff.damaged0_5);
        break;
      case 137: // どくぼうそう
        myState.buffDebuffs.removeAllByID(BuffDebuff.physical1_5);
        break;
      case 138: // ねつぼうそう
        myState.buffDebuffs.removeAllByID(BuffDebuff.special1_5);
        break;
      case 142: // ぼうじん
        myState.buffDebuffs.removeAllByID(BuffDebuff.overcoat);
        break;
      case 147: // ミラクルスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.yourStatusAccuracy50);
        break;
      case 148: // アナライズ
        myState.buffDebuffs.removeAllByID(BuffDebuff.analytic);
        break;
      case 151: // すりぬけ
        myState.buffDebuffs.removeAllByID(BuffDebuff.ignoreWall);
        break;
      case 156: // マジックミラー
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.magicCoat);
        break;
      case 158: // いたずらごころ
        myState.buffDebuffs.removeAllByID(BuffDebuff.prankster);
        break;
      case 159: // すなのちから
        myState.buffDebuffs.removeAllByID(BuffDebuff.rockGroundSteel1_3);
        break;
      case 162: // しょうりのほし
        myState.buffDebuffs.removeAllByID(BuffDebuff.accuracy1_1);
        break;
      case 169: // ファーコート
        myState.buffDebuffs.removeAllByID(BuffDebuff.guard2);
        break;
      case 171: // ぼうだん
        myState.buffDebuffs.removeAllByID(BuffDebuff.bulletProof);
        break;
      case 173: // がんじょうあご
        myState.buffDebuffs.removeAllByID(BuffDebuff.bite1_5);
        break;
      case 174: // フリーズスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.freezeSkin);
        break;
      case 176: // バトルスイッチ
        myState.buffDebuffs.removeAllByID(BuffDebuff.shieldForm);
        break;
      case 177: // はやてのつばさ
        myState.buffDebuffs.removeAllByID(BuffDebuff.galeWings);
        break;
      case 178: // メガランチャー
        myState.buffDebuffs.removeAllByID(BuffDebuff.wave1_5);
        break;
      case 181: // かたいツメ
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttack1_3);
        break;
      case 182: // フェアリースキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.fairySkin);
        break;
      case 184: // スカイスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.airSkin);
        break;
      case 196: // ひとでなし
        myState.buffDebuffs.removeAllByID(BuffDebuff.merciless);
        break;
      case 198: // はりこみ
        myState.buffDebuffs.removeAllByID(BuffDebuff.change2);
        break;
      case 199: // すいほう
        myState.buffDebuffs.removeAllByID(BuffDebuff.waterBubble1);
        myState.buffDebuffs.removeAllByID(BuffDebuff.waterBubble2);
        break;
      case 200: // はがねつかい
        myState.buffDebuffs.removeAllByID(BuffDebuff.steelWorker);
        break;
      case 204: // うるおいボイス
        myState.buffDebuffs.removeAllByID(BuffDebuff.liquidVoice);
        break;
      case 205: // ヒーリングシフト
        myState.buffDebuffs.removeAllByID(BuffDebuff.healingShift);
        break;
      case 206: // エレキスキン
        myState.buffDebuffs.removeAllByID(BuffDebuff.electricSkin);
        break;
      case 208: // ぎょぐん
        myState.buffDebuffs.removeAllByID(BuffDebuff.singleForm);
        break;
      case 209: // ばけのかわ
        myState.buffDebuffs.removeAllByAllID(
            [BuffDebuff.transedForm, BuffDebuff.revealedForm]);
        break;
      case 217: // バッテリー
        myState.buffDebuffs.removeAllByID(BuffDebuff.special1_5);
        break;
      case 218: // もふもふ
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttackedDamage0_5);
        myState.buffDebuffs.removeAllByID(BuffDebuff.fireAttackedDamage2);
        break;
      case 233: // ブレインフォース
        myState.buffDebuffs.removeAllByID(BuffDebuff.greatDamage1_25);
        break;
      case 239: // スクリューおびれ
      case 242: // すじがねいり
        myState.buffDebuffs.removeAllByID(BuffDebuff.targetRock);
        break;
      case 244: // パンクロック
        myState.buffDebuffs.removeAllByID(BuffDebuff.sound1_3);
        myState.buffDebuffs.removeAllByID(BuffDebuff.soundedDamage0_5);
        break;
      case 246: // こおりのりんぷん
        myState.buffDebuffs.removeAllByID(BuffDebuff.specialDamaged0_5);
        break;
      case 247: // じゅくせい
        myState.buffDebuffs.removeAllByID(BuffDebuff.nuts2);
        break;
      case 248: // アイスフェイス
        myState.buffDebuffs
            .removeAllByAllID([BuffDebuff.iceFace, BuffDebuff.niceFace]);
        break;
      case 249: // パワースポット
        myState.buffDebuffs.removeAllByID(BuffDebuff.attackMove1_3);
        break;
      case 252: // はがねのせいしん
        myState.buffDebuffs.removeAllByID(BuffDebuff.steel1_5);
        break;
      case 255: // ごりむちゅう
        myState.buffDebuffs.removeFirstByID(BuffDebuff.gorimuchu);
        break;
      case 258: // はらぺこスイッチ
        myState.buffDebuffs.removeAllByAllID(
            [BuffDebuff.harapekoForm, BuffDebuff.manpukuForm]);
        break;
      case 260: // ふかしのこぶし
        myState.buffDebuffs.removeAllByID(BuffDebuff.directAttackIgnoreGurad);
        break;
      case 262: // トランジスタ
        myState.buffDebuffs.removeAllByID(BuffDebuff.electric1_3);
        break;
      case 263: // りゅうのあぎと
        myState.buffDebuffs.removeAllByID(BuffDebuff.dragon1_5);
        break;
      case 272: // きよめのしお
        myState.buffDebuffs.removeAllByID(BuffDebuff.ghosted0_5);
        break;
      case 276: // いわはこび
        myState.buffDebuffs.removeAllByID(BuffDebuff.rock1_5);
        break;
      case 278: // マイティチェンジ
        myState.buffDebuffs
            .removeAllByAllID([BuffDebuff.naiveForm, BuffDebuff.mightyForm]);
        break;
      case 284: // わざわいのうつわ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.specialAttack0_75);
        break;
      case 285: // わざわいのつるぎ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.defense0_75);
        break;
      case 286: // わざわいのおふだ
        yourState.buffDebuffs.removeAllByID(BuffDebuff.attack0_75);
        break;
      case 287: // わざわいのたま
        yourState.buffDebuffs.removeAllByID(BuffDebuff.specialDefense0_75);
        break;
      case 292: // きれあじ
        myState.buffDebuffs.removeAllByID(BuffDebuff.cut1_5);
        break;
      case 298: // きんしのちから
        myState.buffDebuffs.removeAllByID(BuffDebuff.myceliumMight);
        break;
    }

    if (id == 186 && yourState.currentAbility.id != 186) {
      // ダークオーラ
      myState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiDarkAura, BuffDebuff.darkAura]);
      yourState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiDarkAura, BuffDebuff.darkAura]);
    }
    if (id == 187 && yourState.currentAbility.id != 187) {
      // フェアリーオーラ
      myState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiFairyAura, BuffDebuff.fairyAura]);
      yourState.buffDebuffs
          .removeAllByAllID([BuffDebuff.antiFairyAura, BuffDebuff.fairyAura]);
    }
    if (id == 188) {
      // オーラブレイク
      myState.buffDebuffs.removeAllByAllID(
          [BuffDebuff.antiFairyAura, BuffDebuff.antiDarkAura]);
      yourState.buffDebuffs.removeAllByAllID(
          [BuffDebuff.antiFairyAura, BuffDebuff.antiDarkAura]);
      if (yourState.currentAbility.id == 186) {
        // ダークオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
      if (yourState.currentAbility.id == 187) {
        // フェアリーオーラ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  /// SQLに保存された文字列からabilityをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// ```
  static Ability deserialize(dynamic str, String split1) {
    final List elements = str.split(split1);
    return Ability(
        int.parse(elements.removeAt(0)),
        elements.removeAt(0),
        elements.removeAt(0),
        Timing.values[int.parse(elements.removeAt(0))],
        Target.values[int.parse(elements.removeAt(0))]);
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1: 区切り文字
  /// ```
  String serialize(String split1) {
    return '$id$split1$_displayName$split1$_displayNameEn$split1${timing.index}$split1${target.index}';
  }
}
