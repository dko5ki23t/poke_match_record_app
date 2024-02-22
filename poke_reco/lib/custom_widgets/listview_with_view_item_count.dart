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
        return Scrollbar(
          child: ListView.builder(
              itemExtent: constraints.maxHeight / viewItemCount,
              findChildIndexCallback: (Key key) {
                final index =
                    children.indexWhere((element) => element.key == key);

                if (index > 0) {
                  return index;
                } else {
                  return null;
                }
              },
              itemBuilder: (context, index) {
                if (index < children.length) {
                  return children[index];
                }
                return null;
              }),
        );
      },
    );
  }
}
