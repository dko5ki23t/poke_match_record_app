import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/timing.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';
import 'package:poke_reco/tool.dart';

class AddEffectDialog extends StatefulWidget {
  final void Function(TurnEffect effect) onSelect;
  final String title;
  final List<TurnEffect> effectList;
  final String youText;
  final String? youAfterMoveText; // 交代わざ使用後の場合(交代する前のポケモンの表示)
  final String opponentText;
  final String? opponentAfterMoveText; // 交代わざ使用後の場合(交代する前のポケモンの表示)

  const AddEffectDialog({
    required this.onSelect,
    required this.title,
    required this.effectList,
    required this.youText,
    required this.youAfterMoveText,
    required this.opponentText,
    required this.opponentAfterMoveText,
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
    String displayStr(PlayerType player, bool isAfterMove) {
      String ret = '';
      if (player == PlayerType.me) {
        ret = isAfterMove
            ? widget.youAfterMoveText ?? widget.youText
            : widget.youText;
      } else if (player == PlayerType.opponent) {
        ret = isAfterMove
            ? widget.opponentAfterMoveText ?? widget.opponentText
            : widget.opponentText;
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

    // 統合テスト作成用
    List<Map<String, bool>> doubling = [{}, {}, {}];

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
    bool currentIsAfterMove = false;
    if (filteredList.isNotEmpty) {
      currentPlayer = filteredList.first.playerType;
      currentIsAfterMove = filteredList.first.timing == Timing.afterMove;
      widgetList.add(Text(displayStr(currentPlayer, currentIsAfterMove)));
      widgetList.add(const Divider(
        height: 10,
        thickness: 1,
      ));
    }
    for (final effect in filteredList) {
      if (effect.playerType != currentPlayer) {
        currentPlayer = effect.playerType;
        currentIsAfterMove = effect.timing == Timing.afterMove;
        widgetList.add(Text(displayStr(currentPlayer, currentIsAfterMove)));
        widgetList.add(const Divider(
          height: 10,
          thickness: 1,
        ));
      } else if ((effect.timing == Timing.afterMove) != currentIsAfterMove) {
        currentIsAfterMove = effect.timing == Timing.afterMove;
        if ((currentPlayer == PlayerType.me &&
                widget.youAfterMoveText != null) ||
            (currentPlayer == PlayerType.opponent &&
                widget.opponentAfterMoveText != null)) {
          widgetList.add(Text(displayStr(currentPlayer, currentIsAfterMove)));
          widgetList.add(const Divider(
            height: 10,
            thickness: 1,
          ));
        }
      }
      // 統合テスト作成用
      String labelNo = '1';
      if (doubling[effect.playerType.number]
          .containsKey(effect.displayName(loc: loc))) {
        labelNo = '2';
      }
      widgetList.add(
        Semantics(
          label: 'EffectListTile${keyName(effect.playerType)}$labelNo',
          child: ListTile(
            title: Text(effect.displayName(loc: loc)),
            onTap: () {
              Navigator.pop(context);
              widget.onSelect(effect);
            },
          ),
        ),
      );
      // 統合テスト作成用
      if (effect.playerType.number >= 0) {
        doubling[effect.playerType.number][effect.displayName(loc: loc)] = true;
      }
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
