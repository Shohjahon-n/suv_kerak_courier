import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import 'bottle_balance_models.dart';

class BottleBalancePage extends StatefulWidget {
  const BottleBalancePage({super.key});

  @override
  State<BottleBalancePage> createState() => _BottleBalancePageState();
}

class _BottleBalancePageState extends State<BottleBalancePage> {
  DateTime? _emptyStart;
  DateTime? _emptyEnd;
  DateTime? _fullStart;
  DateTime? _fullEnd;

  Future<void> _pickDate({
    required BottleBalanceKind kind,
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
      if (kind == BottleBalanceKind.emptyBottles) {
        if (isStart) {
          _emptyStart = picked;
        } else {
          _emptyEnd = picked;
        }
      } else {
        if (isStart) {
          _fullStart = picked;
        } else {
          _fullEnd = picked;
        }
      }
    });
  }

  DateTime? _currentDate(BottleBalanceKind kind, bool isStart) {
    if (kind == BottleBalanceKind.emptyBottles) {
      return isStart ? _emptyStart : _emptyEnd;
    }
    return isStart ? _fullStart : _fullEnd;
  }

  void _openReport(BottleBalanceKind kind) {
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
    final request = BottleBalanceRequest(kind: kind, range: range);
    final path = kind == BottleBalanceKind.emptyBottles
        ? '/bottle-balance/empty'
        : '/bottle-balance/full-water';
    context.push(path, extra: request);
  }

  DateTimeRange? _rangeFor(BottleBalanceKind kind) {
    if (kind == BottleBalanceKind.emptyBottles) {
      if (_emptyStart == null || _emptyEnd == null) {
        return null;
      }
      return DateTimeRange(start: _emptyStart!, end: _emptyEnd!);
    }
    if (_fullStart == null || _fullEnd == null) {
      return null;
    }
    return DateTimeRange(start: _fullStart!, end: _fullEnd!);
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
        title: Text(l10n.menuBottleBalance),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _BalanceSectionCard(
            title: l10n.bottleBalanceEmptyPeriodicTitle,
            icon: Icons.inventory_2_outlined,
            startLabel: l10n.cashReportStartDate,
            endLabel: l10n.cashReportEndDate,
            pickLabel: l10n.cashReportPickDate,
            startDate: _emptyStart,
            endDate: _emptyEnd,
            dateFormat: dateFormat,
            colorScheme: colorScheme,
            onPickStart: () => _pickDate(
              kind: BottleBalanceKind.emptyBottles,
              isStart: true,
            ),
            onPickEnd: () => _pickDate(
              kind: BottleBalanceKind.emptyBottles,
              isStart: false,
            ),
            onSubmit: (_emptyStart != null && _emptyEnd != null)
                ? () => _openReport(BottleBalanceKind.emptyBottles)
                : null,
            submitLabel: l10n.cashReportShow,
          ),
          const SizedBox(height: 20),
          _BalanceSectionCard(
            title: l10n.bottleBalanceFullWaterPeriodicTitle,
            icon: Icons.water_drop_outlined,
            startLabel: l10n.cashReportStartDate,
            endLabel: l10n.cashReportEndDate,
            pickLabel: l10n.cashReportPickDate,
            startDate: _fullStart,
            endDate: _fullEnd,
            dateFormat: dateFormat,
            colorScheme: colorScheme,
            onPickStart: () => _pickDate(
              kind: BottleBalanceKind.fullWater,
              isStart: true,
            ),
            onPickEnd: () => _pickDate(
              kind: BottleBalanceKind.fullWater,
              isStart: false,
            ),
            onSubmit: (_fullStart != null && _fullEnd != null)
                ? () => _openReport(BottleBalanceKind.fullWater)
                : null,
            submitLabel: l10n.cashReportShow,
          ),
        ],
      ),
    );
  }
}

class _BalanceSectionCard extends StatelessWidget {
  const _BalanceSectionCard({
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
