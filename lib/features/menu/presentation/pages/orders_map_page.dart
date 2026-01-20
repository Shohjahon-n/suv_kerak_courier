import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';

enum NavMode { autoRotate, userRotate }

class OrdersMapPage extends StatefulWidget {
  const OrdersMapPage({super.key});

  @override
  State<OrdersMapPage> createState() => _OrdersMapPageState();
}

class _OrdersMapPageState extends State<OrdersMapPage> {
  final MapController _mapController = MapController();
  final Talker _talker = getIt<Talker>();
  final Dio _dio = getIt<Dio>();
  final AppPreferences _preferences = getIt<AppPreferences>();

  StreamSubscription<CompassEvent>? _compassStream;
  StreamSubscription<Position>? _positionStream;

  List<dynamic> _orders = [];
  LatLng? _myLocation;

  bool _isFirstLoad = true;
  double _heading = 0;

  Map<String, dynamic> _orderDetail = {};
  Map<String, dynamic> _orderDetailPay = {};

  bool _showDetail = false;
  bool _ready = false;
  bool _onWay = false;
  bool _loading = false;

  List<dynamic> _route = [];
  Map<String, dynamic> _onWayData = {};
  String _phone = "";

  NavMode _navMode = NavMode.autoRotate;

  bool _mapReady = false;
  double _mapRotDeg = 0;

  LatLng? _pendingMoveCenter;
  double? _distanceMeters;

  bool _arrivalDialogShown = false;
  bool _arrivalDialogOpen = false;

  Timer? _routeDebounce;

  // Magic numbers as constants
  static const double _iconOffset = 65;
  static const double _truckAngleOffset = 70;
  static const double _truckUserModeOffset = 13.5;
  static const double _bottleAngleOffset = 38.7;
  static const double _autoArriveDistanceMeters = 15;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startCompassTracking();
    _getOrdersLocation();
    _getOnWayOrder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mapReady) {
        setState(() {
          _mapReady = true;
        });
        _flushPendingMove();
      }
    });
  }

  void _flushPendingMove() {
    final c = _pendingMoveCenter;
    if (c == null) return;
    _pendingMoveCenter = null;
  }

  Future<void> _getOnWayOrder() async {
    try {
      final dio = _dio;
      final preferences = _preferences;
      final courierId = preferences.readCourierId();

      if (courierId == null) return;

      final location = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _myLocation = LatLng(location.latitude, location.longitude);
      });

      final res = await dio.get(
        "/menegers/on-way-order-for-meneger-map/",
        queryParameters: {
          "lat": location.latitude,
          "lon": location.longitude,
          "menedjer_id": courierId,
        },
      );

      if (res.data["found"] == true && res.data["has_coords"] == true) {
        setState(() {
          _orderDetail = {
            "order_num": res.data["order"]["order_num"],
            "manzil": "",
            "suv_soni": "",
            ...res.data["finish"],
            "lng": res.data["finish"]["lon"],
          };
          _onWayData = {
            "order_num": res.data["order"]["order_num"],
            "manzil": "",
            "suv_soni": "",
            ...res.data["finish"],
            "lng": res.data["finish"]["lon"],
          };
          _loading = true;
          _arrivalDialogShown = false;
          _phone = "";
        });

        await _getRoute();

        setState(() {
          _onWay = true;
        });
      }
    } catch (e, stackTrace) {
      _talker.error('Failed to load on-way order', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapOnWayOrderLoadFailed,
        );
      }
    }
  }

  Future<void> _arrivedFun() async {
    setState(() {
      _loading = true;
    });

    try {
      final dio = _dio;
      final preferences = _preferences;
      final courierId = preferences.readCourierId();
      final locale = preferences.readLocale()?.languageCode ?? 'en';

      if (courierId == null) return;

      final res = await dio.post(
        "/bots/arrived-hint/",
        data: {
          "force": 0,
          "kuryer_id": courierId,
          ..._orderDetail,
          "lang": locale == "fr" ? "uz_lat" : locale,
        },
      );

      setState(() {
        _phone = res.data["phone"] ?? "";
        _loading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
      });
      _talker.error('Failed to send arrival hint', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapArrivedHintFailed,
        );
      }
    }
  }

  Future<void> _initLocation() async {
    await _requestLocationPermission();
    _startLocationTracking();
  }

  void _startCompassTracking() {
    _compassStream = FlutterCompass.events?.listen((event) {
      if (event.heading == null) return;

      final h = event.heading!;
      setState(() {
        _heading = h;
      });

      if (_mapReady && _navMode == NavMode.autoRotate) {
        try {
          _mapController.rotate(_headingFixed);
        } catch (e) {
          _talker.warning('Map rotation failed (non-critical)', e);
        }
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersLocationServiceDisabled,
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersLocationPermissionDenied,
        );
      }
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          ).ordersLocationPermissionPermanentlyDenied,
        );
      }
    }
  }

  Future<void> _setStatus() async {
    setState(() {
      _loading = true;
    });

    try {
      final dio = _dio;
      final preferences = _preferences;
      final businessId = preferences.readBusinessId();

      if (businessId == null) return;

      await dio.post(
        "/orders/mark-on-way/",
        data: {
          "business_id": businessId,
          "label": _orderDetail["order_num"],
          "ilova": "courier_ilova",
        },
      );

      setState(() {
        _onWay = true;
        _loading = false;
        _arrivalDialogShown = false;
        _phone = "";
      });
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
      });
      _talker.error('Failed to set on-way status', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapSetOnWayFailed,
        );
      }
    }
  }

  void _startLocationTracking() {
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          final latLng = LatLng(position.latitude, position.longitude);

          setState(() {
            _myLocation = latLng;
          });

          if (!_mapReady) {
            _pendingMoveCenter = latLng;
          }

          if (_isFirstLoad && _orders.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _adjustCameraToFitAllPoints();
            });
          }

          if (_ready && _onWay && _phone.isEmpty && !_arrivalDialogOpen) {
            _routeDebounce?.cancel();
            _routeDebounce = Timer(const Duration(milliseconds: 900), () {
              if (!mounted) return;
              if (_loading) return;
              _getRoute();
            });
          }
        });
  }

  Future<void> _getOrdersLocation() async {
    try {
      final dio = _dio;
      final preferences = _preferences;
      final businessId = preferences.readBusinessId();

      if (businessId == null) return;

      final res = await dio.post(
        "/boss/dispatcher-map-data/",
        data: {"business_id": businessId},
      );

      setState(() {
        _orders = res.data["orders"] ?? [];
      });

      if (_myLocation != null && _orders.isNotEmpty && _isFirstLoad) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _adjustCameraToFitAllPoints();
        });
      }
    } catch (e, stackTrace) {
      _talker.error('Failed to load orders location', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context).ordersLoadFailed);
      }
    }
  }

  void _adjustCameraToFitAllPoints() {
    if (!_isFirstLoad) return;
    if (!_mapReady) return;

    List<LatLng> allPoints = [];

    if (_myLocation != null) {
      allPoints.add(_myLocation!);
    }

    for (var order in _orders) {
      if (order["lat"] != null && order["lng"] != null) {
        allPoints.add(LatLng(order["lat"], order["lng"]));
      }
    }

    if (allPoints.length >= 2) {
      _calculateAndSetCamera(allPoints);
      _isFirstLoad = false;
    }
  }

  void _calculateAndSetCamera(List<LatLng> points) {
    if (!_mapReady) return;

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    double latDelta = maxLat - minLat;
    double lngDelta = maxLng - minLng;
    double maxDelta = max(latDelta, lngDelta);

    double zoom;
    if (maxDelta < 0.001) {
      zoom = 18.0;
    } else if (maxDelta < 0.005) {
      zoom = 16.0;
    } else if (maxDelta < 0.01) {
      zoom = 14.0;
    } else if (maxDelta < 0.02) {
      zoom = 13.0;
    } else if (maxDelta < 0.05) {
      zoom = 12.0;
    } else if (maxDelta < 0.1) {
      zoom = 11.0;
    } else {
      zoom = 10.0;
    }

    zoom -= 0.5;

    try {
      _mapController.move(center, zoom);
    } catch (e) {
      _talker.warning('Map move failed (non-critical)', e);
    }
  }

  void _fitAllMarkers() {
    if (!_mapReady) return;

    List<LatLng> allPoints = [];

    if (_myLocation != null) {
      allPoints.add(_myLocation!);
    }

    for (var order in _orders) {
      if (order["lat"] != null && order["lng"] != null) {
        allPoints.add(LatLng(order["lat"], order["lng"]));
      }
    }

    if (allPoints.length >= 2) {
      _calculateAndSetCamera(allPoints);
    } else if (allPoints.length == 1) {
      try {
        _mapController.move(allPoints[0], 15);
      } catch (e) {
        _talker.warning('Map move failed (non-critical)', e);
      }
    }
  }

  double? _extractDistanceMeters(dynamic data) {
    try {
      final r0 = data["routes"]?[0];
      final g = r0?["geometry"];
      final props = g?["properties"];
      final d1 = props?["distance"];
      if (d1 != null) return double.tryParse(d1.toString());

      final d2 = r0?["distance"];
      if (d2 != null) return double.tryParse(d2.toString());
    } catch (e) {
      _talker.warning('Failed to extract distance from route data', e);
    }
    return null;
  }

  Future<void> _maybeShowAutoArrive() async {
    if (!mounted) return;
    if (_arrivalDialogShown) return;
    if (_arrivalDialogOpen) return;
    if (!_ready || !_onWay) return;
    if (_phone.isNotEmpty) return;

    final d = _distanceMeters;
    if (d == null) return;
    if (d > _autoArriveDistanceMeters) return;

    _arrivalDialogShown = true;
    _arrivalDialogOpen = true;
    await _showArrivedModal();
    _arrivalDialogOpen = false;
  }

  Future<void> _getRoute() async {
    if (_myLocation == null) return;
    if (_orderDetail.isEmpty) return;
    if (_orderDetail["lat"] == null || _orderDetail["lng"] == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final res = await _dio.get(
        "/api/route",
        queryParameters: {
          "from": "${_myLocation!.longitude},${_myLocation!.latitude}",
          "to": "${_orderDetail["lng"]},${_orderDetail["lat"]}",
        },
      );

      final coords =
          res.data["routes"]?[0]?["geometry"]?["geometry"]?["coordinates"];
      final dist = _extractDistanceMeters(res.data);

      setState(() {
        _route = (coords is List) ? coords : [];
        _distanceMeters = dist;
        _ready = true;
        _loading = false;
      });

      await _maybeShowAutoArrive();
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
      });
      _talker.error('Failed to load route', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context).ordersRouteFailed);
      }
    }
  }

  Future<void> _getOrderData() async {
    setState(() {
      _loading = true;
    });

    try {
      final dio = _dio;
      final preferences = _preferences;
      final courierId = preferences.readCourierId();
      final businessId = preferences.readBusinessId();

      if (courierId == null || businessId == null) return;

      final res = await dio.post(
        "/orders/order-price-brief/",
        data: {
          "order_num": _orderDetail["order_num"],
          "kuryer_id": courierId,
          "business_id": businessId,
        },
      );

      setState(() {
        _orderDetailPay = res.data;
        _loading = false;
      });

      await _showInfoTableModal(res.data);
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
      });
      _talker.error('Failed to load order details', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapOrderDetailsLoadFailed,
        );
      }
    }
  }

  Future<void> _completeOrder() async {
    setState(() {
      _loading = true;
    });

    try {
      final dio = _dio;
      final preferences = _preferences;
      final businessId = preferences.readBusinessId();

      if (businessId == null) return;

      await dio.post(
        "/orders/complete/",
        data: {
          "business_id": businessId,
          "label": _orderDetail["order_num"],
          "ilova": "courier_ilova",
          "order_num": _orderDetail["order_num"],
          "suv_soni": _orderDetailPay["suv_soni"],
          "sotilgan_tara_soni": _orderDetailPay["sotilgan_tara_soni"],
          "summa": _orderDetailPay["summa_jami"],
        },
      );

      setState(() {
        _loading = false;
        _orderDetail = {};
        _orderDetailPay = {};
        _showDetail = false;
        _ready = false;
        _onWay = false;
        _route = [];
        _onWayData = {};
        _phone = "";
        _distanceMeters = null;
        _arrivalDialogShown = false;
        _arrivalDialogOpen = false;
      });

      _getOrdersLocation();
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
      });
      _talker.error('Failed to complete order', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapCompleteOrderFailed,
        );
      }
    }
  }

  Future<void> _openCallApp(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception("Call app failed to open");
      }
    } catch (e, stackTrace) {
      _talker.error('Failed to open call app', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).ordersMapOpenCallFailed,
        );
      }
    }
  }

  void _setNavMode(NavMode mode) {
    if (_navMode == mode) return;
    setState(() {
      _navMode = mode;
    });

    if (_mapReady && _navMode == NavMode.autoRotate) {
      try {
        _mapController.rotate(-_heading);
      } catch (e) {
        _talker.warning('Map rotation failed (non-critical)', e);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double get _headingFixed {
    final h = -_heading;
    return h + _iconOffset;
  }

  Future<void> _showArrivedModal() async {
    int seconds = 10;
    Timer? timer;
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (seconds == 0) {
                t.cancel();
                Navigator.of(dialogContext).pop();
              } else {
                setState(() {
                  seconds--;
                });
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.ordersMapArrivedDialogTitle,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.ordersMapArrivedAutoClose(seconds),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            timer?.cancel();
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            l10n.commonNo,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            timer?.cancel();
                            _arrivedFun();
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            l10n.commonYes,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    timer?.cancel();
  }

  Future<void> _showInfoTableModal(Map<String, dynamic> data) async {
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.ordersMapOrderDetailsTitle,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _TableRowItem(
                      title: l10n.ordersMapWaterPriceLabel,
                      value: data["suv_summasi"]?.toString() ?? "0",
                    ),
                    const _Divider(),
                    _TableRowItem(
                      title: l10n.ordersMapWaterLabel,
                      value: data["suv_soni"]?.toString() ?? "0",
                    ),
                    const _Divider(),
                    _TableRowItem(
                      title: l10n.ordersMapSoldBottleLabel,
                      value: data["sotilgan_tara_soni"]?.toString() ?? "0",
                    ),
                    const _Divider(),
                    _TableRowItem(
                      title: l10n.ordersMapTotalLabel,
                      value: data["summa_jami"]?.toString() ?? "0",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _completeOrder();
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      data["tulov_onlinemi"] == true
                          ? l10n.ordersMapPaymentAcceptedOnline
                          : l10n.ordersMapAcceptPayment,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      l10n.commonBack,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConfirmDialog(String title, VoidCallback onConfirm) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonNo),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonYes),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headingRad = _heading * pi / 180;
    final bottleAngle = -(_mapRotDeg * pi / 180);
    final truckAngleUserMode = headingRad - _truckUserModeOffset;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersMapTitle)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation ?? const LatLng(38.859444, 65.794444),
              initialZoom: 15,
              maxZoom: 19,
              onMapReady: () {
                if (_mapReady) return;
                setState(() => _mapReady = true);
                _flushPendingMove();
              },
              onPositionChanged: (pos, hasGesture) {
                _mapRotDeg = pos.rotation;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: "com.suvkerak.courier",
                retinaMode: RetinaMode.isHighDensity(context),
                maxNativeZoom: 19,
                maxZoom: 19,
                additionalOptions: const {'id': 'mapbox.streets'},
                tileProvider: NetworkTileProvider(),
                errorImage: const AssetImage('assets/images/app_icon.png'),
              ),
              const MapCompass.cupertino(hideIfRotatedNorth: true),
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 50,
                      height: 70,
                      child: Transform.rotate(
                        angle: (_navMode == NavMode.userRotate)
                            ? truckAngleUserMode
                            : (headingRad - _truckAngleOffset),
                        child: Image.asset(
                          "assets/images/flags/truck.png",
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.local_shipping),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_orders.isNotEmpty)
                MarkerLayer(
                  markers: _orders
                      .map(
                        (e) => Marker(
                          point: LatLng(e["lat"], e["lng"]),
                          width: 200,
                          height: 100,
                          child: InkWell(
                            onTap: () {
                              if (!_ready) {
                                setState(() {
                                  _orderDetail = e;
                                  _showDetail = true;
                                  _onWayData = {};
                                  _phone = "";
                                  _arrivalDialogShown = false;
                                });
                              }
                            },
                            child: Transform.rotate(
                              angle: (_navMode != NavMode.userRotate)
                                  ? headingRad - _bottleAngleOffset
                                  : bottleAngle,
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      e["order_num"]?.toString() ?? "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Image.asset(
                                    width: 20,
                                    "assets/images/flags/bottle.png",
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.location_on),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              if (_onWayData.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_onWayData["lat"], _onWayData["lng"]),
                      width: 200,
                      height: 100,
                      child: Transform.rotate(
                        angle: (_navMode != NavMode.userRotate)
                            ? headingRad - _bottleAngleOffset
                            : bottleAngle,
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                _onWayData["order_num"]?.toString() ?? "",
                                style: const TextStyle(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Image.asset(
                              width: 20,
                              "assets/images/flags/bottle.png",
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.location_on),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      strokeWidth: 4,
                      points: _route.map((e) => LatLng(e[1], e[0])).toList(),
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          if (_myLocation != null && _orders.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: _fitAllMarkers,
                    mini: true,
                    child: const Icon(Icons.zoom_out_map),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          color: Color(0x22000000),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _setNavMode(NavMode.autoRotate),
                          icon: Icon(
                            Icons.explore,
                            color: _navMode == NavMode.autoRotate
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _setNavMode(NavMode.userRotate),
                          icon: Icon(
                            Icons.touch_app,
                            color: _navMode == NavMode.userRotate
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!_ready)
            Positioned(
              bottom: 16,
              left: 10,
              right: 70,
              child: Opacity(
                opacity: _showDetail ? 1 : 0.7,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (!_showDetail) return;
                    _getRoute();
                  },
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          _showDetail
                              ? l10n.ordersMapTakeOrder(
                                  _orderDetail["order_num"]?.toString() ?? '',
                                )
                              : l10n.ordersMapSelectOrder,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
          if (_ready && _phone == "")
            Positioned(
              bottom: 16,
              left: 10,
              right: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_onWay) {
                    _arrivalDialogOpen = true;
                    await _showArrivedModal();
                    _arrivalDialogOpen = false;
                    return;
                  }
                  await _setStatus();
                },
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        _onWay
                            ? l10n.ordersMapArrivedButton(
                                _orderDetail["order_num"]?.toString() ?? '',
                              )
                            : l10n.ordersMapOnWayButton,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          if (_ready && _phone.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 10,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmDialog(
                        l10n.ordersMapConfirmCompletedTitle,
                        _getOrderData,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.ordersMapFoundButton,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _openCallApp(_phone);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.ordersMapNotFoundButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          if (_showDetail)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _orderDetail["manzil"] ?? "",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.ordersMapOrderSummary(
                        _orderDetail["order_num"]?.toString() ?? '',
                        _orderDetail["suv_soni"]?.toString() ?? '',
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  final String title;
  final String value;

  const _TableRowItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey.shade300);
  }
}
