import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/register_pokemon.dart';
import 'package:poke_reco/pokemons.dart';
import 'package:poke_reco/poke_db.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
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
  late List<Pokemon> pokemons;

  MyAppState() {
    fetchPokeData();
  }

  Future<void> fetchPokeData() async {
    pokemons = await pokeData.initialize();
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
        page = BattlesPage();
        break;
      case TabItem.pokemons:
        page = TabNavigator(
                navigatorKey: _navigatorKeys[TabItem.battles],
                tabItem: TabItem.battles
              );
        break;
      case TabItem.parties:
        page = Placeholder();
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

class TabNavigatorRoutes {
  static const String root = '/';
  static const String register = '/register';
}

class TabNavigator extends StatefulWidget {
  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
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
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case TabNavigatorRoutes.register:
                // 新規作成
                return RegisterPokemonPage(
                  onFinish: () => _pop(context),
                  myPokemon: Pokemon(),
                  isNew: true,
                );
              default:
                return PokemonsPage(
                  onAdd: (myPokemon, isNew) => _push(context, myPokemon, isNew)
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
