import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { loadAchievements, loadProfile } from './service';

export const meRouter = Router();

meRouter.get('/me', async (req, res, next) => {
  try {
    const profile = await loadProfile(prisma, req.userId);
    res.status(200).json(profile);
  } catch (error) {
    next(error);
  }
});

meRouter.get('/me/achievements', async (req, res, next) => {
  try {
    const achievements = await loadAchievements(prisma, req.userId);
    res.status(200).json(achievements);
  } catch (error) {
    next(error);
  }
});
