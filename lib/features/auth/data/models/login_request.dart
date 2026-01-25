import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  const LoginRequest({required this.phone, required this.password});

  final String phone;
  final String password;

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'password': password};
  }

  @override
  List<Object?> get props => [phone, password];
}
