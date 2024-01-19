import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_type.dart';

class MoveViewRow extends Row {
  MoveViewRow(
    ThemeData theme,
    Move move,
    int pp,
    {
      required AppLocalizations loc,
    }
  ) : 
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        flex: 7,
        child: ListTile(
          title: Text(move.displayName),
          subtitle: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: move.type.displayIcon,
                  ),
                ),
                TextSpan(text: move.damageClass.id == 1 ? ' ${loc.commonMoveStatus}' : move.damageClass.id == 2 ? ' ${loc.commonMovePhysical}' : move.damageClass.id == 3 ? ' ${loc.commonMoveSpecial}' : ' ?'),
                TextSpan(text: ' ${loc.commonMovePower} : ${move.power} ${loc.commonMoveAccuracy} : ${move.accuracy}'),
                TextSpan(text: '\n${PokeDB().getMoveFlavor(move.id) ?? ''}'),
              ],
              style: theme.textTheme.bodyMedium,
            ),
          ),
          trailing: Text('PP:$pp', style: theme.textTheme.bodyMedium,),
        ),
      ),
    ],
  );
}