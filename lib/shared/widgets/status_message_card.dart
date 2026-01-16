import 'package:flutter/material.dart';

import '../../core/widgets/responsive_spacing.dart';

class StatusMessageCard extends StatelessWidget {
  const StatusMessageCard({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: ResponsiveSpacing.largePadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveSpacing.borderRadius(context, base: 16),
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
