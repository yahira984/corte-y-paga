import 'package:proyecto_av/data/database/database_helper.dart';
import 'package:proyecto_av/data/models/cita_model.dart';
import 'package:proyecto_av/utils/notification_service.dart';

/*
* Repositorio para manejar la lógica de negocio de las Citas.
* Este repositorio es especial:
* 1. Habla con la Base de Datos (DatabaseHelper)
* 2. Habla con el Servicio de Notificaciones (NotificationService)
*/
class CitaRepository {

  final dbHelper = DatabaseHelper.instance;
  final notificationService = NotificationService.instance;

  // --- MÉTODOS PÚBLICOS ---

  Future<int> insertCita(Cita cita) async {
    // 1. Inserta la cita en la BD
    final id = await dbHelper.insertCita(cita);

    // 2. Si se insertó, programa la notificación
    //    Programamos la notificación 1 hora antes.
    if (id > 0) {
      try {
        final fechaHora = DateTime.parse(cita.fechaHora);
        final horaNotificacion = fechaHora.subtract(const Duration(hours: 1));

        // Solo programar si la cita es en el futuro
        if (horaNotificacion.isAfter(DateTime.now())) {
          notificationService.scheduleNotification(
            id: id, // Usamos el ID de la cita como ID de la notificación
            title: 'Recordatorio de Cita',
            body: 'Tienes una cita programada en 1 hora.',
            scheduledTime: horaNotificacion,
          );
        }
      } catch (e) {
        // Manejar error si la fechaHora no es válida
        print('Error al programar notificación: $e');
      }
    }
    return id;
  }

  Future<List<Cita>> getAllCitas() async {
    return await dbHelper.getAllCitas();
  }

  Future<List<Cita>> getCitasPorDia(DateTime dia) async {
    return await dbHelper.getCitasPorDia(dia);
  }

  Future<int> updateCita(Cita cita) async {
    // 1. Actualiza la cita en la BD
    final rowsAffected = await dbHelper.updateCita(cita);

    if (rowsAffected > 0) {
      try {
        // 2. Reprograma la notificación: Cancela la vieja y crea una nueva
        await notificationService.cancelNotification(cita.id!);

        final fechaHora = DateTime.parse(cita.fechaHora);
        final horaNotificacion = fechaHora.subtract(const Duration(hours: 1));

        if (horaNotificacion.isAfter(DateTime.now())) {
          notificationService.scheduleNotification(
            id: cita.id!,
            title: 'Cita Actualizada',
            body: 'Tu cita ha sido reprogramada. Tienes una cita en 1 hora.',
            scheduledTime: horaNotificacion,
          );
        }
      } catch (e) {
        print('Error al reprogramar notificación: $e');
      }
    }
    return rowsAffected;
  }

  Future<int> deleteCita(int id) async {
    // 1. Cancela la notificación primero
    try {
      await notificationService.cancelNotification(id);
    } catch (e) {
      print('Error al cancelar notificación: $e');
    }

    // 2. Borra la cita de la BD
    return await dbHelper.deleteCita(id);
  }
}