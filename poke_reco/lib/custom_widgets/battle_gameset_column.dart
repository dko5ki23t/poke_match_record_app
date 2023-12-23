import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleGamesetColumn extends Column {
  BattleGamesetColumn(
    ThemeData theme,
    TurnEffect turnEffect,
    String opponentName,
    {
      required AppLocalizations loc,
    }
  ) :
  super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            turnEffect.isMyWin && turnEffect.isYourWin ?
            Text(loc.battleResultDraw) :
            turnEffect.isMyWin ?
            Text(loc.battleResultYouWin) :
            turnEffect.isYourWin ?
            Text(loc.battleResultOpponentWin(opponentName)) :
            Text(loc.battleResultDraw),
          ],
        ),
      ),
    ],
  );
}
