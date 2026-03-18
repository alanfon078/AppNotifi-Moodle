import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Zona horaria real del dispositivo
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotifications(
      int taskId, String taskName, String courseName, DateTime dueDate) async {

    // ── PRUEBA INMEDIATA: llega en 10 segundos ──
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 9999,
      title: '🔔 PRUEBA',
      body: 'Si ves esto, las notificaciones funcionan ✅',
      scheduledDate: tz.TZDateTime.from(testTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'moodle_tasks_channel',
          'Recordatorios de Tareas',
          channelDescription: 'Notificaciones para tareas próximas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    // ── FIN PRUEBA ──

    // timesToNotify y messages deben tener el mismo número de elementos
    final timesToNotify = [
      dueDate.subtract(const Duration(minutes: 2)), // PRUEBA: notifica en 2 min
      dueDate.subtract(const Duration(hours: 24)),
      dueDate.subtract(const Duration(hours: 12)),
      dueDate.subtract(const Duration(hours: 6)),
      dueDate.subtract(const Duration(hours: 1)),
    ];

    final messages = [
      '🔔 PRUEBA: Notificación de prueba activa.',
      '¡Mañana vence esta tarea!',
      'Quedan 12 horas para tu entrega.',
      '¡Hoy vence esta tarea!',
      '¡URGENTE! Queda 1 hora para el cierre.',
    ];

    for (int i = 0; i < timesToNotify.length; i++) {
      final scheduledTime = timesToNotify[i];

      if (scheduledTime.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: taskId * 10 + i, // Evita IDs duplicados con parse
          title: '⏰ $courseName',
          body: '${messages[i]} $taskName',
          scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'moodle_tasks_channel',
              'Recordatorios de Tareas',
              channelDescription: 'Notificaciones para tareas próximas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }
}