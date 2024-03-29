import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poke_reco/ad_banner.dart';
import 'package:poke_reco/data_structs/phase_state.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/pages/battles.dart';
import 'package:poke_reco/pages/parties.dart';
import 'package:poke_reco/pages/register_battle.dart';
import 'package:poke_reco/pages/register_party.dart';
import 'package:poke_reco/pages/register_pokemon.dart';
import 'package:poke_reco/pages/pokemons.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/pages/settings.dart';
import 'package:poke_reco/pages/view_battle.dart';
import 'package:poke_reco/pages/view_party.dart';
import 'package:poke_reco/pages/view_pokemon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:poke_reco/data_structs/battle.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String pokeRecoVersion = '1.0.3';
const int pokeRecoInternalVersion = 2;      // SQLのテーブルバージョンに使用

enum TabItem {
  battles,
  pokemons,
  parties,
  settings,
}

const Map<TabItem, IconData> tabIcon = {
  TabItem.battles: Icons.list,
  TabItem.pokemons: Icons.catching_pokemon,
  TabItem.parties: Icons.groups,
  TabItem.settings: Icons.settings,
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final directory = await getApplicationDocumentsDirectory();
  final localPath = directory.path;
  final saveDataFile = File('$localPath/poke_reco.json');
  String configText;
  dynamic configJson;
  Locale? locale;
  try {
    configText = await saveDataFile.readAsString();
    configJson = jsonDecode(configText);
    switch (configJson[configKeyLanguage] as int) {
      case 1:
        locale = Locale('en');
        break;
      case 0:
      default:
        locale = Locale('ja');
        break;
    }
  }
  catch (e) {
    locale = null;
  }
  runApp(MyApp(initialLocale: locale));
}

class MyApp extends StatefulWidget {
  final Locale? initialLocale;
  const MyApp({required this.initialLocale, super.key});

  @override
  State<MyApp> createState() => MyAppStateForLocale();
  static MyAppStateForLocale? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppStateForLocale>();
}

class MyAppStateForLocale extends State<MyApp> {
  Locale? _locale;
  bool firstBuild = true;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      _locale = widget.initialLocale;
      firstBuild = false;
    }
    return ChangeNotifierProvider(
      create: (context) => MyAppState(context, _locale),
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ja', ''),
          const Locale('en', ''),
        ],
        locale: _locale,
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

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
}

class MyAppState extends ChangeNotifier {
  final pokeData = PokeDB();
  Map<int, Pokemon> pokemons = {};
  Map<int, Party> parties = {};
  Map<int, Battle> battles = {};
  void Function() onBackKeyPushed = (){};
  void Function(void Function() func) onTabChange = (func) {};  // 各ページで書き換えてもらう関数
  void Function(void Function() func) changeTab = (func) {};
  bool allowPop = false;
  // 対戦登録画面のわざ選択前後入力で必要なステート
  List<bool> editingPhase = [];
  // ターン内のフェーズ更新要求フラグ(指定したインデックス以降)
  int needAdjustPhases = -1;
  // 行動順入れ替え要求フラグ
  bool requestActionSwap = false;
  // 削除によるフェーズ更新かどうか(trueの場合、自動補完は無効にする)
  bool adjustPhaseByDelete = false;
  // 広告表示フラグ
  bool showAd = false;

  MyAppState(BuildContext context, Locale? locale) {
    changeTab = (func) {onTabChange(func);};
    fetchPokeData(locale ?? Locale(Platform.localeName.substring(0,2), ''));
  }

  Future<void> fetchPokeData(Locale locale) async {
    await pokeData.initialize(locale);
    pokemons = pokeData.pokemons;
    parties = pokeData.parties;
    battles = pokeData.battles;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentTab = TabItem.battles;
  Widget page = Container();
  final _navigatorKeys = {
    TabItem.battles: GlobalKey<NavigatorState>(),
    TabItem.pokemons: GlobalKey<NavigatorState>(),
    TabItem.parties: GlobalKey<NavigatorState>(),
  };

  void _selectTab(TabItem tabItem) async {
    if (_currentTab != tabItem) {
      var appState = context.read<MyAppState>();
      appState.changeTab(() {
        setState(() => _currentTab = tabItem);
      },);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      case TabItem.settings:
        page = SettingTabNavigator(
          navigatorKey: _navigatorKeys[TabItem.settings],
          tabItem: TabItem.settings,
        );
        break;
      default:
        throw UnimplementedError('no widget');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return PopScope(
          onPopInvoked: (canPop) {
            if (canPop) {
              var appState = context.read<MyAppState>();
              appState.onBackKeyPushed();
  /*            Navigator.pop(
                currentContext,
              );*/
            }
          },
          child: Scaffold(
            body: Center(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
            bottomNavigationBar: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait,
                      MediaQuery.of(context).size.width.truncate()),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<AnchoredAdaptiveBannerAdSize?> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      final data = snapshot.data;
                      if (data != null) {
                        return Container(
                          height: 70,
                          color: Colors.white70,
                          child: AdBanner(size: data),
                        );
                      } else {
                        return Container(
                          height: 70,
                          color: Colors.white70,
                        );
                      }
                    } else {
                      return Container(
                        height: 70,
                        color: Colors.white70,
                      );
                    }
                  },
                ),
                BottomNavigation(
                  currentTab: _currentTab,
                  onSelectTab: _selectTab,
                ),
              ],
            ),
          ),
        );
      }
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

  void pop() {
    
  }
}

class _PokemonTabNavigatorState extends State<PokemonTabNavigator> {
  void _pushRegister(BuildContext context, Pokemon myPokemon, bool isNew, {bool isChange = false,}) {
    if (isChange) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // 新規作成
            return RegisterPokemonPage(
              onFinish: () => _pop(context),
              myPokemon: myPokemon,
            );
          },
        ),
      ).then((value) {setState(() {});});
    }
    else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // 新規作成
            return RegisterPokemonPage(
              onFinish: () => _pop(context),
              myPokemon: myPokemon,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final Offset begin = Offset(1.0, 0.0); // 右から左
            const Offset end = Offset.zero;
            final Animatable<Offset> tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOut));
            final Animation<Offset> offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ).then((value) {setState(() {});});
    }
  }

  void _pushView(BuildContext context, List<Pokemon> pokemonList, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // ポケモン詳細表示
          return ViewPokemonPage(
            pokemonList: pokemonList,
            listIndex: index,
            onEdit: (pokemon) => _pushRegister(context, pokemon, false),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
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
                  //isNew: true,
                );
              default:
                return PokemonsPage(
                  onAdd: (myPokemon, isNew) => _pushRegister(context, myPokemon, isNew),
                  onView: (pokemonList, index) => _pushView(context, pokemonList, index),
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
  void _pushRegister(BuildContext context, Party party, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 新規作成
          return RegisterPartyPage(
            onFinish: () => _pop(context),
            onSelectPokemon: (party, idx) => _pushSelectPokemonPage(context, party, idx),
            party: party,
            isNew: isNew,
            isEditPokemon: false,
            onEditPokemon: (pokemon, pokemonState) => {},
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pushView(BuildContext context, List<Party> partyList, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // パーティ詳細表示
          return ViewPartyPage(
            partyList: partyList,
            listIndex: index,
            onEdit: (party) => _pushRegister(context, party, false),
            onViewPokemon: (pokemonList, listIndex) => _pushPokemonView(context, pokemonList, listIndex),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pushPokemonView(BuildContext context, List<Pokemon> pokemonList, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // ポケモン詳細表示
          return ViewPokemonPage(
            pokemonList: pokemonList,
            listIndex: index,
            onEdit: (pokemon) => _pushPokemonRegister(context, pokemon, false),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pushPokemonRegister(BuildContext context, Pokemon pokemon, bool isNew) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // ポケモン編集
          return RegisterPokemonPage(
            onFinish: () => _pop(context),
            myPokemon: pokemon,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  Future<Pokemon?> _pushSelectPokemonPage(BuildContext context, Party party, int selectingPokemonIdx) async {
    var result =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // ポケモン選択
            return PokemonsPage(
              onAdd: (pokemon, isNew) {},
              onView: (pokemonList, index) {},
              onSelect: (pokemon) => _popSelectPokemonPage(context, pokemon),
              selectMode: true,
              party: party,
              selectingPokemonIdx: selectingPokemonIdx,
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
                  onSelectPokemon: (party, idx) => _pushSelectPokemonPage(context, party, idx),
                  party: Party(),
                  isNew: true,
                  isEditPokemon: false,
                  onEditPokemon: (pokemon, pokemonState) => {},
                );
              case PartyTabNavigatorRoutes.registerPokemon:
                // ポケモン選択
                return PokemonsPage(
                  onAdd: (pokemon, isNew){},
                  onView:(pokemonList, index) {},
                  onSelect: (pokemon) => _popSelectPokemonPage(context, pokemon),
                  selectMode: true,
                );
              default:
                return PartiesPage(
                  onAdd: (party, isNew) => _pushRegister(context, party, isNew),
                  onSelect: null,
                  onView: (partyList, index) => _pushView(context, partyList, index),
                  selectMode: false,
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
  void _push(
    BuildContext context,
    Battle battle,
    bool isNew,
    {
      RegisterBattlePageType pageType = RegisterBattlePageType.basePage,
      int turnNum = 1,
    }
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 新規作成
          return RegisterBattlePage(
            onFinish: () => _pop(context),
            onSelectParty: () => _pushSelectPartyPage(context),
            battle: battle,
            isNew: isNew,
            onSaveOpponentParty: (party, state) => _pushRegisterPartyPage(context, party, state),
            firstPageType: pageType,
            firstTurnNum: turnNum,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pushBattleView(BuildContext context, Battle battle,) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // 対戦詳細表示
          return ViewBattlePage(
            battle: battle,
            onEdit: (b, pageType, turnNum) =>
              _push(context, b, false, pageType: pageType, turnNum: turnNum),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

  void _pushEditPokemonPage(BuildContext context, Pokemon pokemon, PokemonState pokemonState) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // ポケモン編集
          return RegisterPokemonPage(
            onFinish: () => _pop(context),
            myPokemon: pokemon,
            //isNew: false,
            pokemonState: pokemonState,
          );
        },
      ),
    );
  }

  Future<Party?> _pushSelectPartyPage(BuildContext context) async {
    var result =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // パーティ選択
            return PartiesPage(
              onAdd: (party, isNew) {},
              onSelect: (party) => _popSelectPartyPage(context, party),
              onView: (partyList, index) {},
              selectMode: true,
            );
          },
        ),
      );
    return Future<Party?>.value(result);
  }

  Future<void> _pushRegisterPartyPage(BuildContext context, Party party, PhaseState state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // パーティ登録
          return RegisterPartyPage(
            onFinish: () => _pop(context),
            onSelectPokemon: (party, idx) {return Future<Pokemon?>.value(Pokemon());},    // 使わない
            party: party,
            isNew: party.id == 0,
            isEditPokemon: true,
            onEditPokemon: (pokemon, pokemonState) => _pushEditPokemonPage(context, pokemon, pokemonState),
            phaseState: state,
          );
        },
      ),
    );
    return Future<void>.value();
  }

  void _pop(BuildContext context) {
    Navigator.pop(
      context,
    );
  }

  void _popSelectPartyPage(BuildContext context, Party party) {
    Navigator.of(context).pop(
      party,
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
                  onSelectParty: () => _pushSelectPartyPage(context),
                  battle: Battle(),
                  isNew: true,
                  onSaveOpponentParty: (party, state) => _pushRegisterPartyPage(context, party, state),
                  firstPageType: RegisterBattlePageType.basePage,
                  firstTurnNum: 1,
                );
              default:
                return BattlesPage(
                  onAdd: (battle, isNew) => _push(context, battle, isNew),
                  onView: (battle) => _pushBattleView(context, battle),
                );
            }
          },
        );
      },
    );
  }
}

class SettingTabNavigatorRoutes {
  static const String root = '/';
  static const String reset = '/reset';
  static const String language = '/language';
  static const String license = '/license';
  static const String policy = '/policy';
}

class SettingTabNavigator extends StatefulWidget {
  const SettingTabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  State<SettingTabNavigator> createState() => _SettingTabNavigatorState();
}

class _SettingTabNavigatorState extends State<SettingTabNavigator> {
  void _push(BuildContext context, String route) {
    Widget pushPage = Container();
    switch (route) {
      case SettingTabNavigatorRoutes.reset:
        pushPage = SettingResetPage();
        break;
      case SettingTabNavigatorRoutes.language:
        pushPage = SettingLanguagePage();
        break;
      case SettingTabNavigatorRoutes.license:
        pushPage = SettingLicensePage();
        break;
      case SettingTabNavigatorRoutes.policy:
        pushPage = SettingPolicyPage();
        break;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return pushPage;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = Offset(1.0, 0.0); // 右から左
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((value) {setState(() {});});
  }

/*
  void _pop(BuildContext context) {
    Navigator.pop(
      context,
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: SettingTabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (routeSettings.name) {
              case SettingTabNavigatorRoutes.reset:
                return SettingResetPage();
              default:
                return SettingsPage(
                  onReset: () => _push(context, SettingTabNavigatorRoutes.reset),
                  viewLanguage: () => _push(context, SettingTabNavigatorRoutes.language),
                  viewLicense: () => _push(context, SettingTabNavigatorRoutes.license),
                  viewPolicy: () => _push(context, SettingTabNavigatorRoutes.policy),
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

  String _tabName(TabItem item, BuildContext context) {
    switch (item) {
      case TabItem.battles:
        return AppLocalizations.of(context)!.tabBattles;
      case TabItem.pokemons:
        return AppLocalizations.of(context)!.tabPokemons;
      case TabItem.parties:
        return AppLocalizations.of(context)!.tabParties;
      case TabItem.settings:
        return AppLocalizations.of(context)!.tabSettings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        for (var tab in TabItem.values)
          BottomNavigationBarItem(
            icon: Icon(tabIcon[tab]),
            label: _tabName(tab, context),
          ),
      ],
      currentIndex: currentTab.index,
      onTap: (index) => onSelectTab(TabItem.values[index])
    );
  }
}
