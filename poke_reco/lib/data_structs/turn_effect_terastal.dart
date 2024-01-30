import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect.dart';

class TurnEffectTerastal extends TurnEffect {
  TurnEffectTerastal({required player, required this.teraType})
      : super(EffectType.terastal) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  final Timing timing = Timing.terastaling;
  PokeType teraType;

  @override
  List<Object?> get props => [playerType, timing, teraType];

  @override
  TurnEffectTerastal copy() =>
      TurnEffectTerastal(player: playerType, teraType: teraType);

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
    final pokeData = PokeDB();

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
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.stellarForm));
      } else {
        myState.buffDebuffs
            .changeID(BuffDebuff.terastalForm, BuffDebuff.stellarForm);
      }
      // TODO この2行csvに移したい
      myState.maxStats.h.race = 160;
      myState.maxStats.a.race = 105;
      myState.maxStats.b.race = 110;
      myState.maxStats.c.race = 130;
      myState.maxStats.d.race = 110;
      myState.maxStats.s.race = 85;
      myState.minStats.h.race = 160;
      myState.minStats.a.race = 105;
      myState.minStats.b.race = 110;
      myState.minStats.c.race = 130;
      myState.minStats.d.race = 110;
      myState.minStats.s.race = 85;
      for (final stat in StatIndexList.listHtoS) {
        var biases = Temper.getTemperBias(myState.pokemon.temper);
        myState.maxStats[stat].real = SixParams.getRealABCDS(
            myState.pokemon.level,
            myState.maxStats[stat].race,
            myState.maxStats[stat].indi,
            myState.maxStats[stat].effort,
            biases[stat.index - 1]);
        myState.minStats[stat].real = SixParams.getRealABCDS(
            myState.pokemon.level,
            myState.minStats[stat].race,
            myState.minStats[stat].indi,
            myState.minStats[stat].effort,
            biases[stat.index - 1]);
      }
      if (playerType == PlayerType.me) {
        myState.remainHP += (65 * 2 * myState.pokemon.level / 100).floor();
      }
    }
    if (playerType == PlayerType.me) {
      state.hasOwnTerastal = true;
    } else {
      state.hasOpponentTerastal = true;
    }

    return [];
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none &&
      timing != Timing.none &&
      teraType != PokeType.unknown;

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
        TurnEffectTerastal(player: playerType, teraType: teraType);

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
