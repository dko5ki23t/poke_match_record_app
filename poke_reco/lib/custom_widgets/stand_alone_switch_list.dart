import 'package:flutter/material.dart';

class StandAloneSwitchList extends StatefulWidget {
  const StandAloneSwitchList({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    this.title,
  }) : super(key: key);

  final bool initialValue;
  final void Function(bool) onChanged;
  final Widget? title;

  @override
  State<StandAloneSwitchList> createState() => _StandAloneSwitchListState();
}

class _StandAloneSwitchListState extends State<StandAloneSwitchList> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: widget.title,
        dense: true,
        value: value,
        onChanged: (v) {
          widget.onChanged(v);
          setState(() {
            value = v;
          });
        });
  }
}
