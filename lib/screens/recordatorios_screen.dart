import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/recordatorio.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final GlobalKey _quickAddKey = GlobalKey();

  DateTime _selectedDateTime = _roundedNow();
  _ReminderFilter _selectedFilter = _ReminderFilter.upcoming;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final recordatorios = _filteredRecordatorios(planner.proximosRecordatorios);
    final vencidos = planner.recordatorios.where(_isOverdue).length;
    final hoy = planner.recordatorios.where(_isToday).length;

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
              title: 'Recordatorios',
              subtitle:
                  'Organiza avisos importantes con fecha, hora y prioridad visual.',
            ),
            const SizedBox(height: AppSpacing.md),
            _ReminderSummary(
              total: planner.recordatorios.length,
              today: hoy,
              overdue: vencidos,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildQuickAddCard(context),
            const SizedBox(height: AppSpacing.md),
            _ReminderFilterBar(
              selected: _selectedFilter,
              onChanged: (filter) => setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: AppSpacing.md),
            if (recordatorios.isEmpty)
              _EmptyReminderCard(filter: _selectedFilter)
            else
              ...recordatorios.map(
                (item) => TweenAnimationBuilder<double>(
                  key: ValueKey('animated-${item.id}'),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, item),
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
                      onDismissed: (_) => _deleteRecordatorio(context, item),
                      child: _RecordatorioCard(
                        recordatorio: item,
                        onTap: () => _showEditRecordatorioDialog(context, item),
                        onEdit: () =>
                            _showEditRecordatorioDialog(context, item),
                        onDelete: () => _deleteRecordatorio(context, item),
                      ),
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: _focusQuickAdd,
            icon: const Icon(Icons.add_alert),
            label: const Text(
              'Nuevo aviso',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      key: _quickAddKey,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nuevo recordatorio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Programar para mañana',
                onPressed: () {
                  setState(() {
                    _selectedDateTime = _roundedNow().add(
                      const Duration(days: 1),
                    );
                  });
                },
                icon: const Icon(Icons.next_plan_outlined),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Captura el aviso y programa cuándo quieres verlo destacado.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _CustomInput(
            controller: _tituloController,
            label: 'Título',
            icon: Icons.title,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CustomInput(
            controller: _descripcionController,
            label: 'Descripción',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DateTimeSelector(
            value: _selectedDateTime,
            onDatePressed: () => _pickDate(context),
            onTimePressed: () => _pickTime(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_tituloController.text.trim().isEmpty ||
                        _descripcionController.text.trim().isEmpty) {
                      _showValidationMessage(context);
                      return;
                    }
                    _addRecordatorio(context);
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(onPressed: _clearFields, child: const Text('Limpiar')),
            ],
          ),
        ],
      ),
    );
  }

  void _addRecordatorio(BuildContext context) {
    context.read<PlannerProvider>().addRecordatorio(
      Recordatorio(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fecha: _selectedDateTime,
      ),
    );

    _clearFields();
    _showSaveSnackBar(context);
  }

  void _clearFields() {
    _tituloController.clear();
    _descripcionController.clear();
    setState(() => _selectedDateTime = _roundedNow());
  }

  void _showValidationMessage(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 2),
        content: Text(
          'Completa título y descripción antes de guardar.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showSaveSnackBar(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        duration: const Duration(seconds: 2),
        content: const Text(
          'Recordatorio guardado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showRemoveSnackBar(BuildContext context, Recordatorio item) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        duration: const Duration(seconds: 3),
        content: const Text(
          'Recordatorio eliminado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.accentSoft,
          onPressed: () {
            context.read<PlannerProvider>().addRecordatorio(item);
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    Recordatorio recordatorio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar recordatorio'),
        content: Text(
          '¿Quieres eliminar "${recordatorio.titulo}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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

  void _deleteRecordatorio(BuildContext context, Recordatorio item) {
    context.read<PlannerProvider>().deleteRecordatorio(item.id);
    _showRemoveSnackBar(context, item);
  }

  void _showEditRecordatorioDialog(
    BuildContext context,
    Recordatorio recordatorio,
  ) {
    final tituloController = TextEditingController(text: recordatorio.titulo);
    final descripcionController = TextEditingController(
      text: recordatorio.descripcion,
    );
    DateTime selectedDateTime = recordatorio.fecha;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Editar recordatorio',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CustomInput(
                  controller: tituloController,
                  label: 'Título',
                  icon: Icons.title,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sm),
                _CustomInput(
                  controller: descripcionController,
                  label: 'Descripción',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DateTimeSelector(
                  value: selectedDateTime,
                  onDatePressed: () async {
                    final date = await _showDatePicker(
                      dialogContext,
                      selectedDateTime,
                    );
                    if (date == null) return;
                    setDialogState(() {
                      selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selectedDateTime.hour,
                        selectedDateTime.minute,
                      );
                    });
                  },
                  onTimePressed: () async {
                    final time = await _showTimePicker(
                      dialogContext,
                      selectedDateTime,
                    );
                    if (time == null) return;
                    setDialogState(() {
                      selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                if (tituloController.text.trim().isEmpty ||
                    descripcionController.text.trim().isEmpty) {
                  return;
                }

                context.read<PlannerProvider>().updateRecordatorio(
                  recordatorio.copyWith(
                    titulo: tituloController.text.trim(),
                    descripcion: descripcionController.text.trim(),
                    fecha: selectedDateTime,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      tituloController.dispose();
      descripcionController.dispose();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await _showDatePicker(context, _selectedDateTime);
    if (date == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await _showTimePicker(context, _selectedDateTime);
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    DateTime initialDate,
  ) {
    final today = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Listo',
    );
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    DateTime initialDate,
  ) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Selecciona la hora',
      cancelText: 'Cancelar',
      confirmText: 'Listo',
    );
  }

  List<Recordatorio> _filteredRecordatorios(List<Recordatorio> items) {
    return items.where((item) {
      return switch (_selectedFilter) {
        _ReminderFilter.upcoming => !_isOverdue(item),
        _ReminderFilter.today => _isToday(item),
        _ReminderFilter.overdue => _isOverdue(item),
        _ReminderFilter.all => true,
      };
    }).toList();
  }

  void _focusQuickAdd() {
    final context = _quickAddKey.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _RecordatorioCard extends StatelessWidget {
  final Recordatorio recordatorio;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordatorioCard({
    required this.recordatorio,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = _isOverdue(recordatorio);
    final today = _isToday(recordatorio);
    final statusColor = overdue
        ? AppColors.error
        : today
        ? AppColors.warning
        : AppColors.primary;

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
            border: Border.all(
              color: overdue
                  ? AppColors.error.withValues(alpha: 0.38)
                  : scheme.outline,
            ),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  overdue
                      ? Icons.notification_important_outlined
                      : Icons.notifications_active_outlined,
                  color: statusColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recordatorio.titulo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _StatusPill(
                          label: overdue
                              ? 'Vencido'
                              : today
                              ? 'Hoy'
                              : 'Próximo',
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recordatorio.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: scheme.onSurface.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatearFecha(recordatorio.fecha),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ReminderAction>(
                tooltip: 'Opciones',
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _ReminderAction.edit:
                      onEdit();
                    case _ReminderAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ReminderAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ReminderAction.delete,
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

class _ReminderSummary extends StatelessWidget {
  final int total;
  final int today;
  final int overdue;

  const _ReminderSummary({
    required this.total,
    required this.today,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Total',
            value: total.toString(),
            icon: Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Hoy',
            value: today.toString(),
            icon: Icons.today_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Vencidos',
            value: overdue.toString(),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
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

class _ReminderFilterBar extends StatelessWidget {
  final _ReminderFilter selected;
  final ValueChanged<_ReminderFilter> onChanged;

  const _ReminderFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<_ReminderFilter>(
        segments: const [
          ButtonSegment(
            value: _ReminderFilter.upcoming,
            icon: Icon(Icons.upcoming_outlined),
            label: Text('Próximos'),
          ),
          ButtonSegment(
            value: _ReminderFilter.today,
            icon: Icon(Icons.today_outlined),
            label: Text('Hoy'),
          ),
          ButtonSegment(
            value: _ReminderFilter.overdue,
            icon: Icon(Icons.warning_amber_rounded),
            label: Text('Vencidos'),
          ),
          ButtonSegment(
            value: _ReminderFilter.all,
            icon: Icon(Icons.list_alt_rounded),
            label: Text('Todos'),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary;
          }),
        ),
      ),
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  final DateTime value;
  final VoidCallback onDatePressed;
  final VoidCallback onTimePressed;

  const _DateTimeSelector({
    required this.value,
    required this.onDatePressed,
    required this.onTimePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDatePressed,
            icon: const Icon(Icons.event_outlined),
            label: Text(_formatDate(value)),
            style: _selectorStyle(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTimePressed,
            icon: const Icon(Icons.schedule_outlined),
            label: Text(_formatTime(value)),
            style: _selectorStyle(),
          ),
        ),
      ],
    );
  }

  ButtonStyle _selectorStyle() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyReminderCard extends StatelessWidget {
  final _ReminderFilter filter;

  const _EmptyReminderCard({required this.filter});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = switch (filter) {
      _ReminderFilter.upcoming => 'No tienes recordatorios próximos.',
      _ReminderFilter.today => 'No hay recordatorios para hoy.',
      _ReminderFilter.overdue => 'No tienes recordatorios vencidos.',
      _ReminderFilter.all => 'Todavía no tienes recordatorios.',
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
            Icons.notifications_none_rounded,
            size: 34,
            color: scheme.onSurface.withValues(alpha: 0.62),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Agrega avisos importantes para mantener tu día bajo control.',
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputAction? textInputAction;

  const _CustomInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.68),
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

enum _ReminderFilter { upcoming, today, overdue, all }

enum _ReminderAction { edit, delete }

bool _isOverdue(Recordatorio recordatorio) {
  return recordatorio.fecha.isBefore(DateTime.now());
}

bool _isToday(Recordatorio recordatorio) {
  final now = DateTime.now();
  final date = recordatorio.fecha;
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

DateTime _roundedNow() {
  final now = DateTime.now().add(const Duration(hours: 1));
  return DateTime(now.year, now.month, now.day, now.hour);
}

String _formatDate(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final anio = fecha.year;

  return '$dia/$mes/$anio';
}

String _formatTime(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');

  return '$hora:$minuto';
}

String _formatearFecha(DateTime fecha) {
  return '${_formatDate(fecha)}  ${_formatTime(fecha)}';
}
