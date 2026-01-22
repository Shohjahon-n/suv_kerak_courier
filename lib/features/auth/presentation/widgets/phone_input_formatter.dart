import 'package:flutter/services.dart';

/// Formats Uzbek phone numbers to: +998 XX XXX XX XX
/// Auto-adds +998 prefix and formats as user types
class UzPhoneInputFormatter extends TextInputFormatter {
  static const String _countryCode = '998';
  static const int _maxLength = 12; // 998 + 9 digits = 12 total

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // If user clears everything, return empty
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Auto-add country code if not present
    if (!digits.startsWith(_countryCode)) {
      // If user typed something that doesn't match country code
      if (digits.length <= 3) {
        // User is still typing the country code or starting fresh
        digits = _countryCode;
      } else {
        // User typed a number without country code, prepend it
        digits = _countryCode + digits;
      }
    }

    // Limit to max 12 digits (998 + 9)
    if (digits.length > _maxLength) {
      digits = digits.substring(0, _maxLength);
    }

    // Format: +998 XX XXX XX XX
    final formatted = _formatDigits(digits);

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

  /// Format digits according to pattern: +998 XX XXX XX XX
  String _formatDigits(String digits) {
    final buffer = StringBuffer('+');

    for (int i = 0; i < digits.length; i++) {
      // Add spaces at specific positions
      if (i == 3 || i == 5 || i == 8 || i == 10) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
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

    // Count digits before cursor in new text
    final digitsBeforeCursor = newText
        .substring(0, oldCursor)
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Find position in formatted text with same number of digits
    int digitCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i].contains(RegExp(r'\d'))) {
        digitCount++;
        if (digitCount >= digitsBeforeCursor) {
          return i + 1;
        }
      }
    }

    return formattedText.length;
  }

  /// Get clean phone number (only digits)
  static String getCleanPhone(String formatted) {
    return formatted.replaceAll(RegExp(r'\D'), '');
  }

  /// Validate Uzbek phone number
  /// Must be exactly 12 digits starting with 998
  static bool isValid(String formatted) {
    final clean = getCleanPhone(formatted);

    // Must be 12 digits (998 + 9)
    if (clean.length != _maxLength) {
      return false;
    }

    // Must start with 998
    if (!clean.startsWith(_countryCode)) {
      return false;
    }

    // Second digit should be valid Uzbek operator code (9, 3, 5, 6, 7, 8)
    final operatorCode = clean.substring(3, 4);
    final validOperators = ['9', '3', '5', '6', '7', '8'];

    return validOperators.contains(operatorCode);
  }

  /// Get formatted display string from clean digits
  static String format(String digits) {
    final formatter = UzPhoneInputFormatter();
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    return formatter._formatDigits(
      clean.startsWith(_countryCode) ? clean : _countryCode + clean,
    );
  }
}
