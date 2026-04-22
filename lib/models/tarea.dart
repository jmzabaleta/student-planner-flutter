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
}
