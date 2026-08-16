import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateQuery } from '../../middleware/validate';
import { leaderboardQuerySchema, LeaderboardQuery } from './schema';
import { fetchLeaderboard } from './service';

export const leaderboardRouter = Router();

leaderboardRouter.get(
  '/leaderboard',
  validateQuery(leaderboardQuerySchema),
  async (req, res, next) => {
    try {
      const query = req.validatedQuery as LeaderboardQuery;
      const entries = await fetchLeaderboard(prisma, query.limit);
      res.status(200).json(entries);
    } catch (error) {
      next(error);
    }
  },
);
