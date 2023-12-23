import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PokemonDeleteCheckDialog extends StatefulWidget {
  final bool containedParty;
  final void Function() onClearPressed;

  const PokemonDeleteCheckDialog(
    this.containedParty,
    this.onClearPressed,
    {Key? key}) : super(key: key);

  @override
  PokemonDeleteCheckDialogState createState() => PokemonDeleteCheckDialogState();
}

class PokemonDeleteCheckDialogState extends State<PokemonDeleteCheckDialog> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.dialogQuestionDeletePokemons1),
      content: widget.containedParty ?
        Text(loc.dialogQuestionDeletePokemons2) : Text(''),
      actions: <Widget>[
        GestureDetector(
          child: Text(loc.commonNo),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          child: Text(loc.commonYes),
          onTap: () {
            Navigator.pop(context);
            widget.onClearPressed();
          },
        )
      ],
    );
  }
}