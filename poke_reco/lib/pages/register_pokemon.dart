import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poke_reco/custom_dialogs/delete_editing_check_dialog.dart';
import 'package:poke_reco/custom_widgets/app_base/app_base_typeahead_field.dart';
import 'package:poke_reco/custom_widgets/move_input_row.dart';
import 'package:poke_reco/custom_widgets/stat_input_row.dart';
import 'package:poke_reco/custom_widgets/stat_total_row.dart';
import 'package:poke_reco/custom_widgets/type_dropdown_button.dart';
import 'package:poke_reco/data_structs/four_params.dart';
import 'package:poke_reco/data_structs/move.dart';
import 'package:poke_reco/data_structs/pokemon_state.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/data_structs/poke_type.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:poke_reco/data_structs/pokemon.dart';
import 'package:poke_reco/data_structs/poke_base.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<RegisterPokemonPageState> _pokemonNameInputKey =
    GlobalKey<RegisterPokemonPageState>(debugLabel: 'PokemonNameInput');
final GlobalKey<RegisterPokemonPageState> _teraTypeInputKey =
    GlobalKey<RegisterPokemonPageState>(debugLabel: 'TeraTypeInput');
final GlobalKey<RegisterPokemonPageState> _saveButtonKey =
    GlobalKey<RegisterPokemonPageState>(debugLabel: 'SaveButton');
final GlobalKey<RegisterPokemonPageState> _cameraButtonKey =
    GlobalKey<RegisterPokemonPageState>(debugLabel: 'CameraButton');

class RegisterPokemonPage extends StatefulWidget {
  RegisterPokemonPage({
    Key? key,
    required this.onFinish,
    required this.myPokemon,
//    required this.isNew,
    this.pokemonState,
  }) : super(key: key);

  final void Function() onFinish;
  final Pokemon myPokemon;
//  final bool isNew;     // この変数の代わりに、ポケモンのIDが0(まだ無効)かどうかで新規登録かを判定する
  final PokemonState? pokemonState;

  @override
  RegisterPokemonPageState createState() => RegisterPokemonPageState();
}

class RegisterPokemonPageState extends State<RegisterPokemonPage>
    with WidgetsBindingObserver {
  static const notAllowedStyle = TextStyle(
    color: Colors.red,
  );
  final pokeNameController = TextEditingController();
  final pokeNickNameController = TextEditingController();
  final pokeNoController = TextEditingController();
  final pokeLevelController = TextEditingController();
  final pokeNatureController = TextEditingController();
  final pokeStatRaceController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatIndiController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatEffortController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeStatRealController =
      List.generate(StatIndex.size.index, (i) => TextEditingController());
  final pokeMoveController = List.generate(4, (i) => TextEditingController());
  final pokePPController = List.generate(4, (i) => TextEditingController());

  Future<void>? _future;
  CameraController? _cameraController;
  // TODO: 英語対応
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  RecognizedText? recognizedText;
  bool _isPermissionGranted = false;

  /// 縦画面かどうか
  bool isVerticallyLong = false;

  bool canChangeTeraType = true;
  List<TargetFocus> tutorialTargets = [];

  void updateRealStat() {
    widget.myPokemon.updateRealStats();

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatRealController[i].text =
          widget.myPokemon.stats[StatIndex.values[i]].real.toString();
    }
    // notify
    setState(() {});
  }

  void updateStatsRefReal(StatIndex statIndex) {
    widget.myPokemon.updateStatsRefReal(statIndex);

    for (int i = 0; i < StatIndex.size.index; i++) {
      pokeStatEffortController[i].text =
          widget.myPokemon.stats[StatIndex.values[i]].effort.toString();
      pokeStatIndiController[i].text =
          widget.myPokemon.stats[StatIndex.values[i]].indi.toString();
    }
    // notify
    setState(() {});
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // 最初のリアカメラを選択します
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;
    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      recognizedText = await textRecognizer.processImage(inputImage);
      // 撮影後、元の画面に戻る
      setState(() {
        _future = null;
      });
    } catch (e) {
      setState(() {
        _future = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokemons = appState.pokemons;
    var pokeData = appState.pokeData;
    var pokemonState = widget.pokemonState;
    var myPokemon = widget.myPokemon;
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;

    void levelInputFunc(num value) {
      myPokemon.level = value.toInt();
      updateRealStat();
    }

    isVerticallyLong =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // 画像からスキャンした文字の読み取り
    if (recognizedText != null) {
      // まずレベルを認識
      for (final block in recognizedText!.blocks) {
        if (block.text.startsWith('Lv.')) {
          int? level = int.tryParse(block.text.substring(3));
          if (level != null) {
            level = level.clamp(1, 100);
            widget.myPokemon.level = level;
            recognizedText!.blocks.remove(block);
            break;
          }
        }
      }
      List<int> removeIdx = [];
      for (int i = 0; i < recognizedText!.blocks.length; i++) {
        final block = recognizedText!.blocks[i];
        if (block.text == 'HP') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          final hpMaxHp = nearestStr.split('/');
          if (hpMaxHp.length > 1) {
            int? hp = int.tryParse(hpMaxHp[1]);
            if (hp != null) {
              widget.myPokemon.h.real = hp;
              updateStatsRefReal(StatIndex.H);
              removeIdx.add(i);
            }
          }
        } else if (block.text == 'こうげき') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          int? attack = int.tryParse(nearestStr);
          if (attack != null) {
            widget.myPokemon.a.real = attack;
            updateStatsRefReal(StatIndex.A);
            removeIdx.add(i);
          }
        } else if (block.text == 'ぼうぎょ') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          int? defense = int.tryParse(nearestStr);
          if (defense != null) {
            widget.myPokemon.b.real = defense;
            updateStatsRefReal(StatIndex.B);
            removeIdx.add(i);
          }
        } else if (block.text == 'とくこう') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          int? sAttack = int.tryParse(nearestStr);
          if (sAttack != null) {
            widget.myPokemon.c.real = sAttack;
            updateStatsRefReal(StatIndex.C);
            removeIdx.add(i);
          }
        } else if (block.text == 'とくぼう') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          int? sDefense = int.tryParse(nearestStr);
          if (sDefense != null) {
            widget.myPokemon.d.real = sDefense;
            updateStatsRefReal(StatIndex.D);
            removeIdx.add(i);
          }
        } else if (block.text == 'すばやさ') {
          String nearestStr = '';
          double nearestDistance = 10000;
          for (final b in recognizedText!.blocks) {
            if (b != block) {
              double dist =
                  (b.boundingBox.center - block.boundingBox.center).distance;
              if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestStr = b.text;
              }
            }
          }
          int? speed = int.tryParse(nearestStr);
          if (speed != null) {
            widget.myPokemon.s.real = speed;
            updateStatsRefReal(StatIndex.S);
            removeIdx.add(i);
          }
        }
      }
      removeIdx.sort(((a, b) => b.compareTo(a)));
      for (final idx in removeIdx) {
        recognizedText!.blocks.removeAt(idx);
      }
      List<Move> moves = [];
      List<int> pps = [];
      for (final block in recognizedText!.blocks) {
        final exp = RegExp(r"^[0-9]+/(\s|　)*[0-9]+$");
        if (exp.hasMatch(block.text)) {
          final ppMaxPp = block.text.split('/');
          int? maxPp = int.tryParse(ppMaxPp[1]);
          if (maxPp != null) {
            String nearestMoveStr = '';
            double nearestDistanceTorR = 10000;
            // PPは、テキストのboundingBoxの上(縦長画面のときは右)の値が最も近いテキストを技名とする
            for (final b in recognizedText!.blocks) {
              if (b != block) {
                double distTorR = isVerticallyLong
                    ? (b.boundingBox.right - block.boundingBox.right).abs()
                    : (b.boundingBox.top - block.boundingBox.top).abs();
                if (distTorR < nearestDistanceTorR && !exp.hasMatch(b.text)) {
                  nearestDistanceTorR = distTorR;
                  nearestMoveStr = b.text;
                }
              }
            }
            var matches = pokeData.pokeBase[widget.myPokemon.no]!.move.where(
                (element) => element.displayName.contains(nearestMoveStr));
            if (matches.isNotEmpty) {
              moves.add(matches.first);
              pps.add(maxPp);
            } else {
              // 最初の一文字目にタイプアイコンを文字として認識して変な文字が入ることがあるので、
              // それを削除して技名があるか検査する
              nearestMoveStr.substring(1);
              matches = pokeData.pokeBase[widget.myPokemon.no]!.move.where(
                  (element) => element.displayName.contains(nearestMoveStr));
              if (matches.isNotEmpty) {
                moves.add(matches.first);
                pps.add(maxPp);
              }
            }
          }
        }
      }
      for (int i = 0; i < min(4, moves.length); i++) {
        widget.myPokemon.moves[i] = moves[i].copy();
        widget.myPokemon.pps[i] = pps[i];
      }
      recognizedText = null;
    }

    pokeNameController.text = myPokemon.name;
    pokeNickNameController.text = myPokemon.nickname;
    pokeNoController.text = myPokemon.no.toString();
    pokeLevelController.text = myPokemon.level.toString();
    pokeNatureController.text = myPokemon.nature.displayName;
    for (final stat in StatIndexList.listHtoS) {
      pokeStatRaceController[stat.index].text =
          '${stat.alphabet} ${myPokemon.name == '' ? '-' : myPokemon.stats[stat].race}';
    }
    pokeMoveController[0].text = myPokemon.move1.displayName;
    pokeMoveController[1].text =
        myPokemon.move2 == null ? '' : myPokemon.move2!.displayName;
    pokeMoveController[2].text =
        myPokemon.move3 == null ? '' : myPokemon.move3!.displayName;
    pokeMoveController[3].text =
        myPokemon.move4 == null ? '' : myPokemon.move4!.displayName;

    Future<bool?> showBackDialog() async {
      if (myPokemon != pokeData.pokemons[myPokemon.id]) {
        return showDialog<bool?>(
            context: context,
            builder: (_) {
              return DeleteEditingCheckDialog(
                null,
                () {},
              );
            });
      } else {
        return true;
      }
    }

    void onComplete() async {
      if (myPokemon.id != 0) {
        pokemons[myPokemon.id] = myPokemon;
        // 登録されているパーティのポケモン情報更新
        var parties = appState.parties;
        for (final party in parties.values) {
          var target = party.pokemons
              .indexWhere((element) => element?.id == myPokemon.id);
          if (target >= 0) {
            party.pokemons[target] = myPokemon;
          }
        }
      }
      await pokeData.addMyPokemon(
          myPokemon, myPokemon.id == 0, appState.notify);
      widget.onFinish();
    }

    void showTutorial() {
      TutorialCoachMark(
        targets: tutorialTargets,
        alignSkip: Alignment.topRight,
        textSkip: loc.tutorialSkip,
        onClickTarget: (target) {},
      ).show(context: context);
    }

    if (appState.tutorialStep == 1) {
      appState.inclementTutorialStep();
      tutorialTargets.add(TargetFocus(
        keyTarget: _pokemonNameInputKey,
        shape: ShapeLightFocus.RRect,
        radius: 10.0,
        enableOverlayTab: true, // 暗くなってる部分を押しても次へ進む
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterPokemon,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputPokemonName,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: _teraTypeInputKey,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: 10.0,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterPokemon2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputPokemonInfo,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: _cameraButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterPokemon3,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialInputPokemonInfoFromCamera,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      tutorialTargets.add(TargetFocus(
        keyTarget: _saveButtonKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  loc.tutorialTitleRegisterPokemon4,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    loc.tutorialRegisterPokemonSave,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ));
      showTutorial();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool? shouldPop = await showBackDialog();
        if (shouldPop ?? false) {
          navigator.pop();
          appState.notify(); // tutorialStepの変化を知らせるため
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: myPokemon.id == 0
                ? Text(loc.pokemonsTabRegisterPokemon)
                : Text(loc.pokemonsTabEditPokemon),
            actions: [
              IconButton(
                  key: _cameraButtonKey,
                  onPressed: widget.myPokemon.no != 0
                      ? () {
                          setState(() {
                            _future = _requestCameraPermission();
                          });
                        }
                      : null,
                  icon: Icon(Icons.photo_camera)),
              TextButton(
                key: _saveButtonKey,
                onPressed: (myPokemon.isValid &&
                        myPokemon != pokeData.pokemons[myPokemon.id])
                    ? () => onComplete()
                    : null,
                child: Text(loc.registerSave),
              ),
            ]),
        body: _future != null
            ? FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (_isPermissionGranted) {
                    // カメラでの撮影画面
                    return FutureBuilder<List<CameraDescription>>(
                      future: availableCameras(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _initCameraController(snapshot.data!);
                          return Stack(
                            children: [
                              Center(
                                child: CameraPreview(
                                  _cameraController!,
                                  child: RotatedBox(
                                    quarterTurns: isVerticallyLong ? 1 : 0,
                                    child: Image.asset(
                                        'assets/images/pokemon_status_guide_line.png'),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.only(bottom: 30.0),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: _scanImage,
                                        child: const Text('Scan text'),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        } else {
                          return const LinearProgressIndicator();
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Camera permission denied',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                })
            : ListView(
//        mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          // ポケモン名, 図鑑No
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 7,
                              child: AppBaseTypeAheadField(
                                key: _pokemonNameInputKey,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: pokeNameController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: loc.pokemonsTabPokemonName,
                                    labelStyle: myPokemon.no == 0
                                        ? notAllowedStyle
                                        : null,
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<PokeBase> matches = [];
                                  matches.addAll(pokeData.pokeBase.values);
                                  matches.remove(pokeData.pokeBase[0]);
                                  matches.retainWhere((s) {
                                    return toKatakana50(s.name.toLowerCase())
                                        .contains(toKatakana50(
                                            pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: pokeData.getPokeAPI
                                        ? Image.network(
                                            suggestion.imageUrl,
                                            height: theme.buttonTheme.height,
                                            errorBuilder: (c, o, s) {
                                              return const Icon(
                                                  Icons.catching_pokemon);
                                            },
                                          )
                                        : const Icon(Icons.catching_pokemon),
                                    title: Text(suggestion.name),
                                    autofocus: true,
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  pokeNoController.text =
                                      suggestion.no.toString();
                                  myPokemon
                                    //..name = suggestion.name
                                    ..no = suggestion.no // nameも変わる
                                    ..type1 = suggestion.type1
                                    ..type2 = suggestion.type2
                                    ..ability = suggestion.ability[0]
                                    ..sex = suggestion.sex[0]
                                    ..h.race = suggestion.h
                                    ..a.race = suggestion.a
                                    ..b.race = suggestion.b
                                    ..c.race = suggestion.c
                                    ..d.race = suggestion.d
                                    ..s.race = suggestion.s
                                    ..teraType = suggestion.fixedTeraType;
                                  canChangeTeraType =
                                      suggestion.fixedTeraType ==
                                          PokeType.unknown;
                                  for (final stat in StatIndexList.listHtoS) {
                                    pokeStatRaceController[stat.index].text =
                                        '${stat.alphabet} ${myPokemon.stats[stat].race}';
                                  }
                                  updateRealStat();
                                  myPokemon.move1 = Move.none(); // 無効なわざ
                                  myPokemon.move2 = null;
                                  myPokemon.move3 = null;
                                  myPokemon.move4 = null;
                                  for (int i = 0; i < 4; i++) {
                                    pokeMoveController[i].text = '';
                                    myPokemon.pps[i] = 0;
                                    pokePPController[i].text = '0';
                                  }
                                  pokeNameController.text = suggestion.name;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // ポケモン画像
                            Expanded(
                              flex: 3,
                              child: pokeData.getPokeAPI
                                  ? Image.network(
                                      pokeData.pokeBase[myPokemon.no]!.imageUrl,
                                      errorBuilder: (c, o, s) {
                                        return const Icon(
                                            Icons.catching_pokemon);
                                      },
                                    )
                                  : const Icon(Icons.catching_pokemon),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          // ニックネーム
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: loc.pokemonsTabNickName,
                                ),
                                onChanged: (value) {
                                  myPokemon.nickname = value;
                                },
                                maxLength: 20,
                                controller: pokeNickNameController,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          // タイプ1, タイプ2, テラスタイプ
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: TypeDropdownButton(
                                loc.commonType1,
                                null,
                                myPokemon.type1 == PokeType.unknown
                                    ? null
                                    : myPokemon.type1,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: TypeDropdownButton(
                                loc.commonType2,
                                null,
                                myPokemon.type2 == PokeType.unknown
                                    ? null
                                    : myPokemon.type2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              key: _teraTypeInputKey,
                              child: TypeDropdownButton(
                                loc.commonTeraType,
                                canChangeTeraType
                                    ? (value) {
                                        setState(() {
                                          myPokemon.teraType = value;
                                        });
                                      }
                                    : null,
                                myPokemon.teraType == PokeType.unknown
                                    ? null
                                    : myPokemon.teraType,
                                isError: myPokemon.teraType == PokeType.unknown,
                                isTeraType: true,
                              ),
                            ),
                          ],
                        ),
                        pokemonState != null
                            ? Row(
                                // テラスタイプ
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${loc.pokemonsTabConfTeraType} : ${pokemonState.teraType1 != PokeType.unknown ? pokemonState.teraType1.displayName : loc.commonNone}',
                                        style: TextStyle(
                                            color: theme.primaryColor,
                                            fontSize: theme.textTheme.bodyMedium
                                                ?.fontSize),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 10),
                        Row(
                          // レベル, せいべつ
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: NumberInputWithIncrementDecrement(
                                controller: pokeLevelController,
                                numberFieldDecoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: loc.commonLevel,
                                ),
                                widgetContainerDecoration: const BoxDecoration(
                                  border: null,
                                ),
                                min: pokemonMinLevel,
                                max: pokemonMaxLevel,
                                initialValue: myPokemon.level,
                                onIncrement: levelInputFunc,
                                onDecrement: levelInputFunc,
                                onChanged: levelInputFunc,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: loc.commonGender,
                                ),
                                items: <DropdownMenuItem<Sex>>[
                                  for (var type
                                      in pokeData.pokeBase[myPokemon.no]!.sex)
                                    DropdownMenuItem(
                                      value: type,
                                      child: type.displayIcon,
                                    ),
                                ],
                                value: myPokemon.sex,
                                onChanged: myPokemon.no != 0
                                    ? (value) {
                                        myPokemon.sex = value as Sex;
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          // せいかく, とくせい
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: AppBaseTypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: pokeNatureController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: loc.commonNature,
                                    labelStyle: myPokemon.nature.id == 0
                                        ? notAllowedStyle
                                        : null,
                                  ),
                                ),
                                autoFlipDirection: true,
                                suggestionsCallback: (pattern) async {
                                  List<Nature> matches = [];
                                  matches.addAll(pokeData.natures.values);
                                  matches.remove(pokeData.natures[0]);
                                  matches.retainWhere((s) {
                                    return toKatakana50(
                                            s.displayName.toLowerCase())
                                        .contains(toKatakana50(
                                            pattern.toLowerCase()));
                                  });
                                  return matches;
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(
                                              text: suggestion.displayName),
                                          suggestion.increasedStat.alphabet !=
                                                  ''
                                              ? TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                  text:
                                                      ' ${suggestion.increasedStat.alphabet}')
                                              : TextSpan(),
                                          suggestion.decreasedStat.alphabet !=
                                                  ''
                                              ? TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                  text:
                                                      ' ${suggestion.decreasedStat.alphabet}')
                                              : TextSpan(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  pokeNatureController.text =
                                      suggestion.displayName;
                                  myPokemon.nature = suggestion;
                                  updateRealStat();
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: loc.commonAbility,
                                ),
                                items: <DropdownMenuItem>[
                                  for (var ab in pokeData
                                      .pokeBase[myPokemon.no]!.ability)
                                    DropdownMenuItem(
                                      value: ab,
                                      child: Text(ab.displayName),
                                    )
                                ],
                                value: pokeData.abilities[myPokemon.ability.id],
                                onChanged: (myPokemon.name == '')
                                    ? null
                                    : (dynamic value) {
                                        myPokemon.ability = value;
                                        setState(() {});
                                      },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // HP, こうげき, ぼうぎょ, とくこう, とくぼう, すばやさ の数値入力
                        for (int i = 0; i < StatIndex.size.index; i++)
                          Column(children: [
                            StatInputRow(
                              StatIndex.values[i].name,
                              myPokemon,
                              pokeStatRaceController[i],
                              pokeStatIndiController[i],
                              pokemonMinIndividual,
                              pokemonMaxIndividual,
                              myPokemon.stats[StatIndex.values[i]].indi,
                              (value) {
                                myPokemon.stats[StatIndex.values[i]].indi =
                                    value.toInt();
                                updateRealStat();
                              },
                              pokeStatEffortController[i],
                              pokemonMinEffort,
                              pokemonMaxEffort,
                              myPokemon.stats[StatIndex.values[i]].effort,
                              (value) {
                                myPokemon.stats[StatIndex.values[i]].effort =
                                    value.toInt();
                                updateRealStat();
                              },
                              pokeStatRealController[i],
                              myPokemon.stats[StatIndex.values[i]].real,
                              (value) {
                                myPokemon.stats[StatIndex.values[i]].real =
                                    value.toInt();
                                updateStatsRefReal(StatIndex.values[i]);
                              },
                              effectNature: i != 0,
                              statIndex: StatIndex.values[i],
                              loc: loc,
                            ),
                            pokemonState != null
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${loc.pokemonsTabConfValueRange} : ${pokemonState.minStats[StatIndex.values[i]].real} ~ ${pokemonState.maxStats[StatIndex.values[i]].real}',
                                            style: TextStyle(
                                                color: theme.primaryColor,
                                                fontSize: theme.textTheme
                                                    .bodyMedium?.fontSize),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ]),
                        // ステータスの合計値
                        StatTotalRow(
                          myPokemon.totalRace,
                          myPokemon.totalEffort,
                          loc: loc,
                        ),

                        // わざ1, PP1, わざ2, PP2, わざ3, PP3, わざ4, PP4
                        for (int i = 0; i < 4; i++)
                          Column(
                            children: [
                              MoveInputRow(
                                myPokemon,
                                '${loc.commonMove}${i + 1}',
                                'PP',
                                pokeMoveController[i],
                                [
                                  for (int j = 0; j < 4; j++)
                                    i != j ? myPokemon.moves[j] : null
                                ],
                                (suggestion) {
                                  pokeMoveController[i].text =
                                      suggestion.displayName;
                                  myPokemon.moves[i] = suggestion;
                                  pokePPController[i].text =
                                      suggestion.pp.toString();
                                  myPokemon.pps[i] = suggestion.pp;
                                  setState(() {});
                                },
                                () {
                                  for (int j = i; j < 4; j++) {
                                    if (j + 1 < 4 &&
                                        myPokemon.moves[j + 1] != null) {
                                      pokeMoveController[j].text =
                                          myPokemon.moves[j + 1]!.displayName;
                                      myPokemon.moves[j] =
                                          myPokemon.moves[j + 1];
                                      pokePPController[j].text =
                                          '${myPokemon.pps[j + 1]}';
                                      myPokemon.pps[j] = myPokemon.pps[j + 1];
                                    } else {
                                      pokeMoveController[j].text = '';
                                      myPokemon.moves[j] =
                                          j == 0 ? Move.none() : null;
                                      pokePPController[j].text = '0';
                                      myPokemon.pps[j] = 0;
                                      break;
                                    }
                                  }
                                  setState(() {});
                                },
                                pokePPController[i],
                                (value) {
                                  myPokemon.pps[i] = value.toInt();
                                },
                                minPP: myPokemon.moves[i] != null
                                    ? myPokemon.moves[i]!.minPP
                                    : 0,
                                maxPP: myPokemon.moves[i] != null
                                    ? myPokemon.moves[i]!.maxPP
                                    : 0,
                                moveEnabled: i == 0
                                    ? myPokemon.name != ''
                                    : myPokemon.moves[i - 1] != null &&
                                        myPokemon.moves[i - 1]!.id != 0,
                                ppEnabled: myPokemon.moves[i] != null &&
                                    myPokemon.moves[i]!.id != 0,
                                initialPPValue: myPokemon.pps[i] ?? 0,
                                isError: i == 0 && myPokemon.move1.id == 0,
                                moveTypeIcon: myPokemon.moves[i] != null &&
                                        myPokemon.moves[i]?.type !=
                                            PokeType.unknown
                                    ? myPokemon.moves[i]!.type.displayIcon
                                    : null,
                              ),
                              pokemonState != null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              i < pokemonState.moves.length
                                                  ? '${loc.pokemonsTabConfMove}${i + 1} : ${pokeData.moves[pokemonState.moves[i].id]!.displayName}'
                                                  : '',
                                              style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: theme.textTheme
                                                      .bodyMedium?.fontSize),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
