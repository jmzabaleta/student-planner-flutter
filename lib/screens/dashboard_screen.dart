import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Tu panel estudiantil',
            subtitle: 'Un vistazo rápido para que no se te escape nada.',
          ),
          const SizedBox(height: AppSpacing.md),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.20,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(
                title: 'Clases',
                value: '${planner.clases.length}',
                icon: Icons.school_outlined,
              ),
              SummaryCard(
                title: 'Tareas',
                value: '${planner.tareasPendientes.length}',
                icon: Icons.pending_actions_outlined,
              ),
              SummaryCard(
                title: 'Notas',
                value: '${planner.notas.length}',
                icon: Icons.sticky_note_2_outlined,
              ),
              SummaryCard(
                title: 'Recordatorios',
                value: '${planner.recordatorios.length}',
                icon: Icons.notifications_active_outlined,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Próximas tareas',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (planner.tareasPendientes.isEmpty)
            const _EmptyStateCard(
              icon: Icons.task_alt,
              message: 'Todo al día. No tienes tareas pendientes.',
            )
          else
            ...planner.tareasPendientes.take(3).map(
              (tarea) => _InfoCard(
                icon: Icons.assignment_outlined,
                title: tarea.titulo,
                subtitle:
                    '${tarea.materia} • ${_formatearFecha(tarea.fechaEntrega)}',
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          const Text(
            'Próximos recordatorios',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (planner.proximosRecordatorios.isEmpty)
            const _EmptyStateCard(
              icon: Icons.notifications_none_rounded,
              message: 'Sin recordatorios por ahora.',
            )
          else
            ...planner.proximosRecordatorios.take(3).map(
              (item) => _InfoCard(
                icon: Icons.alarm_rounded,
                title: item.titulo,
                subtitle: item.descripcion,
              ),
            ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes  $hora:$minuto';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.navIndicator,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navIndicator),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}