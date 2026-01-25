import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  const LoginResponse({
    required this.ok,
    required this.detail,
    required this.kuryerId,
    required this.name,
    required this.lang,
    required this.businessId,
    required this.lastActiveAt,
    required this.sessionid,
    required this.access,
    required this.refresh,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      ok: json['ok'] as bool? ?? false,
      detail: json['detail'] as String? ?? '',
      kuryerId: json['kuryer_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      lang: json['lang'] as String? ?? 'uz',
      businessId: json['business_id'] as int? ?? 0,
      lastActiveAt: json['last_active_at'] as String? ?? '',
      sessionid: json['sessionid'] as String? ?? '',
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  final bool ok;
  final String detail;
  final int kuryerId;
  final String name;
  final String lang;
  final int businessId;
  final String lastActiveAt;
  final String sessionid;
  final String access;
  final String refresh;
  final String tokenType;

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'detail': detail,
      'kuryer_id': kuryerId,
      'name': name,
      'lang': lang,
      'business_id': businessId,
      'last_active_at': lastActiveAt,
      'sessionid': sessionid,
      'access': access,
      'refresh': refresh,
      'token_type': tokenType,
    };
  }

  @override
  List<Object?> get props => [
    ok,
    detail,
    kuryerId,
    name,
    lang,
    businessId,
    lastActiveAt,
    sessionid,
    access,
    refresh,
    tokenType,
  ];
}
