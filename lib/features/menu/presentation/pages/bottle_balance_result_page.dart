import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import 'bottle_balance_models.dart';

class BottleBalanceResultPage extends StatefulWidget {
  const BottleBalanceResultPage({super.key, required this.request});

  final BottleBalanceRequest? request;

  @override
  State<BottleBalanceResultPage> createState() =>
      _BottleBalanceResultPageState();
}

class _BottleBalanceResultPageState extends State<BottleBalanceResultPage> {
  bool _hasLoaded = false;
  bool _isLoading = false;
  String? _error;
  BottleBalancePeriodReport? _bottleReport;
  FullWaterPeriodReport? _fullWaterReport;

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
        _isLoading = false;
        _error = l10n.cashReportApiNotReady;
        _bottleReport = null;
        _fullWaterReport = null;
      });
      return;
    }

    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();
    if (courierId == null) {
      setState(() {
        _isLoading = false;
        _error = l10n.cashReportSessionMissing;
        _bottleReport = null;
        _fullWaterReport = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _bottleReport = null;
      _fullWaterReport = null;
    });

    try {
      final dio = context.read<Dio>();
      final dateFormat = DateFormat('dd.MM.yyyy');
      final payload = {
        'kuryer_id': courierId,
        'bosh_sana': dateFormat.format(request.range.start),
        'tugash_sana': dateFormat.format(request.range.end),
      };
      final response = await dio.post(endpoint, data: payload);
      final data = response.data;
      BottleBalancePeriodReport? bottleReport;
      FullWaterPeriodReport? fullWaterReport;
      String? errorMessage;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final detail = _extractDetail(map);
        final ok = map['ok'] == true;
        final hasRows = map['rows'] is List;
        if (!ok && detail != null && !hasRows) {
          errorMessage = detail;
        } else if (request.kind == BottleBalanceKind.emptyBottles) {
          bottleReport = BottleBalancePeriodReport.fromJson(map);
        } else if (request.kind == BottleBalanceKind.fullWater) {
          fullWaterReport = FullWaterPeriodReport.fromJson(map);
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
        _bottleReport = bottleReport;
        _fullWaterReport = fullWaterReport;
      });
    } on DioException catch (error) {
      final message = _extractError(error) ?? l10n.cashReportEmptyResult;
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = message;
        _bottleReport = null;
        _fullWaterReport = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = l10n.cashReportEmptyResult;
        _bottleReport = null;
        _fullWaterReport = null;
      });
    }
  }

  String? _endpointFor(BottleBalanceKind kind) {
    switch (kind) {
      case BottleBalanceKind.emptyBottles:
        return '/couriers/kuryer/tara-bottle/period-report/';
      case BottleBalanceKind.fullWater:
        return '/couriers/full_bottles/period-report/';
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
        ? l10n.menuBottleBalance
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
    BottleBalanceRequest request,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());
    final numberFormat = NumberFormat('#,##0', locale.toString());
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
    } else if (request.kind == BottleBalanceKind.emptyBottles) {
      final report = _bottleReport;
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
            numberFormat,
          ),
        );
      }
    } else if (request.kind == BottleBalanceKind.fullWater) {
      final report = _fullWaterReport;
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
          _buildFullWaterReport(
            report,
            l10n,
            colorScheme,
            textTheme,
            numberFormat,
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
        padding: ResponsiveSpacing.pagePadding(context),
        physics: const AlwaysScrollableScrollPhysics(),
        children: content,
      ),
    );
  }

  String _titleFor(BottleBalanceKind kind, AppLocalizations l10n) {
    switch (kind) {
      case BottleBalanceKind.emptyBottles:
        return l10n.bottleBalanceEmptyPeriodicTitle;
      case BottleBalanceKind.fullWater:
        return l10n.bottleBalanceFullWaterPeriodicTitle;
    }
  }

  List<Widget> _buildPeriodicReport(
    BottleBalancePeriodReport report,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
    NumberFormat numberFormat,
  ) {
    String formatCount(int value) => numberFormat.format(value);

    final items = <Widget>[
      Text(
        l10n.bottleBalanceSummaryTitle,
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
            title: l10n.bottleBalanceOpeningBalanceLabel,
            value: formatCount(report.openingBalance),
            icon: Icons.inventory_2_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
          _SummaryCard(
            title: l10n.bottleBalanceClosingBalanceLabel,
            value: formatCount(report.closingBalance),
            icon: Icons.inventory_outlined,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
          ),
          _SummaryCard(
            title: l10n.bottleBalanceTotalIncomeLabel,
            value: formatCount(report.totalIncome),
            icon: Icons.trending_up,
            background: colorScheme.tertiaryContainer,
            foreground: colorScheme.onTertiaryContainer,
          ),
          _SummaryCard(
            title: l10n.bottleBalanceTotalExpenseLabel,
            value: formatCount(report.totalExpense),
            icon: Icons.trending_down,
            background: colorScheme.errorContainer,
            foreground: colorScheme.onErrorContainer,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text(
        l10n.bottleBalanceOperationsTitle,
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
          (row) => _BottleRowCard(
            row: row,
            l10n: l10n,
            numberFormat: numberFormat,
          ),
        ),
      );
    }

    return items;
  }

  List<Widget> _buildFullWaterReport(
    FullWaterPeriodReport report,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
    NumberFormat numberFormat,
  ) {
    String formatCount(int value) => numberFormat.format(value);

    final items = <Widget>[
      Text(
        l10n.bottleBalanceSummaryTitle,
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
            title: l10n.fullWaterOpeningBalanceLabel,
            value: formatCount(report.openingBalance),
            icon: Icons.water_drop_outlined,
            background: colorScheme.primaryContainer,
            foreground: colorScheme.onPrimaryContainer,
          ),
          _SummaryCard(
            title: l10n.fullWaterClosingBalanceLabel,
            value: formatCount(report.closingBalance),
            icon: Icons.water_drop,
            background: colorScheme.secondaryContainer,
            foreground: colorScheme.onSecondaryContainer,
          ),
          _SummaryCard(
            title: l10n.fullWaterTotalIncomeLabel,
            value: formatCount(report.totalIncome),
            icon: Icons.trending_up,
            background: colorScheme.tertiaryContainer,
            foreground: colorScheme.onTertiaryContainer,
          ),
          _SummaryCard(
            title: l10n.fullWaterTotalExpenseLabel,
            value: formatCount(report.totalExpense),
            icon: Icons.trending_down,
            background: colorScheme.errorContainer,
            foreground: colorScheme.onErrorContainer,
          ),
        ],
      ),
      const SizedBox(height: 22),
      Text(
        l10n.bottleBalanceOperationsTitle,
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
          (row) => _FullWaterRowCard(
            row: row,
            l10n: l10n,
            numberFormat: numberFormat,
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
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
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
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
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

class _BottleRowCard extends StatelessWidget {
  const _BottleRowCard({
    required this.row,
    required this.l10n,
    required this.numberFormat,
  });

  final BottleBalanceRow row;
  final AppLocalizations l10n;
  final NumberFormat numberFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = _buildDateLabel();
    final operation =
        row.operation.isNotEmpty ? row.operation : l10n.notAvailable;
    final balanceLabel = numberFormat.format(row.balance);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.spacing(context, base: 12)),
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            icon: Icons.event_outlined,
            title: dateLabel,
            trailing: _BalancePill(
              label: l10n.bottleBalanceBalanceLabel,
              value: balanceLabel,
              background: colorScheme.surfaceContainerHighest,
              foreground: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            operation,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ResponsivePillRow(
            leading: _AmountPill(
              label: l10n.bottleBalanceIncomeLabel,
              value: numberFormat.format(row.income),
              background: colorScheme.primaryContainer,
              foreground: colorScheme.onPrimaryContainer,
            ),
            trailing: _AmountPill(
              label: l10n.bottleBalanceExpenseLabel,
              value: numberFormat.format(row.expense),
              background: colorScheme.errorContainer,
              foreground: colorScheme.onErrorContainer,
            ),
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

class _FullWaterRowCard extends StatelessWidget {
  const _FullWaterRowCard({
    required this.row,
    required this.l10n,
    required this.numberFormat,
  });

  final FullWaterRow row;
  final AppLocalizations l10n;
  final NumberFormat numberFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = _buildDateLabel();
    final operation =
        row.operation.isNotEmpty ? row.operation : l10n.notAvailable;
    final balanceLabel = numberFormat.format(row.balance);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.spacing(context, base: 12)),
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            icon: Icons.event_outlined,
            title: dateLabel,
            trailing: _BalancePill(
              label: l10n.bottleBalanceBalanceLabel,
              value: balanceLabel,
              background: colorScheme.surfaceContainerHighest,
              foreground: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            operation,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ResponsivePillRow(
            leading: _AmountPill(
              label: l10n.bottleBalanceIncomeLabel,
              value: numberFormat.format(row.income),
              background: colorScheme.primaryContainer,
              foreground: colorScheme.onPrimaryContainer,
            ),
            trailing: _AmountPill(
              label: l10n.bottleBalanceExpenseLabel,
              value: numberFormat.format(row.expense),
              background: colorScheme.errorContainer,
              foreground: colorScheme.onErrorContainer,
            ),
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
      padding: ResponsiveSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: foreground.withValues(alpha: 0.8),
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
              color: foreground.withValues(alpha: 0.8),
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
              color: foreground.withValues(alpha: 0.85),
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 280 || textScale >= 1.25;
        final titleWidget = Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        );

        final leading = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(child: titleWidget),
          ],
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(child: titleWidget),
            const SizedBox(width: 8),
            trailing,
          ],
        );
      },
    );
  }
}

class _ResponsivePillRow extends StatelessWidget {
  const _ResponsivePillRow({
    required this.leading,
    required this.trailing,
  });

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 280 || textScale >= 1.25;
        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leading,
              const SizedBox(height: 12),
              trailing,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: leading),
            const SizedBox(width: 12),
            Expanded(child: trailing),
          ],
        );
      },
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
