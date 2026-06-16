import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _error = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user;
      if (_isLogin) {
        user = await _auth.signInWithEmail(_email, _password);
      } else {
        user = await _auth.registerWithEmail(_email, _password);
      }
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        setState(() {
          _error = 'Authentication failed. Please check your credentials.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrimeFleet Login'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 80, color: Color(0xFF0D47A1)),
              const SizedBox(height: 32),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email)),
                onSaved: (value) => _email = value!,
                validator: (value) =>
                value!.isEmpty ? 'Enter an email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                onSaved: (value) => _password = value!,
                validator: (value) =>
                value!.isEmpty ? 'Enter a password' : null,
              ),
              const SizedBox(height: 16),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    minimumSize: const Size(double.infinity, 50)),
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}