import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_cubit.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  bool _isSaving = false;

  Future<void> _select(Locale locale) async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    await context.read<LocaleCubit>().setLocale(locale);
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final options = [
      _LanguageOption(
        locale: const Locale('en'),
        label: l10n.languageEnglish,
        flag: '🇬🇧',
      ),
      _LanguageOption(
        locale: const Locale('ru'),
        label: l10n.languageRussian,
        flag: '🇷🇺',
      ),
      _LanguageOption(
        locale: const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
        label: l10n.languageUzbekLatin,
        flag: '🇺🇿',
      ),
      _LanguageOption(
        locale: const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
        label: l10n.languageUzbekCyrillic,
        flag: '🇺🇿',
      ),
    ];

    final gradientColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.surface,
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.languageSelectionTitle,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.languageSelectionSubtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return _LanguageCard(
                        option: option,
                        onTap: _isSaving ? null : () => _select(option.locale),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Positioned.fill(
              child: ColoredBox(
                color: colorScheme.surface.withValues(alpha: 0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.flag,
  });

  final Locale locale;
  final String label;
  final String flag;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.onTap,
  });

  final _LanguageOption option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.flag,
                    style: const TextStyle(fontSize: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
