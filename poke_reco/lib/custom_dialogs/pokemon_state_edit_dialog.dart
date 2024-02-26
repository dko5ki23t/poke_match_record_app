import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/tool.dart';

class PokemonStateEditDialog extends StatefulWidget {
  final PokemonState pokemonState;
  final void Function(bool abilityChanged, Ability ability, bool itemChanged,
      Item? item, bool hpChanged, int remainHP) onApply;

  const PokemonStateEditDialog(
    this.pokemonState,
    this.onApply, {
    Key? key,
  }) : super(key: key);

  @override
  PokemonStateEditDialogState createState() => PokemonStateEditDialogState();
}

class PokemonStateEditDialogState extends State<PokemonStateEditDialog> {
  late final PokemonState pokemonState;
  TextEditingController abilityController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  late final PlayerType playerType;
  late final Ability initialAbility;
  late final Item? initialHoldingItem;
  late final int initialRemainHP;
  late Ability editingAbility;
  late Item? editingItem;
  late int editingRemainHP;
  late final int maxHP;

  @override
  void initState() {
    super.initState();
    pokemonState = widget.pokemonState;
    playerType = pokemonState.playerType;
    abilityController.text = pokemonState.currentAbility.displayName;
    itemController.text = pokemonState.holdingItem != null
        ? pokemonState.holdingItem!.displayName
        : '';
    initialAbility = editingAbility = pokemonState.currentAbility;
    initialHoldingItem = editingItem = pokemonState.holdingItem;
    initialRemainHP = editingRemainHP = playerType == PlayerType.me
        ? pokemonState.remainHP
        : pokemonState.remainHPPercent;
    maxHP = playerType == PlayerType.me ? pokemonState.pokemon.h.real : 100;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool abilityChanged = editingAbility != initialAbility;
    bool itemChanged = editingItem != initialHoldingItem;
    bool hpChanged = editingRemainHP != initialRemainHP;
    return AlertDialog(
      title: Text(pokemonState.pokemon.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // レベル
            Row(
              children: [
                Text('${loc.commonLevel} : '),
                Text('${pokemonState.pokemon.level}')
              ],
            ),
            // せいべつ
            Row(
              children: [
                Text('${loc.commonGender} : '),
                pokemonState.sex.displayIcon,
              ],
            ),
            // タイプ
            Row(
              children: [
                Text('${loc.commonType} : '),
                pokemonState.type1.displayIcon,
                pokemonState.type2 != null
                    ? pokemonState.type2!.displayIcon
                    : Container(),
              ],
            ),
            // テラスタイプ
            Row(
              children: [
                Text('${loc.commonTeraType} : '),
                pokemonState.isTerastaling
                    ? pokemonState.teraType1.displayIcon
                    : pokemonState.pokemon.teraType.displayIcon,
              ],
            ),
            // とくせい
            Row(
              children: [
                Text('${loc.commonAbility} : '),
                Expanded(
                  child: TypeAheadField(
                    key: Key('PokemonStateEditDialogAbility'),
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: abilityController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    autoFlipDirection: true,
                    onSuggestionsBoxToggle: (val) {
                      if (val) {
                        // 全選択
                        abilityController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: abilityController.value.text.length);
                      }
                    },
                    suggestionsCallback: (pattern) async {
                      List<Ability> matches = [
                        ...PokeDB().pokeBase[pokemonState.pokemon.no]!.ability
                      ];
                      matches.retainWhere((s) {
                        return toKatakana50(s.displayName.toLowerCase())
                            .contains(toKatakana50(pattern.toLowerCase()));
                      });
                      return matches;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.displayName),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      abilityController.text = suggestion.displayName;
                      editingAbility = suggestion;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            // もちもの
            Row(
              children: [
                Text('${loc.commonItem} : '),
                Expanded(
                  child: TypeAheadField(
                    key: Key('PokemonStateEditDialogItem'),
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: itemController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    autoFlipDirection: true,
                    onSuggestionsBoxToggle: (val) {
                      if (val) {
                        // 全選択
                        itemController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: itemController.value.text.length);
                      }
                    },
                    suggestionsCallback: (pattern) async {
                      List<Item> matches = [...PokeDB().items.values];
                      matches.retainWhere((s) {
                        return toKatakana50(s.displayName.toLowerCase())
                            .contains(toKatakana50(pattern.toLowerCase()));
                      });
                      return matches;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.displayName),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      itemController.text = suggestion.displayName;
                      editingItem = suggestion;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            // 残りHP
            Row(
              children: [
                Text('HP : '),
                Slider(
                  value: editingRemainHP.toDouble(),
                  max: maxHP.toDouble(),
                  divisions: maxHP,
                  //label: editingRemainHP.toString(),
                  onChanged: (val) => setState(() {
                    editingRemainHP = val.round();
                  }),
                ),
                Text(editingRemainHP.toString()),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: abilityChanged || itemChanged || hpChanged
              ? () {
                  Navigator.pop(context);
                  widget.onApply(abilityChanged, editingAbility, itemChanged,
                      editingItem, hpChanged, editingRemainHP);
                }
              : null,
          child: Text(loc.commonApply),
        ),
      ],
    );
  }
}
