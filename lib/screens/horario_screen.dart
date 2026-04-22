import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/clase.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';

class HorarioScreen extends StatelessWidget {
  const HorarioScreen({super.key});

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
              title: 'Horario de clases',
              subtitle: 'Organiza tus materias por día, hora y salón.',
            ),
            const SizedBox(height: AppSpacing.md),

            if (planner.clases.isEmpty)
              const _EmptyScheduleCard()
            else
              ...planner.clases.map(
                (clase) => _ClaseCard(clase: clase),
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
            onPressed: () => _showAddClaseDialog(context),
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar clase',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddClaseDialog(BuildContext context) {
    final materiaController = TextEditingController();
    final salonController = TextEditingController();
    final profesorController = TextEditingController();
    final diaController = TextEditingController();
    final inicioController = TextEditingController();
    final finController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Nueva clase',
          style: AppTextStyles.sectionTitle,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomInput(
                controller: materiaController,
                label: 'Materia',
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: salonController,
                label: 'Salón',
                icon: Icons.meeting_room_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: profesorController,
                label: 'Profesor',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: diaController,
                label: 'Día',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: inicioController,
                label: 'Hora inicio',
                icon: Icons.access_time_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CustomInput(
                controller: finController,
                label: 'Hora fin',
                icon: Icons.schedule_outlined,
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
              if (materiaController.text.trim().isEmpty ||
                  salonController.text.trim().isEmpty ||
                  profesorController.text.trim().isEmpty ||
                  diaController.text.trim().isEmpty ||
                  inicioController.text.trim().isEmpty ||
                  finController.text.trim().isEmpty) {
                return;
              }

              context.read<PlannerProvider>().addClase(
                    Clase(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      materia: materiaController.text.trim(),
                      salon: salonController.text.trim(),
                      profesor: profesorController.text.trim(),
                      dia: diaController.text.trim(),
                      horaInicio: inicioController.text.trim(),
                      horaFin: finController.text.trim(),
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

class _ClaseCard extends StatelessWidget {
  final Clase clase;

  const _ClaseCard({required this.clase});

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.navIndicator,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.schedule,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clase.materia,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${clase.dia} • ${clase.horaInicio} - ${clase.horaFin}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${clase.salon} • ${clase.profesor}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
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

class _EmptyScheduleCard extends StatelessWidget {
  const _EmptyScheduleCard();

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
            Icons.event_note_outlined,
            size: 34,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Todavía no has agregado clases.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Empieza agregando tu horario para tener todo más organizado.',
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