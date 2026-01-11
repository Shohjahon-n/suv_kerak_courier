import 'package:intl/intl.dart';

class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = 'https://suv-kerak-backend-eu-d9af752240af.herokuapp.com';
}

var uzsFormat = NumberFormat.currency(locale: 'uz_UZ', symbol: 'so\'m');
