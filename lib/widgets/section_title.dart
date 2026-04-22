import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action; // opcional (botón, icono, etc.)

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),

        if (action != null) ...[
          const SizedBox(width: AppSpacing.sm),
          action!,
        ]
      ],
    );
  }
}