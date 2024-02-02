import 'package:flutter/material.dart';

void main() =>
    runApp(MaterialApp(home: Scaffold(appBar: AppBar(), body: MyApp())));

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final Hoge _hoge = Hoge();
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(_hoge.text, key: const Key('text')),
      ElevatedButton(
        key: const Key('button'),
        child: const Text('button'),
        onPressed: () {
          setState(() {
            _hoge.change();
          });
        },
      )
    ]);
  }
}

class Hoge {
  String text = 'hogehoge';
  void change() {
    if (text == 'hogehoge') {
      text = 'fugafuga';
    } else {
      text = 'hogehoge';
    }
  }
}
