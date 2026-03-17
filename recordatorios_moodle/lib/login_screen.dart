import 'package:flutter/material.dart';
import 'moodle_service.dart'; // Importar el backend local

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final MoodleService _moodleService = MoodleService();
  
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      setState(() { _isLoading = false; });
      return;
    }

    //Llamar al backend
    final success = await _moodleService.loginAndSaveToken(username, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Limpiar las contraseñas de la memoria de los controladores por seguridad
      _passwordController.clear(); 
      
      // Navegar a la siguiente pantalla
      Navigator.pushReplacementNamed(context, '/dashboard'); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas o error de red')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recordatorios Moodle')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.blue),
            SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Número de Control',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true, // Oculta la contraseña
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}