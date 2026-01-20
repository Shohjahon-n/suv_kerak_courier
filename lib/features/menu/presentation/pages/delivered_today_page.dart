import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/status_message_card.dart';
import '../widgets/order_cards.dart';
import 'delivered_today_models.dart';

class DeliveredTodayPage extends StatefulWidget {
  const DeliveredTodayPage({super.key});

  @override
  State<DeliveredTodayPage> createState() => _DeliveredTodayPageState();
}

class _DeliveredTodayPageState extends State<DeliveredTodayPage>
    with ErrorHandlingMixin<DeliveredTodayPage> {
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _error;
  DeliveredTodayResponse? _data;

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
    final courierId = preferences.readCourierId();
    if (businessId == null || courierId == null) {
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
        '/orders/delivered-today-for-courier/',
        data: {'business_id': businessId, 'kuryer_id': courierId},
      );
      final data = response.data;
      DeliveredTodayResponse? result;
      String? errorMessage;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = stringValue(map, 'detail');
        final ok = map['ok'];
        if (ok == false && detail != null) {
          errorMessage = detail;
        } else {
          result = DeliveredTodayResponse.fromJson(map);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersCompletedTodayButton)),
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
            return DeliveredTodayOrderCard(
              item: item,
              l10n: l10n,
              numberFormat: numberFormat,
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
