import 'package:flutter/material.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing')),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
