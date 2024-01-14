import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

class BattleTile extends ListTile {
  BattleTile(
    Battle battle,
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
    key: Key('${battle.id}'),
    title: Row(
      children: [
        Expanded(
          child: Text(battle.name, overflow: TextOverflow.ellipsis,),
        ),
        SizedBox(width: 10,),
        battle.isMyWin && !battle.isYourWin ? Text('WIN!', style: TextStyle(color: Colors.red,)) :
        !battle.isMyWin && battle.isYourWin ? Text('LOSE...', style: TextStyle(color: Colors.blue,)) :
        battle.isMyWin && battle.isYourWin ? Text('DRAW', style: TextStyle(color: Colors.green[800],)) : Text(''),
      ],
    ),
    subtitle: Row(
      children: [
        Expanded(
          child: Text('vs ${battle.opponentName}'),
        ),
        Expanded(
          child: Text(battle.getParty(PlayerType.me).name),
        ),
        Expanded(
          child: Text(battle.formattedDateTime),
        ),
      ],
    ),
    onTap: onTap,
    onLongPress: onLongPress,
    trailing: trailing,
  );
}
