import { NextFunction, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';

declare module 'express-serve-static-core' {
  interface Request {
    requestID: string;
  }
}

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const incoming = req.header('X-Request-ID');
  const requestID = incoming && incoming.trim().length > 0 ? incoming : uuidv4();
  req.requestID = requestID;
  res.setHeader('X-Request-ID', requestID);
  next();
}
