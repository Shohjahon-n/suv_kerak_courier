import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../constants/app_constants.dart';

class DioClient {
  DioClient._();

  static Dio create({required Talker talker}) {
    final logNetwork = kDebugMode;
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

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
