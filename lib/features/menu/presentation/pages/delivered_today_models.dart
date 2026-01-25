import 'package:equatable/equatable.dart';

class DeliveredTodayResponse extends Equatable {
  const DeliveredTodayResponse({
    required this.businessId,
    required this.courierId,
    required this.count,
    required this.totalWaterCount,
    required this.items,
  });

  final int businessId;
  final int courierId;
  final int count;
  final int totalWaterCount;
  final List<DeliveredTodayItem> items;

  @override
  List<Object> get props => [
    businessId,
    courierId,
    count,
    totalWaterCount,
    items,
  ];

  factory DeliveredTodayResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(
          (item) =>
              DeliveredTodayItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    return DeliveredTodayResponse(
      businessId: _toInt(json['business_id']) ?? 0,
      courierId: _toInt(json['kuryer_id']) ?? 0,
      count: _toInt(json['count']) ?? items.length,
      totalWaterCount: _toInt(json['suv_soni_jami']) ?? 0,
      items: items,
    );
  }
}

class DeliveredTodayItem extends Equatable {
  const DeliveredTodayItem({
    required this.orderDate,
    required this.orderTime,
    required this.address,
    required this.note,
    required this.buyerId,
    required this.orderNumber,
    required this.waterCount,
    required this.locationRaw,
    required this.paymentStatus,
    required this.onlinePayments,
    required this.courierName,
    required this.courierPhone,
  });

  final String orderDate;
  final String orderTime;
  final String address;
  final String note;
  final int buyerId;
  final String orderNumber;
  final int waterCount;
  final String locationRaw;
  final String paymentStatus;
  final List<dynamic> onlinePayments;
  final String courierName;
  final String courierPhone;

  @override
  List<Object> get props => [
    orderDate,
    orderTime,
    address,
    note,
    buyerId,
    orderNumber,
    waterCount,
    locationRaw,
    paymentStatus,
    onlinePayments,
    courierName,
    courierPhone,
  ];

  factory DeliveredTodayItem.fromJson(Map<String, dynamic> json) {
    return DeliveredTodayItem(
      orderDate: json['buyurtma_sanasi']?.toString() ?? '',
      orderTime: json['buyurtma_vaqti']?.toString() ?? '',
      address: json['manzil']?.toString() ?? '',
      note: json['izoh']?.toString() ?? '',
      buyerId: _toInt(json['buyurtmachi_id']) ?? 0,
      orderNumber: json['buyurtma_id_raqami']?.toString() ?? '',
      waterCount: _toInt(json['suv_soni']) ?? 0,
      locationRaw: json['location']?.toString() ?? '',
      paymentStatus: json['tulov_statusi']?.toString() ?? '',
      onlinePayments: json['online_payments'] as List<dynamic>? ?? [],
      courierName: json['kuryer_name']?.toString() ?? '',
      courierPhone: json['kuryer_tel_num']?.toString() ?? '',
    );
  }

  ParsedLocation? parseLocation() {
    return ParsedLocation.fromPointString(locationRaw);
  }
}

class ParsedLocation extends Equatable {
  const ParsedLocation({required this.latitude, required this.longitude});

  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [latitude, longitude];

  bool get hasValue => latitude != null && longitude != null;

  String? format() {
    if (!hasValue) {
      return null;
    }
    return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
  }

  static ParsedLocation? fromPointString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final match = RegExp(
      r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)',
    ).firstMatch(raw);
    if (match == null) {
      return null;
    }
    final lng = double.tryParse(match.group(1) ?? '');
    final lat = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) {
      return null;
    }
    return ParsedLocation(latitude: lat, longitude: lng);
  }
}

int? _toInt(dynamic value) {
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
