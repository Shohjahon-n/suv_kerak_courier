import 'package:flutter/material.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/date_range_card.dart';
import '../../../../shared/widgets/section_title.dart';
import 'delivered_orders_models.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with ErrorHandlingMixin<OrdersPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (!mounted) {
      return;
    }
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _showReport() {
    final l10n = AppLocalizations.of(context);
    if (_startDate == null || _endDate == null) {
      showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      showToast(l10n.cashReportValidationOrder);
      return;
    }
    final range = DateTimeRange(start: _startDate!, end: _endDate!);
    context.push(
      '/orders/delivered-range',
      extra: DeliveredOrdersRequest(range: range),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuOrders),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: ResponsiveSpacing.pagePadding(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SectionTitle(title: l10n.ordersQuickActionsTitle),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            _ActionCard(
              title: l10n.ordersPendingButton,
              icon: Icons.pending_actions_outlined,
              background: colorScheme.primaryContainer,
              foreground: colorScheme.onPrimaryContainer,
              onTap: () => context.push('/orders/pending'),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            _ActionCard(
              title: l10n.ordersCompletedTodayButton,
              icon: Icons.task_alt_outlined,
              background: colorScheme.secondaryContainer,
              foreground: colorScheme.onSecondaryContainer,
              onTap: () => context.push('/orders/delivered-today'),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            _ActionCard(
              title: l10n.ordersMapButton,
              icon: Icons.map_outlined,
              background: colorScheme.tertiaryContainer,
              foreground: colorScheme.onTertiaryContainer,
              onTap: () => context.push('/orders/map'),
            ),
            SizedBox(height: ResponsiveSpacing.verticalSpacing(context, base: 24)),
            SectionTitle(title: l10n.ordersPeriodicReportTitle),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            DateRangeCard(
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _startDate,
              endDate: _endDate,
              dateFormat: dateFormat,
              onPickStart: () => _pickDate(isStart: true),
              onPickEnd: () => _pickDate(isStart: false),
              onSubmit: (_startDate != null && _endDate != null)
                  ? _showReport
                  : null,
              submitLabel: l10n.cashReportShow,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveSpacing.borderRadius(context, base: 18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: ResponsiveSpacing.largePadding(context),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveSpacing.spacing(context, base: 10),
                ),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    ResponsiveSpacing.borderRadius(context, base: 14),
                  ),
                ),
                child: Icon(
                  icon,
                  color: foreground,
                  size: ResponsiveSpacing.iconSize(context, base: 22),
                ),
              ),
              SizedBox(width: ResponsiveSpacing.spacing(context, base: 12)),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: foreground,
                size: ResponsiveSpacing.iconSize(context, base: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
