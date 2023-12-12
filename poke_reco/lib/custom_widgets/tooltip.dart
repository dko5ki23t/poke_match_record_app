import 'package:flutter/material.dart';
import 'package:poke_reco/data_structs/ability.dart';
import 'package:poke_reco/data_structs/item.dart';
import 'package:poke_reco/data_structs/poke_db.dart';

// 長押しで説明が表示されるテキスト

class AbilityTooltip extends Tooltip {
  AbilityTooltip(
    {
      required Ability ability,
      required Widget child,
      TooltipTriggerMode? triggerMode,
    }
  ) : 
  super(
    message: PokeDB().abilityFlavors[ability.id] ?? '',
    child: child,
    showDuration: Duration(minutes: 1,),
    triggerMode: triggerMode,
  );
}

class AbilityText extends AbilityTooltip {
  AbilityText(
    Ability ability,
    {
      bool showHatena = false,
      TooltipTriggerMode? triggerMode,
    }
  ) : 
  super(
    ability: ability,
    child: Text(
      showHatena && ability.id == 0 ? '？' :
      ability.displayName
    ),
    triggerMode: triggerMode,
  );
}

class ItemTooltip extends Tooltip {
  ItemTooltip(
    {
      required Item? item,
      required Widget child,
      TooltipTriggerMode? triggerMode,
    }
  ) : 
  super(
    message: PokeDB().itemFlavors[item?.id] ?? '',
    child: child,
    showDuration: Duration(minutes: 1,),
    triggerMode: triggerMode,
  );
}

class ItemText extends ItemTooltip {
  ItemText(
    Item? item,
    {
      bool showHatena = false,
      bool showNone = false,
      TooltipTriggerMode? triggerMode,
    }
  ) : 
  super(
    item: item,
    child: Text(
      showNone && item == null ? 'なし' :
      showHatena && item?.id == 0 ? '？' :
      item == null ? '' : item.displayName
    ),
    triggerMode: triggerMode,
  );
}

class MoveTooltip extends Tooltip {
  MoveTooltip(
    {
      required Move move,
      required Widget child,
      TooltipTriggerMode? triggerMode,
    }
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
    child: child,
    showDuration: Duration(minutes: 1,),
    triggerMode: triggerMode,
  );
}

class MoveText extends MoveTooltip {
  MoveText(
    Move move,
    {
      TooltipTriggerMode? triggerMode,
    }
  ) :
  super(
    move: move,
    child: Text(move.displayName),
    triggerMode: triggerMode,
  );
}
