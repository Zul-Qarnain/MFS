import type { SignOptions, VerifyOptions } from 'jsonwebtoken';
import jwt from 'jsonwebtoken';

import { env } from '../../config/env.js';
import { unauthorized } from '../errors/AppError.js';

export interface AccessTokenPayload {
  sub: string; // userId
  phone: string;
  deviceId: string;
  deviceFingerprint: string;
}

export interface RefreshTokenPayload {
  sub: string; // userId
  deviceId: string;
  tokenType: 'refresh';
}

const ACCESS_TTL_SECONDS = parseTtl(env.JWT_ACCESS_TTL);
const REFRESH_TTL_SECONDS = parseTtl(env.JWT_REFRESH_TTL);

function parseTtl(ttl: string): number {
  const match = /^(\d+)([smhd])$/.exec(ttl);
  if (!match) return 15 * 60;
  const [, n, u] = match;
  const factor = { s: 1, m: 60, h: 3600, d: 86_400 }[u as 's' | 'm' | 'h' | 'd'] ?? 1;
  return Number(n) * factor;
}

export function signAccessToken(payload: AccessTokenPayload): string {
  const options: SignOptions = {
    expiresIn: ACCESS_TTL_SECONDS,
    issuer: 'mfs-unified',
    audience: 'mfs-client',
  };
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, options);
}

export function signRefreshToken(payload: RefreshTokenPayload): string {
  const options: SignOptions = {
    expiresIn: REFRESH_TTL_SECONDS,
    issuer: 'mfs-unified',
    audience: 'mfs-client',
  };
  return jwt.sign(payload, env.JWT_REFRESH_SECRET, options);
}

export function verifyAccessToken(token: string): AccessTokenPayload {
  try {
    const options: VerifyOptions = { issuer: 'mfs-unified', audience: 'mfs-client' };
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET, options);
    if (typeof decoded === 'string') throw new Error('scalar token');
    return decoded as AccessTokenPayload;
  } catch {
    throw unauthorized('AUTH_INVALID_TOKEN', 'Access token is invalid or expired');
  }
}

export function verifyRefreshToken(token: string): RefreshTokenPayload {
  try {
    const options: VerifyOptions = { issuer: 'mfs-unified', audience: 'mfs-client' };
    const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET, options);
    if (typeof decoded === 'string') throw new Error('scalar token');
    if ((decoded as RefreshTokenPayload).tokenType !== 'refresh') {
      throw new Error('not a refresh token');
    }
    return decoded as RefreshTokenPayload;
  } catch {
    throw unauthorized('AUTH_INVALID_TOKEN', 'Refresh token is invalid or expired');
  }
}

export { ACCESS_TTL_SECONDS, REFRESH_TTL_SECONDS };
