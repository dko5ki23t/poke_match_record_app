import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_state_edit_dialog.dart';
import 'package:poke_reco/custom_widgets/listview_with_view_item_count.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/ailment.dart';
import 'package:poke_reco/data_structs/buff_debuff.dart';
import 'package:poke_reco/data_structs/field.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/individual_field.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/weather.dart';

class BattlePokemonStateInfo extends StatefulWidget {
  const BattlePokemonStateInfo({
    Key? key,
    required this.focusState,
    required this.playerType,
    required this.playerName,
    required this.onStatusEdit,
  }) : super(key: key);

  final PhaseState focusState;
  final PlayerType playerType;
  final String playerName;
  final void Function(bool abilityChanged, Ability ability, bool itemChanged,
      Item? item, bool hpChanged, int remainHP) onStatusEdit;

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

    List<Widget> statusConditions = [
      for (final ailment in focusingPokemonState.ailmentsIterable)
        ailmentViewItem(ailment),
      for (final buffDebuff in focusingPokemonState.buffDebuffs.list)
        buffDebuffViewItem(buffDebuff),
    ];
    for (int i = 0; i < 7 - statusConditions.length; i++) {
      statusConditions.add(nullItem());
    }
    List<Widget> fields = [
      for (final indiField in focusState.getIndiFields(playerType))
        indiFieldViewItem(indiField),
    ];
    if (focusState.weather.id != 0) {
      fields.add(weatherViewItem(focusState.weather));
    }
    if (focusState.field.id != 0) {
      fields.add(fieldViewItem(focusState.field));
    }
    for (int i = 0; i < 7 - fields.length; i++) {
      fields.add(nullItem());
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTapUp: (details) {
              showDialog(
                  context: context,
                  builder: (_) {
                    return PokemonStateEditDialog(
                      focusingPokemonState,
                      (abilityChanged, ability, itemChanged, item, hpChanged,
                              remainHP) =>
                          widget.onStatusEdit(abilityChanged, ability,
                              itemChanged, item, hpChanged, remainHP),
                      loc: loc,
                    );
                  });
            },
            child: FittedBox(
              child: Column(
                children: [
                  // ポケモン画像/アイコン
                  pokeData.getPokeAPI
                      ? Image.network(
                          pokeData.pokeBase[focusingPokemon.no]!.imageUrl,
                          height: theme.buttonTheme.height * 1.5,
                          errorBuilder: (c, o, s) {
                            return const Icon(Icons.catching_pokemon);
                          },
                        )
                      : const Icon(Icons.catching_pokemon),
                  // ポケモン名
                  Text(
                    '${focusingPokemon.name}/${widget.playerName}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'Lv.${focusingPokemon.level}',
                            overflow: TextOverflow.ellipsis,
                          )),
                      Flexible(
                          fit: FlexFit.loose,
                          child: focusingPokemonState.sex.displayIcon),
                    ],
                  ),
                  // タイプ
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                          opacity:
                              focusingPokemonState.isTerastaling ? 0.3 : 1.0,
                          child: Flexible(
                              fit: FlexFit.loose,
                              child: focusingPokemonState.type1.displayIcon)),
                      focusingPokemonState.type2 != null
                          ? Opacity(
                              opacity: focusingPokemonState.isTerastaling
                                  ? 0.3
                                  : 1.0,
                              child: Flexible(
                                  fit: FlexFit.loose,
                                  child:
                                      focusingPokemonState.type2!.displayIcon))
                          : Container(),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          thickness: 1,
                        ),
                      ),
                      focusingPokemonState.isTerastaling
                          ? Opacity(
                              opacity: focusingPokemonState.isTerastaling
                                  ? 1.0
                                  : 0.3,
                              child: Flexible(
                                  fit: FlexFit.loose,
                                  child: focusingPokemonState
                                      .teraType1.displayIcon))
                          : Opacity(
                              opacity: focusingPokemonState.isTerastaling
                                  ? 1.0
                                  : 0.3,
                              child: Flexible(
                                  fit: FlexFit.loose,
                                  child: focusingPokemonState
                                      .pokemon.teraType.displayIcon)),
                    ],
                  ),
                  // とくせい
                  AbilityText(
                    focusingPokemonState.currentAbility,
                    showHatena: true,
                  ),
                  // もちもの
                  ItemText(
                    focusingPokemonState.holdingItem,
                    showHatena: true,
                    showNone: true,
                    loc: loc,
                  ),
                  hpBarRow(
                    playerType,
                    playerType == PlayerType.me
                        ? focusingPokemonState.remainHP
                        : focusingPokemonState.remainHPPercent,
                    playerType == PlayerType.me ? focusingPokemon.h.real : 100,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          // 各ステータス(HABCDS)の実数値/各ステータス(ABCDSAcEv)の変化/状態変化
          child: Stack(
            children: [
              PageView(
                controller: controller,
                children: [
                  // 1. 各ステータス(HABCDS)の種族値
                  FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(loc.commonStatRace),
                        for (final stat in StatIndexList.listHtoS)
                          statStatusViewRow(
                            stat.alphabet,
                            focusingPokemonState.minStats[stat].race,
                            focusingPokemonState.maxStats[stat].race,
                          ),
                        Text(' '),
                      ],
                    ),
                  ),
                  // 2. 各ステータス(HABCDS)の実数値
                  FittedBox(
                    child: Column(
                      children: [
                        Text(loc.commonStatReal),
                        for (final stat in StatIndexList.listHtoS)
                          statStatusViewRow(
                            stat.alphabet,
                            focusingPokemonState.minStats[stat].real,
                            focusingPokemonState.maxStats[stat].real,
                          ),
                        Text(' '),
                      ],
                    ),
                  ),
                  // 3. 各ステータス(ABCDSAcEv)のランク変化
                  FittedBox(
                    child: Column(
                      children: [
                        Text(loc.battlesTabStatusModeRank),
                        for (int i = 0; i < 7; i++)
                          statChangeViewRow(
                            statAlphabets[i],
                            focusingPokemonState.statChanges(i),
                            (idx) {},
                          ),
                      ],
                    ),
                  ),
                  // 4. 状態変化
                  FittedBox(
                    child: Column(
                      children: [
                        Text(loc.commonStatusCondition),
                        SizedBox(
                          width: theme.iconTheme.size ?? 24.0 * 7,
                          height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                              (theme.primaryTextTheme.bodyMedium!.height ??
                                  1.0) *
                              7,
                          child: ListViewWithViewItemCount(
                            viewItemCount: 7,
                            children: statusConditions,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 5. 場
                  FittedBox(
                    child: Column(
                      children: [
                        Text(loc.commonFields),
                        SizedBox(
                          width: theme.iconTheme.size ?? 24.0 * 7,
                          height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                              (theme.primaryTextTheme.bodyMedium!.height ??
                                  1.0) *
                              7,
                          child: ListViewWithViewItemCount(
                            viewItemCount: 7,
                            children: fields,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  child: Column(
                    children: [
                      SizedBox(
                        height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                            (theme.primaryTextTheme.bodyMedium!.height ?? 1.0) *
                            4,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0x80000000),
                        ),
                        onPressed: () {
                          controller.previousPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                      ),
                      SizedBox(
                        height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                            (theme.primaryTextTheme.bodyMedium!.height ?? 1.0) *
                            4,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  child: Column(
                    children: [
                      SizedBox(
                        height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                            (theme.primaryTextTheme.bodyMedium!.height ?? 1.0) *
                            4,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0x80000000),
                        ),
                        onPressed: () {
                          controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                      ),
                      SizedBox(
                        height: theme.primaryTextTheme.bodyMedium!.fontSize! *
                            (theme.primaryTextTheme.bodyMedium!.height ?? 1.0) *
                            4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget hpBarRow(
    PlayerType playerType,
    int remainHP,
    int? maxHP,
  ) {
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
                child: Container(width: 150, height: 20, color: Colors.grey),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  width: (remainHP / maxHPRe) * 150,
                  height: 20,
                  color: (remainHP / maxHPRe) <= 0.25
                      ? Colors.red
                      : (remainHP / maxHPRe) <= 0.5
                          ? Colors.yellow
                          : Colors.lightGreen,
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

  Widget statChangeViewRow(
    String label,
    int statChange,
    void Function(int idx) onOwnPressed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Text(label),
              for (int i = 0; i < statChange.abs(); i++)
                statChange > 0
                    ? GestureDetector(
                        onTap: () => onOwnPressed(i),
                        child: Icon(Icons.arrow_drop_up, color: Colors.red))
                    : GestureDetector(
                        onTap: () => onOwnPressed(i),
                        child: Icon(Icons.arrow_drop_down, color: Colors.blue)),
              for (int i = statChange.abs(); i < 6; i++)
                GestureDetector(
                    onTap: () => onOwnPressed(i),
                    child: Icon(Icons.remove, color: Colors.grey)),
            ],
          ),
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
          child: Row(
            children: [
              Text(label),
              statusMin == statusMax
                  ? Text(statusMin.toString())
                  : Text('$statusMin ~ $statusMax'),
            ],
          ),
        ),
      ],
    );
  }

  Widget ailmentViewItem(
    Ailment ailment,
  ) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          color: ailment.bgColor,
          child:
              Text(ailment.displayName, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget buffDebuffViewItem(BuffDebuff buffDebuff) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          color: buffDebuff.bgColor,
          child: Text(buffDebuff.displayName,
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget indiFieldViewItem(
    IndividualField indiField,
  ) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          color: indiField.bgColor,
          child: Text(indiField.displayName,
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget weatherViewItem(Weather weather) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          color: weather.bgColor,
          child:
              Text(weather.displayName, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget fieldViewItem(Field field) {
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          color: field.bgColor,
          child: Text(field.displayName, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget nullItem() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      child: Container(
        color: Color(0x00ffffff),
        child: Text('null', style: TextStyle(color: Color(0x00ffffff))),
      ),
    );
  }
}
