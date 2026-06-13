import { randomUUID } from 'node:crypto';

import { mockInitiation, mockReceiptFromRequest, mockStatus } from './mock.helpers.js';
import type {
  PaymentInitiation,
  PaymentReceipt,
  PaymentRequest,
  PaymentStatus,
  ProviderAdapter,
} from './provider.interface.js';

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

  launchDialerPassThrough(req: PaymentRequest): Promise<PaymentInitiation> {
    const ussd = `*167*1*${req.recipientPhone ?? ''}*${Math.floor(req.amountMinorUnits / 100)}#`;
    return Promise.resolve(
      mockInitiation(req, {
        providerTxnId: `NAGAD-D-${randomUUID()}`,
        ussdString: ussd,
      }),
    );
  }

  pollStatus(providerTxnId: string): Promise<PaymentStatus> {
    return Promise.resolve(mockStatus(providerTxnId, 'SUCCESS'));
  }

  fetchReceipt(providerTxnId: string): Promise<PaymentReceipt> {
    return Promise.resolve(
      mockReceiptFromRequest(
        {
          providerId: 'nagad',
          type: 'MERCHANT_PAYMENT',
          amountMinorUnits: 0,
          currency: 'BDT',
          idempotencyKey: '',
        },
        providerTxnId,
      ),
    );
  }
}
