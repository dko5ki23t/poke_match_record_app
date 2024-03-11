import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/data_structs/turn_effect/turn_effect.dart';

class EditEffectDialog extends StatefulWidget {
  final void Function() onDelete;
  final void Function(TurnEffect effect) onEdit;
  final String title;
  final TurnEffect turnEffect;
  final PokemonState myState;
  final PokemonState yourState;
  final Party ownParty;
  final Party opponentParty;
  final PhaseState state;

  const EditEffectDialog(
    this.onDelete,
    this.onEdit,
    this.title,
    this.turnEffect,
    this.myState,
    this.yourState,
    this.ownParty,
    this.opponentParty,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  EditEffectDialogState createState() => EditEffectDialogState();
}

class EditEffectDialogState extends State<EditEffectDialog> {
  late TurnEffect editingEffect;
  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    editingEffect = widget.turnEffect.copy();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
          child: editingEffect.editArgWidget(
              widget.myState,
              widget.yourState,
              widget.ownParty,
              widget.opponentParty,
              widget.state,
              controller,
              controller2,
              onEdit: () => setState(() {}),
              loc: loc,
              theme: theme)),
      actions: <Widget>[
        TextButton(
          child: Text(loc.commonCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(
            loc.commonDelete,
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onDelete();
          },
        ),
        TextButton(
          onPressed: editingEffect.isValid()
              ? () {
                  Navigator.pop(context);
                  widget.onEdit(editingEffect);
                  // 統合テスト作成用
                  print("await driver.tap(find.text('OK'));");
                }
              : null,
          child: Text('OK'),
        ),
      ],
    );
  }
}
