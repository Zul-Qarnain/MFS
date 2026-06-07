import type { Request } from 'express';
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';

import { env } from '../../config/env.js';
import { getRedis } from '../../config/redis.js';

/**
 * Global rate limiter — per IP.
 */
export const globalRateLimiter = rateLimit({
  windowMs: env.RATE_LIMIT_WINDOW_MS,
  max: env.RATE_LIMIT_MAX_GLOBAL,
  standardHeaders: true,
  legacyHeaders: false,
  store: new RedisStore({
    sendCommand: async (...args: string[]) => {
      const r = getRedis();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-return
      return (r as any).sendCommand(args);
    },
  }),
  keyGenerator: (req: Request) => req.ip ?? 'unknown',
  message: {
    code: 'RATE_LIMIT',
    message: 'Too many requests',
  },
});

/**
 * Per-user rate limiter for write endpoints.
 * Requires the auth middleware to have populated `req.userId`.
 */
export const perUserRateLimiter = rateLimit({
  windowMs: env.RATE_LIMIT_WINDOW_MS,
  max: env.RATE_LIMIT_MAX_PER_USER,
  standardHeaders: true,
  legacyHeaders: false,
  store: new RedisStore({
    sendCommand: async (...args: string[]) => {
      const r = getRedis();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-return
      return (r as any).sendCommand(args);
    },
  }),
  keyGenerator: (req: Request) =>
    (req as Request & { userId?: string }).userId ?? req.ip ?? 'unknown',
  skip: (req) => !(req as Request & { userId?: string }).userId,
  message: {
    code: 'RATE_LIMIT',
    message: 'Too many requests',
  },
});
