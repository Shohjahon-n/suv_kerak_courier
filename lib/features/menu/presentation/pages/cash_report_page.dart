import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import 'cash_report_models.dart';

class CashReportPage extends StatefulWidget {
  const CashReportPage({super.key});

  @override
  State<CashReportPage> createState() => _CashReportPageState();
}

class _CashReportPageState extends State<CashReportPage> {
  DateTime? _periodStart;
  DateTime? _periodEnd;
  DateTime? _onlineStart;
  DateTime? _onlineEnd;

  Future<void> _pickDate({
    required CashReportKind kind,
    required bool isStart,
  }) async {
    final now = DateTime.now();
    final initialDate = _currentDate(kind, isStart) ?? now;
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
      if (kind == CashReportKind.periodic) {
        if (isStart) {
          _periodStart = picked;
        } else {
          _periodEnd = picked;
        }
      } else {
        if (isStart) {
          _onlineStart = picked;
        } else {
          _onlineEnd = picked;
        }
      }
    });
  }

  DateTime? _currentDate(CashReportKind kind, bool isStart) {
    if (kind == CashReportKind.periodic) {
      return isStart ? _periodStart : _periodEnd;
    }
    return isStart ? _onlineStart : _onlineEnd;
  }

  void _openReport(CashReportKind kind) {
    final l10n = AppLocalizations.of(context);
    final range = _rangeFor(kind);
    if (range == null) {
      _showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (range.end.isBefore(range.start)) {
      _showToast(l10n.cashReportValidationOrder);
      return;
    }
    final request = CashReportRequest(kind: kind, range: range);
    final path = kind == CashReportKind.periodic
        ? '/cash-report/periodic'
        : '/cash-report/online';
    context.push(path, extra: request);
  }

  DateTimeRange? _rangeFor(CashReportKind kind) {
    if (kind == CashReportKind.periodic) {
      if (_periodStart == null || _periodEnd == null) {
        return null;
      }
      return DateTimeRange(start: _periodStart!, end: _periodEnd!);
    }
    if (_onlineStart == null || _onlineEnd == null) {
      return null;
    }
    return DateTimeRange(start: _onlineStart!, end: _onlineEnd!);
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
        title: Text(l10n.menuCashReport),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ReportSectionCard(
            title: l10n.cashReportPeriodicTitle,
            icon: Icons.payments_outlined,
            startLabel: l10n.cashReportStartDate,
            endLabel: l10n.cashReportEndDate,
            pickLabel: l10n.cashReportPickDate,
            startDate: _periodStart,
            endDate: _periodEnd,
            dateFormat: dateFormat,
            colorScheme: colorScheme,
            onPickStart: () => _pickDate(
              kind: CashReportKind.periodic,
              isStart: true,
            ),
            onPickEnd: () => _pickDate(
              kind: CashReportKind.periodic,
              isStart: false,
            ),
            onSubmit: (_periodStart != null && _periodEnd != null)
                ? () => _openReport(CashReportKind.periodic)
                : null,
            submitLabel: l10n.cashReportShow,
          ),
          const SizedBox(height: 20),
          _ReportSectionCard(
            title: l10n.cashReportOnlineTitle,
            icon: Icons.credit_card_outlined,
            startLabel: l10n.cashReportStartDate,
            endLabel: l10n.cashReportEndDate,
            pickLabel: l10n.cashReportPickDate,
            startDate: _onlineStart,
            endDate: _onlineEnd,
            dateFormat: dateFormat,
            colorScheme: colorScheme,
            onPickStart: () => _pickDate(
              kind: CashReportKind.onlinePayments,
              isStart: true,
            ),
            onPickEnd: () => _pickDate(
              kind: CashReportKind.onlinePayments,
              isStart: false,
            ),
            onSubmit: (_onlineStart != null && _onlineEnd != null)
                ? () => _openReport(CashReportKind.onlinePayments)
                : null,
            submitLabel: l10n.cashReportShow,
          ),
        ],
      ),
    );
  }
}

class _ReportSectionCard extends StatelessWidget {
  const _ReportSectionCard({
    required this.title,
    required this.icon,
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

  final String title;
  final IconData icon;
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DateField(
            label: startLabel,
            value: startDate == null ? pickLabel : dateFormat.format(startDate!),
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
