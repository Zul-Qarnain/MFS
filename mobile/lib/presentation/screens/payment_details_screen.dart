import 'package:flutter/material.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key, this.qrPayload});

  final String? qrPayload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: Center(
        child: Text('PaymentDetailsScreen — qr=$qrPayload'),
      ),
    );
  }
}
