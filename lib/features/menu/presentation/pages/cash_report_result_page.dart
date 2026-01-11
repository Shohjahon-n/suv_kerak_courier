import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:suv_kerak_courier/core/constants/app_constants.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import 'cash_report_models.dart';

class CashReportResultPage extends StatefulWidget {
  const CashReportResultPage({super.key, required this.request});

  final CashReportRequest? request;

  @override
  State<CashReportResultPage> createState() => _CashReportResultPageState();
}

class _CashReportResultPageState extends State<CashReportResultPage> {
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _error;
  CashPeriodReport? _periodReport;
  OnlinePaymentReport? _onlineReport;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) {
      return;
    }
    _hasLoaded = true;
    if (widget.request != null) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = widget.request;
    if (request == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final endpoint = _endpointFor(request.kind);
    if (endpoint == null) {
      setState(() {
        _error = l10n.cashReportApiNotReady;
        _periodReport = null;
        _onlineReport = null;
      });
      return;
    }
    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();
    final businessId = preferences.readBusinessId();
    final requiresCourier = request.kind == CashReportKind.periodic;
    if (businessId == null || (requiresCourier && courierId == null)) {
      setState(() {
        _error = l10n.cashReportSessionMissing;
        _periodReport = null;
        _onlineReport = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _periodReport = null;
      _onlineReport = null;
    });

    try {
      final dio = context.read<Dio>();
      final dateFormat = DateFormat('dd.MM.yyyy');
      final Map<String, Object?> payload = {
        'business_id': businessId,
        'bosh_sana': dateFormat.format(request.range.start),
        'tugash_sana': dateFormat.format(request.range.end),
      };
      if (requiresCourier) {
        payload['kuryer_id'] = courierId;
      }
      final response = await dio.post(endpoint, data: payload);
      final data = response.data;
      CashPeriodReport? report;
      OnlinePaymentReport? onlineReport;
      String? errorMessage;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = _extractDetail(map);
        final ok = map['ok'] == true;
        final hasRows = map['rows'] is List;
        if (!ok && detail != null && !hasRows) {
          errorMessage = detail;
        } else {
          if (request.kind == CashReportKind.periodic) {
            report = CashPeriodReport.fromJson(map);
          } else {
            onlineReport = OnlinePaymentReport.fromJson(map);
          }
        }
      } else {
        errorMessage = l10n.cashReportEmptyResult;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = errorMessage;
        _periodReport = report;
        _onlineReport = onlineReport;
      });
    } on DioException catch (error) {
      final message = _extractError(error) ?? l10n.cashReportEmptyResult;
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = message;
        _periodReport = null;
        _onlineReport = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = l10n.cashReportEmptyResult;
        _periodReport = null;
        _onlineReport = null;
      });
    }
  }

  String? _endpointFor(CashReportKind kind) {
    switch (kind) {
      case CashReportKind.periodic:
        return '/finance/kuryer/cash/period-report/';
      case CashReportKind.onlinePayments:
        return '/boss/online-payments/period-report/';
    }
  }

  String? _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return _extractDetail(Map<String, dynamic>.from(data));
    }
    return null;
  }

  String? _extractDetail(Map<String, dynamic> data) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final request = widget.request;
    final title = request == null
        ? l10n.menuCashReport
        : _titleFor(request.kind, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: request == null
          ? _EmptySelection(message: l10n.cashReportValidationRequired)
          : _buildBody(context, request, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CashReportRequest request,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rangeLabel =
        '${dateFormat.format(request.range.start)} - ${dateFormat.format(request.range.end)}';

    final content = <Widget>[
      _RangeCard(
        title: l10n.cashReportRangeLabel,
        value: rangeLabel,
      ),
      const SizedBox(height: 16),
    ];

    if (_isLoading) {
      content.addAll([
        const SizedBox(height: 40),
        const Center(child: CircularProgressIndicator()),
      ]);
    } else if (_error != null) {
      content.add(
        _MessageCard(
          icon: Icons.info_outline,
          message: _error!,
          onRetry: _endpointFor(request.kind) == null ? null : () => _load(),
          retryLabel: l10n.cashReportRetry,
        ),
      );
    } else if (request.kind == CashReportKind.periodic) {
      final report = _periodReport;
      if (report == null) {
        content.add(
          _MessageCard(
            icon: Icons.inbox_outlined,
            message: l10n.cashReportEmptyResult,
            onRetry: () => _load(),
            retryLabel: l10n.cashReportRetry,
          ),
        );
      } else {
        content.addAll(
          _buildPeriodicReport(
            report,
            l10n,
            colorScheme,
            textTheme,
          ),
        );
      }
    } else if (request.kind == CashReportKind.onlinePayments) {
      final report = _onlineReport;
      if (report == null) {
        content.add(
          _MessageCard(
            icon: Icons.inbox_outlined,
            message: l10n.cashReportEmptyResult,
            onRetry: () => _load(),
            retryLabel: l10n.cashReportRetry,
          ),
        );
      } else {
        content.addAll(
          _buildOnlineReport(
            report,
            l10n,
            colorScheme,
            textTheme,
          ),
        );
      }
    } else {
      content.add(
        _MessageCard(
          icon: Icons.info_outline,
          message: l10n.cashReportApiNotReady,
          onRetry: null,
          retryLabel: l10n.cashReportRetry,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: content,
      ),
    );
  }

  String _titleFor(CashReportKind kind, AppLocalizations l10n) {
    switch (kind) {
      case CashReportKind.periodic:
        return l10n.cashReportPeriodicTitle;
      case CashReportKind.onlinePayments:
        return l10n.cashReportOnlineTitle;
    }
  }

  List<Widget> _buildPeriodicReport(
    CashPeriodReport report,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final items = <Widget>[
      Text(
        l10n.cashReportSummaryTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
        children: [
          _SummaryCard(
            title: l10n.cashReportOpeningBalanceLabel,
            value: report.openingBalance,
            icon: Icons.account_balance_wallet_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
          _SummaryCard(
            title: l10n.cashReportClosingBalanceLabel,
            value: report.closingBalance,
            icon: Icons.account_balance_outlined,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
          ),
          _SummaryCard(
            title: l10n.cashReportTotalIncomeLabel,
            value: report.totalIncome,
            icon: Icons.trending_up,
            background: colorScheme.tertiaryContainer,
            foreground: colorScheme.onTertiaryContainer,
          ),
          _SummaryCard(
            title: l10n.cashReportTotalExpenseLabel,
            value: report.totalExpense,
            icon: Icons.trending_down,
            background: colorScheme.errorContainer,
            foreground: colorScheme.onErrorContainer,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text(
        l10n.cashReportOperationsTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (report.rows.isEmpty) {
      items.add(
        _MessageCard(
          icon: Icons.inbox_outlined,
          message: l10n.cashReportEmptyResult,
          onRetry: () => _load(),
          retryLabel: l10n.cashReportRetry,
        ),
      );
    } else {
      items.addAll(
        report.rows.map(
          (row) => _CashRowCard(
            row: row,
            l10n: l10n,
          ),
        ),
      );
    }

    return items;
  }

  List<Widget> _buildOnlineReport(
    OnlinePaymentReport report,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final items = <Widget>[
      Text(
        l10n.cashReportSummaryTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.8,
        children: [
          _SummaryCard(
            title: l10n.cashReportTotalAmountLabel,
            value: report.totalAmount,
            icon: Icons.payments_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text(
        l10n.cashReportPaymentsTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (report.rows.isEmpty) {
      items.add(
        _MessageCard(
          icon: Icons.inbox_outlined,
          message: l10n.cashReportEmptyResult,
          onRetry: () => _load(),
          retryLabel: l10n.cashReportRetry,
        ),
      );
    } else {
      items.addAll(
        report.rows.map(
          (row) => _OnlinePaymentCard(
            row: row,
            l10n: l10n,
          ),
        ),
      );
    }

    return items;
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
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
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _CashRowCard extends StatelessWidget {
  const _CashRowCard({
    required this.row,
    required this.l10n,
  });

  final CashPeriodRow row;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = _buildDateLabel();
    final operation =
        row.operation.isNotEmpty ? row.operation : l10n.notAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _BalancePill(
                label: l10n.cashReportBalanceLabel,
                value: uzsFormat.format(int.tryParse(row.balance)),
                background: colorScheme.surfaceVariant,
                foreground: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            operation,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (row.courierName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    row.courierName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AmountPill(
                  label: l10n.cashReportIncomeLabel,
                  value: uzsFormat.format(int.tryParse(row.income)),
                  background: colorScheme.primaryContainer,
                  foreground: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountPill(
                  label: l10n.cashReportExpenseLabel,
                  value: uzsFormat.format(int.tryParse(row.expense)),
                  background: colorScheme.errorContainer,
                  foreground: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDateLabel() {
    final date = row.date.isNotEmpty ? row.date : l10n.notAvailable;
    final time = row.time.trim();
    if (time.isEmpty) {
      return date;
    }
    return '$date · $time';
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: foreground.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: foreground.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({
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

class _OnlinePaymentCard extends StatelessWidget {
  const _OnlinePaymentCard({
    required this.row,
    required this.l10n,
  });

  final OnlinePaymentRow row;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = _buildDateLabel();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _BalancePill(
                label: l10n.cashReportAmountLabel,
                value: uzsFormat.format(int.tryParse(row.amount)),
                background: colorScheme.secondaryContainer,
                foreground: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.receipt_long_outlined,
            label: l10n.cashReportOrderLabel,
            value: _valueOrFallback(row.orderNumber),
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.person_outline,
            label: l10n.cashReportBuyerLabel,
            value: _valueOrFallback(row.buyer),
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: l10n.cashReportPaymentSystemLabel,
            value: _valueOrFallback(row.paymentSystem),
          ),
        ],
      ),
    );
  }

  String _buildDateLabel() {
    final date = row.date.isNotEmpty ? row.date : l10n.notAvailable;
    final time = row.time.trim();
    if (time.isEmpty) {
      return date;
    }
    return '$date · $time';
  }

  String _valueOrFallback(String value) {
    return value.trim().isEmpty ? l10n.notAvailable : value;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySelection extends StatelessWidget {
  const _EmptySelection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
