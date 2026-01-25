import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../constants/app_constants.dart';
import '../storage/app_preferences.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required Talker talker,
    required AppPreferences preferences,
  }) {
    final logNetwork = kDebugMode;
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    // Create auth interceptor
    final authInterceptor = AuthInterceptor(
      preferences: preferences,
      talker: talker,
    );

    // Add auth interceptor first (before logging)
    dio.interceptors.add(authInterceptor);

    // Set Dio instance after adding interceptor to avoid circular dependency
    authInterceptor.setDio(dio);

    // Add logging interceptor
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: TalkerDioLoggerSettings(
          printResponseData: logNetwork,
          printRequestData: logNetwork,
          printRequestHeaders: logNetwork,
          printResponseMessage: logNetwork,
          printResponseTime: logNetwork,
        ),
      ),
    );

    return dio;
  }
}
