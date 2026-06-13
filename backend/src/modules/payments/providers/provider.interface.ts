/**
 * Provider integration contract.
 *
 * Every MFS provider (bKash, Nagad, Rocket) implements this interface.
 * Swapping a mock adapter for a live one requires NO changes to
 * screens or repositories — see SYSTEM_ARCHITECTURE.md §3 and
 * ARCHITECTURE_DECISIONS.md AD-001.
 *
 * CRITICAL: The contract MUST NOT carry a provider PIN. The
 * `PaymentRequest` type contains only fields our stack is allowed to
 * know. See SECURITY_REVIEW.md §2.
 */

export type ProviderId = 'bkash' | 'nagad' | 'rocket';

export type TransactionType = 'MERCHANT_PAYMENT' | 'P2P_SEND' | 'CASH_OUT' | 'BILL_PAY';

export type PaymentStatusValue =
  | 'PENDING'
  | 'INITIATED'
  | 'PROCESSING'
  | 'SUCCESS'
  | 'FAILED'
  | 'CANCELLED'
  | 'EXPIRED';

export interface PaymentRequest {
  providerId: ProviderId;
  type: TransactionType;
  amountMinorUnits: number; // integer paisa
  currency: 'BDT';
  recipientPhone?: string; // E.164
  merchantName?: string;
  idempotencyKey: string;
  deviceFingerprint?: string;
}

export interface PaymentInitiation {
  providerTxnId?: string;
  redirectUrl?: string; // for web checkout (bKash tokenized)
  status: PaymentStatusValue;
  expiresAt?: string; // ISO 8601
  instructions?: {
    ussdString?: string; // pre-filled dialer string, e.g. `tel:*247%23`
    method: 'API' | 'DIALER_PASS_THROUGH' | 'PROVIDER_APP';
  };
  metadata?: Record<string, unknown>;
}

export interface PaymentStatus {
  providerTxnId: string;
  status: PaymentStatusValue;
  amountMinorUnits?: number;
  updatedAt: string;
}

export interface PaymentReceipt {
  providerTxnId: string;
  providerId: ProviderId;
  type: TransactionType;
  status: PaymentStatusValue;
  amountMinorUnits: number;
  currency: 'BDT';
  recipientPhone?: string;
  merchantName?: string;
  feeMinorUnits?: number;
  completedAt?: string;
  metadata?: Record<string, unknown>;
}

export interface ProviderAdapter {
  readonly id: ProviderId;

  /** Start a payment. Returns instructions for the client. */
  initiate(req: PaymentRequest): Promise<PaymentInitiation>;

  /** Poll for the latest status. */
  pollStatus(providerTxnId: string): Promise<PaymentStatus>;

  /** Fetch the final receipt (call after status === SUCCESS/FAILED). */
  fetchReceipt(providerTxnId: string): Promise<PaymentReceipt>;

  /** Build the dialer pass-through URI for unsupported transaction types. */
  launchDialerPassThrough(req: PaymentRequest): Promise<PaymentInitiation>;
}
