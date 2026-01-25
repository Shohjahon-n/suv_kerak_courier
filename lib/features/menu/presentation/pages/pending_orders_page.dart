import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/status_message_card.dart';
import '../widgets/order_cards.dart';
import 'pending_orders_models.dart';

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage>
    with ErrorHandlingMixin<PendingOrdersPage> {
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _error;
  PendingOrdersResponse? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) {
      return;
    }
    _hasLoaded = true;
    _load();
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final preferences = context.read<AppPreferences>();
    final businessId = preferences.readBusinessId();
    if (businessId == null) {
      setState(() {
        _error = l10n.ordersSessionMissing;
        _data = null;
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
        ApiEndpoints.pendingOrders,
        data: {'business_id': businessId},
      );
      final data = response.data;
      PendingOrdersResponse? result;
      String? errorMessage;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = stringValue(map, 'detail');
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
        _data = result;
      });
    } on DioException catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.ordersLoadFailed,
      );
      setState(() {
        _isLoading = false;
        _error = extractErrorDetail(error) ?? l10n.ordersLoadFailed;
        _data = null;
      });
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.ordersLoadFailed,
      );
      setState(() {
        _isLoading = false;
        _error = l10n.ordersLoadFailed;
        _data = null;
      });
    }
  }

  Future<void> _handleAccept(PendingOrderItem item) async {
    final l10n = AppLocalizations.of(context);
    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();

    if (courierId == null) {
      showToast(l10n.ordersSessionMissing);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ordersAcceptTitle),
        content: Text(l10n.ordersAcceptConfirm(item.orderNumber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        ApiEndpoints.markOnWay,
        data: {
          'business_id': courierId,
          'label': item.orderNumber,
          'ilova': ApiEndpoints.appIdentifier,
        },
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      final data = response.data;
      if (data is Map) {
        final ok = data['ok'];
        final detail = stringValue(data, 'detail');

        if (ok == true) {
          showToast(l10n.ordersAcceptSuccess);
          // Reload the orders list
          await _load();
        } else {
          showToast(detail ?? l10n.ordersAcceptFailed);
        }
      } else {
        showToast(l10n.ordersAcceptFailed);
      }
    } on DioException catch (error, stackTrace) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.ordersAcceptFailed,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.ordersAcceptFailed,
        showSnackbar: true,
      );
    }
  }

  Future<void> _handleCallCustomer(PendingOrderItem item) async {
    final l10n = AppLocalizations.of(context);
    final phoneNumber = item.buyerPhone.trim();

    if (phoneNumber.isEmpty) {
      showToast(l10n.ordersPhoneNotAvailable);
      return;
    }

    final uri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        showToast(l10n.ordersCallAppFailed);
      }
    } catch (e) {
      if (!mounted) return;
      showToast(l10n.ordersCallAppFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersPendingTitle)),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: _buildSlivers(context, l10n),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat('#,##0', locale.toString());
    final padding = ResponsiveSpacing.pagePadding(context);

    if (_isLoading && _data == null) {
      return [
        SliverPadding(
          padding: padding,
          sliver: const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (_error != null) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: StatusMessageCard(
              icon: Icons.info_outline,
              message: _error!,
              actionLabel: l10n.cashReportRetry,
              onAction: _load,
            ),
          ),
        ),
      ];
    }

    if (_data == null || _data!.items.isEmpty) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: StatusMessageCard(
              icon: Icons.inbox_outlined,
              message: l10n.ordersEmptyState,
              actionLabel: l10n.cashReportRetry,
              onAction: _load,
            ),
          ),
        ),
      ];
    }

    final data = _data!;
    final headerWidgets = <Widget>[
      SectionTitle(title: l10n.ordersSummaryTitle),
      SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.push('/orders/map'),
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.ordersMapButton),
        ),
      ),
      SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
      AdaptiveGrid(
        minItemWidth: 145,
        baseChildAspectRatio: 1.55,
        crossAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
        mainAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
        children: [
          OrderSummaryCard(
            title: l10n.ordersCountLabel,
            value: numberFormat.format(data.count),
            icon: Icons.list_alt_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
          OrderSummaryCard(
            title: l10n.ordersTotalWaterLabel,
            value: numberFormat.format(data.totalWaterCount),
            icon: Icons.water_drop_outlined,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
      SizedBox(height: ResponsiveSpacing.verticalSpacing(context, base: 20)),
      SectionTitle(title: l10n.menuOrders),
      SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
    ];

    final slivers = <Widget>[
      SliverPadding(
        padding: padding,
        sliver: SliverList(delegate: SliverChildListDelegate(headerWidgets)),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          0,
          padding.right,
          padding.bottom,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = data.items[index];
            return OrderCard(
              item: item,
              l10n: l10n,
              numberFormat: numberFormat,
              onAccept: () => _handleAccept(item),
              onCall: () => _handleCallCustomer(item),
            );
          }, childCount: data.items.length),
        ),
      ),
    ];

    if (_isLoading) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
            ),
            child: LinearProgressIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer,
            ),
          ),
        ),
      );
    }

    return slivers;
  }
}
