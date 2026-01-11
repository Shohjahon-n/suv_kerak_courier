import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import 'delivered_orders_models.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
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
      _showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showToast(l10n.cashReportValidationOrder);
      return;
    }
    final range = DateTimeRange(start: _startDate!, end: _endDate!);
    context.push(
      '/orders/delivered-range',
      extra: DeliveredOrdersRequest(range: range),
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
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuOrders),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(title: l10n.ordersQuickActionsTitle),
          const SizedBox(height: 12),
          _ActionCard(
            title: l10n.ordersPendingButton,
            icon: Icons.pending_actions_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
            onTap: () => context.push('/orders/pending'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: l10n.ordersCompletedTodayButton,
            icon: Icons.task_alt_outlined,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
            onTap: () => _showToast(l10n.comingSoon),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: l10n.ordersMapButton,
            icon: Icons.map_outlined,
            background: colorScheme.tertiaryContainer,
            foreground: colorScheme.onTertiaryContainer,
            onTap: () => context.push('/orders/map'),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.ordersPeriodicReportTitle),
          const SizedBox(height: 12),
          _ReportCard(
            startLabel: l10n.cashReportStartDate,
            endLabel: l10n.cashReportEndDate,
            pickLabel: l10n.cashReportPickDate,
            startDate: _startDate,
            endDate: _endDate,
            dateFormat: dateFormat,
            colorScheme: colorScheme,
            onPickStart: () => _pickDate(isStart: true),
            onPickEnd: () => _pickDate(isStart: false),
            onSubmit: (_startDate != null && _endDate != null)
                ? _showReport
                : null,
            submitLabel: l10n.cashReportShow,
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: foreground.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.startLabel,
    required this.endLabel,
    required this.pickLabel,
    required this.startDate,
    required this.endDate,
    required this.dateFormat,
    required this.colorScheme,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String startLabel;
  final String endLabel;
  final String pickLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateFormat dateFormat;
  final ColorScheme colorScheme;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateField(
            label: startLabel,
            value:
                startDate == null ? pickLabel : dateFormat.format(startDate!),
            onTap: onPickStart,
          ),
          const SizedBox(height: 12),
          _DateField(
            label: endLabel,
            value: endDate == null ? pickLabel : dateFormat.format(endDate!),
            onTap: onPickEnd,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.arrow_forward),
              label: Text(submitLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
