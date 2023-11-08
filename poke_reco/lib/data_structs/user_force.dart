import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

// ユーザが手動で変更した内容
class UserForce {
  static const int none = 0;
  static const int ability = 1;
  static const int item = 2;
  static const int hp = 3;

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
    switch (force.typeId) {
      case UserForce.ability:
        // とくせいの修正が既にある場合は、それを削除して上書き
        forces.removeWhere((e) => e.playerType.id == force.playerType.id && e.typeId == UserForce.ability);
        forces.add(force);
        break;
      case UserForce.item:
        // もちものの修正が既にある場合は、それを削除して上書き
        forces.removeWhere((e) => e.playerType.id == force.playerType.id && e.typeId == UserForce.item);
        forces.add(force);
        break;
      case UserForce.hp:
        // HPの修正が既にある場合は、それを削除して上書き
        forces.removeWhere((e) => e.playerType.id == force.playerType.id && e.typeId == UserForce.hp);
        forces.add(force);
        break;
      default:
        break;
    }
  }

  List<String> processEffect(
    Party ownParty,
    PokemonState ownPokemonState,
    Party opponentParty,
    PokemonState opponentPokemonState,
    PhaseState state,
    TurnEffect? prevAction,
    int continuousCount,
  )
  {
    var pokeData = PokeDB();
    for (var force in forces) {
      switch (force.typeId) {
        case UserForce.ability:
          if (force.playerType.id == PlayerType.me) {
            ownPokemonState.currentAbility = pokeData.abilities[force.arg1]!;
          }
          else if (force.playerType.id == PlayerType.opponent) {
            opponentPokemonState.currentAbility = pokeData.abilities[force.arg1]!;
          }
          break;
        case UserForce.item:
        var item = force.arg1 < 0 ? null : pokeData.items[force.arg1]!;
          if (force.playerType.id == PlayerType.me) {
            ownPokemonState.holdingItem = item;
          }
          else if (force.playerType.id == PlayerType.opponent) {
            opponentPokemonState.holdingItem = item;
          }
          break;
        case UserForce.hp:
          if (force.playerType.id == PlayerType.me) {
            ownPokemonState.remainHP = force.arg1;
          }
          else if (force.playerType.id == PlayerType.opponent) {
            opponentPokemonState.remainHPPercent = force.arg1;
          }
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
          PlayerType(int.parse(f[0])),
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
      ret += e.playerType.id.toString();
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
