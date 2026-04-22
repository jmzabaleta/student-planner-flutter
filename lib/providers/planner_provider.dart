import 'package:flutter/material.dart';

import '../models/clase.dart';
import '../models/nota.dart';
import '../models/recordatorio.dart';
import '../models/tarea.dart';

class PlannerProvider extends ChangeNotifier {
  final List<Clase> _clases = [];
  final List<Nota> _notas = [];
  final List<Tarea> _tareas = [];
  final List<Recordatorio> _recordatorios = [];

  List<Clase> get clases => List.unmodifiable(_clases);
  List<Nota> get notas => List.unmodifiable(_notas);
  List<Tarea> get tareas => List.unmodifiable(_tareas);
  List<Recordatorio> get recordatorios => List.unmodifiable(_recordatorios);

  List<Tarea> get tareasPendientes =>
      _tareas.where((t) => !t.completada).toList()
        ..sort((a, b) => a.fechaEntrega.compareTo(b.fechaEntrega));

  List<Recordatorio> get proximosRecordatorios =>
      List<Recordatorio>.from(_recordatorios)
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

  void seedData() {
    if (_clases.isNotEmpty) return;

    _clases.addAll([
      Clase(
        id: '1',
        materia: 'Bases de Datos',
        salon: 'A-203',
        profesor: 'Ing. Ramírez',
        dia: 'Lunes',
        horaInicio: '08:00',
        horaFin: '10:00',
      ),
      Clase(
        id: '2',
        materia: 'Programación',
        salon: 'B-101',
        profesor: 'Ing. Torres',
        dia: 'Martes',
        horaInicio: '10:00',
        horaFin: '12:00',
      ),
    ]);

    _notas.add(
      Nota(
        id: '1',
        titulo: 'Repasar parcial',
        contenido: 'Estudiar normal, binomial y ejercicios de inferencia.',
        fecha: DateTime.now(),
      ),
    );

    _tareas.addAll([
      Tarea(
        id: '1',
        titulo: 'Taller de SQL',
        materia: 'Bases de Datos',
        fechaEntrega: DateTime.now().add(const Duration(days: 2)),
      ),
      Tarea(
        id: '2',
        titulo: 'Mapa conceptual',
        materia: 'Ingeniería de Software',
        fechaEntrega: DateTime.now().add(const Duration(days: 4)),
      ),
    ]);

    _recordatorios.add(
      Recordatorio(
        id: '1',
        titulo: 'Llevar USB',
        descripcion: 'Guardar presentación antes de salir.',
        fecha: DateTime.now().add(const Duration(hours: 12)),
      ),
    );

    notifyListeners();
  }

  void addClase(Clase clase) {
    _clases.add(clase);
    notifyListeners();
  }

  void addNota(Nota nota) {
    _notas.insert(0, nota);
    notifyListeners();
  }

  void addTarea(Tarea tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void toggleTarea(String id) {
    final index = _tareas.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tareas[index].completada = !_tareas[index].completada;
    notifyListeners();
  }

  void addRecordatorio(Recordatorio recordatorio) {
    _recordatorios.add(recordatorio);
    notifyListeners();
  }
}
