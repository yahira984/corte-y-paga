import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // INIT: CONFIGURACIÓN COMPLETA
  // ---------------------------------------------------------------------------
  Future<void> init() async {
    // ANDROID
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inicializar plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Inicializar zona horaria
    tz.initializeTimeZones();

    // PEDIR PERMISO EN ANDROID 13+
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    androidPlugin?.requestNotificationsPermission();
  }

  // ---------------------------------------------------------------------------
  // CANAL DE NOTIFICACIONES — DEBE COINCIDIR CON ANDROIDMANIFEST
  // ---------------------------------------------------------------------------
  final AndroidNotificationDetails _androidNotificationDetails =
  const AndroidNotificationDetails(
    'citas_channel', // <- ESTE YA COINCIDE
    'Recordatorios de Citas',
    channelDescription: 'Canal para notificar citas de Corte & Paga',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  // ---------------------------------------------------------------------------
  // NOTIFICACIÓN INMEDIATA (para pruebas)
  // ---------------------------------------------------------------------------
  Future<void> showNotification(int id, String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  // ---------------------------------------------------------------------------
  // PROGRAMAR NOTIFICACIÓN A UNA FECHA / HORA EXACTA
  // ---------------------------------------------------------------------------
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime scheduledTZTime =
    tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      NotificationDetails(android: _androidNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ---------------------------------------------------------------------------
  // PROGRAMAR NOTIFICACIÓN 10 MINUTOS ANTES DE UNA CITA
  // ---------------------------------------------------------------------------
  Future<void> schedule10MinBefore({
    required int id,
    required String cliente,
    required DateTime fechaCita,
  }) async {
    final DateTime notificationTime = fechaCita.subtract(
      const Duration(minutes: 10),
    );

    await scheduleNotification(
      id: id,
      title: 'Cita próxima',
      body: 'Tu cliente $cliente llega en 10 minutos.',
      scheduledTime: notificationTime,
    );
  }

  // ---------------------------------------------------------------------------
  // CANCELAR (por si borras una cita)
  // ---------------------------------------------------------------------------
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
