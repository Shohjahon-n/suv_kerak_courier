class PendingOrdersResponse {
  const PendingOrdersResponse({
    required this.businessId,
    required this.count,
    required this.totalWaterCount,
    required this.items,
  });

  final int businessId;
  final int count;
  final int totalWaterCount;
  final List<PendingOrderItem> items;

  factory PendingOrdersResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((item) => PendingOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return PendingOrdersResponse(
      businessId: _toInt(json['business_id']) ?? 0,
      count: _toInt(json['count']) ?? items.length,
      totalWaterCount: _toInt(json['suv_soni_jami']) ?? 0,
      items: items,
    );
  }
}

class PendingOrderItem {
  const PendingOrderItem({
    required this.orderDate,
    required this.orderTime,
    required this.address,
    required this.note,
    required this.buyerId,
    required this.orderNumber,
    required this.waterCount,
    required this.locationRaw,
    required this.paymentStatus,
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

  factory PendingOrderItem.fromJson(Map<String, dynamic> json) {
    return PendingOrderItem(
      orderDate: json['buyurtma_sanasi']?.toString() ?? '',
      orderTime: json['buyurtma_vaqti']?.toString() ?? '',
      address: json['manzil']?.toString() ?? '',
      note: json['izoh']?.toString() ?? '',
      buyerId: _toInt(json['buyurtmachi_id']) ?? 0,
      orderNumber: json['buyurtma_id_raqami']?.toString() ?? '',
      waterCount: _toInt(json['suv_soni']) ?? 0,
      locationRaw: json['location']?.toString() ?? '',
      paymentStatus: json['tulov_statusi']?.toString() ?? '',
    );
  }

  ParsedLocation? parseLocation() {
    return ParsedLocation.fromPointString(locationRaw);
  }
}

class ParsedLocation {
  const ParsedLocation({
    required this.latitude,
    required this.longitude,
  });

  final double? latitude;
  final double? longitude;

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
    final match =
        RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)').firstMatch(raw);
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
