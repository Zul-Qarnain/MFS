import { Router } from 'express';

import { validate } from '../../core/middleware/validate.js';
import { requireAuth } from '../../core/middleware/authMiddleware.js';
import { perUserRateLimiter } from '../../core/middleware/rateLimit.js';

import * as authService from './auth.service.js';
import {
  loginSchema,
  registerSchema,
  setPinSchema,
  verifyOtpSchema,
} from './auth.schema.js';

const router = Router();

router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const out = await authService.register(req.body);
    res.status(202).json(out);
  } catch (err) {
    next(err);
  }
});

router.post('/verify-otp', validate(verifyOtpSchema), async (req, res, next) => {
  try {
    const out = await authService.verifyOtp(req.body);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

router.post(
  '/set-pin',
  requireAuth,
  perUserRateLimiter,
  validate(setPinSchema),
  async (req, res, next) => {
    try {
      const out = await authService.setPin(req.userId!, req.body);
      res.status(200).json(out);
    } catch (err) {
      next(err);
    }
  },
);

router.post('/login', validate(loginSchema), async (req, res, next) => {
  try {
    const out = await authService.login(req.body);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

router.post('/refresh', async (req, res, next) => {
  try {
    const token = (req.body as { refreshToken?: string }).refreshToken;
    if (!token) {
      res.status(400).json({ code: 'AUTH_MISSING_TOKEN', message: 'refreshToken required' });
      return;
    }
    const out = authService.refresh(token);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

export default router;
