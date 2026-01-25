import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_spacing.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.leading,
    this.extra,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? leading;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = ResponsiveSpacing.pagePadding(context);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.surface,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentPadding = padding.copyWith(
                  bottom: padding.bottom + keyboardInset,
                );
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: contentPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (leading != null) ...[
                              leading!,
                              SizedBox(
                                height: ResponsiveSpacing.spacing(
                                  context,
                                  base: 12,
                                ),
                              ),
                            ],
                            Text(
                              title,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveSpacing.spacing(
                                context,
                                base: 12,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (extra != null) ...[
                              SizedBox(
                                height: ResponsiveSpacing.spacing(
                                  context,
                                  base: 12,
                                ),
                              ),
                              extra!,
                            ],
                            SizedBox(
                              height: ResponsiveSpacing.verticalSpacing(
                                context,
                                base: 24,
                              ),
                            ),
                            form,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 20),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
