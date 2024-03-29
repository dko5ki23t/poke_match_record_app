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
  PlayerType playerType = PlayerType.none;    // ポケモンの所有者
  Pokemon pokemon = Pokemon();  // ポケモン(DBへの保存時はIDだけ)
  int remainHP = 0;             // 残りHP
  int remainHPPercent = 100;    // 残りHP割合
  bool isTerastaling = false;   // テラスタルしているかどうか
  PokeType teraType1 = PokeType.createFromId(0);      // テラスタルした場合のタイプ
  bool _isFainting = false;     // ひんしかどうか
  int battlingNum = 0;          // バトルでの選出順(選出されていなければ0、選出順を気にしない場合は単に0/1)
  Item? _holdingItem = Item(
    id: 0, displayName: '', displayNameEn: '', flingPower: 0, flingEffectId: 0,
    timing: Timing.none, isBerry: false, imageUrl: '');  // 持っているもちもの(失えばnullにする)
  List<int> usedPPs = List.generate(4, (index) => 0);       // 各わざの消費PP
  List<int> _statChanges = List.generate(7, (i) => 0);   // のうりょく変化
  List<BuffDebuff> buffDebuffs = [];    // その他の補正(フォルムとか)
  List<BuffDebuff> hiddenBuffs = [];    // 画面上には表示させないその他の補正(わざ「ものまね」の変化後とか)
  Ability _currentAbility = Ability(0, '', '', Timing.none, Target(0), AbilityEffect(0));  // 現在のとくせい(バトル中にとくせいが変わることあるので)
  Ailments _ailments = Ailments();   // 状態変化
  SixStats minStats = SixStats.generateMinStat();     // 個体値や努力値のあり得る範囲の最小値
  SixStats maxStats = SixStats.generateMaxStat();     // 個体値や努力値のあり得る範囲の最大値
  List<Ability> possibleAbilities = [];     // 候補のとくせい
  List<Item> impossibleItems = [];          // 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Move> moves = [];        // 判明しているわざ
  PokeType type1 = PokeType.createFromId(0);  // ポケモンのタイプ1(対戦中変わることもある)
  PokeType? type2;              // ポケモンのタイプ2
  Move? lastMove;               // 最後に使用した(PP消費した)わざ

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
    ..minStats = minStats.copyWith()
    ..maxStats = maxStats.copyWith()
    ..possibleAbilities = [for (final e in possibleAbilities) e.copyWith()]
    ..impossibleItems = [for (final e in impossibleItems) e.copyWith()]
    ..moves = [...moves]
    ..type1 = type1
    ..type2 = type2
    ..lastMove = lastMove?.copyWith();

  Item? get holdingItem => _holdingItem != null ? canUseItem ? _holdingItem : PokeDB().items[0] : null;
  Ability get currentAbility => isEffectAbility ? _currentAbility : PokeDB().abilities[0]!;
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
  bool get isMe => playerType == PlayerType.me;
  bool get usedAnyPP => usedPPs.where((element) => element > 0).isNotEmpty;
  bool get canUseItem {
    return ailmentsWhere((e) => e.id == Ailment.embargo).isEmpty &&
      buffDebuffs.where((e) => e.id == BuffDebuff.noItemEffect).isEmpty &&
      hiddenBuffs.where((e) => e.id == BuffDebuff.magicRoom).isEmpty;
  }
  bool get isEffectAbility {
    return ailmentsWhere((e) => e.id == Ailment.abilityNoEffect).isEmpty;
  }

  set holdingItem(Item? item) {
    _holdingItem?.clearPassiveEffect(this);
    if (canUseItem) item?.processPassiveEffect(this);
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

  Item? getHoldingItem() {  // もちものの効果なしかどうかに関わらずもちもの取得
    return _holdingItem;
  }

  Ability getCurrentAbility() {   // とくせいの効果なしかどうかに関わらずとくせい取得
    return _currentAbility;
  }

  void setCurrentAbility(Ability ability, PokemonState yourState, bool isOwn, PhaseState state) {
    _currentAbility.clearPassiveEffect(this, yourState, isOwn, state);
    if (isEffectAbility) ability.processPassiveEffect(this, yourState, isOwn, state);
    _currentAbility = ability;
    /*if (pokemon.ability.id == 0 && PokeDB().pokeBase[pokemon.no]!.ability.where((e) => e.id == ability.id).isNotEmpty) {
      pokemon.ability = ability;
    }*/
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
    if (isTypeContain(PokeTypeId.fly) || currentAbility.id == 26 || holdingItem?.id == 584 ||
        ailmentsWhere((e) => e.id == Ailment.magnetRise || e.id == Ailment.telekinesis).isNotEmpty) {
      return false;
    }
    return true;
  }

  // 相手のこうげきわざ以外でのダメージを受けるかどうか
  bool get isNotAttackedDamaged {
    return buffDebuffs.where((e) => e.id == BuffDebuff.magicGuard).isEmpty;
  }

  // 交代可能な状態かどうか
  bool canChange(PokemonState yourState, PhaseState state) {
    var fields = isMe ? state.getIndiFields(PlayerType.me) : state.getIndiFields(PlayerType.opponent);
    return isTypeContain(PokeTypeId.ghost) ||   // ゴーストタイプならOK
       holdingItem?.id == 272 ||            // きれいなぬけがらを持っていればOK
    (fields.where((element) => element.id == IndividualField.fairyLock).isEmpty &&
      (
        ailmentsWhere((e) => e.id == Ailment.cannotRunAway).isEmpty ||
        (ailmentsWhere((e) => e.id == Ailment.cannotRunAway).first.extraArg1 == 2 && !isTypeContain(PokeTypeId.steel)) ||
        (ailmentsWhere((e) => e.id == Ailment.cannotRunAway).first.extraArg1 == 3 && !isGround(fields))
      )
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
    if (isTerastaling && teraType1.id != PokeTypeId.stellar) {
      return teraType1.id == typeId;
    }
    else {
      List<int> typeIDs = [type1.id];
      if (type2 != null) typeIDs.add(type2!.id);
      if (ailmentsWhere((e) => e.id == Ailment.halloween).isNotEmpty) typeIDs.add(PokeTypeId.ghost);
      if (ailmentsWhere((e) => e.id == Ailment.forestCurse).isNotEmpty) typeIDs.add(PokeTypeId.grass);
      return typeIDs.contains(typeId);
    }
  }

  // ダメージ計算におけるタイプ一致ボーナス
  double typeBonusRate(int moveTypeId, bool isAdaptability) {
    double rate = 1.0;
    if (isTerastaling) {
      if (teraType1.id == PokeTypeId.stellar) {   // ステラタイプ
        if (canGetStellarHosei(moveTypeId)) {
          if (isTypeContain(moveTypeId)) {
            rate += 1.0;
          }
          else {
            rate += 0.2;
          }
        }
        else {
          if (isTypeContain(moveTypeId)) {
            rate += 0.5;
          }
        }
      }
      else {      // その他のタイプ
        if (isAdaptability) {
          if (teraType1.id == moveTypeId) {
            rate += 1.0;
          }
          if (type1.id == moveTypeId || type2?.id == moveTypeId) {
            rate += 0.5;
          }
          if (rate > 2.25) rate = 2.25;
        }
        else {
          if (teraType1.id == moveTypeId) {
            rate += 0.5;
          }
          if (type1.id == moveTypeId || type2?.id == moveTypeId) {
            rate += 0.5;
          }
        }
      }
    }
    else {
      if (isTypeContain(moveTypeId)) {
        rate += 0.5;
        if (isAdaptability) rate += 0.5;
      }
    }

    return rate;
  }

  bool canGetTerastalHosei(int typeId) {
    if (!isTerastaling || teraType1.id == PokeTypeId.stellar) return false;   // 前提
    if (teraType1.id == typeId) return true;
    return false;
  }

  bool canGetStellarHosei(int typeId) {
    if (!isTerastaling || teraType1.id != PokeTypeId.stellar) return false;   // 前提
    int findIdx = hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.stellarUsed);
    if (pokemon.no == 1024 || findIdx < 0) return true;
    if (hiddenBuffs[findIdx].extraArg1 & (1 << (typeId-1)) != 0) return false;   // すでに使ったことがあるタイプ
    return true;
  }

  void addStellarUsed(int typeId) {
    if (!isTerastaling || teraType1.id != PokeTypeId.stellar || pokemon.no == 1024) return;   // 前提
    int findIdx = hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.stellarUsed);
    if (findIdx < 0) {
      hiddenBuffs.add(BuffDebuff(BuffDebuff.stellarUsed)..extraArg1 = 1 << (typeId-1));
    }
    hiddenBuffs[findIdx].extraArg1 |= 1 << (typeId-1);
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
  void processExitEffect(bool isOwn, PokemonState yourState, PhaseState state) {
    resetStatChanges();
    resetRealSixParams();
    setCurrentAbilityNoEffect(pokemon.ability);
    type1 = pokemon.type1;
    type2 = pokemon.type2;
    ailmentsRemoveWhere((e) => e.id > Ailment.sleep);   // 状態変化の回復
    // もうどくはターン数をリセット(ターン数をもとにダメージを計算するため)
    var badPoison = ailmentsWhere((e) => e.id == Ailment.badPoison);
    if (badPoison.isNotEmpty) badPoison.first.turns = 0;
    if (_isFainting) ailmentsClear(yourState, state);
    // 退場後も継続するフォルム以外をクリア
    var unchangingForms = buffDebuffs.where((e) =>
      e.id == BuffDebuff.iceFace || e.id == BuffDebuff.niceFace ||
      e.id == BuffDebuff.manpukuForm || e.id == BuffDebuff.harapekoForm ||
      e.id == BuffDebuff.transedForm || e.id == BuffDebuff.revealedForm ||
      e.id == BuffDebuff.naiveForm || e.id == BuffDebuff.mightyForm ||
      e.id == BuffDebuff.terastalForm || e.id == BuffDebuff.stellarForm
    ).toList();
    buffDebuffs.clear();
    buffDebuffs.addAll(unchangingForms);
    var unchangingHidden = hiddenBuffs.where((e) =>
      e.id == BuffDebuff.lastLostItem || e.id == BuffDebuff.lastLostBerry ||
      e.id == BuffDebuff.attackedCount || e.id == BuffDebuff.zoroappear ||
      e.id == BuffDebuff.stellarUsed
    ).toList();
    hiddenBuffs.clear();
    hiddenBuffs.addAll(unchangingHidden);
    // ひんしでない退場で発動するフォルムチェンジ
    if (!isFainting) {
      int findIdx = buffDebuffs.indexWhere((e) => e.id == BuffDebuff.naiveForm);
      if (findIdx >= 0) {
        buffDebuffs[findIdx] = BuffDebuff(BuffDebuff.mightyForm);   // マイティフォルム
        // TODO この2行csvに移したい
        maxStats.a.race = 160; maxStats.b.race = 97; maxStats.c.race = 106; maxStats.d.race = 87;
        minStats.a.race = 160; minStats.b.race = 97; minStats.c.race = 106; minStats.d.race = 87;
        for (final stat in [StatIndex.A, StatIndex.B, StatIndex.C, StatIndex.D]) {
          var biases = Temper.getTemperBias(pokemon.temper);
          maxStats[stat].real = SixParams.getRealABCDS(
            pokemon.level, maxStats[stat].race, maxStats[stat].indi, maxStats[stat].effort, biases[stat.index-1]);
          minStats[stat].real = SixParams.getRealABCDS(
            pokemon.level, minStats[stat].race, minStats[stat].indi, minStats[stat].effort, biases[stat.index-1]);
        }
      }
    }
    // あいてのロックオン状態解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.lockOn);
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
    // あいてのにげられない状態の解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.cannotRunAway && e.extraArg1 == 1);
    // 退場することで自身に効果がある場合
    if (!_isFainting && currentAbility.id == 30) { // しぜんかいふく
      ailmentsClear(yourState, state);
    }
    if (!_isFainting && currentAbility.id == 144) { // さいせいりょく
      if (isOwn) {
        remainHP += (pokemon.h.real / 3).floor();
      }
      else {
        remainHPPercent += 33;
      }
    }
    // 最後に退場した状態の保存
    state.lastExitedStates[isMe ? 0 : 1][state.getPokemonIndex(playerType, null)-1] = copyWith();
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
    var indiField = playerType == PlayerType.me ? state.getIndiFields(PlayerType.me) : state.getIndiFields(PlayerType.opponent);
    if (isGround(indiField) && isTypeContain(PokeTypeId.poison)) {
      indiField.removeWhere((e) => e.id == IndividualField.toxicSpikes);
    }
  }

  // ターン終了時に行う処理
  void processTurnEnd(PhaseState state, bool isFaintingChange,) {
    // 状態変化の経過ターンインクリメント
    if (!isFaintingChange) {
      for (var e in _ailments.iterable) {
        if (e.id != Ailment.sleep) {    // ねむりのターン経過は行動時のみ
          e.turns++;
        }
      }
    }
    // ちゅうもくのまと/まもる状態/そうでんは解除
    ailmentsRemoveWhere((e) => e.id == Ailment.attention || e.id == Ailment.protect || e.id == Ailment.electrify);
    // はねやすめ解除＆ひこうタイプ復活
    var findIdx = ailmentsIndexWhere((e) => e.id == Ailment.roost);
    if (findIdx >= 0) {
      if (ailments(findIdx).extraArg1 == 1) type1 = PokeType.createFromId(PokeTypeId.fly);
      if (ailments(findIdx).extraArg1 == 2) type2 = PokeType.createFromId(PokeTypeId.fly);
      if (ailments(findIdx).extraArg1 == 3) {
        type2 = PokeType.createFromId(type1.id);
        type1 = PokeType.createFromId(PokeTypeId.fly);
      }
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
    // スロースタート終了
    buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attackSpeed0_5 && e.turns >= 5);
    // 交代したターンであることのフラグ削除
    // 当ターンでランクが変わったかを示すフラグ削除
    hiddenBuffs.removeWhere((e) => e.id == BuffDebuff.changedThisTurn ||
      e.id == BuffDebuff.thisTurnUpStatChange || e.id == BuffDebuff.thisTurnDownStatChange);
    // フォーカスレンズの効果削除
    buffDebuffs.removeWhere((e) => e.id == BuffDebuff.movedAccuracy1_2);
    // わざの反動で動けない状態は2ターンエンド経過で削除
    hiddenBuffs.removeWhere((e) => e.id == BuffDebuff.recoiling && e.turns >= 2);
  }

  // 状態異常に関する関数群ここから
  bool ailmentsAdd(Ailment ailment, PhaseState state, {bool forceAdd = false}) {
    var indiFields = isMe ? state.getIndiFields(PlayerType.me) : state.getIndiFields(PlayerType.opponent);
    var yourState = state.getPokemonState(playerType.opposite, null);
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
    if (currentAbility.id == 165 && (ailment.id == Ailment.infatuation || ailment.id == Ailment.encore || ailment.id == Ailment.torment ||
        ailment.id == Ailment.disable || ailment.id == Ailment.taunt || ailment.id == Ailment.healBlock)) return false; // アロマベール
    if (currentAbility.id == 166 && isTypeContain(12) && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // フラワーベール
    if (currentAbility.id == 272 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false; // きよめのしお
    if ((currentAbility.id == 39) && (ailment.id == Ailment.flinch)) return false;      // せいしんりょく<-ひるみ
    if ((currentAbility.id == 40) && (ailment.id == Ailment.freeze)) return false;      // マグマのよろい<-こおり
    if ((currentAbility.id == 102) && (state.weather.id == Weather.sunny) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // 晴れ下リーフガード<-状態異常＋ねむけ
    if (currentAbility.id == 213 && (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) return false;    // ぜったいねむり<-状態異常＋ねむけ
    // TODO:リミットシールド
    //if (currentAbility.id == 213) return false;
    if ((ailmentsWhere((e) => e.id == Ailment.uproar).isNotEmpty || state.getPokemonState(playerType.opposite, null).ailmentsWhere((e) => e.id == Ailment.uproar).isNotEmpty) &&
        ailment.id == Ailment.sleep) return false;
    if (state.weather.id == Weather.sunny && holdingItem?.id != Item.bannougasa && ailment.id == Ailment.freeze) return false;
    if (state.field.id == Field.electricTerrain &&
        isGround(indiFields) &&
        ailment.id == Ailment.sleep) return false;
    // 各々の場
    if (indiFields.where((e) => e.id == IndividualField.safeGuard).isNotEmpty && yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isEmpty &&
      (ailment.id <= Ailment.confusion || ailment.id == Ailment.sleepy)) return false; // しんぴのまもり
    if (state.field.id == Field.mistyTerrain) return false;
    // 持続ターン数の変更
    if (holdingItem?.id == 263 && ailment.id == Ailment.partiallyTrapped) ailment.extraArg1 = 7;    // ねばりのかぎづめ＋バインド
    // ダメージの変更
    if (holdingItem?.id == 587 && ailment.id == Ailment.partiallyTrapped) ailment.extraArg1 = 10;    // じめつけバンド＋バインド

    bool isAdded = _ailments.add(ailment);

    // さしおさえの場合
    if (ailment.id == Ailment.embargo) {
      _holdingItem?.clearPassiveEffect(this, clearForm: false);
    }
    // とくせいなしの場合
    if (ailment.id == Ailment.abilityNoEffect) {
      _currentAbility.clearPassiveEffect(this, yourState, isMe, state);
    }

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
    if (yourState.currentAbility.id == 307 && yourState.pokemon.id == 1025 && (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {
      // モモワロウのどくぐくつによってどく/もうどくになった場合、こんらんも併発させる
      ailmentsAdd(Ailment(Ailment.confusion), state, forceAdd: forceAdd);
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

  Ailment ailmentsRemoveAt(int index, {PokemonState? yourState, PhaseState? state}) {
    var ret = _ailments.removeAt(index);
    if (ret.id <= Ailment.sleep && ret.id != 0) {
      if (currentAbility.id == 62) {  // こんじょう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense1_5);
      }
      if (currentAbility.id == 95) {  // はやあし
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
      }
    }
    else if (ret.id == Ailment.confusion) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
      }
    }
    else if (ret.id == Ailment.poison || ret.id == Ailment.badPoison) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physical1_5);
      }
    }
    else if (ret.id == Ailment.burn) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_5);
      }
    }
    else if (ret.id == Ailment.embargo) { // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    }
    else if (ret.id == Ailment.abilityNoEffect) { // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState!, isMe, state!);
    }
    
    return ret;
  }

  void ailmentsRemoveWhere(bool Function(Ailment) test, {PokemonState? yourState, PhaseState? state}) {
    bool embargo = _ailments.where((e) => e.id == Ailment.embargo).isNotEmpty;
    bool abilityNoEffect = _ailments.where((e) => e.id == Ailment.abilityNoEffect).isNotEmpty;
    _ailments.removeWhere(test);
    if (_ailments.indexWhere((e) => e.id <= Ailment.sleep && e.id != 0) < 0) {
      if (currentAbility.id == 62) {  // こんじょう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
      }
      if (currentAbility.id == 63) {  // ふしぎなうろこ
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense1_5);
      }
      if (currentAbility.id == 95) {  // はやあし
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
      }
    }
    if (_ailments.indexWhere((e) => e.id == Ailment.confusion) < 0) {    // こんらん消失時
      if (currentAbility.id == 77) {  // ちどりあし
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
      }
    }
    if (_ailments.indexWhere((e) => e.id == Ailment.poison || e.id == Ailment.badPoison) < 0) {    // どく/もうどく消失時
      if (currentAbility.id == 137) {  // どくぼうそう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physical1_5);
      }
    }
    if (_ailments.indexWhere((e) => e.id == Ailment.burn) < 0) {    // やけど消失時
      if (currentAbility.id == 138) {  // ねつぼうそう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_5);
      }
    }
    if (embargo && _ailments.indexWhere((e) => e.id == Ailment.embargo) < 0) {  // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    }
    if (abilityNoEffect && _ailments.indexWhere((e) => e.id == Ailment.abilityNoEffect) < 0) { // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState!, isMe, state!);
    }
  }

  void ailmentsClear(PokemonState yourState, PhaseState state) {
    bool embargo = _ailments.where((e) => e.id == Ailment.embargo).isNotEmpty;
    bool abilityNoEffect = _ailments.where((e) => e.id == Ailment.abilityNoEffect).isNotEmpty;
    _ailments.clear();
    if (currentAbility.id == 62) {  // こんじょう
        buffDebuffs.removeWhere((e) => e.id == BuffDebuff.attack1_5WithIgnBurn);
    }
    if (currentAbility.id == 63) {  // ふしぎなうろこ
      buffDebuffs.removeWhere((e) => e.id == BuffDebuff.defense1_5);
    }
    if (currentAbility.id == 95) {  // はやあし
      buffDebuffs.removeWhere((e) => e.id == BuffDebuff.speed1_5IgnPara);
    }
    if (currentAbility.id == 77) {  // ちどりあし
      buffDebuffs.removeWhere((e) => e.id == BuffDebuff.yourAccuracy0_5);
    }
    if (currentAbility.id == 137) {  // どくぼうそう
      buffDebuffs.removeWhere((e) => e.id == BuffDebuff.physical1_5);
    }
    if (currentAbility.id == 138) {  // ねつぼうそう
      buffDebuffs.removeWhere((e) => e.id == BuffDebuff.special1_5);
    }
    if (embargo) {  // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    }
    if (abilityNoEffect) { // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState, isMe, state);
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
    if (!isMyEffect && myFields!.where((e) => e.id == IndividualField.mist).isNotEmpty &&
      yourState.buffDebuffs.where((e) => e.id == BuffDebuff.ignoreWall).isEmpty && num < 0) return false;       // しろいきり
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
    if (currentAbility.id == 299 && index == 5 && num < 0) return false;    //しんがん
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

    int before = _statChanges[index];
    _statChanges[index] = (_statChanges[index] + change).clamp(-6, 6);
    if (_statChanges[index] > before && hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.thisTurnUpStatChange) < 0) hiddenBuffs.add(BuffDebuff(BuffDebuff.thisTurnUpStatChange));
    if (_statChanges[index] < before && hiddenBuffs.indexWhere((e) => e.id == BuffDebuff.thisTurnDownStatChange) < 0) hiddenBuffs.add(BuffDebuff(BuffDebuff.thisTurnDownStatChange));
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

  // ランク補正後の実数値を返す
  int getRankedStat(int val, StatIndex statIdx, {bool plusCut = false, bool minusCut = false}) {
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
    return ret.floor();
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

  // ランク補正等込みのHABCDSを返す(※やけど・まひの補正は入ってないので注意)
  int finalizedMaxStat(StatIndex statIdx, PokeType type, PokemonState yourState, PhaseState state, {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return maxStats[StatIndex.H].real;
    }
    return _finalizedStat(maxStats[statIdx].real, statIdx, type, yourState, state, plusCut: plusCut, minusCut: minusCut);
  }
  
  int finalizedMinStat(StatIndex statIdx, PokeType type, PokemonState yourState, PhaseState state, {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return minStats[StatIndex.H].real;
    }
    return _finalizedStat(minStats[statIdx].real, statIdx, type, yourState, state, plusCut: plusCut, minusCut: minusCut);
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
          if (type.id == PokeTypeId.fire && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.flashFired) >= 0) ret *= 1.5;
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
          if (type.id == PokeTypeId.fire && buffDebuffs.indexWhere((e) => e.id == BuffDebuff.flashFired) >= 0) ret *= 1.5;
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
    SixParams.getRealH(pokemon.level, maxStats[StatIndex.H].race, maxStats[StatIndex.H].indi, maxStats[StatIndex.H].effort);
    final temperBiases = Temper.getTemperBias(pokemon.temper);
    for (final stat in StatIndexList.listAtoS) {
      SixParams.getRealABCDS(pokemon.level, maxStats[stat].race, maxStats[stat].indi, maxStats[stat].effort, temperBiases[stat.index-1]);
    }
  }

  // SQLに保存された文字列からPokemonStateをパース
  static PokemonState deserialize(dynamic str, String split1, String split2, String split3, {int version = -1}) {   // -1は最新バージョン
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
    if (version == 1) {
      pokemonState.setCurrentAbilityNoEffect(Ability.deserialize(stateElements[12], split2));
    }
    else {
      pokemonState.setCurrentAbilityNoEffect(pokeData.abilities[int.parse(stateElements[12])]!);
    }
    // ailments
    pokemonState._ailments = Ailments.deserialize(stateElements[13], split2, split3);
    // minStats
    final minStatElements = stateElements[14].split(split2);
    for (final stat in StatIndexList.listHtoS) {
      pokemonState.minStats[stat] = SixParams.deserialize(minStatElements[stat], split3);
    }
    // maxStats
    final maxStatElements = stateElements[15].split(split2);
    for (final stat in StatIndexList.listHtoS) {
      pokemonState.maxStats[stat] = SixParams.deserialize(maxStatElements[stat], split3);
    }
    // possibleAbilities
    final abilities = stateElements[16].split(split2);
    for (var ability in abilities) {
      if (ability == '') break;
      if (version == 1) {
        pokemonState.possibleAbilities.add(Ability.deserialize(ability, split3));
      }
      else {
        pokemonState.possibleAbilities.add(pokeData.abilities[int.parse(ability)]!);
      }
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
    //ret += currentAbility.serialize(split2);    // version==1
    ret += currentAbility.id.toString();
    ret += split1;
    // ailments
    ret += _ailments.serialize(split2, split3);
    ret += split1;
    // minStats
    for (final stat in StatIndexList.listHtoS) {
      ret += minStats[stat].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // maxStats
    for (final stat in StatIndexList.listHtoS) {
      ret += maxStats[stat].serialize(split3);
      ret += split2;
    }
    ret += split1;
    // possibleAbilities
    for (final ability in possibleAbilities) {
      //ret += ability.serialize(split3);     // version==1
      ret += ability.id.toString();
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
