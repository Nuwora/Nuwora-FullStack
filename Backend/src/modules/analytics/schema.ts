import { z } from 'zod';

export const analyticsPeriodSchema = z.enum(['week', 'month', 'three_months']);

export const scoresQuerySchema = z.object({
  period: analyticsPeriodSchema,
  page: z.coerce.number().int().min(1).optional(),
});

export type ScoresQuery = z.infer<typeof scoresQuerySchema>;
