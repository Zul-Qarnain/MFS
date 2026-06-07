import { prisma } from '../../config/prisma.js';
import { env } from '../../config/env.js';
import { hashSecret, verifySecret } from '../../core/security/hash.js';
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  type AccessTokenPayload,
} from '../../core/security/jwt.js';
import { badRequest, unauthorized, conflict } from '../../core/errors/AppError.js';

import type { LoginInput, RegisterInput, SetPinInput, VerifyOtpInput } from './auth.schema.js';

function buildOtp(): { otp: string; hash: string } {
  // The OTP is 6 digits, logged/returned to the client only through an
  // SMS gateway (mock in dev, real in prod). NEVER log the plaintext.
  const otp = Math.floor(100_000 + Math.random() * 900_000).toString();
  return { otp, hash: '' }; // hash assigned below after async call
}

export async function register(input: RegisterInput) {
  const existing = await prisma.user.findUnique({ where: { phone: input.phone } });
  if (existing) {
    throw conflict('AUTH_USER_EXISTS', 'A user with this phone already exists');
  }

  const { otp, hash: _stub } = buildOtp();
  const otpHash = await hashSecret(otp);

  const session = await prisma.otpSession.create({
    data: {
      phone: input.phone,
      purpose: 'REGISTER',
      otpHash,
      expiresAt: new Date(Date.now() + env.OTP_TTL_SECONDS * 1000),
    },
  });

  // TODO(B3-live-providers): send OTP via SMS gateway (SSL Wireless / MimSMS).
  // In development we echo the OTP for integration tests ONLY.
  const echoInDev = env.NODE_ENV === 'development' || env.NODE_ENV === 'test';

  return {
    sessionId: session.id,
    expiresIn: env.OTP_TTL_SECONDS,
    ...(echoInDev ? { __devOtp: otp } : {}),
  };
}

export async function verifyOtp(input: VerifyOtpInput) {
  const session = await prisma.otpSession.findUnique({ where: { id: input.sessionId } });
  if (!session || session.phone !== input.phone || session.purpose !== input.purpose) {
    throw badRequest('AUTH_INVALID_SESSION', 'OTP session is invalid');
  }
  if (session.consumedAt) {
    throw badRequest('AUTH_OTP_CONSUMED', 'OTP has already been used');
  }
  if (session.expiresAt < new Date()) {
    throw badRequest('AUTH_OTP_EXPIRED', 'OTP has expired');
  }
  if (session.attempts >= env.OTP_MAX_ATTEMPTS) {
    throw badRequest('AUTH_OTP_EXHAUSTED', 'Too many OTP attempts');
  }

  const ok = await verifySecret(input.otp, session.otpHash);
  await prisma.otpSession.update({
    where: { id: session.id },
    data: { attempts: { increment: 1 }, consumedAt: ok ? new Date() : null },
  });
  if (!ok) throw badRequest('AUTH_OTP_INVALID', 'OTP is incorrect');

  if (input.purpose === 'REGISTER') {
    return { sessionId: session.id, verified: true, phone: session.phone };
  }

  // LOGIN → issue tokens
  const user = await prisma.user.findUnique({ where: { phone: session.phone } });
  if (!user) throw unauthorized('AUTH_USER_NOT_FOUND', 'No account for this phone');
  const device = await upsertDevice(user.id, input as unknown as { deviceFingerprint: string });
  return issueTokens(user.id, user.phone, device.id, device.fingerprint);
}

export async function createUserAfterOtp(
  sessionId: string,
  name: string,
  deviceFingerprint: string,
  deviceName?: string,
) {
  const session = await prisma.otpSession.findUnique({ where: { id: sessionId } });
  if (!session || !session.consumedAt) {
    throw badRequest('AUTH_INVALID_SESSION', 'OTP session not verified');
  }
  const existing = await prisma.user.findUnique({ where: { phone: session.phone } });
  if (existing) throw conflict('AUTH_USER_EXISTS', 'A user with this phone already exists');

  const user = await prisma.user.create({ data: { phone: session.phone, name } });
  const device = await prisma.device.create({
    data: { userId: user.id, fingerprint: deviceFingerprint, deviceName },
  });
  return issueTokens(user.id, user.phone, device.id, device.fingerprint);
}

export async function login(input: LoginInput) {
  const user = await prisma.user.findUnique({ where: { phone: input.phone } });
  if (!user) throw unauthorized('AUTH_USER_NOT_FOUND', 'No account for this phone');

  const { otp, hash: _stub } = buildOtp();
  const otpHash = await hashSecret(otp);

  const session = await prisma.otpSession.create({
    data: {
      userId: user.id,
      phone: user.phone,
      purpose: 'LOGIN',
      otpHash,
      expiresAt: new Date(Date.now() + env.OTP_TTL_SECONDS * 1000),
    },
  });

  const echoInDev = env.NODE_ENV === 'development' || env.NODE_ENV === 'test';
  return {
    sessionId: session.id,
    expiresIn: env.OTP_TTL_SECONDS,
    requiresPin: user.isPinSet,
    ...(echoInDev ? { __devOtp: otp } : {}),
  };
}

export async function setPin(userId: string, input: SetPinInput) {
  const pinHash = await hashSecret(input.pin);
  await prisma.user.update({ where: { id: userId }, data: { pinHash, isPinSet: true } });
  return { pinSet: true };
}

async function upsertDevice(userId: string, input: { deviceFingerprint: string }) {
  const existing = await prisma.device.findUnique({ where: { fingerprint: input.deviceFingerprint } });
  if (existing) {
    if (existing.userId !== userId) {
      throw badRequest('AUTH_DEVICE_BOUND_ELSEWHERE', 'This device is bound to another account');
    }
    return prisma.device.update({
      where: { id: existing.id },
      data: { lastSeenAt: new Date() },
    });
  }
  return prisma.device.create({ data: { userId, fingerprint: input.deviceFingerprint } });
}

function issueTokens(userId: string, phone: string, deviceId: string, deviceFingerprint: string) {
  const accessTokenPayload: AccessTokenPayload = {
    sub: userId,
    phone,
    deviceId,
    deviceFingerprint,
  };
  const accessToken = signAccessToken(accessTokenPayload);
  const refreshToken = signRefreshToken({
    sub: userId,
    deviceId,
    tokenType: 'refresh',
  });
  return {
    accessToken,
    refreshToken,
    expiresIn: env.JWT_ACCESS_TTL,
    user: { id: userId, phone },
  };
}

export function refresh(refreshToken: string) {
  const payload = verifyRefreshToken(refreshToken);
  // In a real flow we'd re-load the device + user here; for the scaffold
  // we re-sign a minimal access token.
  const accessToken = signAccessToken({
    sub: payload.sub,
    phone: '',
    deviceId: payload.deviceId,
    deviceFingerprint: '',
  });
  return { accessToken, expiresIn: env.JWT_ACCESS_TTL };
}
