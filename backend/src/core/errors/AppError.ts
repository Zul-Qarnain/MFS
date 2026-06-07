/**
 * Base error class for the backend. Every thrown error should extend this
 * so the error-handler middleware can map it to a clean HTTP response.
 */
export class AppError extends Error {
  public readonly code: string;
  public readonly statusCode: number;
  public readonly details?: unknown;
  public readonly isOperational: boolean;

  constructor(opts: {
    code: string;
    message: string;
    statusCode?: number;
    details?: unknown;
    isOperational?: boolean;
  }) {
    super(opts.message);
    this.code = opts.code;
    this.statusCode = opts.statusCode ?? 500;
    this.details = opts.details;
    this.isOperational = opts.isOperational ?? true;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export function badRequest(code: string, message: string, details?: unknown): AppError {
  return new AppError({ code, message, statusCode: 400, details });
}

export function unauthorized(code: string, message: string): AppError {
  return new AppError({ code, message, statusCode: 401 });
}

export function forbidden(code: string, message: string): AppError {
  return new AppError({ code, message, statusCode: 403 });
}

export function notFound(code: string, message: string): AppError {
  return new AppError({ code, message, statusCode: 404 });
}

export function conflict(code: string, message: string): AppError {
  return new AppError({ code, message, statusCode: 409 });
}

export function rateLimited(retryAfterSeconds: number): AppError {
  return new AppError({
    code: 'RATE_LIMIT',
    message: 'Too many requests',
    statusCode: 429,
    details: { retryAfterSeconds },
  });
}
