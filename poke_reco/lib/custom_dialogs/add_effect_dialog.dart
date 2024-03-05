import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/tool.dart';

class AddEffectDialog extends StatefulWidget {
  final void Function(TurnEffect effect) onSelect;
  final String title;
  final List<TurnEffect> effectList;
  final String youText;
  final String opponentText;

  const AddEffectDialog(
    this.onSelect,
    this.title,
    this.effectList,
    this.youText,
    this.opponentText, {
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

    // 効果主の表示名
    String displayStr(PlayerType player) {
      String ret = '';
      if (player == PlayerType.me) {
        ret = widget.youText;
      } else if (player == PlayerType.opponent) {
        ret = widget.opponentText;
      } else if (player == PlayerType.entireField) {
        ret = loc.battleWeatherField;
      }
      return ret;
    }

    String keyName(PlayerType player) {
      if (player == PlayerType.me) {
        return 'Own';
      } else if (player == PlayerType.opponent) {
        return 'Opponent';
      } else if (player == PlayerType.entireField) {
        return 'Entire';
      }
      return '';
    }

    // 検索窓の入力でフィルタリング
    final pattern = nameController.text;
    final filteredList = [...widget.effectList];
    if (pattern != '') {
      filteredList.retainWhere((s) {
        return toKatakana50(s.displayName(loc: loc).toLowerCase())
            .contains(toKatakana50(pattern.toLowerCase()));
      });
    }
    List<Widget> widgetList = [];
    PlayerType currentPlayer = PlayerType.none;
    if (filteredList.isNotEmpty) {
      currentPlayer = filteredList.first.playerType;
      widgetList.add(Text(displayStr(currentPlayer)));
      widgetList.add(const Divider(
        height: 10,
        thickness: 1,
      ));
    }
    for (final effect in filteredList) {
      if (effect.playerType != currentPlayer) {
        currentPlayer = effect.playerType;
        widgetList.add(Text(displayStr(currentPlayer)));
        widgetList.add(const Divider(
          height: 10,
          thickness: 1,
        ));
      }
      widgetList.add(
        Semantics(
          label: 'EffectListTile${keyName(effect.playerType)}',
          child: ListTile(
            title: Text(effect.displayName(loc: loc)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelect(effect);
            },
          ),
        ),
      );
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
                children: widgetList,
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
