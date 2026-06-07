import { z } from 'zod';

import { phoneSchema, providerIdSchema } from '../auth/auth.schema.js';

export const paymentRequestSchema = z
  .object({
    providerId: providerIdSchema,
    type: z.enum(['MERCHANT_PAYMENT', 'P2P_SEND', 'CASH_OUT', 'BILL_PAY']),
    amountMinorUnits: z.number().int().min(100), // ৳1.00 minimum
    currency: z.literal('BDT'),
    recipientPhone: phoneSchema.optional(),
    merchantName: z.string().max(120).optional(),
    idempotencyKey: z.string().uuid(),
  })
  .strict();

export const paymentStatusQuerySchema = z
  .object({
    providerTxnId: z.string().min(1).max(120),
  })
  .strict();

export type PaymentRequestInput = z.infer<typeof paymentRequestSchema>;
export type PaymentStatusQueryInput = z.infer<typeof paymentStatusQuerySchema>;
