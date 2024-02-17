import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';

/// 対戦終了
class TurnEffectGameset extends TurnEffect {
  TurnEffectGameset({
    required this.winner,
    required this.opponentName,
  }) : super(EffectType.gameset);

  final PlayerType winner;
  final String opponentName;

  @override
  List<Object?> get props => [winner, opponentName];

  @override
  TurnEffectGameset copy() =>
      TurnEffectGameset(winner: winner, opponentName: opponentName);

  @override
  String displayName({required AppLocalizations loc}) => winner == PlayerType.me
      ? loc.battleResultYouWin
      : loc.battleResultOpponentWin(opponentName);

  @override
  PlayerType get playerType => PlayerType.none;
  @override
  set playerType(type) {}
  @override
  Timing get timing => Timing.gameSet;
  @override
  set timing(Timing t) {}
  @override
  bool isValid() => true;

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
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  @override
  void setChangePokemonIndex(PlayerType player, int? val) {}

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffectAction? prevAction,
      {required AppLocalizations loc}) {
    return [];
  }

  /// 引数を自動で設定(TurnEffectGamesetでは何も処理しない)
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
  @override
  bool nearEqual(TurnEffect t) {
    return this == t;
  }

  /// SQLに保存された文字列からUserForcesをパース
  /// ```
  /// str: SQLに保存された文字列
  /// split1: 区切り文字
  /// version: SQLテーブルのバージョン(-1は最新バージョンを表す)
  /// ```
  static TurnEffectGameset deserialize(dynamic str, String split1,
      {int version = -1}) {
    final List gameSetElements = str.split(split1);
    // effectType
    gameSetElements.removeAt(0);
    // winner
    final winner =
        PlayerTypeNum.createFromNumber(int.parse(gameSetElements.removeAt(0)));
    // opponentName
    final opponentName = gameSetElements.removeAt(0);
    return TurnEffectGameset(winner: winner, opponentName: opponentName);
  }

  /// SQL保存用の文字列に変換
  /// ```
  /// split1~split3: 区切り文字
  /// ```
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
    // winner
    ret += winner.number.toString();
    ret += split1;
    // opponentName
    ret += opponentName;

    return ret;
  }
}
