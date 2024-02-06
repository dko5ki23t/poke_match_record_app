import 'package:flutter/material.dart';

class BubbleBorder extends ShapeBorder {
  final bool usePadding;
  final bool? nipInBottom;

  const BubbleBorder({this.usePadding = true, this.nipInBottom});

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: usePadding ? 12 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r =
        Rect.fromPoints(rect.topLeft, rect.bottomRight - const Offset(0, 12));
    if (nipInBottom == null) {
      return Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(8)));
    } else if (nipInBottom!) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(8)))
        ..moveTo(r.bottomCenter.dx - 10, r.bottomCenter.dy)
        ..relativeLineTo(10, 12)
        ..relativeLineTo(10, -12)
        ..close();
    } else {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(8)))
        ..moveTo(r.topCenter.dx - 10, r.topCenter.dy)
        ..relativeLineTo(10, -12)
        ..relativeLineTo(10, 12)
        ..close();
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
