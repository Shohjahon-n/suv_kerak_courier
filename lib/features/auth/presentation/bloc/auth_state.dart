part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.courierId,
    this.businessId,
    this.courierName,
    this.message,
    this.errorMessage,
  });

  final AuthStatus status;
  final int? courierId;
  final int? businessId;
  final String? courierName;
  final String? message;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    int? courierId,
    int? businessId,
    String? courierName,
    String? message,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      courierId: courierId ?? this.courierId,
      businessId: businessId ?? this.businessId,
      courierName: courierName ?? this.courierName,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    courierId,
    businessId,
    courierName,
    message,
    errorMessage,
  ];
}
