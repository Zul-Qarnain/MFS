import crypto from 'node:crypto';

/**
 * Compose a stable device fingerprint from Android-reported fields.
 *
 * The fingerprint binds a session to the physical device so stolen tokens
 * cannot be replayed from another handset. See SECURITY_REVIEW.md §5.
 *
 * Inputs must come from the Android client's `device_info_plus` +
 * per-install salt. Never include user-entered data.
 */
export interface DeviceFingerprintInput {
  androidId: string;
  packageName: string;
  deviceModel: string;
  manufacturer: string;
  osVersion: string;
  installSalt: string;
}

export function computeDeviceFingerprint(input: DeviceFingerprintInput): string {
  const blob = [
    input.androidId,
    input.packageName,
    input.deviceModel,
    input.manufacturer,
    input.osVersion,
    input.installSalt,
  ].join('|');

  return crypto.createHash('sha256').update(blob, 'utf8').digest('hex');
}
