import 'package:flutter/material.dart';
import 'package:poke_reco/poke_db.dart';

class BattleTile extends ListTile {
  BattleTile(
    Battle battle,
    ThemeData theme,
    PokeDB pokeData,
    {
      leading,
      trailing,
      onTap,
      onLongPress,
    }
  ) : 
  super(
    isThreeLine: true,
    leading: leading,
    title: Text(battle.name),
    subtitle: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
/*
        Row(children:
          [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(text: party.pokemon1.name),
                  party.pokemon2 != null ? TextSpan(text: '/${party.pokemon2!.name}') : TextSpan(),
                  party.pokemon2 != null && party.pokemon3 != null ? TextSpan(text: '/${party.pokemon3!.name}') : TextSpan(),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  party.pokemon2 != null && party.pokemon3 != null && party.pokemon4 != null ? TextSpan(text: '/${party.pokemon4!.name}') : TextSpan(),
                  party.pokemon2 != null && party.pokemon3 != null && party.pokemon4 != null && party.pokemon5 != null ? TextSpan(text: '/${party.pokemon5!.name}') : TextSpan(),
                  party.pokemon2 != null && party.pokemon3 != null && party.pokemon4 != null && party.pokemon5 != null && party.pokemon6 != null ? TextSpan(text: '/${party.pokemon6!.name}') : TextSpan(),
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