import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/recordatorio.dart';
import '../models/tarea.dart';
import '../providers/planner_provider.dart';
import '../screens/profile_screen.dart';
import '../widgets/section_title.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final pendingTasks = planner.tareasPendientes;
    final doneTasks = planner.tareas.where((task) => task.completada).length;
    final totalTasks = planner.tareas.length;
    final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;
    final todayReminders = planner.recordatorios.where(_isToday).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHero(
            pendingTasks: pendingTasks.length,
            todayReminders: todayReminders.length,
            progress: progress,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileShortcut(
            classes: planner.clases.length,
            pendingTasks: pendingTasks.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(
            title: 'Vista rápida',
            subtitle: 'Tus números importantes en una sola mirada.',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.22,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                title: 'Clases',
                value: '${planner.clases.length}',
                icon: Icons.school_outlined,
                color: AppColors.primary,
              ),
              _MetricCard(
                title: 'Pendientes',
                value: '${pendingTasks.length}',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
              _MetricCard(
                title: 'Notas',
                value: '${planner.notas.length}',
                icon: Icons.sticky_note_2_outlined,
                color: AppColors.success,
              ),
              _MetricCard(
                title: 'Avisos',
                value: '${planner.recordatorios.length}',
                icon: Icons.notifications_active_outlined,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: 'Próximas tareas',
            subtitle: '${pendingTasks.take(3).length} visibles',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (pendingTasks.isEmpty)
            const _EmptyStateCard(
              icon: Icons.task_alt_rounded,
              message: 'Todo al día. No tienes tareas pendientes.',
            )
          else
            ...pendingTasks.take(3).map((task) => _TaskPreview(task: task)),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: 'Recordatorios',
            subtitle:
                '${planner.proximosRecordatorios.take(3).length} próximos',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (planner.proximosRecordatorios.isEmpty)
            const _EmptyStateCard(
              icon: Icons.notifications_none_rounded,
              message: 'Sin recordatorios por ahora.',
            )
          else
            ...planner.proximosRecordatorios
                .take(3)
                .map((item) => _ReminderPreview(item: item)),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final int pendingTasks;
  final int todayReminders;
  final double progress;

  const _HomeHero({
    required this.pendingTasks,
    required this.todayReminders,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Buenos días'
        : now.hour < 18
        ? 'Buenas tardes'
        : 'Buenas noches';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent.withValues(alpha: 0.88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatWeekday(now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pendingTasks == 0
                ? 'Tu día se ve tranquilo. Buen momento para adelantar.'
                : 'Tienes $pendingTasks tareas pendientes y $todayReminders avisos para hoy.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% de tareas completadas',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileShortcut extends StatelessWidget {
  final int classes;
  final int pendingTasks;

  const _ProfileShortcut({required this.classes, required this.pendingTasks});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.person_rounded, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi espacio académico',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$classes clases registradas · $pendingTasks pendientes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.66),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.58),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TaskPreview extends StatelessWidget {
  final Tarea task;

  const _TaskPreview({required this.task});

  @override
  Widget build(BuildContext context) {
    return _PreviewCard(
      icon: Icons.assignment_outlined,
      color: _isOverdue(task.fechaEntrega)
          ? AppColors.error
          : AppColors.warning,
      title: task.titulo,
      subtitle: '${task.materia} · ${_formatDate(task.fechaEntrega)}',
    );
  }
}

class _ReminderPreview extends StatelessWidget {
  final Recordatorio item;

  const _ReminderPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return _PreviewCard(
      icon: Icons.alarm_rounded,
      color: _isToday(item) ? AppColors.warning : AppColors.primary,
      title: item.titulo,
      subtitle: '${item.descripcion} · ${_formatDate(item.fecha)}',
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _PreviewCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
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

  const _EmptyStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

bool _isToday(Recordatorio item) {
  final now = DateTime.now();
  final date = item.fecha;
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool _isOverdue(DateTime date) {
  final now = DateTime.now();
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).isBefore(DateTime(now.year, now.month, now.day));
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String _formatWeekday(DateTime date) {
  const days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return days[date.weekday - 1];
}
