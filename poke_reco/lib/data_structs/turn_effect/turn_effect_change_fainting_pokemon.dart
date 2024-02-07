import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';

class TurnEffectChangeFaintingPokemon extends TurnEffect {
  TurnEffectChangeFaintingPokemon({required player, required this.timing})
      : super(EffectType.changeFaintingPokemon) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  Timing timing;
  int changePokemonIndex = 0; // 0は無効値

  @override
  List<Object?> get props => [playerType, timing, changePokemonIndex];

  @override
  TurnEffectChangeFaintingPokemon copy() =>
      TurnEffectChangeFaintingPokemon(player: playerType, timing: timing)
        ..changePokemonIndex = changePokemonIndex;

  @override
  String displayName({required AppLocalizations loc}) =>
      loc.battlePokemonChange;

  @override
  PlayerType get playerType => _playerType;

  @override
  set playerType(type) => _playerType = type;

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

    // のうりょく変化リセット、現在のポケモンを表すインデックス更新
    myState.processExitEffect(yourState, state);
    if (changePokemonIndex != 0) {
      state.setPokemonIndex(playerType, changePokemonIndex);
      state
          .getPokemonState(playerType, null)
          .processEnterEffect(yourState, state);
    }

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      changePokemonIndex != 0;

  // SQLに保存された文字列からTurnEffectChangeFaintingPokemonをパース
  static TurnEffectChangeFaintingPokemon deserialize(
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
    TurnEffectChangeFaintingPokemon turnEffect =
        TurnEffectChangeFaintingPokemon(player: playerType, timing: timing);
    // changePokemonIndex
    turnEffect.changePokemonIndex = int.parse(turnEffectElements.removeAt(0));

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
    // changePokemonIndex
    ret += changePokemonIndex.toString();

    return ret;
  }
}
