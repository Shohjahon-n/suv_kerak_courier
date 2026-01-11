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
    const keys = <_PinKeyData>[
      _PinKeyData.digit('1'),
      _PinKeyData.digit('2'),
      _PinKeyData.digit('3'),
      _PinKeyData.digit('4'),
      _PinKeyData.digit('5'),
      _PinKeyData.digit('6'),
      _PinKeyData.digit('7'),
      _PinKeyData.digit('8'),
      _PinKeyData.digit('9'),
      _PinKeyData.spacer(),
      _PinKeyData.digit('0'),
      _PinKeyData.backspace(),
    ];

    return SizedBox(
      height: 260,
      child: GridView.builder(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          if (key.isSpacer) {
            return const SizedBox.shrink();
          }
          return _PinKeyButton(
            digit: key.digit,
            isBackspace: key.isBackspace,
            onPressed: key.isBackspace ? onBackspace : () => onDigit(key.digit!),
            enabled: enabled,
          );
        },
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    required this.digit,
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
    );
  }
}

class _PinKeyData {
  const _PinKeyData._({
    required this.digit,
    required this.isBackspace,
    required this.isSpacer,
  });

  const _PinKeyData.digit(String value)
      : this._(digit: value, isBackspace: false, isSpacer: false);

  const _PinKeyData.backspace()
      : this._(digit: null, isBackspace: true, isSpacer: false);

  const _PinKeyData.spacer()
      : this._(digit: null, isBackspace: false, isSpacer: true);

  final String? digit;
  final bool isBackspace;
  final bool isSpacer;
}
