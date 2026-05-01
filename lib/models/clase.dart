class Clase {
  final String id;
  final String materia;
  final String salon;
  final String profesor;
  final String dia;
  final String horaInicio;
  final String horaFin;

  Clase({
    required this.id,
    required this.materia,
    required this.salon,
    required this.profesor,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materia': materia,
      'salon': salon,
      'profesor': profesor,
      'dia': dia,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
    };
  }

  factory Clase.fromMap(Map<String, dynamic> map) {
    return Clase(
      id: map['id'] as String? ?? '',
      materia: map['materia'] as String? ?? 'Sin materia',
      salon: map['salon'] as String? ?? '',
      profesor: map['profesor'] as String? ?? '',
      dia: map['dia'] as String? ?? 'Lunes',
      horaInicio: map['horaInicio'] as String? ?? '07:00',
      horaFin: map['horaFin'] as String? ?? '08:00',
    );
  }

  Clase copyWith({
    String? id,
    String? materia,
    String? salon,
    String? profesor,
    String? dia,
    String? horaInicio,
    String? horaFin,
  }) {
    return Clase(
      id: id ?? this.id,
      materia: materia ?? this.materia,
      salon: salon ?? this.salon,
      profesor: profesor ?? this.profesor,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }
}
