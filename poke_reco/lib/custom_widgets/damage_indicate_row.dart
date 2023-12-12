import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/data_structs/pokemon.dart';

class DamageIndicateRow extends Row {
  DamageIndicateRow(
    Pokemon pokemon,
    TextEditingController controller,
    bool isMe,
    void Function()? onTap,
    void Function(String)? onChanged,
    int damage,
    bool isInput,
    {
      bool enabled = true,
    }
  ) : 
  super(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: isInput ?
          TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: '${pokemon.name}の残りHP',
            ),
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onTap: onTap,
            onChanged: onChanged,
          ) :
          TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: '${pokemon.name}の残りHP',
            ),
            readOnly: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onTap: onTap,
          ),
      ),
      isMe ?
      Flexible(child: Text('/${pokemon.h.real}')) :
      Flexible(child: Text('% /100%')),
      SizedBox(width: 10,),
      isMe ?
        damage != 0 ?
        damage > 0 ?
        Flexible(child: Text('= ダメージ $damage')) :
        Flexible(child: Text('= 回復 ${-damage}')) : Container() :
        damage != 0 ?
        damage > 0 ?
        Flexible(child: Text('= ダメージ $damage%')) :
        Flexible(child: Text('= 回復 ${-damage}%')) : Container(),
    ],
  );
}
