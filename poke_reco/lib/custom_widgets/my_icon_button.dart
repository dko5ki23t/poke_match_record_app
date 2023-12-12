import 'package:flutter/material.dart';

class MyIconButton extends IconButton {
  MyIconButton(
    {
      required ThemeData theme,
      required void Function()? onPressed,
      required Widget icon,
      String? tooltip,
    }
  ) : 
  super(
    onPressed: onPressed,
    color: theme.buttonTheme.colorScheme!.primary,
    icon: icon,
    tooltip: tooltip,
  );
}