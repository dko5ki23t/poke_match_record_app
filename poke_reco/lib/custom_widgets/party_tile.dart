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
                  TextSpan(text: _removeFormName(party.pokemon1.name)),
                  party.pokemon2 != null ? TextSpan(text: '/${_removeFormName(party.pokemon2!.name)}') : TextSpan(),
                  party.pokemon3 != null ? TextSpan(text: '/${_removeFormName(party.pokemon3!.name)}') : TextSpan(),
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
                  party.pokemon4 != null ? TextSpan(text: _removeFormName(party.pokemon4!.name)) : TextSpan(),
                  party.pokemon5 != null ? TextSpan(text: '/${_removeFormName(party.pokemon5!.name)}') : TextSpan(),
                  party.pokemon6 != null ? TextSpan(text: '/${_removeFormName(party.pokemon6!.name)}') : TextSpan(),
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
