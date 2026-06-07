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
 * Mock Rocket adapter.
 *
 * DBBL has not published a public developer API. This adapter returns
 * deterministic mock responses. See RISK_REGISTER.md R-PRV-02.
 */
export class RocketAdapter implements ProviderAdapter {
  readonly id = 'rocket' as const;

  async initiate(req: PaymentRequest): Promise<PaymentInitiation> {
    if (req.type === 'MERCHANT_PAYMENT') {
      return mockInitiation(req, {
        providerTxnId: `ROCKET-M-${randomUUID()}`,
        redirectUrl: `https://sandbox.rocket.example.com/mock/checkout?id=${req.idempotencyKey}`,
      });
    }
    return this.launchDialerPassThrough(req);
  }

  async launchDialerPassThrough(req: PaymentRequest): Promise<PaymentInitiation> {
    const ussd = `*322*1*${req.recipientPhone ?? ''}*${Math.floor(req.amountMinorUnits / 100)}#`;
    return mockInitiation(req, {
      providerTxnId: `ROCKET-D-${randomUUID()}`,
      ussdString: ussd,
    });
  }

  async pollStatus(providerTxnId: string): Promise<PaymentStatus> {
    return mockStatus(providerTxnId, 'SUCCESS');
  }

  async fetchReceipt(providerTxnId: string): Promise<PaymentReceipt> {
    return mockReceiptFromRequest(
      {
        providerId: 'rocket',
        type: 'MERCHANT_PAYMENT',
        amountMinorUnits: 0,
        currency: 'BDT',
        idempotencyKey: '',
      },
      providerTxnId,
    );
  }
}
