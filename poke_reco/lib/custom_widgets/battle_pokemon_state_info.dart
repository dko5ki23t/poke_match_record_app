import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

class BattlePokemonStateInfo extends StatefulWidget {
  const BattlePokemonStateInfo({
    Key? key,
    required this.focusState,
    required this.playerType,
    required this.playerName,
  }) : super(key: key);

  final PhaseState focusState;
  final PlayerType playerType;
  final String playerName;

  @override
  BattlePokemonStateInfoState createState() => BattlePokemonStateInfoState();
}

class BattlePokemonStateInfoState extends State<BattlePokemonStateInfo> {
  static const statAlphabets = ['A ', 'B ', 'C ', 'D ', 'S ', 'Ac', 'Ev'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    final pokeData = PokeDB();
    final focusState = widget.focusState;
    final playerType = widget.playerType;
    final focusingPokemonState = focusState.getPokemonState(playerType, null);
    final focusingPokemon = focusingPokemonState.pokemon;
    final PageController controller = PageController();

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: FittedBox(
            child: Column(
              children: [
                // ポケモン画像/アイコン
                pokeData.getPokeAPI ?
                Image.network(
                  pokeData.pokeBase[focusingPokemon.no]!.imageUrl,
                  height: theme.buttonTheme.height * 1.5,
                  errorBuilder: (c, o, s) {
                    return const Icon(Icons.catching_pokemon);
                  },
                ) : const Icon(Icons.catching_pokemon),
                // ポケモン名
                Text('${focusingPokemon.name}/${widget.playerName}', overflow: TextOverflow.ellipsis,),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(fit:FlexFit.loose, child: Text('Lv.${focusingPokemon.level}', overflow: TextOverflow.ellipsis,)),
                  Flexible(fit:FlexFit.loose, child: focusingPokemonState.sex.displayIcon),
                ],),
                // タイプ
                focusingPokemonState.isTerastaling ?
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(fit:FlexFit.loose, child: Text(loc.commonTerastal)),
                  Flexible(fit:FlexFit.loose, child: focusingPokemonState.teraType1.displayIcon),
                ],) :
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(fit:FlexFit.loose, child: focusingPokemonState.type1.displayIcon),
                  focusingPokemonState.type2 != null ?
                  Flexible(fit:FlexFit.loose, child: focusingPokemonState.type2!.displayIcon) : Container(),
                ],),
                // とくせい/もちもの
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(fit:FlexFit.loose, child: AbilityText(focusingPokemonState.currentAbility, showHatena: true,),),
                  ItemText(focusingPokemonState.holdingItem, showHatena: true, showNone: true, loc: loc,),
                ],),
                // HP
        //        isEditMode ?
        //        _HPInputRow(
        //          ownHPController, opponentHPController,
        //          (userForce) => userForceAdd(focusPhaseIdx, userForce)) :
                hpBarRow(
                  playerType,
                  playerType == PlayerType.me ? focusingPokemonState.remainHP : focusingPokemonState.remainHPPercent,
                  playerType == PlayerType.me ? focusingPokemon.h.real : 100,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          // 各ステータス(HABCDS)の実数値/各ステータス(ABCDSAcEv)の変化/状態変化
          // TODO
          child: PageView(
            controller: controller,
            children: [
              // 1. 各ステータス(HABCDS)の種族値
              FittedBox(
                child: Column(
                  children: [
                    Text('種族値'),
                    for (final stat in StatIndexList.listHtoS)
                    statStatusViewRow(
                      stat.alphabet,
                      focusingPokemonState.minStats[stat].race,
                      focusingPokemonState.maxStats[stat].race,
                    ),
                  ],
                ),
              ),
              // 2. 各ステータス(HABCDS)の実数値
              FittedBox(
                child: Column(
                  children: [
                    Text('実数値'),
                    for (final stat in StatIndexList.listHtoS)
                    statStatusViewRow(
                      stat.alphabet,
                      focusingPokemonState.minStats[stat].real,
                      focusingPokemonState.maxStats[stat].real,
                    ),
                  ],
                ),
              ),
              // 3. 各ステータス(ABCDSAcEv)のランク変化
              FittedBox(
                child: Column(
                  children: [
                    Text('ランク'),
                    for (int i = 0; i < 7; i++)
                    statChangeViewRow(
                      statAlphabets[i], focusingPokemonState.statChanges(i), 
                      (idx) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget hpBarRow (PlayerType playerType, int remainHP, int? maxHP,) {
    int maxHPRe = playerType != PlayerType.me || maxHP == null ? 100 : maxHP;
    String suffix = playerType != PlayerType.me ? '%' : '';
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Container(
                  width: 150,
                  height: 20,
                  color: Colors.grey),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Container(
                  width: (remainHP / maxHPRe) * 150,
                  height: 20,
                  color: (remainHP / maxHPRe) <= 0.25 ? Colors.red : (remainHP / maxHPRe) <= 0.5 ? Colors.yellow : Colors.lightGreen,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: SizedBox(
                  width: 150,
                  height: 20,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('$remainHP$suffix/$maxHPRe$suffix'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget statChangeViewRow (
    String label,
    int statChange,
    void Function(int idx) onOwnPressed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(children: [
            Text(label),
            for (int i = 0; i < statChange.abs(); i++)
            statChange > 0 ?
              GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.arrow_drop_up, color: Colors.red)) :
              GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.arrow_drop_down, color: Colors.blue)),
            for (int i = statChange.abs(); i < 6; i++)
              GestureDetector(onTap: () => onOwnPressed(i), child: Icon(Icons.remove, color: Colors.grey)),
          ],),
        ),
      ],
    );
  }

  Widget statStatusViewRow(
    String label,
    int statusMin,
    int statusMax,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(children: [
            Text(label),
            statusMin == statusMax ?
            Text(statusMin.toString()) :
            Text('$statusMin ~ $statusMax'),
          ],),
        ),
      ],
    );
  }
}
