import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_dropdown_button_form_field.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class PokemonPopupMenuItem extends ColoredPopupMenuItem {
  PokemonPopupMenuItem({
    required int value,
    required Pokemon pokemon,
    required ThemeData theme,
    bool enabled = false,
    bool showNetworkImage = false,
  }) : super(
          value: value,
          enabled: enabled,
          child: Row(
            children: [
              showNetworkImage
                  ? Image.network(
                      PokeDB().pokeBase[pokemon.no]!.imageUrl,
                      height: theme.buttonTheme.height,
                      errorBuilder: (c, o, s) {
                        return const Icon(Icons.catching_pokemon);
                      },
                    )
                  : const Icon(Icons.catching_pokemon),
              SizedBox(
                width: 10,
              ),
              Text(
                pokemon.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: enabled ? Colors.black : Colors.grey),
              ),
            ],
          ),
        );
}
