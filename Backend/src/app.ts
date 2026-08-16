import cors from 'cors';
import express, { Express, Router } from 'express';
import pinoHttp from 'pino-http';
import { env } from './env';
import { logger } from './logger';
import { requestIdMiddleware } from './middleware/requestId';
import { authMiddleware } from './middleware/auth';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { authRouter } from './modules/auth/router';
import { onboardingRouter } from './modules/onboarding/router';
import { dashboardRouter } from './modules/dashboard/router';
import { moodsRouter } from './modules/moods/router';
import { plansRouter } from './modules/plans/router';
import { exercisesRouter } from './modules/exercises/router';
import { coachRouter } from './modules/coach/router';
import { analyticsRouter } from './modules/analytics/router';
import { meRouter } from './modules/me/router';
import { leaderboardRouter } from './modules/leaderboard/router';

export function createApp(): Express {
  const app = express();

  app.disable('x-powered-by');
  app.use(requestIdMiddleware);
  app.use(
    pinoHttp({
      logger,
      genReqId: (req) => (req as express.Request).requestID,
      customLogLevel: (_req, res, err) => {
        if (err || res.statusCode >= 500) return 'error';
        if (res.statusCode >= 400) return 'warn';
        return 'info';
      },
    }),
  );
  app.use(
    cors({
      origin: env.corsOrigins,
    }),
  );
  app.use(express.json());

  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  const v1Router = Router();
  v1Router.use(authRouter);
  v1Router.use(authMiddleware);
  v1Router.use(onboardingRouter);
  v1Router.use(dashboardRouter);
  v1Router.use(moodsRouter);
  v1Router.use(plansRouter);
  v1Router.use(exercisesRouter);
  v1Router.use(coachRouter);
  v1Router.use(analyticsRouter);
  v1Router.use(meRouter);
  v1Router.use(leaderboardRouter);

  app.use('/v1', v1Router);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
