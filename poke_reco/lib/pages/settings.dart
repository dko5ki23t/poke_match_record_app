import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.onReset,
    required this.viewLicense,
  }) : super(key: key);
  final void Function() onReset;
  final void Function() viewLicense;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Column(
        children: [
          /*ListTile(
            title: Text('リセット'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.onReset(),
          ),*/
          ListTile(
            title: Text('ライセンス情報'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.viewLicense(),
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
    var appState = context.watch<MyAppState>();
    var pokeData = appState.pokeData;

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    return Scaffold(
      appBar: AppBar(
        title: Text('リセット'),
        actions: [
          TextButton(
            onPressed: getSelectedNum(checkList) > 0 ?
              (){} : null,
            child: Text('実行'),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('対戦記録削除'),
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
            title: Text('ポケモン情報削除'),
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
            title: Text('パーティ情報削除'),
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
    rootBundle.loadString('assets/licenses/LICENSE')
      .then((value) => {
        setState(() {
          ossLicense = value;
        })
      });
    rootBundle.loadString('assets/licenses/OFL.txt')
      .then((value) => {
        setState(() {
          fontLicense = value;
        })
      });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    appState.onBackKeyPushed = (){};
    appState.onTabChange = (func) => func();

    return Scaffold(
      appBar: AppBar(
        title: Text('ライセンス情報'),
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
                    Text('本アプリOSSライセンス', style: TextStyle(color: theme.primaryColor, fontSize: theme.textTheme.headlineSmall?.fontSize)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ossExpanded ?
                        Icon(Icons.keyboard_arrow_up) :
                        Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
              ossExpanded ?
              Text(ossLicense) : Container(),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () => setState(() {
                  fontExpanded = !fontExpanded;
                }),
                child: Stack(
                  children: [
                    Text('使用フォントライセンス', style: TextStyle(color: theme.primaryColor, fontSize: theme.textTheme.headlineSmall?.fontSize)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: fontExpanded ?
                        Icon(Icons.keyboard_arrow_up) :
                        Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
              fontExpanded ?
              Text(fontLicense) : Container(),
            ],
          ),
          /*child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  style: theme.textTheme.headlineSmall,
                  text: '本アプリOSSライセンス\n',
                ),
                TextSpan(text: ossLicense),
                TextSpan(
                  style: theme.textTheme.headlineSmall,
                  text: '\n使用フォントライセンス\n',
                ),
                TextSpan(text: fontLicense),
              ],
            ),
          ),*/
        ),
      ),
    );
  }
}

