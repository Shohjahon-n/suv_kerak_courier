import 'package:flutter/material.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/date_range_card.dart';
import 'bottle_balance_models.dart';

class BottleBalancePage extends StatefulWidget {
  const BottleBalancePage({super.key});

  @override
  State<BottleBalancePage> createState() => _BottleBalancePageState();
}

class _BottleBalancePageState extends State<BottleBalancePage>
    with ErrorHandlingMixin<BottleBalancePage> {
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
      showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (range.end.isBefore(range.start)) {
      showToast(l10n.cashReportValidationOrder);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuBottleBalance),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: ResponsiveSpacing.pagePadding(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            DateRangeCard(
              title: l10n.bottleBalanceEmptyPeriodicTitle,
              icon: Icons.inventory_2_outlined,
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _emptyStart,
              endDate: _emptyEnd,
              dateFormat: dateFormat,
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
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            DateRangeCard(
              title: l10n.bottleBalanceFullWaterPeriodicTitle,
              icon: Icons.water_drop_outlined,
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _fullStart,
              endDate: _fullEnd,
              dateFormat: dateFormat,
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
      ),
    );
  }
}
