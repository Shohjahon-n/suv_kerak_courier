import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/app_preferences.dart';
import '../models/login_response.dart';

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required AppPreferences preferences,
    required Talker talker,
  }) : _dio = dio,
       _preferences = preferences,
       _talker = talker;

  final Dio _dio;
  final AppPreferences _preferences;
  final Talker _talker;

  /// Login with courier ID and password
  Future<LoginResponse> login({
    required int courierId,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'kuryer_id': courierId, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        // Save tokens and user data to storage
        await _saveSession(loginResponse);

        _talker.info('Login successful for courier: ${loginResponse.kuryerId}');
        return loginResponse;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      _talker.error('Login failed - DioException', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      _talker.error('Login failed', e, stackTrace);
      rethrow;
    }
  }

  /// Save login session to storage
  Future<void> _saveSession(LoginResponse response) async {
    _talker.info('💾 Saving session to storage...');
    _talker.debug('  Courier ID: ${response.kuryerId}');
    _talker.debug('  Business ID: ${response.businessId}');

    await _preferences.setAccessToken(response.access);
    await _preferences.setRefreshToken(response.refresh);
    await _preferences.setCourierId(response.kuryerId);
    await _preferences.setBusinessId(response.businessId);

    // Save user JSON for profile data
    final userJson = response.toJson();
    await _preferences.setUserJson(userJson.toString());

    _talker.info('✅ Session saved successfully');
  }

  /// Logout - clear session
  Future<void> logout() async {
    try {
      // Optional: call logout endpoint if backend has one
      // await _dio.post('/auth/logout/');

      await _preferences.clearSession();
      _talker.info('Logout successful');
    } catch (e, stackTrace) {
      _talker.error('Logout failed', e, stackTrace);
      // Still clear local session even if API call fails
      await _preferences.clearSession();
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final accessToken = _preferences.readAccessToken();
    final courierId = _preferences.readCourierId();
    return accessToken != null && accessToken.isNotEmpty && courierId != null;
  }

  /// Get current courier ID
  int? getCurrentCourierId() {
    return _preferences.readCourierId();
  }

  /// Get current business ID
  int? getCurrentBusinessId() {
    return _preferences.readBusinessId();
  }
}
