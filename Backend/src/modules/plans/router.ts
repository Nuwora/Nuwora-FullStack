import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { ensureTodayPlan } from './service';
import { serializeExercise } from '../exercises/serializers';

export const plansRouter = Router();

plansRouter.get('/plans/today', async (req, res, next) => {
  try {
    const items = await ensureTodayPlan(prisma, req.userId);
    res.status(200).json(items.map((item) => serializeExercise(item.exercise, item.daily.status)));
  } catch (error) {
    next(error);
  }
});
