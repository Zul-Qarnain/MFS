import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MFS Unified')),
      body: const Center(
        child: Text('HomeScreen — placeholder (validation sprint)'),
      ),
    );
  }
}
