import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/clase.dart';
import '../providers/planner_provider.dart';
import '../services/widget_service.dart';
import '../widgets/section_title.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  String _selectedDay = _weekDays[DateTime.now().weekday - 1];

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final clases = _classesForDay(planner.clases, _selectedDay);

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
              title: 'Horario de clases',
              subtitle: 'Visualiza tu semana por día, salón y profesor.',
            ),
            const SizedBox(height: AppSpacing.md),
            _WidgetPromptCard(
              onAddWidget: () => WidgetService.openWidgetConfiguration(),
            ),
            const SizedBox(height: AppSpacing.md),
            _ScheduleHero(total: planner.clases.length, day: _selectedDay),
            const SizedBox(height: AppSpacing.md),
            _DaySelector(
              selectedDay: _selectedDay,
              onChanged: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: AppSpacing.md),
            if (clases.isEmpty)
              _EmptyScheduleCard(day: _selectedDay)
            else
              ...clases.map(
                (clase) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Dismissible(
                    key: ValueKey(clase.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context, clase),
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
                    onDismissed: (_) => _deleteClass(context, clase),
                    child: _ClassCard(
                      clase: clase,
                      onTap: () => _showClassSheet(context, clase: clase),
                      onEdit: () => _showClassSheet(context, clase: clase),
                      onDelete: () => _deleteClass(context, clase),
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
            onPressed: () => _showClassSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Nueva clase',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  List<Clase> _classesForDay(List<Clase> clases, String day) {
    final sorted = List<Clase>.from(clases)
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    return sorted
        .where((clase) => clase.dia.toLowerCase() == day.toLowerCase())
        .toList();
  }

  Future<bool?> _confirmDelete(BuildContext context, Clase clase) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: Text('¿Quieres eliminar "${clase.materia}" del horario?'),
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

  void _deleteClass(BuildContext context, Clase clase) {
    final provider = context.read<PlannerProvider>();
    provider.deleteClase(clase.id);
    WidgetService.updateScheduleWidget(provider.clases);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Clase eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.accentSoft,
          onPressed: () {
            provider.addClase(clase);
            WidgetService.updateScheduleWidget(provider.clases);
          },
        ),
      ),
    );
  }

  void _showClassSheet(BuildContext context, {Clase? clase}) {
    final materiaController = TextEditingController(text: clase?.materia ?? '');
    final salonController = TextEditingController(text: clase?.salon ?? '');
    final profesorController = TextEditingController(
      text: clase?.profesor ?? '',
    );
    String selectedDay = clase?.dia ?? _selectedDay;
    TimeOfDay startTime =
        _parseTime(clase?.horaInicio) ?? const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime =
        _parseTime(clase?.horaFin) ?? const TimeOfDay(hour: 8, minute: 0);
    final isEditing = clase != null;

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
                    isEditing ? 'Editar clase' : 'Nueva clase',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: materiaController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: salonController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Salón',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: profesorController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Profesor',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Día',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: _weekDays
                        .map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text(day)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => selectedDay = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeButton(
                          label: 'Inicio',
                          time: startTime,
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: sheetContext,
                              initialTime: startTime,
                              helpText: 'Hora de inicio',
                              cancelText: 'Cancelar',
                              confirmText: 'Listo',
                            );
                            if (time == null) return;
                            setSheetState(() => startTime = time);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TimeButton(
                          label: 'Fin',
                          time: endTime,
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: sheetContext,
                              initialTime: endTime,
                              helpText: 'Hora de fin',
                              cancelText: 'Cancelar',
                              confirmText: 'Listo',
                            );
                            if (time == null) return;
                            setSheetState(() => endTime = time);
                          },
                        ),
                      ),
                    ],
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
                            if (materiaController.text.trim().isEmpty ||
                                salonController.text.trim().isEmpty ||
                                profesorController.text.trim().isEmpty) {
                              return;
                            }

                            final provider = context.read<PlannerProvider>();
                            final updatedClass = Clase(
                              id:
                                  clase?.id ??
                                  DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                              materia: materiaController.text.trim(),
                              salon: salonController.text.trim(),
                              profesor: profesorController.text.trim(),
                              dia: selectedDay,
                              horaInicio: _formatTime(startTime),
                              horaFin: _formatTime(endTime),
                            );

                            if (isEditing) {
                              provider.updateClase(updatedClass);
                            } else {
                              provider.addClase(updatedClass);
                              setState(() => _selectedDay = selectedDay);
                            }

                            // Actualiza el widget con las clases
                            WidgetService.updateScheduleWidget(provider.clases);

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
      materiaController.dispose();
      salonController.dispose();
      profesorController.dispose();
    });
  }
}

class _ScheduleHero extends StatelessWidget {
  final int total;
  final String day;

  const _ScheduleHero({required this.total, required this.day});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total clases guardadas en tu semana',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            color: scheme.onPrimary.withValues(alpha: 0.86),
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onChanged;

  const _DaySelector({required this.selectedDay, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final selected = day == selectedDay;

          return ChoiceChip(
            selected: selected,
            label: Text(day.substring(0, 3)),
            avatar: selected ? const Icon(Icons.check_rounded, size: 16) : null,
            onSelected: (_) => onChanged(day),
          );
        },
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Clase clase;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.clase,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
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
              Container(
                width: 5,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clase.materia,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.schedule_outlined,
                          label: '${clase.horaInicio} - ${clase.horaFin}',
                        ),
                        _InfoChip(
                          icon: Icons.meeting_room_outlined,
                          label: clase.salon,
                        ),
                        _InfoChip(
                          icon: Icons.person_outline,
                          label: clase.profesor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ClassAction>(
                tooltip: 'Opciones',
                onSelected: (action) {
                  switch (action) {
                    case _ClassAction.edit:
                      onEdit();
                    case _ClassAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ClassAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ClassAction.delete,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.primary, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onPressed;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.schedule_outlined),
      label: Text('$label ${_formatTime(time)}'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _EmptyScheduleCard extends StatelessWidget {
  final String day;

  const _EmptyScheduleCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
            Icons.event_note_outlined,
            size: 34,
            color: scheme.onSurface.withValues(alpha: 0.65),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No hay clases para $day.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega una clase y mantén tu semana mucho más clara.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WidgetPromptCard extends StatelessWidget {
  final VoidCallback onAddWidget;

  const _WidgetPromptCard({required this.onAddWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.widgets_outlined,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agrega a tu inicio',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ver tu próxima clase sin abrir la app',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onAddWidget,
            icon: const Icon(Icons.add_rounded),
            color: AppColors.accent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

const _weekDays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

enum _ClassAction { edit, delete }

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

TimeOfDay? _parseTime(String? value) {
  if (value == null || !value.contains(':')) return null;

  final parts = value.split(':');
  final hour = int.tryParse(parts.first);
  final minute = int.tryParse(parts.last);
  if (hour == null || minute == null) return null;

  return TimeOfDay(hour: hour, minute: minute);
}
