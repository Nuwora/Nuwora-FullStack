import { PrismaClient } from '@prisma/client';
import { withIdempotency } from '../../lib/idempotency';
import { unlockEligibleAchievements } from '../../domain/achievements';
import { loadAchievementStats } from '../../domain/stats';
import { MoodCheckInInput } from './schema';

export async function logMood(
  prisma: PrismaClient,
  userId: string,
  input: MoodCheckInInput,
): Promise<void> {
  await withIdempotency(
    prisma,
    { userId, clientMutationID: input.clientMutationID, mutationType: 'mood_check_in' },
    async (tx) => {
      await tx.moodEntry.create({
        data: { userId, mood: input.mood, occurredAt: input.occurredAt },
      });
      const stats = await loadAchievementStats(tx, userId);
      await unlockEligibleAchievements(tx, userId, stats);
      return null;
    },
  );
}
