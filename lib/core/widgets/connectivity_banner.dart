import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';

import 'responsive_spacing.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _results = const [];
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateResults);
  }

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateResults(results);
  }

  void _updateResults(List<ConnectivityResult> results) {
    if (!mounted) {
      return;
    }
    setState(() {
      _hasChecked = true;
      _results = results;
    });
  }

  bool get _isOffline {
    if (!_hasChecked) {
      return false;
    }
    return _results.isEmpty || _results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _OfflineBanner(
      message: AppLocalizations.of(context).offlineRetryMessage,
    );

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: ResponsiveSpacing.spacing(context, base: 16),
          right: ResponsiveSpacing.spacing(context, base: 16),
          bottom: ResponsiveSpacing.spacing(context, base: 16),
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: _isOffline ? Offset.zero : const Offset(0, 0.3),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isOffline ? 1 : 0,
                child: IgnorePointer(ignoring: true, child: banner),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      elevation: 3,
      borderRadius: BorderRadius.circular(
        ResponsiveSpacing.borderRadius(context, base: 16),
      ),
      child: Padding(
        padding: ResponsiveSpacing.largePadding(context),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: colorScheme.onErrorContainer),
            SizedBox(width: ResponsiveSpacing.spacing(context, base: 12)),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
