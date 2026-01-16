import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../pages/delivered_today_models.dart';
import '../pages/pending_orders_models.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
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
    return Container(
      padding: ResponsiveSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: foreground,
            size: ResponsiveSpacing.iconSize(context, base: 22),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: foreground.withValues(alpha: 0.8),
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

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
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
      margin: EdgeInsets.only(
        bottom: ResponsiveSpacing.spacing(context, base: 12),
      ),
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 16),
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderHeader(
            label:
                '${l10n.ordersOrderIdLabel}: '
                '${item.orderNumber.isEmpty ? l10n.notAvailable : item.orderNumber}',
            countLabel: l10n.ordersWaterCountLabel,
            countValue: waterLabel,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            dateLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
          _OrderInfoRow(
            icon: Icons.person_outline,
            label: l10n.ordersBuyerIdLabel,
            value: item.buyerId == 0
                ? l10n.notAvailable
                : numberFormat.format(item.buyerId),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          _OrderInfoRow(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.ordersNoteLabel,
            value: note,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          _OrderInfoRow(
            icon: Icons.payments_outlined,
            label: l10n.ordersPaymentStatusLabel,
            value: status,
          ),
          if (locationLabel != null) ...[
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
            _OrderInfoRow(
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
    const separator = ' \u00b7 ';
    return '$date$separator$time';
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({
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
      valueStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
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
              size: ResponsiveSpacing.iconSize(context, base: 18),
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ResponsiveSpacing.spacing(context, base: 8)),
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
              SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
              Align(alignment: Alignment.centerRight, child: pill),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: ResponsiveSpacing.iconSize(context, base: 18),
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ResponsiveSpacing.spacing(context, base: 8)),
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
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSpacing.spacing(context, base: 10),
        vertical: ResponsiveSpacing.spacing(context, base: 6),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foreground.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 2)),
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

class DeliveredTodayOrderCard extends StatelessWidget {
  const DeliveredTodayOrderCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.numberFormat,
  });

  final DeliveredTodayItem item;
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
    final courierName = item.courierName.trim().isEmpty
        ? l10n.notAvailable
        : item.courierName;
    final courierPhone = item.courierPhone.trim().isEmpty
        ? l10n.notAvailable
        : item.courierPhone;

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveSpacing.spacing(context, base: 12),
      ),
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 16),
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderHeader(
            label:
                '${l10n.ordersOrderIdLabel}: '
                '${item.orderNumber.isEmpty ? l10n.notAvailable : item.orderNumber}',
            countLabel: l10n.ordersWaterCountLabel,
            countValue: waterLabel,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            dateLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
          _OrderInfoRow(
            icon: Icons.person_outline,
            label: l10n.ordersBuyerIdLabel,
            value: item.buyerId == 0
                ? l10n.notAvailable
                : numberFormat.format(item.buyerId),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          _OrderInfoRow(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.ordersNoteLabel,
            value: note,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          _OrderInfoRow(
            icon: Icons.payments_outlined,
            label: l10n.ordersPaymentStatusLabel,
            value: status,
          ),
          if (locationLabel != null) ...[
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
            _OrderInfoRow(
              icon: Icons.place_outlined,
              label: l10n.ordersLocationLabel,
              value: locationLabel,
            ),
          ],
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          _OrderInfoRow(
            icon: Icons.delivery_dining_outlined,
            label: l10n.ordersCourierLabel,
            value: courierName,
          ),
          if (courierPhone != l10n.notAvailable) ...[
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
            _OrderInfoRow(
              icon: Icons.phone_outlined,
              label: l10n.loginCourierIdLabel,
              value: courierPhone,
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
    const separator = ' \u00b7 ';
    return '$date$separator$time';
  }
}
