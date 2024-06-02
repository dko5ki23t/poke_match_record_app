import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_dropdown_button_form_field.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';

// 状態変化による効果(TurnEffectのeffectIdに使用する定数を提供)
class AilmentEffect {
  static const int none = 0;
  static const int burn = 1; // やけど
  static const int freezeEnd = 2; // こおりがとけた
  static const int paralysis = 3; // まひ
  static const int poison = 4; // どく
  static const int badPoison = 5; // もうどく
  static const int sleep = 6; // ねむり     ここまで、重複しない
  static const int confusionEnd = 7; // こんらんがとけた
  static const int curse = 8; // のろい
  static const int encoreEnd = 9; // アンコール
  static const int flinch = 10; // ひるみ
  static const int identify = 11; // みやぶられている
  static const int infatuation = 12; // メロメロ
  static const int leechSeed = 13; // やどりぎのタネ
  static const int lockOnEnd = 15; // ロックオン終了
//  static const int nightmare = 16;          // あくむ
  static const int partiallyTrapped = 17; // バインド(交代不可、毎ターンダメージ) / 終了も含む
  static const int perishSong = 18; // ほろびのうた
  static const int tauntEnd = 19; // ちょうはつ終了
  static const int torment = 20; // いちゃもん
  static const int saltCure = 22; // しおづけ
  static const int disableEnd = 23; // かなしばり終了
  static const int magnetRiseEnd = 24; // でんじふゆう終了
  static const int telekinesisEnd = 25; // テレキネシス終了
  static const int healBlockEnd = 26; // かいふくふうじ終了
  static const int embargoEnd = 27; // さしおさえ終了
  static const int sleepy = 28; // ねむけ→ねむり
  static const int ingrain = 29; // ねをはる
  static const int uproarEnd = 30; // さわぐ終了
  static const int antiAir = 31; // うちおとす
  static const int magicCoat = 32; // マジックコート
  static const int charging = 33; // じゅうでん
  static const int thrash = 34; // あばれる
//  static const int bide = 35;               // がまん
  static const int destinyBond = 36; // みちづれ
  static const int cannotRunAway = 37; // にげられない
  static const int minimize = 38; // ちいさくなる
  static const int flying = 39; // そらをとぶ
  static const int digging = 40; // あなをほる
  static const int curl =
      41; // まるくなる(ころがる・アイスボール当てるたびに威力2倍。extraArg1に連続で当たった回数を格納)
  static const int stock1 =
      42; // たくわえる(1)    extraArg1の1の位→たくわえたときに上がったぼうぎょ、10の位→たくわえたときに上がったとくぼう(はきだす・のみこむ時に下がる分を表す)
  static const int stock2 = 43; // たくわえる(2)
  static const int stock3 = 44; // たくわえる(3)
  static const int attention = 45; // ちゅうもくのまと
//  static const int helpHand = 46;           // てだすけ
  static const int imprison = 47; // ふういん
  static const int grudge = 48; // おんねん
  static const int roost = 49; // はねやすめ
  static const int miracleEye = 50; // ミラクルアイ (+1以上かいひランク無視、エスパーわざがあくタイプに等倍)
  static const int powerTrick = 51; // パワートリック
  static const int abilityNoEffect = 52; // とくせいなし
  static const int aquaRing = 53; // アクアリング
  static const int diving = 54; // ダイビング
  static const int shadowForcing = 55; // シャドーダイブ(姿を消した状態)
  static const int electrify = 56; // そうでん
//  static const int powder = 57;             // ふんじん
  static const int throatChopEnd = 58; // じごくづき終了(画面には出ない)
  static const int tarShot = 59; // タールショット
  static const int octoLock = 60; // たこがため
  static const int protect = 61; // まもる extraArg1 =
  // 588:キングシールド(直接攻撃してきた相手のこうげき1段階DOWN)
  // 596:ニードルガード(直接攻撃してきた相手に最大HP1/8ダメージ)
  // 661:トーチカ(直接攻撃してきた相手をどく状態にする)
  // 792:ブロッキング(直接攻撃してきた相手のぼうぎょ2段階DOWN)
  // 852:スレッドトラップ(直接攻撃してきた相手のすばやさ1段階DOWN)
  // 908:かえんのまもり(直接攻撃してきた相手をやけど状態にする)
  static const int candyCandy = 62; // あめまみれ / 終了も含む
  static const int halloween = 63; // ハロウィン(ゴーストタイプ)
  static const int forestCurse = 64; // もりののろい(くさタイプ)

  static int getIdFromAilment(Ailment ailment) {
    switch (ailment.id) {
      default:
        break;
    }
    return ailment.id;
  }

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('やけど', 'Burn'),
    2: Tuple2('こおりが溶けた', 'Defrosted'),
    3: Tuple2('まひ', 'Paralysis'),
    4: Tuple2('どくダメージ', 'Poison'),
    5: Tuple2('もうどくダメージ', 'Bad poison'),
    6: Tuple2('ねむり', 'Sleep'),
    7: Tuple2('こんらんが解けた', 'Confused no more'),
    8: Tuple2('のろいダメージ', 'Curse'),
    9: Tuple2('アンコールが解けた', 'Encore is resolved'),
    10: Tuple2('ひるみ', 'Flinch'),
    11: Tuple2('みやぶられている', 'Foresighted'),
    12: Tuple2('メロメロ', 'Attracted'),
    13: Tuple2('やどりぎのタネダメージ', 'Leech Seed'),
    15: Tuple2('ロックオン終了', 'Lock-On end'),
//    16: Tuple2('あくむ', 'Nightmare'),
    17: Tuple2('バインド(ダメージ/終了)', 'Partially Trapped'),
    18: Tuple2('ほろびのうた', 'Perish Song'),
    19: Tuple2('ちょうはつ終了', 'Taunt is resolved'), // 挑発の効果が解けた
    20: Tuple2('いちゃもん', 'Torment'),
    22: Tuple2('しおづけダメージ', 'Salt Cure'),
    23: Tuple2('かなしばりが解けた', 'Disable is resolved'),
    24: Tuple2('でんじふゆう終了', 'Magnet Rise end'),
    25: Tuple2('テレキネシス終了', 'Telekinesis end'),
    26: Tuple2('かいふくふうじ終了', 'Heal Block end'),
    27: Tuple2('さしおさえ終了', 'Embargo end'),
    28: Tuple2('ねむってしまった', 'Fell asleap'),
    29: Tuple2('ねをはる', 'Ingrain'),
    30: Tuple2('さわぐ終了', 'Uproar end'),
    31: Tuple2('うちおとす', 'Anti Air'),
    32: Tuple2('マジックコート', 'Magic Coat'),
    33: Tuple2('じゅうでん', 'Charging'),
    34: Tuple2('あばれる', 'Thrash'),
//    35: Tuple2('がまん', 'Bide'),
    36: Tuple2('みちづれ', 'Destiny Bond'),
    37: Tuple2('にげられない', 'Cannot run away'),
    38: Tuple2('ちいさくなる', 'Minimize'),
    39: Tuple2('そらをとぶ', 'Flying'),
    40: Tuple2('あなをほる', 'Digging'),
    41: Tuple2('まるくなる', 'Curl'),
    42: Tuple2('たくわえる(1)', 'Stock(1)'),
    43: Tuple2('たくわえる(2)', 'Stock(2)'),
    44: Tuple2('たくわえる(3)', 'Stock(3)'),
    45: Tuple2('ちゅうもくのまと', 'Attention'),
//    46: Tuple2('てだすけ', 'Help Hand'),
    47: Tuple2('ふういん', 'Imprison'),
    48: Tuple2('おんねん', 'Grudge'),
    49: Tuple2('はねやすめ', 'Roost'),
    50: Tuple2('ミラクルアイ', 'Miracle Eye'),
    51: Tuple2('パワートリック', 'Power Trick'),
    52: Tuple2('とくせいなし', 'Ability no effect'),
    53: Tuple2('アクアリング', 'Aqua Ring'),
    54: Tuple2('ダイビング', 'Diving'),
    55: Tuple2('シャドーダイブ', 'Shadow Forcing'),
    56: Tuple2('そうでん', 'Electrify'),
//    57: Tuple2('ふんじん', 'Powder'),
    58: Tuple2('じごくづき', 'Throat Chop end'),
    59: Tuple2('タールショット', 'Tar Shot'),
    60: Tuple2('たこがため', 'Octo Lock'),
    61: Tuple2('まもる', 'Protect'),
    62: Tuple2('あめまみれ', 'Covered in candy'),
    63: Tuple2('ハロウィン', 'Halloween'),
    64: Tuple2('もりののろい', 'Forest Curse'),
  };

  const AilmentEffect(this.id);

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  // ただ状態変化を終了させるだけの処理を行う
  static void processRemove(int effectId, PokemonState pokemonState) {
    switch (effectId) {
      case AilmentEffect.confusionEnd:
      case AilmentEffect.tauntEnd:
      case AilmentEffect.encoreEnd:
      case AilmentEffect.lockOnEnd:
      case AilmentEffect.disableEnd:
      case AilmentEffect.magnetRiseEnd:
      case AilmentEffect.telekinesisEnd:
      case AilmentEffect.embargoEnd:
      case AilmentEffect.uproarEnd:
        pokemonState.ailmentsRemoveWhere((e) => e.id == effectId);
        break;
      default:
        break;
    }
  }

  final int id;
}

class TurnEffectAilment extends TurnEffect {
  TurnEffectAilment(
      {required player, required this.timing, required this.ailmentEffectID})
      : super(EffectType.ailment) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  @override
  Timing timing = Timing.none;
  int ailmentEffectID = 0;
  int turns = 0;
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        ...super.props,
        playerType,
        timing,
        ailmentEffectID,
        turns,
        extraArg1,
        extraArg2
      ];

  @override
  TurnEffectAilment copy() => TurnEffectAilment(
      player: playerType, timing: timing, ailmentEffectID: ailmentEffectID)
    ..turns
    ..extraArg1 = extraArg1
    ..extraArg2 = extraArg2
    ..baseCopyWith(this);

  @override
  String displayName({required AppLocalizations loc}) =>
      AilmentEffect(ailmentEffectID).displayName;

  @override
  PlayerType get playerType => _playerType;

  @override
  set playerType(type) => _playerType = type;

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getChangePokemonIndex(PlayerType player) {
    return null;
  }

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を設定する
  /// nullを設定すると交換していないことを表す
  /// ```
  /// player: 行動主
  /// prev: 交換前ポケモンのパーティ内インデックス(1始まり)
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  @override
  void setChangePokemonIndex(PlayerType player, int? prev, int? val) {}

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getPrevPokemonIndex(PlayerType player) {
    return null;
  }

  /// 効果のextraArg等を編集するWidgetを返す
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 対戦相手のパーティ
  /// state: フェーズの状態
  /// controller: テキスト入力コントローラ
  /// onEdit: 編集したときに呼び出すコールバック
  /// (ダイアログで、効果が有効かどうかでOKボタンの有効無効を切り替えるために使う)
  /// ```
  @override
  Widget editArgWidget(
    PokemonState myState,
    PokemonState yourState,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    TextEditingController controller,
    TextEditingController controller2, {
    required void Function() onEdit,
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    final dropdownMenuKey = Key('AilmentEffectDropDownMenu');
    switch (ailmentEffectID) {
      case AilmentEffect.poison: // どく
      case AilmentEffect.badPoison: // もうどく
      case AilmentEffect.burn: // やけど
      case AilmentEffect.saltCure: // しおづけ
      case AilmentEffect.curse: // のろい
      case AilmentEffect.ingrain: // ねをはる
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
          }
          return DamageIndicateRow(
            myState.pokemon,
            controller,
            playerType == PlayerType.me,
            (value) {
              if (playerType == PlayerType.me) {
                extraArg1 = myState.remainHP - value;
              } else {
                extraArg1 = myState.remainHPPercent - value;
              }
              onEdit();
              return extraArg1;
            },
            extraArg1,
            true,
            loc: loc,
          );
        }
      case AilmentEffect.leechSeed: // やどりぎのタネ
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
            controller2.text =
                (yourState.remainHPPercent - extraArg2).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
            controller2.text = (yourState.remainHP - extraArg2).toString();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                myState.pokemon,
                controller,
                playerType == PlayerType.me,
                (value) {
                  if (playerType == PlayerType.me) {
                    extraArg1 = myState.remainHP - value;
                  } else {
                    extraArg1 = myState.remainHPPercent - value;
                  }
                  onEdit();
                  return extraArg1;
                },
                extraArg1,
                true,
                loc: loc,
              ),
              SizedBox(
                height: 10,
              ),
              DamageIndicateRow(
                yourState.pokemon,
                controller2,
                playerType != PlayerType.me,
                (value) {
                  if (playerType == PlayerType.me) {
                    extraArg2 = yourState.remainHPPercent - value;
                  } else {
                    extraArg2 = yourState.remainHP - value;
                  }
                  onEdit();
                  return extraArg2;
                },
                extraArg2,
                true,
                keyStr: '2',
                loc: loc,
              ),
            ],
          );
        }
      case AilmentEffect.partiallyTrapped: // バインド
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
          }
          return Column(
            children: [
              _myDropdownButtonFormField(
                key: dropdownMenuKey,
                decoration: InputDecoration(
                  labelText: loc.battleEffect,
                ),
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: 0,
                    child: Text(loc.battleDamaged),
                  ),
                  ColoredPopupMenuItem(
                    value: 1,
                    child: Text(loc.battleEffectExpired),
                  ),
                ],
                value: extraArg2,
                onChanged: (value) {
                  extraArg2 = value;
                  onEdit();
                  // 統合テスト作成用
                  final text =
                      value == 0 ? loc.battleDamaged : loc.battleEffectExpired;
                  print("// $text\n"
                      "await driver.tap(find.byValueKey('$dropdownMenuKey'));\n"
                      "await driver.tap(find.text('$text'));");
                },
                isInput: true,
                textValue: extraArg2 == 1
                    ? loc.battleEffectExpired
                    : loc.battleDamaged,
              ),
              SizedBox(
                height: 10,
              ),
              extraArg2 == 0
                  ? DamageIndicateRow(
                      myState.pokemon,
                      controller,
                      playerType == PlayerType.me,
                      (value) {
                        if (playerType == PlayerType.me) {
                          extraArg1 = myState.remainHP - value;
                        } else {
                          extraArg1 = myState.remainHPPercent - value;
                        }
                        onEdit();
                        return extraArg1;
                      },
                      extraArg1,
                      true,
                      loc: loc,
                    )
                  : Container(),
            ],
          );
        }
      case AilmentEffect.candyCandy: // あめまみれ
        return Row(
          children: [
            Expanded(
              child: _myDropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: loc.battleEffect,
                ),
                items: <ColoredPopupMenuItem>[
                  ColoredPopupMenuItem(
                    value: 0,
                    child:
                        Text(loc.battleSpeedDown1(myState.pokemon.omittedName)),
                  ),
                  ColoredPopupMenuItem(
                    value: 1,
                    child: Text(loc.battleEffectExpired),
                  ),
                ],
                value: extraArg2,
                onChanged: (value) {
                  extraArg2 = value;
                  onEdit();
                },
                isInput: true,
                textValue: extraArg2 == 1
                    ? loc.battleEffectExpired
                    : loc.battleSpeedDown1(myState.pokemon.omittedName),
              ),
            ),
          ],
        );
    }
    return Container();
  }

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffectAction? prevAction,
      {required AppLocalizations loc}) {
    final myState = timing == Timing.afterMove && prevAction != null
        ? state.getPokemonState(playerType, prevAction)
        : playerType == PlayerType.me
            ? ownState
            : opponentState;
    final yourState = timing == Timing.afterMove && prevAction != null
        ? state.getPokemonState(playerType.opposite, prevAction)
        : playerType == PlayerType.me
            ? opponentState
            : ownState;

    super.beforeProcessEffect(ownState, opponentState);

    switch (ailmentEffectID) {
      case AilmentEffect.sleepy:
        myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleepy);
        myState.ailmentsAdd(Ailment(Ailment.sleep), state);
        break;
      case AilmentEffect.burn:
      case AilmentEffect.poison:
      case AilmentEffect.badPoison:
      case AilmentEffect.saltCure:
      case AilmentEffect.curse:
      case AilmentEffect.ingrain:
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case AilmentEffect.leechSeed:
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
          yourState.remainHPPercent -= extraArg2;
        } else {
          myState.remainHPPercent -= extraArg1;
          yourState.remainHP -= extraArg2;
        }
        // 相手HP確定
        if (playerType == PlayerType.opponent) {
          int drain = extraArg2.abs();
          if (yourState.remainHP < yourState.pokemon.h.real &&
              myState.remainHPPercent > 0 &&
              drain > 0) {
            if (yourState.holdingItem?.id == 273) {
              // おおきなねっこ
              int tmp = ((drain.toDouble() + 0.5) / 1.3).round();
              while (roundOff5(tmp * 1.3) > drain) {
                tmp--;
              }
              drain = tmp;
            }
            int hpMin = drain * 8;
            int hpMax = hpMin + 3;
            if (hpMin != myState.minStats.h.real ||
                hpMax != myState.maxStats.h.real) {
/*
              ret.add(Guide()
                ..guideId = Guide.leechSeedConfHP
                ..args = [hpMin, hpMax]
                ..guideStr = loc.battleGuideLeechSeedConfHP(
                    hpMax, hpMin, myState.pokemon.omittedName));
*/
            }
          }
        }
        break;
      case AilmentEffect.partiallyTrapped:
        if (extraArg2 > 0) {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.partiallyTrapped);
        } else {
          if (playerType == PlayerType.me) {
            myState.remainHP -= extraArg1;
          } else {
            myState.remainHPPercent -= extraArg1;
          }
        }
        break;
      case AilmentEffect.perishSong:
        myState.remainHP = 0;
        myState.remainHPPercent = 0;
        myState.isFainting = true;
        break;
      case AilmentEffect.octoLock:
        myState.addStatChanges(true, 1, -1, yourState);
        myState.addStatChanges(true, 3, -1, yourState);
        break;
      case AilmentEffect.candyCandy:
        if (extraArg2 > 0) {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.candyCandy);
        } else {
          myState.addStatChanges(false, 4, -1, yourState);
        }
        break;
      default:
        AilmentEffect.processRemove(ailmentEffectID, myState);
        break;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      ailmentEffectID != 0;

  /// 現在のポケモンの状態等から決定できる引数を自動で設定
  /// ```
  /// myState: 効果発動主のポケモンの状態
  /// yourState: 効果発動主の相手のポケモンの状態
  /// state: フェーズの状態
  /// prevAction: 直前の行動
  /// ```
  @override
  void setAutoArgs(
    PokemonState myState,
    PokemonState yourState,
    PhaseState state,
    TurnEffectAction? prevAction,
  ) {
    extraArg1 = 0;
    extraArg2 = 0;
    bool isMe = playerType == PlayerType.me;

    switch (ailmentEffectID) {
      case AilmentEffect.burn:
        if (myState.buffDebuffs.containsByID(BuffDebuff.heatproof)) {
          extraArg1 = isMe ? (myState.pokemon.h.real / 32).floor() : 3;
        } else {
          extraArg1 = isMe ? (myState.pokemon.h.real / 16).floor() : 6;
        }
        return;
      case AilmentEffect.poison:
      case AilmentEffect.leechSeed:
      case AilmentEffect.partiallyTrapped:
        extraArg1 = isMe
            ? turns >= 10
                ? (myState.pokemon.h.real / 6).floor()
                : (myState.pokemon.h.real / 8).floor()
            : turns >= 10
                ? 16
                : 12;
        return;
      case AilmentEffect.badPoison:
        extraArg1 = isMe
            ? (myState.pokemon.h.real * (turns + 1).clamp(1, 15) / 16).floor()
            : (100 * (turns + 1).clamp(1, 15) / 16).floor();
        return;
      case AilmentEffect.curse:
        extraArg1 = isMe ? (myState.pokemon.h.real / 4).floor() : 25;
        return;
      case AilmentEffect.saltCure:
        {
          int bunbo = myState.isTypeContain(PokeType.steel) ||
                  myState.isTypeContain(PokeType.water)
              ? 4
              : 8;
          extraArg1 = isMe
              ? (myState.pokemon.h.real / bunbo).floor()
              : (100 / bunbo).floor();
          return;
        }
      case AilmentEffect.ingrain:
      case AilmentEffect.aquaRing:
        {
          int rec = isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
          extraArg1 =
              myState.holdingItem?.id == 273 ? -((-rec * 1.3).floor()) : rec;
          return;
        }
      default:
        return;
    }
  }

  /// カスタムしたDropdownButtonFormField
  /// ```
  /// onFocus: フォーカスされたとき(タップされたとき)に呼ぶコールバック
  /// isInput: 入力モードかどうか
  /// textValue: 出力文字列(isInput==falseのとき必須)
  /// prefixIconPokemon: フィールド前に配置するアイコンのポケモン
  /// showNetworkImage: インターネットから取得したポケモンの画像を使うかどうか
  /// ```
  Widget _myDropdownButtonFormField<T>({
    Key? key,
    required List<ColoredPopupMenuItem<T>> items,
    T? value,
    required ValueChanged<T?>? onChanged,
    double elevation = 8,
    Widget? icon,
    double iconSize = 24.0,
    InputDecoration? decoration,
    bool? enableFeedback,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    required bool isInput,
    required String? textValue,
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    ThemeData? theme,
  }) {
    if (isInput) {
      return AppBaseDropdownButtonFormField(
        key: key,
        items: items,
        value: value,
        onChanged: onChanged,
        elevation: elevation,
        icon: icon,
        iconSize: iconSize,
        decoration: decoration,
        enableFeedback: enableFeedback,
        padding: padding,
      );
    } else {
      return TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: decoration?.labelText,
          prefixIcon: prefixIconPokemon != null
              ? showNetworkImage
                  ? Image.network(
                      PokeDB().pokeBase[prefixIconPokemon.no]!.imageUrl,
                      height: theme?.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    )
                  : const Icon(Icons.catching_pokemon)
              : null,
        ),
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
      );
    }
  }

  /// extraArg等以外同じ、ほぼ同じかどうか
  /// ```
  /// allowTimingDiff: タイミングが異なっていても同じとみなすかどうか
  /// ```
  @override
  bool nearEqual(
    TurnEffect t, {
    bool allowTimingDiff = false,
    bool isChangeMe = false,
    bool isChangeOpponent = false,
  }) {
    return t.runtimeType == TurnEffectAilment &&
        playerType == t.playerType &&
        (timing == t.timing ||
            (allowTimingDiff &&
                !(isChangeMe &&
                    playerType == PlayerType.me &&
                    (timing == Timing.afterMove ||
                        t.timing == Timing.afterMove)) &&
                !(isChangeOpponent &&
                    playerType == PlayerType.opponent &&
                    (timing == Timing.afterMove ||
                        t.timing == Timing.afterMove)))) &&
        ailmentEffectID == (t as TurnEffectAilment).ailmentEffectID;
  }

  // SQLに保存された文字列からTurnEffectAilmentをパース
  static TurnEffectAilment deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // playerType
    final playerType = PlayerTypeNum.createFromNumber(
        int.parse(turnEffectElements.removeAt(0)));
    // timing
    final timing = Timing.values[int.parse(turnEffectElements.removeAt(0))];
    // ailmentEffectID
    final ailmentEffectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectAilment turnEffect = TurnEffectAilment(
        player: playerType, timing: timing, ailmentEffectID: ailmentEffectID);
    // turns
    turnEffect.turns = int.parse(turnEffectElements.removeAt(0));
    // extraArg1
    turnEffect.extraArg1 = int.parse(turnEffectElements.removeAt(0));
    // extraArg2
    turnEffect.extraArg2 = int.parse(turnEffectElements.removeAt(0));

    return turnEffect;
  }

  // SQL保存用の文字列に変換
  @override
  String serialize(
    String split1,
    String split2,
    String split3,
  ) {
    String ret = '';
    // effectType
    ret += effectType.index.toString();
    ret += split1;
    // playerType
    ret += playerType.number.toString();
    ret += split1;
    // timing
    ret += timing.index.toString();
    ret += split1;
    // ailmentEffectID
    ret += ailmentEffectID.toString();
    ret += split1;
    // turns
    ret += turns.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }
}
