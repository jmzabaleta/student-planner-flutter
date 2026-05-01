class Recordatorio {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  Recordatorio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'] as String? ?? '',
      titulo: map['titulo'] as String? ?? 'Sin título',
      descripcion: map['descripcion'] as String? ?? '',
      fecha: DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Recordatorio copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
    );
  }
}
