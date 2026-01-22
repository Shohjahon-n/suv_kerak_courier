import 'package:flutter/services.dart';

/// Formats Uzbek car plates to: 01 A 123 AA
/// Pattern: 2 digits + 1 letter + 3 digits + 2 letters
class CarPlateInputFormatter extends TextInputFormatter {
  static const int _maxLength = 8; // 2 + 1 + 3 + 2 = 8 characters

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert to uppercase
    String text = newValue.text.toUpperCase();

    // If empty, return as is
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Remove all invalid characters and spaces
    // Valid: 0-9, A-Z, Cyrillic letters, Uzbek special letters
    final clean = text.replaceAll(RegExp(r'[^0-9A-ZА-ЯЁЎҚҒҲ]'), '');

    // Build formatted string according to pattern
    final formatted = _formatPlate(clean);

    // Calculate cursor position
    final cursorPosition = _calculateCursorPosition(
      oldValue.text,
      newValue.text,
      formatted,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Format plate according to pattern: 01 A 123 AA
  String _formatPlate(String clean) {
    if (clean.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    final maxLen = clean.length > _maxLength ? _maxLength : clean.length;

    for (int i = 0; i < maxLen; i++) {
      final char = clean[i];

      // Position 0-1: Must be digits
      if (i < 2) {
        if (RegExp(r'\d').hasMatch(char)) {
          buffer.write(char);
        }
      }
      // Position 2: Must be letter
      else if (i == 2) {
        if (RegExp(r'[A-ZА-ЯЁЎҚҒҲ]').hasMatch(char)) {
          if (buffer.length == 2) {
            buffer.write(' ');
          }
          buffer.write(char);
        }
      }
      // Position 3-5: Must be digits
      else if (i < 6) {
        if (RegExp(r'\d').hasMatch(char)) {
          if (buffer.length == 4) {
            buffer.write(' ');
          }
          buffer.write(char);
        }
      }
      // Position 6-7: Must be letters
      else {
        if (RegExp(r'[A-ZА-ЯЁЎҚҒҲ]').hasMatch(char)) {
          if (buffer.length == 8) {
            buffer.write(' ');
          }
          buffer.write(char);
        }
      }
    }

    return buffer.toString();
  }

  /// Calculate proper cursor position after formatting
  int _calculateCursorPosition(
    String oldText,
    String newText,
    String formattedText,
    int oldCursor,
  ) {
    // If cursor was at end, keep it at end
    if (oldCursor >= newText.length) {
      return formattedText.length;
    }

    // Count non-space chars before cursor
    final charsBeforeCursor = newText
        .substring(0, oldCursor)
        .replaceAll(' ', '')
        .length;

    // Find position in formatted text with same number of chars
    int charCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != ' ') {
        charCount++;
        if (charCount >= charsBeforeCursor) {
          return i + 1;
        }
      }
    }

    return formattedText.length;
  }

  /// Get clean plate (no spaces)
  static String getCleanPlate(String formatted) {
    return formatted.replaceAll(' ', '');
  }

  /// Validate Uzbek car plate
  /// Pattern: 2 digits + 1 letter + 3 digits + 2 letters
  static bool isValid(String formatted) {
    final clean = getCleanPlate(formatted);

    // Must be exactly 8 characters
    if (clean.length != _maxLength) {
      return false;
    }

    // Check pattern: NN L NNN LL
    // Positions 0-1: digits
    if (!RegExp(r'^\d{2}').hasMatch(clean.substring(0, 2))) {
      return false;
    }

    // Position 2: letter (Latin or Cyrillic)
    if (!RegExp(r'[A-ZА-ЯЁЎҚҒҲ]').hasMatch(clean[2])) {
      return false;
    }

    // Positions 3-5: digits
    if (!RegExp(r'^\d{3}').hasMatch(clean.substring(3, 6))) {
      return false;
    }

    // Positions 6-7: letters (Latin or Cyrillic)
    if (!RegExp(r'^[A-ZА-ЯЁЎҚҒҲ]{2}').hasMatch(clean.substring(6, 8))) {
      return false;
    }

    return true;
  }

  /// Get formatted display string from clean plate
  static String format(String clean) {
    final formatter = CarPlateInputFormatter();
    return formatter._formatPlate(clean.toUpperCase().replaceAll(' ', ''));
  }
}
