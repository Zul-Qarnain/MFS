import type {
  PaymentInitiation,
  PaymentReceipt,
  PaymentRequest,
  PaymentStatus,
} from './provider.interface.js';

/**
 * Shared helpers for mock adapters (Nagad, Rocket, and the P2P/Cash Out
 * portion of bKash). Each mock returns deterministic responses suitable
 * for development and Play Store screenshots.
 */

export const MOCK_PROVIDER_TXN_PREFIX = 'MOCK-';

export function encodeUssd(raw: string): string {
  return `tel:${raw.replace(/#/g, '%23')}`;
}

export function mockReceiptFromRequest(
  req: PaymentRequest,
  providerTxnId: string,
  status: 'SUCCESS' | 'FAILED' = 'SUCCESS',
): PaymentReceipt {
  return {
    providerTxnId,
    providerId: req.providerId,
    type: req.type,
    status,
    amountMinorUnits: req.amountMinorUnits,
    currency: req.currency,
    recipientPhone: req.recipientPhone,
    merchantName: req.merchantName,
    feeMinorUnits: 0,
    completedAt: status === 'SUCCESS' ? new Date().toISOString() : undefined,
    metadata: { mock: true },
  };
}

export function mockStatus(providerTxnId: string, status: PaymentStatus['status']): PaymentStatus {
  return {
    providerTxnId,
    status,
    updatedAt: new Date().toISOString(),
  };
}

export function mockInitiation(
  _req: PaymentRequest,
  opts: {
    providerTxnId: string;
    ussdString?: string;
    redirectUrl?: string;
  },
): PaymentInitiation {
  return {
    providerTxnId: opts.providerTxnId,
    redirectUrl: opts.redirectUrl,
    status: 'INITIATED',
    expiresAt: new Date(Date.now() + 10 * 60_000).toISOString(),
    instructions: {
      method: opts.ussdString ? 'DIALER_PASS_THROUGH' : 'API',
      ussdString: opts.ussdString ? encodeUssd(opts.ussdString) : undefined,
    },
    metadata: { mock: true },
  };
}

export type { PaymentInitiation, PaymentReceipt, PaymentRequest, PaymentStatus };
