import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../widgets/orders_map_view.dart';
import 'orders_map_models.dart';
import 'pending_orders_models.dart';

class OrdersMapPage extends StatefulWidget {
  const OrdersMapPage({super.key, this.request});

  final OrdersMapRequest? request;

  @override
  State<OrdersMapPage> createState() => _OrdersMapPageState();
}

class _OrdersMapPageState extends State<OrdersMapPage> {
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _error;
  List<OrdersMapPoint> _points = const [];
  OrdersMapRequest _request = const OrdersMapRequest(loadPending: true);
  LatLng? _courierPosition;
  StreamSubscription<Position>? _positionSubscription;
  final MapController _mapController = MapController();
  bool _isRouteLoading = false;
  List<LatLng> _routePoints = const [];
  bool _mapReady = false;
  bool _followHeading = false;
  double? _heading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) {
      return;
    }
    _hasLoaded = true;
    _request = widget.request ?? const OrdersMapRequest(loadPending: true);
    _points = _request.points;
    _startLocationTracking();
    if (_request.loadPending && _points.isEmpty) {
      _loadPending();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final l10n = AppLocalizations.of(context);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) {
        return;
      }
      if (!serviceEnabled) {
        _showToast(l10n.ordersLocationServiceDisabled);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (!mounted) {
        return;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) {
          return;
        }
      }
      if (permission == LocationPermission.denied) {
        _showToast(l10n.ordersLocationPermissionDenied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showToast(l10n.ordersLocationPermissionPermanentlyDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) {
        return;
      }
      _updatePosition(position);

      await _positionSubscription?.cancel();
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      );
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
        (position) {
          if (!mounted) {
            return;
          }
          _updatePosition(position);
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showToast(l10n.ordersLocationUnavailable);
    }
  }

  void _updatePosition(Position position) {
    final newHeading = _sanitizeHeading(position.heading);
    setState(() {
      _courierPosition = LatLng(position.latitude, position.longitude);
      if (newHeading != null) {
        _heading = newHeading;
      }
    });

    if (_followHeading) {
      _applyFollowHeading(
        position: LatLng(position.latitude, position.longitude),
        heading: newHeading ?? _heading,
      );
    }
  }

  double? _sanitizeHeading(double? heading) {
    if (heading == null || heading.isNaN || heading < 0) {
      return null;
    }
    return heading % 360;
  }

  void _applyFollowHeading({LatLng? position, double? heading}) {
    if (!_mapReady) {
      return;
    }
    final target = position ?? _courierPosition;
    if (target == null) {
      return;
    }
    final rotation = heading ?? _heading ?? _mapController.camera.rotation;
    _mapController.moveAndRotate(
      target,
      _mapController.camera.zoom,
      rotation,
    );
  }

  Future<void> _centerOnCourier() async {
    if (_courierPosition == null) {
      await _startLocationTracking();
    }
    if (!mounted) {
      return;
    }
    final position = _courierPosition;
    if (position == null || !_mapReady) {
      return;
    }
    _mapController.move(position, 16);
  }

  Future<void> _toggleFollowHeading() async {
    final shouldEnable = !_followHeading;
    if (shouldEnable && _courierPosition == null) {
      await _startLocationTracking();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _followHeading = shouldEnable && _courierPosition != null;
    });

    if (!_followHeading) {
      if (_mapReady) {
        _mapController.rotate(0);
      }
      return;
    }
    _applyFollowHeading();
  }

  Future<void> _loadPending() async {
    final l10n = AppLocalizations.of(context);
    final preferences = context.read<AppPreferences>();
    final businessId = preferences.readBusinessId();
    if (businessId == null) {
      setState(() {
        _isLoading = false;
        _error = l10n.ordersSessionMissing;
        _points = const [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        '/orders/pending-orders/',
        data: {'business_id': businessId},
      );
      final data = response.data;
      PendingOrdersResponse? result;
      String? errorMessage;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = _stringValue(map, 'detail');
        final ok = map['ok'];
        if (ok == false && detail != null) {
          errorMessage = detail;
        } else {
          result = PendingOrdersResponse.fromJson(map);
        }
      } else {
        errorMessage = l10n.ordersLoadFailed;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = errorMessage;
        _points = result == null ? const [] : _buildPoints(result.items);
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = _extractErrorDetail(error) ?? l10n.ordersLoadFailed;
        _points = const [];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = l10n.ordersLoadFailed;
        _points = const [];
      });
    }
  }

  List<OrdersMapPoint> _buildPoints(List<PendingOrderItem> items) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat('#,##0', locale.toString());

    return items
        .map((item) => _mapItem(item, l10n, numberFormat))
        .whereType<OrdersMapPoint>()
        .toList();
  }

  OrdersMapPoint? _mapItem(
    PendingOrderItem item,
    AppLocalizations l10n,
    NumberFormat numberFormat,
  ) {
    final location = item.parseLocation();
    if (location == null || !location.hasValue) {
      return null;
    }

    final position = LatLng(location.latitude!, location.longitude!);
    final orderNumber =
        item.orderNumber.isEmpty ? l10n.notAvailable : item.orderNumber;
    final dateLabel = _buildDateLabel(item, l10n);
    final details = <MapEntry<String, String>>[];

    if (item.buyerId > 0) {
      details.add(
        MapEntry(l10n.ordersBuyerIdLabel, numberFormat.format(item.buyerId)),
      );
    }
    details.add(
      MapEntry(
        l10n.ordersWaterCountLabel,
        numberFormat.format(item.waterCount),
      ),
    );

    final paymentStatus = item.paymentStatus.trim();
    details.add(
      MapEntry(
        l10n.ordersPaymentStatusLabel,
        paymentStatus.isEmpty ? l10n.notAvailable : paymentStatus,
      ),
    );

    final note = item.note.trim();
    if (note.isNotEmpty) {
      details.add(MapEntry(l10n.ordersNoteLabel, note));
    }

    final locationLabel = location.format();
    if (locationLabel != null) {
      details.add(MapEntry(l10n.ordersLocationLabel, locationLabel));
    }

    return OrdersMapPoint(
      position: position,
      title: '${l10n.ordersOrderIdLabel}: $orderNumber',
      subtitle: dateLabel,
      details: details,
      label: numberFormat.format(item.waterCount),
    );
  }

  String _buildDateLabel(PendingOrderItem item, AppLocalizations l10n) {
    final date = item.orderDate.isEmpty ? l10n.notAvailable : item.orderDate;
    final time = item.orderTime.trim();
    if (time.isEmpty) {
      return date;
    }
    return '$date · $time';
  }

  String? _extractErrorDetail(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return _stringValue(Map<String, dynamic>.from(data), 'detail');
    }
    return null;
  }

  String? _stringValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  void _showPointDetails(OrdersMapPoint point) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final l10n = AppLocalizations.of(context);
        final canNavigate = _courierPosition != null && !_isRouteLoading;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                point.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                point.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (point.details.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...point.details.map(
                  (detail) => _DetailRow(
                    label: detail.key,
                    value: detail.value,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canNavigate
                      ? () {
                          Navigator.of(context).pop();
                          _buildRouteTo(point);
                        }
                      : null,
                  icon: const Icon(Icons.directions),
                  label: Text(l10n.ordersMapGoButton),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _buildRouteTo(OrdersMapPoint point) async {
    if (_isRouteLoading) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final origin = _courierPosition;
    if (origin == null) {
      _showToast(l10n.ordersLocationUnavailable);
      return;
    }

    final previousRoute = _routePoints;
    setState(() {
      _isRouteLoading = true;
    });

    try {
      final dio = context.read<Dio>();
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${point.position.longitude},${point.position.latitude}',
      ).replace(queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      });
      final response = await dio.getUri(uri);
      final points = _parseRoutePoints(response.data);
      if (points.isEmpty) {
        throw StateError('Route is empty');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isRouteLoading = false;
        _routePoints = points;
      });
      _centerOnRoute(points);
    } on DioException {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRouteLoading = false;
        _routePoints = previousRoute;
      });
      _showToast(l10n.ordersRouteFailed);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRouteLoading = false;
        _routePoints = previousRoute;
      });
      _showToast(l10n.ordersRouteFailed);
    }
  }

  List<LatLng> _parseRoutePoints(dynamic data) {
    if (data is! Map) {
      return const [];
    }
    final map = Map<String, dynamic>.from(data);
    final routes = map['routes'];
    if (routes is! List || routes.isEmpty) {
      return const [];
    }
    final route = routes.first;
    if (route is! Map) {
      return const [];
    }
    final geometry = route['geometry'];
    if (geometry is! Map) {
      return const [];
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List) {
      return const [];
    }
    final points = <LatLng>[];
    for (final entry in coordinates) {
      if (entry is List && entry.length >= 2) {
        final lon = _toDouble(entry[0]);
        final lat = _toDouble(entry[1]);
        if (lat != null && lon != null) {
          points.add(LatLng(lat, lon));
        }
      }
    }
    return points;
  }

  void _centerOnRoute(List<LatLng> points) {
    if (points.isEmpty || !_mapReady) {
      return;
    }
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }
    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    _mapController.move(center, 13);
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  void _showCourierDetails() {
    final l10n = AppLocalizations.of(context);
    final position = _courierPosition;
    if (position == null) {
      _showToast(l10n.ordersLocationUnavailable);
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final coords =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ordersCourierTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ordersCourierSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                label: l10n.ordersLocationLabel,
                value: coords,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _request.title ?? l10n.ordersMapButton;
    final canRetry = _request.loadPending;
    final isBusy = _isLoading || _isRouteLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final followTooltip = _followHeading
        ? l10n.ordersMapFollowHeadingOff
        : l10n.ordersMapFollowHeading;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          OrdersMapView(
            points: _points,
            onPointTap: _showPointDetails,
            mapController: _mapController,
            routePoints: _routePoints,
            onMapReady: () {
              if (!mounted) {
                return;
              }
              _mapReady = true;
              if (_followHeading) {
                _applyFollowHeading();
              }
            },
            courierPosition: _courierPosition,
            courierLabel: l10n.ordersCourierLabel,
            courierTooltip: l10n.ordersCourierTitle,
            courierHeading: _heading,
            rotateCourierWithHeading: !_followHeading,
            onCourierTap: _showCourierDetails,
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'orders-map-follow-heading',
                  onPressed: _toggleFollowHeading,
                  tooltip: followTooltip,
                  mini: true,
                  backgroundColor:
                      _followHeading ? colorScheme.primary : null,
                  foregroundColor:
                      _followHeading ? colorScheme.onPrimary : null,
                  child: Icon(
                    _followHeading
                        ? Icons.explore
                        : Icons.explore_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'orders-map-find-me',
                  onPressed: _centerOnCourier,
                  tooltip: l10n.ordersMapFindMe,
                  mini: true,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          if (isBusy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.05),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_error != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _OverlayCard(
                  icon: Icons.wifi_off_outlined,
                  message: _error!,
                  actionLabel: canRetry ? l10n.cashReportRetry : null,
                  onAction: canRetry ? _loadPending : null,
                ),
              ),
            )
          else if (!_isLoading && _points.isEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _OverlayCard(
                  icon: Icons.place_outlined,
                  message: l10n.ordersEmptyState,
                  actionLabel: canRetry ? l10n.cashReportRetry : null,
                  onAction: canRetry ? _loadPending : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
