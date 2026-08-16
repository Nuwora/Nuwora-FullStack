import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateQuery } from '../../middleware/validate';
import { scoresQuerySchema, ScoresQuery } from './schema';
import { fetchCorrelationInsights, fetchScores, fetchWeeklySummary } from './service';

export const analyticsRouter = Router();

analyticsRouter.get(
  '/analytics/scores',
  validateQuery(scoresQuerySchema),
  async (req, res, next) => {
    try {
      const query = req.validatedQuery as ScoresQuery;
      const scores = await fetchScores(prisma, req.userId, query.period, query.page);
      res.status(200).json(scores);
    } catch (error) {
      next(error);
    }
  },
);

analyticsRouter.get('/analytics/correlations', (_req, res) => {
  res.status(200).json(fetchCorrelationInsights());
});

analyticsRouter.get('/analytics/weekly-summary', async (req, res, next) => {
  try {
    const summary = await fetchWeeklySummary(prisma, req.userId);
    res.status(200).json({ summary });
  } catch (error) {
    next(error);
  }
});
