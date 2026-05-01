import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/tarea.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  _TaskFilter _filter = _TaskFilter.pending;

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final tareas = _filteredTasks(planner.tareas);
    final pendientes = planner.tareas.where((t) => !t.completada).length;
    final completadas = planner.tareas.where((t) => t.completada).length;
    final vencidas = planner.tareas.where(_isOverdue).length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            160,
          ),
          children: [
            const SectionTitle(
              title: 'Tareas',
              subtitle: 'Controla entregas, avances y pendientes sin fricción.',
            ),
            const SizedBox(height: AppSpacing.md),
            _TaskSummary(
              pending: pendientes,
              done: completadas,
              overdue: vencidas,
            ),
            const SizedBox(height: AppSpacing.md),
            _TaskFilterBar(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: AppSpacing.md),
            if (tareas.isEmpty)
              _EmptyTasksCard(filter: _filter)
            else
              ...tareas.map(
                (tarea) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Dismissible(
                    key: ValueKey(tarea.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context, tarea),
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    onDismissed: (_) => _deleteTask(context, tarea),
                    child: _TaskCard(
                      tarea: tarea,
                      onToggle: () {
                        context.read<PlannerProvider>().toggleTarea(tarea.id);
                      },
                      onEdit: () => _showTaskSheet(context, tarea: tarea),
                      onDelete: () => _deleteTask(context, tarea),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showTaskSheet(context),
            icon: const Icon(Icons.add_task_rounded),
            label: const Text(
              'Nueva tarea',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  List<Tarea> _filteredTasks(List<Tarea> tareas) {
    final sorted = List<Tarea>.from(tareas)
      ..sort((a, b) => a.fechaEntrega.compareTo(b.fechaEntrega));

    return sorted.where((tarea) {
      return switch (_filter) {
        _TaskFilter.pending => !tarea.completada,
        _TaskFilter.today => _isToday(tarea),
        _TaskFilter.overdue => _isOverdue(tarea),
        _TaskFilter.done => tarea.completada,
        _TaskFilter.all => true,
      };
    }).toList();
  }

  Future<bool?> _confirmDelete(BuildContext context, Tarea tarea) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Quieres eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, Tarea tarea) {
    final provider = context.read<PlannerProvider>();
    provider.deleteTarea(tarea.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Tarea eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.accentSoft,
          onPressed: () => provider.addTarea(tarea),
        ),
      ),
    );
  }

  void _showTaskSheet(BuildContext context, {Tarea? tarea}) {
    final titleController = TextEditingController(text: tarea?.titulo ?? '');
    final subjectController = TextEditingController(text: tarea?.materia ?? '');
    DateTime selectedDate = tarea?.fechaEntrega ?? DateTime.now();
    final isEditing = tarea != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isEditing ? 'Editar tarea' : 'Nueva tarea',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: subjectController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DateButton(
                    date: selectedDate,
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 5),
                        helpText: 'Fecha de entrega',
                        cancelText: 'Cancelar',
                        confirmText: 'Listo',
                      );
                      if (date == null) return;
                      setSheetState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty ||
                                subjectController.text.trim().isEmpty) {
                              return;
                            }

                            final provider = context.read<PlannerProvider>();
                            if (isEditing) {
                              provider.updateTarea(
                                tarea.copyWith(
                                  titulo: titleController.text.trim(),
                                  materia: subjectController.text.trim(),
                                  fechaEntrega: selectedDate,
                                ),
                              );
                            } else {
                              provider.addTarea(
                                Tarea(
                                  id: DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                                  titulo: titleController.text.trim(),
                                  materia: subjectController.text.trim(),
                                  fechaEntrega: selectedDate,
                                ),
                              );
                            }

                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: Text(isEditing ? 'Guardar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      titleController.dispose();
      subjectController.dispose();
    });
  }
}

class _TaskSummary extends StatelessWidget {
  final int pending;
  final int done;
  final int overdue;

  const _TaskSummary({
    required this.pending,
    required this.done,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Pendientes',
            value: '$pending',
            icon: Icons.pending_actions_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Listas',
            value: '$done',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Vencidas',
            value: '$overdue',
            icon: Icons.priority_high_rounded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFilterBar extends StatelessWidget {
  final _TaskFilter selected;
  final ValueChanged<_TaskFilter> onChanged;

  const _TaskFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<_TaskFilter>(
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.first),
        segments: const [
          ButtonSegment(
            value: _TaskFilter.pending,
            icon: Icon(Icons.radio_button_unchecked),
            label: Text('Pendientes'),
          ),
          ButtonSegment(
            value: _TaskFilter.today,
            icon: Icon(Icons.today_outlined),
            label: Text('Hoy'),
          ),
          ButtonSegment(
            value: _TaskFilter.overdue,
            icon: Icon(Icons.warning_amber_rounded),
            label: Text('Vencidas'),
          ),
          ButtonSegment(
            value: _TaskFilter.done,
            icon: Icon(Icons.done_all_rounded),
            label: Text('Listas'),
          ),
          ButtonSegment(
            value: _TaskFilter.all,
            icon: Icon(Icons.list_alt_rounded),
            label: Text('Todas'),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.tarea,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = _isOverdue(tarea);
    final today = _isToday(tarea);
    final statusColor = tarea.completada
        ? AppColors.success
        : overdue
        ? AppColors.error
        : today
        ? AppColors.warning
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onEdit,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: tarea.completada,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tarea.materia,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: _formatDate(tarea.fechaEntrega),
                          icon: Icons.event_available_outlined,
                          color: statusColor,
                        ),
                        _Chip(
                          label: tarea.completada
                              ? 'Completada'
                              : overdue
                              ? 'Vencida'
                              : today
                              ? 'Para hoy'
                              : 'Pendiente',
                          icon: tarea.completada
                              ? Icons.check_rounded
                              : Icons.timelapse_rounded,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_TaskAction>(
                tooltip: 'Opciones',
                onSelected: (action) {
                  switch (action) {
                    case _TaskAction.edit:
                      onEdit();
                    case _TaskAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _TaskAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _TaskAction.delete,
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      title: Text('Eliminar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPressed;

  const _DateButton({required this.date, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.event_outlined),
      label: Text('Entrega: ${_formatDate(date)}'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  final _TaskFilter filter;

  const _EmptyTasksCard({required this.filter});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = switch (filter) {
      _TaskFilter.pending => 'No tienes tareas pendientes.',
      _TaskFilter.today => 'No hay tareas para hoy.',
      _TaskFilter.overdue => 'No tienes tareas vencidas.',
      _TaskFilter.done => 'Todavía no has completado tareas.',
      _TaskFilter.all => 'Todavía no has agregado tareas.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 34,
            color: scheme.onSurface.withValues(alpha: 0.65),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Crea tareas con fecha de entrega para priorizar mejor tu semana.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _TaskFilter { pending, today, overdue, done, all }

enum _TaskAction { edit, delete }

bool _isOverdue(Tarea tarea) {
  final today = DateTime.now();
  final due = tarea.fechaEntrega;
  final dueDate = DateTime(due.year, due.month, due.day);
  final todayDate = DateTime(today.year, today.month, today.day);
  return !tarea.completada && dueDate.isBefore(todayDate);
}

bool _isToday(Tarea tarea) {
  final now = DateTime.now();
  final date = tarea.fechaEntrega;
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _formatDate(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}
