import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import '../storage/app_preferences.dart';

/// Interceptor that adds Authorization header to all requests
/// and handles token refresh on 401 responses
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AppPreferences preferences, required Talker talker})
    : _preferences = preferences,
      _talker = talker;

  final AppPreferences _preferences;
  final Talker _talker;
  Dio? _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _requestsQueue = [];

  /// Set the Dio instance after creation to avoid circular dependency
  void setDio(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _preferences.readAccessToken();

    _talker.debug('🔐 AuthInterceptor onRequest:');
    _talker.debug('  Path: ${options.path}');
    _talker.debug('  Full URI: ${options.uri}');
    _talker.debug('  Method: ${options.method}');
    _talker.debug('  Is Auth Endpoint: ${_isAuthEndpoint(options.path)}');
    _talker.debug(
      '  Has Token: ${accessToken != null && accessToken.isNotEmpty}',
    );

    // Skip adding token for auth endpoints
    if (_isAuthEndpoint(options.path)) {
      _talker.debug('  ⏭️  Skipping token for auth endpoint');
      return handler.next(options);
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      // Ensure headers map exists
      if (options.headers.isEmpty) {
        options.headers = {};
      }

      options.headers['Authorization'] = 'Bearer $accessToken';

      _talker.info('  ✅ Added Bearer token to: ${options.path}');
      _talker.debug('  Token preview: ${accessToken.substring(0, 20)}...');
      _talker.debug('  Headers after: ${options.headers}');
    } else {
      _talker.warning('  ⚠️  No access token for: ${options.path}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 - Unauthorized
    if (err.response?.statusCode == 401) {
      _talker.warning('Received 401, attempting token refresh');

      // Avoid refresh loops
      if (_isAuthEndpoint(err.requestOptions.path)) {
        return handler.next(err);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _requestsQueue.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = _preferences.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _talker.error('No refresh token available');
          await _preferences.clearSession();
          return handler.next(err);
        }

        // Attempt to refresh token
        final newTokens = await _refreshToken(refreshToken);

        if (newTokens != null) {
          // Save new tokens
          await _preferences.setAccessToken(newTokens['access']);
          await _preferences.setRefreshToken(newTokens['refresh']);

          // Retry the failed request with new token
          if (_dio != null) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer ${newTokens['access']}';

            final response = await _dio!.fetch(options);
            handler.resolve(response);
          } else {
            handler.next(err);
            return;
          }

          // Retry queued requests
          await _retryQueuedRequests(newTokens['access']!);
        } else {
          // Refresh failed, clear session
          _talker.error('Token refresh failed');
          await _preferences.clearSession();
          handler.next(err);
        }
      } catch (e, stackTrace) {
        _talker.error('Error during token refresh', e, stackTrace);
        await _preferences.clearSession();
        handler.next(err);
      } finally {
        _isRefreshing = false;
        _requestsQueue.clear();
      }
    } else {
      handler.next(err);
    }
  }

  /// Refresh access token using refresh token
  Future<Map<String, String>?> _refreshToken(String refreshToken) async {
    if (_dio == null) {
      _talker.error('Dio instance not set in AuthInterceptor');
      return null;
    }

    try {
      final response = await _dio!.post(
        '/auth/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Remove auth header
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'access': data['access'] as String,
          'refresh': data['refresh'] as String? ?? refreshToken,
        };
      }
      return null;
    } catch (e, stackTrace) {
      _talker.error('Token refresh request failed', e, stackTrace);
      return null;
    }
  }

  /// Retry queued requests with new access token
  Future<void> _retryQueuedRequests(String newAccessToken) async {
    if (_dio == null) return;

    for (final options in _requestsQueue) {
      try {
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        await _dio!.fetch(options);
      } catch (e) {
        _talker.error('Failed to retry queued request: ${options.path}', e);
      }
    }
  }

  /// Check if the endpoint is an auth endpoint (no token needed)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/token/refresh') ||
        path.contains('/auth/forgot-password');
  }
}
