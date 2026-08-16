import { NextFunction, Request, Response } from 'express';
import { z, ZodTypeAny } from 'zod';
import { AppError } from '../lib/errors';

function firstIssueMessage(error: z.ZodError): string {
  const issue = error.issues[0];
  if (!issue) {
    return 'Invalid request.';
  }
  const path = issue.path.join('.');
  return path ? `${path}: ${issue.message}` : issue.message;
}

export function validateBody<Schema extends ZodTypeAny>(schema: Schema) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      next(AppError.validation(firstIssueMessage(result.error)));
      return;
    }
    req.body = result.data;
    next();
  };
}

export function validateQuery<Schema extends ZodTypeAny>(schema: Schema) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      next(AppError.validation(firstIssueMessage(result.error)));
      return;
    }
    req.validatedQuery = result.data;
    next();
  };
}

export function validateParams<Schema extends ZodTypeAny>(schema: Schema) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.params);
    if (!result.success) {
      next(AppError.validation(firstIssueMessage(result.error)));
      return;
    }
    req.validatedParams = result.data;
    next();
  };
}

declare module 'express-serve-static-core' {
  interface Request {
    validatedQuery?: unknown;
    validatedParams?: unknown;
  }
}
