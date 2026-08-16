import { z } from 'zod';

export const leaderboardQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(3),
});

export type LeaderboardQuery = z.infer<typeof leaderboardQuerySchema>;
