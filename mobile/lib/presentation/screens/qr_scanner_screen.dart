import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/app_typography.dart';
import '../../domain/entities/qr_payload.dart';
import '../../domain/usecases/parse_qr_code.dart';
import '../router/app_router.dart';

/// QR Scanner — full-screen camera preview with overlay chrome.
///
/// Emits a [QrPayload] on successful scan and navigates to the provider
/// selection / payment details screen.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  final QrParser _parser = QrParser();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final payload = _parser.parse(raw);
      if (payload.kind == QrPayloadKind.unknown) continue;
      _handled = true;
      _controller.stop();
      context.push(Routes.pay, extra: payload);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _OverlayMask(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align the QR code inside the frame',
                style: AppTypography.bodyLg.copyWith(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayMask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MaskPainter());
  }
}

class _MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cut = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cut, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));

    canvas.drawRRect(
      RRect.fromRectAndRadius(cut, const Radius.circular(24)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
