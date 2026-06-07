import 'dotenv/config';
import { z } from 'zod';

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),

    PORT: z.coerce.number().int().positive().default(4000),
    HOST: z.string().default('0.0.0.0'),
    CORS_ORIGIN: z.string().default('http://localhost:3000'),
    REQUEST_TIMEOUT_MS: z.coerce.number().int().positive().default(30_000),

    DATABASE_URL: z.string().url(),
    REDIS_URL: z.string().url(),

    JWT_ACCESS_SECRET: z.string().min(32),
    JWT_REFRESH_SECRET: z.string().min(32),
    JWT_ACCESS_TTL: z.string().default('15m'),
    JWT_REFRESH_TTL: z.string().default('7d'),

    BCRYPT_ROUNDS: z.coerce.number().int().min(8).max(14).default(12),

    // bKash
    BKASH_BASE_URL: z.string().url().default('https://tokenized.sandbox.bka.sh/v1.2.0-beta'),
    BKASH_APP_KEY: z.string().default(''),
    BKASH_APP_SECRET: z.string().default(''),
    BKASH_USERNAME: z.string().default(''),
    BKASH_PASSWORD: z.string().default(''),
    BKASH_CALLBACK_URL: z.string().url().optional(),

    // Nagad
    NAGAD_BASE_URL: z.string().url().default('https://sandbox.mynagad.com:10061/api/dfs-service'),
    NAGAD_MERCHANT_ID: z.string().default(''),
    NAGAD_PG_PUBLIC_KEY: z.string().default(''),
    NAGAD_MERCHANT_PRIVATE_KEY: z.string().default(''),

    // Rate limiting
    RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(60_000),
    RATE_LIMIT_MAX_GLOBAL: z.coerce.number().int().positive().default(200),
    RATE_LIMIT_MAX_PER_USER: z.coerce.number().int().positive().default(60),

    // OTP
    OTP_TTL_SECONDS: z.coerce.number().int().positive().default(300),
    OTP_MAX_ATTEMPTS: z.coerce.number().int().positive().default(5),
  })
  .strict();

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  // eslint-disable-next-line no-console
  console.error('❌ Invalid environment variables:');
  // eslint-disable-next-line no-console
  console.error(parsed.error.format());
  process.exit(1);
}

export const env = parsed.data;
export type Env = z.infer<typeof envSchema>;
