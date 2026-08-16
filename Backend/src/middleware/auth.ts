import { NextFunction, Request, Response } from 'express';
import { AppError } from '../lib/errors';
import { verifyAccessToken } from '../lib/jwt';

declare module 'express-serve-static-core' {
  interface Request {
    userId: string;
  }
}

const BEARER_PREFIX = 'Bearer ';

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const header = req.header('Authorization');
  if (!header || !header.startsWith(BEARER_PREFIX)) {
    next(AppError.unauthorized('Missing or malformed Authorization header.'));
    return;
  }

  const token = header.slice(BEARER_PREFIX.length).trim();
  if (token.length === 0) {
    next(AppError.unauthorized('Missing bearer token.'));
    return;
  }

  try {
    const payload = verifyAccessToken(token);
    req.userId = payload.sub;
    next();
  } catch {
    next(AppError.unauthorized('Invalid or expired access token.'));
  }
}
