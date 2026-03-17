import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodleService {
  // Inicializar el almacenamiento seguro
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  final String _baseUrl = 'https://pev.surguanajuato.tecnm.mx';

  // Función para hacer login y guardar el token
  Future<bool> loginAndSaveToken(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login/token.php?username=$username&password=$password&service=moodle_mobile_app');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('token')) {
          final token = data['token'];
          
          // Guardamos el token encriptado en el dispositivo, no en texto plano.
          await _secureStorage.write(key: 'moodle_token', value: token);
          print('✅ Token guardado de forma segura.');
          return true; // Login exitoso
        } else if (data.containsKey('error')) {
          print('❌ Error de Moodle: ${data['error']}');
          return false;
        }
      }
    } catch (e) {
      print('⚠️ Error de red o ejecución: $e');
    }
    
    return false; // Si llegamos aquí, algo falló
  }

  // Función para obtener las tareas
  Future<List<dynamic>> getUpcomingTasks() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('$_baseUrl/webservice/rest/server.php?wstoken=$token&wsfunction=core_calendar_get_calendar_upcoming_view&moodlewsrestformat=json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('events')) {
          return data['events'];
        }
      }
    } catch (e) {
      print('Error obteniendo tareas: $e');
    }
    return [];
  }

  // Función auxiliar para leer el token cuando queramos consultar las tareas
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'moodle_token');
  }

  // Función para cerrar sesión (borrar el token)
  Future<void> logout() async {
    await _secureStorage.delete(key: 'moodle_token');
  }
}