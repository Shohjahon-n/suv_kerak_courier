import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:suv_kerak_courier/core/constants/app_constants.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../shared/widgets/date_range_card.dart';
import 'courier_service_models.dart';

class CourierServicePage extends StatefulWidget {
  const CourierServicePage({super.key});

  @override
  State<CourierServicePage> createState() => _CourierServicePageState();
}

class _CourierServicePageState extends State<CourierServicePage>
    with ErrorHandlingMixin<CourierServicePage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;
  CourierServiceReport? _report;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = (isStart ? _startDate : _endDate) ?? now;
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

  void _loadReport() {
    final l10n = AppLocalizations.of(context);
    if (_startDate == null || _endDate == null) {
      showToast(l10n.cashReportValidationRequired);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      showToast(l10n.cashReportValidationOrder);
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final startDate = _startDate;
    final endDate = _endDate;
    if (startDate == null || endDate == null) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();
    final businessId = preferences.readBusinessId();

    if (businessId == null || courierId == null) {
      setState(() {
        _error = l10n.cashReportSessionMissing;
        _report = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _report = null;
    });

    try {
      final dio = context.read<Dio>();
      final dateFormat = DateFormat('dd.MM.yyyy');
      final Map<String, Object?> payload = {
        'business_id': businessId,
        'kuryer_id': courierId,
        'bosh_sana': dateFormat.format(startDate),
        'tugash_sana': dateFormat.format(endDate),
      };

      final response =
          await dio.post('/boss/courier/service-statement/', data: payload);
      final data = response.data;
      CourierServiceReport? report;
      String? errorMessage;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = _extractDetail(map);
        final ok = map['ok'] == true;
        final hasRows = map['rows'] is List;
        if (!ok && detail != null && !hasRows) {
          errorMessage = detail;
        } else {
          report = CourierServiceReport.fromJson(map);
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
        _report = report;
      });
    } on DioException catch (error) {
      final message = _extractError(error) ?? l10n.cashReportEmptyResult;
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = message;
        _report = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = l10n.cashReportEmptyResult;
        _report = null;
      });
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
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.courierServiceTitle),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: ResponsiveSpacing.pagePadding(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            DateRangeCard(
              title: l10n.courierServiceTitle,
              icon: Icons.receipt_outlined,
              startLabel: l10n.cashReportStartDate,
              endLabel: l10n.cashReportEndDate,
              pickLabel: l10n.cashReportPickDate,
              startDate: _startDate,
              endDate: _endDate,
              dateFormat: dateFormat,
              onPickStart: () => _pickDate(isStart: true),
              onPickEnd: () => _pickDate(isStart: false),
              onSubmit: (_startDate != null && _endDate != null)
                  ? _loadReport
                  : null,
              submitLabel: l10n.cashReportShow,
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _MessageCard(
                icon: Icons.info_outline,
                message: _error!,
                onRetry: () => _load(),
                retryLabel: l10n.cashReportRetry,
              )
            else if (_report != null)
              ..._buildReport(_report!, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReport(
    CourierServiceReport report,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = <Widget>[
      _MessageInfoCard(
        message: report.startMessage,
        color: _parseColor(report.startMessageColor, colorScheme),
      ),
      const SizedBox(height: 12),
      _MessageInfoCard(
        message: report.endMessage,
        color: _parseColor(report.endMessageColor, colorScheme),
      ),
      const SizedBox(height: 20),
      Text(
        l10n.cashReportSummaryTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
      AdaptiveGrid(
        minItemWidth: 145,
        maxColumns: 2,
        baseChildAspectRatio: 1.4,
        crossAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
        mainAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
        children: [
          _SummaryCard(
            title: l10n.courierServiceStartBalance,
            value: report.startCashBalance.toUzsFormat(),
            icon: Icons.account_balance_wallet_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
          _SummaryCard(
            title: l10n.courierServiceEndBalance,
            value: report.endCashBalance.toUzsFormat(),
            icon: Icons.account_balance_outlined,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
          ),
          _SummaryCard(
            title: l10n.cashReportTotalIncomeLabel,
            value: report.totalIncome.toUzsFormat(),
            icon: Icons.trending_up,
            background: colorScheme.tertiaryContainer,
            foreground: colorScheme.onTertiaryContainer,
          ),
          _SummaryCard(
            title: l10n.cashReportTotalExpenseLabel,
            value: report.totalExpense.toUzsFormat(),
            icon: Icons.trending_down,
            background: colorScheme.errorContainer,
            foreground: colorScheme.onErrorContainer,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text(
        l10n.courierServiceOperationsTitle,
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
          (row) => _ServiceRowCard(
            row: row,
            l10n: l10n,
          ),
        ),
      );
    }

    return items;
  }

  Color _parseColor(String colorName, ColorScheme colorScheme) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
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
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
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

class _MessageInfoCard extends StatelessWidget {
  const _MessageInfoCard({
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: ResponsiveSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 12),
        ),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

class _ServiceRowCard extends StatelessWidget {
  const _ServiceRowCard({
    required this.row,
    required this.l10n,
  });

  final CourierServiceRow row;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = row.date;
    final timeLabel = row.time.trim().isEmpty ? '' : ' · ${row.time}';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  row.operation,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                row.cashBalance.toUzsFormat(),
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 4)),
          Text(
            '$dateLabel$timeLabel',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
          KeyValueRow(
            icon: Icons.receipt_long_outlined,
            label: l10n.courierServiceOrderNumber,
            value: row.orderNumber.isEmpty ? l10n.notAvailable : row.orderNumber,
            iconColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            valueStyle:
                textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          KeyValueRow(
            icon: Icons.add_circle_outline,
            label: l10n.courierServiceCharged,
            value: row.charged.toUzsFormat(),
            iconColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            valueStyle:
                textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          KeyValueRow(
            icon: Icons.remove_circle_outline,
            label: l10n.courierServicePaid,
            value: row.paid.toUzsFormat(),
            iconColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            valueStyle:
                textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          KeyValueRow(
            icon: Icons.water_drop_outlined,
            label: l10n.courierServiceCount,
            value: row.serviceCount.toString(),
            iconColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            valueStyle:
                textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
