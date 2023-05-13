import 'package:flutter/material.dart';
import 'package:poke_reco/main.dart';
import 'package:provider/provider.dart';

class PokemonsPage extends StatelessWidget {
  const PokemonsPage({
    Key? key,
    required this.onAdd,
  }) : super(key: key);
  final void Function() onAdd;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;

    Widget lists;

    if (pokemons.isEmpty) {
      lists = Center(
        child: Text('ポケモンが登録されていません。'),
      );
    }
    else {
      lists = ListView(
        children: [
          for (var pokemon in pokemons)
            ListTile(
              leading: Icon(Icons.catching_pokemon),
              title:  Text(pokemon.name),            
            ),
        ],
      );
    }

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.outline,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ポケモン一覧'),
      ),
      body: Stack(
        children: [
          lists,
          Align(
            alignment: Alignment.bottomRight,
            //padding: EdgeInsets.all(30),
            child: FloatingActionButton(
              tooltip: 'ポケモン登録',
              shape: CircleBorder(),
              onPressed: (){
                onAdd();
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
