import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/party.dart';

// ユーザが手動で変更した内容
class UserForce {
  static const int none = 0;
  static const int ability = 1;
  static const int item = 2;
  static const int hp = 3;
  static const int rankA = 4;
  static const int rankB = 5;
  static const int rankC = 6;
  static const int rankD = 7;
  static const int rankS = 8;
  static const int rankAc = 9;
  static const int rankEv = 10;
  static const int statMinH = 11;
  static const int statMinA = 12;
  static const int statMinB = 13;
  static const int statMinC = 14;
  static const int statMinD = 15;
  static const int statMinS = 16;
  static const int statMaxH = 17;
  static const int statMaxA = 18;
  static const int statMaxB = 19;
  static const int statMaxC = 20;
  static const int statMaxD = 21;
  static const int statMaxS = 22;
  static const int pokemon = 23;

  final PlayerType playerType;
  final int typeId;
  final int arg1;

  const UserForce(this.playerType, this.typeId, this.arg1);

}

class UserForces {
  final List<UserForce> forces = [];

  UserForces copyWith() =>
    UserForces()
    ..forces.addAll([...forces]);

  void add(UserForce force) {
    // 既に同じプレイヤー・種類の修正がある場合はそれを削除して上書き
    forces.removeWhere((e) => e.playerType == force.playerType && e.typeId == force.typeId);
    forces.add(force);
  }

  List<String> processEffect(
    PokemonState ownPokemonState,
    PokemonState opponentPokemonState,
    PhaseState state,
    Party ownParty,
    Party opponentParty,
  )
  {
    var pokeData = PokeDB();
    for (var force in forces) {
      switch (force.typeId) {
        case UserForce.ability:
          if (force.playerType == PlayerType.me) {
            ownPokemonState.setCurrentAbility(pokeData.abilities[force.arg1]!, opponentPokemonState, true, state);
          }
          else if (force.playerType == PlayerType.opponent) {
            if (opponentPokemonState.getCurrentAbility().id == 0) {
              opponentPokemonState.pokemon.ability = pokeData.abilities[force.arg1]!;
            }
            opponentPokemonState.setCurrentAbility(pokeData.abilities[force.arg1]!, ownPokemonState, false, state);
          }
          break;
        case UserForce.item:
        var item = force.arg1 < 0 ? null : pokeData.items[force.arg1]!;
          if (force.playerType == PlayerType.me) {
            ownPokemonState.holdingItem = item;
          }
          else if (force.playerType == PlayerType.opponent) {
            if (opponentPokemonState.pokemon.item?.id == 0) {
              opponentPokemonState.pokemon.item = item;
            }
            opponentPokemonState.holdingItem = item;
          }
          break;
        case UserForce.hp:
          if (force.playerType == PlayerType.me) {
            ownPokemonState.remainHP = force.arg1;
          }
          else if (force.playerType == PlayerType.opponent) {
            opponentPokemonState.remainHPPercent = force.arg1;
          }
          break;
        case UserForce.rankA:
        case UserForce.rankB:
        case UserForce.rankC:
        case UserForce.rankD:
        case UserForce.rankS:
        case UserForce.rankAc:
        case UserForce.rankEv:
          if (force.playerType == PlayerType.me) {
            ownPokemonState.forceSetStatChanges(force.typeId - UserForce.rankA, force.arg1);
          }
          else if (force.playerType == PlayerType.opponent) {
            opponentPokemonState.forceSetStatChanges(force.typeId - UserForce.rankA, force.arg1);
          }
          break;
        case UserForce.statMinH:
        case UserForce.statMinA:
        case UserForce.statMinB:
        case UserForce.statMinC:
        case UserForce.statMinD:
        case UserForce.statMinS:
          if (force.playerType == PlayerType.me) {
            ownPokemonState.minStats[StatIndexNumber.getStatIndexFromIndex(force.typeId-UserForce.statMinH)].real = force.arg1;
          }
          else if (force.playerType == PlayerType.opponent) {
            opponentPokemonState.minStats[StatIndexNumber.getStatIndexFromIndex(force.typeId-UserForce.statMinH)].real = force.arg1;
          }
          break;
        case UserForce.statMaxH:
        case UserForce.statMaxA:
        case UserForce.statMaxB:
        case UserForce.statMaxC:
        case UserForce.statMaxD:
        case UserForce.statMaxS:
          if (force.playerType == PlayerType.me) {
            ownPokemonState.maxStats[StatIndexNumber.getStatIndexFromIndex(force.typeId-UserForce.statMaxH)].real = force.arg1;
          }
          else if (force.playerType == PlayerType.opponent) {
            opponentPokemonState.maxStats[StatIndexNumber.getStatIndexFromIndex(force.typeId-UserForce.statMaxH)].real = force.arg1;
          }
          break;
        case UserForce.pokemon:
          state.makePokemonOther(force.playerType, force.arg1, ownParty: ownParty, opponentParty: opponentParty);
          break;
      }
    }

    return [];
  }

  // SQLに保存された文字列からUserForcesをパース
  static UserForces deserialize(dynamic str, String split1, String split2) {
    UserForces userForces = UserForces();
    final forceElements = str.split(split1);
    for (var force in forceElements) {
      if (force == '') break;
      final f = force.split(split2);
      userForces.forces.add(
        UserForce(
          PlayerTypeNum.createFromNumber(int.parse(f[0])),
          int.parse(f[1]), int.parse(f[2])
        )
      );
    }
    return userForces;
  }

  // SQL保存用の文字列に変換
  String serialize(String split1, String split2) {
    String ret = '';
    for (var e in forces) {
      // playerType
      ret += e.playerType.number.toString();
      ret += split2;
      // typeId
      ret += e.typeId.toString();
      ret += split2;
      // arg1
      ret += e.arg1.toString();
      ret += split2;

      ret += split1;
    }

    return ret;
  }
}
