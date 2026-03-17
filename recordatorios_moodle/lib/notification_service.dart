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

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // En la v14, initialize recibe el objeto directamente (sin la etiqueta "settings:")
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Solicitar permisos para Android 13+ (En v14 el método se llama requestPermission)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  Future<void> scheduleTaskNotifications(int taskId, String taskName, String courseName, DateTime dueDate) async {
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
      '¡URGENTE! Queda 1 hora para el cierre.'
    ];

    for (int i = 0; i < timesToNotify.length; i++) {
      final scheduledTime = timesToNotify[i];

      if (scheduledTime.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          int.parse('${taskId}${i}'),         // 1. ID
          '⏰ $courseName',                     // 2. Título
          '${messages[i]} $taskName',         // 3. Cuerpo del mensaje
          tz.TZDateTime.from(scheduledTime, tz.local), // 4. Fecha programada
          NotificationDetails(          // 5. Detalles de la notificación
            android: AndroidNotificationDetails(
              'moodle_tasks_channel',
              'Recordatorios de Tareas',
              channelDescription: 'Notificaciones para tareas próximas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}