import 'package:flutter/material.dart';
import 'package:poke_reco/custom_widgets/party_tile.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BattleFilterDialog extends StatefulWidget {
  final Future<void> Function (
    List<int> winFilter,
    List<int> partyIDFilter) onOK;
  final PokeDB pokeData;
  final List<int> winFilter;
  final List<int> partyIDFilter;

  const BattleFilterDialog(
    this.pokeData,
    this.winFilter,
    this.partyIDFilter,
    this.onOK,
    {Key? key}) : super(key: key);

  @override
  BattleFilterDialogState createState() => BattleFilterDialogState();
}

class BattleFilterDialogState extends State<BattleFilterDialog> {
  bool isFirstBuild = true;
  bool winExpanded = true;
  bool partyIDExpanded = true;
  List<int> winFilter = [];
  List<int> partyIDFilter = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    if (isFirstBuild) {
      winFilter = [...widget.winFilter];
      partyIDFilter = [...widget.partyIDFilter];
      isFirstBuild = false;
    }

    return AlertDialog(
      title: Text(loc.commonFilter),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() {
                winExpanded = !winExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text(loc.filterDialogWinOrLose),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: winExpanded ?
                      Icon(Icons.keyboard_arrow_up) :
                      Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            winExpanded ?
            ListTile(
              title: Text(loc.filterDialogUndecided),
              leading: Checkbox(
                value: winFilter.contains(1),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      winFilter.add(1);
                    }
                    else {
                      winFilter.remove(1);
                    }
                  });
                },
              ),
            ) : Container(),
            winExpanded ?
            ListTile(
              title: Text(loc.filterDialogWin),
              leading: Checkbox(
                value: winFilter.contains(2),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      winFilter.add(2);
                    }
                    else {
                      winFilter.remove(2);
                    }
                  });
                },
              ),
            ) : Container(),
            winExpanded ?
            ListTile(
              title: Text(loc.filterDialogLose),
              leading: Checkbox(
                value: winFilter.contains(3),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value == true) {
                      winFilter.add(3);
                    }
                    else {
                      winFilter.remove(3);
                    }
                  });
                },
              ),
            ) : Container(),
            GestureDetector(
              onTap:() => setState(() {
                partyIDExpanded = !partyIDExpanded;
              }),
              child: Stack(
                children: [
                  Center(child: Text(loc.filterDialogParty),),
                  Align(
                    alignment: Alignment.centerRight,
                    child: partyIDExpanded ?
                      Icon(Icons.keyboard_arrow_up) :
                      Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            for (var partyID in partyIDFilter)
              partyIDExpanded ?
              ListTile(
                title: Text(widget.pokeData.parties[partyID]!.name),
                leading: Checkbox(
                  value: partyIDFilter.contains(partyID),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (value == true) {
                        partyIDFilter.add(partyID);
                      }
                      else {
                        partyIDFilter.remove(partyID);
                      }
                    });
                  },
                ),
              ) : Container(),
            partyIDExpanded ?
            ListTile(
              title: DropdownButtonFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: loc.filterDialogAddParty,
                ),
                selectedItemBuilder: (context) {
                  return [
                    for (final party in widget.pokeData.parties.values.where((element) => element.id != 0 && element.owner == Owner.mine))
                      Text(party.name),
                  ];
                },
                items: <DropdownMenuItem>[
                  for (final party in widget.pokeData.parties.values.where((element) => element.id != 0 && element.owner == Owner.mine))
                    DropdownMenuItem(
                      value: party.id,
                      child: PartyTile(party, theme, loc: loc,),
                    ),
                ],
                value: null,
                onChanged: (value) {
                  partyIDFilter.add(value);
                  setState(() {});
                },
              ),
            ) : Container(),
          ],
        ),
      ),
      actions:
        <Widget>[
          GestureDetector(
            child: Text(loc.commonCancel),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child: Text(loc.commonReset),
            onTap: () {
              winFilter = [for (int i = 1; i < 4; i++) i];
              partyIDFilter = [];
            },
          ),
          GestureDetector(
            child: Text('OK'),
            onTap: () async {
              Navigator.pop(context);
              await widget.onOK(winFilter, partyIDFilter,);
            },
          ),
        ],
    );
  }
}