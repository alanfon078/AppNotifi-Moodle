import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'notification_service.dart';
import 'moodle_service.dart';

// Esta función se ejecuta en segundo plano
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 Tarea en segundo plano ejecutada: $task');

    try {
      final moodleService = MoodleService();
      final notificationService = NotificationService();

      await notificationService.init();

      final loggedIn = await moodleService.isLoggedIn();
      if (!loggedIn) return Future.value(true);

      final tasks = await moodleService.getUpcomingTasks();
      for (var task in tasks) {
        final dueDate = DateTime.fromMillisecondsSinceEpoch(task['timestart'] * 1000);
        await notificationService.scheduleTaskNotifications(
          task['id'],
          task['name'],
          task['course']['fullname'],
          dueDate,
        );
      }
      print('✅ Notificaciones actualizadas en segundo plano');
    } catch (e) {
      print('❌ Error en background: $e');
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  await NotificationService().init();

  // Inicializar WorkManager para segundo plano
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Registrar tarea periódica cada 1 hora
  await Workmanager().registerPeriodicTask(
    'sync-moodle-tasks',
    'syncMoodleTasks',
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );

  runApp(const RecordatoriosMoodleApp());
}

class RecordatoriosMoodleApp extends StatelessWidget {
  const RecordatoriosMoodleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorios Moodle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}