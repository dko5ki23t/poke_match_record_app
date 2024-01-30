import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/turn_effect.dart';
import 'package:poke_reco/tool.dart';

// ユーザが手動で変更した内容
class UserEdit extends Equatable {
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

  @override
  List<Object?> get props => [
        playerType,
        typeId,
        arg1,
      ];

  const UserEdit(this.playerType, this.typeId, this.arg1);
}

class TurnEffectUserEdit extends TurnEffect {
  TurnEffectUserEdit() : super(EffectType.userEdit);

  final List<UserEdit> forces = [];

  @override
  List<Object?> get props => [forces];

  @override
  TurnEffectUserEdit copy() => TurnEffectUserEdit()..forces.addAll([...forces]);

  @override
  String displayName({required AppLocalizations loc}) => '';

  @override
  PlayerType get playerType => PlayerType.none;
  @override
  set playerType(type) {}
  @override
  bool isValid() => true;

  void add(UserEdit force) {
    // 既に同じプレイヤー・種類の修正がある場合はそれを削除して上書き
    forces.removeWhere(
        (e) => e.playerType == force.playerType && e.typeId == force.typeId);
    forces.add(force);
  }

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
    var pokeData = PokeDB();
    for (var force in forces) {
      switch (force.typeId) {
        case UserEdit.ability:
          if (force.playerType == PlayerType.me) {
            ownState.setCurrentAbility(
                pokeData.abilities[force.arg1]!, opponentState, true, state);
          } else if (force.playerType == PlayerType.opponent) {
            if (opponentState.getCurrentAbility().id == 0) {
              opponentState.pokemon.ability = pokeData.abilities[force.arg1]!;
            }
            opponentState.setCurrentAbility(
                pokeData.abilities[force.arg1]!, ownState, false, state);
          }
          break;
        case UserEdit.item:
          var item = force.arg1 < 0 ? null : pokeData.items[force.arg1]!;
          if (force.playerType == PlayerType.me) {
            ownState.holdingItem = item;
          } else if (force.playerType == PlayerType.opponent) {
            if (opponentState.pokemon.item?.id == 0) {
              opponentState.pokemon.item = item;
            }
            opponentState.holdingItem = item;
          }
          break;
        case UserEdit.hp:
          if (force.playerType == PlayerType.me) {
            ownState.remainHP = force.arg1;
          } else if (force.playerType == PlayerType.opponent) {
            opponentState.remainHPPercent = force.arg1;
          }
          break;
        case UserEdit.rankA:
        case UserEdit.rankB:
        case UserEdit.rankC:
        case UserEdit.rankD:
        case UserEdit.rankS:
        case UserEdit.rankAc:
        case UserEdit.rankEv:
          if (force.playerType == PlayerType.me) {
            ownState.forceSetStatChanges(
                force.typeId - UserEdit.rankA, force.arg1);
          } else if (force.playerType == PlayerType.opponent) {
            opponentState.forceSetStatChanges(
                force.typeId - UserEdit.rankA, force.arg1);
          }
          break;
        case UserEdit.statMinH:
        case UserEdit.statMinA:
        case UserEdit.statMinB:
        case UserEdit.statMinC:
        case UserEdit.statMinD:
        case UserEdit.statMinS:
          if (force.playerType == PlayerType.me) {
            ownState
                .minStats[StatIndexNumber.getStatIndexFromIndex(
                    force.typeId - UserEdit.statMinH)]
                .real = force.arg1;
          } else if (force.playerType == PlayerType.opponent) {
            opponentState
                .minStats[StatIndexNumber.getStatIndexFromIndex(
                    force.typeId - UserEdit.statMinH)]
                .real = force.arg1;
          }
          break;
        case UserEdit.statMaxH:
        case UserEdit.statMaxA:
        case UserEdit.statMaxB:
        case UserEdit.statMaxC:
        case UserEdit.statMaxD:
        case UserEdit.statMaxS:
          if (force.playerType == PlayerType.me) {
            ownState
                .maxStats[StatIndexNumber.getStatIndexFromIndex(
                    force.typeId - UserEdit.statMaxH)]
                .real = force.arg1;
          } else if (force.playerType == PlayerType.opponent) {
            opponentState
                .maxStats[StatIndexNumber.getStatIndexFromIndex(
                    force.typeId - UserEdit.statMaxH)]
                .real = force.arg1;
          }
          break;
        case UserEdit.pokemon:
          state.makePokemonOther(force.playerType, force.arg1,
              ownParty: ownParty, opponentParty: opponentParty);
          break;
      }
    }

    return [];
  }

  // SQLに保存された文字列からUserForcesをパース
  static TurnEffectUserEdit deserialize(
      dynamic str, String split1, String split2, String split3,
      {int version = -1}) {
    // -1は最新バージョン
    TurnEffectUserEdit userForces = TurnEffectUserEdit();
    final List forceElements = str.split(split1);
    // effectType
    forceElements.removeAt(0);
    for (var force in forceElements) {
      if (force == '') break;
      final f = force.split(split2);
      userForces.forces.add(UserEdit(
          PlayerTypeNum.createFromNumber(int.parse(f[0])),
          int.parse(f[1]),
          int.parse(f[2])));
    }
    return userForces;
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