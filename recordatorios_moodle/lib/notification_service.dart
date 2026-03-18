import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

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
    final timesToNotify = [
      dueDate.subtract(const Duration(hours: 24)),
      dueDate.subtract(const Duration(hours: 12)),
      dueDate.subtract(const Duration(hours: 6)),
      dueDate.subtract(const Duration(hours: 1)),
    ];

    final messages = [
      '¡Mañana vence esta tarea!',
      'Quedan 12 horas para tu entrega.',
      '¡Hoy vence esta tarea!',
      '¡URGENTE! Queda 1 hora para el cierre.',
    ];

    for (int i = 0; i < timesToNotify.length; i++) {
      final scheduledTime = timesToNotify[i];

      if (scheduledTime.isAfter(DateTime.now())) {
        // v21: zonedSchedule ahora usa parámetros nombrados obligatorios
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: int.parse('$taskId$i'),
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