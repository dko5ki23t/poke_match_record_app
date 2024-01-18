import 'package:flutter/material.dart';

class ListViewWithViewItemCount extends StatelessWidget {
  const ListViewWithViewItemCount({
    super.key,
    required this.viewItemCount,
    required this.children,
  });
  final int viewItemCount;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          itemExtent: constraints.maxHeight / viewItemCount,
          children: children,
        );
      },
    );
  }
}