import pino from 'pino';

import { env } from '../config/env.js';
import { maskPii } from './middleware/piiMask.js';

/**
 * Structured logger. PII is masked in every string argument before it is
 * written to the destination stream.
 */
export const logger = pino({
  level: env.LOG_LEVEL,
  base: { service: 'mfs-backend' },
  formatters: {
    level: (label) => ({ level: label }),
  },
  hooks: {
    logMethod(inputArgs, method) {
      const masked = inputArgs.map((arg) => (typeof arg === 'string' ? maskPii(arg) : arg));
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return method.apply(this, masked as any);
    },
  },
});
