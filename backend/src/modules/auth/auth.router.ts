import { Router } from 'express';

import {
  type LoginInput,
  type RegisterInput,
  type SetPinInput,
  type VerifyOtpInput,
  loginSchema,
  registerSchema,
  setPinSchema,
  verifyOtpSchema,
} from './auth.schema.js';
import * as authService from './auth.service.js';
import { requireAuth } from '../../core/middleware/authMiddleware.js';
import { perUserRateLimiter } from '../../core/middleware/rateLimit.js';
import { validate } from '../../core/middleware/validate.js';

const router = Router();

router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const body: RegisterInput = req.body;
    const out = await authService.register(body);
    res.status(202).json(out);
  } catch (err) {
    next(err);
  }
});

router.post('/verify-otp', validate(verifyOtpSchema), async (req, res, next) => {
  try {
    const body: VerifyOtpInput = req.body;
    const out = await authService.verifyOtp(body);
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
      const body: SetPinInput = req.body;
      const out = await authService.setPin(req.userId!, body);
      res.status(200).json(out);
    } catch (err) {
      next(err);
    }
  },
);

router.post('/login', validate(loginSchema), async (req, res, next) => {
  try {
    const body: LoginInput = req.body;
    const out = await authService.login(body);
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
});

router.post('/refresh', (req, res, next) => {
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
