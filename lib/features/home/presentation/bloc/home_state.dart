import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

enum HomeMessageKey { courierIdMissing, unexpectedResponse, requestFailed }

class HomeDashboard extends Equatable {
  const HomeDashboard({
    required this.courierId,
    required this.lastActiveAt,
    required this.cashBalance,
    required this.fullWaterRemaining,
    required this.emptyBottleCount,
    required this.ordersCompletedToday,
  });

  final int courierId;
  final DateTime? lastActiveAt;
  final double cashBalance;
  final int fullWaterRemaining;
  final int emptyBottleCount;
  final int ordersCompletedToday;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    return HomeDashboard(
      courierId: _toInt(json['kuryer_id']) ?? 0,
      lastActiveAt: DateTime.tryParse(
        json['oxirgi_faol_vaqt']?.toString() ?? '',
      ),
      cashBalance: _toDouble(json['kassa_qoldigi']),
      fullWaterRemaining: _toInt(json['tula_suv_qoldigi']) ?? 0,
      emptyBottleCount: _toInt(json['bosh_bak_soni']) ?? 0,
      ordersCompletedToday:
          _toInt(json['bugungi_bajarilgan_buyurtmalar_soni']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
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

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  List<Object?> get props => [
        courierId,
        lastActiveAt,
        cashBalance,
        fullWaterRemaining,
        emptyBottleCount,
        ordersCompletedToday,
      ];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.dashboard,
    this.messageKey,
    this.messageDetail,
  });

  final HomeStatus status;
  final HomeDashboard? dashboard;
  final HomeMessageKey? messageKey;
  final String? messageDetail;

  HomeState copyWith({
    HomeStatus? status,
    HomeDashboard? dashboard,
    HomeMessageKey? messageKey,
    String? messageDetail,
    bool clearMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      messageDetail:
          clearMessage ? null : (messageDetail ?? this.messageDetail),
    );
  }

  @override
  List<Object?> get props => [status, dashboard, messageKey, messageDetail];
}
