import 'package:flutter/material.dart';
import 'moodle_service.dart';
import 'notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MoodleService _moodleService = MoodleService();
  final NotificationService _notificationService = NotificationService();

  List<dynamic> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {

    // ── PRUEBA: siempre programa esto, sin importar si hay tareas ──
    final DateTime examDate = DateTime(2026, 3, 25, 11, 0, 0);
    await _notificationService.scheduleTaskNotifications(
      999,
      'Examen Final',
      'Tu Materia',
      examDate,
    );
    // ── FIN PRUEBA ──

    final tasks = await _moodleService.getUpcomingTasks();

     for (var task in tasks) {
       final dueDate = DateTime.fromMillisecondsSinceEpoch(task['timestart'] * 1000);
       await _notificationService.scheduleTaskNotifications(
         task['id'],
         task['name'],
         task['course']['fullname'],
         dueDate,
       );
     }

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _moodleService.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(child: Text('¡Libre de tareas! 🎉', style: TextStyle(fontSize: 20)))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final dueDate = DateTime.fromMillisecondsSinceEpoch(task['timestart'] * 1000);

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: const Icon(Icons.assignment, color: Colors.blue),
              ),
              title: Text(task['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['course']['fullname'], style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'Vence: ${dueDate.day}/${dueDate.month}/${dueDate.year} - ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}