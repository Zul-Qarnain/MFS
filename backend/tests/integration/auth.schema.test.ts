import { describe, expect, it } from 'vitest';

import {
  registerSchema,
  verifyOtpSchema,
  setPinSchema,
  loginSchema,
} from '../../src/modules/auth/auth.schema.js';

describe('auth schemas', () => {
  describe('registerSchema', () => {
    it('accepts a valid request', () => {
      expect(() =>
        registerSchema.parse({
          phone: '+8801712345678',
          name: 'Zayan',
          deviceFingerprint: 'a'.repeat(64),
        }),
      ).not.toThrow();
    });

    it('rejects non-E.164 phones', () => {
      expect(() =>
        registerSchema.parse({
          phone: '01712345678',
          name: 'Zayan',
          deviceFingerprint: 'a'.repeat(64),
        }),
      ).toThrow();
    });

    it('rejects unknown keys', () => {
      expect(() =>
        registerSchema.parse({
          phone: '+8801712345678',
          name: 'Zayan',
          deviceFingerprint: 'a'.repeat(64),
          extra: 1,
        }),
      ).toThrow();
    });
  });

  describe('verifyOtpSchema', () => {
    it('requires 6-digit OTP', () => {
      expect(() =>
        verifyOtpSchema.parse({
          phone: '+8801712345678',
          purpose: 'REGISTER',
          otp: '12345',
          sessionId: '00000000-0000-0000-0000-000000000000',
        }),
      ).toThrow();
    });
  });

  describe('setPinSchema', () => {
    it('accepts 4–6 digit PINs', () => {
      expect(() => setPinSchema.parse({ pin: '1234' })).not.toThrow();
      expect(() => setPinSchema.parse({ pin: '123456' })).not.toThrow();
    });

    it('rejects other lengths', () => {
      expect(() => setPinSchema.parse({ pin: '123' })).toThrow();
      expect(() => setPinSchema.parse({ pin: '1234567' })).toThrow();
    });
  });

  describe('loginSchema', () => {
    it('parses a valid login', () => {
      expect(() =>
        loginSchema.parse({
          phone: '+8801712345678',
          deviceFingerprint: 'b'.repeat(64),
        }),
      ).not.toThrow();
    });
  });
});
