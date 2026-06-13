import type { PaymentRequestInput } from './payments.schema.js';
import { getAdapter } from './providers/index.js';
import { prisma } from '../../config/prisma.js';
import { notFound } from '../../core/errors/AppError.js';

export async function initiate(
  userId: string,
  input: PaymentRequestInput,
  deviceFingerprint?: string,
) {
  // Idempotency check
  const existingKey = await prisma.idempotencyKey.findUnique({
    where: { key: input.idempotencyKey },
  });
  if (existingKey) {
    return existingKey.responseBody as { providerTxnId: string; status: string };
  }

  const adapter = getAdapter(input.providerId);

  const initiation =
    input.type === 'MERCHANT_PAYMENT'
      ? await adapter.initiate({
          providerId: input.providerId,
          type: input.type,
          amountMinorUnits: input.amountMinorUnits,
          currency: input.currency,
          recipientPhone: input.recipientPhone,
          merchantName: input.merchantName,
          idempotencyKey: input.idempotencyKey,
          deviceFingerprint,
        })
      : await adapter.launchDialerPassThrough({
          providerId: input.providerId,
          type: input.type,
          amountMinorUnits: input.amountMinorUnits,
          currency: input.currency,
          recipientPhone: input.recipientPhone,
          idempotencyKey: input.idempotencyKey,
          deviceFingerprint,
        });

  const tx = await prisma.transaction.create({
    data: {
      userId,
      provider: input.providerId.toUpperCase() as 'BKASH' | 'NAGAD' | 'ROCKET',
      type: input.type,
      status: 'INITIATED',
      amountMinorUnits: input.amountMinorUnits,
      currency: input.currency,
      recipientPhone: input.recipientPhone ?? null,
      merchantName: input.merchantName ?? null,
      providerTxnId: initiation.providerTxnId ?? null,
      idempotencyKey: input.idempotencyKey,
      deviceFingerprint: deviceFingerprint ?? null,
      metadata: initiation.metadata ?? undefined,
    },
  });

  return {
    transactionId: tx.id,
    providerTxnId: tx.providerTxnId,
    status: tx.status,
    instructions: initiation.instructions,
    redirectUrl: initiation.redirectUrl,
    expiresAt: initiation.expiresAt,
  };
}

export async function getStatus(providerTxnId: string) {
  const tx = await prisma.transaction.findUnique({ where: { providerTxnId } });
  if (!tx) throw notFound('TXN_NOT_FOUND', 'Transaction not found');

  const adapter = getAdapter(tx.provider.toLowerCase() as 'bkash' | 'nagad' | 'rocket');
  const remoteStatus = await adapter.pollStatus(providerTxnId);

  if (remoteStatus.status !== tx.status) {
    await prisma.transaction.update({
      where: { id: tx.id },
      data: { status: remoteStatus.status as typeof tx.status },
    });
  }

  return {
    transactionId: tx.id,
    providerTxnId,
    status: remoteStatus.status,
    updatedAt: remoteStatus.updatedAt,
  };
}

export async function getReceipt(providerTxnId: string) {
  const tx = await prisma.transaction.findUnique({ where: { providerTxnId } });
  if (!tx) throw notFound('TXN_NOT_FOUND', 'Transaction not found');
  const adapter = getAdapter(tx.provider.toLowerCase() as 'bkash' | 'nagad' | 'rocket');
  return adapter.fetchReceipt(providerTxnId);
}
