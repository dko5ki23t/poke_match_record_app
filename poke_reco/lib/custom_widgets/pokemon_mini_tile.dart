import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class PokemonMiniTile extends ListTile {
  PokemonMiniTile(
    Pokemon pokemon,
    ThemeData theme,
    {
      selected = false,
      enabled = true,
      leading,
      trailing,
      onTap,
      onLongPress,
      selectedTileColor,
      bool showLevel = true,
      bool showSex = true,
    }
  ) : 
  super(
    selected: selected,
    enabled: enabled,
    isThreeLine: true,
    leading: leading,
    title: Row(
      children: [
        Expanded(
          child: Text(
            pokemon.nickname == '' ?
            '${pokemon.name}/' :
            '${pokemon.nickname}/',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10),
        showLevel ?
        Text(
          'Lv.${pokemon.level}', overflow: TextOverflow.ellipsis,
        ) : Container(),
      ],
    ),
    subtitle: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pokemon.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10,),
            showSex ? pokemon.sex.displayIcon : Container(),
          ],
        ),
        Row(
          children: [
            pokemon.type1.displayIcon,
            pokemon.type2 != null ? Text(' / ') : Opacity(opacity: 0, child: Text(' / ')),
            pokemon.type2 != null ? pokemon.type2!.displayIcon : Opacity(opacity: 0, child: PokeDB().types[0].displayIcon),
            SizedBox(width: 10),
            pokemon.teraType.displayIcon,
          ],
        ),
      ],
    ),
    onTap: onTap,
    onLongPress: onLongPress,
    selectedTileColor: selectedTileColor,
    trailing: trailing,
  );
}
