import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DamageIndicateRow extends Row {
  DamageIndicateRow(
    Pokemon pokemon,
    TextEditingController controller,
    bool isMe,
    void Function(String)? onChanged,
    int damage,
    bool isInput, {
    bool enabled = true,
    required AppLocalizations loc,
  }) : super(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: isInput
                  ? TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: loc.battleRemainHP(pokemon.name),
                      ),
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onChanged,
                    )
                  : TextFormField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: loc.battleRemainHP(pokemon.name),
                      ),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
            ),
            isMe
                ? Flexible(child: Text('/${pokemon.h.real}'))
                : Flexible(child: Text('% /100%')),
            SizedBox(
              width: 10,
            ),
            isMe
                ? damage != 0
                    ? damage > 0
                        ? Flexible(child: Text('= ${loc.battleDamage(damage)}'))
                        : Flexible(
                            child: Text('= ${loc.battleRecovery(-damage)}'))
                    : Container()
                : damage != 0
                    ? damage > 0
                        ? Flexible(
                            child: Text('= ${loc.battleDamage('$damage%')}'))
                        : Flexible(
                            child:
                                Text('= ${loc.battleRecovery('${-damage}%')}'))
                    : Container(),
          ],
        );
}
