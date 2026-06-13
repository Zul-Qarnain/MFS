import { z } from 'zod';

export const phoneSchema = z
  .string()
  .regex(/^\+\d{10,14}$/, 'Phone must be E.164 with 10–14 digits');

export const providerIdSchema = z.enum(['bkash', 'nagad', 'rocket']);

export const registerSchema = z
  .object({
    phone: phoneSchema,
    name: z.string().min(1).max(120),
    deviceFingerprint: z.string().min(32).max(128),
    deviceName: z.string().max(80).optional(),
  })
  .strict();

export const verifyOtpSchema = z
  .object({
    phone: phoneSchema,
    purpose: z.enum(['LOGIN', 'REGISTER', 'PIN_RESET']),
    otp: z.string().regex(/^\d{6}$/, 'OTP must be 6 digits'),
    sessionId: z.string().uuid(),
  })
  .strict();

export const setPinSchema = z
  .object({
    pin: z.string().regex(/^\d{4,6}$/, 'PIN must be 4–6 digits'),
  })
  .strict();

export const loginSchema = z
  .object({
    phone: phoneSchema,
    deviceFingerprint: z.string().min(32).max(128),
  })
  .strict();

export type RegisterInput = z.infer<typeof registerSchema>;
export type VerifyOtpInput = z.infer<typeof verifyOtpSchema>;
export type SetPinInput = z.infer<typeof setPinSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
