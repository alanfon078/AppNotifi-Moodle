import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initialSettings);

    // Pedir permiso en Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotifications(int taskId, String taskName, String courseName, DateTime dueDate) async {
    // Definimos los tiempos de las 4 notificaciones
    final timesToNotify = [
      dueDate.subtract(const Duration(hours: 24)), // 1 día antes
      dueDate.subtract(const Duration(hours: 12)), // Medio día antes
      dueDate.subtract(const Duration(hours: 6)),  // El día de la entrega
      dueDate.subtract(const Duration(hours: 1)),  // 1 hora antes
    ];

    final messages = [
      '¡Mañana vence esta tarea!',
      'Quedan 12 horas para tu entrega.',
      '¡Hoy vence esta tarea!',
      '¡URGENTE! Queda 1 hora para el cierre.'
    ];

    for (int i = 0; i < timesToNotify.length; i++) {
      final scheduledTime = timesToNotify[i];

      // Solo programar si la fecha está en el futuro
      if (scheduledTime.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          int.parse('${taskId}${i}'), // ID único para cada notificación
          '⏰ $courseName',
          '${messages[i]} $taskName',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'moodle_tasks_channel',
              'Recordatorios de Tareas',
              channelDescription: 'Notificaciones para tareas próximas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}