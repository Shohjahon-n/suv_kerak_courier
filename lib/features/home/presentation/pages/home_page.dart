import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<Dio>(),
        context.read<AppPreferences>(),
      ),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((ThemeCubit cubit) => cubit.state);
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<HomeCubit>().clearMessage();
      },
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.homeTitle),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings),
                tooltip: l10n.openSettings,
              ),
              IconButton(
                onPressed: () async {
                  await context.read<ThemeCubit>().toggle();
                },
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: themeMode == ThemeMode.dark
                    ? l10n.themeLight
                    : l10n.themeDark,
              ),
            ],
          ),
          body: _buildBody(context, state, colorScheme, l10n),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeState state,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final dashboard = state.dashboard;

    if (dashboard == null) {
      if (state.status == HomeStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          l10n.homeEmptyState,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat('#,##0.##', locale.toString());
    final dateFormat = DateFormat.yMMMd(locale.toString()).add_Hm();
    final lastActive = dashboard.lastActiveAt == null
        ? l10n.notAvailable
        : dateFormat.format(dashboard.lastActiveAt!);

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().load(),
      child: ListView(
        padding: ResponsiveSpacing.pagePadding(context),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.homeCourierIdLabel}: ${dashboard.courierId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.verticalSpacing(context, base: 16)),
          _DashboardHighlightCard(
            title: l10n.homeLastActiveLabel,
            value: lastActive,
            icon: Icons.access_time,
            background: colorScheme.surfaceVariant,
            foreground: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 14)),
          AdaptiveGrid(
            minItemWidth: 145,
            maxColumns: 2,
            baseChildAspectRatio: 1.3,
            crossAxisSpacing: ResponsiveSpacing.spacing(context, base: 12),
            mainAxisSpacing: ResponsiveSpacing.spacing(context, base: 12),
            children: [
              _DashboardStatCard(
                title: l10n.homeCashBalanceLabel,
                value: numberFormat.format(dashboard.cashBalance),
                icon: Icons.payments_outlined,
                background: colorScheme.primaryContainer,
                foreground: colorScheme.onPrimaryContainer,
              ),
              _DashboardStatCard(
                title: l10n.homeFullWaterLabel,
                value: numberFormat.format(dashboard.fullWaterRemaining),
                icon: Icons.water_drop_outlined,
                background: colorScheme.secondaryContainer,
                foreground: colorScheme.onSecondaryContainer,
              ),
              _DashboardStatCard(
                title: l10n.homeEmptyBottleLabel,
                value: numberFormat.format(dashboard.emptyBottleCount),
                icon: Icons.inbox_outlined,
                background: colorScheme.tertiaryContainer,
                foreground: colorScheme.onTertiaryContainer,
              ),
              _DashboardStatCard(
                title: l10n.homeOrdersTodayLabel,
                value: numberFormat.format(dashboard.ordersCompletedToday),
                icon: Icons.receipt_long_outlined,
                background: colorScheme.surfaceVariant,
                foreground: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: ResponsiveSpacing.verticalSpacing(context, base: 24)),
          Text(
            l10n.mainMenuTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
          AdaptiveGrid(
            minItemWidth: 130,
            maxColumns: 2,
            baseChildAspectRatio: 1.3,
            crossAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
            mainAxisSpacing: ResponsiveSpacing.spacing(context, base: 10),
            children: [
              _MenuCard(
                title: l10n.menuOrders,
                icon: Icons.assignment_outlined,
                onTap: () => context.push('/orders'),
              ),
              _MenuCard(
                title: l10n.menuCashReport,
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.push('/cash-report'),
              ),
              _MenuCard(
                title: l10n.menuBottleBalance,
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push('/bottle-balance'),
              ),
              _MenuCard(
                title: l10n.menuSettings,
                icon: Icons.settings_outlined,
                onTap: () => context.push('/settings'),
              ),
              _MenuCard(
                title: l10n.menuSecurity,
                icon: Icons.verified_user_outlined,
                onTap: () => context.push('/security'),
              ),
              _MenuCard(
                title: l10n.menuAbout,
                icon: Icons.info_outline,
                onTap: () => context.push('/about'),
              ),
            ],
          ),
          if (state.status == HomeStatus.loading)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: LinearProgressIndicator(
                color: colorScheme.primary,
                backgroundColor: colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
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
    final colorScheme = Theme.of(context).colorScheme;
    final cardPadding = ResponsiveSpacing.cardPadding(context);
    final iconSz = ResponsiveSpacing.iconSize(context, base: 22);
    final radius = ResponsiveSpacing.borderRadius(context, base: 18);

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: iconSz),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DashboardHighlightCard extends StatelessWidget {
  const _DashboardHighlightCard({
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
    final padding = ResponsiveSpacing.largePadding(context);
    final radius = ResponsiveSpacing.borderRadius(context, base: 18);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveSpacing.spacing(context, base: 10)),
            decoration: BoxDecoration(
              color: foreground.withOpacity(0.12),
              borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 14)),
            ),
            child: Icon(icon, color: foreground, size: ResponsiveSpacing.iconSize(context, base: 24)),
          ),
          SizedBox(width: ResponsiveSpacing.spacing(context, base: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground.withOpacity(0.8),
                      ),
                ),
                SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveSpacing.borderRadius(context, base: 14);
    final padding = ResponsiveSpacing.cardPadding(context);
    final iconSz = ResponsiveSpacing.iconSize(context, base: 24);

    return Material(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary, size: iconSz),
              SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
