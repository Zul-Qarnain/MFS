import { Router } from 'express';

import {
  type PaymentRequestInput,
  paymentRequestSchema,
  paymentStatusQuerySchema,
} from './payments.schema.js';
import * as paymentsService from './payments.service.js';
import { listProviders } from './providers/index.js';
import { requireAuth } from '../../core/middleware/authMiddleware.js';
import { perUserRateLimiter } from '../../core/middleware/rateLimit.js';
import { validate } from '../../core/middleware/validate.js';

const router = Router();

router.use(requireAuth);

router.get('/providers', (_req, res) => {
  res.json({ providers: listProviders() });
});

router.post(
  '/initiate',
  perUserRateLimiter,
  validate(paymentRequestSchema),
  async (req, res, next) => {
    try {
      const body: PaymentRequestInput = req.body;
      const out = await paymentsService.initiate(req.userId!, body, req.deviceFingerprint);
      res.status(202).json(out);
    } catch (err) {
      next(err);
    }
  },
);

router.get('/status', validate(paymentStatusQuerySchema, 'query'), async (req, res, next) => {
  try {
    const out = await paymentsService.getStatus(req.query.providerTxnId as string);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

router.get('/receipt', validate(paymentStatusQuerySchema, 'query'), async (req, res, next) => {
  try {
    const out = await paymentsService.getReceipt(req.query.providerTxnId as string);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

export default router;
