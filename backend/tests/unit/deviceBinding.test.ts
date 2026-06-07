import { describe, expect, it } from 'vitest';

import { computeDeviceFingerprint } from '../../src/core/security/deviceBinding.js';

describe('computeDeviceFingerprint', () => {
  const input = {
    androidId: 'abcd1234',
    packageName: 'com.mfs.unified',
    deviceModel: 'Pixel 7',
    manufacturer: 'Google',
    osVersion: '14',
    installSalt: '0000000000000000',
  };

  it('returns a 64-char hex string', () => {
    const fp = computeDeviceFingerprint(input);
    expect(fp).toMatch(/^[a-f0-9]{64}$/);
  });

  it('is deterministic for the same input', () => {
    expect(computeDeviceFingerprint(input)).toBe(computeDeviceFingerprint(input));
  });

  it('differs when any field changes', () => {
    const a = computeDeviceFingerprint(input);
    const b = computeDeviceFingerprint({ ...input, osVersion: '15' });
    expect(a).not.toBe(b);
  });
});
