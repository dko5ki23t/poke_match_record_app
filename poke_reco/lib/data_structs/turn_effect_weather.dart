import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect.dart';
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

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffect? prevAction,
      int continuousCount,
      {required AppLocalizations loc}) {
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

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      weatherEffectID != 0;

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