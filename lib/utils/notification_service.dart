import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // --- INICIO DEL PATRÓN SINGLETON ---
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();
  // --- FIN DEL PATRÓN SINGLETON ---

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 1. Método de inicialización
  Future<void> init() async {
    // --- Configuración de Android ---
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Usa el ícono de tu app

    // --- Configuración de iOS (básica) ---
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // --- Inicialización General ---
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Inicializar la base de datos de zonas horarias
    tz.initializeTimeZones();
  }

  // 2. Detalles del Canal de Notificación (Android)
  final AndroidNotificationDetails _androidNotificationDetails =
  const AndroidNotificationDetails(
    'high_importance_channel', // ID del canal (el mismo que en AndroidManifest.xml)
    'Notificaciones de Citas',
    channelDescription: 'Canal para recordatorios de citas de Corte & Paga',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  // 3. Método para MOSTRAR una notificación INMEDIATAMENTE
  Future<void> showNotification(int id, String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  // 4. Método para PROGRAMAR una notificación (¡El que usaremos!)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {

    // Convertimos la hora del dispositivo a la hora de la zona horaria correcta
    final tz.TZDateTime scheduledTZTime =
    tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime, // Usamos la hora con zona horaria
      NotificationDetails(android: _androidNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 5. Método para CANCELAR una notificación (si se borra la cita)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}