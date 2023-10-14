import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
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
    ThemeData theme,
    {
      enabled = true,
      leading,
      trailing,
      onTap,
      onLongPress,
      showWarning = false,
    }
  ) : 
  super(
    enabled: enabled,
    isThreeLine: true,
    leading: leading,
    title: Row(
      children: [
        showWarning && pokemon.refCount > 0 ?
        Icon(Icons.warning, color: Colors.red,)
        : Container(),
        Expanded(
          child: Text(
            pokemon.nickname == '' ?
            '${pokemon.name}/${pokemon.name}' :
            '${pokemon.nickname}/${pokemon.name}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10),
        Text(
            'Lv.${pokemon.level}', overflow: TextOverflow.ellipsis,
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
            pokemon.type2 != null ? Text(' / ') : Opacity(opacity: 0, child: Text(' / ')),
            pokemon.type2 != null ? pokemon.type2!.displayIcon : Opacity(opacity: 0, child: PokeDB().types[0].displayIcon),
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
                      style: pokemon.temper.increasedStat == 'attack' ? increaseStateStyle :
                        pokemon.temper.decreasedStat == 'attack' ? decreaseStateStyle : null,
                    ),
                    TextSpan(text: '/'),
                    TextSpan(
                      text: '${pokemon.b.real}',
                      style: pokemon.temper.increasedStat == 'defense' ? increaseStateStyle :
                        pokemon.temper.decreasedStat == 'defense' ? decreaseStateStyle : null,
                    ),
                    TextSpan(text: '/'),
                    TextSpan(
                      text: '${pokemon.c.real}',
                      style: pokemon.temper.increasedStat == 'special-attack' ? increaseStateStyle :
                        pokemon.temper.decreasedStat == 'special-attack' ? decreaseStateStyle : null,
                    ),
                    TextSpan(text: '/'),
                    TextSpan(
                      text: '${pokemon.d.real}',
                      style: pokemon.temper.increasedStat == 'special-defense' ? increaseStateStyle :
                        pokemon.temper.decreasedStat == 'special-defense' ? decreaseStateStyle : null,
                    ),
                    TextSpan(text: '/'),
                    TextSpan(
                      text: '${pokemon.s.real}',
                      style: pokemon.temper.increasedStat == 'speed' ? increaseStateStyle :
                        pokemon.temper.decreasedStat == 'speed' ? decreaseStateStyle : null,
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
  );
}
