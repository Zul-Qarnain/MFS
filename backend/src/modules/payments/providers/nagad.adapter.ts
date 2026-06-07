import { randomUUID } from 'node:crypto';

import type {
  PaymentInitiation,
  PaymentReceipt,
  PaymentRequest,
  PaymentStatus,
  ProviderAdapter,
} from './provider.interface.js';
import { mockInitiation, mockReceiptFromRequest, mockStatus } from './mock.helpers.js';

/**
 * Mock Nagad adapter.
 *
 * Merchant API docs are gated; this adapter returns deterministic mock
 * responses conforming to the same DTOs as the live adapter will. Swapping
 * to the live implementation requires zero changes to callers.
 * See RISK_REGISTER.md R-PRV-01.
 */
export class NagadAdapter implements ProviderAdapter {
  readonly id = 'nagad' as const;

  async initiate(req: PaymentRequest): Promise<PaymentInitiation> {
    if (req.type === 'MERCHANT_PAYMENT') {
      return mockInitiation(req, {
        providerTxnId: `NAGAD-M-${randomUUID()}`,
        redirectUrl: `https://sandbox.mynagad.com:10061/api/dfs-service/mock/checkout?id=${req.idempotencyKey}`,
      });
    }
    return this.launchDialerPassThrough(req);
  }

  async launchDialerPassThrough(req: PaymentRequest): Promise<PaymentInitiation> {
    const ussd = `*167*1*${req.recipientPhone ?? ''}*${Math.floor(req.amountMinorUnits / 100)}#`;
    return mockInitiation(req, {
      providerTxnId: `NAGAD-D-${randomUUID()}`,
      ussdString: ussd,
    });
  }

  async pollStatus(providerTxnId: string): Promise<PaymentStatus> {
    return mockStatus(providerTxnId, 'SUCCESS');
  }

  async fetchReceipt(providerTxnId: string): Promise<PaymentReceipt> {
    return mockReceiptFromRequest(
      {
        providerId: 'nagad',
        type: 'MERCHANT_PAYMENT',
        amountMinorUnits: 0,
        currency: 'BDT',
        idempotencyKey: '',
      },
      providerTxnId,
    );
  }
}
