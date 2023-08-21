import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:poke_reco/battles.dart';
import 'package:poke_reco/parties.dart';
import 'package:poke_reco/register_battle.dart';
import 'package:poke_reco/register_party.dart';
import 'package:poke_reco/register_pokemon.dart';
import 'package:poke_reco/pokemons.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  // TODO
//  Intl.defaultLocale = 'ja_JP';
//  initializeDateFormatting('ja', );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Poke Reco',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          fontFamily: 'Murecho',
        ),
        home: MyHomePage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  final pokeData = PokeDB();
  List<Pokemon> pokemons = [];
  List<Party> parties = [];
  List<Battle> battles = [];

  MyAppState() {
    fetchPokeData();
  }

  Future<void> fetchPokeData() async {
    await pokeData.initialize();
    pokemons = pokeData.pokemons;
    parties = pokeData.parties;
    battles = pokeData.battles;
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentTab = TabItem.battles;
  final _navigatorKeys = {
    TabItem.battles: GlobalKey<NavigatorState>(),
    TabItem.pokemons: GlobalKey<NavigatorState>(),
    TabItem.parties: GlobalKey<NavigatorState>(),
  };

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_currentTab) {
      case TabItem.battles:
        page = BattleTabNavigator(
          navigatorKey: _navigatorKeys[TabItem.battles],
          tabItem: TabItem.battles,
        );
        break;
      case TabItem.pokemons:
        page = PokemonTabNavigator(
          navigatorKey: _navigatorKeys[TabItem.pokemons],
          tabItem: TabItem.pokemons,
        );
        break;
      case TabItem.parties:
        page = PartyTabNavigator(
          navigatorKey: _navigatorKeys[TabItem.parties],
          tabItem: TabItem.parties,
        );
        break;
      default:
        throw UnimplementedError('no widget');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Center(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            currentTab: _currentTab,
            onSelectTab: _selectTab,
          ),
        );
      }
    );
  }
}

/*
class BattlesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                },
                icon: Icon(Icons.abc),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class PokemonTabNavigatorRoutes {
  static const String root = '/';
  static const String register = '/register';
}

class PokemonTabNavigator extends StatefulWidget {
  const PokemonTabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  State<PokemonTabNavigator> createState() => _PokemonTabNavigatorState();
}

class _PokemonTabNavigatorState extends State<PokemonTabNavigator> {
  void _push(BuildContext context, Pokemon myPokemon, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 新規作成
          return RegisterPokemonPage(
            onFinish: () => _pop(context),
            myPokemon: myPokemon,
            isNew: isNew,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pop(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: PokemonTabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case PokemonTabNavigatorRoutes.register:
                // 新規作成
                return RegisterPokemonPage(
                  onFinish: () => _pop(context),
                  myPokemon: Pokemon(),
                  isNew: true,
                );
              default:
                return PokemonsPage(
                  onAdd: (myPokemon, isNew) => _push(context, myPokemon, isNew),
                  onSelect: null,
                  selectMode: false,
                );
            }
          },
        );
      },
    );
  }
}

class PartyTabNavigatorRoutes {
  static const String root = '/';
  static const String register = '/register';
  static const String registerPokemon = '/register/pokemon';
}

class PartyTabNavigator extends StatefulWidget {
  const PartyTabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  State<PartyTabNavigator> createState() => _PartyTabNavigatorState();
}

class _PartyTabNavigatorState extends State<PartyTabNavigator> {
  void _push(BuildContext context, Party party, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 新規作成
          return RegisterPartyPage(
            onFinish: () => _pop(context),
            onSelectPokemon: (party) => _pushSelectPokemonPage(context, party),
            party: party,
            isNew: isNew,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  Future<Pokemon?> _pushSelectPokemonPage(BuildContext context, Party party) async {
    var result =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // ポケモン選択
            return PokemonsPage(
              onAdd: (pokemon, isNew){},
              onSelect: (pokemon) => _popSelectPokemonPage(context, pokemon),
              selectMode: true,
              party: party,
            );
          },
        ),
      );
    return Future<Pokemon?>.value(result);
  }

  void _pop(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

  void _popSelectPokemonPage(BuildContext context, Pokemon pokemon) {
    Navigator.of(context).pop(
      pokemon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: PartyTabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case PartyTabNavigatorRoutes.register:
                // 新規作成
                return RegisterPartyPage(
                  onFinish: () => _pop(context),
                  onSelectPokemon: (party) => _pushSelectPokemonPage(context, party),
                  party: Party(),
                  isNew: true,
                );
              case PartyTabNavigatorRoutes.registerPokemon:
                // ポケモン選択
                return PokemonsPage(
                  onAdd: (pokemon, isNew){},
                  onSelect: (pokemon) => _popSelectPokemonPage(context, pokemon),
                  selectMode: true,
                );
              default:
                return PartiesPage(
                  onAdd: (party, isNew) => _push(context, party, isNew)
                );
            }
          },
        );
      },
    );
  }
}

class BattleTabNavigatorRoutes {
  static const String root = '/';
  static const String register = '/register';
}

class BattleTabNavigator extends StatefulWidget {
  const BattleTabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  State<BattleTabNavigator> createState() => _BattleTabNavigatorState();
}

class _BattleTabNavigatorState extends State<BattleTabNavigator> {
  void _push(BuildContext context, Battle battle, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 新規作成
          return RegisterBattlePage(
            onFinish: () => _pop(context),
            battle: battle,
            isNew: isNew,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pop(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: BattleTabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case BattleTabNavigatorRoutes.register:
                // 新規作成
                return RegisterBattlePage(
                  onFinish: () => _pop(context),
                  battle: Battle(),
                  isNew: true,
                );
              default:
                return BattlesPage(
                  onAdd: (battle, isNew) => _push(context, battle, isNew)
                );
            }
          },
        );
      },
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onSelectTab,
  }) : super(key: key);
  final TabItem currentTab;
  final void Function(TabItem) onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        for (var tab in TabItem.values)
          BottomNavigationBarItem(
            icon: Icon(tabIcon[tab]),
            label: tabName[tab],
          ),
      ],
      currentIndex: currentTab.index,
      onTap: (index) => onSelectTab(TabItem.values[index])
    );
  }
}
