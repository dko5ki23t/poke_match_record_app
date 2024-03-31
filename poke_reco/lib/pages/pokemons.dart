import 'package:flutter/material.dart';
import 'package:poke_reco/custom_dialogs/pokemon_delete_check_dialog.dart';
import 'package:poke_reco/custom_dialogs/pokemon_filter_dialog.dart';
import 'package:poke_reco/custom_dialogs/pokemon_sort_dialog.dart';
import 'package:poke_reco/custom_widgets/my_icon_button.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/custom_widgets/pokemon_tile.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/party.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<PokemonsPageState> _addPokemonButtonKey =
    GlobalKey<PokemonsPageState>(debugLabel: 'AddPokemonButton');
final GlobalKey<PokemonsPageState> _firstPokemonListTileKey =
    GlobalKey<PokemonsPageState>(debugLabel: 'FirstPokemonListTile');

class PokemonsPage extends StatefulWidget {
  const PokemonsPage({
    Key? key,
    required this.onAdd,
    required this.onView,
    required this.selectMode,
    required this.onSelect,
    this.party,
    this.selectingPokemonIdx,
  }) : super(key: key);
  final void Function(Pokemon myPokemon, bool isNew) onAdd;
  final void Function(List<Pokemon> pokemonList, int index) onView;
  final void Function(Pokemon selectedPokemon)? onSelect;
  final bool selectMode;
  final Party? party;
  final int? selectingPokemonIdx;

  @override
  PokemonsPageState createState() => PokemonsPageState();
}

class PokemonsPageState extends State<PokemonsPage> {
  bool isEditMode = false;
  Map<int, bool>? checkList;
  Pokemon? selectedPokemon;
  TextEditingController searchTextController = TextEditingController();
  List<TargetFocus> tutorialTargets = [];
  List<TargetFocus> tutorialTargets2 = [];

  final increaseStateStyle = TextStyle(
    color: Colors.red,
  );
  final decreaseStateStyle = TextStyle(
    color: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;
    var loc = AppLocalizations.of(context)!;
    var ownerFilter = pokeData.pokemonsOwnerFilter;
    var noFilter = pokeData.pokemonsNoFilter;
    var typeFilter = pokeData.pokemonsTypeFilter;
    var teraTypeFilter = pokeData.pokemonsTeraTypeFilter;
    var moveFilter = pokeData.pokemonsMoveFilter;
    var sexFilter = pokeData.pokemonsSexFilter;
    var abilityFilter = pokeData.pokemonsAbilityFilter;
    var temperFilter = pokeData.pokemonsTemperFilter;
    var pokemons = appState.pokemons;
    var filteredPokemons = pokemons.entries.where((element) =>
        element.value.id != 0 && ownerFilter.contains(element.value.owner));
    if (noFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons
          .where((element) => noFilter.contains(element.value.no));
    }
    filteredPokemons = filteredPokemons.where((element) =>
        typeFilter.contains(element.value.type1) ||
        typeFilter.contains(element.value.type2));
    filteredPokemons = filteredPokemons.where((element) =>
        teraTypeFilter.contains(element.value.teraType) ||
        element.value.teraType == PokeType.unknown);
    if (moveFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons.where((element) =>
          moveFilter.contains(element.value.move1.id) ||
          moveFilter.contains(element.value.move2?.id) ||
          moveFilter.contains(element.value.move3?.id) ||
          moveFilter.contains(element.value.move4?.id));
    }
    filteredPokemons = filteredPokemons
        .where((element) => sexFilter.contains(element.value.sex.id));
    if (abilityFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons
          .where((element) => abilityFilter.contains(element.value.ability.id));
    }
    if (temperFilter.isNotEmpty) {
      filteredPokemons = filteredPokemons
          .where((element) => temperFilter.contains(element.value.temper.id));
    }
    // 検索窓の入力でフィルタリング
    final pattern = searchTextController.text;
    if (pattern != '') {
      filteredPokemons = filteredPokemons.where((s) {
        return toKatakana50(s.value.name.toLowerCase())
                .contains(toKatakana50(pattern.toLowerCase())) ||
            toKatakana50(s.value.nickname.toLowerCase())
                .contains(toKatakana50(pattern.toLowerCase()));
      });
    }
    // 通常の表示ではvalidでないポケモンも表示するが、
    // パーティ編集での表示ではvalidでないポケモンは表示しない
    if (widget.selectMode) {
      filteredPokemons =
          filteredPokemons.where((element) => element.value.isValid);
    }
    var sort = pokeData.pokemonsSort;
    var sortedPokemons = filteredPokemons.toList();
    sortedPokemons
        .sort((a, b) => a.value.viewOrder.compareTo(b.value.viewOrder));

    final theme = Theme.of(context);

    void onPressAddButton() {
      checkList = null;
      widget.onAdd(Pokemon()..owner = Owner.mine, true);
    }

    void showTutorial() {
      TutorialCoachMark(
        targets: tutorialTargets,
        alignSkip: Alignment.topRight,
        textSkip: loc.tutorialSkip,
        onClickTarget: (target) {
          onPressAddButton();
        },
      ).show(context: context);
    }

    final tutorialCoachMark2 = TutorialCoachMark(
      targets: tutorialTargets2,
      alignSkip: Alignment.topRight,
      textSkip: loc.tutorialSkip,
    );
    void showTutorial2() {
      tutorialCoachMark2.show(context: context, rootOverlay: true);
    }

    // データ読み込みで待つ
    if (!pokeData.isLoaded) {
      EasyLoading.instance.userInteractions = false; // 操作禁止にする
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.5);
      EasyLoading.show(status: loc.commonLoading);
    } else {
      EasyLoading.dismiss();
      if (appState.tutorialStep == 0 && !widget.selectMode) {
        appState.inclementTutorialStep();
        tutorialTargets.add(TargetFocus(
          keyTarget: _addPokemonButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    loc.tutorialWelcome,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      loc.tutorialAddPokemon,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
        showTutorial();
      } else if (appState.tutorialStep == 2 &&
          sortedPokemons.isNotEmpty &&
          !widget.selectMode) {
        appState.inclementTutorialStep();
        tutorialTargets2.add(TargetFocus(
          keyTarget: _firstPokemonListTileKey,
          shape: ShapeLightFocus.RRect,
          radius: 10,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    loc.tutorialTitleCompleteRegisterPokemon,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      loc.tutorialToPartyTab,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
        tutorialTargets2.add(TargetFocus(
          keyTarget: bottomNavBarAndAdKey,
          shape: ShapeLightFocus.RRect,
          radius: 10,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    loc.tutorialTitleCompleteRegisterPokemon2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      loc.tutorialToPartyTab2,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
        showTutorial2();
      }
    }

    Widget lists;
    if (checkList == null) {
      checkList = {};
      for (final e in sortedPokemons) {
        checkList![e.key] = false;
      }
    }
    // データベースの読み込みタイミングによってはリストが0の場合があるため
    if (checkList!.length != sortedPokemons.length) {
      checkList = {};
      for (final e in sortedPokemons) {
        checkList![e.key] = false;
      }
    }
    List<int?> partyPokemonsNo = [
      for (int i = 0; i < 6; i++)
        widget.selectingPokemonIdx != null &&
                i != widget.selectingPokemonIdx! - 1
            ? widget.party?.pokemons[i]?.no
            : null,
    ];

    final searchBar = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: TextField(
        key: Key('PokemonsSearch'),
        controller: searchTextController,
        autofocus: widget.selectMode && filteredPokemons.length >= 10,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          contentPadding: EdgeInsets.all(1),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );

    if (sortedPokemons.isEmpty) {
      lists = Column(
        children: [
          searchBar,
          Expanded(
            child: Center(
              child: Text(loc.pokemonsTabNoPokemon),
            ),
          ),
        ],
      );
    } else {
      if (isEditMode) {
        lists = Column(
          children: [
            searchBar,
            Expanded(
              child: Scrollbar(
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = sortedPokemons.removeAt(oldIndex);
                      sortedPokemons.insert(newIndex, item);
                      for (int i = 0; i < sortedPokemons.length; i++) {
                        var pokemon = pokemons[sortedPokemons[i].key]!;
                        pokemon.viewOrder = i + 1;
                      }
                    });
                  },
                  children: [
                    for (int i = 0; i < sortedPokemons.length; i++)
                      PokemonTile(
                        key: i == 0 ? _firstPokemonListTileKey : null,
                        sortedPokemons[i].value,
                        theme,
                        leading: Icon(Icons.drag_handle),
                        trailing: Checkbox(
                          value: checkList![sortedPokemons[i].key],
                          onChanged: (isCheck) {
                            setState(() {
                              checkList![sortedPokemons[i].key] =
                                  isCheck ?? false;
                            });
                          },
                        ),
                        showWarning: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        lists = Column(
          children: [
            searchBar,
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: [
                    for (int i = 0; i < sortedPokemons.length; i++)
                      PokemonTile(
                        key: i == 0 ? _firstPokemonListTileKey : null,
                        sortedPokemons[i].value,
                        theme,
                        enabled: !partyPokemonsNo
                            .contains(sortedPokemons[i].value.no),
                        leading: pokeData.getPokeAPI
                            ? Image.network(
                                pokeData.pokeBase[sortedPokemons[i].value.no]!
                                    .imageUrl,
                                height: theme.buttonTheme.height,
                                errorBuilder: (c, o, s) {
                                  return const Icon(Icons.catching_pokemon);
                                },
                              )
                            : const Icon(Icons.catching_pokemon),
                        onLongPress: !widget.selectMode
                            ? () => widget.onAdd(
                                sortedPokemons[i].value.copy(), false)
                            : null,
                        onTap: widget.selectMode
                            ? () {
                                selectedPokemon = sortedPokemons[i].value;
                                widget.onSelect!(sortedPokemons[i].value);
                              }
                            : () => widget.onView(
                                [for (final e in sortedPokemons) e.value], i),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(selectedPokemon);
        },
        child: Scaffold(
          appBar: AppBar(
            title: widget.selectMode
                ? Text(loc.pokemonsTabTitleSelectPokemon)
                : Text(loc.pokemonsTabTitlePokemonList),
            actions: [
              !widget.selectMode
                  ? isEditMode
                      ? MyIconButton(
                          theme: theme,
                          onPressed: () {
                            setState(() => isEditMode = false);
                            pokeData.pokemonsSort = null;
                          },
                          icon: Icon(Icons.check),
                          tooltip: loc.commonDone,
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              MyIconButton(
                                theme: theme,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return PokemonFilterDialog(
                                          pokeData,
                                          ownerFilter,
                                          noFilter,
                                          typeFilter,
                                          teraTypeFilter,
                                          moveFilter,
                                          sexFilter,
                                          abilityFilter,
                                          temperFilter,
                                          (f1, f2, f3, f4, f5, f6, f7,
                                              f8) async {
                                            ownerFilter.clear();
                                            noFilter.clear();
                                            typeFilter.clear();
                                            teraTypeFilter.clear();
                                            moveFilter.clear();
                                            sexFilter.clear();
                                            abilityFilter.clear();
                                            temperFilter.clear();
                                            ownerFilter.addAll(f1);
                                            noFilter.addAll(f2);
                                            typeFilter.addAll(f3);
                                            teraTypeFilter.addAll(f4);
                                            moveFilter.addAll(f5);
                                            sexFilter.addAll(f6);
                                            abilityFilter.addAll(f7);
                                            temperFilter.addAll(f8);
                                            await pokeData.saveConfig();
                                            setState(() {});
                                          },
                                        );
                                      });
                                },
                                icon: Icon(Icons.filter_alt),
                                tooltip: loc.commonFilter,
                              ),
                              MyIconButton(
                                theme: theme,
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) {
                                      return PokemonSortDialog(
                                          (pokemonSort) async {
                                        switch (pokemonSort) {
                                          case PokemonSort.registerUp:
                                            sortedPokemons.sort(
                                              (a, b) => a.value.id
                                                  .compareTo(b.value.id),
                                            );
                                            break;
                                          case PokemonSort.registerDown:
                                            sortedPokemons.sort(
                                              (a, b) =>
                                                  -1 *
                                                  a.value.id
                                                      .compareTo(b.value.id),
                                            );
                                            break;
                                          case PokemonSort.nickNameUp:
                                            sortedPokemons.sort(
                                              (a, b) => a.value.nickname
                                                  .compareTo(b.value.nickname),
                                            );
                                            break;
                                          case PokemonSort.nickNameDown:
                                            sortedPokemons.sort(
                                              (a, b) =>
                                                  -1 *
                                                  a.value.nickname.compareTo(
                                                      b.value.nickname),
                                            );
                                            break;
                                          case PokemonSort.nameUp:
                                            sortedPokemons.sort(
                                              (a, b) => a.value.name
                                                  .compareTo(b.value.name),
                                            );
                                            break;
                                          case PokemonSort.nameDown:
                                            sortedPokemons.sort(
                                              (a, b) =>
                                                  -1 *
                                                  a.value.name
                                                      .compareTo(b.value.name),
                                            );
                                            break;
                                          default:
                                            break;
                                        }
                                        if (sort != pokemonSort &&
                                            pokemonSort != null) {
                                          for (int i = 0;
                                              i < sortedPokemons.length;
                                              i++) {
                                            var pokemon = pokemons[
                                                sortedPokemons[i].key]!;
                                            pokemon.viewOrder = i + 1;
                                          }
                                          await pokeData
                                              .updateAllMyPokemonViewOrder();
                                        }
                                        pokeData.pokemonsSort = pokemonSort;
                                        await pokeData.saveConfig();
                                        setState(() {});
                                      }, sort);
                                    }),
                                icon: Icon(Icons.sort),
                                tooltip: loc.commonSort,
                              ),
                              MyIconButton(
                                theme: theme,
                                onPressed: (sortedPokemons.isNotEmpty)
                                    ? () => setState(() => isEditMode = true)
                                    : null,
                                icon: Icon(Icons.edit),
                                tooltip: loc.commonEdit,
                              ),
                            ],
                          ),
                        )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          MyIconButton(
                            theme: theme,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return PokemonFilterDialog(
                                      pokeData,
                                      ownerFilter,
                                      noFilter,
                                      typeFilter,
                                      teraTypeFilter,
                                      moveFilter,
                                      sexFilter,
                                      abilityFilter,
                                      temperFilter,
                                      (f1, f2, f3, f4, f5, f6, f7, f8) async {
                                        ownerFilter.clear();
                                        noFilter.clear();
                                        typeFilter.clear();
                                        teraTypeFilter.clear();
                                        moveFilter.clear();
                                        sexFilter.clear();
                                        abilityFilter.clear();
                                        temperFilter.clear();
                                        ownerFilter.addAll(f1);
                                        noFilter.addAll(f2);
                                        typeFilter.addAll(f3);
                                        teraTypeFilter.addAll(f4);
                                        moveFilter.addAll(f5);
                                        sexFilter.addAll(f6);
                                        abilityFilter.addAll(f7);
                                        temperFilter.addAll(f8);
                                        await pokeData.saveConfig();
                                        setState(() {});
                                      },
                                    );
                                  });
                            },
                            icon: Icon(Icons.filter_alt),
                            tooltip: loc.commonFilter,
                          ),
                          MyIconButton(
                            theme: theme,
                            onPressed: () => showDialog(
                                context: context,
                                builder: (_) {
                                  return PokemonSortDialog((pokemonSort) async {
                                    switch (pokemonSort) {
                                      case PokemonSort.registerUp:
                                        sortedPokemons.sort(
                                          (a, b) =>
                                              a.value.id.compareTo(b.value.id),
                                        );
                                        break;
                                      case PokemonSort.registerDown:
                                        sortedPokemons.sort(
                                          (a, b) =>
                                              -1 *
                                              a.value.id.compareTo(b.value.id),
                                        );
                                        break;
                                      case PokemonSort.nickNameUp:
                                        sortedPokemons.sort(
                                          (a, b) => a.value.nickname
                                              .compareTo(b.value.nickname),
                                        );
                                        break;
                                      case PokemonSort.nickNameDown:
                                        sortedPokemons.sort(
                                          (a, b) =>
                                              -1 *
                                              a.value.nickname
                                                  .compareTo(b.value.nickname),
                                        );
                                        break;
                                      case PokemonSort.nameUp:
                                        sortedPokemons.sort(
                                          (a, b) => a.value.name
                                              .compareTo(b.value.name),
                                        );
                                        break;
                                      case PokemonSort.nameDown:
                                        sortedPokemons.sort(
                                          (a, b) =>
                                              -1 *
                                              a.value.name
                                                  .compareTo(b.value.name),
                                        );
                                        break;
                                      default:
                                        break;
                                    }
                                    if (sort != pokemonSort &&
                                        pokemonSort != null) {
                                      for (int i = 0;
                                          i < sortedPokemons.length;
                                          i++) {
                                        var pokemon =
                                            pokemons[sortedPokemons[i].key]!;
                                        pokemon.viewOrder = i + 1;
                                      }
                                      await pokeData
                                          .updateAllMyPokemonViewOrder();
                                    }
                                    pokeData.pokemonsSort = pokemonSort;
                                    await pokeData.saveConfig();
                                    setState(() {});
                                  }, sort);
                                }),
                            icon: Icon(Icons.sort),
                            tooltip: loc.commonSort,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: isEditMode
                    ? [
                        Expanded(flex: 10, child: lists),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Row(children: [
                                    Icon(Icons.select_all),
                                    SizedBox(width: 10),
                                    Text(loc.commonSelectAll)
                                  ]),
                                  onPressed: () => setState(() {
                                    selectAllMap(checkList!);
                                  }),
                                ),
                                SizedBox(width: 20),
                                TextButton(
                                  onPressed: (getSelectedNumMap(checkList!) > 0)
                                      ? () {
                                          bool isContainedParty = false;
                                          for (final e in checkList!.keys) {
                                            if (checkList![e]!) {
                                              if (sortedPokemons
                                                  .where((element) =>
                                                      element.value.id == e)
                                                  .first
                                                  .value
                                                  .refs) {
                                                isContainedParty = true;
                                                break;
                                              }
                                            }
                                          }
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return PokemonDeleteCheckDialog(
                                                  isContainedParty,
                                                  () async {
                                                    List<int> deleteIDs = [];
                                                    for (final e
                                                        in checkList!.keys) {
                                                      if (checkList![e]!) {
                                                        deleteIDs.add(e);
                                                      }
                                                    }
                                                    await pokeData
                                                        .deleteMyPokemon(
                                                            deleteIDs,
                                                            appState.notify);
                                                    setState(() {});
                                                  },
                                                );
                                              });
                                        }
                                      : null,
                                  child: Row(children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 10),
                                    Text(loc.commonDelete)
                                  ]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                TextButton(
                                  onPressed: (getSelectedNumMap(checkList!) > 0)
                                      ? () async {
                                          for (final e in checkList!.keys) {
                                            if (checkList![e]!) {
                                              Pokemon copiedPokemon =
                                                  pokemons[e]!.copy();
                                              await pokeData.addMyPokemon(
                                                  copiedPokemon,
                                                  true,
                                                  appState.notify);
                                            }
                                          }
                                          setState(() {
                                            checkList = {};
                                            for (final e in sortedPokemons) {
                                              checkList![e.key] = false;
                                            }
                                          });
                                        }
                                      : null,
                                  child: Row(children: [
                                    Icon(Icons.copy),
                                    SizedBox(width: 10),
                                    Text(loc.commonCopy),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    : [
                        Expanded(child: lists),
                      ],
              ),
              !isEditMode && !widget.selectMode
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          tooltip: loc.pokemonsTabRegisterPokemon,
                          key: _addPokemonButtonKey,
                          shape: CircleBorder(),
                          onPressed: onPressAddButton,
                          child: Icon(Icons.add),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
