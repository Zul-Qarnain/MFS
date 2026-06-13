import { randomUUID } from 'node:crypto';

import type { NextFunction, Request, Response } from 'express';

import { logger } from '../../utils/logger.js';

/**
 * Request logger — structured pino log line per request with PII masking.
 */
export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  const correlationId = (req.headers['x-correlation-id'] as string | undefined) ?? randomUUID();
  req.headers['x-correlation-id'] = correlationId;
  res.setHeader('X-Correlation-Id', correlationId);

  const startedAt = Date.now();
  res.on('finish', () => {
    const durationMs = Date.now() - startedAt;
    logger.info(
      {
        correlationId,
        method: req.method,
        route: req.originalUrl,
        status: res.statusCode,
        durationMs,
        userId: (req as Request & { userId?: string }).userId ?? null,
        deviceFingerprint: req.headers['x-device-fingerprint'] ?? null,
      },
      'request',
    );
  });

  next();
}
