// 天気

import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/tool.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

// 天気
class Weather extends Equatable implements Copyable {
  static const int none = 0;
  static const int sunny = 1; // 晴れ
  static const int rainy = 2; // あめ
  static const int sandStorm = 3; // すなあらし
  static const int snowy = 4; // ゆき

  static const int invalid = 100; // 天気無効化

  static const Map<int, Tuple4<String, String, Color, int>> _nameColorTurnMap =
      {
    0: Tuple4('', '', Colors.black, 0),
    1: Tuple4('晴れ', 'Sunny', Colors.orange, 5),
    2: Tuple4('あめ', 'Rainy', Colors.blueAccent, 5),
    3: Tuple4('すなあらし', 'Sandstorm', Colors.brown, 5),
    4: Tuple4('ゆき', 'Snowy', Colors.blue, 5),
  };

  String get displayName {
    if (isValid) {
      switch (PokeDB().language) {
        case Language.japanese:
          return '${_nameColorTurnMap[id]!.item1} ($turns/$maxTurns)';
        case Language.english:
        default:
          return '${_nameColorTurnMap[id]!.item2} ($turns/$maxTurns)';
      }
    } else {
      switch (PokeDB().language) {
        case Language.japanese:
          return '${_nameColorTurnMap[id]!.item1} ($turns/$maxTurns)(無効)';
        case Language.english:
        default:
          return '${_nameColorTurnMap[id]!.item2} ($turns/$maxTurns)(Invalid)';
      }
    }
  }

  Color get bgColor => isValid ? _nameColorTurnMap[id]!.item3 : Colors.grey;
  int get maxTurns {
    if (extraArg1 == 8) {
      return 8;
    }
    return _nameColorTurnMap[id]!.item4;
  }

  int id;
  int turns = 0; // 経過ターン
  int extraArg1 = 0; //

  @override
  List<Object?> get props => [
        id,
        turns,
        extraArg1,
      ];

  Weather(this.id);

  @override
  Weather copy() => Weather(id)
    ..turns = turns
    ..extraArg1 = extraArg1;

  bool get isValid => id < invalid;
  set valid(bool b) {
    if (b && id >= invalid) {
      id -= invalid;
    } else if (!b && id < invalid) {
      id += invalid;
    }
  }

  // 天気変化もしくは場に登場したポケモンに対して天気の効果をかける
  // (場に出たポケモンに対しては、変化前を「天気なし」として引数を渡すとよい)
  static void processWeatherEffect(Weather before, Weather after,
      PokemonState? ownPokemonState, PokemonState? opponentPokemonState) {
    if (ownPokemonState != null &&
        (ownPokemonState.currentAbility.id == 13 ||
            ownPokemonState.currentAbility.id == 76)) {
      // ノーてんき/エアロック
      after.valid = false;
    } else if (opponentPokemonState != null &&
        (opponentPokemonState.currentAbility.id == 13 ||
            opponentPokemonState.currentAbility.id == 76)) {
      // ノーてんき/エアロック
      after.valid = false;
    } else {
      after.valid = true;
    }

    if (after.isValid) {
      if (before.id != Weather.sandStorm && after.id == Weather.sandStorm) {
        // すなあらしになる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 8) {
          // すながくれ
          ownPokemonState.buffDebuffs
              .add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 146) {
          // すなかき
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 8) {
          // すながくれ
          opponentPokemonState.buffDebuffs
              .add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 146) {
          // すなかき
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.sandStorm && after.id != Weather.sandStorm) {
        // すなあらしではなくなる時
        if (ownPokemonState != null && ownPokemonState.currentAbility.id == 8) {
          // すながくれ
          ownPokemonState.buffDebuffs
              .removeFirstByID(BuffDebuff.yourAccuracy0_8);
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 146) {
          // すなかき
          ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 8) {
          // すながくれ
          opponentPokemonState.buffDebuffs
              .removeFirstByID(BuffDebuff.yourAccuracy0_8);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 146) {
          // すなかき
          opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
      }
      if (before.id != Weather.rainy && after.id == Weather.rainy) {
        // あめになる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 33) {
          // すいすい
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 33) {
          // すいすい
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.rainy && after.id != Weather.rainy) {
        // あめではなくなる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 33) {
          // すいすい
          ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 33) {
          // すいすい
          opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
      }
      if (before.id != Weather.sunny && after.id == Weather.sunny) {
        // 晴れになる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 34) {
          // ようりょくそ
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 288) {
          // ひひいろのこどう
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.attack1_33));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 34) {
          // ようりょくそ
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 288) {
          // ひひいろのこどう
          opponentPokemonState.buffDebuffs
              .add(BuffDebuff(BuffDebuff.attack1_33));
        }
      }
      if (before.id == Weather.sunny && after.id != Weather.sunny) {
        // 晴れではなくなる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 34) {
          // ようりょくそ
          ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 288) {
          // ひひいろのこどう
          ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.attack1_33);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 34) {
          // ようりょくそ
          opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 288) {
          // ひひいろのこどう
          opponentPokemonState.buffDebuffs
              .removeFirstByID(BuffDebuff.attack1_33);
        }
      }
      if (before.id != Weather.snowy && after.id == Weather.snowy) {
        // ゆきになる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 81) {
          // ゆきがくれ
          ownPokemonState.buffDebuffs
              .add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 202) {
          // ゆきかき
          ownPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 81) {
          // ゆきがくれ
          opponentPokemonState.buffDebuffs
              .add(BuffDebuff(BuffDebuff.yourAccuracy0_8));
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 202) {
          // ゆきかき
          opponentPokemonState.buffDebuffs.add(BuffDebuff(BuffDebuff.speed2));
        }
      }
      if (before.id == Weather.snowy && after.id != Weather.snowy) {
        // ゆきではなくなる時
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 81) {
          // ゆきがくれ
          ownPokemonState.buffDebuffs
              .removeFirstByID(BuffDebuff.yourAccuracy0_8);
        }
        if (ownPokemonState != null &&
            ownPokemonState.currentAbility.id == 202) {
          // ゆきかき
          ownPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 81) {
          // ゆきがくれ
          opponentPokemonState.buffDebuffs
              .removeFirstByID(BuffDebuff.yourAccuracy0_8);
        }
        if (opponentPokemonState != null &&
            opponentPokemonState.currentAbility.id == 202) {
          // ゆきかき
          opponentPokemonState.buffDebuffs.removeFirstByID(BuffDebuff.speed2);
        }
      }

      // ポワルンのフォルムチェンジ
      for (var pokeState in [ownPokemonState, opponentPokemonState]) {
        if (pokeState == null) continue;
        if (pokeState.currentAbility.id != 59) continue; // てんきや
        int findIdx = pokeState.buffDebuffs.list.indexWhere((element) =>
            BuffDebuff.powalenNormal <= element.id &&
            element.id <= BuffDebuff.powalenSnow);
        BuffDebuff newForm = BuffDebuff(BuffDebuff.powalenNormal);
        switch (after.id) {
          case Weather.sunny:
            newForm = BuffDebuff(BuffDebuff.powalenSun);
            break;
          case Weather.rainy:
            newForm = BuffDebuff(BuffDebuff.powalenRain);
            break;
          case Weather.snowy:
            newForm = BuffDebuff(BuffDebuff.powalenSnow);
            break;
        }
        if (findIdx >= 0) {
          pokeState.buffDebuffs.list[findIdx] = newForm;
        } else {
          pokeState.buffDebuffs.add(newForm);
        }
      }

      // チェリムのフォルムチェンジ
      for (var pokeState in [ownPokemonState, opponentPokemonState]) {
        if (pokeState == null) continue;
        if (pokeState.currentAbility.id != 122) continue; // フラワーギフト
        int findIdx = pokeState.buffDebuffs.list.indexWhere((element) =>
            BuffDebuff.negaForm <= element.id &&
            element.id <= BuffDebuff.posiForm);
        BuffDebuff newForm = BuffDebuff(BuffDebuff.negaForm);
        if (after.id == Weather.sunny) {
          newForm = BuffDebuff(BuffDebuff.posiForm);
        }
        if (findIdx >= 0) {
          pokeState.buffDebuffs.list[findIdx] = newForm;
        } else {
          pokeState.buffDebuffs.add(newForm);
        }
      }
    }
  }

  // SQLに保存された文字列からWeatherをパース
  static Weather deserialize(dynamic str, String split1) {
    final elements = str.split(split1);
    return Weather(int.parse(elements[0]))
      ..turns = int.parse(elements[1])
      ..extraArg1 = int.parse(elements[2]);
  }

  // SQL保存用の文字列に変換
  String serialize(String split1) {
    return '$id$split1$turns$split1$extraArg1';
  }
}
