/**
 * PII-mask filter for logs.
 *
 * Replaces patterns commonly containing personally-identifiable information
 * with a masked form that preserves only the last 4 characters.
 *
 * SECURITY_REVIEW.md §9.1 — phone numbers, OTPs, tokens, and auth headers
 * must NEVER be logged in plaintext.
 */

const PHONE_RE = /\+?\d[\d\s-]{6,}\d/g;
const TOKEN_RE = /(Bearer\s+)[\w.-]+/gi;
const EMAIL_RE = /([a-zA-Z0-9._%+-]{1,2})[a-zA-Z0-9._%+-]*(@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g;

export function maskPii(input: string): string {
  if (!input) return input;

  let out = input;
  out = out.replace(TOKEN_RE, (_, prefix) => `${prefix}***`);
  out = out.replace(EMAIL_RE, (_, head, domain) => `${head}***${domain}`);
  out = out.replace(PHONE_RE, (match) => {
    const last4 = match.replace(/\D/g, '').slice(-4);
    return `+880 ***${last4}`;
  });
  return out;
}
