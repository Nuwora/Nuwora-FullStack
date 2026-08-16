import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import { validateBody } from '../../middleware/validate';
import { onboardingSchema, OnboardingInput } from './schema';
import { submitOnboarding } from './service';

export const onboardingRouter = Router();

onboardingRouter.post('/onboarding', validateBody(onboardingSchema), async (req, res, next) => {
  try {
    await submitOnboarding(prisma, req.userId, req.body as OnboardingInput);
    res.status(204).end();
  } catch (error) {
    next(error);
  }
});
