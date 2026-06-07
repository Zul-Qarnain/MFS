import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/provider_id.dart';
import '../../domain/entities/qr_payload.dart';

part 'provider_selection_strip.g.dart';

/// State for the provider selection flow.
@riverpod
class ProviderSelector extends _$ProviderSelector {
  @override
  ProviderId? build() => null;

  void select(ProviderId id) => state = id;

  /// Initialise from a scanned QR payload — if it carries a provider,
  /// pre-select it; otherwise leave null so the user must choose.
  void hydrateFromQr(QrPayload payload) {
    state = payload.providerId;
  }
}

/// Horizontal scrolling list of provider avatars.
///
/// Active provider is highlighted with a 2 px [AppColors.primary] ring;
/// inactive providers are rendered in grayscale until selected.
class ProviderSelectionStrip extends ConsumerWidget {
  const ProviderSelectionStrip({super.key, this.onSelected});

  final ValueChanged<ProviderId>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(providerSelectorProvider);
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
        itemCount: ProviderId.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final id = ProviderId.values[i];
          final isActive = selected == id;
          return _ProviderTile(
            id: id,
            isActive: isActive,
            onTap: () {
              ref.read(providerSelectorProvider.notifier).select(id);
              onSelected?.call(id);
            },
          );
        },
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.id, required this.isActive, required this.onTap});

  final ProviderId id;
  final bool isActive;
  final VoidCallback onTap;

  Color get _brand {
    switch (id) {
      case ProviderId.bkash:
        return AppColors.bkash;
      case ProviderId.nagad:
        return AppColors.nagad;
      case ProviderId.rocket:
        return AppColors.rocket;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.providerAvatar,
            height: AppSize.providerAvatar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.outlineVariant,
                width: isActive ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Container(
                width: AppSize.providerAvatar - 16,
                height: AppSize.providerAvatar - 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brand.withOpacity(isActive ? 1.0 : 0.4),
                ),
                alignment: Alignment.center,
                child: Text(
                  id.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            id.displayName,
            style: AppTypography.labelMd.copyWith(
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
