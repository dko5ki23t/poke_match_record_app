import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:tuple/tuple.dart';

// フィールドによる効果(TurnEffectのeffectIdに使用する定数を提供)
class FieldEffect {
  static const int none = 0;
  static const int electricTerrainEnd = 1; // エレキフィールド終了
  static const int grassyTerrainEnd = 2; // グラスフィールド終了
  static const int mistyTerrainEnd = 3; // ミストフィールド終了
  static const int psychicTerrainEnd = 4; // サイコフィールド終了
  static const int grassHeal = 5; // グラスフィールドによる回復

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('エレキフィールド終了', 'Electric Terrain ends'),
    2: Tuple2('グラスフィールド終了', 'Grassy Terrain ends'),
    3: Tuple2('ミストフィールド終了', 'Misty Terrain ends'),
    4: Tuple2('サイコフィールド終了', 'Psychic Terrain ends'),
    5: Tuple2('グラスフィールドによる回復', 'Recovery by Grassy Terrain'),
  };

  const FieldEffect(this.id);

  static int getIdFromField(Field field) {
    switch (field.id) {
      case Field.electricTerrain:
      case Field.grassyTerrain:
      case Field.mistyTerrain:
      case Field.psychicTerrain:
        return field.id;
      default:
        return 0;
    }
  }

  String get displayName {
    switch (PokeDB().language) {
      case Language.japanese:
        return _displayNameMap[id]!.item1;
      case Language.english:
      default:
        return _displayNameMap[id]!.item2;
    }
  }

  final int id;
}

class TurnEffectField extends TurnEffect {
  TurnEffectField({required this.timing, required this.fieldEffectID})
      : super(EffectType.field);

  @override
  Timing timing;
  int fieldEffectID;
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        ...super.props,
        timing,
        fieldEffectID,
        extraArg1,
        extraArg2,
      ];

  @override
  TurnEffectField copy() =>
      TurnEffectField(timing: timing, fieldEffectID: fieldEffectID)
        ..baseCopyWith(this);

  @override
  String displayName({required AppLocalizations loc}) =>
      FieldEffect(fieldEffectID).displayName;

  @override
  PlayerType get playerType => PlayerType.entireField;

  @override
  set playerType(type) {}

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
    var ownPokemonState =
        myState.playerType == PlayerType.me ? myState : yourState;
    var opponentPokemonState =
        myState.playerType == PlayerType.me ? yourState : myState;
    var ownPokemon = ownPokemonState.pokemon;
    var opponentPokemon = opponentPokemonState.pokemon;
    switch (fieldEffectID) {
      case FieldEffect.grassHeal: // グラスフィールドによる回復
        {
          controller.text =
              (state.getPokemonState(PlayerType.me, null).remainHP - extraArg1)
                  .toString();
          controller2.text = (state
                      .getPokemonState(PlayerType.opponent, null)
                      .remainHPPercent -
                  extraArg2)
              .toString();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DamageIndicateRow(
                ownPokemon,
                controller,
                true,
                (value) {
                  extraArg1 = ownPokemonState.remainHP - value;
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
                opponentPokemon,
                controller2,
                false,
                (value) {
                  extraArg2 = opponentPokemonState.remainHPPercent - value;
                  onEdit();
                  return extraArg2;
                },
                extraArg2,
                true,
                loc: loc,
              ),
            ],
          );
        }
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
    super.beforeProcessEffect(ownState, opponentState);

    switch (fieldEffectID) {
      case FieldEffect.electricTerrainEnd:
      case FieldEffect.grassyTerrainEnd:
      case FieldEffect.mistyTerrainEnd:
      case FieldEffect.psychicTerrainEnd:
        state.field = Field(Field.none);
        break;
      case FieldEffect.grassHeal:
        ownState.remainHP -= extraArg1;
        opponentState.remainHPPercent -= extraArg2;
        break;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      fieldEffectID != 0;

  /// 引数を自動で設定(TurnEffectFieldでは何も処理しない)
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
  ) {}

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
    return t.runtimeType == TurnEffectField &&
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
        fieldEffectID == (t as TurnEffectField).fieldEffectID;
  }

  // SQLに保存された文字列からTurnEffectFieldをパース
  static TurnEffectField deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // timing
    final timing = Timing.values[int.parse(turnEffectElements.removeAt(0))];
    // fieldEffectID
    final fieldEffectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectField turnEffect =
        TurnEffectField(timing: timing, fieldEffectID: fieldEffectID);
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
    // timing
    ret += timing.index.toString();
    ret += split1;
    // fieldEffectID
    ret += fieldEffectID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }
}
