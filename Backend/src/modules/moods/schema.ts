import { z } from 'zod';

export const moodCheckInSchema = z.object({
  mood: z
    .number()
    .int()
    .min(1, 'mood must be between 1 and 5')
    .max(5, 'mood must be between 1 and 5'),
  occurredAt: z.coerce.date(),
  clientMutationID: z.string().uuid('clientMutationID must be a UUID string'),
});

export type MoodCheckInInput = z.infer<typeof moodCheckInSchema>;
