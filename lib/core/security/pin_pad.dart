import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
  });

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
            (index) {
          final isFilled = index < filled;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? colorScheme.primary : colorScheme.surface,
              border: Border.all(
                color: isFilled
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.6),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 1, 2, 3
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 12),
          // Row 2: 4, 5, 6
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 12),
          // Row 3: 7, 8, 9
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 12),
          // Row 4: empty, 0, backspace
          _buildRow([null, '0', 'backspace']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String?> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == null) {
          return const SizedBox(width: 70, height: 70);
        }
        if (key == 'backspace') {
          return _PinKeyButton(
            isBackspace: true,
            onPressed: onBackspace,
            enabled: enabled,
          );
        }
        return _PinKeyButton(
          digit: key,
          isBackspace: false,
          onPressed: () => onDigit(key),
          enabled: enabled,
        );
      }).toList(),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    this.digit,
    required this.isBackspace,
    required this.onPressed,
    required this.enabled,
  });

  final String? digit;
  final bool isBackspace;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = colorScheme.onSurface;
    final background = colorScheme.surfaceVariant;
    final borderColor = colorScheme.outline.withOpacity(0.35);

    final child = isBackspace
        ? Icon(Icons.backspace_outlined, color: foreground)
        : Text(
      digit ?? '',
      style: textTheme.titleLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onPressed : null,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}