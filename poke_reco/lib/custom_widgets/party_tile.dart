import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class PartyTile extends ListTile {
  PartyTile(
    Party party,
    ThemeData theme,
    {
      leading,
      trailing,
      onTap,
      onLongPress,
      bool showNetworkImage = false,
    }
  ) : 
  super(
    isThreeLine: true,
    leading: leading,
    key: Key('${party.id}'),
    title: Text(party.name),
    subtitle: Column(
      children: [
        showNetworkImage ?
        Row(
          children: [
            _pokemonWidget(party.pokemons[0], theme),
            _itemWidget(party.items[0], theme),
            party.pokemons[1] != null ? Text('/') : Container(),
            _pokemonWidget(party.pokemons[1], theme),
            _itemWidget(party.items[1], theme),
            party.pokemons[2] != null ? Text('/') : Container(),
            _pokemonWidget(party.pokemons[2], theme),
            _itemWidget(party.items[2], theme),
          ],
        ) :
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
        showNetworkImage ?
        Row(
          children: [
            _pokemonWidget(party.pokemons[3], theme),
            _itemWidget(party.items[3], theme),
            party.pokemons[4] != null ? Text('/') : Container(),
            _pokemonWidget(party.pokemons[4], theme),
            _itemWidget(party.items[4], theme),
            party.pokemons[5] != null ? Text('/') : Container(),
            _pokemonWidget(party.pokemons[5], theme),
            _itemWidget(party.items[5], theme),
          ],
        ) :
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

  static Widget _pokemonWidget(Pokemon? poke, ThemeData theme,) {
    if (poke != null) {
      return Image.network(
        PokeDB().pokeBase[poke.no]!.imageUrl,
        height: theme.buttonTheme.height,
        errorBuilder: (c, o, s) {
          return Text(_removeFormName(poke.name));
        },
      );
    }
    else {
      return Container();
    }
  }

  static Widget _itemWidget(Item? item, ThemeData theme,) {
    if (item != null) {
      return Image.network(
        item.imageUrl,
        height: theme.buttonTheme.height,
        errorBuilder: (c, o, s) {
          return const Icon(Icons.category);
        },
      );
    }
    else {
      return Container();
    }
  }

              
}
