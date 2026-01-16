import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/responsive_spacing.dart';

class DateRangeCard extends StatelessWidget {
  const DateRangeCard({
    super.key,
    this.title,
    this.icon,
    required this.startLabel,
    required this.endLabel,
    required this.pickLabel,
    required this.startDate,
    required this.endDate,
    required this.dateFormat,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String? title;
  final IconData? icon;
  final String startLabel;
  final String endLabel;
  final String pickLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateFormat dateFormat;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = ResponsiveSpacing.largePadding(context);
    final radius = ResponsiveSpacing.borderRadius(context, base: 18);
    final spacing = ResponsiveSpacing.spacing(context, base: 12);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveSpacing.spacing(context, base: 10),
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        ResponsiveSpacing.borderRadius(context, base: 14),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: colorScheme.onPrimaryContainer,
                      size: ResponsiveSpacing.iconSize(context, base: 22),
                    ),
                  ),
                  SizedBox(width: spacing),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 16)),
          ],
          DateField(
            label: startLabel,
            value: startDate == null
                ? pickLabel
                : dateFormat.format(startDate!),
            onTap: onPickStart,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
          DateField(
            label: endLabel,
            value: endDate == null ? pickLabel : dateFormat.format(endDate!),
            onTap: onPickEnd,
          ),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.arrow_forward),
              label: Text(submitLabel),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveSpacing.spacing(context, base: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSpacing.borderRadius(context, base: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: ResponsiveSpacing.spacing(context, base: 6)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveSpacing.borderRadius(context, base: 14),
          ),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSpacing.spacing(context, base: 14),
              vertical: ResponsiveSpacing.spacing(context, base: 12),
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                ResponsiveSpacing.borderRadius(context, base: 14),
              ),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  color: colorScheme.primary,
                  size: ResponsiveSpacing.iconSize(context, base: 20),
                ),
                SizedBox(width: ResponsiveSpacing.spacing(context, base: 10)),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
