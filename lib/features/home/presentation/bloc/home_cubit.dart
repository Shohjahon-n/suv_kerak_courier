import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/app_preferences.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._dio, this._preferences) : super(const HomeState()) {
    load();
  }

  final Dio _dio;
  final AppPreferences _preferences;

  Future<void> load() async {
    final courierId = _preferences.readCourierId();
    if (courierId == null) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: 'Courier ID not found.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading, clearMessage: true));

    try {
      final response = await _dio.get(
        '/orders/kuryer/main-menu/',
        queryParameters: {'kuryer_id': courierId},
      );

      final data = response.data;
      if (data is! Map) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            message: 'Unexpected response.',
          ),
        );
        return;
      }

      final dashboard =
          HomeDashboard.fromJson(Map<String, dynamic>.from(data));
      emit(
        state.copyWith(
          status: HomeStatus.success,
          dashboard: dashboard,
          clearMessage: true,
        ),
      );
    } on DioException catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: _extractErrorDetail(error) ?? 'Request failed.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: 'Request failed.',
        ),
      );
    }
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  String? _extractErrorDetail(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return null;
  }
}
