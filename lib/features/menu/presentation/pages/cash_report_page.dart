import 'package:flutter/material.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/date_range_card.dart';
import 'cash_report_models.dart';

class CashReportPage extends StatefulWidget {
  const CashReportPage({super.key});

  @override
  State<CashReportPage> createState() => _CashReportPageState();
}

class _CashReportPageState extends State<CashReportPage>
    with ErrorHandlingMixin<CashReportPage> {
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
      showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (range.end.isBefore(range.start)) {
      showToast(l10n.cashReportValidationOrder);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuCashReport),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: ResponsiveSpacing.pagePadding(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            DateRangeCard(
              title: l10n.cashReportPeriodicTitle,
              icon: Icons.payments_outlined,
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _periodStart,
              endDate: _periodEnd,
              dateFormat: dateFormat,
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
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            DateRangeCard(
              title: l10n.cashReportOnlineTitle,
              icon: Icons.credit_card_outlined,
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _onlineStart,
              endDate: _onlineEnd,
              dateFormat: dateFormat,
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
      ),
    );
  }
}
