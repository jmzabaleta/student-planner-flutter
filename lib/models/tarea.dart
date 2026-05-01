class Tarea {
  final String id;
  final String titulo;
  final String materia;
  final DateTime fechaEntrega;
  bool completada;

  Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.fechaEntrega,
    this.completada = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'materia': materia,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'completada': completada,
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as String? ?? '',
      titulo: map['titulo'] as String? ?? 'Sin título',
      materia: map['materia'] as String? ?? '',
      fechaEntrega:
          DateTime.tryParse(map['fechaEntrega'] as String? ?? '') ??
          DateTime.now(),
      completada: map['completada'] as bool? ?? false,
    );
  }

  Tarea copyWith({
    String? id,
    String? titulo,
    String? materia,
    DateTime? fechaEntrega,
    bool? completada,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      materia: materia ?? this.materia,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      completada: completada ?? this.completada,
    );
  }
}
