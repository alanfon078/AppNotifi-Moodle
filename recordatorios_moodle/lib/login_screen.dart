import 'package:flutter/material.dart';
import 'moodle_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final MoodleService _moodleService = MoodleService();

  bool _isLoading = true;
  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Si ya tiene token válido, ir directo al dashboard
    final loggedIn = await _moodleService.isLoggedIn();
    if (loggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    // Si no, cargar credenciales guardadas si existen
    final saved = await _moodleService.getSavedCredentials();
    if (saved['remember'] == 'true') {
      _usernameController.text = saved['username'] ?? '';
      _passwordController.text = saved['password'] ?? '';
      setState(() { _rememberCredentials = true; });
    }

    setState(() { _isLoading = false; });
  }

  void _handleLogin() async {
    setState(() { _isLoading = true; });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      setState(() { _isLoading = false; });
      return;
    }

    final success = await _moodleService.loginAndSaveToken(
      username,
      password,
      rememberCredentials: _rememberCredentials,
    );

    setState(() { _isLoading = false; });

    if (success) {
      if (!_rememberCredentials) _passwordController.clear();
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas o error de red')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Recordatorios Moodle')),
      body: SingleChildScrollView(  // ← Esto soluciona el overflow
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),  // ← Espacio superior para centrar visualmente
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _rememberCredentials,
                  onChanged: (val) => setState(() => _rememberCredentials = val ?? false),
                ),
                Text('Recordar mis datos'),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20), // ← Espacio inferior para que no quede pegado
          ],
        ),
      ),
    );
  }
}