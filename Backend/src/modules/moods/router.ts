import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateBody } from '../../middleware/validate';
import { moodCheckInSchema, MoodCheckInInput } from './schema';
import { logMood } from './service';

export const moodsRouter = Router();

moodsRouter.post('/moods', validateBody(moodCheckInSchema), async (req, res, next) => {
  try {
    await logMood(prisma, req.userId, req.body as MoodCheckInInput);
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});
