import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/custom_widgets/damage_indicate_row.dart';
import 'package:poke_reco/custom_widgets/pokemon_dropdown_menu_item.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect_action.dart';

class TurnEffectItem extends TurnEffect {
  TurnEffectItem(
      {required PlayerType player, required this.timing, required this.itemID})
      : super(EffectType.item) {
    _playerType = player;
  }

  PlayerType _playerType = PlayerType.none;
  @override
  Timing timing = Timing.none;
  int itemID = 0;

  /// 自身・相手の(あるなら)交換先ポケモンのパーティ内インデックス(1始まり)
  List<int?> _changePokemonIndexes = [null, null];

  /// 自身・相手の(あるなら)交換前ポケモンのパーティ内インデックス(1始まり)
  List<int?> _prevPokemonIndexes = [null, null];
  int extraArg1 = 0;
  int extraArg2 = 0;

  @override
  List<Object?> get props => [
        playerType,
        timing,
        itemID,
        _changePokemonIndexes,
        _prevPokemonIndexes,
        extraArg1,
        extraArg2
      ];

  @override
  TurnEffectItem copy() =>
      TurnEffectItem(player: playerType, timing: timing, itemID: itemID)
        .._changePokemonIndexes = [..._changePokemonIndexes]
        .._prevPokemonIndexes = [..._prevPokemonIndexes]
        ..extraArg1 = extraArg1
        ..extraArg2 = extraArg2;

  @override
  String displayName({required AppLocalizations loc}) =>
      PokeDB().items[itemID]!.displayName;

  @override
  PlayerType get playerType => _playerType;

  @override
  set playerType(type) => _playerType = type;

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getChangePokemonIndex(PlayerType player) {
    if (player == PlayerType.me) {
      return _changePokemonIndexes[0];
    }
    return _changePokemonIndexes[1];
  }

  /// 交換先ポケモンのパーティ内インデックス(1始まり)を設定する
  /// nullを設定すると交換していないことを表す
  /// ```
  /// player: 行動主
  /// prev: 交換前ポケモンのパーティ内インデックス(1始まり)
  /// val: 交換先ポケモンのパーティ内インデックス(1始まり)
  /// ```
  @override
  void setChangePokemonIndex(PlayerType player, int? prev, int? val) {
    if (player == PlayerType.me) {
      _changePokemonIndexes[0] = val;
      _prevPokemonIndexes[0] = prev;
    } else {
      _changePokemonIndexes[1] = val;
      _prevPokemonIndexes[1] = prev;
    }
  }

  /// 交換前ポケモンのパーティ内インデックス(1始まり)を返す。
  /// 交換していなければnullを返す
  /// ```
  /// player: 行動主
  /// ```
  @override
  int? getPrevPokemonIndex(PlayerType player) {
    if (player == PlayerType.me) {
      return _prevPokemonIndexes[0];
    }
    return _prevPokemonIndexes[1];
  }

  /// 効果のextraArg等を編集するWidgetを返す
  /// ```
  /// myState: 効果の主のポケモンの状態
  /// yourState: 効果の主の相手のポケモンの状態
  /// ownParty: 自身(ユーザー)のパーティ
  /// opponentParty: 対戦相手のパーティ
  /// state: フェーズの状態
  /// controller: テキスト入力コントローラ
  /// ```
  @override
  Widget editArgWidget(
    PokemonState myState,
    PokemonState yourState,
    Party ownParty,
    Party opponentParty,
    PhaseState state,
    TextEditingController controller,
    TextEditingController controller2, {
    required AppLocalizations loc,
    required ThemeData theme,
  }) {
    final myParty = playerType == PlayerType.me ? ownParty : opponentParty;
    final yourParty = playerType == PlayerType.me ? opponentParty : ownParty;
    final pokeSelectKey = Key('ItemEffectSelectPokemon');
    switch (itemID) {
      case 184: // スターのみ
        return Row(
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                items: <DropdownMenuItem>[
                  for (final statIndex in StatIndexList.listAtoS)
                    DropdownMenuItem(
                      value: statIndex.index - 1,
                      child: Text(statIndex.name),
                    ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1 = value,
                textValue: StatIndex.values[extraArg1 + 1].name,
                isInput: true,
              ),
            ),
            Text(loc.battleRankUp1),
          ],
        );
      case 247: // いのちのたま
      case 265: // くっつきバリ
      case 258: // くろいヘドロ
      case 211: // たべのこし
      case 132: // オレンのみ
      case 135: // オボンのみ
      case 185: // ナゾのみ
      case 230: // かいがらのすず
      case 43: // きのみジュース
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
          }
          return DamageIndicateRow(
            myState.pokemon,
            controller,
            playerType == PlayerType.me,
            (value) {
              int val = myState.remainHP - (int.tryParse(value) ?? 0);
              if (playerType == PlayerType.opponent) {
                val = myState.remainHPPercent - (int.tryParse(value) ?? 0);
              }
              extraArg1 = val;
              return extraArg1;
            },
            extraArg1,
            true,
            loc: loc,
          );
        }
      case 136: // フィラのみ
      case 137: // ウイのみ
      case 138: // マゴのみ
      case 139: // バンジのみ
      case 140: // イアのみ
        {
          if (playerType == PlayerType.me) {
            controller.text = (myState.remainHP - extraArg1).toString();
          } else {
            controller.text = (myState.remainHPPercent - extraArg1).toString();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                Flexible(
                  child: _myDropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      DropdownMenuItem(
                        value: 0,
                        child: Text(loc.battleHPRecovery),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text(loc.battleConfused2),
                      ),
                    ],
                    value: extraArg2,
                    onChanged: (value) => extraArg2 = value,
                    textValue: extraArg2 == 0
                        ? loc.battleHPRecovery
                        : extraArg1 == 1
                            ? loc.battleConfused2
                            : '',
                    isInput: true,
                  ),
                ),
              ]),
              extraArg2 == 0
                  ? SizedBox(
                      height: 10,
                    )
                  : Container(),
              extraArg2 == 0
                  ? DamageIndicateRow(
                      myState.pokemon,
                      controller,
                      playerType == PlayerType.me,
                      (value) {
                        int val = myState.remainHP - (int.tryParse(value) ?? 0);
                        if (playerType == PlayerType.opponent) {
                          val = myState.remainHPPercent -
                              (int.tryParse(value) ?? 0);
                        }
                        extraArg1 = val;
                        return extraArg1;
                      },
                      extraArg1,
                      true,
                      loc: loc,
                    )
                  : Container(),
            ],
          );
        }
      case 583: // ゴツゴツメット
      case 188: // ジャポのみ
      case 189: // レンブのみ
        {
          if (playerType == PlayerType.me) {
            controller.text =
                (yourState.remainHPPercent - extraArg1).toString();
          } else {
            controller.text = (yourState.remainHP - extraArg1).toString();
          }
          return DamageIndicateRow(
            yourState.pokemon,
            controller,
            playerType != PlayerType.me,
            (value) {
              int val = yourState.remainHPPercent - (int.tryParse(value) ?? 0);
              if (playerType == PlayerType.opponent) {
                val = yourState.remainHP - (int.tryParse(value) ?? 0);
              }
              extraArg1 = val;
              return extraArg1;
            },
            extraArg1,
            true,
            loc: loc,
          );
        }
      case 584: // ふうせん
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: 0,
                    child: Text(loc.battleBalloonFloat),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(loc.battleBalloonBurst),
                  ),
                ],
                value: extraArg1,
                onChanged: (value) => extraArg1 = value,
                textValue: extraArg1 == 0
                    ? loc.battleBalloonFloat
                    : extraArg1 == 1
                        ? loc.battleBalloonBurst
                        : '',
                isInput: true,
              ),
            ),
          ],
        );
      case 585: // レッドカード
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                key: pokeSelectKey,
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battlePokemonToChange,
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < yourParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i + 1,
                      enabled:
                          state.isPossibleBattling(playerType.opposite, i) &&
                              !state
                                  .getPokemonStates(playerType.opposite)[i]
                                  .isFainting,
                      theme: theme,
                      pokemon: yourParty.pokemons[i]!,
                      showNetworkImage: PokeDB().getPokeAPI,
                    ),
                ],
                value: getChangePokemonIndex(playerType),
                onChanged: (value) => setChangePokemonIndex(playerType.opposite,
                    state.getPokemonIndex(playerType.opposite, null), value),
                textValue: null,
                isInput: true,
                prefixIconPokemon: null,
                showNetworkImage: PokeDB().getPokeAPI,
                theme: theme,
              ),
            ),
          ],
        );
      case 1699: // ものまねハーブ
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonAttack}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankAMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[0] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[0],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[0] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[0] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[0])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonDefense}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankBMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[1] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[1],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[1] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[1] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[1])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonSAttack}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankCMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[2] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[2],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[2] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[2] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[2])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonSDefense}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankDMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[3] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[3],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[3] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[3] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[3])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonSpeed}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankSMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[4] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[4],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[4] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[4] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[4])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonAccuracy}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankAcMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[5] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[5],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[5] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[5] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[5])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${loc.commonEvasiveness}:'),
                Flexible(
                  child: _myDropdownButtonFormField(
                    key: Key('ItemEffectRankEvMenu'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    items: <DropdownMenuItem>[
                      for (int i = 0; i <= 6; i++)
                        DropdownMenuItem(
                          value: i,
                          enabled: true,
                          child: Center(child: Text('+$i')),
                        ),
                    ],
                    value: PokemonState.unpackStatChanges(extraArg1)[6] < 0
                        ? 0
                        : PokemonState.unpackStatChanges(extraArg1)[6],
                    onChanged: (value) {
                      var statChanges =
                          PokemonState.unpackStatChanges(extraArg1);
                      statChanges[6] = value;
                      extraArg1 = PokemonState.packStatChanges(statChanges);
                    },
                    textValue: (PokemonState.unpackStatChanges(extraArg1)[6] < 0
                            ? 0
                            : PokemonState.unpackStatChanges(extraArg1)[6])
                        .toString(),
                    isInput: true,
                  ),
                ),
              ],
            ),
          ],
        );
      case 1177: // だっしゅつパック
      case 590: // だっしゅつボタン
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _myDropdownButtonFormField(
                key: pokeSelectKey,
                isExpanded: true,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.battlePokemonToChange,
                ),
                items: <DropdownMenuItem>[
                  for (int i = 0; i < myParty.pokemonNum; i++)
                    PokemonDropdownMenuItem(
                      value: i + 1,
                      enabled: state.isPossibleBattling(playerType, i) &&
                          !state.getPokemonStates(playerType)[i].isFainting,
                      theme: theme,
                      pokemon: myParty.pokemons[i]!,
                      showNetworkImage: PokeDB().getPokeAPI,
                    ),
                ],
                value: getChangePokemonIndex(playerType),
                onChanged: (value) => setChangePokemonIndex(
                    playerType, state.getPokemonIndex(playerType, null), value),
                textValue: null,
                isInput: true,
                prefixIconPokemon: null,
                showNetworkImage: PokeDB().getPokeAPI,
                theme: theme,
              ),
            ),
          ],
        );
    }
    return Container();
  }

  @override
  List<Guide> processEffect(
      Party ownParty,
      PokemonState ownState,
      Party opponentParty,
      PokemonState opponentState,
      PhaseState state,
      TurnEffectAction? prevAction,
      {bool autoConsume = true,
      required AppLocalizations loc}) {
    final pokeData = PokeDB();
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
    super.beforeProcessEffect(ownState, opponentState);
    List<Guide> ret = [];
    if (playerType == PlayerType.opponent &&
        myState.getHoldingItem()?.id == 0) {
      ret.add(Guide()
        ..guideId = Guide.confItem
        ..args = [itemID]
        ..guideStr = loc.battleGuideConfItem2(
            pokeData.items[itemID]!.displayName, myState.pokemon.omittedName));
    }
    // 既にもちものがわかっている場合は代入しない(代入によってbuffを追加してしまうから)
    if (myState.holdingItem == null || myState.getHoldingItem()?.id != itemID) {
      myState.holdingItem = pokeData.items[itemID];
    }
    bool doubleBerry = myState.buffDebuffs.containsByID(BuffDebuff.nuts2);

    switch (itemID) {
      case 161: // オッカのみ
      case 162: // イトケのみ
      case 163: // ソクノのみ
      case 164: // リンドのみ
      case 165: // ヤチェのみ
      case 166: // ヨプのみ
      case 167: // ビアーのみ
      case 168: // シュカのみ
      case 169: // バコウのみ
      case 170: // ウタンのみ
      case 171: // タンガのみ
      case 172: // ヨロギのみ
      case 173: // カシブのみ
      case 174: // ハバンのみ
      case 175: // ナモのみ
      case 176: // リリバのみ
      case 723: // ロゼルのみ
      case 177: // ホズのみ
        // ダメージ軽減効果はわざのダメージ計算時に使う
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.halvedBerry)
          ..extraArg1 = doubleBerry ? 1 : 0);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 187: // イバンのみ
      case 248: // パワフルハーブ
      case 669: // ノーマルジュエル
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 194: // せんせいのツメ
        myState.holdingItem = pokeData.items[itemID];
        break;
      case 178: // チイラのみ
        myState.addStatChanges(true, 0, doubleBerry ? 2 : 1, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 589: // じゅうでんち
      case 689: // ゆきだま
        myState.addStatChanges(true, 0, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 179: // リュガのみ
      case 724: // アッキのみ
        myState.addStatChanges(true, 1, doubleBerry ? 2 : 1, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 898: // エレキシード
      case 901: // グラスシード
        myState.addStatChanges(true, 1, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 181: // ヤタピのみ
        myState.addStatChanges(true, 2, doubleBerry ? 2 : 1, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 588: // きゅうこん
      case 1176: // のどスプレー
        myState.addStatChanges(true, 2, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 182: // ズアのみ
      case 725: // タラプのみ
        myState.addStatChanges(true, 3, doubleBerry ? 2 : 1, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 688: // ひかりごけ
      case 899: // サイコシード
      case 900: // ミストシード
        myState.addStatChanges(true, 3, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 180: // カムラのみ
        myState.addStatChanges(true, 4, doubleBerry ? 2 : 1, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 883: // ビビリだま
        myState.addStatChanges(true, 4, 1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 183: // サンのみ
        myState.addVitalRank(doubleBerry ? 2 : 1);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 184: // スターのみ
        myState.addStatChanges(true, extraArg1, doubleBerry ? 4 : 2, yourState,
            itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 186: // ミクルのみ
        myState.buffDebuffs.add(BuffDebuff(BuffDebuff.onceAccuracy1_2));
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 188: // ジャポのみ
      case 189: // レンブのみ
        if (playerType == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        } else {
          yourState.remainHP -= extraArg1;
        }
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 191: // しろいハーブ
        myState.resetDownedStatChanges();
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 682: // じゃくてんほけん
        myState.addStatChanges(true, 0, 2, yourState, itemId: itemID);
        myState.addStatChanges(true, 2, 2, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 247: // いのちのたま
      case 265: // くっつきバリ
      case 258: // くろいヘドロ
      case 211: // たべのこし
      case 230: // かいがらのすず
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        break;
      case 132: // オレンのみ
      case 43: // きのみジュース
      case 135: // オボンのみ
      case 185: // ナゾのみ
        if (playerType == PlayerType.me) {
          myState.remainHP -= extraArg1;
        } else {
          myState.remainHPPercent -= extraArg1;
        }
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 136: // フィラのみ
      case 137: // ウイのみ
      case 138: // マゴのみ
      case 139: // バンジのみ
      case 140: // イアのみ
        if (extraArg2 == 0) {
          if (playerType == PlayerType.me) {
            myState.remainHP -= extraArg1;
          } else {
            myState.remainHPPercent -= extraArg1;
          }
        } else {
          myState.ailmentsAdd(Ailment(Ailment.confusion), state);
        }
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 126: // クラボのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.paralysis);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 127: // カゴのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.sleep);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 128: // モモンのみ
        {
          myState.ailmentsRemoveWhere(
              (e) => e.id == Ailment.poison || e.id == Ailment.badPoison);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 129: // チーゴのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.burn);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 130: // ナナシのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.freeze);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 133: // キーのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id == Ailment.confusion);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 134: // ラムのみ
        {
          myState.ailmentsRemoveWhere((e) => e.id <= Ailment.confusion);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 196: // メンタルハーブ
        {
          myState.ailmentsRemoveWhere((e) =>
              e.id == Ailment.infatuation ||
              e.id == Ailment.encore ||
              e.id == Ailment.torment ||
              e.id == Ailment.disable ||
              e.id == Ailment.taunt ||
              e.id == Ailment.healBlock);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 249: // どくどくだま
        myState.ailmentsAdd(Ailment(Ailment.badPoison), state);
        break;
      case 250: // かえんだま
        myState.ailmentsAdd(Ailment(Ailment.burn), state);
        break;
      case 257: // あかいいと
        yourState.ailmentsAdd(Ailment(Ailment.infatuation), state);
        break;
      case 207: // きあいのハチマキ
        if (playerType == PlayerType.me) {
          myState.remainHP == 1;
        } else {
          myState.remainHPPercent == 1;
        }
        break;
      case 252: // きあいのタスキ
        if (playerType == PlayerType.me) {
          myState.remainHP == 1;
        } else {
          myState.remainHPPercent == 1;
        }
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 583: // ゴツゴツメット
        if (playerType == PlayerType.me) {
          yourState.remainHPPercent -= extraArg1;
        } else {
          yourState.remainHP -= extraArg1;
        }
        break;
      case 584: // ふうせん
        if (extraArg1 != 0) {
          // ふうせんが割れたとき
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 585: // レッドカード
        int? val = getChangePokemonIndex(playerType.opposite);
        if (val != null && val != 0) {
          yourState.processExitEffect(myState, state);
          state.setPokemonIndex(playerType.opposite, val);
          PokemonState newState;
          newState = state.getPokemonState(playerType.opposite, null);
          newState.processEnterEffect(myState, state);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 1177: // だっしゅつパック
      case 590: // だっしゅつボタン
        int? val = getChangePokemonIndex(playerType.opposite);
        if (val != null && val != 0) {
          myState.processExitEffect(yourState, state);
          state.setPokemonIndex(playerType, val);
          PokemonState newState;
          newState = state.getPokemonState(playerType, null);
          newState.processEnterEffect(yourState, state);
          if (autoConsume) myState.holdingItem = null; // アイテム消費
        }
        break;
      case 1179: // からぶりほけん
        myState.addStatChanges(true, 4, 2, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 1180: // ルームサービス
        myState.addStatChanges(true, 4, -1, yourState, itemId: itemID);
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      case 1699: // ものまねハーブ
        var statChanges = PokemonState.unpackStatChanges(extraArg1);
        for (int i = 0; i < 7; i++) {
          myState.addStatChanges(true, i, statChanges[i], yourState,
              itemId: itemID);
        }
        if (autoConsume) myState.holdingItem = null; // アイテム消費
        break;
      default:
        break;
    }

    super.afterProcessEffect(ownState, opponentState, state);

    return ret;
  }

  @override
  bool isValid() =>
      playerType != PlayerType.none && timing != Timing.none && itemID != 0;

  /// 現在のポケモンの状態等から決定できる引数を自動で設定
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
  ) {
    extraArg1 = 0;
    extraArg2 = 0;
    bool isMe = playerType == PlayerType.me;
    bool doubleBerry = myState.buffDebuffs.containsByID(BuffDebuff.nuts2);

    switch (itemID) {
      case 247: // いのちのたま
        extraArg1 = isMe ? (myState.pokemon.h.real / 10).floor() : 10;
        return;
      case 583: // ゴツゴツメット
        extraArg1 = !isMe ? (yourState.pokemon.h.real / 6).floor() : 16;
        return;
      case 188: // ジャポのみ
      case 189: // レンブのみ
        extraArg1 = !isMe
            ? (yourState.pokemon.h.real / (doubleBerry ? 4 : 8)).floor()
            : (doubleBerry ? 25 : 12);
        return;
      case 584: // ふうせん
        if (timing != Timing.pokemonAppear) {
          extraArg1 = 1;
        }
        return;
      case 265: // くっつきバリ
        extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        return;
      case 132: // オレンのみ
        if (isMe) extraArg1 = doubleBerry ? -20 : -10;
        return;
      case 43: // きのみジュース
        if (isMe) extraArg1 = -20;
        return;
      case 135: // オボンのみ
      case 185: // ナゾのみ
        extraArg1 = isMe
            ? -(myState.pokemon.h.real / (doubleBerry ? 2 : 4)).floor()
            : (doubleBerry ? -50 : -25);
        return;
      case 136: // フィラのみ
      case 137: // ウイのみ
      case 138: // マゴのみ
      case 139: // バンジのみ
      case 140: // イアのみ
        extraArg1 = isMe
            ? -(myState.pokemon.h.real * (doubleBerry ? 2 : 1) / 3).floor()
            : (doubleBerry ? -66 : -33);
        return;
      case 258: // くろいヘドロ
        if (myState.isTypeContain(PokeType.poison)) {
          // どくタイプか
          extraArg1 = isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
        } else {
          extraArg1 = isMe ? (myState.pokemon.h.real / 8).floor() : 12;
        }
        return;
      case 211: // たべのこし
        extraArg1 = isMe ? -(myState.pokemon.h.real / 16).floor() : -6;
        return;
      case 1699: // ものまねハーブ
        extraArg1 = 0x06666666;
        return;
      default:
        return;
    }
  }

  /// extraArg等以外同じ、ほぼ同じかどうか
  /// ```
  /// allowTimingDiff: タイミングが異なっていても同じとみなすかどうか
  /// ```
  @override
  bool nearEqual(
    TurnEffect t, {
    bool allowTimingDiff = false,
  }) {
    return t.runtimeType == TurnEffectItem &&
        playerType == t.playerType &&
        (allowTimingDiff || timing == t.timing) &&
        itemID == (t as TurnEffectItem).itemID;
  }

  // SQLに保存された文字列からTurnEffectItemをパース
  static TurnEffectItem deserialize(
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
    // itemID
    final itemID = int.parse(turnEffectElements.removeAt(0));
    TurnEffectItem turnEffect =
        TurnEffectItem(player: playerType, timing: timing, itemID: itemID);
    // _changePokemonIndexes
    var changePokemonIndexes = turnEffectElements.removeAt(0).split(split2);
    for (int i = 0; i < 2; i++) {
      if (changePokemonIndexes[i] == '') {
        turnEffect._changePokemonIndexes[i] = null;
      } else {
        turnEffect._changePokemonIndexes[i] =
            int.parse(changePokemonIndexes[i]);
      }
    }
    // _prevPokemonIndexes
    var prevPokemonIndexes = turnEffectElements.removeAt(0).split(split2);
    for (int i = 0; i < 2; i++) {
      if (prevPokemonIndexes[i] == '') {
        turnEffect._prevPokemonIndexes[i] = null;
      } else {
        turnEffect._prevPokemonIndexes[i] = int.parse(prevPokemonIndexes[i]);
      }
    }
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
    // playerType
    ret += playerType.number.toString();
    ret += split1;
    // timing
    ret += timing.index.toString();
    ret += split1;
    // itemID
    ret += itemID.toString();
    ret += split1;
    // _changePokemonIndex
    for (int i = 0; i < 2; i++) {
      if (_changePokemonIndexes[i] != null) {
        ret += _changePokemonIndexes[i].toString();
      }
      ret += split2;
    }
    ret += split1;
    // _prevPokemonIndex
    for (int i = 0; i < 2; i++) {
      if (_prevPokemonIndexes[i] != null) {
        ret += _prevPokemonIndexes[i].toString();
      }
      ret += split2;
    }
    ret += split1;
    // extraArg1
    ret += extraArg1.toString();
    ret += split1;
    // extraArg2
    ret += extraArg2.toString();

    return ret;
  }

  /// カスタムしたDropdownButtonFormField
  /// ```
  /// onFocus: フォーカスされたとき(タップされたとき)に呼ぶコールバック
  /// isInput: 入力モードかどうか
  /// textValue: 出力文字列(isInput==falseのとき必須)
  /// prefixIconPokemon: フィールド前に配置するアイコンのポケモン
  /// showNetworkImage: インターネットから取得したポケモンの画像を使うかどうか
  /// ```
  Widget _myDropdownButtonFormField<T>({
    Key? key,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    T? value,
    Widget? hint,
    Widget? disabledHint,
    required ValueChanged<T?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    required bool isInput,
    required String? textValue,
    Pokemon? prefixIconPokemon,
    bool showNetworkImage = false,
    ThemeData? theme,
  }) {
    if (isInput) {
      return DropdownButtonFormField(
        key: key,
        items: items,
        selectedItemBuilder: selectedItemBuilder,
        value: value,
        hint: hint,
        disabledHint: disabledHint,
        onChanged: onChanged,
        onTap: onTap,
        elevation: elevation,
        style: style,
        icon: icon,
        iconDisabledColor: iconDisabledColor,
        iconEnabledColor: iconEnabledColor,
        iconSize: iconSize,
        isDense: isDense,
        isExpanded: isExpanded,
        itemHeight: itemHeight,
        focusColor: focusColor,
        focusNode: focusNode,
        autofocus: autofocus,
        dropdownColor: dropdownColor,
        decoration: decoration,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        menuMaxHeight: menuMaxHeight,
        enableFeedback: enableFeedback,
        alignment: alignment,
        borderRadius: borderRadius,
        padding: padding,
      );
    } else {
      return TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: decoration?.labelText,
          prefixIcon: prefixIconPokemon != null
              ? showNetworkImage
                  ? Image.network(
                      PokeDB().pokeBase[prefixIconPokemon.no]!.imageUrl,
                      height: theme?.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    )
                  : const Icon(Icons.catching_pokemon)
              : null,
        ),
        controller: TextEditingController(
          text: textValue,
        ),
        readOnly: true,
      );
    }
  }
}
