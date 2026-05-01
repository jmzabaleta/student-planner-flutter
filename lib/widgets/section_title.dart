import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.sm), action!],
      ],
    );
  }
}
