class Nota {
  final String id;
  final String titulo;
  final String contenido;
  final DateTime fecha;

  Nota({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'] as String? ?? '',
      titulo: map['titulo'] as String? ?? 'Sin título',
      contenido: map['contenido'] as String? ?? '',
      fecha: DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Nota copyWith({
    String? id,
    String? titulo,
    String? contenido,
    DateTime? fecha,
  }) {
    return Nota(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fecha: fecha ?? this.fecha,
    );
  }
}
