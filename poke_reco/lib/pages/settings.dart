import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poke_reco/main.dart';
import 'package:poke_reco/tool.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.onReset,
    required this.viewLicense,
    required this.viewPolicy,
  }) : super(key: key);
  final void Function() onReset;
  final void Function() viewLicense;
  final void Function() viewPolicy;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
          ListTile(
            title: Text('プライバシーポリシー'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => widget.viewPolicy(),
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
        ),
      ),
    );
  }
}

class SettingPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プライバシーポリシー'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('以下のURLからプライバシーポリシーをご確認ください。'),
              Link(
                uri: Uri.parse('https://dko5ki23t.wixsite.com/my-site'),
                builder: (context, openLink) {
                  return TextButton(
                    onPressed: openLink,
                    child: Text('Webサイト表示'),
                  );
                },),
            ],
          ),
        ),
      ),
    );
  }
}

