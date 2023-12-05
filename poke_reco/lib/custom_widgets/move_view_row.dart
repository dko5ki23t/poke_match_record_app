import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

class MoveViewRow extends Row {
  MoveViewRow(
    ThemeData theme,
    Move move,
    int pp,
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
                TextSpan(text: move.damageClass.id == 1 ? '　変化' : move.damageClass.id == 2 ? '　物理' : move.damageClass.id == 3 ? '　特殊' : '　？'),
                TextSpan(text: '　威力：${move.power}　命中：${move.accuracy}'),
                TextSpan(text: '\n${PokeDB().moveFlavors[move.id] ?? ''}'),
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