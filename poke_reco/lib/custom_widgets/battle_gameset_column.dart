import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_effect.dart';

class BattleGamesetColumn extends Column {
  BattleGamesetColumn(
    ThemeData theme,
    TurnEffect turnEffect,
    String opponentName,
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
            Text('引き分け') :
            turnEffect.isMyWin ?
            Text('あなたの勝利！') :
            turnEffect.isYourWin ?
            Text('$opponentNameの勝利！') :
            Text('引き分け'),
          ],
        ),
      ),
    ],
  );
}
