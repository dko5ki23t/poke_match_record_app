import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

// 長押しで説明が表示されるテキスト

class AbilityText extends Tooltip {
  AbilityText(
    Ability ability,
    {
      bool showHatena = false,
    }
  ) : 
  super(
    message: PokeDB().abilityFlavors[ability.id] ?? '',
    child: Text(
      showHatena && ability.id == 0 ? '？' :
      ability.displayName
    ),
    showDuration: Duration(minutes: 1,),
  );
}

class ItemText extends Tooltip {
  ItemText(
    Item? item,
    {
      bool showHatena = false,
      bool showNone = false,
    }
  ) : 
  super(
    message: PokeDB().itemFlavors[item?.id] ?? '',
    child: Text(
      showNone && item == null ? 'なし' :
      showHatena && item?.id == 0 ? '？' :
      item == null ? '' : item.displayName
    ),
    showDuration: Duration(minutes: 1,),
  );
}

class MoveText extends Tooltip {
  MoveText(
    Move move,
  ) : 
  super(
    richMessage: TextSpan(children: [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: move.type.displayIcon,
        ),
      ),
      TextSpan(text: move.damageClass.id == 1 ? '　変化' : move.damageClass.id == 2 ? '　物理' : move.damageClass.id == 3 ? '　特殊' : '　？'),
      TextSpan(text: '　威力：${move.power}　命中：${move.accuracy}'),
      TextSpan(text: '\n${PokeDB().moveFlavors[move.id] ?? ''}'),
    ]),
    child: Text(move.displayName),
    showDuration: Duration(minutes: 1,),
  );
}
