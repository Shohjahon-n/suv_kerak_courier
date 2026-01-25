import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:talker/talker.dart';

import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository, required Talker talker})
    : _authRepository = authRepository,
      _talker = talker,
      super(const AuthState());

  final AuthRepository _authRepository;
  final Talker _talker;

  /// Login with phone and password
  Future<void> login({required String phone, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.login(
        phone: phone,
        password: password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          courierId: response.kuryerId,
          businessId: response.businessId,
          courierName: response.name,
          message: response.detail,
        ),
      );

      _talker.info('User logged in successfully: ${response.kuryerId}');
    } catch (e, stackTrace) {
      _talker.error('Login failed', e, stackTrace);
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(const AuthState());
      _talker.info('User logged out successfully');
    } catch (e, stackTrace) {
      _talker.error('Logout failed', e, stackTrace);
    }
  }

  /// Check if user is logged in
  Future<void> checkAuthStatus() async {
    final isLoggedIn = _authRepository.isLoggedIn();
    final courierId = _authRepository.getCurrentCourierId();
    final businessId = _authRepository.getCurrentBusinessId();

    if (isLoggedIn && courierId != null && businessId != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          courierId: courierId,
          businessId: businessId,
        ),
      );
      _talker.info('User is already logged in: $courierId');
    } else {
      emit(const AuthState());
      _talker.info('User is not logged in');
    }
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStatus.error) {
      emit(state.copyWith(status: AuthStatus.initial, errorMessage: null));
    }
  }
}
