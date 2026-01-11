import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class OrdersMapPoint {
  const OrdersMapPoint({
    required this.position,
    required this.title,
    required this.subtitle,
    this.details = const [],
    this.label,
  });

  final LatLng position;
  final String title;
  final String subtitle;
  final List<MapEntry<String, String>> details;
  final String? label;
}

@immutable
class OrdersMapRequest {
  const OrdersMapRequest({
    this.title,
    this.points = const [],
    this.loadPending = false,
  });

  final String? title;
  final List<OrdersMapPoint> points;
  final bool loadPending;
}
