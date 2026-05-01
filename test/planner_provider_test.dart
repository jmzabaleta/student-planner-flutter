import 'package:flutter_test/flutter_test.dart';
import 'package:gaara/models/clase.dart';
import 'package:gaara/models/nota.dart';
import 'package:gaara/models/recordatorio.dart';
import 'package:gaara/models/tarea.dart';
import 'package:gaara/providers/planner_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guarda, actualiza, elimina y recarga clases', () async {
    final provider = PlannerProvider();
    await provider.loadData();

    final clase = Clase(
      id: 'clase-1',
      materia: 'Matemáticas',
      salon: 'Aula 201',
      profesor: 'Laura',
      dia: 'Lunes',
      horaInicio: '08:00',
      horaFin: '09:00',
    );

    await provider.addClase(clase);
    expect(provider.clases, hasLength(1));

    await provider.updateClase(clase.copyWith(salon: 'Aula 305'));
    expect(provider.clases.single.salon, 'Aula 305');

    final reloaded = PlannerProvider();
    await reloaded.loadData();
    expect(reloaded.clases.single.materia, 'Matemáticas');

    await provider.deleteClase('clase-1');
    expect(provider.clases, isEmpty);
  });

  test('guarda tareas y permite completarlas', () async {
    final provider = PlannerProvider();
    await provider.loadData();

    final tarea = Tarea(
      id: 'tarea-1',
      titulo: 'Ensayo',
      materia: 'Lengua',
      fechaEntrega: DateTime(2026, 5, 8),
    );

    await provider.addTarea(tarea);
    expect(provider.tareasPendientes, hasLength(1));

    await provider.toggleTarea('tarea-1');
    expect(provider.tareas.single.completada, isTrue);
    expect(provider.tareasPendientes, isEmpty);

    await provider.updateTarea(tarea.copyWith(titulo: 'Ensayo final'));
    expect(provider.tareas.single.titulo, 'Ensayo final');
  });

  test('guarda recordatorios y notas de forma persistente', () async {
    final provider = PlannerProvider();
    await provider.loadData();

    final recordatorio = Recordatorio(
      id: 'recordatorio-1',
      titulo: 'Examen',
      descripcion: 'Repasar capítulos 1 y 2',
      fecha: DateTime(2026, 5, 10, 9),
    );
    final nota = Nota(
      id: 'nota-1',
      titulo: 'Idea',
      contenido: 'Preparar mapa mental',
      fecha: DateTime(2026, 5, 1),
    );

    await provider.addRecordatorio(recordatorio);
    await provider.addNota(nota);

    final reloaded = PlannerProvider();
    await reloaded.loadData();

    expect(reloaded.recordatorios.single.titulo, 'Examen');
    expect(reloaded.notas.single.contenido, 'Preparar mapa mental');

    await provider.deleteRecordatorio('recordatorio-1');
    await provider.deleteNota('nota-1');
    expect(provider.recordatorios, isEmpty);
    expect(provider.notas, isEmpty);
  });

  test('ignora datos corruptos del almacenamiento local', () async {
    SharedPreferences.setMockInitialValues({'clases': 'esto no es json'});

    final provider = PlannerProvider();
    await provider.loadData();

    expect(provider.clases, isEmpty);
  });
}
