import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class ChangePokemonCommandTile extends ListTile {
  ChangePokemonCommandTile(
    Pokemon pokemon,
    ThemeData theme, {
    Key? key,
    enabled = true,
    onTap,
    selected = false,
    bool showNetworkImage = false,
  }) : super(
          key: key,
          dense: true,
          leading: showNetworkImage
              ? Image.network(
                  PokeDB().pokeBase[pokemon.no]!.imageUrl,
                  height: theme.iconTheme.size,
                  errorBuilder: (c, o, s) {
                    return const Icon(Icons.catching_pokemon);
                  },
                )
              : const Icon(Icons.catching_pokemon),
          title: Text(pokemon.name),
          subtitle: Row(
            children: [
              pokemon.type1.displayIcon,
              pokemon.type2 != null
                  ? Text(' / ')
                  : Opacity(opacity: 0, child: Text(' / ')),
              pokemon.type2 != null
                  ? pokemon.type2!.displayIcon
                  : Opacity(opacity: 0, child: PokeDB().types[0].displayIcon),
              SizedBox(width: 10),
              pokemon.teraType.displayIcon,
            ],
          ),
          onTap: onTap,
          selected: selected,
          selectedTileColor: Colors.black26,
          enabled: enabled,
        );
}
