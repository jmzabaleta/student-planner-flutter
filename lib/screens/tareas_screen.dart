import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/tarea.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';

class TareasScreen extends StatelessWidget {
  const TareasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            100,
          ),
          children: [
            const SectionTitle(
              title: 'Tareas',
              subtitle: 'Lleva control de entregas, avances y pendientes.',
            ),
            const SizedBox(height: AppSpacing.md),

            if (planner.tareas.isEmpty)
              const _EmptyTasksCard()
            else
              ...planner.tareas.map(
                (tarea) => _TareaCard(tarea: tarea),
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
            onPressed: () => _showAddTareaDialog(context),
            icon: const Icon(Icons.add_task),
            label: const Text(
              'Agregar tarea',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTareaDialog(BuildContext context) {
    final tituloController = TextEditingController();
    final materiaController = TextEditingController();
    final fechaController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Nueva tarea',
          style: AppTextStyles.sectionTitle,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomInput(
                controller: tituloController,
                label: 'Título',
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: materiaController,
                label: 'Materia',
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: fechaController,
                label: 'Fecha entrega (YYYY-MM-DD)',
                icon: Icons.event_outlined,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
                  materiaController.text.trim().isEmpty) {
                return;
              }

              final fecha =
                  DateTime.tryParse(fechaController.text.trim()) ??
                      DateTime.now();

              context.read<PlannerProvider>().addTarea(
                    Tarea(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      titulo: tituloController.text.trim(),
                      materia: materiaController.text.trim(),
                      fechaEntrega: fecha,
                    ),
                  );

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _TareaCard extends StatelessWidget {
  final Tarea tarea;

  const _TareaCard({required this.tarea});

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
          Transform.scale(
            scale: 1.05,
            child: Checkbox(
              value: tarea.completada,
              onChanged: (_) =>
                  context.read<PlannerProvider>().toggleTarea(tarea.id),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea.titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tarea.completada
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: tarea.completada
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tarea.materia,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatearFecha(tarea.fechaEntrega),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _EstadoChip(completada: tarea.completada),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year;

    return 'Entrega: $dia/$mes/$anio';
  }
}

class _EstadoChip extends StatelessWidget {
  final bool completada;

  const _EstadoChip({required this.completada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completada
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        completada ? 'Completada' : 'Pendiente',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: completada
              ? const Color(0xFF2E7D32)
              : const Color(0xFFB26A00),
        ),
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navIndicator),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 34,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Todavía no has agregado tareas.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Añade tus pendientes para llevar mejor control de tus entregas.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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

  const _CustomInput({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}