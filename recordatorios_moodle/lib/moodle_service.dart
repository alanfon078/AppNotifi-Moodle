import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodleService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = 'https://pev.surguanajuato.tecnm.mx';

  Future<bool> loginAndSaveToken(String username, String password, {bool rememberCredentials = false}) async {
    final url = Uri.parse('$_baseUrl/login/token.php?username=$username&password=$password&service=moodle_mobile_app');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('token')) {
          await _secureStorage.write(key: 'moodle_token', value: data['token']);
          print('✅ Token guardado de forma segura.');

          if (rememberCredentials) {
            await _secureStorage.write(key: 'saved_username', value: username);
            await _secureStorage.write(key: 'saved_password', value: password);
            await _secureStorage.write(key: 'remember_credentials', value: 'true');
          } else {
            await _secureStorage.delete(key: 'saved_username');
            await _secureStorage.delete(key: 'saved_password');
            await _secureStorage.write(key: 'remember_credentials', value: 'false');
          }
          return true;
        } else if (data.containsKey('error')) {
          print('❌ Error de Moodle: ${data['error']}');
          return false;
        }
      }
    } catch (e) {
      print('⚠️ Error de red o ejecución: $e');
    }
    return false;
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'moodle_token');
    return token != null && token.isNotEmpty;
  }

  // Leer credenciales guardadas
  Future<Map<String, String?>> getSavedCredentials() async {
    final remember = await _secureStorage.read(key: 'remember_credentials');
    if (remember == 'true') {
      return {
        'username': await _secureStorage.read(key: 'saved_username'),
        'password': await _secureStorage.read(key: 'saved_password'),
        'remember': 'true',
      };
    }
    return {'remember': 'false'};
  }

  Future<List<dynamic>> getUpcomingTasks() async {
    final token = await getToken();
    if (token == null) return [];
    final url = Uri.parse('$_baseUrl/webservice/rest/server.php?wstoken=$token&wsfunction=core_calendar_get_calendar_upcoming_view&moodlewsrestformat=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('events')) return data['events'];
      }
    } catch (e) {
      print('Error obteniendo tareas: $e');
    }
    return [];
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'moodle_token');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'moodle_token');
  }
}