import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Utility functions for error handling across the app
class ErrorHandler {
  /// Extract error detail message from DioException response
  static String? extractErrorDetail(DioException error) {
    final data = error.response?.data;
    return _stringValue(data, 'detail');
  }

  /// Extract string value from dynamic data map
  static String? _stringValue(dynamic data, String key) {
    if (data is Map) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  /// Extract int value from dynamic data
  static int? intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Log error to Talker and optionally show snackbar
  static void handleError(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? customMessage,
    bool showSnackbar = false,
  }) {
    // Log to Talker
    try {
      final talker = context.read<Talker>();
      talker.error(customMessage ?? 'Error occurred', error, stackTrace);
    } catch (_) {
      // Talker not available in context, log to debug console
      debugPrint('Error: ${customMessage ?? error.toString()}');
    }

    // Show snackbar if requested
    if (showSnackbar && context.mounted) {
      String message = customMessage ?? 'An error occurred';
      if (error is DioException) {
        message = extractErrorDetail(error) ?? message;
      }
      showToast(context, message);
    }
  }

  /// Show a toast message using SnackBar
  static void showToast(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

/// Mixin for StatefulWidget states to easily handle errors
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  /// Extract error detail from DioException
  String? extractErrorDetail(DioException error) =>
      ErrorHandler.extractErrorDetail(error);

  /// Extract string value from dynamic data
  String? stringValue(dynamic data, String key) =>
      ErrorHandler._stringValue(data, key);

  /// Extract int value from dynamic data
  int? intValue(dynamic value) => ErrorHandler.intValue(value);

  /// Handle and log error
  void handleError(
    Object error, {
    StackTrace? stackTrace,
    String? customMessage,
    bool showSnackbar = false,
  }) {
    ErrorHandler.handleError(
      context,
      error,
      stackTrace: stackTrace,
      customMessage: customMessage,
      showSnackbar: showSnackbar,
    );
  }

  /// Show toast message
  void showToast(String message) => ErrorHandler.showToast(context, message);
}
