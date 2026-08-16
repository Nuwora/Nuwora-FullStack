export type ErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'INTERNAL_ERROR';

const STATUS_BY_CODE: Record<ErrorCode, number> = {
  VALIDATION_ERROR: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_ERROR: 500,
};

export class AppError extends Error {
  readonly code: ErrorCode;
  readonly status: number;

  constructor(code: ErrorCode, message: string) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = STATUS_BY_CODE[code];
  }

  static validation(message: string): AppError {
    return new AppError('VALIDATION_ERROR', message);
  }

  static unauthorized(message = 'Authentication is required.'): AppError {
    return new AppError('UNAUTHORIZED', message);
  }

  static forbidden(message = 'You do not have permission for this action.'): AppError {
    return new AppError('FORBIDDEN', message);
  }

  static notFound(message = 'The requested resource was not found.'): AppError {
    return new AppError('NOT_FOUND', message);
  }

  static conflict(message: string): AppError {
    return new AppError('CONFLICT', message);
  }

  static internal(message = 'An unexpected error occurred.'): AppError {
    return new AppError('INTERNAL_ERROR', message);
  }
}
