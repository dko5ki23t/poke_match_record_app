import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/register_pokemon.dart';
import 'package:poke_reco/my_flutter_app_icons.dart';
import 'package:provider/provider.dart';

enum TabItem {
  battles,
  pokemons,
  parties,
}

const Map<TabItem, String> tabName = {
  TabItem.battles: '対戦',
  TabItem.pokemons: 'ポケモン',
  TabItem.parties: 'パーティ',
};

const Map<TabItem, IconData> tabIcon = {
  TabItem.battles: Icons.list,
  TabItem.pokemons: Icons.catching_pokemon,
  TabItem.parties: Icons.groups,
};

enum Sex {
  male,
  female,
  none,
}

// 使い方：print(PokeType.normal.displayName) -> 'ノーマル'
enum PokeType {
  normal('ノーマル', Icons.radio_button_unchecked),
  fire('ほのお', Icons.whatshot),
  water('みず', Icons.opacity),
  grass('くさ', Icons.grass),
  electric('でんき', Icons.bolt),
  ice('こおり', Icons.ac_unit),
  fighting('かくとう', Icons.sports_mma),
  poison('どく', Icons.coronavirus),
  ground('じめん', Icons.abc),
  flying('ひこう', Icons.air),
  psychic('エスパー', Icons.psychology),
  bug('むし', Icons.bug_report),
  rock('いわ', Icons.abc),
  ghost('ゴースト', Icons.abc),
  dragon('ドラゴン', MyFlutterApp.dragon),
  dark('あく', Icons.abc),
  steel('はがね', Icons.abc),
  fairy('フェアリー', Icons.abc),
  ;

  const PokeType(this.displayName, this.displayIcon);

  final String displayName;
  final IconData displayIcon;
}

// TODO: 全部追加する
enum Temper {
  ijippari('いじっぱり'),
  tereya('てれや'),
  ;

  const Temper(this.displayName);

  final String displayName;
}

class SixParams {
  int race = 0;
  int indi = 0;
  int effort = 0;
  int real = 0;

  set(race, indi, effort, real) {
    this.race = race;
    this.indi = indi;
    this.effort = effort;
    this.real = real;
  }
}

// TODO: 全部追加する
enum Ability {
  ikaku('いかく'),
  bakenokawa('ばけのかわ'),
  ;

  const Ability(this.displayName);

  final String displayName;
}

// TODO: 全部追加する
enum Item {
  tabenokoshi('たべのこし'),
  kodawarimegane('こだわりメガネ'),
  ;

  const Item(this.displayName);

  final String displayName;
}

// TODO: 全部追加する
enum Move {
  jumanboruto('10まんボルト'),
  meiso('めいそう'),
  ;

  const Move(this.displayName);

  final String displayName;
}

class Pokemon {
  String name = 'アンノーン';       // ポケモン名
  String nickname = '';            // ニックネーム
  int level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int no = 1;                      // 図鑑No.
  PokeType type1 = PokeType.normal;        // タイプ1
  PokeType? type2;                     // タイプ2(null OK)
  PokeType teraType = PokeType.normal;     // テラスタルタイプ
  Temper temper = Temper.ijippari; // せいかく
  SixParams h = SixParams();       // HP
  SixParams a = SixParams();       // こうげき
  SixParams b = SixParams();       // ぼうぎょ
  SixParams c = SixParams();       // とくこう
  SixParams d = SixParams();       // とくぼう
  SixParams s = SixParams();       // すばやさ
  Ability ability = Ability.ikaku; // とくせい
  Item? item;                      // もちもの(null OK)
  Move move1 = Move.meiso;         // わざ1
  int pp1 = 5;                     // PP1
  Move? move2;                     // わざ2
  int? pp2 = 5;                    // PP2
  Move? move3;                     // わざ3
  int? pp3 = 5;                    // PP3
  Move? move4;                     // わざ4
  int? pp4 = 5;                    // PP4
}

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
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var pokemons = <Pokemon>[];
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

class PokemonsPage extends StatelessWidget {
  const PokemonsPage({
    Key? key,
    required this.onPush,
  }) : super(key: key);
  final void Function() onPush;

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

    return Stack(
      children: [
        lists,
        Align(
          alignment: Alignment.bottomRight,
          //padding: EdgeInsets.all(30),
          child: FloatingActionButton(
            tooltip: 'ポケモン登録',
            shape: CircleBorder(),
            onPressed: (){
              onPush();
            },
            child: Icon(Icons.add),
          ),
        )
      ],
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

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return RegisterPokemonPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case TabNavigatorRoutes.register:
                return RegisterPokemonPage();
              default:
                return PokemonsPage(
                  onPush: () => _push(context)
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
