// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:developer';

import 'package:flutter/material.dart';

extension Notifiers on ChangeNotifier {
  void rebuild() {
    if (!hasListeners) {
      log(
        'No listeners to notify in $runtimeType. Skipping notifyListeners call.',
      );
      return;
    }
    notifyListeners();
  }
}

extension Capitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
