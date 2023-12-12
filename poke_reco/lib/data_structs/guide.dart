import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

// わざや処理の入力に対して表示する情報や、そこから推定できる相手ポケモンのパラメータなど
class Guide {
  // 値はconfirm_status.csvのNoと一致させてる
  static const int none = 0;
  static const int damageCalc = 1001;       // ダメージ計算
  static const int confItem = 1002;         // 相手のもちもの確定(当該もちものの使用等、自然にわかる範囲)
  static const int confMove = 1003;         // 相手のわざ確定(当該わざの使用等、自然にわかる範囲)
  static const int confAbility = 1004;      // 相手のとくせい確定(当該わざの使用等、自然にわかる範囲)
  static const int leechSeedConfHP = 1;     // やどりぎのタネから相手のHP範囲確定
  static const int sapConfAttack = 2;       // ちからをすいとるから相手のこうげき確定

  int guideId = 0;
  int categoryId = 0;     // カテゴリ別に表示のON/OFFができるように
  List<int> args = [];
  String guideStr = '';
  bool canDelete = true;

  // (注)他のeffectよりも後に行う
  void processEffect(
    PokemonState ownState,
    PokemonState opponentState,
    PhaseState state,
  ) {
    var pokeData = PokeDB();
    switch (guideId) {
      case damageCalc:
        // nop
        break;
      case confItem:
        opponentState.pokemon.item = pokeData.items[args[0]]!;
        break;
      case confMove:
        // nop
        break;
      case confAbility:
        opponentState.pokemon.ability = pokeData.abilities[args[0]]!;
        break;
      case leechSeedConfHP:
        // TODO: この時点で努力値等を反映するのかどうかとか
        opponentState.minStats[0].real = args[0];
        opponentState.maxStats[0].real = args[1];
        break;
      case sapConfAttack:
        // TODO: この時点で努力値等を反映するのかどうかとか
        opponentState.minStats[1].real = args[0];
        opponentState.maxStats[1].real = args[1];
        break;
    }
  }
}