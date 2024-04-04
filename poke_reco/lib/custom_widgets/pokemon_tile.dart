import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class PokemonTile extends ListTile {
  static const increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  static const decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  PokemonTile(
    Pokemon pokemon,
    ThemeData theme, {
    enabled = true,
    leading,
    trailing,
    onTap,
    onLongPress,
    showWarning = false,
    dense = false,
    selected = false,
    selectedTileColor,
    Key? key,
  }) : super(
          enabled: enabled,
          isThreeLine: true,
          leading: leading,
          key: key ?? Key('${pokemon.id}'),
          title: Row(
            children: [
              showWarning && pokemon.refs
                  ? Icon(
                      Icons.warning,
                      color: Colors.red,
                    )
                  : Container(),
              Expanded(
                child: Text(
                  pokemon.nickname == ''
                      ? '${pokemon.name}/${pokemon.name}'
                      : '${pokemon.nickname}/${pokemon.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Lv.${pokemon.level}',
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 10),
              pokemon.sex.displayIcon,
            ],
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  pokemon.type1.displayIcon,
                  pokemon.type2 != null
                      ? Text(' / ')
                      : Opacity(opacity: 0, child: Text(' / ')),
                  pokemon.type2 != null
                      ? pokemon.type2!.displayIcon
                      : Opacity(
                          opacity: 0, child: PokeDB().types[0].displayIcon),
                  SizedBox(width: 10),
                  pokemon.teraType.displayIcon,
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(text: '${pokemon.h.real}/'),
                          TextSpan(
                            text: '${pokemon.a.real}',
                            style: pokemon.temper.increasedStat == StatIndex.A
                                ? increaseStateStyle
                                : pokemon.temper.decreasedStat == StatIndex.A
                                    ? decreaseStateStyle
                                    : null,
                          ),
                          TextSpan(text: '/'),
                          TextSpan(
                            text: '${pokemon.b.real}',
                            style: pokemon.temper.increasedStat == StatIndex.B
                                ? increaseStateStyle
                                : pokemon.temper.decreasedStat == StatIndex.B
                                    ? decreaseStateStyle
                                    : null,
                          ),
                          TextSpan(text: '/'),
                          TextSpan(
                            text: '${pokemon.c.real}',
                            style: pokemon.temper.increasedStat == StatIndex.C
                                ? increaseStateStyle
                                : pokemon.temper.decreasedStat == StatIndex.C
                                    ? decreaseStateStyle
                                    : null,
                          ),
                          TextSpan(text: '/'),
                          TextSpan(
                            text: '${pokemon.d.real}',
                            style: pokemon.temper.increasedStat == StatIndex.D
                                ? increaseStateStyle
                                : pokemon.temper.decreasedStat == StatIndex.D
                                    ? decreaseStateStyle
                                    : null,
                          ),
                          TextSpan(text: '/'),
                          TextSpan(
                            text: '${pokemon.s.real}',
                            style: pokemon.temper.increasedStat == StatIndex.S
                                ? increaseStateStyle
                                : pokemon.temper.decreasedStat == StatIndex.S
                                    ? decreaseStateStyle
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              /*
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(text: '${pokemon.ability.displayName}    ${pokemon.move1.displayName}'),
                    pokemon.move2 != null ? TextSpan(text: '/${pokemon.move2!.displayName}') : TextSpan(),
                    pokemon.move2 != null && pokemon.move3 != null ? TextSpan(text: '/') : TextSpan(),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    pokemon.move2 != null && pokemon.move3 != null ? TextSpan(text: pokemon.move3!.displayName) : TextSpan(),
                    pokemon.move2 != null && pokemon.move3 != null && pokemon.move4 != null ? TextSpan(text: '/${pokemon.move4!.displayName}') : TextSpan(),
                  ],
                ),
              ),
            ],
          ),
  */
            ],
          ),
          onTap: onTap,
          onLongPress: onLongPress,
          trailing: trailing,
          dense: dense,
          selected: selected,
          selectedTileColor: selectedTileColor,
        );
}
