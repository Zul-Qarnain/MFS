import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.providerTxnId});

  final String providerTxnId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Center(
        child: Text('Success — txn=$providerTxnId'),
      ),
    );
  }
}
