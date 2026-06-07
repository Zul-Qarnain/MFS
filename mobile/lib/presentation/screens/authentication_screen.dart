import 'package:flutter/material.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticate')),
      body: const Center(
        child: Text('AuthenticationScreen — placeholder'),
      ),
    );
  }
}
