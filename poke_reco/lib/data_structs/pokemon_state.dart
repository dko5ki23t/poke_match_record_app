import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/data_structs/timing.dart';

class PokemonState {
  Pokemon pokemon = Pokemon();  // ポケモン(DBへの保存時はIDだけ)
  int remainHP = 0;             // 残りHP
  int remainHPPercent = 100;    // 残りHP割合
  PokeType? teraType;           // テラスタルしているかどうか、している場合はそのタイプ
  bool isFainting = false;      // ひんしかどうか
  bool isBattling = false;      // バトルに参加しているかどうか
  Item? _holdingItem = Item(0, '', AbilityTiming(0));  // 持っているもちもの(失えばnullにする)
  List<int> usedPPs = List.generate(4, (index) => 0);       // 各わざの消費PP
  List<int> _statChanges = List.generate(7, (i) => 0);   // のうりょく変化
  List<BuffDebuff> buffDebuffs = [];    // その他の補正(フォルムとか)
  Ability currentAbility = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0)); // 現在のとくせい(バトル中にとくせいが変わることあるので)
  Ailments _ailments = Ailments();   // 状態異常
  List<SixParams> minStats = List.generate(StatIndex.size.index, (i) => SixParams(0, 0, 0, 0));     // 個体値や努力値のあり得る範囲の最小値
  List<SixParams> maxStats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, pokemonMaxEffort, 0));   // 個体値や努力値のあり得る範囲の最大値
  List<Ability> possibleAbilities = [];     // 候補のとくせい
  List<Item> impossibleItems = [];          // 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Move> moves = [];         // 判明しているわざ
  PokeType type1 = PokeType.createFromId(0);  // ポケモンのタイプ1(対戦中変わることもある)
  PokeType? type2;                // ポケモンのタイプ2

  PokemonState copyWith() =>
    PokemonState()
    ..pokemon = pokemon
    ..remainHP = remainHP
    ..remainHPPercent = remainHPPercent
    ..teraType = teraType
    ..isFainting = isFainting
    ..isBattling = isBattling
    .._holdingItem = _holdingItem?.copyWith()
    ..usedPPs = [...usedPPs]
    .._statChanges = [..._statChanges]
    ..buffDebuffs = [for (final e in buffDebuffs) e.copyWith()]
    ..currentAbility = currentAbility.copyWith()
    .._ailments = _ailments.copyWith()
    ..minStats = [...minStats]        // TODO:よい？
    ..maxStats = [...maxStats]        // TODO:よい？
    ..possibleAbilities = [for (final e in possibleAbilities) e.copyWith()]
    ..impossibleItems = [for (final e in impossibleItems) e.copyWith()]
    ..moves = [...moves]
    ..type1 = type1
    ..type2 = type2;

  Item? get holdingItem => _holdingItem;

  set holdingItem(Item? item) {
    _holdingItem?.clearPassiveEffect(this);
    item?.processPassiveEffect(this);
    _holdingItem = item;
  }

  // 地面にいるかどうかの判定
  bool isGround(List<IndividualField> fields) {
    if (ailmentsWhere((e) => e.id == Ailment.ingrain || e.id == Ailment.antiAir).isNotEmpty ||
        fields.where((e) => e.id == IndividualField.gravity).isNotEmpty ||
        holdingItem?.id == 255) {
      return true;
    }
    if (isTypeContain(3) || currentAbility.id == 26 || holdingItem?.id == 584 ||
        ailmentsWhere((e) => e.id == Ailment.magnetRise || e.id == Ailment.telekinesis).isNotEmpty) {
      return false;
    }
    return true;
  }

  // きゅうしょランク加算
  void addVitalRank(int i) {
    int findIdx = buffDebuffs.indexWhere((element) => BuffDebuff.vital1 <= element.id && element.id <= BuffDebuff.vital3);
    if (findIdx < 0) {
      int vitalRank = (BuffDebuff.vital1 + (i-1)).clamp(BuffDebuff.vital1, BuffDebuff.vital3);
      buffDebuffs.add(BuffDebuff(vitalRank));
    }
    else {
      int newRank = buffDebuffs[findIdx].id + i;
      if (newRank < BuffDebuff.vital1) {
        buffDebuffs.removeAt(findIdx);
      }
      else {
        int vitalRank = (newRank).clamp(BuffDebuff.vital1, BuffDebuff.vital3);
        buffDebuffs[findIdx] = BuffDebuff(vitalRank);
      }
    }
  }

  // タイプが含まれるか判定(テラスタル後ならテラスタイプで判定)
  bool isTypeContain(int typeId) {
    if (teraType != null) {
      return teraType!.id == typeId;
    }
    else {
      return type1.id == typeId || type2?.id == typeId;
    }
  }

  // ポケモン交代やひんしにより退場する場合の処理
  void processExitEffect(bool isOwn, PokemonState yourState) {
    resetStatChanges();
    currentAbility = pokemon.ability;
    ailmentsRemoveWhere((e) => e.id > Ailment.sleep);   // 状態変化の回復
    if (isFainting) ailmentsClear();
    // 退場後も継続するフォルム以外をクリア
    var unchangingForms = buffDebuffs.where((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace).toList();
    unchangingForms.addAll(buffDebuffs.where((e) => e.id == BuffDebuff.manpukuForm || e.id == BuffDebuff.harapekoForm));
    buffDebuffs.clear();
    buffDebuffs.addAll(unchangingForms);
    // 場にいると両者にバフ/デバフがかかる場合
    if (currentAbility.id == 186 && yourState.currentAbility.id != 186) { // ダークオーラ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura || element.id == BuffDebuff.antiDarkAura);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 187 && yourState.currentAbility.id == 187) { // フェアリーオーラ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura || element.id == BuffDebuff.antiFairyAura);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    // 場にいると相手にバフ/デバフがかかる場合
    if (currentAbility.id == 284) { // わざわいのうつわ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialAttack0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 285) { // わざわいのつるぎ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.defense0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 286) { // わざわいのおふだ
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.attack0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    if (currentAbility.id == 287) { // わざわいのたま
      int findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.specialDefense0_75);
      if (findIdx >= 0) yourState.buffDebuffs.removeAt(findIdx);
    }
    // にげられない状態の解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.cannotRunAway);
    // 退場することで自身に効果がある場合
    if (!isFainting && currentAbility.id == 30) { // しぜんかいふく
      ailmentsClear();
    }
    if (!isFainting && currentAbility.id == 144) { // さいせいりょく
      if (isOwn) {
        remainHP += (pokemon.h.real / 3).floor();
      }
      else {
        remainHPPercent += 33;
      }
    }
  }

  // ポケモン交代や死に出しにより登場する場合の処理
  void processEnterEffect(bool isOwn, Weather weather, Field field, PokemonState yourState) {
    isBattling = true;
    currentAbility = pokemon.ability;
    processPassiveEffect(isOwn, weather, field, yourState);   // パッシブ効果
    Weather.processWeatherEffect(Weather(0), weather, isOwn ? this : null, isOwn ? null : this);  // 天気の影響
    Field.processFieldEffect(Field(0), field, isOwn ? this : null, isOwn ? null : this);  // フィールドの影響
  }

  // ポケモンのとくせい/もちもの等で常に働く効果を付与。ポケモン登場時に一度だけ呼ぶ
  void processPassiveEffect(bool isOwn, Weather weather, Field field, PokemonState yourState) {
    // ポケモン固有のフォルム等
    if (pokemon.no == 648) {  // メロエッタ
      buffDebuffs.add(BuffDebuff(BuffDebuff.voiceForm));
    }

    switch (currentAbility.id) {
      case 14:  // ふくがん
        buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_3));
        break;
      case 32:  // てんのめぐみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.additionalEffect2));
        break;
      case 37:  // ちからもち
      case 74:  // ヨガパワー
        buffDebuffs.add(BuffDebuff(BuffDebuff.attack2));
        break;
      case 55:  // はりきり
        buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5));
        buffDebuffs.add(BuffDebuff(BuffDebuff.physicalAccuracy0_8));
        break;
      case 59:  // てんきや
        buffDebuffs.add(BuffDebuff(BuffDebuff.powalenNormal));
        break;
      case 62:  // こんじょう
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
        }
        break;
      case 63:  // ふしぎなうろこ
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
        }
        break;
      case 77:  // ちどりあし
        if (ailmentsIndexWhere((e) => e.id == Ailment.confusion) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
        }
        break;
      case 79:  // とうそうしん
        buffDebuffs.add(BuffDebuff(BuffDebuff.opponentSex1_5));
        break;
      case 85:  // たいねつ
        buffDebuffs.add(BuffDebuff(BuffDebuff.heatproof));
        break;
      case 87:  // かんそうはだ
        buffDebuffs.add(BuffDebuff(BuffDebuff.drySkin));
        break;
      case 89:  // てつのこぶし
        buffDebuffs.add(BuffDebuff(BuffDebuff.punch1_2));
        break;
      case 91:  // てきおうりょく
        buffDebuffs.add(BuffDebuff(BuffDebuff.typeBonus2));
        break;
      case 95:  // はやあし
        if (ailmentsIndexWhere((e) => e.id <= Ailment.sleep && e.id != 0) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
        }
        break;
      case 96:  // ノーマルスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.normalize));
        break;
      case 97:  // スナイパー
        buffDebuffs.add(BuffDebuff(BuffDebuff.sniper));
        break;
      case 98:  // マジックガード
        buffDebuffs.add(BuffDebuff(BuffDebuff.magicGuard));
        break;
      case 99:  // ノーガード
        buffDebuffs.add(BuffDebuff(BuffDebuff.noGuard));
        break;
      case 100: // あとだし
        buffDebuffs.add(BuffDebuff(BuffDebuff.stall));
        break;
      case 101: // テクニシャン
        buffDebuffs.add(BuffDebuff(BuffDebuff.technician));
        break;
      case 103: // ぶきよう
        buffDebuffs.add(BuffDebuff(BuffDebuff.noItemEffect));
        break;
      case 104: // かたやぶり
      case 163: // ターボブレイズ
      case 164: // テラボルテージ
        buffDebuffs.add(BuffDebuff(BuffDebuff.noAbilityEffect));
        break;
      case 105: // きょううん
        addVitalRank(1);
        break;
      case 109: // てんねん
        buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreRank));
        break;
      case 110: // いろめがね
        buffDebuffs.add(BuffDebuff(BuffDebuff.notGoodType2));
        break;
      case 111: // フィルター
      case 116: // ハードロック
      case 232: // プリズムアーマー
        buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamaged0_75));
        break;
      case 120: // すてみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.recoil1_2));
        break;
      case 122: // フラワーギフト
        buffDebuffs.add(BuffDebuff(BuffDebuff.negaForm));
        break;
      case 125: // ちからずく
        buffDebuffs.add(BuffDebuff(BuffDebuff.sheerForce));
        break;
      case 134: // ヘヴィメタル
        buffDebuffs.add(BuffDebuff(BuffDebuff.heavy2));
        break;
      case 135: // ライトメタル
        buffDebuffs.add(BuffDebuff(BuffDebuff.heavy0_5));
        break;
      case 136: // マルチスケイル
      case 231: // ファントムガード
        if ((isOwn && remainHP == pokemon.h.real) || (!isOwn && remainHPPercent == 100)) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.damaged0_5));
        }
        break;
      case 137:  // どくぼうそう
        if (ailmentsIndexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
        }
        break;
      case 138:  // ねつぼうそう
        if (ailmentsIndexWhere((e) => e.id == Ailment.burn) >= 0) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        }
        break;
      case 142:  // ぼうじん
        buffDebuffs.add(BuffDebuff(BuffDebuff.overcoat));
        break;
      case 147:  // ミラクルスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.yourStatusAccuracy50));
        break;
      case 148:  // アナライズ
        buffDebuffs.add(BuffDebuff(BuffDebuff.analytic));
        break;
      case 151:  // すりぬけ
        buffDebuffs.add(BuffDebuff(BuffDebuff.ignoreWall));
        break;
      case 156:  // マジックミラー
        ailmentsAdd(Ailment(Ailment.magicCoat), weather, field);
        break;
      case 158:  // いたずらごころ
        buffDebuffs.add(BuffDebuff(BuffDebuff.prankster));
        break;
      case 159:   // すなのちから
        buffDebuffs.add(BuffDebuff(BuffDebuff.rockGroundSteel1_3));
        break;
      case 162:   // しょうりのほし
        buffDebuffs.add(BuffDebuff(BuffDebuff.accuracy1_1));
        break;
      case 169:   // ファーコート
        buffDebuffs.add(BuffDebuff(BuffDebuff.guard2));
        break;
      case 171:   // ぼうだん
        buffDebuffs.add(BuffDebuff(BuffDebuff.bulletProof));
        break;
      case 173:   // がんじょうあご
        buffDebuffs.add(BuffDebuff(BuffDebuff.bite1_5));
        break;
      case 174:   // フリーズスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.freezeSkin));
        break;
      case 176:   // バトルスイッチ
        buffDebuffs.add(BuffDebuff(BuffDebuff.shieldForm));
        break;
      case 177: // はやてのつばさ
        if ((isOwn && remainHP == pokemon.h.real) || (!isOwn && remainHPPercent == 100)) {
          buffDebuffs.add(BuffDebuff(BuffDebuff.galeWings));
        }
        break;
      case 178:   // メガランチャー
        buffDebuffs.add(BuffDebuff(BuffDebuff.wave1_5));
        break;
      case 181:   // かたいツメ
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttack1_3));
        break;
      case 182:   // フェアリースキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.fairySkin));
        break;
      case 184:   // スカイスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.airSkin));
        break;
      case 196:   // ひとでなし
        buffDebuffs.add(BuffDebuff(BuffDebuff.merciless));
        break;
      case 198:   // はりこみ
        buffDebuffs.add(BuffDebuff(BuffDebuff.change2));
        break;
      case 199:   // すいほう
        buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble1));
        buffDebuffs.add(BuffDebuff(BuffDebuff.waterBubble2));
        break;
      case 200:   // はがねつかい
        buffDebuffs.add(BuffDebuff(BuffDebuff.steelWorker));
        break;
      case 204:   // うるおいボイス
        buffDebuffs.add(BuffDebuff(BuffDebuff.liquidVoice));
        break;
      case 205:   // ヒーリングシフト
        buffDebuffs.add(BuffDebuff(BuffDebuff.healingShift));
        break;
      case 206:   // エレキスキン
        buffDebuffs.add(BuffDebuff(BuffDebuff.electricSkin));
        break;
      case 208:   // ぎょぐん
        buffDebuffs.add(BuffDebuff(BuffDebuff.singleForm));
        break;
      case 209:   // ばけのかわ
        buffDebuffs.add(BuffDebuff(BuffDebuff.transedForm));
        break;
      case 217:   // バッテリー
        buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
        break;
      case 218:   // もふもふ
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackedDamage0_5));
        buffDebuffs.add(BuffDebuff(BuffDebuff.fireAttackedDamage2));
        break;
      case 233:   // ブレインフォース
        buffDebuffs.add(BuffDebuff(BuffDebuff.greatDamage1_25));
        break;
      case 239:   // スクリューおびれ
      case 242:   // すじがねいり
        buffDebuffs.add(BuffDebuff(BuffDebuff.targetRock));
        break;
      case 244:   // パンクロック
        buffDebuffs.add(BuffDebuff(BuffDebuff.sound1_3));
        buffDebuffs.add(BuffDebuff(BuffDebuff.soundedDamage0_5));
        break;
      case 246:   // こおりのりんぷん
        buffDebuffs.add(BuffDebuff(BuffDebuff.specialDamaged0_5));
        break;
      case 247:   // じゅくせい
        buffDebuffs.add(BuffDebuff(BuffDebuff.nuts2));
        break;
      case 248:   // アイスフェイス
        {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace);
          if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.iceFace));
        }
        break;
      case 249:   // パワースポット
        buffDebuffs.add(BuffDebuff(BuffDebuff.attackMove1_3));
        break;
      case 252:   // はがねのせいしん
        buffDebuffs.add(BuffDebuff(BuffDebuff.steel1_5));
        break;
      case 255:   // ごりむちゅう
        buffDebuffs.add(BuffDebuff(BuffDebuff.gorimuchu));
        break;
      case 258:   // はらぺこスイッチ
        if (teraType == null || teraType!.id == 0) {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.harapekoForm || e.id == BuffDebuff.manpukuForm);
          if (findIdx < 0) {
            buffDebuffs.add(BuffDebuff(BuffDebuff.manpukuForm));
          }
          else {
            buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.manpukuForm);
          }
        }
        break;
      case 260:   // ふかしのこぶし
        buffDebuffs.add(BuffDebuff(BuffDebuff.directAttackIgnoreGurad));
        break;
      case 262:   // トランジスタ
        buffDebuffs.add(BuffDebuff(BuffDebuff.electric1_3));
        break;
      case 263:   // りゅうのあぎと
        buffDebuffs.add(BuffDebuff(BuffDebuff.dragon1_5));
        break;
      case 272:   // きよめのしお
        buffDebuffs.add(BuffDebuff(BuffDebuff.ghosted0_5));
        break;
      case 276:   // いわはこび
        buffDebuffs.add(BuffDebuff(BuffDebuff.rock1_5));
        break;
      case 278:   // マイティチェンジ
        {
          int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm);
          if (findIdx < 0) {
            buffDebuffs.add(BuffDebuff(BuffDebuff.naiveForm));
          }
          else {
            buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.mightyForm);
          }
        }
        break;
      case 284:   // わざわいのうつわ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialAttack0_75));
        break;
      case 285:   // わざわいのつるぎ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.defense0_75));
        break;
      case 286:   // わざわいのおふだ
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack0_75));
        break;
      case 287:   // わざわいのたま
        yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.specialDefense0_75));
        break;
      case 292:   // きれあじ
        buffDebuffs.add(BuffDebuff(BuffDebuff.cut1_5));
        break;
      case 298:   // きんしのちから
        buffDebuffs.add(BuffDebuff(BuffDebuff.myceliumMight));
        break;
    }
    
    // もちものの効果を反映
    holdingItem?.processPassiveEffect(this);
  
    // 両者のバフ/デバフに関係する場合
    if (currentAbility.id == 186 || yourState.currentAbility.id == 186) { // ダークオーラ
      if (currentAbility.id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiDarkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiDarkAura));
      }
      else {
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.darkAura));
      }
    }
    if (currentAbility.id == 187 || yourState.currentAbility.id == 187) { // フェアリーオーラ
      if (currentAbility.id == 188 || yourState.currentAbility.id == 188) { // オーラブレイク
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.antiFairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.antiFairyAura));
      }
      else {
        int findIdx = buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
        findIdx = yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura);
        if (findIdx < 0) yourState.buffDebuffs.add(BuffDebuff(BuffDebuff.fairyAura));
      }
    }
  }

  // 状態異常に関する関数群ここから
  bool ailmentsAdd(Ailment ailment, Weather weather, Field field, {bool forceAdd = false}) {
    // すでに同じものになっている場合は何も起こらない
    if (_ailments.where((e) => e.id == ailment.id).isNotEmpty) return false;
    // タイプによる耐性
    if ((isTypeContain(9) || isTypeContain(4)) &&
        (ailment.id == Ailment.poison || (!forceAdd && ailment.id == Ailment.badPoison))    // もうどくに関しては、わざ使用者のとくせいがふしょくなら可能
    ) return false;
    if (isTypeContain(10) && ailment.id == Ailment.burn) return false;
    if (isTypeContain(13) && ailment.id == Ailment.paralysis) return false;
    // とくせいによる耐性
    if ((currentAbility.id == 17 || currentAbility.id == 257) && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) return false;
    if ((currentAbility.id == 7) && (ailment.id == Ailment.paralysis)) return false;
    if ((currentAbility.id == 41 || currentAbility.id == 199 || currentAbility.id == 270) && (ailment.id == Ailment.burn)) return false;    // みずのベール/ねつこうかん<-やけど
    if (currentAbility.id == 166 && isTypeContain(12) && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // フラワーベール
    if ((currentAbility.id == 39) && (ailment.id == Ailment.flinch)) return false;      // せいしんりょく<-ひるみ
    if ((currentAbility.id == 40) && (ailment.id == Ailment.freeze)) return false;      // マグマのよろい<-こおり
    if ((currentAbility.id == 102) && (weather.id == Weather.sunny) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // 晴れ下リーフガード<-状態異常＋ねむけ
    if (currentAbility.id == 213 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // ぜったいねむり<-状態異常＋ねむけ
    // TODO:リミットシールド
    if (currentAbility.id == 213) return false;
    if (field.id == Field.mistyTerrain) return false;

    bool isAdded = _ailments.add(ailment);

    if (isAdded && ailment.id <= Ailment.sleep && ailment.id != 0) {    // 状態異常時
      if (currentAbility.id == 62) buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));  // こんじょう
      if (currentAbility.id == 63) buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));            // ふしぎなうろこ
      if (currentAbility.id == 95) buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));       // はやあし
    }
    else if (isAdded && ailment.id == Ailment.confusion) {    // こんらん時
      if (currentAbility.id == 77) buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));  // ちどりあし
    }
    else if (isAdded && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {    // どく/もうどく時
      if (currentAbility.id == 137) buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));        // どくぼうそう
    }
    else if (isAdded && ailment.id == Ailment.burn) {    // やけど時
      if (currentAbility.id == 138) buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));         // ねつぼうそう
    }
    return true;
  }

  int get ailmentsLength => _ailments.length;
  Iterable<Ailment> get ailmentsIterable => _ailments.iterable;

  Ailment ailments(int i) {
    return _ailments[i];
  }

  Iterable<Ailment> ailmentsWhere(bool Function(Ailment) test) {
    return _ailments.where(test);
  }

  int ailmentsIndexWhere(bool Function(Ailment) test) {
    return _ailments.indexWhere(test);
  }

  Ailment ailmentsRemoveAt(int index) {
    var ret = _ailments.removeAt(index);
    if (ret.id <= Ailment.sleep && ret.id != 0) {
      if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.confusion) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.poison || ret.id == Ailment.badPoison) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (ret.id == Ailment.burn) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    
    return ret;
  }

  void ailmentsRemoveWhere(bool Function(Ailment) test) {
    _ailments.removeWhere(test);
    if (_ailments.indexWhere((e) => e.id <= Ailment.sleep && e.id != 0) < 0) {
      if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.confusion) < 0) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) < 0) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
    else if (_ailments.indexWhere((e) => e.id == Ailment.burn) < 0) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
    }
  }

  void ailmentsClear() {
    _ailments.clear();
    if (currentAbility.id == 62) {  // こんじょう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 95) {  // はやあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 77) {  // ちどりあし
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 137) {  // どくぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.physical1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
      if (currentAbility.id == 138) {  // ねつぼうそう
        int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.special1_5);
        if (findIdx >= 0) buffDebuffs.removeAt(findIdx);
      }
  }
  // 状態異常に関する関数群ここまで
  
  // ランク変化に関する関数群ここから
  int statChanges(int i) {return _statChanges[i];}

  // 引数で指定した値そのものにする。とくせいの効果等に影響されない変化をさせたいときに使う
  void forceSetStatChanges(int index, int num,) {
    _statChanges[index] = num;
    if (_statChanges[index] < -6) _statChanges[index] = -6;
    if (_statChanges[index] > 6) _statChanges[index] = 6;
  }

  // とくせい等によって変化できなかった場合はfalseが返る
  bool addStatChanges(
    bool isMyEffect, int index, int num, PokemonState yourState,
    {int? moveId, int? abilityId, int? itemId, bool lastMirror = false}
  ) {
    int change = num;
    if (!isMyEffect && holdingItem?.id == 1698 && num < 0) return false;    // クリアチャーム
    if (!isMyEffect && currentAbility.id == 12 && moveId == 445) return false;   // どんかん
    if (!isMyEffect && abilityId == 22 &&        // いかくに対する
        (currentAbility.id == 12 || currentAbility.id == 20  || currentAbility.id == 39 ||    // どんかん/マイペース/せいしんりょく
         currentAbility.id == 113)) return false;                                             // きもったま
    if (!isMyEffect && currentAbility.id == 20 && abilityId == 22) return false;   // マイペース
    if (!isMyEffect && (currentAbility.id == 29 || currentAbility.id == 73 || currentAbility.id == 230) && num < 0) return false;   // クリアボディ/しろいけむり/メタルプロテクト
    if (!isMyEffect && (currentAbility.id == 35 || currentAbility.id == 51) && index == 5 && num < 0) return false;   // はっこう/するどいめ
    if (!isMyEffect && currentAbility.id == 52 && index == 0 && num < 0) return false;   // かいりきバサミ
    if (!isMyEffect && currentAbility.id == 145 && index == 1 && num < 0) return false;   // はとむね
    if (!isMyEffect && currentAbility.id == 166 && isTypeContain(12) && num < 0) return false;   // フラワーベール
    if (!isMyEffect && currentAbility.id == 240 && num < 0 && !lastMirror) {    // ミラーアーマー
      yourState.addStatChanges(isMyEffect, index, num, this, lastMirror: true);
      return false;
    }
    if (!isMyEffect && abilityId == 22 && currentAbility.id == 275) num = 1;   // いかくに対するばんけん

    if (currentAbility.id == 86) change *= 2;   // たんじゅん
    if (currentAbility.id == 126) change *= -1; // あまのじゃく
    if (!isMyEffect && currentAbility.id == 128 && num < 0) {  // まけんき
      _statChanges[0] =  (_statChanges[0] + 2).clamp(-6, 6);
    }

    _statChanges[index] = (_statChanges[index] + change).clamp(-6, 6);
    return true;
  }

  void resetStatChanges() {
    _statChanges = List.generate(7, (index) => 0);
  }

  void resetDownedStatChanges() {
    for (int i = 0; i < 7; i++) {
      if (_statChanges[i] < 0) _statChanges[i] = 0;
    }
  }
  // ランク変化に関する関数群ここまで

  // SQLに保存された文字列からPokemonStateをパース
  static PokemonState deserialize(dynamic str, String split1, String split2, String split3) {
    final pokeData = PokeDB();
    PokemonState pokemonState = PokemonState();
    final stateElements = str.split(split1);
    // pokemon
    pokemonState.pokemon = pokeData.pokemons.where((element) => element.id == int.parse(stateElements[0])).first;
    // remainHP
    pokemonState.remainHP = int.parse(stateElements[1]);
    // remainHPPercent
    pokemonState.remainHPPercent = int.parse(stateElements[2]);
    // teraType
    if (stateElements[3] != '') {
      pokemonState.teraType = PokeType.createFromId(int.parse(stateElements[3]));
    }
    // isFainting
    pokemonState.isFainting = int.parse(stateElements[4]) != 0;
    // isBattling
    pokemonState.isBattling = int.parse(stateElements[5]) != 0;
    // holdingItem
    pokemonState.holdingItem = stateElements[6] == '' ? null : pokeData.items[int.parse(stateElements[6])];
    // usedPPs
    pokemonState.usedPPs.clear();
    final pps = stateElements[7].split(split2);
    for (final pp in pps) {
      if (pp == '') break;
      pokemonState.usedPPs.add(int.parse(pp));
    }
    // statChanges
    final statChangeElements = stateElements[8].split(split2);
    for (int i = 0; i < 7; i++) {
      pokemonState._statChanges[i] = int.parse(statChangeElements[i]);
    }
    // buffDebuffs
    final buffDebuffElements = stateElements[9].split(split2);
    for (final buffDebuff in buffDebuffElements) {
      if (buffDebuff == '') break;
      pokemonState.buffDebuffs.add(BuffDebuff.deserialize(buffDebuff, split3));
    }
    // currentAbility
    pokemonState.currentAbility = Ability.deserialize(stateElements[10], split2);
    // ailments
    pokemonState._ailments = Ailments.deserialize(stateElements[11], split2, split3);
    // minStats
    final minStatElements = stateElements[12].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.minStats[i] = SixParams.deserialize(minStatElements[i], split3);
    }
    // maxStats
    final maxStatElements = stateElements[13].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.maxStats[i] = SixParams.deserialize(maxStatElements[i], split3);
    }
    // possibleAbilities
    final abilities = stateElements[14].split(split2);
    for (var ability in abilities) {
      if (ability == '') break;
      pokemonState.possibleAbilities.add(Ability.deserialize(ability, split3));
    }
    // impossibleItems
    final items = stateElements[15].split(split2);
    for (var item in items) {
      if (item == '') break;
      pokemonState.impossibleItems.add(pokeData.items[int.parse(item)]!);
    }
    // moves
    final moves = stateElements[16].split(split2);
    for (var move in moves) {
      if (move == '') break;
      pokemonState.moves.add(pokeData.moves[int.parse(move)]!);
    }
    // type1
    pokemonState.type1 = PokeType.createFromId(int.parse(stateElements[17]));
    // type2
    if (stateElements[18] != '') {
      pokemonState.type2 = PokeType.createFromId(int.parse(stateElements[18]));
    }

    return pokemonState;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3) {
    String ret = '';
    // pokemon
    ret += pokemon.id.toString();
    ret += split1;
    // remainHP
    ret += remainHP.toString();
    ret += split1;
    // remainHPPercent
    ret += remainHPPercent.toString();
    ret += split1;
    // teraType
    if (teraType != null) {
      ret += teraType!.id.toString();
    }
    ret += split1;
    // isFainting
    ret += isFainting ? '1' : '0';
    ret += split1;
    // isBattling
    ret += isBattling ? '1' : '0';
    ret += split1;
    // holdingItem
    ret += holdingItem != null ? holdingItem!.id.toString() : '';
    ret += split1;
    // usedPPs
    for (final pp in usedPPs) {
      ret += pp.toString();
      ret += split2;
    }
    ret += split1;
    // statChanges
    for (int i = 0; i < 7; i++) {
      ret += _statChanges[i].toString();
      ret += split2;
    }
    ret += split1;
    // buffDebuffs
    for (final buffDebuff in buffDebuffs) {
      ret += buffDebuff.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // currentAbility
    ret += currentAbility.serialize(split2);
    ret += split1;
    // ailments
    ret += _ailments.serialize(split2, split3);
    ret += split1;
    // minStats
    for (int i = 0; i < 6; i++) {
      ret += minStats[i].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // maxStats
    for (int i = 0; i < 6; i++) {
      ret += maxStats[i].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // possibleAbilities
    for (final ability in possibleAbilities) {
      ret += ability.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // impossibleItems
    for (final item in impossibleItems) {
      ret += item.id.toString();
      ret += split2;
    }
    ret += split1;
    // moves
    for (final move in moves) {
      ret += move.id.toString();
      ret += split2;
    }
    ret += split1;
    // type1
    ret += type1.id.toString();
    ret += split1;
    // type2
    if (type2 != null) {
      ret += type2!.id.toString();
    }

    return ret;
  }
}
