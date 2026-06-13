import type { NextFunction, Request, Response } from 'express';

import { logger } from '../../utils/logger.js';
import { AppError } from '../errors/AppError.js';

/**
 * Final error handler. Must be registered AFTER all route handlers.
 */
export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction): void {
  const appErr =
    err instanceof AppError
      ? err
      : new AppError({
          code: 'INTERNAL_ERROR',
          message: 'An unexpected error occurred',
          statusCode: 500,
          isOperational: false,
        });

  if (!appErr.isOperational) {
    logger.error(
      {
        err,
        route: req.originalUrl,
        method: req.method,
        correlationId: req.headers['x-correlation-id'],
      },
      'Unhandled error',
    );
  }

  const body: Record<string, unknown> = {
    code: appErr.code,
    message: appErr.message,
  };
  if (appErr.details !== undefined) body.details = appErr.details;

  res.status(appErr.statusCode).json(body);
}
