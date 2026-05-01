import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/nota.dart';
import '../providers/planner_provider.dart';
import '../widgets/section_title.dart';

class NotasScreen extends StatelessWidget {
  const NotasScreen({super.key});

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
            160,
          ),
          children: [
            const SectionTitle(
              title: 'Notas rápidas',
              subtitle:
                  'Ideas, apuntes, pendientes y cualquier chispa académica.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (planner.notas.isEmpty)
              const _EmptyNotesCard()
            else
              ...planner.notas.map(
                (nota) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Dismissible(
                    key: ValueKey(nota.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context, nota),
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
                    onDismissed: (_) => _deleteNote(context, nota),
                    child: _NotaCard(
                      nota: nota,
                      onTap: () => _showNoteDialog(context, nota: nota),
                      onEdit: () => _showNoteDialog(context, nota: nota),
                      onDelete: () => _deleteNote(context, nota),
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
            onPressed: () => _showNoteDialog(context),
            icon: const Icon(Icons.edit_note),
            label: const Text(
              'Agregar nota',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Nota nota) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text(
          '¿Quieres eliminar "${nota.titulo}"?',
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

  void _deleteNote(BuildContext context, Nota nota) {
    final provider = context.read<PlannerProvider>();
    provider.deleteNota(nota.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Nota eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.accentSoft,
          onPressed: () => provider.addNota(nota),
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, {Nota? nota}) {
    final tituloController = TextEditingController(text: nota?.titulo ?? '');
    final contenidoController = TextEditingController(
      text: nota?.contenido ?? '',
    );
    final isEditing = nota != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
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
                  isEditing ? 'Editar nota' : 'Nueva nota',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: tituloController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: contenidoController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    alignLabelWithHint: true,
                  ),
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
                          if (tituloController.text.trim().isEmpty ||
                              contenidoController.text.trim().isEmpty) {
                            return;
                          }

                          final provider = context.read<PlannerProvider>();
                          if (isEditing) {
                            provider.updateNota(
                              nota.copyWith(
                                titulo: tituloController.text.trim(),
                                contenido: contenidoController.text.trim(),
                              ),
                            );
                          } else {
                            provider.addNota(
                              Nota(
                                id: DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                                titulo: tituloController.text.trim(),
                                contenido: contenidoController.text.trim(),
                                fecha: DateTime.now(),
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
    ).whenComplete(() {
      tituloController.dispose();
      contenidoController.dispose();
    });
  }
}

class _NotaCard extends StatelessWidget {
  final Nota nota;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NotaCard({
    required this.nota,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.note_alt_outlined,
                  color: scheme.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nota.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nota.contenido,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(nota.fecha),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_NoteAction>(
                tooltip: 'Opciones',
                onSelected: (action) {
                  switch (action) {
                    case _NoteAction.edit:
                      onEdit();
                    case _NoteAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _NoteAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.delete,
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

class _EmptyNotesCard extends StatelessWidget {
  const _EmptyNotesCard();

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
            Icons.sticky_note_2_outlined,
            size: 34,
            color: scheme.onSurface.withValues(alpha: 0.62),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Todavía no has creado notas.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Guarda ideas, apuntes o pendientes rápidos para tenerlos a mano.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _NoteAction { edit, delete }

String _formatDate(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}
