import type { NextFunction, Request, Response } from 'express';

import { unauthorized } from '../errors/AppError.js';
import { verifyAccessToken } from '../security/jwt.js';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId?: string;
      deviceId?: string;
      deviceFingerprint?: string;
    }
  }
}

/**
 * Verifies the Bearer JWT and populates `req.userId`, `req.deviceId`,
 * `req.deviceFingerprint`. Throws 401 on failure.
 */
export function requireAuth(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw unauthorized('AUTH_MISSING_TOKEN', 'Authorization header missing or malformed');
  }

  const token = header.slice(7);
  const payload = verifyAccessToken(token);

  const reported = req.headers['x-device-fingerprint'];
  if (reported && reported !== payload.deviceFingerprint) {
    throw unauthorized('AUTH_DEVICE_MISMATCH', 'Device fingerprint does not match bound session');
  }

  req.userId = payload.sub;
  req.deviceId = payload.deviceId;
  req.deviceFingerprint = payload.deviceFingerprint;

  next();
}
