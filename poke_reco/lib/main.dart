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
import 'package:go_router/go_router.dart';

const String pokeRecoVersion = '2.1.2';
const int pokeRecoInternalVersion = 4; // SQLのテーブルバージョンに使用

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
final bottomNavBarAndAdKey =
    GlobalKey<NavigatorState>(debugLabel: 'bottomNavBarAndAdKey');
final bottomNavIconKeys = {
  TabItem.battles: GlobalKey<NavigatorState>(debugLabel: 'battlesIconKey'),
  TabItem.pokemons: GlobalKey<NavigatorState>(debugLabel: 'pokemonsIconKey'),
  TabItem.parties: GlobalKey<NavigatorState>(debugLabel: 'partiesIconKey'),
  TabItem.settings: GlobalKey<NavigatorState>(debugLabel: 'settingsIconKey'),
};

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final _navigatorKeys = {
  TabItem.battles: GlobalKey<NavigatorState>(debugLabel: 'battles'),
  TabItem.pokemons: GlobalKey<NavigatorState>(debugLabel: 'pokemons'),
  TabItem.parties: GlobalKey<NavigatorState>(debugLabel: 'parties'),
  TabItem.settings: GlobalKey<NavigatorState>(debugLabel: 'settings'),
};

void main({
  bool testMode = false,
  bool usePrepared = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final directory = await getApplicationDocumentsDirectory();
  final localPath = directory.path;
  final saveDataFile = File('$localPath/poke_reco.json');
  String configText;
  dynamic configJson;
  Locale? locale;
  // テストモードに設定
  if (testMode) {
    PokeDB().setTestMode();
  }
  // 事前準備したデータを使う
  if (usePrepared) {
    PokeDB().replacePrepared = true;
  }
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
  } catch (e) {
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

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: PokemonTabPath.root.fullpath,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // 対戦タブ
          StatefulShellBranch(
            navigatorKey: _navigatorKeys[TabItem.battles],
            routes: <RouteBase>[
              GoRoute(
                path: BattleTabPath.root.fullpath,
                builder: (BuildContext context, GoRouterState state) =>
                    const BattleTabScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: BattleTabPath.register.path,
                    builder: (BuildContext context, GoRouterState state) {
                      List argList = state.extra! as List;
                      return RegisterBattleScreen(
                        battle: argList[0],
                        isNew: argList[1],
                        pageType: argList[2],
                        turnNum: argList[3],
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: BattleTabPath.registerSelectParty.path,
                        builder: (BuildContext context, GoRouterState state) {
                          List argList = state.extra! as List;
                          return PartiesPage(
                            onAdd: argList[0],
                            onSelect: argList[1],
                            onView: argList[2],
                            selectMode: argList[3],
                          );
                        },
                      ),
                      GoRoute(
                        path: BattleTabPath.registerRegisterParty.path,
                        builder: (BuildContext context, GoRouterState state) {
                          List argList = state.extra! as List;
                          return RegisterPartyPage(
                            onFinish: argList[0],
                            onSelectPokemon: argList[1],
                            party: argList[2],
                            isNew: argList[3],
                            isEditPokemon: argList[4],
                            onEditPokemon: argList[5],
                            phaseState: argList[6],
                          );
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: BattleTabPath
                                .registerRegisterPartyEditPokemon.path,
                            builder:
                                (BuildContext context, GoRouterState state) {
                              List argList = state.extra! as List;
                              return RegisterPokemonPage(
                                onFinish: argList[0],
                                myPokemon: argList[1],
                                pokemonState: argList[2],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // ポケモンタブ
          StatefulShellBranch(
            navigatorKey: _navigatorKeys[TabItem.pokemons],
            routes: <RouteBase>[
              GoRoute(
                path: PokemonTabPath.root.fullpath,
                builder: (BuildContext context, GoRouterState state) =>
                    const PokemonTabScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: PokemonTabPath.register.path,
                    builder: (BuildContext context, GoRouterState state) {
                      List argList = state.extra! as List;
                      return RegisterPokemonPage(
                        onFinish: argList[0],
                        myPokemon: argList[1],
                      );
                    },
                  ),
                  GoRoute(
                    path: PokemonTabPath.view.path,
                    builder: (BuildContext context, GoRouterState state) {
                      List argList = state.extra! as List;
                      return ViewPokemonPage(
                        onEdit: argList[0],
                        pokemonIDList: argList[1],
                        listIndex: argList[2],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // パーティタブ
          StatefulShellBranch(
            navigatorKey: _navigatorKeys[TabItem.parties],
            routes: <RouteBase>[
              GoRoute(
                path: PartyTabPath.root.fullpath,
                builder: (BuildContext context, GoRouterState state) =>
                    const PartyTabScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: PartyTabPath.register.path,
                    builder: (BuildContext context, GoRouterState state) {
                      List argList = state.extra! as List;
                      return RegisterPartyPage(
                        onFinish: argList[0],
                        onSelectPokemon: argList[1],
                        party: argList[2],
                        isNew: argList[3],
                        isEditPokemon: argList[4],
                        onEditPokemon: argList[5],
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: PartyTabPath.registerSelectPokemon.path,
                        builder: (BuildContext context, GoRouterState state) {
                          List argList = state.extra! as List;
                          return PokemonsPage(
                            onAdd: argList[0],
                            onView: argList[1],
                            onSelect: argList[2],
                            selectMode: argList[3],
                            party: argList[4],
                            selectingPokemonIdx: argList[5],
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: PartyTabPath.view.path,
                    builder: (BuildContext context, GoRouterState state) {
                      List argList = state.extra! as List;
                      return ViewPartyPage(
                        partyIDList: argList[0],
                        listIndex: argList[1],
                        onEdit: argList[2],
                        onViewPokemon: argList[3],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: PartyTabPath.viewViewPokemon.path,
                        builder: (BuildContext context, GoRouterState state) {
                          List argList = state.extra! as List;
                          return ViewPokemonPage(
                            pokemonIDList: argList[0],
                            listIndex: argList[1],
                            onEdit: argList[2],
                          );
                        },
                        routes: [
                          GoRoute(
                            path: PartyTabPath
                                .viewViewPokemonRegisterPokemon.path,
                            builder:
                                (BuildContext context, GoRouterState state) {
                              List argList = state.extra! as List;
                              return RegisterPokemonPage(
                                onFinish: argList[0],
                                myPokemon: argList[1],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 設定タブ
          StatefulShellBranch(
            navigatorKey: _navigatorKeys[TabItem.settings],
            routes: <RouteBase>[
              GoRoute(
                path: SettingTabPath.root.fullpath,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingTabScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: SettingTabPath.reset.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingResetPage();
                    },
                  ),
                  GoRoute(
                    path: SettingTabPath.language.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingLanguagePage();
                    },
                  ),
                  GoRoute(
                    path: SettingTabPath.license.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingLicensePage();
                    },
                  ),
                  GoRoute(
                    path: SettingTabPath.policy.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingPolicyPage();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(context, _locale),
      child: MaterialApp.router(
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
        routerConfig: _router,
        //home: MyHomePage(),
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

  /// チュートリアルの段階(PokeDBと同期させる)
  int tutorialStep = 0;

  MyAppState(BuildContext context, Locale? locale) {
    fetchPokeData(locale ?? Locale(Platform.localeName.substring(0, 2), ''));
  }

  Future<void> fetchPokeData(Locale locale) async {
    await pokeData.initialize(locale);
    pokemons = pokeData.pokemons;
    parties = pokeData.parties;
    battles = pokeData.battles;
    tutorialStep = pokeData.tutorialStep;
    notifyListeners();
  }

  /// チュートリアルの段階をインクリメント(設定ファイルにも反映する)
  /// 最終まで到達したらこの関数内でマイナス値にセットする
  /// notify()は内部で読んでないので注意
  Future<void> inclementTutorialStep() async {
    tutorialStep++;
    if (tutorialStep > 10) {
      tutorialStep = -1;
    }
    // 設定ファイルに書き込み
    pokeData.tutorialStep = tutorialStep - 1;
    pokeData.saveConfig();
  }

  void notify() => notifyListeners();
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _selectTab(BuildContext context, int index) {
    navigationShell.goBranch(index,
        initialLocation: /*index == navigationShell.currentIndex*/ false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      String tabName(TabItem item, BuildContext context) {
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

      return NavigatorPopHandler(
        onPop: () {
          // TODO:できればネストしたNavigatorを操作するようにしたい。https://api.flutter.dev/flutter/widgets/NavigatorPopHandler-class.html
        },
        child: Scaffold(
          body: Center(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: navigationShell,
            ),
          ),
          bottomNavigationBar: Column(
            key: bottomNavBarAndAdKey,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              PokeDB().showAd
                  ? FutureBuilder(
                      future: AdSize.getAnchoredAdaptiveBannerAdSize(
                          Orientation.portrait,
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
                    )
                  : Container(),
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => _selectTab(context, index),
                items: <BottomNavigationBarItem>[
                  for (var tab in TabItem.values)
                    BottomNavigationBarItem(
                      icon: Icon(key: bottomNavIconKeys[tab], tabIcon[tab]),
                      label: tabName(tab, context),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

enum PokemonTabPath {
  root,
  register,
  view,
  viewRegister,
}

extension PokemonTabPathStr on PokemonTabPath {
  String get path {
    switch (this) {
      case PokemonTabPath.register:
        return 'register';
      case PokemonTabPath.view:
        return 'view';
      case PokemonTabPath.root:
      default:
        return 'pokemons';
    }
  }

  String get fullpath {
    switch (this) {
      case PokemonTabPath.register:
        return '/pokemons/register';
      case PokemonTabPath.view:
        return '/pokemons/view';
      case PokemonTabPath.root:
      default:
        return '/pokemons';
    }
  }
}

class PokemonTabScreen extends StatelessWidget {
  const PokemonTabScreen({
    Key? key,
  }) : super(key: key);

  void _pushRegister(
    BuildContext context,
    Pokemon myPokemon,
  ) {
    GoRouter.of(context).push(
      PokemonTabPath.register.fullpath,
      // 新規作成
      extra: [
        () => _pop(context),
        myPokemon,
      ],
    );
/*          },
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
      ).then((value) {
        setState(() {});
      });
    }*/
  }

  void _pushView(BuildContext context, List<int> pokemonIDList, int index) {
    GoRouter.of(context).push(
      // ポケモン詳細表示
      PokemonTabPath.view.fullpath,
      extra: [
        (pokemon) => _pushRegister(context, pokemon),
        pokemonIDList,
        index,
      ],
    );
/*        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    ).then((value) {
      setState(() {});
    });*/
  }

  void _pop(BuildContext context) {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PokemonsPage(
      onAdd: (myPokemon, isNew) => _pushRegister(context, myPokemon),
      onView: (pokemonList, index) =>
          _pushView(context, [for (final e in pokemonList) e.id], index),
      onSelect: null,
      selectMode: false,
    );
  }
}

enum PartyTabPath {
  root,
  view,
  viewViewPokemon,
  viewViewPokemonRegisterPokemon,
  register,
  registerSelectPokemon,
  registerPokemon,
}

extension PartyTabPathStr on PartyTabPath {
  String get path {
    switch (this) {
      case PartyTabPath.view:
        return 'view';
      case PartyTabPath.viewViewPokemon:
        return 'viewPokemon';
      case PartyTabPath.viewViewPokemonRegisterPokemon:
        return 'registerPokemon';
      case PartyTabPath.register:
        return 'register';
      case PartyTabPath.registerSelectPokemon:
        return 'selectPokemon';
      case PartyTabPath.registerPokemon:
        return 'pokemon';
      case PartyTabPath.root:
      default:
        return 'parties';
    }
  }

  String get fullpath {
    switch (this) {
      case PartyTabPath.view:
        return '/parties/view';
      case PartyTabPath.viewViewPokemon:
        return '/parties/view/viewPokemon';
      case PartyTabPath.viewViewPokemonRegisterPokemon:
        return '/parties/view/viewPokemon/registerPokemon';
      case PartyTabPath.register:
        return '/parties/register';
      case PartyTabPath.registerSelectPokemon:
        return '/parties/register/selectPokemon';
      case PartyTabPath.registerPokemon:
        return '/parties/register/pokemon';
      case PartyTabPath.root:
      default:
        return '/parties';
    }
  }
}

class PartyTabScreen extends StatelessWidget {
  const PartyTabScreen({
    Key? key,
  }) : super(key: key);

  void _pushRegister(BuildContext context, Party party, bool isNew) {
    GoRouter.of(context).push(
      // 新規作成
      PartyTabPath.register.fullpath,
      extra: [
        () => _pop(context),
        (party, idx) => _pushSelectPokemonPage(context, party, idx),
        party,
        isNew,
        false,
        (pokemon, pokemonState) => {},
      ],
    );
  }

  void _pushView(BuildContext context, List<int> partyIDList, int index) {
    GoRouter.of(context).push(
      // パーティ詳細表示
      PartyTabPath.view.fullpath,
      extra: [
        partyIDList,
        index,
        (party) => _pushRegister(context, party, false),
        (pokemonList, listIndex) => _pushPokemonView(
            context, [for (final e in pokemonList) e.id], listIndex),
      ],
    );
/*        },
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
    ).then((value) {
      setState(() {});
    });*/
  }

  void _pushPokemonView(
      BuildContext context, List<int> pokemonIDList, int index) {
    GoRouter.of(context).push(
      // ポケモン詳細表示
      PartyTabPath.viewViewPokemon.fullpath,
      extra: [
        pokemonIDList,
        index,
        (pokemon) => _pushPokemonRegister(context, pokemon, false),
      ],
    );
/*        },
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
    ).then((value) {
      setState(() {});
    });*/
  }

  void _pushPokemonRegister(BuildContext context, Pokemon pokemon, bool isNew) {
    GoRouter.of(context).push(
      // ポケモン編集
      PartyTabPath.viewViewPokemonRegisterPokemon.fullpath,
      extra: [
        () => _pop(context),
        pokemon,
      ],
    );
  }

  Future<Pokemon?> _pushSelectPokemonPage(
      BuildContext context, Party party, int selectingPokemonIdx) async {
    var result = await GoRouter.of(context).push<Pokemon?>(
      // ポケモン選択
      PartyTabPath.registerSelectPokemon.fullpath,
      extra: [
        (pokemon, isNew) {},
        (pokemonList, index) {},
        (pokemon) => _popSelectPokemonPage(context, pokemon),
        true,
        party,
        selectingPokemonIdx,
      ],
    );
    return Future<Pokemon?>.value(result);
  }

  void _pop(BuildContext context) {
    GoRouter.of(context).pop();
  }

  void _popSelectPokemonPage(BuildContext context, Pokemon pokemon) {
    GoRouter.of(context).pop(pokemon);
  }

  @override
  Widget build(BuildContext context) {
/*    return Navigator(
      key: widget.navigatorKey,
      initialRoute: PartyTabPaths.root,
      onGenerateRoute: (routeSettings) {
        //return MaterialPageRoute(
        //builder: (context) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            switch (routeSettings.name) {
              case PartyTabPaths.register:
                // 新規作成
                return RegisterPartyPage(
                  onFinish: () => _pop(context),
                  onSelectPokemon: (party, idx) =>
                      _pushSelectPokemonPage(context, party, idx),
                  party: Party(),
                  isNew: true,
                  isEditPokemon: false,
                  onEditPokemon: (pokemon, pokemonState) => {},
                );
              case PartyTabPaths.registerPokemon:
                // ポケモン選択
                return PokemonsPage(
                  onAdd: (pokemon, isNew) {},
                  onView: (pokemonList, index) {},
                  onSelect: (pokemon) =>
                      _popSelectPokemonPage(context, pokemon),
                  selectMode: true,
                );
            }
          },
        );
      },
    );*/
    return PartiesPage(
      onAdd: (party, isNew) => _pushRegister(context, party, isNew),
      onSelect: null,
      onView: (partyList, index) =>
          _pushView(context, [for (final e in partyList) e.id], index),
      selectMode: false,
    );
  }
}

enum BattleTabPath {
  root,
  view,
  register,
  registerSelectParty,
  registerRegisterParty,
  registerRegisterPartyEditPokemon,
}

extension BattleTabPathStr on BattleTabPath {
  String get path {
    switch (this) {
      case BattleTabPath.view:
        return 'view';
      case BattleTabPath.register:
        return 'register';
      case BattleTabPath.registerSelectParty:
        return 'selectParty';
      case BattleTabPath.registerRegisterParty:
        return 'registerParty';
      case BattleTabPath.registerRegisterPartyEditPokemon:
        return 'editPokemon';
      case BattleTabPath.root:
      default:
        return 'battles';
    }
  }

  String get fullpath {
    switch (this) {
      case BattleTabPath.view:
        return '/battles/view';
      case BattleTabPath.register:
        return '/battles/register';
      case BattleTabPath.registerSelectParty:
        return '/battles/register/selectParty';
      case BattleTabPath.registerRegisterParty:
        return '/battles/register/registerParty';
      case BattleTabPath.registerRegisterPartyEditPokemon:
        return '/battles/register/registerParty/editPokemon';
      case BattleTabPath.root:
      default:
        return '/battles';
    }
  }
}

class BattleTabScreen extends StatelessWidget {
  const BattleTabScreen({
    Key? key,
  }) : super(key: key);

  void _push(
    BuildContext context,
    Battle battle,
    bool isNew, {
    RegisterBattlePageType pageType = RegisterBattlePageType.basePage,
    int turnNum = 1,
  }) {
    GoRouter.of(context).push(
      BattleTabPath.register.fullpath,
      extra: [battle, isNew, pageType, turnNum],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BattlesPage(
      onAdd: (battle, isNew) => _push(context, battle, isNew),
      onView: (battle) => () {},
    );
  }
}

class RegisterBattleScreen extends StatelessWidget {
  const RegisterBattleScreen({
    required this.battle,
    required this.isNew,
    required this.pageType,
    required this.turnNum,
    Key? key,
  }) : super(key: key);

  final Battle battle;
  final bool isNew;
  final RegisterBattlePageType pageType;
  final int turnNum;

  void _pushEditPokemonPage(
      BuildContext context, Pokemon pokemon, PokemonState pokemonState) async {
    GoRouter.of(context).push(
      PokemonTabPath.register.fullpath,
      extra: [
        () => _pop(context),
        pokemon,
        pokemonState,
      ],
    );
  }

  Future<Party?> _pushSelectPartyPage(BuildContext context) async {
    var result = await GoRouter.of(context).push<Party?>(
      // パーティ選択
      BattleTabPath.registerSelectParty.fullpath,
      extra: [
        (party, isNew) {},
        (party) => _popSelectPartyPage(context, party),
        (partyList, index) {},
        true,
      ],
    );
    return Future<Party?>.value(result);
  }

  Future<void> _pushRegisterPartyPage(
      BuildContext context, Party party, PhaseState state) async {
    GoRouter.of(context).push(
      PartyTabPath.register.fullpath,
      extra: [
        () => _pop(context),
        (party, idx) {
          return Future<Pokemon?>.value(Pokemon());
        }, // 使わない
        party,
        party.id == 0,
        true,
        (pokemon, pokemonState) =>
            _pushEditPokemonPage(context, pokemon, pokemonState),
        state,
      ],
    );
  }

  void _pop(BuildContext context) {
    GoRouter.of(context).pop();
  }

  void _popSelectPartyPage(BuildContext context, Party party) {
    GoRouter.of(context).pop(party);
  }

  @override
  Widget build(BuildContext context) {
    return RegisterBattlePage(
      onFinish: () => _pop(context),
      onSelectParty: () => _pushSelectPartyPage(context),
      battle: battle,
      isNew: isNew,
      onSaveOpponentParty: (party, state) =>
          _pushRegisterPartyPage(context, party, state),
      firstPageType: pageType,
      firstTurnNum: turnNum,
    );
  }
}

enum SettingTabPath {
  root,
  reset,
  language,
  license,
  policy,
}

extension SettingTabPathStr on SettingTabPath {
  String get path {
    switch (this) {
      case SettingTabPath.reset:
        return 'reset';
      case SettingTabPath.language:
        return 'language';
      case SettingTabPath.license:
        return 'license';
      case SettingTabPath.policy:
        return 'policy';
      case SettingTabPath.root:
      default:
        return 'settings';
    }
  }

  String get fullpath {
    switch (this) {
      case SettingTabPath.reset:
        return '/settings/reset';
      case SettingTabPath.language:
        return '/settings/language';
      case SettingTabPath.license:
        return '/settings/license';
      case SettingTabPath.policy:
        return '/settings/policy';
      case SettingTabPath.root:
      default:
        return '/settings';
    }
  }
}

class SettingTabScreen extends StatelessWidget {
  const SettingTabScreen({
    Key? key,
  }) : super(key: key);

  void _push(BuildContext context, SettingTabPath path) {
    GoRouter.of(context).push(path.fullpath);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      onReset: () => _push(context, SettingTabPath.reset),
      viewLanguage: () => _push(context, SettingTabPath.language),
      viewLicense: () => _push(context, SettingTabPath.license),
      viewPolicy: () => _push(context, SettingTabPath.policy),
    );
/*            }
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
        );
      },
    );*/
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
        onTap: (index) => onSelectTab(TabItem.values[index]));
  }
}
