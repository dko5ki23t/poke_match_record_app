import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/pokemon_dropdown_menu_item.dart';
import 'package:poke_reco/data_structs/guide.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/turn.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleChangeFaintingPokemonColumn extends Column {
  BattleChangeFaintingPokemonColumn(
    PhaseState prevState,       // 直前までの状態
    ThemeData theme,
    Battle battle,
    Turn turn,
    MyAppState appState,
    int focusPhaseIdx,
    void Function(int) onFocus,
    int phaseIdx,
    Timing timing,
    List<TextEditingController> moveControllerList,
    List<TextEditingController> hpControllerList,
    List<TextEditingController> textEditingControllerList3,
    List<Guide> guides,
    {
      required bool isInput,
      required AppLocalizations loc,
    }
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: focusPhaseIdx != phaseIdx+1 ? () => onFocus(phaseIdx+1) : () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: focusPhaseIdx == phaseIdx+1 ? Border.all(width: 3, color: Colors.orange) : Border.all(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              isInput ?
                Stack(
                  children: [
                  Center(child: Text(loc.battlePokemonChange)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                      appState.editingPhase[phaseIdx] ?
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: turn.phases[phaseIdx].isValid() ? () {
                          appState.editingPhase[phaseIdx] = false;
                          onFocus(phaseIdx+1);
                        } : null,
                      ) : Container(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          turn.phases[phaseIdx].effectId = 0;
                          onFocus(phaseIdx+1);
                        },
                      ),
                    ],
                  ),
                ],) :
                Center(child: Text(loc.battlePokemonChange)),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: isInput ?
                      DropdownButtonFormField(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePlayer,
                        ),
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            value: PlayerType.me,
                            child: Text(loc.battleYou, overflow: TextOverflow.ellipsis,),
                          ),
                          DropdownMenuItem(
                            value: PlayerType.opponent,
                            child: Text(battle.opponentName, overflow: TextOverflow.ellipsis,),
                          ),
                        ],
                        value: turn.phases[phaseIdx].playerType == PlayerType.none ? null : turn.phases[phaseIdx].playerType,
                        onChanged: null,
                      ) :
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePlayer,
                        ),
                        controller: TextEditingController(
                          text: turn.phases[phaseIdx].playerType == PlayerType.me ?
                                  loc.battleYou : battle.opponentName,
                        ),
                        readOnly: true,
                        onTap: () => onFocus(phaseIdx+1),
                      ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 5,
                    child: isInput ?
                      DropdownButtonFormField<bool>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battleSuccessFailureOfAction,
                        ),
                        items: <DropdownMenuItem<bool>>[
                          DropdownMenuItem(
                            value: true,
                            child: Text(loc.battleActionSuccessed, overflow: TextOverflow.ellipsis,),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(loc.battleActionFailed, overflow: TextOverflow.ellipsis,),
                          ),
                        ],
                        value: true,
                        onChanged: null,
                      ) :
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battleSuccessFailureOfAction,
                        ),
                        controller: TextEditingController(text: loc.battleActionSuccessed),
                        readOnly: true,
                        onTap: () => onFocus(phaseIdx+1),
                      ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: isInput ?
                      DropdownButtonFormField(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePokemonToChange,
                        ),
                        items: 
                          <DropdownMenuItem>[
                          for (int i = 0; i < battle.getParty(turn.phases[phaseIdx].playerType).pokemonNum; i++)
                            PokemonDropdownMenuItem(
                              value: i+1,
                              pokemon: battle.getParty(turn.phases[phaseIdx].playerType).pokemons[i]!,
                              theme: theme,
                              enabled: prevState.isPossibleBattling(turn.phases[phaseIdx].playerType, i) && !prevState.getPokemonStates(turn.phases[phaseIdx].playerType)[i].isFainting,
                              showNetworkImage: PokeDB().getPokeAPI,
                            ),
                          ],
                        value: turn.phases[phaseIdx].effectId == 0 ? null : turn.phases[phaseIdx].effectId,
                        onChanged: (value) {
                          turn.phases[phaseIdx].effectId = value;
                          appState.editingPhase[phaseIdx] = true;
                          onFocus(phaseIdx+1);
                        },
                      ) :
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.battlePokemonToChange,
                          prefixIcon: PokeDB().getPokeAPI ?
                            Image.network(
                              PokeDB().pokeBase[battle.getParty(turn.phases[phaseIdx].playerType).pokemons[turn.phases[phaseIdx].effectId-1]!.no]!.imageUrl,
                              height: theme.buttonTheme.height,
                              errorBuilder: (c, o, s) {
                                return const Icon(Icons.catching_pokemon);
                              },
                            ) : const Icon(Icons.catching_pokemon),
                        ),
                        controller: TextEditingController(
                          text: battle.getParty(turn.phases[phaseIdx].playerType).pokemons[turn.phases[phaseIdx].effectId-1]!.name
                        ),
                        readOnly: true,
                        onTap: () => onFocus(phaseIdx+1),
                      ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              for (final e in guides)
              Row(
                children: [
                  Expanded(child: Icon(Icons.info, color: Colors.lightGreen,)),
                  Expanded(flex: 10, child: Text(e.guideStr)),
                  e.canDelete && isInput ?
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        turn.phases[phaseIdx].invalidGuideIDs.add(e.guideId);
                        appState.needAdjustPhases = phaseIdx+1;
                        onFocus(phaseIdx+1);
                      },
                      icon: Icon(Icons.cancel, color: Colors.grey[800],),
                    ),
                   ) : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
