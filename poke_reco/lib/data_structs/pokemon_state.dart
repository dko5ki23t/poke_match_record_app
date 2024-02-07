import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/six_stats.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:poke_reco/tool.dart';

/// ポケモンのstate(状態)を管理するclass
class PokemonState extends Equatable implements Copyable {
  /// ポケモンの所有者
  PlayerType playerType = PlayerType.none;

  /// ポケモン(DBへの保存時はIDだけ)
  Pokemon pokemon = Pokemon();

  /// 残りHP
  int remainHP = 0;

  /// 残りHP割合
  int remainHPPercent = 100;

  /// テラスタルしているかどうか
  bool isTerastaling = false;

  /// テラスタルした場合のタイプ
  PokeType teraType1 = PokeType.unknown;

  /// ひんしかどうか
  bool _isFainting = false;

  /// バトルでの選出順(選出されていなければ0、選出順を気にしない場合は単に0/1)
  int battlingNum = 0;

  /// 持っているもちもの(失えばnullにする)
  Item? _holdingItem = Item.none();

  /// 各わざの消費PP
  List<int> usedPPs = List.generate(4, (index) => 0);

  /// 能力ランク変化[A,B,C,D,S,Ac(命中率),Ev(回避率)]
  List<int> _statChanges = List.generate(7, (i) => 0);

  /// その他の補正(フォルムとか)
  BuffDebuffList buffDebuffs = BuffDebuffList();

  /// 画面上には表示させないその他の補正(わざ「ものまね」の変化後とか)
  BuffDebuffList hiddenBuffs = BuffDebuffList();

  /// 現在のとくせい(バトル中にとくせいが変わることもある)
  Ability _currentAbility = Ability.none();

  /// 状態変化
  Ailments _ailments = Ailments();

  /// 個体値や努力値のあり得る範囲の最小値
  SixStats minStats = SixStats.generateMinStat();

  /// 個体値や努力値のあり得る範囲の最大値
  SixStats maxStats = SixStats.generateMaxStat();

  /// 候補のとくせい
  List<Ability> possibleAbilities = [];

  /// 候補から外れたもちもの(他ポケモンが持ってる等)
  List<Item> impossibleItems = [];

  /// 判明しているわざ
  List<Move> moves = [];

  /// ポケモンのタイプ1(対戦中変わることもある)
  PokeType type1 = PokeType.unknown;

  /// ポケモンのタイプ2
  PokeType? type2;

  /// 最後に使用した(PP消費した)わざ
  Move? lastMove;

  @override
  List<Object?> get props => [
        playerType,
        pokemon,
        remainHP,
        remainHPPercent,
        isTerastaling,
        teraType1,
        _isFainting,
        battlingNum,
        _holdingItem,
        usedPPs,
        _statChanges,
        buffDebuffs,
        hiddenBuffs,
        _currentAbility,
        _ailments,
        minStats,
        maxStats,
        possibleAbilities,
        impossibleItems,
        moves,
        type1,
        type2,
        lastMove,
      ];

  @override
  PokemonState copy() => PokemonState()
    ..playerType = playerType
    ..pokemon = pokemon
    ..remainHP = remainHP
    ..remainHPPercent = remainHPPercent
    ..isTerastaling = isTerastaling
    ..teraType1 = teraType1
    .._isFainting = _isFainting
    ..battlingNum = battlingNum
    .._holdingItem = _holdingItem?.copy()
    ..usedPPs = [...usedPPs]
    .._statChanges = [..._statChanges]
    ..buffDebuffs = buffDebuffs.copy()
    ..hiddenBuffs = hiddenBuffs.copy()
    .._currentAbility = _currentAbility.copy()
    .._ailments = _ailments.copy()
    ..minStats = minStats.copy()
    ..maxStats = maxStats.copy()
    ..possibleAbilities = [for (final e in possibleAbilities) e.copy()]
    ..impossibleItems = [for (final e in impossibleItems) e.copy()]
    ..moves = [...moves]
    ..type1 = type1
    ..type2 = type2
    ..lastMove = lastMove?.copy();

  /// 持っているもちもの(持っていない場合はnull)
  Item? get holdingItem => _holdingItem != null
      ? canUseItem
          ? _holdingItem
          : PokeDB().items[0]
      : null;

  /// 現在のとくせい(バトル中にとくせいが変わることもある)
  Ability get currentAbility =>
      isEffectAbility ? _currentAbility : PokeDB().abilities[0]!;

  /// ひんしかどうか
  bool get isFainting => _isFainting;

  /// おもさ(メタモンはへんしん状態に応じて変化)
  int get weight {
    final trans = buffDebuffs.whereByID(BuffDebuff.transform);
    int no = trans.isNotEmpty ? trans.first.extraArg1 : pokemon.no;
    return PokeDB().pokeBase[no]!.weight;
  }

  /// たかさ(メタモンはへんしん状態に応じて変化)
  int get height {
    final trans = buffDebuffs.whereByID(BuffDebuff.transform);
    int no = trans.isNotEmpty ? trans.first.extraArg1 : pokemon.no;
    return PokeDB().pokeBase[no]!.height;
  }

  /// せいべつ(メタモンはへんしん状態に応じて変化)
  Sex get sex {
    final trans = buffDebuffs.whereByID(BuffDebuff.transform);
    return trans.isNotEmpty ? Sex.createFromId(trans.first.turns) : pokemon.sex;
  }

  /// 所有者はユーザーかどうか
  bool get isMe => playerType == PlayerType.me;

  /// どれか1回でもわざを使用したかどうか
  bool get usedAnyPP => usedPPs.where((element) => element > 0).isNotEmpty;

  /// もちものを使えるかどうか
  bool get canUseItem {
    return ailmentsWhere((e) => e.id == Ailment.embargo).isEmpty &&
        !buffDebuffs.containsByID(BuffDebuff.noItemEffect) &&
        !hiddenBuffs.containsByID(BuffDebuff.magicRoom);
  }

  /// とくせいの効果は発動できる状態にあるか
  bool get isEffectAbility {
    return ailmentsWhere((e) => e.id == Ailment.abilityNoEffect).isEmpty;
  }

  set holdingItem(Item? item) {
    _holdingItem?.clearPassiveEffect(this);
    if (canUseItem) item?.processPassiveEffect(this);
    if (item == null && _holdingItem != null && _holdingItem!.id != 0) {
      // 最後に消費したもちもの/きのみ更新
      final lastLostItem = hiddenBuffs.whereByID(BuffDebuff.lastLostItem);
      if (lastLostItem.isEmpty) {
        hiddenBuffs.add(
            BuffDebuff(BuffDebuff.lastLostItem)..extraArg1 = _holdingItem!.id);
      } else {
        lastLostItem.first.extraArg1 = _holdingItem!.id;
      }
      if (_holdingItem!.isBerry) {
        final lastLostBerry = hiddenBuffs.whereByID(BuffDebuff.lastLostBerry);
        if (lastLostBerry.isEmpty) {
          hiddenBuffs.add(BuffDebuff(BuffDebuff.lastLostBerry)
            ..extraArg1 = _holdingItem!.id);
        } else {
          lastLostBerry.first.extraArg1 = _holdingItem!.id;
        }
      }
    }
    _holdingItem = item;
  }

  /// 「もちものの効果なし」かどうかに関わらずもちもの取得
  Item? getHoldingItem() {
    return _holdingItem;
  }

  /// 「とくせいの効果なし」かどうかに関わらずとくせい取得
  Ability getCurrentAbility() {
    return _currentAbility;
  }

  /// 現在のとくせいをセット
  void setCurrentAbility(
      Ability ability, PokemonState yourState, bool isOwn, PhaseState state) {
    _currentAbility.clearPassiveEffect(this, yourState, isOwn, state);
    if (isEffectAbility) {
      ability.processPassiveEffect(this, yourState, isOwn, state);
    }
    _currentAbility = ability;
    /*if (pokemon.ability.id == 0 && PokeDB().pokeBase[pokemon.no]!.ability.where((e) => e.id == ability.id).isNotEmpty) {
      pokemon.ability = ability;
    }*/
  }

  /// ひんしかどうかをセット(ひんしにする場合、テラスタルは解除される)
  set isFainting(bool t) {
    // テラスタル解除
    if (t) isTerastaling = false;
    _isFainting = t;
  }

  /// 効果等を起こさずもちものをセット
  /// ```
  /// item: もちもの
  /// ```
  void setHoldingItemNoEffect(Item? item) {
    _holdingItem = item;
  }

  /// 効果等を起こさずとくせいをセット
  /// ```
  /// ability: とくせい
  /// ```
  void setCurrentAbilityNoEffect(Ability ability) {
    _currentAbility = ability;
  }

  /// 地面にいるかどうかを返す
  /// ```
  /// fields: このポケモンがいる場
  /// ```
  bool isGround(List<IndividualField> fields) {
    if (ailmentsWhere((e) => e.id == Ailment.ingrain || e.id == Ailment.antiAir)
            .isNotEmpty ||
        fields.where((e) => e.id == IndividualField.gravity).isNotEmpty ||
        holdingItem?.id == 255) {
      return true;
    }
    if (isTypeContain(PokeType.fly) ||
        currentAbility.id == 26 ||
        holdingItem?.id == 584 ||
        ailmentsWhere((e) =>
                e.id == Ailment.magnetRise || e.id == Ailment.telekinesis)
            .isNotEmpty) {
      return false;
    }
    return true;
  }

  /// 相手のこうげきわざ以外でのダメージを受けるかどうか
  bool get isNotAttackedDamaged =>
      !buffDebuffs.containsByID(BuffDebuff.magicGuard);

  /// 交代可能な状態かどうかを返す
  /// ```
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  bool canChange(PokemonState yourState, PhaseState state) {
    var fields = isMe
        ? state.getIndiFields(PlayerType.me)
        : state.getIndiFields(PlayerType.opponent);
    return isTypeContain(PokeType.ghost) || // ゴーストタイプならOK
        holdingItem?.id == 272 || // きれいなぬけがらを持っていればOK
        (fields
                .where((element) => element.id == IndividualField.fairyLock)
                .isEmpty &&
            (ailmentsWhere((e) => e.id == Ailment.cannotRunAway).isEmpty ||
                (ailmentsWhere((e) => e.id == Ailment.cannotRunAway)
                            .first
                            .extraArg1 ==
                        2 &&
                    !isTypeContain(PokeType.steel)) ||
                (ailmentsWhere((e) => e.id == Ailment.cannotRunAway)
                            .first
                            .extraArg1 ==
                        3 &&
                    !isGround(fields))));
  }

  /// きゅうしょランクを加算する
  /// ```
  /// i: 加減値(マイナスもOK)
  /// ```
  void addVitalRank(int i) {
    int findIdx = buffDebuffs.list.indexWhere((element) =>
        BuffDebuff.vital1 <= element.id && element.id <= BuffDebuff.vital3);
    if (findIdx < 0) {
      if (i <= 0) return;
      int vitalRank = (BuffDebuff.vital1 + (i - 1))
          .clamp(BuffDebuff.vital1, BuffDebuff.vital3);
      buffDebuffs.add(BuffDebuff(vitalRank));
    } else {
      int newRank = buffDebuffs.list[findIdx].id + i;
      if (newRank < BuffDebuff.vital1) {
        buffDebuffs.list.removeAt(findIdx);
      } else {
        int vitalRank = (newRank).clamp(BuffDebuff.vital1, BuffDebuff.vital3);
        buffDebuffs.list[findIdx] = BuffDebuff(vitalRank);
      }
    }
  }

  /// 指定したタイプが含まれるか判定(テラスタル後ならテラスタイプで判定)
  /// ```
  /// type: タイプ
  /// ```
  bool isTypeContain(PokeType type) {
    if (isTerastaling && teraType1 != PokeType.stellar) {
      return teraType1 == type;
    } else {
      List<PokeType> types = [type1];
      if (type2 != null) types.add(type2!);
      if (ailmentsWhere((e) => e.id == Ailment.halloween).isNotEmpty) {
        types.add(PokeType.ghost);
      }
      if (ailmentsWhere((e) => e.id == Ailment.forestCurse).isNotEmpty) {
        types.add(PokeType.grass);
      }
      return types.contains(type);
    }
  }

  /// ダメージ計算におけるタイプ一致ボーナスを返す
  /// ```
  /// moveType: わざのタイプ
  /// isAdaptability: てきおうりょくかどうか
  /// ```
  double typeBonusRate(PokeType moveType, bool isAdaptability) {
    double rate = 1.0;
    if (isTerastaling) {
      if (teraType1 == PokeType.stellar) {
        // ステラタイプ
        if (canGetStellarHosei(moveType)) {
          if (isTypeContain(moveType)) {
            rate += 1.0;
          } else {
            rate += 0.2;
          }
        } else {
          if (isTypeContain(moveType)) {
            rate += 0.5;
          }
        }
      } else {
        // その他のタイプ
        if (isAdaptability) {
          if (teraType1 == moveType) {
            rate += 1.0;
          }
          if (type1 == moveType || (type2 != null && type2! == moveType)) {
            rate += 0.5;
          }
          if (rate > 2.25) rate = 2.25;
        } else {
          if (teraType1 == moveType) {
            rate += 0.5;
          }
          if (type1 == moveType || (type2 != null && type2! == moveType)) {
            rate += 0.5;
          }
        }
      }
    } else {
      if (isTypeContain(moveType)) {
        rate += 0.5;
        if (isAdaptability) rate += 0.5;
      }
    }

    return rate;
  }

  /// テラスタル補正を受けるかどうかを返す
  /// ```
  /// type: わざのタイプ
  /// ```
  bool canGetTerastalHosei(PokeType type) {
    if (!isTerastaling || teraType1 == PokeType.stellar) return false; // 前提
    if (teraType1 == type) return true;
    return false;
  }

  /// テラスステラ補正を受けるかどうかを返す
  /// ```
  /// type: わざのタイプ
  /// ```
  bool canGetStellarHosei(PokeType type) {
    if (!isTerastaling || teraType1 != PokeType.stellar) return false; // 前提
    final founds = hiddenBuffs.whereByID(BuffDebuff.stellarUsed);
    if (pokemon.no == 1024 || founds.isEmpty) return true;
    if (founds.first.extraArg1 & (1 << (type.index - 1)) != 0) {
      return false; // すでに使ったことがあるタイプ
    }
    return true;
  }

  /// テラスステラ補正使用状態を更新する
  /// ```
  /// type: わざのタイプ
  /// ```
  void addStellarUsed(PokeType type) {
    if (!isTerastaling || teraType1 != PokeType.stellar || pokemon.no == 1024) {
      return; // 前提
    }
    final findIdx = hiddenBuffs.list
        .indexWhere((element) => element.id == BuffDebuff.stellarUsed);
    if (findIdx < 0) {
      hiddenBuffs.add(BuffDebuff(BuffDebuff.stellarUsed)
        ..extraArg1 = 1 << (type.index - 1));
    } else {
      hiddenBuffs.list[findIdx].extraArg1 |= 1 << (type.index - 1);
    }
  }

  /// すなあらしダメージを受けるか判定
  bool isSandstormDamaged() {
    if (isTypeContain(PokeType.ground) ||
        isTypeContain(PokeType.rock) ||
        isTypeContain(PokeType.steel)) return false;
    if (holdingItem?.id == 690) return false; // ぼうじんゴーグル
    if (currentAbility.id == 146 ||
        currentAbility.id == 8 || // すなかき/すながくれ
        currentAbility.id == 159 ||
        currentAbility.id == 98 || // すなのちから/マジックガード
        currentAbility.id == 142) return false; // ぼうじん
    if (ailmentsWhere(// あなをほる/ダイビング状態
        (e) => e.id == Ailment.digging || e.id == Ailment.diving).isNotEmpty) {
      return false;
    }
    return true;
  }

  /// ポケモン交代やひんしにより退場する場合の処理を行う
  /// ```
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  void processExitEffect(PokemonState yourState, PhaseState state) {
    bool isOwn = playerType == PlayerType.me;
    resetStatChanges();
    resetRealSixParams();
    setCurrentAbilityNoEffect(pokemon.ability);
    type1 = pokemon.type1;
    type2 = pokemon.type2;
    ailmentsRemoveWhere((e) => e.id > Ailment.sleep); // 状態変化の回復
    // もうどくはターン数をリセット(ターン数をもとにダメージを計算するため)
    var badPoison = ailmentsWhere((e) => e.id == Ailment.badPoison);
    if (badPoison.isNotEmpty) badPoison.first.turns = 0;
    if (_isFainting) ailmentsClear(yourState, state);
    // 退場後も継続するフォルム以外をクリア
    final unchangingForms = buffDebuffs.whereByAnyID([
      BuffDebuff.iceFace,
      BuffDebuff.niceFace,
      BuffDebuff.manpukuForm,
      BuffDebuff.harapekoForm,
      BuffDebuff.transedForm,
      BuffDebuff.revealedForm,
      BuffDebuff.naiveForm,
      BuffDebuff.mightyForm,
      BuffDebuff.terastalForm,
      BuffDebuff.stellarForm,
    ]).toList();
    buffDebuffs.clear();
    buffDebuffs.addAll(unchangingForms);
    final unchangingHidden = hiddenBuffs.whereByAnyID([
      BuffDebuff.lastLostItem,
      BuffDebuff.lastLostBerry,
      BuffDebuff.attackedCount,
      BuffDebuff.zoroappear,
      BuffDebuff.stellarUsed,
    ]).toList();
    hiddenBuffs.clear();
    hiddenBuffs.addAll(unchangingHidden);
    // ひんしでない退場で発動するフォルムチェンジ
    if (!isFainting) {
      final findIdx = buffDebuffs.list
          .indexWhere((element) => element.id == BuffDebuff.naiveForm);
      if (findIdx >= 0) {
        buffDebuffs.list[findIdx] =
            BuffDebuff(BuffDebuff.mightyForm); // マイティフォルム
        // TODO この2行csvに移したい
        maxStats.a.race = 160;
        maxStats.b.race = 97;
        maxStats.c.race = 106;
        maxStats.d.race = 87;
        minStats.a.race = 160;
        minStats.b.race = 97;
        minStats.c.race = 106;
        minStats.d.race = 87;
        for (final stat in [
          StatIndex.A,
          StatIndex.B,
          StatIndex.C,
          StatIndex.D
        ]) {
          maxStats[stat].updateReal(pokemon.level, pokemon.temper);
          minStats[stat].updateReal(pokemon.level, pokemon.temper);
        }
      }
    }
    // あいてのロックオン状態解除
    yourState.ailmentsRemoveWhere((e) => e.id == Ailment.lockOn);
    // 場にいると両者にバフ/デバフがかかる場合
    if (currentAbility.id == 186 && yourState.currentAbility.id != 186) {
      // ダークオーラ
      yourState.buffDebuffs.removeAllByAllID([
        BuffDebuff.darkAura,
        BuffDebuff.antiDarkAura,
      ]);
    }
    if (currentAbility.id == 187 && yourState.currentAbility.id == 187) {
      // フェアリーオーラ
      yourState.buffDebuffs.removeAllByAllID([
        BuffDebuff.fairyAura,
        BuffDebuff.antiFairyAura,
      ]);
    }
    // 場にいると相手にバフ/デバフがかかる場合
    if (currentAbility.id == 284) {
      // わざわいのうつわ
      yourState.buffDebuffs.removeAllByID(BuffDebuff.specialAttack0_75);
    }
    if (currentAbility.id == 285) {
      // わざわいのつるぎ
      yourState.buffDebuffs.removeAllByID(BuffDebuff.defense0_75);
    }
    if (currentAbility.id == 286) {
      // わざわいのおふだ
      yourState.buffDebuffs.removeAllByID(BuffDebuff.attack0_75);
    }
    if (currentAbility.id == 287) {
      // わざわいのたま
      yourState.buffDebuffs.removeAllByID(BuffDebuff.specialDefense0_75);
    }
    // あいてのにげられない状態の解除
    yourState.ailmentsRemoveWhere(
        (e) => e.id == Ailment.cannotRunAway && e.extraArg1 == 1);
    // 退場することで自身に効果がある場合
    if (!_isFainting && currentAbility.id == 30) {
      // しぜんかいふく
      ailmentsClear(yourState, state);
    }
    if (!_isFainting && currentAbility.id == 144) {
      // さいせいりょく
      if (isOwn) {
        remainHP += (pokemon.h.real / 3).floor();
      } else {
        remainHPPercent += 33;
      }
    }
    // 最後に退場した状態の保存
    state.lastExitedStates[isMe ? 0 : 1]
        [state.getPokemonIndex(playerType, null) - 1] = copy();
  }

  /// ポケモン交代や死に出しにより登場する場合の処理を行う
  /// ```
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  void processEnterEffect(PokemonState yourState, PhaseState state) {
    bool isOwn = playerType == PlayerType.me;
    if (battlingNum < 1) battlingNum = 1;
    setCurrentAbilityNoEffect(pokemon.ability);
    processPassiveEffect(yourState, state); // パッシブ効果
    Weather.processWeatherEffect(Weather(0), state.weather, isOwn ? this : null,
        isOwn ? null : this); // 天気の影響
    Field.processFieldEffect(Field(0), state.field, isOwn ? this : null,
        isOwn ? null : this); // フィールドの影響
  }

  /// ポケモンのとくせい/もちもの等で常に働く効果を付与する。ポケモン登場時に一度だけ呼ぶ
  /// ```
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  void processPassiveEffect(PokemonState yourState, PhaseState state) {
    // ポケモン固有のフォルム等
    if (pokemon.no == 648) {
      // メロエッタ
      buffDebuffs.add(BuffDebuff(BuffDebuff.voiceForm));
    }

    // とくせいの効果を反映
    currentAbility.processPassiveEffect(
        this, yourState, playerType == PlayerType.me, state);

    // もちものの効果を反映
    holdingItem?.processPassiveEffect(this);

    // 地面にいるどくポケモンによるどくびし/どくどくびしの消去
    var indiField = playerType == PlayerType.me
        ? state.getIndiFields(PlayerType.me)
        : state.getIndiFields(PlayerType.opponent);
    if (isGround(indiField) && isTypeContain(PokeType.poison)) {
      indiField.removeWhere((e) => e.id == IndividualField.toxicSpikes);
    }
  }

  /// ターン終了時の処理を行う
  /// ```
  /// state: フェーズの状態
  /// isFaintingChange: ひんしによる交代があったかどうか(状態変化の経過ターンに影響する)
  /// ```
  void processTurnEnd(
    PhaseState state,
    bool isFaintingChange,
  ) {
    // 状態変化の経過ターンインクリメント
    if (!isFaintingChange) {
      for (var e in _ailments.iterable) {
        if (e.id != Ailment.sleep) {
          // ねむりのターン経過は行動時のみ
          e.turns++;
        }
      }
    }
    // ちゅうもくのまと/まもる状態/そうでんは解除
    ailmentsRemoveWhere((e) =>
        e.id == Ailment.attention ||
        e.id == Ailment.protect ||
        e.id == Ailment.electrify);
    // はねやすめ解除＆ひこうタイプ復活
    var findIdx = ailmentsIndexWhere((e) => e.id == Ailment.roost);
    if (findIdx >= 0) {
      if (ailments(findIdx).extraArg1 == 1) type1 = PokeType.fly;
      if (ailments(findIdx).extraArg1 == 2) type2 = PokeType.fly;
      if (ailments(findIdx).extraArg1 == 3) {
        type2 = type1; // TODO:コピーされる？
        type1 = PokeType.fly;
      }
      ailmentsRemoveAt(findIdx);
    }
    // その他の補正の経過ターンインクリメント
    for (var e in buffDebuffs.list) {
      e.turns++;
    }
    // 隠れ補正の経過ターンインクリメント
    for (var e in hiddenBuffs.list) {
      e.turns++;
    }
    // スロースタート終了
    buffDebuffs.list
        .removeWhere((e) => e.id == BuffDebuff.attackSpeed0_5 && e.turns >= 5);
    // 交代したターンであることのフラグ削除
    // 当ターンでランクが変わったかを示すフラグ削除
    hiddenBuffs.removeAllByAllID([
      BuffDebuff.changedThisTurn,
      BuffDebuff.thisTurnUpStatChange,
      BuffDebuff.thisTurnDownStatChange,
    ]);
    // フォーカスレンズの効果削除
    buffDebuffs.removeAllByID(BuffDebuff.movedAccuracy1_2);
    // わざの反動で動けない状態は2ターンエンド経過で削除
    hiddenBuffs.list
        .removeWhere((e) => e.id == BuffDebuff.recoiling && e.turns >= 2);
  }

  // 状態変化に関する関数群ここから
  /// 状態変化を追加する
  /// ```
  /// ailment: 追加する状態変化
  /// state: フェーズの状態
  /// forceAdd: 強制的に追加する
  /// ```
  bool ailmentsAdd(Ailment ailment, PhaseState state, {bool forceAdd = false}) {
    var indiFields = isMe
        ? state.getIndiFields(PlayerType.me)
        : state.getIndiFields(PlayerType.opponent);
    var yourState = state.getPokemonState(playerType.opposite, null);
    // すでに同じものになっている場合は何も起こらない
    if (_ailments.where((e) => e.id == ailment.id).isNotEmpty) return false;
    // タイプによる耐性
    if ((isTypeContain(PokeType.steel) || isTypeContain(PokeType.poison)) &&
            (ailment.id == Ailment.poison ||
                (!forceAdd &&
                    ailment.id ==
                        Ailment.badPoison)) // もうどくに関しては、わざ使用者のとくせいがふしょくなら可能
        ) return false;
    if (isTypeContain(PokeType.fire) && ailment.id == Ailment.burn) {
      return false;
    }
    if (isTypeContain(PokeType.ice) && ailment.id == Ailment.freeze) {
      return false;
    }
    if (isTypeContain(PokeType.electric) && ailment.id == Ailment.paralysis) {
      return false;
    }
    // とくせいによる耐性
    if ((currentAbility.id == 17 || currentAbility.id == 257) &&
        (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {
      return false;
    }
    if ((currentAbility.id == 7) && (ailment.id == Ailment.paralysis)) {
      return false;
    }
    if ((currentAbility.id == 41 ||
            currentAbility.id == 199 ||
            currentAbility.id == 270) &&
        (ailment.id == Ailment.burn)) return false; // みずのベール/ねつこうかん<-やけど
    if (currentAbility.id == 15 &&
        (ailment.id == Ailment.sleep || ailment.id == Ailment.sleepy)) {
      // ふみん
      return false;
    }
    if (currentAbility.id == 165 &&
        (ailment.id == Ailment.infatuation ||
            ailment.id == Ailment.encore ||
            ailment.id == Ailment.torment ||
            ailment.id == Ailment.disable ||
            ailment.id == Ailment.taunt ||
            ailment.id == Ailment.healBlock)) return false; // アロマベール
    if (currentAbility.id == 166 &&
        isTypeContain(PokeType.grass) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) {
      // フラワーベール
      return false;
    }
    if (currentAbility.id == 272 &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) {
      // きよめのしお
      return false;
    }
    if ((currentAbility.id == 39) && (ailment.id == Ailment.flinch)) {
      // せいしんりょく<-ひるみ
      return false;
    }
    if ((currentAbility.id == 40) && (ailment.id == Ailment.freeze)) {
      // マグマのよろい<-こおり
      return false;
    }
    if ((currentAbility.id == 102) &&
        (state.weather.id == Weather.sunny) &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) {
      // 晴れ下リーフガード<-状態異常＋ねむけ
      return false;
    }
    if (currentAbility.id == 213 &&
        (ailment.id <= Ailment.sleep || ailment.id == Ailment.sleepy)) {
      // ぜったいねむり<-状態異常＋ねむけ
      return false;
    }
    // TODO:リミットシールド
    //if (currentAbility.id == 213) return false;
    if ((ailmentsWhere((e) => e.id == Ailment.uproar).isNotEmpty ||
            state
                .getPokemonState(playerType.opposite, null)
                .ailmentsWhere((e) => e.id == Ailment.uproar)
                .isNotEmpty) &&
        ailment.id == Ailment.sleep) return false;
    if (state.weather.id == Weather.sunny &&
        holdingItem?.id != Item.bannougasa &&
        ailment.id == Ailment.freeze) return false;
    if (state.field.id == Field.electricTerrain &&
        isGround(indiFields) &&
        ailment.id == Ailment.sleep) return false;
    // 各々の場
    if (indiFields.where((e) => e.id == IndividualField.safeGuard).isNotEmpty &&
        !yourState.buffDebuffs.containsByID(BuffDebuff.ignoreWall) &&
        (ailment.id <= Ailment.confusion || ailment.id == Ailment.sleepy)) {
      // しんぴのまもり
      return false;
    }
    if (state.field.id == Field.mistyTerrain) return false;
    // 持続ターン数の変更
    if (holdingItem?.id == 263 && ailment.id == Ailment.partiallyTrapped) {
      // ねばりのかぎづめ＋バインド
      ailment.extraArg1 = 7;
    }
    // ダメージの変更
    if (holdingItem?.id == 587 && ailment.id == Ailment.partiallyTrapped) {
      // じめつけバンド＋バインド
      ailment.extraArg1 = 10;
    }

    bool isAdded = _ailments.add(ailment);

    // さしおさえの場合
    if (ailment.id == Ailment.embargo) {
      _holdingItem?.clearPassiveEffect(this, clearForm: false);
    }
    // とくせいなしの場合
    if (ailment.id == Ailment.abilityNoEffect) {
      _currentAbility.clearPassiveEffect(this, yourState, isMe, state);
    }

    if (isAdded && ailment.id <= Ailment.sleep && ailment.id != 0) {
      // 状態異常時
      if (currentAbility.id == 62) {
        // こんじょう
        buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_5WithIgnBurn));
      }
      if (currentAbility.id == 63) {
        // ふしぎなうろこ
        buffDebuffs.add(BuffDebuff(BuffDebuff.defense1_5));
      }
      if (currentAbility.id == 95) {
        // はやあし
        buffDebuffs.add(BuffDebuff(BuffDebuff.speed1_5IgnPara));
      }
    } else if (isAdded && ailment.id == Ailment.confusion) {
      // こんらん時
      if (currentAbility.id == 77) {
        // ちどりあし
        buffDebuffs.add(BuffDebuff(BuffDebuff.yourAccuracy0_5));
      }
    } else if (isAdded &&
        (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {
      // どく/もうどく時
      if (currentAbility.id == 137) {
        // どくぼうそう
        buffDebuffs.add(BuffDebuff(BuffDebuff.physical1_5));
      }
    } else if (isAdded && ailment.id == Ailment.burn) {
      // やけど時
      if (currentAbility.id == 138) {
        // ねつぼうそう
        buffDebuffs.add(BuffDebuff(BuffDebuff.special1_5));
      }
    }
    if (yourState.currentAbility.id == 307 &&
        yourState.pokemon.id == 1025 &&
        (ailment.id == Ailment.poison || ailment.id == Ailment.badPoison)) {
      // モモワロウのどくぐくつによってどく/もうどくになった場合、こんらんも併発させる
      ailmentsAdd(Ailment(Ailment.confusion), state, forceAdd: forceAdd);
    }
    return true;
  }

  /// 状態変化数
  int get ailmentsLength => _ailments.length;

  /// 状態変化のIterable
  Iterable<Ailment> get ailmentsIterable => _ailments.iterable;

  /// 状態変化のi番目
  Ailment ailments(int i) => _ailments[i];

  /// 条件に合致する状態変化を返す
  /// ```
  /// test: 条件
  /// ```
  Iterable<Ailment> ailmentsWhere(bool Function(Ailment) test) {
    return _ailments.where(test);
  }

  /// 条件に合致する最初の状態変化のインデックスを返す
  /// ```
  /// test: 条件
  /// ```
  int ailmentsIndexWhere(bool Function(Ailment) test) {
    return _ailments.indexWhere(test);
  }

  /// 指定インデックスの状態変化を削除する
  /// ```
  /// index: インデックス
  /// yourState: 相手のポケモンの状態(※削除対象がとくせいなしの場合は必須)
  /// state: フェーズの状態(※削除対象がとくせいなしの場合は必須)
  /// ```
  Ailment ailmentsRemoveAt(int index,
      {PokemonState? yourState, PhaseState? state}) {
    var ret = _ailments.removeAt(index);
    if (ret.id <= Ailment.sleep && ret.id != 0) {
      if (currentAbility.id == 62) {
        // こんじょう
        buffDebuffs.removeAllByID(BuffDebuff.attack1_5WithIgnBurn);
      }
      if (currentAbility.id == 63) {
        // ふしぎなうろこ
        buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
      }
      if (currentAbility.id == 95) {
        // はやあし
        buffDebuffs.removeAllByID(BuffDebuff.speed1_5IgnPara);
      }
    } else if (ret.id == Ailment.confusion) {
      // こんらん消失時
      if (currentAbility.id == 77) {
        // ちどりあし
        buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_5);
      }
    } else if (ret.id == Ailment.poison || ret.id == Ailment.badPoison) {
      // どく/もうどく消失時
      if (currentAbility.id == 137) {
        // どくぼうそう
        buffDebuffs.removeAllByID(BuffDebuff.physical1_5);
      }
    } else if (ret.id == Ailment.burn) {
      // やけど消失時
      if (currentAbility.id == 138) {
        // ねつぼうそう
        buffDebuffs.removeAllByID(BuffDebuff.special1_5);
      }
    } else if (ret.id == Ailment.embargo) {
      // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    } else if (ret.id == Ailment.abilityNoEffect) {
      // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState!, isMe, state!);
    }

    return ret;
  }

  /// 条件に合う状態変化を削除する
  /// ```
  /// test: 条件
  /// yourState: 相手のポケモンの状態(※削除対象がとくせいなしの場合は必須)
  /// state: フェーズの状態(※削除対象がとくせいなしの場合は必須)
  /// ```
  void ailmentsRemoveWhere(bool Function(Ailment) test,
      {PokemonState? yourState, PhaseState? state}) {
    bool embargo = _ailments.where((e) => e.id == Ailment.embargo).isNotEmpty;
    bool abilityNoEffect =
        _ailments.where((e) => e.id == Ailment.abilityNoEffect).isNotEmpty;
    _ailments.removeWhere(test);
    if (_ailments.indexWhere((e) => e.id <= Ailment.sleep && e.id != 0) < 0) {
      if (currentAbility.id == 62) {
        // こんじょう
        buffDebuffs.removeAllByID(BuffDebuff.attack1_5WithIgnBurn);
      }
      if (currentAbility.id == 63) {
        // ふしぎなうろこ
        buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
      }
      if (currentAbility.id == 95) {
        // はやあし
        buffDebuffs.removeAllByID(BuffDebuff.speed1_5IgnPara);
      }
    }
    if (_ailments.indexWhere((e) => e.id == Ailment.confusion) < 0) {
      // こんらん消失時
      if (currentAbility.id == 77) {
        // ちどりあし
        buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_5);
      }
    }
    if (_ailments.indexWhere(
            (e) => e.id == Ailment.poison || e.id == Ailment.badPoison) <
        0) {
      // どく/もうどく消失時
      if (currentAbility.id == 137) {
        // どくぼうそう
        buffDebuffs.removeAllByID(BuffDebuff.physical1_5);
      }
    }
    if (_ailments.indexWhere((e) => e.id == Ailment.burn) < 0) {
      // やけど消失時
      if (currentAbility.id == 138) {
        // ねつぼうそう
        buffDebuffs.removeAllByID(BuffDebuff.special1_5);
      }
    }
    if (embargo && _ailments.indexWhere((e) => e.id == Ailment.embargo) < 0) {
      // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    }
    if (abilityNoEffect &&
        _ailments.indexWhere((e) => e.id == Ailment.abilityNoEffect) < 0) {
      // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState!, isMe, state!);
    }
  }

  /// すべての状態変化を削除する
  /// ```
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// ```
  void ailmentsClear(PokemonState yourState, PhaseState state) {
    bool embargo = _ailments.where((e) => e.id == Ailment.embargo).isNotEmpty;
    bool abilityNoEffect =
        _ailments.where((e) => e.id == Ailment.abilityNoEffect).isNotEmpty;
    _ailments.clear();
    if (currentAbility.id == 62) {
      // こんじょう
      buffDebuffs.removeAllByID(BuffDebuff.attack1_5WithIgnBurn);
    }
    if (currentAbility.id == 63) {
      // ふしぎなうろこ
      buffDebuffs.removeAllByID(BuffDebuff.defense1_5);
    }
    if (currentAbility.id == 95) {
      // はやあし
      buffDebuffs.removeAllByID(BuffDebuff.speed1_5IgnPara);
    }
    if (currentAbility.id == 77) {
      // ちどりあし
      buffDebuffs.removeAllByID(BuffDebuff.yourAccuracy0_5);
    }
    if (currentAbility.id == 137) {
      // どくぼうそう
      buffDebuffs.removeAllByID(BuffDebuff.physical1_5);
    }
    if (currentAbility.id == 138) {
      // ねつぼうそう
      buffDebuffs.removeAllByID(BuffDebuff.special1_5);
    }
    if (embargo) {
      // さしおさえ消失時
      _holdingItem?.processPassiveEffect(this, processForm: false);
    }
    if (abilityNoEffect) {
      // とくせいなし消失時
      _currentAbility.processPassiveEffect(this, yourState, isMe, state);
    }
  }
  // 状態異常に関する関数群ここまで

  // ランク変化に関する関数群ここから
  /// 能力ランク変化[A,B,C,D,S,Ac(命中率),Ev(回避率)]からインデックスを指定して取得
  int statChanges(int i) => _statChanges[i];

  /// 能力ランク変化を、引数で指定した値に設定する。とくせいの効果等に影響されない変化をさせたいときに使う
  /// ```
  /// index: 能力ランクのインデックス
  /// num: 変化値(-6 ~ +6)
  /// ```
  void forceSetStatChanges(
    int index,
    int num,
  ) {
    _statChanges[index] = num;
    if (_statChanges[index] < -6) _statChanges[index] = -6;
    if (_statChanges[index] > 6) _statChanges[index] = 6;
  }

  /// とくせい等によって変化できなかった場合はfalseが返る
  /// ```
  /// isMyEffect: 自身のわざやとくせい等で起こった変化かどうか
  /// index: 能力ランクのインデックス
  /// delta: 変化量
  /// yourState: 相手のポケモンの状態
  /// moveId: この変化を起こしたわざのID
  /// abilityId: この変化を起こしたとくせいのID
  /// itemId: この変化を起こしたもちもののID
  /// lastMirror: 跳ね返しはもう起きないかどうか(この関数の使用者は考えなくてよい)
  /// myFields: 自身の場
  /// yourFields: 相手の場
  /// ```
  bool addStatChanges(
    bool isMyEffect,
    int index,
    int delta,
    PokemonState yourState, {
    int? moveId,
    int? abilityId,
    int? itemId,
    bool lastMirror = false,
    List<IndividualField>? myFields,
    List<IndividualField>? yourFields,
  }) {
    int change = delta;
    if (!isMyEffect &&
        buffDebuffs.containsByID(BuffDebuff.substitute) &&
        delta < 0) return false; // みがわり
    if (!isMyEffect &&
        myFields!.where((e) => e.id == IndividualField.mist).isNotEmpty &&
        !yourState.buffDebuffs.containsByID(BuffDebuff.ignoreWall) &&
        delta < 0) return false; // しろいきり
    if (!isMyEffect && holdingItem?.id == 1698 && delta < 0) {
      // クリアチャーム
      return false;
    }
    if (!isMyEffect && currentAbility.id == 12 && moveId == 445) {
      // どんかん
      return false;
    }
    if (!isMyEffect &&
        abilityId == 22 && // いかくに対する
        (currentAbility.id == 12 ||
            currentAbility.id == 20 ||
            currentAbility.id == 39 || // どんかん/マイペース/せいしんりょく
            currentAbility.id == 113)) return false; // きもったま
    if (!isMyEffect && currentAbility.id == 20 && abilityId == 22) {
      // マイペース
      return false;
    }
    if (!isMyEffect &&
        (currentAbility.id == 29 ||
            currentAbility.id == 73 ||
            currentAbility.id == 230) &&
        delta < 0) return false; // クリアボディ/しろいけむり/メタルプロテクト
    if (!isMyEffect &&
        (currentAbility.id == 35 || currentAbility.id == 51) &&
        index == 5 &&
        delta < 0) return false; // はっこう/するどいめ
    if (!isMyEffect && currentAbility.id == 52 && index == 0 && delta < 0) {
      // かいりきバサミ
      return false;
    }
    if (!isMyEffect && currentAbility.id == 145 && index == 1 && delta < 0) {
      // はとむね
      return false;
    }
    if (!isMyEffect &&
        currentAbility.id == 166 &&
        isTypeContain(PokeType.grass) &&
        delta < 0) {
      // フラワーベール
      return false;
    }
    if (currentAbility.id == 299 && index == 5 && delta < 0) {
      // しんがん
      return false;
    }
    if (!isMyEffect && currentAbility.id == 240 && delta < 0 && !lastMirror) {
      // ミラーアーマー
      yourState.addStatChanges(isMyEffect, index, delta, this,
          myFields: yourFields, yourFields: myFields, lastMirror: true);
      return false;
    }
    if (!isMyEffect && abilityId == 22 && currentAbility.id == 275) {
      // いかくに対するばんけん
      change = 1;
    }

    if (currentAbility.id == 86) change *= 2; // たんじゅん
    if (currentAbility.id == 126) change *= -1; // あまのじゃく
    if (!isMyEffect && currentAbility.id == 128 && delta < 0) {
      // まけんき
      _statChanges[0] = (_statChanges[0] + 2).clamp(-6, 6);
    }

    int before = _statChanges[index];
    _statChanges[index] = (_statChanges[index] + change).clamp(-6, 6);
    if (_statChanges[index] > before &&
        !hiddenBuffs.containsByID(BuffDebuff.thisTurnUpStatChange)) {
      hiddenBuffs.add(BuffDebuff(BuffDebuff.thisTurnUpStatChange));
    }
    if (_statChanges[index] < before &&
        !hiddenBuffs.containsByID(BuffDebuff.thisTurnDownStatChange)) {
      hiddenBuffs.add(BuffDebuff(BuffDebuff.thisTurnDownStatChange));
    }
    return true;
  }

  /// 能力ランク変化をすべて0にリセットする
  void resetStatChanges() => _statChanges = List.generate(7, (index) => 0);

  /// 下がった能力ランク変化をすべて0に戻す(上がった変化はそのまま)
  void resetDownedStatChanges() {
    for (int i = 0; i < 7; i++) {
      if (_statChanges[i] < 0) _statChanges[i] = 0;
    }
  }

  /// 7つの能力ランク変化をintに詰める
  /// ```
  /// statChanges: 能力ランク変化
  /// ```
  static int packStatChanges(List<int> statChanges) {
    int ret = 0;
    for (int i = 0; i < statChanges.length && i < 7; i++) {
      int t = (statChanges[i] + 6).clamp(0, 12);
      ret <<= 4;
      ret += t;
    }
    return ret;
  }

  /// intから7つの能力ランク変化に展開する
  /// ```
  /// statChanges: 能力ランク変化のint表現
  /// ```
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

  /// ランク補正後の実数値を返す
  /// ```
  /// val: ランク補正前の実数値
  /// statIdx: ステータスのインデックス
  /// plusCut: ランク上昇分を無視するかどうか
  /// minusCut: ランク下降分を無視するかどうか
  /// ```
  int getRankedStat(int val, StatIndex statIdx,
      {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return val;
    }
    double ret = val.toDouble();
    // ランク補正
    switch (statChanges(statIdx.index - 1)) {
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

  /// ランク補正後の実数値から、ランク補正なしの実数値を計算してその値を返す
  /// ```
  /// statIdx: ステータスのインデックス
  /// stat: ランク補正後の実数値
  /// ```
  int getNotRankedStat(StatIndex statIdx, int stat) {
    if (statIdx == StatIndex.H) {
      return stat;
    }
    double coef = 1.0;
    switch (statChanges(statIdx.index - 1)) {
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
    if ((ret.toDouble() * coef).floor() < stat) {
      ret++;
    } else if ((ret.toDouble() * coef).floor() > stat) {
      ret--;
    }
    return ret;
  }

  // ランク変化に関する関数群ここまで

  /// ランク補正等込みのHABCDS実数値(最大値)を返す(※やけど・まひの補正は入ってないので注意)
  /// ```
  /// statIdx: ステータスのインデックス
  /// type: こうげき側(自分)わざのタイプ
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// plusCut: ランク上昇分を無視するかどうか
  /// minusCut: ランク下降分を無視するかどうか
  /// ```
  int finalizedMaxStat(StatIndex statIdx, PokeType type, PokemonState yourState,
      PhaseState state,
      {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return maxStats[StatIndex.H].real;
    }
    return _finalizedStat(
        maxStats[statIdx].real, statIdx, type, yourState, state,
        plusCut: plusCut, minusCut: minusCut);
  }

  /// ランク補正等込みのHABCDS実数値(最小値)を返す(※やけど・まひの補正は入ってないので注意)
  /// ```
  /// statIdx: ステータスのインデックス
  /// type: こうげき側(自分)わざのタイプ
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// plusCut: ランク上昇分を無視するかどうか
  /// minusCut: ランク下降分を無視するかどうか
  /// ```
  int finalizedMinStat(StatIndex statIdx, PokeType type, PokemonState yourState,
      PhaseState state,
      {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return minStats[StatIndex.H].real;
    }
    return _finalizedStat(
        minStats[statIdx].real, statIdx, type, yourState, state,
        plusCut: plusCut, minusCut: minusCut);
  }

  /// ランク補正等込みのHABCDS実数値を返す(※やけど・まひの補正は入ってないので注意)
  /// ```
  /// val: 補正前の実数値
  /// statIdx: ステータスのインデックス
  /// type: こうげき側(自分)わざのタイプ
  /// yourState: 相手のポケモンの状態
  /// state: フェーズの状態
  /// plusCut: ランク上昇分を無視するかどうか
  /// minusCut: ランク下降分を無視するかどうか
  /// ```
  int _finalizedStat(int val, StatIndex statIdx, PokeType type,
      PokemonState yourState, PhaseState state,
      {bool plusCut = false, bool minusCut = false}) {
    if (statIdx == StatIndex.H) {
      return val;
    }
    double ret = val.toDouble();
    // ランク補正
    switch (statChanges(statIdx.index - 1)) {
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
          if (buffDebuffs.containsByID(BuffDebuff.attack1_3)) ret *= 1.3;
          if (buffDebuffs.containsByID(BuffDebuff.attack2)) ret *= 2;
          if (buffDebuffs.containsByID(BuffDebuff.attack1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.attack1_5WithIgnBurn)) {
            ret *= 1.5;
          }
          if (buffDebuffs.containsByID(BuffDebuff.attackSpeed0_5)) ret *= 0.5;
          if (buffDebuffs.containsByID(BuffDebuff.defeatist)) ret *= 0.5;
          if (type == PokeType.fire &&
              yourState.buffDebuffs.containsByID(BuffDebuff.waterBubble1)) {
            ret *= 0.5;
          }
          if (type == PokeType.water &&
              buffDebuffs.containsByID(BuffDebuff.waterBubble2)) ret *= 2;
          if (type == PokeType.steel &&
              buffDebuffs.containsByID(BuffDebuff.steelWorker)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.gorimuchu)) ret *= 1.5;
          if (type == PokeType.electric &&
              buffDebuffs.containsByID(BuffDebuff.electric1_3)) ret *= 1.3;
          if (type == PokeType.dragon &&
              buffDebuffs.containsByID(BuffDebuff.dragon1_5)) ret *= 1.5;
          if (type == PokeType.ghost &&
              yourState.buffDebuffs.containsByID(BuffDebuff.ghosted0_5)) {
            ret *= 0.5;
          }
          if (type == PokeType.rock &&
              buffDebuffs.containsByID(BuffDebuff.rock1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.attack0_75)) ret *= 0.75;
          if (buffDebuffs.containsByID(BuffDebuff.attack1_33)) ret *= 1.33;
          if (buffDebuffs.containsByID(BuffDebuff.attackMove2)) ret *= 2;
          if (type == PokeType.fire &&
              buffDebuffs.containsByID(BuffDebuff.flashFired)) ret *= 1.5;
        }
        break;
      case StatIndex.B:
        {
          if (buffDebuffs.containsByID(BuffDebuff.defense1_3)) ret *= 1.3;
          if (buffDebuffs.containsByID(BuffDebuff.defense1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.guard2)) ret *= 2.0;
          if (buffDebuffs.containsByID(BuffDebuff.guard1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.defense0_75)) ret *= 0.75;
          if (state.weather.id == Weather.snowy &&
              isTypeContain(PokeType.ice)) {
            ret * 1.5;
          }
        }
        break;
      case StatIndex.C:
        {
          if (buffDebuffs.containsByID(BuffDebuff.specialAttack1_3)) ret *= 1.3;
          if (buffDebuffs.containsByID(BuffDebuff.defeatist)) ret *= 0.5;
          if (type == PokeType.fire &&
              yourState.buffDebuffs.containsByID(BuffDebuff.waterBubble1)) {
            ret *= 0.5;
          }
          if (type == PokeType.water &&
              buffDebuffs.containsByID(BuffDebuff.waterBubble2)) ret *= 2;
          if (type == PokeType.steel &&
              buffDebuffs.containsByID(BuffDebuff.steelWorker)) ret *= 1.5;
          if (type == PokeType.electric &&
              buffDebuffs.containsByID(BuffDebuff.electric1_3)) ret *= 1.3;
          if (type == PokeType.dragon &&
              buffDebuffs.containsByID(BuffDebuff.dragon1_5)) ret *= 1.5;
          if (type == PokeType.ghost &&
              yourState.buffDebuffs.containsByID(BuffDebuff.ghosted0_5)) {
            ret *= 0.5;
          }
          if (type == PokeType.rock &&
              buffDebuffs.containsByID(BuffDebuff.rock1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.specialAttack0_75)) {
            ret *= 0.75;
          }
          if (buffDebuffs.containsByID(BuffDebuff.specialAttack1_33)) {
            ret *= 1.33;
          }
          if (buffDebuffs.containsByID(BuffDebuff.choiceSpecs)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.specialAttack2)) ret *= 2.0;
          if (buffDebuffs.containsByID(BuffDebuff.attackMove2)) ret *= 2.0;
          if (type == PokeType.fire &&
              buffDebuffs.containsByID(BuffDebuff.flashFired)) ret *= 1.5;
        }
        break;
      case StatIndex.D:
        {
          if (buffDebuffs.containsByID(BuffDebuff.specialDefense1_3)) {
            ret *= 1.3;
          }
          if (buffDebuffs.containsByID(BuffDebuff.specialDefense0_75)) {
            ret *= 0.75;
          }
          if (buffDebuffs.containsByID(BuffDebuff.specialDefense1_5)) {
            ret *= 1.5;
          }
          if (buffDebuffs
              .containsByID(BuffDebuff.onlyAttackSpecialDefense1_5)) {
            ret *= 1.5;
          }
          if (buffDebuffs.containsByID(BuffDebuff.specialDefense2)) ret *= 2.0;
          if (state.weather.id == Weather.sandStorm &&
              isTypeContain(PokeType.rock)) ret * 1.5;
        }
        break;
      case StatIndex.S:
        {
          if (buffDebuffs.containsByID(BuffDebuff.speed1_5)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.speed2)) ret *= 2.0;
          if (buffDebuffs.containsByID(BuffDebuff.unburden)) ret *= 2.0;
          if (buffDebuffs.containsByID(BuffDebuff.speed1_5IgnPara)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.attackSpeed0_5)) ret *= 0.5;
          if (buffDebuffs.containsByID(BuffDebuff.choiceScarf)) ret *= 1.5;
          if (buffDebuffs.containsByID(BuffDebuff.speed0_5)) ret *= 0.5;
        }
        break;
      default:
        break;
    }

    return ret.floor();
  }

  /// ガードシェア等によって変更された実数値を元に戻す
  void resetRealSixParams() {
    for (final stat in StatIndexList.listAtoS) {
      maxStats[stat].updateReal(pokemon.level, pokemon.temper);
      minStats[stat].updateReal(pokemon.level, pokemon.temper);
    }
  }

  /// SQLに保存された文字列からPokemonStateをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1 ~ split3: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
  static PokemonState deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final pokeData = PokeDB();
    PokemonState pokemonState = PokemonState();
    final stateElements = str.split(split1);
    // pokemon
    pokemonState.pokemon =
        pokeData.pokemons[int.parse(stateElements[0])]!.copy();
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
    pokemonState.teraType1 = PokeType.values[int.parse(stateElements[4])];
    // _isFainting
    pokemonState._isFainting = int.parse(stateElements[5]) != 0;
    // battlingNum
    pokemonState.battlingNum = int.parse(stateElements[6]);
    // holdingItem
    pokemonState.setHoldingItemNoEffect(stateElements[7] == ''
        ? null
        : pokeData.items[int.parse(stateElements[7])]);
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
      pokemonState.setCurrentAbilityNoEffect(
          Ability.deserialize(stateElements[12], split2));
    } else {
      pokemonState.setCurrentAbilityNoEffect(
          pokeData.abilities[int.parse(stateElements[12])]!);
    }
    // ailments
    pokemonState._ailments =
        Ailments.deserialize(stateElements[13], split2, split3);
    // minStats
    final minStatElements = stateElements[14].split(split2);
    for (final stat in StatIndexList.listHtoS) {
      pokemonState.minStats[stat] = FourParams.deserialize(
          minStatElements[stat.index], split3,
          version: version, statIndex: stat);
    }
    // maxStats
    final maxStatElements = stateElements[15].split(split2);
    for (final stat in StatIndexList.listHtoS) {
      pokemonState.maxStats[stat] = FourParams.deserialize(
          maxStatElements[stat.index], split3,
          version: version, statIndex: stat);
    }
    // possibleAbilities
    final abilities = stateElements[16].split(split2);
    for (var ability in abilities) {
      if (ability == '') break;
      if (version == 1) {
        pokemonState.possibleAbilities
            .add(Ability.deserialize(ability, split3));
      } else {
        pokemonState.possibleAbilities
            .add(pokeData.abilities[int.parse(ability)]!);
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
    pokemonState.type1 = PokeType.values[int.parse(stateElements[19])];
    // type2
    if (stateElements[20] != '') {
      pokemonState.type2 = PokeType.values[int.parse(stateElements[20])];
    }
    // lastMove
    if (stateElements[21] != '') {
      pokemonState.lastMove = pokeData.moves[int.parse(stateElements[21])];
    }

    return pokemonState;
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1 ~ split3: 区切り文字
  /// ```
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
    ret += teraType1.index.toString();
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
    for (final buffDebuff in buffDebuffs.list) {
      ret += buffDebuff.serialize(split3);
      ret += split2;
    }
    ret += split1;
    // hiddenBuffs
    for (final buffDebuff in hiddenBuffs.list) {
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
    ret += type1.index.toString();
    ret += split1;
    // type2
    if (type2 != null) {
      ret += type2!.index.toString();
    }
    ret += split1;
    // lastMove
    if (lastMove != null) {
      ret += lastMove!.id.toString();
    }

    return ret;
  }
}
