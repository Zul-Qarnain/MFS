import type { NextFunction, Request, Response } from 'express';
import { type ZodSchema, ZodError } from 'zod';

import { badRequest } from '../errors/AppError.js';

type Source = 'body' | 'query' | 'params';

/**
 * Express middleware that validates a request source with a Zod schema
 * and replaces the source with the parsed (and type-narrowed) value.
 */
export function validate<T>(schema: ZodSchema<T>, source: Source = 'body') {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      const parsed = schema.parse(req[source]);
      (req as unknown as Record<Source, T>)[source] = parsed;
      next();
    } catch (err) {
      if (err instanceof ZodError) {
        throw badRequest('VALIDATION_ERROR', 'Request validation failed', err.issues);
      }
      next(err);
    }
  };
}
