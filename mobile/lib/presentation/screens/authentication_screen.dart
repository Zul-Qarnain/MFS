import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../core/security/biometric_service.dart';

/// Authentication screen — PIN keypad + biometric fallback button.
class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({
    super.key,
    this.mode = AuthMode.verify,
    this.onSuccess,
  });

  final AuthMode mode;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

enum AuthMode { verify, setPin, confirmPin }

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  String _buffer = '';
  String? _error;
  String? _firstPin; // used during `setPin` to capture the confirmation step
  bool _biometricAvailable = false;
  bool _busy = false;

  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    BiometricService().isAvailable().then((v) {
      if (mounted) setState(() => _biometricAvailable = v);
    });
  }

  String get _title {
    switch (widget.mode) {
      case AuthMode.verify:
        return 'Enter your PIN';
      case AuthMode.setPin:
        return _firstPin == null ? 'Create a 6-digit PIN' : 'Confirm your PIN';
      case AuthMode.confirmPin:
        return 'Confirm your PIN';
    }
  }

  void _append(String digit) {
    if (_buffer.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buffer += digit;
      _error = null;
    });
    if (_buffer.length == _pinLength) _submit();
  }

  void _backspace() {
    if (_buffer.isEmpty) return;
    setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);

    switch (widget.mode) {
      case AuthMode.verify:
        // TODO(validation sprint): call AuthRepository.verifyPin(_buffer).
        await Future.delayed(const Duration(milliseconds: 200));
        _reset();
        widget.onSuccess?.call();
        break;

      case AuthMode.setPin:
        if (_firstPin == null) {
          setState(() {
            _firstPin = _buffer;
            _buffer = '';
            _busy = false;
          });
          return;
        }
        if (_firstPin != _buffer) {
          setState(() {
            _error = 'PINs did not match — try again';
            _firstPin = null;
            _buffer = '';
            _busy = false;
          });
          return;
        }
        // TODO(validation sprint): call AuthRepository.setPin(_buffer).
        _reset();
        widget.onSuccess?.call();
        break;

      case AuthMode.confirmPin:
        _reset();
        widget.onSuccess?.call();
        break;
    }
  }

  Future<void> _onBiometric() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await BiometricService().authenticate();
    setState(() => _busy = false);
    if (ok) widget.onSuccess?.call();
  }

  void _reset() {
    setState(() {
      _buffer = '';
      _error = null;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(_title, style: AppTypography.headlineMd),
              const SizedBox(height: 32),
              _PinDots(length: _pinLength, filled: _buffer.length),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
              ],
              const Spacer(),
              _Keypad(onKey: _append, onBackspace: _backspace),
              if (widget.mode == AuthMode.verify && _biometricAvailable) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _onBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use fingerprint'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled ? AppColors.primary : AppColors.surfaceContainerHigh,
            border: Border.all(color: AppColors.outlineVariant),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onBackspace});

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  static const List<String> _rows = [
    '123',
    '456',
    '789',
    '_0<',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.split('').map((ch) {
              if (ch == '_') return const SizedBox(width: 64, height: 64);
              if (ch == '<') {
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: IconButton(
                    icon: const Icon(Icons.backspace_outlined),
                    onPressed: onBackspace,
                  ),
                );
              }
              return SizedBox(
                width: 64,
                height: 64,
                child: Material(
                  color: AppColors.surfaceContainerLowest,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onKey(ch),
                    child: Center(
                      child: Text(
                        ch,
                        style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
