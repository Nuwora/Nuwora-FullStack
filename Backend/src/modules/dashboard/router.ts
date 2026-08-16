import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { loadDashboard } from './service';

export const dashboardRouter = Router();

dashboardRouter.get('/dashboard', async (req, res, next) => {
  try {
    const snapshot = await loadDashboard(prisma, req.userId);
    res.status(200).json(snapshot);
  } catch (error) {
    next(error);
  }
});
