import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // Esto inicializa las zonas horarias y permisos

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
      // Definir la ruta inicial
      initialRoute: '/login',
      // Definir el mapa de rutas
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}