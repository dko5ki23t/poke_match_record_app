import 'package:flutter/material.dart';

class BubbleBorder extends ShapeBorder {
  final bool? nipInBottom;

  const BubbleBorder({this.nipInBottom});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  //EdgeInsets.only(bottom: usePadding ? 0 : 0, top: usePadding ? 0 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    if (nipInBottom == null) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)));
    } else if (nipInBottom!) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)))
        ..moveTo(rect.bottomCenter.dx - 10, rect.bottomCenter.dy)
        ..relativeLineTo(10, 8)
        ..relativeLineTo(10, -8)
        ..close();
    } else {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)))
        ..moveTo(rect.topCenter.dx - 10, rect.topCenter.dy)
        ..relativeLineTo(10, -8)
        ..relativeLineTo(10, 8)
        ..close();
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
