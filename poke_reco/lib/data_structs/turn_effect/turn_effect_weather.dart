import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';
import 'package:poke_reco/data_structs/weather.dart';
import 'package:tuple/tuple.dart';

// 天気による効果(TurnEffectのeffectIdに使用する定数を提供)
class WeatherEffect {
  static const int none = 0;
  static const int sunnyEnd = 1; // 晴れ終了
  static const int rainyEnd = 2; // あめ終了
  static const int sandStormEnd = 3; // すなあらし終了
  static const int snowyEnd = 4; // ゆき終了
  static const int sandStormDamage = 5; // すなあらしダメージ

  static const Map<int, Tuple2<String, String>> _displayNameMap = {
    0: Tuple2('', ''),
    1: Tuple2('晴れ終了', 'Sunny End'),
    2: Tuple2('あめ終了', 'Rainy End'),
    3: Tuple2('すなあらし終了', 'Sandstorm End'),
    4: Tuple2('ゆき終了', 'Snowy End'),
    5: Tuple2('すなあらしによるダメージ', 'Sandstorm Damage'),
  };

  const WeatherEffect(this.id);

  static int getIdFromWeather(Weather weather) {
    switch (weather.id) {
      case Weather.sunny:
      case Weather.rainy:
      case Weather.sandStorm:
      case Weather.snowy:
        return weather.id;
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

class TurnEffectWeather extends TurnEffect {
  TurnEffectWeather({required this.timing, required this.weatherEffectID})
      : super(EffectType.weather);

  @override
  Timing timing;
  int weatherEffectID;
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        timing,
        weatherEffectID,
        extraArg1,
        extraArg2,
      ];

  @override
  TurnEffectWeather copy() =>
      TurnEffectWeather(timing: timing, weatherEffectID: weatherEffectID);

  @override
  String displayName({required AppLocalizations loc}) =>
      WeatherEffect(weatherEffectID).displayName;

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
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    var ownPokemonState =
        myState.playerType == PlayerType.me ? myState : yourState;
    var opponentPokemonState =
        myState.playerType == PlayerType.me ? yourState : myState;
    var ownPokemon = ownPokemonState.pokemon;
    var opponentPokemon = opponentPokemonState.pokemon;
    switch (weatherEffectID) {
      case WeatherEffect.sandStormDamage: // すなあらしによるダメージ
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
    switch (weatherEffectID) {
      case WeatherEffect.sunnyEnd:
      case WeatherEffect.rainyEnd:
      case WeatherEffect.sandStormEnd:
      case WeatherEffect.snowyEnd:
        state.weather = Weather(Weather.none);
        break;
      case WeatherEffect.sandStormDamage:
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
      weatherEffectID != 0;

  /// 引数を自動で設定(TurnEffectWeatherでは何も処理しない)
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
  }) {
    return t.runtimeType == TurnEffectWeather &&
        playerType == t.playerType &&
        (allowTimingDiff || timing == t.timing) &&
        weatherEffectID == (t as TurnEffectWeather).weatherEffectID;
  }

  // SQLに保存された文字列からTurnEffectWeatherをパース
  static TurnEffectWeather deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    final List turnEffectElements = str.split(split1);
    // effectType
    turnEffectElements.removeAt(0);
    // timing
    final timing = Timing.values[int.parse(turnEffectElements.removeAt(0))];
    // weatherEffectID
    final weatherEffectID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectWeather turnEffect =
        TurnEffectWeather(timing: timing, weatherEffectID: weatherEffectID);
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
    // weatherEffectID
    ret += weatherEffectID.toString();
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }
}
