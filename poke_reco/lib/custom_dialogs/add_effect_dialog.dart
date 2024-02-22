import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/tool.dart';

class AddEffectDialog extends StatefulWidget {
  final void Function(TurnEffect effect) onSelect;
  final String title;
  final List<TurnEffect> effectList;

  const AddEffectDialog(
    this.onSelect,
    this.title,
    this.effectList, {
    Key? key,
  }) : super(key: key);

  @override
  AddEffectDialogState createState() => AddEffectDialogState();
}

class AddEffectDialogState extends State<AddEffectDialog> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // 検索窓の入力でフィルタリング
    final pattern = nameController.text;
    final filteredList = [...widget.effectList];
    if (pattern != '') {
      filteredList.retainWhere((s) {
        return toKatakana50(s.displayName(loc: loc).toLowerCase())
            .contains(toKatakana50(pattern.toLowerCase()));
      });
    }

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        children: [
          Flexible(
            child: TextField(
              key: Key('AddEffectDialogSearchBar'),
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Flexible(
            flex: 10,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final effect in filteredList)
                    ListTile(
                      title: Text(effect.displayName(loc: loc)),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelect(effect);
                      },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
