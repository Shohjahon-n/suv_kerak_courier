
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl =
      'https://suv-kerak-backend-eu-d9af752240af.herokuapp.com';
  static const String appShareUrl = '';
  static const String appUpdateUrl = '';
}


extension StringFormatExtension on String? {
  String toUzsFormat() {
    final raw = this?.trim();
    if (raw == null || raw.isEmpty) {
      return '0';
    }
    var normalized = raw.replaceAll(' ', '');
    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll(',', '');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    final value = double.tryParse(normalized) ?? 0;
    if (value == 0) {
      return '0';
    }
    final isNegative = value.isNegative;
    final absValue = value.abs();
    final hasFraction = absValue % 1 != 0;
    final fixed = absValue.toStringAsFixed(hasFraction ? 2 : 0);
    final parts = fixed.split('.');
    final grouped = _formatUzsDigits(parts[0]);
    final fraction = hasFraction ? '.${parts[1]}' : '';
    final sign = isNegative ? '-' : '';
    return '$sign$grouped$fraction UZS';
  }
}

String _formatUzsDigits(String digits) {
  return digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]} ',
  );
}
