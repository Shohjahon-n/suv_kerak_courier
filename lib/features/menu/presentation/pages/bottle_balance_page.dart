import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class BottleBalancePage extends StatelessWidget {
  const BottleBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuBottleBalance),
      ),
      body: Center(
        child: Text(
          l10n.comingSoon,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
