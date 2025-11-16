// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// form validation mixins
mixin FormValidators {
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    // at least 2 characters
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    // at least 2 words
    if (value.trim().split(' ').length < 2) {
      return 'Please enter your full name';
    }
    // only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // basic email format check (local-part@domain)
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

enum _CapitalizationType { words, sentence }

class CapitalizerFormatter implements TextInputFormatter {
  CapitalizerFormatter.words() : _capitalizeWords = _CapitalizationType.words;
  CapitalizerFormatter.sentence() : _capitalizeWords = _CapitalizationType.sentence;

  final _CapitalizationType _capitalizeWords;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText;
    if (_capitalizeWords == _CapitalizationType.words) {
      newText = newValue.text
          .split(' ')
          .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
    } else if (_capitalizeWords == _CapitalizationType.sentence) {
      final sentences = newValue.text.split(RegExp(r'([.!?]\s*)'));
      newText = sentences.map((sentence) {
        final trimmed = sentence.trimLeft();
        if (trimmed.isEmpty) return sentence;
        return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
      }).join();
    } else {
      throw UnimplementedError('Unsupported capitalization type');
    }
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}
