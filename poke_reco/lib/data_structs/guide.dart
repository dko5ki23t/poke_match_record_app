import 'package:poke_reco/custom_widgets/battle_pokemon_state_info.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';

/// とくせいやもちものが持つ効果の分類。
/// 受けたダメージの大きさ等からとくせいやもちものを推測するときに使う
// TODO:無くす？
/*enum SuggestCategory {
  none,
  
  /// 物理技使用時、こうげきを2倍にしてダメージ計算
  
}*/

/// わざや処理の入力に対して表示する情報や、そこから推定できる相手ポケモンのパラメータなど
class Guide {
  // 値はconfirm_status.csvのNoと一致させてる
  static const int none = 0;

  /// ダメージ計算
  static const int damageCalc = 1001;

  /// 相手のもちもの確定(当該もちものの使用等、自然にわかる範囲)
  static const int confItem = 1002;

  /// 相手のわざ確定(当該わざの使用等、自然にわかる範囲)
  static const int confMove = 1003;

  /// 相手のとくせい確定(当該わざの使用等、自然にわかる範囲)
  static const int confAbility = 1004;

  /// 相手が使用したわざから、相手のポケモンがゾロアーク系であること確定(ここではなくprocessMoveで処理)
  static const int confZoroark = 1005;

  // 以下、別CSVに記載のIDと一致させる
  /// やどりぎのタネから相手のHP範囲確定
  static const int leechSeedConfHP = 1;

  /// ちからをすいとるから相手のこうげき確定
  static const int sapConfAttack = 2;

  /// 被ダメージ→相手のこうげき/とくこう実数値範囲確定
  static const int moveDamagedToStatus = 3;

  /// わざの発生順序から相手のすばやさ範囲確定
  static const int moveOrderConfSpeed = 4;

  /// 被ダメージ→相手のとくせい候補を提案
  static const int suggestAbilities = 5;

  /// 被ダメージ→相手のもちもの候補を提案
  static const int suggestItems = 6;

  int guideId = 0;
  int categoryId = 0; // カテゴリ別に表示のON/OFFができるように
  List<int> args = [];
  String guideStr = '';
  bool canDelete = true;

  /// 効果等の結果からステータスを確定する
  /// (注)他のeffectよりも後に行う
  /// 確定させたステータスに対応するページのenumを返す
  StatusInfoPageIndex processEffect(
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
      case confZoroark:
        // nop
        break;
      case leechSeedConfHP:
        // TODO: この時点で努力値等を反映するのかどうかとか
        opponentState.minStats.h.real = args[0];
        opponentState.maxStats.h.real = args[1];
        return StatusInfoPageIndex.real;
      case sapConfAttack:
        // TODO: この時点で努力値等を反映するのかどうかとか
        opponentState.minStats.a.real = args[0];
        opponentState.maxStats.a.real = args[1];
        return StatusInfoPageIndex.real;
      case moveDamagedToStatus:
        // TODO: この時点で努力値等を反映するのかどうかとか
        // TODO! せいかく補正込みの値がargsに入っているため、そのまま代入するのは間違い？
        opponentState.minStats[StatIndex.values[args[0]]].real = args[1];
        opponentState.maxStats[StatIndex.values[args[0]]].real = args[2];
        return StatusInfoPageIndex.real;
      case moveOrderConfSpeed:
        // TODO: この時点で努力値等を反映するのかどうかとか
        opponentState.minStats.s.real = args[0];
        opponentState.maxStats.s.real = args[1];
        return StatusInfoPageIndex.real;
      case suggestAbilities:
      case suggestItems:
        // 提案の表示は別の場所で行う
        break;
    }
    return StatusInfoPageIndex.none;
  }
}
