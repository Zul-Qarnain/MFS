import bcrypt from 'bcrypt';

import { env } from '../../config/env.js';

/**
 * Hash a value with bcrypt. Cost is controlled by BCRYPT_ROUNDS in env.
 *
 * Used for the user's app-unlock PIN. NEVER call this with a provider PIN
 * — provider PINs are architecturally excluded from this stack (see
 * `docs/design_tokens.md`, SECURITY_REVIEW.md §2).
 */
export async function hashSecret(plain: string): Promise<string> {
  return bcrypt.hash(plain, env.BCRYPT_ROUNDS);
}

export async function verifySecret(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
