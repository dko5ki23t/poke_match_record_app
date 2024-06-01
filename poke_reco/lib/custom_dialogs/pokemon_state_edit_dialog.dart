import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/tool.dart';

class PokemonStateEditDialog extends StatefulWidget {
  final PokemonState pokemonState;
  final void Function(bool abilityChanged, Ability ability, bool itemChanged,
      Item? item, bool hpChanged, int remainHP) onApply;

  const PokemonStateEditDialog(
    this.pokemonState,
    this.onApply, {
    Key? key,
    required this.loc,
  }) : super(key: key);

  final AppLocalizations loc;

  @override
  PokemonStateEditDialogState createState() => PokemonStateEditDialogState();
}

class PokemonStateEditDialogState extends State<PokemonStateEditDialog> {
  late final PokemonState pokemonState;
  TextEditingController abilityController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController remainHPController = TextEditingController();
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
    abilityController.text = pokemonState.currentAbility.displayNameWithUnknown;
    itemController.text = pokemonState.holdingItem != null
        ? pokemonState.holdingItem!.displayNameWithUnknown
        : widget.loc.commonNone;
    initialAbility = editingAbility = pokemonState.currentAbility;
    initialHoldingItem = editingItem = pokemonState.holdingItem;
    initialRemainHP = editingRemainHP = playerType == PlayerType.me
        ? pokemonState.remainHP
        : pokemonState.remainHPPercent;
    remainHPController.text = editingRemainHP.toString();
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
                  child: AppBaseTypeAheadField(
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
                      // 候補が2つ以上あるなら不明（？）も追加する
                      if (pokemonState.playerType == PlayerType.opponent &&
                          matches.length > 1) {
                        matches.add(PokeDB().abilities[0]!);
                      }
                      matches.retainWhere((s) {
                        return toKatakana50(
                                s.displayNameWithUnknown.toLowerCase())
                            .contains(toKatakana50(pattern.toLowerCase()));
                      });
                      return matches;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.displayNameWithUnknown),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      abilityController.text =
                          suggestion.displayNameWithUnknown;
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
                  child: AppBaseTypeAheadField(
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
                      // もちものなしも追加
                      matches.add(Item(
                        id: -1,
                        displayName: loc.commonNone,
                        displayNameEn: loc.commonNone,
                        flingPower: 0,
                        flingEffectId: 0,
                        timing: Timing.none,
                        isBerry: false,
                        imageUrl: '',
                        possiblyChangeStat: [],
                      ));
                      matches.retainWhere((s) {
                        return toKatakana50(
                                s.displayNameWithUnknown.toLowerCase())
                            .contains(toKatakana50(pattern.toLowerCase()));
                      });
                      return matches;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.displayNameWithUnknown),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      itemController.text = suggestion.displayNameWithUnknown;
                      if (suggestion.id >= 0) {
                        editingItem = suggestion;
                      } else {
                        editingItem = null;
                      }
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
                Flexible(
                  flex: 8,
                  child: Slider(
                    value: editingRemainHP.toDouble(),
                    max: maxHP.toDouble(),
                    divisions: maxHP,
                    //label: editingRemainHP.toString(),
                    onChanged: (val) => setState(() {
                      editingRemainHP = val.round();
                      remainHPController.text = editingRemainHP.toString();
                    }),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: TextFormField(
                    key: Key('PokemonStateEditDialogRemainHP'), // テストでの識別用
                    controller: remainHPController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        int changedVal = int.tryParse(value) ?? 0;
                        editingRemainHP = changedVal.clamp(0, maxHP);
                        remainHPController.text = editingRemainHP.toString();
                      });
                    },
                    onTap: () {
                      // 全選択
                      remainHPController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: remainHPController.value.text.length);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
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
