import 'package:flutter/material.dart';

import '../models/clase.dart';
import '../models/nota.dart';
import '../models/recordatorio.dart';
import '../models/tarea.dart';
import '../services/local_storage_service.dart';

class PlannerProvider extends ChangeNotifier {
  List<Clase> _clases = [];
  List<Nota> _notas = [];
  List<Tarea> _tareas = [];
  List<Recordatorio> _recordatorios = [];
  Future<void>? _loadingData;

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

  PlannerProvider() {
    _loadingData = _loadData();
  }

  Future<void> loadData() async {
    final currentLoad = _loadingData;
    if (currentLoad != null) {
      await currentLoad;
      return;
    }

    _loadingData = _loadData();
    await _loadingData;
  }

  Future<void> _loadData() async {
    final clasesData = await LocalStorageService.loadList('clases');
    final notasData = await LocalStorageService.loadList('notas');
    final tareasData = await LocalStorageService.loadList('tareas');
    final recordatoriosData = await LocalStorageService.loadList(
      'recordatorios',
    );

    _clases = clasesData
        .map((e) => Clase.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    _notas = notasData
        .map((e) => Nota.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    _tareas = tareasData
        .map((e) => Tarea.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    _recordatorios = recordatoriosData
        .map((e) => Recordatorio.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    _loadingData = null;
    notifyListeners();
  }

  Future<void> _ensureLoaded() async {
    final currentLoad = _loadingData;
    if (currentLoad != null) {
      await currentLoad;
    }
  }

  Future<void> _saveClases() async {
    await LocalStorageService.saveList(
      'clases',
      _clases.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> _saveNotas() async {
    await LocalStorageService.saveList(
      'notas',
      _notas.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> _saveTareas() async {
    await LocalStorageService.saveList(
      'tareas',
      _tareas.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> _saveRecordatorios() async {
    await LocalStorageService.saveList(
      'recordatorios',
      _recordatorios.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> addClase(Clase clase) async {
    await _ensureLoaded();
    _clases.add(clase);
    await _saveClases();
    notifyListeners();
  }

  Future<void> deleteClase(String id) async {
    await _ensureLoaded();
    _clases.removeWhere((c) => c.id == id);
    await _saveClases();
    notifyListeners();
  }

  Future<void> updateClase(Clase claseActualizada) async {
    await _ensureLoaded();
    final index = _clases.indexWhere((c) => c.id == claseActualizada.id);
    if (index == -1) return;

    _clases[index] = claseActualizada;
    await _saveClases();
    notifyListeners();
  }

  Future<void> addTarea(Tarea tarea) async {
    await _ensureLoaded();
    _tareas.add(tarea);
    await _saveTareas();
    notifyListeners();
  }

  Future<void> deleteTarea(String id) async {
    await _ensureLoaded();
    _tareas.removeWhere((t) => t.id == id);
    await _saveTareas();
    notifyListeners();
  }

  Future<void> updateTarea(Tarea tareaActualizada) async {
    await _ensureLoaded();
    final index = _tareas.indexWhere((t) => t.id == tareaActualizada.id);
    if (index == -1) return;

    _tareas[index] = tareaActualizada;
    await _saveTareas();
    notifyListeners();
  }

  Future<void> toggleTarea(String id) async {
    await _ensureLoaded();
    final index = _tareas.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tareas[index] = _tareas[index].copyWith(
      completada: !_tareas[index].completada,
    );

    await _saveTareas();
    notifyListeners();
  }

  Future<void> addRecordatorio(Recordatorio recordatorio) async {
    await _ensureLoaded();
    _recordatorios.add(recordatorio);
    await _saveRecordatorios();
    notifyListeners();
  }

  Future<void> deleteRecordatorio(String id) async {
    await _ensureLoaded();
    _recordatorios.removeWhere((r) => r.id == id);
    await _saveRecordatorios();
    notifyListeners();
  }

  Future<void> updateRecordatorio(Recordatorio recordatorioActualizado) async {
    await _ensureLoaded();
    final index = _recordatorios.indexWhere(
      (r) => r.id == recordatorioActualizado.id,
    );
    if (index == -1) return;

    _recordatorios[index] = recordatorioActualizado;
    await _saveRecordatorios();
    notifyListeners();
  }

  Future<void> addNota(Nota nota) async {
    await _ensureLoaded();
    _notas.insert(0, nota);
    await _saveNotas();
    notifyListeners();
  }

  Future<void> deleteNota(String id) async {
    await _ensureLoaded();
    _notas.removeWhere((n) => n.id == id);
    await _saveNotas();
    notifyListeners();
  }

  Future<void> updateNota(Nota notaActualizada) async {
    await _ensureLoaded();
    final index = _notas.indexWhere((n) => n.id == notaActualizada.id);
    if (index == -1) return;

    _notas[index] = notaActualizada;
    await _saveNotas();
    notifyListeners();
  }
}
