import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/provider_id.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/value_objects/money.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';

/// Home dashboard — balance card, provider strip, quick-send avatars,
/// recent transactions streamed from Isar.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txRepoAsync = ref.watch(transactionRepositoryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('MFS Unified')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          children: [
            _BalanceCard(),
            const SizedBox(height: 24),
            const Text('Recent transactions', style: AppTypography.titleLg),
            const SizedBox(height: 12),
            txRepoAsync.when(
              data: (repo) => _RecentTransactions(repo: repo),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Failed to load transactions: $e'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.scan),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          colors: [AppColors.balanceGradientStart, AppColors.balanceGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: AppTypography.labelMd.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('৳ ', style: AppTypography.labelMd.copyWith(color: Colors.white)),
              Text('0.00', style: AppTypography.amountDisplay.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.repo});

  final TransactionRepository repo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final txns = snap.data!;
        if (txns.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No transactions yet',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _TransactionTile(tx: txns[i]),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final amount = Money(minorUnits: tx.amountMinorUnits, currency: tx.currency);
    final isCredit = tx.type.contains('RECEIVE') || tx.amountMinorUnits < 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProviderIcon(providerId: tx.providerId),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.merchantName ?? tx.recipientPhone ?? tx.type,
                    style: AppTypography.bodyLg),
                Text('${tx.status} • ${tx.createdAt.toLocal().toString().substring(0, 16)}',
                    style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            isCredit ? '+${amount.format()}' : '-${amount.format()}',
            style: AppTypography.titleLg.copyWith(
              color: isCredit ? AppColors.success : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.providerId});

  final String providerId;

  Color get _color {
    switch (providerId.toLowerCase()) {
      case 'bkash':
        return AppColors.bkash;
      case 'nagad':
        return AppColors.nagad;
      case 'rocket':
        return AppColors.rocket;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      alignment: Alignment.center,
      child: Text(
        providerId.substring(0, 1).toUpperCase(),
        style: TextStyle(color: _color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
