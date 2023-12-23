import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/tooltip.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class PokemonItemViewRow extends Row {
  PokemonItemViewRow(
    String? labelPokemonText,
    String? labelItemText,
    TextEditingController pokemonController,
    TextEditingController itemController,
    Pokemon pokemon,
    Item? item,
    ThemeData theme,
    void Function() pokemonOnEdit,
    {
      bool showNetworkImage = false,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
      children: [
        showNetworkImage ?
        Image.network(
          PokeDB().pokeBase[pokemon.no]!.imageUrl,
          height: theme.buttonTheme.height,
          errorBuilder: (c, o, s) {
            return const Icon(Icons.catching_pokemon);
          },
        ) : const Icon(Icons.catching_pokemon),
        Flexible(
          flex: 5,
          child: TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: labelPokemonText,
            ),
            controller: pokemonController,
            onTap: () => pokemonOnEdit(),
            readOnly: true,
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          flex: 5,
          child: TextField(
            controller: itemController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: labelItemText,
              suffix: ItemTooltip(
                item: item,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.help),
              ),
            ),
            readOnly: true,
          ),
        ),
        item != null && showNetworkImage ?
        Image.network(
          PokeDB().items[item.id]!.imageUrl,
          height: theme.buttonTheme.height,
          errorBuilder: (c, o, s) {
            return const Icon(Icons.category);
          },
        ) :
        const Icon(Icons.category),
      ],
  );
}