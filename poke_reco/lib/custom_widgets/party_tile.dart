import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/party.dart';

class PartyTile extends ListTile {
  PartyTile(
    Party party,
    ThemeData theme,
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
    key: Key('${party.id}'),
    title: Text(party.name),
    subtitle: Column(
      children: [
        Row(
          children:[
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(text: _removeFormName(party.pokemons[0]!.name)),
                  party.pokemons[1] != null ? TextSpan(text: '/${_removeFormName(party.pokemons[1]!.name)}') : TextSpan(),
                  party.pokemons[2] != null ? TextSpan(text: '/${_removeFormName(party.pokemons[2]!.name)}') : TextSpan(),
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
                  party.pokemons[3] != null ? TextSpan(text: _removeFormName(party.pokemons[3]!.name)) : TextSpan(),
                  party.pokemons[4] != null ? TextSpan(text: '/${_removeFormName(party.pokemons[4]!.name)}') : TextSpan(),
                  party.pokemons[5] != null ? TextSpan(text: '/${_removeFormName(party.pokemons[5]!.name)}') : TextSpan(),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('勝率：${party.winRate}% ${party.winCount}/${party.usedCount}')
          ],
        ),
      ],
    ),
    onTap: onTap,
    onLongPress: onLongPress,
    trailing: trailing,
  );

  static String _removeFormName(String name) {
    return name.replaceAll(RegExp(r'\(.*\)'), '');
  }
}
