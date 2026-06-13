const phonePattern = /\+880\d{10}/g;
const otpPattern = /\b\d{6}\b/g;
const tokenPattern = /eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g;

export function maskPii(input: string): string {
  return input
    .replace(phonePattern, '+880***MASKED***')
    .replace(otpPattern, '***OTP***')
    .replace(tokenPattern, '***TOKEN***');
}
