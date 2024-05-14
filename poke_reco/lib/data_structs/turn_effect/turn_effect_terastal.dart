import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';

class TurnEffectTerastal extends TurnEffect {
  TurnEffectTerastal({required this.playerType, required this.teraType})
      : super(EffectType.terastal);

  @override
  PlayerType playerType = PlayerType.none;
  PokeType teraType;

  @override
  List<Object?> get props => [playerType, teraType];

  @override
  TurnEffectTerastal copy() =>
      TurnEffectTerastal(playerType: playerType, teraType: teraType);

  @override
  String displayName({required AppLocalizations loc}) => loc.commonTerastal;

  @override
  Timing get timing => Timing.terastaling;
  @override
  set timing(Timing t) {}

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
    required Function() onEdit,
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    return TypeDropdownButton(
      loc.commonTeraType,
      playerType == PlayerType.me
          ? null
          : (value) {
              teraType = value;
              onEdit();
            },
      teraType,
      isTeraType: true,
    );
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
    final pokeData = PokeDB();

    super.beforeProcessEffect(ownState, opponentState);

    myState.isTerastaling = true;
    myState.teraType1 = teraType;
    if (pokeData.pokeBase[myState.pokemon.no]!.teraTypedAbilityID != 0) {
      // テラスタルによってとくせいが変わる場合
      myState.setCurrentAbility(
          pokeData.abilities[
              pokeData.pokeBase[myState.pokemon.no]!.teraTypedAbilityID]!,
          yourState,
          playerType == PlayerType.me,
          state);
    }
    if (myState.pokemon.id == 1024) {
      //テラパゴスがテラスタルした場合
      if (!myState.buffDebuffs.containsByID(BuffDebuff.terastalForm)) {
        myState.buffDebuffs
            .add(PokeDB().buffDebuffs[BuffDebuff.stellarForm]!.copy());
      } else {
        myState.buffDebuffs
            .changeID(BuffDebuff.terastalForm, BuffDebuff.stellarForm);
      }
      myState.buffDebuffs.list
          .firstWhere((element) => element.id == BuffDebuff.stellarForm)
          .changeForm(myState);
      if (playerType == PlayerType.me) {
        myState.remainHP += (65 * 2 * myState.pokemon.level / 100).floor();
      }
    }
    if (playerType == PlayerType.me) {
      state.hasOwnTerastal = true;
    } else {
      state.hasOpponentTerastal = true;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      teraType != PokeType.unknown;

  /// 引数を自動で設定(TurnEffectTerastalでは何も処理しない)
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
    return this == t;
  }

  // SQLに保存された文字列からTurnEffectTerastalをパース
  static TurnEffectTerastal deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // playerType
    final playerType = PlayerTypeNum.createFromNumber(
        int.parse(turnEffectElements.removeAt(0)));
    // teraType
    final teraType = PokeType.values[int.parse(turnEffectElements.removeAt(0))];
    TurnEffectTerastal turnEffect =
        TurnEffectTerastal(playerType: playerType, teraType: teraType);

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
    // teraType
    ret += teraType.index.toString();

    return ret;
  }
}
