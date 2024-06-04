// ai_assistant/lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_assistant/services/auth_service.dart';
import 'package:ai_assistant/screens/ai_assistant_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLogin = true;
  String errorMessage = '';

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        User? user = await _authService.signInWithEmail(email, password);
        if (user != null) {
          setState(() {
            errorMessage = '';
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AiAssistantScreen()),
          );
        } else {
          setState(() {
            errorMessage = 'Login failed';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
    }
  }

  void _navigateToRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        errorMessage = result;
        isLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double inputWidth = isMobile ? double.infinity : 300;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: inputWidth,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    onSubmitted: (value) => _login(),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: inputWidth,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSubmitted: (value) => _login(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: _navigateToRegister,
                child: Text('Don\'t have an account? Register here.'),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = '';

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        User? user = await _authService.registerWithEmail(email, password);
        if (user != null) {
          Navigator.pop(context, 'Registration successful. Please log in.');
        } else {
          setState(() {
            errorMessage = 'Registration failed';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double inputWidth = isMobile ? double.infinity : 300;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: inputWidth,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: inputWidth,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSubmitted: (value) => _register(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Already have an account? Login here.'),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
