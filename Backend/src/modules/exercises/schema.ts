import { z } from 'zod';

export const exerciseIdParamSchema = z.object({
  id: z.string().uuid('Exercise id must be a UUID string'),
});

export const completeExerciseSchema = z.object({
  performance: z
    .number()
    .min(0, 'performance must be between 0 and 1')
    .max(1, 'performance must be between 0 and 1'),
  completedAt: z.coerce.date(),
  clientMutationID: z.string().uuid('clientMutationID must be a UUID string'),
});

export const skipExerciseSchema = z.object({
  skippedAt: z.coerce.date(),
  clientMutationID: z.string().uuid('clientMutationID must be a UUID string'),
});

export type CompleteExerciseInput = z.infer<typeof completeExerciseSchema>;
export type SkipExerciseInput = z.infer<typeof skipExerciseSchema>;
