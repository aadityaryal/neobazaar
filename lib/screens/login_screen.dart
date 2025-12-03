import 'package:flutter/material.dart';
import '../widgets/my_textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login to NeoBazaar',
                style: TextStyle(color: Color(0xFFFF9933), fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              MyTextFormField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter email (e.g., user@neobazaar.np)',
                error: 'Email required',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              MyTextFormField(
                controller: passwordController,
                label: 'Password',
                hint: 'Enter secure password',
                error: 'Password required',
                obscureText: true,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9933), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // No navigation yet — placeholder for later
                    }
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}