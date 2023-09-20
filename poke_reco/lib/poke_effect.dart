import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:poke_reco/poke_move.dart';

class EffectType {
  static const int none = 0;
  static const int ability = 1;
  static const int item = 2;
  static const int individualField = 3;
  static const int ailment = 4;
  static const int weather = 5;
  static const int field = 6;
  static const int move = 7;

  const EffectType(this.id);

  final int id;
}

class PlayerType {
  static const int none = 0;
  static const int me = 1;          // 自身
  static const int opponent = 2;    // 相手
  static const int entireField = 3; // 全体の場(両者に影響あり)

  const PlayerType(this.id);

  final int id;
}

// ポケモンを繰り出すとき
// とくせい
const List<int> pokemonAppearAbilityIDs = [
  256,    // かがくへんかガス
  127,    // きんちょうかん
  266,    // じんばいったい
  267,    // じんばいったい
  2,      // あめふらし
  22,     // いかく
  76,     // エアロック
  226,    // エレキメイカー
  188,    // オーラブレイク
  119,    // おみとおし
  190,    // おわりのだいち
  104,    // かたやぶり
  150,    // かわりもの
  107,    // きけんよち
  261,    // きみょうなくすり
  229,    // グラスメイカー
  227,    // サイコメイカー
  112,    // スロースタート
  45,     // すなおこし
  213,    // ぜったいねむり
  293,    // そうだいしょう
  186,    // ダークオーラ
  163,    // ターボブレイズ
  88,     // ダウンロード
  164,    // テラボルテージ
  191,    // デルタストリーム
  36,     // トレース
  13,     // ノーてんき
  189,    // はじまりのうみ
  289,    // ハドロンエンジン
  251,    // バリアフリー
  70,     // ひでり
  288,    // ひひいろのこどう
  187,    // フェアリーオーラ
  235,    // ふくつのたて
  234,    // ふとうのけん
  46,     // プレッシャー
  278,    // マイティチェンジ
  228,    // ミストメイカー
  117,    // ゆきふらし
  108,    // よちむ
  284,    // わざわいのうつわ
  286,    // わざわいのおふだ
  287,    // わざわいのたま
  285,    // わざわいのつるぎ
  7,      // じゅうなん
  199,    // すいほう
  270,    // ねつこうかん
  257,    // パステルベール
  15,     // ふみん
  40,     // マグマのよろい
  41,     // みずのベール
  17,     // めんえき
  72,     // やるき
  250,    // ぎたい
  208,    // ぎょぐん
  197,    // リミットシールド
  248,    // アイスフェイス
  294,    // きょうえん
  282,    // クォークチャージ
  281,    // こだいかっせい
  279,    // しれいとう
  59,     // てんきや
  122,    // フラワーギフト
  290,    // びんじょう
];
// もちもの
const List<int> pokemonAppearItemIDs = [
  126,      // クラボのみ	持たせるとまひを回復する
  127,      // カゴのみ	持たせると眠りを回復する
  128,      // モモンのみ	持たせるとどくを回復する
  129,      // チーゴのみ	持たせるとやけどを回復する
  130,      // ナナシのみ	持たせるとこおりを回復する
  131,      // ヒメリのみ	持たせるとPPを10回復する
  132,      // オレンのみ	持たせるとHPを10回復する
  133,      // キーのみ	持たせると混乱を回復する
  134,      // ラムのみ	持たせると全ての状態異常を回復する
  135,      // オボンのみ	持たせるとHPを少しだけ回復する
  136,      // フィラのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  137,      // ウイのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  138,      // マゴのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  139,      // バンジのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  140,      // イアのみ	持たせるとピンチの時にHPを回復する 嫌いな味だと混乱する
  178,      // チイラのみ	持たせるとピンチの時に攻撃が上がる
  179,      // リュガのみ	持たせるとピンチの時に防御が上がる
  181,      // ヤタビのみ	持たせるとピンチの時に特攻が上がる
  182,      // ズアのみ	持たせるとピンチの時に特防が上がる
  180,      // カムラのみ	持たせるとピンチの時に素早さが上がる
  898,      // エレキシード
  901,      // グラスシード
  899,      // サイコシード
  900,      // ミストシード
  1180,     // ルームサービス
  1696,     // ブーストエナジー
  191,      // しろいハーブ
  1699,     // ものまねハーブ
  1177,     // だっしゅつパック
];
// ポケモンの場
const List<int> pokemonAppearFieldIDs = [
  IndividualField.healingWish,  // いやしのねがい
  IndividualField.lunarDance,   // みかづきのまい
  IndividualField.spikes,       // まきびし
  IndividualField.toxicSpikes,  // どくびし
  IndividualField.stealthRock,  // ステルスロック
  IndividualField.stickyWeb,    // ねばねばネット
];

// 行動決定直後
// とくせい
const List<int> afterActionDecisionAbilityIDs = [
  259,    // クイックドロウ
];
// もちもの
const List <int> afterActionDecisionItemIDs = [
  194,      // せんせいのツメ
  187,      // イバンのみ
];

// 毎ターン終了時
// とくせい
const List<int> everyTurnEndAbilityIDs = [
  87,           // かんそうはだ
  94,           // サンパワー
  44,           // あめうけざら
  115,          // アイスボディ
  194,          // ききかいひ
  193,          // にげごし
  93,           // うるおいボディ
  61,           // だっぴ
  131,          // いやしのこころ
  392,          // アクアリング
  90,           // ポイズンヒール
  3,            // かそく
  141,          // ムラっけ
  112,          // スロースタート
  123,          // ナイトメア
  291,          // はんすう
  53,           // ものひろい
  139,          // しゅうかく
  237,          // たまひろい
  161,          // ダルマモード
  197,          // リミットシールド
  211,          // スワームチェンジ
  208,          // ぎょぐん
  258,          // はらぺこスイッチ
];
// もちもの
const List<int> everyTurnEndItemIDs = [
  211,      // たべのこし
  258,      // くろいヘドロ
  265,      // くっつきバリ
  249,      // どくどくだま
  250,      // かえんだま
  191,      // しろいハーブ
  1177,     // だっしゅつパック
];
// 状態異常
const List<int> everyTurnEndAilmentIDs = [
  Ailment.leechSeed,          // やどりぎのタネ
  Ailment.poison,             // どく
  Ailment.badPoison,          // もうどく
  Ailment.burn,               // やけど
  Ailment.nightmare,          // あくむ
  Ailment.curse,              // のろい
  Ailment.partiallyTrapped,   // バインド
  Ailment.saltCure,           // しおづけ
  Ailment.taunt,              // ちょうはつ終了
  Ailment.torment,            // いちゃもん終了
  Ailment.encore,             // アンコール終了
  Ailment.disable,            // かなしばり終了
  Ailment.magnetRise,         // でんじふゆう終了
  Ailment.telekinesis,        // テレキネシス終了
  Ailment.healBlock,          // かいふくふうじ終了
  Ailment.embargo,            // さしおさえ終了
  Ailment.sleepy,             // ねむけによるねむり
  Ailment.perishSong,         // ほろびのうた
  Ailment.ingrain,            // ねをはる
  Ailment.uproar,             // さわぐ終了
];
// 天気
const List<int> everyTurnEndWeatherIDs = [
  Weather.sunny,            // 晴れ終了
  Weather.rainy,            // あめ終了
  Weather.sandStorm,        // すなあらし終了
  Weather.snowy,            // ゆき終了
];
// ポケモンの場
const List<int> everyTurnEndIndividualFieldIDs = [
  IndividualField.sandStormDamage,    // すなあらしによるダメージ
  IndividualField.futureAttack,       // みらいにこうげき
  IndividualField.futureAttackSteel,  // はめつのねがい
  IndividualField.grassFieldRecovery, // グラスフィールドによる回復
  IndividualField.reflector,          // リフレクター終了
  IndividualField.lightScreen,        // ひかりのかべ終了
  IndividualField.safeGuard,          // しんぴのまもり
  IndividualField.mist,               // しろいきり終了
  IndividualField.tailwind,           // おいかぜ終了
  IndividualField.luckyChant,         // おまじない終了
  IndividualField.auroraVeil,         // オーロラベール終了
];
// フィールド
const List<int> everyTurnEndFieldIDs = [
  Field.trickRoom,      // トリックルーム終了
  Field.gravity,        // じゅうりょく終了
  Field.waterSport,     // みずあそび終了
  Field.mudSport,       // どろあそび終了
  Field.wonderRoom,     // ワンダールーム終了
  Field.magicRoom,      // マジックルーム終了
  Field.electricTerrain,// エレキフィールド終了
  Field.grassyTerrain,  // グラスフィールド終了
  Field.mistyTerrain,   // ミストフィールド終了
  Field.psychicTerrain, // サイコフィールド終了
];

class TurnEffect {
  PlayerType playerType = PlayerType(PlayerType.none);
  AbilityTiming timing = AbilityTiming(AbilityTiming.none);
  EffectType effect = EffectType(EffectType.none);
  int effectId = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;
  TurnMove? move;         // タイプがわざの場合は非null
  bool isAdding = false;  // trueの場合、追加待ち状態

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..timing = AbilityTiming(timing.id)
    ..effect = effect
    ..effectId = effectId
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2
    ..move = move?.copyWith()
    ..isAdding = isAdding;

  bool isValid() {
    return
      playerType.id != PlayerType.none &&
      effect.id != EffectType.none &&
      (effect.id == EffectType.move && move != null && move!.isValid() || effectId > 0);
  }

  void processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentParty,
    PokemonState opponentPokemonState,
    PhaseState state,
    PokeDB pokeData,
  )
  {
    if (!isValid()) return;

    var myState = ownPokemonState;
    var yourState = opponentPokemonState;
    if (playerType.id == PlayerType.opponent) {
      myState = opponentPokemonState;
      yourState = ownPokemonState;
    }
    var myParty = ownParty;
    var yourParty = opponentParty;
    if (playerType.id == PlayerType.opponent) {
      myParty = opponentParty;
      yourParty = ownParty;
    }
    var myPokemonIndex = state.ownPokemonIndex;
    var yourPokemonIndex = state.opponentPokemonIndex;
    if (playerType.id == PlayerType.opponent) {
      myPokemonIndex = state.opponentPokemonIndex;
      yourPokemonIndex = state.ownPokemonIndex;
    }

    switch (effect.id) {
      case EffectType.ability:
        switch (effectId) {
          case 22:    // いかく
            yourState.statChanges[0]--;
            break;
          case 281:   // こだいかっせい
            myState.buffDebuffs.add(BuffDebuff(1+extraArg1));
// TODO:以下のような決定をユーザに確認したい
/*
            if (state.weather.id != Weather.sunny) {  // 晴れではないのに発動したら
              myParty.items[myPokemonIndex-1] = pokeData.items[1696];   // ブーストエナジー確定
              myState.holdingItem = null;   // アイテム消費
            }
*/
            break;
          case 282:   // クォークチャージ
            myState.buffDebuffs.add(BuffDebuff(1+extraArg1));
            break;
          default:
            break;
        }
        break;
      case EffectType.move:
        if (move!.isSuccess && move!.type.id == TurnMoveType.change) {
          if (playerType.id == PlayerType.me) {
            state.ownPokemonIndex = move!.changePokemonIndex!;
          }
          else {
            state.opponentPokemonIndex = move!.changePokemonIndex!;
          }
        }
        if (move!.isSuccess && move!.type.id == TurnMoveType.move) {
          if (playerType.id == PlayerType.me) {
            state.opponentPokemonStates[state.opponentPokemonIndex-1].remainHPPercent -= move!.percentDamage;
          }
          else {
            state.ownPokemonStates[state.ownPokemonIndex-1].remainHP -= move!.realDamage;
          }
        }
        break;
    }
  }

  // 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
  static List<TurnEffect> getPossibleEffects(
    AbilityTiming timing, PlayerType playerType, EffectType type, Pokemon? pokemon, PokemonState? pokemonState, PhaseState? phaseState)
  {
    List<TurnEffect> ret = [];
    List<int> abilityIDs = [];
    List<int> itemIDs = [];
    List<int> individualFieldIDs = [];
    List<int> ailmentIDs = [];
    List<int> weatherIDs = [];
    List<int> fieldIDs = [];
    switch (timing.id) {
      case AbilityTiming.pokemonAppear:   // ポケモンを繰り出すとき
        abilityIDs = pokemonAppearAbilityIDs;
        itemIDs = pokemonAppearItemIDs;
        individualFieldIDs = pokemonAppearFieldIDs;
        break;
      case AbilityTiming.everyTurnEnd:           // 毎ターン終了時
        abilityIDs = everyTurnEndAbilityIDs;
        itemIDs = everyTurnEndItemIDs;
        individualFieldIDs = everyTurnEndIndividualFieldIDs;
        ailmentIDs = everyTurnEndAilmentIDs;
        weatherIDs = everyTurnEndWeatherIDs;
        fieldIDs = everyTurnEndFieldIDs;
        break;
      case AbilityTiming.afterActionDecision:    // 行動決定直後
        abilityIDs = afterActionDecisionAbilityIDs;
        itemIDs = afterActionDecisionItemIDs;
        break;
      case AbilityTiming.afterMove:     // わざ使用後
        break;
      default:
        break;
    }

    if (playerType.id == PlayerType.me || playerType.id == PlayerType.opponent) {
      if (playerType.id == PlayerType.me && type.id == EffectType.ability) {
        if (abilityIDs.contains(pokemon!.ability.id)) {
          ret.add(TurnEffect()
            ..playerType = PlayerType(PlayerType.me)
            ..effect = EffectType(EffectType.ability)
            ..effectId = pokemon!.ability.id
          );
        }
      }
      else if (playerType.id == PlayerType.opponent && type.id == EffectType.ability) {
        for (final ability in pokemonState!.possibleAbilities) {
          if (abilityIDs.contains(ability.id)) {
            ret.add(TurnEffect()
              ..playerType = PlayerType(PlayerType.opponent)
              ..effect = EffectType(EffectType.ability)
              ..effectId = ability.id
            );
          }
        }
      }
      if (type.id == EffectType.individualField) {
        for (final field in pokemonState!.fields) {
          if (individualFieldIDs.contains(field.id)) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.individualField)
              ..effectId = field.id
            );
          }
        }
      }
      if (type.id == EffectType.ailment) {
        for (final ailment in pokemonState!.ailments) {
          if (ailmentIDs.contains(ailment.id)) {
            ret.add(TurnEffect()
              ..playerType = playerType
              ..effect = EffectType(EffectType.ailment)
              ..effectId = ailment.id
            );
          }
        }
      }
      if (playerType.id == PlayerType.me && type.id == EffectType.item) {
        if (itemIDs.contains(pokemonState!.holdingItem?.id)) {
          ret.add(TurnEffect()
            ..playerType = PlayerType(PlayerType.me)
            ..effect = EffectType(EffectType.item)
            ..effectId = pokemonState.holdingItem!.id
          );
        }
      }
      else if (playerType.id == PlayerType.opponent && type.id == EffectType.item) {
        for (final item in pokemonState!.impossibleItems) {
          if (itemIDs.contains(item.id)) {
            itemIDs.remove(item.id);
          }
        }
        for (final item in itemIDs) {
          ret.add(TurnEffect()
            ..playerType = PlayerType(PlayerType.opponent)
            ..effect = EffectType(EffectType.item)
            ..effectId = item
          );
        }
      }
    }

    if (playerType.id == PlayerType.entireField) {
      if (weatherIDs.contains(phaseState!.weather.id)) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.weather)
          ..effectId = phaseState.weather.id
        );
      }
      if (fieldIDs.contains(phaseState.field.id)) {
        ret.add(TurnEffect()
          ..playerType = PlayerType(PlayerType.entireField)
          ..effect = EffectType(EffectType.field)
          ..effectId = phaseState.field.id
        );
      }
    }

    return ret;
  }

  String getDisplayName(PokeDB pokeData) {
    switch (effect.id) {
      case EffectType.ability:
        return pokeData.abilities[effectId]!.displayName;
      case EffectType.item:
        return pokeData.items[effectId]!.displayName;
      case EffectType.individualField:
        return IndividualField(effectId).displayName;
      case EffectType.weather:
        return Weather(effectId).displayName;
      case EffectType.field:
        return Field(effectId).displayName;
      case EffectType.move:
        return move!.move.displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText1() {
    switch (timing.id) {
      case AbilityTiming.action:
        return move == null ? '' : move!.move.displayName;
      default:
        return '';
    }
  }

  String getEditingControllerText2() {
    /*
    switch (timing.id) {
      case AbilityTiming.action:
        {
          if (move == null) return '';
          if (move!.playerType.id == PlayerType.me) {
            return move!.percentDamage.toString();
          }
          else {
            return move!.realD
          }
        }
      default:
        return '';
    }
    */
    return '';
  }

  Widget extraInputWidget(
    void Function() setState,
  )
  {
    if (effect.id == EffectType.ability) {   // とくせいによる効果
      switch (effectId) {
        case 281:     // こだいかっせい
        case 282:     // クォークチャージ
          return Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 0,
                      child: Text('こうげき'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('ぼうぎょ'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('とくこう'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('とくぼう'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('すばやさ'),
                    ),
                  ],
                  value: extraArg1,
                  onChanged: (value) {
                    extraArg1 = value;
                    setState();
                  },
                ),
              ),
              Text('があがった'),
            ],
          );
        default:
          break;
      }
    }

    return Container();
  }

  // SQLに保存された文字列からTurnMoveをパース
  static TurnEffect deserialize(dynamic str, String split1, String split2, String split3) {
    TurnEffect effect = TurnEffect();
    final effectElements = str.split(split1);
    // playerType
    effect.playerType = PlayerType(int.parse(effectElements[0]));
    // timing
    effect.timing = AbilityTiming(int.parse(effectElements[1]));
    // effect
    effect.effect = EffectType(int.parse(effectElements[2]));
    // effectId
    effect.effectId = int.parse(effectElements[3]);
    // extraArg1
    effect.extraArg1 = int.parse(effectElements[4]);
    // extraArg2
    effect.extraArg2 = int.parse(effectElements[5]);
    // move
    if (effectElements[6] == '') {
      effect.move = null;
    }
    else {
      effect.move = TurnMove.deserialize(effectElements[6], split2, split3);
    }
    // isAdding
    effect.isAdding = int.parse(effectElements[7]) != 0;

    return effect;
  }

   // SQL保存用の文字列に変換
  String serialize(String split1, String split2, String split3) {
    String ret = '';
    // playerType
    ret += playerType.id.toString();
    ret += split1;
    // timing
    ret += timing.id.toString();
    ret += split1;
    // effect
    ret += '${effect.id}';
    ret += split1;
    // effectId
    ret += effectId.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();
    ret += split1;
    // move
    ret += move == null ? '' : move!.serialize(split2, split3);
    ret += split1;
    // isAdding
    ret += isAdding ? '1' : '0';

    return ret;
  }

  static void swap(List<TurnEffect> list, int idx1, int idx2) {
    TurnEffect tmp = list[idx1].copyWith();
    list[idx1] = list[idx2].copyWith();
    list[idx2] = tmp;
  }
}

class TurnEffectAndState {
  TurnEffect turnEffect = TurnEffect();
  PhaseState phaseState = PhaseState();
}
