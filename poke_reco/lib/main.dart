import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:poke_reco/register_pokemon.dart';
import 'package:provider/provider.dart';

enum Sex {
  male,
  female,
  none,
}

class Pokemon {
  String name = 'アンノーン';       // ポケモン名
  String nickname = '';            // ニックネーム
  int level = 50;                  // レベル
  Sex sex = Sex.none;              // せいべつ
  int no = 1;                      // 図鑑No.
  Type type1 = Type.normal;        // タイプ1
  Type? type2;                     // タイプ2(null OK)
  Type teraType = Type.normal;     // テラスタルタイプ
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
  Move? move2;                     // わざ2
  Move? move3;                     // わざ3
  Move? move4;                     // わざ4
}

// 使い方：print(Type.normal.displayName) -> 'ノーマル'
enum Type {
  normal('ノーマル'),
  fire('ほのお'),
  water('みず'),
  grass('くさ'),
  electric('でんき'),
  ice('こおり'),
  fighting('かくとう'),
  poison('どく'),
  ground('じめん'),
  flying('ひこう'),
  psychic('エスパー'),
  bug('むし'),
  rock('いわ'),
  ghost('ゴースト'),
  dragon('ドラゴン'),
  dark('あく'),
  steel('はがね'),
  fairy('フェアリー'),
  ;

  const Type(this.displayName);

  final String displayName;
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

/*
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    }
    else {
      favorites.add(current);
    }
    notifyListeners();
  }
*/
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = BattlesPage();
        break;
      case 1:
        page = PokemonsPage();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Poke Reco')
          ),
          body: Center(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '対戦',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets),
                label: 'ポケモン',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups),
                label: 'パーティ',
              ),
            ],
            currentIndex: _selectedIndex,
//            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
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

class PokemonsPage extends StatefulWidget {
  @override
  State<PokemonsPage> createState() => _PokemonsPageState();
}

class _PokemonsPageState extends State<PokemonsPage> {
  /*var _

  void _onPushed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

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
              leading: Icon(Icons.pets),
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterPokemonPage())
              );
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
