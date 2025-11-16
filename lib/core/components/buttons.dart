import 'package:flutter/material.dart';

class FCButton extends ElevatedButton {
  const FCButton._({
    super.key,
    required super.onPressed,
    required super.child,
    super.style,
  });

  factory FCButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return FCButton._(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  factory FCButton.danger({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return FCButton._(
      key: key,
      onPressed: onPressed,
      style: style?.copyWith(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
      child: child,
    );
  }

  factory FCButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return FCButton._(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  factory FCButton.terciary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    required ButtonStyle? style,
  }) {
    return FCButton._(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
