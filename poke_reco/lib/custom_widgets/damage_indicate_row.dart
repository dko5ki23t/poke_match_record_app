import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 現在のポケモンのHPの入力フィールドと、その入力に基づいたダメージor回復量を表示するWidget
/// controllerの値およびonChangedによって渡される値は、0～対象ポケモンの最大HPの範囲内に自動で収める
class DamageIndicateRow extends StatefulWidget {
  DamageIndicateRow(
    this.pokemon,
    this.controller,
    this.isMe,
    this.onChanged,
    this.initialDamage,
    this.isInput, {
    bool enable = true,
    String? keyStr,
    required this.loc,
  }) {
    enabled = enable;
    keySubString = keyStr;
  }

  final Pokemon pokemon;
  final TextEditingController controller;
  final bool isMe;

  /// 戻り値に新たなダメージを返してもらう
  final int Function(int)? onChanged;
  final int initialDamage;
  final bool isInput;
  late final bool enabled;
  final AppLocalizations loc;
  late final String? keySubString;

  @override
  State<DamageIndicateRow> createState() => _DamageIndicateRowState();
}

class _DamageIndicateRowState extends State<DamageIndicateRow> {
  int damage = 0;
  static const int minHP = 0;
  late final int maxHP;

  @override
  void initState() {
    super.initState();
    damage = widget.initialDamage;
    maxHP = widget.isMe ? widget.pokemon.h.real : 100;
    final controller = widget.controller;
    if (controller.text != '') {
      int initialHP = int.tryParse(controller.text) ?? 0;
      controller.text = initialHP.clamp(minHP, maxHP).toString();
    }
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
                  key: Key(
                      'DamageIndicateTextField${widget.keySubString ?? ''}'),
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
                          int remainHP =
                              (int.tryParse(val) ?? 0).clamp(minHP, maxHP);
                          setState(() {
                            damage = widget.onChanged!(remainHP);
                          });
                          // 統合テスト作成用
                          print(
                              "await driver.tap(find.byValueKey('DamageIndicateTextField${widget.keySubString ?? ''}'));\n"
                              "await driver.enterText('$remainHP');");
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
