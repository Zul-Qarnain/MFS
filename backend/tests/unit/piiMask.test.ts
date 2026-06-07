import { describe, expect, it } from 'vitest';

import { maskPii } from '../../src/core/middleware/piiMask.js';

describe('maskPii', () => {
  it('masks Bangladeshi phone numbers', () => {
    expect(maskPii('Call +8801712345678 now')).toBe('Call +880 ***5678 now');
  });

  it('masks Bearer tokens', () => {
    expect(maskPii('Authorization: Bearer abc.def.ghi')).toBe('Authorization: Bearer ***');
  });

  it('masks emails', () => {
    expect(maskPii('user john.doe@example.com logged in')).toMatch(/jo\*\*\*@example\.com/);
  });

  it('returns empty string untouched', () => {
    expect(maskPii('')).toBe('');
  });
});
