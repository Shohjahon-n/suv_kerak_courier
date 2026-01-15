import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import 'pending_orders_models.dart';

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage> {
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
        _data = result;
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = _extractErrorDetail(error) ?? l10n.ordersLoadFailed;
        _data = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = l10n.ordersLoadFailed;
        _data = null;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersPendingTitle),
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat('#,##0', locale.toString());

    final content = <Widget>[];

    if (_isLoading && _data == null) {
      content.addAll([
        const SizedBox(height: 40),
        const Center(child: CircularProgressIndicator()),
      ]);
    } else if (_error != null) {
      content.add(
        _MessageCard(
          icon: Icons.info_outline,
          message: _error!,
          onRetry: _load,
          retryLabel: l10n.cashReportRetry,
        ),
      );
    } else if (_data == null || _data!.items.isEmpty) {
      content.add(
        _MessageCard(
          icon: Icons.inbox_outlined,
          message: l10n.ordersEmptyState,
          onRetry: _load,
          retryLabel: l10n.cashReportRetry,
        ),
      );
    } else {
      final data = _data!;
      content.addAll([
        _SectionTitle(title: l10n.ordersSummaryTitle),
        const SizedBox(height: 8),
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
            _SummaryCard(
              title: l10n.ordersCountLabel,
              value: numberFormat.format(data.count),
              icon: Icons.list_alt_outlined,
              background: colorScheme.primaryContainer,
              foreground: colorScheme.onPrimaryContainer,
            ),
            _SummaryCard(
              title: l10n.ordersTotalWaterLabel,
              value: numberFormat.format(data.totalWaterCount),
              icon: Icons.water_drop_outlined,
              background: colorScheme.secondaryContainer,
              foreground: colorScheme.onSecondaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: l10n.menuOrders),
        const SizedBox(height: 12),
        ...data.items.map(
          (item) => _OrderCard(
            item: item,
            l10n: l10n,
            numberFormat: numberFormat,
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer,
            ),
          ),
      ]);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: ResponsiveSpacing.pagePadding(context),
        physics: const AlwaysScrollableScrollPhysics(),
        children: content,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final padding = ResponsiveSpacing.cardPadding(context);
    final radius = ResponsiveSpacing.borderRadius(context, base: 16);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: ResponsiveSpacing.iconSize(context, base: 22)),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: foreground.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.l10n,
    required this.numberFormat,
  });

  final PendingOrderItem item;
  final AppLocalizations l10n;
  final NumberFormat numberFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = _buildDateLabel();
    final waterLabel = numberFormat.format(item.waterCount);
    final location = item.parseLocation();
    final locationLabel = location?.format();
    final note = item.note.trim().isEmpty ? l10n.notAvailable : item.note;
    final status = item.paymentStatus.trim().isEmpty
        ? l10n.notAvailable
        : item.paymentStatus;

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.spacing(context, base: 12)),
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderHeader(
            label: '${l10n.ordersOrderIdLabel}: '
                '${item.orderNumber.isEmpty ? l10n.notAvailable : item.orderNumber}',
            countLabel: l10n.ordersWaterCountLabel,
            countValue: waterLabel,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.person_outline,
            label: l10n.ordersBuyerIdLabel,
            value: item.buyerId == 0
                ? l10n.notAvailable
                : numberFormat.format(item.buyerId),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.ordersNoteLabel,
            value: note,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: l10n.ordersPaymentStatusLabel,
            value: status,
          ),
          if (locationLabel != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.place_outlined,
              label: l10n.ordersLocationLabel,
              value: locationLabel,
            ),
          ],
        ],
      ),
    );
  }

  String _buildDateLabel() {
    final date = item.orderDate.isEmpty ? l10n.notAvailable : item.orderDate;
    final time = item.orderTime.trim();
    if (time.isEmpty) {
      return date;
    }
    return '$date · $time';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return KeyValueRow(
      icon: icon,
      label: label,
      value: value,
      iconColor: colorScheme.onSurfaceVariant,
      labelStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      valueStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.label,
    required this.countLabel,
    required this.countValue,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String countLabel;
  final String countValue;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 280 || textScale >= 1.25;
        final title = Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        );

        final leading = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(child: title),
          ],
        );

        final pill = _CountPill(
          label: countLabel,
          value: countValue,
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: pill),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(child: title),
            pill,
          ],
        );
      },
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foreground.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
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
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
