import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateBody, validateParams } from '../../middleware/validate';
import {
  completeExerciseSchema,
  exerciseIdParamSchema,
  skipExerciseSchema,
  CompleteExerciseInput,
  SkipExerciseInput,
} from './schema';
import { completeExercise, skipExercise } from './service';

export const exercisesRouter = Router();

exercisesRouter.post(
  '/exercises/:id/complete',
  validateParams(exerciseIdParamSchema),
  validateBody(completeExerciseSchema),
  async (req, res, next) => {
    try {
      const { id } = req.validatedParams as { id: string };
      await completeExercise(prisma, req.userId, id, req.body as CompleteExerciseInput);
      res.status(204).end();
    } catch (error) {
      next(error);
    }
  },
);

exercisesRouter.post(
  '/exercises/:id/skip',
  validateParams(exerciseIdParamSchema),
  validateBody(skipExerciseSchema),
  async (req, res, next) => {
    try {
      const { id } = req.validatedParams as { id: string };
      await skipExercise(prisma, req.userId, id, req.body as SkipExerciseInput);
      res.status(204).end();
    } catch (error) {
      next(error);
    }
  },
);
