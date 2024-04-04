import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/data_structs/poke_db.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.onReset,
    required this.viewLanguage,
    required this.viewLicense,
    required this.viewPolicy,
  }) : super(key: key);
  final void Function() onReset;
  final void Function() viewLanguage;
  final void Function() viewLicense;
  final void Function() viewPolicy;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTabTitleTop),
      ),
      body: Column(
        children: [
          /*ListTile(
            title: Text(loc.settingsTabReset),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.onReset(),
          ),*/
          ListTile(
            title: Text(loc.settingsTabGetWebImage),
            subtitle: Text(loc.settingsTabGetWebImageDescription),
            trailing: Checkbox(
              value: PokeDB().getPokeAPI,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  PokeDB().getPokeAPI = value;
                  PokeDB().saveConfig();
                });
              },
            ),
          ),
          ListTile(
            title: Text(loc.settingsTabLanguage),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.viewLanguage(),
          ),
          ListTile(
            title: Text(loc.settingsTabLicenses),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.viewLicense(),
          ),
          ListTile(
            title: Text(loc.settingsTabPrivacyPolicy),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.viewPolicy(),
          ),
          ListTile(
            title: Text(loc.settingsTabVersion),
            trailing: Text(pokeRecoVersion),
          ),
        ],
      ),
    );
  }
}

class SettingResetPage extends StatefulWidget {
  SettingResetPage({
    Key? key,
  }) : super(key: key);

  @override
  SettingResetPageState createState() => SettingResetPageState();
}

class SettingResetPageState extends State<SettingResetPage> {
  List<bool> checkList = List.generate(3, (index) => false);

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTabReset),
        actions: [
          TextButton(
            onPressed: getSelectedNum(checkList) > 0 ? () {} : null,
            child: Text(loc.settingsTabResetDone),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(loc.settingsTabDeleteBattles),
            leading: Checkbox(
              value: checkList[0],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  checkList[0] = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(loc.settingsTabDeletePokemons),
            leading: Checkbox(
              value: checkList[1],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  checkList[1] = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(loc.settingsTabDeleteParties),
            leading: Checkbox(
              value: checkList[2],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  checkList[2] = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingLanguagePage extends StatefulWidget {
  SettingLanguagePage({
    Key? key,
  }) : super(key: key);

  @override
  SettingLanguagePageState createState() => SettingLanguagePageState();
}

class SettingLanguagePageState extends State<SettingLanguagePage> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTabLanguage),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('日本語'),
            trailing: PokeDB().language == Language.japanese
                ? Icon(Icons.check)
                : null,
            onTap: () => setState(() {
              PokeDB().language = Language.japanese;
              PokeDB().saveConfig();
              MyApp.of(context)!.setLocale(Locale('ja', ''));
            }),
          ),
          ListTile(
            title: Text('English'),
            trailing: PokeDB().language == Language.english
                ? Icon(Icons.check)
                : null,
            onTap: () => setState(() {
              PokeDB().language = Language.english;
              PokeDB().saveConfig();
              MyApp.of(context)!.setLocale(Locale('en', ''));
            }),
          ),
        ],
      ),
    );
  }
}

class SettingLicensePage extends StatefulWidget {
  SettingLicensePage({
    Key? key,
  }) : super(key: key);

  @override
  SettingLicensePageState createState() => SettingLicensePageState();
}

class SettingLicensePageState extends State<SettingLicensePage> {
  String ossLicense = '';
  String fontLicense = '';
  bool ossExpanded = false;
  bool fontExpanded = false;

  SettingLicensePageState() {
    _loadContent();
  }

  void _loadContent() async {
    rootBundle.loadString('assets/licenses/LICENSE').then((value) => {
          setState(() {
            ossLicense = value;
          })
        });
    rootBundle.loadString('assets/licenses/OFL.txt').then((value) => {
          setState(() {
            fontLicense = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTabLicenses),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  ossExpanded = !ossExpanded;
                }),
                child: Stack(
                  children: [
                    Text(loc.settingsTabOSSLicense,
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: theme.textTheme.headlineSmall?.fontSize)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ossExpanded
                          ? Icon(Icons.keyboard_arrow_up)
                          : Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
              ossExpanded ? Text(ossLicense) : Container(),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => setState(() {
                  fontExpanded = !fontExpanded;
                }),
                child: Stack(
                  children: [
                    Text(loc.settingsTabFontLicense,
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: theme.textTheme.headlineSmall?.fontSize)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: fontExpanded
                          ? Icon(Icons.keyboard_arrow_up)
                          : Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
              fontExpanded ? Text(fontLicense) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTabPrivacyPolicy),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(loc.settingsTabPrivacyPolicyPrompt),
              Link(
                uri: Uri.parse('https://dko5ki23t.wixsite.com/my-site'),
                builder: (context, openLink) {
                  return TextButton(
                    onPressed: openLink,
                    child: Text(loc.settingsTabPrivacyPolicyButton),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
