
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl =
      'https://suv-kerak-backend-eu-d9af752240af.herokuapp.com';
  static const String appShareUrl = '';
  static const String appUpdateUrl = '';
}


extension StringFormatExtension on String? {
  String toUzsFormat() {
    final value = int.tryParse(this ?? '0') ?? 0;
    if (value == 0) return '0';
    return "${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
    )} UZS";
  }
}
