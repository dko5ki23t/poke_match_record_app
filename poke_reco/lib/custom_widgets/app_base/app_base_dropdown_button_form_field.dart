import 'package:flutter/material.dart';

/// デフォルトでメニューのボックスが角丸なDropdownButtonFormField
/// 角丸を表現するため、PopupMenuButton+InputDecoratorを用いる
/// enabled = falseまたはonChanged = null指定で無効になる
class AppBaseDropdownButtonFormField<T> extends PopupMenuButton<T> {
  AppBaseDropdownButtonFormField({
    Key? key,
    required List<ColoredPopupMenuItem<T>> items,
    T? value,
    VoidCallback? onOpened,
    PopupMenuItemSelected<T>? onChanged,
    PopupMenuCanceled? onCanceled,
    String? tooltip,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    double? splashRadius,
    Widget? icon,
    double? iconSize,
    Offset offset = Offset.zero,
    bool enabled = true,
    ShapeBorder? shape,
    Color? color,
    Color? iconColor,
    bool? enableFeedback,
    BoxConstraints? constraints,
    PopupMenuPosition? position,
    Clip clipBehavior = Clip.none,
    InputDecoration? decoration,
    Widget? childWhenNullValueSelected,
  }) : super(
          key: key,
          itemBuilder: (context) => items,
          initialValue: value,
          onOpened: onOpened,
          onSelected: onChanged,
          onCanceled: onCanceled,
          tooltip: tooltip,
          elevation: elevation,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          padding: padding,
          child: Builder(builder: (context) {
            InputBorder copiedOrDefaultBorder =
                decoration?.border ?? UnderlineInputBorder();
            return InputDecorator(
              decoration: decoration != null
                  ? decoration.copyWith(
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                      border: copiedOrDefaultBorder,
                      enabled: enabled && onChanged != null)
                  : InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                      border: UnderlineInputBorder(),
                      enabled: enabled && onChanged != null),
              child: value == null
                  ? childWhenNullValueSelected
                  : Builder(builder: (context) {
                      final selectedItems =
                          items.where((element) => element.value == value);
                      if (selectedItems.length != 1) {
                        return Container();
                      }
                      return selectedItems.first.child ?? Container();
                    }),
            );
          }),
          splashRadius: splashRadius,
          icon: icon,
          iconSize: iconSize,
          offset: offset,
          enabled: enabled && onChanged != null,
          shape: shape ??
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
          color: color,
          iconColor: iconColor,
          enableFeedback: enableFeedback,
          constraints: constraints,
          position: position,
          clipBehavior: clipBehavior,
        );
}

class ColoredPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;

  const ColoredPopupMenuItem({
    Key? key,
    T? value,
    bool enabled = true,
    Widget? child,
    this.color = Colors.white,
  }) : super(key: key, value: value, enabled: enabled, child: child);

  @override
  createState() => _ColoredPopupMenuItemState<T>();
}

class _ColoredPopupMenuItemState<T>
    extends PopupMenuItemState<T, ColoredPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: super.build(context),
    );
  }
}
