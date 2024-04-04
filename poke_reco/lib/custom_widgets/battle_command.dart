import 'package:flutter/material.dart';

abstract class BattleCommandState<T extends StatefulWidget> extends State<T> {
  void reset();
}
