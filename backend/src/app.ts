import cors from 'cors';
import express from 'express';
import helmet from 'helmet';

import { env } from './config/env.js';
import { errorHandler } from './core/middleware/errorHandler.js';
import { globalRateLimiter } from './core/middleware/rateLimit.js';
import { requestLogger } from './core/middleware/requestLogger.js';
import authRouter from './modules/auth/auth.router.js';
import healthRouter from './modules/health/health.router.js';
import paymentsRouter from './modules/payments/payments.router.js';

export function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(
    cors({
      origin: env.CORS_ORIGIN,
      credentials: true,
    }),
  );
  app.use(express.json({ limit: '64kb' }));

  app.use(requestLogger);
  app.use(globalRateLimiter);

  app.use('/', healthRouter);
  app.use('/auth', authRouter);
  app.use('/payments', paymentsRouter);

  // 404 for unmatched routes
  app.use((_req, res) => {
    res.status(404).json({ code: 'NOT_FOUND', message: 'Route not found' });
  });

  app.use(errorHandler);

  return app;
}
