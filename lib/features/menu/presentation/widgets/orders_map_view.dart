import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../pages/orders_map_models.dart';

class OrdersMapView extends StatelessWidget {
  const OrdersMapView({
    super.key,
    required this.points,
    this.center,
    this.zoom = 13,
    this.onPointTap,
    this.mapController,
    this.routePoints = const [],
    this.onMapReady,
    this.courierPosition,
    this.courierLabel,
    this.courierTooltip,
    this.courierHeading,
    this.rotateCourierWithHeading = true,
    this.onCourierTap,
  });

  final List<OrdersMapPoint> points;
  final LatLng? center;
  final double zoom;
  final ValueChanged<OrdersMapPoint>? onPointTap;
  final MapController? mapController;
  final List<LatLng> routePoints;
  final VoidCallback? onMapReady;
  final LatLng? courierPosition;
  final String? courierLabel;
  final String? courierTooltip;
  final double? courierHeading;
  final bool rotateCourierWithHeading;
  final VoidCallback? onCourierTap;

  static const _fallbackCenter = LatLng(41.3111, 69.2797);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initialCenter = center ??
        (points.isNotEmpty
            ? points.first.position
            : courierPosition ?? _fallbackCenter);
    final markers = <Marker>[
      ...points.map(
        (point) => Marker(
          point: point.position,
          width: 46,
          height: 46,
          child: _MapMarker(
            point: point,
            onTap: onPointTap,
          ),
        ),
      ),
    ];
    if (courierPosition != null) {
      markers.add(
        Marker(
          point: courierPosition!,
          width: 50,
          height: 50,
          child: _CourierMarker(
            label: courierLabel,
            tooltip: courierTooltip,
            heading: courierHeading,
            rotateWithHeading: rotateCourierWithHeading,
            onTap: onCourierTap,
          ),
        ),
      );
    }
    final polylines = routePoints.isEmpty
        ? const <Polyline>[]
        : [
            Polyline(
              points: routePoints,
              strokeWidth: 5,
              color: colorScheme.primary,
            ),
          ];
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: zoom,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'suv_kerak_courier',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.point,
    required this.onTap,
  });

  final OrdersMapPoint point;
  final ValueChanged<OrdersMapPoint>? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = point.label;
    final marker = Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: 36,
          color: colorScheme.primary,
        ),
        if (label != null)
          Positioned(
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.primary),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
      ],
    );

    final child = Tooltip(
      message: point.title,
      child: marker,
    );

    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: () => onTap!(point),
      child: child,
    );
  }
}

class _CourierMarker extends StatelessWidget {
  const _CourierMarker({
    required this.label,
    required this.tooltip,
    required this.heading,
    required this.rotateWithHeading,
    required this.onTap,
  });

  final String? label;
  final String? tooltip;
  final double? heading;
  final bool rotateWithHeading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmedLabel = label?.trim();
    final headingValue = rotateWithHeading ? heading : null;
    final rotation = headingValue == null
        ? 0.0
        : (headingValue * math.pi / 180);
    final marker = Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: rotation,
          child: Icon(
            Icons.my_location,
            size: 32,
            color: colorScheme.secondary,
          ),
        ),
        if (trimmedLabel != null && trimmedLabel.isNotEmpty)
          Positioned(
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.secondary),
              ),
              child: Text(
                trimmedLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
      ],
    );

    final tooltipText = tooltip?.trim();
    final child = tooltipText != null && tooltipText.isNotEmpty
        ? Tooltip(message: tooltipText, child: marker)
        : marker;

    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
