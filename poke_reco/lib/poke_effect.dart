import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

enum EffectType {
  none(0),
  ability(1),
  item(2),
  individualField(3),
  ;

  const EffectType(this.id);

  final int id;
}

enum PlayerType {
  none(0),
  me(1),            // 自身
  opponent(2),      // 相手
  entireField(3),   // 全体の場(両者に影響あり)
  ;

  const PlayerType(this.id);

  final int id;
}

class TurnEffect {
  PlayerType playerType = PlayerType.none;
  EffectType effect = EffectType.none;
  int effectId = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;

  TurnEffect copyWith() =>
    TurnEffect()
    ..playerType = playerType
    ..effect = effect
    ..effectId = effectId
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2;

  bool isValid() {
    return
      playerType != PlayerType.none &&
      effect != EffectType.none &&
      effectId > 0;
  }

  void processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentPokemon,
    PokemonState opponentPokemonState,
    PhaseState state,
  )
  {
    if (effect == EffectType.ability) {
      switch (effectId) {
        case 22:   // いかく
          if (playerType == PlayerType.me) {
            opponentPokemonState.statChanges[0]--;
          }
          else {
            ownPokemonState.statChanges[0]--;
          }
          break;
        default:
          break;
      }
    }
  }

  // 引数で指定したポケモンor nullならフィールドや天気が起こし得る処理を返す
  static List<TurnEffect> getPossibleEffects(
    AbilityTiming timing, PlayerType playerType, EffectType type, Pokemon? pokemon, PokemonState? state)
  {
    List<TurnEffect> ret = [];
    switch (timing.id) {
      case 1:   // ポケモンを繰り出すとき
        if (pokemon != null) {
          // とくせい
          List<int> abilityIDs = [
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
          if (playerType == PlayerType.me && type == EffectType.ability) {
            if (abilityIDs.contains(pokemon.ability.id)) {
              ret.add(TurnEffect()
                ..playerType = PlayerType.me
                ..effect = EffectType.ability
                ..effectId = pokemon.ability.id
              );
            }
          }
          else if (playerType == PlayerType.opponent && type == EffectType.ability) {
            for (final ability in state!.possibleAbilities) {
              if (abilityIDs.contains(ability.id)) {
                ret.add(TurnEffect()
                  ..playerType = PlayerType.opponent
                  ..effect = EffectType.ability
                  ..effectId = ability.id
                );
              }
            }
          }
          // ポケモンの場
          List<int> fieldIDs = [
            IndividualField.healingWish,  // いやしのねがい
            IndividualField.lunarDance,   // みかづきのまい
            IndividualField.spikes,       // まきびし
            IndividualField.toxicSpikes,  // どくびし
            IndividualField.stickyWeb,    // ねばねばネット
          ];
          if (type == EffectType.individualField) {
            for (final field in state!.fields) {
              if (fieldIDs.contains(field.id)) {
                ret.add(TurnEffect()
                  ..playerType = playerType
                  ..effect = EffectType.individualField
                  ..effectId = field.id
                );
              }
            }
          }
          // もちもの
          List <int> itemIDs = [
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
          if (playerType == PlayerType.me && type == EffectType.item) {
            if (itemIDs.contains(state!.holdingItem?.id)) {
              ret.add(TurnEffect()
                ..playerType = PlayerType.me
                ..effect = EffectType.item
                ..effectId = state.holdingItem!.id
              );
            }
          }
          else if (playerType == PlayerType.opponent && type == EffectType.item) {
            for (final item in state!.impossibleItems) {
              if (itemIDs.contains(item.id)) {
                itemIDs.remove(item.id);
              }
            }
            for (final item in itemIDs) {
              ret.add(TurnEffect()
                ..playerType = PlayerType.opponent
                ..effect = EffectType.item
                ..effectId = item
              );
            }
          }
        }
        break;
      default:
        break;
    }

    return ret;
  }

  String getDisplayName(PokeDB pokeData) {
    switch (effect) {
      case EffectType.ability:
        return pokeData.abilities[effectId]!.displayName;
      case EffectType.item:
        return pokeData.items[effectId]!.displayName;
      case EffectType.individualField:
        return IndividualField(effectId).displayName;
      default:
        return '';
    }
  }

  Widget extraInputWidget(
    void Function() setState,
  )
  {
    if (effect == EffectType.ability) {   // とくせいによる効果
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
  static TurnEffect deserialize(dynamic str, String split1) {
    TurnEffect effect = TurnEffect();
    final effectElements = str.split(split1);
    // playerType
    switch (int.parse(effectElements[0])) {
      case 1:
        effect.playerType = PlayerType.me;
        break;
      case 2:
        effect.playerType = PlayerType.opponent;
        break;
      case 3:
        effect.playerType = PlayerType.entireField;
        break;
      default:
        effect.playerType = PlayerType.none;
        break;
    }
    // effect
    switch (int.parse(effectElements[1])) {
      case 1:
        effect.effect = EffectType.ability;
        break;
      case 2:
        effect.effect = EffectType.item;
        break;
      default:
        effect.effect = EffectType.none;
        break;
    }
    // effectId
    effect.effectId = int.parse(effectElements[2]);
    // extraArg1
    effect.extraArg1 = int.parse(effectElements[3]);
    // extraArg2
    effect.extraArg2 = int.parse(effectElements[4]);

    return effect;
  }

   // SQL保存用の文字列に変換
  String serialize(String split1) {
    String ret = '';
    // playerType
    switch (playerType) {
      case PlayerType.me:
        ret += '1';
        ret += split1;
        break;
      case PlayerType.opponent:
        ret += '2';
        ret += split1;
        break;
      case PlayerType.entireField:
        ret += '3';
        ret += split1;
        break;
      default:
        ret += '0';
        ret += split1;
        break;
    }
    // effect
    switch (effect) {
      case EffectType.ability:
        ret += '1';
        ret += split1;
        break;
      case EffectType.item:
        ret += '2';
        ret += split1;
        break;
      default:
        ret += '0';
        ret += split1;
        break;
    }
    // effectId
    ret += effectId.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }

  static void swap(List<TurnEffect> list, int idx1, int idx2) {
    TurnEffect tmp = list[idx1].copyWith();
    list[idx1] = list[idx2].copyWith();
    list[idx2] = tmp;
  }
}