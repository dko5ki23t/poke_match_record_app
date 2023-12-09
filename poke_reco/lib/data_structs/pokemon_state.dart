import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
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
  PlayerType playerType = PlayerType(0);    // ポケモンの所有者
  Pokemon pokemon = Pokemon();  // ポケモン(DBへの保存時はIDだけ)
  int remainHP = 0;             // 残りHP
  int remainHPPercent = 100;    // 残りHP割合
  bool isTerastaling = false;   // テラスタルしているかどうか
  PokeType teraType1 = PokeType.createFromId(0);      // テラスタルした場合のタイプ
  bool _isFainting = false;     // ひんしかどうか
  int battlingNum = 0;          // バトルでの選出順(選出されていなければ0、選出順を気にしない場合は単に0/1)
  Item? _holdingItem = Item(
    id: 0, displayName: '', flingPower: 0, flingEffectId: 0,
    timing: AbilityTiming(0), isBerry: false, imageUrl: '');  // 持っているもちもの(失えばnullにする)
  List<int> usedPPs = List.generate(4, (index) => 0);       // 各わざの消費PP
  List<int> _statChanges = List.generate(7, (i) => 0);   // のうりょく変化
  List<BuffDebuff> buffDebuffs = [];    // その他の補正(フォルムとか)
  List<BuffDebuff> hiddenBuffs = [];    // 画面上には表示させないその他の補正(わざ「ものまね」の変化後とか)
  Ability _currentAbility = Ability(0, '', AbilityTiming(0), Target(0), AbilityEffect(0));  // 現在のとくせい(バトル中にとくせいが変わることあるので)
  Ailments _ailments = Ailments();   // 状態変化
  List<SixParams> minStats = List.generate(StatIndex.size.index, (i) => SixParams(0, 0, 0, 0));     // 個体値や努力値のあり得る範囲の最小値
  List<SixParams> maxStats = List.generate(StatIndex.size.index, (i) => SixParams(0, pokemonMaxIndividual, pokemonMaxEffort, 0));   // 個体値や努力値のあり得る範囲の最大値
  List<Ability> possibleAbilities = [];     // 候補のとくせい
  List<Item> impossibleItems = [];          // 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Move> moves = [];        // 判明しているわざ
  PokeType type1 = PokeType.createFromId(0);  // ポケモンのタイプ1(対戦中変わることもある)
  PokeType? type2;              // ポケモンのタイプ2
  Move? lastMove;               // 最後に使用した(PP消費した)わざ
  bool isOriginalItem = true;   // trueのときに判明したholdingItemは、ポケモンがもともと持っていたもの(トリック等でfalseになる)

  PokemonState copyWith() =>
    PokemonState()
    ..playerType = playerType
    ..pokemon = pokemon
    ..remainHP = remainHP
    ..remainHPPercent = remainHPPercent
    ..isTerastaling = isTerastaling
    ..teraType1 = teraType1
    .._isFainting = _isFainting
    ..battlingNum = battlingNum
    .._holdingItem = _holdingItem?.copyWith()
    ..usedPPs = [...usedPPs]
    .._statChanges = [..._statChanges]
    ..buffDebuffs = [for (final e in buffDebuffs) e.copyWith()]
    ..hiddenBuffs = [for (final e in hiddenBuffs) e.copyWith()]
    .._currentAbility = _currentAbility.copyWith()
    .._ailments = _ailments.copyWith()
    ..minStats = [for (final e in minStats) e.copyWith()]
    ..maxStats = [for (final e in maxStats) e.copyWith()]
    ..possibleAbilities = [for (final e in possibleAbilities) e.copyWith()]
    ..impossibleItems = [for (final e in impossibleItems) e.copyWith()]
    ..moves = [...moves]
    ..type1 = type1
    ..type2 = type2
    ..lastMove = lastMove?.copyWith()
    ..isOriginalItem = isOriginalItem;

  Item? get holdingItem => _holdingItem;
  Ability get currentAbility => _currentAbility;
  bool get isFainting => _isFainting;
  // たかさ・おもさ・せいべつはメタモンのへんしん状態に応じて変化
  int get weight {
    var trans = buffDebuffs.where((e) => e.id == BuffDebuff.transform);
    int no = trans.isNotEmpty ? trans.first.extraArg1 : pokemon.no;
    return PokeDB().pokeBase[no]!.weight;
  }
  int get height {
    var trans = buffDebuffs.where((e) => e.id == BuffDebuff.transform);
    int no = trans.isNotEmpty ? trans.first.extraArg1 : pokemon.no;
    return PokeDB().pokeBase[no]!.height;
  }
  Sex get sex {
    var trans = buffDebuffs.where((e) => e.id == BuffDebuff.transform);
    return trans.isNotEmpty ? Sex.createFromId(trans.first.turns) : pokemon.sex;
  }
  bool get isMe => playerType.id == PlayerType.me;
  bool get usedAnyPP => usedPPs.where((element) => element > 0).isNotEmpty;

  set holdingItem(Item? item) {
    if (isOriginalItem && item != null) {
      pokemon.item = item;
      isOriginalItem = false;
    }
    _holdingItem?.clearPassiveEffect(this);
    item?.processPassiveEffect(this);
    if (item == null && _holdingItem != null && _holdingItem!.id != 0) {
      // 最後に消費したもちもの/きのみ更新
      var lastLostItem = hiddenBuffs.where((e) => e.id == BuffDebuff.lastLostItem);
      if (lastLostItem.isEmpty) {
        hiddenBuffs.add(BuffDebuff(BuffDebuff.lastLostItem)..extraArg1 = _holdingItem!.id);
      }
      else {
        lastLostItem.first.extraArg1 = _holdingItem!.id;
      }
      if (_holdingItem!.isBerry) {
        var lastLostBerry = hiddenBuffs.where((e) => e.id == BuffDebuff.lastLostBerry);
        if (lastLostBerry.isEmpty) {
          hiddenBuffs.add(BuffDebuff(BuffDebuff.lastLostBerry)..extraArg1 = _holdingItem!.id);
        }
        else {
          lastLostBerry.first.extraArg1 = _holdingItem!.id;
        }
      }
    }
    _holdingItem = item;
  }

  void setCurrentAbility(Ability ability, PokemonState yourState, bool isOwn, PhaseState state) {
    _currentAbility.clearPassiveEffect(this, yourState, isOwn, state);
    ability.processPassiveEffect(this, yourState, isOwn, state);
    _currentAbility = ability;
    // TODO:これでいいかは要確認
    if (pokemon.ability.id == 0 && PokeDB().pokeBase[pokemon.no]!.ability.where((e) => e.id == ability.id).isNotEmpty) {
      pokemon.ability = ability;
    }
  }

  set isFainting(bool t) {
    // テラスタル解除
    if (t) isTerastaling = false;
    _isFainting = t;
  }

  // 効果等を起こさずもちものをセット
  void setHoldingItemNoEffect(Item? item) {
    _holdingItem = item;
  }

  // 効果等を起こさずとくせいをセット
  void setCurrentAbilityNoEffect(Ability ability) {
    _currentAbility = ability;
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

  // 相手のこうげきわざ以外でのダメージを受けるかどうか
  bool get isNotAttackedDamaged {
    return currentAbility.id != 98;
  }

  // 交代可能な状態かどうか
  bool canChange(PokemonState yourState, PhaseState state) {
    var fields = isMe ? state.ownFields : state.opponentFields;
    return fields.where((element) => element.id == IndividualField.fairyLock).isEmpty &&
          (isTypeContain(PokeTypeId.ghost) ||   // ゴーストタイプならOK
           // (yourState.currentAbility.id != 23)   // TODO:かげふみとくせいで、ailment「にげられない」を追加しとく。ほかにもとくせい「じりょく」とか「ありじごく」とか
           ailmentsWhere((e) => e.id == Ailment.cannotRunAway).isEmpty
          );
  }

  // きゅうしょランク加算
  void addVitalRank(int i) {
    int findIdx = buffDebuffs.indexWhere((element) => BuffDebuff.vital1 <= element.id && element.id <= BuffDebuff.vital3);
    if (findIdx < 0) {
      if (i <= 0) return;
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
    if (isTerastaling) {
      return teraType1.id == typeId;
    }
    else {
      return type1.id == typeId || type2?.id == typeId;
    }
  }

  double typeBonusRate(int moveTypeId, bool isAdaptability) {
    double rate = 1.0;
    if (isTerastaling) {
      if (isAdaptability) {
        if (teraType1.id == moveTypeId) rate += 1.0;
        if (type1.id == moveTypeId || type2?.id == moveTypeId) {
          rate += 0.5;
        }
        if (rate > 2.25) rate = 2.25;
      }
      else {
        if (teraType1.id == moveTypeId) rate += 0.5;
        if (type1.id == moveTypeId || type2?.id == moveTypeId) {
          rate += 0.5;
        }
      }
    }
    else {
      if (type1.id == moveTypeId || type2?.id == moveTypeId) {
        rate += 0.5;
        if (isAdaptability) rate += 0.5;
      }
    }

    return rate;
  }

  // すなあらしダメージを受けるか判定
  bool isSandstormDamaged() {
    if (isTypeContain(5) || isTypeContain(6) || isTypeContain(9)) return false;
    if (holdingItem?.id == 690) return false;   // ぼうじんゴーグル
    if (currentAbility.id == 146 || currentAbility.id == 8 ||       // すなかき/すながくれ
        currentAbility.id == 159 || currentAbility.id == 98 ||      // すなのちから/マジックガード
        currentAbility.id == 142) return false;                     // ぼうじん
    if (ailmentsWhere(        // あなをほる/ダイビング状態
      (e) => e.id == Ailment.digging || e.id == Ailment.diving).isNotEmpty) return false;
    return true;
  }

  // ポケモン交代やひんしにより退場する場合の処理
  void processExitEffect(bool isOwn, PokemonState yourState) {
    resetStatChanges();
    resetRealSixParams();
    setCurrentAbilityNoEffect(pokemon.ability);
    type1 = pokemon.type1;
    type2 = pokemon.type2;
    ailmentsRemoveWhere((e) => e.id > Ailment.sleep);   // 状態変化の回復
    // もうどくはターン数をリセット(ターン数をもとにダメージを計算するため)
    var badPoison = ailmentsWhere((e) => e.id == Ailment.badPoison);
    if (badPoison.isNotEmpty) badPoison.first.turns = 0;
    if (_isFainting) ailmentsClear();
    // 退場後も継続するフォルム以外をクリア
    var unchangingForms = buffDebuffs.where((e) =>
      e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace ||
      e.id == BuffDebuff.manpukuForm || e.id == BuffDebuff.harapekoForm ||
      e.id == BuffDebuff.transedForm || e.id == BuffDebuff.revealedForm ||
      e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm
    ).toList();
    buffDebuffs.clear();
    buffDebuffs.addAll(unchangingForms);
    var unchangingHidden = hiddenBuffs.where((e) =>
      e.id == BuffDebuff.lastLostItem || e.id == BuffDebuff.lastLostBerry
    ).toList();
    hiddenBuffs.clear();
    hiddenBuffs.addAll(unchangingHidden);
    // ひんしでない退場で発動するフォルムチェンジ
    if (!isFainting) {
      int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.naiveForm);
      if (findIdx >= 0) {
        buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.mightyForm);   // マイティフォルム
        // TODO この2行csvに移したい
        maxStats[StatIndex.A.index].race = 160; maxStats[StatIndex.B.index].race = 97; maxStats[StatIndex.C.index].race = 106; maxStats[StatIndex.D.index].race = 87;
        minStats[StatIndex.A.index].race = 160; minStats[StatIndex.B.index].race = 97; minStats[StatIndex.C.index].race = 106; minStats[StatIndex.D.index].race = 87;
        for (int i = StatIndex.A.index; i <= StatIndex.D.index; i++) {
          var biases = Temper.getTemperBias(pokemon.temper);
          maxStats[StatIndex.A.index].real = SixParams.getRealABCDS(
            pokemon.level, maxStats[StatIndex.A.index].race, maxStats[StatIndex.A.index].indi, maxStats[StatIndex.A.index].effort, biases[i-1]);
          minStats[StatIndex.A.index].real = SixParams.getRealABCDS(
            pokemon.level, minStats[StatIndex.A.index].race, minStats[StatIndex.A.index].indi, minStats[StatIndex.A.index].effort, biases[i-1]);
        }
      }
    }
    // 場にいると両者にバフ/デバフがかかる場合
    if (currentAbility.id == 186 && yourState.currentAbility.id != 186) { // ダークオーラ
      yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.darkAura || element.id == BuffDebuff.antiDarkAura);
    }
    if (currentAbility.id == 187 && yourState.currentAbility.id == 187) { // フェアリーオーラ
      yourState.buffDebuffs.indexWhere((element) => element.id == BuffDebuff.fairyAura || element.id == BuffDebuff.antiFairyAura);
    }
    // 場にいると相手にバフ/デバフがかかる場合
    if (currentAbility.id == 284) { // わざわいのうつわ
      yourState.buffDebuffs.removeWhere((element) => element.id == BuffDebuff.specialAttack0_75);
    }
    if (currentAbility.id == 285) { // わざわいのつるぎ
      yourState.buffDebuffs.removeWhere((element) => element.id == BuffDebuff.defense0_75);
    }
    if (currentAbility.id == 286) { // わざわいのおふだ
      yourState.buffDebuffs.removeWhere((element) => element.id == BuffDebuff.attack0_75);
    }
    if (currentAbility.id == 287) { // わざわいのたま
      yourState.buffDebuffs.removeWhere((element) => element.id == BuffDebuff.specialDefense0_75);
    }
    // にげられない状態の解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.cannotRunAway);
    // 退場することで自身に効果がある場合
    if (!_isFainting && currentAbility.id == 30) { // しぜんかいふく
      ailmentsClear();
    }
    if (!_isFainting && currentAbility.id == 144) { // さいせいりょく
      if (isOwn) {
        remainHP += (pokemon.h.real / 3).floor();
      }
      else {
        remainHPPercent += 33;
      }
    }
  }

  // ポケモン交代や死に出しにより登場する場合の処理
  void processEnterEffect(bool isOwn, PhaseState state, PokemonState yourState) {
    if (battlingNum < 1) battlingNum = 1;
    setCurrentAbilityNoEffect(pokemon.ability);
    processPassiveEffect(isOwn, state, yourState);   // パッシブ効果
    Weather.processWeatherEffect(Weather(0), state.weather, isOwn ? this : null, isOwn ? null : this);  // 天気の影響
    Field.processFieldEffect(Field(0), state.field, isOwn ? this : null, isOwn ? null : this);  // フィールドの影響
  }

  // ポケモンのとくせい/もちもの等で常に働く効果を付与。ポケモン登場時に一度だけ呼ぶ
  void processPassiveEffect(bool isOwn, PhaseState state, PokemonState yourState) {
    // ポケモン固有のフォルム等
    if (pokemon.no == 648) {  // メロエッタ
      buffDebuffs.add(BuffDebuff(BuffDebuff.voiceForm));
    }

    // とくせいの効果を反映
    currentAbility.processPassiveEffect(this, yourState, isOwn, state);
 
    // もちものの効果を反映
    holdingItem?.processPassiveEffect(this);
  
    // 地面にいるどくポケモンによるどくびし/どくどくびしの消去
    var indiField = isOwn ? state.ownFields : state.opponentFields;
    if (isGround(indiField) && isTypeContain(PokeTypeId.poison)) {
      indiField.removeWhere((e) => e.id == IndividualField.toxicSpikes);
    }
  }

  // ターン終了時に行う処理
  void processTurnEnd(PhaseState state, bool isFaintingChange,) {
    // 状態変化の経過ターンインクリメント
    if (!isFaintingChange) {
      for (var e in _ailments.iterable) {
        e.turns++;
      }
    }
    // ねむけ→ねむりに変化
    var findIdx = ailmentsIndexWhere((e) => e.id == Ailment.sleepy && e.turns >= 2);
    if (findIdx >= 0) {
      ailmentsRemoveAt(findIdx);
      ailmentsAdd(Ailment(Ailment.sleep), state);
    }
    // まもる状態は解除
    ailmentsRemoveWhere((e) => e.id == Ailment.protect);
    // はねやすめ解除＆ひこうタイプ復活
    findIdx = ailmentsIndexWhere((e) => e.id == Ailment.roost);
    if (findIdx >= 0) {
      if (ailments(findIdx).extraArg1 == 1) type1 = PokeType.createFromId(3);
      if (ailments(findIdx).extraArg1 == 2) type2 = PokeType.createFromId(3);
      ailmentsRemoveAt(findIdx);
    }
    // その他の補正の経過ターンインクリメント
    for (var e in buffDebuffs) {
      e.turns++;
    }
    // 隠れ補正の経過ターンインクリメント
    for (var e in hiddenBuffs) {
      e.turns++;
    }
    // わざの反動で動けない状態は2ターンエンド経過で削除
    hiddenBuffs.removeWhere((e) => e.id == BuffDebuff.recoiling && e.turns >= 2);
  }

  // 状態異常に関する関数群ここから
  bool ailmentsAdd(Ailment ailment, PhaseState state, {bool forceAdd = false}) {
    bool isMe = playerType.id == PlayerType.me;
    var indiFields = isMe ? state.ownFields : state.opponentFields;
    // すでに同じものになっている場合は何も起こらない
    if (_ailments.where((e) => e.id == ailment.id).isNotEmpty) return false;
    // タイプによる耐性
    if ((isTypeContain(PokeTypeId.steel) || isTypeContain(PokeTypeId.poison)) &&
        (ailment.id == Ailment.poison || (!forceAdd && ailment.id == Ailment.badPoison))    // もうどくに関しては、わざ使用者のとくせいがふしょくなら可能
    ) return false;
    if (isTypeContain(PokeTypeId.fire) && ailment.id == Ailment.burn) return false;
    if (isTypeContain(PokeTypeId.ice) && ailment.id == Ailment.freeze) return false;
    if (isTypeContain(PokeTypeId.electric) && ailment.id == Ailment.paralysis) return false;
    // とくせいによる耐性
    if ((currentAbility.id == 17 || currentAbility.id == 257) && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) return false;
    if ((currentAbility.id == 7) && (ailment.id == Ailment.paralysis)) return false;
    if ((currentAbility.id == 41 || currentAbility.id == 199 || currentAbility.id == 270) && (ailment.id == Ailment.burn)) return false;    // みずのベール/ねつこうかん<-やけど
    if (currentAbility.id == 15 && (ailment.id == Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // ふみん
    if (currentAbility.id == 166 && isTypeContain(12) && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // フラワーベール
    if (currentAbility.id == 272 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // きよめのしお
    if ((currentAbility.id == 39) && (ailment.id == Ailment.flinch)) return false;      // せいしんりょく<-ひるみ
    if ((currentAbility.id == 40) && (ailment.id == Ailment.freeze)) return false;      // マグマのよろい<-こおり
    if ((currentAbility.id == 102) && (state.weather.id == Weather.sunny) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // 晴れ下リーフガード<-状態異常＋ねむけ
    if (currentAbility.id == 213 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // ぜったいねむり<-状態異常＋ねむけ
    // TODO:リミットシールド
    if (currentAbility.id == 213) return false;
    if (state.weather.id == Weather.sunny && holdingItem?.id != Item.bannougasa && ailment.id == Ailment.freeze) return false;
    if (state.field.id == Field.electricTerrain &&
        isGround(indiFields) &&
        ailment.id == Ailment.sleep) return false;
    // 各々の場
    if (indiFields.where((e) => e.id == IndividualField.safeGuard).isNotEmpty && (ailment.id <= Ailment.confusion || ailment.id == Ailment.sleepy)) return false; // しんぴのまもり
    if (state.field.id == Field.mistyTerrain) return false;

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
    {
     int? moveId, int? abilityId, int? itemId, bool lastMirror = false,
     List<IndividualField>? myFields, List<IndividualField>? yourFields,
    }
  ) {
    int change = num;
    if (!isMyEffect && buffDebuffs.where((e) => e.id == BuffDebuff.substitute).isNotEmpty && num < 0) return false;   // みがわり
    if (!isMyEffect && myFields!.where((e) => e.id == IndividualField.mist).isNotEmpty && num < 0) return false;       // しろいきり
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
      yourState.addStatChanges(isMyEffect, index, num, this, myFields: yourFields, yourFields: myFields, lastMirror: true);
      return false;
    }
    if (!isMyEffect && abilityId == 22 && currentAbility.id == 275) change = 1;   // いかくに対するばんけん

    if (currentAbility.id == 86) change *= 2;   // たんじゅん
    if (currentAbility.id == 126) change *= -1; // あまのじゃく
    if (!isMyEffect && currentAbility.id == 128 && num < 0) {  // まけんき
      _statChanges[0] = (_statChanges[0] + 2).clamp(-6, 6);
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

  static int packStatChanges(List<int> statChanges) {
    int ret = 0;
    for (int i = 0; i < statChanges.length && i < 7; i++) {
      int t = (statChanges[i] + 6).clamp(0, 12);
      ret <<= 4;
      ret += t;
    }
    return ret;
  }

  static List<int> unpackStatChanges(int statChanges) {
    int t = statChanges;
    List<int> ret = List.generate(7, (i) => 0);
    for (int i = 6; i >= 0; i--) {
      int statChange = (t & 0xf) - 6;
      ret[i] = statChange;
      t >>= 4;
    }
    return ret;
  }

  // ランク補正後の実数値→ランク補正なしの実数値を得る
  int getNotRankedStat(StatIndex statIdx, int stat) {
    if (statIdx == StatIndex.H) {
      return stat;
    }
    double coef = 1.0;
    switch (statChanges(statIdx.index-1)) {
      case -6:
        coef = 2 / 8;
        break;
      case -5:
        coef = 2 / 7;
        break;
      case -4:
        coef = 2 / 6;
        break;
      case -3:
        coef = 2 / 5;
        break;
      case -2:
        coef = 2 / 4;
        break;
      case -1:
        coef = 2 / 3;
        break;
      case 1:
        coef = 3 / 2;
        break;
      case 2:
        coef = 4 / 2;
        break;
      case 3:
        coef = 5 / 2;
        break;
      case 4:
        coef = 6 / 2;
        break;
      case 5:
        coef = 7 / 2;
        break;
      case 6:
        coef = 8 / 2;
        break;
      default:
        break;
    }
    // ランク補正で割る
    int ret = (stat.toDouble() / coef).floor();
    if ((ret.toDouble() * coef).floor() < stat) {ret++;}
    else if ((ret.toDouble() * coef).floor() > stat) {ret--;}
    return ret;
  }

  // ランク変化に関する関数群ここまで

  // ランク補正等込みのHABCDSを返す
  int finalizedMaxStat(StatIndex statIdx, PokeType type, PokemonState yourState, PhaseState state, {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return maxStats[StatIndex.H.index].real;
    }
    return _finalizedStat(maxStats[statIdx.index].real, statIdx, type, yourState, state, plusCut: plusCut, minusCut: minusCut);
  }
  
  int finalizedMinStat(StatIndex statIdx, PokeType type, PokemonState yourState, PhaseState state, {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return minStats[StatIndex.H.index].real;
    }
    return _finalizedStat(minStats[statIdx.index].real, statIdx, type, yourState, state, plusCut: plusCut, minusCut: minusCut);
  }

  int _finalizedStat(int val, StatIndex statIdx, PokeType type, PokemonState yourState, PhaseState state, {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return val;
    }
    double ret = val.toDouble();
    // ランク補正
    switch (statChanges(statIdx.index-1)) {
      case -6:
        if (!minusCut) ret = ret * 2 / 8;
        break;
      case -5:
        if (!minusCut) ret = ret * 2 / 7;
        break;
      case -4:
        if (!minusCut) ret = ret * 2 / 6;
        break;
      case -3:
        if (!minusCut) ret = ret * 2 / 5;
        break;
      case -2:
        if (!minusCut) ret = ret * 2 / 4;
        break;
      case -1:
        if (!minusCut) ret = ret * 2 / 3;
        break;
      case 1:
        if (!plusCut) ret = ret * 3 / 2;
        break;
      case 2:
        if (!plusCut) ret = ret * 4 / 2;
        break;
      case 3:
        if (!plusCut) ret = ret * 5 / 2;
        break;
      case 4:
        if (!plusCut) ret = ret * 6 / 2;
        break;
      case 5:
        if (!plusCut) ret = ret * 7 / 2;
        break;
      case 6:
        if (!plusCut) ret = ret * 8 / 2;
        break;
      default:
        break;
    }
    // バフ等の補正
    switch (statIdx) {
      case StatIndex.A:
        {
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_3) >= 0) ret *= 1.3;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack2) >= 0) ret *= 2;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackSpeed0_5) >= 0) ret *= 0.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defeatist) >= 0) ret *= 0.5;
          if (type.id == 10 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterBubble1) >= 0) ret *= 0.5;
          if (type.id == 11 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterBubble2) >= 0) ret *= 2;
          if (type.id == 9 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelWorker) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.gorimuchu) >= 0) ret *= 1.5;
          if (type.id == 13 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electric1_3) >= 0) ret *= 1.3;
          if (type.id == 16 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragon1_5) >= 0) ret *= 1.5;
          if (type.id == 8 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghosted0_5) >= 0) ret *= 0.5;
          if (type.id == 6 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rock1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack0_75) >= 0) ret *= 0.75;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attack1_33) >= 0) ret *= 1.33;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove2) >= 0) ret *= 2;
        }
        break;
      case StatIndex.B:
        {
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_3) >= 0) ret *= 1.3;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.guard2) >= 0) ret *= 2.0;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.guard1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defense0_75) >= 0) ret *= 0.75;
          if (state.weather.id == Weather.snowy && isTypeContain(15)) ret * 1.5;
        }
        break;
      case StatIndex.C:
        {
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack1_3) >= 0) ret *= 1.3;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.defeatist) >= 0) ret *= 0.5;
          if (type.id == 10 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterBubble1) >= 0) ret *= 0.5;
          if (type.id == 11 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.waterBubble2) >= 0) ret *= 2;
          if (type.id == 9 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.steelWorker) >= 0) ret *= 1.5;
          if (type.id == 13 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.electric1_3) >= 0) ret *= 1.3;
          if (type.id == 16 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.dragon1_5) >= 0) ret *= 1.5;
          if (type.id == 8 && yourState.buffDebuffs.indexWhere((e) => e.id == BuffDebuff.ghosted0_5) >= 0) ret *= 0.5;
          if (type.id == 6 && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.rock1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack0_75) >= 0) ret *= 0.75;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack1_33) >= 0) ret *= 1.33;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceSpecs) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialAttack2) >= 0) ret *= 2.0;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackMove2) >= 0) ret *= 2.0;
        }
        break;
      case StatIndex.D:
        {
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense1_3) >= 0) ret *= 1.3;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense0_75) >= 0) ret *= 0.75;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.onlyAttackSpecialDefense1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.specialDefense2) >= 0) ret *= 2.0;
          if (state.weather.id == Weather.sandStorm && isTypeContain(6)) ret * 1.5;
        }
        break;
      case StatIndex.S:
        {
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed2) >= 0) ret *= 2.0;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.unburden) >= 0) ret *= 2.0;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed1_5IgnPara) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.attackSpeed0_5) >= 0) ret *= 0.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.choiceScarf) >= 0) ret *= 1.5;
          if (buffDebuffs.indexWhere((e) => e.id == BuffDebuff.speed0_5) >= 0) ret *= 0.5;
        }
        break;
      default:
        break;
    }

    return ret.floor();
  }

  // ガードシェア等によって変更された実数値を元に戻す
  void resetRealSixParams() {
    SixParams.getRealH(pokemon.level, maxStats[StatIndex.H.index].race, maxStats[StatIndex.H.index].indi, maxStats[StatIndex.H.index].effort);
    final temperBiases = Temper.getTemperBias(pokemon.temper);
    for (int i = StatIndex.A.index; i < StatIndex.size.index; i++) {
      SixParams.getRealABCDS(pokemon.level, maxStats[i].race, maxStats[i].indi, maxStats[i].effort, temperBiases[i-1]);
    }
  }

  // SQLに保存された文字列からPokemonStateをパース
  static PokemonState deserialize(dynamic str, String split1, String split2, String split3) {
    final pokeData = PokeDB();
    PokemonState pokemonState = PokemonState();
    final stateElements = str.split(split1);
    // pokemon
    pokemonState.pokemon = pokeData.pokemons[int.parse(stateElements[0])]!.copyWith();
    // ポケモンのレベルを50に
    pokemonState.pokemon.level = 50;
    pokemonState.pokemon.updateRealStats();
    // remainHP
    pokemonState.remainHP = int.parse(stateElements[1]);
    // remainHPPercent
    pokemonState.remainHPPercent = int.parse(stateElements[2]);
    // isTerastaling
    pokemonState.isTerastaling = int.parse(stateElements[3]) != 0;
    // teraType1
    pokemonState.teraType1 = PokeType.createFromId(int.parse(stateElements[4]));
    // _isFainting
    pokemonState._isFainting = int.parse(stateElements[5]) != 0;
    // battlingNum
    pokemonState.battlingNum = int.parse(stateElements[6]);
    // holdingItem
    pokemonState.setHoldingItemNoEffect(stateElements[7] == '' ? null : pokeData.items[int.parse(stateElements[7])]);
    // usedPPs
    pokemonState.usedPPs.clear();
    final pps = stateElements[8].split(split2);
    for (final pp in pps) {
      if (pp == '') break;
      pokemonState.usedPPs.add(int.parse(pp));
    }
    // statChanges
    final statChangeElements = stateElements[9].split(split2);
    for (int i = 0; i < 7; i++) {
      pokemonState._statChanges[i] = int.parse(statChangeElements[i]);
    }
    // buffDebuffs
    final buffDebuffElements = stateElements[10].split(split2);
    for (final buffDebuff in buffDebuffElements) {
      if (buffDebuff == '') break;
      pokemonState.buffDebuffs.add(BuffDebuff.deserialize(buffDebuff, split3));
    }
    // hiddenBuffs
    final hiddenBuffElements = stateElements[11].split(split2);
    for (final buffDebuff in hiddenBuffElements) {
      if (buffDebuff == '') break;
      pokemonState.hiddenBuffs.add(BuffDebuff.deserialize(buffDebuff, split3));
    }
    // currentAbility
    pokemonState.setCurrentAbilityNoEffect(Ability.deserialize(stateElements[12], split2));
    // ailments
    pokemonState._ailments = Ailments.deserialize(stateElements[13], split2, split3);
    // minStats
    final minStatElements = stateElements[14].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.minStats[i] = SixParams.deserialize(minStatElements[i], split3);
    }
    // maxStats
    final maxStatElements = stateElements[15].split(split2);
    for (int i = 0; i < 6; i++) {
      pokemonState.maxStats[i] = SixParams.deserialize(maxStatElements[i], split3);
    }
    // possibleAbilities
    final abilities = stateElements[16].split(split2);
    for (var ability in abilities) {
      if (ability == '') break;
      pokemonState.possibleAbilities.add(Ability.deserialize(ability, split3));
    }
    // impossibleItems
    final items = stateElements[17].split(split2);
    for (var item in items) {
      if (item == '') break;
      pokemonState.impossibleItems.add(pokeData.items[int.parse(item)]!);
    }
    // moves
    final moves = stateElements[18].split(split2);
    for (var move in moves) {
      if (move == '') break;
      pokemonState.moves.add(pokeData.moves[int.parse(move)]!);
    }
    // type1
    pokemonState.type1 = PokeType.createFromId(int.parse(stateElements[19]));
    // type2
    if (stateElements[20] != '') {
      pokemonState.type2 = PokeType.createFromId(int.parse(stateElements[20]));
    }
    // lastMove
    if (stateElements[21] != '') {
      pokemonState.lastMove = pokeData.moves[int.parse(stateElements[21])];
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
    // isTerastaling
    ret += isTerastaling ? '1' : '0';
    ret += split1;
    // teraType1
    ret += teraType1.id.toString();
    ret += split1;
    // _isFainting
    ret += _isFainting ? '1' : '0';
    ret += split1;
    // battlingNum
    ret += battlingNum.toString();
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
    // hiddenBuffs
    for (final buffDebuff in hiddenBuffs) {
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
    ret += split1;
    // lastMove
    if (lastMove != null) {
      ret += lastMove!.id.toString();
    }

    return ret;
  }
}
