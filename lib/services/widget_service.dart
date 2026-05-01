import 'package:home_widget/home_widget.dart';
import 'package:gaara/models/clase.dart';

class WidgetService {
  /// Actualiza el widget con el horario actual
  static Future<void> updateScheduleWidget(List<Clase> clases) async {
    try {
      // Ordena las clases por hora
      clases.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      // Obtiene la próxima clase (hoy)
      final now = DateTime.now();
      final currentDay = _getDayName(now.weekday);
      
      Clase? nextClass;
      for (var clase in clases) {
        if (clase.dia.toLowerCase() == currentDay.toLowerCase()) {
          // Compara la hora de fin con la hora actual
          if (_isTimeAfterNow(clase.horaFin)) {
            nextClass = clase;
            break;
          }
        }
      }

      // Prepara los datos para el widget
      if (nextClass != null) {
        await HomeWidget.saveWidgetData<String>(
          'nextClassName',
          nextClass.materia,
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassTime',
          '${nextClass.horaInicio} - ${nextClass.horaFin}',
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassProfesor',
          nextClass.profesor,
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassAula',
          nextClass.salon,
        );
      } else {
        // No hay clases pendientes
        await HomeWidget.saveWidgetData<String>(
          'nextClassName',
          'Sin clases',
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassTime',
          'Sin horario',
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassProfesor',
          '',
        );
        await HomeWidget.saveWidgetData<String>(
          'nextClassAula',
          '',
        );
      }

      // Actualiza el widget
      await HomeWidget.updateWidget(
        name: 'GaaraScheduleWidget',
        iOSName: 'GaaraScheduleWidget',
      );
    } catch (e) {
      // Silenciosamente ignora errores si el widget no está disponible
    }
  }

  /// Convierte el número del día (1-7) a nombre del día
  static String _getDayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[weekday - 1];
  }

  /// Verifica si una hora está después de la hora actual
  static bool _isTimeAfterNow(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return false;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      
      if (hour == null || minute == null) return false;

      final now = DateTime.now();
      final classTime = DateTime(now.year, now.month, now.day, hour, minute);

      return classTime.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  /// Abre la pantalla de añadir widget
  static Future<void> openWidgetConfiguration() async {
    // home_widget no proporciona un método para abrir la configuración
    // El usuario debe agregar el widget manualmente desde el panel de widgets del dispositivo
    // Esta función se mantiene para posible uso futuro
  }
}