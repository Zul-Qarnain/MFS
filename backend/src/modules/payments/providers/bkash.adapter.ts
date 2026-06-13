import { randomUUID } from 'node:crypto';

import { mockInitiation, mockStatus } from './mock.helpers.js';
import type {
  PaymentInitiation,
  PaymentReceipt,
  PaymentRequest,
  PaymentStatus,
  ProviderAdapter,
} from './provider.interface.js';

/**
 * Mock bKash adapter.
 *
 * Phase B scope:
 *   - Merchant payments: LIVE via bKash Tokenized Checkout REST API.
 *     The production implementation goes here; for this scaffold it
 *     returns a mock redirect URL.
 *   - P2P / Cash Out: MOCK + dialer pass-through (USSD *247#).
 *
 * The live bKash implementation will replace the mock paths below in a
 * follow-up task. The interface and DTOs stay identical.
 */
export class BkashAdapter implements ProviderAdapter {
  readonly id = 'bkash' as const;

  async initiate(req: PaymentRequest): Promise<PaymentInitiation> {
    if (req.type === 'MERCHANT_PAYMENT') {
      return this.initiateMerchant(req);
    }
    return this.launchDialerPassThrough(req);
  }

  private initiateMerchant(req: PaymentRequest): Promise<PaymentInitiation> {
    // TODO(B3-live-providers): swap with real bKash tokenized checkout call.
    return Promise.resolve(
      mockInitiation(req, {
        providerTxnId: `BKASH-M-${randomUUID()}`,
        redirectUrl: `https://checkout.sandbox.bka.sh/v1.2.0-beta/payment/complete?mock=1&id=${req.idempotencyKey}`,
      }),
    );
  }

  launchDialerPassThrough(req: PaymentRequest): Promise<PaymentInitiation> {
    const ussd = `*247*1*${req.recipientPhone ?? ''}*${Math.floor(req.amountMinorUnits / 100)}#`;
    return Promise.resolve(
      mockInitiation(req, {
        providerTxnId: `BKASH-D-${randomUUID()}`,
        ussdString: ussd,
      }),
    );
  }

  pollStatus(providerTxnId: string): Promise<PaymentStatus> {
    return Promise.resolve(mockStatus(providerTxnId, 'SUCCESS'));
  }

  fetchReceipt(providerTxnId: string): Promise<PaymentReceipt> {
    return Promise.resolve({
      providerTxnId,
      providerId: 'bkash',
      type: 'MERCHANT_PAYMENT',
      status: 'SUCCESS',
      amountMinorUnits: 0,
      currency: 'BDT',
      feeMinorUnits: 0,
      completedAt: new Date().toISOString(),
      metadata: { mock: true },
    });
  }
}
