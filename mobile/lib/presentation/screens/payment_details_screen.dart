import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/provider_id.dart';
import '../../domain/entities/qr_payload.dart';
import '../../domain/value_objects/money.dart';
import '../router/app_router.dart';
import '../widgets/provider_selection_strip.dart';

/// Payment details — shown after a successful QR scan.
///
/// The scanned payload is passed via go_router's `extra` argument. The
/// user picks a provider (if not auto-detected), enters an amount if
/// the QR didn't carry one, and taps "Pay" to navigate to the
/// processing screen.
class PaymentDetailsScreen extends ConsumerStatefulWidget {
  const PaymentDetailsScreen({super.key, this.qrPayload});

  final Object? qrPayload;

  @override
  ConsumerState<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  late final QrPayload _payload;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _payload = widget.qrPayload is QrPayload
        ? widget.qrPayload! as QrPayload
        : const QrPayload(raw: '', kind: QrPayloadKind.unknown);
    _amount = TextEditingController(
      text: _payload.amountMinorUnits != null
          ? (_payload.amountMinorUnits! / 100).toStringAsFixed(2)
          : '',
    );
    if (_payload.providerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(providerSelectorProvider.notifier).hydrateFromQr(_payload);
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(providerSelectorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          const Text('Provider', style: AppTypography.titleLg),
          const SizedBox(height: 12),
          const ProviderSelectionStrip(),
          const SizedBox(height: 24),
          if (_payload.merchantName != null) ...[
            Text(_payload.merchantName!, style: AppTypography.headlineMd),
            const SizedBox(height: 4),
            if (_payload.merchantId != null)
              Text(_payload.merchantId!,
                  style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
          ],
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.amountDisplay,
            decoration: const InputDecoration(
              prefixText: '৳ ',
              labelText: 'Amount',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: AppSize.buttonPrimaryHeight,
            child: ElevatedButton(
              onPressed: provider == null ? null : _onPay,
              child: Text(provider == null ? 'Select a provider' : 'Pay with ${provider.displayName}'),
            ),
          ),
        ],
      ),
    );
  }

  void _onPay() {
    final major = double.tryParse(_amount.text) ?? 0;
    if (major <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    // TODO(validation sprint): call ProviderRepository.initiate(...) and
    // navigate to /processing while polling.
    context.push('${Routes.success}?id=MOCK-${DateTime.now().millisecondsSinceEpoch}');
  }
}

/// Used by the payment details screen to pre-format amounts; kept here so
/// the screen file is self-contained.
// ignore: unused_element
Money _toMoney(double major) => Money.fromMajor(major);
