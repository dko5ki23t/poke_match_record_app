import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DamageIndicateRow extends StatefulWidget {
  DamageIndicateRow(
    this.pokemon,
    this.controller,
    this.isMe,
    this.onChanged,
    this.initialDamage,
    this.isInput, {
    bool enable = true,
    required this.loc,
  }) {
    enabled = enable;
  }

  final Pokemon pokemon;
  final TextEditingController controller;
  final bool isMe;

  /// 戻り値に新たなダメージを返してもらう
  final int Function(String)? onChanged;
  final int initialDamage;
  final bool isInput;
  late final bool enabled;
  final AppLocalizations loc;

  @override
  State<DamageIndicateRow> createState() => _DamageIndicateRowState();
}

class _DamageIndicateRowState extends State<DamageIndicateRow> {
  int damage = 0;

  @override
  void initState() {
    super.initState();
    damage = widget.initialDamage;
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final controller = widget.controller;
    final isMe = widget.isMe;
    final loc = widget.loc;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: widget.isInput
              ? TextFormField(
                  key: Key('DamageIndicateTextField'),
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: loc.battleRemainHP(pokemon.name),
                  ),
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: widget.onChanged != null
                      ? (val) {
                          setState(() {
                            damage = widget.onChanged!(val);
                          });
                        }
                      : null,
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
                    : Flexible(child: Text('= ${loc.battleRecovery(-damage)}'))
                : Container()
            : damage != 0
                ? damage > 0
                    ? Flexible(child: Text('= ${loc.battleDamage('$damage%')}'))
                    : Flexible(
                        child: Text('= ${loc.battleRecovery('${-damage}%')}'))
                : Container(),
      ],
    );
  }
}
