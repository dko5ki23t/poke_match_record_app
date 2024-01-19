import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/move_view_row.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/custom_widgets/stat_total_row.dart';
import 'package:poke_reco/custom_widgets/stat_view_row.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewPokemonPage extends StatefulWidget {
  ViewPokemonPage({
    Key? key,
    required this.onEdit,
    required this.pokemonList,
    required this.listIndex,
  }) : super(key: key);

  final void Function(Pokemon) onEdit;
  final List<Pokemon> pokemonList;
  final int listIndex;

  @override
  ViewPokemonPageState createState() => ViewPokemonPageState();
}

class ViewPokemonPageState extends State<ViewPokemonPage> {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );
  final pokeNameController = TextEditingController();
  final pokeNickNameController = TextEditingController();
  final pokeType1Controller = TextEditingController();
  final pokeType2Controller = TextEditingController();
  final pokeTeraTypeController = TextEditingController();
  final pokeNoController = TextEditingController();
  final pokeLevelController = TextEditingController();
  final pokeTemperController = TextEditingController();
  final pokeAbilityController = TextEditingController();
  final pokeStatRaceController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatIndiController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatEffortController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatRealController = List.generate(StatIndex.size.index, (i) => TextEditingController());
  bool isFirstBuild = true;
  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;
    var myPokemon = widget.pokemonList[widget.listIndex];
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;

    if (isFirstBuild) {
      listIndex = widget.listIndex;
      isFirstBuild = false;
    }
    else {
      myPokemon = widget.pokemonList[listIndex];
    }
    
    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    pokeNameController.text = myPokemon.name;
    pokeNickNameController.text = myPokemon.nickname;
    pokeType1Controller.text = myPokemon.type1.displayName;
    pokeType2Controller.text = myPokemon.type2 != null ? myPokemon.type2!.displayName : '';
    pokeTeraTypeController.text = myPokemon.teraType.displayName;
    pokeNoController.text = myPokemon.no.toString();
    pokeLevelController.text = myPokemon.level.toString();
    pokeTemperController.text = myPokemon.temper.displayName;
    pokeAbilityController.text = myPokemon.ability.displayName;
    pokeStatRaceController[0].text = myPokemon.name == '' ? 'H -' : 'H ${myPokemon.h.race}';
    pokeStatRaceController[1].text = myPokemon.name == '' ? 'A -' : 'A ${myPokemon.a.race}';
    pokeStatRaceController[2].text = myPokemon.name == '' ? 'B -' : 'B ${myPokemon.b.race}';
    pokeStatRaceController[3].text = myPokemon.name == '' ? 'C -' : 'C ${myPokemon.c.race}';
    pokeStatRaceController[4].text = myPokemon.name == '' ? 'D -' : 'D ${myPokemon.d.race}';
    pokeStatRaceController[5].text = myPokemon.name == '' ? 'S -' : 'S ${myPokemon.s.race}';
    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatIndiController[i].text = myPokemon.stats[i].indi.toString();
      pokeStatEffortController[i].text = myPokemon.stats[i].effort.toString();
      pokeStatRealController[i].text = myPokemon.stats[i].real.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${myPokemon.nickname}/${myPokemon.name}'),
        actions: [
          MyIconButton(
            onPressed: listIndex != 0 ? () => setState(() {
              listIndex--;
            }) : null,
            theme: theme,
            icon: Icon(Icons.arrow_upward),
            tooltip: loc.viewToolTipPrev,
          ),
          MyIconButton(
            onPressed: listIndex + 1 < widget.pokemonList.length ? () => setState(() {
              listIndex++;
            }) : null,
            theme: theme,
            icon: Icon(Icons.arrow_downward),
            tooltip: loc.viewToolTipNext,
          ),
          MyIconButton(
            onPressed: () => widget.onEdit(myPokemon),
            theme: theme,
            icon: Icon(Icons.edit),
            tooltip: loc.viewToolTipEdit,
          ),
        ]
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(  // ポケモン名, 図鑑No
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 7,
                      child: TextField(
                        controller: pokeNameController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.pokemonsTabPokemonName,
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: pokeData.getPokeAPI ?
                        Image.network(
                          pokeData.pokeBase[myPokemon.no]!.imageUrl,
                          errorBuilder: (c, o, s) {
                            return const Icon(Icons.catching_pokemon);
                          },
                        ) : const Icon(Icons.catching_pokemon),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // ニックネーム
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.pokemonsTabNickName,
                        ),
                        readOnly: true,
                        maxLength: 20,
                        controller: pokeNickNameController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // タイプ1, タイプ2, テラスタイプ
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonType1,
                          prefixIcon: myPokemon.type1.displayIcon,
                        ),
                        readOnly: true,
                        controller: pokeType1Controller,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonType2,
                          prefixIcon: myPokemon.type2?.displayIcon,
                        ),
                        readOnly: true,
                        controller: pokeType2Controller,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonTeraType,
                          prefixIcon: myPokemon.teraType.displayIcon,
                        ),
                        readOnly: true,
                        controller: pokeTeraTypeController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // レベル, せいべつ
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: pokeLevelController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonLevel,
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonGender,
                        ),
                        items: <DropdownMenuItem<Sex>>[
                          for (var type in pokeData.pokeBase[myPokemon.no]!.sex)
                            DropdownMenuItem(
                              value: type,
                              child: type.displayIcon,
                          ),
                        ],
                        value: myPokemon.sex,
                        onChanged: null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(  // せいかく, とくせい
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: pokeTemperController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonNature,
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: loc.commonAbility,
                          suffix: AbilityTooltip(
                            ability: myPokemon.ability,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(Icons.help),
                          ),
                        ),
                        readOnly: true,
                        controller: pokeAbilityController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ の数値入力
                for (int i = 0; i < StatIndex.size.index; i++)
                  Column(
                    children: [
                      StatViewRow(
                        StatIndexNumber.getStatIndexFromIndex(i).name,
                        myPokemon,
                        pokeStatRaceController[i],
                        pokeStatIndiController[i],
                        pokeStatEffortController[i],
                        pokeStatRealController[i],
                        effectTemper: i != 0,
                        statIndex: StatIndexNumber.getStatIndexFromIndex(i),
                        loc: loc,
                      ),
                    ]
                  ),
                // ステータスの合計値
                StatTotalRow(myPokemon.totalRace(), myPokemon.totalEffort(), loc: loc,),
                SizedBox(height: 10,),
                Text(loc.pokemonsTabRememberingMoves,),
                SizedBox(height: 5,),
                // わざ1, PP1, わざ2, PP2, わざ3, PP3, わざ4, PP4
                for (int i = 0; i < myPokemon.moveNum; i++)
                  Column(children: [
                    MoveViewRow(
                      theme,
                      myPokemon.moves[i]!,
                      myPokemon.pps[i]!,
                      loc: loc,
                    ),
                  ],),

                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}